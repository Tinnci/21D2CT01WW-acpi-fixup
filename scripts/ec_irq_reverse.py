#!/usr/bin/env python3
"""EC IRQ Handler Deep Reverse Engineering — Capstone-based Function Analysis.

Extracts and deeply analyzes all 37+ active IRQ handlers from the EC firmware,
identifying their functional purpose through:
  - Peripheral register access patterns (which MMIO regions are touched)
  - String references (if any data strings are loaded)
  - Call graph (BL targets → sub-function mapping)
  - I2C/SPI/UART register access (for bus communication identification)
  - Timer/PWM patterns (for fan/LED control)
  - GPIO patterns (for button/lid/power events)

Target: ThinkPad Z13 Gen1 EC (ARM Cortex-M, Thumb-2)
"""

import struct
import sys
from pathlib import Path
from collections import defaultdict

try:
    from capstone import (
        Cs, CS_ARCH_ARM, CS_MODE_THUMB,
        CS_GRP_CALL, CS_GRP_JUMP, CS_GRP_RET,
        CS_OP_IMM, CS_OP_REG, CS_OP_MEM,
    )
    # Capstone 5.x: ARM_REG_PC = 11
    from capstone.arm import ARM_REG_PC, ARM_REG_SP, ARM_REG_LR
except ImportError:
    print("ERROR: capstone not installed. Run: pip install capstone")
    sys.exit(1)

# ==============================================================================
# Constants
# ==============================================================================
EC_BASE = 0x10070000
SRAM_BASE = 0x200C0000
SRAM_END  = 0x200C8000

# Known peripheral ranges (ARM Cortex-M + vendor-specific)
PERIPH_RANGES = {
    (0x40000000, 0x40010000): "GPIO_BLOCK_0",
    (0x40010000, 0x40020000): "GPIO_BLOCK_1",
    (0x40020000, 0x40030000): "TIMER_BLOCK",
    (0x40030000, 0x40040000): "PWM_BLOCK",
    (0x40040000, 0x40050000): "I2C_BLOCK_0",
    (0x40050000, 0x40060000): "I2C_BLOCK_1",
    (0x40060000, 0x40070000): "SPI_BLOCK",
    (0x40070000, 0x40080000): "UART_BLOCK",
    (0x40080000, 0x40090000): "ADC_BLOCK",
    (0x40090000, 0x400A0000): "WDT_BLOCK",
    (0x400A0000, 0x400B0000): "SMBUS_BLOCK",
    (0x400B0000, 0x400C0000): "ESPI_BLOCK",
    (0x400C0000, 0x400D0000): "KBD_BLOCK",
    (0x400D0000, 0x400E0000): "PS2_BLOCK",
    (0x400E0000, 0x400F0000): "ACPI_EC_BLOCK",
    (0x400F0000, 0x40100000): "EMI_BLOCK",
    (0xE000E000, 0xE000F000): "NVIC",
    (0xE000ED00, 0xE000EE00): "SCB",
}

# Heuristic peripheral address tags (single-address patterns)
KNOWN_REGS = {
    0xE000ED08: "SCB_VTOR",
    0xE000ED0C: "SCB_AIRCR",
    0xE000E100: "NVIC_ISER0",
    0xE000E180: "NVIC_ICER0",
    0xE000E200: "NVIC_ISPR0",
    0xE000E280: "NVIC_ICPR0",
    0xE000E400: "NVIC_IPR0",
}


def classify_address(addr):
    """Classify a 32-bit address into a memory region."""
    if SRAM_BASE <= addr < SRAM_END:
        return "SRAM"
    if EC_BASE <= addr < EC_BASE + 0x80000:
        return "EC_FLASH"
    for (lo, hi), name in PERIPH_RANGES.items():
        if lo <= addr < hi:
            return name
    if addr in KNOWN_REGS:
        return KNOWN_REGS[addr]
    if 0x40000000 <= addr < 0x50000000:
        return f"PERIPH_{addr:#010x}"
    if 0xE0000000 <= addr < 0xF0000000:
        return f"ARM_SYS_{addr:#010x}"
    return None


