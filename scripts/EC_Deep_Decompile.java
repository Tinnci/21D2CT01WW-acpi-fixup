// EC Deep Function Decompilation — decompile key subroutines called by IRQ handlers
//
// Run with:
//   analyzeHeadless /tmp/ghidra_ec EC_N3GHT15W \
//     -import firmware/ec/N3GHT25W_extracted.bin \
//     -processor "ARM:LE:32:Cortex" -cspec "default" \
//     -loader BinaryLoader -loader-baseAddr "0x10070000" \
//     -postScript EC_Deep_Decompile.java \
//     -scriptPath scripts/ -deleteProject -overwrite
//
// @category Firmware
// @description Deep decompile key EC subroutines

import ghidra.app.script.GhidraScript;
import ghidra.app.decompiler.DecompInterface;
import ghidra.app.decompiler.DecompileResults;
import ghidra.app.cmd.function.CreateFunctionCmd;
import ghidra.program.model.listing.*;
import ghidra.program.model.address.Address;
import ghidra.program.model.mem.Memory;
import ghidra.program.model.mem.MemoryBlock;
import ghidra.program.model.symbol.SourceType;
import ghidra.program.model.symbol.Reference;
import ghidra.program.model.symbol.ReferenceIterator;
import ghidra.program.model.symbol.SymbolIterator;

import java.io.File;
import java.io.PrintWriter;
import java.util.*;

public class EC_Deep_Decompile extends GhidraScript {

    static final long EC_BASE = 0x10070000L;

    // Key functions identified from IRQ handler analysis
    static final long[][] KEY_FUNCS = {
        // {address, 0=regular/1=named}
        {0x10082700L}, // Event dispatcher — called by almost all IRQ handlers with event ID
        {0x10082720L}, // Interrupt lock (disable IRQ n)
        {0x10082740L}, // Interrupt unlock (enable IRQ n)
        {0x10086fb8L}, // Hot sub — called by 298+ sites, likely FIFO/queue push
        {0x100720d4L}, // Task/event post (called with 0x53 etc.)
        {0x10086ad4L}, // eSPI sub (IRQ49/61)
        {0x10098500L}, // ACPI EC command handler (called from IRQ8)
        {0x10099b80L}, // GPIO handler sub (IRQ60/41)
        {0x10086050L}, // GPIO sub (IRQ60)
        {0x1008da80L}, // SMBus master TX (IRQ48)
        {0x1008da4cL}, // SMBus master RX (IRQ48)
        {0x1009e1f0L}, // Thunk from IRQ60
    };

    // Descriptive names for key functions
    static final String[] KEY_NAMES = {
        "ec_event_dispatch",
        "ec_irq_lock",
        "ec_irq_unlock",
        "ec_fifo_push",
        "ec_task_post",
        "ec_espi_sub",
        "ec_acpi_cmd_handler",
        "ec_gpio_handler_sub",
        "ec_gpio_sub",
        "ec_smbus_master_tx",
        "ec_smbus_master_rx",
        "ec_thunk_irq60",
    };

    private Address mkAddr(long offset) {
        return currentProgram.getAddressFactory()
            .getDefaultAddressSpace().getAddress(offset);
    }

