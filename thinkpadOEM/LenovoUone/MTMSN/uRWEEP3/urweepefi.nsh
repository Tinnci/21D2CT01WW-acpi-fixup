echo -off
cls
#cp length.efi

If %1 == "" then
    goto END
Endif

If %2 == "" then 
  goto Readit
Endif

:Writeit
length.efi %2

:Write
if %1 == /uu then
goto UU
endif

if %1 == /ln then
goto LN
endif

if %1 == /mt then
goto MT
endif

if %1 == /pn then
goto PN
endif

goto END


:UU

uRWEEPROM.EFI /w 2 80 8F "%CandidatesUUID%"

goto MBDStatusU

:LN
if %Length% == 1 then
uRWEEPROM.EFI /w 0 A1 A1 00
uRWEEPROM.EFI /w 0 A0 A0 [%2]
endif

if %Length% == 2 then
uRWEEPROM.EFI /w 0 A2 A2 00
uRWEEPROM.EFI /w 0 A0 A1 [%2]
endif

if %Length% == 3 then
uRWEEPROM.EFI /w 0 A3 A3 00
uRWEEPROM.EFI /w 0 A0 A2 [%2]
endif

if %Length% == 4 then
uRWEEPROM.EFI /w 0 A4 A4 00
uRWEEPROM.EFI /w 0 A0 A3 [%2]
endif

if %Length% == 5 then
uRWEEPROM.EFI /w 0 A5 A5 00
uRWEEPROM.EFI /w 0 A0 A4 [%2]
endif

if %Length% == 6 then
uRWEEPROM.EFI /w 0 A6 A6 00
uRWEEPROM.EFI /w 0 A0 A5 [%2]
endif

if %Length% == 7 then
uRWEEPROM.EFI /w 0 A7 A7 00
uRWEEPROM.EFI /w 0 A0 A6 [%2]
endif

if %Length% == 8 then
uRWEEPROM.EFI /w 0 A8 A8 00
uRWEEPROM.EFI /w 0 A0 A7 [%2]
endif

if %Length% == 9 then
uRWEEPROM.EFI /w 0 A9 A9 00
uRWEEPROM.EFI /w 0 A0 A8 [%2]
endif

if %Length% == 10 then
uRWEEPROM.EFI /w 0 AA AA 00
uRWEEPROM.EFI /w 0 A0 A9 [%2]
endif

if %Length% == 11 then
uRWEEPROM.EFI /w 0 AB AB 00
uRWEEPROM.EFI /w 0 A0 AA [%2]
endif

if %Length% == 12 then
uRWEEPROM.EFI /w 0 AC AC 00
uRWEEPROM.EFI /w 0 A0 AB [%2]
endif

if %Length% == 13 then
uRWEEPROM.EFI /w 0 AD AD 00
uRWEEPROM.EFI /w 0 A0 AC [%2]
endif

if %Length% == 14 then
uRWEEPROM.EFI /w 0 AE AE 00
uRWEEPROM.EFI /w 0 A0 AD [%2]
endif

if %Length% == 15 then
uRWEEPROM.EFI /w 0 AF AF 00
uRWEEPROM.EFI /w 0 A0 AE [%2]
endif

if %Length% == 16 then
uRWEEPROM.EFI /w 0 B0 B0 00
uRWEEPROM.EFI /w 0 A0 AF [%2]
endif

if %Length% == 17 then
uRWEEPROM.EFI /w 0 B1 B1 00
uRWEEPROM.EFI /w 0 A0 B0 [%2]
endif

if %Length% == 18 then
uRWEEPROM.EFI /w 0 B2 B2 00
uRWEEPROM.EFI /w 0 A0 B1 [%2]
endif

if %Length% == 19 then
uRWEEPROM.EFI /w 0 B3 B3 00
uRWEEPROM.EFI /w 0 A0 B2 [%2]
endif

if %Length% == 20 then
uRWEEPROM.EFI /w 0 B4 B4 00
uRWEEPROM.EFI /w 0 A0 B3 [%2]
endif

