#!/usr/bin/env python3
"""
PD 固件 Blob 差异分析脚本
比较 N3GPD17W / N3GPH20W / N3GPH70W 三个 PD 控制器固件 blob

作者：逆向工程会话 (2026-03-XX)
用法：python3 scripts/analyze_pd_blobs_diff.py [--verbose]
"""

import struct
import sys
import os
from pathlib import Path
from collections import defaultdict

# ===== TLV 解析器 =====

def parse_pd_blob(data: bytes, name: str) -> dict | None:
    """
    解析 Microchip PD 固件 blob（从 FL2 提取的格式）。
    
    已确认的 blob 格式（以版本字符串偏移 vp 为参考）：
      vp - 0x22: FF FF FF FF（分隔符）
      vp - 0x1E: 01 00（格式版本 LE16 = 1）
      vp - 0x1C: XX XX（sub_blob_size LE16）
      vp - 0x1A: XX XX XX XX（校验 LE32）
      vp - 0x16: XX（num_ports）
      vp - 0x0A: FA XX（Microchip magic，高字节=FA）
      vp - 0x08: XX XX XX XX（端口配置 LE32）
      vp - 0x04: XX XX XX XX（预-TLV 字段）
      vp + 0x00: "N3GPxxxxW"（8字节版本ID）
      vp + 0x08: TLV 数据区（sub_blob_size 字节）
    
    TLV 数据区分四个子区：
      - 子区1: TAG1 [type_LE16] [len_byte] [data(len_byte+1 B)]  → 主配置参数
      - 子区2: 0x08 [type_LE16] [0x00] [data 1B]               → 寄存器写入序列
      - 子区3: LE16 单调递增数组                                → ADC 电流校正 LUT
      - 子区4: TAG [len3] [data(len3+1 B)]（混合 TAG）          → 充电曲线/CC/OCP 等
    
    子区1 的 TAG 字节因 blob 版本而异：
      N3GPD17W: TAG1 = 0x0C（USB-C 全功能端口）
      N3GPH20W: TAG1 = 0xFF（USB-C 全功能端口，不同布局）
      N3GPH70W: TAG1 = 0x0F（Thunderbolt/USB4 精简端口）
    
    Returns:
        解析结果字典，包含 header, sec1, sec2, sec3, sec4 等字段
    """
    vp = data.find(b'N3GP')
    if vp < 0 or vp < 0x22:
        return None
    
    # 读取头部字段
    sub_blob_size = struct.unpack_from('<H', data, vp - 0x1C)[0]
    checksum = struct.unpack_from('<I', data, vp - 0x1A)[0]
    num_ports = data[vp - 0x16]
    mchp_magic = data[vp - 0x0A:vp - 0x08]
    port_config = struct.unpack_from('<I', data, vp - 0x08)[0]
    pre_tlv = data[vp - 0x04:vp].hex(' ')
    
    tlv_start = vp + 8
    tlv_end = vp + sub_blob_size
    
    if tlv_end > len(data):
        tlv_end = len(data)
    
    config_tag = data[tlv_start]
    
    # === 子区1：主配置 TLV ===
    sec1 = []
    off = tlv_start
    while off < tlv_end - 4 and data[off] == config_tag:
        t = struct.unpack_from('<H', data, off + 1)[0]
        lb = data[off + 3]
        al = lb + 1
        d = bytes(data[off + 4:off + 4 + al])
        sec1.append({'type': t, 'len': al, 'data': d})
        off += 4 + al
    
    # === 子区2：寄存器写入 TLV (TAG=0x08) ===
    sec2 = []
    while off < tlv_end - 4 and data[off] == 0x08:
        t = struct.unpack_from('<H', data, off + 1)[0]
        lb = data[off + 3]
        al = lb + 1
        d = bytes(data[off + 4:off + 4 + al])
        sec2.append({'type': t, 'len': al, 'data': d})
        off += 4 + al
    
    # === 子区3：LE16 单调递增 LUT ===
    sec3 = []
    while off < tlv_end - 1:
        v = struct.unpack_from('<H', data, off)[0]
        if v == 0 or v > 0x0500:
            break
        if sec3 and v < sec3[-1] - 0x20:
            break
        sec3.append(v)
        off += 2
    # 步长异常大 (>50) 表示最后一个值实为 5X TAG 记录的开头字节，撤销
    if len(sec3) >= 2 and abs(sec3[-1] - sec3[-2]) > 50:
        sec3.pop()
        off -= 2
    
    # === 子区4：混合 TAG 记录 ===
    sec4 = []
    term_off = off  # 记录子区4起始位置
    while off < tlv_end - 2:
        tag = data[off]
        if tag in (0x00, 0xFF):
            break
        len3 = data[off + 1]
        if len3 > 80:
            off += 2
            continue
        payload = bytes(data[off + 2:off + 2 + len3 + 1])
        sec4.append({'tag': tag, 'len3': len3, 'payload': payload})
        off += len3 + 3
    
    return {
        'name': name,
        'version_pos': vp,
        'version_str': data[vp:vp + 8].decode('ascii', errors='replace'),
        'header': {
            'sub_blob_size': sub_blob_size,
            'checksum': checksum,
            'num_ports': num_ports,
            'mchp_magic': mchp_magic.hex(),
            'port_config': port_config,
            'config_tag': config_tag,
            'pre_tlv': pre_tlv,
        },
        'tlv_start': tlv_start,
        'tlv_end': tlv_end,
        'sec1': sec1,
        'sec2': sec2,
        'sec3': sec3,
        'sec4': sec4,
        'sec4_start_off': term_off,
    }


