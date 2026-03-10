echo -off
cls

If %1 == "" then
    goto END
Endif

If %2 == "" then 
  goto Readit
Endif

:Writeit
If %1 == "/uu" then
  EEPROM.efi -s -uu -b "%CandidatesUUID%"
  goto END
Endif

If %1 == "/ln" then 
  EEPROM.efi -s -ln -c %2
  goto END
Endif

If %1 == "/mt" then
  EEPROM.efi -s -mt -c %2
  goto END
Endif

If %1 == "/pn" then
  EEPROM.efi -s -pn -c %2
  goto END
Endif

goto END

:Readit
If %1 == "/uu" then
  EEPROM.efi -g -uu
  goto END
Endif

If %1 == "/ln" then 
  EEPROM.efi -g -ln
  goto END
Endif

If %1 == "/mt" then
  EEPROM.efi -g -mt
  goto END
Endif

If %1 == "/pn" then
  EEPROM.efi -g -pn
  goto END
Endif

goto END

:END