if %Length% == 21 then
uRWEEPROM.EFI /w 0 B5 B5 00
uRWEEPROM.EFI /w 0 A0 B4 [%2]
endif

if %Length% == 22 then
uRWEEPROM.EFI /w 0 B6 B6 00
uRWEEPROM.EFI /w 0 A0 B5 [%2]
endif

if %Length% == 23 then
uRWEEPROM.EFI /w 0 B7 B7 00
uRWEEPROM.EFI /w 0 A0 B6 [%2]
endif

if %Length% == 24 then
uRWEEPROM.EFI /w 0 B8 B8 00
uRWEEPROM.EFI /w 0 A0 B7 [%2]
endif

if %Length% == 25 then
uRWEEPROM.EFI /w 0 B9 B9 00
uRWEEPROM.EFI /w 0 A0 B8 [%2]
endif

if %Length% == 26 then
uRWEEPROM.EFI /w 0 BA BA 00
uRWEEPROM.EFI /w 0 A0 B9 [%2]
endif

if %Length% == 27 then
uRWEEPROM.EFI /w 0 BB BB 00
uRWEEPROM.EFI /w 0 A0 BA [%2]
endif

if %Length% == 28 then
uRWEEPROM.EFI /w 0 BC BC 00
uRWEEPROM.EFI /w 0 A0 BB [%2]
endif

if %Length% == 29 then
uRWEEPROM.EFI /w 0 BD BD 00
uRWEEPROM.EFI /w 0 A0 BC [%2]
endif

if %Length% == 30 then
uRWEEPROM.EFI /w 0 BE BE 00
uRWEEPROM.EFI /w 0 A0 BD [%2]
endif

if %Length% == 31 then
uRWEEPROM.EFI /w 0 BF BF 00
uRWEEPROM.EFI /w 0 A0 BE [%2]
endif

goto MBDStatus

:MT
if %Length% == 1 then
uRWEEPROM.EFI /w 0 41 41 00
uRWEEPROM.EFI /w 0 40 40 [%2]
endif

if %Length% == 2 then
uRWEEPROM.EFI /w 0 42 42 00
uRWEEPROM.EFI /w 0 40 41 [%2]
endif

if %Length% == 3 then
uRWEEPROM.EFI /w 0 43 43 00
uRWEEPROM.EFI /w 0 40 42 [%2]
endif

if %Length% == 4 then
uRWEEPROM.EFI /w 0 44 44 00
uRWEEPROM.EFI /w 0 40 43 [%2]
endif

if %Length% == 5 then
uRWEEPROM.EFI /w 0 45 45 00
uRWEEPROM.EFI /w 0 40 44 [%2]
endif

if %Length% == 6 then
uRWEEPROM.EFI /w 0 46 46 00
uRWEEPROM.EFI /w 0 40 45 [%2]
endif

if %Length% == 7 then
uRWEEPROM.EFI /w 0 47 47 00
uRWEEPROM.EFI /w 0 40 46 [%2]
endif

if %Length% == 8 then
uRWEEPROM.EFI /w 0 48 48 00
uRWEEPROM.EFI /w 0 40 47 [%2]
endif

if %Length% == 9 then
uRWEEPROM.EFI /w 0 49 49 00
uRWEEPROM.EFI /w 0 40 48 [%2]
endif

if %Length% == 10 then
uRWEEPROM.EFI /w 0 4A 4A 00
uRWEEPROM.EFI /w 0 40 49 [%2]
endif

if %Length% == 11 then
uRWEEPROM.EFI /w 0 4B 4B 00
uRWEEPROM.EFI /w 0 40 4A [%2]
endif

if %Length% == 12 then
uRWEEPROM.EFI /w 0 4C 4C 00
uRWEEPROM.EFI /w 0 40 4B [%2]
endif

if %Length% == 13 then
uRWEEPROM.EFI /w 0 4D 4D 00
uRWEEPROM.EFI /w 0 40 4C [%2]
endif

if %Length% == 14 then
uRWEEPROM.EFI /w 0 4E 4E 00
uRWEEPROM.EFI /w 0 40 4D [%2]
endif