def extract_ec_from_spi(data, slot_offset=0x1000):
    """Extract EC blob from a 32MB SPI dump."""
    if data[slot_offset:slot_offset+3] != b'_EC':
        return None, None
    ver = data[slot_offset + 3]
    total = struct.unpack_from("<I", data, slot_offset + 8)[0]
    if total < 0x1000 or total > 0x100000:
        return None, None
    blob = data[slot_offset:slot_offset + total]
    return blob, ver


def parse_vector_table(blob, ver):
    """Parse the 80-entry vector table."""
    if ver == 1:
        vt_off = 0x0120
    else:
        vt_off = 0x0100

    vectors = []
    for i in range(80):
        val = struct.unpack_from("<I", blob, vt_off + i * 4)[0]
        vectors.append(val)
    return vectors, vt_off


def find_version_string(blob):
    """Find N3GHTxxW version string."""
    for off in range(min(len(blob), 0x3000)):
        if blob[off:off+5] == b'N3GHT':
            end = off + 5
            while end < off + 12 and blob[end] != 0:
                end += 1
            return blob[off:end].decode('ascii', errors='replace')
    return "unknown"


def disasm_function(md, blob, func_addr, ec_base, max_insns=500):
    """Disassemble a function starting at func_addr, following linear flow.
    
    Returns list of (address, mnemonic, op_str, insn) tuples.
    Stops at unconditional return or after max_insns.
    """
    offset = func_addr - ec_base
    if offset < 0 or offset >= len(blob):
        return []

    # Thumb: clear bit 0
    if func_addr & 1:
        offset = (func_addr & ~1) - ec_base

    instructions = []
    visited = set()

    code = blob[offset:]
    for insn in md.disasm(code, func_addr & ~1):
        if insn.address in visited:
            break
        visited.add(insn.address)
        instructions.append(insn)

        if len(instructions) >= max_insns:
            break

        # Stop at unconditional return
        mn = insn.mnemonic
        if mn in ('bx', 'pop') and 'lr' in insn.op_str and mn == 'bx':
            break
        if mn == 'pop' and 'pc' in insn.op_str:
            break
        # Infinite loop (branch to self)
        if mn == 'b' and len(insn.operands) == 1:
            if insn.operands[0].type == CS_OP_IMM:
                if insn.operands[0].imm == insn.address:
                    break

    return instructions


