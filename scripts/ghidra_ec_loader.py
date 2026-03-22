#!/usr/bin/env python3
# @name ThinkPad_EC_Loader
# @category Firmware
# @description Load ThinkPad Z13/Z16 EC firmware with known base address, memory map, vector table, and symbols
# @author EC Reverse Engineering Project
#
# Ghidra Python script for loading ThinkPad EC firmware.
#
# Usage in Ghidra:
#   1. Import the EC binary: File -> Import File
#      - Select the EC blob (e.g., extracted from SPI dump at offset 0x1000)
#      - Language: ARM:LE:32:Cortex (Thumb mode)
#      - Do NOT auto-analyze yet
#   2. Run this script: Script Manager -> ThinkPad_EC_Loader.py
#   3. Then run auto-analysis
#
# OR: Import raw binary with base address 0x10070000, then run this script.
#
# Supports both _EC header ver=1 (VT @ +0x0120) and ver=2 (VT @ +0x0100).

# ==============================================================================
# Configuration — adjust for your specific EC version
# ==============================================================================

EC_BASE = 0x10070000       # All versions use this base
SRAM_BASE = 0x200C0000     # SRAM start
SRAM_SIZE = 0x8000          # 32KB (may be 0x7C00 for N3GHT64W+)
PERIPH_BASE = 0x40000000   # Peripheral registers
ARM_SYS_BASE = 0xE0000000  # ARM system registers (SCB, NVIC, etc.)

# Vector table names (Cortex-M standard)
VECTOR_NAMES = [
    "SP_Main", "Reset_Handler", "NMI_Handler", "HardFault_Handler",
    "MemManage_Handler", "BusFault_Handler", "UsageFault_Handler",
    "Reserved_7", "Reserved_8", "Reserved_9", "Reserved_10",
    "SVC_Handler", "DebugMon_Handler", "Reserved_13",
    "PendSV_Handler", "SysTick_Handler",
    # IRQ 0-63
    "IRQ0_Handler", "IRQ1_Handler", "IRQ2_Handler", "IRQ3_Handler",
    "IRQ4_Handler", "IRQ5_Handler", "IRQ6_Handler", "IRQ7_Handler",
    "IRQ8_Handler", "IRQ9_Handler", "IRQ10_Handler", "IRQ11_Handler",
    "IRQ12_Handler", "IRQ13_Handler", "IRQ14_Handler", "IRQ15_Handler",
    "IRQ16_Handler", "IRQ17_Handler", "IRQ18_Handler", "IRQ19_Handler",
    "IRQ20_Handler", "IRQ21_Handler", "IRQ22_Handler", "IRQ23_Handler",
    "IRQ24_Handler", "IRQ25_Handler", "IRQ26_Handler", "IRQ27_Handler",
    "IRQ28_Handler", "IRQ29_Handler", "IRQ30_Handler", "IRQ31_Handler",
    "IRQ32_Handler", "IRQ33_Handler", "IRQ34_Handler", "IRQ35_Handler",
    "IRQ36_Handler", "IRQ37_Handler", "IRQ38_Handler", "IRQ39_Handler",
    "IRQ40_Handler", "IRQ41_Handler", "IRQ42_Handler", "IRQ43_Handler",
    "IRQ44_Handler", "IRQ45_Handler", "IRQ46_Handler", "IRQ47_Handler",
    "IRQ48_Handler", "IRQ49_Handler", "IRQ50_Handler", "IRQ51_Handler",
    "IRQ52_Handler", "IRQ53_Handler", "IRQ54_Handler", "IRQ55_Handler",
    "IRQ56_Handler", "IRQ57_Handler", "IRQ58_Handler", "IRQ59_Handler",
    "IRQ60_Handler", "IRQ61_Handler", "IRQ62_Handler", "IRQ63_Handler",
]