def diff_sec1(r1: dict, r2: dict) -> list:
    """对比两个 blob 的 SEC1 记录，返回差异列表。"""
    types1 = {r['type']: r for r in r1['sec1']}
    types2 = {r['type']: r for r in r2['sec1']}
    all_types = sorted(set(types1) | set(types2))
    diffs = []
    for t in all_types:
        has1 = t in types1
        has2 = t in types2
        if not has1:
            diffs.append(('only_in_2', t, None, types2[t]))
        elif not has2:
            diffs.append(('only_in_1', t, types1[t], None))
        elif types1[t]['data'] != types2[t]['data']:
            diffs.append(('data_diff', t, types1[t], types2[t]))
    return diffs


def print_header_comparison(blobs: list[dict]) -> None:
    """打印多个 blob 的头部对比表。"""
    fields = ['sub_blob_size', 'config_tag', 'num_ports', 'mchp_magic', 'port_config', 'checksum']
    names = [b['name'] for b in blobs]
    col_w = 14
    name_w = 16

    print("=" * 70)
    print("PD Blob 头部对比")
    print("=" * 70)
    hdr = f"{'字段':<{name_w}}" + "".join(f"{n:>{col_w}}" for n in names)
    print(hdr)
    print("-" * (name_w + col_w * len(blobs)))
    
    for k in fields:
        vals = [b['header'][k] for b in blobs]
        row = f"  {k:<{name_w-2}}"
        for v in vals:
            if isinstance(v, int):
                if v > 0xFFFF:
                    row += f"{v:#010x}".rjust(col_w)
                elif v > 0xFF:
                    row += f"{v:#06x}".rjust(col_w)
                else:
                    row += str(v).rjust(col_w)
            else:
                row += str(v).rjust(col_w)
        # 标注全部相同的行
        if len(set(map(str, vals))) == 1:
            row += "  ← 相同"
        print(row)
    
    print()
    print("mchp_magic 含义推测：")
    magic_map = {'fa8e': 'USB-C 全功能左端口 (D系 PD控制器)', 
                 'fa82': 'USB-C 全功能右端口 (H2x PD控制器)',
                 'fa3a': 'Thunderbolt/USB4 端口控制器 (H7x)'}
    for b in blobs:
        m = b['header']['mchp_magic']
        print(f"  {b['name']}: {m} → {magic_map.get(m, '未知')}")
    print()


def print_sec1_diff_table(r1: dict, r2: dict, verbose: bool = False) -> None:
    """打印两个 blob 之间的 SEC1 差异。"""
    diffs = diff_sec1(r1, r2)
    name1, name2 = r1['name'], r2['name']
    
    print(f"--- {name1} vs {name2} ---")
    print(f"  SEC1 条目: {name1}={len(r1['sec1'])}, {name2}={len(r2['sec1'])}")
    
    if not diffs:
        print("  SEC1 完全相同")
        return
    
    print(f"  差异: {len(diffs)} 处")
    for kind, t, rec1, rec2 in diffs:
        if kind == 'only_in_1':
            print(f"  type={t:#06x}({t:3d}): 仅 {name1} len={rec1['len']} data={rec1['data'][:8].hex(' ')}")
        elif kind == 'only_in_2':
            print(f"  type={t:#06x}({t:3d}): 仅 {name2} len={rec2['len']} data={rec2['data'][:8].hex(' ')}")
        else:
            d1, d2 = rec1['data'], rec2['data']
            if len(d1) != len(d2):
                print(f"  type={t:#06x}({t:3d}): len 不同 {rec1['len']} vs {rec2['len']}")
            else:
                byte_diffs = [i for i in range(len(d1)) if d1[i] != d2[i]]
                print(f"  type={t:#06x}({t:3d}): {len(byte_diffs)} 字节不同，差异位置: {byte_diffs[:6]}")
            if verbose:
                print(f"    {name1}: {d1.hex(' ')}")
                print(f"    {name2}: {d2.hex(' ')}")
    print()