if %Length% == 15 then
uRWEEPROM.EFI /w 0 4F 4F 00
uRWEEPROM.EFI /w 0 40 4E [%2]
endif

if %Length% == 16 then
uRWEEPROM.EFI /w 0 50 50 00
uRWEEPROM.EFI /w 0 40 4F [%2]
endif

if %Length% == 17 then
uRWEEPROM.EFI /w 0 51 51 00
uRWEEPROM.EFI /w 0 40 50 [%2]
endif

if %Length% == 18 then
uRWEEPROM.EFI /w 0 52 52 00
uRWEEPROM.EFI /w 0 40 51 [%2]
endif

if %Length% == 19 then
uRWEEPROM.EFI /w 0 53 53 00
uRWEEPROM.EFI /w 0 40 52 [%2]
endif

if %Length% == 20 then
uRWEEPROM.EFI /w 0 54 54 00
uRWEEPROM.EFI /w 0 40 53 [%2]
endif

if %Length% == 21 then
uRWEEPROM.EFI /w 0 55 55 00
uRWEEPROM.EFI /w 0 40 54 [%2]
endif

if %Length% == 22 then
uRWEEPROM.EFI /w 0 56 56 00
uRWEEPROM.EFI /w 0 40 55 [%2]
endif

if %Length% == 23 then
uRWEEPROM.EFI /w 0 57 57 00
uRWEEPROM.EFI /w 0 40 56 [%2]
endif

if %Length% == 24 then
uRWEEPROM.EFI /w 0 58 58 00
uRWEEPROM.EFI /w 0 40 57 [%2]
endif

if %Length% == 25 then
uRWEEPROM.EFI /w 0 59 59 00
uRWEEPROM.EFI /w 0 40 58 [%2]
endif

if %Length% == 26 then
uRWEEPROM.EFI /w 0 5A 5A 00
uRWEEPROM.EFI /w 0 40 59 [%2]
endif

if %Length% == 27 then
uRWEEPROM.EFI /w 0 5B 5B 00
uRWEEPROM.EFI /w 0 40 5A [%2]
endif

if %Length% == 28 then
uRWEEPROM.EFI /w 0 6C 5C 00
uRWEEPROM.EFI /w 0 40 5B [%2]
endif

if %Length% == 29 then
uRWEEPROM.EFI /w 0 5D 5D 00
uRWEEPROM.EFI /w 0 40 5C [%2]
endif

if %Length% == 30 then
uRWEEPROM.EFI /w 0 5E 5E 00
uRWEEPROM.EFI /w 0 40 5D [%2]
endif

if %Length% == 31 then
uRWEEPROM.EFI /w 0 5F 5F 00
uRWEEPROM.EFI /w 0 40 5E [%2]
endif

goto MBDStatus

:PN

if %Length% == 1 then
uRWEEPROM.EFI /w 0 81 81 00
uRWEEPROM.EFI /w 0 80 80 [%2]
endif

if %Length% == 2 then
uRWEEPROM.EFI /w 0 82 82 00
uRWEEPROM.EFI /w 0 80 81 [%2]
endif

if %Length% == 3 then
uRWEEPROM.EFI /w 0 83 83 00
uRWEEPROM.EFI /w 0 80 82 [%2]
endif

if %Length% == 4 then
uRWEEPROM.EFI /w 0 84 84 00
uRWEEPROM.EFI /w 0 80 83 [%2]
endif

if %Length% == 5 then
uRWEEPROM.EFI /w 0 85 85 00
uRWEEPROM.EFI /w 0 80 84 [%2]
endif

if %Length% == 6 then
uRWEEPROM.EFI /w 0 86 86 00
uRWEEPROM.EFI /w 0 80 85 [%2]
endif

if %Length% == 7 then
uRWEEPROM.EFI /w 0 87 87 00
uRWEEPROM.EFI /w 0 80 86 [%2]
endif

if %Length% == 8 then
uRWEEPROM.EFI /w 0 88 88 00
uRWEEPROM.EFI /w 0 80 87 [%2]
endif

if %Length% == 9 then
uRWEEPROM.EFI /w 0 89 89 00
uRWEEPROM.EFI /w 0 80 88 [%2]
endif

