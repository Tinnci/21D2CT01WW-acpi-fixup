echo -off
cls

If %1 == "" then
    BIOSID.efi
    goto END
Endif

If %2 == "" then 
    BIOSID.efi %1
    goto END
Endif

If %3 == "" then
    goto END
Endif

BIOSID.efi %1 %2

:END