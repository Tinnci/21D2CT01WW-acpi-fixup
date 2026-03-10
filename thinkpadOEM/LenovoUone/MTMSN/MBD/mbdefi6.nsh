echo -off
cls
#cp PARR2.efi

If %1 == "" then
    goto END
Endif

If %2 == "" then 
  goto Readit
Endif

:Writeit
set -v Par2 %2
PARR2.efi /Str %Par2% /Tn=0 /S=" /Var=Par2 /V /B
echo ::Par2=%Par2%

cls

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
set -v Par2 %CandidatesUUID%
PARR2.efi /Str %Par2% /Tn=0 /S=" /Var=Par2 /V /B
echo ::Par2=%Par2%

MBD2.efi /Wh 1A0 "%Par2%"
stall 2000000 > nul
set -v MBDStatus %lasterror%
if %MBDStatus% == 0 then 
    cls
    goto Verify
endif

goto END

:LN
MBD2.efi /Ws 150 "%Par2%"
stall 2000000 > nul
set -v MBDStatus %lasterror%
if %MBDStatus% == 0 then 
    cls
    goto Verify
endif

goto END

:MT

MBD2.efi /Ws 30 "%Par2%"
stall 2000000 > nul
set -v MBDStatus %lasterror%
if %MBDStatus% == 0 then 
    cls
    goto Verify
endif

goto END

:PN
MBD2.efi /Wh B0 0000000000000000000000000000000000000000
stall 2000000 > nul
MBD2.efi /CHK B0 21 > nul
MBD2.efi /Ws B0 "%Par2%"
stall 2000000 > nul
set -v MBDStatus %lasterror%
if %MBDStatus% == 0 then 
    cls
    goto Verify
endif

goto END

:Verify
echo Verifying NVS...
MBD2.efi /CHK 00 10 > nul
MBD2.efi /CHK 10 10 > nul
MBD2.efi /CHK 20 10 > nul
MBD2.efi /CHK 30 41 > nul
MBD2.efi /CHK 80 21 > nul
MBD2.efi /CHK B0 21 > nul
MBD2.efi /CHK 100 41 > nul
MBD2.efi /CHK 150 21 > nul
MBD2.efi /CHK 180 11 > nul
MBD2.efi /CHK 1C0 41 > nul
MBD2.efi /CHK 210 21 > nul
MBD2.efi /CHK 260 21 > nul
echo "Done!"
goto END

:Readit
If %1 == "/uu" then
  MBD2.efi /Rh 1A0 10
  goto END
Endif

If %1 == "/ln" then 
  MBD2.efi /Rs 150 20
  goto END
Endif

If %1 == "/mt" then
  MBD2.efi /Rs 30 10
  goto END
Endif

If %1 == "/pn" then
  MBD2.efi /Rs B0 20
  goto END
Endif

goto END

:END