if %Length% == 10 then
uRWEEPROM.EFI /w 0 8A 8A 00
uRWEEPROM.EFI /w 0 80 89 [%2]
endif

if %Length% == 11 then
uRWEEPROM.EFI /w 0 8B 8B 00
uRWEEPROM.EFI /w 0 80 8A [%2]
endif

if %Length% == 12 then
uRWEEPROM.EFI /w 0 8C 8C 00
uRWEEPROM.EFI /w 0 80 8B [%2]
endif

if %Length% == 13 then
uRWEEPROM.EFI /w 0 8D 8D 00
uRWEEPROM.EFI /w 0 80 8C [%2]
endif

if %Length% == 14 then
uRWEEPROM.EFI /w 0 8E 8E 00
uRWEEPROM.EFI /w 0 80 8D [%2]
endif

if %Length% == 15 then
uRWEEPROM.EFI /w 0 8F 8F 00
uRWEEPROM.EFI /w 0 80 8E [%2]
endif

if %Length% == 16 then
uRWEEPROM.EFI /w 0 90 90 00
uRWEEPROM.EFI /w 0 80 8F [%2]
endif

if %Length% == 17 then
uRWEEPROM.EFI /w 0 91 91 00
uRWEEPROM.EFI /w 0 80 90 [%2]
endif

if %Length% == 18 then
uRWEEPROM.EFI /w 0 92 92 00
uRWEEPROM.EFI /w 0 80 91 [%2]
endif

if %Length% == 19 then
uRWEEPROM.EFI /w 0 93 93 00
uRWEEPROM.EFI /w 0 80 92 [%2]
endif

if %Length% == 20 then
uRWEEPROM.EFI /w 0 94 94 00
uRWEEPROM.EFI /w 0 80 93 [%2]
endif

if %Length% == 21 then
uRWEEPROM.EFI /w 0 95 95 00
uRWEEPROM.EFI /w 0 80 94 [%2]
endif

if %Length% == 22 then
uRWEEPROM.EFI /w 0 96 96 00
uRWEEPROM.EFI /w 0 80 95 [%2]
endif

if %Length% == 23 then
uRWEEPROM.EFI /w 0 97 97 00
uRWEEPROM.EFI /w 0 80 96 [%2]
endif

if %Length% == 24 then
uRWEEPROM.EFI /w 0 98 98 00
uRWEEPROM.EFI /w 0 80 97 [%2]
endif

if %Length% == 25 then
uRWEEPROM.EFI /w 0 99 99 00
uRWEEPROM.EFI /w 0 80 98 [%2]
endif

if %Length% == 26 then
uRWEEPROM.EFI /w 0 9A 9A 00
uRWEEPROM.EFI /w 0 80 99 [%2]
endif

if %Length% == 27 then
uRWEEPROM.EFI /w 0 9B 9B 00
uRWEEPROM.EFI /w 0 80 9A [%2]
endif

if %Length% == 28 then
uRWEEPROM.EFI /w 0 9C 9C 00
uRWEEPROM.EFI /w 0 80 9B [%2]
endif

if %Length% == 29 then
uRWEEPROM.EFI /w 0 9D 9D 00
uRWEEPROM.EFI /w 0 80 9C [%2]
endif

if %Length% == 30 then
uRWEEPROM.EFI /w 0 9E 9E 00
uRWEEPROM.EFI /w 0 80 9D [%2]
endif

if %Length% == 31 then
uRWEEPROM.EFI /w 0 9F 9F 00
uRWEEPROM.EFI /w 0 80 9E [%2]
endif

goto MBDStatus

:MBDStatus
set -v MBDStatus %lasterror%

if %MBDStatus% == "0x7" then
BIOSID.efi %1Cpalo %2
cls
echo Done..
endif

goto END

:MBDStatusU
set -v MBDStatus %lasterror%

if %MBDStatus% == "0x7" then
BIOSID.efi %1Cpalo %CandidatesUUID%
cls
echo Done..
endif

goto END

:Readit


goto END

:END


