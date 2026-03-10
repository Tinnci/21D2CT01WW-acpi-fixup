echo -off
# Initial Setup for current working drive & Screen mode
#
mode 80 25
mode 100 31
mode 128 40
mode 160 53
mode 160 60
cls

if exist fs0:\STARTUP.NSH then
    fs0:
    set -v CTL_DRV fs0:
endif

if exist fs1:\STARTUP.NSH then
    fs1:
    set -v CTL_DRV fs1:
endif

if exist fs2:\STARTUP.NSH then
    fs0:
    set -v CTL_DRV fs2:
endif

if exist fs3:\STARTUP.NSH then
    fs1:
    set -v CTL_DRV fs3:
endif

if exist fs4:\STARTUP.NSH then
    fs0:
    set -v CTL_DRV fs4:
endif

if exist fs5:\STARTUP.NSH then
    fs1:
    set -v CTL_DRV fs5:
endif

set -v U1ver 3.5.3
set -v TEST_DRV %CTL_DRV%
set -v BOOTL EFI\BOOT
set -v MTSN MTMSN
set -v CBIOS LBIOS
set -v BIOS %MTSN%\BIOSID
set -v BMENU %MTSN%\BMENU
set -v Log %MTSN%\Help
set -v MENUITEM exit
set -v MTSNTool Other 
set -v path %CTL_DRV%\%MTSN%;%TEST_DRV%\%DOSDIR%;%CTL_DRV%\%MTSN%\Help;%CTL_DRV%\%BIOS%;%CTL_DRV%\gku1tools;%CTL_DRV%\LDIAG;%CTL_DRV%\MODS;%path%

%CTL_DRV%

BIOSID32.nsh /RD
BIOSID.nsh /RD

cd \

:B2LBIOS

if exist %CTL_DRV%\%CBIOS%.NSH then
   %CBIOS%.NSH
endif

if "%LBIOS%" == "Yes" then 
   goto checkMTM
endif

:BMENU

cd \
cd %BMENU%

Bmenu32.nsh
Bmenu.nsh

goto %MENUITEM%

:checkMTM
cd \

if "%MTSNTool%" == "Other" then
  goto %MTSNTool%
endif

if "%LBIOS%" == "Yes" then 
   goto LBIOS
endif

if "%MTSNTool%" == "ThinkPad" then
  cls
  message.nsh
  message6.nsh
  pause
  goto %MTarget%
endif

if "%MTSNTool%" == "TP2" then
  cls
  message.nsh
  pause
  goto ThinkPad
endif

if "%MTSNTool%" == "TP8TP10" then
  cls
  message.nsh
  pause
  goto ThinkPad
endif

goto LBG

:ThinkPad
cd \
md Trace
echo ""%U1ver%" "%BIOSVERSION%" "%MTSNTool%"" >> %Log%\Machine.dat
cd %MTSN%\%MTSNTool%
%MTarget%.nsh

goto exit

:ThinkPad1
cd \
md Trace
echo ""%U1ver%" "%BIOSVERSION%" Edge E4xx E5xx" >> %Log%\Machine.dat
cd %MTSN%\%MTSNTool%
%MTarget%.nsh

goto exit

:LBG
if %MTSNTool% == "MBD" then

   BIOSID.efi /SC "F9CN" %BIOSVERSION%
   if %lasterror% == 0 then
       set -v BLF BLF
   endif

   BIOSID.efi /SC "GJCN" %BIOSVERSION%
   if %lasterror% == 0 then
       set -v BLF BLF
   endif

endif

cd \
cls

message.nsh
message3.nsh

if "%BLF%" == "BLF" then
message12.nsh
endif

goto exit

:LDIAGLINUX
cls
message11.nsh
pause
cd \
cd %BOOTL%
ldiag-linux.efi
goto exit

:WinPE
cd \
md boot
if not exist %CTL_DRV%\boot\BOOT.SDI then
   copy %CTL_DRV%\%BMENU%\BOOT.SDI %CTL_DRV%\boot
endif
cls
message10.nsh
pause
cd \
cd %BOOTL%
BootX64-PE.efi
goto exit

:Grub
cd \
cd %BOOTL%
bootx64-grub.efi
goto exit

:LBIOS

biosid.efi /CB

if "%LBIOS%" == "No" then 
   echo =   CUSTOM BIOS is not found   
   goto LBIOSQ
endif

if "%LBIOS%" == "No3" then 
   echo =   Please check and set correct MTM first !!!   
   goto LBIOSQ
endif

if "%LBIOS%" == "No4" then 
   echo =   current product is not supported !!!   
   goto LBIOSQ
endif

cd \
cd %CBIOS%\%MTSNTool%
%CTarget%

:LBIOSQ
cd \
if exist %CTL_DRV%\%CBIOS%.NSH then
   RM %CTL_DRV%\%CBIOS%.NSH -q
endif

goto exit

:Other
cd \
echo ""%U1ver%" "%BIOSVERSION%" Other" >> %Log%\Machine.dat
cls
message.nsh
message2.nsh

biosid.efi /ID
message5.nsh
cd \

goto exit

:KBID
cd \
cls
message9.nsh

goto exit

:OTHERT
cd \
cls
message8.nsh
cd \

goto exit

:exit
cd \