def analyze_handler(md, blob, handler_addr, ec_base, blob_size):
    """Analyze a single IRQ handler deeply.
    
    Returns a dict of analysis results.
    """
    result = {
        'addr': handler_addr,
        'size': 0,
        'periph_accesses': defaultdict(int),  # region -> count
        'sram_accesses': 0,
        'flash_reads': 0,
        'bl_targets': [],    # called sub-functions
        'branch_targets': [],
        'ldr_constants': [],  # LDR =constant values
        'uses_i2c': False,
        'uses_spi': False,
        'uses_uart': False,
        'uses_gpio': False,
        'uses_timer': False,
        'uses_pwm': False,
        'uses_adc': False,
        'uses_smbus': False,
        'uses_espi': False,
        'uses_kbd': False,
        'uses_acpi_ec': False,
        'uses_nvic': False,
        'string_refs': [],
        'insn_count': 0,
    }

    instructions = disasm_function(md, blob, handler_addr, ec_base)
    result['insn_count'] = len(instructions)
    if instructions:
        result['size'] = (instructions[-1].address - (handler_addr & ~1)) + instructions[-1].size

    # Track register state for LDR/MOV constant propagation
    reg_vals = {}  # reg_id -> last_known_value

    for insn in instructions:
        mn = insn.mnemonic
        ops = insn.operands

        # ── BL calls ──
        if mn == 'bl' and len(ops) == 1 and ops[0].type == CS_OP_IMM:
            result['bl_targets'].append(ops[0].imm)

        # ── Branches ──
        if mn in ('b', 'b.w', 'bne', 'beq', 'bcc', 'bcs', 'bhi', 'bls',
                   'bge', 'blt', 'bgt', 'ble', 'bpl', 'bmi') and len(ops) == 1:
            if ops[0].type == CS_OP_IMM:
                result['branch_targets'].append(ops[0].imm)

        # ── LDR with PC-relative (loads constants from literal pool) ──
        if mn.startswith('ldr') and not mn.startswith('ldrb') and not mn.startswith('ldrh'):
            if len(ops) == 2 and ops[1].type == CS_OP_MEM:
                mem = ops[1].mem
                if mem.base == ARM_REG_PC:
                    # PC-relative LDR: compute literal pool address
                    pc_val = (insn.address & ~3) + 4  # Thumb PC alignment
                    lit_addr = pc_val + mem.disp
                    lit_offset = lit_addr - ec_base
                    if 0 <= lit_offset < len(blob) - 3:
                        val = struct.unpack_from("<I", blob, lit_offset)[0]
                        result['ldr_constants'].append(val)

                        # Track reg value
                        if ops[0].type == CS_OP_REG:
                            reg_vals[ops[0].reg] = val

                        # Classify the loaded constant
                        cls = classify_address(val)
                        if cls:
                            result['periph_accesses'][cls] += 1
                            # Set specific flags
                            if 'I2C' in cls:
                                result['uses_i2c'] = True
                            elif 'SPI' in cls:
                                result['uses_spi'] = True
                            elif 'UART' in cls:
                                result['uses_uart'] = True
                            elif 'GPIO' in cls:
                                result['uses_gpio'] = True
                            elif 'TIMER' in cls:
                                result['uses_timer'] = True
                            elif 'PWM' in cls:
                                result['uses_pwm'] = True
                            elif 'ADC' in cls:
                                result['uses_adc'] = True
                            elif 'SMBUS' in cls:
                                result['uses_smbus'] = True
                            elif 'ESPI' in cls:
                                result['uses_espi'] = True
                            elif 'KBD' in cls:
                                result['uses_kbd'] = True
                            elif 'ACPI_EC' in cls:
                                result['uses_acpi_ec'] = True
                            elif 'NVIC' in cls or 'SCB' in cls:
                                result['uses_nvic'] = True
                            elif cls == 'SRAM':
                                result['sram_accesses'] += 1
                            elif cls == 'EC_FLASH':
                                result['flash_reads'] += 1

        # ── MOV/MOVW/MOVT for constant building ──
        if mn in ('mov', 'movs', 'movw', 'movt'):
            if len(ops) == 2 and ops[0].type == CS_OP_REG and ops[1].type == CS_OP_IMM:
                if mn == 'movt' and ops[0].reg in reg_vals:
                    reg_vals[ops[0].reg] = (ops[1].imm << 16) | (reg_vals[ops[0].reg] & 0xFFFF)
                else:
                    reg_vals[ops[0].reg] = ops[1].imm

        # ── STR/LDR with register base (check if base points to peripheral) ──
        if mn.startswith(('str', 'ldr')) and len(ops) >= 2:
            mem_op = ops[1] if len(ops) >= 2 else None
            if mem_op and mem_op.type == CS_OP_MEM:
                base_reg = mem_op.mem.base
                if base_reg in reg_vals:
                    effective_addr = reg_vals[base_reg] + mem_op.mem.disp
                    cls = classify_address(effective_addr)
                    if cls:
                        result['periph_accesses'][cls] += 1

    # Check for string references in loaded constants
    for val in result['ldr_constants']:
        off = val - ec_base
        if 0 <= off < len(blob) - 4:
            # Check if this points to printable ASCII
            s = []
            for b in blob[off:off+64]:
                if 0x20 <= b < 0x7F:
                    s.append(chr(b))
                elif b == 0 and len(s) >= 4:
                    break
                else:
                    s = []
                    break
            if len(s) >= 4:
                result['string_refs'].append(''.join(s))

    return result


