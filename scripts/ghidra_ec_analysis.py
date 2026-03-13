# Ghidra headless script for Nuvoton NPCX EC firmware analysis
# @author acpi-fixup analysis
# @category Firmware
# @keybinding
# @menupath
# @toolbar

from ghidra.program.model.symbol import SourceType
from ghidra.program.model.data import PointerDataType


def setup_memory_regions():
    """Add NPCX peripheral memory regions."""
    mem = currentProgram.getMemory()
    space = currentProgram.getAddressFactory().getDefaultAddressSpace()

    regions = [
        # (name, start, size, read, write, execute, volatile)
        ("DATA_RAM", 0x200C0000, 0x10000, True, True, False, False),
        ("PECI", 0x4000C000, 0x1000, True, True, False, True),
        ("SPIP", 0x4000E000, 0x1000, True, True, False, True),
        ("SMB4", 0x40080000, 0x2000, True, True, False, True),
        ("SMB5", 0x40082000, 0x2000, True, True, False, True),
        ("SMB6", 0x40084000, 0x2000, True, True, False, True),
        ("SMB7", 0x40086000, 0x2000, True, True, False, True),
        ("GPIO_ALT", 0x40090000, 0x10000, True, True, False, True),
        ("FLASH_REGS", 0x40100000, 0x10000, True, True, False, True),
        ("MIWU0", 0x400C1000, 0x2000, True, True, False, True),
        ("MIWU1", 0x400C3000, 0x2000, True, True, False, True),
        ("MIWU2", 0x400C5000, 0x2000, True, True, False, True),
        ("GPIO", 0x400C7000, 0x2000, True, True, False, True),
        ("CDCG", 0x400C9000, 0x2000, True, True, False, True),
        ("PM_CH", 0x400CB000, 0x2000, True, True, False, True),
        ("UART", 0x400CD000, 0x2000, True, True, False, True),
        ("SHI", 0x400CF000, 0x2000, True, True, False, True),
        ("SHM", 0x400D1000, 0x2000, True, True, False, True),
        ("KBC", 0x400D3000, 0x2000, True, True, False, True),
        ("ADC", 0x400D5000, 0x2000, True, True, False, True),
        ("SMB0", 0x400D7000, 0x2000, True, True, False, True),
        ("SMB1", 0x400D9000, 0x2000, True, True, False, True),
        ("SMB2", 0x400DB000, 0x2000, True, True, False, True),
        ("SMB3", 0x400DD000, 0x2000, True, True, False, True),
        ("TWD", 0x400DF000, 0x2000, True, True, False, True),
        ("ITIM", 0x400E1000, 0x2000, True, True, False, True),
        ("PWM", 0x400E3000, 0x2000, True, True, False, True),
        ("ESPI", 0x400E5000, 0x2000, True, True, False, True),
        ("NVIC", 0xE000E000, 0x1000, True, True, False, True),
        ("SCB", 0xE000ED00, 0x100, True, True, False, True),
    ]

    for name, start, size, r, w, x, v in regions:
        addr = space.getAddress(start)
        try:
            block = mem.createUninitializedBlock(name, addr, size, False)
            block.setRead(r)
            block.setWrite(w)
            block.setExecute(x)
            block.setVolatile(v)
            println("  Created region: %s at 0x%08X" % (name, start))
        except Exception as e:
            println("  Region %s already exists or error: %s" % (name, str(e)))


def label_vector_table():
    """Label the ARM Cortex-M vector table entries."""
    space = currentProgram.getAddressFactory().getDefaultAddressSpace()
    listing = currentProgram.getListing()
    symtab = currentProgram.getSymbolTable()

    vectors = [
        (0, "INITIAL_SP"),
        (4, "RESET_VECTOR"),
        (8, "NMI_VECTOR"),
        (12, "HARDFAULT_VECTOR"),
        (16, "MEMMANAGE_VECTOR"),
        (20, "BUSFAULT_VECTOR"),
        (24, "USAGEFAULT_VECTOR"),
        (44, "SVCALL_VECTOR"),
        (48, "DEBUGMON_VECTOR"),
        (56, "PENDSV_VECTOR"),
        (60, "SYSTICK_VECTOR"),
    ]

    base = 0x10070000
    for offset, name in vectors:
        addr = space.getAddress(base + offset)
        symtab.createLabel(addr, name, SourceType.USER_DEFINED)
        # Create pointer data type
        try:
            listing.createData(addr, PointerDataType.dataType)
        except:
            pass

    # Label IRQ vectors (16-63)
    for i in range(16, 64):
        addr = space.getAddress(base + i * 4)
        irq_name = "IRQ%d_VECTOR" % (i - 16)
        # Read the vector value
        val = getInt(addr)
        if val != 0:
            symtab.createLabel(addr, irq_name, SourceType.USER_DEFINED)
            try:
                listing.createData(addr, PointerDataType.dataType)
            except:
                pass


def label_npcx_peripherals():
    """Label known NPCX peripheral registers."""
    space = currentProgram.getAddressFactory().getDefaultAddressSpace()
    symtab = currentProgram.getSymbolTable()

    # Key NPCX registers related to USB PD / SMBus / GPIO
    registers = {
        # SMBus registers (used for USB PD communication via I2C)
        0x400DD000: "SMB3_SMBSDA",
        0x400DD002: "SMB3_SMBST",
        0x400DD004: "SMB3_SMBCTL1",
        0x400DD006: "SMB3_SMBADDR1",
        0x400DD008: "SMB3_SMBCTL2",
        0x400DD00A: "SMB3_SMBADDR2",
        0x400DD00C: "SMB3_SMBCTL3",
        # GPIO registers
        0x400C7000: "GPIO_PDOUT0",
        0x400C7002: "GPIO_PDIN0",
        0x400C7004: "GPIO_PDIR0",
        0x400C7006: "GPIO_PPULL0",
        0x400C7008: "GPIO_PPUD0",
        0x400C700A: "GPIO_PENVDD0",
        # PM Channel (ACPI EC interface)
        0x400CB000: "PM_PMSTS",
        0x400CB002: "PM_PMDO",
        0x400CB004: "PM_PMDI",
        0x400CB006: "PM_PMCTL",
        # PECI (thermal interface)
        0x4000C000: "PECI_CTL_STS",
        # eSPI (SoC communication)
        0x400E5000: "ESPI_ESPIID",
    }

    for addr_val, name in registers.items():
        try:
            addr = space.getAddress(addr_val)
            symtab.createLabel(addr, name, SourceType.USER_DEFINED)
        except:
            pass


