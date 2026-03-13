# Ghidra pre-script: set base address for imported binary
# @author acpi-fixup
# @category Firmware

from ghidra.program.model.mem import MemoryConflictException


def set_base_address():
    """Move the code block to the correct NPCX base address 0x10070000."""
    mem = currentProgram.getMemory()
    blocks = mem.getBlocks()

    target_base = 0x10070000
    space = currentProgram.getAddressFactory().getDefaultAddressSpace()
    target_addr = space.getAddress(target_base)

    for block in blocks:
        current_start = block.getStart()
        println(
            "  Block '%s': 0x%08X - 0x%08X (%d bytes)"
            % (block.getName(), current_start.getOffset(), block.getEnd().getOffset(), block.getSize())
        )

        if current_start.getOffset() != target_base:
            println("  Moving block to 0x%08X..." % target_base)
            try:
                mem.moveBlock(block, target_addr, monitor)
                println("  Block moved successfully!")
            except MemoryConflictException as e:
                println("  Conflict moving block: %s" % str(e))
            except Exception as e:
                println("  Error moving block: %s" % str(e))


println("=== Setting EC firmware base address ===")
set_base_address()
