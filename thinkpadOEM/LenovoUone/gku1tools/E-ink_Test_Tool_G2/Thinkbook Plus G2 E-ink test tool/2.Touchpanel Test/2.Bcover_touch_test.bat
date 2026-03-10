@echo off
rem cls


echo "Starting SCheckCap for B-Cover"
echo "ThinkbookPlusG2_Assy_PID5299 or"
echo "ThinkbookPlusG2_Assy_PID529B"

exe\chkhidpid.exe --vid 0x056A --pid 0x5299
if %ERRORLEVEL% equ 0 (
	exe\SCheckCapG14T_v0.02.8m.exe ini\ThinkbookPlusG2_Assy_PID5299_Auto.ini
	goto END
)

exe\chkhidpid.exe --vid 0x056A --pid 0x529B
if %ERRORLEVEL% equ 0 (
	exe\SCheckCapG14T_v0.02.8m.exe ini\ThinkbookPlusG2_Assy_PID529B_Auto.ini
	goto END
)

echo "Failed. not found the device."

:END

rem exit
