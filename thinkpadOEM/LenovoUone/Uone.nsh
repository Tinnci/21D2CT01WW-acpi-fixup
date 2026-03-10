echo -off

if %1 == /uu then
set -v MTSNUT " /uu"
goto checkUU
endif

if %1 == /ln then
set -v MTSNUT " /ln"
goto checkSTRING
endif

if %1 == /mt then
set -v MTSNUT " /mt"
goto checkSTRING
endif

if %1 == /pn then
set -v MTSNUT " /pn"
goto checkSTRING
endif

if %1 == /UU then
set -v MTSNUT " /uu"
goto checkUU
endif

if %1 == /LN then
set -v MTSNUT " /ln"
goto checkSTRING
endif

if %1 == /MT then
set -v MTSNUT " /mt"
goto checkSTRING
endif

if %1 == /PN then
set -v MTSNUT " /pn"
goto checkSTRING
endif

if %1 == /BLFE then
set -v MTSNUT " /BLFE"
goto checkBL
endif

if %1 == /blfe then
set -v MTSNUT " /BLFE"
goto checkBL
endif

if %1 == /blfd then
set -v MTSNUT " /BLFD"
goto checkBL
endif

if %1 == /BLFD then
set -v MTSNUT " /BLFD"
goto checkBL
endif


cls
echo "Invalid parameter!"
goto HELP

:checkUU
If %2 == "" then
cls
goto checkamide
Endif

If NOT %2 == "AUTO" then
cls
echo "Error ! : uone.nsh "%1" "%2" "%3" "%4" "%5" "%6"..."
goto HELP
Endif

cls
message7.nsh
pause

:checkSTRING
If %2 == "" then
cls
goto checkamide
Endif

If NOT %3 == "" then
cls
echo "Error ! : uone.nsh "%1" "%2" "%3" "%4" "%5" "%6"..."
echo "For Parameter ^"string^" , do NOT forget the quotes!" 
goto HELP
Endif

cd \

echo ""%U1ver%" "%BIOSVERSION%" "%1" "%2"" >> %Log%\Machine.dat

:CheckMTSN
if "%MTSNTool%" == "Other" then
  goto Other
endif

:Writeit
#### run MTSNTools
####
cd \
cd %MTSN%\%MTSNTool%
%MTarget% %MTSNUT% %2
if "%MTSNTool%" == "Lvar" then
   if %MTSNUT% == "/pn" then
      biosid.efi /FM %2
      %MTarget% "/fm" "%FM%"
   endif

endif
goto HELP

:checkamide
if "%MTSNTool%" == "Flash" then
 goto Flash
endif

goto Readit

:Flash
echo "Invalid parameter!"
goto HELP

:Other
cd \
cls
message.nsh
message2.nsh

goto exit

:checkBL
if "%BLF%" == "BLF" then
 cd \
 cls
 cd %MTSN%\%MTSNTool%
 %MTarget% %MTSNUT%
endif

goto HELP

:Readit
 cd \
 cls
 cd %MTSN%\%MTSNTool%
%MTarget% %MTSNUT%

:HELP
cd \

message.nsh
message3.nsh

if "%BLF%" == "BLF" then
message12.nsh
endif

:exit
