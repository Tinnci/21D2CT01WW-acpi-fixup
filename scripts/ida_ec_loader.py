#!/usr/bin/env python3
"""
IDA Pro Python script for ThinkPad Z13/Z16 EC firmware.

Usage:
  1. Open IDA Pro, select "ARM Little-Endian" processor
  2. Load the EC blob as raw binary at address 0x10070000
     - Processor = ARM, Mode = Thumb
  3. Run this script: File -> Script file... -> ida_ec_loader.py

This script will:
  - Create memory segments (SRAM, peripherals)
  - Label the vector table entries
  - Create functions at all IRQ handlers
  - Add known symbols and comments
"""

import idc
import idaapi
import ida_name
import ida_funcs
import ida_segment
import ida_bytes

# ==============================================================================
# Configuration
# ==============================================================================

EC_BASE = 0x10070000
SRAM_BASE = 0x200C0000
SRAM_SIZE = 0x8000

VECTOR_NAMES = [
    "SP_Main", "Reset_Handler", "NMI_Handler", "HardFault_Handler",
    "MemManage_Handler", "BusFault_Handler", "UsageFault_Handler",
    "Reserved_7", "Reserved_8", "Reserved_9", "Reserved_10",
    "SVC_Handler", "DebugMon_Handler", "Reserved_13",
    "PendSV_Handler", "SysTick_Handler",
] + ["IRQ%d_Handler" % i for i in range(64)]

ARM_SYSTEM_REGS = {
    0xE000E100: "NVIC_ISER0",
    0xE000E180: "NVIC_ICER0",
    0xE000ED00: "SCB_CPUID",
    0xE000ED04: "SCB_ICSR",
    0xE000ED08: "SCB_VTOR",
    0xE000ED0C: "SCB_AIRCR",
    0xE000ED10: "SCB_SCR",
    0xE000ED14: "SCB_CCR",
    0xE000ED24: "SCB_SHCSR",
    0xE000ED28: "SCB_CFSR",
    0xE000ED2C: "SCB_HFSR",
    0xE000EF00: "STI_R",
    0xE000E010: "SYST_CSR",
    0xE000E014: "SYST_RVR",
    0xE000E018: "SYST_CVR",
}


def detect_header_version():
    """Detect _EC header version to determine VT offset."""
    magic = idc.get_bytes(EC_BASE, 3)
    if magic == b'_EC':
        ver = idc.get_wide_byte(EC_BASE + 3)
        return ver
    return 2  # default


def create_memory_segments():
    """Create SRAM and peripheral memory segments."""
    # SRAM
    if ida_segment.getseg(SRAM_BASE) is None:
        ida_segment.add_segm(0, SRAM_BASE, SRAM_BASE + SRAM_SIZE, "SRAM", "DATA")
        print("Created SRAM segment: 0x%08X - 0x%08X" % (SRAM_BASE, SRAM_BASE + SRAM_SIZE))

    # ARM system registers (small block)
    if ida_segment.getseg(0xE000E000) is None:
        ida_segment.add_segm(0, 0xE000E000, 0xE000F000, "ARM_SYS", "DATA")
        print("Created ARM_SYS segment")


def process_vector_table(vt_offset):
    """Label and process vector table entries."""
    vt_addr = EC_BASE + vt_offset
    idc.set_name(vt_addr, "VectorTable", idc.SN_NOCHECK)

    # SP entry
    sp = idc.get_wide_dword(vt_addr)
    idc.set_cmt(vt_addr, "Initial SP = 0x%08X" % sp, False)
    ida_bytes.create_dword(vt_addr, 4)
    print("  SP = 0x%08X" % sp)

    unique_handlers = set()
    for i in range(1, 80):
        entry_addr = vt_addr + i * 4
        val = idc.get_wide_dword(entry_addr)
        name = VECTOR_NAMES[i] if i < len(VECTOR_NAMES) else "IRQ%d" % (i - 16)

        # Create pointer
        ida_bytes.create_dword(entry_addr, 4)

        handler_addr = val & ~1
        if EC_BASE <= handler_addr < EC_BASE + 0x80000:
            if handler_addr not in unique_handlers:
                unique_handlers.add(handler_addr)
                idc.set_name(handler_addr, name, idc.SN_NOCHECK)
                # Set as Thumb code and create function
                idc.split_sreg_range(handler_addr, "T", 1)
                ida_funcs.add_func(handler_addr)

    print("  Processed %d unique handlers" % len(unique_handlers))


def label_landmarks(header_ver):
    """Label known code landmarks."""
    labels = {
        EC_BASE: "_EC_Header",
        EC_BASE + 0x01F4: "CRT0_Entry",
        EC_BASE + 0x0240: "CRT0_Init",
        EC_BASE + 0x02F4: "Flash_CRC_Check",
    }

    if header_ver == 1:
        labels[EC_BASE + 0x037C] = "Startup_LiteralPool"
    else:
        labels[EC_BASE + 0x035C] = "Startup_LiteralPool"

    for address, name in labels.items():
        idc.set_name(address, name, idc.SN_NOCHECK)


def find_version_string():
    """Find and label EC version string."""
    for off in [0x0508, 0x0528]:
        b = idc.get_wide_byte(EC_BASE + off)
        if b == ord('N'):
            ver = idc.get_strlit_contents(EC_BASE + off, -1, idc.STRTYPE_C)
            if ver and ver.startswith(b'N3GHT'):
                idc.set_name(EC_BASE + off, "EC_Version", idc.SN_NOCHECK)
                ida_bytes.create_strlit(EC_BASE + off, 8, idc.STRTYPE_C)
                print("  Version: %s at EC+0x%04X" % (ver.decode(), off))
                return


def label_arm_registers():
    """Label known ARM system registers."""
    for reg_addr, name in ARM_SYSTEM_REGS.items():
        idc.set_name(reg_addr, name, idc.SN_NOCHECK)


def main():
    print("=" * 60)
    print("ThinkPad Z13/Z16 EC Firmware Loader (IDA)")
    print("=" * 60)

    header_ver = detect_header_version()
    vt_offset = 0x0120 if header_ver == 1 else 0x0100
    print("_EC header version: %d, VT @ EC+0x%04X" % (header_ver, vt_offset))

    create_memory_segments()
    print("\nProcessing vector table...")
    process_vector_table(vt_offset)
    label_landmarks(header_ver)
    find_version_string()
    label_arm_registers()

    # Set processor to Thumb mode for the entire EC region
    print("\nSetting Thumb mode for EC region...")
    idc.split_sreg_range(EC_BASE + vt_offset + 4, "T", 1)

    print("\n✓ EC firmware loaded. Run auto-analysis (Edit -> Plugins -> Auto-analyze).")
    print("  Base: 0x%08X, VT: EC+0x%04X" % (EC_BASE, vt_offset))


if __name__ == "__main__":
    main()
