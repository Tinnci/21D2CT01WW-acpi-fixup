// EC IRQ Handler Decompilation Export for Ghidra Headless
//
// Run with:
//   analyzeHeadless /tmp/ghidra_ec EC_N3GHT15W \
//     -import firmware/ec/N3GHT25W_extracted.bin \
//     -processor "ARM:LE:32:Cortex" -cspec "default" \
//     -loader BinaryLoader -loader-baseAddr "0x10070000" \
//     -postScript EC_IRQ_Export.java \
//     -scriptPath scripts/ -deleteProject -overwrite
//
// @category Firmware
// @description Export decompiled IRQ handlers for ThinkPad Z13 EC

import ghidra.app.script.GhidraScript;
import ghidra.app.decompiler.DecompInterface;
import ghidra.app.decompiler.DecompileResults;
import ghidra.app.cmd.function.CreateFunctionCmd;
import ghidra.program.model.listing.Function;
import ghidra.program.model.listing.Instruction;
import ghidra.program.model.address.Address;
import ghidra.program.model.mem.Memory;
import ghidra.program.model.mem.MemoryBlock;
import ghidra.program.model.symbol.SourceType;

import java.io.File;
import java.io.PrintWriter;
import java.util.*;

public class EC_IRQ_Export extends GhidraScript {

    static final long EC_BASE = 0x10070000L;
    static final int VT_OFFSET = 0x0100;
    static final int VT_COUNT = 80;

    static final String[] SYSTEM_NAMES = {
        "SP_Main", "Reset_Handler", "NMI_Handler", "HardFault_Handler",
        "MemManage_Handler", "BusFault_Handler", "UsageFault_Handler",
        "Rsvd7", "Rsvd8", "Rsvd9", "Rsvd10",
        "SVC_Handler", "DebugMon_Handler", "Rsvd13",
        "PendSV_Handler", "SysTick_Handler"
    };

    private Address mkAddr(long offset) {
        return currentProgram.getAddressFactory()
            .getDefaultAddressSpace().getAddress(offset);
    }

