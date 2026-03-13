#!/usr/bin/env python3
"""
EC Probe Tool - Direct ACPI EC communication for ThinkPad Z13 Gen 1
Uses /dev/port for raw I/O port access to ACPI EC (ports 0x62/0x66)

ACPI EC Protocol:
  Data port: 0x62
  Command/Status port: 0x66
  Status bits: OBF (bit 0), IBF (bit 1), CMD (bit 3), BURST (bit 4), SCI_EVT (bit 5)

EC Command Set (from reverse engineering):
  0x80: Standard read (addr) -> data
  0x81: Standard write (addr, data)
  0x82: Burst enable
  0x83: Burst disable
  0x84: Query (returns event code)
  0xA0-0xAF: Extended read commands (handled by FUN_10075078)
  0xCD: Vendor flash command (DO NOT USE)
  0xCE: Vendor config command
  0xCF: Vendor query command

WARNING: Only read operations are safe. Do NOT write to unknown registers.
"""

import sys
import os
import time
import argparse

EC_DATA_PORT = 0x62
EC_CMD_PORT = 0x66

# Status register bits
OBF = 0x01  # Output Buffer Full
IBF = 0x02  # Input Buffer Full
CMD = 0x08  # Command flag
BURST = 0x10  # Burst mode
SCI_EVT = 0x20  # SCI event pending

TIMEOUT_US = 50000  # 50ms timeout
POLL_DELAY = 0.0001  # 100us


class ECPort:
    def __init__(self):
        self.fd = None

    def open(self):
        try:
            self.fd = os.open("/dev/port", os.O_RDWR)
        except PermissionError:
            print("ERROR: Need root privileges. Run with sudo.", file=sys.stderr)
            sys.exit(1)

    def close(self):
        if self.fd is not None:
            os.close(self.fd)
            self.fd = None

    def inb(self, port):
        os.lseek(self.fd, port, os.SEEK_SET)
        data = os.read(self.fd, 1)
        return data[0]

    def outb(self, port, val):
        os.lseek(self.fd, port, os.SEEK_SET)
        os.write(self.fd, bytes([val & 0xFF]))

    def wait_ibf_clear(self, timeout_ms=50):
        """Wait for Input Buffer Full flag to clear"""
        deadline = time.monotonic() + timeout_ms / 1000.0
        while time.monotonic() < deadline:
            status = self.inb(EC_CMD_PORT)
            if not (status & IBF):
                return True
            time.sleep(POLL_DELAY)
        return False

    def wait_obf_set(self, timeout_ms=50):
        """Wait for Output Buffer Full flag to set"""
        deadline = time.monotonic() + timeout_ms / 1000.0
        while time.monotonic() < deadline:
            status = self.inb(EC_CMD_PORT)
            if status & OBF:
                return True
            time.sleep(POLL_DELAY)
        return False

    def send_command(self, cmd):
        """Send a command byte to the EC command port"""
        if not self.wait_ibf_clear():
            raise TimeoutError("IBF not clear before command")
        self.outb(EC_CMD_PORT, cmd)

    def send_data(self, data):
        """Send a data byte to the EC data port"""
        if not self.wait_ibf_clear():
            raise TimeoutError("IBF not clear before data send")
        self.outb(EC_DATA_PORT, data)

    def recv_data(self, timeout_ms=50):
        """Receive a data byte from the EC data port"""
        if not self.wait_obf_set(timeout_ms):
            raise TimeoutError("OBF not set - no response from EC")
        return self.inb(EC_DATA_PORT)

    def ec_read(self, addr):
        """Standard EC read (command 0x80)"""
        self.send_command(0x80)
        self.send_data(addr)
        return self.recv_data()

    def ec_status(self):
        """Read EC status register"""
        return self.inb(EC_CMD_PORT)

    def ec_query(self):
        """EC Query command (0x84) - returns pending event code"""
        self.send_command(0x84)
        return self.recv_data(timeout_ms=100)