def find_function_patterns():
    """Find and create functions from Thumb push patterns."""
    currentProgram.getMemory()
    space = currentProgram.getAddressFactory().getDefaultAddressSpace()
    listing = currentProgram.getListing()

    # Search for common Thumb-2 function prologue patterns:
    # PUSH {r4-r7, lr} = 0xB5F0
    # PUSH {r3-r7, lr} = 0xB5F8
    # PUSH {r4, lr} = 0xB510
    # PUSH.W {r4-r11, lr} = 0xE92D 0x4FF0

    base = 0x10070000
    code_start = base + 0x100  # Skip vector table
    code_end = base + 0x50000

    count = 0
    addr = space.getAddress(code_start)
    end = space.getAddress(code_end)

    while addr.compareTo(end) < 0:
        try:
            b0 = getByte(addr) & 0xFF
            b1 = getByte(addr.add(1)) & 0xFF

            # PUSH {regs, lr} - 0xB5xx where bit 0-7 has register mask including LR
            if b1 == 0xB5 and (b0 & 0x01) == 0:  # Common push patterns
                # Check if this looks like a function start
                instr = listing.getInstructionAt(addr)
                if instr is None:
                    try:
                        createFunction(addr, None)
                        count += 1
                    except:
                        pass

            addr = addr.add(2)
        except:
            addr = addr.add(2)

    println("  Created %d functions from prologue patterns" % count)


def search_usb_pd_code():
    """Search for USB PD / mux control related code patterns."""
    mem = currentProgram.getMemory()
    space = currentProgram.getAddressFactory().getDefaultAddressSpace()
    currentProgram.getListing()
    symtab = currentProgram.getSymbolTable()

    # Find PD firmware version strings
    pd_strings = {
        "N3GPD17W": "PD_FW_VERSION_1",
        "N3GPH20W": "PD_FW_VERSION_2",
        "N3GPH70W": "PD_FW_VERSION_3",
        "N3GHT68W": "EC_FW_VERSION",
    }

    base = 0x10070000
    for search_str, label_name in pd_strings.items():
        search_bytes = search_str.encode("ascii")
        addr = mem.findBytes(space.getAddress(base), search_bytes, None, True, monitor)
        if addr is not None:
            symtab.createLabel(addr, label_name, SourceType.USER_DEFINED)
            println("  Found %s at %s" % (label_name, addr))

            # Find cross-references to this string
            refs = getReferencesTo(addr)
            for ref in refs:
                from_addr = ref.getFromAddress()
                println("    Referenced from %s" % from_addr)


def analyze_smbus_functions():
    """Find functions that access SMBus registers (I2C for USB PD)."""
    mem = currentProgram.getMemory()
    space = currentProgram.getAddressFactory().getDefaultAddressSpace()
    currentProgram.getSymbolTable()

    # SMBus base addresses (I2C channels used for USB PD TCPC communication)
    smb_bases = [
        (0x400D7000, "SMB0"),
        (0x400D9000, "SMB1"),
        (0x400DB000, "SMB2"),
        (0x400DD000, "SMB3"),
        (0x40080000, "SMB4"),
        (0x40082000, "SMB5"),
        (0x40084000, "SMB6"),
        (0x40086000, "SMB7"),
    ]

    println("\n  SMBus controller usage analysis:")
    for smb_addr, smb_name in smb_bases:
        # Count references to each SMBus controller
        count = 0
        search_addr = space.getAddress(0x10070000)
        end_addr = space.getAddress(0x100C0000)

        # Search for the base address in code
        search_bytes = bytearray(
            [
                (smb_addr >> 0) & 0xFF,
                (smb_addr >> 8) & 0xFF,
                (smb_addr >> 16) & 0xFF,
                (smb_addr >> 24) & 0xFF,
            ]
        )

        addr = search_addr
        while addr is not None and addr.compareTo(end_addr) < 0:
            addr = mem.findBytes(addr, search_bytes, None, True, monitor)
            if addr is not None:
                count += 1
                addr = addr.add(1)

        if count > 0:
            println("    %s (0x%08X): %d references" % (smb_name, smb_addr, count))


def main():
    println("=" * 60)
    println("NPCX EC FIRMWARE ANALYSIS")
    println("=" * 60)

    println("\n[1/6] Setting up memory regions...")
    setup_memory_regions()

    println("\n[2/6] Labeling vector table...")
    label_vector_table()

    println("\n[3/6] Labeling NPCX peripherals...")
    label_npcx_peripherals()

    println("\n[4/6] Running auto-analysis...")
    # Auto-analysis is handled by Ghidra's analyzers

    println("\n[5/6] Searching for USB PD code...")
    search_usb_pd_code()

    println("\n[6/6] Analyzing SMBus usage...")
    analyze_smbus_functions()

    println("\n" + "=" * 60)
    println("Analysis complete! Export results with:")
    println("  - Function list")
    println("  - String references")
    println("  - Cross-references to PD firmware")
    println("=" * 60)


main()