def infer_function_name(idx, result):
    """Infer a human-readable function name based on analysis."""
    # Priority-based heuristic
    if result['uses_kbd']:
        return "kbd_irq"
    if result['uses_acpi_ec']:
        return "acpi_ec_irq"
    if result['uses_espi']:
        return "espi_irq"
    if result['uses_smbus']:
        return "smbus_irq"
    if result['uses_i2c']:
        return "i2c_irq"
    if result['uses_spi']:
        return "spi_irq"
    if result['uses_uart']:
        return "uart_irq"
    if result['uses_timer'] and result['uses_pwm']:
        return "fan_pwm_irq"
    if result['uses_timer']:
        return "timer_irq"
    if result['uses_pwm']:
        return "pwm_irq"
    if result['uses_adc']:
        return "adc_irq"
    if result['uses_gpio']:
        return "gpio_irq"
    if result['uses_nvic']:
        return "nvic_mgmt_irq"
    if result['insn_count'] <= 5:
        return "stub_irq"

    # Fallback: look at dominant peripheral
    if result['periph_accesses']:
        top = max(result['periph_accesses'], key=result['periph_accesses'].get)
        return f"{top.lower()}_irq"

    return f"irq{idx}"


def analyze_subroutine(md, blob, sub_addr, ec_base):
    """Quick analysis of a called subroutine — just peripheral accesses."""
    insns = disasm_function(md, blob, sub_addr, ec_base, max_insns=200)
    periphs = set()
    bl_targets = []
    ldr_vals = []

    reg_vals = {}
    for insn in insns:
        mn = insn.mnemonic
        ops = insn.operands

        if mn == 'bl' and len(ops) == 1 and ops[0].type == CS_OP_IMM:
            bl_targets.append(ops[0].imm)

        if mn.startswith('ldr') and len(ops) == 2 and ops[1].type == CS_OP_MEM:
            mem = ops[1].mem
            if mem.base == ARM_REG_PC:
                pc_val = (insn.address & ~3) + 4
                lit_addr = pc_val + mem.disp
                lit_offset = lit_addr - ec_base
                if 0 <= lit_offset < len(blob) - 3:
                    val = struct.unpack_from("<I", blob, lit_offset)[0]
                    ldr_vals.append(val)
                    if ops[0].type == CS_OP_REG:
                        reg_vals[ops[0].reg] = val
                    cls = classify_address(val)
                    if cls:
                        periphs.add(cls)

        if mn in ('movw', 'movt', 'mov', 'movs'):
            if len(ops) == 2 and ops[0].type == CS_OP_REG and ops[1].type == CS_OP_IMM:
                if mn == 'movt' and ops[0].reg in reg_vals:
                    reg_vals[ops[0].reg] = (ops[1].imm << 16) | (reg_vals[ops[0].reg] & 0xFFFF)
                else:
                    reg_vals[ops[0].reg] = ops[1].imm

    return {
        'addr': sub_addr,
        'insn_count': len(insns),
        'periphs': periphs,
        'bl_targets': bl_targets,
    }


