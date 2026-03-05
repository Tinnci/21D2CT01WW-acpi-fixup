/*
 * Intel ACPI Component Architecture
 * AML/ASL+ Disassembler version 20250404 (64-bit version)
 * Copyright (c) 2000 - 2025 Intel Corporation
 * 
 * Disassembling to symbolic ASL+ operators
 *
 * Disassembly of dsdt.aml
 *
 * Original Table Header:
 *     Signature        "DSDT"
 *     Length           0x00011B76 (72566)
 *     Revision         0x01 **** 32-bit table (V1), no 64-bit math support
 *     Checksum         0x7F
 *     OEM ID           "LENOVO"
 *     OEM Table ID     "TP-RXX  "
 *     OEM Revision     0x000000F5 (240)
 *     Compiler ID      "INTL"
 *     Compiler Version 0x20250404 (539296772)
 */
DefinitionBlock ("", "DSDT", 1, "LENOVO", "TP-RXX  ", 0x000000F5)
{
    External (_SB_.ALIB, MethodObj)    // 2 Arguments
    External (_SB_.APTS, MethodObj)    // 1 Arguments
    External (_SB_.AWAK, MethodObj)    // 1 Arguments
    External (_SB_.PCI0.GP17.VGA_.AFN4, MethodObj)    // 1 Arguments
    External (_SB_.PCI0.GP17.VGA_.AFN7, MethodObj)    // 1 Arguments
    External (_SB_.PCI0.LPC0.EC0_.HAM6, UnknownObj)
    External (_SB_.PCI0.LPC0.EC0_.HPLD, UnknownObj)
    External (_SB_.PCI0.LPC0.EC0_.LHKF, DeviceObj)
    External (_SB_.PCI0.LPC0.EC0_.LISD, IntObj)
    External (_SB_.TPM_.PTS_, MethodObj)    // 1 Arguments
    External (M000, MethodObj)    // 1 Arguments
    External (M017, MethodObj)    // 6 Arguments
    External (M019, MethodObj)    // 4 Arguments
    External (M020, MethodObj)    // 5 Arguments
    External (M460, MethodObj)    // 7 Arguments

    Scope (_SB)
    {
    Device (PC00)
    {
        Name (_ADR, Zero)
        Alias (\_SB.PCI0.GP17.XHC0, XHC0)
        Alias (\_SB.PCI0.GP17.XHC1, XHC1)
        Alias (\_SB.PCI0.GP17.XHC0, XHCI)
    }

        Device (PLTF)
        {
            Name (_HID, "ACPI0010" /* Processor Container Device */)  // _HID: Hardware ID
            Name (_CID, EisaId ("PNP0A05") /* Generic Container Device */)  // _CID: Compatible ID
            Name (_UID, One)  // _UID: Unique ID
            Device (C000)
            {
                Name (_HID, "ACPI0007" /* Processor Device */)  // _HID: Hardware ID
                Name (_UID, Zero)  // _UID: Unique ID
            }

            Device (C001)
            {
                Name (_HID, "ACPI0007" /* Processor Device */)  // _HID: Hardware ID
                Name (_UID, One)  // _UID: Unique ID
            }

            Device (C002)
            {
                Name (_HID, "ACPI0007" /* Processor Device */)  // _HID: Hardware ID
                Name (_UID, 0x02)  // _UID: Unique ID
            }

            Device (C003)
            {
                Name (_HID, "ACPI0007" /* Processor Device */)  // _HID: Hardware ID
                Name (_UID, 0x03)  // _UID: Unique ID
            }

            Device (C004)
            {
                Name (_HID, "ACPI0007" /* Processor Device */)  // _HID: Hardware ID
                Name (_UID, 0x04)  // _UID: Unique ID
            }

            Device (C005)
            {
                Name (_HID, "ACPI0007" /* Processor Device */)  // _HID: Hardware ID
                Name (_UID, 0x05)  // _UID: Unique ID
            }

            Device (C006)
            {
                Name (_HID, "ACPI0007" /* Processor Device */)  // _HID: Hardware ID
                Name (_UID, 0x06)  // _UID: Unique ID
            }

            Device (C007)
            {
                Name (_HID, "ACPI0007" /* Processor Device */)  // _HID: Hardware ID
                Name (_UID, 0x07)  // _UID: Unique ID
            }

            Device (C008)
            {
                Name (_HID, "ACPI0007" /* Processor Device */)  // _HID: Hardware ID
                Name (_UID, 0x08)  // _UID: Unique ID
            }

            Device (C009)
            {
                Name (_HID, "ACPI0007" /* Processor Device */)  // _HID: Hardware ID
                Name (_UID, 0x09)  // _UID: Unique ID
            }

            Device (C00A)
            {
                Name (_HID, "ACPI0007" /* Processor Device */)  // _HID: Hardware ID
                Name (_UID, 0x0A)  // _UID: Unique ID
            }

            Device (C00B)
            {
                Name (_HID, "ACPI0007" /* Processor Device */)  // _HID: Hardware ID
                Name (_UID, 0x0B)  // _UID: Unique ID
            }

            Device (C00C)
            {
                Name (_HID, "ACPI0007" /* Processor Device */)  // _HID: Hardware ID
                Name (_UID, 0x0C)  // _UID: Unique ID
            }

            Device (C00D)
            {
                Name (_HID, "ACPI0007" /* Processor Device */)  // _HID: Hardware ID
                Name (_UID, 0x0D)  // _UID: Unique ID
            }

            Device (C00E)
            {
                Name (_HID, "ACPI0007" /* Processor Device */)  // _HID: Hardware ID
                Name (_UID, 0x0E)  // _UID: Unique ID
            }

            Device (C00F)
            {
                Name (_HID, "ACPI0007" /* Processor Device */)  // _HID: Hardware ID
                Name (_UID, 0x0F)  // _UID: Unique ID
            }
        }
    }

    Name (_S0, Package (0x04)  // _S0_: S0 System State
    {
        Zero, 
        Zero, 
        Zero, 
        Zero
    })
    Name (NOS3, Package (0x04)
    {
        0x03, 
        0x03, 
        Zero, 
        Zero
    })
    Name (_S4, Package (0x04)  // _S4_: S4 System State
    {
        0x04, 
        0x04, 
        Zero, 
        Zero
    })
    Name (_S5, Package (0x04)  // _S5_: S5 System State
    {
        0x05, 
        0x05, 
        Zero, 
        Zero
    })
    Name (TZFG, Zero)
    OperationRegion (DBG0, SystemIO, 0x80, One)
    Field (DBG0, ByteAcc, NoLock, Preserve)
    {
        IO80,   8
    }

    OperationRegion (DEB2, SystemIO, 0x80, 0x02)
    Field (DEB2, WordAcc, NoLock, Preserve)
    {
        P80H,   16
    }

    Method (GSMI, 1, NotSerialized)
    {
        APMD = Arg0
        APMC = 0xE4
        Sleep (0x02)
    }

    Method (BSMI, 1, NotSerialized)
    {
        APMD = Arg0
        APMC = 0xBE
        Sleep (One)
    }

    Method (PPTS, 1, NotSerialized)
    {
        If ((Arg0 == 0x03))
        {
            \_SB.PCI0.SMB.RSTU = Zero
        }

        \_SB.PCI0.SMB.CLPS = One
        \_SB.PCI0.SMB.SLPS = One
        \_SB.PCI0.SMB.PEWS = \_SB.PCI0.SMB.PEWS
    }

    Method (PWAK, 1, NotSerialized)
    {
        If ((Arg0 == 0x03))
        {
            \_SB.PCI0.SMB.RSTU = One
        }

        \_SB.PCI0.SMB.PEWS = \_SB.PCI0.SMB.PEWS
        \_SB.PCI0.SMB.PEWD = Zero
    }

    Method (TPST, 1, Serialized)
    {
        M000 (Arg0)
    }

    Name (PRWP, Package (0x02)
    {
        Zero, 
        Zero
    })
    Method (GPRW, 2, NotSerialized)
    {
        PRWP [Zero] = Arg0
        PRWP [One] = Arg1
        If ((DAS3 == Zero))
        {
            If ((Arg1 <= 0x03))
            {
                PRWP [One] = Zero
            }
        }

        Return (PRWP) /* \PRWP */
    }

    OperationRegion (GNVS, SystemMemory, 0xBAC36E98, 0x0D)
    Field (GNVS, AnyAcc, NoLock, Preserve)
    {
        BRTL,   8, 
        CNSB,   8, 
        DAS3,   8, 
        WKPM,   8, 
        NAPC,   8, 
        PCBA,   32, 
        BT00,   8, 
        MWTT,   8, 
        DPTC,   8, 
        WOVS,   8
    }

    OperationRegion (OGNS, SystemMemory, 0xBAC36F18, 0x05)
    Field (OGNS, AnyAcc, Lock, Preserve)
    {
        THPN,   8, 
        THPD,   8, 
        SDMO,   8, 
        TBEN,   8, 
        TBNH,   8
    }

    OperationRegion (PNVS, SystemMemory, 0xBAC36F98, 0x02)
    Field (PNVS, AnyAcc, NoLock, Preserve)
    {
        HDSI,   8, 
        HDSO,   8
    }

    Name (LINX, Zero)
    Name (OSSP, Zero)
    Name (OSTB, Ones)
    Name (TPOS, Zero)
    Method (OSTP, 0, NotSerialized)
    {
        If ((OSTB == Ones))
        {
            If (CondRefOf (\_OSI, Local0))
            {
                OSTB = Zero
                TPOS = Zero
                If (_OSI ("Windows 2001"))
                {
                    OSTB = 0x08
                    TPOS = 0x08
                }

                If (_OSI ("Windows 2001.1"))
                {
                    OSTB = 0x20
                    TPOS = 0x20
                }

                If (_OSI ("Windows 2001 SP1"))
                {
                    OSTB = 0x10
                    TPOS = 0x10
                }

                If (_OSI ("Windows 2001 SP2"))
                {
                    OSTB = 0x11
                    TPOS = 0x11
                }

                If (_OSI ("Windows 2001 SP3"))
                {
                    OSTB = 0x12
                    TPOS = 0x12
                }

                If (_OSI ("Windows 2006"))
                {
                    OSTB = 0x40
                    TPOS = 0x40
                }

                If (_OSI ("Windows 2006 SP1"))
                {
                    OSSP = One
                    OSTB = 0x40
                    TPOS = 0x40
                }

                If (_OSI ("Windows 2009"))
                {
                    OSSP = One
                    OSTB = 0x50
                    TPOS = 0x50
                }

                If (_OSI ("Windows 2012"))
                {
                    OSSP = One
                    OSTB = 0x60
                    TPOS = 0x60
                }

                If (_OSI ("Windows 2013"))
                {
                    OSSP = One
                    OSTB = 0x61
                    TPOS = 0x61
                }

                If (_OSI ("Windows 2015"))
                {
                    OSSP = One
                    WIN8 = One
                    OSTB = 0x70
                    TPOS = 0x70
                }

                If (_OSI ("Windows 2016"))
                {
                    OSSP = One
                    WIN8 = One
                    OSTB = 0x70
                    TPOS = 0x70
                }

                If (_OSI ("Linux"))
                {
                    LINX = One
                    OSTB = 0x80
                    TPOS = 0x80
                }
            }
            ElseIf (CondRefOf (\_OS, Local0))
            {
                If (SEQL (_OS, "Microsoft Windows"))
                {
                    OSTB = One
                    TPOS = One
                }
                ElseIf (SEQL (_OS, "Microsoft WindowsME: Millennium Edition"))
                {
                    OSTB = 0x02
                    TPOS = 0x02
                }
                ElseIf (SEQL (_OS, "Microsoft Windows NT"))
                {
                    OSTB = 0x04
                    TPOS = 0x04
                }
                Else
                {
                    OSTB = Zero
                    TPOS = Zero
                }
            }
            Else
            {
                OSTB = Zero
                TPOS = Zero
            }

            If ((TPOS == 0x80)){}
        }

        Return (OSTB) /* \OSTB */
    }

    Method (SEQL, 2, Serialized)
    {
        Local0 = SizeOf (Arg0)
        Local1 = SizeOf (Arg1)
        If ((Local0 != Local1))
        {
            Return (Zero)
        }

        Name (BUF0, Buffer (Local0){})
        BUF0 = Arg0
        Name (BUF1, Buffer (Local0){})
        BUF1 = Arg1
        Local2 = Zero
        While ((Local2 < Local0))
        {
            Local3 = DerefOf (BUF0 [Local2])
            Local4 = DerefOf (BUF1 [Local2])
            If ((Local3 != Local4))
            {
                Return (Zero)
            }

            Local2++
        }

        Return (One)
    }

    Method (_PTS, 1, NotSerialized)  // _PTS: Prepare To Sleep
    {
        P80H = Arg0
        PPTS (Arg0)
        If ((Arg0 == 0x05))
        {
            If ((WKPM == One)){}
            BSMI (Zero)
            GSMI (0x03)
            Local1 = 0xC0
        }

        If ((Arg0 == 0x04))
        {
            \_SB.PCI0.SMB.CLPS = One
            \_SB.PCI0.SMB.RSTU = One
            Local1 = 0x80
        }

        If ((Arg0 == 0x03))
        {
            \_SB.PCI0.SMB.SLPS = One
            Local1 = 0x40
        }

        If (CondRefOf (\_SB.TPM.PTS))
        {
            \_SB.TPM.PTS (Arg0)
        }

        \_SB.APTS (Arg0)
        Local0 = One
        If ((Arg0 == SPS))
        {
            Local0 = Zero
        }

        If (((Arg0 == Zero) || (Arg0 >= 0x06)))
        {
            Local0 = Zero
        }

        If (Local0)
        {
            SPS = Arg0
            \_SB.PCI0.LPC0.EC0.HKEY.MHKE (Zero)
            If (\_SB.PCI0.LPC0.EC0.KBLT)
            {
                SCMS (0x0D)
            }

            If ((Arg0 == One))
            {
                FNID = \_SB.PCI0.LPC0.EC0.HFNI
                \_SB.PCI0.LPC0.EC0.HFNI = Zero
                \_SB.PCI0.LPC0.EC0.HFSP = Zero
            }

            If ((Arg0 == 0x03))
            {
                SLTP ()
                ACST = \_SB.PCI0.LPC0.EC0.AC._PSR ()
                If ((FNWK == One))
                {
                    If (H8DR)
                    {
                        \_SB.PCI0.LPC0.EC0.HWFN = Zero
                    }
                    Else
                    {
                        MBEC (0x32, 0xEF, Zero)
                    }
                }
            }

            If ((Arg0 == 0x04))
            {
                \_SB.SLPB._PSW (Zero)
                SLTP ()
                AWON (0x04)
            }

            If ((Arg0 == 0x05))
            {
                SLTP ()
                AWON (0x05)
            }

            If ((Arg0 >= 0x04))
            {
                \_SB.PCI0.LPC0.EC0.HWLB = Zero
            }
            Else
            {
                \_SB.PCI0.LPC0.EC0.HWLB = One
            }

            If ((Arg0 >= 0x03))
            {
                \_SB.PCI0.LPC0.EC0.HCMU = One
            }

            If ((Arg0 != 0x05)){}
            \_SB.PCI0.LPC0.EC0.HKEY.WGPS (Arg0)
        }
    }

    OperationRegion (XMOS, SystemIO, 0x72, 0x02)
    Field (XMOS, ByteAcc, Lock, Preserve)
    {
        XIDX,   8, 
        XDAT,   8
    }

    IndexField (XIDX, XDAT, ByteAcc, Lock, Preserve)
    {
        Offset (0xAE), 
        WKSR,   8
    }

    Name (WAKI, Package (0x02)
    {
        Zero, 
        Zero
    })
    Method (_WAK, 1, NotSerialized)  // _WAK: Wake
    {
        P80H = (Arg0 << 0x04)
        PWAK (Arg0)
        \_SB.AWAK (Arg0)
        If (((Arg0 == 0x03) || (Arg0 == 0x04)))
        {
            If (GPIC)
            {
                \_SB.PCI0.LPC0.DSPI ()
                If (NAPC)
                {
                    \_SB.PCI0.NAPE ()
                }
            }

            If ((WKSR == 0x61))
            {
                Notify (\_SB.PWRB, 0x02) // Device Wake
            }
            ElseIf ((WKSR == 0x68))
            {
                Notify (\_SB.PWRB, 0x02) // Device Wake
            }
            ElseIf ((WKSR == 0x6B))
            {
                Notify (\_SB.PWRB, 0x02) // Device Wake
            }
        }

        If ((Arg0 == 0x03))
        {
            \_SB.PCI0.LPC0.EC0.HWAK = Zero
        }

        If (((Arg0 == Zero) || (Arg0 >= 0x05)))
        {
            Return (WAKI) /* \WAKI */
        }

        SPS = Zero
        Local0 = Zero
        If ((TPOS == 0x40))
        {
            Local0 = One
        }

        If ((TPOS == 0x80))
        {
            Local0 = 0x02
        }

        If ((TPOS == 0x50))
        {
            Local0 = 0x03
        }

        If ((TPOS == 0x60))
        {
            Local0 = 0x04
        }

        If ((TPOS == 0x61))
        {
            Local0 = 0x04
        }

        If ((TPOS == 0x70))
        {
            Local0 = 0x05
        }

        \_SB.PCI0.LPC0.EC0.HCMU = Zero
        \_SB.PCI0.LPC0.EC0.HUBS = Zero
        \_SB.PCI0.LPC0.EC0.EVNT (One)
        \_SB.PCI0.LPC0.EC0.HKEY.MHKE (One)
        \_SB.PCI0.LPC0.EC0.FNST ()
        SCMS (0x0D)
        LIDB = Zero
        If ((Arg0 == One))
        {
            FNID = \_SB.PCI0.LPC0.EC0.HFNI
        }

        If ((Arg0 == 0x03))
        {
            NVSS (Zero)
            IOEN = Zero
            IOST = Zero
            If ((ISWK == One))
            {
                If (\_SB.PCI0.LPC0.EC0.HKEY.DHKC)
                {
                    \_SB.PCI0.LPC0.EC0.HKEY.MHKQ (0x6070)
                }
            }

            VCMS (One, \_SB.LID._LID ())
            AWON (Zero)
            If ((WLAC == 0x02)){}
            ElseIf ((\_SB.PCI0.LPC0.EC0.ELNK && (WLAC == One)))
            {
                \_SB.PCI0.LPC0.EC0.DCWL = Zero
            }
            Else
            {
                \_SB.PCI0.LPC0.EC0.DCWL = One
            }
        }

        If ((Arg0 == 0x04))
        {
            NVSS (Zero)
            \_SB.PCI0.LPC0.EC0.HSPA = Zero
            Local0 = AUDC (Zero, Zero)
            Local0 &= One
            If ((Local0 == Zero))
            {
                \_SB.WFIO (0x54, Zero)
            }
            Else
            {
                \_SB.WFIO (0x54, One)
            }

            IOEN = Zero
            IOST = Zero
            If ((ISWK == 0x02))
            {
                If (\_SB.PCI0.LPC0.EC0.HKEY.DHKC)
                {
                    \_SB.PCI0.LPC0.EC0.HKEY.MHKQ (0x6080)
                }
            }

            If ((WLAC == 0x02)){}
            ElseIf ((\_SB.PCI0.LPC0.EC0.ELNK && (WLAC == One)))
            {
                \_SB.PCI0.LPC0.EC0.DCWL = Zero
            }
            Else
            {
                \_SB.PCI0.LPC0.EC0.DCWL = One
            }
        }

        \_SB.PCI0.LPC0.EC0.BATW (Arg0)
        \_SB.PCI0.LPC0.EC0.HKEY.WGWK (Arg0)
        VSLD (\_SB.LID._LID ())
        If ((Arg0 < 0x04))
        {
            If (((RRBF & 0x02) || (\_SB.PCI0.LPC0.EC0.HWAC & 0x02)))
            {
                Local0 = (Arg0 << 0x08)
                Local0 |= 0x2013
                \_SB.PCI0.LPC0.EC0.HKEY.MHKQ (Local0)
            }
        }

        If ((Arg0 == 0x04))
        {
            Local0 = Zero
            Local1 = CSUM (Zero)
            If ((Local1 != CHKC))
            {
                Local0 = One
                CHKC = Local1
            }

            Local1 = CSUM (One)
            If ((Local1 != CHKE))
            {
                Local0 = One
                CHKE = Local1
            }

            If (Local0)
            {
                Notify (_SB, Zero) // Bus Check
            }
        }

        If (((Arg0 == 0x03) || (Arg0 == 0x04)))
        {
            \_SB.PCI0.LPC0.EC0.HKEY.DYTC (0x000F0001)
        }

        RRBF = Zero
        \_SB.PCI0.LPC0.EC0.AC.ACDC = 0xFF
        Notify (\_SB.PCI0.LPC0.EC0.AC, 0x80) // Status Change
        Notify (\_SB.PCI0, Zero) // Bus Check
        Return (WAKI) /* \WAKI */
    }

    Name (GPIC, Zero)
    Method (_PIC, 1, NotSerialized)  // _PIC: Interrupt Model
    {
        GPIC = Arg0
        If (Arg0)
        {
            \_SB.PCI0.LPC0.DSPI ()
            If (NAPC)
            {
                \_SB.PCI0.NAPE ()
            }
        }
    }

    Scope (_SB)
    {
        Device (PWRB)
        {
            Name (_HID, EisaId ("PNP0C0C") /* Power Button Device */)  // _HID: Hardware ID
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                Return (0x0B)
            }
        }

        Device (PCI0)
        {
            Name (_HID, EisaId ("PNP0A08") /* PCI Express Bus */)  // _HID: Hardware ID
            Name (_CID, EisaId ("PNP0A03") /* PCI Bus */)  // _CID: Compatible ID
            Name (_UID, One)  // _UID: Unique ID
            Name (_BBN, Zero)  // _BBN: BIOS Bus Number
            Name (_ADR, Zero)  // _ADR: Address
            Name (NBRI, Zero)
            Name (NBAR, Zero)
            Name (NCMD, Zero)
            Name (PXDC, Zero)
            Name (PXLC, Zero)
            Name (PXD2, Zero)
            Method (OINI, 0, NotSerialized)
            {
                OSIF = One
                ^LPC0.MOU.MHID ()
                If ((TPOS == 0x80))
                {
                    ^LPC0.EC0.SAUM (0x02)
                    SCMS (0x1C)
                }
            }

            Method (_INI, 0, NotSerialized)  // _INI: Initialize
            {
                If ((GPIC != Zero))
                {
                    ^LPC0.DSPI ()
                    If (NAPC)
                    {
                        NAPE ()
                    }
                }

                OSTP ()
                OINI ()
            }

            Name (SUPP, Zero)
            Name (CTRL, Zero)
            Method (_OSC, 4, NotSerialized)  // _OSC: Operating System Capabilities
            {
                CreateDWordField (Arg3, Zero, CDW1)
                CreateDWordField (Arg3, 0x04, CDW2)
                CreateDWordField (Arg3, 0x08, CDW3)
                If ((Arg0 == ToUUID ("33db4d5b-1ff7-401c-9657-7441c03dd766") /* PCI Host Bridge Device */))
                {
                    SUPP = CDW2 /* \_SB_.PCI0._OSC.CDW2 */
                    CTRL = CDW3 /* \_SB_.PCI0._OSC.CDW3 */
                    If ((TBEN == One))
                    {
                        If ((TBNH != Zero))
                        {
                            CTRL &= 0xFFFFFFF5
                        }
                        Else
                        {
                            CTRL &= 0xFFFFFFF4
                        }
                    }

                    If (((SUPP & 0x16) != 0x16))
                    {
                        CTRL &= 0x1E
                    }

                    CTRL &= 0x1D
                    If (~(CDW1 & One))
                    {
                        If ((CTRL & One)){}
                        If ((CTRL & 0x04)){}
                        If ((CTRL & 0x10)){}
                    }

                    If ((Arg1 != One))
                    {
                        CDW1 |= 0x08
                    }

                    If ((CDW3 != CTRL))
                    {
                        CDW1 |= 0x10
                    }

                    CDW3 = CTRL /* \_SB_.PCI0.CTRL */
                    Return (Arg3)
                }
                Else
                {
                    CDW1 |= 0x04
                    Return (Arg3)
                }
            }

            OperationRegion (K8ST, SystemMemory, 0xBAD78B18, 0x68)
            Field (K8ST, AnyAcc, NoLock, Preserve)
            {
                C0_0,   16, 
                C2_0,   16, 
                C4_0,   16, 
                C6_0,   16, 
                C8_0,   16, 
                CA_0,   16, 
                CC_0,   16, 
                CE_0,   16, 
                D0_0,   16, 
                D2_0,   16, 
                D4_0,   16, 
                D6_0,   16, 
                D8_0,   16, 
                DA_0,   16, 
                DC_0,   16, 
                DE_0,   16, 
                E0_0,   16, 
                E2_0,   16, 
                E4_0,   16, 
                E6_0,   16, 
                E8_0,   16, 
                EA_0,   16, 
                EC_0,   16, 
                EE_0,   16, 
                F0_0,   16, 
                F2_0,   16, 
                F4_0,   16, 
                F6_0,   16, 
                F8_0,   16, 
                FA_0,   16, 
                FC_0,   16, 
                FE_0,   16, 
                TOML,   32, 
                TOMH,   32, 
                PCIB,   32, 
                PCIS,   32, 
                T1MN,   64, 
                T1MX,   64, 
                T1LN,   64
            }

            Name (RSRC, ResourceTemplate ()
            {
                WordBusNumber (ResourceProducer, MinFixed, MaxFixed, SubDecode,
                    0x0000,             // Granularity
                    0x0000,             // Range Minimum
                    0x00FF,             // Range Maximum
                    0x0000,             // Translation Offset
                    0x0100,             // Length
                    0x00,, )
                DWordMemory (ResourceProducer, SubDecode, MinFixed, MaxFixed, NonCacheable, ReadWrite,
                    0x00000000,         // Granularity
                    0x000A0000,         // Range Minimum
                    0x000BFFFF,         // Range Maximum
                    0x00000000,         // Translation Offset
                    0x00020000,         // Length
                    0x00,, , AddressRangeMemory, TypeStatic)
                DWordMemory (ResourceProducer, SubDecode, MinFixed, MaxFixed, NonCacheable, ReadWrite,
                    0x00000000,         // Granularity
                    0x000C0000,         // Range Minimum
                    0x000C1FFF,         // Range Maximum
                    0x00000000,         // Translation Offset
                    0x00002000,         // Length
                    0x00,, , AddressRangeMemory, TypeStatic)
                DWordMemory (ResourceProducer, SubDecode, MinFixed, MaxFixed, NonCacheable, ReadWrite,
                    0x00000000,         // Granularity
                    0x000C2000,         // Range Minimum
                    0x000C3FFF,         // Range Maximum
                    0x00000000,         // Translation Offset
                    0x00002000,         // Length
                    0x00,, , AddressRangeMemory, TypeStatic)
                DWordMemory (ResourceProducer, SubDecode, MinFixed, MaxFixed, NonCacheable, ReadWrite,
                    0x00000000,         // Granularity
                    0x000C4000,         // Range Minimum
                    0x000C5FFF,         // Range Maximum
                    0x00000000,         // Translation Offset
                    0x00002000,         // Length
                    0x00,, , AddressRangeMemory, TypeStatic)
                DWordMemory (ResourceProducer, SubDecode, MinFixed, MaxFixed, NonCacheable, ReadWrite,
                    0x00000000,         // Granularity
                    0x000C6000,         // Range Minimum
                    0x000C7FFF,         // Range Maximum
                    0x00000000,         // Translation Offset
                    0x00002000,         // Length
                    0x00,, , AddressRangeMemory, TypeStatic)
                DWordMemory (ResourceProducer, SubDecode, MinFixed, MaxFixed, NonCacheable, ReadWrite,
                    0x00000000,         // Granularity
                    0x000C8000,         // Range Minimum
                    0x000C9FFF,         // Range Maximum
                    0x00000000,         // Translation Offset
                    0x00002000,         // Length
                    0x00,, , AddressRangeMemory, TypeStatic)
                DWordMemory (ResourceProducer, SubDecode, MinFixed, MaxFixed, NonCacheable, ReadWrite,
                    0x00000000,         // Granularity
                    0x000CA000,         // Range Minimum
                    0x000CBFFF,         // Range Maximum
                    0x00000000,         // Translation Offset
                    0x00002000,         // Length
                    0x00,, , AddressRangeMemory, TypeStatic)
                DWordMemory (ResourceProducer, SubDecode, MinFixed, MaxFixed, NonCacheable, ReadWrite,
                    0x00000000,         // Granularity
                    0x000CC000,         // Range Minimum
                    0x000CDFFF,         // Range Maximum
                    0x00000000,         // Translation Offset
                    0x00002000,         // Length
                    0x00,, , AddressRangeMemory, TypeStatic)
                DWordMemory (ResourceProducer, SubDecode, MinFixed, MaxFixed, NonCacheable, ReadWrite,
                    0x00000000,         // Granularity
                    0x000CE000,         // Range Minimum
                    0x000CFFFF,         // Range Maximum
                    0x00000000,         // Translation Offset
                    0x00002000,         // Length
                    0x00,, , AddressRangeMemory, TypeStatic)
                DWordMemory (ResourceProducer, SubDecode, MinFixed, MaxFixed, NonCacheable, ReadWrite,
                    0x00000000,         // Granularity
                    0x000D0000,         // Range Minimum
                    0x000D1FFF,         // Range Maximum
                    0x00000000,         // Translation Offset
                    0x00002000,         // Length
                    0x00,, , AddressRangeMemory, TypeStatic)
                DWordMemory (ResourceProducer, SubDecode, MinFixed, MaxFixed, NonCacheable, ReadWrite,
                    0x00000000,         // Granularity
                    0x000D2000,         // Range Minimum
                    0x000D3FFF,         // Range Maximum
                    0x00000000,         // Translation Offset
                    0x00002000,         // Length
                    0x00,, , AddressRangeMemory, TypeStatic)
                DWordMemory (ResourceProducer, SubDecode, MinFixed, MaxFixed, NonCacheable, ReadWrite,
                    0x00000000,         // Granularity
                    0x000D4000,         // Range Minimum
                    0x000D5FFF,         // Range Maximum
                    0x00000000,         // Translation Offset
                    0x00002000,         // Length
                    0x00,, , AddressRangeMemory, TypeStatic)
                DWordMemory (ResourceProducer, SubDecode, MinFixed, MaxFixed, NonCacheable, ReadWrite,
                    0x00000000,         // Granularity
                    0x000D6000,         // Range Minimum
                    0x000D7FFF,         // Range Maximum
                    0x00000000,         // Translation Offset
                    0x00002000,         // Length
                    0x00,, , AddressRangeMemory, TypeStatic)
                DWordMemory (ResourceProducer, SubDecode, MinFixed, MaxFixed, NonCacheable, ReadWrite,
                    0x00000000,         // Granularity
                    0x000D8000,         // Range Minimum
                    0x000D9FFF,         // Range Maximum
                    0x00000000,         // Translation Offset
                    0x00002000,         // Length
                    0x00,, , AddressRangeMemory, TypeStatic)
                DWordMemory (ResourceProducer, SubDecode, MinFixed, MaxFixed, NonCacheable, ReadWrite,
                    0x00000000,         // Granularity
                    0x000DA000,         // Range Minimum
                    0x000DBFFF,         // Range Maximum
                    0x00000000,         // Translation Offset
                    0x00002000,         // Length
                    0x00,, , AddressRangeMemory, TypeStatic)
                DWordMemory (ResourceProducer, SubDecode, MinFixed, MaxFixed, NonCacheable, ReadWrite,
                    0x00000000,         // Granularity
                    0x000DC000,         // Range Minimum
                    0x000DDFFF,         // Range Maximum
                    0x00000000,         // Translation Offset
                    0x00002000,         // Length
                    0x00,, , AddressRangeMemory, TypeStatic)
                DWordMemory (ResourceProducer, SubDecode, MinFixed, MaxFixed, NonCacheable, ReadWrite,
                    0x00000000,         // Granularity
                    0x000DE000,         // Range Minimum
                    0x000DFFFF,         // Range Maximum
                    0x00000000,         // Translation Offset
                    0x00002000,         // Length
                    0x00,, , AddressRangeMemory, TypeStatic)
                DWordMemory (ResourceProducer, SubDecode, MinFixed, MaxFixed, NonCacheable, ReadWrite,
                    0x00000000,         // Granularity
                    0x000E0000,         // Range Minimum
                    0x000E1FFF,         // Range Maximum
                    0x00000000,         // Translation Offset
                    0x00002000,         // Length
                    0x00,, , AddressRangeMemory, TypeStatic)
                DWordMemory (ResourceProducer, SubDecode, MinFixed, MaxFixed, NonCacheable, ReadWrite,
                    0x00000000,         // Granularity
                    0x000E2000,         // Range Minimum
                    0x000E3FFF,         // Range Maximum
                    0x00000000,         // Translation Offset
                    0x00002000,         // Length
                    0x00,, , AddressRangeMemory, TypeStatic)
                DWordMemory (ResourceProducer, SubDecode, MinFixed, MaxFixed, NonCacheable, ReadWrite,
                    0x00000000,         // Granularity
                    0x000E4000,         // Range Minimum
                    0x000E5FFF,         // Range Maximum
                    0x00000000,         // Translation Offset
                    0x00002000,         // Length
                    0x00,, , AddressRangeMemory, TypeStatic)
                DWordMemory (ResourceProducer, SubDecode, MinFixed, MaxFixed, NonCacheable, ReadWrite,
                    0x00000000,         // Granularity
                    0x000E6000,         // Range Minimum
                    0x000E7FFF,         // Range Maximum
                    0x00000000,         // Translation Offset
                    0x00002000,         // Length
                    0x00,, , AddressRangeMemory, TypeStatic)
                DWordMemory (ResourceProducer, SubDecode, MinFixed, MaxFixed, NonCacheable, ReadWrite,
                    0x00000000,         // Granularity
                    0x000E8000,         // Range Minimum
                    0x000E9FFF,         // Range Maximum
                    0x00000000,         // Translation Offset
                    0x00002000,         // Length
                    0x00,, , AddressRangeMemory, TypeStatic)
                DWordMemory (ResourceProducer, SubDecode, MinFixed, MaxFixed, NonCacheable, ReadWrite,
                    0x00000000,         // Granularity
                    0x000EA000,         // Range Minimum
                    0x000EBFFF,         // Range Maximum
                    0x00000000,         // Translation Offset
                    0x00002000,         // Length
                    0x00,, , AddressRangeMemory, TypeStatic)
                DWordMemory (ResourceProducer, SubDecode, MinFixed, MaxFixed, NonCacheable, ReadWrite,
                    0x00000000,         // Granularity
                    0x000EC000,         // Range Minimum
                    0x000EDFFF,         // Range Maximum
                    0x00000000,         // Translation Offset
                    0x00002000,         // Length
                    0x00,, , AddressRangeMemory, TypeStatic)
                DWordMemory (ResourceProducer, SubDecode, MinFixed, MaxFixed, NonCacheable, ReadWrite,
                    0x00000000,         // Granularity
                    0x000EE000,         // Range Minimum
                    0x000EFFFF,         // Range Maximum
                    0x00000000,         // Translation Offset
                    0x00002000,         // Length
                    0x00,, , AddressRangeMemory, TypeStatic)
                DWordMemory (ResourceProducer, SubDecode, MinFixed, MaxFixed, NonCacheable, ReadWrite,
                    0x00000000,         // Granularity
                    0x00000000,         // Range Minimum
                    0x00000000,         // Range Maximum
                    0x00000000,         // Translation Offset
                    0x00000000,         // Length
                    0x00,, _Y00, AddressRangeMemory, TypeStatic)
                DWordMemory (ResourceProducer, SubDecode, MinFixed, MaxFixed, NonCacheable, ReadWrite,
                    0x00000000,         // Granularity
                    0xFC000000,         // Range Minimum
                    0xFDFFFFFF,         // Range Maximum
                    0x00000000,         // Translation Offset
                    0x02000000,         // Length
                    0x00,, _Y01, AddressRangeMemory, TypeStatic)
                QWordMemory (ResourceProducer, PosDecode, MinFixed, MaxFixed, NonCacheable, ReadWrite,
                    0x0000000000000000, // Granularity
                    0x0000000000000000, // Range Minimum
                    0x0000000000000000, // Range Maximum
                    0x0000000000000000, // Translation Offset
                    0x0000000000000000, // Length
                    ,, _Y02, AddressRangeMemory, TypeStatic)
                IO (Decode16,
                    0x0CF8,             // Range Minimum
                    0x0CF8,             // Range Maximum
                    0x01,               // Alignment
                    0x08,               // Length
                    )
                WordIO (ResourceProducer, MinFixed, MaxFixed, PosDecode, EntireRange,
                    0x0000,             // Granularity
                    0x0000,             // Range Minimum
                    0x0CF7,             // Range Maximum
                    0x0000,             // Translation Offset
                    0x0CF8,             // Length
                    0x00,, , TypeStatic, DenseTranslation)
                WordIO (ResourceProducer, MinFixed, MaxFixed, PosDecode, EntireRange,
                    0x0000,             // Granularity
                    0x0D00,             // Range Minimum
                    0xFFFF,             // Range Maximum
                    0x0000,             // Translation Offset
                    0xF300,             // Length
                    0x00,, , TypeStatic, DenseTranslation)
            })
            Method (_CRS, 0, Serialized)  // _CRS: Current Resource Settings
            {
                CreateDWordField (RSRC, \_SB.PCI0._Y00._MIN, BT1S)  // _MIN: Minimum Base Address
                CreateDWordField (RSRC, \_SB.PCI0._Y00._MAX, BT1M)  // _MAX: Maximum Base Address
                CreateDWordField (RSRC, \_SB.PCI0._Y00._LEN, BT1L)  // _LEN: Length
                CreateDWordField (RSRC, \_SB.PCI0._Y01._MIN, BT2S)  // _MIN: Minimum Base Address
                CreateDWordField (RSRC, \_SB.PCI0._Y01._MAX, BT2M)  // _MAX: Maximum Base Address
                CreateDWordField (RSRC, \_SB.PCI0._Y01._LEN, BT2L)  // _LEN: Length
                Local0 = PCIB /* \_SB_.PCI0.PCIB */
                BT1S = TOML /* \_SB_.PCI0.TOML */
                BT1M = (Local0 - One)
                BT1L = (Local0 - TOML) /* \_SB_.PCI0.TOML */
                CreateQWordField (RSRC, \_SB.PCI0._Y02._MIN, M1MN)  // _MIN: Minimum Base Address
                CreateQWordField (RSRC, \_SB.PCI0._Y02._MAX, M1MX)  // _MAX: Maximum Base Address
                CreateQWordField (RSRC, \_SB.PCI0._Y02._LEN, M1LN)  // _LEN: Length
                M1MN = T1MN /* \_SB_.PCI0.T1MN */
                M1MX = T1MX /* \_SB_.PCI0.T1MX */
                M1LN = T1LN /* \_SB_.PCI0.T1LN */
                Return (RSRC) /* \_SB_.PCI0.RSRC */
            }

            Device (MEMR)
            {
                Name (_HID, EisaId ("PNP0C02") /* PNP Motherboard Resources */)  // _HID: Hardware ID
                Name (MEM1, ResourceTemplate ()
                {
                    Memory32Fixed (ReadWrite,
                        0x00000000,         // Address Base
                        0x00000000,         // Address Length
                        _Y03)
                    Memory32Fixed (ReadWrite,
                        0x00000000,         // Address Base
                        0x00000000,         // Address Length
                        _Y04)
                    Memory32Fixed (ReadWrite,
                        0x00000000,         // Address Base
                        0x00000000,         // Address Length
                        _Y05)
                })
                Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
                {
                    CreateDWordField (MEM1, \_SB.PCI0.MEMR._Y03._BAS, MB01)  // _BAS: Base Address
                    CreateDWordField (MEM1, \_SB.PCI0.MEMR._Y03._LEN, ML01)  // _LEN: Length
                    CreateDWordField (MEM1, \_SB.PCI0.MEMR._Y04._BAS, MB02)  // _BAS: Base Address
                    CreateDWordField (MEM1, \_SB.PCI0.MEMR._Y04._LEN, ML02)  // _LEN: Length
                    If (GPIC)
                    {
                        MB01 = 0xFEC00000
                        MB02 = 0xFEE00000
                        ML01 = 0x1000
                        If (NAPC)
                        {
                            ML01 += 0x1000
                        }

                        ML02 = 0x1000
                    }

                    CreateDWordField (MEM1, \_SB.PCI0.MEMR._Y05._BAS, MB03)  // _BAS: Base Address
                    CreateDWordField (MEM1, \_SB.PCI0.MEMR._Y05._LEN, ML03)  // _LEN: Length
                    MB03 = PCIB /* \_SB_.PCI0.PCIB */
                    ML03 = PCIS /* \_SB_.PCI0.PCIS */
                    Return (MEM1) /* \_SB_.PCI0.MEMR.MEM1 */
                }
            }

            Mutex (NAPM, 0x00)
            Method (NAPE, 0, NotSerialized)
            {
                Acquire (NAPM, 0xFFFF)
                Local0 = (PCBA + 0xB8)
                OperationRegion (VARM, SystemMemory, Local0, 0x08)
                Field (VARM, DWordAcc, NoLock, Preserve)
                {
                    NAPX,   32, 
                    NAPD,   32
                }

                Local1 = NAPX /* \_SB_.PCI0.NAPE.NAPX */
                NAPX = 0x14300000
                Local0 = NAPD /* \_SB_.PCI0.NAPE.NAPD */
                Local0 &= 0xFFFFFFEF
                NAPD = Local0
                NAPX = Local1
                Release (NAPM)
            }

            Method (PXCR, 3, Serialized)
            {
                M460 ("PLA-ASL-_SB.PCI0.GPPX.PXCR\n", Zero, Zero, Zero, Zero, Zero, Zero)
                Local0 = Zero
                Local1 = M017 (Arg0, Arg1, Arg2, 0x34, Zero, 0x08)
                While ((Local1 != Zero))
                {
                    Local2 = M017 (Arg0, Arg1, Arg2, Local1, Zero, 0x08)
                    If (((Local2 == Zero) || (Local2 == 0xFF)))
                    {
                        Break
                    }

                    If ((Local2 == 0x10))
                    {
                        Local0 = Local1
                        Break
                    }

                    Local1 = M017 (Arg0, Arg1, Arg2, (Local1 + One), Zero, 0x08)
                }

                Return (Local0)
            }

            Method (SPCF, 1, NotSerialized)
            {
                M460 ("PLA-ASL-_SB.PCI0.GPPX.SPCF\n", Zero, Zero, Zero, Zero, Zero, Zero)
                Local0 = M019 (Zero, (Arg0 >> 0x10), (Arg0 & 0xFF), 
                    0x18)
                NBRI = ((Local0 & 0xFF00) >> 0x08)
                NCMD = M019 (NBRI, Zero, Zero, 0x04)
                NBAR = M019 (NBRI, Zero, Zero, 0x10)
                Local1 = PXCR (NBRI, Zero, Zero)
                PXDC = M019 (NBRI, Zero, Zero, (Local1 + 0x08))
                PXLC = M019 (NBRI, Zero, Zero, (Local1 + 0x10))
                PXD2 = M019 (NBRI, Zero, Zero, (Local1 + 0x28))
            }

            Method (RPCF, 0, NotSerialized)
            {
                M460 ("PLA-ASL-_SB.PCI0.GPPX.RPCF\n", Zero, Zero, Zero, Zero, Zero, Zero)
                Local1 = PXCR (NBRI, Zero, Zero)
                M020 (NBRI, Zero, Zero, (Local1 + 0x08), PXDC)
                M020 (NBRI, Zero, Zero, (Local1 + 0x10), (PXLC & 0xFFFFFEFC))
                M020 (NBRI, Zero, Zero, (Local1 + 0x28), PXD2)
                M020 (NBRI, Zero, Zero, 0x10, NBAR)
                M020 (NBRI, Zero, Zero, 0x04, (NCMD | 0x06))
            }

            Method (UPWD, 0, NotSerialized)
            {
                M460 ("PLA-ASL-_SB.PCI0.UPWD\n", Zero, Zero, Zero, Zero, Zero, Zero)
                OperationRegion (PSMI, SystemIO, 0xB0, 0x02)
                Field (PSMI, ByteAcc, NoLock, Preserve)
                {
                    SMIC,   8, 
                    SMID,   8
                }

                SMIC = 0xE3
            }

            Method (_PRT, 0, NotSerialized)  // _PRT: PCI Routing Table
            {
                If (GPIC)
                {
                    Return (Package (0x12)
                    {
                        Package (0x04)
                        {
                            0x0001FFFF, 
                            Zero, 
                            Zero, 
                            0x28
                        }, 

                        Package (0x04)
                        {
                            0x0001FFFF, 
                            One, 
                            Zero, 
                            0x29
                        }, 

                        Package (0x04)
                        {
                            0x0001FFFF, 
                            0x02, 
                            Zero, 
                            0x2A
                        }, 

                        Package (0x04)
                        {
                            0x0001FFFF, 
                            0x03, 
                            Zero, 
                            0x2B
                        }, 

                        Package (0x04)
                        {
                            0x0001FFFF, 
                            0x04, 
                            Zero, 
                            0x28
                        }, 

                        Package (0x04)
                        {
                            0x0002FFFF, 
                            Zero, 
                            Zero, 
                            0x24
                        }, 

                        Package (0x04)
                        {
                            0x0002FFFF, 
                            One, 
                            Zero, 
                            0x25
                        }, 

                        Package (0x04)
                        {
                            0x0002FFFF, 
                            0x02, 
                            Zero, 
                            0x26
                        }, 

                        Package (0x04)
                        {
                            0x0002FFFF, 
                            0x03, 
                            Zero, 
                            0x27
                        }, 

                        Package (0x04)
                        {
                            0x0002FFFF, 
                            0x04, 
                            Zero, 
                            0x24
                        }, 

                        Package (0x04)
                        {
                            0x0002FFFF, 
                            0x05, 
                            Zero, 
                            0x25
                        }, 

                        Package (0x04)
                        {
                            0x0008FFFF, 
                            Zero, 
                            Zero, 
                            0x20
                        }, 

                        Package (0x04)
                        {
                            0x0008FFFF, 
                            One, 
                            Zero, 
                            0x21
                        }, 

                        Package (0x04)
                        {
                            0x0008FFFF, 
                            0x02, 
                            Zero, 
                            0x22
                        }, 

                        Package (0x04)
                        {
                            0x0014FFFF, 
                            Zero, 
                            Zero, 
                            0x10
                        }, 

                        Package (0x04)
                        {
                            0x0014FFFF, 
                            One, 
                            Zero, 
                            0x11
                        }, 

                        Package (0x04)
                        {
                            0x0014FFFF, 
                            0x02, 
                            Zero, 
                            0x12
                        }, 

                        Package (0x04)
                        {
                            0x0014FFFF, 
                            0x03, 
                            Zero, 
                            0x13
                        }
                    })
                }
                Else
                {
                    Return (Package (0x12)
                    {
                        Package (0x04)
                        {
                            0x0001FFFF, 
                            Zero, 
                            ^LPC0.LNKA, 
                            Zero
                        }, 

                        Package (0x04)
                        {
                            0x0001FFFF, 
                            One, 
                            ^LPC0.LNKB, 
                            Zero
                        }, 

                        Package (0x04)
                        {
                            0x0001FFFF, 
                            0x02, 
                            ^LPC0.LNKC, 
                            Zero
                        }, 

                        Package (0x04)
                        {
                            0x0001FFFF, 
                            0x03, 
                            ^LPC0.LNKD, 
                            Zero
                        }, 

                        Package (0x04)
                        {
                            0x0001FFFF, 
                            0x04, 
                            ^LPC0.LNKA, 
                            Zero
                        }, 

                        Package (0x04)
                        {
                            0x0002FFFF, 
                            Zero, 
                            ^LPC0.LNKE, 
                            Zero
                        }, 

                        Package (0x04)
                        {
                            0x0002FFFF, 
                            One, 
                            ^LPC0.LNKF, 
                            Zero
                        }, 

                        Package (0x04)
                        {
                            0x0002FFFF, 
                            0x02, 
                            ^LPC0.LNKG, 
                            Zero
                        }, 

                        Package (0x04)
                        {
                            0x0002FFFF, 
                            0x03, 
                            ^LPC0.LNKH, 
                            Zero
                        }, 

                        Package (0x04)
                        {
                            0x0002FFFF, 
                            0x04, 
                            ^LPC0.LNKE, 
                            Zero
                        }, 

                        Package (0x04)
                        {
                            0x0002FFFF, 
                            0x05, 
                            ^LPC0.LNKF, 
                            Zero
                        }, 

                        Package (0x04)
                        {
                            0x0008FFFF, 
                            Zero, 
                            ^LPC0.LNKA, 
                            Zero
                        }, 

                        Package (0x04)
                        {
                            0x0008FFFF, 
                            One, 
                            ^LPC0.LNKB, 
                            Zero
                        }, 

                        Package (0x04)
                        {
                            0x0008FFFF, 
                            0x02, 
                            ^LPC0.LNKC, 
                            Zero
                        }, 

                        Package (0x04)
                        {
                            0x0014FFFF, 
                            Zero, 
                            ^LPC0.LNKA, 
                            Zero
                        }, 

                        Package (0x04)
                        {
                            0x0014FFFF, 
                            One, 
                            ^LPC0.LNKB, 
                            Zero
                        }, 

                        Package (0x04)
                        {
                            0x0014FFFF, 
                            0x02, 
                            ^LPC0.LNKC, 
                            Zero
                        }, 

                        Package (0x04)
                        {
                            0x0014FFFF, 
                            0x03, 
                            ^LPC0.LNKD, 
                            Zero
                        }
                    })
                }
            }

            OperationRegion (BAR1, PCI_Config, 0x14, 0x04)
            Field (BAR1, ByteAcc, NoLock, Preserve)
            {
                NBBA,   32
            }

            OperationRegion (PM80, SystemIO, 0x0CD6, 0x02)
            Field (PM80, AnyAcc, NoLock, Preserve)
            {
                PM0I,   8, 
                PM0D,   8
            }

            IndexField (PM0I, PM0D, ByteAcc, NoLock, Preserve)
            {
                Offset (0x80), 
                SI3R,   1
            }

            Device (GPP0)
            {
                Name (_ADR, 0x00010001)  // _ADR: Address
                Method (_PRW, 0, NotSerialized)  // _PRW: Power Resources for Wake
                {
                    If ((WKPM == One))
                    {
                        Return (GPRW (0x08, 0x04))
                    }
                    Else
                    {
                        Return (GPRW (0x08, Zero))
                    }
                }

                Method (_PRT, 0, NotSerialized)  // _PRT: PCI Routing Table
                {
                    If (GPIC)
                    {
                        Return (Package (0x04)
                        {
                            Package (0x04)
                            {
                                0xFFFF, 
                                Zero, 
                                Zero, 
                                0x18
                            }, 

                            Package (0x04)
                            {
                                0xFFFF, 
                                One, 
                                Zero, 
                                0x19
                            }, 

                            Package (0x04)
                            {
                                0xFFFF, 
                                0x02, 
                                Zero, 
                                0x1A
                            }, 

                            Package (0x04)
                            {
                                0xFFFF, 
                                0x03, 
                                Zero, 
                                0x1B
                            }
                        })
                    }
                    Else
                    {
                        Return (Package (0x04)
                        {
                            Package (0x04)
                            {
                                0xFFFF, 
                                Zero, 
                                ^^LPC0.LNKA, 
                                Zero
                            }, 

                            Package (0x04)
                            {
                                0xFFFF, 
                                One, 
                                ^^LPC0.LNKB, 
                                Zero
                            }, 

                            Package (0x04)
                            {
                                0xFFFF, 
                                0x02, 
                                ^^LPC0.LNKC, 
                                Zero
                            }, 

                            Package (0x04)
                            {
                                0xFFFF, 
                                0x03, 
                                ^^LPC0.LNKD, 
                                Zero
                            }
                        })
                    }
                }
            }

            Device (GPP1)
            {
                Name (_ADR, 0x00010002)  // _ADR: Address
                Method (RHRW, 0, NotSerialized)
                {
                    If ((WKPM == One))
                    {
                        Return (GPRW (0x08, 0x04))
                    }
                    Else
                    {
                        Return (GPRW (0x08, Zero))
                    }
                }

                Method (_PRT, 0, NotSerialized)  // _PRT: PCI Routing Table
                {
                    If (GPIC)
                    {
                        Return (Package (0x04)
                        {
                            Package (0x04)
                            {
                                0xFFFF, 
                                Zero, 
                                Zero, 
                                0x1C
                            }, 

                            Package (0x04)
                            {
                                0xFFFF, 
                                One, 
                                Zero, 
                                0x1D
                            }, 

                            Package (0x04)
                            {
                                0xFFFF, 
                                0x02, 
                                Zero, 
                                0x1E
                            }, 

                            Package (0x04)
                            {
                                0xFFFF, 
                                0x03, 
                                Zero, 
                                0x1F
                            }
                        })
                    }
                    Else
                    {
                        Return (Package (0x04)
                        {
                            Package (0x04)
                            {
                                0xFFFF, 
                                Zero, 
                                ^^LPC0.LNKE, 
                                Zero
                            }, 

                            Package (0x04)
                            {
                                0xFFFF, 
                                One, 
                                ^^LPC0.LNKF, 
                                Zero
                            }, 

                            Package (0x04)
                            {
                                0xFFFF, 
                                0x02, 
                                ^^LPC0.LNKG, 
                                Zero
                            }, 

                            Package (0x04)
                            {
                                0xFFFF, 
                                0x03, 
                                ^^LPC0.LNKH, 
                                Zero
                            }
                        })
                    }
                }

                Device (WLAN)
                {
                    Name (_ADR, Zero)  // _ADR: Address
                    Name (_S0W, 0x04)  // _S0W: S0 Device Wake State
                }
            }

            Device (GPP2)
            {
                Name (_ADR, 0x00010003)  // _ADR: Address
                Method (RHRW, 0, NotSerialized)
                {
                    If ((WKPM == One))
                    {
                        Return (GPRW (0x08, 0x04))
                    }
                    Else
                    {
                        Return (GPRW (0x08, Zero))
                    }
                }

                Method (_PRT, 0, NotSerialized)  // _PRT: PCI Routing Table
                {
                    If (GPIC)
                    {
                        Return (Package (0x04)
                        {
                            Package (0x04)
                            {
                                0xFFFF, 
                                Zero, 
                                Zero, 
                                0x20
                            }, 

                            Package (0x04)
                            {
                                0xFFFF, 
                                One, 
                                Zero, 
                                0x21
                            }, 

                            Package (0x04)
                            {
                                0xFFFF, 
                                0x02, 
                                Zero, 
                                0x22
                            }, 

                            Package (0x04)
                            {
                                0xFFFF, 
                                0x03, 
                                Zero, 
                                0x23
                            }
                        })
                    }
                    Else
                    {
                        Return (Package (0x04)
                        {
                            Package (0x04)
                            {
                                0xFFFF, 
                                Zero, 
                                ^^LPC0.LNKA, 
                                Zero
                            }, 

                            Package (0x04)
                            {
                                0xFFFF, 
                                One, 
                                ^^LPC0.LNKB, 
                                Zero
                            }, 

                            Package (0x04)
                            {
                                0xFFFF, 
                                0x02, 
                                ^^LPC0.LNKC, 
                                Zero
                            }, 

                            Package (0x04)
                            {
                                0xFFFF, 
                                0x03, 
                                ^^LPC0.LNKD, 
                                Zero
                            }
                        })
                    }
                }

                Device (WWAN)
                {
                    Name (_ADR, Zero)  // _ADR: Address
                }
            }

            Device (GPP3)
            {
                Name (_ADR, 0x00010004)  // _ADR: Address
                Method (_PRT, 0, NotSerialized)  // _PRT: PCI Routing Table
                {
                    If (GPIC)
                    {
                        Return (Package (0x04)
                        {
                            Package (0x04)
                            {
                                0xFFFF, 
                                Zero, 
                                Zero, 
                                0x24
                            }, 

                            Package (0x04)
                            {
                                0xFFFF, 
                                One, 
                                Zero, 
                                0x25
                            }, 

                            Package (0x04)
                            {
                                0xFFFF, 
                                0x02, 
                                Zero, 
                                0x26
                            }, 

                            Package (0x04)
                            {
                                0xFFFF, 
                                0x03, 
                                Zero, 
                                0x27
                            }
                        })
                    }
                    Else
                    {
                        Return (Package (0x04)
                        {
                            Package (0x04)
                            {
                                0xFFFF, 
                                Zero, 
                                ^^LPC0.LNKE, 
                                Zero
                            }, 

                            Package (0x04)
                            {
                                0xFFFF, 
                                One, 
                                ^^LPC0.LNKF, 
                                Zero
                            }, 

                            Package (0x04)
                            {
                                0xFFFF, 
                                0x02, 
                                ^^LPC0.LNKG, 
                                Zero
                            }, 

                            Package (0x04)
                            {
                                0xFFFF, 
                                0x03, 
                                ^^LPC0.LNKH, 
                                Zero
                            }
                        })
                    }
                }
            }

            Device (GPP4)
            {
                Name (_ADR, 0x00010005)  // _ADR: Address
                Method (_PRT, 0, NotSerialized)  // _PRT: PCI Routing Table
                {
                    If (GPIC)
                    {
                        Return (Package (0x04)
                        {
                            Package (0x04)
                            {
                                0xFFFF, 
                                Zero, 
                                Zero, 
                                0x28
                            }, 

                            Package (0x04)
                            {
                                0xFFFF, 
                                One, 
                                Zero, 
                                0x29
                            }, 

                            Package (0x04)
                            {
                                0xFFFF, 
                                0x02, 
                                Zero, 
                                0x2A
                            }, 

                            Package (0x04)
                            {
                                0xFFFF, 
                                0x03, 
                                Zero, 
                                0x2B
                            }
                        })
                    }
                    Else
                    {
                        Return (Package (0x04)
                        {
                            Package (0x04)
                            {
                                0xFFFF, 
                                Zero, 
                                ^^LPC0.LNKA, 
                                Zero
                            }, 

                            Package (0x04)
                            {
                                0xFFFF, 
                                One, 
                                ^^LPC0.LNKB, 
                                Zero
                            }, 

                            Package (0x04)
                            {
                                0xFFFF, 
                                0x02, 
                                ^^LPC0.LNKC, 
                                Zero
                            }, 

                            Package (0x04)
                            {
                                0xFFFF, 
                                0x03, 
                                ^^LPC0.LNKD, 
                                Zero
                            }
                        })
                    }
                }
            }

            Device (GPP5)
            {
                Name (_ADR, 0x00020001)  // _ADR: Address
                Method (RHRW, 0, NotSerialized)
                {
                    If ((WKPM == One))
                    {
                        Return (GPRW (0x0F, 0x04))
                    }
                    Else
                    {
                        Return (GPRW (0x0F, Zero))
                    }
                }

                Method (_PRT, 0, NotSerialized)  // _PRT: PCI Routing Table
                {
                    If (GPIC)
                    {
                        Return (Package (0x04)
                        {
                            Package (0x04)
                            {
                                0xFFFF, 
                                Zero, 
                                Zero, 
                                0x2C
                            }, 

                            Package (0x04)
                            {
                                0xFFFF, 
                                One, 
                                Zero, 
                                0x2D
                            }, 

                            Package (0x04)
                            {
                                0xFFFF, 
                                0x02, 
                                Zero, 
                                0x2E
                            }, 

                            Package (0x04)
                            {
                                0xFFFF, 
                                0x03, 
                                Zero, 
                                0x2F
                            }
                        })
                    }
                    Else
                    {
                        Return (Package (0x04)
                        {
                            Package (0x04)
                            {
                                0xFFFF, 
                                Zero, 
                                ^^LPC0.LNKE, 
                                Zero
                            }, 

                            Package (0x04)
                            {
                                0xFFFF, 
                                One, 
                                ^^LPC0.LNKF, 
                                Zero
                            }, 

                            Package (0x04)
                            {
                                0xFFFF, 
                                0x02, 
                                ^^LPC0.LNKG, 
                                Zero
                            }, 

                            Package (0x04)
                            {
                                0xFFFF, 
                                0x03, 
                                ^^LPC0.LNKH, 
                                Zero
                            }
                        })
                    }
                }

                Device (RTL8)
                {
                    Name (_ADR, Zero)  // _ADR: Address
                }

                Device (RUSB)
                {
                    Name (_ADR, 0x04)  // _ADR: Address
                }
            }

            Device (GPP6)
            {
                Name (_ADR, 0x00020002)  // _ADR: Address
                Method (RHRW, 0, NotSerialized)
                {
                    If ((WKPM == One))
                    {
                        Return (GPRW (0x0E, 0x03))
                    }
                    Else
                    {
                        Return (GPRW (0x0E, Zero))
                    }
                }

                Method (_PRT, 0, NotSerialized)  // _PRT: PCI Routing Table
                {
                    If (GPIC)
                    {
                        Return (Package (0x04)
                        {
                            Package (0x04)
                            {
                                0xFFFF, 
                                Zero, 
                                Zero, 
                                0x30
                            }, 

                            Package (0x04)
                            {
                                0xFFFF, 
                                One, 
                                Zero, 
                                0x31
                            }, 

                            Package (0x04)
                            {
                                0xFFFF, 
                                0x02, 
                                Zero, 
                                0x32
                            }, 

                            Package (0x04)
                            {
                                0xFFFF, 
                                0x03, 
                                Zero, 
                                0x33
                            }
                        })
                    }
                    Else
                    {
                        Return (Package (0x04)
                        {
                            Package (0x04)
                            {
                                0xFFFF, 
                                Zero, 
                                ^^LPC0.LNKA, 
                                Zero
                            }, 

                            Package (0x04)
                            {
                                0xFFFF, 
                                One, 
                                ^^LPC0.LNKB, 
                                Zero
                            }, 

                            Package (0x04)
                            {
                                0xFFFF, 
                                0x02, 
                                ^^LPC0.LNKC, 
                                Zero
                            }, 

                            Package (0x04)
                            {
                                0xFFFF, 
                                0x03, 
                                ^^LPC0.LNKD, 
                                Zero
                            }
                        })
                    }
                }

                Device (BTH0)
                {
                    Name (_HID, "QCOM6390")  // _HID: Hardware ID
                    Name (_S4W, 0x02)  // _S4W: S4 Device Wake State
                    Name (_S0W, 0x02)  // _S0W: S0 Device Wake State
                    Method (_STA, 0, NotSerialized)  // _STA: Status
                    {
                        If ((BT00 == Zero))
                        {
                            Return (Zero)
                        }
                        Else
                        {
                            Return (0x0F)
                        }
                    }

                    Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
                    {
                        Name (UBUF, ResourceTemplate ()
                        {
                            UartSerialBusV2 (0x0001C200, DataBitsEight, StopBitsOne,
                                0xC0, LittleEndian, ParityTypeNone, FlowControlHardware,
                                0x0020, 0x0020, "\\_SB.FUR0",
                                0x00, ResourceConsumer, , Exclusive,
                                )
                            GpioInt (Edge, ActiveLow, ExclusiveAndWake, PullUp, 0x0000,
                                "\\_SB.GPIO", 0x00, ResourceConsumer, ,
                                )
                                {   // Pin list
                                    0x0004
                                }
                        })
                        Return (UBUF) /* \_SB_.PCI0.GPP6.BTH0._CRS.UBUF */
                    }
                }
            }

            Device (GPP7)
            {
                Alias (L850, DEV0)
                Name (_ADR, 0x00020003)  // _ADR: Address
                Method (RHRW, 0, NotSerialized)
                {
                    If ((WKPM == One))
                    {
                        Return (GPRW (0x02, 0x04))
                    }
                    Else
                    {
                        Return (GPRW (0x02, Zero))
                    }
                }

                OperationRegion (PCG1, PCI_Config, 0x58, 0x20)
                Field (PCG1, DWordAcc, NoLock, Preserve)
                {
                    Offset (0x10), 
                    LNKC,   2
                }

                Method (_PS0, 0, NotSerialized)  // _PS0: Power State 0
                {
                    LNKC = 0x02
                }

                Method (_PS3, 0, NotSerialized)  // _PS3: Power State 3
                {
                    LNKC = 0x02
                }

                Device (L850)
                {
                    Name (_ADR, Zero)  // _ADR: Address
                    Method (RHRW, 0, NotSerialized)
                    {
                        If ((WKPM == One))
                        {
                            Return (GPRW (0x08, 0x03))
                        }
                        Else
                        {
                            Return (GPRW (0x08, Zero))
                        }
                    }

                    OperationRegion (PCG2, PCI_Config, Zero, 0x90)
                    Field (PCG2, DWordAcc, NoLock, Preserve)
                    {
                        VID0,   16, 
                        DID0,   16, 
                        Offset (0x80), 
                        APML,   2
                    }

                    Method (_RST, 0, NotSerialized)  // _RST: Device Reset
                    {
                        LNKC = 0x02
                        WFIO (0x03, Zero)
                        Sleep (0x32)
                        Notify (L850, One) // Device Check
                        LNKC = 0x02
                        WFIO (0x03, One)
                        Sleep (0x3E)
                        Notify (_SB, Zero) // Bus Check
                        Sleep (0x64)
                        Notify (PCI0, Zero) // Bus Check
                        Sleep (0x64)
                        Notify (L850, One) // Device Check
                        LNKC = 0x02
                        APML = 0x02
                        Return (Zero)
                    }

                    Method (_DSM, 4, Serialized)  // _DSM: Device-Specific Method
                    {
                        If ((Arg0 == ToUUID ("bad01b75-22a8-4f48-8792-bdde9467747d") /* Unknown UUID */))
                        {
                            If ((Arg2 == Zero))
                            {
                                Return (Buffer (One)
                                {
                                     0x09                                             // .
                                })
                            }

                            If ((Arg2 == One)){}
                            If ((Arg2 == 0x02)){}
                            If ((Arg2 == 0x03))
                            {
                                Return (0x03)
                            }
                        }

                        Return (Buffer (One)
                        {
                             0x00                                             // .
                        })
                    }

                    Method (LFCT, 0, NotSerialized)
                    {
                        If ((DID0 == 0x7360))
                        {
                            APML = 0x02
                            Return (Zero)
                        }
                    }
                }

                Method (_PRT, 0, NotSerialized)  // _PRT: PCI Routing Table
                {
                    If (GPIC)
                    {
                        Return (Package (0x04)
                        {
                            Package (0x04)
                            {
                                0xFFFF, 
                                Zero, 
                                Zero, 
                                0x32
                            }, 

                            Package (0x04)
                            {
                                0xFFFF, 
                                One, 
                                Zero, 
                                0x33
                            }, 

                            Package (0x04)
                            {
                                0xFFFF, 
                                0x02, 
                                Zero, 
                                0x30
                            }, 

                            Package (0x04)
                            {
                                0xFFFF, 
                                0x03, 
                                Zero, 
                                0x31
                            }
                        })
                    }
                    Else
                    {
                        Return (Package (0x04)
                        {
                            Package (0x04)
                            {
                                0xFFFF, 
                                Zero, 
                                ^^LPC0.LNKC, 
                                Zero
                            }, 

                            Package (0x04)
                            {
                                0xFFFF, 
                                One, 
                                ^^LPC0.LNKD, 
                                Zero
                            }, 

                            Package (0x04)
                            {
                                0xFFFF, 
                                0x02, 
                                ^^LPC0.LNKA, 
                                Zero
                            }, 

                            Package (0x04)
                            {
                                0xFFFF, 
                                0x03, 
                                ^^LPC0.LNKB, 
                                Zero
                            }
                        })
                    }
                }
            }

            Device (GPP8)
            {
                Name (_ADR, 0x00020004)  // _ADR: Address
                Method (_PRT, 0, NotSerialized)  // _PRT: PCI Routing Table
                {
                    If (GPIC)
                    {
                        Return (Package (0x04)
                        {
                            Package (0x04)
                            {
                                0xFFFF, 
                                Zero, 
                                Zero, 
                                0x2E
                            }, 

                            Package (0x04)
                            {
                                0xFFFF, 
                                One, 
                                Zero, 
                                0x2F
                            }, 

                            Package (0x04)
                            {
                                0xFFFF, 
                                0x02, 
                                Zero, 
                                0x2C
                            }, 

                            Package (0x04)
                            {
                                0xFFFF, 
                                0x03, 
                                Zero, 
                                0x2D
                            }
                        })
                    }
                    Else
                    {
                        Return (Package (0x04)
                        {
                            Package (0x04)
                            {
                                0xFFFF, 
                                Zero, 
                                ^^LPC0.LNKG, 
                                Zero
                            }, 

                            Package (0x04)
                            {
                                0xFFFF, 
                                One, 
                                ^^LPC0.LNKH, 
                                Zero
                            }, 

                            Package (0x04)
                            {
                                0xFFFF, 
                                0x02, 
                                ^^LPC0.LNKE, 
                                Zero
                            }, 

                            Package (0x04)
                            {
                                0xFFFF, 
                                0x03, 
                                ^^LPC0.LNKF, 
                                Zero
                            }
                        })
                    }
                }
            }

            Device (GPP9)
            {
                Name (_ADR, 0x00020005)  // _ADR: Address
                Method (_PRT, 0, NotSerialized)  // _PRT: PCI Routing Table
                {
                    If (GPIC)
                    {
                        Return (Package (0x04)
                        {
                            Package (0x04)
                            {
                                0xFFFF, 
                                Zero, 
                                Zero, 
                                0x2A
                            }, 

                            Package (0x04)
                            {
                                0xFFFF, 
                                One, 
                                Zero, 
                                0x2B
                            }, 

                            Package (0x04)
                            {
                                0xFFFF, 
                                0x02, 
                                Zero, 
                                0x28
                            }, 

                            Package (0x04)
                            {
                                0xFFFF, 
                                0x03, 
                                Zero, 
                                0x29
                            }
                        })
                    }
                    Else
                    {
                        Return (Package (0x04)
                        {
                            Package (0x04)
                            {
                                0xFFFF, 
                                Zero, 
                                ^^LPC0.LNKC, 
                                Zero
                            }, 

                            Package (0x04)
                            {
                                0xFFFF, 
                                One, 
                                ^^LPC0.LNKD, 
                                Zero
                            }, 

                            Package (0x04)
                            {
                                0xFFFF, 
                                0x02, 
                                ^^LPC0.LNKA, 
                                Zero
                            }, 

                            Package (0x04)
                            {
                                0xFFFF, 
                                0x03, 
                                ^^LPC0.LNKB, 
                                Zero
                            }
                        })
                    }
                }
            }

            Device (GP10)
            {
                Name (_ADR, 0x00020006)  // _ADR: Address
                Method (_PRT, 0, NotSerialized)  // _PRT: PCI Routing Table
                {
                    If (GPIC)
                    {
                        Return (Package (0x04)
                        {
                            Package (0x04)
                            {
                                0xFFFF, 
                                Zero, 
                                Zero, 
                                0x26
                            }, 

                            Package (0x04)
                            {
                                0xFFFF, 
                                One, 
                                Zero, 
                                0x27
                            }, 

                            Package (0x04)
                            {
                                0xFFFF, 
                                0x02, 
                                Zero, 
                                0x24
                            }, 

                            Package (0x04)
                            {
                                0xFFFF, 
                                0x03, 
                                Zero, 
                                0x25
                            }
                        })
                    }
                    Else
                    {
                        Return (Package (0x04)
                        {
                            Package (0x04)
                            {
                                0xFFFF, 
                                Zero, 
                                ^^LPC0.LNKG, 
                                Zero
                            }, 

                            Package (0x04)
                            {
                                0xFFFF, 
                                One, 
                                ^^LPC0.LNKH, 
                                Zero
                            }, 

                            Package (0x04)
                            {
                                0xFFFF, 
                                0x02, 
                                ^^LPC0.LNKE, 
                                Zero
                            }, 

                            Package (0x04)
                            {
                                0xFFFF, 
                                0x03, 
                                ^^LPC0.LNKF, 
                                Zero
                            }
                        })
                    }
                }
            }

            Device (GP17)
            {
                Name (_ADR, 0x00080001)  // _ADR: Address
                Method (_PRW, 0, NotSerialized)  // _PRW: Power Resources for Wake
                {
                    If ((WKPM == One))
                    {
                        Return (GPRW (0x19, 0x03))
                    }
                    Else
                    {
                        Return (GPRW (0x19, Zero))
                    }
                }

                Method (_PRT, 0, NotSerialized)  // _PRT: PCI Routing Table
                {
                    If (GPIC)
                    {
                        Return (Package (0x04)
                        {
                            Package (0x04)
                            {
                                0xFFFF, 
                                Zero, 
                                Zero, 
                                0x22
                            }, 

                            Package (0x04)
                            {
                                0xFFFF, 
                                One, 
                                Zero, 
                                0x23
                            }, 

                            Package (0x04)
                            {
                                0xFFFF, 
                                0x02, 
                                Zero, 
                                0x20
                            }, 

                            Package (0x04)
                            {
                                0xFFFF, 
                                0x03, 
                                Zero, 
                                0x21
                            }
                        })
                    }
                    Else
                    {
                        Return (Package (0x04)
                        {
                            Package (0x04)
                            {
                                0xFFFF, 
                                Zero, 
                                ^^LPC0.LNKC, 
                                Zero
                            }, 

                            Package (0x04)
                            {
                                0xFFFF, 
                                One, 
                                ^^LPC0.LNKD, 
                                Zero
                            }, 

                            Package (0x04)
                            {
                                0xFFFF, 
                                0x02, 
                                ^^LPC0.LNKA, 
                                Zero
                            }, 

                            Package (0x04)
                            {
                                0xFFFF, 
                                0x03, 
                                ^^LPC0.LNKB, 
                                Zero
                            }
                        })
                    }
                }

                Device (VGA)
                {
                    Name (_ADR, Zero)  // _ADR: Address
                    Method (_STA, 0, NotSerialized)  // _STA: Status
                    {
                        Return (0x0F)
                    }

                    Name (AF7E, 0x80000001)
                    Name (DOSA, Zero)
                    Method (_DOS, 1, NotSerialized)  // _DOS: Disable Output Switching
                    {
                        DOSA = Arg0
                    }

                    Method (_DOD, 0, NotSerialized)  // _DOD: Display Output Devices
                    {
                        Return (Package (0x07)
                        {
                            0x00010110, 
                            0x00010210, 
                            0x00010220, 
                            0x00010230, 
                            0x00010240, 
                            0x00031000, 
                            0x00032000
                        })
                    }

                    Device (LCD)
                    {
                        Method (_ADR, 0, NotSerialized)  // _ADR: Address
                        {
                            Return (0x0110)
                        }

                        Name (BRLV, Buffer (0x11)
                        {
                            /* 0000 */  0x52, 0x22, 0x02, 0x08, 0x0E, 0x16, 0x1C, 0x22,  // R"....."
                            /* 0008 */  0x2A, 0x30, 0x36, 0x3E, 0x44, 0x4B, 0x52, 0x58,  // *06>DKRX
                            /* 0010 */  0x64                                             // d
                        })
                        Method (_BCL, 0, NotSerialized)  // _BCL: Brightness Control Levels
                        {
                            If ((AF7E == 0x80000001))
                            {
                                Return (Package (0x67)
                                {
                                    0x64, 
                                    0x64, 
                                    Zero, 
                                    One, 
                                    0x02, 
                                    0x03, 
                                    0x04, 
                                    0x05, 
                                    0x06, 
                                    0x07, 
                                    0x08, 
                                    0x09, 
                                    0x0A, 
                                    0x0B, 
                                    0x0C, 
                                    0x0D, 
                                    0x0E, 
                                    0x0F, 
                                    0x10, 
                                    0x11, 
                                    0x12, 
                                    0x13, 
                                    0x14, 
                                    0x15, 
                                    0x16, 
                                    0x17, 
                                    0x18, 
                                    0x19, 
                                    0x1A, 
                                    0x1B, 
                                    0x1C, 
                                    0x1D, 
                                    0x1E, 
                                    0x1F, 
                                    0x20, 
                                    0x21, 
                                    0x22, 
                                    0x23, 
                                    0x24, 
                                    0x25, 
                                    0x26, 
                                    0x27, 
                                    0x28, 
                                    0x29, 
                                    0x2A, 
                                    0x2B, 
                                    0x2C, 
                                    0x2D, 
                                    0x2E, 
                                    0x2F, 
                                    0x30, 
                                    0x31, 
                                    0x32, 
                                    0x33, 
                                    0x34, 
                                    0x35, 
                                    0x36, 
                                    0x37, 
                                    0x38, 
                                    0x39, 
                                    0x3A, 
                                    0x3B, 
                                    0x3C, 
                                    0x3D, 
                                    0x3E, 
                                    0x3F, 
                                    0x40, 
                                    0x41, 
                                    0x42, 
                                    0x43, 
                                    0x44, 
                                    0x45, 
                                    0x46, 
                                    0x47, 
                                    0x48, 
                                    0x49, 
                                    0x4A, 
                                    0x4B, 
                                    0x4C, 
                                    0x4D, 
                                    0x4E, 
                                    0x4F, 
                                    0x50, 
                                    0x51, 
                                    0x52, 
                                    0x53, 
                                    0x54, 
                                    0x55, 
                                    0x56, 
                                    0x57, 
                                    0x58, 
                                    0x59, 
                                    0x5A, 
                                    0x5B, 
                                    0x5C, 
                                    0x5D, 
                                    0x5E, 
                                    0x5F, 
                                    0x60, 
                                    0x61, 
                                    0x62, 
                                    0x63, 
                                    0x64
                                })
                            }
                        }

                        Method (_BCM, 1, NotSerialized)  // _BCM: Brightness Control Method
                        {
                            If ((AF7E == 0x80000001))
                            {
                                If (((Arg0 >= Zero) && (Arg0 <= 0x64)))
                                {
                                    Local0 = ((Arg0 * 0xFF) / 0x64)
                                    AFN7 (Local0)
                                }
                            }
                        }

                        Method (_BQC, 0, NotSerialized)  // _BQC: Brightness Query Current
                        {
                            Return (BRTL) /* \BRTL */
                        }

                        Method (_DDC, 1, NotSerialized)  // _DDC: Display Data Current
                        {
                            If ((Arg0 == One))
                            {
                                Return (VEDI) /* \VEDI */
                            }
                            ElseIf ((Arg0 == 0x02))
                            {
                                Name (VBUF, Buffer (0x0100)
                                {
                                     0x00                                             // .
                                })
                                Concatenate (VEDI, VEDX, VBUF) /* \_SB_.PCI0.GP17.VGA_.LCD_._DDC.VBUF */
                                Return (VBUF) /* \_SB_.PCI0.GP17.VGA_.LCD_._DDC.VBUF */
                            }

                            Return (Zero)
                        }
                    }
                }

                Device (PSP)
                {
                    Name (_ADR, 0x02)  // _ADR: Address
                }

                Device (ACP)
                {
                    Name (_ADR, 0x05)  // _ADR: Address
                    Method (_WOV, 0, NotSerialized)
                    {
                        Return (WOVS) /* \WOVS */
                    }
                }

                Device (AZAL)
                {
                    Name (_ADR, 0x06)  // _ADR: Address
                }

                Device (HDAU)
                {
                    Name (_ADR, One)  // _ADR: Address
                }

                Device (XHC0)
                {
                    Name (_ADR, 0x03)  // _ADR: Address
                    OperationRegion (PMOP, PCI_Config, 0x50, 0x08)
                    Field (PMOP, DWordAcc, NoLock, Preserve)
                    {
                        Offset (0x01), 
                        Offset (0x02), 
                            ,   3, 
                            ,   1, 
                            ,   1, 
                            ,   1, 
                            ,   3, 
                            ,   1, 
                            ,   1, 
                        Offset (0x04), 
                        PSTA,   2, 
                            ,   1, 
                            ,   1, 
                            ,   3, 
                        Offset (0x05), 
                            ,   4, 
                            ,   2, 
                        PMES,   1, 
                            ,   2
                    }

                    Method (RHRW, 0, NotSerialized)
                    {
                        Return (GPRW (0x19, 0x03))
                    }

                    Device (RHUB)
                    {
                        Name (_ADR, Zero)  // _ADR: Address
                        Name (UPCN, Package (0x04)
                        {
                            Zero, 
                            Zero, 
                            Zero, 
                            Zero
                        })
                        Name (UPC4, Package (0x04)
                        {
                            0xFF, 
                            0x09, 
                            Zero, 
                            Zero
                        })
                        Name (UPC3, Package (0x04)
                        {
                            0xFF, 
                            0x03, 
                            Zero, 
                            Zero
                        })
                        Name (UPCP, Package (0x04)
                        {
                            0xFF, 
                            0xFF, 
                            Zero, 
                            Zero
                        })
                        Name (UPC5, Package (0x04)
                        {
                            0xFF, 
                            Zero, 
                            Zero, 
                            Zero
                        })
                        Name (PLDN, Package (0x01)
                        {
                            Buffer (0x10)
                            {
                                /* 0000 */  0x82, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                                /* 0008 */  0x99, 0x11, 0x00, 0x00, 0x03, 0x00, 0x00, 0x00   // ........
                            }
                        })
                        Name (PLD1, Package (0x01)
                        {
                            Buffer (0x10)
                            {
                                /* 0000 */  0x82, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                                /* 0008 */  0x69, 0x0C, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00   // i.......
                            }
                        })
                        Name (PLD2, Package (0x01)
                        {
                            Buffer (0x10)
                            {
                                /* 0000 */  0x82, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                                /* 0008 */  0x61, 0x1C, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00   // a.......
                            }
                        })
                        Name (PLD3, Package (0x01)
                        {
                            Buffer (0x10)
                            {
                                /* 0000 */  0x82, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                                /* 0008 */  0x61, 0x1C, 0x80, 0x01, 0x00, 0x00, 0x00, 0x00   // a.......
                            }
                        })
                        Name (PLD4, Package (0x01)
                        {
                            Buffer (0x10)
                            {
                                /* 0000 */  0x82, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                                /* 0008 */  0x65, 0x1D, 0x00, 0x02, 0x00, 0x00, 0x00, 0x00   // e.......
                            }
                        })
                        Device (HS01)
                        {
                            Name (_ADR, One)  // _ADR: Address
                            Method (_UPC, 0, NotSerialized)  // _UPC: USB Port Capabilities
                            {
                                Return (UPC5) /* \_SB_.PCI0.GP17.XHC0.RHUB.UPC5 */
                            }

                            Method (_PLD, 0, NotSerialized)  // _PLD: Physical Location of Device
                            {
                                Return (PLD1) /* \_SB_.PCI0.GP17.XHC0.RHUB.PLD1 */
                            }
                        }

                        Device (HS02)
                        {
                            Name (_ADR, 0x02)  // _ADR: Address
                            Method (_UPC, 0, NotSerialized)  // _UPC: USB Port Capabilities
                            {
                                Return (UPC5) /* \_SB_.PCI0.GP17.XHC0.RHUB.UPC5 */
                            }

                            Method (_PLD, 0, NotSerialized)  // _PLD: Physical Location of Device
                            {
                                Return (PLD2) /* \_SB_.PCI0.GP17.XHC0.RHUB.PLD2 */
                            }
                        }

                        Device (HS03)
                        {
                            Name (_ADR, 0x03)  // _ADR: Address
                            Method (_UPC, 0, NotSerialized)  // _UPC: USB Port Capabilities
                            {
                                Return (UPCN) /* \_SB_.PCI0.GP17.XHC0.RHUB.UPCN */
                            }

                            Method (_PLD, 0, NotSerialized)  // _PLD: Physical Location of Device
                            {
                                Return (PLDN) /* \_SB_.PCI0.GP17.XHC0.RHUB.PLDN */
                            }
                        }

                        Device (HS04)
                        {
                            Name (_ADR, 0x04)  // _ADR: Address
                            Method (_UPC, 0, NotSerialized)  // _UPC: USB Port Capabilities
                            {
                                Return (UPCN) /* \_SB_.PCI0.GP17.XHC0.RHUB.UPCN */
                            }

                            Method (_PLD, 0, NotSerialized)  // _PLD: Physical Location of Device
                            {
                                Return (PLDN) /* \_SB_.PCI0.GP17.XHC0.RHUB.PLDN */
                            }
                        }

                        Device (SS01)
                        {
                            Name (_ADR, 0x05)  // _ADR: Address
                            Method (_UPC, 0, NotSerialized)  // _UPC: USB Port Capabilities
                            {
                                Return (UPC4) /* \_SB_.PCI0.GP17.XHC0.RHUB.UPC4 */
                            }

                            Method (_PLD, 0, NotSerialized)  // _PLD: Physical Location of Device
                            {
                                Return (PLD1) /* \_SB_.PCI0.GP17.XHC0.RHUB.PLD1 */
                            }
                        }

                        Device (SS02)
                        {
                            Name (_ADR, 0x06)  // _ADR: Address
                            Method (_UPC, 0, NotSerialized)  // _UPC: USB Port Capabilities
                            {
                                Return (UPC3) /* \_SB_.PCI0.GP17.XHC0.RHUB.UPC3 */
                            }

                            Method (_PLD, 0, NotSerialized)  // _PLD: Physical Location of Device
                            {
                                Return (PLD2) /* \_SB_.PCI0.GP17.XHC0.RHUB.PLD2 */
                            }
                        }

                        Device (SS03)
                        {
                            Name (_ADR, 0x07)  // _ADR: Address
                            Method (_UPC, 0, NotSerialized)  // _UPC: USB Port Capabilities
                            {
                                Return (UPCN) /* \_SB_.PCI0.GP17.XHC0.RHUB.UPCN */
                            }
                        }

                        Device (SS04)
                        {
                            Name (_ADR, 0x08)  // _ADR: Address
                            Method (_UPC, 0, NotSerialized)  // _UPC: USB Port Capabilities
                            {
                                Return (UPCN) /* \_SB_.PCI0.GP17.XHC0.RHUB.UPCN */
                            }
                        }
                    }
                }

                Device (XHC1)
                {
                    Name (_ADR, 0x04)  // _ADR: Address
                    Method (RHRW, 0, NotSerialized)
                    {
                        Return (GPRW (0x19, 0x03))
                    }

                    Device (RHUB)
                    {
                        Name (_ADR, Zero)  // _ADR: Address
                        Name (UPCN, Package (0x04)
                        {
                            Zero, 
                            Zero, 
                            Zero, 
                            Zero
                        })
                        Name (UPC4, Package (0x04)
                        {
                            0xFF, 
                            0x09, 
                            Zero, 
                            Zero
                        })
                        Name (UPC3, Package (0x04)
                        {
                            0xFF, 
                            0x03, 
                            Zero, 
                            Zero
                        })
                        Name (UPCP, Package (0x04)
                        {
                            0xFF, 
                            0xFF, 
                            Zero, 
                            Zero
                        })
                        Name (UPC5, Package (0x04)
                        {
                            0xFF, 
                            Zero, 
                            Zero, 
                            Zero
                        })
                        Name (PLDN, Package (0x01)
                        {
                            Buffer (0x10)
                            {
                                /* 0000 */  0x82, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                                /* 0008 */  0x99, 0x11, 0x00, 0x00, 0x03, 0x00, 0x00, 0x00   // ........
                            }
                        })
                        Name (PLD5, Package (0x01)
                        {
                            Buffer (0x10)
                            {
                                /* 0000 */  0x82, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                                /* 0008 */  0x69, 0x0C, 0x00, 0x04, 0x00, 0x00, 0x00, 0x00   // i.......
                            }
                        })
                        Name (PLD6, Package (0x01)
                        {
                            Buffer (0x10)
                            {
                                /* 0000 */  0x82, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                                /* 0008 */  0x61, 0x1E, 0x00, 0x03, 0x00, 0x00, 0x00, 0x00   // a.......
                            }
                        })
                        Name (PLD7, Package (0x01)
                        {
                            Buffer (0x10)
                            {
                                /* 0000 */  0x82, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                                /* 0008 */  0x61, 0x1C, 0x80, 0x03, 0x00, 0x00, 0x00, 0x00   // a.......
                            }
                        })
                        Name (PLD8, Package (0x01)
                        {
                            Buffer (0x10)
                            {
                                /* 0000 */  0x82, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                                /* 0008 */  0xE0, 0x1E, 0x08, 0x02, 0x00, 0x00, 0x00, 0x00   // ........
                            }
                        })
                        Device (HS01)
                        {
                            Name (_ADR, One)  // _ADR: Address
                            Method (_UPC, 0, NotSerialized)  // _UPC: USB Port Capabilities
                            {
                                Return (UPC5) /* \_SB_.PCI0.GP17.XHC1.RHUB.UPC5 */
                            }

                            Method (_PLD, 0, NotSerialized)  // _PLD: Physical Location of Device
                            {
                                Return (PLD5) /* \_SB_.PCI0.GP17.XHC1.RHUB.PLD5 */
                            }
                        }

                        Device (HS02)
                        {
                            Name (_ADR, 0x02)  // _ADR: Address
                            Method (_UPC, 0, NotSerialized)  // _UPC: USB Port Capabilities
                            {
                                Return (UPC5) /* \_SB_.PCI0.GP17.XHC1.RHUB.UPC5 */
                            }

                            Method (_PLD, 0, NotSerialized)  // _PLD: Physical Location of Device
                            {
                                Return (PLD6) /* \_SB_.PCI0.GP17.XHC1.RHUB.PLD6 */
                            }
                        }

                        Device (HS03)
                        {
                            Name (_ADR, 0x03)  // _ADR: Address
                            Method (_UPC, 0, NotSerialized)  // _UPC: USB Port Capabilities
                            {
                                Return (UPCN) /* \_SB_.PCI0.GP17.XHC1.RHUB.UPCN */
                            }

                            Method (_PLD, 0, NotSerialized)  // _PLD: Physical Location of Device
                            {
                                Return (PLDN) /* \_SB_.PCI0.GP17.XHC1.RHUB.PLDN */
                            }
                        }

                        Device (HS04)
                        {
                            Name (_ADR, 0x04)  // _ADR: Address
                            Method (_UPC, 0, NotSerialized)  // _UPC: USB Port Capabilities
                            {
                                Return (UPCN) /* \_SB_.PCI0.GP17.XHC1.RHUB.UPCN */
                            }

                            Method (_PLD, 0, NotSerialized)  // _PLD: Physical Location of Device
                            {
                                Return (PLDN) /* \_SB_.PCI0.GP17.XHC1.RHUB.PLDN */
                            }
                        }

                        Device (SS01)
                        {
                            Name (_ADR, 0x05)  // _ADR: Address
                            Method (_UPC, 0, NotSerialized)  // _UPC: USB Port Capabilities
                            {
                                Return (UPC4) /* \_SB_.PCI0.GP17.XHC1.RHUB.UPC4 */
                            }

                            Method (_PLD, 0, NotSerialized)  // _PLD: Physical Location of Device
                            {
                                Return (PLD5) /* \_SB_.PCI0.GP17.XHC1.RHUB.PLD5 */
                            }
                        }

                        Device (SS02)
                        {
                            Name (_ADR, 0x06)  // _ADR: Address
                            Method (_UPC, 0, NotSerialized)  // _UPC: USB Port Capabilities
                            {
                                Return (UPC3) /* \_SB_.PCI0.GP17.XHC1.RHUB.UPC3 */
                            }

                            Method (_PLD, 0, NotSerialized)  // _PLD: Physical Location of Device
                            {
                                Return (PLD6) /* \_SB_.PCI0.GP17.XHC1.RHUB.PLD6 */
                            }
                        }

                        Device (SS03)
                        {
                            Name (_ADR, 0x07)  // _ADR: Address
                            Method (_UPC, 0, NotSerialized)  // _UPC: USB Port Capabilities
                            {
                                Return (UPCN) /* \_SB_.PCI0.GP17.XHC1.RHUB.UPCN */
                            }
                        }

                        Device (SS04)
                        {
                            Name (_ADR, 0x08)  // _ADR: Address
                            Method (_UPC, 0, NotSerialized)  // _UPC: USB Port Capabilities
                            {
                                Return (UPCN) /* \_SB_.PCI0.GP17.XHC1.RHUB.UPCN */
                            }
                        }
                    }
                }

                Device (MP2C)
                {
                    Name (_ADR, 0x07)  // _ADR: Address
                }
            }

            Device (GP18)
            {
                Name (_ADR, 0x00080002)  // _ADR: Address
                Method (_PRT, 0, NotSerialized)  // _PRT: PCI Routing Table
                {
                    If (GPIC)
                    {
                        Return (Package (0x04)
                        {
                            Package (0x04)
                            {
                                0xFFFF, 
                                Zero, 
                                Zero, 
                                0x1E
                            }, 

                            Package (0x04)
                            {
                                0xFFFF, 
                                One, 
                                Zero, 
                                0x1F
                            }, 

                            Package (0x04)
                            {
                                0xFFFF, 
                                0x02, 
                                Zero, 
                                0x1C
                            }, 

                            Package (0x04)
                            {
                                0xFFFF, 
                                0x03, 
                                Zero, 
                                0x1D
                            }
                        })
                    }
                    Else
                    {
                        Return (Package (0x04)
                        {
                            Package (0x04)
                            {
                                0xFFFF, 
                                Zero, 
                                ^^LPC0.LNKG, 
                                Zero
                            }, 

                            Package (0x04)
                            {
                                0xFFFF, 
                                One, 
                                ^^LPC0.LNKH, 
                                Zero
                            }, 

                            Package (0x04)
                            {
                                0xFFFF, 
                                0x02, 
                                ^^LPC0.LNKE, 
                                Zero
                            }, 

                            Package (0x04)
                            {
                                0xFFFF, 
                                0x03, 
                                ^^LPC0.LNKF, 
                                Zero
                            }
                        })
                    }
                }

                Device (SATA)
                {
                    Name (_ADR, Zero)  // _ADR: Address
                }

                Device (SAT1)
                {
                    Name (_ADR, One)  // _ADR: Address
                }
            }

            Device (GP19)
            {
                Name (_ADR, 0x00080003)  // _ADR: Address
                Method (_PRW, 0, NotSerialized)  // _PRW: Power Resources for Wake
                {
                    If ((WKPM == One))
                    {
                        Return (GPRW (0x08, 0x03))
                    }
                }

                Method (_PRT, 0, NotSerialized)  // _PRT: PCI Routing Table
                {
                    If (GPIC)
                    {
                        Return (Package (0x04)
                        {
                            Package (0x04)
                            {
                                0xFFFF, 
                                Zero, 
                                Zero, 
                                0x1A
                            }, 

                            Package (0x04)
                            {
                                0xFFFF, 
                                One, 
                                Zero, 
                                0x1B
                            }, 

                            Package (0x04)
                            {
                                0xFFFF, 
                                0x02, 
                                Zero, 
                                0x18
                            }, 

                            Package (0x04)
                            {
                                0xFFFF, 
                                0x03, 
                                Zero, 
                                0x19
                            }
                        })
                    }
                    Else
                    {
                        Return (Package (0x04)
                        {
                            Package (0x04)
                            {
                                0xFFFF, 
                                Zero, 
                                ^^LPC0.LNKC, 
                                Zero
                            }, 

                            Package (0x04)
                            {
                                0xFFFF, 
                                One, 
                                ^^LPC0.LNKD, 
                                Zero
                            }, 

                            Package (0x04)
                            {
                                0xFFFF, 
                                0x02, 
                                ^^LPC0.LNKA, 
                                Zero
                            }, 

                            Package (0x04)
                            {
                                0xFFFF, 
                                0x03, 
                                ^^LPC0.LNKB, 
                                Zero
                            }
                        })
                    }
                }

                Device (XHC2)
                {
                    Name (_ADR, Zero)  // _ADR: Address
                    Method (XPRW, 0, NotSerialized)
                    {
                        Return (GPRW (0x1A, 0x04))
                    }

                    Device (RHUB)
                    {
                        Name (_ADR, Zero)  // _ADR: Address
                        Device (PRT1)
                        {
                            Name (_ADR, One)  // _ADR: Address
                            Name (UPC1, Package (0x04)
                            {
                                0xFF, 
                                Zero, 
                                Zero, 
                                Zero
                            })
                            Method (_UPC, 0, Serialized)  // _UPC: USB Port Capabilities
                            {
                                Return (UPC1) /* \_SB_.PCI0.GP19.XHC2.RHUB.PRT1.UPC1 */
                            }

                            Name (PLD1, Package (0x01)
                            {
                                Buffer (0x14)
                                {
                                    /* 0000 */  0x82, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                                    /* 0008 */  0x00, 0x00, 0x00, 0x04, 0x00, 0x00, 0x00, 0x00,  // ........
                                    /* 0010 */  0x00, 0x00, 0x00, 0x00                           // ....
                                }
                            })
                            Method (_PLD, 0, Serialized)  // _PLD: Physical Location of Device
                            {
                                Return (PLD1) /* \_SB_.PCI0.GP19.XHC2.RHUB.PRT1.PLD1 */
                            }

                            Device (CAM0)
                            {
                                Name (_ADR, 0x03)  // _ADR: Address
                            }

                            Device (CAM1)
                            {
                                Name (_ADR, One)  // _ADR: Address
                            }
                        }

                        Device (PRT2)
                        {
                            Name (_ADR, 0x02)  // _ADR: Address
                            Name (UPC1, Package (0x04)
                            {
                                Zero, 
                                Zero, 
                                Zero, 
                                Zero
                            })
                            Name (PLD1, Package (0x01)
                            {
                                Buffer (0x14)
                                {
                                    /* 0000 */  0x82, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                                    /* 0008 */  0x00, 0x00, 0x00, 0x04, 0x00, 0x00, 0x00, 0x00,  // ........
                                    /* 0010 */  0x00, 0x00, 0x00, 0x00                           // ....
                                }
                            })
                            Method (_UPC, 0, Serialized)  // _UPC: USB Port Capabilities
                            {
                                Return (UPC1) /* \_SB_.PCI0.GP19.XHC2.RHUB.PRT2.UPC1 */
                            }

                            Method (_PLD, 0, Serialized)  // _PLD: Physical Location of Device
                            {
                                Return (PLD1) /* \_SB_.PCI0.GP19.XHC2.RHUB.PRT2.PLD1 */
                            }
                        }
                    }
                }
            }

            Scope (GPP6)
            {
                Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
                {
                    Name (RBUF, ResourceTemplate ()
                    {
                        GpioInt (Edge, ActiveLow, ExclusiveAndWake, PullNone, 0x0000,
                            "\\_SB.GPIO", 0x00, ResourceConsumer, ,
                            )
                            {   // Pin list
                                0x0012
                            }
                        GpioInt (Edge, ActiveHigh, SharedAndWake, PullNone, 0x0000,
                            "\\_SB.GPIO", 0x00, ResourceConsumer, ,
                            )
                            {   // Pin list
                                0x00AC
                            }
                    })
                    Return (RBUF) /* \_SB_.PCI0.GPP6._CRS.RBUF */
                }
            }

            Device (HPET)
            {
                Name (_HID, EisaId ("PNP0103") /* HPET System Timer */)  // _HID: Hardware ID
                Method (_STA, 0, NotSerialized)  // _STA: Status
                {
                    If ((^^SMB.HPEN == One))
                    {
                        If ((OSTB >= 0x40))
                        {
                            Return (0x0F)
                        }

                        ^^SMB.HPEN = Zero
                        Return (One)
                    }

                    Return (One)
                }

                Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
                {
                    Name (BUF0, ResourceTemplate ()
                    {
                        IRQNoFlags ()
                            {0}
                        IRQNoFlags ()
                            {8}
                        Memory32Fixed (ReadOnly,
                            0xFED00000,         // Address Base
                            0x00000400,         // Address Length
                            _Y06)
                    })
                    CreateDWordField (BUF0, \_SB.PCI0.HPET._CRS._Y06._BAS, HPEB)  // _BAS: Base Address
                    Local0 = 0xFED00000
                    HPEB = (Local0 & 0xFFFFFC00)
                    Return (BUF0) /* \_SB_.PCI0.HPET._CRS.BUF0 */
                }
            }

            Device (SMB)
            {
                Name (_ADR, 0x00140000)  // _ADR: Address
                OperationRegion (SBRV, PCI_Config, 0x08, 0x0100)
                Field (SBRV, AnyAcc, NoLock, Preserve)
                {
                    RVID,   8, 
                    Offset (0x5A), 
                    I1F,    1, 
                    I12F,   1, 
                    Offset (0x7A), 
                        ,   2, 
                    G31O,   1, 
                    Offset (0xD9), 
                        ,   6, 
                    ACIR,   1
                }

                OperationRegion (PMIO, SystemMemory, 0xFED80300, 0x0100)
                Field (PMIO, ByteAcc, NoLock, Preserve)
                {
                        ,   6, 
                    HPEN,   1, 
                    Offset (0x60), 
                    P1EB,   16, 
                    Offset (0xF0), 
                        ,   3, 
                    RSTU,   1
                }

                OperationRegion (ERMG, SystemMemory, 0xFED81500, 0x03FF)
                Field (ERMG, AnyAcc, NoLock, Preserve)
                {
                    Offset (0x0B), 
                        ,   4, 
                    P2IS,   1, 
                    P2WS,   1, 
                    Offset (0x18), 
                    Offset (0x1A), 
                    GE10,   1, 
                    Offset (0x1C), 
                    Offset (0x1E), 
                    GE11,   1, 
                    Offset (0x40), 
                    Offset (0x42), 
                    GE12,   1, 
                    Offset (0x46), 
                    GS17,   1, 
                        ,   5, 
                    GV17,   1, 
                    GE17,   1, 
                    Offset (0x108), 
                    Offset (0x10A), 
                    P33I,   1, 
                    Offset (0x10C), 
                    Offset (0x10E), 
                    P37I,   1, 
                    Offset (0x118), 
                    Offset (0x11A), 
                    P3BI,   1, 
                    Offset (0x11C), 
                    Offset (0x11E), 
                    P40I,   1, 
                    Offset (0x128), 
                        ,   22, 
                    PLEN,   1, 
                    Offset (0x130), 
                    Offset (0x132), 
                    BOID,   1
                }

                OperationRegion (ERMM, SystemMemory, 0xFED80000, 0x1000)
                Field (ERMM, AnyAcc, NoLock, Preserve)
                {
                    Offset (0x288), 
                        ,   1, 
                    CLPS,   1, 
                    Offset (0x2B0), 
                        ,   2, 
                    SLPS,   2, 
                    Offset (0x3BB), 
                        ,   6, 
                    PWDE,   1
                }

                OperationRegion (P1E0, SystemIO, P1EB, 0x04)
                Field (P1E0, ByteAcc, NoLock, Preserve)
                {
                    Offset (0x01), 
                        ,   6, 
                    PEWS,   1, 
                    WSTA,   1, 
                    Offset (0x03), 
                        ,   6, 
                    PEWD,   1
                }

                Method (TRMD, 0, NotSerialized)
                {
                }

                Method (HTCD, 0, NotSerialized)
                {
                }

                OperationRegion (ABIO, SystemIO, 0x0CD8, 0x08)
                Field (ABIO, DWordAcc, NoLock, Preserve)
                {
                    INAB,   32, 
                    DAAB,   32
                }

                Method (RDAB, 1, NotSerialized)
                {
                    INAB = Arg0
                    Return (DAAB) /* \_SB_.PCI0.SMB_.DAAB */
                }

                Method (WTAB, 2, NotSerialized)
                {
                    INAB = Arg0
                    DAAB = Arg1
                }

                Method (RWAB, 3, NotSerialized)
                {
                    Local0 = (RDAB (Arg0) & Arg1)
                    Local1 = (Local0 | Arg2)
                    WTAB (Arg0, Local1)
                }

                Method (CABR, 3, NotSerialized)
                {
                    Local0 = (Arg0 << 0x05)
                    Local1 = (Local0 + Arg1)
                    Local2 = (Local1 << 0x18)
                    Local3 = (Local2 + Arg2)
                    Return (Local3)
                }
            }

            Device (LPC0)
            {
                Name (_ADR, 0x00140003)  // _ADR: Address
                OperationRegion (PIRQ, SystemIO, 0x0C00, 0x02)
                Field (PIRQ, ByteAcc, NoLock, Preserve)
                {
                    PIID,   8, 
                    PIDA,   8
                }

                IndexField (PIID, PIDA, ByteAcc, NoLock, Preserve)
                {
                    PIRA,   8, 
                    PIRB,   8, 
                    PIRC,   8, 
                    PIRD,   8, 
                    PIRE,   8, 
                    PIRF,   8, 
                    PIRG,   8, 
                    PIRH,   8, 
                    Offset (0x0C), 
                    SIRA,   8, 
                    SIRB,   8, 
                    SIRC,   8, 
                    SIRD,   8, 
                    PIRS,   8, 
                    Offset (0x13), 
                    HDAD,   8, 
                    Offset (0x17), 
                    SDCL,   8, 
                    Offset (0x1A), 
                    SDIO,   8, 
                    Offset (0x30), 
                    USB1,   8, 
                    Offset (0x34), 
                    USB3,   8, 
                    Offset (0x41), 
                    SATA,   8, 
                    Offset (0x62), 
                    GIOC,   8, 
                    Offset (0x70), 
                    I2C0,   8, 
                    I2C1,   8, 
                    I2C2,   8, 
                    I2C3,   8, 
                    URT0,   8, 
                    URT1,   8
                }

                Name (IPRS, ResourceTemplate ()
                {
                    IRQ (Level, ActiveLow, Shared, )
                        {3,5,6,10,11}
                })
                Name (UPRS, ResourceTemplate ()
                {
                    IRQ (Level, ActiveLow, Exclusive, )
                        {15}
                })
                OperationRegion (KBDD, SystemIO, 0x64, One)
                Field (KBDD, ByteAcc, NoLock, Preserve)
                {
                    PD64,   8
                }

                Method (DSPI, 0, NotSerialized)
                {
                    INTA (0x1F)
                    INTB (0x1F)
                    INTC (0x1F)
                    INTD (0x1F)
                    Local1 = PD64 /* \_SB_.PCI0.LPC0.PD64 */
                    PIRE = 0x1F
                    PIRF = 0x1F
                    PIRG = 0x1F
                    PIRH = 0x1F
                }

                Method (INTA, 1, NotSerialized)
                {
                    PIRA = Arg0
                    If (GPIC)
                    {
                        HDAD = Arg0
                        SDCL = Arg0
                    }
                }

                Method (INTB, 1, NotSerialized)
                {
                    PIRB = Arg0
                }

                Method (INTC, 1, NotSerialized)
                {
                    PIRC = Arg0
                    If (GPIC)
                    {
                        USB1 = Arg0
                        USB3 = Arg0
                    }
                }

                Method (INTD, 1, NotSerialized)
                {
                    PIRD = Arg0
                    If (GPIC)
                    {
                        SATA = Arg0
                    }
                }

                Device (LNKA)
                {
                    Name (_HID, EisaId ("PNP0C0F") /* PCI Interrupt Link Device */)  // _HID: Hardware ID
                    Name (_UID, One)  // _UID: Unique ID
                    Method (_STA, 0, NotSerialized)  // _STA: Status
                    {
                        If (PIRA)
                        {
                            Return (0x0B)
                        }
                        Else
                        {
                            Return (0x09)
                        }
                    }

                    Method (_PRS, 0, NotSerialized)  // _PRS: Possible Resource Settings
                    {
                        Return (IPRS) /* \_SB_.PCI0.LPC0.IPRS */
                    }

                    Method (_DIS, 0, NotSerialized)  // _DIS: Disable Device
                    {
                        INTA (0x1F)
                    }

                    Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
                    {
                        Local0 = IPRS /* \_SB_.PCI0.LPC0.IPRS */
                        CreateWordField (Local0, One, IRQ0)
                        IRQ0 = (One << PIRA) /* \_SB_.PCI0.LPC0.PIRA */
                        Return (Local0)
                    }

                    Method (_SRS, 1, NotSerialized)  // _SRS: Set Resource Settings
                    {
                        CreateWordField (Arg0, One, IRQ0)
                        FindSetRightBit (IRQ0, Local0)
                        Local0--
                        INTA (Local0)
                    }
                }

                Device (LNKB)
                {
                    Name (_HID, EisaId ("PNP0C0F") /* PCI Interrupt Link Device */)  // _HID: Hardware ID
                    Name (_UID, 0x02)  // _UID: Unique ID
                    Method (_STA, 0, NotSerialized)  // _STA: Status
                    {
                        If (PIRB)
                        {
                            Return (0x0B)
                        }
                        Else
                        {
                            Return (0x09)
                        }
                    }

                    Method (_PRS, 0, NotSerialized)  // _PRS: Possible Resource Settings
                    {
                        Return (IPRS) /* \_SB_.PCI0.LPC0.IPRS */
                    }

                    Method (_DIS, 0, NotSerialized)  // _DIS: Disable Device
                    {
                        INTB (0x1F)
                    }

                    Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
                    {
                        Local0 = IPRS /* \_SB_.PCI0.LPC0.IPRS */
                        CreateWordField (Local0, One, IRQ0)
                        IRQ0 = (One << PIRB) /* \_SB_.PCI0.LPC0.PIRB */
                        Return (Local0)
                    }

                    Method (_SRS, 1, NotSerialized)  // _SRS: Set Resource Settings
                    {
                        CreateWordField (Arg0, One, IRQ0)
                        FindSetRightBit (IRQ0, Local0)
                        Local0--
                        INTB (Local0)
                    }
                }

                Device (LNKC)
                {
                    Name (_HID, EisaId ("PNP0C0F") /* PCI Interrupt Link Device */)  // _HID: Hardware ID
                    Name (_UID, 0x03)  // _UID: Unique ID
                    Method (_STA, 0, NotSerialized)  // _STA: Status
                    {
                        If (PIRC)
                        {
                            Return (0x0B)
                        }
                        Else
                        {
                            Return (0x09)
                        }
                    }

                    Method (_PRS, 0, NotSerialized)  // _PRS: Possible Resource Settings
                    {
                        Return (IPRS) /* \_SB_.PCI0.LPC0.IPRS */
                    }

                    Method (_DIS, 0, NotSerialized)  // _DIS: Disable Device
                    {
                        INTC (0x1F)
                    }

                    Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
                    {
                        Local0 = IPRS /* \_SB_.PCI0.LPC0.IPRS */
                        CreateWordField (Local0, One, IRQ0)
                        IRQ0 = (One << PIRC) /* \_SB_.PCI0.LPC0.PIRC */
                        Return (Local0)
                    }

                    Method (_SRS, 1, NotSerialized)  // _SRS: Set Resource Settings
                    {
                        CreateWordField (Arg0, One, IRQ0)
                        FindSetRightBit (IRQ0, Local0)
                        Local0--
                        INTC (Local0)
                    }
                }

                Device (LNKD)
                {
                    Name (_HID, EisaId ("PNP0C0F") /* PCI Interrupt Link Device */)  // _HID: Hardware ID
                    Name (_UID, 0x04)  // _UID: Unique ID
                    Method (_STA, 0, NotSerialized)  // _STA: Status
                    {
                        If (PIRD)
                        {
                            Return (0x0B)
                        }
                        Else
                        {
                            Return (0x09)
                        }
                    }

                    Method (_PRS, 0, NotSerialized)  // _PRS: Possible Resource Settings
                    {
                        Return (IPRS) /* \_SB_.PCI0.LPC0.IPRS */
                    }

                    Method (_DIS, 0, NotSerialized)  // _DIS: Disable Device
                    {
                        INTD (0x1F)
                    }

                    Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
                    {
                        Local0 = IPRS /* \_SB_.PCI0.LPC0.IPRS */
                        CreateWordField (Local0, One, IRQ0)
                        IRQ0 = (One << PIRD) /* \_SB_.PCI0.LPC0.PIRD */
                        Return (Local0)
                    }

                    Method (_SRS, 1, NotSerialized)  // _SRS: Set Resource Settings
                    {
                        CreateWordField (Arg0, One, IRQ0)
                        FindSetRightBit (IRQ0, Local0)
                        Local0--
                        INTD (Local0)
                    }
                }

                Device (LNKE)
                {
                    Name (_HID, EisaId ("PNP0C0F") /* PCI Interrupt Link Device */)  // _HID: Hardware ID
                    Name (_UID, 0x05)  // _UID: Unique ID
                    Method (_STA, 0, NotSerialized)  // _STA: Status
                    {
                        If (PIRE)
                        {
                            Return (0x0B)
                        }
                        Else
                        {
                            Return (0x09)
                        }
                    }

                    Method (_PRS, 0, NotSerialized)  // _PRS: Possible Resource Settings
                    {
                        Return (IPRS) /* \_SB_.PCI0.LPC0.IPRS */
                    }

                    Method (_DIS, 0, NotSerialized)  // _DIS: Disable Device
                    {
                        PIRE = 0x1F
                    }

                    Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
                    {
                        Local0 = IPRS /* \_SB_.PCI0.LPC0.IPRS */
                        CreateWordField (Local0, One, IRQ0)
                        IRQ0 = (One << PIRE) /* \_SB_.PCI0.LPC0.PIRE */
                        Return (Local0)
                    }

                    Method (_SRS, 1, NotSerialized)  // _SRS: Set Resource Settings
                    {
                        CreateWordField (Arg0, One, IRQ0)
                        FindSetRightBit (IRQ0, Local0)
                        Local0--
                        PIRE = Local0
                    }
                }

                Device (LNKF)
                {
                    Name (_HID, EisaId ("PNP0C0F") /* PCI Interrupt Link Device */)  // _HID: Hardware ID
                    Name (_UID, 0x06)  // _UID: Unique ID
                    Method (_STA, 0, NotSerialized)  // _STA: Status
                    {
                        If (PIRF)
                        {
                            Return (0x0B)
                        }
                        Else
                        {
                            Return (0x09)
                        }
                    }

                    Method (_PRS, 0, NotSerialized)  // _PRS: Possible Resource Settings
                    {
                        Return (IPRS) /* \_SB_.PCI0.LPC0.IPRS */
                    }

                    Method (_DIS, 0, NotSerialized)  // _DIS: Disable Device
                    {
                        PIRF = 0x1F
                    }

                    Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
                    {
                        Local0 = IPRS /* \_SB_.PCI0.LPC0.IPRS */
                        CreateWordField (Local0, One, IRQ0)
                        IRQ0 = (One << PIRF) /* \_SB_.PCI0.LPC0.PIRF */
                        Return (Local0)
                    }

                    Method (_SRS, 1, NotSerialized)  // _SRS: Set Resource Settings
                    {
                        CreateWordField (Arg0, One, IRQ0)
                        FindSetRightBit (IRQ0, Local0)
                        Local0--
                        PIRF = Local0
                    }
                }

                Device (LNKG)
                {
                    Name (_HID, EisaId ("PNP0C0F") /* PCI Interrupt Link Device */)  // _HID: Hardware ID
                    Name (_UID, 0x07)  // _UID: Unique ID
                    Method (_STA, 0, NotSerialized)  // _STA: Status
                    {
                        If (PIRG)
                        {
                            Return (0x0B)
                        }
                        Else
                        {
                            Return (0x09)
                        }
                    }

                    Method (_PRS, 0, NotSerialized)  // _PRS: Possible Resource Settings
                    {
                        Return (IPRS) /* \_SB_.PCI0.LPC0.IPRS */
                    }

                    Method (_DIS, 0, NotSerialized)  // _DIS: Disable Device
                    {
                        PIRG = 0x1F
                    }

                    Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
                    {
                        Local0 = IPRS /* \_SB_.PCI0.LPC0.IPRS */
                        CreateWordField (Local0, One, IRQ0)
                        IRQ0 = (One << PIRG) /* \_SB_.PCI0.LPC0.PIRG */
                        Return (Local0)
                    }

                    Method (_SRS, 1, NotSerialized)  // _SRS: Set Resource Settings
                    {
                        CreateWordField (Arg0, One, IRQ0)
                        FindSetRightBit (IRQ0, Local0)
                        Local0--
                        PIRG = Local0
                    }
                }

                Device (LNKH)
                {
                    Name (_HID, EisaId ("PNP0C0F") /* PCI Interrupt Link Device */)  // _HID: Hardware ID
                    Name (_UID, 0x08)  // _UID: Unique ID
                    Method (_STA, 0, NotSerialized)  // _STA: Status
                    {
                        If (PIRH)
                        {
                            Return (0x0B)
                        }
                        Else
                        {
                            Return (0x09)
                        }
                    }

                    Method (_PRS, 0, NotSerialized)  // _PRS: Possible Resource Settings
                    {
                        Return (IPRS) /* \_SB_.PCI0.LPC0.IPRS */
                    }

                    Method (_DIS, 0, NotSerialized)  // _DIS: Disable Device
                    {
                        PIRH = 0x1F
                    }

                    Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
                    {
                        Local0 = IPRS /* \_SB_.PCI0.LPC0.IPRS */
                        CreateWordField (Local0, One, IRQ0)
                        IRQ0 = (One << PIRH) /* \_SB_.PCI0.LPC0.PIRH */
                        Return (Local0)
                    }

                    Method (_SRS, 1, NotSerialized)  // _SRS: Set Resource Settings
                    {
                        CreateWordField (Arg0, One, IRQ0)
                        FindSetRightBit (IRQ0, Local0)
                        Local0--
                        PIRH = Local0
                    }
                }

                Device (DMAC)
                {
                    Name (_HID, EisaId ("PNP0200") /* PC-class DMA Controller */)  // _HID: Hardware ID
                    Name (_CRS, ResourceTemplate ()  // _CRS: Current Resource Settings
                    {
                        IO (Decode16,
                            0x0000,             // Range Minimum
                            0x0000,             // Range Maximum
                            0x01,               // Alignment
                            0x10,               // Length
                            )
                        IO (Decode16,
                            0x0081,             // Range Minimum
                            0x0081,             // Range Maximum
                            0x01,               // Alignment
                            0x0F,               // Length
                            )
                        IO (Decode16,
                            0x00C0,             // Range Minimum
                            0x00C0,             // Range Maximum
                            0x01,               // Alignment
                            0x20,               // Length
                            )
                        DMA (Compatibility, NotBusMaster, Transfer8_16, )
                            {4}
                    })
                }

                Device (COPR)
                {
                    Name (_HID, EisaId ("PNP0C04") /* x87-compatible Floating Point Processing Unit */)  // _HID: Hardware ID
                    Name (_CRS, ResourceTemplate ()  // _CRS: Current Resource Settings
                    {
                        IO (Decode16,
                            0x00F0,             // Range Minimum
                            0x00F0,             // Range Maximum
                            0x01,               // Alignment
                            0x0F,               // Length
                            )
                        IRQNoFlags ()
                            {13}
                    })
                }

                Device (PIC)
                {
                    Name (_HID, EisaId ("PNP0000") /* 8259-compatible Programmable Interrupt Controller */)  // _HID: Hardware ID
                    Name (_CRS, ResourceTemplate ()  // _CRS: Current Resource Settings
                    {
                        IO (Decode16,
                            0x0020,             // Range Minimum
                            0x0020,             // Range Maximum
                            0x01,               // Alignment
                            0x02,               // Length
                            )
                        IO (Decode16,
                            0x00A0,             // Range Minimum
                            0x00A0,             // Range Maximum
                            0x01,               // Alignment
                            0x02,               // Length
                            )
                        IRQNoFlags ()
                            {2}
                    })
                }

                Device (RTC)
                {
                    Name (_HID, EisaId ("PNP0B00") /* AT Real-Time Clock */)  // _HID: Hardware ID
                    Name (BUF0, ResourceTemplate ()
                    {
                        IO (Decode16,
                            0x0070,             // Range Minimum
                            0x0070,             // Range Maximum
                            0x01,               // Alignment
                            0x02,               // Length
                            )
                    })
                    Name (BUF1, ResourceTemplate ()
                    {
                        IO (Decode16,
                            0x0070,             // Range Minimum
                            0x0070,             // Range Maximum
                            0x01,               // Alignment
                            0x02,               // Length
                            )
                        IRQNoFlags ()
                            {8}
                    })
                    Method (_CRS, 0, Serialized)  // _CRS: Current Resource Settings
                    {
                        If ((^^^SMB.HPEN == One))
                        {
                            Return (BUF0) /* \_SB_.PCI0.LPC0.RTC_.BUF0 */
                        }

                        Return (BUF1) /* \_SB_.PCI0.LPC0.RTC_.BUF1 */
                    }
                }

                Device (SPKR)
                {
                    Name (_HID, EisaId ("PNP0800") /* Microsoft Sound System Compatible Device */)  // _HID: Hardware ID
                    Name (_CRS, ResourceTemplate ()  // _CRS: Current Resource Settings
                    {
                        IO (Decode16,
                            0x0061,             // Range Minimum
                            0x0061,             // Range Maximum
                            0x01,               // Alignment
                            0x01,               // Length
                            )
                    })
                }

                Device (TIME)
                {
                    Name (_HID, EisaId ("PNP0100") /* PC-class System Timer */)  // _HID: Hardware ID
                    Name (BUF0, ResourceTemplate ()
                    {
                        IO (Decode16,
                            0x0040,             // Range Minimum
                            0x0040,             // Range Maximum
                            0x01,               // Alignment
                            0x04,               // Length
                            )
                    })
                    Name (BUF1, ResourceTemplate ()
                    {
                        IO (Decode16,
                            0x0040,             // Range Minimum
                            0x0040,             // Range Maximum
                            0x01,               // Alignment
                            0x04,               // Length
                            )
                        IRQNoFlags ()
                            {0}
                    })
                    Method (_CRS, 0, Serialized)  // _CRS: Current Resource Settings
                    {
                        If ((^^^SMB.HPEN == One))
                        {
                            Return (BUF0) /* \_SB_.PCI0.LPC0.TIME.BUF0 */
                        }

                        Return (BUF1) /* \_SB_.PCI0.LPC0.TIME.BUF1 */
                    }
                }

                Device (KBD)
                {
                    Method (_HID, 0, NotSerialized)  // _HID: Hardware ID
                    {
                        If (WIN8)
                        {
                            Return (0x7100AE30)
                        }

                        Return (0x0303D041)
                    }

                    Name (_CID, EisaId ("PNP0303") /* IBM Enhanced Keyboard (101/102-key, PS/2 Mouse) */)  // _CID: Compatible ID
                    Name (_CRS, ResourceTemplate ()  // _CRS: Current Resource Settings
                    {
                        IO (Decode16,
                            0x0060,             // Range Minimum
                            0x0060,             // Range Maximum
                            0x01,               // Alignment
                            0x01,               // Length
                            )
                        IO (Decode16,
                            0x0064,             // Range Minimum
                            0x0064,             // Range Maximum
                            0x01,               // Alignment
                            0x01,               // Length
                            )
                        IRQ (Edge, ActiveHigh, Exclusive, )
                            {1}
                    })
                }

                Device (MOU)
                {
                    Name (_HID, "PNP0F13" /* PS/2 Mouse */)  // _HID: Hardware ID
                    Name (_CID, EisaId ("PNP0F13") /* PS/2 Mouse */)  // _CID: Compatible ID
                    Name (_STA, 0x0F)  // _STA: Status
                    Name (_CRS, ResourceTemplate ()  // _CRS: Current Resource Settings
                    {
                        IRQNoFlags ()
                            {12}
                    })
                    Name (DIDL, Package (0x05)
                    {
                        0x03, 
                        0x05, 
                        0x02, 
                        One, 
                        One
                    })
                    Name (PNPL, Package (0x05)
                    {
                        "LEN0307", 
                        "LEN0308", 
                        "LEN0305", 
                        "LEN0305", 
                        "LEN0305"
                    })
                    Method (_INI, 0, NotSerialized)  // _INI: Initialize
                    {
                        MHID ()
                    }

                    Method (MHID, 0, NotSerialized)
                    {
                        Local0 = Match (DIDL, MEQ, (TPID & 0xFF), MTR, Zero, Zero)
                        If ((Local0 != Ones))
                        {
                            _HID = DerefOf (PNPL [Local0])
                        }
                        Else
                        {
                            _STA = Zero
                        }
                    }
                }

                Device (SYSR)
                {
                    Name (_HID, EisaId ("PNP0C02") /* PNP Motherboard Resources */)  // _HID: Hardware ID
                    Name (_UID, One)  // _UID: Unique ID
                    Name (_CRS, ResourceTemplate ()  // _CRS: Current Resource Settings
                    {
                        IO (Decode16,
                            0x0010,             // Range Minimum
                            0x0010,             // Range Maximum
                            0x01,               // Alignment
                            0x10,               // Length
                            )
                        IO (Decode16,
                            0x0072,             // Range Minimum
                            0x0072,             // Range Maximum
                            0x01,               // Alignment
                            0x02,               // Length
                            )
                        IO (Decode16,
                            0x0080,             // Range Minimum
                            0x0080,             // Range Maximum
                            0x01,               // Alignment
                            0x01,               // Length
                            )
                        IO (Decode16,
                            0x0092,             // Range Minimum
                            0x0092,             // Range Maximum
                            0x01,               // Alignment
                            0x01,               // Length
                            )
                        IO (Decode16,
                            0x00B0,             // Range Minimum
                            0x00B0,             // Range Maximum
                            0x01,               // Alignment
                            0x02,               // Length
                            )
                        IO (Decode16,
                            0x0400,             // Range Minimum
                            0x0400,             // Range Maximum
                            0x01,               // Alignment
                            0xD0,               // Length
                            )
                        IO (Decode16,
                            0x04D0,             // Range Minimum
                            0x04D0,             // Range Maximum
                            0x01,               // Alignment
                            0x02,               // Length
                            )
                        IO (Decode16,
                            0x04D6,             // Range Minimum
                            0x04D6,             // Range Maximum
                            0x01,               // Alignment
                            0x01,               // Length
                            )
                        IO (Decode16,
                            0x0C00,             // Range Minimum
                            0x0C00,             // Range Maximum
                            0x01,               // Alignment
                            0x02,               // Length
                            )
                        IO (Decode16,
                            0x0C14,             // Range Minimum
                            0x0C14,             // Range Maximum
                            0x01,               // Alignment
                            0x01,               // Length
                            )
                        IO (Decode16,
                            0x0C50,             // Range Minimum
                            0x0C50,             // Range Maximum
                            0x01,               // Alignment
                            0x03,               // Length
                            )
                        IO (Decode16,
                            0x0C6C,             // Range Minimum
                            0x0C6C,             // Range Maximum
                            0x01,               // Alignment
                            0x01,               // Length
                            )
                        IO (Decode16,
                            0x0C6F,             // Range Minimum
                            0x0C6F,             // Range Maximum
                            0x01,               // Alignment
                            0x01,               // Length
                            )
                        IO (Decode16,
                            0x0CD0,             // Range Minimum
                            0x0CD0,             // Range Maximum
                            0x01,               // Alignment
                            0x0C,               // Length
                            )
                    })
                }

                OperationRegion (LPCS, PCI_Config, 0xA0, 0x04)
                Field (LPCS, DWordAcc, NoLock, Preserve)
                {
                    SPBA,   32
                }

                Device (MEM)
                {
                    Name (_HID, EisaId ("PNP0C01") /* System Board */)  // _HID: Hardware ID
                    Name (MSRC, ResourceTemplate ()
                    {
                        Memory32Fixed (ReadOnly,
                            0x000E0000,         // Address Base
                            0x00020000,         // Address Length
                            )
                        Memory32Fixed (ReadOnly,
                            0x00000000,         // Address Base
                            0x02000000,         // Address Length
                            )
                        Memory32Fixed (ReadWrite,
                            0x00000000,         // Address Base
                            0x00000000,         // Address Length
                            _Y07)
                        Memory32Fixed (ReadWrite,
                            0xFEC10000,         // Address Base
                            0x00000020,         // Address Length
                            _Y08)
                        Memory32Fixed (ReadOnly,
                            0xFED00000,         // Address Base
                            0x00000400,         // Address Length
                            )
                        Memory32Fixed (ReadWrite,
                            0xFED61000,         // Address Base
                            0x00000400,         // Address Length
                            )
                        Memory32Fixed (ReadWrite,
                            0xFED80000,         // Address Base
                            0x00001000,         // Address Length
                            )
                    })
                    Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
                    {
                        CreateDWordField (MSRC, \_SB.PCI0.LPC0.MEM._Y07._BAS, BARX)  // _BAS: Base Address
                        CreateDWordField (MSRC, \_SB.PCI0.LPC0.MEM._Y07._LEN, GALN)  // _LEN: Length
                        CreateDWordField (MSRC, \_SB.PCI0.LPC0.MEM._Y08._BAS, MB01)  // _BAS: Base Address
                        CreateDWordField (MSRC, \_SB.PCI0.LPC0.MEM._Y08._LEN, ML01)  // _LEN: Length
                        Local0 = SPBA /* \_SB_.PCI0.LPC0.SPBA */
                        MB01 = (Local0 & 0xFFFFFFE0)
                        Local0 = NBBA /* \_SB_.PCI0.NBBA */
                        If (Local0)
                        {
                            GALN = 0x1000
                            BARX = (Local0 & 0xFFFFFFF0)
                        }

                        Return (MSRC) /* \_SB_.PCI0.LPC0.MEM_.MSRC */
                    }
                }

                Device (EC0)
                {
                    Name (_HID, EisaId ("PNP0C09") /* Embedded Controller Device */)  // _HID: Hardware ID
                    Name (_UID, Zero)  // _UID: Unique ID
                    Name (_GPE, 0x07)  // _GPE: General Purpose Events
                    Method (_REG, 2, NotSerialized)  // _REG: Region Availability
                    {
                        If ((Arg0 == 0x03))
                        {
                            H8DR = Arg1
                        }
                    }

                    Mutex (UCCI, 0x00)
                    Mutex (SMUM, 0x00)
                    OperationRegion (ECOR, EmbeddedControl, Zero, 0x0100)
                    Field (ECOR, ByteAcc, NoLock, Preserve)
                    {
                        HDBM,   1, 
                            ,   1, 
                            ,   1, 
                        HFNE,   1, 
                            ,   1, 
                            ,   1, 
                        HLDM,   1, 
                        Offset (0x01), 
                        BBLS,   1, 
                        BTCM,   1, 
                            ,   1, 
                            ,   1, 
                            ,   1, 
                        HBPR,   1, 
                        BTPC,   1, 
                        Offset (0x02), 
                        HDUE,   1, 
                            ,   4, 
                        SNLK,   1, 
                        Offset (0x03), 
                            ,   5, 
                        HAUM,   2, 
                        Offset (0x05), 
                        HSPA,   1, 
                        Offset (0x06), 
                        HSUN,   8, 
                        HSRP,   8, 
                        Offset (0x0C), 
                        HLCL,   8, 
                            ,   4, 
                        CALM,   1, 
                        Offset (0x0E), 
                        HFNS,   2, 
                        Offset (0x0F), 
                            ,   6, 
                        NULS,   1, 
                        Offset (0x10), 
                        HAM0,   8, 
                        HAM1,   8, 
                        HAM2,   8, 
                        HAM3,   8, 
                        HAM4,   8, 
                        HAM5,   8, 
                        HAM6,   8, 
                        HAM7,   8, 
                        HAM8,   8, 
                        HAM9,   8, 
                        HAMA,   8, 
                        HAMB,   8, 
                        HAMC,   8, 
                        HAMD,   8, 
                        HAME,   8, 
                        HAMF,   8, 
                        Offset (0x23), 
                        HANT,   8, 
                        Offset (0x26), 
                            ,   2, 
                        HANA,   2, 
                        Offset (0x27), 
                        Offset (0x28), 
                            ,   1, 
                        SKEM,   1, 
                            ,   1, 
                        WRST,   1, 
                            ,   5, 
                        Offset (0x2A), 
                        HATR,   8, 
                        HT0H,   8, 
                        HT0L,   8, 
                        HT1H,   8, 
                        HT1L,   8, 
                        HFSP,   8, 
                            ,   6, 
                        HMUT,   1, 
                        Offset (0x31), 
                            ,   2, 
                        HUWB,   1, 
                            ,   3, 
                        VPON,   1, 
                        VRST,   1, 
                        HWPM,   1, 
                        HWLB,   1, 
                        HWLO,   1, 
                        HWDK,   1, 
                        HWFN,   1, 
                        HWBT,   1, 
                        HWRI,   1, 
                        HWBU,   1, 
                        HWLU,   1, 
                        Offset (0x34), 
                            ,   3, 
                        PIBS,   1, 
                            ,   3, 
                        HPLO,   1, 
                            ,   4, 
                        FANE,   1, 
                        Offset (0x36), 
                        HWAC,   16, 
                        HB0S,   7, 
                        HB0A,   1, 
                        HB1S,   7, 
                        HB1A,   1, 
                        HCMU,   1, 
                            ,   2, 
                        OVRQ,   1, 
                        DCBD,   1, 
                        DCWL,   1, 
                        DCWW,   1, 
                        HB1I,   1, 
                            ,   1, 
                        KBLT,   1, 
                        BTPW,   1, 
                        FNKC,   1, 
                        HUBS,   1, 
                        BDPW,   1, 
                        BDDT,   1, 
                        HUBB,   1, 
                        Offset (0x46), 
                            ,   1, 
                        BTWK,   1, 
                        HPLD,   1, 
                            ,   1, 
                        HPAC,   1, 
                        BTST,   1, 
                        PSST,   1, 
                        Offset (0x47), 
                        HPBU,   1, 
                            ,   1, 
                        HBID,   1, 
                            ,   3, 
                        HBCS,   1, 
                        HPNF,   1, 
                            ,   1, 
                        GSTS,   1, 
                            ,   2, 
                        HLBU,   1, 
                        DOCD,   1, 
                        HCBL,   1, 
                        Offset (0x49), 
                        SLUL,   1, 
                            ,   1, 
                        ACAT,   1, 
                            ,   4, 
                        ELNK,   1, 
                        FPSU,   1, 
                        Offset (0x4B), 
                        Offset (0x4C), 
                        HTMH,   8, 
                        HTML,   8, 
                        HWAK,   16, 
                        HMPR,   8, 
                            ,   7, 
                        HMDN,   1, 
                        Offset (0x78), 
                        TMP0,   8, 
                        Offset (0x7F), 
                            ,   1, 
                        QCON,   1, 
                        Offset (0x80), 
                        Offset (0x81), 
                        HIID,   8, 
                        Offset (0x83), 
                        HFNI,   8, 
                        HSPD,   16, 
                        Offset (0x88), 
                        TSL0,   7, 
                        TSR0,   1, 
                        TSL1,   7, 
                        TSR1,   1, 
                        TSL2,   7, 
                        TSR2,   1, 
                        TSL3,   7, 
                        TSR3,   1, 
                        GPUT,   1, 
                        Offset (0x8D), 
                        HDAA,   3, 
                        HDAB,   3, 
                        HDAC,   2, 
                        Offset (0xB0), 
                        HDEN,   32, 
                        HDEP,   32, 
                        HDEM,   8, 
                        HDES,   8, 
                        Offset (0xC4), 
                        CQLS,   2, 
                        Offset (0xC5), 
                        Offset (0xC8), 
                        ATMX,   8, 
                        HWAT,   8, 
                        Offset (0xCB), 
                        TTCI,   8, 
                        PWMH,   8, 
                        PWML,   8, 
                        Offset (0xCF), 
                            ,   4, 
                        ESFL,   1, 
                        ESLS,   1, 
                        ESLP,   1, 
                        Offset (0xD0), 
                        Offset (0xED), 
                            ,   4, 
                        HDDD,   1
                    }

                    Method (_INI, 0, NotSerialized)  // _INI: Initialize
                    {
                        If (H8DR)
                        {
                            HSPA = Zero
                        }
                        Else
                        {
                            MBEC (0x05, 0xFE, Zero)
                        }

                        ^HKEY.WGIN ()
                        If (H8DR)
                        {
                            If ((WLAC == 0x02)){}
                            ElseIf ((ELNK && (WLAC == One)))
                            {
                                DCWL = Zero
                            }
                            Else
                            {
                                DCWL = One
                            }
                        }
                        Else
                        {
                            MBEC (0x3A, 0xFF, 0x20)
                        }
                    }

                    Name (_CRS, ResourceTemplate ()  // _CRS: Current Resource Settings
                    {
                        IO (Decode16,
                            0x0062,             // Range Minimum
                            0x0062,             // Range Maximum
                            0x01,               // Alignment
                            0x01,               // Length
                            )
                        IO (Decode16,
                            0x0066,             // Range Minimum
                            0x0066,             // Range Maximum
                            0x01,               // Alignment
                            0x01,               // Length
                            )
                    })
                    Method (LED, 2, NotSerialized)
                    {
                        Local0 = (Arg0 | Arg1)
                        If (H8DR)
                        {
                            HLCL = Local0
                        }
                        Else
                        {
                            WBEC (0x0C, Local0)
                        }
                    }

                    Name (BAON, Zero)
                    Name (WBON, Zero)
                    Method (BEEP, 1, NotSerialized)
                    {
                        If ((Arg0 == 0x05))
                        {
                            WBON = Zero
                        }

                        Local2 = WBON /* \_SB_.PCI0.LPC0.EC0_.WBON */
                        If (BAON)
                        {
                            If ((Arg0 == Zero))
                            {
                                BAON = Zero
                                If (WBON)
                                {
                                    Local0 = 0x03
                                    Local1 = 0x08
                                }
                                Else
                                {
                                    Local0 = Zero
                                    Local1 = Zero
                                }
                            }
                            Else
                            {
                                Local0 = 0xFF
                                Local1 = 0xFF
                                If ((Arg0 == 0x11))
                                {
                                    WBON = Zero
                                }

                                If ((Arg0 == 0x10))
                                {
                                    WBON = One
                                }
                            }
                        }
                        Else
                        {
                            Local0 = Arg0
                            Local1 = 0xFF
                            If ((Arg0 == 0x0F))
                            {
                                Local0 = Arg0
                                Local1 = 0x08
                                BAON = One
                            }

                            If ((Arg0 == 0x11))
                            {
                                Local0 = Zero
                                Local1 = Zero
                                WBON = Zero
                            }

                            If ((Arg0 == 0x10))
                            {
                                Local0 = 0x03
                                Local1 = 0x08
                                WBON = One
                            }
                        }

                        If ((Arg0 == 0x03))
                        {
                            WBON = Zero
                            If (Local2)
                            {
                                Local0 = 0x07
                                If (((SPS == 0x03) || (SPS == 0x04)))
                                {
                                    Local2 = Zero
                                    Local0 = 0xFF
                                    Local1 = 0xFF
                                }
                            }
                        }

                        If ((Arg0 == 0x07))
                        {
                            If (Local2)
                            {
                                Local2 = Zero
                                Local0 = 0xFF
                                Local1 = 0xFF
                            }
                        }

                        If (H8DR)
                        {
                            If ((Local2 && !WBON))
                            {
                                HSRP = Zero
                                HSUN = Zero
                                Sleep (0x64)
                            }

                            If ((Local1 != 0xFF))
                            {
                                HSRP = Local1
                            }

                            If ((Local0 != 0xFF))
                            {
                                HSUN = Local0
                            }
                        }
                        Else
                        {
                            If ((Local2 && !WBON))
                            {
                                WBEC (0x07, Zero)
                                WBEC (0x06, Zero)
                                Sleep (0x64)
                            }

                            If ((Local1 != 0xFF))
                            {
                                WBEC (0x07, Local1)
                            }

                            If ((Local0 != 0xFF))
                            {
                                WBEC (0x06, Local0)
                            }
                        }

                        If ((Arg0 == 0x03)){}
                        If ((Arg0 == 0x07))
                        {
                            Sleep (0x01F4)
                        }
                    }

                    Method (EVNT, 1, NotSerialized)
                    {
                        If (H8DR)
                        {
                            If (Arg0)
                            {
                                HAM5 |= 0x04
                            }
                            Else
                            {
                                HAM5 &= 0xFB
                            }
                        }
                        ElseIf (Arg0)
                        {
                            MBEC (0x15, 0xFF, 0x04)
                        }
                        Else
                        {
                            MBEC (0x15, 0xFB, Zero)
                        }
                    }

                    Name (USPS, Zero)
                    PowerResource (PUBS, 0x03, 0x0000)
                    {
                        Method (_STA, 0, NotSerialized)  // _STA: Status
                        {
                            If (H8DR)
                            {
                                Local0 = HUBS /* \_SB_.PCI0.LPC0.EC0_.HUBS */
                            }
                            Else
                            {
                                Local0 = (RBEC (0x3B) & 0x10)
                            }

                            If (Local0)
                            {
                                Return (One)
                            }
                            Else
                            {
                                Return (Zero)
                            }
                        }

                        Method (_ON, 0, NotSerialized)  // _ON_: Power On
                        {
                            Local0 = 0x64
                            While ((USPS && Local0))
                            {
                                Sleep (One)
                                Local0--
                            }

                            If (H8DR)
                            {
                                HUBS = One
                            }
                            Else
                            {
                                MBEC (0x3B, 0xFF, 0x10)
                            }
                        }

                        Method (_OFF, 0, NotSerialized)  // _OFF: Power Off
                        {
                            USPS = One
                            If (H8DR)
                            {
                                HUBS = Zero
                            }
                            Else
                            {
                                MBEC (0x3B, 0xEF, Zero)
                            }

                            Sleep (0x14)
                            USPS = Zero
                        }
                    }

                    Method (CHKS, 0, NotSerialized)
                    {
                        Local0 = 0x03E8
                        While (HMPR)
                        {
                            Sleep (One)
                            Local0--
                            If (!Local0)
                            {
                                Return (0x8080)
                            }
                        }

                        If (HMDN)
                        {
                            Return (Zero)
                        }

                        Return (0x8081)
                    }

                    Method (LPMD, 0, NotSerialized)
                    {
                        Local0 = Zero
                        Local1 = Zero
                        Local2 = Zero
                        Return (Local0)
                    }

                    Method (CLPM, 0, NotSerialized)
                    {
                    }

                    Method (ECNT, 1, Serialized)
                    {
                        Switch (ToInteger (Arg0))
                        {
                            Case (Zero)
                            {
                                If (H8DR)
                                {
                                    ESLS = Zero
                                }
                                Else
                                {
                                    Local0 = RBEC (0xCF)
                                    Local0 &= 0xFFFFFFDF
                                    WBEC (0xCF, Local0)
                                }

                                LED (0x0A, 0x80)
                                LED (Zero, 0x80)
                                Return (Zero)
                            }
                            Case (One)
                            {
                                If (H8DR)
                                {
                                    ESLS = One
                                }
                                Else
                                {
                                    Local1 = RBEC (0xCF)
                                    Local1 |= 0x20
                                    WBEC (0xCF, Local1)
                                }

                                LED (Zero, 0xA0)
                                LED (0x0A, 0xA0)
                                Return (Zero)
                            }
                            Case (0x02)
                            {
                                If (H8DR)
                                {
                                    ESLP = Zero
                                }
                                Else
                                {
                                    Local0 = RBEC (0xCF)
                                    Local0 &= 0xFFFFFFBF
                                    WBEC (0xCF, Local0)
                                }

                                Sleep (0x0A)
                                Return (Zero)
                            }
                            Case (0x03)
                            {
                                If (H8DR)
                                {
                                    ESLP = One
                                }
                                Else
                                {
                                    Local1 = RBEC (0xCF)
                                    Local1 |= 0x40
                                    WBEC (0xCF, Local1)
                                }

                                Return (Zero)
                            }
                            Default
                            {
                                Return (0xFF)
                            }

                        }
                    }

                    Device (HKEY)
                    {
                        Name (_HID, EisaId ("LEN0268"))  // _HID: Hardware ID
                        Method (_STA, 0, NotSerialized)  // _STA: Status
                        {
                            Return (0x0F)
                        }

                        Method (MHKV, 0, NotSerialized)
                        {
                            Return (0x0200)
                        }

                        Name (DHKC, Zero)
                        Name (DHKB, One)
                        Name (DHKH, Zero)
                        Name (DHKW, Zero)
                        Name (DHKS, Zero)
                        Name (DHKD, Zero)
                        Name (DHKN, 0x0808)
                        Name (DHKE, Zero)
                        Name (DHKF, 0x01FF0000)
                        Name (DHKT, Zero)
                        Name (DHWW, Zero)
                        Mutex (XDHK, 0x00)
                        Method (MHKA, 1, NotSerialized)
                        {
                            If ((Arg0 == Zero))
                            {
                                Return (0x03)
                            }
                            ElseIf ((Arg0 == One))
                            {
                                Return (0xFFFFFFFB)
                            }
                            ElseIf ((Arg0 == 0x02))
                            {
                                Return (Zero)
                            }
                            ElseIf ((Arg0 == 0x03))
                            {
                                Return (0x01FF0000)
                            }
                            Else
                            {
                                Return (Zero)
                            }
                        }

                        Method (MHKN, 1, NotSerialized)
                        {
                            If ((Arg0 == Zero))
                            {
                                Return (0x03)
                            }
                            ElseIf ((Arg0 == One))
                            {
                                Return (DHKN) /* \_SB_.PCI0.LPC0.EC0_.HKEY.DHKN */
                            }
                            ElseIf ((Arg0 == 0x02))
                            {
                                Return (DHKE) /* \_SB_.PCI0.LPC0.EC0_.HKEY.DHKE */
                            }
                            ElseIf ((Arg0 == 0x03))
                            {
                                Return (DHKF) /* \_SB_.PCI0.LPC0.EC0_.HKEY.DHKF */
                            }
                            Else
                            {
                                Return (Zero)
                            }
                        }

                        Method (MHKK, 2, NotSerialized)
                        {
                            If ((Arg0 == Zero))
                            {
                                Return (0x03)
                            }
                            ElseIf (DHKC)
                            {
                                If ((Arg0 == One))
                                {
                                    Return ((DHKN & Arg1))
                                }
                                ElseIf ((Arg0 == 0x02))
                                {
                                    Return ((DHKE & Arg1))
                                }
                                ElseIf ((Arg0 == 0x03))
                                {
                                    Return ((DHKF & Arg1))
                                }
                                Else
                                {
                                    Return (Zero)
                                }
                            }
                            Else
                            {
                                Return (Zero)
                            }
                        }

                        Method (MHKM, 2, NotSerialized)
                        {
                            Acquire (XDHK, 0xFFFF)
                            If ((Arg0 > 0x60))
                            {
                                Noop
                            }
                            ElseIf ((Arg0 <= 0x20))
                            {
                                Local0 = (One << Arg0--)
                                If ((Local0 & 0xFFFFFFFB))
                                {
                                    If (Arg1)
                                    {
                                        DHKN |= Local0
                                    }
                                    Else
                                    {
                                        DHKN &= (Local0 ^ Ones)
                                    }
                                }
                                Else
                                {
                                    Noop
                                }
                            }
                            ElseIf ((Arg0 <= 0x40))
                            {
                                Noop
                            }
                            ElseIf ((Arg0 <= 0x60))
                            {
                                Arg0 -= 0x40
                                Local0 = (One << Arg0--)
                                If ((Local0 & 0x01FF0000))
                                {
                                    If (Arg1)
                                    {
                                        DHKF |= Local0
                                    }
                                    Else
                                    {
                                        DHKF &= (Local0 ^ Ones)
                                    }
                                }
                                Else
                                {
                                    Noop
                                }
                            }

                            Release (XDHK)
                        }

                        Method (MHKS, 0, NotSerialized)
                        {
                            Notify (SLPB, 0x80) // Status Change
                        }

                        Method (MHKC, 1, NotSerialized)
                        {
                            DHKC = Arg0
                        }

                        Method (MHKP, 0, NotSerialized)
                        {
                            Acquire (XDHK, 0xFFFF)
                            If (DHWW)
                            {
                                Local1 = DHWW /* \_SB_.PCI0.LPC0.EC0_.HKEY.DHWW */
                                DHWW = Zero
                            }
                            ElseIf (DHKW)
                            {
                                Local1 = DHKW /* \_SB_.PCI0.LPC0.EC0_.HKEY.DHKW */
                                DHKW = Zero
                            }
                            ElseIf (DHKD)
                            {
                                Local1 = DHKD /* \_SB_.PCI0.LPC0.EC0_.HKEY.DHKD */
                                DHKD = Zero
                            }
                            ElseIf (DHKS)
                            {
                                Local1 = DHKS /* \_SB_.PCI0.LPC0.EC0_.HKEY.DHKS */
                                DHKS = Zero
                            }
                            ElseIf (DHKT)
                            {
                                Local1 = DHKT /* \_SB_.PCI0.LPC0.EC0_.HKEY.DHKT */
                                DHKT = Zero
                            }
                            Else
                            {
                                Local1 = DHKH /* \_SB_.PCI0.LPC0.EC0_.HKEY.DHKH */
                                DHKH = Zero
                            }

                            Release (XDHK)
                            Return (Local1)
                        }

                        Method (MHKE, 1, Serialized)
                        {
                            DHKB = Arg0
                            Acquire (XDHK, 0xFFFF)
                            DHKH = Zero
                            DHKW = Zero
                            DHKS = Zero
                            DHKD = Zero
                            DHKT = Zero
                            DHWW = Zero
                            Release (XDHK)
                        }

                        Method (MHKQ, 1, Serialized)
                        {
                            If (DHKB)
                            {
                                If (DHKC)
                                {
                                    Acquire (XDHK, 0xFFFF)
                                    If ((Arg0 < 0x1000)){}
                                    ElseIf ((Arg0 < 0x2000))
                                    {
                                        DHKH = Arg0
                                    }
                                    ElseIf ((Arg0 < 0x3000))
                                    {
                                        DHKW = Arg0
                                    }
                                    ElseIf ((Arg0 < 0x4000))
                                    {
                                        DHKS = Arg0
                                    }
                                    ElseIf ((Arg0 < 0x5000))
                                    {
                                        DHKD = Arg0
                                    }
                                    ElseIf ((Arg0 < 0x6000))
                                    {
                                        DHKH = Arg0
                                    }
                                    ElseIf ((Arg0 < 0x7000))
                                    {
                                        DHKT = Arg0
                                    }
                                    ElseIf ((Arg0 < 0x8000))
                                    {
                                        DHWW = Arg0
                                    }
                                    Else
                                    {
                                    }

                                    Release (XDHK)
                                    Notify (HKEY, 0x80) // Status Change
                                }
                                ElseIf ((Arg0 == 0x1004))
                                {
                                    Notify (SLPB, 0x80) // Status Change
                                }
                            }
                        }

                        Method (MHKB, 1, NotSerialized)
                        {
                            If ((Arg0 == Zero))
                            {
                                BEEP (0x11)
                                LIDB = Zero
                            }
                            ElseIf ((Arg0 == One))
                            {
                                BEEP (0x10)
                                LIDB = One
                            }
                            Else
                            {
                            }
                        }

                        Method (MHKD, 0, NotSerialized)
                        {
                            If ((PLUX == Zero)){}
                        }

                        Method (MHQC, 1, NotSerialized)
                        {
                            If (WNTF)
                            {
                                If ((Arg0 == Zero))
                                {
                                    Return (CWAC) /* \CWAC */
                                }
                                ElseIf ((Arg0 == One))
                                {
                                    Return (CWAP) /* \CWAP */
                                }
                                ElseIf ((Arg0 == 0x02))
                                {
                                    Return (CWAT) /* \CWAT */
                                }
                                Else
                                {
                                    Noop
                                }
                            }
                            Else
                            {
                                Noop
                            }

                            Return (Zero)
                        }

                        Method (MHGC, 0, NotSerialized)
                        {
                            If (WNTF)
                            {
                                Acquire (XDHK, 0xFFFF)
                                If (CKC4 (Zero))
                                {
                                    Local0 = 0x03
                                }
                                Else
                                {
                                    Local0 = 0x04
                                }

                                Release (XDHK)
                                Return (Local0)
                            }
                            Else
                            {
                                Noop
                            }

                            Return (Zero)
                        }

                        Method (MHSC, 1, NotSerialized)
                        {
                        }

                        Method (CKC4, 1, NotSerialized)
                        {
                            Local0 = Zero
                            If (C4WR)
                            {
                                If (!C4AC)
                                {
                                    Local0 |= One
                                }
                            }

                            If (C4NA)
                            {
                                Local0 |= 0x02
                            }

                            If ((CWAC && CWAS))
                            {
                                Local0 |= 0x04
                            }

                            Local0 &= ~Arg0
                            Return (Local0)
                        }

                        Method (MHQE, 0, NotSerialized)
                        {
                            Return (Zero)
                        }

                        Method (MHGE, 0, NotSerialized)
                        {
                            If ((C4WR && C4AC))
                            {
                                Return (0x04)
                            }

                            Return (0x03)
                        }

                        Method (MHSE, 1, NotSerialized)
                        {
                        }

                        Method (UAWO, 1, NotSerialized)
                        {
                            Return (UAWS (Arg0))
                        }

                        Method (MLCG, 1, NotSerialized)
                        {
                            Local0 = KBLS (Zero, Zero)
                            Return (Local0)
                        }

                        Method (MLCS, 1, NotSerialized)
                        {
                            Local0 = KBLS (One, Arg0)
                            If (!(Local0 & 0x80000000))
                            {
                                If ((Arg0 & 0x00010000))
                                {
                                    MHKQ (0x6001)
                                }
                                ElseIf (MHKK (One, 0x00020000))
                                {
                                    MHKQ (0x1012)
                                }
                            }

                            Return (Local0)
                        }

                        Method (DSSG, 1, NotSerialized)
                        {
                            Local0 = (0x0400 | PDCI) /* \PDCI */
                            Return (Local0)
                        }

                        Method (DSSS, 1, NotSerialized)
                        {
                            PDCI |= Arg0
                        }

                        Method (SBSG, 1, NotSerialized)
                        {
                            Return (SYBC (Zero, Zero))
                        }

                        Method (SBSS, 1, NotSerialized)
                        {
                            Return (SYBC (One, Arg0))
                        }

                        Method (PBLG, 1, NotSerialized)
                        {
                            Local0 = BRLV /* \BRLV */
                            Local1 = (Local0 | 0x0F00)
                            Return (Local1)
                        }

                        Method (PBLS, 1, NotSerialized)
                        {
                            BRLV = Arg0
                            If (VIGD){}
                            Else
                            {
                                VBRC (BRLV)
                            }

                            If (!NBCF)
                            {
                                MHKQ (0x6050)
                            }

                            Return (Zero)
                        }

                        Method (PMSG, 1, NotSerialized)
                        {
                            Local0 = PRSM (Zero, Zero)
                            Return (Local0)
                        }

                        Method (PMSS, 1, NotSerialized)
                        {
                            PRSM (One, Arg0)
                            Return (Zero)
                        }

                        Method (ISSG, 1, NotSerialized)
                        {
                            Local0 = ISSP /* \ISSP */
                            If (ISSP)
                            {
                                Local0 |= 0x01000000
                                Local0 |= (ISFS << 0x19)
                            }

                            Local0 |= (ISCG & 0x30)
                            Local0 &= 0xFFFFFFFE
                            Local0 |= 0x02
                            Local0 |= ((ISWK & 0x02) << 0x02)
                            Return (Local0)
                        }

                        Method (ISSS, 1, NotSerialized)
                        {
                            ISCG = Arg0
                            Return (Zero)
                        }

                        Method (FFSG, 1, NotSerialized)
                        {
                            Return (Zero)
                        }

                        Method (FFSS, 1, NotSerialized)
                        {
                            Return (0x80000000)
                        }

                        Method (GMKS, 0, NotSerialized)
                        {
                            Return (FNSC (0x02, Zero))
                        }

                        Method (SMKS, 1, NotSerialized)
                        {
                            Local0 = FNSC (0x03, (Arg0 & 0x00010001))
                            MHKQ (0x6060)
                            Return (Local0)
                        }

                        Method (GSKL, 1, NotSerialized)
                        {
                            Return (FNSC (0x04, (Arg0 & 0x0F000000)))
                        }

                        Method (SSKL, 1, NotSerialized)
                        {
                            Return (FNSC (0x05, (Arg0 & 0x0F00FFFF)))
                        }

                        Method (INSG, 1, NotSerialized)
                        {
                            Local0 = IOEN /* \IOEN */
                            Local0 |= (IOST << 0x07)
                            Local0 |= (IOCP << 0x08)
                            Local0 |= 0x10000000
                            Return (Local0)
                        }

                        Method (INSS, 1, NotSerialized)
                        {
                            If ((Arg0 & 0x10000000))
                            {
                                If (IOCP)
                                {
                                    Local0 = ((Arg0 & 0x80) >> 0x07)
                                    If (!EZRC (Local0))
                                    {
                                        IOST = Local0
                                    }
                                }

                                Return (Zero)
                            }

                            If ((IOCP && (Arg0 & One)))
                            {
                                IOEN = One
                            }
                            Else
                            {
                                IOEN = Zero
                                If (IOST)
                                {
                                    If (!ISOC (Zero))
                                    {
                                        IOST = Zero
                                    }
                                }
                            }

                            Return (Zero)
                        }
                    }

                    Device (AC)
                    {
                        Name (_HID, "ACPI0003" /* Power Source Device */)  // _HID: Hardware ID
                        Name (_UID, Zero)  // _UID: Unique ID
                        Name (_PCL, Package (0x01)  // _PCL: Power Consumer List
                        {
                            _SB
                        })
                        Name (XX00, Buffer (0x03)
                        {
                             0x03, 0x00, 0x00                                 // ...
                        })
                        CreateWordField (XX00, Zero, SSZE)
                        CreateByteField (XX00, 0x02, ACST)
                        Name (ACDC, 0xFF)
                        Method (_PSR, 0, NotSerialized)  // _PSR: Power Source
                        {
                            If (H8DR)
                            {
                                Local0 = HPAC /* \_SB_.PCI0.LPC0.EC0_.HPAC */
                            }
                            ElseIf ((RBEC (0x46) & 0x10))
                            {
                                Local0 = One
                            }
                            Else
                            {
                                Local0 = Zero
                            }

                            Local1 = Acquire (SMUM, 0x03E8)
                            If ((Local0 == Zero))
                            {
                                If (CondRefOf (\_SB.ALIB))
                                {
                                    If ((ACDC != Local0))
                                    {
                                        ACDC = Local0
                                        If ((ACDC == One))
                                        {
                                            ACST = Zero
                                            ^^^^GP17.VGA.AFN4 (One)
                                        }
                                        Else
                                        {
                                            ACST = One
                                            ^^^^GP17.VGA.AFN4 (0x02)
                                        }

                                        ALIB (One, XX00)
                                    }
                                }

                                Release (SMUM)
                            }

                            Return (Local0)
                        }

                        Method (_STA, 0, NotSerialized)  // _STA: Status
                        {
                            Return (0x0F)
                        }
                    }

                    Scope (HKEY)
                    {
                        Method (SMPS, 1, Serialized)
                        {
                            If (((Arg0 & 0xFFFF0000) != Zero))
                            {
                                Return (0x80000000)
                            }

                            Switch ((Arg0 & 0xFFFF))
                            {
                                Case (Zero)
                                {
                                    Local1 = 0x0100
                                }
                                Case (0x0100)
                                {
                                    Local1 = HWAT /* \_SB_.PCI0.LPC0.EC0_.HWAT */
                                    Local1 |= 0x002D0000
                                }
                                Default
                                {
                                    Local1 = 0x80000000
                                }

                            }

                            Return (Local1)
                        }
                    }

                    Method (_Q22, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
                    {
                        If (HB0A)
                        {
                            Notify (BAT0, 0x80) // Status Change
                        }
                    }

                    Method (_Q4A, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
                    {
                        Notify (BAT0, 0x81) // Information Change
                    }

                    Method (_Q4B, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
                    {
                        Notify (BAT0, 0x80) // Status Change
                        ^HKEY.DYTC (0x000F0001)
                    }

                    Method (_Q24, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
                    {
                        Notify (BAT0, 0x80) // Status Change
                    }

                    Method (BFCC, 0, NotSerialized)
                    {
                        If (^BAT0.B0ST)
                        {
                            Notify (BAT0, 0x81) // Information Change
                        }
                    }

                    Method (BATW, 1, NotSerialized)
                    {
                        If (BT2T){}
                    }

                    Field (ECOR, ByteAcc, NoLock, Preserve)
                    {
                        Offset (0xA0), 
                        SBRC,   16, 
                        SBFC,   16, 
                        SBAE,   16, 
                        SBRS,   16, 
                        SBAC,   16, 
                        SBVO,   16, 
                        SBAF,   16, 
                        SBBS,   16
                    }

                    Field (ECOR, ByteAcc, NoLock, Preserve)
                    {
                        Offset (0xA0), 
                        SBBM,   16, 
                        SBMD,   16, 
                        SBCC,   16
                    }

                    Field (ECOR, ByteAcc, NoLock, Preserve)
                    {
                        Offset (0xA0), 
                        SBDC,   16, 
                        SBDV,   16, 
                        SBOM,   16, 
                        SBSI,   16, 
                        SBDT,   16, 
                        SBSN,   16
                    }

                    Field (ECOR, ByteAcc, NoLock, Preserve)
                    {
                        Offset (0xA0), 
                        SBCH,   32
                    }

                    Field (ECOR, ByteAcc, NoLock, Preserve)
                    {
                        Offset (0xA0), 
                        SBMN,   128
                    }

                    Field (ECOR, ByteAcc, NoLock, Preserve)
                    {
                        Offset (0xA0), 
                        SBDN,   128
                    }

                    Mutex (BATM, 0x00)
                    Method (GBIF, 3, NotSerialized)
                    {
                        Acquire (BATM, 0xFFFF)
                        If (Arg2)
                        {
                            HIID = (Arg0 | One)
                            Local7 = SBBM /* \_SB_.PCI0.LPC0.EC0_.SBBM */
                            Local7 >>= 0x0F
                            Arg1 [Zero] = (Local7 ^ One)
                            HIID = Arg0
                            If (Local7)
                            {
                                Local1 = (SBFC * 0x0A)
                            }
                            Else
                            {
                                Local1 = SBFC /* \_SB_.PCI0.LPC0.EC0_.SBFC */
                            }

                            Arg1 [0x02] = Local1
                            HIID = (Arg0 | 0x02)
                            If (Local7)
                            {
                                Local0 = (SBDC * 0x0A)
                            }
                            Else
                            {
                                Local0 = SBDC /* \_SB_.PCI0.LPC0.EC0_.SBDC */
                            }

                            Arg1 [One] = Local0
                            Divide (Local1, 0x14, Local2, Arg1 [0x05])
                            If (Local7)
                            {
                                Arg1 [0x06] = 0xC8
                            }
                            ElseIf (SBDV)
                            {
                                Divide (0x00030D40, SBDV, Local2, Arg1 [0x06])
                            }
                            Else
                            {
                                Arg1 [0x06] = Zero
                            }

                            Arg1 [0x04] = SBDV /* \_SB_.PCI0.LPC0.EC0_.SBDV */
                            Local0 = SBSN /* \_SB_.PCI0.LPC0.EC0_.SBSN */
                            Name (SERN, Buffer (0x06)
                            {
                                "     "
                            })
                            Local2 = 0x04
                            While (Local0)
                            {
                                Divide (Local0, 0x0A, Local1, Local0)
                                SERN [Local2] = (Local1 + 0x30)
                                Local2--
                            }

                            Arg1 [0x0A] = SERN /* \_SB_.PCI0.LPC0.EC0_.GBIF.SERN */
                            HIID = (Arg0 | 0x06)
                            Arg1 [0x09] = SBDN /* \_SB_.PCI0.LPC0.EC0_.SBDN */
                            HIID = (Arg0 | 0x04)
                            Name (BTYP, Buffer (0x05)
                            {
                                 0x00, 0x00, 0x00, 0x00, 0x00                     // .....
                            })
                            BTYP = SBCH /* \_SB_.PCI0.LPC0.EC0_.SBCH */
                            Arg1 [0x0B] = BTYP /* \_SB_.PCI0.LPC0.EC0_.GBIF.BTYP */
                            HIID = (Arg0 | 0x05)
                            Arg1 [0x0C] = SBMN /* \_SB_.PCI0.LPC0.EC0_.SBMN */
                        }
                        Else
                        {
                            Arg1 [One] = Ones
                            Arg1 [0x05] = Zero
                            Arg1 [0x06] = Zero
                            Arg1 [0x02] = Ones
                        }

                        Release (BATM)
                        Return (Arg1)
                    }

                    Method (GBIX, 3, Serialized)
                    {
                        Acquire (BATM, 0xFFFF)
                        If (Arg2)
                        {
                            HIID = (Arg0 | One)
                            Local7 = SBCC /* \_SB_.PCI0.LPC0.EC0_.SBCC */
                            Arg1 [0x08] = Local7
                            Local7 = SBBM /* \_SB_.PCI0.LPC0.EC0_.SBBM */
                            Local7 >>= 0x0F
                            Arg1 [One] = (Local7 ^ One)
                            HIID = Arg0
                            If (Local7)
                            {
                                Local1 = (SBFC * 0x0A)
                            }
                            Else
                            {
                                Local1 = SBFC /* \_SB_.PCI0.LPC0.EC0_.SBFC */
                            }

                            Arg1 [0x03] = Local1
                            HIID = (Arg0 | 0x02)
                            If (Local7)
                            {
                                Local0 = (SBDC * 0x0A)
                            }
                            Else
                            {
                                Local0 = SBDC /* \_SB_.PCI0.LPC0.EC0_.SBDC */
                            }

                            Arg1 [0x02] = Local0
                            Divide (Local1, 0x14, Local2, Arg1 [0x06])
                            If (Local7)
                            {
                                Arg1 [0x07] = 0xC8
                            }
                            ElseIf (SBDV)
                            {
                                Divide (0x00030D40, SBDV, Local2, Arg1 [0x07])
                            }
                            Else
                            {
                                Arg1 [0x07] = Zero
                            }

                            Arg1 [0x05] = SBDV /* \_SB_.PCI0.LPC0.EC0_.SBDV */
                            Local0 = SBSN /* \_SB_.PCI0.LPC0.EC0_.SBSN */
                            Name (SERN, Buffer (0x06)
                            {
                                "     "
                            })
                            Local2 = 0x04
                            While (Local0)
                            {
                                Divide (Local0, 0x0A, Local1, Local0)
                                SERN [Local2] = (Local1 + 0x30)
                                Local2--
                            }

                            Arg1 [0x11] = SERN /* \_SB_.PCI0.LPC0.EC0_.GBIX.SERN */
                            HIID = (Arg0 | 0x06)
                            Arg1 [0x10] = SBDN /* \_SB_.PCI0.LPC0.EC0_.SBDN */
                            HIID = (Arg0 | 0x04)
                            Name (BTYP, Buffer (0x05)
                            {
                                 0x00, 0x00, 0x00, 0x00, 0x00                     // .....
                            })
                            BTYP = SBCH /* \_SB_.PCI0.LPC0.EC0_.SBCH */
                            Arg1 [0x12] = BTYP /* \_SB_.PCI0.LPC0.EC0_.GBIX.BTYP */
                            HIID = (Arg0 | 0x05)
                            Arg1 [0x13] = SBMN /* \_SB_.PCI0.LPC0.EC0_.SBMN */
                        }
                        Else
                        {
                            Arg1 [0x02] = Ones
                            Arg1 [0x06] = Zero
                            Arg1 [0x07] = Zero
                            Arg1 [0x03] = Ones
                        }

                        Release (BATM)
                        Return (Arg1)
                    }

                    Name (B0I0, Zero)
                    Name (B0I1, Zero)
                    Name (B0I2, Zero)
                    Name (B0I3, Zero)
                    Name (B1I0, Zero)
                    Name (B1I1, Zero)
                    Name (B1I2, Zero)
                    Name (B1I3, Zero)
                    Method (GBST, 4, Serialized)
                    {
                        Acquire (BATM, 0xFFFF)
                        If ((Arg1 & 0x20))
                        {
                            Local0 = 0x02
                        }
                        ElseIf ((Arg1 & 0x40))
                        {
                            Local0 = One
                        }
                        Else
                        {
                            Local0 = Zero
                        }

                        If ((Arg1 & 0x07)){}
                        Else
                        {
                            Local0 |= 0x04
                        }

                        If (((Arg1 & 0x07) == 0x07))
                        {
                            Local1 = Ones
                            Local2 = Ones
                            Local3 = Ones
                        }
                        Else
                        {
                            HIID = Arg0
                            Local3 = SBVO /* \_SB_.PCI0.LPC0.EC0_.SBVO */
                            If (Arg2)
                            {
                                Local2 = (SBRC * 0x0A)
                            }
                            Else
                            {
                                Local2 = SBRC /* \_SB_.PCI0.LPC0.EC0_.SBRC */
                            }

                            Local1 = SBAC /* \_SB_.PCI0.LPC0.EC0_.SBAC */
                            If ((Local1 >= 0x8000))
                            {
                                If ((Local0 & One))
                                {
                                    Local1 = (0x00010000 - Local1)
                                }
                                Else
                                {
                                    Local1 = Zero
                                }
                            }
                            ElseIf (!(Local0 & 0x02))
                            {
                                Local1 = Zero
                            }

                            If (Arg2)
                            {
                                Local1 *= Local3
                                Divide (Local1, 0x03E8, Local7, Local1)
                            }
                        }

                        Local5 = (One << (Arg0 >> 0x04))
                        BSWA |= BSWR /* \_SB_.PCI0.LPC0.EC0_.BSWR */
                        If (((BSWA & Local5) == Zero))
                        {
                            Arg3 [Zero] = Local0
                            Arg3 [One] = Local1
                            Arg3 [0x02] = Local2
                            Arg3 [0x03] = Local3
                            If ((Arg0 == Zero))
                            {
                                B0I0 = Local0
                                B0I1 = Local1
                                B0I2 = Local2
                                B0I3 = Local3
                            }
                            Else
                            {
                                B1I0 = Local0
                                B1I1 = Local1
                                B1I2 = Local2
                                B1I3 = Local3
                            }
                        }
                        Else
                        {
                            If (^AC._PSR ())
                            {
                                If ((Arg0 == Zero))
                                {
                                    Arg3 [Zero] = B0I0 /* \_SB_.PCI0.LPC0.EC0_.B0I0 */
                                    Arg3 [One] = B0I1 /* \_SB_.PCI0.LPC0.EC0_.B0I1 */
                                    Arg3 [0x02] = B0I2 /* \_SB_.PCI0.LPC0.EC0_.B0I2 */
                                    Arg3 [0x03] = B0I3 /* \_SB_.PCI0.LPC0.EC0_.B0I3 */
                                }
                                Else
                                {
                                    Arg3 [Zero] = B1I0 /* \_SB_.PCI0.LPC0.EC0_.B1I0 */
                                    Arg3 [One] = B1I1 /* \_SB_.PCI0.LPC0.EC0_.B1I1 */
                                    Arg3 [0x02] = B1I2 /* \_SB_.PCI0.LPC0.EC0_.B1I2 */
                                    Arg3 [0x03] = B1I3 /* \_SB_.PCI0.LPC0.EC0_.B1I3 */
                                }
                            }
                            Else
                            {
                                Arg3 [Zero] = Local0
                                Arg3 [One] = Local1
                                Arg3 [0x02] = Local2
                                Arg3 [0x03] = Local3
                            }

                            If ((((Local0 & 0x04) == Zero) && ((Local2 > Zero) && 
                                (Local3 > Zero))))
                            {
                                BSWA &= ~Local5
                                Arg3 [Zero] = Local0
                                Arg3 [One] = Local1
                                Arg3 [0x02] = Local2
                                Arg3 [0x03] = Local3
                            }
                        }

                        Release (BATM)
                        Return (Arg3)
                    }

                    Name (BSWR, Zero)
                    Name (BSWA, Zero)
                    Method (AJTP, 3, NotSerialized)
                    {
                        Local0 = Arg1
                        Acquire (BATM, 0xFFFF)
                        HIID = Arg0
                        Local1 = SBRC /* \_SB_.PCI0.LPC0.EC0_.SBRC */
                        Release (BATM)
                        If ((Arg0 == Zero))
                        {
                            Local2 = HB0S /* \_SB_.PCI0.LPC0.EC0_.HB0S */
                        }
                        Else
                        {
                            Local2 = HB1S /* \_SB_.PCI0.LPC0.EC0_.HB1S */
                        }

                        If ((Local2 & 0x20))
                        {
                            If ((Arg2 > Zero))
                            {
                                Local0 += One
                            }

                            If ((Local0 <= Local1))
                            {
                                Local0 = (Local1 + One)
                            }
                        }
                        ElseIf ((Local2 & 0x40))
                        {
                            If ((Local0 >= Local1))
                            {
                                Local0 = (Local1 - One)
                            }
                        }

                        Return (Local0)
                    }

                    Device (BAT0)
                    {
                        Name (_HID, EisaId ("PNP0C0A") /* Control Method Battery */)  // _HID: Hardware ID
                        Name (_UID, Zero)  // _UID: Unique ID
                        Name (_PCL, Package (0x01)  // _PCL: Power Consumer List
                        {
                            _SB
                        })
                        Name (B0ST, Zero)
                        Name (BT0I, Package (0x0D)
                        {
                            Zero, 
                            Ones, 
                            Ones, 
                            One, 
                            0x2A30, 
                            Zero, 
                            Zero, 
                            One, 
                            One, 
                            "", 
                            "", 
                            "", 
                            ""
                        })
                        Name (BX0I, Package (0x15)
                        {
                            One, 
                            Zero, 
                            Ones, 
                            Ones, 
                            One, 
                            Ones, 
                            Zero, 
                            Zero, 
                            Ones, 
                            0x00017318, 
                            Ones, 
                            Ones, 
                            0x03E8, 
                            0x01F4, 
                            Ones, 
                            Ones, 
                            "", 
                            "", 
                            "", 
                            "", 
                            Zero
                        })
                        Name (BT0P, Package (0x04){})
                        Method (_STA, 0, NotSerialized)  // _STA: Status
                        {
                            If (H8DR)
                            {
                                B0ST = HB0A /* \_SB_.PCI0.LPC0.EC0_.HB0A */
                            }
                            ElseIf ((RBEC (0x38) & 0x80))
                            {
                                B0ST = One
                            }
                            Else
                            {
                                B0ST = Zero
                            }

                            If (B0ST)
                            {
                                Return (0x1F)
                            }
                            Else
                            {
                                Return (0x0F)
                            }
                        }

                        Method (_BIF, 0, NotSerialized)  // _BIF: Battery Information
                        {
                            Local7 = Zero
                            Local6 = 0x0A
                            While ((!Local7 && Local6))
                            {
                                If (HB0A)
                                {
                                    If (((HB0S & 0x07) == 0x07))
                                    {
                                        Sleep (0x03E8)
                                        Local6--
                                    }
                                    Else
                                    {
                                        Local7 = One
                                    }
                                }
                                Else
                                {
                                    Local6 = Zero
                                }
                            }

                            GBIX (Zero, BX0I, Local7)
                            BT0I [Zero] = DerefOf (BX0I [One])
                            BT0I [One] = DerefOf (BX0I [0x02])
                            BT0I [0x02] = DerefOf (BX0I [0x03])
                            BT0I [0x03] = DerefOf (BX0I [0x04])
                            BT0I [0x04] = DerefOf (BX0I [0x05])
                            BT0I [0x05] = DerefOf (BX0I [0x06])
                            BT0I [0x06] = DerefOf (BX0I [0x07])
                            BT0I [0x07] = DerefOf (BX0I [0x0E])
                            BT0I [0x08] = DerefOf (BX0I [0x0F])
                            BT0I [0x09] = DerefOf (BX0I [0x10])
                            BT0I [0x0A] = DerefOf (BX0I [0x11])
                            BT0I [0x0B] = DerefOf (BX0I [0x12])
                            BT0I [0x0C] = DerefOf (BX0I [0x13])
                            Return (BT0I) /* \_SB_.PCI0.LPC0.EC0_.BAT0.BT0I */
                        }

                        Method (_BIX, 0, NotSerialized)  // _BIX: Battery Information Extended
                        {
                            Local7 = Zero
                            Local6 = 0x0A
                            While ((!Local7 && Local6))
                            {
                                If (HB0A)
                                {
                                    If (((HB0S & 0x07) == 0x07))
                                    {
                                        Sleep (0x03E8)
                                        Local6--
                                    }
                                    Else
                                    {
                                        Local7 = One
                                    }
                                }
                                Else
                                {
                                    Local6 = Zero
                                }
                            }

                            Return (GBIX (Zero, BX0I, Local7))
                        }

                        Method (_BST, 0, NotSerialized)  // _BST: Battery Status
                        {
                            Local0 = (DerefOf (BX0I [One]) ^ One)
                            GBST (Zero, HB0S, Local0, BT0P)
                            If (((HB0S & 0x07) == 0x07))
                            {
                                BT0P [One] = Ones
                                BT0P [0x02] = Ones
                                BT0P [0x03] = Ones
                            }

                            Return (BT0P) /* \_SB_.PCI0.LPC0.EC0_.BAT0.BT0P */
                        }

                        Method (_BTP, 1, NotSerialized)  // _BTP: Battery Trip Point
                        {
                            HAM4 &= 0xEF
                            If (Arg0)
                            {
                                Local0 = Zero
                                Local1 = Arg0
                                If (!DerefOf (BX0I [One]))
                                {
                                    Divide (Local1, 0x0A, Local0, Local1)
                                }

                                Local1 = AJTP (Zero, Local1, Local0)
                                HT0L = (Local1 & 0xFF)
                                HT0H = ((Local1 >> 0x08) & 0xFF)
                                HAM4 |= 0x10
                            }
                        }
                    }
                }
            }
        }
    }

    Scope (\)
    {
        Name (HPDT, Package (0x09)
        {
            "LEGACYHP", 
            0x80000000, 
            0x80000000, 
            "NATIVEHP", 
            0x80000000, 
            0x80000000, 
            "THERMALX", 
            0x80000000, 
            0x80000000
        })
        Name (DDB0, Zero)
        Name (DDB1, Zero)
        Name (DDB2, Zero)
    }

    Scope (_GPE)
    {
        Method (XL08, 0, NotSerialized)
        {
            TPST (0x3908)
            If ((TBEN == Zero)){}
            Notify (\_SB.PCI0.GP18, 0x02) // Device Wake
            Local0 = \_SB.PCI0.LPC0.EC0.HWAK
            RRBF = Local0
            If ((Local0 & One)){}
            If ((Local0 & 0x02)){}
            If ((Local0 & 0x04))
            {
                Notify (\_SB.LID, 0x02) // Device Wake
            }

            If ((Local0 & 0x08))
            {
                Notify (\_SB.SLPB, 0x02) // Device Wake
            }

            If ((Local0 & 0x10))
            {
                Notify (\_SB.SLPB, 0x02) // Device Wake
            }

            If ((Local0 & 0x80))
            {
                Notify (\_SB.SLPB, 0x02) // Device Wake
            }

            \_SB.PCI0.LPC0.EC0.HWAK = Zero
        }

        Method (_L0A, 0, NotSerialized)  // _Lxx: Level-Triggered GPE, xx=0x00-0xFF
        {
            TPST (0x390A)
            Notify (\_SB.PCI0.GP19, 0x02) // Device Wake
            Notify (\_SB.PCI0.GP19.XHC2, 0x02) // Device Wake
        }

        Method (XL19, 0, NotSerialized)
        {
            TPST (0x3919)
            Notify (\_SB.PCI0.GP17, 0x02) // Device Wake
            Notify (\_SB.PCI0.GP17.XHC0, 0x02) // Device Wake
            Notify (\_SB.PCI0.GP17.XHC1, 0x02) // Device Wake
        }

        Method (XL1A, 0, NotSerialized)
        {
            TPST (0x390A)
            Notify (\_SB.PCI0.GP19, 0x02) // Device Wake
            Notify (\_SB.PCI0.GP19.XHC2, 0x02) // Device Wake
        }
    }

    Name (TSOS, 0x75)
    Name (UR0I, 0x03)
    Name (UR1I, 0x04)
    Name (UR2I, 0x03)
    Name (UR3I, 0x04)
    Name (UR4I, 0x0F)
    Name (IC0I, 0x0A)
    Name (IC1I, 0x0B)
    Name (IC2I, 0x04)
    Name (IC3I, 0x06)
    Name (IC4I, 0x0E)
    If (CondRefOf (\_OSI))
    {
        If (_OSI ("Windows 2009"))
        {
            TSOS = 0x50
        }

        If (_OSI ("Windows 2015"))
        {
            TSOS = 0x70
        }
    }

    Scope (_SB)
    {
        OperationRegion (SMIC, SystemMemory, 0xFED80000, 0x00800000)
        Field (SMIC, ByteAcc, NoLock, Preserve)
        {
            Offset (0x36A), 
            SMIB,   8
        }

        OperationRegion (SSMI, SystemIO, SMIB, 0x02)
        Field (SSMI, AnyAcc, NoLock, Preserve)
        {
            SMIW,   16
        }

        OperationRegion (ECMC, SystemIO, 0x72, 0x02)
        Field (ECMC, AnyAcc, NoLock, Preserve)
        {
            ECMI,   8, 
            ECMD,   8
        }

        IndexField (ECMI, ECMD, ByteAcc, NoLock, Preserve)
        {
            Offset (0x08), 
            FRTB,   32
        }

        OperationRegion (FRTP, SystemMemory, FRTB, 0x0100)
        Field (FRTP, AnyAcc, NoLock, Preserve)
        {
            PEBA,   32, 
                ,   5, 
            IC0E,   1, 
            IC1E,   1, 
            IC2E,   1, 
            IC3E,   1, 
            IC4E,   1, 
            IC5E,   1, 
            UT0E,   1, 
            UT1E,   1, 
            I31E,   1, 
            I32E,   1, 
            I33E,   1, 
            UT2E,   1, 
                ,   1, 
            EMMD,   2, 
            UT4E,   1, 
            I30E,   1, 
                ,   1, 
            XHCE,   1, 
                ,   1, 
                ,   1, 
            UT3E,   1, 
            ESPI,   1, 
                ,   1, 
            HFPE,   1, 
            HD0E,   1, 
            HD2E,   1, 
            PCEF,   1, 
                ,   4, 
            IC0D,   1, 
            IC1D,   1, 
            IC2D,   1, 
            IC3D,   1, 
            IC4D,   1, 
            IC5D,   1, 
            UT0D,   1, 
            UT1D,   1, 
            I31D,   1, 
            I32D,   1, 
            I33D,   1, 
            UT2D,   1, 
                ,   1, 
            EHCD,   1, 
                ,   1, 
            UT4D,   1, 
            I30D,   1, 
                ,   1, 
            XHCD,   1, 
            SD_D,   1, 
                ,   1, 
            UT3D,   1, 
                ,   1, 
            STD3,   1, 
                ,   2, 
            S03D,   1, 
            Offset (0x1C), 
            I30M,   1, 
            I31M,   1, 
            I32M,   1, 
            I33M,   1
        }

        OperationRegion (FCFG, SystemMemory, PEBA, 0x01000000)
        Field (FCFG, DWordAcc, NoLock, Preserve)
        {
            Offset (0xA3078), 
                ,   2, 
            LDQ0,   1, 
            Offset (0xA30CB), 
                ,   7, 
            AUSS,   1
        }

        OperationRegion (IOMX, SystemMemory, 0xFED80D00, 0x0100)
        Field (IOMX, AnyAcc, NoLock, Preserve)
        {
            Offset (0x15), 
            IM15,   8, 
            IM16,   8, 
            Offset (0x1F), 
            IM1F,   8, 
            IM20,   8, 
            Offset (0x44), 
            IM44,   8, 
            Offset (0x46), 
            IM46,   8, 
            Offset (0x4A), 
            IM4A,   8, 
            IM4B,   8, 
            Offset (0x57), 
            IM57,   8, 
            IM58,   8, 
            Offset (0x68), 
            IM68,   8, 
            IM69,   8, 
            IM6A,   8, 
            IM6B,   8, 
            Offset (0x6D), 
            IM6D,   8
        }

        OperationRegion (FACR, SystemMemory, 0xFED81E00, 0x0100)
        Field (FACR, AnyAcc, NoLock, Preserve)
        {
            Offset (0x80), 
                ,   28, 
            RD28,   1, 
                ,   1, 
            RQTY,   1, 
            Offset (0x84), 
                ,   28, 
            SD28,   1, 
                ,   1, 
            Offset (0xA0), 
            PG1A,   1
        }

        OperationRegion (LUIE, SystemMemory, 0xFEDC0020, 0x04)
        Field (LUIE, AnyAcc, NoLock, Preserve)
        {
            IER0,   1, 
            IER1,   1, 
            IER2,   1, 
            IER3,   1, 
            UOL0,   1, 
            UOL1,   1, 
            UOL2,   1, 
            UOL3,   1, 
            WUR0,   2, 
            WUR1,   2, 
            WUR2,   2, 
            WUR3,   2
        }

        Method (FRUI, 2, Serialized)
        {
            If ((Arg0 == Zero))
            {
                Arg1 = IUA0 /* \_SB_.IUA0 */
            }

            If ((Arg0 == One))
            {
                Arg1 = IUA1 /* \_SB_.IUA1 */
            }

            If ((Arg0 == 0x02))
            {
                Arg1 = IUA2 /* \_SB_.IUA2 */
            }

            If ((Arg0 == 0x03))
            {
                Arg1 = IUA3 /* \_SB_.IUA3 */
            }
        }

        Method (FUIO, 1, Serialized)
        {
            If ((IER0 == One))
            {
                If ((WUR0 == Arg0))
                {
                    Return (Zero)
                }
            }

            If ((IER1 == One))
            {
                If ((WUR1 == Arg0))
                {
                    Return (One)
                }
            }

            If ((IER2 == One))
            {
                If ((WUR2 == Arg0))
                {
                    Return (0x02)
                }
            }

            If ((IER3 == One))
            {
                If ((WUR3 == Arg0))
                {
                    Return (0x03)
                }
            }

            Return (0x0F)
        }

        Method (SRAD, 2, Serialized)
        {
            Local0 = (Arg0 << One)
            Local0 += 0xFED81E40
            OperationRegion (ADCR, SystemMemory, Local0, 0x02)
            Field (ADCR, ByteAcc, NoLock, Preserve)
            {
                ADTD,   2, 
                ADPS,   1, 
                ADPD,   1, 
                ADSO,   1, 
                ADSC,   1, 
                ADSR,   1, 
                ADIS,   1, 
                ADDS,   3
            }

            ADIS = One
            ADSR = Zero
            Stall (Arg1)
            ADSR = One
            ADIS = Zero
            Stall (Arg1)
        }

        Method (DSAD, 2, Serialized)
        {
            Local0 = (Arg0 << One)
            Local0 += 0xFED81E40
            OperationRegion (ADCR, SystemMemory, Local0, 0x02)
            Field (ADCR, ByteAcc, NoLock, Preserve)
            {
                ADTD,   2, 
                ADPS,   1, 
                ADPD,   1, 
                ADSO,   1, 
                ADSC,   1, 
                ADSR,   1, 
                ADIS,   1, 
                ADDS,   3
            }

            If ((Arg1 != ADTD))
            {
                If ((Arg1 == Zero))
                {
                    ADTD = Zero
                    ADPD = One
                    Local0 = ADDS /* \_SB_.DSAD.ADDS */
                    While ((Local0 != 0x07))
                    {
                        Local0 = ADDS /* \_SB_.DSAD.ADDS */
                    }
                }

                If ((Arg1 == 0x03))
                {
                    ADPD = Zero
                    Local0 = ADDS /* \_SB_.DSAD.ADDS */
                    While ((Local0 != Zero))
                    {
                        Local0 = ADDS /* \_SB_.DSAD.ADDS */
                    }

                    ADTD = 0x03
                }
            }
        }

        Method (HSAD, 2, Serialized)
        {
            Local3 = (One << Arg0)
            Local0 = (Arg0 << One)
            Local0 += 0xFED81E40
            OperationRegion (ADCR, SystemMemory, Local0, 0x02)
            Field (ADCR, ByteAcc, NoLock, Preserve)
            {
                ADTD,   2, 
                ADPS,   1, 
                ADPD,   1, 
                ADSO,   1, 
                ADSC,   1, 
                ADSR,   1, 
                ADIS,   1, 
                ADDS,   3
            }

            If ((Arg1 != ADTD))
            {
                If ((Arg1 == Zero))
                {
                    PG1A = One
                    ADTD = Zero
                    ADPD = One
                    Local0 = ADDS /* \_SB_.HSAD.ADDS */
                    While ((Local0 != 0x07))
                    {
                        Local0 = ADDS /* \_SB_.HSAD.ADDS */
                    }

                    RQTY = One
                    RD28 = One
                    Local0 = SD28 /* \_SB_.SD28 */
                    While (!Local0)
                    {
                        Local0 = SD28 /* \_SB_.SD28 */
                    }
                }

                If ((Arg1 == 0x03))
                {
                    RQTY = Zero
                    RD28 = One
                    Local0 = SD28 /* \_SB_.SD28 */
                    While (Local0)
                    {
                        Local0 = SD28 /* \_SB_.SD28 */
                    }

                    ADPD = Zero
                    Local0 = ADDS /* \_SB_.HSAD.ADDS */
                    While ((Local0 != Zero))
                    {
                        Local0 = ADDS /* \_SB_.HSAD.ADDS */
                    }

                    ADTD = 0x03
                    PG1A = Zero
                }
            }
        }

        OperationRegion (FPIC, SystemIO, 0x0C00, 0x02)
        Field (FPIC, AnyAcc, NoLock, Preserve)
        {
            FPII,   8, 
            FPID,   8
        }

        IndexField (FPII, FPID, ByteAcc, NoLock, Preserve)
        {
            Offset (0xF4), 
            IUA0,   8, 
            IUA1,   8, 
            Offset (0xF8), 
            IUA2,   8, 
            IUA3,   8
        }

        Device (HFP1)
        {
            Name (_HID, "AMDI0060")  // _HID: Hardware ID
            Name (_UID, Zero)  // _UID: Unique ID
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If (HFPE)
                {
                    Return (0x0F)
                }
                Else
                {
                    Return (Zero)
                }
            }

            Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
            {
                Name (RBUF, ResourceTemplate ()
                {
                    Memory32Fixed (ReadWrite,
                        0xFEC11000,         // Address Base
                        0x00000100,         // Address Length
                        )
                })
                Return (RBUF) /* \_SB_.HFP1._CRS.RBUF */
            }
        }

        Device (HID0)
        {
            Name (_HID, "AMDI0063")  // _HID: Hardware ID
            Name (_UID, Zero)  // _UID: Unique ID
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If (HD0E)
                {
                    Return (0x0F)
                }
                Else
                {
                    Return (Zero)
                }
            }

            Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
            {
                Name (RBUF, ResourceTemplate ()
                {
                    Memory32Fixed (ReadWrite,
                        0xFEC13000,         // Address Base
                        0x00000200,         // Address Length
                        )
                    GpioInt (Edge, ActiveLow, SharedAndWake, PullNone, 0x0000,
                        "\\_SB.GPIO", 0x00, ResourceConsumer, ,
                        )
                        {   // Pin list
                            0x004E
                        }
                })
                Return (RBUF) /* \_SB_.HID0._CRS.RBUF */
            }
        }

        Device (HID2)
        {
            Name (_HID, "AMDI0063")  // _HID: Hardware ID
            Name (_UID, 0x02)  // _UID: Unique ID
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If (HD2E)
                {
                    Return (0x0F)
                }
                Else
                {
                    Return (Zero)
                }
            }

            Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
            {
                Name (RBUF, ResourceTemplate ()
                {
                    Memory32Fixed (ReadWrite,
                        0xFEC12000,         // Address Base
                        0x00000200,         // Address Length
                        )
                    GpioInt (Edge, ActiveLow, SharedAndWake, PullNone, 0x0000,
                        "\\_SB.GPIO", 0x00, ResourceConsumer, ,
                        )
                        {   // Pin list
                            0x004E
                        }
                })
                Return (RBUF) /* \_SB_.HID2._CRS.RBUF */
            }
        }

        Device (GPIO)
        {
            Name (_HID, "AMDI0030")  // _HID: Hardware ID
            Name (_CID, "AMDI0030")  // _CID: Compatible ID
            Name (_UID, Zero)  // _UID: Unique ID
            Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
            {
                Name (RBUF, ResourceTemplate ()
                {
                    Interrupt (ResourceConsumer, Level, ActiveLow, Shared, ,, )
                    {
                        0x00000007,
                    }
                    Memory32Fixed (ReadWrite,
                        0xFED81500,         // Address Base
                        0x00000400,         // Address Length
                        )
                })
                Return (RBUF) /* \_SB_.GPIO._CRS.RBUF */
            }

            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If ((TSOS >= 0x70))
                {
                    Return (0x0F)
                }
                Else
                {
                    Return (Zero)
                }
            }
        }

        Device (PPKG)
        {
            Name (_HID, "AMDI0052")  // _HID: Hardware ID
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                Return (0x0F)
            }
        }

        Method (MI2C, 3, Serialized)
        {
            Switch (ToInteger (Arg0))
            {
                Case (Zero)
                {
                    Name (IIC0, ResourceTemplate ()
                    {
                        I2cSerialBusV2 (0x0000, ControllerInitiated, 0x00061A80,
                            AddressingMode7Bit, "\\_SB.I2CA",
                            0x00, ResourceConsumer, _Y09, Exclusive,
                            )
                    })
                    CreateWordField (IIC0, \_SB.MI2C._Y09._ADR, DAD0)  // _ADR: Address
                    CreateDWordField (IIC0, \_SB.MI2C._Y09._SPE, DSP0)  // _SPE: Speed
                    DAD0 = Arg1
                    DSP0 = Arg2
                    Return (IIC0) /* \_SB_.MI2C.IIC0 */
                }
                Case (One)
                {
                    Name (IIC1, ResourceTemplate ()
                    {
                        I2cSerialBusV2 (0x0000, ControllerInitiated, 0x00061A80,
                            AddressingMode7Bit, "\\_SB.I2CB",
                            0x00, ResourceConsumer, _Y0A, Exclusive,
                            )
                    })
                    CreateWordField (IIC1, \_SB.MI2C._Y0A._ADR, DAD1)  // _ADR: Address
                    CreateDWordField (IIC1, \_SB.MI2C._Y0A._SPE, DSP1)  // _SPE: Speed
                    DAD1 = Arg1
                    DSP1 = Arg2
                    Return (IIC1) /* \_SB_.MI2C.IIC1 */
                }
                Case (0x02)
                {
                    Name (IIC2, ResourceTemplate ()
                    {
                        I2cSerialBusV2 (0x0000, ControllerInitiated, 0x00061A80,
                            AddressingMode7Bit, "\\_SB.I2CC",
                            0x00, ResourceConsumer, _Y0B, Exclusive,
                            )
                    })
                    CreateWordField (IIC2, \_SB.MI2C._Y0B._ADR, DAD2)  // _ADR: Address
                    CreateDWordField (IIC2, \_SB.MI2C._Y0B._SPE, DSP2)  // _SPE: Speed
                    DAD2 = Arg1
                    DSP2 = Arg2
                    Return (IIC2) /* \_SB_.MI2C.IIC2 */
                }
                Case (0x03)
                {
                    Name (IIC3, ResourceTemplate ()
                    {
                        I2cSerialBusV2 (0x0000, ControllerInitiated, 0x00061A80,
                            AddressingMode7Bit, "\\_SB.I2CD",
                            0x00, ResourceConsumer, _Y0C, Exclusive,
                            )
                    })
                    CreateWordField (IIC3, \_SB.MI2C._Y0C._ADR, DAD3)  // _ADR: Address
                    CreateDWordField (IIC3, \_SB.MI2C._Y0C._SPE, DSP3)  // _SPE: Speed
                    DAD3 = Arg1
                    DSP3 = Arg2
                    Return (IIC3) /* \_SB_.MI2C.IIC3 */
                }
                Default
                {
                    Return (Zero)
                }

            }
        }

        Device (I2CA)
        {
            Name (_HID, "AMDI0010")  // _HID: Hardware ID
            Name (_UID, Zero)  // _UID: Unique ID
            Method (_CRS, 0, Serialized)  // _CRS: Current Resource Settings
            {
                Name (BUF0, ResourceTemplate ()
                {
                    IRQ (Edge, ActiveHigh, Exclusive, )
                        {10}
                    Memory32Fixed (ReadWrite,
                        0xFEDC2000,         // Address Base
                        0x00001000,         // Address Length
                        )
                })
                CreateWordField (BUF0, One, IRQW)
                IRQW = (One << (IC0I & 0x0F))
                Return (BUF0) /* \_SB_.I2CA._CRS.BUF0 */
            }

            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If ((TSOS >= 0x70))
                {
                    If ((IC0E == One))
                    {
                        Return (0x0F)
                    }

                    Return (Zero)
                }
                Else
                {
                    Return (Zero)
                }
            }

            Method (_DSM, 4, Serialized)  // _DSM: Device-Specific Method
            {
                If ((Arg0 == ToUUID ("d93e4d1c-58bb-493c-a06a-605a717f9e2e") /* Unknown UUID */))
                {
                    Switch (ToInteger (Arg2))
                    {
                        Case (Zero)
                        {
                            Return (Buffer (One)
                            {
                                 0x03                                             // .
                            })
                        }
                        Case (One)
                        {
                            Return (Buffer (0x04)
                            {
                                 0xE5, 0x00, 0x6A, 0x00                           // ..j.
                            })
                        }

                    }
                }
                Else
                {
                    Return (Buffer (One)
                    {
                         0x00                                             // .
                    })
                }
            }

            Method (RSET, 0, NotSerialized)
            {
                SRAD (0x05, 0xC8)
            }

            Method (_S0W, 0, NotSerialized)  // _S0W: S0 Device Wake State
            {
                If ((IC0D && IC0E))
                {
                    Return (0x04)
                }
                Else
                {
                    Return (Zero)
                }
            }

            Method (_PS0, 0, NotSerialized)  // _PS0: Power State 0
            {
                If ((IC0D && IC0E))
                {
                    DSAD (0x05, Zero)
                }
            }

            Method (_PS3, 0, NotSerialized)  // _PS3: Power State 3
            {
                If ((IC0D && IC0E))
                {
                    DSAD (0x05, 0x03)
                }
            }
        }

        Device (I2CB)
        {
            Name (_HID, "AMDI0010")  // _HID: Hardware ID
            Name (_UID, One)  // _UID: Unique ID
            Method (_CRS, 0, Serialized)  // _CRS: Current Resource Settings
            {
                Name (BUF0, ResourceTemplate ()
                {
                    IRQ (Edge, ActiveHigh, Exclusive, )
                        {11}
                    Memory32Fixed (ReadWrite,
                        0xFEDC3000,         // Address Base
                        0x00001000,         // Address Length
                        )
                })
                CreateWordField (BUF0, One, IRQW)
                IRQW = (One << (IC1I & 0x0F))
                Return (BUF0) /* \_SB_.I2CB._CRS.BUF0 */
            }

            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If ((TSOS >= 0x70))
                {
                    If ((IC1E == One))
                    {
                        Return (0x0F)
                    }

                    Return (Zero)
                }
                Else
                {
                    Return (Zero)
                }
            }

            Method (_DSM, 4, Serialized)  // _DSM: Device-Specific Method
            {
                If ((Arg0 == ToUUID ("d93e4d1c-58bb-493c-a06a-605a717f9e2e") /* Unknown UUID */))
                {
                    Switch (ToInteger (Arg2))
                    {
                        Case (Zero)
                        {
                            Return (Buffer (One)
                            {
                                 0x03                                             // .
                            })
                        }
                        Case (One)
                        {
                            Return (Buffer (0x04)
                            {
                                 0xE5, 0x00, 0x6A, 0x00                           // ..j.
                            })
                        }

                    }
                }
                Else
                {
                    Return (Buffer (One)
                    {
                         0x00                                             // .
                    })
                }
            }

            Method (RSET, 0, NotSerialized)
            {
                SRAD (0x06, 0xC8)
            }

            Method (_S0W, 0, NotSerialized)  // _S0W: S0 Device Wake State
            {
                If ((IC1D && IC1E))
                {
                    Return (0x04)
                }
                Else
                {
                    Return (Zero)
                }
            }

            Method (_PS0, 0, NotSerialized)  // _PS0: Power State 0
            {
                If ((IC1D && IC1E))
                {
                    DSAD (0x06, Zero)
                }
            }

            Method (_PS3, 0, NotSerialized)  // _PS3: Power State 3
            {
                If ((IC1D && IC1E))
                {
                    DSAD (0x06, 0x03)
                }
            }
        }

        Device (I2CC)
        {
            Name (_HID, "AMDI0010")  // _HID: Hardware ID
            Name (_UID, 0x02)  // _UID: Unique ID
            Method (_CRS, 0, Serialized)  // _CRS: Current Resource Settings
            {
                Name (BUF0, ResourceTemplate ()
                {
                    IRQ (Edge, ActiveHigh, Exclusive, )
                        {4}
                    Memory32Fixed (ReadWrite,
                        0xFEDC4000,         // Address Base
                        0x00001000,         // Address Length
                        )
                })
                CreateWordField (BUF0, One, IRQW)
                IRQW = (One << (IC2I & 0x0F))
                Return (BUF0) /* \_SB_.I2CC._CRS.BUF0 */
            }

            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If ((TSOS >= 0x70))
                {
                    If ((IC2E == One))
                    {
                        Return (0x0F)
                    }

                    Return (Zero)
                }
                Else
                {
                    Return (Zero)
                }
            }

            Method (_DSM, 4, Serialized)  // _DSM: Device-Specific Method
            {
                If ((Arg0 == ToUUID ("d93e4d1c-58bb-493c-a06a-605a717f9e2e") /* Unknown UUID */))
                {
                    Switch (ToInteger (Arg2))
                    {
                        Case (Zero)
                        {
                            Return (Buffer (One)
                            {
                                 0x03                                             // .
                            })
                        }
                        Case (One)
                        {
                            Return (Buffer (0x04)
                            {
                                 0xE5, 0x00, 0x6A, 0x00                           // ..j.
                            })
                        }

                    }
                }
                Else
                {
                    Return (Buffer (One)
                    {
                         0x00                                             // .
                    })
                }
            }

            Method (RSET, 0, NotSerialized)
            {
                SRAD (0x07, 0xC8)
            }

            Method (_S0W, 0, NotSerialized)  // _S0W: S0 Device Wake State
            {
                If ((IC2D && IC2E))
                {
                    Return (0x04)
                }
                Else
                {
                    Return (Zero)
                }
            }

            Method (_PS0, 0, NotSerialized)  // _PS0: Power State 0
            {
                If ((IC2D && IC2E))
                {
                    DSAD (0x07, Zero)
                }
            }

            Method (_PS3, 0, NotSerialized)  // _PS3: Power State 3
            {
                If ((IC2D && IC2E))
                {
                    DSAD (0x07, 0x03)
                }
            }
        }
    }

    Scope (_SB.I2CC)
    {
        Device (NFC1)
        {
            Name (_HID, EisaId ("NXP8013"))  // _HID: Hardware ID
            Name (_UID, 0x03)  // _UID: Unique ID
            Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
            {
                Name (RBUF, ResourceTemplate ()
                {
                    I2cSerialBusV2 (0x0029, ControllerInitiated, 0x00061A80,
                        AddressingMode7Bit, "\\_SB.I2CC",
                        0x00, ResourceConsumer, , Exclusive,
                        )
                    GpioInt (Level, ActiveLow, ExclusiveAndWake, PullNone, 0x0000,
                        "\\_SB.GPIO", 0x00, ResourceConsumer, ,
                        )
                        {   // Pin list
                            0x005B
                        }
                    GpioIo (Exclusive, PullNone, 0x0000, 0x0000, IoRestrictionOutputOnly,
                        "\\_SB.GPIO", 0x00, ResourceConsumer, ,
                        )
                        {   // Pin list
                            0x0099
                        }
                    GpioIo (Exclusive, PullNone, 0x0000, 0x0000, IoRestrictionOutputOnly,
                        "\\_SB.GPIO", 0x00, ResourceConsumer, ,
                        )
                        {   // Pin list
                            0x009A
                        }
                })
                Return (RBUF) /* \_SB_.I2CC.NFC1._CRS.RBUF */
            }

            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                Return (Zero)
            }
        }
    }

    OperationRegion (MNVS, SystemMemory, 0xBAC25018, 0x1000)
    Field (MNVS, DWordAcc, NoLock, Preserve)
    {
        Offset (0xD00), 
        GAPA,   32, 
        GAPL,   32, 
        DCKI,   32, 
        DCKS,   32, 
        VCDL,   1, 
        VCDC,   1, 
        VCDT,   1, 
        VCDD,   1, 
            ,   1, 
        VCSS,   1, 
        VCDB,   1, 
        VCIN,   1, 
        VVPO,   8, 
        BNTN,   8, 
        BRLV,   8, 
        CDFL,   8, 
        CDAH,   8, 
        PMOD,   2, 
        PDIR,   1, 
        PDMA,   1, 
        Offset (0xD17), 
        LFDC,   1, 
        Offset (0xD18), 
        C2NA,   1, 
        C3NA,   1, 
        C4NA,   1, 
        C6NA,   1, 
        C7NA,   1, 
        Offset (0xD19), 
        Offset (0xD1A), 
            ,   2, 
            ,   1, 
        NHPS,   1, 
        NPMS,   1, 
        Offset (0xD1B), 
        UOPT,   8, 
        BTID,   32, 
        DPP0,   1, 
        DPP1,   1, 
        DPP2,   1, 
        DPP3,   1, 
        DPP4,   1, 
        DPP5,   1, 
        Offset (0xD21), 
        Offset (0xD22), 
        TCRT,   16, 
        TPSV,   16, 
        TTC1,   16, 
        TTC2,   16, 
        TTSP,   16, 
        SRAH,   8, 
        SRHE,   8, 
        SRE1,   8, 
        SRE2,   8, 
        SRE3,   8, 
        SRE4,   8, 
        SRE5,   8, 
        SRE6,   8, 
        SRU1,   8, 
        SRU2,   8, 
        SRU3,   8, 
        SRU7,   8, 
        SRU4,   8, 
        SRU5,   8, 
        SRU8,   8, 
        SRPB,   8, 
        SRLP,   8, 
        SRSA,   8, 
        SRSM,   8, 
        CWAC,   1, 
        CWAS,   1, 
        CWUE,   1, 
        CWUS,   1, 
        Offset (0xD40), 
        CWAP,   16, 
        CWAT,   16, 
        DBGC,   1, 
        Offset (0xD45), 
        FS1L,   16, 
        FS1M,   16, 
        FS1H,   16, 
        FS2L,   16, 
        FS2M,   16, 
        FS2H,   16, 
        FS3L,   16, 
        FS3M,   16, 
        FS3H,   16, 
        TATC,   1, 
            ,   6, 
        TATL,   1, 
        TATW,   8, 
        TNFT,   4, 
        TNTT,   4, 
        TDFA,   4, 
        TDTA,   4, 
        TDFD,   4, 
        TDTD,   4, 
        TCFA,   4, 
        TCTA,   4, 
        TCFD,   4, 
        TCTD,   4, 
        TSFT,   4, 
        TSTT,   4, 
        TIT0,   8, 
        TCR0,   16, 
        TPS0,   16, 
        TIT1,   8, 
        TCR1,   16, 
        TPS1,   16, 
        TIT2,   8, 
        TCR2,   16, 
        TPS2,   16, 
        TIF0,   8, 
        TIF1,   8, 
        TIF2,   8, 
        Offset (0xD78), 
        BTHI,   1, 
        Offset (0xD79), 
        HDIR,   1, 
        HDEH,   1, 
        HDSP,   1, 
        HDPP,   1, 
        HDUB,   1, 
        HDMC,   1, 
        NFCF,   1, 
        NOMC,   1, 
        TPME,   8, 
        BIDE,   4, 
        IDET,   4, 
            ,   1, 
            ,   1, 
        Offset (0xD7D), 
        DTS0,   8, 
        Offset (0xD7F), 
        DT00,   1, 
        DT01,   1, 
        DT02,   1, 
        DT03,   1, 
        Offset (0xD80), 
        LIDB,   1, 
        C4WR,   1, 
        C4AC,   1, 
        ODDX,   1, 
        CMPR,   1, 
        ILNF,   1, 
        PLUX,   1, 
        Offset (0xD81), 
        Offset (0xD8A), 
        WLAC,   8, 
        WIWK,   1, 
        Offset (0xD8C), 
            ,   4, 
            ,   1, 
        IDMM,   1, 
        Offset (0xD8D), 
            ,   3, 
            ,   1, 
            ,   1, 
            ,   1, 
        Offset (0xD8E), 
        Offset (0xD8F), 
            ,   4, 
        Offset (0xD90), 
        Offset (0xD91), 
        SWGP,   8, 
        IPMS,   8, 
        IPMB,   120, 
        IPMR,   24, 
        IPMO,   24, 
        IPMA,   8, 
        VIGD,   1, 
        VDSC,   1, 
        VMSH,   1, 
            ,   1, 
        VDSP,   1, 
        Offset (0xDAA), 
        Offset (0xDAD), 
        ASFT,   8, 
        PL1L,   8, 
        PL1M,   8, 
        CHKC,   32, 
        CHKE,   32, 
        ATRB,   32, 
        Offset (0xDBD), 
        PPCR,   8, 
        TPCR,   5, 
        Offset (0xDBF), 
        Offset (0xDCE), 
        CTPR,   8, 
        PPCA,   8, 
        TPCA,   5, 
        Offset (0xDD1), 
        BFWB,   296, 
        OSPX,   1, 
        OSC4,   1, 
        CPPX,   1, 
        Offset (0xDF7), 
        SPEN,   1, 
        SCRM,   1, 
            ,   1, 
        ETAU,   1, 
        IHBC,   1, 
        ARPM,   1, 
        APMF,   1, 
        Offset (0xDF8), 
        FTPS,   8, 
        HIST,   8, 
        LPST,   8, 
        LWST,   8, 
        Offset (0xDFF), 
        Offset (0xE00), 
        Offset (0xE20), 
        HPET,   32, 
        PKLI,   16, 
        VLCX,   16, 
        VNIT,   8, 
        VBD0,   8, 
        VBDT,   128, 
        VBPL,   16, 
        VBPH,   16, 
        VBML,   8, 
        VBMH,   8, 
        VEDI,   1024, 
        PDCI,   16, 
        ISCG,   32, 
        ISSP,   1, 
        ISWK,   2, 
        ISFS,   3, 
        Offset (0xEC7), 
        SHA1,   160, 
        Offset (0xEDC), 
        LWCP,   1, 
        LWEN,   1, 
        IOCP,   1, 
        IOEN,   1, 
        IOST,   1, 
        Offset (0xEDD), 
        USBR,   1, 
        Offset (0xEDE), 
        Offset (0xEDF), 
        Offset (0xEE1), 
        BT2T,   1, 
        Offset (0xEE2), 
        TPPP,   8, 
        TPPC,   8, 
        CTPC,   8, 
        FNWK,   8, 
        Offset (0xEE7), 
        XHCC,   8, 
        FCAP,   16, 
        VSTD,   1, 
        VCQL,   1, 
        VTIO,   1, 
        VMYH,   1, 
        VSTP,   1, 
        VCQH,   1, 
        VDCC,   1, 
        VSFN,   1, 
        VDMC,   1, 
        VFHP,   1, 
        VIFC,   1, 
        VMMC,   1, 
        VMSC,   1, 
        VPSC,   1, 
        VCSC,   1, 
        Offset (0xEEC), 
        CICF,   4, 
        CICM,   4, 
        MYHC,   8, 
        MMCC,   8, 
        PT1D,   15, 
        Offset (0xEF1), 
        PT2D,   15, 
        Offset (0xEF3), 
        PT0D,   15, 
        Offset (0xEF5), 
        DVS0,   1, 
        DVS1,   1, 
        DVS2,   1, 
        DVS3,   1, 
        Offset (0xEF7), 
        DSTD,   15, 
        Offset (0xEF9), 
        DCQL,   15, 
        Offset (0xEFB), 
        DTIO,   15, 
        Offset (0xEFD), 
        DMYH,   15, 
        Offset (0xEFF), 
        DPST,   15, 
        Offset (0xF01), 
        DCQH,   15, 
        Offset (0xF03), 
        DDCC,   15, 
        Offset (0xF05), 
        DSFN,   15, 
        Offset (0xF07), 
        DDMC,   15, 
        Offset (0xF09), 
        DFHP,   15, 
        Offset (0xF0B), 
        DIFC,   15, 
        Offset (0xF0D), 
        DMMC,   15, 
        Offset (0xF0F), 
        DMSC,   15, 
        Offset (0xF11), 
        DPSC,   15, 
        Offset (0xF13), 
        ECSC,   15, 
        Offset (0xF15), 
        SMYH,   4, 
        SMMC,   4, 
        SPSC,   4, 
        Offset (0xF17), 
        STDV,   8, 
        SCRB,   8, 
        PMOF,   8, 
        MPID,   8, 
        VEDX,   1024, 
        SHDW,   8, 
        TPID,   16, 
        TPAD,   8, 
        TDVI,   16, 
        TDPI,   16, 
        TLVI,   16, 
        TLPI,   16, 
        DYPR,   32
    }

    Field (MNVS, ByteAcc, NoLock, Preserve)
    {
        Offset (0xB00), 
        WITM,   8, 
        WSEL,   8, 
        WLS0,   8, 
        WLS1,   8, 
        WLS2,   8, 
        WLS3,   8, 
        WLS4,   8, 
        WLS5,   8, 
        WLS6,   8, 
        WLS7,   8, 
        WLS8,   8, 
        WLS9,   8, 
        WLSA,   8, 
        WLSB,   8, 
        WLSC,   8, 
        WLSD,   8, 
        WENC,   8, 
        WKBD,   8, 
        WPTY,   8, 
        WPAS,   1032, 
        WPNW,   1032, 
        WSPM,   8, 
        WSPS,   8, 
        WSMN,   8, 
        WSMX,   8, 
        WSEN,   8, 
        WSKB,   8, 
        WASB,   8, 
        WASI,   16, 
        WASD,   8, 
        WASS,   32, 
        WDRV,   8, 
        WMTH,   8, 
        RTC0,   8, 
        RTC1,   8, 
        RTC2,   8, 
        WSHS,   8
    }

    Field (MNVS, ByteAcc, NoLock, Preserve)
    {
        Offset (0xA00), 
        DBGB,   1024
    }

    Scope (\)
    {
        OperationRegion (LFCN, SystemMemory, 0xBAD78698, 0x14)
        Field (LFCN, AnyAcc, Lock, Preserve)
        {
            BDID,   8, 
            BDTP,   8, 
            MCSZ,   8, 
            KBID,   8, 
            LWSR,   8, 
            LSID,   8, 
            TPVD,   16, 
            TPPD,   16, 
            PNVD,   16, 
            PNPD,   16, 
            TPSD,   16, 
            WWVD,   16, 
            WWPD,   16
        }
    }

    OperationRegion (CNVS, SystemMemory, 0xBAC2F018, 0x1000)
    Field (CNVS, ByteAcc, NoLock, Preserve)
    {
        SCSB,   32768
    }

    Field (CNVS, ByteAcc, NoLock, Preserve)
    {
        SNMA,   32
    }

    Field (CNVS, ByteAcc, NoLock, Preserve)
    {
        SSMB,   24768, 
        SSPL,   16, 
        SSPB,   2048
    }

    Field (CNVS, ByteAcc, NoLock, Preserve)
    {
        SGMB,   128, 
        SGPL,   16, 
        SGPB,   2048
    }

    Field (CNVS, ByteAcc, NoLock, Preserve)
    {
        SGSB,   24608
    }

    Field (CNVS, ByteAcc, NoLock, Preserve)
    {
        SEDL,   768, 
        SENS,   32
    }

    Name (SPS, Zero)
    Name (OSIF, Zero)
    Name (WNTF, Zero)
    Name (WXPF, Zero)
    Name (WVIS, Zero)
    Name (WIN7, Zero)
    Name (WIN8, Zero)
    Name (WSPV, Zero)
    Name (LNUX, Zero)
    Name (H8DR, Zero)
    Name (MEMX, Zero)
    Name (ACST, Zero)
    Name (FMBL, One)
    Name (FDTP, 0x02)
    Name (FUPS, 0x03)
    Name (FNID, Zero)
    Name (RRBF, Zero)
    Name (NBCF, Zero)
    OperationRegion (SMI0, SystemIO, 0xB0, 0x02)
    Field (SMI0, ByteAcc, NoLock, Preserve)
    {
        APMC,   8, 
        APMD,   8
    }

    Field (MNVS, AnyAcc, NoLock, Preserve)
    {
        Offset (0xFC0), 
        CMD,    8, 
        ERR,    32, 
        PAR0,   32, 
        PAR1,   32, 
        PAR2,   32, 
        PAR3,   32
    }

    Mutex (MSMI, 0x00)
    Method (SMI, 5, Serialized)
    {
        Acquire (MSMI, 0xFFFF)
        CMD = Arg0
        ERR = One
        PAR0 = Arg1
        PAR1 = Arg2
        PAR2 = Arg3
        PAR3 = Arg4
        APMC = 0xF5
        While ((ERR == One))
        {
            Sleep (One)
            APMC = 0xF5
        }

        Local0 = PAR0 /* \PAR0 */
        Release (MSMI)
        Return (Local0)
    }

    Method (RPCI, 1, NotSerialized)
    {
        Return (SMI (Zero, Zero, Arg0, Zero, Zero))
    }

    Method (WPCI, 2, NotSerialized)
    {
        SMI (Zero, One, Arg0, Arg1, Zero)
    }

    Method (MPCI, 3, NotSerialized)
    {
        SMI (Zero, 0x02, Arg0, Arg1, Arg2)
    }

    Method (RBEC, 1, NotSerialized)
    {
        Return (SMI (Zero, 0x03, Arg0, Zero, Zero))
    }

    Method (WBEC, 2, NotSerialized)
    {
        SMI (Zero, 0x04, Arg0, Arg1, Zero)
    }

    Method (MBEC, 3, NotSerialized)
    {
        SMI (Zero, 0x05, Arg0, Arg1, Arg2)
    }

    Method (RISA, 1, NotSerialized)
    {
        Return (SMI (Zero, 0x06, Arg0, Zero, Zero))
    }

    Method (WISA, 2, NotSerialized)
    {
        SMI (Zero, 0x07, Arg0, Arg1, Zero)
    }

    Method (MISA, 3, NotSerialized)
    {
        SMI (Zero, 0x08, Arg0, Arg1, Arg2)
    }

    Method (VEXP, 0, NotSerialized)
    {
        SMI (One, Zero, Zero, Zero, Zero)
    }

    Method (VUPS, 1, NotSerialized)
    {
        SMI (One, One, Arg0, Zero, Zero)
    }

    Method (VSDS, 2, NotSerialized)
    {
        SMI (One, 0x02, Arg0, Arg1, Zero)
    }

    Method (VDDC, 0, NotSerialized)
    {
        SMI (One, 0x03, Zero, Zero, Zero)
    }

    Method (VVPD, 1, NotSerialized)
    {
        SMI (One, 0x04, Arg0, Zero, Zero)
    }

    Method (VNRS, 1, NotSerialized)
    {
        SMI (One, 0x05, Arg0, Zero, Zero)
    }

    Method (GLPW, 0, NotSerialized)
    {
        Return (SMI (One, 0x06, Zero, Zero, Zero))
    }

    Method (VSLD, 1, NotSerialized)
    {
        SMI (One, 0x07, Arg0, Zero, Zero)
    }

    Method (VEVT, 1, NotSerialized)
    {
        Return (SMI (One, 0x08, Arg0, Zero, Zero))
    }

    Method (VTHR, 0, NotSerialized)
    {
        Return (SMI (One, 0x09, Zero, Zero, Zero))
    }

    Method (VBRC, 1, NotSerialized)
    {
        SMI (One, 0x0A, Arg0, Zero, Zero)
    }

    Method (VBRG, 0, NotSerialized)
    {
        Return (SMI (One, 0x0E, Zero, Zero, Zero))
    }

    Method (VCMS, 2, NotSerialized)
    {
        Return (SMI (One, 0x0B, Arg0, Arg1, Zero))
    }

    Method (VBTD, 0, NotSerialized)
    {
        Return (SMI (One, 0x0F, Zero, Zero, Zero))
    }

    Method (VDYN, 2, NotSerialized)
    {
        Return (SMI (One, 0x11, Arg0, Arg1, Zero))
    }

    Method (SDPS, 2, NotSerialized)
    {
        Return (SMI (One, 0x12, Arg0, Arg1, Zero))
    }

    Method (SCMS, 1, NotSerialized)
    {
        Return (SMI (0x02, Arg0, Zero, Zero, Zero))
    }

    Method (BHDP, 2, NotSerialized)
    {
        Return (SMI (0x03, Zero, Arg0, Arg1, Zero))
    }

    Method (STEP, 1, NotSerialized)
    {
        SMI (0x04, Arg0, Zero, Zero, Zero)
    }

    Method (SLTP, 0, NotSerialized)
    {
        SMI (0x05, Zero, Zero, Zero, Zero)
    }

    Method (CBRI, 0, NotSerialized)
    {
        SMI (0x05, One, Zero, Zero, Zero)
    }

    Method (BCHK, 0, NotSerialized)
    {
        Return (SMI (0x05, 0x04, Zero, Zero, Zero))
    }

    Method (BYRS, 0, NotSerialized)
    {
        SMI (0x05, 0x05, Zero, Zero, Zero)
    }

    Method (LCHK, 1, NotSerialized)
    {
        Return (SMI (0x05, 0x06, Arg0, Zero, Zero))
    }

    Method (BLTH, 1, NotSerialized)
    {
        Return (SMI (0x06, Arg0, Zero, Zero, Zero))
    }

    Method (PRSM, 2, NotSerialized)
    {
        Return (SMI (0x07, Zero, Arg0, Arg1, Zero))
    }

    Method (ISOC, 1, NotSerialized)
    {
        Return (SMI (0x07, 0x03, Arg0, Zero, Zero))
    }

    Method (EZRC, 1, NotSerialized)
    {
        Return (SMI (0x07, 0x04, Arg0, Zero, Zero))
    }

    Method (WGSV, 1, NotSerialized)
    {
        Return (SMI (0x09, Arg0, Zero, Zero, Zero))
    }

    Method (TSDL, 0, NotSerialized)
    {
        Return (SMI (0x0A, 0x03, Zero, Zero, Zero))
    }

    Method (FLPF, 1, NotSerialized)
    {
        Return (SMI (0x0A, 0x04, Arg0, Zero, Zero))
    }

    Method (CSUM, 1, NotSerialized)
    {
        Return (SMI (0x0E, Arg0, Zero, Zero, Zero))
    }

    Method (NVSS, 1, NotSerialized)
    {
        Return (SMI (0x0F, Arg0, Zero, Zero, Zero))
    }

    Method (WMIS, 2, NotSerialized)
    {
        Return (SMI (0x10, Arg0, Arg1, Zero, Zero))
    }

    Method (AWON, 1, NotSerialized)
    {
        Return (SMI (0x12, Arg0, Zero, Zero, Zero))
    }

    Method (PMON, 2, NotSerialized)
    {
        Local0 = SizeOf (Arg0)
        Name (TSTR, Buffer (Local0){})
        TSTR = Arg0
        DBGB = TSTR /* \PMON.TSTR */
        SMI (0x11, Arg1, Zero, Zero, Zero)
    }

    Method (UAWS, 1, NotSerialized)
    {
        Return (SMI (0x13, Arg0, Zero, Zero, Zero))
    }

    Method (BFWC, 1, NotSerialized)
    {
        Return (SMI (0x14, Zero, Arg0, Zero, Zero))
    }

    Method (BFWP, 0, NotSerialized)
    {
        Return (SMI (0x14, One, Zero, Zero, Zero))
    }

    Method (BFWL, 0, NotSerialized)
    {
        SMI (0x14, 0x02, Zero, Zero, Zero)
    }

    Method (BFWG, 1, NotSerialized)
    {
        SMI (0x14, 0x03, Arg0, Zero, Zero)
    }

    Method (BDMC, 1, NotSerialized)
    {
        SMI (0x14, 0x04, Arg0, Zero, Zero)
    }

    Method (PSIF, 2, NotSerialized)
    {
        Return (SMI (0x14, 0x05, Arg0, Arg1, Zero))
    }

    Method (FNSC, 2, NotSerialized)
    {
        Return (SMI (0x14, 0x06, Arg0, Arg1, Zero))
    }

    Method (AUDC, 2, NotSerialized)
    {
        Return (SMI (0x14, 0x07, Arg0, Arg1, Zero))
    }

    Method (SYBC, 2, NotSerialized)
    {
        Return (SMI (0x14, 0x08, Arg0, Arg1, Zero))
    }

    Method (KBLS, 2, NotSerialized)
    {
        Return (SMI (0x14, 0x09, Arg0, Arg1, Zero))
    }

    Method (FPCI, 2, NotSerialized)
    {
        Return (SMI (0x14, 0x0A, Arg0, Arg1, Zero))
    }

    Method (UBIS, 1, NotSerialized)
    {
        Return (SMI (0x15, Zero, Arg0, Zero, Zero))
    }

    Method (DIEH, 1, NotSerialized)
    {
        Return (SMI (0x16, Zero, Arg0, Zero, Zero))
    }

    Method (OUTP, 2, NotSerialized)
    {
        SMI (0x17, Arg0, Arg1, Zero, Zero)
    }

    Method (SREQ, 3, NotSerialized)
    {
        SMI (0x18, (Arg0 & 0xFF), (Arg1 & 0xFF), (Arg2 & 
            0xFF), Zero)
    }

    Method (SPMS, 1, NotSerialized)
    {
        SMI (0x19, (Arg0 & 0xFF), Zero, Zero, Zero)
    }

    Method (LVSS, 2, NotSerialized)
    {
        Return (SMI (0x1A, (Arg0 & 0xFF), Arg1, Zero, Zero))
    }

    Method (SCMP, 2, NotSerialized)
    {
        Local0 = SizeOf (Arg0)
        If ((Local0 != SizeOf (Arg1)))
        {
            Return (One)
        }

        Local0++
        Name (STR1, Buffer (Local0){})
        Name (STR2, Buffer (Local0){})
        STR1 = Arg0
        STR2 = Arg1
        Local1 = Zero
        While ((Local1 < Local0))
        {
            Local2 = DerefOf (STR1 [Local1])
            Local3 = DerefOf (STR2 [Local1])
            If ((Local2 != Local3))
            {
                Return (One)
            }

            Local1++
        }

        Return (Zero)
    }

    Name (MACA, "_AUXMAX_#XXXXXXXXXXXX#")
    Name (WOLD, "_S5WOL_#01EF1700000000#")
    Scope (_SB)
    {
        Method (WMEM, 5, Serialized)
        {
            Local0 = (Arg0 + Arg1)
            OperationRegion (VARM, SystemMemory, Local0, 0x04)
            Field (VARM, DWordAcc, NoLock, Preserve)
            {
                VARR,   32
            }

            Local1 = VARR /* \_SB_.WMEM.VARR */
            Local5 = 0x7FFFFFFF
            Local5 |= 0x80000000
            Local2 = (Arg2 + Arg3)
            Local2 = (0x20 - Local2)
            Local2 = (((Local5 << Local2) & Local5) >> Local2)
            Local2 = ((Local2 >> Arg2) << Arg2)
            Local3 = (Arg4 << Arg2)
            Local4 = ((Local1 & (Local5 ^ Local2)) | Local3)
            VARR = Local4
        }

        Method (WFIO, 2, Serialized)
        {
            If ((Arg0 <= 0xFF))
            {
                Local0 = (Arg0 << 0x02)
                WMEM (0xFED81500, Local0, 0x16, One, Arg1)
            }
            Else
            {
                Local0 = Arg0 &= 0x03FC
                WMEM (0xFED81200, Local0, 0x16, One, Arg1)
            }
        }

        Method (RFIO, 1, Serialized)
        {
            If ((Arg0 <= 0xFF))
            {
                Local0 = (0xFED81500 | (Local0 = (Arg0 << 0x02)))
            }
            Else
            {
                Local0 = (0xFED81200 | Local0 = Arg0 &= 0x03FC)
            }

            OperationRegion (RGPI, SystemMemory, Local0, 0x04)
            Field (RGPI, DWordAcc, NoLock, Preserve)
            {
                GPID,   32
            }

            Local1 = GPID /* \_SB_.RFIO.GPID */
            Local1 &= 0x00010000
            Local1 >>= 0x10
            If ((Local1 == Zero))
            {
                Return (Zero)
            }
            Else
            {
                Return (One)
            }
        }

        OperationRegion (GSCI, SystemMemory, 0xFED80200, 0x10)
        Field (GSCI, DWordAcc, NoLock, Preserve)
        {
            Offset (0x08), 
            GAHL,   32, 
            GLEV,   32
        }

        Method (GCTL, 2, Serialized)
        {
            Local0 = GAHL /* \_SB_.GAHL */
            Local1 = GLEV /* \_SB_.GLEV */
            If ((Arg0 == Zero))
            {
                Local2 = (Local0 & ~(One << Arg1))
                Local3 = (Local1 & ~(One << Arg1))
            }
            Else
            {
                Local2 = (Local0 | (One << Arg1))
                Local3 = (Local1 | (One << Arg1))
            }

            GAHL = Local2
            GLEV = Local3
        }

        Device (LID)
        {
            Name (_HID, EisaId ("PNP0C0D") /* Lid Device */)  // _HID: Hardware ID
            Method (_LID, 0, NotSerialized)  // _LID: Lid Status
            {
                If (((ILNF == Zero) && (PLUX == Zero)))
                {
                    If (H8DR)
                    {
                        Return (^^PCI0.LPC0.EC0.HPLD) /* \_SB_.PCI0.LPC0.EC0_.HPLD */
                    }
                    ElseIf ((RBEC (0x46) & 0x04))
                    {
                        Return (One)
                    }
                    Else
                    {
                        Return (Zero)
                    }
                }
                Else
                {
                    Return (One)
                }
            }

            Method (_PRW, 0, NotSerialized)  // _PRW: Power Resources for Wake
            {
                If (LWCP)
                {
                    Return (Package (0x02)
                    {
                        0x08, 
                        0x04
                    })
                }
                Else
                {
                    Return (Package (0x02)
                    {
                        0x08, 
                        0x03
                    })
                }
            }

            Method (_PSW, 1, NotSerialized)  // _PSW: Power State Wake
            {
                If (H8DR)
                {
                    If (Arg0)
                    {
                        ^^PCI0.LPC0.EC0.HWLO = One
                    }
                    Else
                    {
                        ^^PCI0.LPC0.EC0.HWLO = Zero
                    }
                }
                ElseIf (Arg0)
                {
                    MBEC (0x32, 0xFF, 0x04)
                }
                Else
                {
                    MBEC (0x32, 0xFB, Zero)
                }

                If (LWCP)
                {
                    If (Arg0)
                    {
                        LWEN = One
                    }
                    Else
                    {
                        LWEN = Zero
                    }
                }
            }
        }

        Device (SLPB)
        {
            Name (_HID, EisaId ("PNP0C0E") /* Sleep Button Device */)  // _HID: Hardware ID
            Method (_PRW, 0, NotSerialized)  // _PRW: Power Resources for Wake
            {
                Return (Package (0x02)
                {
                    0x08, 
                    0x03
                })
            }

            Method (_PSW, 1, NotSerialized)  // _PSW: Power State Wake
            {
                If (H8DR)
                {
                    If (Arg0)
                    {
                        ^^PCI0.LPC0.EC0.HWFN = One
                    }
                    Else
                    {
                        ^^PCI0.LPC0.EC0.HWFN = Zero
                    }
                }
                ElseIf (Arg0)
                {
                    MBEC (0x32, 0xFF, 0x10)
                }
                Else
                {
                    MBEC (0x32, 0xEF, Zero)
                }
            }
        }

        Device (WMI1)
        {
            Name (_HID, EisaId ("PNP0C14") /* Windows Management Instrumentation Device */)  // _HID: Hardware ID
            Name (_UID, One)  // _UID: Unique ID
            Name (_WDG, Buffer (0xC8)
            {
                /* 0000 */  0x0E, 0x23, 0xF5, 0x51, 0x77, 0x96, 0xCD, 0x46,  // .#.Qw..F
                /* 0008 */  0xA1, 0xCF, 0xC0, 0xB2, 0x3E, 0xE3, 0x4D, 0xB7,  // ....>.M.
                /* 0010 */  0x41, 0x30, 0xFF, 0x05, 0x64, 0x9A, 0x47, 0x98,  // A0..d.G.
                /* 0018 */  0xF5, 0x33, 0x33, 0x4E, 0xA7, 0x07, 0x8E, 0x25,  // .33N...%
                /* 0020 */  0x1E, 0xBB, 0xC3, 0xA1, 0x41, 0x31, 0x01, 0x06,  // ....A1..
                /* 0028 */  0xEF, 0x54, 0x4B, 0x6A, 0xED, 0xA5, 0x33, 0x4D,  // .TKj..3M
                /* 0030 */  0x94, 0x55, 0xB0, 0xD9, 0xB4, 0x8D, 0xF4, 0xB3,  // .U......
                /* 0038 */  0x41, 0x32, 0x01, 0x06, 0xB6, 0xEB, 0xF1, 0x74,  // A2.....t
                /* 0040 */  0x7A, 0x92, 0x7D, 0x4C, 0x95, 0xDF, 0x69, 0x8E,  // z.}L..i.
                /* 0048 */  0x21, 0xE8, 0x0E, 0xB5, 0x41, 0x33, 0x01, 0x06,  // !...A3..
                /* 0050 */  0xFF, 0x04, 0xEF, 0x7E, 0x28, 0x43, 0x7C, 0x44,  // ...~(C|D
                /* 0058 */  0xB5, 0xBB, 0xD4, 0x49, 0x92, 0x5D, 0x53, 0x8D,  // ...I.]S.
                /* 0060 */  0x41, 0x34, 0x01, 0x06, 0x9E, 0x15, 0xDB, 0x8A,  // A4......
                /* 0068 */  0x32, 0x1E, 0x5C, 0x45, 0xBC, 0x93, 0x30, 0x8A,  // 2.\E..0.
                /* 0070 */  0x7E, 0xD9, 0x82, 0x46, 0x41, 0x35, 0x01, 0x01,  // ~..FA5..
                /* 0078 */  0xFD, 0xD9, 0x51, 0x26, 0x1C, 0x91, 0x69, 0x4B,  // ..Q&..iK
                /* 0080 */  0xB9, 0x4E, 0xD0, 0xDE, 0xD5, 0x96, 0x3B, 0xD7,  // .N....;.
                /* 0088 */  0x41, 0x36, 0x01, 0x06, 0x1A, 0x65, 0x64, 0x73,  // A6...eds
                /* 0090 */  0x2F, 0x13, 0xE7, 0x4F, 0xAD, 0xAA, 0x40, 0xC6,  // /..O..@.
                /* 0098 */  0xC7, 0xEE, 0x2E, 0x3B, 0x41, 0x37, 0x01, 0x06,  // ...;A7..
                /* 00A0 */  0x2C, 0xEF, 0xDD, 0xDF, 0xD4, 0x57, 0xCE, 0x48,  // ,....W.H
                /* 00A8 */  0xB1, 0x96, 0x0F, 0xB7, 0x87, 0xD9, 0x08, 0x36,  // .......6
                /* 00B0 */  0x43, 0x30, 0x01, 0x06, 0x21, 0x12, 0x90, 0x05,  // C0..!...
                /* 00B8 */  0x66, 0xD5, 0xD1, 0x11, 0xB2, 0xF0, 0x00, 0xA0,  // f.......
                /* 00C0 */  0xC9, 0x06, 0x29, 0x10, 0x42, 0x41, 0x01, 0x00   // ..).BA..
            })
            Name (RETN, Package (0x05)
            {
                "Success", 
                "Not Supported", 
                "Invalid Parameter", 
                "Access Denied", 
                "System Busy"
            })
            Name (ITEM, Package (0x9C)
            {
                Package (0x02)
                {
                    Zero, 
                    "Reserved"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "Reserved"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "USBBIOSSupport"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "AlwaysOnUSB"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "TrackPoint"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "TouchPad"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "FnSticky"
                }, 

                Package (0x02)
                {
                    0x04, 
                    "ThinkPadNumLock"
                }, 

                Package (0x02)
                {
                    0x0C, 
                    "PowerOnNumLock"
                }, 

                Package (0x02)
                {
                    0x05, 
                    "BootDisplayDevice"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "Reserved"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "Reserved"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "Reserved"
                }, 

                Package (0x02)
                {
                    0x06, 
                    "CDROMSpeed"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "CPUPowerManagement"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "PowerControlBeep"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "LowBatteryAlarm"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "PasswordBeep"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "KeyboardBeep"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "ExtendedMemoryTest"
                }, 

                Package (0x02)
                {
                    0x07, 
                    "SATAControllerMode"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "CoreMultiProcessing"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "VirtualizationTechnology"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "LockBIOSSetting"
                }, 

                Package (0x02)
                {
                    0x0B, 
                    "MinimumPasswordLength"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "BIOSPasswordAtUnattendedBoot"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "FingerprintPredesktopAuthentication"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "Reserved"
                }, 

                Package (0x02)
                {
                    0x03, 
                    "FingerprintSecurityMode"
                }, 

                Package (0x02)
                {
                    0x02, 
                    "SecurityChip"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "BIOSUpdateByEndUsers"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "DataExecutionPrevention"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "EthernetLANAccess"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "WirelessLANAccess"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "WirelessWANAccess"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "BluetoothAccess"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "WirelessUSBAccess"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "ModemAccess"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "USBPortAccess"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "IEEE1394Access"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "ExpressCardAccess"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "PCIExpressSlotAccess"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "UltrabayAccess"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "MemoryCardSlotAccess"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "SmartCardSlotAccess"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "IntegratedCameraAccess"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "MicrophoneAccess"
                }, 

                Package (0x02)
                {
                    0x0A, 
                    "BootMode"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "StartupOptionKeys"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "BootDeviceListF12Option"
                }, 

                Package (0x02)
                {
                    0x64, 
                    "BootOrder"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "WiMAXAccess"
                }, 

                Package (0x02)
                {
                    0x0D, 
                    "GraphicsDevice"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "TXTFeature"
                }, 

                Package (0x02)
                {
                    0x18, 
                    "AmdVt"
                }, 

                Package (0x02)
                {
                    0x0F, 
                    "AMTControl"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "Reserved"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "FingerprintReaderAccess"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "OsDetectionForSwitchableGraphics"
                }, 

                Package (0x02)
                {
                    0x0F, 
                    "AbsolutePersistenceModuleActivation"
                }, 

                Package (0x02)
                {
                    One, 
                    "PCIExpressPowerManagement"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "Reserved"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "eSATAPortAccess"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "HardwarePasswordManager"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "HyperThreadingTechnology"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "FnCtrlKeySwap"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "BIOSPasswordAtReboot"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "OnByAcAttach"
                }, 

                Package (0x02)
                {
                    0x64, 
                    "NetworkBoot"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "BootOrderLock"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "Reserved"
                }, 

                Package (0x02)
                {
                    0x11, 
                    "ExpressCardSpeed"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "RapidStartTechnology"
                }, 

                Package (0x02)
                {
                    0x12, 
                    "KeyboardIllumination"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "IPv4NetworkStack"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "IPv6NetworkStack"
                }, 

                Package (0x02)
                {
                    0x13, 
                    "UefiPxeBootPriority"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "Reserved"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "PhysicalPresenceForTpmClear"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "SecureRollBackPrevention"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "SecureBoot"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "NfcAccess"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "BottomCoverTamperDetected"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "PasswordCountExceededError"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "BIOSPasswordAtBootDeviceList"
                }, 

                Package (0x02)
                {
                    0x14, 
                    "UMAFramebufferSize"
                }, 

                Package (0x02)
                {
                    0x15, 
                    "BootTimeExtension"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "FnKeyAsPrimary"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "WiGig"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "BIOSPasswordAtPowerOn"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "Reserved"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "Reserved"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "InternalStorageTamper"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "Reserved"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "Reserved"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "USBKeyProvisioning"
                }, 

                Package (0x02)
                {
                    0x1B, 
                    "MACAddressPassThrough"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "ThunderboltAccess"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "WindowsUEFIFirmwareUpdate"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "WakeOnLANDock"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "Reserved"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "Reserved"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "Reserved"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "Reserved"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "DeviceGuard"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "Reserved"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "Reserved"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "Reserved"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "Reserved"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "IntegratedAudioAccess"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "Reserved"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "Reserved"
                }, 

                Package (0x02)
                {
                    0x0F, 
                    "ComputraceModuleActivation"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "Reserved"
                }, 

                Package (0x02)
                {
                    0x1C, 
                    "MaxPasswordAttempts"
                }, 

                Package (0x02)
                {
                    0x1D, 
                    "PasswordChangeTime"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "SystemManagementPasswordControl"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "PowerOnPasswordControl"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "HardDiskPasswordControl"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "BIOSSetupConfigurations"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "EnhancedWindowsBiometricSecurity"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "ThinkShieldsecurewipe"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "KernelDMAProtection"
                }, 

                Package (0x02)
                {
                    0x1E, 
                    "SetupUI"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "ChargeInBatteryMode"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "StrongPassword"
                }, 

                Package (0x02)
                {
                    0x20, 
                    "KeyboardLayout"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "PCIeTunneling"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "Reserved"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "Reserved"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "Reserved"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "Reserved"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "Reserved"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "Reserved"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "Reserved"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "Reserved"
                }, 

                Package (0x02)
                {
                    0x21, 
                    "WakeUponAlarm"
                }, 

                Package (0x02)
                {
                    0x22, 
                    "AlarmDate"
                }, 

                Package (0x02)
                {
                    0x23, 
                    "AlarmTime"
                }, 

                Package (0x02)
                {
                    0x24, 
                    "AlarmDayofWeek"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "UserDefinedAlarmSunday"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "UserDefinedAlarmMonday"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "UserDefinedAlarmTuesday"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "UserDefinedAlarmWednesday"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "UserDefinedAlarmThursday"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "UserDefinedAlarmFriday"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "UserDefinedAlarmSaturday"
                }, 

                Package (0x02)
                {
                    0x23, 
                    "UserDefinedAlarmTime"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "BlockSIDAuthentication"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "Reserved"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "Reserved"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "Reserved"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "Reserved"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "Reserved"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "TSME"
                }, 

                Package (0x02)
                {
                    0x29, 
                    "HDMIModeSelect"
                }
            })
            Name (VSEL, Package (0x2A)
            {
                Package (0x02)
                {
                    "Disable", 
                    "Enable"
                }, 

                Package (0x02)
                {
                    "Disable", 
                    "Automatic"
                }, 

                Package (0x04)
                {
                    "Active", 
                    "Inactive", 
                    "Disable", 
                    "Enable"
                }, 

                Package (0x02)
                {
                    "Normal", 
                    "High"
                }, 

                Package (0x02)
                {
                    "Independent", 
                    "Synchronized"
                }, 

                Package (0x02)
                {
                    "LCD", 
                    "ExternalDisplay"
                }, 

                Package (0x03)
                {
                    "High", 
                    "Normal", 
                    "Silent"
                }, 

                Package (0x02)
                {
                    "Compatibility", 
                    "AHCI"
                }, 

                Package (0x02)
                {
                    "External", 
                    "InternalOnly"
                }, 

                Package (0x02)
                {
                    "MaximizePerformance", 
                    "Balanced"
                }, 

                Package (0x02)
                {
                    "Quick", 
                    "Diagnostics"
                }, 

                Package (0x0A)
                {
                    "Disable", 
                    "4", 
                    "5", 
                    "6", 
                    "7", 
                    "8", 
                    "9", 
                    "10", 
                    "11", 
                    "12"
                }, 

                Package (0x03)
                {
                    "Auto", 
                    "On", 
                    "Off"
                }, 

                Package (0x03)
                {
                    "IntegratedGfx", 
                    "DiscreteGfx", 
                    "SwitchableGfx"
                }, 

                Package (0x03)
                {
                    "Disable", 
                    "ACOnly", 
                    "ACandBattery"
                }, 

                Package (0x03)
                {
                    "Disable", 
                    "Enable", 
                    "PermanentlyDisable"
                }, 

                Package (0x02)
                {
                    "HDMI", 
                    "USBTypeC"
                }, 

                Package (0x02)
                {
                    "Generation1", 
                    "Automatic"
                }, 

                Package (0x03)
                {
                    "ThinkLightOnly", 
                    "BacklightOnly", 
                    "Both"
                }, 

                Package (0x02)
                {
                    "IPv6First", 
                    "IPv4First"
                }, 

                Package (0x05)
                {
                    "Auto", 
                    "1GB", 
                    "2GB", 
                    "4GB", 
                    "8GB"
                }, 

                Package (0x0B)
                {
                    "Disable", 
                    "1", 
                    "2", 
                    "3", 
                    "", 
                    "5", 
                    "", 
                    "", 
                    "", 
                    "", 
                    "10"
                }, 

                Package (0x03)
                {
                    "Disable", 
                    "Enable", 
                    "SoftwareControl"
                }, 

                Package (0x04)
                {
                    "NoSecurity", 
                    "UserAuthorization", 
                    "SecureConnect", 
                    "DisplayPortandUSB"
                }, 

                Package (0x02)
                {
                    "Disable", 
                    "Enable"
                }, 

                Package (0x03)
                {
                    "Enable", 
                    "Disable", 
                    ""
                }, 

                Package (0x03)
                {
                    "Disable", 
                    "Enable", 
                    "Pre-BootACL"
                }, 

                Package (0x03)
                {
                    "Disable", 
                    "Enable", 
                    "Second"
                }, 

                Package (0x04)
                {
                    "Unlimited", 
                    "1", 
                    "3", 
                    "100"
                }, 

                Package (0x02)
                {
                    "Immediately", 
                    "AfterReboot"
                }, 

                Package (0x02)
                {
                    "SimpleText", 
                    "Graphical"
                }, 

                Package (0x02)
                {
                    "Linux", 
                    "Windows10"
                }, 

                Package (0x1B)
                {
                    "English_US", 
                    "CanadianFrenchMultilingual", 
                    "CanadianFrench", 
                    "Spanish_LA", 
                    "Portuguese_BR", 
                    "Belgian", 
                    "Danish", 
                    "Spanish", 
                    "French", 
                    "German", 
                    "Hungarian", 
                    "Icelandic", 
                    "Italian", 
                    "Norwegian", 
                    "Portuguese", 
                    "Slovenian", 
                    "Swedish", 
                    "Swiss", 
                    "Turkish", 
                    "English_UK", 
                    "Japanese", 
                    "Korean", 
                    "TraditionalChinese", 
                    "Turkish-F", 
                    "Estonian", 
                    "Finnish", 
                    "Czech"
                }, 

                Package (0x05)
                {
                    "Disable", 
                    "UserDefined", 
                    "WeeklyEvent", 
                    "DailyEvent", 
                    "SingleEvent"
                }, 

                Package (0x01)
                {
                    "MM/DD/YYYY"
                }, 

                Package (0x01)
                {
                    "HH/MM/SS"
                }, 

                Package (0x07)
                {
                    "Sunday", 
                    "Monday", 
                    "Tuesday", 
                    "Wednesday", 
                    "Thursday", 
                    "Friday", 
                    "Saturday"
                }, 

                Package (0x03)
                {
                    "Near", 
                    "Middle", 
                    "Far"
                }, 

                Package (0x03)
                {
                    "Fast", 
                    "Medium", 
                    "Slow"
                }, 

                Package (0x02)
                {
                    "No", 
                    "Yes"
                }, 

                Package (0x02)
                {
                    "Linux", 
                    "Windows 10"
                }, 

                Package (0x02)
                {
                    "HDMI1.4", 
                    "HDMI2.0"
                }
            })
            Name (VLST, Package (0x13)
            {
                "HDD0", 
                "HDD1", 
                "HDD2", 
                "HDD3", 
                "HDD4", 
                "PXEBOOT", 
                "ATAPICD0", 
                "ATAPICD1", 
                "ATAPICD2", 
                "USBFDD", 
                "USBCD", 
                "USBHDD", 
                "OtherHDD", 
                "OtherCD", 
                "NVMe0", 
                "NVMe1", 
                "HTTPSBOOT", 
                "LENOVOCLOUD", 
                "NODEV"
            })
            Name (VR01, Package (0x67)
            {
                "0000", 
                "1998", 
                "1999", 
                "2000", 
                "2001", 
                "2002", 
                "2003", 
                "2004", 
                "2005", 
                "2006", 
                "2007", 
                "2008", 
                "2009", 
                "2010", 
                "2011", 
                "2012", 
                "2013", 
                "2014", 
                "2015", 
                "2016", 
                "2017", 
                "2018", 
                "2019", 
                "2020", 
                "2021", 
                "2022", 
                "2023", 
                "2024", 
                "2025", 
                "2026", 
                "2027", 
                "2028", 
                "2029", 
                "2030", 
                "2031", 
                "2032", 
                "2033", 
                "2034", 
                "2035", 
                "2036", 
                "2037", 
                "2038", 
                "2039", 
                "2040", 
                "2041", 
                "2042", 
                "2043", 
                "2044", 
                "2045", 
                "2046", 
                "2047", 
                "2048", 
                "2049", 
                "2050", 
                "2051", 
                "2052", 
                "2053", 
                "2054", 
                "2055", 
                "2056", 
                "2057", 
                "2058", 
                "2059", 
                "2060", 
                "2061", 
                "2062", 
                "2063", 
                "2064", 
                "2065", 
                "2066", 
                "2067", 
                "2068", 
                "2069", 
                "2070", 
                "2071", 
                "2072", 
                "2073", 
                "2074", 
                "2075", 
                "2076", 
                "2077", 
                "2078", 
                "2079", 
                "2080", 
                "2081", 
                "2082", 
                "2083", 
                "2084", 
                "2085", 
                "2086", 
                "2087", 
                "2088", 
                "2089", 
                "2090", 
                "2091", 
                "2092", 
                "2093", 
                "2094", 
                "2095", 
                "2096", 
                "2097", 
                "2098", 
                "2099"
            })
            Name (VR02, Package (0x0D)
            {
                "00", 
                "01", 
                "02", 
                "03", 
                "04", 
                "05", 
                "06", 
                "07", 
                "08", 
                "09", 
                "10", 
                "11", 
                "12"
            })
            Name (VR03, Package (0x20)
            {
                "00", 
                "01", 
                "02", 
                "03", 
                "04", 
                "05", 
                "06", 
                "07", 
                "08", 
                "09", 
                "10", 
                "11", 
                "12", 
                "13", 
                "14", 
                "15", 
                "16", 
                "17", 
                "18", 
                "19", 
                "20", 
                "21", 
                "22", 
                "23", 
                "24", 
                "25", 
                "26", 
                "27", 
                "28", 
                "29", 
                "30", 
                "31"
            })
            Name (VR04, Package (0x18)
            {
                "00", 
                "01", 
                "02", 
                "03", 
                "04", 
                "05", 
                "06", 
                "07", 
                "08", 
                "09", 
                "10", 
                "11", 
                "12", 
                "13", 
                "14", 
                "15", 
                "16", 
                "17", 
                "18", 
                "19", 
                "20", 
                "21", 
                "22", 
                "23"
            })
            Name (VR05, Package (0x3C)
            {
                "00", 
                "01", 
                "02", 
                "03", 
                "04", 
                "05", 
                "06", 
                "07", 
                "08", 
                "09", 
                "10", 
                "11", 
                "12", 
                "13", 
                "14", 
                "15", 
                "16", 
                "17", 
                "18", 
                "19", 
                "20", 
                "21", 
                "22", 
                "23", 
                "24", 
                "25", 
                "26", 
                "27", 
                "28", 
                "29", 
                "30", 
                "31", 
                "32", 
                "33", 
                "34", 
                "35", 
                "36", 
                "37", 
                "38", 
                "39", 
                "40", 
                "41", 
                "42", 
                "43", 
                "44", 
                "45", 
                "46", 
                "47", 
                "48", 
                "49", 
                "50", 
                "51", 
                "52", 
                "53", 
                "54", 
                "55", 
                "56", 
                "57", 
                "58", 
                "59"
            })
            Name (PENC, Package (0x02)
            {
                "ascii", 
                "scancode"
            })
            Name (PKBD, Package (0x03)
            {
                "us", 
                "fr", 
                "gr"
            })
            Name (PTYP, Package (0x13)
            {
                "pap", 
                "pop", 
                "uhdp1", 
                "mhdp1", 
                "uhdp2", 
                "mhdp2", 
                "uhdp3", 
                "mhdp3", 
                "uhdp4", 
                "mhdp4", 
                "udrp1", 
                "adrp1", 
                "udrp2", 
                "adrp2", 
                "udrp3", 
                "adrp3", 
                "udrp4", 
                "adrp4", 
                "smp"
            })
            Name (OPCD, Package (0x0E)
            {
                "WmiOpcodePasswordType", 
                "WmiOpcodePasswordCurrent01", 
                "WmiOpcodePasswordCurrent02", 
                "WmiOpcodePasswordCurrent03", 
                "WmiOpcodePasswordCurrent04", 
                "WmiOpcodePasswordNew01", 
                "WmiOpcodePasswordNew02", 
                "WmiOpcodePasswordNew03", 
                "WmiOpcodePasswordNew04", 
                "WmiOpcodePasswordEncode", 
                "WmiOpcodePasswordSetUpdate", 
                "WmiOpcodePasswordAdmin", 
                "WmiOpcodeTPM", 
                "WmiOpcodePasswordFree"
            })
            Name (FUNC, Package (0x05)
            {
                Package (0x02)
                {
                    0x27, 
                    "ClearSecurityChip"
                }, 

                Package (0x02)
                {
                    0x27, 
                    "ResetFingerprintData"
                }, 

                Package (0x02)
                {
                    0x27, 
                    "ResettoSetupMode"
                }, 

                Package (0x02)
                {
                    0x27, 
                    "RestoreFactoryKeys"
                }, 

                Package (0x02)
                {
                    0x27, 
                    "ClearAllSecureBootKeys"
                }
            })
            Mutex (MWMI, 0x00)
            Name (PCFG, Buffer (0x18){})
            Name (IBUF, Buffer (0x0200){})
            Name (ILEN, Zero)
            Name (PSTR, Buffer (0x81){})
            Name (ALEN, Zero)
            Method (WQA0, 1, NotSerialized)
            {
                Acquire (MWMI, 0xFFFF)
                If ((WMIS (Zero, Arg0) != Zero))
                {
                    Release (MWMI)
                    Return ("")
                }

                Local0 = DerefOf (ITEM [WITM])
                Local1 = DerefOf (Local0 [Zero])
                Local2 = DerefOf (Local0 [One])
                If ((Local1 == 0x22))
                {
                    Concatenate (Local2, ",", Local6)
                    Concatenate (Local6, DerefOf (VR02 [RTC1]), Local7)
                    Concatenate (Local7, "/", Local6)
                    Concatenate (Local6, DerefOf (VR03 [RTC2]), Local7)
                    Concatenate (Local7, "/", Local6)
                    Concatenate (Local6, DerefOf (VR01 [RTC0]), Local7)
                }
                ElseIf ((Local1 == 0x23))
                {
                    Concatenate (Local2, ",", Local6)
                    Concatenate (Local6, DerefOf (VR04 [RTC0]), Local7)
                    Concatenate (Local7, ":", Local6)
                    Concatenate (Local6, DerefOf (VR05 [RTC1]), Local7)
                    Concatenate (Local7, ":", Local6)
                    Concatenate (Local6, DerefOf (VR05 [RTC2]), Local7)
                }
                ElseIf ((Local1 < 0x64))
                {
                    Concatenate (Local2, ",", Local6)
                    Local3 = DerefOf (VSEL [Local1])
                    Concatenate (Local6, DerefOf (Local3 [WSEL]), Local7)
                }
                Else
                {
                    Local3 = SizeOf (VLST)
                    If ((WLS0 <= Local3))
                    {
                        Concatenate (Local2, ",", Local7)
                        Concatenate (Local7, DerefOf (VLST [WLS0]), Local2)
                    }

                    If ((WLS1 <= Local3))
                    {
                        Concatenate (Local2, ":", Local7)
                        Concatenate (Local7, DerefOf (VLST [WLS1]), Local2)
                    }

                    If ((WLS2 <= Local3))
                    {
                        Concatenate (Local2, ":", Local7)
                        Concatenate (Local7, DerefOf (VLST [WLS2]), Local2)
                    }

                    If ((WLS3 <= Local3))
                    {
                        Concatenate (Local2, ":", Local7)
                        Concatenate (Local7, DerefOf (VLST [WLS3]), Local2)
                    }

                    If ((WLS4 <= Local3))
                    {
                        Concatenate (Local2, ":", Local7)
                        Concatenate (Local7, DerefOf (VLST [WLS4]), Local2)
                    }

                    If ((WLS5 <= Local3))
                    {
                        Concatenate (Local2, ":", Local7)
                        Concatenate (Local7, DerefOf (VLST [WLS5]), Local2)
                    }

                    If ((WLS6 <= Local3))
                    {
                        Concatenate (Local2, ":", Local7)
                        Concatenate (Local7, DerefOf (VLST [WLS6]), Local2)
                    }

                    If ((WLS7 <= Local3))
                    {
                        Concatenate (Local2, ":", Local7)
                        Concatenate (Local7, DerefOf (VLST [WLS7]), Local2)
                    }

                    If ((WLS8 <= Local3))
                    {
                        Concatenate (Local2, ":", Local7)
                        Concatenate (Local7, DerefOf (VLST [WLS8]), Local2)
                    }

                    If ((WLS9 <= Local3))
                    {
                        Concatenate (Local2, ":", Local7)
                        Concatenate (Local7, DerefOf (VLST [WLS9]), Local2)
                    }

                    If ((WLSA <= Local3))
                    {
                        Concatenate (Local2, ":", Local7)
                        Concatenate (Local7, DerefOf (VLST [WLSA]), Local2)
                    }

                    If ((WLSB <= Local3))
                    {
                        Concatenate (Local2, ":", Local7)
                        Concatenate (Local7, DerefOf (VLST [WLSB]), Local2)
                    }

                    If ((WLSC <= Local3))
                    {
                        Concatenate (Local2, ":", Local7)
                        Concatenate (Local7, DerefOf (VLST [WLSC]), Local2)
                    }

                    If ((WLSD <= Local3))
                    {
                        Concatenate (Local2, ":", Local7)
                        Concatenate (Local7, DerefOf (VLST [WLSD]), Local2)
                    }

                    Local7 = Local2
                }

                Release (MWMI)
                Return (Local7)
            }

            Method (WMA1, 3, NotSerialized)
            {
                Acquire (MWMI, 0xFFFF)
                If ((SizeOf (Arg2) == Zero))
                {
                    Local0 = 0x02
                }
                Else
                {
                    Local0 = CARG (Arg2)
                    If ((Local0 == Zero))
                    {
                        Local0 = WSET (ITEM, VSEL)
                        If ((Local0 == Zero))
                        {
                            Local0 = WMIS (One, Zero)
                        }
                    }
                }

                Release (MWMI)
                Return (DerefOf (RETN [Local0]))
            }

            Method (WMA2, 3, NotSerialized)
            {
                Acquire (MWMI, 0xFFFF)
                Local0 = CARG (Arg2)
                If ((Local0 == Zero))
                {
                    If ((ILEN != Zero))
                    {
                        Local0 = CPAS (IBUF, Zero)
                    }

                    If ((Local0 == Zero))
                    {
                        Local0 = WMIS (0x02, Zero)
                    }
                }

                Release (MWMI)
                Return (DerefOf (RETN [Local0]))
            }

            Method (WMA3, 3, NotSerialized)
            {
                Acquire (MWMI, 0xFFFF)
                Local0 = CARG (Arg2)
                If ((Local0 == Zero))
                {
                    If ((ILEN != Zero))
                    {
                        Local0 = CPAS (IBUF, Zero)
                    }

                    If ((Local0 == Zero))
                    {
                        Local0 = WMIS (0x03, Zero)
                    }
                }

                Release (MWMI)
                Return (DerefOf (RETN [Local0]))
            }

            Method (WMA4, 3, NotSerialized)
            {
                Acquire (MWMI, 0xFFFF)
                Local0 = CARG (Arg2)
                If ((Local0 == Zero))
                {
                    If ((ILEN != Zero))
                    {
                        Local0 = CPAS (IBUF, Zero)
                    }

                    If ((Local0 == Zero))
                    {
                        Local0 = WMIS (0x04, Zero)
                    }
                }

                Release (MWMI)
                Return (DerefOf (RETN [Local0]))
            }

            Method (WQA5, 1, NotSerialized)
            {
                Acquire (MWMI, 0xFFFF)
                Local0 = WMIS (0x05, Zero)
                PCFG [Zero] = WSPM /* \WSPM */
                PCFG [0x04] = WSPS /* \WSPS */
                PCFG [0x08] = WSMN /* \WSMN */
                PCFG [0x0C] = WSMX /* \WSMX */
                PCFG [0x10] = WSEN /* \WSEN */
                PCFG [0x14] = WSKB /* \WSKB */
                Release (MWMI)
                Return (PCFG) /* \_SB_.WMI1.PCFG */
            }

            Method (WMA6, 3, NotSerialized)
            {
                Acquire (MWMI, 0xFFFF)
                If ((SizeOf (Arg2) == Zero))
                {
                    Local0 = 0x02
                }
                Else
                {
                    Local0 = CARG (Arg2)
                    If ((Local0 == Zero))
                    {
                        If ((ILEN != Zero))
                        {
                            Local0 = SPAS (IBUF)
                        }

                        If ((Local0 == Zero))
                        {
                            Local0 = WMIS (0x06, Zero)
                        }
                    }
                }

                Release (MWMI)
                Return (DerefOf (RETN [Local0]))
            }

            Method (WMA7, 3, NotSerialized)
            {
                If ((SizeOf (Arg2) == Zero))
                {
                    Return ("")
                }

                Local0 = CARG (Arg2)
                If ((Local0 == Zero))
                {
                    Local1 = GITM (IBUF, ITEM)
                    If ((Local1 == Ones))
                    {
                        Return ("")
                    }

                    Local0 = DerefOf (ITEM [Local1])
                    Local1 = DerefOf (Local0 [Zero])
                    If ((Local1 < 0x64))
                    {
                        Local3 = DerefOf (VSEL [Local1])
                        Local2 = DerefOf (Local3 [Zero])
                        Local4 = SizeOf (Local3)
                        Local5 = One
                        While ((Local5 < Local4))
                        {
                            Local6 = DerefOf (Local3 [Local5])
                            If ((SizeOf (Local6) != Zero))
                            {
                                Concatenate (Local2, ",", Local7)
                                Concatenate (Local7, Local6, Local2)
                            }

                            Local5++
                        }
                    }
                    Else
                    {
                        Local2 = DerefOf (VLST [Zero])
                        Local4 = SizeOf (VLST)
                        Local5 = One
                        While ((Local5 < Local4))
                        {
                            Local6 = DerefOf (VLST [Local5])
                            Concatenate (Local2, ",", Local7)
                            Concatenate (Local7, Local6, Local2)
                            Local5++
                        }
                    }
                }

                Return (Local2)
            }

            Method (WQA8, 1, NotSerialized)
            {
                Acquire (MWMI, 0xFFFF)
                If ((WMIS (0x10, Arg0) != Zero))
                {
                    Release (MWMI)
                    Return ("")
                }

                Local0 = DerefOf (FUNC [WITM])
                Local1 = DerefOf (Local0 [Zero])
                Local2 = DerefOf (Local0 [One])
                Concatenate (Local2, ",", Local6)
                Local3 = DerefOf (VSEL [Local1])
                Concatenate (Local6, DerefOf (Local3 [WSEL]), Local7)
                Release (MWMI)
                Return (Local7)
            }

            Method (WMA9, 3, NotSerialized)
            {
                Acquire (MWMI, 0xFFFF)
                If ((SizeOf (Arg2) == Zero))
                {
                    Local0 = 0x02
                }
                Else
                {
                    Local0 = CARG (Arg2)
                    If ((Local0 == Zero))
                    {
                        Local0 = WSET (FUNC, VSEL)
                        If ((Local0 == Zero))
                        {
                            Local0 = WMIS (0x11, Zero)
                        }
                    }
                }

                Release (MWMI)
                Return (DerefOf (RETN [Local0]))
            }

            Method (WMC0, 3, NotSerialized)
            {
                Acquire (MWMI, 0xFFFF)
                If ((SizeOf (Arg2) == Zero))
                {
                    Local0 = 0x02
                }
                Else
                {
                    Local0 = CARG (Arg2)
                    If ((Local0 == Zero))
                    {
                        Local6 = GSEL (OPCD, IBUF, Zero)
                        If ((Local6 != Ones))
                        {
                            Local4 = DerefOf (OPCD [Local6])
                            Local2 = SizeOf (Local4)
                            Local3 = DerefOf (IBUF [Local2])
                            If (((Local3 == 0x2C) || (Local3 == 0x3A)))
                            {
                                Local2++
                            }

                            Local5 = (SizeOf (Arg2) - Local2)
                            Local0 = Zero
                            If ((Local6 == Zero))
                            {
                                WPTY = 0xFF
                                Local7 = GSEL (PTYP, IBUF, Local2)
                                If ((Local7 != Ones))
                                {
                                    WPTY = Local7
                                }
                                Else
                                {
                                    Local0 = 0x02
                                }
                            }
                            ElseIf ((Local6 == One))
                            {
                                PSTR = Zero
                                Local1 = GPAO (IBUF, Local2)
                                If ((Local1 == Ones))
                                {
                                    Local0 = 0x02
                                }

                                If ((Local0 == Zero))
                                {
                                    WPAS = PSTR /* \_SB_.WMI1.PSTR */
                                }
                            }
                            ElseIf ((Local6 == 0x05))
                            {
                                PSTR = Zero
                                Local1 = GPAO (IBUF, Local2)
                                If ((Local1 == Ones))
                                {
                                    Local0 = 0x02
                                }

                                If ((Local1 == Zero))
                                {
                                    PSTR = Zero
                                }

                                If ((Local0 == Zero))
                                {
                                    WPNW = PSTR /* \_SB_.WMI1.PSTR */
                                }
                            }
                            ElseIf ((Local6 == 0x0A))
                            {
                                Local0 = Zero
                            }
                            ElseIf ((Local6 == 0x0B))
                            {
                                PSTR = Zero
                                Local1 = GPAO (IBUF, Local2)
                                If ((Local1 == Ones))
                                {
                                    Local0 = 0x02
                                }

                                If ((Local1 == Zero))
                                {
                                    Local0 = 0x02
                                }

                                If ((Local0 == Zero))
                                {
                                    WPAS = PSTR /* \_SB_.WMI1.PSTR */
                                }
                            }
                            Else
                            {
                                Local0 = 0x02
                            }

                            If ((Local0 == Zero))
                            {
                                Local0 = WMIS (0x0F, Local6)
                            }
                        }
                        Else
                        {
                            Local0 = 0x02
                        }
                    }
                }

                Release (MWMI)
                Return (DerefOf (RETN [Local0]))
            }

            Method (CARG, 1, NotSerialized)
            {
                Local0 = SizeOf (Arg0)
                If ((Local0 == Zero))
                {
                    IBUF = Zero
                    ILEN = Zero
                    Return (Zero)
                }

                If ((ObjectType (Arg0) != 0x02))
                {
                    Return (0x02)
                }

                If ((Local0 >= 0x01FF))
                {
                    Return (0x02)
                }

                IBUF = Arg0
                Local0--
                Local1 = DerefOf (IBUF [Local0])
                If (((Local1 == 0x3B) || (Local1 == 0x2A)))
                {
                    IBUF [Local0] = Zero
                    ILEN = Local0
                }
                Else
                {
                    ILEN = SizeOf (Arg0)
                }

                Return (Zero)
            }

            Method (SCMP, 3, NotSerialized)
            {
                Local0 = SizeOf (Arg0)
                If ((Local0 == Zero))
                {
                    Return (Zero)
                }

                Local0++
                Name (STR1, Buffer (Local0){})
                STR1 = Arg0
                Local0--
                If ((ALEN != Zero))
                {
                    Local0 = ALEN /* \_SB_.WMI1.ALEN */
                }

                Local1 = Zero
                Local2 = Arg2
                While ((Local1 < Local0))
                {
                    Local3 = DerefOf (STR1 [Local1])
                    Local4 = DerefOf (Arg1 [Local2])
                    If ((Local3 != Local4))
                    {
                        Return (Zero)
                    }

                    Local1++
                    Local2++
                }

                If ((ALEN != Zero))
                {
                    Return (One)
                }

                Local4 = DerefOf (Arg1 [Local2])
                If ((Local4 == Zero))
                {
                    Return (One)
                }

                If (((Local4 == 0x2C) || (Local4 == 0x3A)))
                {
                    Return (One)
                }

                Return (Zero)
            }

            Method (GITM, 2, NotSerialized)
            {
                Local0 = Zero
                Local1 = SizeOf (Arg1)
                While ((Local0 < Local1))
                {
                    Local3 = DerefOf (DerefOf (Arg1 [Local0]) [One])
                    If (SCMP (Local3, Arg0, Zero))
                    {
                        Return (Local0)
                    }

                    Local0++
                }

                Return (Ones)
            }

            Method (GSEL, 3, NotSerialized)
            {
                Local0 = Zero
                Local1 = SizeOf (Arg0)
                While ((Local0 < Local1))
                {
                    Local2 = DerefOf (Arg0 [Local0])
                    If (SCMP (Local2, Arg1, Arg2))
                    {
                        Return (Local0)
                    }

                    Local0++
                }

                Return (Ones)
            }

            Method (SLEN, 2, NotSerialized)
            {
                Local0 = DerefOf (Arg0 [Arg1])
                Return (SizeOf (Local0))
            }

            Method (CLRP, 0, NotSerialized)
            {
                WPAS = Zero
                WPNW = Zero
            }

            Method (GPAS, 2, NotSerialized)
            {
                Local0 = Arg1
                Local1 = Zero
                While ((Local1 <= 0x80))
                {
                    Local2 = DerefOf (Arg0 [Local0])
                    If (((Local2 == 0x2C) || (Local2 == Zero)))
                    {
                        PSTR [Local1] = Zero
                        Return (Local1)
                    }

                    PSTR [Local1] = Local2
                    Local0++
                    Local1++
                }

                PSTR [Local1] = Zero
                Return (Ones)
            }

            Method (GPAO, 2, NotSerialized)
            {
                Local0 = Arg1
                Local1 = Zero
                While ((Local1 <= 0x80))
                {
                    Local2 = DerefOf (Arg0 [Local0])
                    If ((Local2 == Zero))
                    {
                        PSTR [Local1] = Zero
                        Return (Local1)
                    }

                    PSTR [Local1] = Local2
                    Local0++
                    Local1++
                }

                Local1--
                PSTR [Local1] = Zero
                Return (Ones)
            }

            Method (CPAS, 2, NotSerialized)
            {
                CLRP ()
                Local0 = Arg1
                Local1 = GPAS (Arg0, Local0)
                If ((Local1 == Ones))
                {
                    Return (0x02)
                }

                If ((Local1 == Zero))
                {
                    Return (0x02)
                }

                WPAS = PSTR /* \_SB_.WMI1.PSTR */
                Local0 += Local1
                Local0++
                Local6 = GSEL (PENC, Arg0, Local0)
                If ((Local6 == Ones))
                {
                    Return (0x02)
                }

                WENC = Local6
                If ((Local6 == Zero))
                {
                    Local0 += SLEN (PENC, Zero)
                    If ((DerefOf (Arg0 [Local0]) != 0x2C))
                    {
                        Return (0x02)
                    }

                    Local0++
                    Local6 = GSEL (PKBD, Arg0, Local0)
                    If ((Local6 == Ones))
                    {
                        Return (0x02)
                    }

                    WKBD = Local6
                }

                Return (Zero)
            }

            Method (SPAS, 1, NotSerialized)
            {
                CLRP ()
                Local6 = GSEL (PTYP, Arg0, Zero)
                If ((Local6 == Ones))
                {
                    Return (0x02)
                }

                WPTY = Local6
                Local0 = SLEN (PTYP, Local6)
                If ((DerefOf (Arg0 [Local0]) != 0x2C))
                {
                    Return (0x02)
                }

                Local0++
                Local1 = GPAS (Arg0, Local0)
                If ((Local1 == Ones))
                {
                    Return (0x02)
                }

                WPAS = PSTR /* \_SB_.WMI1.PSTR */
                Local0 += Local1
                If ((DerefOf (Arg0 [Local0]) != 0x2C))
                {
                    Return (0x02)
                }

                Local0++
                Local1 = GPAS (Arg0, Local0)
                If ((Local1 == Ones))
                {
                    Return (0x02)
                }

                If ((Local1 == Zero))
                {
                    PSTR = Zero
                }

                WPNW = PSTR /* \_SB_.WMI1.PSTR */
                Local0 += Local1
                Local0++
                Local6 = GSEL (PENC, Arg0, Local0)
                If ((Local6 == Ones))
                {
                    Return (0x02)
                }

                WENC = Local6
                If ((Local6 == Zero))
                {
                    Local0 += SLEN (PENC, Zero)
                    If ((DerefOf (Arg0 [Local0]) != 0x2C))
                    {
                        Return (0x02)
                    }

                    Local0++
                    Local6 = GSEL (PKBD, Arg0, Local0)
                    If ((Local6 == Ones))
                    {
                        Return (0x02)
                    }

                    WKBD = Local6
                }

                Return (Zero)
            }

            Method (WSET, 2, NotSerialized)
            {
                Local0 = ILEN /* \_SB_.WMI1.ILEN */
                Local0++
                Local1 = GITM (IBUF, Arg0)
                If ((Local1 == Ones))
                {
                    Return (0x02)
                }

                WITM = Local1
                Local3 = DerefOf (Arg0 [Local1])
                Local4 = DerefOf (Local3 [One])
                Local2 = SizeOf (Local4)
                Local2++
                Local4 = DerefOf (Local3 [Zero])
                If ((Local4 == 0x22))
                {
                    If ((ALMD (Local2) != Zero))
                    {
                        Return (0x02)
                    }

                    Local2 += 0x0A
                    Local4 = DerefOf (IBUF [Local2])
                }
                ElseIf ((Local4 == 0x23))
                {
                    If ((ALMT (Local2) != Zero))
                    {
                        Return (0x02)
                    }

                    Local2 += 0x08
                    Local4 = DerefOf (IBUF [Local2])
                }
                ElseIf ((Local4 < 0x64))
                {
                    Local5 = DerefOf (Arg1 [Local4])
                    Local6 = GSEL (Local5, IBUF, Local2)
                    If ((Local6 == Ones))
                    {
                        Return (0x02)
                    }

                    WSEL = Local6
                    Local2 += SLEN (Local5, Local6)
                    Local4 = DerefOf (IBUF [Local2])
                }
                Else
                {
                    WLS0 = 0x3F
                    WLS1 = 0x3F
                    WLS2 = 0x3F
                    WLS3 = 0x3F
                    WLS4 = 0x3F
                    WLS5 = 0x3F
                    WLS6 = 0x3F
                    WLS7 = 0x3F
                    WLS8 = 0x3F
                    WLS9 = 0x3F
                    WLSA = 0x3F
                    WLSB = 0x3F
                    WLSC = 0x3F
                    WLSD = 0x3F
                    Local6 = GSEL (VLST, IBUF, Local2)
                    If ((Local6 == Ones))
                    {
                        Return (0x02)
                    }

                    WLS0 = Local6
                    Local2 += SLEN (VLST, Local6)
                    Local4 = DerefOf (IBUF [Local2])
                    If (((Local2 < Local0) && (Local4 == 0x3A)))
                    {
                        Local2++
                        Local6 = GSEL (VLST, IBUF, Local2)
                        If ((Local6 == Ones))
                        {
                            Return (0x02)
                        }

                        WLS1 = Local6
                        Local2 += SLEN (VLST, Local6)
                        Local4 = DerefOf (IBUF [Local2])
                    }

                    If (((Local2 < Local0) && (Local4 == 0x3A)))
                    {
                        Local2++
                        Local6 = GSEL (VLST, IBUF, Local2)
                        If ((Local6 == Ones))
                        {
                            Return (0x02)
                        }

                        WLS2 = Local6
                        Local2 += SLEN (VLST, Local6)
                        Local4 = DerefOf (IBUF [Local2])
                    }

                    If (((Local2 < Local0) && (Local4 == 0x3A)))
                    {
                        Local2++
                        Local6 = GSEL (VLST, IBUF, Local2)
                        If ((Local6 == Ones))
                        {
                            Return (0x02)
                        }

                        WLS3 = Local6
                        Local2 += SLEN (VLST, Local6)
                        Local4 = DerefOf (IBUF [Local2])
                    }

                    If (((Local2 < Local0) && (Local4 == 0x3A)))
                    {
                        Local2++
                        Local6 = GSEL (VLST, IBUF, Local2)
                        If ((Local6 == Ones))
                        {
                            Return (0x02)
                        }

                        WLS4 = Local6
                        Local2 += SLEN (VLST, Local6)
                        Local4 = DerefOf (IBUF [Local2])
                    }

                    If (((Local2 < Local0) && (Local4 == 0x3A)))
                    {
                        Local2++
                        Local6 = GSEL (VLST, IBUF, Local2)
                        If ((Local6 == Ones))
                        {
                            Return (0x02)
                        }

                        WLS5 = Local6
                        Local2 += SLEN (VLST, Local6)
                        Local4 = DerefOf (IBUF [Local2])
                    }

                    If (((Local2 < Local0) && (Local4 == 0x3A)))
                    {
                        Local2++
                        Local6 = GSEL (VLST, IBUF, Local2)
                        If ((Local6 == Ones))
                        {
                            Return (0x02)
                        }

                        WLS6 = Local6
                        Local2 += SLEN (VLST, Local6)
                        Local4 = DerefOf (IBUF [Local2])
                    }

                    If (((Local2 < Local0) && (Local4 == 0x3A)))
                    {
                        Local2++
                        Local6 = GSEL (VLST, IBUF, Local2)
                        If ((Local6 == Ones))
                        {
                            Return (0x02)
                        }

                        WLS7 = Local6
                        Local2 += SLEN (VLST, Local6)
                        Local4 = DerefOf (IBUF [Local2])
                    }

                    If (((Local2 < Local0) && (Local4 == 0x3A)))
                    {
                        Local2++
                        Local6 = GSEL (VLST, IBUF, Local2)
                        If ((Local6 == Ones))
                        {
                            Return (0x02)
                        }

                        WLS8 = Local6
                        Local2 += SLEN (VLST, Local6)
                        Local4 = DerefOf (IBUF [Local2])
                    }

                    If (((Local2 < Local0) && (Local4 == 0x3A)))
                    {
                        Local2++
                        Local6 = GSEL (VLST, IBUF, Local2)
                        If ((Local6 == Ones))
                        {
                            Return (0x02)
                        }

                        WLS9 = Local6
                        Local2 += SLEN (VLST, Local6)
                        Local4 = DerefOf (IBUF [Local2])
                    }

                    If (((Local2 < Local0) && (Local4 == 0x3A)))
                    {
                        Local2++
                        Local6 = GSEL (VLST, IBUF, Local2)
                        If ((Local6 == Ones))
                        {
                            Return (0x02)
                        }

                        WLSA = Local6
                        Local2 += SLEN (VLST, Local6)
                        Local4 = DerefOf (IBUF [Local2])
                    }

                    If (((Local2 < Local0) && (Local4 == 0x3A)))
                    {
                        Local2++
                        Local6 = GSEL (VLST, IBUF, Local2)
                        If ((Local6 == Ones))
                        {
                            Return (0x02)
                        }

                        WLSB = Local6
                        Local2 += SLEN (VLST, Local6)
                        Local4 = DerefOf (IBUF [Local2])
                    }

                    If (((Local2 < Local0) && (Local4 == 0x3A)))
                    {
                        Local2++
                        Local6 = GSEL (VLST, IBUF, Local2)
                        If ((Local6 == Ones))
                        {
                            Return (0x02)
                        }

                        WLSC = Local6
                        Local2 += SLEN (VLST, Local6)
                        Local4 = DerefOf (IBUF [Local2])
                    }

                    If (((Local2 < Local0) && (Local4 == 0x3A)))
                    {
                        Local2++
                        Local6 = GSEL (VLST, IBUF, Local2)
                        If ((Local6 == Ones))
                        {
                            Return (0x02)
                        }

                        WLSD = Local6
                        Local2 += SLEN (VLST, Local6)
                        Local4 = DerefOf (IBUF [Local2])
                    }
                }

                If (((Local4 == 0x2C) && (Local2 < Local0)))
                {
                    Local2++
                    Local0 = CPAS (IBUF, Local2)
                    If ((Local0 != Zero))
                    {
                        Return (Local0)
                    }
                }

                Return (Zero)
            }

            Method (ALMD, 1, NotSerialized)
            {
                Local0 = Arg0
                Local1 = VR02 /* \_SB_.WMI1.VR02 */
                ALEN = 0x02
                Local2 = GSEL (Local1, IBUF, Local0)
                ALEN = Zero
                If ((Local2 == Ones))
                {
                    Return (0x02)
                }

                RTC1 = Local2
                Local0++
                Local0++
                Local3 = DerefOf (IBUF [Local0])
                If ((Local3 != 0x2F))
                {
                    Return (0x02)
                }

                Local0++
                Local1 = VR03 /* \_SB_.WMI1.VR03 */
                ALEN = 0x02
                Local2 = GSEL (Local1, IBUF, Local0)
                ALEN = Zero
                If ((Local2 == Ones))
                {
                    Return (0x02)
                }

                RTC2 = Local2
                Local0++
                Local0++
                Local3 = DerefOf (IBUF [Local0])
                If ((Local3 != 0x2F))
                {
                    Return (0x02)
                }

                Local0++
                Local1 = VR01 /* \_SB_.WMI1.VR01 */
                Local2 = GSEL (Local1, IBUF, Local0)
                If ((Local2 == Ones))
                {
                    Return (0x02)
                }

                RTC0 = Local2
                Return (Zero)
            }

            Method (ALMT, 1, NotSerialized)
            {
                Local0 = Arg0
                Local1 = VR04 /* \_SB_.WMI1.VR04 */
                ALEN = 0x02
                Local2 = GSEL (Local1, IBUF, Local0)
                ALEN = Zero
                If ((Local2 == Ones))
                {
                    Return (0x02)
                }

                RTC0 = Local2
                Local0++
                Local0++
                Local3 = DerefOf (IBUF [Local0])
                If ((Local3 != 0x3A))
                {
                    Return (0x02)
                }

                Local0++
                Local1 = VR05 /* \_SB_.WMI1.VR05 */
                ALEN = 0x02
                Local2 = GSEL (Local1, IBUF, Local0)
                ALEN = Zero
                If ((Local2 == Ones))
                {
                    Return (0x02)
                }

                RTC1 = Local2
                Local0++
                Local0++
                Local3 = DerefOf (IBUF [Local0])
                If ((Local3 != 0x3A))
                {
                    Return (0x02)
                }

                Local0++
                Local1 = VR05 /* \_SB_.WMI1.VR05 */
                Local2 = GSEL (Local1, IBUF, Local0)
                If ((Local2 == Ones))
                {
                    Return (0x02)
                }

                RTC2 = Local2
                Return (Zero)
            }

            Name (WQBA, Buffer (0x0AA7)
            {
                /* 0000 */  0x46, 0x4F, 0x4D, 0x42, 0x01, 0x00, 0x00, 0x00,  // FOMB....
                /* 0008 */  0x97, 0x0A, 0x00, 0x00, 0x56, 0x49, 0x00, 0x00,  // ....VI..
                /* 0010 */  0x44, 0x53, 0x00, 0x01, 0x1A, 0x7D, 0xDA, 0x54,  // DS...}.T
                /* 0018 */  0x98, 0x5E, 0xA3, 0x00, 0x01, 0x06, 0x18, 0x42,  // .^.....B
                /* 0020 */  0x10, 0x19, 0x10, 0x0A, 0x0D, 0x21, 0x02, 0x0B,  // .....!..
                /* 0028 */  0x83, 0x50, 0x4C, 0x18, 0x14, 0xA0, 0x45, 0x41,  // .PL...EA
                /* 0030 */  0xC8, 0x05, 0x14, 0x95, 0x02, 0x21, 0xC3, 0x02,  // .....!..
                /* 0038 */  0x14, 0x0B, 0x70, 0x2E, 0x40, 0xBA, 0x00, 0xE5,  // ..p.@...
                /* 0040 */  0x28, 0x72, 0x0C, 0x22, 0x02, 0xF7, 0xEF, 0x0F,  // (r."....
                /* 0048 */  0x31, 0x0E, 0x88, 0x14, 0x40, 0x48, 0x26, 0x84,  // 1...@H&.
                /* 0050 */  0x44, 0x00, 0x53, 0x21, 0x70, 0x84, 0xA0, 0x5F,  // D.S!p.._
                /* 0058 */  0x01, 0x08, 0x1D, 0xA2, 0xC9, 0xA0, 0x00, 0xA7,  // ........
                /* 0060 */  0x08, 0x82, 0xB4, 0x65, 0x01, 0xBA, 0x05, 0xF8,  // ...e....
                /* 0068 */  0x16, 0xA0, 0x1D, 0x42, 0x68, 0x15, 0x0A, 0x30,  // ...Bh..0
                /* 0070 */  0x29, 0xC0, 0x27, 0x98, 0x2C, 0x0A, 0x90, 0x0D,  // ).'.,...
                /* 0078 */  0x26, 0xDB, 0x70, 0x64, 0x18, 0x4C, 0xE4, 0x18,  // &.pd.L..
                /* 0080 */  0x50, 0x62, 0xC6, 0x80, 0xD2, 0x39, 0x05, 0xD9,  // Pb...9..
                /* 0088 */  0x04, 0x16, 0x74, 0xA1, 0x28, 0x9A, 0x46, 0x94,  // ..t.(.F.
                /* 0090 */  0x04, 0x07, 0x75, 0x0C, 0x11, 0x82, 0x97, 0x2B,  // ..u....+
                /* 0098 */  0x40, 0xF2, 0x04, 0xA4, 0x79, 0x5E, 0xB2, 0x3E,  // @...y^.>
                /* 00A0 */  0x08, 0x0D, 0x81, 0x8D, 0x80, 0x47, 0x91, 0x00,  // .....G..
                /* 00A8 */  0xC2, 0x62, 0x2C, 0x53, 0xE2, 0x61, 0x50, 0x1E,  // .b,S.aP.
                /* 00B0 */  0x40, 0x24, 0x67, 0xA8, 0x28, 0x60, 0x7B, 0x9D,  // @$g.(`{.
                /* 00B8 */  0x88, 0x86, 0x75, 0x9C, 0x4C, 0x12, 0x1C, 0x6A,  // ..u.L..j
                /* 00C0 */  0x94, 0x96, 0x28, 0xC0, 0xFC, 0xC8, 0x34, 0x91,  // ..(...4.
                /* 00C8 */  0x63, 0x6B, 0x7A, 0xC4, 0x82, 0x64, 0xD2, 0x86,  // ckz..d..
                /* 00D0 */  0x82, 0x1A, 0xBA, 0xA7, 0x75, 0x52, 0x9E, 0x68,  // ....uR.h
                /* 00D8 */  0xC4, 0x83, 0x32, 0x4C, 0x02, 0x8F, 0x82, 0xA1,  // ..2L....
                /* 00E0 */  0x71, 0x82, 0xB2, 0x20, 0xE4, 0x60, 0xA0, 0x28,  // q.. .`.(
                /* 00E8 */  0xC0, 0x93, 0xF0, 0x1C, 0x8B, 0x17, 0x20, 0x7C,  // ...... |
                /* 00F0 */  0xC6, 0xE4, 0x28, 0x10, 0x23, 0x81, 0x8F, 0x04,  // ..(.#...
                /* 00F8 */  0x1E, 0xCD, 0x31, 0x63, 0x81, 0xC2, 0x05, 0x3C,  // ..1c...<
                /* 0100 */  0x9F, 0x63, 0x88, 0x1C, 0xF7, 0x50, 0x63, 0x1C,  // .c...Pc.
                /* 0108 */  0x45, 0xE4, 0x04, 0xEF, 0x00, 0x51, 0x8C, 0x56,  // E....Q.V
                /* 0110 */  0xD0, 0xBC, 0x85, 0x18, 0x2C, 0x9A, 0xC1, 0x7A,  // ....,..z
                /* 0118 */  0x06, 0x27, 0x83, 0x4E, 0xF0, 0xFF, 0x3F, 0x02,  // .'.N..?.
                /* 0120 */  0x7E, 0x5C, 0xB0, 0x47, 0x01, 0x56, 0x07, 0xA5,  // ~\.G.V..
                /* 0128 */  0x69, 0x98, 0xA0, 0x7B, 0x01, 0xD6, 0x04, 0x18,  // i..{....
                /* 0130 */  0x13, 0xF0, 0x6C, 0x88, 0x51, 0x99, 0x00, 0x67,  // ..l.Q..g
                /* 0138 */  0xF7, 0x05, 0xCD, 0xA8, 0x2D, 0x01, 0xE6, 0x04,  // ....-...
                /* 0140 */  0x68, 0x13, 0xE0, 0x0D, 0x41, 0x28, 0xE7, 0x19,  // h...A(..
                /* 0148 */  0xE5, 0x58, 0x4E, 0x31, 0xCA, 0xC3, 0x40, 0xCC,  // .XN1..@.
                /* 0150 */  0x97, 0x81, 0xA0, 0x51, 0x62, 0xC4, 0x3C, 0x97,  // ...Qb.<.
                /* 0158 */  0xB8, 0x86, 0x8D, 0x10, 0x23, 0xE4, 0x29, 0x04,  // ....#.).
                /* 0160 */  0x8A, 0xDB, 0xFE, 0x20, 0xC8, 0xA0, 0x71, 0xA3,  // ... ..q.
                /* 0168 */  0xF7, 0x69, 0xE1, 0xAC, 0x4E, 0xE0, 0xE8, 0x9F,  // .i..N...
                /* 0170 */  0x14, 0x4C, 0xE0, 0x29, 0x1F, 0xD8, 0xB3, 0xC1,  // .L.)....
                /* 0178 */  0x09, 0x1C, 0x6B, 0xD4, 0x18, 0xA7, 0x92, 0xC0,  // ..k.....
                /* 0180 */  0xB1, 0x1F, 0x10, 0xD2, 0x00, 0xA2, 0x48, 0xF0,  // ......H.
                /* 0188 */  0xA8, 0xD3, 0x82, 0xCF, 0x05, 0x1E, 0xDA, 0x41,  // .......A
                /* 0190 */  0x7B, 0x8E, 0x27, 0x10, 0xE4, 0x10, 0x8E, 0xE0,  // {.'.....
                /* 0198 */  0x89, 0xE1, 0x81, 0xC0, 0x63, 0x60, 0x37, 0x05,  // ....c`7.
                /* 01A0 */  0x1F, 0x01, 0x7C, 0x42, 0xC0, 0xBB, 0x06, 0xD4,  // ..|B....
                /* 01A8 */  0xD5, 0xE0, 0xC1, 0x80, 0x0D, 0x3A, 0x1C, 0x66,  // .....:.f
                /* 01B0 */  0xBC, 0x1E, 0x7E, 0xB8, 0x13, 0x38, 0xC9, 0x07,  // ..~..8..
                /* 01B8 */  0x0C, 0x7E, 0xD8, 0xF0, 0xE0, 0x70, 0xF3, 0x3C,  // .~...p.<
                /* 01C0 */  0x99, 0x23, 0x2B, 0x55, 0x80, 0xD9, 0xC3, 0x81,  // .#+U....
                /* 01C8 */  0x0E, 0x12, 0x3E, 0x6D, 0xB0, 0x33, 0x00, 0x46,  // ..>m.3.F
                /* 01D0 */  0xFE, 0x20, 0x50, 0x23, 0x33, 0xB4, 0xC7, 0xFD,  // . P#3...
                /* 01D8 */  0xD2, 0x61, 0xC8, 0xE7, 0x84, 0xC3, 0x62, 0x62,  // .a....bb
                /* 01E0 */  0x4F, 0x1D, 0x74, 0x3C, 0xE0, 0xBF, 0x8C, 0x3C,  // O.t<...<
                /* 01E8 */  0x67, 0x78, 0xFA, 0x9E, 0xAF, 0x09, 0x86, 0x1D,  // gx......
                /* 01F0 */  0x38, 0x7A, 0x20, 0x86, 0x7E, 0xD8, 0x38, 0x8C,  // 8z .~.8.
                /* 01F8 */  0xD3, 0xF0, 0xFD, 0xC3, 0xE7, 0x05, 0x18, 0xA7,  // ........
                /* 0200 */  0x00, 0x8F, 0xDC, 0xFF, 0xFF, 0x43, 0x8A, 0x4F,  // .....C.O
                /* 0208 */  0x13, 0xFC, 0x68, 0xE1, 0xD3, 0x04, 0xBB, 0x1E,  // ..h.....
                /* 0210 */  0x9C, 0xC6, 0x73, 0x80, 0x87, 0x73, 0x56, 0x3E,  // ..s..sV>
                /* 0218 */  0x4C, 0x80, 0xED, 0x7E, 0xC2, 0x46, 0xF4, 0x6E,  // L..~.F.n
                /* 0220 */  0xE1, 0xD1, 0x60, 0x4F, 0x01, 0xE0, 0x3B, 0xBF,  // ..`O..;.
                /* 0228 */  0x80, 0xF3, 0xAE, 0xC1, 0x06, 0x0B, 0xE3, 0xFC,  // ........
                /* 0230 */  0x02, 0x3C, 0x4E, 0x08, 0x1E, 0x02, 0x3F, 0x48,  // .<N...?H
                /* 0238 */  0x78, 0x08, 0x7C, 0x00, 0xCF, 0x1F, 0x67, 0x68,  // x.|...gh
                /* 0240 */  0xA5, 0xF3, 0x42, 0x0E, 0x0C, 0xDE, 0x39, 0x07,  // ..B...9.
                /* 0248 */  0xC6, 0x28, 0x78, 0x9E, 0xC7, 0x86, 0x09, 0x14,  // .(x.....
                /* 0250 */  0xE4, 0x35, 0xA0, 0x50, 0xCF, 0x02, 0x0A, 0xE3,  // .5.P....
                /* 0258 */  0x53, 0x0D, 0xF0, 0xFA, 0xFF, 0x9F, 0x6A, 0x80,  // S.....j.
                /* 0260 */  0xCB, 0xE1, 0x00, 0x77, 0x72, 0x80, 0x7B, 0x2F,  // ...wr.{/
                /* 0268 */  0x60, 0x17, 0x87, 0xE7, 0x1A, 0xB8, 0xA2, 0xCF,  // `.......
                /* 0270 */  0x35, 0x50, 0xEF, 0x2D, 0xC5, 0x8D, 0x51, 0xD7,  // 5P.-..Q.
                /* 0278 */  0x98, 0x20, 0x8F, 0x02, 0x8F, 0x34, 0x51, 0x9E,  // . ...4Q.
                /* 0280 */  0x67, 0xDE, 0x65, 0x22, 0x3C, 0xDB, 0xF8, 0x5A,  // g.e"<..Z
                /* 0288 */  0xE3, 0x29, 0xC4, 0xF1, 0xB5, 0xC6, 0x88, 0x2F,  // .)...../
                /* 0290 */  0x13, 0xEF, 0x36, 0xC6, 0x3D, 0xB8, 0xC7, 0x9A,  // ..6.=...
                /* 0298 */  0x87, 0x1C, 0x83, 0x1C, 0x4D, 0x84, 0x17, 0x83,  // ....M...
                /* 02A0 */  0x80, 0x8F, 0x37, 0x3E, 0xD6, 0x80, 0x57, 0xCC,  // ..7>..W.
                /* 02A8 */  0x0B, 0x45, 0x16, 0x8E, 0x35, 0x80, 0xC6, 0xFF,  // .E..5...
                /* 02B0 */  0xFF, 0xB1, 0x06, 0xB8, 0x61, 0x3D, 0xA0, 0x80,  // ....a=..
                /* 02B8 */  0xEF, 0xC8, 0xC0, 0x6E, 0x28, 0xF0, 0x4E, 0x28,  // ...n(.N(
                /* 02C0 */  0x80, 0x9F, 0xC4, 0x2F, 0x00, 0x1D, 0x39, 0x9C,  // .../..9.
                /* 02C8 */  0x16, 0x44, 0x36, 0xDE, 0x00, 0x3E, 0x05, 0x50,  // .D6..>.P
                /* 02D0 */  0x35, 0x40, 0x9A, 0x26, 0x6C, 0x82, 0xE9, 0xC9,  // 5@.&l...
                /* 02D8 */  0x05, 0xEF, 0x23, 0x81, 0x73, 0x93, 0x28, 0xF9,  // ..#.s.(.
                /* 02E0 */  0xB0, 0x28, 0x9C, 0xB3, 0x1E, 0x44, 0x28, 0x88,  // .(...D(.
                /* 02E8 */  0x01, 0x1D, 0xE4, 0x38, 0x81, 0x3E, 0xA3, 0xF8,  // ...8.>..
                /* 02F0 */  0x20, 0x72, 0xA2, 0x4F, 0x84, 0x1E, 0x94, 0x87,  //  r.O....
                /* 02F8 */  0xF1, 0x8E, 0xC2, 0x4E, 0x20, 0x3E, 0x4C, 0x78,  // ...N >Lx
                /* 0300 */  0xEC, 0x3E, 0x26, 0xF0, 0x7F, 0x8C, 0x67, 0x63,  // .>&...gc
                /* 0308 */  0x74, 0xAB, 0xC1, 0xD0, 0xFF, 0xFF, 0x9C, 0xC2,  // t.......
                /* 0310 */  0xC1, 0x7C, 0x10, 0xE1, 0x04, 0x75, 0xDD, 0x24,  // .|...u.$
                /* 0318 */  0x40, 0xA6, 0xEF, 0xA8, 0x00, 0x0A, 0x20, 0xDF,  // @..... .
                /* 0320 */  0x0B, 0x7C, 0x0E, 0x78, 0x36, 0x60, 0x63, 0x78,  // .|.x6`cx
                /* 0328 */  0x14, 0x30, 0x9A, 0xD1, 0x79, 0xF8, 0xC9, 0xA2,  // .0..y...
                /* 0330 */  0xE2, 0x4E, 0x96, 0x82, 0x78, 0xB2, 0x8E, 0x32,  // .N..x..2
                /* 0338 */  0x59, 0xF4, 0x4C, 0x7C, 0xAF, 0xF0, 0x8C, 0xDE,  // Y.L|....
                /* 0340 */  0xB4, 0x3C, 0x47, 0x4F, 0xD8, 0xF7, 0x10, 0x58,  // .<GO...X
                /* 0348 */  0x87, 0x81, 0x90, 0x0F, 0x06, 0x9E, 0x86, 0xE1,  // ........
                /* 0350 */  0x3C, 0x59, 0x0E, 0xE7, 0xC9, 0xF2, 0xB1, 0xF8,  // <Y......
                /* 0358 */  0x1A, 0x02, 0x3E, 0x81, 0xB3, 0x05, 0x39, 0x3C,  // ..>...9<
                /* 0360 */  0x26, 0xD6, 0xA8, 0xE8, 0x55, 0xC8, 0xC3, 0xE3,  // &...U...
                /* 0368 */  0x97, 0x03, 0xCF, 0xE7, 0x19, 0xE1, 0x28, 0x9F,  // ......(.
                /* 0370 */  0x24, 0x70, 0x18, 0xCF, 0x24, 0x1E, 0xA2, 0x6F,  // $p..$..o
                /* 0378 */  0x45, 0xB0, 0x26, 0x72, 0xD2, 0xBE, 0x2D, 0x9C,  // E.&r..-.
                /* 0380 */  0x6C, 0xD0, 0xD7, 0x33, 0xCC, 0xAD, 0x08, 0xF6,  // l..3....
                /* 0388 */  0xFF, 0xFF, 0x56, 0x04, 0xE7, 0x82, 0x06, 0x33,  // ..V....3
                /* 0390 */  0xD3, 0xBD, 0x0A, 0x15, 0xEB, 0x5E, 0x05, 0x88,  // .....^..
                /* 0398 */  0x1D, 0xD6, 0x6B, 0x8F, 0x0F, 0x56, 0x70, 0xEF,  // ..k..Vp.
                /* 03A0 */  0x55, 0x70, 0x2F, 0x55, 0xCF, 0x0A, 0xC7, 0x18,  // Up/U....
                /* 03A8 */  0xFE, 0x61, 0x2A, 0xC6, 0x29, 0xBD, 0x76, 0x1A,  // .a*.).v.
                /* 03B0 */  0x28, 0x4C, 0x94, 0x78, 0xEF, 0x55, 0x1E, 0xE3,  // (L.x.U..
                /* 03B8 */  0x7B, 0x15, 0xBB, 0x42, 0x85, 0x89, 0xF5, 0x72,  // {..B...r
                /* 03C0 */  0x65, 0xD4, 0xD7, 0x89, 0x70, 0x81, 0x82, 0x44,  // e...p..D
                /* 03C8 */  0x7A, 0xB5, 0x8A, 0x12, 0x39, 0xBE, 0x21, 0xDF,  // z...9.!.
                /* 03D0 */  0xAB, 0xC0, 0x2B, 0xE7, 0x5E, 0x05, 0xB2, 0xFF,  // ..+.^...
                /* 03D8 */  0xFF, 0xBD, 0x0A, 0x30, 0x8F, 0xF6, 0x5E, 0x05,  // ...0..^.
                /* 03E0 */  0xC6, 0x6B, 0x03, 0xBB, 0x21, 0xC1, 0x02, 0x7A,  // .k..!..z
                /* 03E8 */  0xB1, 0x02, 0x0C, 0x65, 0xBE, 0x58, 0xD1, 0xBC,  // ...e.X..
                /* 03F0 */  0x17, 0x2B, 0xC4, 0xFF, 0xFF, 0x5C, 0xC2, 0xF4,  // .+...\..
                /* 03F8 */  0x5C, 0xAC, 0xC8, 0x3C, 0xE1, 0xDF, 0xAC, 0x00,  // \..<....
                /* 0400 */  0x4E, 0xFF, 0xFF, 0x6F, 0x56, 0x80, 0xB1, 0x7B,  // N..oV..{
                /* 0408 */  0x11, 0xE6, 0x68, 0x05, 0x2F, 0xE5, 0xCD, 0x8A,  // ..h./...
                /* 0410 */  0xC6, 0x59, 0x86, 0x02, 0x2E, 0x88, 0xC2, 0xF8,  // .Y......
                /* 0418 */  0x66, 0x05, 0x38, 0xBA, 0xAE, 0xE0, 0x86, 0x0C,  // f.8.....
                /* 0420 */  0x17, 0x2C, 0x4A, 0x30, 0x1F, 0x42, 0x3C, 0x9D,  // .,J0.B<.
                /* 0428 */  0x23, 0x7E, 0x48, 0x78, 0x09, 0x78, 0xCC, 0xF1,  // #~Hx.x..
                /* 0430 */  0x80, 0x1F, 0x08, 0x7C, 0xB9, 0x02, 0xD3, 0xFF,  // ...|....
                /* 0438 */  0x9F, 0xC0, 0x27, 0xDF, 0xB3, 0x7C, 0x9B, 0x7A,  // ..'..|.z
                /* 0440 */  0xEF, 0xE5, 0x07, 0xAC, 0xF7, 0x2A, 0x1F, 0x7E,  // .....*.~
                /* 0448 */  0x63, 0xBD, 0x33, 0xBC, 0x5C, 0x79, 0x24, 0x51,  // c.3.\y$Q
                /* 0450 */  0x4E, 0x22, 0x94, 0xEF, 0x56, 0xEF, 0x55, 0x46,  // N"..V.UF
                /* 0458 */  0x89, 0xF8, 0x42, 0xEC, 0x53, 0xB0, 0xA1, 0x8D,  // ..B.S...
                /* 0460 */  0xF2, 0x54, 0x11, 0xDD, 0x78, 0x2F, 0x57, 0xE0,  // .T..x/W.
                /* 0468 */  0x95, 0x74, 0xB9, 0x02, 0x68, 0x32, 0xFC, 0x97,  // .t..h2..
                /* 0470 */  0x2B, 0xF0, 0xDD, 0x1C, 0xB0, 0xD7, 0x24, 0x38,  // +.....$8
                /* 0478 */  0xFF, 0xFF, 0x6B, 0x12, 0xBF, 0x5E, 0x01, 0x7E,  // ..k..^.~
                /* 0480 */  0xB2, 0x5F, 0xAF, 0x68, 0xEE, 0xEB, 0x15, 0x4A,  // ._.h...J
                /* 0488 */  0x14, 0x84, 0x14, 0x01, 0x69, 0xA6, 0xE0, 0xB9,  // ....i...
                /* 0490 */  0x5F, 0x01, 0x9C, 0xF8, 0xFF, 0xDF, 0xAF, 0x00,  // _.......
                /* 0498 */  0xCB, 0xE1, 0xEE, 0x57, 0x40, 0xEF, 0x76, 0x04,  // ...W@.v.
                /* 04A0 */  0x5E, 0x94, 0xB7, 0x23, 0xEC, 0x15, 0x0B, 0x9F,  // ^..#....
                /* 04A8 */  0xF1, 0x8A, 0x45, 0xC3, 0xAC, 0x44, 0xF1, 0xD6,  // ..E..D..
                /* 04B0 */  0x44, 0x61, 0x7C, 0xC5, 0x02, 0x26, 0xFF, 0xFF,  // Da|..&..
                /* 04B8 */  0x2B, 0x16, 0x30, 0x3B, 0x88, 0xE2, 0x46, 0x0D,  // +.0;..F.
                /* 04C0 */  0xF7, 0xE2, 0xE4, 0x5B, 0x8F, 0xE7, 0x1B, 0xD1,  // ...[....
                /* 04C8 */  0x77, 0x18, 0xCC, 0x09, 0x0B, 0xC6, 0x0D, 0x0B,  // w.......
                /* 04D0 */  0xFE, 0x90, 0x1E, 0x86, 0x7D, 0x92, 0x78, 0xC7,  // ....}.x.
                /* 04D8 */  0xF2, 0xD1, 0xCA, 0x20, 0x6F, 0xC0, 0x4F, 0x56,  // ... o.OV
                /* 04E0 */  0x0F, 0x56, 0x51, 0x8C, 0x10, 0xF0, 0x78, 0xDE,  // .VQ...x.
                /* 04E8 */  0x85, 0x7D, 0xB4, 0x7A, 0xD3, 0x32, 0x4A, 0xEC,  // .}.z.2J.
                /* 04F0 */  0x58, 0xBE, 0x50, 0x3D, 0x6B, 0xF9, 0x9A, 0x65,  // X.P=k..e
                /* 04F8 */  0x88, 0xB8, 0x0F, 0xC4, 0xBE, 0x61, 0x01, 0xB6,  // .....a..
                /* 0500 */  0xFF, 0xFF, 0x37, 0x2C, 0xC0, 0xD1, 0xC5, 0x81,  // ..7,....
                /* 0508 */  0x1F, 0x1C, 0xB0, 0x37, 0x2C, 0xC0, 0xE7, 0x4C,  // ...7,..L
                /* 0510 */  0xC1, 0x73, 0xC3, 0x02, 0x36, 0xFF, 0xFF, 0x1B,  // .s..6...
                /* 0518 */  0x16, 0xC0, 0xFF, 0xFF, 0xFF, 0x0D, 0x0B, 0x38,  // .......8
                /* 0520 */  0xDC, 0xAE, 0xB0, 0xB7, 0x2C, 0xEC, 0xED, 0x85,  // ....,...
                /* 0528 */  0xAC, 0x82, 0x86, 0x5A, 0x89, 0x82, 0x7F, 0xAF,  // ...Z....
                /* 0530 */  0x0C, 0x43, 0x6F, 0x58, 0x80, 0xA3, 0x71, 0x7B,  // .CoX..q{
                /* 0538 */  0xD4, 0xE0, 0x38, 0x1B, 0x3C, 0x49, 0x60, 0xCE,  // ..8.<I`.
                /* 0540 */  0xD5, 0xB8, 0xD9, 0x1C, 0x5C, 0xE0, 0x08, 0xBD,  // ....\...
                /* 0548 */  0x83, 0x6A, 0xEE, 0xEC, 0x92, 0x02, 0xE3, 0x96,  // .j......
                /* 0550 */  0x05, 0xF7, 0x52, 0xF5, 0xD0, 0x10, 0xE5, 0x20,  // ..R.... 
                /* 0558 */  0x5E, 0x85, 0x1F, 0xAC, 0x1E, 0xA5, 0x8E, 0xEC,  // ^.......
                /* 0560 */  0xF1, 0xEA, 0x69, 0xD8, 0xC7, 0x2C, 0xDF, 0xB2,  // ..i..,..
                /* 0568 */  0x0C, 0x15, 0xE1, 0x2D, 0x8B, 0x9D, 0x21, 0xE2,  // ...-..!.
                /* 0570 */  0xC5, 0x8A, 0x12, 0xE2, 0xBD, 0x22, 0xB4, 0xEF,  // ....."..
                /* 0578 */  0x5C, 0x06, 0x7F, 0x34, 0x36, 0x6A, 0xD0, 0x97,  // \..46j..
                /* 0580 */  0xE3, 0xB7, 0x2C, 0x78, 0xFF, 0xFF, 0x5B, 0x16,  // ..,x..[.
                /* 0588 */  0x7C, 0x91, 0x7F, 0x15, 0x9D, 0x08, 0x7C, 0xCB,  // |.....|.
                /* 0590 */  0x02, 0xF8, 0x11, 0x0C, 0x42, 0x4E, 0x06, 0x8E,  // ....BN..
                /* 0598 */  0x3E, 0x2F, 0xE0, 0x07, 0xF0, 0x30, 0xE2, 0x21,  // >/...0.!
                /* 05A0 */  0xB1, 0x00, 0x03, 0xA7, 0xF7, 0x25, 0x9F, 0x29,  // .....%.)
                /* 05A8 */  0xF8, 0x01, 0xC3, 0x67, 0x0A, 0x76, 0x3D, 0x88,  // ...g.v=.
                /* 05B0 */  0xFE, 0x18, 0xE0, 0x73, 0x09, 0x66, 0x70, 0xE0,  // ...s.fp.
                /* 05B8 */  0xBF, 0x56, 0x1C, 0xBA, 0x47, 0xF1, 0xFA, 0x60,  // .V..G..`
                /* 05C0 */  0x02, 0x0F, 0x8E, 0xFF, 0xFF, 0x07, 0x07, 0xF7,  // ........
                /* 05C8 */  0xCE, 0x70, 0x44, 0xBE, 0xC3, 0x78, 0x70, 0x60,  // .pD..xp`
                /* 05D0 */  0x3B, 0x08, 0x00, 0x87, 0xC1, 0xE1, 0x43, 0x0D,  // ;.....C.
                /* 05D8 */  0x0E, 0x3D, 0x1E, 0x03, 0x87, 0xF4, 0x79, 0x8C,  // .=....y.
                /* 05E0 */  0x5D, 0x18, 0x1E, 0x72, 0x3C, 0x34, 0xB0, 0x01,  // ]..r<4..
                /* 05E8 */  0x7A, 0x68, 0xC0, 0x72, 0x12, 0x4F, 0x21, 0x87,  // zh.r.O!.
                /* 05F0 */  0x06, 0x66, 0x09, 0x43, 0x03, 0x4A, 0xF1, 0x86,  // .f.C.J..
                /* 05F8 */  0x46, 0xFF, 0xFF, 0x43, 0xE3, 0x43, 0xF2, 0x61,  // F..C.C.a
                /* 0600 */  0x21, 0xE6, 0x53, 0x4E, 0x84, 0xF7, 0x05, 0x9F,  // !.SN....
                /* 0608 */  0xA0, 0x18, 0xFA, 0x6B, 0x8A, 0x6F, 0x17, 0xBE,  // ...k.o..
                /* 0610 */  0x09, 0xE2, 0xC6, 0x07, 0xAE, 0x4B, 0xA7, 0xC7,  // .....K..
                /* 0618 */  0x07, 0x7C, 0x8E, 0x5C, 0x1E, 0x1F, 0xEE, 0xE8,  // .|.\....
                /* 0620 */  0xE4, 0xF1, 0xC1, 0x70, 0x79, 0x95, 0x21, 0x47,  // ...py.!G
                /* 0628 */  0x13, 0x1F, 0xAD, 0xD8, 0xF0, 0xC0, 0x76, 0xD3,  // ......v.
                /* 0630 */  0xF3, 0xF0, 0x80, 0xCF, 0x75, 0x13, 0x8C, 0x57,  // ....u..W
                /* 0638 */  0x48, 0x7E, 0x2D, 0x81, 0x71, 0x82, 0xC2, 0x5F,  // H~-.q.._
                /* 0640 */  0x37, 0xC1, 0xFB, 0xFF, 0xBF, 0x6E, 0x02, 0xCF,  // 7....n..
                /* 0648 */  0x51, 0x70, 0xAD, 0x97, 0x6C, 0x1A, 0xE4, 0x95,  // Qp..l...
                /* 0650 */  0xA3, 0x58, 0x2F, 0x02, 0x0A, 0xE3, 0x33, 0x1B,  // .X/...3.
                /* 0658 */  0xE0, 0x68, 0xAC, 0xCF, 0x6C, 0x60, 0xB9, 0x17,  // .h..l`..
                /* 0660 */  0xB0, 0x1B, 0x1B, 0xDC, 0xD3, 0x1A, 0xEC, 0xBB,  // ........
                /* 0668 */  0xC3, 0xC3, 0xD9, 0x63, 0xDA, 0xA3, 0xDA, 0x03,  // ...c....
                /* 0670 */  0x9A, 0x8F, 0xD8, 0x31, 0xDE, 0xD2, 0x82, 0xC4,  // ...1....
                /* 0678 */  0x89, 0xF0, 0x3A, 0xF0, 0xB4, 0xE6, 0x4B, 0x46,  // ..:...KF
                /* 0680 */  0xBC, 0x40, 0x4F, 0x6B, 0xC6, 0x88, 0xF3, 0xD2,  // .@Ok....
                /* 0688 */  0x66, 0xC4, 0x57, 0x8A, 0x10, 0x0F, 0x6B, 0x3E,  // f.W...k>
                /* 0690 */  0xB9, 0x19, 0xEF, 0x61, 0x22, 0x5C, 0x98, 0x17,  // ...a"\..
                /* 0698 */  0xB6, 0xA7, 0x35, 0x70, 0xFC, 0xFF, 0x4F, 0x6B,  // ..5p..Ok
                /* 06A0 */  0x70, 0xE4, 0x5C, 0xB1, 0x01, 0x9A, 0x5C, 0xF4,  // p.\...\.
                /* 06A8 */  0x71, 0x87, 0x14, 0xB0, 0x5C, 0x1B, 0xD8, 0x2D,  // q...\..-
                /* 06B0 */  0x05, 0xDE, 0x05, 0x1B, 0x38, 0xFF, 0xFF, 0x8F,  // ....8...
                /* 06B8 */  0x28, 0xE0, 0xCB, 0x72, 0xC1, 0xA6, 0x39, 0x2E,  // (..r..9.
                /* 06C0 */  0xD8, 0x28, 0x0E, 0xAB, 0x01, 0xD2, 0x3C, 0xE1,  // .(....<.
                /* 06C8 */  0x5F, 0xAF, 0xC1, 0x3F, 0x09, 0x5F, 0xAF, 0x01,  // _..?._..
                /* 06D0 */  0xDB, 0xB7, 0x58, 0xDC, 0xF5, 0x1A, 0x58, 0xFD,  // ..X...X.
                /* 06D8 */  0xFF, 0xAF, 0xD7, 0xC0, 0x52, 0xF0, 0x48, 0xE9,  // ....R.H.
                /* 06E0 */  0x9D, 0x1A, 0x5C, 0x37, 0x6D, 0x3C, 0xE8, 0x9B,  // ..\7m<..
                /* 06E8 */  0x36, 0x4C, 0xC1, 0xB7, 0x28, 0x1A, 0x85, 0x5C,  // 6L..(..\
                /* 06F0 */  0xD1, 0x16, 0x42, 0x61, 0x7C, 0x8B, 0x02, 0x1C,  // ..Ba|...
                /* 06F8 */  0x61, 0xBF, 0x45, 0x81, 0xE5, 0xE2, 0xF4, 0x16,  // a.E.....
                /* 0700 */  0x85, 0x9F, 0x81, 0x07, 0xED, 0xBB, 0x0E, 0xC3,  // ........
                /* 0708 */  0xF4, 0x1D, 0x1A, 0xFE, 0xA9, 0xE9, 0xB9, 0xE9,  // ........
                /* 0710 */  0xC1, 0xE9, 0xA1, 0xD9, 0x07, 0x29, 0x1F, 0x0E,  // .....)..
                /* 0718 */  0x9E, 0x9F, 0xFE, 0xFF, 0x31, 0xDE, 0xEB, 0x7C,  // ....1..|
                /* 0720 */  0x93, 0x7A, 0x8D, 0xF2, 0x05, 0xE6, 0x18, 0x22,  // .z....."
                /* 0728 */  0x46, 0x79, 0x99, 0x36, 0x44, 0x3C, 0x9F, 0x9A,  // Fy.6D<..
                /* 0730 */  0x7C, 0x56, 0x88, 0x1B, 0xE2, 0x21, 0xDA, 0x08,  // |V...!..
                /* 0738 */  0x51, 0x9F, 0xA7, 0x3D, 0xA1, 0xD7, 0x28, 0xF0,  // Q..=..(.
                /* 0740 */  0x0A, 0xBA, 0x46, 0x01, 0x34, 0xB9, 0x1F, 0xE1,  // ..F.4...
                /* 0748 */  0xAE, 0x51, 0x60, 0xB9, 0x37, 0xB0, 0xF3, 0x10,  // .Q`.7...
                /* 0750 */  0xBF, 0x12, 0xF9, 0xDA, 0x00, 0xE3, 0x1E, 0x05,  // ........
                /* 0758 */  0xE7, 0xFF, 0x7F, 0x8F, 0x02, 0x6C, 0x84, 0xB9,  // .....l..
                /* 0760 */  0x47, 0xD1, 0x20, 0xF7, 0x28, 0xD4, 0xC9, 0xC4,  // G. .(...
                /* 0768 */  0x97, 0x3A, 0x4F, 0x14, 0x1C, 0xE1, 0x2F, 0x52,  // .:O.../R
                /* 0770 */  0xA8, 0xD8, 0x24, 0x0A, 0x7D, 0x18, 0x42, 0xC5,  // ..$.}.B.
                /* 0778 */  0x3C, 0x8C, 0x50, 0x10, 0x03, 0x3A, 0xC3, 0x89,  // <.P..:..
                /* 0780 */  0x02, 0xAD, 0xE2, 0x44, 0x41, 0x6E, 0x31, 0x9E,  // ...DAn1.
                /* 0788 */  0xD4, 0x63, 0x14, 0xE0, 0x6B, 0x99, 0x1E, 0x2A,  // .c..k..*
                /* 0790 */  0x8F, 0x3C, 0x54, 0x0A, 0xE2, 0xA1, 0x3A, 0xCE,  // .<T...:.
                /* 0798 */  0x50, 0xD1, 0x93, 0xF4, 0xFC, 0x31, 0xFF, 0xFF,  // P....1..
                /* 07A0 */  0x83, 0x03, 0xF6, 0x20, 0x05, 0xF0, 0x42, 0xF5,  // ... ..B.
                /* 07A8 */  0x41, 0x8A, 0x86, 0x21, 0x57, 0xB8, 0x85, 0x50,  // A..!W..P
                /* 07B0 */  0x18, 0x1F, 0xA4, 0x00, 0x47, 0x37, 0x4B, 0xDC,  // ....G7K.
                /* 07B8 */  0x41, 0x0A, 0xC6, 0xFF, 0xFF, 0x20, 0x85, 0x19,  // A.... ..
                /* 07C0 */  0x01, 0x7B, 0x8D, 0x3C, 0x47, 0xC5, 0x7A, 0x5A,  // .{.<G.zZ
                /* 07C8 */  0x67, 0xA0, 0x71, 0xDE, 0x8A, 0x7C, 0x16, 0x64,  // g.q..|.d
                /* 07D0 */  0x17, 0x16, 0x1F, 0x8B, 0x4C, 0xE0, 0x93, 0x14,  // ....L...
                /* 07D8 */  0x5C, 0x8C, 0xA7, 0x5B, 0x1F, 0x6A, 0x0D, 0xF2,  // \..[.j..
                /* 07E0 */  0xF0, 0xF4, 0x74, 0xEB, 0xB3, 0xD4, 0xFB, 0x53,  // ..t....S
                /* 07E8 */  0xA0, 0x43, 0x7D, 0x88, 0xB2, 0xB8, 0x11, 0x90,  // .C}.....
                /* 07F0 */  0xFB, 0xAD, 0xAF, 0x53, 0xCF, 0xB6, 0x46, 0x79,  // ...S..Fy
                /* 07F8 */  0x7A, 0x08, 0x1A, 0x27, 0x62, 0xB4, 0x98, 0x86,  // z..'b...
                /* 0800 */  0x0A, 0x14, 0xE5, 0xCD, 0xCA, 0x27, 0x29, 0x80,  // .....').
                /* 0808 */  0x65, 0xFF, 0xFF, 0x93, 0x14, 0xB8, 0x2E, 0x0E,  // e.......
                /* 0810 */  0xEC, 0xE0, 0x80, 0xBB, 0x37, 0xC0, 0x39, 0x49,  // ....7.9I
                /* 0818 */  0x01, 0x7E, 0xF2, 0x9C, 0xA4, 0xE8, 0x15, 0xD7,  // .~......
                /* 0820 */  0x27, 0x29, 0x2E, 0x0A, 0x42, 0x8A, 0x80, 0x34,  // ')..B..4
                /* 0828 */  0x51, 0xB0, 0x5C, 0x71, 0x01, 0x97, 0xFF, 0xFF,  // Q.\q....
                /* 0830 */  0x2B, 0x2E, 0xC0, 0xC7, 0x58, 0x12, 0xEE, 0xB7,  // +...X...
                /* 0838 */  0x98, 0x20, 0x30, 0xA8, 0xAB, 0x14, 0xF0, 0xFA,  // . 0.....
                /* 0840 */  0xFF, 0x5F, 0xA5, 0x80, 0xCB, 0x15, 0xE0, 0x55,  // ._.....U
                /* 0848 */  0x0A, 0x2C, 0x87, 0xA5, 0x27, 0x85, 0x07, 0x22,  // .,..'.."
                /* 0850 */  0x23, 0xF1, 0x17, 0xC9, 0x7B, 0x83, 0x8D, 0x63,  // #...{..c
                /* 0858 */  0x09, 0xD8, 0x37, 0x13, 0x36, 0xEF, 0x17, 0x29,  // ..7.6..)
                /* 0860 */  0x98, 0xEE, 0x8F, 0xB8, 0x04, 0xE2, 0x89, 0x21,  // .......!
                /* 0868 */  0xF0, 0x5B, 0xCE, 0x91, 0xBE, 0x41, 0x19, 0xE7,  // .[...A..
                /* 0870 */  0xF9, 0xD6, 0x58, 0x4F, 0xB7, 0xEC, 0xCA, 0x74,  // ..XO...t
                /* 0878 */  0x1E, 0x51, 0x62, 0x84, 0x7B, 0x86, 0x8A, 0x11,  // .Qb.{...
                /* 0880 */  0x25, 0xC6, 0x2B, 0x55, 0x90, 0x80, 0x21, 0x9E,  // %.+U..!.
                /* 0888 */  0xA9, 0x42, 0x3E, 0xED, 0x7A, 0xB2, 0x2F, 0x53,  // .B>.z./S
                /* 0890 */  0xB6, 0x7F, 0x93, 0x02, 0x71, 0xFC, 0x17, 0x83,  // ....q...
                /* 0898 */  0x6E, 0x24, 0xBE, 0x49, 0x01, 0xFE, 0xFE, 0xFF,  // n$.I....
                /* 08A0 */  0x37, 0x29, 0xE0, 0x17, 0x78, 0xE0, 0xE8, 0x81,  // 7)..x...
                /* 08A8 */  0x18, 0xFA, 0x91, 0xC5, 0xD3, 0xF0, 0x79, 0xC3,  // ......y.
                /* 08B0 */  0x67, 0x4A, 0x63, 0x1C, 0x93, 0x07, 0xC7, 0x63,  // gJc....c
                /* 08B8 */  0x8D, 0x9C, 0xDE, 0x8A, 0x7C, 0x9E, 0xE0, 0x87,  // ....|...
                /* 08C0 */  0x0B, 0x9F, 0x27, 0xD8, 0x89, 0xE1, 0x34, 0x9E,  // ..'...4.
                /* 08C8 */  0x03, 0x7C, 0x10, 0xC1, 0x1C, 0x27, 0x80, 0xCB,  // .|...'..
                /* 08D0 */  0x39, 0x00, 0x7C, 0xF7, 0x40, 0xDC, 0x0D, 0x0C,  // 9.|.@...
                /* 08D8 */  0x2C, 0x33, 0xC2, 0x8F, 0x08, 0xC6, 0x05, 0x0C,  // ,3......
                /* 08E0 */  0xB8, 0xFE, 0xFF, 0x2F, 0x60, 0xE0, 0x1C, 0x05,  // .../`...
                /* 08E8 */  0xCF, 0x77, 0xEB, 0x04, 0x14, 0xDF, 0x2B, 0xD8,  // .w....+.
                /* 08F0 */  0xD5, 0xE1, 0xF9, 0x01, 0x1C, 0xB7, 0x4E, 0xB8,  // ......N.
                /* 08F8 */  0x07, 0x1B, 0x5F, 0x5F, 0xCE, 0xF2, 0x4C, 0x5F,  // ..__..L_
                /* 0900 */  0x68, 0x9E, 0x6A, 0x18, 0xCC, 0xE3, 0x4D, 0x84,  // h.j...M.
                /* 0908 */  0x38, 0x51, 0x8C, 0x77, 0x96, 0x46, 0x79, 0xFF,  // 8Q.w.Fy.
                /* 0910 */  0x88, 0xF1, 0x6A, 0x13, 0x23, 0x4A, 0xA0, 0x48,  // ..j.#J.H
                /* 0918 */  0x06, 0x36, 0x50, 0xE0, 0xB7, 0x8A, 0x27, 0x12,  // .6P...'.
                /* 0920 */  0x83, 0xFA, 0xD6, 0x09, 0x7C, 0xFE, 0xFF, 0xB7,  // ....|...
                /* 0928 */  0x4E, 0x80, 0x41, 0x17, 0x07, 0x76, 0x4B, 0x81,  // N.A..vK.
                /* 0930 */  0x7F, 0x4A, 0x01, 0xBC, 0xFC, 0xFF, 0x4F, 0x29,  // .J....O)
                /* 0938 */  0x3C, 0xF9, 0xAD, 0x93, 0xA6, 0xBE, 0x75, 0x42,  // <.....uB
                /* 0940 */  0x99, 0x28, 0x58, 0x6E, 0x9D, 0xC0, 0xE0, 0x38,  // .(Xn...8
                /* 0948 */  0xF2, 0xD6, 0x09, 0xF8, 0xBE, 0x5B, 0xF8, 0xD6,  // .....[..
                /* 0950 */  0x09, 0xEC, 0xFF, 0xFF, 0xB7, 0x4E, 0x60, 0x11,  // .....N`.
                /* 0958 */  0x6D, 0x54, 0xF4, 0xAA, 0x89, 0x9F, 0xCF, 0xAB,  // mT......
                /* 0960 */  0x26, 0xCC, 0x0B, 0x28, 0xB8, 0xEE, 0x46, 0xC0,  // &..(..F.
                /* 0968 */  0x49, 0xA1, 0x4D, 0x9F, 0x1A, 0x8D, 0x5A, 0x35,  // I.M...Z5
                /* 0970 */  0x28, 0x53, 0xA3, 0x4C, 0x83, 0x5A, 0x7D, 0x2A,  // (S.L.Z}*
                /* 0978 */  0x35, 0x66, 0xEC, 0x5E, 0x65, 0x69, 0x17, 0x0C,  // 5f.^ei..
                /* 0980 */  0x2A, 0x66, 0x59, 0x1A, 0x97, 0xA3, 0x80, 0x50,  // *fY....P
                /* 0988 */  0xD9, 0x57, 0x52, 0x81, 0x38, 0xE4, 0x07, 0x48,  // .WR.8..H
                /* 0990 */  0x80, 0x0E, 0xF6, 0xD1, 0xD2, 0x60, 0xC9, 0xAA,  // .....`..
                /* 0998 */  0x04, 0xE2, 0xF8, 0x26, 0x20, 0x1A, 0x01, 0x91,  // ...& ...
                /* 09A0 */  0x16, 0x15, 0x40, 0x2C, 0x37, 0x88, 0x80, 0xAC,  // ..@,7...
                /* 09A8 */  0x62, 0xCD, 0x02, 0xB2, 0xE6, 0x6F, 0x8D, 0xC0,  // b....o..
                /* 09B0 */  0xAD, 0x53, 0x07, 0x10, 0x4B, 0x09, 0x42, 0x13,  // .S..K.B.
                /* 09B8 */  0xBD, 0x06, 0x04, 0xEA, 0x78, 0x20, 0x1A, 0x0C,  // ....x ..
                /* 09C0 */  0xA1, 0x11, 0x90, 0x83, 0x51, 0x08, 0xC8, 0x32,  // ....Q..2
                /* 09C8 */  0x9C, 0x80, 0x33, 0x01, 0x56, 0x80, 0x98, 0x7C,  // ..3.V..|
                /* 09D0 */  0x10, 0x2A, 0xD8, 0x0B, 0x28, 0x53, 0x0F, 0x22,  // .*..(S."
                /* 09D8 */  0x20, 0x2B, 0x5D, 0xB5, 0x80, 0xAC, 0x1B, 0x44,  //  +]....D
                /* 09E0 */  0x40, 0xCE, 0x6A, 0x06, 0x9C, 0x65, 0x74, 0x03,  // @.j..et.
                /* 09E8 */  0xC4, 0x14, 0xBE, 0x1E, 0x04, 0x62, 0x4D, 0x7A,  // .....bMz
                /* 09F0 */  0x40, 0x99, 0x40, 0x10, 0xDD, 0x42, 0x88, 0x9F,  // @.@..B..
                /* 09F8 */  0xFF, 0x3F, 0x10, 0x93, 0x06, 0x22, 0x20, 0xC7,  // .?..." .
                /* 0A00 */  0xB9, 0xAE, 0x08, 0xDC, 0x71, 0x14, 0x01, 0x52,  // ....q..R
                /* 0A08 */  0x47, 0xC3, 0xA5, 0x20, 0x54, 0xFC, 0xF7, 0x4C,  // G.. T..L
                /* 0A10 */  0x20, 0x16, 0x64, 0x09, 0x8C, 0x82, 0xD0, 0x08,  //  .d.....
                /* 0A18 */  0x9A, 0x40, 0x98, 0x3C, 0x4F, 0x20, 0x2C, 0xD4,  // .@.<O ,.
                /* 0A20 */  0xF7, 0x45, 0x43, 0x70, 0x10, 0x55, 0x43, 0xA4,  // .ECp.UC.
                /* 0A28 */  0xAE, 0x40, 0x58, 0xE0, 0xD7, 0x82, 0x06, 0xE3,  // .@X.....
                /* 0A30 */  0xF4, 0x20, 0x02, 0x72, 0xD2, 0xA7, 0x56, 0x20,  // . .r..V 
                /* 0A38 */  0x92, 0x1B, 0x44, 0x40, 0xCE, 0xFF, 0x3A, 0xD1,  // ..D@..:.
                /* 0A40 */  0x8D, 0x86, 0x3C, 0x31, 0x34, 0x7C, 0xF2, 0x35,  // ..<14|.5
                /* 0A48 */  0x0D, 0x42, 0xC4, 0x3D, 0x4E, 0x83, 0x12, 0xA5,  // .B.=N...
                /* 0A50 */  0x20, 0x02, 0xB2, 0xB2, 0x0F, 0x97, 0x80, 0xAC,  //  .......
                /* 0A58 */  0x13, 0x44, 0x40, 0xD6, 0xFB, 0x03, 0x7B, 0x10,  // .D@...{.
                /* 0A60 */  0x60, 0x0F, 0x2F, 0x1D, 0x04, 0x08, 0x08, 0x4D,  // `./....M
                /* 0A68 */  0xF5, 0xDE, 0x12, 0xA8, 0x23, 0x82, 0x68, 0xA0,  // ....#.h.
                /* 0A70 */  0x44, 0x1D, 0x10, 0x0B, 0x07, 0xA2, 0x01, 0x12,  // D.......
                /* 0A78 */  0x77, 0xE0, 0x2C, 0x9A, 0x3D, 0x20, 0x26, 0xEC,  // w.,.= &.
                /* 0A80 */  0xC7, 0x22, 0x10, 0x0B, 0xF1, 0x07, 0xC2, 0xA4,  // ."......
                /* 0A88 */  0x3F, 0x3C, 0x04, 0x68, 0xC9, 0xCF, 0x9F, 0x03,  // ?<.h....
                /* 0A90 */  0x64, 0x20, 0x34, 0xE0, 0x67, 0x44, 0x43, 0x70,  // d 4.gDCp
                /* 0A98 */  0x5A, 0x10, 0x01, 0x39, 0xD9, 0x3B, 0x44, 0x40,  // Z..9.;D@
                /* 0AA0 */  0xCE, 0x09, 0x22, 0x20, 0xFF, 0xFF, 0x01         // .." ...
            })
        }

        Device (WMI2)
        {
            Name (_HID, EisaId ("PNP0C14") /* Windows Management Instrumentation Device */)  // _HID: Hardware ID
            Name (_UID, 0x02)  // _UID: Unique ID
            Name (_WDG, Buffer (0x64)
            {
                /* 0000 */  0xF1, 0x24, 0xB4, 0xFC, 0x5A, 0x07, 0x0E, 0x4E,  // .$..Z..N
                /* 0008 */  0xBF, 0xC4, 0x62, 0xF3, 0xE7, 0x17, 0x71, 0xFA,  // ..b...q.
                /* 0010 */  0x41, 0x37, 0x01, 0x01, 0xE3, 0x5E, 0xBE, 0xE2,  // A7...^..
                /* 0018 */  0xDA, 0x42, 0xDB, 0x49, 0x83, 0x78, 0x1F, 0x52,  // .B.I.x.R
                /* 0020 */  0x47, 0x38, 0x82, 0x02, 0x41, 0x38, 0x01, 0x02,  // G8..A8..
                /* 0028 */  0x9A, 0x01, 0x30, 0x74, 0xE9, 0xDC, 0x48, 0x45,  // ..0t..HE
                /* 0030 */  0xBA, 0xB0, 0x9F, 0xDE, 0x09, 0x35, 0xCA, 0xFF,  // .....5..
                /* 0038 */  0x41, 0x39, 0x14, 0x05, 0x03, 0x70, 0xF4, 0x7F,  // A9...p..
                /* 0040 */  0x6C, 0x3B, 0x5E, 0x4E, 0xA2, 0x27, 0xE9, 0x79,  // l;^N.'.y
                /* 0048 */  0x82, 0x4A, 0x85, 0xD1, 0x41, 0x41, 0x01, 0x06,  // .J..AA..
                /* 0050 */  0x21, 0x12, 0x90, 0x05, 0x66, 0xD5, 0xD1, 0x11,  // !...f...
                /* 0058 */  0xB2, 0xF0, 0x00, 0xA0, 0xC9, 0x06, 0x29, 0x10,  // ......).
                /* 0060 */  0x42, 0x42, 0x01, 0x00                           // BB..
            })
            Name (PREL, Buffer (0x08)
            {
                 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   // ........
            })
            Method (WQA7, 1, NotSerialized)
            {
                Acquire (^^WMI1.MWMI, 0xFFFF)
                WMIS (0x07, Zero)
                PREL [Zero] = WLS0 /* \WLS0 */
                PREL [One] = WLS1 /* \WLS1 */
                PREL [0x02] = WLS2 /* \WLS2 */
                PREL [0x03] = WLS3 /* \WLS3 */
                PREL [0x04] = WLS4 /* \WLS4 */
                PREL [0x05] = WLS5 /* \WLS5 */
                PREL [0x06] = WLS6 /* \WLS6 */
                PREL [0x07] = WLS7 /* \WLS7 */
                Release (^^WMI1.MWMI)
                Return (PREL) /* \_SB_.WMI2.PREL */
            }

            Method (WMA8, 3, NotSerialized)
            {
                CreateByteField (Arg2, Zero, PRE0)
                CreateByteField (Arg2, One, PRE1)
                CreateByteField (Arg2, 0x02, PRE2)
                CreateByteField (Arg2, 0x03, PRE3)
                CreateByteField (Arg2, 0x04, PRE4)
                CreateByteField (Arg2, 0x05, PRE5)
                CreateByteField (Arg2, 0x06, PRE6)
                CreateByteField (Arg2, 0x07, PRE7)
                Acquire (^^WMI1.MWMI, 0xFFFF)
                WLS0 = PRE0 /* \_SB_.WMI2.WMA8.PRE0 */
                WLS1 = PRE1 /* \_SB_.WMI2.WMA8.PRE1 */
                WLS2 = PRE2 /* \_SB_.WMI2.WMA8.PRE2 */
                WLS3 = PRE3 /* \_SB_.WMI2.WMA8.PRE3 */
                WLS4 = PRE4 /* \_SB_.WMI2.WMA8.PRE4 */
                WLS5 = PRE5 /* \_SB_.WMI2.WMA8.PRE5 */
                WLS6 = PRE6 /* \_SB_.WMI2.WMA8.PRE6 */
                WLS7 = PRE7 /* \_SB_.WMI2.WMA8.PRE7 */
                WMIS (0x08, Zero)
                Release (^^WMI1.MWMI)
            }

            Name (ITEM, Package (0x0B)
            {
                Package (0x02)
                {
                    Zero, 
                    "InhibitEnteringThinkPadSetup"
                }, 

                Package (0x02)
                {
                    0x03, 
                    "MTMSerialConcatenation"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "SwapProductName"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "ComputraceMsgDisable"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "CpuDebugEnable"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "PasswordAfterBootDeviceList"
                }, 

                Package (0x02)
                {
                    0x02, 
                    "SpecialCharForPassword"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "CustomPasswordMode"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "AbsoluteFree"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "ShutdownByBottomCoverTamper"
                }, 

                Package (0x02)
                {
                    Zero, 
                    "TpmClearByBottomCoverTamper"
                }
            })
            Name (VSEL, Package (0x04)
            {
                Package (0x02)
                {
                    "Disable", 
                    "Enable"
                }, 

                Package (0x02)
                {
                    "Off", 
                    "On"
                }, 

                Package (0x25)
                {
                    "409", 
                    "c0c", 
                    "1009", 
                    "80a", 
                    "416", 
                    "813", 
                    "406", 
                    "40a", 
                    "40c", 
                    "407", 
                    "40e", 
                    "40f", 
                    "410", 
                    "414", 
                    "816", 
                    "424", 
                    "40b", 
                    "807", 
                    "41f", 
                    "809", 
                    "411", 
                    "412", 
                    "404", 
                    "841f", 
                    "425", 
                    "8406", 
                    "405", 
                    "401", 
                    "402", 
                    "408", 
                    "40d", 
                    "419", 
                    "8409", 
                    "41e", 
                    "4009", 
                    "9009", 
                    "422"
                }, 

                Package (0x06)
                {
                    "Disable", 
                    "Enable", 
                    "Default", 
                    "MTMSN", 
                    "1SMTMSN", 
                    "MTSN"
                }
            })
            Method (WQA9, 1, NotSerialized)
            {
                Acquire (^^WMI1.MWMI, 0xFFFF)
                If ((WMIS (0x09, Arg0) != Zero))
                {
                    Release (^^WMI1.MWMI)
                    Return ("")
                }

                Local0 = DerefOf (ITEM [WITM])
                Local1 = DerefOf (Local0 [Zero])
                Local2 = DerefOf (Local0 [One])
                Concatenate (Local2, ",", Local6)
                Local3 = DerefOf (VSEL [Local1])
                Concatenate (Local6, DerefOf (Local3 [WSEL]), Local7)
                Release (^^WMI1.MWMI)
                Return (Local7)
            }

            Method (WMAA, 3, NotSerialized)
            {
                Acquire (^^WMI1.MWMI, 0xFFFF)
                If ((SizeOf (Arg2) == Zero))
                {
                    Local0 = 0x02
                }
                Else
                {
                    Local0 = ^^WMI1.CARG (Arg2)
                    If ((Local0 == Zero))
                    {
                        Local0 = ^^WMI1.WSET (ITEM, VSEL)
                        If ((Local0 == Zero))
                        {
                            Local0 = WMIS (0x0A, Zero)
                        }
                    }
                }

                Release (^^WMI1.MWMI)
                Return (DerefOf (^^WMI1.RETN [Local0]))
            }

            Name (WQBB, Buffer (0x0538)
            {
                /* 0000 */  0x46, 0x4F, 0x4D, 0x42, 0x01, 0x00, 0x00, 0x00,  // FOMB....
                /* 0008 */  0x28, 0x05, 0x00, 0x00, 0xAE, 0x18, 0x00, 0x00,  // (.......
                /* 0010 */  0x44, 0x53, 0x00, 0x01, 0x1A, 0x7D, 0xDA, 0x54,  // DS...}.T
                /* 0018 */  0x98, 0xDE, 0x8B, 0x00, 0x01, 0x06, 0x18, 0x42,  // .......B
                /* 0020 */  0x10, 0x0D, 0x10, 0x8A, 0x0D, 0x21, 0x02, 0x0B,  // .....!..
                /* 0028 */  0x83, 0x50, 0x50, 0x18, 0x14, 0xA0, 0x45, 0x41,  // .PP...EA
                /* 0030 */  0xC8, 0x05, 0x14, 0x95, 0x02, 0x21, 0xC3, 0x02,  // .....!..
                /* 0038 */  0x14, 0x0B, 0x70, 0x2E, 0x40, 0xBA, 0x00, 0xE5,  // ..p.@...
                /* 0040 */  0x28, 0x72, 0x0C, 0x22, 0x02, 0xF7, 0xEF, 0x0F,  // (r."....
                /* 0048 */  0x31, 0x10, 0x88, 0x14, 0x40, 0x48, 0x28, 0x84,  // 1...@H(.
                /* 0050 */  0x44, 0x00, 0x53, 0x21, 0x70, 0x84, 0xA0, 0x5F,  // D.S!p.._
                /* 0058 */  0x01, 0x08, 0x1D, 0x0A, 0x90, 0x29, 0xC0, 0xA0,  // .....)..
                /* 0060 */  0x00, 0xA7, 0x08, 0x22, 0x88, 0xD2, 0xB2, 0x00,  // ..."....
                /* 0068 */  0xDD, 0x02, 0x7C, 0x0B, 0xD0, 0x0E, 0x21, 0xB4,  // ..|...!.
                /* 0070 */  0xC8, 0x95, 0x0A, 0xB0, 0x08, 0x25, 0x9F, 0x80,  // .....%..
                /* 0078 */  0x92, 0x88, 0x22, 0xD9, 0x78, 0xB2, 0x8D, 0x48,  // ..".x..H
                /* 0080 */  0xE6, 0x61, 0x91, 0x83, 0x40, 0x89, 0x19, 0x04,  // .a..@...
                /* 0088 */  0x4A, 0x27, 0xAE, 0x6C, 0xE2, 0x6A, 0x10, 0x07,  // J'.l.j..
                /* 0090 */  0x10, 0xE5, 0x3C, 0xA2, 0x24, 0x38, 0xAA, 0x83,  // ..<.$8..
                /* 0098 */  0x88, 0x10, 0xBB, 0x5C, 0x01, 0x92, 0x07, 0x20,  // ...\... 
                /* 00A0 */  0xCD, 0x13, 0x93, 0xF5, 0x39, 0x68, 0x64, 0x6C,  // ....9hdl
                /* 00A8 */  0x04, 0x3C, 0x98, 0x04, 0x10, 0x16, 0x65, 0x9D,  // .<....e.
                /* 00B0 */  0x8A, 0x02, 0x83, 0xF2, 0x00, 0x22, 0x39, 0x63,  // ....."9c
                /* 00B8 */  0x45, 0x01, 0xDB, 0xEB, 0x44, 0x64, 0x72, 0xA0,  // E...Ddr.
                /* 00C0 */  0x54, 0x12, 0x1C, 0x6A, 0x98, 0x9E, 0x5A, 0xF3,  // T..j..Z.
                /* 00C8 */  0x13, 0xD3, 0x44, 0x4E, 0xAD, 0xE9, 0x21, 0x0B,  // ..DN..!.
                /* 00D0 */  0x92, 0x49, 0x1B, 0x0A, 0x6A, 0xEC, 0x9E, 0xD6,  // .I..j...
                /* 00D8 */  0x49, 0x79, 0xA6, 0x11, 0x0F, 0xCA, 0x30, 0x09,  // Iy....0.
                /* 00E0 */  0x3C, 0x0A, 0x86, 0xC6, 0x09, 0xCA, 0x82, 0x90,  // <.......
                /* 00E8 */  0x83, 0x81, 0xA2, 0x00, 0x4F, 0xC2, 0x73, 0x2C,  // ....O.s,
                /* 00F0 */  0x5E, 0x80, 0xF0, 0x11, 0x93, 0xB3, 0x40, 0x8C,  // ^.....@.
                /* 00F8 */  0x04, 0x3E, 0x13, 0x78, 0xE4, 0xC7, 0x8C, 0x1D,  // .>.x....
                /* 0100 */  0x51, 0xB8, 0x80, 0xE7, 0x73, 0x0C, 0x91, 0xE3,  // Q...s...
                /* 0108 */  0x1E, 0x6A, 0x8C, 0xA3, 0x88, 0x7C, 0x38, 0x0C,  // .j...|8.
                /* 0110 */  0xED, 0x74, 0xE3, 0x1C, 0xD8, 0xE9, 0x14, 0x04,  // .t......
                /* 0118 */  0x2E, 0x90, 0x60, 0x3D, 0xCF, 0x59, 0x20, 0xFF,  // ..`=.Y .
                /* 0120 */  0xFF, 0x18, 0x07, 0xC1, 0xF0, 0x8E, 0x01, 0x23,  // .......#
                /* 0128 */  0x03, 0x42, 0x1E, 0x05, 0x58, 0x1D, 0x96, 0x26,  // .B..X..&
                /* 0130 */  0x91, 0xC0, 0xEE, 0x05, 0x68, 0xBC, 0x04, 0x48,  // ....h..H
                /* 0138 */  0xE1, 0x20, 0xA5, 0x0C, 0x42, 0x30, 0x8D, 0x09,  // . ..B0..
                /* 0140 */  0xB0, 0x75, 0x68, 0x90, 0x37, 0x01, 0xD6, 0xAE,  // .uh.7...
                /* 0148 */  0x02, 0x42, 0x89, 0x74, 0x02, 0x71, 0x42, 0x44,  // .B.t.qBD
                /* 0150 */  0x89, 0x18, 0xD4, 0x40, 0x51, 0x6A, 0x43, 0x15,  // ...@QjC.
                /* 0158 */  0x4C, 0x67, 0xC3, 0x13, 0x66, 0xDC, 0x10, 0x31,  // Lg..f..1
                /* 0160 */  0x0C, 0x14, 0xB7, 0xFD, 0x41, 0x90, 0x61, 0xE3,  // ....A.a.
                /* 0168 */  0xC6, 0xEF, 0x41, 0x9D, 0xD6, 0xD9, 0x1D, 0xD3,  // ..A.....
                /* 0170 */  0xAB, 0x82, 0x09, 0x3C, 0xE9, 0x37, 0x84, 0xA7,  // ...<.7..
                /* 0178 */  0x83, 0xA3, 0x38, 0xDA, 0xA8, 0x31, 0x9A, 0x23,  // ..8..1.#
                /* 0180 */  0x65, 0xAB, 0xD6, 0xB9, 0xC2, 0x91, 0xE0, 0x51,  // e......Q
                /* 0188 */  0xE7, 0x05, 0x9F, 0x0C, 0x3C, 0xB4, 0xC3, 0xF6,  // ....<...
                /* 0190 */  0x60, 0xCF, 0xD2, 0x43, 0x38, 0x82, 0x67, 0x86,  // `..C8.g.
                /* 0198 */  0x47, 0x02, 0x8F, 0x81, 0xDD, 0x15, 0x7C, 0x08,  // G.....|.
                /* 01A0 */  0xF0, 0x19, 0x01, 0xEF, 0x1A, 0x50, 0x97, 0x83,  // .....P..
                /* 01A8 */  0x47, 0x03, 0x36, 0xE9, 0x70, 0x98, 0xF1, 0x7A,  // G.6.p..z
                /* 01B0 */  0xEE, 0x9E, 0xBA, 0xCF, 0x18, 0xFC, 0xBC, 0xE1,  // ........
                /* 01B8 */  0xC1, 0xE1, 0x46, 0x7A, 0x32, 0x47, 0x56, 0xAA,  // ..Fz2GV.
                /* 01C0 */  0x00, 0xB3, 0xD7, 0x00, 0x1D, 0x25, 0x7C, 0xE0,  // .....%|.
                /* 01C8 */  0x60, 0x77, 0x81, 0xA7, 0x00, 0x13, 0x58, 0xFE,  // `w....X.
                /* 01D0 */  0x20, 0x50, 0x23, 0x33, 0xB4, 0xC7, 0xFB, 0xDE,  //  P#3....
                /* 01D8 */  0x61, 0xC8, 0x27, 0x85, 0xC3, 0x62, 0x62, 0x0F,  // a.'..bb.
                /* 01E0 */  0x1E, 0x74, 0x3C, 0xE0, 0xBF, 0x8F, 0x3C, 0x69,  // .t<...<i
                /* 01E8 */  0x78, 0xFA, 0x9E, 0xAF, 0x09, 0x06, 0x86, 0x90,  // x.......
                /* 01F0 */  0x95, 0xF1, 0xA0, 0x06, 0x62, 0xE8, 0x57, 0x85,  // ....b.W.
                /* 01F8 */  0xC3, 0x38, 0x0D, 0x9F, 0x40, 0x7C, 0x0E, 0x08,  // .8..@|..
                /* 0200 */  0x12, 0xE3, 0x98, 0x3C, 0x38, 0xFF, 0xFF, 0x09,  // ...<8...
                /* 0208 */  0x1C, 0x6B, 0xE4, 0xF4, 0x9C, 0xE2, 0xF3, 0x04,  // .k......
                /* 0210 */  0x3F, 0x5C, 0xF8, 0x3C, 0xC1, 0x4E, 0x0C, 0xA7,  // ?\.<.N..
                /* 0218 */  0xF1, 0x1C, 0xE0, 0xE1, 0x9C, 0x95, 0x8F, 0x13,  // ........
                /* 0220 */  0xC0, 0x02, 0xE2, 0x75, 0x82, 0x0F, 0x14, 0x3E,  // ...u...>
                /* 0228 */  0xEC, 0xA1, 0x79, 0x14, 0x2F, 0x11, 0x6F, 0x0F,  // ..y./.o.
                /* 0230 */  0x26, 0x88, 0xF6, 0x10, 0x03, 0xC6, 0x19, 0xE1,  // &.......
                /* 0238 */  0xCE, 0x1B, 0x70, 0x4E, 0x31, 0xC0, 0x03, 0xEA,  // ..pN1...
                /* 0240 */  0x10, 0x30, 0x87, 0x09, 0x0F, 0x81, 0x0F, 0xE0,  // .0......
                /* 0248 */  0x19, 0xE4, 0x1C, 0x7D, 0xCC, 0x39, 0x33, 0xDC,  // ...}.93.
                /* 0250 */  0x71, 0x07, 0x6C, 0xC3, 0xE0, 0x91, 0x2D, 0x80,  // q.l...-.
                /* 0258 */  0xB0, 0x38, 0x4F, 0x02, 0x05, 0x7C, 0x1B, 0x50,  // .8O..|.P
                /* 0260 */  0x18, 0x1F, 0x6E, 0xC0, 0xFB, 0xFF, 0x3F, 0xDC,  // ..n...?.
                /* 0268 */  0x00, 0xD7, 0xF3, 0x01, 0xEE, 0xF8, 0x00, 0xF7,  // ........
                /* 0270 */  0x62, 0xC1, 0x0E, 0x0F, 0x8F, 0x37, 0xC0, 0x60,  // b....7.`
                /* 0278 */  0x48, 0x8F, 0x34, 0x6F, 0x35, 0x31, 0x5E, 0x6D,  // H.4o51^m
                /* 0280 */  0x42, 0x44, 0x78, 0xA8, 0x79, 0xB7, 0x31, 0x52,  // BDx.y.1R
                /* 0288 */  0xBC, 0xC7, 0x1B, 0x76, 0x8D, 0x39, 0x8B, 0x07,  // ...v.9..
                /* 0290 */  0x90, 0x28, 0xC5, 0xA1, 0xE9, 0x62, 0x13, 0x23,  // .(...b.#
                /* 0298 */  0xCA, 0x9B, 0x8D, 0x61, 0xDF, 0x74, 0x0C, 0x14,  // ...a.t..
                /* 02A0 */  0x2A, 0x52, 0x84, 0x30, 0x2F, 0x16, 0x21, 0x1E,  // *R.0/.!.
                /* 02A8 */  0x6F, 0xC0, 0x2C, 0xE9, 0xA5, 0xA2, 0xCF, 0x81,  // o.,.....
                /* 02B0 */  0x8F, 0x37, 0x80, 0x97, 0xFF, 0xFF, 0xF1, 0x06,  // .7......
                /* 02B8 */  0xF0, 0x30, 0x0C, 0x1F, 0x53, 0xC0, 0x76, 0x73,  // .0..S.vs
                /* 02C0 */  0x60, 0xF7, 0x14, 0xF8, 0xE7, 0x14, 0xC0, 0x91,  // `.......
                /* 02C8 */  0x90, 0x47, 0x80, 0x0E, 0x1E, 0x16, 0x01, 0x22,  // .G....."
                /* 02D0 */  0x1B, 0xCF, 0x00, 0x9F, 0x89, 0xA8, 0x40, 0x2A,  // ......@*
                /* 02D8 */  0xCD, 0x14, 0x2C, 0xE3, 0x14, 0xAC, 0x4E, 0x88,  // ..,...N.
                /* 02E0 */  0x5C, 0x06, 0x85, 0x44, 0x40, 0x68, 0x64, 0x86,  // \..D@hd.
                /* 02E8 */  0xF3, 0x21, 0xD1, 0x60, 0x06, 0xF1, 0xF9, 0xC0,  // .!.`....
                /* 02F0 */  0x67, 0x0A, 0x9F, 0x9C, 0xF8, 0xFF, 0xFF, 0xE4,  // g.......
                /* 02F8 */  0x04, 0x9E, 0x83, 0xC9, 0x43, 0x05, 0x2C, 0x44,  // ....C.,D
                /* 0300 */  0x9F, 0x16, 0x38, 0x9C, 0xCF, 0x2C, 0x1C, 0xCE,  // ..8..,..
                /* 0308 */  0x47, 0x12, 0x7E, 0x80, 0xE4, 0x47, 0x25, 0x70,  // G.~..G%p
                /* 0310 */  0x09, 0x3C, 0x34, 0x80, 0x02, 0xC8, 0xF7, 0x03,  // .<4.....
                /* 0318 */  0x9F, 0x03, 0x9E, 0x11, 0xD8, 0x1C, 0x1E, 0x09,  // ........
                /* 0320 */  0x7C, 0x20, 0x60, 0xF0, 0x3C, 0xDA, 0xA8, 0xE8,  // | `.<...
                /* 0328 */  0xD1, 0xC6, 0xC3, 0xE3, 0x47, 0x06, 0xCF, 0xE7,  // ....G...
                /* 0330 */  0x81, 0xE0, 0x28, 0x1F, 0x09, 0x70, 0x18, 0xEF,  // ..(..p..
                /* 0338 */  0x17, 0x1E, 0xA2, 0x4F, 0x39, 0xB0, 0x26, 0x72,  // ...O9.&r
                /* 0340 */  0xD4, 0x16, 0x7D, 0x22, 0x10, 0xE8, 0x33, 0x17,  // ..}"..3.
                /* 0348 */  0xE6, 0x94, 0x03, 0x9C, 0x82, 0x8F, 0x1E, 0x15,  // ........
                /* 0350 */  0xF5, 0x40, 0x0A, 0xDA, 0x93, 0x82, 0xCF, 0x0A,  // .@......
                /* 0358 */  0x3E, 0x7C, 0xC1, 0xFF, 0xFF, 0x1F, 0xBE, 0xE0,  // >|......
                /* 0360 */  0xCC, 0xEB, 0x65, 0xCD, 0x07, 0x8E, 0x38, 0x67,  // ..e...8g
                /* 0368 */  0x71, 0xBA, 0xEF, 0x16, 0xF8, 0x13, 0x29, 0x30,  // q.....)0
                /* 0370 */  0x0B, 0x72, 0x22, 0x45, 0xC1, 0xF8, 0x44, 0x0A,  // .r"E..D.
                /* 0378 */  0xD8, 0xBC, 0x05, 0x60, 0xAF, 0x0B, 0x4F, 0x22,  // ...`..O"
                /* 0380 */  0x30, 0xCE, 0x11, 0xCF, 0x58, 0x30, 0x0F, 0x55,  // 0...X0.U
                /* 0388 */  0xA7, 0xF8, 0x52, 0xF5, 0xC6, 0x10, 0xE1, 0xC9,  // ..R.....
                /* 0390 */  0xEA, 0x35, 0xEA, 0x01, 0xCB, 0x60, 0x2F, 0x02,  // .5...`/.
                /* 0398 */  0x86, 0x79, 0xC5, 0xF2, 0xE9, 0x2A, 0xC4, 0x03,  // .y...*..
                /* 03A0 */  0x96, 0xCF, 0x5A, 0xD1, 0x42, 0x84, 0x8C, 0x12,  // ..Z.B...
                /* 03A8 */  0xEC, 0x15, 0xEB, 0x55, 0xC6, 0x47, 0x2A, 0x83,  // ...U.G*.
                /* 03B0 */  0x07, 0x0C, 0x1B, 0x2D, 0x52, 0x84, 0x47, 0x2C,  // ...-R.G,
                /* 03B8 */  0xFC, 0xFF, 0xFF, 0x88, 0x05, 0x1E, 0x09, 0x07,  // ........
                /* 03C0 */  0x52, 0x80, 0x2A, 0x03, 0xC7, 0x1D, 0x48, 0x81,  // R.*...H.
                /* 03C8 */  0xFD, 0x69, 0x02, 0x7F, 0xBD, 0xF0, 0x78, 0xB0,  // .i....x.
                /* 03D0 */  0xFF, 0xFF, 0x73, 0x00, 0xF8, 0x0E, 0x31, 0xC0,  // ..s...1.
                /* 03D8 */  0x60, 0xC0, 0x30, 0x0E, 0x31, 0xC0, 0x43, 0xF0,  // `.0.1.C.
                /* 03E0 */  0xC9, 0x0C, 0xF4, 0xC7, 0x1D, 0xF8, 0xE3, 0xE0,  // ........
                /* 03E8 */  0x19, 0x9F, 0x1C, 0x26, 0x50, 0x98, 0x13, 0x29,  // ...&P..)
                /* 03F0 */  0x0A, 0xC6, 0x27, 0x52, 0xC0, 0xD9, 0xFF, 0xFF,  // ..'R....
                /* 03F8 */  0x70, 0x05, 0x86, 0xE3, 0x0D, 0xF8, 0x6F, 0x33,  // p.....o3
                /* 0400 */  0x3E, 0x84, 0xFA, 0x7C, 0xE3, 0x0B, 0xA9, 0x21,  // >..|...!
                /* 0408 */  0x5E, 0x6C, 0xDE, 0xD4, 0x5E, 0x09, 0x5E, 0xDF,  // ^l..^.^.
                /* 0410 */  0xD9, 0xB5, 0xE6, 0xF5, 0xDD, 0xA7, 0x82, 0x27,  // .......'
                /* 0418 */  0xD1, 0x08, 0x21, 0xA3, 0xBC, 0xE4, 0x18, 0x24,  // ..!....$
                /* 0420 */  0xC4, 0xEB, 0xA8, 0x01, 0x83, 0x05, 0x89, 0x78,  // .......x
                /* 0428 */  0x0A, 0x4F, 0x3B, 0x8F, 0x37, 0xE0, 0x15, 0x75,  // .O;.7..u
                /* 0430 */  0x20, 0x05, 0xE8, 0xF1, 0xFF, 0x3F, 0x90, 0x02,  //  ....?..
                /* 0438 */  0x83, 0x7B, 0x0A, 0xEC, 0x73, 0x0A, 0xE0, 0x29,  // .{..s..)
                /* 0440 */  0xF9, 0x89, 0x94, 0xA6, 0x3E, 0x91, 0xA2, 0x15,  // ....>...
                /* 0448 */  0x01, 0x69, 0xAA, 0x60, 0x21, 0x98, 0xFE, 0x44,  // .i.`!..D
                /* 0450 */  0x4A, 0x0F, 0x06, 0xCE, 0x4D, 0xA2, 0xE4, 0x43,  // J...M..C
                /* 0458 */  0xA3, 0x70, 0xCE, 0x7A, 0x20, 0xA1, 0x20, 0x06,  // .p.z . .
                /* 0460 */  0x74, 0x90, 0x43, 0x05, 0xFA, 0xAC, 0xE2, 0x03,  // t.C.....
                /* 0468 */  0xC9, 0x81, 0x3C, 0x22, 0x7A, 0x58, 0x3E, 0x54,  // ..<"zX>T
                /* 0470 */  0xFA, 0xAE, 0xE2, 0x73, 0x88, 0x8F, 0x14, 0x1E,  // ...s....
                /* 0478 */  0xBF, 0x0F, 0x0B, 0xFC, 0x3F, 0xE3, 0xE3, 0x28,  // ....?..(
                /* 0480 */  0x03, 0xAF, 0xE6, 0xBC, 0x82, 0x02, 0xF3, 0x69,  // .......i
                /* 0488 */  0x14, 0xA3, 0xEB, 0x3E, 0x01, 0x92, 0xFF, 0xFF,  // ...>....
                /* 0490 */  0xFC, 0xB8, 0xBE, 0xC3, 0x28, 0xC8, 0xD1, 0x79,  // ....(..y
                /* 0498 */  0xF8, 0xC9, 0xA2, 0xE2, 0x4E, 0x96, 0x82, 0x78,  // ....N..x
                /* 04A0 */  0xB2, 0x8E, 0x32, 0x59, 0xF4, 0x4C, 0x7C, 0xBB,  // ..2Y.L|.
                /* 04A8 */  0xF0, 0x8C, 0xDE, 0xBB, 0x7C, 0x83, 0x65, 0x37,  // ....|.e7
                /* 04B0 */  0x59, 0x78, 0x97, 0x81, 0x90, 0x8F, 0x06, 0xBE,  // Yx......
                /* 04B8 */  0xC9, 0xC2, 0x1D, 0x8B, 0x2F, 0x23, 0xE0, 0xBB,  // ..../#..
                /* 04C0 */  0xC9, 0x02, 0x5E, 0x47, 0xE3, 0xB3, 0x05, 0x3B,  // ..^G...;
                /* 04C8 */  0x85, 0xF8, 0xBA, 0x06, 0x4B, 0xA1, 0x4D, 0x9F,  // ....K.M.
                /* 04D0 */  0x1A, 0x8D, 0x5A, 0xFD, 0xFF, 0x1B, 0x94, 0xA9,  // ..Z.....
                /* 04D8 */  0x51, 0xA6, 0x41, 0xAD, 0x3E, 0x95, 0x1A, 0x33,  // Q.A.>..3
                /* 04E0 */  0x76, 0xA1, 0xB0, 0xB8, 0x0B, 0x06, 0x95, 0xB4,  // v.......
                /* 04E8 */  0x2C, 0x8D, 0xCB, 0x81, 0x40, 0x68, 0x80, 0x5B,  // ,...@h.[
                /* 04F0 */  0xA9, 0x40, 0x1C, 0xFA, 0x0B, 0xA4, 0x53, 0x02,  // .@....S.
                /* 04F8 */  0xF9, 0x6A, 0x09, 0xC8, 0x62, 0x57, 0x25, 0x10,  // .j..bW%.
                /* 0500 */  0xCB, 0x54, 0x01, 0xD1, 0xC8, 0xDD, 0xC2, 0x20,  // .T..... 
                /* 0508 */  0x02, 0x72, 0xBC, 0x4F, 0x8D, 0x40, 0x1D, 0x49,  // .r.O.@.I
                /* 0510 */  0x07, 0x10, 0x13, 0xE4, 0x63, 0xAC, 0xF4, 0x25,  // ....c..%
                /* 0518 */  0x20, 0x10, 0xCB, 0xA6, 0x15, 0xA0, 0xE5, 0x3A,  //  ......:
                /* 0520 */  0x01, 0x62, 0x61, 0x41, 0x68, 0xC0, 0x5F, 0xB5,  // .baAh._.
                /* 0528 */  0x86, 0xE0, 0xB4, 0x20, 0x02, 0x72, 0x32, 0x2D,  // ... .r2-
                /* 0530 */  0x40, 0x2C, 0x27, 0x88, 0x80, 0xFC, 0xFF, 0x07   // @,'.....
            })
        }

        Device (WMI3)
        {
            Name (_HID, EisaId ("PNP0C14") /* Windows Management Instrumentation Device */)  // _HID: Hardware ID
            Name (_UID, 0x03)  // _UID: Unique ID
            Name (_WDG, /**** Is ResourceTemplate, but EndTag not at buffer end ****/ Buffer (0x3C)
            {
                /* 0000 */  0x79, 0x36, 0x4D, 0x8F, 0x9E, 0x74, 0x79, 0x44,  // y6M..tyD
                /* 0008 */  0x9B, 0x16, 0xC6, 0x26, 0x01, 0xFD, 0x25, 0xF0,  // ...&..%.
                /* 0010 */  0x41, 0x42, 0x01, 0x02, 0x69, 0xE8, 0xD2, 0x85,  // AB..i...
                /* 0018 */  0x5A, 0x36, 0xCE, 0x4A, 0xA4, 0xD3, 0xCD, 0x69,  // Z6.J...i
                /* 0020 */  0x2B, 0x16, 0x98, 0xA0, 0x41, 0x43, 0x01, 0x02,  // +...AC..
                /* 0028 */  0x21, 0x12, 0x90, 0x05, 0x66, 0xD5, 0xD1, 0x11,  // !...f...
                /* 0030 */  0xB2, 0xF0, 0x00, 0xA0, 0xC9, 0x06, 0x29, 0x10,  // ......).
                /* 0038 */  0x42, 0x43, 0x01, 0x00                           // BC..
            })
            Method (WMAB, 3, NotSerialized)
            {
                CreateByteField (Arg2, Zero, ASS0)
                CreateWordField (Arg2, One, ASS1)
                CreateByteField (Arg2, 0x03, ASS2)
                Acquire (^^WMI1.MWMI, 0xFFFF)
                WASB = ASS0 /* \_SB_.WMI3.WMAB.ASS0 */
                WASI = ASS1 /* \_SB_.WMI3.WMAB.ASS1 */
                WASD = ASS2 /* \_SB_.WMI3.WMAB.ASS2 */
                WMIS (0x0B, Zero)
                Local0 = WASS /* \WASS */
                Release (^^WMI1.MWMI)
                Return (Local0)
            }

            Method (WMAC, 3, NotSerialized)
            {
                CreateByteField (Arg2, Zero, ASS0)
                CreateWordField (Arg2, One, ASS1)
                Acquire (^^WMI1.MWMI, 0xFFFF)
                WASB = ASS0 /* \_SB_.WMI3.WMAC.ASS0 */
                WASI = ASS1 /* \_SB_.WMI3.WMAC.ASS1 */
                WMIS (0x0C, Arg1)
                Local0 = WASS /* \WASS */
                Release (^^WMI1.MWMI)
                Return (Local0)
            }

            Name (WQBC, Buffer (0x040A)
            {
                /* 0000 */  0x46, 0x4F, 0x4D, 0x42, 0x01, 0x00, 0x00, 0x00,  // FOMB....
                /* 0008 */  0xFA, 0x03, 0x00, 0x00, 0x32, 0x12, 0x00, 0x00,  // ....2...
                /* 0010 */  0x44, 0x53, 0x00, 0x01, 0x1A, 0x7D, 0xDA, 0x54,  // DS...}.T
                /* 0018 */  0x98, 0xC3, 0x88, 0x00, 0x01, 0x06, 0x18, 0x42,  // .......B
                /* 0020 */  0x10, 0x07, 0x10, 0x8A, 0x0D, 0x21, 0x02, 0x0B,  // .....!..
                /* 0028 */  0x83, 0x50, 0x50, 0x18, 0x14, 0xA0, 0x45, 0x41,  // .PP...EA
                /* 0030 */  0xC8, 0x05, 0x14, 0x95, 0x02, 0x21, 0xC3, 0x02,  // .....!..
                /* 0038 */  0x14, 0x0B, 0x70, 0x2E, 0x40, 0xBA, 0x00, 0xE5,  // ..p.@...
                /* 0040 */  0x28, 0x72, 0x0C, 0x22, 0x02, 0xF7, 0xEF, 0x0F,  // (r."....
                /* 0048 */  0x31, 0x10, 0x88, 0x14, 0x40, 0x48, 0x28, 0x84,  // 1...@H(.
                /* 0050 */  0x44, 0x00, 0x53, 0x21, 0x70, 0x84, 0xA0, 0x5F,  // D.S!p.._
                /* 0058 */  0x01, 0x08, 0x1D, 0x0A, 0x90, 0x29, 0xC0, 0xA0,  // .....)..
                /* 0060 */  0x00, 0xA7, 0x08, 0x22, 0x88, 0xD2, 0xB2, 0x00,  // ..."....
                /* 0068 */  0xDD, 0x02, 0x7C, 0x0B, 0xD0, 0x0E, 0x21, 0xB4,  // ..|...!.
                /* 0070 */  0x58, 0x07, 0x11, 0x21, 0xD2, 0x31, 0x34, 0x29,  // X..!.14)
                /* 0078 */  0x40, 0xA2, 0x00, 0x8B, 0x02, 0x64, 0xC3, 0xC8,  // @....d..
                /* 0080 */  0x36, 0x22, 0x99, 0x87, 0x45, 0x0E, 0x02, 0x25,  // 6"..E..%
                /* 0088 */  0x66, 0x10, 0x28, 0x9D, 0xE0, 0xB2, 0x89, 0xAB,  // f.(.....
                /* 0090 */  0x41, 0x9C, 0x4C, 0x94, 0xF3, 0x88, 0x92, 0xE0,  // A.L.....
                /* 0098 */  0xA8, 0x0E, 0x22, 0x42, 0xEC, 0x72, 0x05, 0x48,  // .."B.r.H
                /* 00A0 */  0x1E, 0x80, 0x34, 0x4F, 0x4C, 0xD6, 0xE7, 0xA0,  // ..4OL...
                /* 00A8 */  0x91, 0xB1, 0x11, 0xF0, 0x94, 0x1A, 0x40, 0x58,  // ......@X
                /* 00B0 */  0xA0, 0x75, 0x2A, 0xE0, 0x7A, 0x0D, 0x43, 0x3D,  // .u*.z.C=
                /* 00B8 */  0x80, 0x48, 0xCE, 0x58, 0x51, 0xC0, 0xF6, 0x3A,  // .H.XQ..:
                /* 00C0 */  0x11, 0x8D, 0xEA, 0x40, 0x99, 0x24, 0x38, 0xD4,  // ...@.$8.
                /* 00C8 */  0x30, 0x3D, 0xB5, 0xE6, 0x27, 0xA6, 0x89, 0x9C,  // 0=..'...
                /* 00D0 */  0x5A, 0xD3, 0x43, 0x16, 0x24, 0x93, 0x36, 0x14,  // Z.C.$.6.
                /* 00D8 */  0xD4, 0xD8, 0x3D, 0xAD, 0x93, 0xF2, 0x4C, 0x23,  // ..=...L#
                /* 00E0 */  0x1E, 0x94, 0x61, 0x12, 0x78, 0x14, 0x0C, 0x8D,  // ..a.x...
                /* 00E8 */  0x13, 0x94, 0x75, 0x22, 0xA0, 0x03, 0xE5, 0x80,  // ..u"....
                /* 00F0 */  0x27, 0xE1, 0x39, 0x16, 0x2F, 0x40, 0xF8, 0x88,  // '.9./@..
                /* 00F8 */  0xC9, 0xB4, 0x4D, 0xE0, 0x33, 0x81, 0x87, 0x79,  // ..M.3..y
                /* 0100 */  0xCC, 0xD8, 0x11, 0x85, 0x0B, 0x78, 0x3E, 0xC7,  // .....x>.
                /* 0108 */  0x10, 0x39, 0xEE, 0xA1, 0xC6, 0x38, 0x8A, 0xC8,  // .9...8..
                /* 0110 */  0x47, 0x60, 0x24, 0x03, 0xC5, 0x2B, 0x08, 0x89,  // G`$..+..
                /* 0118 */  0x80, 0xF8, 0x76, 0x70, 0x70, 0x91, 0xFC, 0xFF,  // ..vpp...
                /* 0120 */  0x47, 0x89, 0x11, 0x2A, 0xC6, 0xDB, 0x00, 0x6E,  // G..*...n
                /* 0128 */  0x5E, 0x09, 0x8A, 0x1E, 0x07, 0x4A, 0x06, 0x84,  // ^....J..
                /* 0130 */  0x3C, 0x0A, 0xB0, 0x7A, 0x28, 0x20, 0x04, 0x16,  // <..z( ..
                /* 0138 */  0x27, 0x40, 0xE3, 0x38, 0x05, 0xD3, 0x99, 0x00,  // '@.8....
                /* 0140 */  0x6D, 0x02, 0xBC, 0x09, 0x30, 0x27, 0xC0, 0x16,  // m...0'..
                /* 0148 */  0x86, 0x80, 0x82, 0x9C, 0x59, 0x94, 0x20, 0x11,  // ....Y. .
                /* 0150 */  0x42, 0x31, 0x88, 0x0A, 0x05, 0x18, 0x43, 0x14,  // B1....C.
                /* 0158 */  0xCA, 0x3B, 0x41, 0x8C, 0xCA, 0x20, 0x74, 0x82,  // .;A.. t.
                /* 0160 */  0x08, 0x14, 0x3D, 0x78, 0x98, 0xD6, 0x40, 0x74,  // ..=x..@t
                /* 0168 */  0x89, 0xF0, 0xC8, 0xB1, 0x47, 0x00, 0x9F, 0x19,  // ....G...
                /* 0170 */  0xCE, 0xE9, 0x04, 0x1F, 0x01, 0xDE, 0x16, 0x4C,  // .......L
                /* 0178 */  0xE0, 0x79, 0xBF, 0x24, 0x1C, 0x6A, 0xD8, 0x03,  // .y.$.j..
                /* 0180 */  0x8E, 0x1A, 0xE3, 0x28, 0x12, 0x58, 0xD0, 0x33,  // ...(.X.3
                /* 0188 */  0x42, 0x16, 0x40, 0x14, 0x09, 0x1E, 0x75, 0x64,  // B.@...ud
                /* 0190 */  0xF0, 0xE1, 0xC0, 0x23, 0x3B, 0x72, 0xCF, 0xF0,  // ...#;r..
                /* 0198 */  0x04, 0x82, 0x1C, 0xC2, 0x11, 0x3C, 0x36, 0x3C,  // .....<6<
                /* 01A0 */  0x15, 0x78, 0x0C, 0xEC, 0xBA, 0xE0, 0x73, 0x80,  // .x....s.
                /* 01A8 */  0x8F, 0x09, 0x78, 0xD7, 0x80, 0x9A, 0xF3, 0xD3,  // ..x.....
                /* 01B0 */  0x01, 0x9B, 0x72, 0x38, 0xCC, 0x70, 0x3D, 0xFD,  // ..r8.p=.
                /* 01B8 */  0x70, 0x27, 0x70, 0xD2, 0x06, 0x64, 0xB3, 0xF3,  // p'p..d..
                /* 01C0 */  0xE0, 0x70, 0xE3, 0x3C, 0x99, 0x23, 0x2B, 0x55,  // .p.<.#+U
                /* 01C8 */  0x80, 0xD9, 0x13, 0x82, 0x4E, 0x13, 0x3E, 0x73,  // ....N.>s
                /* 01D0 */  0xB0, 0xBB, 0xC0, 0xF9, 0xF4, 0x0C, 0x49, 0xE4,  // ......I.
                /* 01D8 */  0x0F, 0x02, 0x35, 0x32, 0x43, 0xFB, 0x2C, 0xF0,  // ..52C.,.
                /* 01E0 */  0xEA, 0x61, 0xC8, 0x87, 0x85, 0xC3, 0x62, 0x62,  // .a....bb
                /* 01E8 */  0xCF, 0x1E, 0x74, 0x3C, 0xE0, 0x3F, 0x25, 0x3C,  // ..t<.?%<
                /* 01F0 */  0x6C, 0x78, 0xFA, 0x9E, 0xAF, 0x09, 0xA2, 0x3D,  // lx.....=
                /* 01F8 */  0x8F, 0x80, 0xE1, 0xFF, 0x7F, 0x1E, 0x81, 0x39,  // .......9
                /* 0200 */  0x9C, 0x07, 0x84, 0x27, 0x07, 0x76, 0x80, 0xC0,  // ...'.v..
                /* 0208 */  0x1C, 0x48, 0x80, 0xC9, 0xF9, 0x02, 0x77, 0x28,  // .H....w(
                /* 0210 */  0xF0, 0x10, 0xF8, 0x00, 0x1E, 0x25, 0xCE, 0xD1,  // .....%..
                /* 0218 */  0x4A, 0x67, 0x86, 0x3C, 0xB9, 0x80, 0x2D, 0xFB,  // Jg.<..-.
                /* 0220 */  0x1B, 0x40, 0x07, 0x0F, 0xE7, 0x06, 0x91, 0x8D,  // .@......
                /* 0228 */  0x57, 0x80, 0x09, 0x74, 0x38, 0xB1, 0x1E, 0x20,  // W..t8.. 
                /* 0230 */  0x4D, 0x14, 0x0C, 0x04, 0xD3, 0xD3, 0x6B, 0x00,  // M.....k.
                /* 0238 */  0x3E, 0x15, 0x38, 0x37, 0x89, 0x92, 0x0F, 0x8C,  // >.87....
                /* 0240 */  0xC2, 0x39, 0xEB, 0x79, 0x84, 0x82, 0x18, 0xD0,  // .9.y....
                /* 0248 */  0x41, 0x20, 0xE4, 0xE4, 0xA0, 0x80, 0x3A, 0xAA,  // A ....:.
                /* 0250 */  0xF8, 0x3C, 0x72, 0xAA, 0x0F, 0x3D, 0x9E, 0x94,  // .<r..=..
                /* 0258 */  0x47, 0xE1, 0xAB, 0x8A, 0x0F, 0x21, 0x3E, 0x4F,  // G....!>O
                /* 0260 */  0x78, 0xF4, 0x3E, 0x29, 0xF0, 0xEF, 0x8C, 0xAF,  // x.>)....
                /* 0268 */  0x0E, 0x46, 0xB7, 0x9A, 0xE3, 0x0A, 0x0A, 0xCC,  // .F......
                /* 0270 */  0x67, 0x11, 0x4E, 0x50, 0xD7, 0x6D, 0x01, 0xFA,  // g.NP.m..
                /* 0278 */  0x29, 0xE0, 0x08, 0x3C, 0x94, 0x77, 0x92, 0xC7,  // )..<.w..
                /* 0280 */  0x90, 0x04, 0xF5, 0x9D, 0x16, 0x40, 0x01, 0xE4,  // .....@..
                /* 0288 */  0x9B, 0x81, 0x4F, 0x02, 0x21, 0xFE, 0xFF, 0x4F,  // ..O.!..O
                /* 0290 */  0x07, 0x1E, 0xC3, 0xC3, 0x80, 0xD1, 0x8C, 0xCE,  // ........
                /* 0298 */  0xC3, 0x4F, 0x16, 0x15, 0x77, 0xB2, 0x14, 0xC4,  // .O..w...
                /* 02A0 */  0x93, 0x75, 0x94, 0xC9, 0xA2, 0x67, 0xE2, 0xAB,  // .u...g..
                /* 02A8 */  0x85, 0x27, 0x74, 0x4A, 0x41, 0xCE, 0xD1, 0x13,  // .'tJA...
                /* 02B0 */  0xF6, 0x55, 0x04, 0xD6, 0xF9, 0x20, 0xE4, 0x8B,  // .U... ..
                /* 02B8 */  0x81, 0xA7, 0x61, 0x38, 0x4F, 0x96, 0xC3, 0x79,  // ..a8O..y
                /* 02C0 */  0xB2, 0x7C, 0x2C, 0xBE, 0x6A, 0xC0, 0x1F, 0x2D,  // .|,.j..-
                /* 02C8 */  0x96, 0xA0, 0xC0, 0xD9, 0x82, 0x1C, 0x1E, 0x13,  // ........
                /* 02D0 */  0x6F, 0x54, 0xF4, 0x46, 0xE4, 0xE1, 0xF1, 0xCB,  // oT.F....
                /* 02D8 */  0x81, 0xE7, 0xF3, 0x8C, 0x70, 0x94, 0x6F, 0x12,  // ....p.o.
                /* 02E0 */  0x38, 0x8C, 0xC7, 0x12, 0x0F, 0xD1, 0x97, 0x23,  // 8......#
                /* 02E8 */  0x58, 0x13, 0x39, 0x69, 0xDF, 0x16, 0x4E, 0x36,  // X.9i..N6
                /* 02F0 */  0xE8, 0x4B, 0x10, 0xBB, 0x1C, 0x01, 0xBF, 0x88,  // .K......
                /* 02F8 */  0x26, 0x86, 0xC1, 0x22, 0x2D, 0x45, 0x11, 0x17,  // &.."-E..
                /* 0300 */  0x45, 0x61, 0x7C, 0xC5, 0x82, 0xFD, 0xFF, 0xBF,  // Ea|.....
                /* 0308 */  0x62, 0x01, 0x16, 0x04, 0x0F, 0x1B, 0x34, 0x87,  // b.....4.
                /* 0310 */  0x83, 0x97, 0x1E, 0x36, 0x6B, 0x38, 0x07, 0x99,  // ...6k8..
                /* 0318 */  0xD3, 0xF1, 0x48, 0x4E, 0x1B, 0xC6, 0x1D, 0x0B,  // ..HN....
                /* 0320 */  0xFE, 0x9D, 0xEA, 0xA9, 0xCA, 0xD3, 0x8A, 0xF2,  // ........
                /* 0328 */  0x64, 0xF5, 0x7A, 0xE5, 0x63, 0x96, 0xA1, 0xCE,  // d.z.c...
                /* 0330 */  0xE0, 0x1D, 0xCB, 0xB7, 0x3C, 0x4F, 0x21, 0x4A,  // ....<O!J
                /* 0338 */  0x9C, 0x97, 0x2D, 0x76, 0xC7, 0x32, 0x48, 0x50,  // ..-v.2HP
                /* 0340 */  0x23, 0x3F, 0x68, 0x31, 0x94, 0xE0, 0xF1, 0xDE,  // #?h1....
                /* 0348 */  0xB1, 0x00, 0x6F, 0xFF, 0xFF, 0x3B, 0x16, 0x60,  // ..o..;.`
                /* 0350 */  0xFC, 0x04, 0xC1, 0x09, 0x7C, 0xC7, 0x02, 0x1C,  // ....|...
                /* 0358 */  0xC5, 0x7E, 0x37, 0xE8, 0x4A, 0x45, 0xEE, 0x58,  // .~7.JE.X
                /* 0360 */  0x28, 0x0E, 0xAB, 0xB9, 0x63, 0x41, 0x9C, 0x28,  // (...cA.(
                /* 0368 */  0xE6, 0x8A, 0x05, 0x86, 0xFF, 0xFF, 0x15, 0x0B,  // ........
                /* 0370 */  0xE0, 0x75, 0xC0, 0x2B, 0x16, 0x68, 0xFE, 0xFF,  // .u.+.h..
                /* 0378 */  0x57, 0x2C, 0xF0, 0x5E, 0x8E, 0x80, 0xDF, 0x09,  // W,.^....
                /* 0380 */  0xD1, 0x77, 0x0D, 0x7E, 0x9A, 0xB6, 0xA2, 0xBB,  // .w.~....
                /* 0388 */  0x06, 0x94, 0x19, 0xBE, 0x07, 0xF9, 0xB0, 0x13,  // ........
                /* 0390 */  0x2C, 0xD2, 0xA3, 0x8D, 0x6F, 0x49, 0xE1, 0x7C,  // ,...oI.|
                /* 0398 */  0xDB, 0x00, 0xD8, 0xF2, 0xFF, 0xBF, 0x6D, 0x00,  // ......m.
                /* 03A0 */  0x4C, 0x19, 0xBF, 0x6F, 0x1B, 0xC0, 0x4F, 0xA1,  // L..o..O.
                /* 03A8 */  0x4D, 0x9F, 0x1A, 0x8D, 0x5A, 0x35, 0x28, 0x53,  // M...Z5(S
                /* 03B0 */  0xA3, 0x4C, 0x83, 0x5A, 0x7D, 0x2A, 0x35, 0x66,  // .L.Z}*5f
                /* 03B8 */  0x4C, 0xC9, 0xC1, 0xCE, 0x77, 0x0C, 0x2A, 0x6C,  // L...w.*l
                /* 03C0 */  0x65, 0x1A, 0x9A, 0x63, 0x81, 0xD0, 0x10, 0xC7,  // e..c....
                /* 03C8 */  0x26, 0x19, 0x01, 0x51, 0x22, 0x10, 0x01, 0x59,  // &..Q"..Y
                /* 03D0 */  0xFD, 0x6F, 0x42, 0x40, 0xCE, 0x02, 0x22, 0x20,  // .oB@.." 
                /* 03D8 */  0x2B, 0x58, 0x9A, 0xC0, 0x9D, 0xFF, 0xD8, 0x28,  // +X.....(
                /* 03E0 */  0x40, 0xA2, 0x02, 0x84, 0x29, 0x7D, 0x93, 0x09,  // @...)}..
                /* 03E8 */  0xD4, 0xB2, 0x41, 0x04, 0xF4, 0xFF, 0x3F, 0x42,  // ..A...?B
                /* 03F0 */  0xD9, 0x00, 0x62, 0x82, 0x41, 0x04, 0x64, 0x91,  // ..b.A.d.
                /* 03F8 */  0x3E, 0x80, 0x98, 0x62, 0x10, 0x01, 0x59, 0xDD,  // >..b..Y.
                /* 0400 */  0xA3, 0x40, 0x40, 0xD6, 0x0A, 0x22, 0x20, 0xFF,  // .@@.." .
                /* 0408 */  0xFF, 0x01                                       // ..
            })
        }

        Device (WMI4)
        {
            Name (_HID, EisaId ("PNP0C14") /* Windows Management Instrumentation Device */)  // _HID: Hardware ID
            Name (_UID, 0x04)  // _UID: Unique ID
            Name (_WDG, Buffer (0x28)
            {
                /* 0000 */  0x57, 0xBB, 0x84, 0x85, 0x31, 0x5E, 0xC4, 0x46,  // W...1^.F
                /* 0008 */  0xBC, 0x8E, 0x5E, 0x94, 0x56, 0x3A, 0xE4, 0x15,  // ..^.V:..
                /* 0010 */  0x41, 0x44, 0x01, 0x06, 0x21, 0x12, 0x90, 0x05,  // AD..!...
                /* 0018 */  0x66, 0xD5, 0xD1, 0x11, 0xB2, 0xF0, 0x00, 0xA0,  // f.......
                /* 0020 */  0xC9, 0x06, 0x29, 0x10, 0x42, 0x44, 0x01, 0x00   // ..).BD..
            })
            Name (TDRV, Package (0x08)
            {
                "Drv1", 
                "Drv2", 
                "Drv3", 
                "Drv4", 
                "Drv5", 
                "Drv6", 
                "Drv7", 
                "Drv8"
            })
            Name (PTYP, Package (0x07)
            {
                "POP", 
                "SVP", 
                "SMP", 
                "UHDP", 
                "MHDP", 
                "UDRP", 
                "ADRP"
            })
            Name (EMTH, Package (0x0C)
            {
                "ATAN", 
                "ATAC", 
                "OPALPASS", 
                "DOD", 
                "SPZ", 
                "USNAF", 
                "CCI6", 
                "BHI5", 
                "GV", 
                "RGP1", 
                "RGP4", 
                "RTOII"
            })
            Method (WMAD, 3, NotSerialized)
            {
                Acquire (^^WMI1.MWMI, 0xFFFF)
                If ((SizeOf (Arg2) == Zero))
                {
                    Local0 = 0x02
                }
                Else
                {
                    Local0 = ^^WMI1.CARG (Arg2)
                    If ((Local0 == Zero))
                    {
                        If ((^^WMI1.ILEN != Zero))
                        {
                            ^^WMI1.CLRP ()
                            Local0 = SWIP (^^WMI1.IBUF)
                            If ((Local0 == Zero))
                            {
                                Local0 = WMIS (0x0D, Zero)
                            }

                            ^^WMI1.CLRP ()
                        }
                    }
                }

                Release (^^WMI1.MWMI)
                Return (DerefOf (^^WMI1.RETN [Local0]))
            }

            Method (SWIP, 1, NotSerialized)
            {
                Local6 = ^^WMI1.GSEL (TDRV, Arg0, Zero)
                If ((Local6 == Ones))
                {
                    Return (0x02)
                }

                WDRV = Local6
                Local0 = ^^WMI1.SLEN (TDRV, Local6)
                If ((DerefOf (Arg0 [Local0]) != 0x2C))
                {
                    Return (0x02)
                }

                Local0++
                Local6 = ^^WMI1.GSEL (EMTH, Arg0, Local0)
                If ((Local6 == Ones))
                {
                    Return (0x02)
                }

                WMTH = Local6
                Local0 += ^^WMI1.SLEN (EMTH, Local6)
                If ((DerefOf (Arg0 [Local0]) != 0x2C))
                {
                    Return (0x02)
                }

                Local0++
                Local6 = ^^WMI1.GSEL (PTYP, Arg0, Local0)
                If ((Local6 == Ones))
                {
                    Return (0x02)
                }

                WPTY = Local6
                Local0 += ^^WMI1.SLEN (PTYP, Local6)
                If ((DerefOf (Arg0 [Local0]) != 0x2C))
                {
                    Return (0x02)
                }

                Local0++
                Local1 = ^^WMI1.GPAS (Arg0, Local0)
                If (((Local1 == Ones) || (Local1 == Zero)))
                {
                    Return (0x02)
                }

                WPAS = ^^WMI1.PSTR /* \_SB_.WMI1.PSTR */
                Return (Zero)
            }

            Name (WQBD, Buffer (0x0322)
            {
                /* 0000 */  0x46, 0x4F, 0x4D, 0x42, 0x01, 0x00, 0x00, 0x00,  // FOMB....
                /* 0008 */  0x12, 0x03, 0x00, 0x00, 0x36, 0x08, 0x00, 0x00,  // ....6...
                /* 0010 */  0x44, 0x53, 0x00, 0x01, 0x1A, 0x7D, 0xDA, 0x54,  // DS...}.T
                /* 0018 */  0x98, 0xDA, 0x83, 0x00, 0x01, 0x06, 0x18, 0x42,  // .......B
                /* 0020 */  0x10, 0x05, 0x10, 0x8A, 0x0E, 0x21, 0x02, 0x0B,  // .....!..
                /* 0028 */  0x83, 0x50, 0x58, 0x18, 0x14, 0xA0, 0x45, 0x41,  // .PX...EA
                /* 0030 */  0xC8, 0x05, 0x14, 0x95, 0x02, 0x21, 0xC3, 0x02,  // .....!..
                /* 0038 */  0x14, 0x0B, 0x70, 0x2E, 0x40, 0xBA, 0x00, 0xE5,  // ..p.@...
                /* 0040 */  0x28, 0x72, 0x0C, 0x22, 0x02, 0xF7, 0xEF, 0x0F,  // (r."....
                /* 0048 */  0x31, 0xD4, 0x18, 0xA8, 0x58, 0x08, 0x89, 0x00,  // 1...X...
                /* 0050 */  0xA6, 0x42, 0xE0, 0x08, 0x41, 0xBF, 0x02, 0x10,  // .B..A...
                /* 0058 */  0x3A, 0x14, 0x20, 0x53, 0x80, 0x41, 0x01, 0x4E,  // :. S.A.N
                /* 0060 */  0x11, 0x44, 0x10, 0xA5, 0x65, 0x01, 0xBA, 0x05,  // .D..e...
                /* 0068 */  0xF8, 0x16, 0xA0, 0x1D, 0x42, 0x68, 0x91, 0xE2,  // ....Bh..
                /* 0070 */  0x9C, 0x42, 0xEB, 0x93, 0x10, 0x48, 0xAF, 0x02,  // .B...H..
                /* 0078 */  0x4C, 0x0B, 0x10, 0x0E, 0x22, 0x8B, 0x02, 0x64,  // L..."..d
                /* 0080 */  0x63, 0xC8, 0x36, 0x28, 0x19, 0x09, 0x13, 0x39,  // c.6(...9
                /* 0088 */  0x0C, 0x94, 0x98, 0x61, 0xA0, 0x74, 0xCE, 0x42,  // ...a.t.B
                /* 0090 */  0x36, 0x81, 0x35, 0x83, 0x42, 0x51, 0x34, 0x93,  // 6.5.BQ4.
                /* 0098 */  0x28, 0x09, 0x4E, 0xE1, 0x30, 0x22, 0x04, 0x2F,  // (.N.0"./
                /* 00A0 */  0x57, 0x80, 0xE4, 0x09, 0x48, 0xF3, 0xD4, 0x34,  // W...H..4
                /* 00A8 */  0x8F, 0x83, 0x38, 0x04, 0x36, 0x02, 0x9E, 0x58,  // ..8.6..X
                /* 00B0 */  0x03, 0x08, 0x8B, 0xB5, 0x52, 0x05, 0x75, 0x00,  // ....R.u.
                /* 00B8 */  0x83, 0xD9, 0xB6, 0x04, 0xC8, 0x19, 0x2D, 0x0A,  // ......-.
                /* 00C0 */  0xD8, 0xB3, 0x3A, 0x91, 0x26, 0x87, 0x4A, 0x25,  // ..:.&.J%
                /* 00C8 */  0xC1, 0xA1, 0x06, 0x6A, 0x89, 0x02, 0xCC, 0x8F,  // ...j....
                /* 00D0 */  0x4C, 0x13, 0x39, 0xB6, 0xD3, 0x3B, 0xC3, 0x90,  // L.9..;..
                /* 00D8 */  0x4C, 0xDA, 0x50, 0x50, 0xA3, 0xF7, 0xB4, 0x4E,  // L.PP...N
                /* 00E0 */  0xCA, 0x73, 0x8D, 0x78, 0x50, 0x86, 0x49, 0xE0,  // .s.xP.I.
                /* 00E8 */  0x51, 0x30, 0x34, 0x4E, 0x50, 0x16, 0x84, 0x76,  // Q04NP..v
                /* 00F0 */  0x44, 0x07, 0x4A, 0x00, 0x4F, 0xC2, 0x73, 0x2C,  // D.J.O.s,
                /* 00F8 */  0x7E, 0xD0, 0x64, 0x22, 0x4F, 0x03, 0x31, 0x12,  // ~.d"O.1.
                /* 0100 */  0xF8, 0x54, 0x60, 0xD1, 0x63, 0x46, 0x8F, 0x28,  // .T`.cF.(
                /* 0108 */  0x5C, 0xC0, 0xF3, 0x39, 0x86, 0xF3, 0xF7, 0x50,  // \..9...P
                /* 0110 */  0x63, 0x1C, 0x45, 0xE4, 0x04, 0xF1, 0x7D, 0x0E,  // c.E...}.
                /* 0118 */  0x60, 0x50, 0x41, 0x0A, 0x12, 0x20, 0x15, 0x5D,  // `PA.. .]
                /* 0120 */  0xFF, 0x7F, 0xB8, 0x68, 0x5D, 0xCF, 0x5D, 0x28,  // ...h].](
                /* 0128 */  0x86, 0x3A, 0xEB, 0x93, 0x0A, 0x76, 0x1C, 0xBE,  // .:...v..
                /* 0130 */  0x10, 0x70, 0x9C, 0xDE, 0x4F, 0x04, 0x74, 0x28,  // .p..O.t(
                /* 0138 */  0x58, 0x19, 0x10, 0xF2, 0x28, 0xC0, 0xEA, 0xE8,  // X...(...
                /* 0140 */  0x34, 0x97, 0x04, 0x16, 0x27, 0xC0, 0x1A, 0x84,  // 4...'...
                /* 0148 */  0xA6, 0x5A, 0x21, 0x82, 0x50, 0x7A, 0x13, 0x60,  // .Z!.Pz.`
                /* 0150 */  0x0B, 0x43, 0x83, 0xE9, 0x4C, 0x80, 0x31, 0x14,  // .C..L.1.
                /* 0158 */  0x61, 0xD5, 0x76, 0x25, 0x10, 0x46, 0x94, 0x70,  // a.v%.F.p
                /* 0160 */  0x41, 0x62, 0x06, 0x8B, 0xC7, 0xCC, 0x41, 0x09,  // Ab....A.
                /* 0168 */  0x24, 0x5C, 0xCC, 0x57, 0x83, 0x38, 0x61, 0xC2,  // $\.W.8a.
                /* 0170 */  0xC6, 0x49, 0xE0, 0xC1, 0xE3, 0x4E, 0x01, 0x3E,  // .I...N.>
                /* 0178 */  0x38, 0x1C, 0xE0, 0x41, 0x3D, 0x05, 0x3C, 0x31,  // 8..A=.<1
                /* 0180 */  0x98, 0xC0, 0x53, 0x3F, 0xB8, 0x67, 0x84, 0x97,  // ..S?.g..
                /* 0188 */  0x8A, 0x73, 0x8C, 0x1A, 0xE3, 0x0C, 0x12, 0x58,  // .s.....X
                /* 0190 */  0xD2, 0x5B, 0x42, 0x16, 0x40, 0x14, 0x09, 0x1E,  // .[B.@...
                /* 0198 */  0x75, 0x6A, 0xF0, 0xF9, 0xC0, 0x23, 0x3B, 0x78,  // uj...#;x
                /* 01A0 */  0x8F, 0xF6, 0x04, 0x82, 0x1C, 0xC2, 0x11, 0x3C,  // .......<
                /* 01A8 */  0x39, 0x3C, 0x18, 0x78, 0x0C, 0xEC, 0xC6, 0xE0,  // 9<.x....
                /* 01B0 */  0xA3, 0x80, 0x4F, 0x0A, 0xF8, 0x51, 0x07, 0x7C,  // ..O..Q.|
                /* 01B8 */  0x45, 0x78, 0x40, 0x60, 0x23, 0x0E, 0x87, 0x19,  // Ex@`#...
                /* 01C0 */  0xAE, 0x87, 0xED, 0x09, 0x9C, 0xFA, 0xB3, 0x06,  // ........
                /* 01C8 */  0x3F, 0x77, 0x78, 0x70, 0xB8, 0x91, 0x9E, 0xCC,  // ?wxp....
                /* 01D0 */  0x91, 0xBD, 0x07, 0x34, 0x7B, 0x48, 0xD0, 0x81,  // ...4{H..
                /* 01D8 */  0xC2, 0x07, 0x0F, 0x76, 0x15, 0xB0, 0x67, 0x48,  // ...v..gH
                /* 01E0 */  0x22, 0x7F, 0x10, 0xA8, 0x91, 0x19, 0xDA, 0x13,  // ".......
                /* 01E8 */  0x7E, 0xFF, 0x30, 0xE4, 0xF3, 0xC2, 0x61, 0xB1,  // ~.0...a.
                /* 01F0 */  0xE3, 0x87, 0x0F, 0x20, 0x1E, 0x0F, 0xF8, 0xEF,  // ... ....
                /* 01F8 */  0x25, 0xCF, 0x1B, 0x9E, 0xBE, 0xE7, 0xEB, 0xF3,  // %.......
                /* 0200 */  0x84, 0x81, 0xB1, 0xFF, 0xFF, 0x43, 0x09, 0x18,  // .....C..
                /* 0208 */  0x6E, 0x0F, 0xFC, 0x58, 0x02, 0xE7, 0x48, 0x02,  // n..X..H.
                /* 0210 */  0x4C, 0x26, 0xE9, 0x21, 0xF0, 0x33, 0x81, 0x87,  // L&.!.3..
                /* 0218 */  0xC0, 0x07, 0xF0, 0x24, 0x71, 0x8A, 0x56, 0x3A,  // ...$q.V:
                /* 0220 */  0x31, 0xE4, 0xE9, 0x05, 0xAC, 0xF9, 0x1F, 0x01,  // 1.......
                /* 0228 */  0x3A, 0x7C, 0x38, 0x3B, 0x88, 0x6C, 0x3C, 0x03,  // :|8;.l<.
                /* 0230 */  0x7C, 0x10, 0xA0, 0x6A, 0x80, 0x34, 0x53, 0xD8,  // |..j.4S.
                /* 0238 */  0x04, 0xD3, 0x93, 0xEB, 0xE0, 0xC3, 0x73, 0x93,  // ......s.
                /* 0240 */  0x28, 0xF9, 0xC8, 0x28, 0x9C, 0xB3, 0x1E, 0x49,  // (..(...I
                /* 0248 */  0x28, 0x88, 0x01, 0x1D, 0xE4, 0x44, 0x81, 0x3E,  // (....D.>
                /* 0250 */  0xAD, 0x78, 0x08, 0xE7, 0xFA, 0xE4, 0xE3, 0x41,  // .x.....A
                /* 0258 */  0xF9, 0x3E, 0xE2, 0xDB, 0x8A, 0x0F, 0x21, 0x3E,  // .>....!>
                /* 0260 */  0x4F, 0x78, 0xF8, 0x3E, 0x29, 0xF0, 0x1F, 0x8D,  // Ox.>)...
                /* 0268 */  0xAF, 0x0E, 0x46, 0xB7, 0x9A, 0x13, 0x0B, 0x0A,  // ..F.....
                /* 0270 */  0xCC, 0x67, 0x11, 0x4E, 0x50, 0xD7, 0x65, 0x02,  // .g.NP.e.
                /* 0278 */  0x64, 0xFA, 0x4E, 0x0B, 0x50, 0xFF, 0xFF, 0x97,  // d.N.P...
                /* 0280 */  0x00, 0x0E, 0xE4, 0xAB, 0x81, 0x8F, 0x02, 0x8F,  // ........
                /* 0288 */  0x07, 0x6C, 0x0C, 0x4F, 0x03, 0x46, 0x33, 0x3A,  // .l.O.F3:
                /* 0290 */  0x0F, 0x3F, 0x59, 0x54, 0xDC, 0xC9, 0x52, 0x10,  // .?YT..R.
                /* 0298 */  0x4F, 0xD6, 0x51, 0x26, 0x8B, 0x9E, 0x89, 0x2F,  // O.Q&.../
                /* 02A0 */  0x00, 0x9E, 0xD1, 0x2B, 0x80, 0xE7, 0xE8, 0x09,  // ...+....
                /* 02A8 */  0xFB, 0x2A, 0x02, 0xEB, 0x80, 0xF0, 0x50, 0xE3,  // .*....P.
                /* 02B0 */  0x3B, 0x06, 0x83, 0xF3, 0x64, 0x39, 0x9C, 0x27,  // ;...d9.'
                /* 02B8 */  0xCB, 0xC7, 0xE2, 0x9B, 0x08, 0xF8, 0x04, 0xCE,  // ........
                /* 02C0 */  0x16, 0xE4, 0xF0, 0x98, 0x90, 0xA3, 0xA2, 0x97,  // ........
                /* 02C8 */  0x22, 0x0F, 0x8F, 0x5F, 0x0E, 0x3C, 0x9F, 0x67,  // ".._.<.g
                /* 02D0 */  0x84, 0xA3, 0x7C, 0x92, 0xC0, 0x61, 0xBC, 0x61,  // ..|..a.a
                /* 02D8 */  0x78, 0x88, 0xBE, 0x1F, 0xC1, 0x9A, 0xC8, 0x49,  // x......I
                /* 02E0 */  0xFB, 0xB6, 0x70, 0xB2, 0x41, 0xE3, 0x87, 0xF5,  // ..p.A...
                /* 02E8 */  0xFD, 0x08, 0xB8, 0x2A, 0xB4, 0xE9, 0x53, 0xA3,  // ...*..S.
                /* 02F0 */  0x51, 0xAB, 0x06, 0x65, 0x6A, 0x94, 0x69, 0x50,  // Q..ej.iP
                /* 02F8 */  0xAB, 0x4F, 0xA5, 0xC6, 0x8C, 0x5D, 0xB3, 0x2C,  // .O...].,
                /* 0300 */  0xD0, 0xC0, 0xFF, 0x7F, 0x44, 0x4C, 0xE2, 0xDA,  // ....DL..
                /* 0308 */  0x34, 0x38, 0x07, 0x04, 0xA1, 0x71, 0xBE, 0x40,  // 48...q.@
                /* 0310 */  0x32, 0x02, 0xA2, 0x6C, 0x20, 0x02, 0x72, 0x8E,  // 2..l .r.
                /* 0318 */  0xFF, 0x84, 0x80, 0x9C, 0x0A, 0x44, 0x40, 0xFE,  // .....D@.
                /* 0320 */  0xFF, 0x03                                       // ..
            })
        }

        Device (WMI5)
        {
            Name (_HID, EisaId ("PNP0C14") /* Windows Management Instrumentation Device */)  // _HID: Hardware ID
            Name (_UID, 0x05)  // _UID: Unique ID
            Name (_WDG, Buffer (0x8C)
            {
                /* 0000 */  0xBF, 0xEF, 0x42, 0x20, 0xF9, 0x9A, 0xDF, 0x47,  // ..B ...G
                /* 0008 */  0xB7, 0x1A, 0x28, 0x7C, 0x03, 0x0C, 0x91, 0xCF,  // ..(|....
                /* 0010 */  0x47, 0x4E, 0x01, 0x01, 0x5E, 0xB4, 0x9E, 0xB7,  // GN..^...
                /* 0018 */  0xB3, 0x85, 0xD5, 0x41, 0xA9, 0x65, 0xCC, 0x17,  // ...A.e..
                /* 0020 */  0xD2, 0x2A, 0x6D, 0x8B, 0x47, 0x4D, 0x01, 0x01,  // .*m.GM..
                /* 0028 */  0x77, 0x80, 0x92, 0x02, 0x0A, 0xAD, 0xC7, 0x4C,  // w......L
                /* 0030 */  0x96, 0xB4, 0x2B, 0x89, 0x83, 0xC4, 0x38, 0x04,  // ..+...8.
                /* 0038 */  0x53, 0x43, 0x01, 0x02, 0x61, 0x57, 0x50, 0x1F,  // SC..aWP.
                /* 0040 */  0x4A, 0x1F, 0x78, 0x4B, 0x8B, 0xD7, 0xBB, 0x52,  // J.xK...R
                /* 0048 */  0xFA, 0x7E, 0x4F, 0x37, 0x47, 0x43, 0x01, 0x02,  // .~O7GC..
                /* 0050 */  0x84, 0xC2, 0x95, 0x28, 0x84, 0x00, 0x9E, 0x41,  // ...(...A
                /* 0058 */  0xAE, 0xF6, 0x8D, 0xCB, 0xBB, 0x55, 0xB0, 0xB1,  // .....U..
                /* 0060 */  0x45, 0x43, 0x01, 0x01, 0xCF, 0xB4, 0x31, 0xD9,  // EC....1.
                /* 0068 */  0x4E, 0xF5, 0x07, 0x4D, 0x94, 0x20, 0x42, 0x85,  // N..M. B.
                /* 0070 */  0x8C, 0xC6, 0xA2, 0x34, 0x4E, 0x53, 0x01, 0x01,  // ...4NS..
                /* 0078 */  0x21, 0x12, 0x90, 0x05, 0x66, 0xD5, 0xD1, 0x11,  // !...f...
                /* 0080 */  0xB2, 0xF0, 0x00, 0xA0, 0xC9, 0x06, 0x29, 0x10,  // ......).
                /* 0088 */  0x42, 0x45, 0x01, 0x00                           // BE..
            })
            Name (RETN, Package (0x0A)
            {
                "Success", 
                "Not Supported", 
                "Invalid Parameter", 
                "Password expired, please restart the system", 
                "System Busy", 
                "Out of resources", 
                "Target GUID is not found", 
                "Input password is incorrect", 
                "Aborted, need system restart", 
                "Input buffer is too small"
            })
            Method (CARU, 2, NotSerialized)
            {
                Local0 = Arg1
                If ((Local0 == Zero))
                {
                    ^^WMI1.IBUF = Zero
                    ^^WMI1.ILEN = Zero
                    Return (Zero)
                }

                Local1 = SizeOf (^^WMI1.IBUF)
                Local1--
                If ((Local0 >= Local1))
                {
                    Return (0x02)
                }

                ^^WMI1.IBUF = Zero
                Local2 = Zero
                While ((Local2 < Local0))
                {
                    Local3 = (Local2 * 0x02)
                    ^^WMI1.IBUF [Local2] = DerefOf (Arg0 [Local3])
                    Local2++
                }

                Local0--
                Local1 = DerefOf (^^WMI1.IBUF [Local0])
                If (((Local1 == 0x3B) || (Local1 == 0x2A)))
                {
                    ^^WMI1.IBUF [Local0] = Zero
                    ^^WMI1.ILEN = Local0
                }
                Else
                {
                    ^^WMI1.ILEN = Arg1
                }

                Return (Zero)
            }

            Method (WQGN, 1, NotSerialized)
            {
                Acquire (^^WMI1.MWMI, 0xFFFF)
                WMIS (0x0E, Zero)
                Release (^^WMI1.MWMI)
                Return (SNMA) /* \SNMA */
            }

            Method (WQGM, 1, NotSerialized)
            {
                Acquire (^^WMI1.MWMI, 0xFFFF)
                WMIS (0x0E, One)
                Release (^^WMI1.MWMI)
                Return (SNMA) /* \SNMA */
            }

            Method (WMSC, 3, NotSerialized)
            {
                Acquire (^^WMI1.MWMI, 0xFFFF)
                SCSB = Arg2
                Local0 = SSPL /* \SSPL */
                If ((Local0 == Zero))
                {
                    SSPB = Zero
                }
                Else
                {
                    Local0 /= 0x02
                }

                Local1 = CARU (SSPB, Local0)
                SSPB = Zero
                SSPL = Zero
                If ((Local1 == Zero))
                {
                    If ((^^WMI1.ILEN != Zero))
                    {
                        Local1 = ^^WMI1.CPAS (^^WMI1.IBUF, Zero)
                    }

                    If ((Local1 == Zero))
                    {
                        Local1 = WMIS (0x0E, 0x02)
                    }
                }

                If ((Local1 != Zero))
                {
                    SCSB = Zero
                    ^^WMI1.CLRP ()
                }

                Release (^^WMI1.MWMI)
                Return (DerefOf (RETN [Local1]))
            }

            Method (WMGC, 3, NotSerialized)
            {
                Acquire (^^WMI1.MWMI, 0xFFFF)
                SCSB = Arg2
                Local0 = SGPL /* \SGPL */
                If ((SGPL == Zero))
                {
                    SGPB = Zero
                }
                Else
                {
                    Local0 /= 0x02
                }

                Local1 = CARU (SGPB, Local0)
                SGPB = Zero
                SGPL = Zero
                If ((Local1 == Zero))
                {
                    If ((^^WMI1.ILEN != Zero))
                    {
                        Local1 = ^^WMI1.CPAS (^^WMI1.IBUF, Zero)
                    }

                    If ((Local1 == Zero))
                    {
                        Local1 = WMIS (0x0E, 0x03)
                    }
                }

                If ((Local1 != Zero))
                {
                    SCSB = Zero
                    ^^WMI1.CLRP ()
                }

                Release (^^WMI1.MWMI)
                Return (SGSB) /* \SGSB */
            }

            Method (WQEC, 1, NotSerialized)
            {
                Acquire (^^WMI1.MWMI, 0xFFFF)
                Local0 = WMIS (0x0E, 0x04)
                If ((Local0 != Zero))
                {
                    SCSB = Zero
                }

                Release (^^WMI1.MWMI)
                Return (SEDL) /* \SEDL */
            }

            Method (WQNS, 1, NotSerialized)
            {
                Acquire (^^WMI1.MWMI, 0xFFFF)
                Local0 = WMIS (0x0E, 0x04)
                If ((Local0 != Zero))
                {
                    SCSB = Zero
                }

                Release (^^WMI1.MWMI)
                Return (SENS) /* \SENS */
            }

            Name (WQBE, Buffer (0x08A1)
            {
                /* 0000 */  0x46, 0x4F, 0x4D, 0x42, 0x01, 0x00, 0x00, 0x00,  // FOMB....
                /* 0008 */  0x91, 0x08, 0x00, 0x00, 0x80, 0x2D, 0x00, 0x00,  // .....-..
                /* 0010 */  0x44, 0x53, 0x00, 0x01, 0x1A, 0x7D, 0xDA, 0x54,  // DS...}.T
                /* 0018 */  0x28, 0x41, 0x96, 0x00, 0x01, 0x06, 0x18, 0x42,  // (A.....B
                /* 0020 */  0x10, 0x11, 0x10, 0x92, 0x40, 0x62, 0x02, 0x09,  // ....@b..
                /* 0028 */  0x83, 0x50, 0x68, 0x16, 0x06, 0x43, 0xB8, 0x2C,  // .Ph..C.,
                /* 0030 */  0x0A, 0x42, 0x2E, 0xA0, 0xA8, 0x14, 0x08, 0x19,  // .B......
                /* 0038 */  0x16, 0xA0, 0x58, 0x80, 0x73, 0x01, 0xD2, 0x05,  // ..X.s...
                /* 0040 */  0x28, 0x47, 0x91, 0x63, 0x10, 0x11, 0xB8, 0x7F,  // (G.c....
                /* 0048 */  0x7F, 0x88, 0xE1, 0x40, 0xA4, 0x00, 0x42, 0xA2,  // ...@..B.
                /* 0050 */  0x47, 0x41, 0x09, 0x2C, 0x04, 0x8E, 0x10, 0xF4,  // GA.,....
                /* 0058 */  0x2B, 0x00, 0xA1, 0x43, 0x01, 0x32, 0x05, 0x18,  // +..C.2..
                /* 0060 */  0x14, 0xE0, 0x14, 0x41, 0x04, 0x51, 0x5A, 0x16,  // ...A.QZ.
                /* 0068 */  0xA0, 0x5B, 0x80, 0x6F, 0x01, 0xDA, 0x21, 0x84,  // .[.o..!.
                /* 0070 */  0x66, 0x9C, 0x73, 0x38, 0x85, 0xA6, 0x05, 0x68,  // f.s8...h
                /* 0078 */  0x86, 0xD0, 0x28, 0x0E, 0x23, 0x4C, 0xA4, 0xA0,  // ..(.#L..
                /* 0080 */  0x31, 0xE2, 0x9D, 0x89, 0x3D, 0xE3, 0xC8, 0xA2,  // 1...=...
                /* 0088 */  0x00, 0xD9, 0x18, 0xB2, 0x0D, 0x4E, 0x46, 0xC3,  // .....NF.
                /* 0090 */  0x44, 0x0E, 0x05, 0x25, 0x66, 0x28, 0x28, 0x9D,  // D..%f((.
                /* 0098 */  0x33, 0x91, 0x4D, 0x60, 0x0D, 0xA0, 0x50, 0x14,  // 3.M`..P.
                /* 00A0 */  0x8D, 0x23, 0x4A, 0x82, 0x33, 0x38, 0x85, 0x08,  // .#J.38..
                /* 00A8 */  0xC1, 0xCB, 0x15, 0x20, 0x79, 0x02, 0x9A, 0xC9,  // ... y...
                /* 00B0 */  0x51, 0xB4, 0x3E, 0x08, 0x0D, 0x81, 0x8D, 0x80,  // Q.>.....
                /* 00B8 */  0x4B, 0xB6, 0x00, 0xC2, 0x44, 0xAD, 0x56, 0x22,  // K...D.V"
                /* 00C0 */  0x61, 0x50, 0x12, 0x40, 0x24, 0x67, 0xC4, 0x28,  // aP.@$g.(
                /* 00C8 */  0x60, 0x7B, 0x9D, 0x88, 0x4C, 0x0E, 0x97, 0x4A,  // `{..L..J
                /* 00D0 */  0x1B, 0x2C, 0x7A, 0x9C, 0xA7, 0x72, 0x84, 0x1E,  // .,z..r..
                /* 00D8 */  0x9C, 0x09, 0x8C, 0x7A, 0x4A, 0x87, 0xF3, 0x0E,  // ...zJ...
                /* 00E0 */  0x50, 0x3C, 0xAA, 0x30, 0x9A, 0x83, 0x22, 0x23,  // P<.0.."#
                /* 00E8 */  0xC7, 0x8D, 0xCF, 0x12, 0x61, 0x75, 0x0A, 0x88,  // ....au..
                /* 00F0 */  0x7D, 0x68, 0x07, 0x5C, 0xF8, 0x94, 0xC9, 0x08,  // }h.\....
                /* 00F8 */  0x0E, 0x35, 0xC1, 0xF1, 0xC5, 0x38, 0xB5, 0xB3,  // .5...8..
                /* 0100 */  0xF5, 0x90, 0x3D, 0x6B, 0x0F, 0xB0, 0x20, 0x50,  // ..=k.. P
                /* 0108 */  0x0D, 0x1E, 0x0E, 0x58, 0xB8, 0x28, 0x86, 0x88,  // ...X.(..
                /* 0110 */  0x72, 0x0C, 0x81, 0xCE, 0xD3, 0x43, 0xC1, 0xC9,  // r....C..
                /* 0118 */  0x80, 0x90, 0x47, 0x01, 0x56, 0x05, 0xFC, 0xFF,  // ..G.V...
                /* 0120 */  0x87, 0x77, 0x2E, 0x09, 0x3C, 0x03, 0x4F, 0xAA,  // .w..<.O.
                /* 0128 */  0x31, 0x01, 0xCA, 0x10, 0x24, 0x6E, 0x58, 0xB2,  // 1...$nX.
                /* 0130 */  0x75, 0x4C, 0xD0, 0xC0, 0x6A, 0x43, 0x12, 0x4A,  // uL..jC.J
                /* 0138 */  0xB0, 0x40, 0x51, 0x82, 0x45, 0x89, 0x16, 0x2B,  // .@Q.E..+
                /* 0140 */  0xD2, 0xA1, 0x84, 0x32, 0xA8, 0xB1, 0x02, 0xB5,  // ...2....
                /* 0148 */  0x06, 0xA1, 0xB1, 0xC4, 0x08, 0x14, 0xE3, 0xCD,  // ........
                /* 0150 */  0xC1, 0x04, 0x05, 0xAD, 0x5C, 0x1A, 0x46, 0xE2,  // ....\.F.
                /* 0158 */  0xC1, 0xCB, 0xC8, 0x7E, 0x9E, 0x1A, 0x28, 0xC1,  // ...~..(.
                /* 0160 */  0xD1, 0xB0, 0x09, 0x9E, 0x59, 0xD4, 0x04, 0x8E,  // ....Y...
                /* 0168 */  0x0D, 0x21, 0x50, 0x9F, 0x22, 0xEC, 0xE0, 0x14,  // .!P."...
                /* 0170 */  0x81, 0x3A, 0x04, 0x1C, 0x69, 0xC8, 0xC3, 0x3A,  // .:..i..:
                /* 0178 */  0x40, 0x36, 0xB1, 0xB8, 0x3E, 0x4F, 0x78, 0x0B,  // @6..>Ox.
                /* 0180 */  0x3E, 0x0E, 0xF0, 0x31, 0x78, 0xB6, 0x47, 0x17,  // >..1x.G.
                /* 0188 */  0xF0, 0x18, 0xD8, 0x79, 0xC0, 0x80, 0x78, 0xEF,  // ...y..x.
                /* 0190 */  0x17, 0x00, 0x32, 0x67, 0x9F, 0x0B, 0x60, 0x1C,  // ..2g..`.
                /* 0198 */  0x05, 0xE0, 0x8E, 0x0C, 0x77, 0x56, 0xF0, 0xB8,  // ....wV..
                /* 01A0 */  0x38, 0xBC, 0x0F, 0x08, 0x6F, 0x10, 0xC5, 0x9E,  // 8...o...
                /* 01A8 */  0x13, 0xE8, 0xEF, 0x43, 0x67, 0x05, 0xE4, 0x3D,  // ...Cg..=
                /* 01B0 */  0xE2, 0xD8, 0x02, 0x96, 0x2A, 0xC0, 0xEC, 0x59,  // ....*..Y
                /* 01B8 */  0x42, 0x47, 0x09, 0xCF, 0xC0, 0x07, 0x0B, 0x0F,  // BG......
                /* 01C0 */  0x3D, 0xC1, 0xE8, 0x10, 0x72, 0x02, 0x4B, 0xC7,  // =...r.K.
                /* 01C8 */  0xCC, 0x51, 0x9B, 0x1F, 0x8E, 0x8E, 0x0D, 0x2C,  // .Q.....,
                /* 01D0 */  0x2A, 0x84, 0x7E, 0x12, 0x1E, 0x33, 0x38, 0x8E,  // *.~..38.
                /* 01D8 */  0x21, 0x1E, 0x33, 0xF0, 0xF8, 0xFF, 0x8F, 0x19,  // !.3.....
                /* 01E0 */  0xFE, 0xC8, 0x70, 0xF7, 0x04, 0x0F, 0x16, 0x1C,  // ..p.....
                /* 01E8 */  0xCE, 0xCE, 0x0C, 0x22, 0xF0, 0x11, 0xC6, 0xA3,  // ..."....
                /* 01F0 */  0xC5, 0x0D, 0xD2, 0x53, 0xE4, 0x37, 0x8E, 0xB0,  // ...S.7..
                /* 01F8 */  0xD5, 0x0F, 0x83, 0xC6, 0x1D, 0x2F, 0xA8, 0x00,  // ...../..
                /* 0200 */  0x3D, 0x5E, 0xF0, 0xCB, 0x1B, 0x2F, 0x68, 0xC6,  // =^.../h.
                /* 0208 */  0x06, 0x67, 0xC4, 0xE0, 0x3B, 0x3B, 0xF8, 0xC0,  // .g..;;..
                /* 0210 */  0x03, 0x1C, 0xC6, 0x84, 0x39, 0xA3, 0xB0, 0xC3,  // ....9...
                /* 0218 */  0x0E, 0xF0, 0xF8, 0xFF, 0x63, 0x78, 0x08, 0xFC,  // ....cx..
                /* 0220 */  0xAC, 0xE1, 0x21, 0xF0, 0x01, 0x3C, 0xB7, 0x9C,  // ..!..<..
                /* 0228 */  0xA4, 0x95, 0x4E, 0x0D, 0x79, 0x36, 0x02, 0x16,  // ..N.y6..
                /* 0230 */  0x83, 0xE1, 0x01, 0xDF, 0x40, 0x26, 0x50, 0x94,  // ....@&P.
                /* 0238 */  0xA3, 0x83, 0x22, 0xC1, 0xA0, 0x3C, 0x9C, 0x84,  // .."..<..
                /* 0240 */  0xA0, 0x4B, 0x82, 0x43, 0x9D, 0x02, 0x3C, 0xEE,  // .K.C..<.
                /* 0248 */  0x27, 0x8B, 0xE3, 0x38, 0x97, 0x77, 0x07, 0x8F,  // '..8.w..
                /* 0250 */  0xE8, 0x41, 0x03, 0xC6, 0x19, 0xC2, 0x63, 0x3C,  // .A....c<
                /* 0258 */  0x63, 0xCF, 0xEE, 0x31, 0xC5, 0xA3, 0x33, 0x81,  // c..1..3.
                /* 0260 */  0x47, 0xC1, 0xD0, 0xF8, 0x21, 0x85, 0x1D, 0x28,  // G...!..(
                /* 0268 */  0xF8, 0x29, 0xC0, 0x07, 0x0A, 0x36, 0xC0, 0x67,  // .)...6.g
                /* 0270 */  0xA3, 0x17, 0x0E, 0x4F, 0xE4, 0x11, 0xC8, 0x04,  // ...O....
                /* 0278 */  0x3E, 0xD3, 0x18, 0xFB, 0x19, 0x06, 0x3C, 0x87,  // >.....<.
                /* 0280 */  0x03, 0x5F, 0x2A, 0x5E, 0x8F, 0xD8, 0xD5, 0xE7,  // ._*^....
                /* 0288 */  0x78, 0x8C, 0x13, 0xEE, 0xE0, 0x1F, 0x8B, 0x3C,  // x......<
                /* 0290 */  0xED, 0xC7, 0x02, 0x83, 0x3C, 0x17, 0xC1, 0xBE,  // ....<...
                /* 0298 */  0x42, 0xBC, 0x4D, 0x3C, 0x0C, 0xF9, 0x7C, 0xE0,  // B.M<..|.
                /* 02A0 */  0x09, 0xBC, 0x0F, 0xF9, 0x50, 0x74, 0xAE, 0x41,  // ....Pt.A
                /* 02A8 */  0xDE, 0x8C, 0x0C, 0xD6, 0xDB, 0x24, 0x05, 0x65,  // .....$.e
                /* 02B0 */  0xB4, 0x28, 0xCF, 0x45, 0xC1, 0xA2, 0xBC, 0x16,  // .(.E....
                /* 02B8 */  0x19, 0xE6, 0x98, 0x62, 0xBF, 0x51, 0x84, 0x08,  // ...b.Q..
                /* 02C0 */  0x12, 0x34, 0x58, 0x8C, 0x90, 0x09, 0x7C, 0xB0,  // .4X...|.
                /* 02C8 */  0xC2, 0xFF, 0xFF, 0x0F, 0x56, 0xE0, 0x10, 0xB2,  // ....V...
                /* 02D0 */  0x6A, 0x1D, 0x8D, 0x1C, 0x09, 0x1E, 0x75, 0x74,  // j.....ut
                /* 02D8 */  0xF0, 0xC9, 0xC0, 0x23, 0x3B, 0x6C, 0x5F, 0x2B,  // ...#;l_+
                /* 02E0 */  0x0C, 0xF2, 0x04, 0xE5, 0x03, 0xC5, 0x23, 0x81,  // ......#.
                /* 02E8 */  0xC7, 0xC0, 0xEE, 0x0A, 0x3E, 0x04, 0xF8, 0x8C,  // ....>...
                /* 02F0 */  0x80, 0x77, 0x0D, 0xA8, 0xCB, 0xC1, 0xB3, 0x09,  // .w......
                /* 02F8 */  0xAC, 0x33, 0x0A, 0xFE, 0x30, 0x02, 0xFF, 0x3C,  // .3..0..<
                /* 0300 */  0xC7, 0x4E, 0x23, 0x3E, 0x4B, 0x24, 0xB0, 0xFC,  // .N#>K$..
                /* 0308 */  0x41, 0xA0, 0x46, 0x66, 0x68, 0xDF, 0x2F, 0x5E,  // A.Ffh./^
                /* 0310 */  0xEB, 0x0C, 0xF9, 0xA4, 0x70, 0x58, 0xEC, 0x54,  // ....pX.T
                /* 0318 */  0xE2, 0x13, 0x10, 0x38, 0xC6, 0x03, 0xFF, 0x32,  // ...8...2
                /* 0320 */  0xF0, 0x18, 0xE2, 0xE9, 0x7B, 0xBE, 0x26, 0x18,  // ....{.&.
                /* 0328 */  0xF6, 0xA4, 0x84, 0x1E, 0xAE, 0x07, 0xFD, 0xB8,  // ........
                /* 0330 */  0x80, 0xF1, 0x79, 0x22, 0xD0, 0x3D, 0xE0, 0x69,  // ..y".=.i
                /* 0338 */  0x01, 0x13, 0x6A, 0xE0, 0xF4, 0xC0, 0x05, 0x9E,  // ..j.....
                /* 0340 */  0xD3, 0x0A, 0xFE, 0x34, 0x01, 0x6F, 0x34, 0xB8,  // ...4.o4.
                /* 0348 */  0xB3, 0x04, 0x9C, 0x61, 0xE2, 0xFE, 0xFF, 0x27,  // ...a...'
                /* 0350 */  0x1C, 0x70, 0xA0, 0x3D, 0xE1, 0x80, 0xEF, 0xB6,  // .p.=....
                /* 0358 */  0xC1, 0xC6, 0x0B, 0xF7, 0x80, 0x03, 0x38, 0x14,  // ......8.
                /* 0360 */  0x72, 0x6C, 0xA4, 0xB1, 0xDE, 0x05, 0x8A, 0x7E,  // rl.....~
                /* 0368 */  0xC0, 0xA1, 0x30, 0x3E, 0xE0, 0x00, 0x8E, 0x0E,  // ..0>....
                /* 0370 */  0x33, 0xFC, 0xFF, 0x7F, 0xC0, 0x01, 0xCF, 0x14,  // 3.......
                /* 0378 */  0x0E, 0xEC, 0x10, 0x62, 0x05, 0x79, 0x4A, 0xF0,  // ...b.yJ.
                /* 0380 */  0x6D, 0x12, 0xE6, 0xD8, 0x7D, 0x26, 0x31, 0xCE,  // m...}&1.
                /* 0388 */  0x89, 0xF8, 0x98, 0x03, 0xFB, 0x72, 0xE3, 0x8B,  // .....r..
                /* 0390 */  0x4C, 0xE0, 0x20, 0xE7, 0xFA, 0x00, 0x19, 0xE4,  // L. .....
                /* 0398 */  0x41, 0xD2, 0x77, 0x48, 0x1F, 0x27, 0x1E, 0x73,  // A.wH.'.s
                /* 03A0 */  0x7C, 0xBA, 0x79, 0x8B, 0x34, 0xCA, 0x69, 0xBC,  // |.y.4.i.
                /* 03A8 */  0x4F, 0x1A, 0xC5, 0x33, 0x89, 0x10, 0xEB, 0x61,  // O..3...a
                /* 03B0 */  0xC7, 0x37, 0x4B, 0x83, 0xC5, 0x8A, 0xF2, 0x52,  // .7K....R
                /* 03B8 */  0xE9, 0x63, 0x0E, 0x78, 0x45, 0x1E, 0x73, 0x00,  // .c.xE.s.
                /* 03C0 */  0x0A, 0xFC, 0xFF, 0x8F, 0x39, 0xE0, 0x78, 0x3C,  // ....9.x<
                /* 03C8 */  0xF8, 0x98, 0x83, 0x3B, 0x4A, 0x18, 0xF8, 0xA1,  // ...;J...
                /* 03D0 */  0xC1, 0x07, 0x10, 0x58, 0x27, 0x11, 0x76, 0x62,  // ...X'.vb
                /* 03D8 */  0xC0, 0x04, 0x3C, 0xEA, 0x80, 0x4E, 0xF0, 0xB9,  // ..<..N..
                /* 03E0 */  0x02, 0x34, 0x23, 0x62, 0xA7, 0x0A, 0x30, 0x1E,  // .4#b..0.
                /* 03E8 */  0x78, 0xC0, 0x37, 0x2C, 0x1F, 0x78, 0xC0, 0x39,  // x.7,.x.9
                /* 03F0 */  0x72, 0x70, 0x1D, 0x7A, 0x80, 0xF7, 0xFF, 0xFF,  // rp.z....
                /* 03F8 */  0xD0, 0x03, 0x5C, 0x74, 0x9A, 0x00, 0x61, 0xC1,  // ..\t..a.
                /* 0400 */  0x5E, 0x08, 0x8A, 0xFC, 0x54, 0xA0, 0x30, 0x3E,  // ^...T.0>
                /* 0408 */  0xF4, 0x00, 0x8E, 0x46, 0xF9, 0x34, 0x01, 0x96,  // ...F.4..
                /* 0410 */  0x03, 0x29, 0xBB, 0x85, 0xF9, 0x1C, 0xE6, 0xF1,  // .)......
                /* 0418 */  0x78, 0xCE, 0x3E, 0x4A, 0xB0, 0xB3, 0xB8, 0xEF,  // x.>J....
                /* 0420 */  0xE4, 0xF0, 0x4F, 0x3D, 0xF0, 0xCF, 0x15, 0x4F,  // ..O=...O
                /* 0428 */  0x13, 0xEF, 0x35, 0x2F, 0x88, 0x46, 0x79, 0xD5,  // ..5/.Fy.
                /* 0430 */  0x89, 0xF0, 0xC0, 0xE3, 0x63, 0xB8, 0x8F, 0x89,  // ....c...
                /* 0438 */  0x1E, 0xF1, 0x0B, 0x8F, 0xA1, 0x7C, 0xE9, 0xF1,  // .....|..
                /* 0440 */  0xED, 0xC7, 0x67, 0x45, 0x83, 0x3C, 0x9C, 0x1B,  // ..gE.<..
                /* 0448 */  0xE2, 0xDD, 0x22, 0x5C, 0xA4, 0x18, 0xD1, 0x3D,  // .."\...=
                /* 0450 */  0x77, 0x9F, 0x7A, 0xC0, 0xF2, 0xFF, 0x3F, 0xF5,  // w.z...?.
                /* 0458 */  0xE0, 0xA5, 0x3D, 0x60, 0xF4, 0xCB, 0xF2, 0xA9,  // ..=`....
                /* 0460 */  0x07, 0xE0, 0xC7, 0x81, 0x15, 0x77, 0x6A, 0x01,  // .....wj.
                /* 0468 */  0xCB, 0xF5, 0x81, 0x5D, 0x44, 0x60, 0x1D, 0x58,  // ...]D`.X
                /* 0470 */  0x80, 0xF9, 0xFF, 0xFF, 0xC0, 0x02, 0x1C, 0xB4,  // ........
                /* 0478 */  0x3E, 0x1E, 0x74, 0x02, 0xB1, 0x4E, 0x10, 0xD9,  // >.t..N..
                /* 0480 */  0x78, 0x0A, 0xF8, 0x30, 0x40, 0x75, 0x9F, 0xFA,  // x..0@u..
                /* 0488 */  0x34, 0x5B, 0xD8, 0xD0, 0x82, 0x14, 0xBC, 0x4F,  // 4[.....O
                /* 0490 */  0x06, 0x56, 0x08, 0x23, 0x8D, 0x2F, 0x08, 0x8D,  // .V.#./..
                /* 0498 */  0xCE, 0x70, 0x56, 0x05, 0x23, 0x38, 0x83, 0xF8,  // .pV.#8..
                /* 04A0 */  0x68, 0xE6, 0x40, 0x10, 0x32, 0x32, 0x10, 0x0A,  // h.@.22..
                /* 04A8 */  0x69, 0x15, 0xE7, 0x0F, 0x72, 0x37, 0xF2, 0x11,  // i...r7..
                /* 04B0 */  0xC1, 0x09, 0x2E, 0xF3, 0x9E, 0x3F, 0xBD, 0x2A,  // .....?.*
                /* 04B8 */  0x70, 0x6C, 0x1F, 0x1E, 0x0C, 0xEC, 0x39, 0xFB,  // pl....9.
                /* 04C0 */  0xCE, 0xC2, 0x27, 0xEE, 0x5B, 0xC0, 0x19, 0xBF,  // ..'.[...
                /* 04C8 */  0x37, 0xF8, 0x7E, 0x60, 0x35, 0x70, 0x28, 0x68,  // 7.~`5p(h
                /* 04D0 */  0xDF, 0x49, 0xF8, 0x09, 0x86, 0x9D, 0x9D, 0xC0,  // .I......
                /* 04D8 */  0x71, 0x1B, 0x49, 0x30, 0xC3, 0x81, 0x15, 0x3D,  // q.I0...=
                /* 04E0 */  0x30, 0xA3, 0xBE, 0x6F, 0xBC, 0xCB, 0xF8, 0xB6,  // 0..o....
                /* 04E8 */  0xC2, 0x46, 0xE2, 0x81, 0xC1, 0x1B, 0x11, 0xAC,  // .F......
                /* 04F0 */  0x01, 0x5B, 0xD7, 0xE1, 0x0A, 0x64, 0x39, 0x66,  // .[...d9f
                /* 04F8 */  0x84, 0x56, 0x72, 0xC5, 0x87, 0x34, 0x27, 0xFE,  // .Vr..4'.
                /* 0500 */  0xFF, 0x9F, 0x13, 0xD8, 0x6E, 0x06, 0x9E, 0x13,  // ....n...
                /* 0508 */  0xD8, 0x4E, 0x07, 0x70, 0xE6, 0xC4, 0x4F, 0x07,  // .N.p..O.
                /* 0510 */  0x60, 0xFE, 0xA0, 0x78, 0x62, 0xB0, 0x90, 0x7C,  // `..xb..|
                /* 0518 */  0x3A, 0x00, 0x57, 0x90, 0xA3, 0x0E, 0xFA, 0x1C,  // :.W.....
                /* 0520 */  0xC5, 0xC6, 0xF5, 0xAE, 0xE1, 0x93, 0x86, 0x8F,  // ........
                /* 0528 */  0x16, 0xBE, 0x47, 0x79, 0xF0, 0x60, 0x1D, 0xA7,  // ..Gy.`..
                /* 0530 */  0x07, 0x0F, 0xFF, 0x96, 0x83, 0xD5, 0x77, 0x8C,  // ......w.
                /* 0538 */  0x01, 0x05, 0x90, 0xEF, 0x2C, 0x3E, 0xA3, 0x3C,  // ....,>.<
                /* 0540 */  0xB7, 0xB0, 0x31, 0x3C, 0xA6, 0x18, 0xCD, 0xE8,  // ..1<....
                /* 0548 */  0x3C, 0x3C, 0x3A, 0x85, 0x71, 0xDC, 0x1B, 0x04,  // <<:.q...
                /* 0550 */  0x05, 0xF1, 0x01, 0xC1, 0x51, 0x26, 0x8B, 0xFC,  // ....Q&..
                /* 0558 */  0xFF, 0xDF, 0x7E, 0xD8, 0x9D, 0xC7, 0x33, 0x3A,  // ..~...3:
                /* 0560 */  0xEC, 0x20, 0x0F, 0x8B, 0xE4, 0x72, 0xA1, 0x3B,  // . ...r.;
                /* 0568 */  0x12, 0xAC, 0x1B, 0x4B, 0xC8, 0xA7, 0x15, 0x4F,  // ...K...O
                /* 0570 */  0xC3, 0xE7, 0x02, 0xFC, 0xE9, 0x83, 0xDF, 0x9F,  // ........
                /* 0578 */  0x7C, 0x45, 0x02, 0x9F, 0xC0, 0xD9, 0x82, 0x1C,  // |E......
                /* 0580 */  0x1E, 0x13, 0xF3, 0xC2, 0x80, 0x1A, 0x1E, 0xBF,  // ........
                /* 0588 */  0x1C, 0x78, 0x3E, 0xCF, 0x08, 0x47, 0xF9, 0x78,  // .x>..G.x
                /* 0590 */  0x83, 0xC3, 0x78, 0x7A, 0xF1, 0x10, 0x7D, 0x73,  // ..xz..}s
                /* 0598 */  0x83, 0x35, 0x91, 0x93, 0xF6, 0x6D, 0xE1, 0x64,  // .5...m.d
                /* 05A0 */  0x83, 0xBE, 0x56, 0x62, 0x6E, 0x6E, 0xC0, 0x55,  // ..Vbnn.U
                /* 05A8 */  0xD3, 0x52, 0x68, 0xA0, 0xE5, 0x28, 0xEA, 0xC2,  // .Rh..(..
                /* 05B0 */  0x28, 0x8C, 0xEF, 0x80, 0xC0, 0xE6, 0xFF, 0x7F,  // (.......
                /* 05B8 */  0x07, 0x04, 0x56, 0xD7, 0xAA, 0x43, 0x07, 0xCB,  // ..V..C..
                /* 05C0 */  0x01, 0xE1, 0x71, 0x02, 0x33, 0x6D, 0xF0, 0xDC,  // ..q.3m..
                /* 05C8 */  0xFF, 0xE0, 0xDE, 0x9B, 0x63, 0xBF, 0x3A, 0xBF,  // ....c.:.
                /* 05D0 */  0x4F, 0x84, 0x78, 0xF3, 0x7B, 0xF1, 0x8B, 0xF3,  // O.x.{...
                /* 05D8 */  0xE0, 0x17, 0xC9, 0x73, 0x7D, 0xFF, 0x63, 0x87,  // ...s}.c.
                /* 05E0 */  0x69, 0x9F, 0x56, 0xDE, 0xA4, 0x8D, 0x72, 0x10,  // i.V...r.
                /* 05E8 */  0x8F, 0x80, 0x06, 0x89, 0x10, 0xF6, 0xD1, 0xE6,  // ........
                /* 05F0 */  0x09, 0xCC, 0x40, 0x87, 0x12, 0x32, 0xCA, 0xE3,  // ..@..2..
                /* 05F8 */  0x4D, 0x94, 0xF7, 0x3F, 0xC0, 0xF4, 0xFF, 0xFF,  // M..?....
                /* 0600 */  0xFE, 0x07, 0x78, 0xBA, 0x04, 0xB3, 0xFB, 0x1F,  // ..x.....
                /* 0608 */  0xE0, 0x54, 0xDF, 0x85, 0x8F, 0x6A, 0x03, 0xD1,  // .T...j..
                /* 0610 */  0xFD, 0x0F, 0xA7, 0xF9, 0xD1, 0xA0, 0xD9, 0xC2,  // ........
                /* 0618 */  0xBE, 0xFB, 0xB1, 0xFB, 0x1F, 0x57, 0x07, 0xA3,  // .....W..
                /* 0620 */  0x24, 0x34, 0x3A, 0x2E, 0x71, 0xED, 0x30, 0x82,  // $4:.q.0.
                /* 0628 */  0x33, 0x88, 0xCF, 0x11, 0xBE, 0xFF, 0xC1, 0xFA,  // 3.......
                /* 0630 */  0xFF, 0xDF, 0xFF, 0x00, 0x13, 0x57, 0x32, 0x60,  // .....W2`
                /* 0638 */  0x77, 0x04, 0x04, 0xC7, 0x95, 0x0C, 0x38, 0x45,  // w.....8E
                /* 0640 */  0xBA, 0x14, 0xA0, 0x42, 0x5C, 0x0A, 0x28, 0x88,  // ...B\.(.
                /* 0648 */  0x27, 0xE6, 0x30, 0x57, 0x43, 0xF4, 0x64, 0x7D,  // '.0WC.d}
                /* 0650 */  0x35, 0x84, 0x71, 0x27, 0x03, 0xFB, 0xB5, 0xC1,  // 5.q'....
                /* 0658 */  0xF7, 0x12, 0xB8, 0xFF, 0xFF, 0xC3, 0x3E, 0x9C,  // ......>.
                /* 0660 */  0x50, 0x57, 0x07, 0xF4, 0x65, 0xC5, 0xA7, 0x43,  // PW..e..C
                /* 0668 */  0xCC, 0x00, 0x75, 0x76, 0xA0, 0x83, 0x02, 0xD7,  // ..uv....
                /* 0670 */  0xF5, 0x10, 0x37, 0x36, 0x78, 0xE7, 0x43, 0xF0,  // ..76x.C.
                /* 0678 */  0xDD, 0xDE, 0x80, 0x47, 0xBC, 0xDB, 0x1B, 0xD0,  // ...G....
                /* 0680 */  0xBB, 0x73, 0x01, 0x37, 0x81, 0x7F, 0x29, 0x13,  // .s.7..).
                /* 0688 */  0x28, 0xCE, 0x52, 0x24, 0x09, 0x06, 0x75, 0x73,  // (.R$..us
                /* 0690 */  0x03, 0xCF, 0xFF, 0xFF, 0xE6, 0x06, 0xDC, 0x0F,  // ........
                /* 0698 */  0x0D, 0x1E, 0x36, 0x38, 0xF0, 0x63, 0x9C, 0xF5,  // ..68.c..
                /* 06A0 */  0x13, 0x81, 0xCF, 0x2C, 0x9E, 0x30, 0x9B, 0x36,  // ...,.0.6
                /* 06A8 */  0x2C, 0xFC, 0x04, 0xBE, 0xB8, 0xC1, 0xBD, 0x68,  // ,......h
                /* 06B0 */  0xBC, 0xFB, 0xFB, 0xB4, 0x16, 0x39, 0x8A, 0x27,  // .....9.'
                /* 06B8 */  0xFA, 0xC4, 0xF6, 0xDE, 0x11, 0x21, 0x0A, 0x83,  // .....!..
                /* 06C0 */  0x78, 0x77, 0x0B, 0x77, 0x06, 0x51, 0xCE, 0xE1,  // xw.w.Q..
                /* 06C8 */  0xB5, 0xC9, 0x17, 0xB8, 0x67, 0x37, 0x8F, 0x35,  // ....g7.5
                /* 06D0 */  0xEC, 0xA3, 0x9B, 0xAF, 0x6E, 0x46, 0x88, 0x11,  // ....nF..
                /* 06D8 */  0x37, 0x44, 0xD0, 0x17, 0x37, 0xF0, 0x86, 0x38,  // 7D..7..8
                /* 06E0 */  0x63, 0xD3, 0x8B, 0x1B, 0xE0, 0xE1, 0xFF, 0x7F,  // c.......
                /* 06E8 */  0x71, 0x03, 0xBC, 0x48, 0x7C, 0x38, 0xE8, 0xCE,  // q..H|8..
                /* 06F0 */  0xC5, 0xC7, 0x63, 0x51, 0xD0, 0xE4, 0xB4, 0x00,  // ..cQ....
                /* 06F8 */  0xE7, 0xF2, 0x83, 0xB9, 0x7F, 0xF8, 0xC2, 0x60,  // .......`
                /* 0700 */  0x11, 0xF0, 0x3A, 0xD8, 0x18, 0xDA, 0x67, 0x0A,  // ..:...g.
                /* 0708 */  0x7E, 0xC0, 0xF0, 0x99, 0x82, 0x01, 0xF3, 0x83,  // ~.......
                /* 0710 */  0x09, 0xE6, 0x48, 0x01, 0xBC, 0x4E, 0x3C, 0xF0,  // ..H..N<.
                /* 0718 */  0xC6, 0xE5, 0xF1, 0x78, 0xD0, 0x70, 0x27, 0x73,  // ...x.p's
                /* 0720 */  0xD2, 0x55, 0x4F, 0x41, 0x77, 0x01, 0xAB, 0x3B,  // .UOAw..;
                /* 0728 */  0xCA, 0x81, 0x64, 0xC8, 0x58, 0x02, 0x0B, 0x3E,  // ..d.X..>
                /* 0730 */  0xF8, 0x80, 0xE2, 0xFF, 0x3F, 0x0D, 0xEC, 0x44,  // ....?..D
                /* 0738 */  0x61, 0x8C, 0x05, 0xD6, 0x40, 0xD9, 0x6D, 0x10,  // a...@.m.
                /* 0740 */  0x70, 0x37, 0x18, 0x2E, 0xE1, 0xF4, 0x83, 0x0A,  // p7......
                /* 0748 */  0xFD, 0x2C, 0xF0, 0x01, 0x08, 0xD0, 0xFD, 0xFF,  // .,......
                /* 0750 */  0x3F, 0x00, 0x81, 0x6F, 0x7A, 0x8F, 0x38, 0x8F,  // ?..oz.8.
                /* 0758 */  0x6E, 0x0F, 0x3C, 0xEF, 0x15, 0xE7, 0x19, 0x3B,  // n.<....;
                /* 0760 */  0xFC, 0x8B, 0xCF, 0xCB, 0xB0, 0x61, 0xDE, 0x7E,  // .....a.~
                /* 0768 */  0x8C, 0x11, 0xEF, 0x51, 0xE5, 0x31, 0xD8, 0x90,  // ...Q.1..
                /* 0770 */  0x61, 0x1E, 0x84, 0xC2, 0x84, 0xF2, 0x51, 0xC8,  // a.....Q.
                /* 0778 */  0x88, 0x21, 0xE2, 0x46, 0x78, 0x09, 0x3A, 0x94,  // .!.Fx.:.
                /* 0780 */  0x40, 0x07, 0x70, 0xDA, 0x3E, 0x00, 0x81, 0x55,  // @.p.>..U
                /* 0788 */  0xE6, 0x01, 0x08, 0xA0, 0xC9, 0xC3, 0xC1, 0xE7,  // ........
                /* 0790 */  0x48, 0xDC, 0x00, 0x3C, 0xE8, 0x37, 0x06, 0xA3,  // H..<.7..
                /* 0798 */  0xBE, 0x2E, 0xD8, 0xE7, 0xF1, 0x40, 0x63, 0x3A,  // .....@c:
                /* 07A0 */  0xA3, 0xFF, 0x7F, 0xDC, 0x63, 0x8A, 0x1D, 0x23,  // ....c..#
                /* 07A8 */  0x56, 0x78, 0x1F, 0x06, 0x62, 0xBC, 0x99, 0xF8,  // Vx..b...
                /* 07B0 */  0xC8, 0xC0, 0x8E, 0x7D, 0xFC, 0x08, 0x04, 0x9E,  // ...}....
                /* 07B8 */  0xA3, 0x1E, 0x78, 0x86, 0x84, 0x3B, 0xF9, 0x7B,  // ..x..;.{
                /* 07C0 */  0x4A, 0xEF, 0x7A, 0x1E, 0x13, 0x1E, 0x2A, 0xFC,  // J.z...*.
                /* 07C8 */  0x39, 0x61, 0x4E, 0x98, 0xE0, 0x3B, 0x61, 0xE0,  // 9aN..;a.
                /* 07D0 */  0x2E, 0xD2, 0xE0, 0x1A, 0x39, 0xF8, 0x4E, 0x3C,  // ....9.N<
                /* 07D8 */  0x80, 0xBF, 0xFF, 0x3F, 0x81, 0x15, 0xDA, 0xF4,  // ...?....
                /* 07E0 */  0xA9, 0xD1, 0xA8, 0x55, 0x83, 0x32, 0x35, 0xCA,  // ...U.25.
                /* 07E8 */  0x34, 0xA8, 0xD5, 0xA7, 0x52, 0x63, 0xC6, 0x6E,  // 4...Rc.n
                /* 07F0 */  0x27, 0x09, 0xCA, 0x7B, 0x2C, 0xE8, 0xD4, 0x49,  // '..{,..I
                /* 07F8 */  0x4E, 0x3D, 0x02, 0xB1, 0xB0, 0xA3, 0x8F, 0x40,  // N=.....@
                /* 0800 */  0x1C, 0xED, 0x3D, 0xA2, 0xB3, 0x82, 0x03, 0xD1,  // ..=.....
                /* 0808 */  0xEB, 0x10, 0x42, 0x4C, 0x80, 0xB0, 0xE8, 0x20,  // ..BL... 
                /* 0810 */  0x54, 0xFA, 0x0B, 0x43, 0x80, 0x16, 0x6F, 0x03,  // T..C..o.
                /* 0818 */  0x8C, 0x82, 0x70, 0x1D, 0x20, 0x2C, 0xC2, 0x9B,  // ..p. ,..
                /* 0820 */  0x40, 0x80, 0x8E, 0xA1, 0x04, 0x88, 0x89, 0x78,  // @......x
                /* 0828 */  0x59, 0x08, 0xC4, 0x1A, 0xAC, 0x9C, 0x66, 0x75,  // Y.....fu
                /* 0830 */  0xE4, 0x30, 0x88, 0x80, 0x9C, 0x02, 0x88, 0x46,  // .0.....F
                /* 0838 */  0x02, 0xA2, 0x62, 0xB4, 0x00, 0x31, 0x65, 0x20,  // ..b..1e 
                /* 0840 */  0x02, 0x72, 0x3A, 0x20, 0x1A, 0x15, 0x88, 0x8A,  // .r: ....
                /* 0848 */  0xF4, 0x02, 0xC4, 0x14, 0x83, 0x08, 0xC8, 0xEA,  // ........
                /* 0850 */  0xDE, 0x04, 0x02, 0xB2, 0x56, 0x10, 0x01, 0x39,  // ....V..9
                /* 0858 */  0xA9, 0x99, 0xE1, 0xB0, 0x94, 0x6E, 0x80, 0x98,  // .....n..
                /* 0860 */  0xC6, 0x97, 0x80, 0x40, 0x2C, 0x51, 0x0F, 0x28,  // ...@,Q.(
                /* 0868 */  0xD3, 0x0B, 0x22, 0x50, 0x02, 0x44, 0x63, 0x03,  // .."P.Dc.
                /* 0870 */  0xD1, 0x90, 0x7E, 0x80, 0x58, 0x64, 0x10, 0x0D,  // ..~.Xd..
                /* 0878 */  0x94, 0x3C, 0x4D, 0x04, 0xE4, 0x20, 0x20, 0x02,  // .<M..  .
                /* 0880 */  0x72, 0x78, 0x43, 0xC3, 0x60, 0xB1, 0x1D, 0x01,  // rxC.`...
                /* 0888 */  0x31, 0xD1, 0xCF, 0x26, 0x81, 0x58, 0xBC, 0x25,  // 1..&.X.%
                /* 0890 */  0x10, 0x26, 0xCE, 0x13, 0x20, 0x93, 0x65, 0x0A,  // .&.. .e.
                /* 0898 */  0x88, 0x85, 0x02, 0xE1, 0xAA, 0x40, 0xD8, 0xFF,  // .....@..
                /* 08A0 */  0x1F                                             // .
            })
        }
    }

    Scope (_SB.PCI0.LPC0.EC0)
    {
        Mutex (MCPU, 0x00)
        Mutex (LIDQ, 0x00)
        Method (_Q1F, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
        {
            If (^HKEY.MHKK (One, 0x00020000))
            {
                If ((PKLI & 0x0C00))
                {
                    ^HKEY.MHKQ (0x1012)
                }
            }

            SCMS (0x0E)
        }

        Method (_Q16, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
        {
            If (^HKEY.MHKK (One, 0x40))
            {
                ^HKEY.MHKQ (0x1007)
            }
        }

        Method (_Q1C, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
        {
            If (^HKEY.MHKK (One, 0x01000000))
            {
                ^HKEY.MHKQ (0x1019)
            }
        }

        Method (_Q1D, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
        {
            If (^HKEY.MHKK (One, 0x02000000))
            {
                ^HKEY.MHKQ (0x101A)
            }
        }

        Method (_Q13, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
        {
            If (^HKEY.DHKC)
            {
                ^HKEY.MHKQ (0x1004)
            }
            Else
            {
                Notify (SLPB, 0x80) // Status Change
            }
        }

        Method (_Q64, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
        {
            If (^HKEY.MHKK (One, 0x10))
            {
                ^HKEY.MHKQ (0x1005)
            }
        }

        Method (_Q62, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
        {
            If (^HKEY.MHKK (0x03, 0x00010000))
            {
                ^HKEY.MHKQ (0x1311)
            }
        }

        Method (_Q65, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
        {
            If (^HKEY.MHKK (0x03, 0x00020000))
            {
                ^HKEY.MHKQ (0x1312)
            }
        }

        Method (_Q94, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
        {
            If (^HKEY.MHKK (0x03, 0x00040000))
            {
                ^HKEY.MHKQ (0x1313)
            }
        }

        Method (_Q78, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
        {
            If (^HKEY.MHKK (0x03, 0x00400000))
            {
                ^HKEY.MHKQ (0x1317)
            }
        }

        Method (_Q79, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
        {
            If (^HKEY.MHKK (0x03, 0x00800000))
            {
                ^HKEY.MHKQ (0x1318)
            }
        }

        Method (_Q7A, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
        {
            If (^HKEY.MHKK (0x03, 0x01000000))
            {
                ^HKEY.MHKQ (0x1319)
            }
        }

        Method (_Q26, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
        {
            If ((Acquire (UCCI, 0xA000) == Zero))
            {
                SCMS (0x12)
                Sleep (0x01F4)
                Notify (AC, 0x80) // Status Change
                If (WXPF)
                {
                    Acquire (MCPU, 0xFFFF)
                }

                If (WXPF)
                {
                    Sleep (0x64)
                }

                If (WXPF)
                {
                    Release (MCPU)
                }

                ^HKEY.MHKQ (0x6040)
                Release (UCCI)
            }
        }

        Method (ACIN, 0, NotSerialized)
        {
            If ((Acquire (UCCI, 0xA000) == Zero))
            {
                SCMS (0x12)
                Sleep (0x01F4)
                Notify (AC, 0x80) // Status Change
                If (WXPF)
                {
                    Acquire (MCPU, 0xFFFF)
                }

                If (WXPF)
                {
                    Sleep (0x64)
                }

                If (WXPF)
                {
                    Release (MCPU)
                }

                ^HKEY.MHKQ (0x6040)
                Release (UCCI)
            }
        }

        Method (_Q27, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
        {
            If ((Acquire (UCCI, 0xA000) == Zero))
            {
                SCMS (0x12)
                Sleep (0x01F4)
                Notify (AC, 0x80) // Status Change
                If (WXPF)
                {
                    Acquire (MCPU, 0xFFFF)
                }

                If (WXPF)
                {
                    Sleep (0x64)
                }

                If (WXPF)
                {
                    Release (MCPU)
                }

                ^HKEY.MHKQ (0x6040)
                Release (UCCI)
            }
        }

        Method (ACOU, 0, NotSerialized)
        {
            If ((Acquire (UCCI, 0xA000) == Zero))
            {
                SCMS (0x12)
                Sleep (0x01F4)
                Notify (AC, 0x80) // Status Change
                If (WXPF)
                {
                    Acquire (MCPU, 0xFFFF)
                }

                If (WXPF)
                {
                    Sleep (0x64)
                }

                If (WXPF)
                {
                    Release (MCPU)
                }

                ^HKEY.MHKQ (0x6040)
                Release (UCCI)
            }
        }

        OperationRegion (QWER, SystemIO, 0x72, 0x02)
        Field (QWER, ByteAcc, NoLock, Preserve)
        {
            INDX,   8, 
            DATA,   8
        }

        IndexField (INDX, DATA, ByteAcc, NoLock, Preserve)
        {
            Offset (0x8D), 
            WERT,   8, 
            DFGH,   8
        }

        Method (_Q2A, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
        {
            If ((Acquire (LIDQ, 0xA000) == Zero))
            {
                P80H = 0x2A
                WERT = HPLD /* \_SB_.PCI0.LPC0.EC0_.HPLD */
                HAM6 = HPLD /* \_SB_.PCI0.LPC0.EC0_.HPLD */
                VCMS (One, ^^^^LID._LID ())
                If ((ILNF == Zero))
                {
                    If (IOST)
                    {
                        If (!ISOC (Zero))
                        {
                            IOST = Zero
                            ^HKEY.MHKQ (0x60D0)
                        }
                    }

                    ^HKEY.MHKQ (0x5002)
                    If ((PLUX == Zero))
                    {
                        Notify (LID, 0x80) // Status Change
                        Sleep (0x01F4)
                    }
                }

                Release (LIDQ)
            }
        }

        Method (LIDO, 0, NotSerialized)
        {
            If ((Acquire (LIDQ, 0xA000) == Zero))
            {
                P80H = 0x2A
                WERT = HPLD /* \_SB_.PCI0.LPC0.EC0_.HPLD */
                HAM6 = HPLD /* \_SB_.PCI0.LPC0.EC0_.HPLD */
                VCMS (One, ^^^^LID._LID ())
                If ((ILNF == Zero))
                {
                    If (IOST)
                    {
                        If (!ISOC (Zero))
                        {
                            IOST = Zero
                            ^HKEY.MHKQ (0x60D0)
                        }
                    }

                    ^HKEY.MHKQ (0x5002)
                    If ((PLUX == Zero))
                    {
                        Notify (LID, 0x80) // Status Change
                    }
                }

                Release (LIDQ)
            }
        }

        Method (_Q2B, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
        {
            If ((Acquire (LIDQ, 0xA000) == Zero))
            {
                P80H = 0x2B
                WERT = Zero
                DFGH = Zero
                HAM6 = Zero
                SCMS (0x0D)
                VCMS (One, ^^^^LID._LID ())
                If ((ILNF == Zero))
                {
                    If ((IOEN && !IOST))
                    {
                        If (!ISOC (One))
                        {
                            IOST = One
                            ^HKEY.MHKQ (0x60D0)
                        }
                    }

                    ^HKEY.MHKQ (0x5001)
                    If ((PLUX == Zero))
                    {
                        Notify (LID, 0x80) // Status Change
                    }
                }

                Release (LIDQ)
            }
        }

        Method (LIDC, 0, NotSerialized)
        {
            P80H = 0x2B
            WERT = Zero
            DFGH = Zero
            HAM6 = Zero
            SCMS (0x0D)
            VCMS (One, ^^^^LID._LID ())
            If ((ILNF == Zero))
            {
                If ((IOEN && !IOST))
                {
                    If (!ISOC (One))
                    {
                        IOST = One
                        ^HKEY.MHKQ (0x60D0)
                    }
                }

                ^HKEY.MHKQ (0x5001)
                If ((PLUX == Zero))
                {
                    Notify (LID, 0x80) // Status Change
                }
            }
        }

        Method (_Q3D, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
        {
        }

        Method (_Q48, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
        {
        }

        Method (_Q49, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
        {
        }

        Method (_Q7F, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
        {
            Fatal (0x01, 0x80010000, 0x5A35)
        }

        Method (_Q46, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
        {
            ^HKEY.MHKQ (0x6012)
        }

        Method (_Q8A, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
        {
            If ((WLAC == 0x02)){}
            ElseIf ((ELNK && (WLAC == One)))
            {
                DCWL = Zero
            }
            Else
            {
                DCWL = One
            }
        }

        Method (_Q2F, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
        {
            BFCC ()
        }

        Method (_Q71, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
        {
            ^HKEY.MHKQ (0x1316)
        }

        Method (_Q86, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
        {
            P80H = 0x86
            ^HKEY.DYTC (0x001F4001)
        }

        Method (_Q87, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
        {
            P80H = 0x87
            ^HKEY.DYTC (0x000F4001)
        }

        Method (_Q6E, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
        {
            P80H = 0x6E
        }

        Method (_Q8B, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
        {
            P80H = 0x8B
            ^HKEY.DYTC (0x001F0001)
        }

        Method (_Q8C, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
        {
            P80H = 0x8C
            ^HKEY.DYTC (0x001F0001)
        }

        Method (_Q6C, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
        {
            P80H = 0x6C
            APMC = 0xCC
        }

        Method (_Q6D, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
        {
            P80H = 0x6D
            APMC = 0xCF
        }

        Scope (\_SB.PCI0.LPC0.EC0)
        {
            Method (_Q6A, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
            {
                If (HDMC)
                {
                    Noop
                }
                ElseIf (^HKEY.MHKK (One, 0x04000000))
                {
                    ^HKEY.MHKQ (0x101B)
                }
            }
        }

        Scope (HKEY)
        {
            Method (MMTG, 0, NotSerialized)
            {
                Local0 = 0x0101
                If (HDMC)
                {
                    Local0 |= 0x00010000
                }

                Return (Local0)
            }

            Method (MMTS, 1, NotSerialized)
            {
                If (HDMC)
                {
                    Noop
                }
                ElseIf ((Arg0 == 0x02))
                {
                    LED (0x0E, 0x80)
                }
                ElseIf ((Arg0 == 0x03))
                {
                    LED (0x0E, 0xC0)
                }
                Else
                {
                    LED (0x0E, Zero)
                }
            }
        }

        Scope (\_SB.PCI0.LPC0.EC0)
        {
            Method (_Q3F, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
            {
                ^HKEY.MHKQ (0x6000)
            }

            Method (_Q74, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
            {
                ^HKEY.MHKQ (0x6060)
            }
        }

        Scope (HKEY)
        {
        }

        Scope (\_SB.PCI0.LPC0.EC0)
        {
            Name (BRTW, Package (0x12)
            {
                0x64, 
                0x64, 
                0x05, 
                0x0A, 
                0x14, 
                0x19, 
                0x1E, 
                0x23, 
                0x28, 
                0x2D, 
                0x32, 
                0x37, 
                0x3C, 
                0x41, 
                0x46, 
                0x50, 
                0x5A, 
                0x64
            })
            Name (BRTB, Package (0x01)
            {
                Package (0x16)
                {
                    0x28, 
                    0x04, 
                    0x04, 
                    0x07, 
                    0x0A, 
                    0x0E, 
                    0x11, 
                    0x16, 
                    0x1B, 
                    0x21, 
                    0x29, 
                    0x32, 
                    0x3C, 
                    0x46, 
                    0x64, 
                    0x8C, 
                    0xB4, 
                    0xFF, 
                    0x04E2, 
                    0x04E2, 
                    0x04, 
                    0x04
                }
            })
            Method (_Q14, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
            {
                If (^HKEY.MHKK (One, 0x8000))
                {
                    ^HKEY.MHKQ (0x1010)
                }

                Notify (^^^GP17.VGA.LCD, 0x86) // Device-Specific
            }

            Method (_Q15, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
            {
                If (^HKEY.MHKK (One, 0x00010000))
                {
                    ^HKEY.MHKQ (0x1011)
                }

                Notify (^^^GP17.VGA.LCD, 0x87) // Device-Specific
            }

            Method (BRNS, 0, NotSerialized)
            {
                Local0 = (BRLV + 0x02)
                Local3 = BNTN /* \BNTN */
                If (CondRefOf (\_SB.PCI0.GP17.VGA.AFN7))
                {
                    Local2 = DerefOf (DerefOf (BRTB [Local3]) [Local0])
                    ^^^GP17.VGA.AFN7 (Local2)
                }
            }

            Method (BFRQ, 0, NotSerialized)
            {
                Local0 = 0x80000100
                Local1 = DerefOf (DerefOf (BRTB [BNTN]) [0x13])
                Local0 |= (Local1 << 0x09)
                Local1 = DerefOf (DerefOf (BRTB [BNTN]) [0x15])
                Local0 |= Local1
                Return (Local0)
            }
        }

        Scope (\_SB.PCI0.LPC0.EC0)
        {
            Method (_Q43, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
            {
                SCMS (0x18)
            }

            Method (SAUM, 1, NotSerialized)
            {
                If ((Arg0 > 0x03))
                {
                    Noop
                }
                ElseIf (H8DR)
                {
                    HAUM = Arg0
                }
                Else
                {
                    MBEC (0x03, 0x9F, (Arg0 << 0x05))
                }
            }
        }

        Scope (HKEY)
        {
            Method (GSMS, 1, NotSerialized)
            {
                Return (AUDC (Zero, Zero))
            }

            Method (SSMS, 1, NotSerialized)
            {
                Return (AUDC (One, (Arg0 & One)))
            }

            Method (SHDA, 1, NotSerialized)
            {
                Local0 = Arg0
                Local0 = 0x02
                Return (AUDC (0x02, (Local0 & 0x03)))
            }
        }

        Scope (\_SB.PCI0.LPC0.EC0)
        {
            Method (_Q19, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
            {
                If (^HKEY.MHKK (One, 0x00800000))
                {
                    ^HKEY.MHKQ (0x1018)
                }

                SCMS (0x03)
            }
        }

        Scope (\_SB.PCI0.LPC0.EC0)
        {
            Method (_Q63, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
            {
                If (^HKEY.MHKK (One, 0x00080000))
                {
                    ^HKEY.MHKQ (0x1014)
                }

                SCMS (0x0B)
            }
        }

        Scope (\_SB.PCI0.LPC0.EC0)
        {
            Method (_Q70, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
            {
                FNST ()
            }

            Method (_Q72, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
            {
                FNST ()
            }

            Method (_Q73, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
            {
                FNST ()
            }

            Method (FNST, 0, NotSerialized)
            {
                If (H8DR)
                {
                    Local0 = HFNS /* \_SB_.PCI0.LPC0.EC0_.HFNS */
                    Local1 = HFNE /* \_SB_.PCI0.LPC0.EC0_.HFNE */
                }
                Else
                {
                    Local0 = (RBEC (0x0E) & 0x03)
                    Local1 = (RBEC (Zero) & 0x08)
                }

                If (Local1)
                {
                    If ((Local0 == Zero))
                    {
                        SCMS (0x11)
                    }

                    If ((Local0 == One))
                    {
                        SCMS (0x0F)
                    }

                    If ((Local0 == 0x02))
                    {
                        SCMS (0x10)
                    }

                    ^HKEY.MHKQ (0x6005)
                }
            }
        }

        Scope (HKEY)
        {
            Method (GHSL, 1, NotSerialized)
            {
                Return (FNSC (Zero, Zero))
            }

            Method (SHSL, 1, NotSerialized)
            {
                Return (FNSC (One, (Arg0 & 0x00010001)))
            }
        }

        Scope (HKEY)
        {
            Name (INDV, Zero)
            Method (MHQI, 0, NotSerialized)
            {
                Return (Zero)
            }

            Method (MHGI, 1, NotSerialized)
            {
                Name (RETB, Buffer (0x10){})
                CreateByteField (RETB, Zero, MHGS)
                Local0 = (One << Arg0)
                If ((INDV & Local0))
                {
                    If ((Arg0 == Zero))
                    {
                        CreateField (RETB, 0x08, 0x78, BRBU)
                        BRBU = IPMB /* \IPMB */
                        MHGS = 0x10
                    }
                    ElseIf ((Arg0 == One))
                    {
                        CreateField (RETB, 0x08, 0x18, RRBU)
                        RRBU = IPMR /* \IPMR */
                        MHGS = 0x04
                    }
                    ElseIf ((Arg0 == 0x08))
                    {
                        CreateField (RETB, 0x10, 0x18, ODBU)
                        CreateByteField (RETB, One, MHGZ)
                        ODBU = IPMO /* \IPMO */
                        MHGS = 0x05
                    }
                    ElseIf ((Arg0 == 0x09))
                    {
                        CreateField (RETB, 0x10, 0x08, AUBU)
                        AUBU = IPMA /* \IPMA */
                        RETB [One] = One
                        MHGS = 0x03
                    }
                    ElseIf ((Arg0 == 0x02))
                    {
                        Local1 = VDYN (Zero, Zero)
                        RETB [0x02] = (Local1 & 0x0F)
                        Local1 >>= 0x04
                        RETB [One] = (Local1 & 0x0F)
                        MHGS = 0x03
                    }
                }

                Return (RETB) /* \_SB_.PCI0.LPC0.EC0_.HKEY.MHGI.RETB */
            }

            Method (MHSI, 2, NotSerialized)
            {
                Local0 = (One << Arg0)
                If ((INDV & Local0))
                {
                    If ((Arg0 == 0x08))
                    {
                        If (Arg1)
                        {
                            If (H8DR)
                            {
                                Local1 = HPBU /* \_SB_.PCI0.LPC0.EC0_.HPBU */
                            }
                            Else
                            {
                                Local1 = (RBEC (0x47) & One)
                            }
                        }
                    }
                    ElseIf ((Arg0 == 0x02))
                    {
                        VDYN (One, Arg1)
                    }
                }
            }
        }

        Scope (HKEY)
        {
            Method (PWMC, 0, NotSerialized)
            {
                Return (Zero)
            }

            Method (PWMG, 0, NotSerialized)
            {
                Local0 = PWMH /* \_SB_.PCI0.LPC0.EC0_.PWMH */
                Local0 <<= 0x08
                Local0 |= PWML /* \_SB_.PCI0.LPC0.EC0_.PWML */
                Return (Local0)
            }
        }

        Scope (HKEY)
        {
            Name (WGFL, Zero)
            Method (WSIF, 0, NotSerialized)
            {
                Return (Zero)
            }

            Method (WLSW, 0, NotSerialized)
            {
                Return (0x10010001)
            }

            Method (GWAN, 0, NotSerialized)
            {
                Local0 = Zero
                If ((WGFL & One))
                {
                    Local0 |= One
                }

                If ((WGFL & 0x08))
                {
                    Return (Local0)
                }

                If (WPWS ())
                {
                    Local0 |= 0x02
                }

                Local0 |= 0x04
                Return (Local0)
            }

            Method (SWAN, 1, NotSerialized)
            {
                If ((Arg0 & 0x02))
                {
                    WPWC (One)
                }
                Else
                {
                    WPWC (Zero)
                }
            }

            Method (GBDC, 0, NotSerialized)
            {
                Local0 = Zero
                If ((WGFL & 0x10))
                {
                    Local0 |= One
                }

                If ((WGFL & 0x80))
                {
                    Return (Local0)
                }

                If (BPWS ())
                {
                    Local0 |= 0x02
                }

                Local0 |= 0x04
                Return (Local0)
            }

            Method (SBDC, 1, NotSerialized)
            {
                If ((Arg0 & 0x02))
                {
                    BPWC (One)
                }
                Else
                {
                    BPWC (Zero)
                }
            }

            Method (WPWS, 0, NotSerialized)
            {
                If (H8DR)
                {
                    Local0 = DCWW /* \_SB_.PCI0.LPC0.EC0_.DCWW */
                }
                Else
                {
                    Local0 = ((RBEC (0x3A) & 0x40) >> 0x06)
                }

                Return (Local0)
            }

            Method (WPWC, 1, NotSerialized)
            {
                If ((Arg0 && ((WGFL & One) && !(WGFL & 0x08
                    ))))
                {
                    If (H8DR)
                    {
                        DCWW = One
                    }
                    Else
                    {
                        MBEC (0x3A, 0xFF, 0x40)
                    }

                    WGFL |= 0x02
                }
                Else
                {
                    If (H8DR)
                    {
                        DCWW = Zero
                    }
                    Else
                    {
                        MBEC (0x3A, 0xBF, Zero)
                    }

                    WGFL &= 0xFFFFFFFD
                }
            }

            Method (BPWS, 0, NotSerialized)
            {
                If (H8DR)
                {
                    Local0 = DCBD /* \_SB_.PCI0.LPC0.EC0_.DCBD */
                }
                Else
                {
                    Local0 = ((RBEC (0x3A) & 0x10) >> 0x04)
                }

                Return (Local0)
            }

            Method (BPWC, 1, NotSerialized)
            {
                If ((Arg0 && ((WGFL & 0x10) && !(WGFL & 0x80
                    ))))
                {
                    If (H8DR)
                    {
                        DCBD = One
                    }
                    Else
                    {
                        MBEC (0x3A, 0xFF, 0x10)
                    }

                    WGFL |= 0x20
                }
                Else
                {
                    If (H8DR)
                    {
                        DCBD = Zero
                    }
                    Else
                    {
                        MBEC (0x3A, 0xEF, Zero)
                    }

                    WGFL &= 0xFFFFFFDF
                }
            }

            Method (WGIN, 0, NotSerialized)
            {
                WGFL = Zero
                WGFL = WGSV (One)
                If (WIN8)
                {
                    If ((WGFL && 0x10))
                    {
                        BPWC (One)
                    }
                }

                If (WPWS ())
                {
                    WGFL |= 0x02
                }

                If (BPWS ())
                {
                    WGFL |= 0x20
                }
            }

            Method (WGPS, 1, NotSerialized)
            {
                If ((Arg0 >= 0x04))
                {
                    BLTH (0x05)
                }
            }

            Method (WGWK, 1, NotSerialized)
            {
                Noop
            }
        }

        Scope (\_SB.PCI0.LPC0.EC0)
        {
            Method (_Q41, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
            {
                ^HKEY.MHKQ (0x7000)
            }
        }

        Scope (HKEY)
        {
            Mutex (BFWM, 0x00)
            Method (MHCF, 1, NotSerialized)
            {
                Local0 = BFWC (Arg0)
                Return (Local0)
            }

            Method (MHPF, 1, NotSerialized)
            {
                Name (RETB, Buffer (0x25){})
                Acquire (BFWM, 0xFFFF)
                If ((SizeOf (Arg0) <= 0x25))
                {
                    BFWB = Arg0
                    If (BFWP ())
                    {
                        CHKS ()
                        BFWL ()
                    }

                    RETB = BFWB /* \BFWB */
                }

                Release (BFWM)
                Return (RETB) /* \_SB_.PCI0.LPC0.EC0_.HKEY.MHPF.RETB */
            }

            Method (MHIF, 1, NotSerialized)
            {
                Name (RETB, Buffer (0x0A){})
                Acquire (BFWM, 0xFFFF)
                BFWG (Arg0)
                RETB = BFWB /* \BFWB */
                Release (BFWM)
                Return (RETB) /* \_SB_.PCI0.LPC0.EC0_.HKEY.MHIF.RETB */
            }

            Method (MHDM, 1, NotSerialized)
            {
                BDMC (Arg0)
            }
        }

        Scope (HKEY)
        {
            Method (PSSG, 1, NotSerialized)
            {
                Return (PSIF (Zero, Zero))
            }

            Method (PSSS, 1, NotSerialized)
            {
                Return (PSIF (One, Arg0))
            }

            Method (PSBS, 1, NotSerialized)
            {
                Return (PSIF (0x02, Arg0))
            }

            Method (BICG, 1, NotSerialized)
            {
                Return (PSIF (0x03, Arg0))
            }

            Method (BICS, 1, NotSerialized)
            {
                Return (PSIF (0x04, Arg0))
            }

            Method (BCTG, 1, NotSerialized)
            {
                Return (PSIF (0x05, Arg0))
            }

            Method (BCCS, 1, NotSerialized)
            {
                Return (PSIF (0x06, Arg0))
            }

            Method (BCSG, 1, NotSerialized)
            {
                Return (PSIF (0x07, Arg0))
            }

            Method (BCSS, 1, NotSerialized)
            {
                Return (PSIF (0x08, Arg0))
            }

            Method (BDSG, 1, NotSerialized)
            {
                Return (PSIF (0x09, Arg0))
            }

            Method (BDSS, 1, NotSerialized)
            {
                Return (PSIF (0x0A, Arg0))
            }
        }

        Scope (HKEY)
        {
            Method (GILN, 0, NotSerialized)
            {
                Return ((0x02 | ILNF))
            }

            Method (SILN, 1, NotSerialized)
            {
                If ((One == Arg0))
                {
                    ILNF = One
                    BBLS = Zero
                    Return (Zero)
                }
                ElseIf ((0x02 == Arg0))
                {
                    ILNF = Zero
                    BBLS = One
                    Return (Zero)
                }
                Else
                {
                    Return (One)
                }
            }

            Method (GLSI, 0, NotSerialized)
            {
                If (H8DR)
                {
                    Return ((0x02 + HPLD))
                }
                ElseIf ((RBEC (0x46) & 0x04))
                {
                    Return (0x03)
                }
                Else
                {
                    Return (0x02)
                }
            }
        }

        Scope (HKEY)
        {
            Method (GDLN, 0, NotSerialized)
            {
                Return ((0x02 | PLUX))
            }

            Method (SDLN, 1, NotSerialized)
            {
                If ((One == Arg0))
                {
                    PLUX = One
                    Return (Zero)
                }
                ElseIf ((0x02 == Arg0))
                {
                    PLUX = Zero
                    Return (Zero)
                }
                Else
                {
                    Return (One)
                }
            }
        }

        Scope (\_SB.PCI0.LPC0.EC0)
        {
            Method (_Q4E, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
            {
                If (H8DR)
                {
                    Local0 = PSST /* \_SB_.PCI0.LPC0.EC0_.PSST */
                    If (PSST)
                    {
                        ^HKEY.MHKQ (0x60B0)
                    }
                    Else
                    {
                        ^HKEY.MHKQ (0x60B1)
                    }
                }
                ElseIf ((RBEC (0x46) & 0x40))
                {
                    ^HKEY.MHKQ (0x60B0)
                }
                Else
                {
                    ^HKEY.MHKQ (0x60B1)
                }
            }
        }

        Scope (HKEY)
        {
            Method (GPSS, 0, NotSerialized)
            {
                If (H8DR)
                {
                    Local1 = PSST /* \_SB_.PCI0.LPC0.EC0_.PSST */
                }
                ElseIf ((RBEC (0x46) & 0x40))
                {
                    Local1 = One
                }
                Else
                {
                    Local1 = Zero
                }

                If ((RFIO (Zero) == Zero))
                {
                    Local0 = One
                }
                Else
                {
                    Local0 = Zero
                }

                Local0 |= (Local1 << One)
                Local0 &= 0x03
                Return (Local0)
            }
        }

        Scope (HKEY)
        {
            Name (AM00, Zero)
            Name (AM01, Zero)
            Name (AM02, Zero)
            Name (AM03, Zero)
            Name (AM04, Zero)
            Name (AM05, Zero)
            Name (AM06, Zero)
            Name (AM07, Zero)
            Name (AM08, Zero)
            Name (AM09, Zero)
            Name (AM0A, Zero)
            Name (AM0B, Zero)
            Name (AM0C, Zero)
            Name (AM0D, Zero)
            Name (AM0E, Zero)
            Name (AM0F, Zero)
            Name (FNLB, Zero)
            Name (QCKB, Zero)
            Name (QCMS, Zero)
            Method (LQCC, 1, NotSerialized)
            {
                Local1 = (Arg0 & 0xFFFF)
                Local0 = Zero
                If ((Local1 == 0x0100))
                {
                    Local1 = One
                    Return (Local1)
                }

                If ((Local1 == 0x0101))
                {
                    If (((Arg0 & 0x00010000) == 0x00010000))
                    {
                        If ((QCMS == Zero))
                        {
                            AM00 = (HAM0 & Zero)
                            AM01 = (HAM1 & Zero)
                            AM02 = (HAM2 & 0x78)
                            AM03 = (HAM3 & 0xB2)
                            AM04 = (HAM4 & Zero)
                            AM05 = (HAM5 & Zero)
                            AM06 = (HAM6 & Zero)
                            AM07 = (HAM7 & 0x70)
                            AM08 = (HAM8 & 0x08)
                            AM09 = (HAM9 & Zero)
                            AM0A = (HAMA & Zero)
                            AM0B = (HAMB & Zero)
                            AM0C = (HAMC & 0xFF)
                            AM0D = (HAMD & 0xFF)
                            AM0E = (HAME & 0x5D)
                            AM0F = (HAMF & 0x07)
                            HAM0 &= Ones
                            HAM1 &= Ones
                            HAM2 &= 0xFFFFFF87
                            HAM3 &= 0xFFFFFF4D
                            HAM4 &= Ones
                            HAM5 &= Ones
                            HAM6 &= Ones
                            HAM7 &= 0xFFFFFF8F
                            HAM8 &= 0xFFFFFFF7
                            HAM9 &= Ones
                            HAMA &= Ones
                            HAMB &= Ones
                            HAMC &= 0xFFFFFF00
                            HAMD &= 0xFFFFFF00
                            HAME &= 0xFFFFFFA2
                            HAMF &= 0xFFFFFFF8
                            FNLB = ESFL /* \_SB_.PCI0.LPC0.EC0_.ESFL */
                            ESFL = Zero
                            QCKB = QCON /* \_SB_.PCI0.LPC0.EC0_.QCON */
                            QCON = One
                            QCMS = One
                            Local0 = Zero
                        }
                        Else
                        {
                            Local0 = Zero
                        }
                    }
                    ElseIf ((QCMS == One))
                    {
                        HAM0 |= AM00 /* \_SB_.PCI0.LPC0.EC0_.HKEY.AM00 */
                        HAM1 |= AM01 /* \_SB_.PCI0.LPC0.EC0_.HKEY.AM01 */
                        HAM2 |= AM02 /* \_SB_.PCI0.LPC0.EC0_.HKEY.AM02 */
                        HAM3 |= AM03 /* \_SB_.PCI0.LPC0.EC0_.HKEY.AM03 */
                        HAM4 |= AM04 /* \_SB_.PCI0.LPC0.EC0_.HKEY.AM04 */
                        HAM5 |= AM05 /* \_SB_.PCI0.LPC0.EC0_.HKEY.AM05 */
                        HAM6 |= AM06 /* \_SB_.PCI0.LPC0.EC0_.HKEY.AM06 */
                        HAM7 |= AM07 /* \_SB_.PCI0.LPC0.EC0_.HKEY.AM07 */
                        HAM8 |= AM08 /* \_SB_.PCI0.LPC0.EC0_.HKEY.AM08 */
                        HAM9 |= AM09 /* \_SB_.PCI0.LPC0.EC0_.HKEY.AM09 */
                        HAMA |= AM0A /* \_SB_.PCI0.LPC0.EC0_.HKEY.AM0A */
                        HAMB |= AM0B /* \_SB_.PCI0.LPC0.EC0_.HKEY.AM0B */
                        HAMC |= AM0C /* \_SB_.PCI0.LPC0.EC0_.HKEY.AM0C */
                        HAMD |= AM0D /* \_SB_.PCI0.LPC0.EC0_.HKEY.AM0D */
                        HAME |= AM0E /* \_SB_.PCI0.LPC0.EC0_.HKEY.AM0E */
                        HAMF |= AM0F /* \_SB_.PCI0.LPC0.EC0_.HKEY.AM0F */
                        ESFL = FNLB /* \_SB_.PCI0.LPC0.EC0_.HKEY.FNLB */
                        QCON = QCKB /* \_SB_.PCI0.LPC0.EC0_.HKEY.QCKB */
                        QCMS = Zero
                        Local0 = Zero
                    }
                    Else
                    {
                        Local0 = Zero
                    }
                }

                Return (Local0)
            }
        }
    }

    Scope (_SB)
    {
        Name (HIDG, ToUUID ("3cdff6f7-4267-4555-ad05-b30a3d8938de") /* HID I2C Device */)
        Method (HIDD, 5, Serialized)
        {
            If ((Arg0 == HIDG))
            {
                If ((Arg2 == Zero))
                {
                    If ((Arg1 == One))
                    {
                        Return (Buffer (One)
                        {
                             0x03                                             // .
                        })
                    }
                }

                If ((Arg2 == One))
                {
                    Return (Arg4)
                }
            }

            Return (Buffer (One)
            {
                 0x00                                             // .
            })
        }

        Method (I2CM, 3, Serialized)
        {
            Switch (ToInteger (Arg0))
            {
                Case (Zero)
                {
                    Name (IICA, ResourceTemplate ()
                    {
                        I2cSerialBusV2 (0x0000, ControllerInitiated, 0x00061A80,
                            AddressingMode7Bit, "\\_SB.I2CA",
                            0x00, ResourceConsumer, _Y0D, Exclusive,
                            )
                    })
                    CreateWordField (IICA, \_SB.I2CM._Y0D._ADR, DADA)  // _ADR: Address
                    CreateDWordField (IICA, \_SB.I2CM._Y0D._SPE, DSPA)  // _SPE: Speed
                    DADA = Arg1
                    DSPA = Arg2
                    Return (IICA) /* \_SB_.I2CM.IICA */
                }
                Case (One)
                {
                    Name (IICB, ResourceTemplate ()
                    {
                        I2cSerialBusV2 (0x0000, ControllerInitiated, 0x00061A80,
                            AddressingMode7Bit, "\\_SB.I2CB",
                            0x00, ResourceConsumer, _Y0E, Exclusive,
                            )
                    })
                    CreateWordField (IICB, \_SB.I2CM._Y0E._ADR, DADB)  // _ADR: Address
                    CreateDWordField (IICB, \_SB.I2CM._Y0E._SPE, DSPB)  // _SPE: Speed
                    DADB = Arg1
                    DSPB = Arg2
                    Return (IICB) /* \_SB_.I2CM.IICB */
                }
                Case (0x02)
                {
                    Name (IICC, ResourceTemplate ()
                    {
                        I2cSerialBusV2 (0x0000, ControllerInitiated, 0x00061A80,
                            AddressingMode7Bit, "\\_SB.I2CC",
                            0x00, ResourceConsumer, _Y0F, Exclusive,
                            )
                    })
                    CreateWordField (IICC, \_SB.I2CM._Y0F._ADR, DADC)  // _ADR: Address
                    CreateDWordField (IICC, \_SB.I2CM._Y0F._SPE, DSPC)  // _SPE: Speed
                    DADC = Arg1
                    DSPC = Arg2
                    Return (IICC) /* \_SB_.I2CM.IICC */
                }
                Default
                {
                    Return (Zero)
                }

            }
        }
    }

    Scope (_SB.I2CA)
    {
        Name (I2CN, Zero)
        Name (I2CX, Zero)
        I2CN = IC0E /* \_SB_.IC0E */
        I2CX = Zero
    }

    Scope (_SB.I2CB)
    {
        Name (I2CN, Zero)
        Name (I2CX, Zero)
        I2CN = IC1E /* \_SB_.IC1E */
        I2CX = One
    }

    Scope (_SB.I2CC)
    {
        Name (I2CN, Zero)
        Name (I2CX, Zero)
        I2CN = IC2E /* \_SB_.IC2E */
        I2CX = 0x02
    }

    Scope (_SB.I2CC)
    {
        Device (TPD0)
        {
            Name (HID2, Zero)
            Name (SBFB, ResourceTemplate ()
            {
                I2cSerialBusV2 (0x0000, ControllerInitiated, 0x00061A80,
                    AddressingMode7Bit, "NULL",
                    0x00, ResourceConsumer, _Y10, Exclusive,
                    )
            })
            Name (SBFG, ResourceTemplate ()
            {
                GpioInt (Level, ActiveLow, ExclusiveAndWake, PullUp, 0x0000,
                    "\\_SB.GPIO", 0x00, ResourceConsumer, ,
                    )
                    {   // Pin list
                        0x0000
                    }
            })
            CreateWordField (SBFB, \_SB.I2CC.TPD0._Y10._ADR, BADR)  // _ADR: Address
            CreateDWordField (SBFB, \_SB.I2CC.TPD0._Y10._SPE, SPED)  // _SPE: Speed
            CreateWordField (SBFG, 0x17, INT1)
            Name (ITML, Package (0x03)
            {
                Package (0x06)
                {
                    0x04F3, 
                    0x3205, 
                    0x15, 
                    One, 
                    One, 
                    "ELAN06A0"
                }, 

                Package (0x06)
                {
                    0x04F3, 
                    0x3231, 
                    0x15, 
                    One, 
                    One, 
                    "ELAN06A0"
                }, 

                Package (0x06)
                {
                    0x04F3, 
                    0x3232, 
                    0x15, 
                    One, 
                    One, 
                    "ELAN06A1"
                }
            })
            Method (UHMS, 0, NotSerialized)
            {
                Local0 = Zero
                Local1 = SizeOf (ITML)
                While ((Local0 < Local1))
                {
                    Local2 = DerefOf (ITML [Local0])
                    Local3 = DerefOf (Local2 [Zero])
                    Local4 = DerefOf (Local2 [One])
                    If ((TDVI == Local3))
                    {
                        If ((TDPI == Local4))
                        {
                            BADR = DerefOf (Local2 [0x02])
                            HID2 = DerefOf (Local2 [0x03])
                            Local5 = DerefOf (Local2 [0x04])
                            _HID = DerefOf (Local2 [0x05])
                            If ((Local5 == Zero))
                            {
                                SPED = 0x000186A0
                            }

                            If ((Local5 == One))
                            {
                                SPED = 0x00061A80
                            }

                            If ((Local5 == 0x02))
                            {
                                SPED = 0x000F4240
                            }

                            Return (One)
                        }
                    }

                    Local0++
                }

                Return (Zero)
            }

            Method (_INI, 0, NotSerialized)  // _INI: Initialize
            {
                INT1 = 0x08
                UHMS ()
            }

            Name (_HID, "XXXX0000")  // _HID: Hardware ID
            Name (_CID, "PNP0C50" /* HID Protocol Device (I2C bus) */)  // _CID: Compatible ID
            Name (_S0W, 0x03)  // _S0W: S0 Device Wake State
            Method (_DSM, 4, Serialized)  // _DSM: Device-Specific Method
            {
                If ((Arg0 == HIDG))
                {
                    Return (HIDD (Arg0, Arg1, Arg2, Arg3, One))
                }

                Return (Buffer (One)
                {
                     0x00                                             // .
                })
            }

            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If (((TDVI == Zero) && (TDPI == Zero)))
                {
                    Return (Zero)
                }

                Return (0x0F)
            }

            Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
            {
                Return (ConcatenateResTemplate (I2CM (I2CX, BADR, SPED), SBFG))
            }
        }
    }

    Scope (_SB.I2CB)
    {
        Device (TPNL)
        {
            Name (HID2, Zero)
            Name (SBFB, ResourceTemplate ()
            {
                I2cSerialBusV2 (0x0000, ControllerInitiated, 0x00061A80,
                    AddressingMode7Bit, "NULL",
                    0x00, ResourceConsumer, _Y11, Exclusive,
                    )
            })
            Name (SBFG, ResourceTemplate ()
            {
                GpioInt (Level, ActiveLow, Exclusive, PullUp, 0x0000,
                    "\\_SB.GPIO", 0x00, ResourceConsumer, ,
                    )
                    {   // Pin list
                        0x0000
                    }
            })
            CreateWordField (SBFB, \_SB.I2CB.TPNL._Y11._ADR, BADR)  // _ADR: Address
            CreateDWordField (SBFB, \_SB.I2CB.TPNL._Y11._SPE, SPED)  // _SPE: Speed
            CreateWordField (SBFG, 0x17, INT1)
            Name (ITML, Package (0x05)
            {
                Package (0x06)
                {
                    0x056A, 
                    0x52E4, 
                    0x0A, 
                    One, 
                    One, 
                    "WACF2200"
                }, 

                Package (0x06)
                {
                    0x056A, 
                    0x52E5, 
                    0x0A, 
                    One, 
                    One, 
                    "WACF2200"
                }, 

                Package (0x06)
                {
                    0x056A, 
                    0x52E6, 
                    0x0A, 
                    One, 
                    One, 
                    "WACF2200"
                }, 

                Package (0x06)
                {
                    0x056A, 
                    0x52E7, 
                    0x0A, 
                    One, 
                    One, 
                    "WACF2200"
                }, 

                Package (0x06)
                {
                    0x056A, 
                    0x52E8, 
                    0x0A, 
                    One, 
                    One, 
                    "WACF2200"
                }
            })
            Method (UHMS, 0, NotSerialized)
            {
                Local0 = Zero
                Local1 = SizeOf (ITML)
                While ((Local0 < Local1))
                {
                    Local2 = DerefOf (ITML [Local0])
                    Local3 = DerefOf (Local2 [Zero])
                    Local4 = DerefOf (Local2 [One])
                    If ((TLVI == Local3))
                    {
                        If ((TLPI == Local4))
                        {
                            BADR = DerefOf (Local2 [0x02])
                            HID2 = DerefOf (Local2 [0x03])
                            Local5 = DerefOf (Local2 [0x04])
                            _HID = DerefOf (Local2 [0x05])
                            If ((Local5 == Zero))
                            {
                                SPED = 0x000186A0
                            }

                            If ((Local5 == One))
                            {
                                SPED = 0x00061A80
                            }

                            If ((Local5 == 0x02))
                            {
                                SPED = 0x000F4240
                            }

                            Return (One)
                        }
                    }

                    Local0++
                }

                Return (Zero)
            }

            Name (_HID, "XXXX0000")  // _HID: Hardware ID
            Name (_CID, "PNP0C50" /* HID Protocol Device (I2C bus) */)  // _CID: Compatible ID
            Name (_S0W, 0x03)  // _S0W: S0 Device Wake State
            Method (_INI, 0, NotSerialized)  // _INI: Initialize
            {
                INT1 = 0x20
                SPED = 0x00061A80
                BADR = 0x0A
            }

            Method (_DSM, 4, Serialized)  // _DSM: Device-Specific Method
            {
                If ((Arg0 == HIDG))
                {
                    Return (HIDD (Arg0, Arg1, Arg2, Arg3, HID2))
                }

                Return (Buffer (One)
                {
                     0x00                                             // .
                })
            }

            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                Return (0x0F)
            }

            Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
            {
                Return (ConcatenateResTemplate (I2CM (I2CX, BADR, SPED), SBFG))
            }
        }
    }

    Scope (_SB.I2CB)
    {
        Device (SPKR)
        {
            Name (_HID, "CSC3551")  // _HID: Hardware ID
            Method (_SUB, 0, Serialized)  // _SUB: Subsystem ID
            {
                If ((RFIO (0x87) == One))
                {
                    Return ("17AA22F1")
                }
                Else
                {
                    Return ("17AA22F2")
                }
            }

            Name (_UID, One)  // _UID: Unique ID
            Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
            {
                Name (RBUF, ResourceTemplate ()
                {
                    I2cSerialBusV2 (0x0040, ControllerInitiated, 0x000F4240,
                        AddressingMode7Bit, "\\_SB.I2CB",
                        0x00, ResourceConsumer, , Exclusive,
                        )
                    I2cSerialBusV2 (0x0041, ControllerInitiated, 0x000F4240,
                        AddressingMode7Bit, "\\_SB.I2CB",
                        0x00, ResourceConsumer, , Exclusive,
                        )
                    GpioIo (Exclusive, PullDown, 0x0000, 0x0000, IoRestrictionOutputOnly,
                        "\\_SB.GPIO", 0x00, ResourceConsumer, ,
                        )
                        {   // Pin list
                            0x0004
                        }
                    GpioInt (Edge, ActiveLow, SharedAndWake, PullUp, 0x0000,
                        "\\_SB.GPIO", 0x00, ResourceConsumer, ,
                        )
                        {   // Pin list
                            0x0059
                        }
                })
                Return (RBUF) /* \_SB_.I2CB.SPKR._CRS.RBUF */
            }

            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                Return (0x0F)
            }

            Method (_DIS, 0, NotSerialized)  // _DIS: Disable Device
            {
            }

            Name (_DSD, Package ()  // _DSD: Device-Specific Data
            {
                ToUUID ("daffd814-6eba-4d8c-8a91-bc9bbf4aa301"),
                Package ()
                {
                    Package () { "cirrus,dev-index", Package () { 0x40, 0x41 } },
                    Package () { "reset-gpios", Package () {
                        SPKR, Zero, Zero, Zero,
                        SPKR, Zero, Zero, Zero
                    } },
                    Package () { "cirrus,speaker-position", Package () { Zero, One } },
                    Package () { "cirrus,gpio1-func", Package () { One, One } },
                    Package () { "cirrus,gpio2-func", Package () { 0x02, 0x02 } },
                    Package () { "cirrus,boost-type", Package () { One, One } }
                }
            })
        }
    }

    Scope (_SB.PCI0.LPC0.EC0)
    {
        Device (LSSD)
        {
            Name (_HID, EisaId ("LEN0111"))  // _HID: Hardware ID
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                Return (0x0F)
            }
        }
    }

    Scope (_SB.PCI0.LPC0.EC0.HKEY)
    {
        Name (MPL0, 0x32C8)
        Name (SPP0, 0x4268)
        Name (FPP0, 0x61A8)
        Name (STC0, 0x05)
        Name (ALA0, 0x1999)
        Name (STL0, 0x2D00)
        Name (ERC0, 0x0147)
        Name (ERA0, 0x2666)
        Name (SM10, 0x014B)
        Name (SM20, 0x0373)
        Name (SCA0, 0xE4C7)
        Name (TCL0, 0x56)
        Name (MPL1, 0x2AF8)
        Name (SPP1, 0x2AF8)
        Name (FPP1, 0x2AF8)
        Name (STC1, 0x05)
        Name (ALA1, 0x1999)
        Name (STL1, 0x2D00)
        Name (ERC1, 0x0147)
        Name (ERA1, 0x2666)
        Name (SM11, 0x0169)
        Name (SM21, 0x02A9)
        Name (SCA1, 0xFAA4)
        Name (TCL1, 0x46)
        Name (MPL2, 0x4268)
        Name (SPP2, 0x5208)
        Name (FPP2, 0x7530)
        Name (STC2, 0x05)
        Name (ALA2, 0x1999)
        Name (STL2, 0x3100)
        Name (ERC2, 0x0147)
        Name (ERA2, 0x2666)
        Name (SM12, 0x0157)
        Name (SM22, 0x0303)
        Name (SCA2, 0xF264)
        Name (TCL2, 0x60)
        Name (MPL3, 0x32C8)
        Name (SPP3, 0x4268)
        Name (FPP3, 0x61A8)
        Name (STC3, 0x05)
        Name (ALA3, 0x1999)
        Name (STL3, 0x2D00)
        Name (ERC3, 0x0147)
        Name (ERA3, 0x2666)
        Name (SM13, 0x014B)
        Name (SM23, 0x0373)
        Name (SCA3, 0xE4C7)
        Name (TCL3, 0x56)
        Name (MPL4, 0x2AF8)
        Name (SPP4, 0x2AF8)
        Name (FPP4, 0x2AF8)
        Name (STC4, 0x05)
        Name (ALA4, 0x1999)
        Name (STL4, 0x2D00)
        Name (ERC4, 0x0147)
        Name (ERA4, 0x2666)
        Name (SM14, 0x0169)
        Name (SM24, 0x02A9)
        Name (SCA4, 0xFAA4)
        Name (TCL4, 0x46)
        Name (MPLA, 0x2AF8)
        Name (SPPA, 0x2AF8)
        Name (FPPA, 0x2AF8)
        Name (STCA, 0x05)
        Name (ALAA, 0x1999)
        Name (STLA, 0x2D00)
        Name (ERCA, 0x0147)
        Name (ERAA, 0x2666)
        Name (SM1A, 0x0169)
        Name (SM2A, 0x02A9)
        Name (SCAA, 0xFAA4)
        Name (TCLA, 0x46)
        Name (TDCA, 0x80E8)
        Name (EDCA, 0xC350)
        Name (TDCN, 0xABE0)
        Name (EDCN, 0x00017318)
        Name (MPL5, 0x32C8)
        Name (SPP5, 0x4650)
        Name (FPP5, 0x61A8)
        Name (STC5, 0x05)
        Name (ALA5, 0x1999)
        Name (STL5, 0x2C80)
        Name (ERC5, 0x0147)
        Name (ERA5, 0x2666)
        Name (SM15, 0x01B9)
        Name (SM25, 0x020B)
        Name (SCA5, 0xFAC0)
        Name (TCL5, 0x56)
        Name (MPL6, 0x2AF8)
        Name (SPP6, 0x2AF8)
        Name (FPP6, 0x2AF8)
        Name (STC6, 0x05)
        Name (ALA6, 0x1999)
        Name (STL6, 0x2D00)
        Name (ERC6, 0x0147)
        Name (ERA6, 0x2666)
        Name (SM16, 0x01D6)
        Name (SM26, 0x0183)
        Name (SCA6, 0x0712)
        Name (TCL6, 0x46)
        Name (MPL7, 0x4268)
        Name (SPP7, 0x55F0)
        Name (FPP7, 0x7530)
        Name (STC7, 0x05)
        Name (ALA7, 0x1999)
        Name (STL7, 0x2C80)
        Name (ERC7, 0x0147)
        Name (ERA7, 0x2666)
        Name (SM17, 0x01FD)
        Name (SM27, 0x0149)
        Name (SCA7, 0x083D)
        Name (TCL7, 0x60)
        Name (MPL8, 0x32C8)
        Name (SPP8, 0x4650)
        Name (FPP8, 0x61A8)
        Name (STC8, 0x05)
        Name (ALA8, 0x1999)
        Name (STL8, 0x2C80)
        Name (ERC8, 0x0147)
        Name (ERA8, 0x2666)
        Name (SM18, 0x01B9)
        Name (SM28, 0x020B)
        Name (SCA8, 0xFAC0)
        Name (TCL8, 0x56)
        Name (MPL9, 0x2AF8)
        Name (SPP9, 0x2AF8)
        Name (FPP9, 0x2AF8)
        Name (STC9, 0x05)
        Name (ALA9, 0x1999)
        Name (STL9, 0x2D00)
        Name (ERC9, 0x0147)
        Name (ERA9, 0x2666)
        Name (SM19, 0x01D6)
        Name (SM29, 0x0183)
        Name (SCA9, 0x0712)
        Name (TCL9, 0x46)
        Name (MPLB, 0x2AF8)
        Name (SPPB, 0x2AF8)
        Name (FPPB, 0x2AF8)
        Name (STCB, 0x05)
        Name (ALAB, 0x1999)
        Name (STLB, 0x2D00)
        Name (ERCB, 0x0147)
        Name (ERAB, 0x2666)
        Name (SM1B, 0x01D6)
        Name (SM2B, 0x0183)
        Name (SCAB, 0x0712)
        Name (TCLB, 0x46)
        Method (DYTC, 1, Serialized)
        {
            Local0 = Arg0
            DYPR = Arg0
            Local1 = Zero
            Name (XX11, Buffer (0x07){})
            Name (TSCB, 0x0F)
            Name (TSCC, 0x0F)
            CreateWordField (XX11, Zero, SSZE)
            CreateByteField (XX11, 0x02, SMUF)
            CreateDWordField (XX11, 0x03, SMUD)
            SSZE = 0x07
            Switch (ToInteger ((Local0 & 0x01FF)))
            {
                Case (Zero)
                {
                    Local1 = 0x0100
                    Local1 |= 0x60000000
                    Local1 |= Zero
                    Local1 |= One
                }
                Case (One)
                {
                    Local2 = ((Local0 >> 0x0C) & 0x0F)
                    Local3 = ((Local0 >> 0x10) & 0x0F)
                    Local4 = ((Local0 >> 0x14) & One)
                    Switch (Local2)
                    {
                        Case (One)
                        {
                            If ((Local3 != 0x0F))
                            {
                                Local1 = 0x0A
                                Return (Local1)
                            }

                            If ((Local4 == Zero))
                            {
                                If ((One == VCQL))
                                {
                                    VCQL = Zero
                                }
                            }
                            ElseIf (((VPSC == One) && ((SPSC == 0x07) || (SPSC == 
                                0x08))))
                            {
                                VCQL = One
                            }
                        }
                        Case (0x04)
                        {
                            If ((Local3 != 0x0F))
                            {
                                Local1 = 0x0A
                                Return (Local1)
                            }

                            If ((Local4 == Zero))
                            {
                                VSTP = Zero
                            }
                            Else
                            {
                                VSTP = One
                            }
                        }
                        Case (0x0D)
                        {
                            If (((Local3 <= 0x08) && (Local3 >= One)))
                            {
                                If ((Local4 != One))
                                {
                                    Local1 = 0x0A
                                    Return (Local1)
                                }
                            }
                            ElseIf ((Local3 == 0x0F))
                            {
                                If ((Local4 != Zero))
                                {
                                    Local1 = 0x0A
                                    Return (Local1)
                                }
                            }
                            Else
                            {
                                Local1 = 0x0A
                                Return (Local1)
                            }

                            If ((Local4 == Zero))
                            {
                                VPSC = Zero
                                SPSC = Zero
                            }
                            Else
                            {
                                VCQL = Zero
                                VPSC = One
                                SPSC = Local3
                            }
                        }
                        Case (Zero)
                        {
                            If ((Local3 != 0x0F))
                            {
                                Local1 = 0x0A
                                Return (Local1)
                            }
                        }
                        Default
                        {
                            Local1 = 0x02
                            Return (Local1)
                        }

                    }

                    If (H8DR){}
                    ElseIf ((((RBEC (0x34) & 0x10) == Zero) || ((
                        RBEC (0x35) & 0x10) == 0x10)))
                    {
                        VSTP = One
                    }

                    If ((RFIO (0x4C) == One))
                    {
                        If ((HB0A == Zero))
                        {
                            SMUF = 0x2E
                            SMUD = MPLA /* \_SB_.PCI0.LPC0.EC0_.HKEY.MPLA */
                            ALIB (0x0C, XX11)
                            SMUF = 0x06
                            SMUD = FPPA /* \_SB_.PCI0.LPC0.EC0_.HKEY.FPPA */
                            ALIB (0x0C, XX11)
                            SMUF = 0x07
                            SMUD = SPPA /* \_SB_.PCI0.LPC0.EC0_.HKEY.SPPA */
                            ALIB (0x0C, XX11)
                            SMUF = 0x08
                            SMUD = STCA /* \_SB_.PCI0.LPC0.EC0_.HKEY.STCA */
                            ALIB (0x0C, XX11)
                            SMUF = 0x20
                            SMUD = ALAA /* \_SB_.PCI0.LPC0.EC0_.HKEY.ALAA */
                            ALIB (0x0C, XX11)
                            SMUF = 0x22
                            SMUD = STLA /* \_SB_.PCI0.LPC0.EC0_.HKEY.STLA */
                            ALIB (0x0C, XX11)
                            SMUF = 0x24
                            SMUD = ERCA /* \_SB_.PCI0.LPC0.EC0_.HKEY.ERCA */
                            ALIB (0x0C, XX11)
                            SMUF = 0x25
                            SMUD = ERAA /* \_SB_.PCI0.LPC0.EC0_.HKEY.ERAA */
                            ALIB (0x0C, XX11)
                            SMUF = 0x26
                            SMUD = SM1A /* \_SB_.PCI0.LPC0.EC0_.HKEY.SM1A */
                            ALIB (0x0C, XX11)
                            SMUF = 0x27
                            SMUD = SM2A /* \_SB_.PCI0.LPC0.EC0_.HKEY.SM2A */
                            ALIB (0x0C, XX11)
                            SMUF = 0x2C
                            SMUD = SCAA /* \_SB_.PCI0.LPC0.EC0_.HKEY.SCAA */
                            ALIB (0x0C, XX11)
                            SMUF = 0x03
                            If ((VSTP == One))
                            {
                                SMUD = TCL4 /* \_SB_.PCI0.LPC0.EC0_.HKEY.TCL4 */
                            }
                            Else
                            {
                                SMUD = TCLA /* \_SB_.PCI0.LPC0.EC0_.HKEY.TCLA */
                            }

                            ALIB (0x0C, XX11)
                            SMUF = 0x0B
                            SMUD = TDCA /* \_SB_.PCI0.LPC0.EC0_.HKEY.TDCA */
                            ALIB (0x0C, XX11)
                            SMUF = 0x0C
                            SMUD = EDCA /* \_SB_.PCI0.LPC0.EC0_.HKEY.EDCA */
                            ALIB (0x0C, XX11)
                        }
                        ElseIf ((VCQL == One))
                        {
                            CICF = One
                            SMUF = 0x2E
                            If ((VSTP == One))
                            {
                                SMUD = MPL4 /* \_SB_.PCI0.LPC0.EC0_.HKEY.MPL4 */
                            }
                            Else
                            {
                                SMUD = MPL0 /* \_SB_.PCI0.LPC0.EC0_.HKEY.MPL0 */
                            }

                            ALIB (0x0C, XX11)
                            SMUF = 0x06
                            If ((VSTP == One))
                            {
                                SMUD = FPP4 /* \_SB_.PCI0.LPC0.EC0_.HKEY.FPP4 */
                            }
                            Else
                            {
                                SMUD = FPP0 /* \_SB_.PCI0.LPC0.EC0_.HKEY.FPP0 */
                            }

                            ALIB (0x0C, XX11)
                            SMUF = 0x07
                            If ((VSTP == One))
                            {
                                SMUD = SPP4 /* \_SB_.PCI0.LPC0.EC0_.HKEY.SPP4 */
                            }
                            Else
                            {
                                SMUD = SPP0 /* \_SB_.PCI0.LPC0.EC0_.HKEY.SPP0 */
                            }

                            ALIB (0x0C, XX11)
                            SMUF = 0x08
                            If ((VSTP == One))
                            {
                                SMUD = STC4 /* \_SB_.PCI0.LPC0.EC0_.HKEY.STC4 */
                            }
                            Else
                            {
                                SMUD = STC0 /* \_SB_.PCI0.LPC0.EC0_.HKEY.STC0 */
                            }

                            ALIB (0x0C, XX11)
                            SMUF = 0x20
                            If ((VSTP == One))
                            {
                                SMUD = ALA4 /* \_SB_.PCI0.LPC0.EC0_.HKEY.ALA4 */
                            }
                            Else
                            {
                                SMUD = ALA0 /* \_SB_.PCI0.LPC0.EC0_.HKEY.ALA0 */
                            }

                            ALIB (0x0C, XX11)
                            SMUF = 0x22
                            If ((VSTP == One))
                            {
                                SMUD = STL4 /* \_SB_.PCI0.LPC0.EC0_.HKEY.STL4 */
                            }
                            Else
                            {
                                SMUD = STL0 /* \_SB_.PCI0.LPC0.EC0_.HKEY.STL0 */
                            }

                            ALIB (0x0C, XX11)
                            SMUF = 0x24
                            If ((VSTP == One))
                            {
                                SMUD = ERC4 /* \_SB_.PCI0.LPC0.EC0_.HKEY.ERC4 */
                            }
                            Else
                            {
                                SMUD = ERC0 /* \_SB_.PCI0.LPC0.EC0_.HKEY.ERC0 */
                            }

                            ALIB (0x0C, XX11)
                            SMUF = 0x25
                            If ((VSTP == One))
                            {
                                SMUD = ERA4 /* \_SB_.PCI0.LPC0.EC0_.HKEY.ERA4 */
                            }
                            Else
                            {
                                SMUD = ERA0 /* \_SB_.PCI0.LPC0.EC0_.HKEY.ERA0 */
                            }

                            ALIB (0x0C, XX11)
                            SMUF = 0x26
                            If ((VSTP == One))
                            {
                                SMUD = SM14 /* \_SB_.PCI0.LPC0.EC0_.HKEY.SM14 */
                            }
                            Else
                            {
                                SMUD = SM10 /* \_SB_.PCI0.LPC0.EC0_.HKEY.SM10 */
                            }

                            ALIB (0x0C, XX11)
                            SMUF = 0x27
                            If ((VSTP == One))
                            {
                                SMUD = SM24 /* \_SB_.PCI0.LPC0.EC0_.HKEY.SM24 */
                            }
                            Else
                            {
                                SMUD = SM20 /* \_SB_.PCI0.LPC0.EC0_.HKEY.SM20 */
                            }

                            ALIB (0x0C, XX11)
                            SMUF = 0x2C
                            If ((VSTP == One))
                            {
                                SMUD = SCA4 /* \_SB_.PCI0.LPC0.EC0_.HKEY.SCA4 */
                            }
                            Else
                            {
                                SMUD = SCA0 /* \_SB_.PCI0.LPC0.EC0_.HKEY.SCA0 */
                            }

                            ALIB (0x0C, XX11)
                            SMUF = 0x03
                            If ((VSTP == One))
                            {
                                SMUD = TCL4 /* \_SB_.PCI0.LPC0.EC0_.HKEY.TCL4 */
                            }
                            Else
                            {
                                SMUD = TCL0 /* \_SB_.PCI0.LPC0.EC0_.HKEY.TCL0 */
                            }

                            ALIB (0x0C, XX11)
                            SMUF = 0x0B
                            SMUD = TDCN /* \_SB_.PCI0.LPC0.EC0_.HKEY.TDCN */
                            ALIB (0x0C, XX11)
                            SMUF = 0x0C
                            SMUD = EDCN /* \_SB_.PCI0.LPC0.EC0_.HKEY.EDCN */
                            ALIB (0x0C, XX11)
                        }
                        ElseIf ((VPSC == One))
                        {
                            CICF = 0x0D
                            Local7 = SPSC /* \SPSC */
                            Switch (Local7)
                            {
                                Case (Package (0x02)
                                    {
                                        0x07, 
                                        0x08
                                    }

)
                                {
                                    SMUF = 0x2E
                                    If ((VSTP == One))
                                    {
                                        SMUD = MPL4 /* \_SB_.PCI0.LPC0.EC0_.HKEY.MPL4 */
                                    }
                                    Else
                                    {
                                        SMUD = MPL2 /* \_SB_.PCI0.LPC0.EC0_.HKEY.MPL2 */
                                    }

                                    ALIB (0x0C, XX11)
                                    SMUF = 0x06
                                    If ((VSTP == One))
                                    {
                                        SMUD = FPP4 /* \_SB_.PCI0.LPC0.EC0_.HKEY.FPP4 */
                                    }
                                    Else
                                    {
                                        SMUD = FPP2 /* \_SB_.PCI0.LPC0.EC0_.HKEY.FPP2 */
                                    }

                                    ALIB (0x0C, XX11)
                                    SMUF = 0x07
                                    If ((VSTP == One))
                                    {
                                        SMUD = SPP4 /* \_SB_.PCI0.LPC0.EC0_.HKEY.SPP4 */
                                    }
                                    Else
                                    {
                                        SMUD = SPP2 /* \_SB_.PCI0.LPC0.EC0_.HKEY.SPP2 */
                                    }

                                    ALIB (0x0C, XX11)
                                    SMUF = 0x08
                                    If ((VSTP == One))
                                    {
                                        SMUD = STC4 /* \_SB_.PCI0.LPC0.EC0_.HKEY.STC4 */
                                    }
                                    Else
                                    {
                                        SMUD = STC2 /* \_SB_.PCI0.LPC0.EC0_.HKEY.STC2 */
                                    }

                                    ALIB (0x0C, XX11)
                                    SMUF = 0x20
                                    If ((VSTP == One))
                                    {
                                        SMUD = ALA4 /* \_SB_.PCI0.LPC0.EC0_.HKEY.ALA4 */
                                    }
                                    Else
                                    {
                                        SMUD = ALA2 /* \_SB_.PCI0.LPC0.EC0_.HKEY.ALA2 */
                                    }

                                    ALIB (0x0C, XX11)
                                    SMUF = 0x22
                                    If ((VSTP == One))
                                    {
                                        SMUD = STL4 /* \_SB_.PCI0.LPC0.EC0_.HKEY.STL4 */
                                    }
                                    Else
                                    {
                                        SMUD = STL2 /* \_SB_.PCI0.LPC0.EC0_.HKEY.STL2 */
                                    }

                                    ALIB (0x0C, XX11)
                                    SMUF = 0x24
                                    If ((VSTP == One))
                                    {
                                        SMUD = ERC4 /* \_SB_.PCI0.LPC0.EC0_.HKEY.ERC4 */
                                    }
                                    Else
                                    {
                                        SMUD = ERC2 /* \_SB_.PCI0.LPC0.EC0_.HKEY.ERC2 */
                                    }

                                    ALIB (0x0C, XX11)
                                    SMUF = 0x25
                                    If ((VSTP == One))
                                    {
                                        SMUD = ERA4 /* \_SB_.PCI0.LPC0.EC0_.HKEY.ERA4 */
                                    }
                                    Else
                                    {
                                        SMUD = ERA2 /* \_SB_.PCI0.LPC0.EC0_.HKEY.ERA2 */
                                    }

                                    ALIB (0x0C, XX11)
                                    SMUF = 0x26
                                    If ((VSTP == One))
                                    {
                                        SMUD = SM14 /* \_SB_.PCI0.LPC0.EC0_.HKEY.SM14 */
                                    }
                                    Else
                                    {
                                        SMUD = SM12 /* \_SB_.PCI0.LPC0.EC0_.HKEY.SM12 */
                                    }

                                    ALIB (0x0C, XX11)
                                    SMUF = 0x27
                                    If ((VSTP == One))
                                    {
                                        SMUD = SM24 /* \_SB_.PCI0.LPC0.EC0_.HKEY.SM24 */
                                    }
                                    Else
                                    {
                                        SMUD = SM22 /* \_SB_.PCI0.LPC0.EC0_.HKEY.SM22 */
                                    }

                                    ALIB (0x0C, XX11)
                                    SMUF = 0x2C
                                    If ((VSTP == One))
                                    {
                                        SMUD = SCA4 /* \_SB_.PCI0.LPC0.EC0_.HKEY.SCA4 */
                                    }
                                    Else
                                    {
                                        SMUD = SCA2 /* \_SB_.PCI0.LPC0.EC0_.HKEY.SCA2 */
                                    }

                                    ALIB (0x0C, XX11)
                                    SMUF = 0x03
                                    If ((VSTP == One))
                                    {
                                        SMUD = TCL4 /* \_SB_.PCI0.LPC0.EC0_.HKEY.TCL4 */
                                    }
                                    Else
                                    {
                                        SMUD = TCL2 /* \_SB_.PCI0.LPC0.EC0_.HKEY.TCL2 */
                                    }

                                    ALIB (0x0C, XX11)
                                    SMUF = 0x0B
                                    SMUD = TDCN /* \_SB_.PCI0.LPC0.EC0_.HKEY.TDCN */
                                    ALIB (0x0C, XX11)
                                    SMUF = 0x0C
                                    SMUD = EDCN /* \_SB_.PCI0.LPC0.EC0_.HKEY.EDCN */
                                    ALIB (0x0C, XX11)
                                }
                                Case (Package (0x03)
                                    {
                                        0x02, 
                                        0x03, 
                                        0x04
                                    }

)
                                {
                                    SMUF = 0x2E
                                    If ((VSTP == One))
                                    {
                                        SMUD = MPL4 /* \_SB_.PCI0.LPC0.EC0_.HKEY.MPL4 */
                                    }
                                    Else
                                    {
                                        SMUD = MPL1 /* \_SB_.PCI0.LPC0.EC0_.HKEY.MPL1 */
                                    }

                                    ALIB (0x0C, XX11)
                                    SMUF = 0x06
                                    If ((VSTP == One))
                                    {
                                        SMUD = FPP4 /* \_SB_.PCI0.LPC0.EC0_.HKEY.FPP4 */
                                    }
                                    Else
                                    {
                                        SMUD = FPP1 /* \_SB_.PCI0.LPC0.EC0_.HKEY.FPP1 */
                                    }

                                    ALIB (0x0C, XX11)
                                    SMUF = 0x07
                                    If ((VSTP == One))
                                    {
                                        SMUD = SPP4 /* \_SB_.PCI0.LPC0.EC0_.HKEY.SPP4 */
                                    }
                                    Else
                                    {
                                        SMUD = SPP1 /* \_SB_.PCI0.LPC0.EC0_.HKEY.SPP1 */
                                    }

                                    ALIB (0x0C, XX11)
                                    SMUF = 0x08
                                    If ((VSTP == One))
                                    {
                                        SMUD = STC4 /* \_SB_.PCI0.LPC0.EC0_.HKEY.STC4 */
                                    }
                                    Else
                                    {
                                        SMUD = STC1 /* \_SB_.PCI0.LPC0.EC0_.HKEY.STC1 */
                                    }

                                    ALIB (0x0C, XX11)
                                    SMUF = 0x20
                                    If ((VSTP == One))
                                    {
                                        SMUD = ALA4 /* \_SB_.PCI0.LPC0.EC0_.HKEY.ALA4 */
                                    }
                                    Else
                                    {
                                        SMUD = ALA1 /* \_SB_.PCI0.LPC0.EC0_.HKEY.ALA1 */
                                    }

                                    ALIB (0x0C, XX11)
                                    SMUF = 0x22
                                    If ((VSTP == One))
                                    {
                                        SMUD = STL4 /* \_SB_.PCI0.LPC0.EC0_.HKEY.STL4 */
                                    }
                                    Else
                                    {
                                        SMUD = STL1 /* \_SB_.PCI0.LPC0.EC0_.HKEY.STL1 */
                                    }

                                    ALIB (0x0C, XX11)
                                    SMUF = 0x24
                                    If ((VSTP == One))
                                    {
                                        SMUD = ERC4 /* \_SB_.PCI0.LPC0.EC0_.HKEY.ERC4 */
                                    }
                                    Else
                                    {
                                        SMUD = ERC1 /* \_SB_.PCI0.LPC0.EC0_.HKEY.ERC1 */
                                    }

                                    ALIB (0x0C, XX11)
                                    SMUF = 0x25
                                    If ((VSTP == One))
                                    {
                                        SMUD = ERA4 /* \_SB_.PCI0.LPC0.EC0_.HKEY.ERA4 */
                                    }
                                    Else
                                    {
                                        SMUD = ERA1 /* \_SB_.PCI0.LPC0.EC0_.HKEY.ERA1 */
                                    }

                                    ALIB (0x0C, XX11)
                                    SMUF = 0x26
                                    If ((VSTP == One))
                                    {
                                        SMUD = SM14 /* \_SB_.PCI0.LPC0.EC0_.HKEY.SM14 */
                                    }
                                    Else
                                    {
                                        SMUD = SM11 /* \_SB_.PCI0.LPC0.EC0_.HKEY.SM11 */
                                    }

                                    ALIB (0x0C, XX11)
                                    SMUF = 0x27
                                    If ((VSTP == One))
                                    {
                                        SMUD = SM24 /* \_SB_.PCI0.LPC0.EC0_.HKEY.SM24 */
                                    }
                                    Else
                                    {
                                        SMUD = SM21 /* \_SB_.PCI0.LPC0.EC0_.HKEY.SM21 */
                                    }

                                    ALIB (0x0C, XX11)
                                    SMUF = 0x2C
                                    If ((VSTP == One))
                                    {
                                        SMUD = SCA4 /* \_SB_.PCI0.LPC0.EC0_.HKEY.SCA4 */
                                    }
                                    Else
                                    {
                                        SMUD = SCA1 /* \_SB_.PCI0.LPC0.EC0_.HKEY.SCA1 */
                                    }

                                    ALIB (0x0C, XX11)
                                    SMUF = 0x03
                                    If ((VSTP == One))
                                    {
                                        SMUD = TCL4 /* \_SB_.PCI0.LPC0.EC0_.HKEY.TCL4 */
                                    }
                                    Else
                                    {
                                        SMUD = TCL1 /* \_SB_.PCI0.LPC0.EC0_.HKEY.TCL1 */
                                    }

                                    ALIB (0x0C, XX11)
                                    SMUF = 0x0B
                                    SMUD = TDCN /* \_SB_.PCI0.LPC0.EC0_.HKEY.TDCN */
                                    ALIB (0x0C, XX11)
                                    SMUF = 0x0C
                                    SMUD = EDCN /* \_SB_.PCI0.LPC0.EC0_.HKEY.EDCN */
                                    ALIB (0x0C, XX11)
                                }
                                Default
                                {
                                    SMUF = 0x2E
                                    If ((VSTP == One))
                                    {
                                        SMUD = MPL4 /* \_SB_.PCI0.LPC0.EC0_.HKEY.MPL4 */
                                    }
                                    Else
                                    {
                                        SMUD = MPL3 /* \_SB_.PCI0.LPC0.EC0_.HKEY.MPL3 */
                                    }

                                    ALIB (0x0C, XX11)
                                    SMUF = 0x06
                                    If ((VSTP == One))
                                    {
                                        SMUD = FPP4 /* \_SB_.PCI0.LPC0.EC0_.HKEY.FPP4 */
                                    }
                                    Else
                                    {
                                        SMUD = FPP3 /* \_SB_.PCI0.LPC0.EC0_.HKEY.FPP3 */
                                    }

                                    ALIB (0x0C, XX11)
                                    SMUF = 0x07
                                    If ((VSTP == One))
                                    {
                                        SMUD = SPP4 /* \_SB_.PCI0.LPC0.EC0_.HKEY.SPP4 */
                                    }
                                    Else
                                    {
                                        SMUD = SPP3 /* \_SB_.PCI0.LPC0.EC0_.HKEY.SPP3 */
                                    }

                                    ALIB (0x0C, XX11)
                                    SMUF = 0x08
                                    If ((VSTP == One))
                                    {
                                        SMUD = STC4 /* \_SB_.PCI0.LPC0.EC0_.HKEY.STC4 */
                                    }
                                    Else
                                    {
                                        SMUD = STC3 /* \_SB_.PCI0.LPC0.EC0_.HKEY.STC3 */
                                    }

                                    ALIB (0x0C, XX11)
                                    SMUF = 0x20
                                    If ((VSTP == One))
                                    {
                                        SMUD = ALA4 /* \_SB_.PCI0.LPC0.EC0_.HKEY.ALA4 */
                                    }
                                    Else
                                    {
                                        SMUD = ALA3 /* \_SB_.PCI0.LPC0.EC0_.HKEY.ALA3 */
                                    }

                                    ALIB (0x0C, XX11)
                                    SMUF = 0x22
                                    If ((VSTP == One))
                                    {
                                        SMUD = STL4 /* \_SB_.PCI0.LPC0.EC0_.HKEY.STL4 */
                                    }
                                    Else
                                    {
                                        SMUD = STL3 /* \_SB_.PCI0.LPC0.EC0_.HKEY.STL3 */
                                    }

                                    ALIB (0x0C, XX11)
                                    SMUF = 0x24
                                    If ((VSTP == One))
                                    {
                                        SMUD = ERC4 /* \_SB_.PCI0.LPC0.EC0_.HKEY.ERC4 */
                                    }
                                    Else
                                    {
                                        SMUD = ERC3 /* \_SB_.PCI0.LPC0.EC0_.HKEY.ERC3 */
                                    }

                                    ALIB (0x0C, XX11)
                                    SMUF = 0x25
                                    If ((VSTP == One))
                                    {
                                        SMUD = ERA4 /* \_SB_.PCI0.LPC0.EC0_.HKEY.ERA4 */
                                    }
                                    Else
                                    {
                                        SMUD = ERA3 /* \_SB_.PCI0.LPC0.EC0_.HKEY.ERA3 */
                                    }

                                    ALIB (0x0C, XX11)
                                    SMUF = 0x26
                                    If ((VSTP == One))
                                    {
                                        SMUD = SM14 /* \_SB_.PCI0.LPC0.EC0_.HKEY.SM14 */
                                    }
                                    Else
                                    {
                                        SMUD = SM13 /* \_SB_.PCI0.LPC0.EC0_.HKEY.SM13 */
                                    }

                                    ALIB (0x0C, XX11)
                                    SMUF = 0x27
                                    If ((VSTP == One))
                                    {
                                        SMUD = SM24 /* \_SB_.PCI0.LPC0.EC0_.HKEY.SM24 */
                                    }
                                    Else
                                    {
                                        SMUD = SM23 /* \_SB_.PCI0.LPC0.EC0_.HKEY.SM23 */
                                    }

                                    ALIB (0x0C, XX11)
                                    SMUF = 0x2C
                                    If ((VSTP == One))
                                    {
                                        SMUD = SCA4 /* \_SB_.PCI0.LPC0.EC0_.HKEY.SCA4 */
                                    }
                                    Else
                                    {
                                        SMUD = SCA3 /* \_SB_.PCI0.LPC0.EC0_.HKEY.SCA3 */
                                    }

                                    ALIB (0x0C, XX11)
                                    SMUF = 0x03
                                    If ((VSTP == One))
                                    {
                                        SMUD = TCL4 /* \_SB_.PCI0.LPC0.EC0_.HKEY.TCL4 */
                                    }
                                    Else
                                    {
                                        SMUD = TCL3 /* \_SB_.PCI0.LPC0.EC0_.HKEY.TCL3 */
                                    }

                                    ALIB (0x0C, XX11)
                                    SMUF = 0x0B
                                    SMUD = TDCN /* \_SB_.PCI0.LPC0.EC0_.HKEY.TDCN */
                                    ALIB (0x0C, XX11)
                                    SMUF = 0x0C
                                    SMUD = EDCN /* \_SB_.PCI0.LPC0.EC0_.HKEY.EDCN */
                                    ALIB (0x0C, XX11)
                                }

                            }
                        }
                        Else
                        {
                            CICF = Zero
                            SMUF = 0x2E
                            If ((VSTP == One))
                            {
                                SMUD = MPL4 /* \_SB_.PCI0.LPC0.EC0_.HKEY.MPL4 */
                            }
                            Else
                            {
                                SMUD = MPL3 /* \_SB_.PCI0.LPC0.EC0_.HKEY.MPL3 */
                            }

                            ALIB (0x0C, XX11)
                            SMUF = 0x06
                            If ((VSTP == One))
                            {
                                SMUD = FPP4 /* \_SB_.PCI0.LPC0.EC0_.HKEY.FPP4 */
                            }
                            Else
                            {
                                SMUD = FPP3 /* \_SB_.PCI0.LPC0.EC0_.HKEY.FPP3 */
                            }

                            ALIB (0x0C, XX11)
                            SMUF = 0x07
                            If ((VSTP == One))
                            {
                                SMUD = SPP4 /* \_SB_.PCI0.LPC0.EC0_.HKEY.SPP4 */
                            }
                            Else
                            {
                                SMUD = SPP3 /* \_SB_.PCI0.LPC0.EC0_.HKEY.SPP3 */
                            }

                            ALIB (0x0C, XX11)
                            SMUF = 0x08
                            If ((VSTP == One))
                            {
                                SMUD = STC4 /* \_SB_.PCI0.LPC0.EC0_.HKEY.STC4 */
                            }
                            Else
                            {
                                SMUD = STC3 /* \_SB_.PCI0.LPC0.EC0_.HKEY.STC3 */
                            }

                            ALIB (0x0C, XX11)
                            SMUF = 0x20
                            If ((VSTP == One))
                            {
                                SMUD = ALA4 /* \_SB_.PCI0.LPC0.EC0_.HKEY.ALA4 */
                            }
                            Else
                            {
                                SMUD = ALA3 /* \_SB_.PCI0.LPC0.EC0_.HKEY.ALA3 */
                            }

                            ALIB (0x0C, XX11)
                            SMUF = 0x22
                            If ((VSTP == One))
                            {
                                SMUD = STL4 /* \_SB_.PCI0.LPC0.EC0_.HKEY.STL4 */
                            }
                            Else
                            {
                                SMUD = STL3 /* \_SB_.PCI0.LPC0.EC0_.HKEY.STL3 */
                            }

                            ALIB (0x0C, XX11)
                            SMUF = 0x24
                            If ((VSTP == One))
                            {
                                SMUD = ERC4 /* \_SB_.PCI0.LPC0.EC0_.HKEY.ERC4 */
                            }
                            Else
                            {
                                SMUD = ERC3 /* \_SB_.PCI0.LPC0.EC0_.HKEY.ERC3 */
                            }

                            ALIB (0x0C, XX11)
                            SMUF = 0x25
                            If ((VSTP == One))
                            {
                                SMUD = ERA4 /* \_SB_.PCI0.LPC0.EC0_.HKEY.ERA4 */
                            }
                            Else
                            {
                                SMUD = ERA3 /* \_SB_.PCI0.LPC0.EC0_.HKEY.ERA3 */
                            }

                            ALIB (0x0C, XX11)
                            SMUF = 0x26
                            If ((VSTP == One))
                            {
                                SMUD = SM14 /* \_SB_.PCI0.LPC0.EC0_.HKEY.SM14 */
                            }
                            Else
                            {
                                SMUD = SM13 /* \_SB_.PCI0.LPC0.EC0_.HKEY.SM13 */
                            }

                            ALIB (0x0C, XX11)
                            SMUF = 0x27
                            If ((VSTP == One))
                            {
                                SMUD = SM24 /* \_SB_.PCI0.LPC0.EC0_.HKEY.SM24 */
                            }
                            Else
                            {
                                SMUD = SM23 /* \_SB_.PCI0.LPC0.EC0_.HKEY.SM23 */
                            }

                            ALIB (0x0C, XX11)
                            SMUF = 0x2C
                            If ((VSTP == One))
                            {
                                SMUD = SCA4 /* \_SB_.PCI0.LPC0.EC0_.HKEY.SCA4 */
                            }
                            Else
                            {
                                SMUD = SCA3 /* \_SB_.PCI0.LPC0.EC0_.HKEY.SCA3 */
                            }

                            ALIB (0x0C, XX11)
                            SMUF = 0x03
                            If ((VSTP == One))
                            {
                                SMUD = TCL4 /* \_SB_.PCI0.LPC0.EC0_.HKEY.TCL4 */
                            }
                            Else
                            {
                                SMUD = TCL3 /* \_SB_.PCI0.LPC0.EC0_.HKEY.TCL3 */
                            }

                            ALIB (0x0C, XX11)
                            SMUF = 0x0B
                            SMUD = TDCN /* \_SB_.PCI0.LPC0.EC0_.HKEY.TDCN */
                            ALIB (0x0C, XX11)
                            SMUF = 0x0C
                            SMUD = EDCN /* \_SB_.PCI0.LPC0.EC0_.HKEY.EDCN */
                            ALIB (0x0C, XX11)
                        }
                    }
                    ElseIf ((HB0A == Zero))
                    {
                        SMUF = 0x2E
                        SMUD = MPLB /* \_SB_.PCI0.LPC0.EC0_.HKEY.MPLB */
                        ALIB (0x0C, XX11)
                        SMUF = 0x06
                        SMUD = FPPB /* \_SB_.PCI0.LPC0.EC0_.HKEY.FPPB */
                        ALIB (0x0C, XX11)
                        SMUF = 0x07
                        SMUD = SPPB /* \_SB_.PCI0.LPC0.EC0_.HKEY.SPPB */
                        ALIB (0x0C, XX11)
                        SMUF = 0x08
                        SMUD = STCB /* \_SB_.PCI0.LPC0.EC0_.HKEY.STCB */
                        ALIB (0x0C, XX11)
                        SMUF = 0x20
                        SMUD = ALAB /* \_SB_.PCI0.LPC0.EC0_.HKEY.ALAB */
                        ALIB (0x0C, XX11)
                        SMUF = 0x22
                        SMUD = STLB /* \_SB_.PCI0.LPC0.EC0_.HKEY.STLB */
                        ALIB (0x0C, XX11)
                        SMUF = 0x24
                        SMUD = ERCB /* \_SB_.PCI0.LPC0.EC0_.HKEY.ERCB */
                        ALIB (0x0C, XX11)
                        SMUF = 0x25
                        SMUD = ERAB /* \_SB_.PCI0.LPC0.EC0_.HKEY.ERAB */
                        ALIB (0x0C, XX11)
                        SMUF = 0x26
                        SMUD = SM1B /* \_SB_.PCI0.LPC0.EC0_.HKEY.SM1B */
                        ALIB (0x0C, XX11)
                        SMUF = 0x27
                        SMUD = SM2B /* \_SB_.PCI0.LPC0.EC0_.HKEY.SM2B */
                        ALIB (0x0C, XX11)
                        SMUF = 0x2C
                        SMUD = SCAB /* \_SB_.PCI0.LPC0.EC0_.HKEY.SCAB */
                        ALIB (0x0C, XX11)
                        SMUF = 0x03
                        If ((VSTP == One))
                        {
                            SMUD = TCL4 /* \_SB_.PCI0.LPC0.EC0_.HKEY.TCL4 */
                        }
                        Else
                        {
                            SMUD = TCLB /* \_SB_.PCI0.LPC0.EC0_.HKEY.TCLB */
                        }

                        ALIB (0x0C, XX11)
                        SMUF = 0x0B
                        SMUD = TDCA /* \_SB_.PCI0.LPC0.EC0_.HKEY.TDCA */
                        ALIB (0x0C, XX11)
                        SMUF = 0x0C
                        SMUD = EDCA /* \_SB_.PCI0.LPC0.EC0_.HKEY.EDCA */
                        ALIB (0x0C, XX11)
                    }
                    ElseIf ((VCQL == One))
                    {
                        CICF = One
                        SMUF = 0x2E
                        If ((VSTP == One))
                        {
                            SMUD = MPL9 /* \_SB_.PCI0.LPC0.EC0_.HKEY.MPL9 */
                        }
                        Else
                        {
                            SMUD = MPL5 /* \_SB_.PCI0.LPC0.EC0_.HKEY.MPL5 */
                        }

                        ALIB (0x0C, XX11)
                        SMUF = 0x06
                        If ((VSTP == One))
                        {
                            SMUD = FPP9 /* \_SB_.PCI0.LPC0.EC0_.HKEY.FPP9 */
                        }
                        Else
                        {
                            SMUD = FPP5 /* \_SB_.PCI0.LPC0.EC0_.HKEY.FPP5 */
                        }

                        ALIB (0x0C, XX11)
                        SMUF = 0x07
                        If ((VSTP == One))
                        {
                            SMUD = SPP9 /* \_SB_.PCI0.LPC0.EC0_.HKEY.SPP9 */
                        }
                        Else
                        {
                            SMUD = SPP5 /* \_SB_.PCI0.LPC0.EC0_.HKEY.SPP5 */
                        }

                        ALIB (0x0C, XX11)
                        SMUF = 0x08
                        If ((VSTP == One))
                        {
                            SMUD = STC9 /* \_SB_.PCI0.LPC0.EC0_.HKEY.STC9 */
                        }
                        Else
                        {
                            SMUD = STC5 /* \_SB_.PCI0.LPC0.EC0_.HKEY.STC5 */
                        }

                        ALIB (0x0C, XX11)
                        SMUF = 0x20
                        If ((VSTP == One))
                        {
                            SMUD = ALA9 /* \_SB_.PCI0.LPC0.EC0_.HKEY.ALA9 */
                        }
                        Else
                        {
                            SMUD = ALA5 /* \_SB_.PCI0.LPC0.EC0_.HKEY.ALA5 */
                        }

                        ALIB (0x0C, XX11)
                        SMUF = 0x22
                        If ((VSTP == One))
                        {
                            SMUD = STL9 /* \_SB_.PCI0.LPC0.EC0_.HKEY.STL9 */
                        }
                        Else
                        {
                            SMUD = STL5 /* \_SB_.PCI0.LPC0.EC0_.HKEY.STL5 */
                        }

                        ALIB (0x0C, XX11)
                        SMUF = 0x24
                        If ((VSTP == One))
                        {
                            SMUD = ERC9 /* \_SB_.PCI0.LPC0.EC0_.HKEY.ERC9 */
                        }
                        Else
                        {
                            SMUD = ERC5 /* \_SB_.PCI0.LPC0.EC0_.HKEY.ERC5 */
                        }

                        ALIB (0x0C, XX11)
                        SMUF = 0x25
                        If ((VSTP == One))
                        {
                            SMUD = ERA9 /* \_SB_.PCI0.LPC0.EC0_.HKEY.ERA9 */
                        }
                        Else
                        {
                            SMUD = ERA5 /* \_SB_.PCI0.LPC0.EC0_.HKEY.ERA5 */
                        }

                        ALIB (0x0C, XX11)
                        SMUF = 0x26
                        If ((VSTP == One))
                        {
                            SMUD = SM19 /* \_SB_.PCI0.LPC0.EC0_.HKEY.SM19 */
                        }
                        Else
                        {
                            SMUD = SM15 /* \_SB_.PCI0.LPC0.EC0_.HKEY.SM15 */
                        }

                        ALIB (0x0C, XX11)
                        SMUF = 0x27
                        If ((VSTP == One))
                        {
                            SMUD = SM29 /* \_SB_.PCI0.LPC0.EC0_.HKEY.SM29 */
                        }
                        Else
                        {
                            SMUD = SM25 /* \_SB_.PCI0.LPC0.EC0_.HKEY.SM25 */
                        }

                        ALIB (0x0C, XX11)
                        SMUF = 0x2C
                        If ((VSTP == One))
                        {
                            SMUD = SCA9 /* \_SB_.PCI0.LPC0.EC0_.HKEY.SCA9 */
                        }
                        Else
                        {
                            SMUD = SCA5 /* \_SB_.PCI0.LPC0.EC0_.HKEY.SCA5 */
                        }

                        ALIB (0x0C, XX11)
                        SMUF = 0x03
                        If ((VSTP == One))
                        {
                            SMUD = TCL9 /* \_SB_.PCI0.LPC0.EC0_.HKEY.TCL9 */
                        }
                        Else
                        {
                            SMUD = TCL5 /* \_SB_.PCI0.LPC0.EC0_.HKEY.TCL5 */
                        }

                        ALIB (0x0C, XX11)
                        SMUF = 0x0B
                        SMUD = TDCN /* \_SB_.PCI0.LPC0.EC0_.HKEY.TDCN */
                        ALIB (0x0C, XX11)
                        SMUF = 0x0C
                        SMUD = EDCN /* \_SB_.PCI0.LPC0.EC0_.HKEY.EDCN */
                        ALIB (0x0C, XX11)
                    }
                    ElseIf ((VPSC == One))
                    {
                        CICF = 0x0D
                        Local7 = SPSC /* \SPSC */
                        Switch (Local7)
                        {
                            Case (Package (0x02)
                                {
                                    0x07, 
                                    0x08
                                }

)
                            {
                                SMUF = 0x2E
                                If ((VSTP == One))
                                {
                                    SMUD = MPL9 /* \_SB_.PCI0.LPC0.EC0_.HKEY.MPL9 */
                                }
                                Else
                                {
                                    SMUD = MPL7 /* \_SB_.PCI0.LPC0.EC0_.HKEY.MPL7 */
                                }

                                ALIB (0x0C, XX11)
                                SMUF = 0x06
                                If ((VSTP == One))
                                {
                                    SMUD = FPP9 /* \_SB_.PCI0.LPC0.EC0_.HKEY.FPP9 */
                                }
                                Else
                                {
                                    SMUD = FPP7 /* \_SB_.PCI0.LPC0.EC0_.HKEY.FPP7 */
                                }

                                ALIB (0x0C, XX11)
                                SMUF = 0x07
                                If ((VSTP == One))
                                {
                                    SMUD = SPP9 /* \_SB_.PCI0.LPC0.EC0_.HKEY.SPP9 */
                                }
                                Else
                                {
                                    SMUD = SPP7 /* \_SB_.PCI0.LPC0.EC0_.HKEY.SPP7 */
                                }

                                ALIB (0x0C, XX11)
                                SMUF = 0x08
                                If ((VSTP == One))
                                {
                                    SMUD = STC9 /* \_SB_.PCI0.LPC0.EC0_.HKEY.STC9 */
                                }
                                Else
                                {
                                    SMUD = STC7 /* \_SB_.PCI0.LPC0.EC0_.HKEY.STC7 */
                                }

                                ALIB (0x0C, XX11)
                                SMUF = 0x20
                                If ((VSTP == One))
                                {
                                    SMUD = ALA9 /* \_SB_.PCI0.LPC0.EC0_.HKEY.ALA9 */
                                }
                                Else
                                {
                                    SMUD = ALA7 /* \_SB_.PCI0.LPC0.EC0_.HKEY.ALA7 */
                                }

                                ALIB (0x0C, XX11)
                                SMUF = 0x22
                                If ((VSTP == One))
                                {
                                    SMUD = STL9 /* \_SB_.PCI0.LPC0.EC0_.HKEY.STL9 */
                                }
                                Else
                                {
                                    SMUD = STL7 /* \_SB_.PCI0.LPC0.EC0_.HKEY.STL7 */
                                }

                                ALIB (0x0C, XX11)
                                SMUF = 0x24
                                If ((VSTP == One))
                                {
                                    SMUD = ERC9 /* \_SB_.PCI0.LPC0.EC0_.HKEY.ERC9 */
                                }
                                Else
                                {
                                    SMUD = ERC7 /* \_SB_.PCI0.LPC0.EC0_.HKEY.ERC7 */
                                }

                                ALIB (0x0C, XX11)
                                SMUF = 0x25
                                If ((VSTP == One))
                                {
                                    SMUD = ERA9 /* \_SB_.PCI0.LPC0.EC0_.HKEY.ERA9 */
                                }
                                Else
                                {
                                    SMUD = ERA7 /* \_SB_.PCI0.LPC0.EC0_.HKEY.ERA7 */
                                }

                                ALIB (0x0C, XX11)
                                SMUF = 0x26
                                If ((VSTP == One))
                                {
                                    SMUD = SM19 /* \_SB_.PCI0.LPC0.EC0_.HKEY.SM19 */
                                }
                                Else
                                {
                                    SMUD = SM17 /* \_SB_.PCI0.LPC0.EC0_.HKEY.SM17 */
                                }

                                ALIB (0x0C, XX11)
                                SMUF = 0x27
                                If ((VSTP == One))
                                {
                                    SMUD = SM29 /* \_SB_.PCI0.LPC0.EC0_.HKEY.SM29 */
                                }
                                Else
                                {
                                    SMUD = SM27 /* \_SB_.PCI0.LPC0.EC0_.HKEY.SM27 */
                                }

                                ALIB (0x0C, XX11)
                                SMUF = 0x2C
                                If ((VSTP == One))
                                {
                                    SMUD = SCA9 /* \_SB_.PCI0.LPC0.EC0_.HKEY.SCA9 */
                                }
                                Else
                                {
                                    SMUD = SCA7 /* \_SB_.PCI0.LPC0.EC0_.HKEY.SCA7 */
                                }

                                ALIB (0x0C, XX11)
                                SMUF = 0x03
                                If ((VSTP == One))
                                {
                                    SMUD = TCL9 /* \_SB_.PCI0.LPC0.EC0_.HKEY.TCL9 */
                                }
                                Else
                                {
                                    SMUD = TCL7 /* \_SB_.PCI0.LPC0.EC0_.HKEY.TCL7 */
                                }

                                ALIB (0x0C, XX11)
                                SMUF = 0x0B
                                SMUD = TDCN /* \_SB_.PCI0.LPC0.EC0_.HKEY.TDCN */
                                ALIB (0x0C, XX11)
                                SMUF = 0x0C
                                SMUD = EDCN /* \_SB_.PCI0.LPC0.EC0_.HKEY.EDCN */
                                ALIB (0x0C, XX11)
                            }
                            Case (Package (0x03)
                                {
                                    0x02, 
                                    0x03, 
                                    0x04
                                }

)
                            {
                                SMUF = 0x2E
                                If ((VSTP == One))
                                {
                                    SMUD = MPL9 /* \_SB_.PCI0.LPC0.EC0_.HKEY.MPL9 */
                                }
                                Else
                                {
                                    SMUD = MPL6 /* \_SB_.PCI0.LPC0.EC0_.HKEY.MPL6 */
                                }

                                ALIB (0x0C, XX11)
                                SMUF = 0x06
                                If ((VSTP == One))
                                {
                                    SMUD = FPP9 /* \_SB_.PCI0.LPC0.EC0_.HKEY.FPP9 */
                                }
                                Else
                                {
                                    SMUD = FPP6 /* \_SB_.PCI0.LPC0.EC0_.HKEY.FPP6 */
                                }

                                ALIB (0x0C, XX11)
                                SMUF = 0x07
                                If ((VSTP == One))
                                {
                                    SMUD = SPP9 /* \_SB_.PCI0.LPC0.EC0_.HKEY.SPP9 */
                                }
                                Else
                                {
                                    SMUD = SPP6 /* \_SB_.PCI0.LPC0.EC0_.HKEY.SPP6 */
                                }

                                ALIB (0x0C, XX11)
                                SMUF = 0x08
                                If ((VSTP == One))
                                {
                                    SMUD = STC9 /* \_SB_.PCI0.LPC0.EC0_.HKEY.STC9 */
                                }
                                Else
                                {
                                    SMUD = STC6 /* \_SB_.PCI0.LPC0.EC0_.HKEY.STC6 */
                                }

                                ALIB (0x0C, XX11)
                                SMUF = 0x20
                                If ((VSTP == One))
                                {
                                    SMUD = ALA9 /* \_SB_.PCI0.LPC0.EC0_.HKEY.ALA9 */
                                }
                                Else
                                {
                                    SMUD = ALA6 /* \_SB_.PCI0.LPC0.EC0_.HKEY.ALA6 */
                                }

                                ALIB (0x0C, XX11)
                                SMUF = 0x22
                                If ((VSTP == One))
                                {
                                    SMUD = STL9 /* \_SB_.PCI0.LPC0.EC0_.HKEY.STL9 */
                                }
                                Else
                                {
                                    SMUD = STL6 /* \_SB_.PCI0.LPC0.EC0_.HKEY.STL6 */
                                }

                                ALIB (0x0C, XX11)
                                SMUF = 0x24
                                If ((VSTP == One))
                                {
                                    SMUD = ERC9 /* \_SB_.PCI0.LPC0.EC0_.HKEY.ERC9 */
                                }
                                Else
                                {
                                    SMUD = ERC6 /* \_SB_.PCI0.LPC0.EC0_.HKEY.ERC6 */
                                }

                                ALIB (0x0C, XX11)
                                SMUF = 0x25
                                If ((VSTP == One))
                                {
                                    SMUD = ERA9 /* \_SB_.PCI0.LPC0.EC0_.HKEY.ERA9 */
                                }
                                Else
                                {
                                    SMUD = ERA6 /* \_SB_.PCI0.LPC0.EC0_.HKEY.ERA6 */
                                }

                                ALIB (0x0C, XX11)
                                SMUF = 0x26
                                If ((VSTP == One))
                                {
                                    SMUD = SM19 /* \_SB_.PCI0.LPC0.EC0_.HKEY.SM19 */
                                }
                                Else
                                {
                                    SMUD = SM16 /* \_SB_.PCI0.LPC0.EC0_.HKEY.SM16 */
                                }

                                ALIB (0x0C, XX11)
                                SMUF = 0x27
                                If ((VSTP == One))
                                {
                                    SMUD = SM29 /* \_SB_.PCI0.LPC0.EC0_.HKEY.SM29 */
                                }
                                Else
                                {
                                    SMUD = SM26 /* \_SB_.PCI0.LPC0.EC0_.HKEY.SM26 */
                                }

                                ALIB (0x0C, XX11)
                                SMUF = 0x2C
                                If ((VSTP == One))
                                {
                                    SMUD = SCA9 /* \_SB_.PCI0.LPC0.EC0_.HKEY.SCA9 */
                                }
                                Else
                                {
                                    SMUD = SCA6 /* \_SB_.PCI0.LPC0.EC0_.HKEY.SCA6 */
                                }

                                ALIB (0x0C, XX11)
                                SMUF = 0x03
                                If ((VSTP == One))
                                {
                                    SMUD = TCL9 /* \_SB_.PCI0.LPC0.EC0_.HKEY.TCL9 */
                                }
                                Else
                                {
                                    SMUD = TCL6 /* \_SB_.PCI0.LPC0.EC0_.HKEY.TCL6 */
                                }

                                ALIB (0x0C, XX11)
                                SMUF = 0x0B
                                SMUD = TDCN /* \_SB_.PCI0.LPC0.EC0_.HKEY.TDCN */
                                ALIB (0x0C, XX11)
                                SMUF = 0x0C
                                SMUD = EDCN /* \_SB_.PCI0.LPC0.EC0_.HKEY.EDCN */
                                ALIB (0x0C, XX11)
                            }
                            Default
                            {
                                SMUF = 0x2E
                                If ((VSTP == One))
                                {
                                    SMUD = MPL9 /* \_SB_.PCI0.LPC0.EC0_.HKEY.MPL9 */
                                }
                                Else
                                {
                                    SMUD = MPL8 /* \_SB_.PCI0.LPC0.EC0_.HKEY.MPL8 */
                                }

                                ALIB (0x0C, XX11)
                                SMUF = 0x06
                                If ((VSTP == One))
                                {
                                    SMUD = FPP9 /* \_SB_.PCI0.LPC0.EC0_.HKEY.FPP9 */
                                }
                                Else
                                {
                                    SMUD = FPP8 /* \_SB_.PCI0.LPC0.EC0_.HKEY.FPP8 */
                                }

                                ALIB (0x0C, XX11)
                                SMUF = 0x07
                                If ((VSTP == One))
                                {
                                    SMUD = SPP9 /* \_SB_.PCI0.LPC0.EC0_.HKEY.SPP9 */
                                }
                                Else
                                {
                                    SMUD = SPP8 /* \_SB_.PCI0.LPC0.EC0_.HKEY.SPP8 */
                                }

                                ALIB (0x0C, XX11)
                                SMUF = 0x08
                                If ((VSTP == One))
                                {
                                    SMUD = STC9 /* \_SB_.PCI0.LPC0.EC0_.HKEY.STC9 */
                                }
                                Else
                                {
                                    SMUD = STC8 /* \_SB_.PCI0.LPC0.EC0_.HKEY.STC8 */
                                }

                                ALIB (0x0C, XX11)
                                SMUF = 0x20
                                If ((VSTP == One))
                                {
                                    SMUD = ALA9 /* \_SB_.PCI0.LPC0.EC0_.HKEY.ALA9 */
                                }
                                Else
                                {
                                    SMUD = ALA8 /* \_SB_.PCI0.LPC0.EC0_.HKEY.ALA8 */
                                }

                                ALIB (0x0C, XX11)
                                SMUF = 0x22
                                If ((VSTP == One))
                                {
                                    SMUD = STL9 /* \_SB_.PCI0.LPC0.EC0_.HKEY.STL9 */
                                }
                                Else
                                {
                                    SMUD = STL8 /* \_SB_.PCI0.LPC0.EC0_.HKEY.STL8 */
                                }

                                ALIB (0x0C, XX11)
                                SMUF = 0x24
                                If ((VSTP == One))
                                {
                                    SMUD = ERC9 /* \_SB_.PCI0.LPC0.EC0_.HKEY.ERC9 */
                                }
                                Else
                                {
                                    SMUD = ERC8 /* \_SB_.PCI0.LPC0.EC0_.HKEY.ERC8 */
                                }

                                ALIB (0x0C, XX11)
                                SMUF = 0x25
                                If ((VSTP == One))
                                {
                                    SMUD = ERA9 /* \_SB_.PCI0.LPC0.EC0_.HKEY.ERA9 */
                                }
                                Else
                                {
                                    SMUD = ERA8 /* \_SB_.PCI0.LPC0.EC0_.HKEY.ERA8 */
                                }

                                ALIB (0x0C, XX11)
                                SMUF = 0x26
                                If ((VSTP == One))
                                {
                                    SMUD = SM19 /* \_SB_.PCI0.LPC0.EC0_.HKEY.SM19 */
                                }
                                Else
                                {
                                    SMUD = SM18 /* \_SB_.PCI0.LPC0.EC0_.HKEY.SM18 */
                                }

                                ALIB (0x0C, XX11)
                                SMUF = 0x27
                                If ((VSTP == One))
                                {
                                    SMUD = SM29 /* \_SB_.PCI0.LPC0.EC0_.HKEY.SM29 */
                                }
                                Else
                                {
                                    SMUD = SM28 /* \_SB_.PCI0.LPC0.EC0_.HKEY.SM28 */
                                }

                                ALIB (0x0C, XX11)
                                SMUF = 0x2C
                                If ((VSTP == One))
                                {
                                    SMUD = SCA9 /* \_SB_.PCI0.LPC0.EC0_.HKEY.SCA9 */
                                }
                                Else
                                {
                                    SMUD = SCA8 /* \_SB_.PCI0.LPC0.EC0_.HKEY.SCA8 */
                                }

                                ALIB (0x0C, XX11)
                                SMUF = 0x03
                                If ((VSTP == One))
                                {
                                    SMUD = TCL9 /* \_SB_.PCI0.LPC0.EC0_.HKEY.TCL9 */
                                }
                                Else
                                {
                                    SMUD = TCL8 /* \_SB_.PCI0.LPC0.EC0_.HKEY.TCL8 */
                                }

                                ALIB (0x0C, XX11)
                                SMUF = 0x0B
                                SMUD = TDCN /* \_SB_.PCI0.LPC0.EC0_.HKEY.TDCN */
                                ALIB (0x0C, XX11)
                                SMUF = 0x0C
                                SMUD = EDCN /* \_SB_.PCI0.LPC0.EC0_.HKEY.EDCN */
                                ALIB (0x0C, XX11)
                            }

                        }
                    }
                    Else
                    {
                        CICF = Zero
                        SMUF = 0x2E
                        If ((VSTP == One))
                        {
                            SMUD = MPL9 /* \_SB_.PCI0.LPC0.EC0_.HKEY.MPL9 */
                        }
                        Else
                        {
                            SMUD = MPL8 /* \_SB_.PCI0.LPC0.EC0_.HKEY.MPL8 */
                        }

                        ALIB (0x0C, XX11)
                        SMUF = 0x06
                        If ((VSTP == One))
                        {
                            SMUD = FPP9 /* \_SB_.PCI0.LPC0.EC0_.HKEY.FPP9 */
                        }
                        Else
                        {
                            SMUD = FPP8 /* \_SB_.PCI0.LPC0.EC0_.HKEY.FPP8 */
                        }

                        ALIB (0x0C, XX11)
                        SMUF = 0x07
                        If ((VSTP == One))
                        {
                            SMUD = SPP9 /* \_SB_.PCI0.LPC0.EC0_.HKEY.SPP9 */
                        }
                        Else
                        {
                            SMUD = SPP8 /* \_SB_.PCI0.LPC0.EC0_.HKEY.SPP8 */
                        }

                        ALIB (0x0C, XX11)
                        SMUF = 0x08
                        If ((VSTP == One))
                        {
                            SMUD = STC9 /* \_SB_.PCI0.LPC0.EC0_.HKEY.STC9 */
                        }
                        Else
                        {
                            SMUD = STC8 /* \_SB_.PCI0.LPC0.EC0_.HKEY.STC8 */
                        }

                        ALIB (0x0C, XX11)
                        SMUF = 0x20
                        If ((VSTP == One))
                        {
                            SMUD = ALA9 /* \_SB_.PCI0.LPC0.EC0_.HKEY.ALA9 */
                        }
                        Else
                        {
                            SMUD = ALA8 /* \_SB_.PCI0.LPC0.EC0_.HKEY.ALA8 */
                        }

                        ALIB (0x0C, XX11)
                        SMUF = 0x22
                        If ((VSTP == One))
                        {
                            SMUD = STL9 /* \_SB_.PCI0.LPC0.EC0_.HKEY.STL9 */
                        }
                        Else
                        {
                            SMUD = STL8 /* \_SB_.PCI0.LPC0.EC0_.HKEY.STL8 */
                        }

                        ALIB (0x0C, XX11)
                        SMUF = 0x24
                        If ((VSTP == One))
                        {
                            SMUD = ERC9 /* \_SB_.PCI0.LPC0.EC0_.HKEY.ERC9 */
                        }
                        Else
                        {
                            SMUD = ERC8 /* \_SB_.PCI0.LPC0.EC0_.HKEY.ERC8 */
                        }

                        ALIB (0x0C, XX11)
                        SMUF = 0x25
                        If ((VSTP == One))
                        {
                            SMUD = ERA9 /* \_SB_.PCI0.LPC0.EC0_.HKEY.ERA9 */
                        }
                        Else
                        {
                            SMUD = ERA8 /* \_SB_.PCI0.LPC0.EC0_.HKEY.ERA8 */
                        }

                        ALIB (0x0C, XX11)
                        SMUF = 0x26
                        If ((VSTP == One))
                        {
                            SMUD = SM19 /* \_SB_.PCI0.LPC0.EC0_.HKEY.SM19 */
                        }
                        Else
                        {
                            SMUD = SM18 /* \_SB_.PCI0.LPC0.EC0_.HKEY.SM18 */
                        }

                        ALIB (0x0C, XX11)
                        SMUF = 0x27
                        If ((VSTP == One))
                        {
                            SMUD = SM29 /* \_SB_.PCI0.LPC0.EC0_.HKEY.SM29 */
                        }
                        Else
                        {
                            SMUD = SM28 /* \_SB_.PCI0.LPC0.EC0_.HKEY.SM28 */
                        }

                        ALIB (0x0C, XX11)
                        SMUF = 0x2C
                        If ((VSTP == One))
                        {
                            SMUD = SCA9 /* \_SB_.PCI0.LPC0.EC0_.HKEY.SCA9 */
                        }
                        Else
                        {
                            SMUD = SCA8 /* \_SB_.PCI0.LPC0.EC0_.HKEY.SCA8 */
                        }

                        ALIB (0x0C, XX11)
                        SMUF = 0x03
                        If ((VSTP == One))
                        {
                            SMUD = TCL9 /* \_SB_.PCI0.LPC0.EC0_.HKEY.TCL9 */
                        }
                        Else
                        {
                            SMUD = TCL8 /* \_SB_.PCI0.LPC0.EC0_.HKEY.TCL8 */
                        }

                        ALIB (0x0C, XX11)
                        SMUF = 0x0B
                        SMUD = TDCN /* \_SB_.PCI0.LPC0.EC0_.HKEY.TDCN */
                        ALIB (0x0C, XX11)
                        SMUF = 0x0C
                        SMUD = EDCN /* \_SB_.PCI0.LPC0.EC0_.HKEY.EDCN */
                        ALIB (0x0C, XX11)
                    }

                    Local5 = VSTD /* \VSTD */
                    Local5 |= (VCQL << One)
                    Local5 |= (VSTP << 0x04)
                    Local5 |= (VPSC << 0x0D)
                    Local1 = (CICF << 0x08)
                    If ((CICF == 0x03))
                    {
                        CICM = SMYH /* \SMYH */
                    }
                    ElseIf ((CICF == 0x0B))
                    {
                        CICM = SMMC /* \SMMC */
                    }
                    ElseIf ((CICF == 0x0D))
                    {
                        CICM = SPSC /* \SPSC */
                    }
                    Else
                    {
                        CICM = 0x0F
                    }

                    Local1 |= (CICM << 0x0C)
                    Local1 |= (Local5 << 0x10)
                    Local1 |= One
                    If (DHKC)
                    {
                        MHKQ (0x6032)
                    }
                }
                Case (0x02)
                {
                    Local5 = VSTD /* \VSTD */
                    Local5 |= (VCQL << One)
                    Local5 |= (VSTP << 0x04)
                    Local5 |= (VPSC << 0x0D)
                    Local1 = (CICF << 0x08)
                    If ((CICF == 0x03))
                    {
                        CICM = SMYH /* \SMYH */
                    }
                    ElseIf ((CICF == 0x0B))
                    {
                        CICM = SMMC /* \SMMC */
                    }
                    ElseIf ((CICF == 0x0D))
                    {
                        CICM = SPSC /* \SPSC */
                    }
                    Else
                    {
                        CICM = 0x0F
                    }

                    Local1 |= (CICM << 0x0C)
                    Local1 |= (Local5 << 0x10)
                    Local1 |= One
                }
                Case (0x03)
                {
                    Local1 = (FCAP << 0x10)
                    Local1 |= One
                }
                Case (0x04)
                {
                    Local1 = (MYHC << 0x10)
                    Local1 |= One
                }
                Case (0x06)
                {
                    Local2 = ((Local0 >> 0x09) & 0x0F)
                    If ((Local2 != One))
                    {
                        Local1 = (MMCC << 0x10)
                    }
                    Else
                    {
                        Local1 = 0x0200
                    }

                    Local1 |= One
                }
                Case (0x05)
                {
                    If (Ones)
                    {
                        Local1 = 0x0500
                        Local1 |= 0x10E00000
                    }

                    Local1 |= One
                }
                Case (0x0100)
                {
                    Local1 = 0x10010000
                    Local1 |= One
                }
                Case (0x01FF)
                {
                    VCQL = Zero
                    VTIO = Zero
                    VMYH = Zero
                    VSTP = Zero
                    VCQH = Zero
                    VDCC = Zero
                    VSFN = Zero
                    VDMC = Zero
                    VFHP = Zero
                    VIFC = Zero
                    VMMC = Zero
                    VMSC = Zero
                    VPSC = Zero
                    VCSC = Zero
                    SMYH = Zero
                    SMMC = Zero
                    SPSC = Zero
                    CICF = Zero
                    CICM = 0x0F
                    Local5 = VSTD /* \VSTD */
                    Local5 |= (VCQL << One)
                    Local5 |= (VSTP << 0x04)
                    Local5 |= (VPSC << 0x0D)
                    Local1 = (CICF << 0x08)
                    Local1 |= (CICM << 0x0C)
                    Local1 |= (Local5 << 0x10)
                    Local1 |= One
                }
                Default
                {
                    Local1 = 0x04
                }

            }

            Return (Local1)
        }
    }

    Scope (_SB.PCI0.LPC0.EC0)
    {
        Method (ATMC, 0, NotSerialized)
        {
            If ((WNTF && TATC))
            {
                If (HPAC)
                {
                    Local0 = TCFA /* \TCFA */
                    Local1 = TCTA /* \TCTA */
                    Local2 = ((Local1 << 0x04) | Local0)
                    Local3 = (Local2 ^ ATMX) /* \_SB_.PCI0.LPC0.EC0_.ATMX */
                    ATMX = Local2
                    If ((TCTA == Zero))
                    {
                        TCRT = TCR0 /* \TCR0 */
                        TPSV = TPS0 /* \TPS0 */
                    }
                    ElseIf ((TCTA == One))
                    {
                        TCRT = TCR1 /* \TCR1 */
                        TPSV = TPS1 /* \TPS1 */
                    }
                    Else
                    {
                    }
                }
                Else
                {
                    Local0 = TCFD /* \TCFD */
                    Local1 = TCTD /* \TCTD */
                    Local2 = ((Local1 << 0x04) | Local0)
                    Local3 = (Local2 ^ ATMX) /* \_SB_.PCI0.LPC0.EC0_.ATMX */
                    ATMX = Local2
                    If ((TCTD == Zero))
                    {
                        TCRT = TCR0 /* \TCR0 */
                        TPSV = TPS0 /* \TPS0 */
                    }
                    ElseIf ((TCTD == One))
                    {
                        TCRT = TCR1 /* \TCR1 */
                        TPSV = TPS1 /* \TPS1 */
                    }
                    Else
                    {
                    }
                }

                If (Local3)
                {
                    If (^HKEY.DHKC)
                    {
                        ^HKEY.MHKQ (0x6030)
                    }
                }
            }
        }
    }

    Scope (_SB.PCI0.LPC0.EC0)
    {
        Device (ITSD)
        {
            Name (_HID, EisaId ("LEN0100"))  // _HID: Hardware ID
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                Return (0x0F)
            }
        }
    }

    Scope (_SB.PCI0.LPC0.EC0)
    {
        Method (_Q40, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
        {
            If (H8DR)
            {
                Local1 = TSL2 /* \_SB_.PCI0.LPC0.EC0_.TSL2 */
                Local2 = TSL1 /* \_SB_.PCI0.LPC0.EC0_.TSL1 */
            }
            Else
            {
                Local1 = (RBEC (0x8A) & 0x7F)
                Local2 = (RBEC (0x89) & 0x7F)
            }

            If ((Local2 & 0x76))
            {
                ^HKEY.DYTC (0x001F4001)
            }
            Else
            {
                ^HKEY.DYTC (0x000F4001)
            }

            If ((^HKEY.DHKC && Local1))
            {
                ^HKEY.MHKQ (0x6022)
            }

            If (!VIGD)
            {
                VTHR ()
            }
        }
    }

    Scope (_SI)
    {
        Method (_SST, 1, NotSerialized)  // _SST: System Status
        {
            If ((Arg0 == Zero))
            {
                \_SB.PCI0.LPC0.EC0.LED (Zero, Zero)
                \_SB.PCI0.LPC0.EC0.LED (0x0A, Zero)
                \_SB.PCI0.LPC0.EC0.LED (0x07, Zero)
            }

            If ((Arg0 == One))
            {
                If ((SPS || WNTF))
                {
                    \_SB.PCI0.LPC0.EC0.BEEP (0x05)
                }

                \_SB.PCI0.LPC0.EC0.LED (Zero, 0x80)
                \_SB.PCI0.LPC0.EC0.LED (0x0A, 0x80)
                \_SB.PCI0.LPC0.EC0.LED (0x07, Zero)
            }

            If ((Arg0 == 0x02))
            {
                \_SB.PCI0.LPC0.EC0.LED (Zero, 0x80)
                \_SB.PCI0.LPC0.EC0.LED (0x0A, 0x80)
                \_SB.PCI0.LPC0.EC0.LED (0x07, 0xC0)
            }

            If ((Arg0 == 0x03))
            {
                If ((SPS > 0x03))
                {
                    \_SB.PCI0.LPC0.EC0.BEEP (0x07)
                }
                ElseIf ((SPS == 0x03))
                {
                    \_SB.PCI0.LPC0.EC0.BEEP (0x03)
                }
                Else
                {
                    \_SB.PCI0.LPC0.EC0.BEEP (0x04)
                }

                If ((SPS == 0x03)){}
                Else
                {
                    \_SB.PCI0.LPC0.EC0.LED (Zero, 0x80)
                    \_SB.PCI0.LPC0.EC0.LED (0x0A, 0x80)
                }

                \_SB.PCI0.LPC0.EC0.LED (Zero, 0xC0)
                Stall (0x64)
                \_SB.PCI0.LPC0.EC0.LED (0x0A, 0xC0)
            }

            If ((Arg0 == 0x04))
            {
                \_SB.PCI0.LPC0.EC0.BEEP (0x03)
                \_SB.PCI0.LPC0.EC0.LED (0x07, 0xC0)
                \_SB.PCI0.LPC0.EC0.LED (Zero, 0xC0)
                \_SB.PCI0.LPC0.EC0.LED (0x0A, 0xC0)
                \_SB.PCI0.LPC0.EC0.HLCL = 0xC0
                Sleep (0x64)
                Local0 = 0xCA
                \_SB.PCI0.LPC0.EC0.HLCL = Local0
            }
        }
    }

    Scope (_SB.PCI0.GPP1.WLAN)
    {
        Method (_PRW, 0, NotSerialized)  // _PRW: Power Resources for Wake
        {
            Return (GPRW (0x08, 0x04))
        }

        Method (_RMV, 0, NotSerialized)  // _RMV: Removal Status
        {
            Return (Zero)
        }

        OperationRegion (RPXX, PCI_Config, Zero, 0x10)
        Field (RPXX, AnyAcc, NoLock, Preserve)
        {
            VDID,   32
        }

        OperationRegion (FLDR, PCI_Config, 0x44, 0x06)
        Field (FLDR, ByteAcc, NoLock, Preserve)
        {
            DCAP,   32, 
            DCTR,   16
        }

        Method (WIST, 0, Serialized)
        {
            If (CondRefOf (VDID))
            {
                Switch (ToInteger (VDID))
                {
                    Case (0x095A8086)
                    {
                        Return (One)
                    }
                    Case (0x095B8086)
                    {
                        Return (One)
                    }
                    Case (0x31658086)
                    {
                        Return (One)
                    }
                    Case (0x31668086)
                    {
                        Return (One)
                    }
                    Case (0x08B18086)
                    {
                        Return (One)
                    }
                    Case (0x08B28086)
                    {
                        Return (One)
                    }
                    Case (0x08B38086)
                    {
                        Return (One)
                    }
                    Case (0x08B48086)
                    {
                        Return (One)
                    }
                    Case (0x24F38086)
                    {
                        Return (One)
                    }
                    Case (0x24F48086)
                    {
                        Return (One)
                    }
                    Case (0x24F58086)
                    {
                        Return (One)
                    }
                    Case (0x24F68086)
                    {
                        Return (One)
                    }
                    Case (0x24FD8086)
                    {
                        Return (One)
                    }
                    Case (0x24FB8086)
                    {
                        Return (One)
                    }
                    Case (0x25268086)
                    {
                        Return (One)
                    }
                    Case (0x27238086)
                    {
                        Return (One)
                    }
                    Case (0xB82210EC)
                    {
                        Return (One)
                    }
                    Default
                    {
                        Return (Zero)
                    }

                }
            }
            Else
            {
                Return (Zero)
            }
        }

        PowerResource (WRST, 0x05, 0x0000)
        {
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                Return (One)
            }

            Method (_ON, 0, NotSerialized)  // _ON_: Power On
            {
            }

            Method (_OFF, 0, NotSerialized)  // _OFF: Power Off
            {
            }

            Method (_RST, 0, NotSerialized)  // _RST: Device Reset
            {
                If (WIST ())
                {
                    If ((DCAP & 0x10000000))
                    {
                        Local0 = DCTR /* \_SB_.PCI0.GPP1.WLAN.DCTR */
                        Local0 |= 0x8000
                        DCTR = Local0
                    }
                }
                Else
                {
                    ^^^^LPC0.EC0.WRST = One
                    Sleep (0xC8)
                    ^^^^LPC0.EC0.WRST = Zero
                }
            }
        }

        Method (_PRR, 0, NotSerialized)  // _PRR: Power Resource for Reset
        {
            If (CondRefOf (WRST))
            {
                Return (Package (0x01)
                {
                    WRST
                })
            }
        }
    }
}