    @Override
    public void run() throws Exception {
        Memory mem = currentProgram.getMemory();

        // Add memory blocks
        int txn = currentProgram.startTransaction("Add Memory Blocks");
        try {
            createBlock(mem, "SRAM",    0x200C0000L, 0x8000,     false);
            createBlock(mem, "PERIPH",  0x40000000L, 0x10000000, true);
            createBlock(mem, "ARM_SYS", 0xE0000000L, 0x100000,   true);
            currentProgram.endTransaction(txn, true);
        } catch (Exception e) {
            currentProgram.endTransaction(txn, false);
        }

        // Create VT functions first (same as EC_IRQ_Export)
        createVTFunctions(mem);

        // Label key functions
        txn = currentProgram.startTransaction("Label Key Functions");
        for (int i = 0; i < KEY_FUNCS.length; i++) {
            long addr = KEY_FUNCS[i][0];
            Address fa = mkAddr(addr);
            Function func = currentProgram.getListing().getFunctionAt(fa);
            if (func == null) {
                CreateFunctionCmd cmd = new CreateFunctionCmd(fa);
                cmd.applyTo(currentProgram);
                func = currentProgram.getListing().getFunctionAt(fa);
            }
            if (func != null && i < KEY_NAMES.length) {
                try {
                    func.setName(KEY_NAMES[i], SourceType.USER_DEFINED);
                } catch (Exception e) { /* duplicate name */ }
            }
        }
        currentProgram.endTransaction(txn, true);

        // Re-analyze
        println("[EC_Deep] Running auto-analysis...");
        analyzeAll(currentProgram);
        println("[EC_Deep] Analysis complete.");

        // Decompile key functions + all functions they call (2 levels deep)
        DecompInterface decomp = new DecompInterface();
        decomp.openProgram(currentProgram);

        StringBuilder sb = new StringBuilder();
        sb.append(repeat("=", 80)).append("\n");
        sb.append("ThinkPad Z13 Gen1 EC — Deep Function Decompilation\n");
        sb.append(String.format("Firmware: N3GHT15W  Base: 0x%08X\n", EC_BASE));
        sb.append(repeat("=", 80)).append("\n\n");

        // First pass: decompile all key functions
        Set<Long> decompiled = new TreeSet<>();
        Set<Long> callees = new TreeSet<>();

        sb.append("## Level 0: Key Functions (called directly from IRQ handlers)\n\n");
        for (int i = 0; i < KEY_FUNCS.length; i++) {
            long addr = KEY_FUNCS[i][0];
            String result = decompileFunction(decomp, addr, KEY_NAMES[i]);
            sb.append(result);
            decompiled.add(addr);

            // Collect callees
            collectCallees(addr, callees);
        }

        // Second pass: decompile callees (level 1)
        callees.removeAll(decompiled);
        if (!callees.isEmpty()) {
            sb.append("\n\n## Level 1: Callees of key functions\n\n");
            Set<Long> level2Callees = new TreeSet<>();
            for (Long addr : callees) {
                if (addr < EC_BASE || addr >= EC_BASE + 0x80000) continue;
                Function func = currentProgram.getListing().getFunctionAt(mkAddr(addr));
                String name = func != null ? func.getName() : String.format("FUN_%08x", addr);
                String result = decompileFunction(decomp, addr, name);
                sb.append(result);
                decompiled.add(addr);
                collectCallees(addr, level2Callees);
            }

            // Level 2: one more level for the most important paths
            level2Callees.removeAll(decompiled);
            if (!level2Callees.isEmpty()) {
                sb.append("\n\n## Level 2: Second-level callees\n\n");
                int count = 0;
                for (Long addr : level2Callees) {
                    if (addr < EC_BASE || addr >= EC_BASE + 0x80000) continue;
                    if (count >= 50) break; // limit
                    Function func = currentProgram.getListing().getFunctionAt(mkAddr(addr));
                    String name = func != null ? func.getName() : String.format("FUN_%08x", addr);
                    String result = decompileFunction(decomp, addr, name);
                    sb.append(result);
                    decompiled.add(addr);
                    count++;
                }
            }
        }

        decomp.dispose();

        // Summary of all DAT_ references (global variables)
        sb.append("\n\n## Global Variable References (DAT_*)\n\n");
        sb.append(collectGlobalRefs());

        // Write output
        String scriptPath = getSourceFile().getAbsolutePath();
        File scriptFile = new File(scriptPath);
        File projectRoot = scriptFile.getParentFile().getParentFile();
        File outFile = new File(projectRoot, "docs/ec_deep_decompiled.txt");
        PrintWriter pw = new PrintWriter(outFile, "UTF-8");
        pw.print(sb.toString());
        pw.close();

        println("[EC_Deep] Output: " + outFile.getAbsolutePath());
        println("[EC_Deep] Decompiled " + decompiled.size() + " functions total.");
        println("[EC_Deep] DONE.");
    }

    private String decompileFunction(DecompInterface decomp, long addr, String name) {
        StringBuilder sb = new StringBuilder();
        sb.append("\n" + repeat("─", 70) + "\n");
        sb.append(String.format("// %s @ 0x%08X\n", name, addr));
        sb.append(repeat("─", 70) + "\n");

        Function func = currentProgram.getListing().getFunctionAt(mkAddr(addr));
        if (func == null) {
            // Try creating it
            CreateFunctionCmd cmd = new CreateFunctionCmd(mkAddr(addr));
            cmd.applyTo(currentProgram);
            func = currentProgram.getListing().getFunctionAt(mkAddr(addr));
        }

        if (func != null) {
            DecompileResults result = decomp.decompileFunction(func, 60, monitor);
            if (result != null && result.decompileCompleted() &&
                result.getDecompiledFunction() != null) {
                sb.append(result.getDecompiledFunction().getC());
            } else {
                sb.append("// Decompilation FAILED\n");
                appendDisasm(sb, addr, 40);
            }

            // Show xrefs to this function
            sb.append(String.format("\n// XRefs to %s: ", name));
            ReferenceIterator refs = currentProgram.getReferenceManager()
                .getReferencesTo(mkAddr(addr));
            int refCount = 0;
            StringBuilder refSb = new StringBuilder();
            while (refs.hasNext() && refCount < 20) {
                Reference ref = refs.next();
                if (refCount > 0) refSb.append(", ");
                refSb.append(String.format("0x%08X", ref.getFromAddress().getOffset()));
                refCount++;
            }
            sb.append(refCount + " refs");
            if (refCount > 0) sb.append(" [" + refSb.toString() + "]");
            sb.append("\n\n");
        } else {
            sb.append("// No function could be created\n\n");
        }

        return sb.toString();
    }