def main():
    spi_path = Path("firmware/ec_spi/N3GHT15W_z13_own_20260313.bin")
    if not spi_path.exists():
        # Try from script directory
        spi_path = Path(__file__).parent.parent / "firmware/ec_spi/N3GHT15W_z13_own_20260313.bin"
    if not spi_path.exists():
        print(f"ERROR: Cannot find SPI dump at {spi_path}")
        sys.exit(1)

    print(f"Loading SPI dump: {spi_path}")
    data = spi_path.read_bytes()

    # Extract EC blob from Slot A (SPI 0x1000)
    blob, ver = extract_ec_from_spi(data, 0x1000)
    if blob is None:
        print("ERROR: Cannot find _EC header at SPI 0x1000")
        sys.exit(1)

    version = find_version_string(blob)
    print(f"EC Version: {version}, Header ver={ver}, Size={len(blob)} bytes ({len(blob)//1024}KB)")

    # Parse vector table
    vectors, vt_off = parse_vector_table(blob, ver)
    sp_init = vectors[0]
    print(f"SP = {sp_init:#010x}, VT offset = +{vt_off:#06x}")
    print(f"Vector Table: {len(vectors)} entries\n")

    # Initialize Capstone
    md = Cs(CS_ARCH_ARM, CS_MODE_THUMB)
    md.detail = True

    # ── Classify all vector entries ──
    default_handler = None
    handler_counts = defaultdict(list)
    for i in range(16, 80):  # IRQ0-63
        addr = vectors[i]
        if addr != 0:
            handler_counts[addr].append(i)

    # The address used by most IRQs is the default handler
    if handler_counts:
        default_handler = max(handler_counts, key=lambda a: len(handler_counts[a]))
        default_irqs = handler_counts[default_handler]
        print(f"Default handler @ {default_handler:#010x} — shared by {len(default_irqs)} IRQs: {default_irqs}")

    # Identify active (unique) handlers
    active_handlers = {}
    for i in range(16, 80):
        addr = vectors[i]
        if addr != 0 and addr != default_handler:
            irq_num = i - 16
            active_handlers[i] = addr

    # Also analyze system handlers
    system_handlers = {}
    for i in range(1, 16):
        addr = vectors[i]
        if addr != 0 and addr != sp_init:
            system_handlers[i] = addr

    print(f"\nActive IRQ handlers: {len(active_handlers)}")
    print(f"System handlers: {len(system_handlers)}")
    print("=" * 80)

    # ── Deep analysis of each active handler ──
    all_results = {}
    all_subs = {}  # sub_addr -> analysis
    
    # System handlers first
    print("\n── System Exception Handlers ──\n")
    sys_names = {
        1: "Reset", 2: "NMI", 3: "HardFault", 4: "MemManage",
        5: "BusFault", 6: "UsageFault", 11: "SVC",
        12: "DebugMon", 14: "PendSV", 15: "SysTick"
    }
    for idx in sorted(system_handlers):
        addr = system_handlers[idx]
        name = sys_names.get(idx, f"Sys{idx}")
        result = analyze_handler(md, blob, addr, EC_BASE, len(blob))
        all_results[f"SYS_{name}"] = result
        print(f"  [{idx:2d}] {name:12s} @ {addr:#010x}  "
              f"insns={result['insn_count']:3d}  size={result['size']:4d}  "
              f"BL={len(result['bl_targets'])}  periphs={dict(result['periph_accesses'])}")

    # Active IRQ handlers
    print("\n── Active IRQ Handlers ──\n")
    print(f"{'VT#':>4} {'IRQ':>4} {'Address':>12} {'Insns':>6} {'Size':>6} {'BLs':>4} {'Name':>20}  Peripherals")
    print("-" * 100)

    for idx in sorted(active_handlers):
        addr = active_handlers[idx]
        irq_num = idx - 16
        result = analyze_handler(md, blob, addr, EC_BASE, len(blob))
        inferred = infer_function_name(irq_num, result)
        all_results[f"IRQ{irq_num}_{inferred}"] = result

        periph_str = ", ".join(f"{k}({v})" for k, v in
                               sorted(result['periph_accesses'].items(), key=lambda x: -x[1])
                               if v > 0)
        print(f"  {idx:2d}  {irq_num:3d}  {addr:#010x}  {result['insn_count']:5d}  "
              f"{result['size']:5d}  {len(result['bl_targets']):3d}  {inferred:>20s}  {periph_str}")

        # Analyze called subroutines (1 level deep)
        for sub_addr in result['bl_targets']:
            if sub_addr not in all_subs:
                sub_result = analyze_subroutine(md, blob, sub_addr, EC_BASE)
                all_subs[sub_addr] = sub_result

    # Default handler
    if default_handler:
        print(f"\n── Default Handler @ {default_handler:#010x} ──\n")
        result = analyze_handler(md, blob, default_handler, EC_BASE, len(blob))
        all_results["DEFAULT"] = result
        print(f"  insns={result['insn_count']}, size={result['size']}, BL={len(result['bl_targets'])}")
        print(f"  Periphs: {dict(result['periph_accesses'])}")

    # ── Summary ──
    print("\n" + "=" * 80)
    print("SUMMARY: Functional Classification")
    print("=" * 80)

    categories = {
        'I2C/SMBus': [],
        'SPI': [],
        'UART': [],
        'GPIO': [],
        'Timer/PWM': [],
        'ADC': [],
        'Keyboard': [],
        'ACPI EC': [],
        'eSPI': [],
        'NVIC/SCB': [],
        'Flash Access': [],
        'SRAM Only': [],
        'Stub/Minimal': [],
        'Unclassified': [],
    }

    for name, result in all_results.items():
        if result['insn_count'] <= 5:
            categories['Stub/Minimal'].append(name)
        elif result['uses_kbd']:
            categories['Keyboard'].append(name)
        elif result['uses_acpi_ec']:
            categories['ACPI EC'].append(name)
        elif result['uses_espi']:
            categories['eSPI'].append(name)
        elif result['uses_i2c'] or result['uses_smbus']:
            categories['I2C/SMBus'].append(name)
        elif result['uses_spi']:
            categories['SPI'].append(name)
        elif result['uses_uart']:
            categories['UART'].append(name)
        elif result['uses_timer'] or result['uses_pwm']:
            categories['Timer/PWM'].append(name)
        elif result['uses_adc']:
            categories['ADC'].append(name)
        elif result['uses_gpio']:
            categories['GPIO'].append(name)
        elif result['uses_nvic']:
            categories['NVIC/SCB'].append(name)
        elif result['flash_reads'] > 0:
            categories['Flash Access'].append(name)
        elif result['sram_accesses'] > 0:
            categories['SRAM Only'].append(name)
        else:
            categories['Unclassified'].append(name)

    for cat, handlers in categories.items():
        if handlers:
            print(f"\n  {cat}:")
            for h in handlers:
                r = all_results[h]
                print(f"    {h:30s} @ {r['addr']:#010x}  ({r['insn_count']} insns)")

    # ── String references found ──
    all_strings = set()
    for result in all_results.values():
        all_strings.update(result['string_refs'])
    if all_strings:
        print(f"\n── String References ({len(all_strings)}) ──\n")
        for s in sorted(all_strings):
            print(f"  \"{s}\"")

    # ── Call graph ──
    print(f"\n── Hot Subroutines (called by multiple handlers) ──\n")
    sub_callers = defaultdict(list)
    for name, result in all_results.items():
        for target in result['bl_targets']:
            sub_callers[target].append(name)

    hot_subs = sorted(
        ((addr, callers) for addr, callers in sub_callers.items() if len(callers) >= 2),
        key=lambda x: -len(x[1])
    )
    for addr, callers in hot_subs[:30]:
        sub_info = all_subs.get(addr, {})
        sub_periphs = sub_info.get('periphs', set()) if sub_info else set()
        print(f"  {addr:#010x}  called by {len(callers):2d} handlers  "
              f"periphs={sub_periphs if sub_periphs else '(none)'}")

    # ── Subroutine peripheral analysis ──
    print(f"\n── Subroutine Peripheral Map ({len(all_subs)} subs analyzed) ──\n")
    periph_subs = defaultdict(list)
    for addr, info in all_subs.items():
        for p in info['periphs']:
            periph_subs[p].append(addr)

    for periph in sorted(periph_subs):
        addrs = periph_subs[periph]
        print(f"  {periph:25s}: {len(addrs)} subs — {[f'{a:#010x}' for a in addrs[:5]]}")

    print(f"\nTotal: {len(all_results)} handlers analyzed, "
          f"{len(all_subs)} subroutines traced")


if __name__ == "__main__":
    main()
