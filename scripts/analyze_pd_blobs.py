import struct, re, hashlib
from pathlib import Path

fl2_68 = Path('firmware/ec/N3GHT68W.FL2').read_bytes()
fl2_69 = Path('firmware/ec/N3GHT69W.FL2').read_bytes()
dump   = Path('firmware/spi_dump/ec_spi_read_20260313_104036.bin').read_bytes()

print("=== FL2 PD 固件 blob 精确定位 ===")

def fmtpos(p):
    return hex(p) if p != -1 else "未找到"

for name in ['N3GPD17W', 'N3GPH20W', 'N3GPH70W', 'N3GPD04W', 'N3GPH03W', 'N3GPH53W']:
    b_name = name.encode()
    pos_68   = fl2_68.find(b_name)
    pos_69   = fl2_69.find(b_name)
    pos_dump = dump.find(b_name)
    print(f"  {name}: FL2_68={fmtpos(pos_68)}  FL2_69={fmtpos(pos_69)}  dump={fmtpos(pos_dump)}")

print()
print("=== PD blob 精确偏移（FL2_68）===")

pd_names_68 = ['N3GPD17W', 'N3GPH20W', 'N3GPH70W']

for name in pd_names_68:
    b_name = name.encode()
    actual_pos = fl2_68.find(b_name)
    if actual_pos == -1:
        print(f"{name}: 未找到")
        continue
    # 头部在版本串前 0x20 字节（+0x20 处是版本ID）
    hdr_off = actual_pos - 0x20
    hdr = fl2_68[hdr_off:hdr_off+0x40]
    print("\n" + name + ":")
    print("  版本串偏移: " + hex(actual_pos))
    print("  推算头部偏移: " + hex(hdr_off))
    print("  头部48字节: " + hdr[:48].hex(' '))
    
    # 解析大小字段
    flag = struct.unpack_from('<H', hdr, 0)[0]
    blob_size = struct.unpack_from('<H', hdr, 2)[0]
    chksum = struct.unpack_from('<I', hdr, 4)[0]
    print(f"  flag=0x{flag:04X}  blob_size=0x{blob_size:X}={blob_size}B  chksum=0x{chksum:08X}")
    
    # 提取完整 blob
    blob = fl2_68[hdr_off : hdr_off + blob_size]
    sha = hashlib.sha256(blob).hexdigest()[:16]
    print(f"  blob SHA256前16: {sha}")
    print(f"  版本串在blob内偏移: 0x{actual_pos - hdr_off:X}")
    
    # 在 dump 中搜索头部
    pos_in_dump = dump.find(hdr[:16])
    print(f"  头部16B在dump中: {fmtpos(pos_in_dump)}")

print()
print("=== FL2_68 vs FL2_69 PD 区域对比 ===")
# 两版本 PD 区域是否相同
for name in pd_names_68:
    b_name = name.encode()
    p68 = fl2_68.find(b_name)
    p69 = fl2_69.find(b_name)
    if p68 == -1 or p69 == -1:
        continue
    # 前 0x1000 字节对比
    seg68 = fl2_68[p68-0x20 : p68-0x20+0x1000]
    seg69 = fl2_69[p69-0x20 : p69-0x20+0x1000]
    same = sum(a==b for a,b in zip(seg68, seg69))
    print(f"  {name}: 68W vs 69W 匹配率 {same/len(seg68)*100:.1f}% ({same}/{len(seg68)})")

print()
print("=== 工程版dump PD区域分析 ===")
# dump 中工程版 PD 串
for name in ['N3GPD04W', 'N3GPH03W', 'N3GPH53W']:
    b_name = name.encode()
    pos = dump.find(b_name)
    if pos == -1:
        print(f"  {name}: 未找到")
        continue
    # 查看前后上下文
    ctx_start = max(0, pos - 0x20)
    ctx = dump[ctx_start : pos + 0x40]
    print(f"\n  {name} @ dump 0x{pos:X}:")
    print(f"  上下文: {ctx[:48].hex(' ')}")
    flag = struct.unpack_from('<H', dump, ctx_start)[0]
    blob_size = struct.unpack_from('<H', dump, ctx_start+2)[0]
    print(f"  flag=0x{flag:04X}  blob_size=0x{blob_size:X}={blob_size}B")
