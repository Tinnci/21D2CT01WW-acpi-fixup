echo -off
cls

If %1 == "" then
    BIOSID32.efi
    goto END
Endif

If %2 == "" then 
    BIOSID32.efi %1
    goto END
Endif

If %3 == "" then
    goto END
Endif

BIOSID32.efi %1 %2

:END