    @Override
    public void run() throws Exception {
        Memory mem = currentProgram.getMemory();

        // ── Step 1: Create memory blocks ──
        println("[EC_IRQ] Creating memory blocks...");
        int txn = currentProgram.startTransaction("Add Memory Blocks");
        try {
            createBlock(mem, "SRAM",    0x200C0000L, 0x8000,     false, false);
            createBlock(mem, "PERIPH",  0x40000000L, 0x10000000, true,  false);
            createBlock(mem, "ARM_SYS", 0xE0000000L, 0x100000,   true,  false);
            createBlock(mem, "SCS",     0xE000E000L, 0x1000,      true,  false);
            currentProgram.endTransaction(txn, true);
            println("[EC_IRQ] Memory blocks created.");
        } catch (Exception e) {
            currentProgram.endTransaction(txn, false);
            println("[EC_IRQ] Memory block warning: " + e.getMessage());
        }

        // ── Step 2: Parse vector table & create functions ──
        println("[EC_IRQ] Parsing vector table...");
        long vtBase = EC_BASE + VT_OFFSET;
        long[] vectors = new long[VT_COUNT];
        String[] vtNames = new String[VT_COUNT];

        for (int i = 0; i < VT_COUNT; i++) {
            vtNames[i] = getVTName(i);
        }

        txn = currentProgram.startTransaction("Create VT Functions");
        int funcCount = 0;
        for (int i = 0; i < VT_COUNT; i++) {
            long entryAddr = vtBase + (long)i * 4;
            long raw = mem.getInt(mkAddr(entryAddr)) & 0xFFFFFFFFL;
            vectors[i] = raw;

            if (i >= 1 && raw != 0) {
                long funcAddr = raw & ~1L;
                if (funcAddr >= EC_BASE && funcAddr < EC_BASE + 0x80000) {
                    Address fa = mkAddr(funcAddr);
                    Function func = currentProgram.getListing().getFunctionAt(fa);
                    if (func == null) {
                        CreateFunctionCmd cmd = new CreateFunctionCmd(fa);
                        cmd.applyTo(currentProgram);
                        func = currentProgram.getListing().getFunctionAt(fa);
                    }
                    if (func != null) {
                        func.setName(vtNames[i], SourceType.USER_DEFINED);
                        funcCount++;
                    }
                    // Label VT entry
                    currentProgram.getSymbolTable().createLabel(
                        mkAddr(entryAddr), "VT_" + vtNames[i], SourceType.USER_DEFINED);
                }
            }
        }
        currentProgram.endTransaction(txn, true);
        println("[EC_IRQ] Created " + funcCount + " VT functions.");

        // ── Step 3: Re-analyze with new functions ──
        println("[EC_IRQ] Running auto-analysis...");
        analyzeAll(currentProgram);
        println("[EC_IRQ] Auto-analysis complete.");

        // ── Step 4: Decompile all unique handlers ──
        println("[EC_IRQ] Decompiling handlers...");
        DecompInterface decomp = new DecompInterface();
        decomp.openProgram(currentProgram);

        // Collect unique handler addresses
        TreeSet<Long> uniqueAddrs = new TreeSet<>();
        Map<Long, List<String>> addrToNames = new HashMap<>();
        for (int i = 1; i < VT_COUNT; i++) {
            long raw = vectors[i];
            if (raw != 0) {
                long funcAddr = raw & ~1L;
                if (funcAddr >= EC_BASE && funcAddr < EC_BASE + 0x80000) {
                    uniqueAddrs.add(funcAddr);
                    addrToNames.computeIfAbsent(funcAddr, k -> new ArrayList<>())
                               .add(vtNames[i]);
                }
            }
        }

        // Build output
        StringBuilder sb = new StringBuilder();
        sb.append(repeat("=", 80)).append("\n");
        sb.append("ThinkPad Z13 Gen1 EC — IRQ Handler Decompilation\n");
        sb.append(String.format("Firmware: N3GHT15W  Base: 0x%08X  VT: 0x%08X\n",
            EC_BASE, EC_BASE + VT_OFFSET));
        sb.append(String.format("Unique handlers: %d / %d vectors\n",
            uniqueAddrs.size(), VT_COUNT));
        sb.append(repeat("=", 80)).append("\n\n");

        // Summary table
        sb.append("Vector Table Summary:\n");
        sb.append(String.format("  %-4s %-22s %s\n", "VT#", "Name", "Address"));
        sb.append("  " + repeat("-", 50) + "\n");
        for (int i = 0; i < VT_COUNT; i++) {
            long raw = vectors[i];
            if (i == 0) {
                sb.append(String.format("  %-4d %-22s 0x%08X (SP_init)\n", i, vtNames[i], raw));
            } else if (raw != 0 && (raw & ~1L) >= EC_BASE && (raw & ~1L) < EC_BASE + 0x80000) {
                sb.append(String.format("  %-4d %-22s 0x%08X\n", i, vtNames[i], raw & ~1L));
            }
        }
        sb.append("\n");

        // Decompile each unique handler
        int decompiled = 0;
        for (Long funcAddr : uniqueAddrs) {
            Function func = currentProgram.getListing().getFunctionAt(mkAddr(funcAddr));
            List<String> names = addrToNames.get(funcAddr);
            String dispName = (names != null && !names.isEmpty()) ? names.get(0) : "unknown";

            sb.append("\n" + repeat("─", 70) + "\n");
            sb.append(String.format("// %s @ 0x%08X", dispName, funcAddr));
            if (names != null && names.size() > 1) {
                sb.append("  (also: " + String.join(", ", names.subList(1, names.size())) + ")");
            }
            sb.append("\n" + repeat("─", 70) + "\n");

            if (func != null) {
                DecompileResults result = decomp.decompileFunction(func, 60, monitor);
                if (result != null && result.decompileCompleted() &&
                    result.getDecompiledFunction() != null) {
                    sb.append(result.getDecompiledFunction().getC());
                    decompiled++;
                } else {
                    sb.append("// Decompilation FAILED\n");
                    appendDisassembly(sb, funcAddr, 40);
                }
            } else {
                sb.append("// No function at this address\n");
                appendDisassembly(sb, funcAddr, 40);
            }
            sb.append("\n");
        }

        decomp.dispose();
        println("[EC_IRQ] Decompiled " + decompiled + "/" + uniqueAddrs.size() + " handlers.");

        // ── Step 5: Write output file ──
        String scriptPath = getSourceFile().getAbsolutePath();
        File scriptFile = new File(scriptPath);
        File projectRoot = scriptFile.getParentFile().getParentFile();
        File outFile = new File(projectRoot, "docs/ec_irq_decompiled.txt");
        PrintWriter pw = new PrintWriter(outFile, "UTF-8");
        pw.print(sb.toString());
        pw.close();

        println("[EC_IRQ] Output: " + outFile.getAbsolutePath());
        println("[EC_IRQ] Lines: " + sb.toString().split("\n").length);
        println("[EC_IRQ] DONE.");
    }

    private void createBlock(Memory mem, String name, long start, long size,
                             boolean isVolatile, boolean isExec) throws Exception {
        MemoryBlock blk = mem.createUninitializedBlock(name, mkAddr(start), size, false);
        blk.setRead(true);
        blk.setWrite(true);
        blk.setExecute(isExec);
        if (isVolatile) blk.setVolatile(true);
    }

    private String getVTName(int index) {
        if (index < SYSTEM_NAMES.length) return SYSTEM_NAMES[index];
        return "IRQ" + (index - 16) + "_Handler";
    }

    private void appendDisassembly(StringBuilder sb, long addr, int maxInsn) {
        Instruction insn = currentProgram.getListing().getInstructionAt(mkAddr(addr));
        int count = 0;
        while (insn != null && count < maxInsn) {
            sb.append(String.format("  %s  %s\n", insn.getAddress(), insn));
            insn = insn.getNext();
            count++;
        }
    }

    private static String repeat(String s, int n) {
        StringBuilder sb = new StringBuilder(s.length() * n);
        for (int i = 0; i < n; i++) sb.append(s);
        return sb.toString();
    }
}