def cmd_dump(ec, args):
    """Dump the standard EC register space (0x00-0xFF)"""
    print("=== EC Register Space (0x00-0xFF) ===")
    print("     00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F")
    for row in range(16):
        values = []
        for col in range(16):
            addr = row * 16 + col
            try:
                val = ec.ec_read(addr)
                values.append(f"{val:02X}")
            except TimeoutError:
                values.append("??")
        print(f"{row * 16:02X}: {' '.join(values)}")

    # Check firmware version at 0xF0
    fw = []
    for i in range(0xF0, 0xF8):
        fw.append(ec.ec_read(i))
    fw_str = "".join(chr(b) if 32 <= b < 127 else "." for b in fw)
    print(f"\nEC Firmware Version (0xF0-0xF7): {fw_str}")


def cmd_extended_read(ec, args):
    """Test extended read commands (0xA0-0xAF)

    Protocol (from RE of FUN_10075078):
      Send command 0xA0+group (0xA0-0xA9)
      Then the EC returns data based on param_1 and param_2 encoding

    However, the exact data protocol for extended commands may differ.
    Let's probe each command to see which ones the EC ACKs.
    """
    print("=== Extended Read Command Probe (0xA0-0xAF) ===")
    print("Testing which extended commands the EC responds to...\n")

    for cmd in range(0xA0, 0xB0):
        try:
            ec.send_command(cmd)
            # Try to read response
            try:
                val = ec.recv_data(timeout_ms=100)
                print(f"  Cmd 0x{cmd:02X}: Response = 0x{val:02X}")
            except TimeoutError:
                # Maybe it needs additional data bytes first
                print(f"  Cmd 0x{cmd:02X}: No immediate response (may need params)")
        except TimeoutError:
            print(f"  Cmd 0x{cmd:02X}: EC busy (IBF stuck)")

        # Flush any pending data
        time.sleep(0.01)
        status = ec.ec_status()
        if status & OBF:
            _ = ec.inb(EC_DATA_PORT)  # Flush


def cmd_vendor_query(ec, args):
    """Test vendor query command 0xCF (read-only, safe)

    From RE of FUN_10076070:
      0xCF is the query-only variant of 0xCE
    """
    print("=== Vendor Query Command 0xCF ===")
    try:
        ec.send_command(0xCF)
        time.sleep(0.01)
        status = ec.ec_status()
        print(
            f"  Status after 0xCF: 0x{status:02X} (OBF={bool(status & OBF)}, IBF={bool(status & IBF)}, SCI={bool(status & SCI_EVT)})"
        )

        if status & OBF:
            val = ec.inb(EC_DATA_PORT)
            print(f"  Response: 0x{val:02X}")
        else:
            print("  No response data (OBF not set)")
    except TimeoutError as e:
        print(f"  Timeout: {e}")


def cmd_status(ec, args):
    """Read and decode EC status register"""
    status = ec.ec_status()
    print(f"EC Status: 0x{status:02X}")
    print(f"  OBF (Output Buffer Full):  {bool(status & OBF)}")
    print(f"  IBF (Input Buffer Full):   {bool(status & IBF)}")
    print(f"  CMD (Last was command):    {bool(status & CMD)}")
    print(f"  BURST (Burst mode):        {bool(status & BURST)}")
    print(f"  SCI_EVT (SCI pending):     {bool(status & SCI_EVT)}")


def cmd_pd_status(ec, args):
    """Read USB PD related registers from standard EC namespace

    Based on EC register analysis:
    - 0xA0-0xAF region may contain PD port status
    - 0x50-0x5F region has interesting data
    """
    print("=== USB PD Related EC Registers ===\n")

    # Standard namespace PD-related areas
    regions = [
        (0x38, 0x3F, "Power/Fan control area"),
        (0x46, 0x4B, "AC/Battery status area"),
        (0x50, 0x5F, "Config/PD area"),
        (0x60, 0x6F, "Battery/Power detail"),
        (0x78, 0x7F, "Temperature/Status"),
        (0x84, 0x8E, "ID/Speed area"),
        (0xA0, 0xAF, "PD Status area (if mapped)"),
        (0xB0, 0xBF, "Extended status"),
        (0xC0, 0xCF, "Thermal/config area"),
        (0xD0, 0xDF, "Reserved/PD?"),
        (0xF0, 0xFF, "Firmware info"),
    ]

    for start, end, desc in regions:
        values = []
        for addr in range(start, end + 1):
            try:
                val = ec.ec_read(addr)
                values.append(f"{val:02X}")
            except TimeoutError:
                values.append("??")
        ascii_repr = "".join(chr(int(v, 16)) if v != "??" and 32 <= int(v, 16) < 127 else "." for v in values)
        print(f"0x{start:02X}-0x{end:02X} [{desc}]:")
        print(f"  Hex: {' '.join(values)}")
        print(f"  Asc: {ascii_repr}")
        print()


