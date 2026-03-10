
@echo off

copy ODMTools\WinWOS\PJT.bin PJT.bin
set "str=%~3"
call :strlen len

if '%1'=='?'    goto HELP
if '%1'=='/?'    goto HELP
if '%1'=='w'    goto Write
if '%1'=='/w'    goto Write
goto HELP

:Write
if '%2'=='/uu'    goto UU
if '%2'=='/ln'    goto LN
if '%2'=='/mt'    goto MT
if '%2'=='/pn'    goto PN
goto HELP

:UU
call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 70 7F %3
goto END

:LN
if %len%==1 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 A0 A0 [%3]
if %len%==1 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 A1 A1 00
if %len%==2 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 A0 A1 [%3]
if %len%==2 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 A2 A2 00
if %len%==3 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 A0 A2 [%3]
if %len%==3 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 A3 A3 00
if %len%==4 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 A0 A3 [%3]
if %len%==4 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 A4 A4 00
if %len%==5 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 A0 A4 [%3]
if %len%==5 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 A5 A5 00
if %len%==6 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 A0 A5 [%3]
if %len%==6 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 A6 A6 00
if %len%==7 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 A0 A6 [%3]
if %len%==7 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 A7 A7 00
if %len%==8 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 A0 A7 [%3]
if %len%==8 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 A8 A8 00
if %len%==9 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 A0 A8 [%3]
if %len%==9 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 A9 A9 00
if %len%==10 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 A0 A9 [%3]
if %len%==10 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 AA AA 00
if %len%==11 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 A0 AA [%3]
if %len%==11 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 AB AB 00
if %len%==12 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 A0 AB [%3]
if %len%==12 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 AC AC 00
if %len%==13 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 A0 AC [%3]
if %len%==13 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 AD AD 00
if %len%==14 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 A0 AD [%3]
if %len%==14 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 AE AE 00
if %len%==15 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 A0 AE [%3]
if %len%==15 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 AF AF 00
if %len%==16 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 A0 AF [%3]
if %len%==16 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 B0 B0 00
if %len%==17 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 A0 B0 [%3]
if %len%==17 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 B1 B1 00
if %len%==18 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 A0 B1 [%3]
if %len%==18 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 B2 B2 00
if %len%==19 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 A0 B2 [%3]
if %len%==19 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 B3 B3 00
if %len%==20 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 A0 B3 [%3]
if %len%==20 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 B4 B4 00
if %len%==21 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 A0 B4 [%3]
if %len%==21 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 B5 B5 00
if %len%==22 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 A0 B5 [%3]
if %len%==22 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 B6 B6 00
if %len%==23 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 A0 B6 [%3]
if %len%==23 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 B7 B7 00
if %len%==24 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 A0 B7 [%3]
if %len%==24 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 B8 B8 00
if %len%==25 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 A0 B8 [%3]
if %len%==25 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 B9 B9 00
if %len%==26 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 A0 B9 [%3]
if %len%==26 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 BA BA 00
if %len%==27 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 A0 BA [%3]
if %len%==27 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 BB BB 00
if %len%==28 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 A0 BB [%3]
if %len%==28 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 BC BC 00
if %len%==29 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 A0 BC [%3]
if %len%==29 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 BD BD 00
if %len%==30 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 A0 BD [%3]
if %len%==30 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 BE BE 00
if %len%==31 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 A0 BE [%3]
if %len%==31 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 BF BF 00
goto END

:MT
if %len%==1 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 50 50 [%3]
if %len%==1 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 51 51 00
if %len%==2 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 50 51 [%3]
if %len%==2 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 52 52 00
if %len%==3 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 50 52 [%3]
if %len%==3 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 53 53 00
if %len%==4 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 50 53 [%3]
if %len%==4 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 54 54 00
if %len%==5 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 50 54 [%3]
if %len%==5 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 55 55 00
if %len%==6 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 50 55 [%3]
if %len%==6 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 56 56 00
if %len%==7 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 50 56 [%3]
if %len%==7 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 57 57 00
if %len%==8 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 50 57 [%3]
if %len%==8 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 58 58 00
if %len%==9 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 50 58 [%3]
if %len%==9 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 59 59 00
if %len%==10 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 50 59 [%3]
if %len%==10 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 5A 5A 00
if %len%==11 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 50 5A [%3]
if %len%==11 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 5B 5B 00
if %len%==12 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 50 5B [%3]
if %len%==12 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 5C 5C 00
if %len%==13 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 50 5C [%3]
if %len%==13 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 5D 5D 00
if %len%==14 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 50 5D [%3]
if %len%==14 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 5E 5E 00
if %len%==15 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 50 5E [%3]
if %len%==15 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 5F 5F 00
if %len%==16 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 50 5F [%3]
if %len%==16 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 60 60 00
if %len%==17 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 50 60 [%3]
if %len%==17 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 61 61 00
if %len%==18 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 50 61 [%3]
if %len%==18 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 62 62 00
if %len%==19 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 50 62 [%3]
if %len%==19 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 63 63 00
if %len%==20 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 50 63 [%3]
if %len%==20 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 64 64 00
if %len%==21 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 50 64 [%3]
if %len%==21 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 65 65 00
if %len%==22 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 50 65 [%3]
if %len%==22 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 66 66 00
if %len%==23 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 50 66 [%3]
if %len%==23 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 67 67 00
if %len%==24 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 50 67 [%3]
if %len%==24 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 68 68 00
if %len%==25 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 50 68 [%3]
if %len%==25 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 69 69 00
if %len%==26 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 50 69 [%3]
if %len%==26 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 6A 6A 00
if %len%==27 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 50 6A [%3]
if %len%==27 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 6B 6B 00
if %len%==28 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 50 6B [%3]
if %len%==28 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 6C 6C 00
if %len%==29 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 50 6C [%3]
if %len%==29 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 6D 6D 00
if %len%==30 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 50 6D [%3]
if %len%==30 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 6E 6E 00
if %len%==31 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 50 6E [%3]
if %len%==31 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 6F 6F 00
goto END

