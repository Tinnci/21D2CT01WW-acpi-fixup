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

MBD3.efi /Wh 1A0 "%Par2%"
stall 2000000 > nul
set -v MBDStatus %lasterror%
if %MBDStatus% == 0 then 
    cls
    goto Verify
endif

goto END

:LN
MBD3.efi /Ws 150 "%Par2%"
stall 2000000 > nul
set -v MBDStatus %lasterror%
if %MBDStatus% == 0 then 
    cls
    goto Verify
endif

goto END

:MT

MBD3.efi /Ws 30 "%Par2%"
stall 2000000 > nul
set -v MBDStatus %lasterror%
if %MBDStatus% == 0 then 
    cls
    goto Verify
endif

goto END

:PN
MBD3.efi /Wh B0 000000000000000000000000000000000000000000000000
stall 2000000 > nul
MBD3.efi /CHK B0 24 > nul
MBD3.efi /Ws B0 "%Par2%"
stall 2000000 > nul
set -v MBDStatus %lasterror%
if %MBDStatus% == 0 then 
    cls
    goto Verify
endif

goto END

:Verify
echo Verifying NVS...
MBD3.efi /CHK 00 10 > nul
MBD3.efi /CHK 10 10 > nul
MBD3.efi /CHK 20 10 > nul
MBD3.efi /CHK 30 41 > nul
MBD3.efi /CHK 80 21 > nul
MBD3.efi /CHK B0 24 > nul
MBD3.efi /CHK 100 41 > nul
MBD3.efi /CHK 150 21 > nul
MBD3.efi /CHK 180 11 > nul
MBD3.efi /CHK 1A0 11 > log
MBD3.efi /CHK 1C0 41 > nul
MBD3.efi /CHK 210 21 > nul
MBD3.efi /CHK 260 21 > nul
echo "Done!"
goto END

:Readit
If %1 == "/uu" then
  MBD3.efi /Rh 1A0 10 | echo "  -- done!"
  goto END
Endif

If %1 == "/ln" then 
  MBD3.efi /Rs 150 20 | echo "  -- done!"
  goto END
Endif

If %1 == "/mt" then
  MBD3.efi /Rs 30 10 | echo "  -- done!"
  goto END
Endif

If %1 == "/pn" then
  MBD3.efi /Rs B0 20 | echo "  -- done!"
  goto END
Endif

If %1 == "/pn" then
  MBD3.efi /Rs B0 20 | echo "  -- done!"
  goto END
Endif

If %1 == "/BLFE" then
  BIOSID.efi /SC "F9CN" %BIOSVERSION%
  if %lasterror% == 0 then
       MBD2.efi /Wh 19 01
       if %lasterror% == 0 then 
           cls
           MBD2.efi /CHK 19 2 > log
           echo " Current Backlight Flag status (01 : Enabled | 00 : Disabled) is : "
           MBD2.efi /Rh 19 1
       endif
  endif

  BIOSID.efi /SC "GJCN" %BIOSVERSION%
  if %lasterror% == 0 then
       MBD2.efi /Wh 16 01
       if %lasterror% == 0 then 
           cls
           MBD2.efi /CHK 16 2 > log
           echo " Current Backlight Flag status (01 : Enabled | 00 : Disabled) is : "
           MBD2.efi /Rh 16 1
       endif
  endif

  goto END
Endif

If %1 == "/BLFD" then
  BIOSID.efi /SC "F9CN" %BIOSVERSION%
  if %lasterror% == 0 then
       MBD2.efi /Wh 19 00
       if %lasterror% == 0 then 
           cls
           MBD2.efi /CHK 19 2 > log
           echo " Current Backlight Flag status (01 : Enabled | 00 : Disabled) is : "
           MBD2.efi /Rh 19 1
       endif
  endif

  BIOSID.efi /SC "GJCN" %BIOSVERSION%
  if %lasterror% == 0 then
       MBD2.efi /Wh 16 00
       if %lasterror% == 0 then 
           cls
           MBD2.efi /CHK 16 2 > log
           echo " Current Backlight Flag status (01 : Enabled | 00 : Disabled) is : "
           MBD2.efi /Rh 16 1
       endif
  endif

  goto END
Endif

goto END

:END