    private void collectCallees(long funcAddr, Set<Long> callees) {
        Function func = currentProgram.getListing().getFunctionAt(mkAddr(funcAddr));
        if (func == null) return;

        // Get all called functions
        Set<Function> called = func.getCalledFunctions(monitor);
        for (Function f : called) {
            callees.add(f.getEntryPoint().getOffset());
        }
    }

    private String collectGlobalRefs() {
        StringBuilder sb = new StringBuilder();
        // Find all labeled data in SRAM range
        SymbolIterator symbols = currentProgram.getSymbolTable().getAllSymbols(true);
        Map<String, Long> sramRefs = new TreeMap<>();
        Map<String, Long> periphRefs = new TreeMap<>();

        // Instead, look at defined data
        DataIterator dataIter = currentProgram.getListing().getDefinedData(true);
        int count = 0;
        while (dataIter.hasNext() && count < 500) {
            Data data = dataIter.next();
            long offset = data.getAddress().getOffset();
            Object val = data.getValue();
            if (val instanceof ghidra.program.model.address.Address) {
                long target = ((ghidra.program.model.address.Address)val).getOffset();
                if (target >= 0x200C0000L && target < 0x200C8000L) {
                    sb.append(String.format("  0x%08X -> SRAM 0x%08X\n", offset, target));
                    count++;
                } else if (target >= 0x40000000L && target < 0x50000000L) {
                    sb.append(String.format("  0x%08X -> PERIPH 0x%08X", offset, target));
                    sb.append(classifyPeripheral(target));
                    sb.append("\n");
                    count++;
                }
            }
        }
        return sb.toString();
    }

    private String classifyPeripheral(long addr) {
        if (addr >= 0x40080000L && addr < 0x40090000L) return " [GPIO_0]";
        if (addr >= 0x40090000L && addr < 0x400A0000L) return " [GPIO_1]";
        if (addr >= 0x400A0000L && addr < 0x400B0000L) return " [SMBUS_" + ((addr - 0x400A0000L) / 0x400) + "]";
        if (addr >= 0x400B0000L && addr < 0x400C0000L) return " [eSPI]";
        if (addr >= 0x400C0000L && addr < 0x400D0000L) return " [KBD]";
        if (addr >= 0x400D0000L && addr < 0x400E0000L) return " [TIMER]";
        if (addr >= 0x400E0000L && addr < 0x400F0000L) return " [ACPI_EC]";
        if (addr >= 0x400F0000L && addr < 0x40100000L) return " [SPI]";
        if (addr >= 0x40100000L && addr < 0x40110000L) return " [UART]";
        if (addr >= 0x40110000L && addr < 0x40120000L) return " [PWM]";
        return "";
    }

    // === Helpers (same as EC_IRQ_Export) ===

    private void createVTFunctions(Memory mem) throws Exception {
        long vtBase = EC_BASE + 0x0100;
        String[] sysNames = {
            "SP_Main", "Reset_Handler", "NMI_Handler", "HardFault_Handler",
            "MemManage_Handler", "BusFault_Handler", "UsageFault_Handler",
            "Rsvd7", "Rsvd8", "Rsvd9", "Rsvd10",
            "SVC_Handler", "DebugMon_Handler", "Rsvd13",
            "PendSV_Handler", "SysTick_Handler"
        };

        int txn = currentProgram.startTransaction("Create VT Functions");
        for (int i = 1; i < 80; i++) {
            long entryAddr = vtBase + (long)i * 4;
            long raw = mem.getInt(mkAddr(entryAddr)) & 0xFFFFFFFFL;
            if (raw != 0) {
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
                        String name = i < sysNames.length ? sysNames[i] :
                            "IRQ" + (i - 16) + "_Handler";
                        func.setName(name, SourceType.USER_DEFINED);
                    }
                }
            }
        }
        currentProgram.endTransaction(txn, true);
    }

    private void createBlock(Memory mem, String name, long start, long size,
                             boolean isVolatile) throws Exception {
        MemoryBlock blk = mem.createUninitializedBlock(name, mkAddr(start), size, false);
        blk.setRead(true);
        blk.setWrite(true);
        blk.setExecute(false);
        if (isVolatile) blk.setVolatile(true);
    }

    private void appendDisasm(StringBuilder sb, long addr, int maxInsn) {
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