def analyze_sec3_lut(sec3: list, name: str) -> None:
    """分析 SEC3 ADC 电流校正 LUT。"""
    if not sec3:
        print(f"  {name}: SEC3 为空")
        return
    
    diffs = [sec3[i+1] - sec3[i] for i in range(len(sec3)-1)]
    from collections import Counter
    step_dist = Counter(diffs)
    
    print(f"  {name}: {len(sec3)} 个值, 范围 {sec3[0]}~{sec3[-1]}")
    print(f"    解读: {sec3[0]}mA~{sec3[-1]}mA @1mA/步（ADC电流校正LUT）")
    top_steps = sorted(step_dist.items(), key=lambda x: -x[1])[:3]
    print(f"    主要步长: {top_steps}")


def main():
    verbose = '--verbose' in sys.argv or '-v' in sys.argv
    
    # 确定 blob 路径
    base = Path('/home/drie/桌面/acpi-fixup/firmware/ec')
    paths = {
        'N3GPD17W': base / 'N3GPD17W.bin',
        'N3GPH20W': base / 'N3GPH20W.bin',
        'N3GPH70W': base / 'N3GPH70W.bin',
    }
    
    blobs = {}
    for name, path in paths.items():
        if not path.exists():
            print(f"警告: {path} 不存在，跳过")
            continue
        data = path.read_bytes()
        r = parse_pd_blob(data, name)
        if r is None:
            print(f"警告: {name} 解析失败")
            continue
        blobs[name] = r
        print(f"✓ 加载 {name}: sub_blob_size={r['header']['sub_blob_size']}, "
              f"config_tag={r['header']['config_tag']:#04x}, SEC1={len(r['sec1'])}, "
              f"SEC2={len(r['sec2'])}, SEC3={len(r['sec3'])}, SEC4={len(r['sec4'])}")
    print()
    
    if len(blobs) < 2:
        print("错误: 需要至少 2 个 blob 文件")
        return 1
    
    blob_list = list(blobs.values())
    
    # === 1. 头部对比 ===
    print_header_comparison(blob_list)
    
    # === 2. SEC1 差异对比 ===
    print("=" * 70)
    print("SEC1 主配置 TLV 差异分析")
    print("=" * 70)
    
    names = list(blobs.keys())
    for i in range(len(names)):
        for j in range(i+1, len(names)):
            print_sec1_diff_table(blobs[names[i]], blobs[names[j]], verbose)
    
    # === 3. SEC3 LUT 对比 ===
    print("=" * 70)
    print("SEC3 ADC 电流校正 LUT 对比")
    print("=" * 70)
    for r in blob_list:
        analyze_sec3_lut(r['sec3'], r['name'])
    # 检查是否完全相同
    secs3_nonempty = [(r['name'], r['sec3']) for r in blob_list if r['sec3']]
    if len(secs3_nonempty) >= 2:
        all_same = all(s == secs3_nonempty[0][1] for _, s in secs3_nonempty)
        print(f"  相同: {all_same}")
    print()
    
    # === 4. SEC4 TAG 分布对比 ===
    print("=" * 70)
    print("SEC4 混合 TAG 记录对比")
    print("=" * 70)
    from collections import Counter
    for r in blob_list:
        tag_cnts = Counter(rec['tag'] for rec in r['sec4'])
        print(f"  {r['name']}: {len(r['sec4'])} 条, TAG分布: "
              + ", ".join(f"{k:#04x}:{v}" for k,v in sorted(tag_cnts.items())))
    print()
    
    # === 5. 总结 ===
    print("=" * 70)
    print("分析总结")
    print("=" * 70)
    print("""
推测各 Blob 对应的硬件端口：

  N3GPD17W (config_tag=0x0C, magic=0xFA8E, port_config=0x081a0054):
    → USB-C 端口 #1（左侧）：全功能 PD 控制器
    → 5 个端口 (num_ports=5)，支持 PPS (APDO)
    → UPD301x 系列，ID: 04d8:0039（本机已发现的 DFU 设备）

  N3GPH20W (config_tag=0xFF, magic=0xFA82, port_config=0x081a0054):
    → USB-C 端口 #2（右侧）：全功能 PD 控制器
    → sub_blob_size=1233（比 D17W 多 22 字节）
    → 0xFF TAG 可能是更新版本的 blob 格式
    → 包含 type=0x007b 等新增记录

  N3GPH70W (config_tag=0x0F, magic=0xFA3A, port_config=0x041a0054):
    → Thunderbolt/USB4 控制器端口
    → sub_blob_size=839（精简配置，无 SEC2/SEC3）
    → port_config 高字节 0x04（vs D17W/H20W 的 0x08）

关键差异点（D17W vs H20W SEC1）：
  type=0x0027: PDO 策略配置不同（可能是不同的充电功率/电流）
  type=0x0033: 电流能力表略有不同（主要是条目数: D17W 3条 vs H20W 2条）
  type=0x0064: 电源开关控制不同（0x08 vs 0x0c 首字节）
  type=0x0017: H20W 和 H70W 有此记录（D17W 无）
  type=0x007b: 仅 H20W 有（UUID/GUID 扩展记录）
""")
    
    return 0


if __name__ == '__main__':
    sys.exit(main())
