#!/usr/bin/env python3
"""Ghidra Headless post-analysis script — export decompiled IRQ handlers.

Run with analyzeHeadless:
  /path/to/analyzeHeadless /tmp/ghidra_project EC_Analysis \
    -import firmware/ec/N3GHT25W_extracted.bin \
    -processor "ARM:LE:32:Cortex" \
    -cspec "default" \
    -loader BinaryLoader \
    -loader-baseAddr 0x10070000 \
    -postScript scripts/ghidra_export_irq.py \
    -scriptPath scripts/ \
    -deleteProject

This script:
  1. Creates memory regions (SRAM, peripheral)
  2. Parses vector table and creates function labels
  3. Runs auto-analysis
  4. Decompiles each IRQ handler
  5. Writes results to docs/ec_irq_decompiled.txt
"""
# @name EC_IRQ_Export
# @category Firmware
# @description Export decompiled IRQ handlers

import struct
import os

EC_BASE = 0x10070000
VT_OFFSET = 0x0100
OUTPUT_FILE = "docs/ec_irq_decompiled.txt"

# Vector names
VT_NAMES = [
    "SP_Main", "Reset_Handler", "NMI_Handler", "HardFault_Handler",
    "MemManage_Handler", "BusFault_Handler", "UsageFault_Handler",
    "Reserved_7", "Reserved_8", "Reserved_9", "Reserved_10",
    "SVC_Handler", "DebugMon_Handler", "Reserved_13",
    "PendSV_Handler", "SysTick_Handler",
]
for i in range(64):
    VT_NAMES.append(f"IRQ{i}_Handler")

try:
    from ghidra.app.decompiler import DecompInterface
    from ghidra.program.model.symbol import SourceType
    from ghidra.program.model.mem import MemoryBlockType
    from ghidra.program.model.address import AddressSet
    import ghidra.app.cmd.function.CreateFunctionCmd as CreateFunctionCmd

    IN_GHIDRA = True
except ImportError:
    IN_GHIDRA = False

if IN_GHIDRA:
    program = currentProgram
    mem = program.getMemory()
    listing = program.getListing()
    symtab = program.getSymbolTable()
    af = program.getAddressFactory()

    def addr(offset):
        return af.getDefaultAddressSpace().getAddress(offset)

    # ── Step 1: Add SRAM memory block ──
    try:
        txn = program.startTransaction("Add Memory Blocks")
        sram = mem.createUninitializedBlock("SRAM", addr(0x200C0000), 0x8000, False)
        sram.setRead(True)
        sram.setWrite(True)
        sram.setExecute(False)

        periph = mem.createUninitializedBlock("PERIPH", addr(0x40000000), 0x10000000, False)
        periph.setRead(True)
        periph.setWrite(True)
        periph.setExecute(False)
        periph.setVolatile(True)

        arm_sys = mem.createUninitializedBlock("ARM_SYS", addr(0xE0000000), 0x100000, False)
        arm_sys.setRead(True)
        arm_sys.setWrite(True)
        arm_sys.setExecute(False)
        arm_sys.setVolatile(True)

        program.endTransaction(txn, True)
        print("[EC_IRQ_Export] Memory blocks created")
    except Exception as e:
        try:
            program.endTransaction(txn, False)
        except:
            pass
        print(f"[EC_IRQ_Export] Memory block error (may already exist): {e}")

    # ── Step 2: Parse vector table ──
    vt_addr = EC_BASE + VT_OFFSET
    block = mem.getBlock(addr(EC_BASE))
    vectors = []

    txn = program.startTransaction("Create VT Functions")
    for i in range(80):
        va = vt_addr + i * 4
        raw = mem.getInt(addr(va))
        val = raw & 0xFFFFFFFF
        vectors.append(val)

        if i >= 1 and val != 0 and (EC_BASE <= (val & ~1) < EC_BASE + 0x80000):
            func_addr = addr(val & ~1)
            name = VT_NAMES[i] if i < len(VT_NAMES) else f"VT{i}_Handler"

            # Create function
            func = listing.getFunctionAt(func_addr)
            if func is None:
                cmd = CreateFunctionCmd(func_addr)
                cmd.applyTo(program)
                func = listing.getFunctionAt(func_addr)

            if func is not None:
                func.setName(name, SourceType.USER_DEFINED)

            # Label the VT entry
            symtab.createLabel(addr(va), f"VT_{name}", SourceType.USER_DEFINED)

    program.endTransaction(txn, True)
    print(f"[EC_IRQ_Export] {len(vectors)} vector entries processed")

    # ── Step 3: Run auto-analysis ──
    from ghidra.app.cmd.disassemble import DisassembleCommand
    from ghidra.program.util import GhidraProgramUtilities

    analyzeAll(program)
    print("[EC_IRQ_Export] Auto-analysis complete")

    # ── Step 4: Decompile handlers ──
    decomp = DecompInterface()
    decomp.openProgram(program)

    output_lines = []
    output_lines.append("=" * 80)
    output_lines.append("ThinkPad Z13 Gen1 EC — IRQ Handler Decompilation")
    output_lines.append(f"Firmware: N3GHT15W, Base: {EC_BASE:#010x}")
    output_lines.append("=" * 80)
    output_lines.append("")

    handler_addrs = set()
    for i in range(1, 80):
        if i < len(vectors):
            val = vectors[i]
            if val != 0 and (EC_BASE <= (val & ~1) < EC_BASE + 0x80000):
                handler_addrs.add(val & ~1)

    for func_addr_int in sorted(handler_addrs):
        func = listing.getFunctionAt(addr(func_addr_int))
        if func is None:
            continue

        name = func.getName()
        output_lines.append(f"\n{'─' * 60}")
        output_lines.append(f"// {name} @ {func_addr_int:#010x}")
        output_lines.append(f"{'─' * 60}")

        result = decomp.decompileFunction(func, 30, monitor)
        if result and result.decompileCompleted():
            c_code = result.getDecompiledFunction().getC()
            output_lines.append(c_code)
        else:
            output_lines.append(f"// Decompilation failed for {name}")
            # Fall back to listing
            insn = listing.getInstructionAt(addr(func_addr_int))
            count = 0
            while insn and count < 50:
                output_lines.append(f"  {insn.getAddress()}  {insn}")
                insn = insn.getNext()
                count += 1

        output_lines.append("")

    decomp.dispose()

    # ── Step 5: Write output ──
    # Get project directory from script path or use cwd
    try:
        import java.io.File as File
        script_dir = os.path.dirname(getSourceFile().getAbsolutePath())
        project_root = os.path.dirname(script_dir)
        out_path = os.path.join(project_root, OUTPUT_FILE)
    except:
        out_path = OUTPUT_FILE

    with open(out_path, "w") as f:
        f.write("\n".join(output_lines))

    print(f"[EC_IRQ_Export] Wrote {len(output_lines)} lines to {out_path}")
    print(f"[EC_IRQ_Export] Decompiled {len(handler_addrs)} unique handlers")

else:
    print("This script must be run inside Ghidra (headless or GUI).")
    print("Usage:")
    print("  analyzeHeadless /tmp/ghidra_project EC_Analysis \\")
    print("    -import firmware/ec/N3GHT25W_extracted.bin \\")
    print("    -processor 'ARM:LE:32:Cortex' \\")
    print("    -loader BinaryLoader -loader-baseAddr 0x10070000 \\")
    print("    -postScript scripts/ghidra_export_irq.py")
