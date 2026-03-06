# Ghidra export script - extract analysis results for further processing
# @author acpi-fixup analysis
# @category Firmware

import json
from ghidra.program.model.symbol import SourceType, SymbolType
from ghidra.program.model.block import BasicBlockModel
from ghidra.util.task import ConsoleTaskMonitor

def export_functions():
    """Export all identified functions."""
    fm = currentProgram.getFunctionManager()
    funcs = []
    for func in fm.getFunctions(True):
        entry = func.getEntryPoint()
        body = func.getBody()
        refs_to = []
        for ref in getReferencesTo(entry):
            refs_to.append("0x%08X" % ref.getFromAddress().getOffset())
        
        funcs.append({
            "name": func.getName(),
            "entry": "0x%08X" % entry.getOffset(),
            "size": body.getNumAddresses(),
            "refs_from": refs_to[:10],  # Limit
        })
    return funcs

def export_strings():
    """Export all defined strings."""
    listing = currentProgram.getListing()
    strings = []
    data_iter = listing.getDefinedData(True)
    while data_iter.hasNext():
        d = data_iter.next()
        dt = d.getDataType()
        if "string" in dt.getName().lower() or "char" in dt.getName().lower():
            val = d.getValue()
            if val and len(str(val)) >= 4:
                strings.append({
                    "addr": "0x%08X" % d.getAddress().getOffset(),
                    "value": str(val),
                    "type": dt.getName(),
                })
    return strings

def export_xrefs_to_smbus():
    """Find all code that accesses SMBus/I2C registers."""
    mem = currentProgram.getMemory()
    space = currentProgram.getAddressFactory().getDefaultAddressSpace()
    
    smb_regions = [
        (0x400D7000, 0x400D7100, "SMB0"),
        (0x400D9000, 0x400D9100, "SMB1"),
        (0x400DB000, 0x400DB100, "SMB2"),
        (0x400DD000, 0x400DD100, "SMB3"),
        (0x40080000, 0x40080100, "SMB4"),
        (0x40082000, 0x40082100, "SMB5"),
        (0x40084000, 0x40084100, "SMB6"),
        (0x40086000, 0x40086100, "SMB7"),
    ]
    
    results = {}
    for start, end, name in smb_regions:
        refs = []
        for addr_val in range(start, end, 2):
            addr = space.getAddress(addr_val)
            for ref in getReferencesTo(addr):
                from_addr = ref.getFromAddress()
                # Find containing function
                func = getFunctionContaining(from_addr)
                func_name = func.getName() if func else "unknown"
                refs.append({
                    "from": "0x%08X" % from_addr.getOffset(),
                    "to_reg": "0x%08X" % addr_val,
                    "function": func_name,
                })
        if refs:
            results[name] = refs
    
    return results

def export_pd_string_xrefs():
    """Find cross-references to PD firmware version strings."""
    mem = currentProgram.getMemory()
    space = currentProgram.getAddressFactory().getDefaultAddressSpace()
    
    pd_strings = ["N3GPD17W", "N3GPH20W", "N3GPH70W"]
    results = {}
    
    for s in pd_strings:
        search_bytes = bytearray(s.encode('ascii'))
        addr = mem.findBytes(space.getAddress(0x10070000), search_bytes, None, True, monitor)
        if addr:
            refs = []
            for ref in getReferencesTo(addr):
                from_addr = ref.getFromAddress()
                func = getFunctionContaining(from_addr)
                func_name = func.getName() if func else "unknown"
                refs.append({
                    "from": "0x%08X" % from_addr.getOffset(),
                    "function": func_name,
                })
            results[s] = {
                "addr": "0x%08X" % addr.getOffset(),
                "refs": refs,
            }
    
    return results

def export_gpio_xrefs():
    """Find code that accesses GPIO registers."""
    space = currentProgram.getAddressFactory().getDefaultAddressSpace()
    
    gpio_ranges = [
        (0x400C7000, 0x400C7100, "GPIO_MAIN"),
        (0x40090000, 0x400A0000, "GPIO_ALT"),
    ]
    
    results = {}
    for start, end, name in gpio_ranges:
        refs = []
        step = 2 if (end - start) < 0x1000 else 0x100
        for addr_val in range(start, end, step):
            addr = space.getAddress(addr_val)
            for ref in getReferencesTo(addr):
                from_addr = ref.getFromAddress()
                func = getFunctionContaining(from_addr)
                func_name = func.getName() if func else "unknown"
                refs.append({
                    "from": "0x%08X" % from_addr.getOffset(),
                    "to_reg": "0x%08X" % addr_val,
                    "function": func_name,
                })
        if refs:
            results[name] = refs[:50]  # Limit output
    
    return results

def main():
    println("Exporting analysis results...")
    
    results = {
        "program": currentProgram.getName(),
        "base_addr": "0x%08X" % currentProgram.getMinAddress().getOffset(),
        "functions": export_functions(),
        "strings": export_strings(),
        "smbus_xrefs": export_xrefs_to_smbus(),
        "pd_string_xrefs": export_pd_string_xrefs(),
        "gpio_xrefs": export_gpio_xrefs(),
    }
    
    # Write to file
    output_path = "/home/drie/桌面/acpi-fixup/firmware/ec_analysis_results.json"
    with open(output_path, 'w') as f:
        json.dump(results, f, indent=2)
    
    println("Results exported to: %s" % output_path)
    println("Functions found: %d" % len(results["functions"]))
    println("Strings found: %d" % len(results["strings"]))
    
    # Also print summary
    println("\n=== FUNCTION SUMMARY ===")
    for func in sorted(results["functions"], key=lambda x: -x["size"])[:30]:
        println("  %s: %s (%d bytes, %d refs)" % (
            func["entry"], func["name"], func["size"], len(func["refs_from"])))
    
    println("\n=== PD STRING REFERENCES ===")
    for name, info in results.get("pd_string_xrefs", {}).items():
        println("  %s at %s:" % (name, info["addr"]))
        for ref in info.get("refs", []):
            println("    from %s in %s" % (ref["from"], ref["function"]))

main()
