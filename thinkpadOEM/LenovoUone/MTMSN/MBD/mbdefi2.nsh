echo -off
cls
set -v MBDStatus 0
#cp PARR.efi

If %1 == "" then
    goto END
Endif

If %2 == "" then 
  goto Readit
Endif

:Writeit
set -v Par2 %2
PARR.efi /Str %Par2% /Tn=0 /S=" /Var=Par2 /V /B
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
PARR.efi /Str %Par2% /Tn=0 /S=" /Var=Par2 /V /B
echo ::Par2=%Par2%

MBD.efi /Wh 160 "%Par2%"
stall 2000000 > nul
set -v MBDStatus %lasterror%
if %MBDStatus% == 0 then 
    cls
    goto Verify
endif

goto END

:LN
MBD.efi /Ws 110 "%Par2%"
stall 2000000 > nul
set -v MBDStatus %lasterror%
if %MBDStatus% == 0 then 
    cls
    goto Verify
endif

goto END

:MT
MBD.efi /Ws 30 "%Par2%"
stall 2000000 > nul
set -v MBDStatus %lasterror%
if %MBDStatus% == 0 then 
    cls
    goto Verify
endif

goto END

:PN
MBD.efi /Wh 90 0000000000000000000000000000000000000000
stall 2000000 > nul
MBD.efi /CHK 90 20 > nul
MBD.efi /Ws 90 "%Par2%"
stall 2000000 > nul
set -v MBDStatus %lasterror%
if %MBDStatus% == 0 then 
    cls
    goto Verify
endif

goto END

:Verify
echo Verifying NVS...
MBD.efi /CHK 00 10 > nul
MBD.efi /CHK 10 10 > nul
MBD.efi /CHK 20 10 > nul
MBD.efi /CHK 30 10 > nul
MBD.efi /CHK 70 20 > nul
MBD.efi /CHK 90 20 > nul
MBD.efi /CHK C0 40 > nul
MBD.efi /CHK 110 30 > nul
MBD.efi /CHK 140 10 > nul
MBD.efi /CHK 180 40 > nul
MBD.efi /CHK 1C0 10 > nul
MBD.efi /CHK 1D0 20 > nul
echo "Done!"
goto END

:Readit
If %1 == "/uu" then
  MBD.efi /Rh 160 10
  goto END
Endif

If %1 == "/ln" then 
  MBD.efi /Rs 110 30
  goto END
Endif

If %1 == "/mt" then
  MBD.efi /Rs 30 10
  goto END
Endif

If %1 == "/pn" then
  MBD.efi /Rs 90 20
  goto END
Endif

goto END


:END


