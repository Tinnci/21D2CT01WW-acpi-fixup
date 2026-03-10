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
  H2OSDE-Sx64.efi -SU AUTO
  goto END
Endif

If %1 == "/ln" then 
  H2OSDE-Sx64.efi -SS %2
  goto END
Endif

If %1 == "/mt" then
  H2OSDE-Sx64.efi -SP %2
  goto END
Endif

If %1 == "/pn" then
  H2OSDE-Sx64.efi -SV %2
  goto END
Endif

goto END

:Readit
If %1 == "/uu" then
  H2OSDE-Sx64.efi -SU
  goto END
Endif

If %1 == "/ln" then 
  H2OSDE-Sx64.efi -SS
  goto END
Endif

If %1 == "/mt" then
  H2OSDE-Sx64.efi -SP
  goto END
Endif

If %1 == "/pn" then
  H2OSDE-Sx64.efi -SV
  goto END
Endif

goto END

:END