# Known ARM system registers
ARM_SYSTEM_REGS = {
    0xE000E100: "NVIC_ISER0",
    0xE000E180: "NVIC_ICER0",
    0xE000E200: "NVIC_ISPR0",
    0xE000E280: "NVIC_ICPR0",
    0xE000E300: "NVIC_IABR0",
    0xE000E400: "NVIC_IPR0",
    0xE000ED00: "SCB_CPUID",
    0xE000ED04: "SCB_ICSR",
    0xE000ED08: "SCB_VTOR",
    0xE000ED0C: "SCB_AIRCR",
    0xE000ED10: "SCB_SCR",
    0xE000ED14: "SCB_CCR",
    0xE000ED18: "SCB_SHPR1",
    0xE000ED1C: "SCB_SHPR2",
    0xE000ED20: "SCB_SHPR3",
    0xE000ED24: "SCB_SHCSR",
    0xE000ED28: "SCB_CFSR",
    0xE000ED2C: "SCB_HFSR",
    0xE000ED34: "SCB_MMFAR",
    0xE000ED38: "SCB_BFAR",
    0xE000EF00: "STI_R",
    0xE000EF34: "FPCCR",
    0xE000EF38: "FPCAR",
    0xE000EF3C: "FPDSCR",
    0xE0001000: "DWT_CTRL",
    0xE000E010: "SYST_CSR",
    0xE000E014: "SYST_RVR",
    0xE000E018: "SYST_CVR",
    0xE000E01C: "SYST_CALIB",
}

# ==============================================================================
# Ghidra Script Implementation
# ==============================================================================

