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
  EEPROM.efi /wuu "%CandidatesUUID%"
  EEPROMx64.efi /wuu "%CandidatesUUID%"
  goto END
Endif

If %1 == "/ln" then 
  EEPROM.efi /wsn %2
  EEPROMx64.efi /wsn %2
  goto END
Endif

If %1 == "/mt" then
  EEPROM.efi /wmt %2
  EEPROMx64.efi /wmt %2
  goto END
Endif

If %1 == "/pn" then
  EEPROM.efi /wpn %2
  EEPROMx64.efi /wpn %2
  goto END
Endif

goto END

:Readit
If %1 == "/uu" then
  EEPROM.efi /ruu
  EEPROMx64.efi /ruu
  goto END
Endif

If %1 == "/ln" then 
  EEPROM.efi /rsn
  EEPROMx64.efi /rsn
  goto END
Endif

If %1 == "/mt" then
  EEPROM.efi /rmt
  EEPROMx64.efi /rmt
  goto END
Endif

If %1 == "/pn" then
  EEPROM.efi /rpn
  EEPROMx64.efi /rpn
  goto END
Endif


goto END

:END

