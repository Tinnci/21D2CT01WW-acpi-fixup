@echo off
path=c:\;c:\windows;c:\windows\system32;c:\windows\system32\windowspowershell\v1.0;z:\WindowsPowerShell\v1.0;d:\win\wintool
cd /D %~dp0
echo  " Eink " 6F " Eink Test Start ..."
IT8951_USB_Cmd.exe -v
echo Display white.jpg
pause
IT8951_USB_Cmd.exe -d 2 white.jpg
cls
echo Display black.jpg
pause
IT8951_USB_Cmd.exe -d 2 black.jpg
cls
echo Display gray.jpg
pause
IT8951_USB_Cmd.exe -d 2 gray.jpg
cls
echo Display white.jpg
pause
IT8951_USB_Cmd.exe -d 2 white.jpg


:start
if exist result.log del result.log
cls
color 0F
::IT8951_USB_Cmd.exe -d 2 test.png
::打开滑线测试时使用
taskkill /f /im "SCheckCapG14T_v0.02.0.exe"
echo "Eink TP Test Start" 1F "Eink TP Test Start"

powershell start-process exe\stopEinkSrv.bat -verb runas
timeout 1
call exe\ThinkBook13S_PathThru_ON.exe
call exe\SCheckCapG14T_v0.02.0.exe ini\ThinkBook-13s_Assy_PID5210.ini
rem call exe\ThinkBook13S_PathThru_OFF.exe
rem powershell start-process exe\startEinkSrv.bat -verb runas

:check
timeout 1
if not exist result.log goto fail
find /i "OK:1 NG:0" result.log >nul
if %errorlevel% == 0 goto end


:fail
cls
color 4F
echo ================================================
echo Eink TP Test Fail
echo The test fails, shut down the test software and 
echo restart the system to test again 
echo ================================================
pause
taskkill /f /im "SCheckCapG14T_v0.02.0.exe"
shutdown -r -t 3
pause
pause
pause
goto fail

:end
color 2F
taskkill /f /im "SCheckCapG14T_v0.02.0.exe"
powershell start-process exe\startEinkSrv.bat -verb runas
echo ===========================================
echo 	Test Pass!!!
echo 	Test Pass!!!
echo 	Test Pass!!!
echo ===========================================
pause
pause