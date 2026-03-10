
V1.0 Release Note:
1.Initial release.

V1.1 Release Note:
1.Fix can not run in 32bit UEFI shell environment.

V1.2 Release Note:
1.Fix UUID Manual update fail.

V1.3 Release Note:
1.Add Country Code for SMBIOS type248 WIFI disable ac & limit 5G channel to CH149-CH162.

V1.4 Release Note:
1.Add Keyboard LED (kbl) option.
Note:
1.This tool can be used on Intel and AMD platform based on Insyde H2O UEFI BIOS 
and so far it only support Flex 10 project or later.
2.It need to be run on UEFI shell environment with secure boot mode disable.
3.shell tool located at¡± EFI\BOOT\BOOTxxx.efi¡±, please copy EFI folder to USB key root directory to create EFI shell bootable disk.

Usage:
+-----------------------------------------------------------------------------+
|               EEPROM&Marker Utility for UEFI     Version 1.4                |
|             Copyright (c) 2017 Bitland INC. All Rights Reserved.            |
+-----------------------------------------------------------------------------+
| Usage: novouefi <Command> [Option1][Option2]                                |
|-----------------------------------------------------------------------------|
| Commands:                                                                   |
|    /r - read system info fields         /w - write system info fields       |
|    /setmark - set mark file             /setrdm  - set random               |
|    /clrmark - clear mark file           /chkmark - check mark file          |
|    /mfgdone - set Manufacturing Done                                        |
| Option1:                                                                    |
|    /pn  - product name                  /bt  - Brand Type                   |
|    /pn2 - project name                  /kd  - keyboradID                   |
|    /mt  - MTM number name               /el  - EPA ID                       |
|    /sn  - serial number                 /fl  - Functionflag                 |
|    /ln  - Lenovo SN                     /rm  - set EEPROM Random            |
|    /uu  - UUID                          /cc  - Country Code                 |
|    /cd  - Customer                      /fd  - Family Name                  |
|    /at  - AssetTag                      /oss - OS Descriptor                |
|    /cf  - Configuration                 /osp - OS PN Number                 |
|    /set - Set Mfgdone                   /clear - Clear Mfgdone              |
|    /all - display Lenovo SN and UUID    /oa3keyid - OA3 KEY ID              | 
|    /kbl - show keyboard led                                                 |
| Option2:                                                                    |
|    /g  - To generate an UUID            /s   - Stop to scan Lenovo SN       |
+-----------------------------------------------------------------------------+
	
For example in x64 environment:
To read product name: novouefix64.efi /r /pn
To write product name: novouefix64.efi /w /pn Lenovo FLEX 3-1130