def cmd_monitor(ec, args):
    """Monitor EC register changes in real-time

    Reads all 256 bytes, then continuously monitors for changes.
    Press Ctrl+C to stop.
    """
    print("=== EC Register Monitor ===")
    print("Reading baseline... ", end="", flush=True)

    baseline = []
    for addr in range(256):
        try:
            baseline.append(ec.ec_read(addr))
        except TimeoutError:
            baseline.append(None)
    print("done.")
    print("Monitoring for changes (Ctrl+C to stop)...\n")

    try:
        iteration = 0
        while True:
            changed = False
            for addr in range(256):
                try:
                    val = ec.ec_read(addr)
                    if baseline[addr] is not None and val != baseline[addr]:
                        ts = time.strftime("%H:%M:%S")
                        print(f"[{ts}] 0x{addr:02X}: 0x{baseline[addr]:02X} -> 0x{val:02X}")
                        baseline[addr] = val
                        changed = True
                except TimeoutError:
                    pass
            iteration += 1
            if not changed and iteration % 10 == 0:
                print(f"  ... {iteration} scans, no changes", end="\r")
            time.sleep(0.5)
    except KeyboardInterrupt:
        print("\nMonitor stopped.")


def cmd_probe_extended_protocol(ec, args):
    """Probe extended command protocol by sending command + params

    From RE of FUN_10075078:
      FUN_10075078(uint param_1, uint param_2, ushort *param_3, undefined4 param_4)
      - uVar7 = param_2 >> 4  (group 0-9)
      - uVar2 = param_2 & 0xF (sub-index 0-F)
      - param_1 further selects within each group

    The ACPI EC protocol for extended reads likely is:
      Protocol A: cmd=0xA0, data1=param_2, data2=param_1 -> read result
      Protocol B: cmd=0xA0+N, data1=param -> read result
      Protocol C: cmd=0xA0, data1=combined_byte -> read result
      Protocol D: Like standard read but cmd=0xA0 instead of 0x80

    Let's try multiple protocols systematically.
    """
    print("=== Extended Protocol Probe ===\n")

    # Protocol D: Exactly like standard read (cmd, addr, read)
    # 0xA0 = custom read, then address byte, then read response
    print("--- Protocol D: cmd 0xA0 + addr byte (like standard read) ---")
    for addr in [0x00, 0x01, 0x10, 0x20, 0x40, 0x50, 0x60]:
        try:
            ec.send_command(0xA0)
            ec.send_data(addr)
            try:
                val = ec.recv_data(timeout_ms=100)
                print(f"  0xA0 + addr=0x{addr:02X}: Response = 0x{val:02X}")
            except TimeoutError:
                print(f"  0xA0 + addr=0x{addr:02X}: No response")
        except TimeoutError:
            print(f"  0xA0 + addr=0x{addr:02X}: Timeout")
        time.sleep(0.02)
        if ec.ec_status() & OBF:
            ec.inb(EC_DATA_PORT)

    print()

    # Protocol A: cmd 0xA0, then TWO data bytes (param2, param1), then read
    print("--- Protocol A: cmd 0xA0 + param2 + param1 (two bytes) ---")
    test_pairs = [(0x00, 0x00), (0x00, 0x01), (0x10, 0x00), (0x60, 0x00), (0x60, 0x01)]
    for p2, p1 in test_pairs:
        try:
            ec.send_command(0xA0)
            ec.send_data(p2)
            ec.send_data(p1)
            try:
                val = ec.recv_data(timeout_ms=100)
                print(f"  0xA0 + p2=0x{p2:02X} + p1=0x{p1:02X}: Response = 0x{val:02X}")
            except TimeoutError:
                print(f"  0xA0 + p2=0x{p2:02X} + p1=0x{p1:02X}: No response")
        except TimeoutError:
            print(f"  0xA0 + p2=0x{p2:02X} + p1=0x{p1:02X}: Timeout")
        time.sleep(0.02)
        if ec.ec_status() & OBF:
            ec.inb(EC_DATA_PORT)

    print()

    # Protocol B: Different cmd bytes 0xA0-0xA9 with single param byte
    print("--- Protocol B: cmd 0xA0-0xA9 + single param ---")
    for cmd_offset in range(10):
        cmd = 0xA0 + cmd_offset
        for param in [0x00, 0x01]:
            try:
                ec.send_command(cmd)
                ec.send_data(param)
                try:
                    val = ec.recv_data(timeout_ms=100)
                    print(f"  0x{cmd:02X} + param=0x{param:02X}: Response = 0x{val:02X}")
                except TimeoutError:
                    print(f"  0x{cmd:02X} + param=0x{param:02X}: No response")
            except TimeoutError:
                print(f"  0x{cmd:02X} + param=0x{param:02X}: Timeout")
            time.sleep(0.02)
            if ec.ec_status() & OBF:
                ec.inb(EC_DATA_PORT)

    print()

    # Protocol E: Three data bytes after command
    print("--- Protocol E: cmd 0xA0 + THREE data bytes ---")
    try:
        ec.send_command(0xA0)
        ec.send_data(0x00)  # param1
        ec.send_data(0x00)  # param2
        ec.send_data(0x00)  # param3
        try:
            val = ec.recv_data(timeout_ms=200)
            print(f"  0xA0 + 0x00 + 0x00 + 0x00: Response = 0x{val:02X}")
        except TimeoutError:
            print("  0xA0 + 0x00 + 0x00 + 0x00: No response")
    except TimeoutError:
        print("  Timeout during 3-byte protocol")
    time.sleep(0.02)
    if ec.ec_status() & OBF:
        ec.inb(EC_DATA_PORT)


