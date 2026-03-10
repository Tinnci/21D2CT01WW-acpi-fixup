echo -off
cls

If %1 == "" then
    goto END
Endif

If %2 == "" then 
  goto Readit
Endif

If %1 == "/uu" then
  novouefi.efi /w /uu /g
  novouefix64.efi /w /uu /g
  goto END
Endif

If %1 == "/ln" then 
  novouefi.efi /w /ln %2
  novouefix64.efi /w /ln %2
  goto END
Endif

If %1 == "/mt" then
  novouefi.efi /w /mt %2
  novouefix64.efi /w /mt %2
  goto END
Endif

If %1 == "/pn" then
  novouefi.efi /w /pn %2
  novouefix64.efi /w /pn %2
  goto END
Endif

goto END

:Readit
If %1 == "/uu" then
  novouefi.efi /r /uu
  novouefix64.efi /r /uu
  goto END
Endif

If %1 == "/ln" then 
  novouefi.efi /r /ln
  novouefix64.efi /r /ln
  goto END
Endif

If %1 == "/mt" then
  novouefi.efi /r /mt
  novouefix64.efi /r /mt
  goto END
Endif

If %1 == "/pn" then
  novouefi.efi /r /pn
  novouefix64.efi /r /pn
  goto END
Endif

goto END


:END