:PN
if %len%==1 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 80 80 [%3]
if %len%==1 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 81 81 00
if %len%==2 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 80 81 [%3]
if %len%==2 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 82 82 00
if %len%==3 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 80 82 [%3]
if %len%==3 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 83 83 00
if %len%==4 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 80 83 [%3]
if %len%==4 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 84 84 00
if %len%==5 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 80 84 [%3]
if %len%==5 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 85 85 00
if %len%==6 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 80 85 [%3]
if %len%==6 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 86 86 00
if %len%==7 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 80 86 [%3]
if %len%==7 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 87 87 00
if %len%==8 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 80 87 [%3]
if %len%==8 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 88 88 00
if %len%==9 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 80 88 [%3]
if %len%==9 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 89 89 00
if %len%==10 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 80 89 [%3]
if %len%==10 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 8A 8A 00
if %len%==11 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 80 8A [%3]
if %len%==11 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 8B 8B 00
if %len%==12 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 80 8B [%3]
if %len%==12 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 8C 8C 00
if %len%==13 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 80 8C [%3]
if %len%==13 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 8D 8D 00
if %len%==14 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 80 8D [%3]
if %len%==14 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 8E 8E 00
if %len%==15 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 80 8E [%3]
if %len%==15 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 8F 8F 00
if %len%==16 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 80 8F [%3]
if %len%==16 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 90 90 00
if %len%==17 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 80 90 [%3]
if %len%==17 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 91 91 00
if %len%==18 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 80 91 [%3]
if %len%==18 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 92 92 00
if %len%==19 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 80 92 [%3]
if %len%==19 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 93 93 00
if %len%==20 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 80 93 [%3]
if %len%==20 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 94 94 00
if %len%==21 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 80 94 [%3]
if %len%==21 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 95 95 00
if %len%==22 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 80 95 [%3]
if %len%==22 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 96 96 00
if %len%==23 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 80 96 [%3]
if %len%==23 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 97 97 00
if %len%==24 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 80 97 [%3]
if %len%==24 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 98 98 00
if %len%==25 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 80 98 [%3]
if %len%==25 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 99 99 00
if %len%==26 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 80 99 [%3]
if %len%==26 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 9A 9A 00
if %len%==27 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 80 9A [%3]
if %len%==27 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 9B 9B 00
if %len%==28 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 80 9B [%3]
if %len%==28 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 9C 9C 00
if %len%==29 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 80 9C [%3]
if %len%==29 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 9D 9D 00
if %len%==30 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 80 9D [%3]
if %len%==30 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 9E 9E 00
if %len%==31 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 80 9E [%3]
if %len%==31 call ODMTools\WinWOS\ControlWosEEPROM.exe /w 0 9F 9F 00
goto END

:HELP
@cls
echo *
echo * (C) Copyright 2016 Compal Electronics, Inc.
echo *
echo * This software is the property of Compal Electronics, Inc.
echo * You have to accept the terms in the license file before use.
echo *
echo * Copyright 2016 Compal Electronics, Inc. All rights reserved.
echo *
echo.
echo Win64 [/w] [/uu /ln /mt /pn] [STRING]
echo         /w    Write
echo         /uu   [UUID]
echo         /ln   [S/N]
echo         /mt   [Machine Type]
echo         /pn   [Product Name]
goto END

:END
del PJT.bin
goto :eof

:strlen
setlocal EnableDelayedExpansion&set n=0
:strlen_loop
if "!str:~%n%,1!" neq "" set /a n+=1&goto strlen_loop
endlocal&set "%~1=%n%"&goto :eof
