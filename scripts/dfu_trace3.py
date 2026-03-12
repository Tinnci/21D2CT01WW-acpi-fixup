#!/usr/bin/env python3
import usb.core, sys, time

LOG = open("/tmp/dfu_result.txt", "w")
def log(s):
    LOG.write(s + "\n")
    LOG.flush()

try:
    dev = usb.core.find(idVendor=0x04d8, idProduct=0x0039)
    if not dev:
        log("No device"); sys.exit(1)
    if dev.is_kernel_driver_active(0):
        dev.detach_kernel_driver(0)
    dev.set_configuration()

    STATES = {0:"appIDLE",2:"dfuIDLE",3:"DNLOAD-SYNC",4:"DNBUSY",
              5:"DNLOAD-IDLE",6:"MANIFEST-SYNC",7:"MANIFEST",
              8:"MANIFEST-WAIT-RST",9:"UPLOAD-IDLE",10:"ERROR"}

    def gs():
        r = dev.ctrl_transfer(0xA1, 3, 0, 0, 6, timeout=5000)
        return r[0], r[1]|(r[2]<<8)|(r[3]<<16), r[4]

    def ps(label):
        s, pt, st = gs()
        log("[%s] status=%d poll=%dms state=%d(%s)" % (label, s, pt, st, STATES.get(st,"?")))
        return st

    log("=== DFU State Trace ===")
    ps("initial")
    try: dev.ctrl_transfer(0x21, 6, 0, 0, None)
    except: pass
    ps("after_abort")

    log("")
    log("DNLOAD block=0 (64B)...")
    dev.ctrl_transfer(0x21, 1, 0, 0, b"\x44\x33" + b"\x00"*62, timeout=5000)
    st = ps("after_blk0")
    if st in (3, 4):
        log("*** PROCESSING ***")
        _, pt, _ = gs()
        if pt > 0: time.sleep(pt/1000.0+0.1)
        ps("poll0")

    log("")
    log("DNLOAD block=1 (64B)...")
    dev.ctrl_transfer(0x21, 1, 1, 0, b"\x00"*64, timeout=5000)
    st = ps("after_blk1")
    if st in (3, 4):
        _, pt, _ = gs()
        if pt > 0: time.sleep(pt/1000.0+0.1)
        ps("poll1")

    log("")
    log("ZLP block=2...")
    dev.ctrl_transfer(0x21, 1, 2, 0, b"", timeout=5000)
    st = ps("after_ZLP")
    if st in (6, 7):
        log("*** MANIFEST ***")
        time.sleep(1)
        ps("manifest_wait")

    try: dev.ctrl_transfer(0x21, 6, 0, 0, None)
    except: pass

    log("")
    log("=== DfuSe SET_ADDRESS ===")
    try:
        dev.ctrl_transfer(0x21, 1, 0, 0, bytes([0x21,0,0,0,0]), timeout=5000)
        st = ps("setaddr")
        if st in (3, 4):
            log("*** DfuSe OK ***")
        elif st == 10:
            log("Not DfuSe")
            dev.ctrl_transfer(0x21, 4, 0, 0, None)
    except Exception as e:
        log("DfuSe err: %s" % e)

    try: dev.ctrl_transfer(0x21, 6, 0, 0, None)
    except: pass

    log("")
    log("=== Upload ===")
    for blk in range(3):
        try:
            r = dev.ctrl_transfer(0xA1, 2, blk, 0, 64, timeout=2000)
            h = " ".join("%02x" % b for b in r[:16]) if len(r) > 0 else ""
            log("blk %d: %dB %s" % (blk, len(r), h))
            if len(r) == 0: break
        except Exception as e:
            log("blk %d: %s" % (blk, e))
            try:
                dev.ctrl_transfer(0x21, 4, 0, 0, None)
                dev.ctrl_transfer(0x21, 6, 0, 0, None)
            except: pass
            break

    log("")
    log("Done.")
except Exception as e:
    import traceback
    log("ERR: %s\n%s" % (e, traceback.format_exc()))
finally:
    LOG.close()
