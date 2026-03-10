echo -off
cls

If %2 == "" then 
  goto Readit
Endif

If %1 == "/uu" then
  AMIDEEFIx64_518.efi /SU AUTO
    goto END
Endif

If %1 == "/ln" then 
  AMIDEEFIx64_518.efi /SS %2
  goto END
Endif

If %1 == "/mt" then
  AMIDEEFIx64_518.efi /SP %2
  goto END
Endif

If %1 == "/pn" then
  AMIDEEFIx64_518.efi /SV %2
  goto END
Endif

goto END

:Readit
If %1 == "/uu" then
  AMIDEEFIx64_518.efi /SU
    goto END
Endif

If %1 == "/ln" then 
  AMIDEEFIx64_518.efi /SS
  goto END
Endif

If %1 == "/mt" then
  AMIDEEFIx64_518.efi /SP
  goto END
Endif

If %1 == "/pn" then
  AMIDEEFIx64_518.efi /SV
  goto END
Endif

goto END


:END