def run():
    """Main entry point for Ghidra."""
    from ghidra.program.model.symbol import SourceType
    from ghidra.program.model.mem import MemoryBlockType
    from ghidra.program.model.data import PointerDataType, DWordDataType, StringDataType
    from ghidra.program.model.listing import CodeUnit
    import struct

    program = getCurrentProgram()
    memory = program.getMemory()
    listing = program.getListing()
    symtab = program.getSymbolTable()
    fm = program.getFunctionManager()
    af = program.getAddressFactory()
    space = af.getDefaultAddressSpace()

    def addr(offset):
        return space.getAddress(offset)

    def get_dword(address):
        try:
            return memory.getInt(addr(address))
        except Exception:
            return None

    def get_byte(address):
        try:
            return memory.getByte(addr(address)) & 0xFF
        except Exception:
            return None

    # Detect _EC header version
    magic = bytes([get_byte(EC_BASE + i) for i in range(3)])
    if magic == b'_EC':
        header_ver = get_byte(EC_BASE + 3)
        println("_EC header version: %d" % header_ver)
    else:
        header_ver = 2
        println("Warning: No _EC magic at base, assuming ver=2")

    vt_offset = 0x0120 if header_ver == 1 else 0x0100
    vt_addr = EC_BASE + vt_offset
    println("Vector table at: 0x%08X (EC+0x%04X)" % (vt_addr, vt_offset))

    # Create SRAM memory block if not exists
    sram_addr = addr(SRAM_BASE)
    if memory.getBlock(sram_addr) is None:
        try:
            memory.createUninitializedBlock("SRAM", sram_addr, SRAM_SIZE, False)
            println("Created SRAM block: 0x%08X - 0x%08X" % (SRAM_BASE, SRAM_BASE + SRAM_SIZE))
        except Exception as e:
            println("SRAM block creation failed: %s" % str(e))

    # Create peripheral memory block (small placeholder)
    periph_addr = addr(PERIPH_BASE)
    if memory.getBlock(periph_addr) is None:
        try:
            memory.createUninitializedBlock("PERIPH", periph_addr, 0x10000000, False)
            println("Created PERIPH block: 0x%08X" % PERIPH_BASE)
        except Exception as e:
            println("PERIPH block note: %s" % str(e))

    # Label _EC header
    start_txn = False

    # Mark _EC header as data region (don't disassemble)
    println("\nLabeling _EC header (EC+0x0000 to EC+0x%04X)..." % vt_offset)
    try:
        symtab.createLabel(addr(EC_BASE), "_EC_Header", SourceType.USER_DEFINED)
    except Exception:
        pass

    # Process vector table
    println("\nProcessing vector table (%d entries)..." % min(80, len(VECTOR_NAMES)))
    sp_val = get_dword(vt_addr)
    println("  SP = 0x%08X" % sp_val)
    try:
        symtab.createLabel(addr(vt_addr), "VectorTable", SourceType.USER_DEFINED)
    except Exception:
        pass

    unique_handlers = set()
    for i in range(min(80, len(VECTOR_NAMES))):
        entry_addr = vt_addr + i * 4
        val = get_dword(entry_addr)
        if val is None:
            continue

        name = VECTOR_NAMES[i] if i < len(VECTOR_NAMES) else "IRQ%d_Handler" % (i - 16)

        if i == 0:
            # SP entry — label as data
            try:
                listing.createData(addr(entry_addr), DWordDataType.dataType)
                listing.getCodeUnitAt(addr(entry_addr)).setComment(
                    CodeUnit.EOL_COMMENT, "Initial Stack Pointer = 0x%08X" % val)
            except Exception:
                pass
            continue

        # Vector entry — create pointer data type
        try:
            listing.createData(addr(entry_addr), PointerDataType.dataType)
        except Exception:
            pass

        # Create function at handler target
        handler_addr = val & ~1  # Clear Thumb bit
        if EC_BASE <= handler_addr < EC_BASE + 0x80000:
            if handler_addr not in unique_handlers:
                unique_handlers.add(handler_addr)
                try:
                    symtab.createLabel(addr(handler_addr), name, SourceType.USER_DEFINED)
                except Exception:
                    pass
                try:
                    fm.createFunction(name, addr(handler_addr), None, SourceType.USER_DEFINED)
                except Exception:
                    pass  # May already exist

    println("  Created %d unique handler symbols" % len(unique_handlers))

    # Label known code landmarks
    landmarks = {
        # Startup flow
        vt_offset: "VectorTable",
        0x01F4: "CRT0_Entry",       # Reset handler target (all versions)
        0x0240: "CRT0_Init",        # BSS/data initialization
        0x02F4: "Flash_CRC_Check",  # Flash integrity verification
    }

    # Adjust for header ver
    if header_ver == 1:
        landmarks[0x037C] = "Startup_LiteralPool"
    else:
        landmarks[0x035C] = "Startup_LiteralPool"

    for off, name in landmarks.items():
        try:
            symtab.createLabel(addr(EC_BASE + off), name, SourceType.USER_DEFINED)
        except Exception:
            pass

    # Find and label version string
    println("\nSearching for version string...")
    for off in [0x0508, 0x0528]:  # Known locations
        b = get_byte(EC_BASE + off)
        if b is not None and b == ord('N'):
            ver_bytes = bytes([get_byte(EC_BASE + off + i) for i in range(8)])
            if ver_bytes.startswith(b'N3GHT'):
                ver_str = ver_bytes.decode('ascii', errors='replace')
                println("  Found version '%s' at EC+0x%04X" % (ver_str, off))
                try:
                    symtab.createLabel(addr(EC_BASE + off), "EC_Version_String", SourceType.USER_DEFINED)
                    listing.createData(addr(EC_BASE + off), StringDataType.dataType)
                except Exception:
                    pass
                break

    # Label copyright strings
    for off in [0x1584, 0x15A4]:
        b = get_byte(EC_BASE + off)
        if b is not None and b == ord('C'):
            try:
                symtab.createLabel(addr(EC_BASE + off), "Copyright_IBM", SourceType.USER_DEFINED)
            except Exception:
                pass
            break

    # Label ARM system registers
    println("\nLabeling ARM system registers...")
    for reg_addr, reg_name in ARM_SYSTEM_REGS.items():
        try:
            symtab.createLabel(addr(reg_addr), reg_name, SourceType.USER_DEFINED)
        except Exception:
            pass

    println("\n✓ ThinkPad EC firmware loaded successfully")
    println("  Base: 0x%08X" % EC_BASE)
    println("  VT: 0x%08X (%d vectors)" % (vt_addr, min(80, len(VECTOR_NAMES))))
    println("  SP: 0x%08X" % sp_val)
    println("  Architecture: ARM Cortex-M (Thumb)")
    println("  Run auto-analysis now for best results.")

# Entry point
run()