def cmd_usbc_plug_test(ec, args):
    """Read EC registers before/after USB-C cable plug event

    Reads a snapshot, then waits for you to plug/unplug a USB-C cable
    and takes another snapshot to detect which registers changed.
    """
    print("=== USB-C Plug Detection Test ===")
    print("Step 1: Reading baseline with current cable state...")

    baseline = {}
    for addr in range(256):
        try:
            baseline[addr] = ec.ec_read(addr)
        except TimeoutError:
            baseline[addr] = None

    print("Step 2: Now PLUG or UNPLUG a USB-C cable, then press Enter...")
    input()

    print("Step 3: Reading new state...")
    time.sleep(0.5)  # Let EC settle

    changes = []
    for addr in range(256):
        try:
            val = ec.ec_read(addr)
            if baseline[addr] is not None and val != baseline[addr]:
                changes.append((addr, baseline[addr], val))
        except TimeoutError:
            pass

    if changes:
        print(f"\nDetected {len(changes)} register changes:")
        for addr, old, new in changes:
            bits_changed = old ^ new
            print(f"  0x{addr:02X}: 0x{old:02X} -> 0x{new:02X}  (XOR: 0x{bits_changed:02X}, bits: {bin(bits_changed)})")
    else:
        print("\nNo register changes detected in standard EC namespace.")
        print("USB-C state may be tracked via extended commands or internal EC state only.")


def main():
    parser = argparse.ArgumentParser(description="EC Probe Tool for ThinkPad Z13 Gen 1")
    subparsers = parser.add_subparsers(dest="command", help="Available commands")

    subparsers.add_parser("dump", help="Dump EC register space (0x00-0xFF)")
    subparsers.add_parser("status", help="Read EC status register")
    subparsers.add_parser("pd", help="Read PD-related EC registers")
    subparsers.add_parser("extended", help="Probe extended read commands (0xA0-0xAF)")
    subparsers.add_parser("vendor", help="Test vendor query command 0xCF")
    subparsers.add_parser("monitor", help="Monitor EC register changes")
    subparsers.add_parser("probe", help="Probe extended command protocol")
    subparsers.add_parser("plug", help="USB-C plug/unplug detection test")

    args = parser.parse_args()

    if not args.command:
        parser.print_help()
        sys.exit(1)

    ec = ECPort()
    ec.open()

    try:
        commands = {
            "dump": cmd_dump,
            "status": cmd_status,
            "pd": cmd_pd_status,
            "extended": cmd_extended_read,
            "vendor": cmd_vendor_query,
            "monitor": cmd_monitor,
            "probe": cmd_probe_extended_protocol,
            "plug": cmd_usbc_plug_test,
        }
        commands[args.command](ec, args)
    finally:
        ec.close()


if __name__ == "__main__":
    main()
