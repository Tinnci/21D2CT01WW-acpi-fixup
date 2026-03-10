@ECHO OFF

set currentdir=%~dp0
set TempFile_Name=%SystemRoot%\System32\BatTestUACin_SysRt%Random%.batemp
echo %TempFile_Name%
echo.
echo.
( echo "BAT Test UAC in Temp" >%TempFile_Name% ) 1>nul 2>nul
cls
if exist %TempFile_Name% (
del %TempFile_Name% 1>nul 2>nul
cls

 
 
color 0f
mode con cols=85 lines=30
echo.
echo.
echo.
echo.                       Create By Will
echo.
echo.
echo This App is now running in Administrator right
echo.
echo.
echo.
goto main1
) else (
echo. 
cls
color 0f
mode con cols=85 lines=30
echo.
echo.
echo.
echo.
echo.
echo.                       Creat By Will
echo.
echo.
echo  Attention please, This App need to run in Administrator right!
echo.
echo.
echo  Please shutdown the app and re-launch with Administrator right!
echo.
echo.
pause
goto exit
echo.
)
pause

:main1
rem echo. path
echo.
echo.
echo. Test will start in... 
timeout /t 3
cls
echo.
echo.
rem echo %currentdir%
echo.
echo.
echo. "System will display a picture on E-Ink display in few seconds later."
echo.
cd %currentdir%
T1000_cmd.exe -d "%currentdir%4k.jpg"
pause
cls

echo.
echo.
echo. "System will display all black on E-Ink display in few seconds later."
echo.
echo.
cd %currentdir%
T1000_cmd.exe -d "%currentdir%black.jpg"
pause
cls

echo.
echo.
echo. "System will display all white on E-Ink display in few seconds later."
echo.
echo.
cd %currentdir%
T1000_cmd.exe -d "%currentdir%white.jpg"
pause
cls

echo.
echo.
echo. "System will display a picture on E-Ink display in few seconds later."
echo.
echo.
cd %currentdir%
T1000_cmd.exe -d "%currentdir%4k.jpg"
echo.
echo.
echo. Test finish
echo.
echo. press any key to exit
echo.
echo.
pause
goto exit

:exit
cls
echo.
echo.
echo. Test will exit in 
timeout /t 5
exit