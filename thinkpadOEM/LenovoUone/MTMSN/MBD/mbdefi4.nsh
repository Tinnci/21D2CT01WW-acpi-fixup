echo -off
cls
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

set -v MBDStatus %lasterror%
goto END

:LN
MBD.efi /Ws 90 "%Par2%"
stall 2000000 > nul
set -v MBDStatus %lasterror%
if %MBDStatus% == 0 then 
    cls
    goto Verify
endif

goto END

:MT

set -v MBDStatus %lasterror%
goto END

:PN
MBD.efi /Wh 60 0000000000000000000000000000000000000000
stall 2000000 > nul
MBD.efi /CHK 60 20 > nul
MBD.efi /Ws 60 "%Par2%"
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
MBD.efi /CHK 50 20 > nul
MBD.efi /CHK 60 20 > nul
MBD.efi /CHK 90 40 > nul
MBD.efi /CHK F0 10 > nul
MBD.efi /CHK 130 40 > nul
MBD.efi /CHK 180 20 > nul
echo "Done!"
goto END

:Readit
If %1 == "/uu" then

  goto END
Endif

If %1 == "/ln" then 
  MBD.efi /Rs 90 40
  goto END
Endif

If %1 == "/mt" then

  goto END
Endif

If %1 == "/pn" then
  MBD.efi /Rs 60 20
  goto END
Endif

goto END

:END



