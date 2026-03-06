#!/bin/bash
# SPI Flash ROM Dump Script
# 仅在 iomem=relaxed 模式下运行!
# 
# 用法: sudo bash scripts/spi_dump.sh
#
# 这是只读操作，不会写入任何内容到闪存。
# 但 flashrom 读取 SPI 时可能导致 EC 异常（风扇/背光/断电）。
# 建议：接通电源适配器，保存所有工作。

set -euo pipefail

DUMP_DIR="$(cd "$(dirname "$0")/.." && pwd)/firmware/spi_dump"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
DUMP_FILE="${DUMP_DIR}/bios_dump_${TIMESTAMP}.bin"
LOG_FILE="${DUMP_DIR}/flashrom_${TIMESTAMP}.log"

# 检查是否为 root
if [ "$(id -u)" -ne 0 ]; then
    echo "错误: 需要 root 权限。使用 sudo 运行。"
    exit 1
fi

# 检查 iomem=relaxed
if ! grep -q "iomem=relaxed" /proc/cmdline; then
    echo "错误: 当前内核未启用 iomem=relaxed!"
    echo "请使用 rEFInd 的 'CachyOS SPI Debug (iomem=relaxed)' 条目启动。"
    echo "当前内核参数: $(cat /proc/cmdline)"
    exit 1
fi

echo "✓ iomem=relaxed 已启用"
echo "✓ 准备 dump SPI Flash..."

mkdir -p "$DUMP_DIR"

echo ""
echo "======================== 警告 ========================"
echo "  flashrom 将通过芯片组直接读取 SPI 闪存。"
echo "  读取过程中 EC 可能产生不可预测的反应。"
echo "  请确保已接通电源适配器并保存所有工作。"
echo "======================================================"
echo ""
read -p "继续? (y/N) " -r
if [[ ! "$REPLY" =~ ^[Yy]$ ]]; then
    echo "已取消。"
    exit 0
fi

echo ""
echo "[1/3] 探测闪存芯片..."
flashrom -p internal:laptop=this_is_not_a_laptop 2>&1 | tee "$LOG_FILE"

echo ""
echo "[2/3] 读取闪存内容..."
flashrom -p internal:laptop=this_is_not_a_laptop -r "$DUMP_FILE" 2>&1 | tee -a "$LOG_FILE"

if [ -f "$DUMP_FILE" ]; then
    SIZE=$(stat -c%s "$DUMP_FILE")
    MD5=$(md5sum "$DUMP_FILE" | cut -d' ' -f1)
    SHA256=$(sha256sum "$DUMP_FILE" | cut -d' ' -f1)
    
    echo ""
    echo "======================== 完成 ========================"
    echo "  文件: $DUMP_FILE"
    echo "  大小: $SIZE bytes ($(( SIZE / 1024 / 1024 )) MB)"
    echo "  MD5:  $MD5"
    echo "  SHA256: $SHA256"
    echo "======================================================"
    
    # 验证 dump
    echo ""
    echo "[3/3] 验证 dump (二次读取对比)..."
    VERIFY_FILE="${DUMP_DIR}/bios_verify_${TIMESTAMP}.bin"
    flashrom -p internal:laptop=this_is_not_a_laptop -r "$VERIFY_FILE" 2>&1 | tee -a "$LOG_FILE"
    
    if cmp -s "$DUMP_FILE" "$VERIFY_FILE"; then
        echo "✓ 验证通过! 两次读取完全一致。"
        rm "$VERIFY_FILE"
    else
        echo "✗ 警告: 两次读取不一致! 保留两个文件供分析。"
    fi
    
    echo ""
    echo "提示: dump 完成后请重启回正常模式 (不带 iomem=relaxed)。"
    echo "分析命令: strings $DUMP_FILE | grep -i 'N3GET\\|USB4\\|UCSI\\|NHI\\|Thunderbolt'"
else
    echo "✗ Dump 失败。查看日志: $LOG_FILE"
fi
