#!/usr/bin/env python3
"""Quick check: VT structure in N3GHT07T (224KB) and N3GHT15W (320KB)"""
import struct

BASE = 0x10070000

for fname, spi_off, total in [
    ("firmware/ec_spi/EC0.07_eng_rev0.3.bin", 0x1000, 0x38040),
    ("firmware/ec_spi/N3GHT15W_z13_own_20260313.bin", 0x1000, 0x50000),
]:
    data = open(fname, "rb").read()
    ec = data[spi_off:spi_off+total]
    
    ver_str = "?"
    for s in range(0, min(len(ec), 0x2000)):
        if ec[s:s+5] == b'N3GHT':
            ver_str = ec[s:s+8].decode('ascii', errors='replace')
            break
    
    print(f"\n{'='*60}")
    print(f"  {ver_str} ({fname.split('/')[-1]})")
    print(f"{'='*60}")
    
    # Full VT dump
    print("  Vector Table @ EC+0x0100:")
    default_handler = None
    unique_handlers = {}
    
    for i in range(80):
        val = struct.unpack_from('<I', ec, 0x100+i*4)[0]
        if i == 0:
            print(f"    [{i:3d}] SP     : 0x{val:08X}")
        elif val == 0:
            print(f"    [{i:3d}] unused : 0x{val:08X}")
        elif 0x10070000 <= (val&~1) < 0x100C0000:
            ec_off = (val&~1) - BASE
            # Check if same as default handler
            if i == 16:  # IRQ0 is first after system
                default_handler = val
            tag = "(DEFAULT)" if val == default_handler and i > 16 else ""
            print(f"    [{i:3d}] {'%-8s' % (['SP','Reset','NMI','HF','MM','BF','UF','r7','r8','r9','r10','SVC','DBG','r13','PSV','STk'][i] if i < 16 else f'IRQ{i-16}')}: "
                  f"0x{val:08X} -> EC+0x{ec_off:05X} {tag}")
            unique_handlers[val] = unique_handlers.get(val, 0) + 1
    
    # Count unique handlers
    print(f"\n  Unique handler addresses: {len(unique_handlers)}")
    # Most common = default handler
    default = max(unique_handlers, key=unique_handlers.get)
    print(f"  Default handler: 0x{default:08X} (used {unique_handlers[default]} times)")
    
    # Where does code actually start after VT?
    # Look for first non-pointer data after VT
    print(f"\n  Post-VT code search:")
    for off in range(0x0240, 0x0280, 4):
        val = struct.unpack_from('<I', ec, off)[0]
        hw = struct.unpack_from('<H', ec, off)[0]
        print(f"    EC+0x{off:04X}: 0x{val:08X} (hw=0x{hw:04X})")
        
        # Check if it's a BL instruction
        hw2 = struct.unpack_from('<H', ec, off+2)[0]
        if 0xF000 <= hw <= 0xF7FF and 0xF800 <= hw2 <= 0xFFFF:
            imm = ((hw & 0x7FF) << 12) | ((hw2 & 0x7FF) << 1)
            if imm & (1 << 22):
                imm |= 0xFF800000  # sign extend
            target = (BASE + off + 4 + imm) & 0xFFFFFFFF
            print(f"           -> BL to 0x{target:08X}")
