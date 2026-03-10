echo -off
cls

If %1 == "" then
    goto END
Endif

If %2 == "" then 
  goto Readit
Endif

If %1 == "/uu" then
  novouefix64-15.efi /w /uu /g
  goto END
Endif

If %1 == "/ln" then 
  novouefix64-15.efi /w /ln %2
  goto END
Endif

If %1 == "/mt" then
  novouefix64-15.efi /w /mt %2
  goto END
Endif

If %1 == "/pn" then
  novouefix64-15.efi /w /pn %2
  goto END
Endif

goto END

:Readit
If %1 == "/uu" then
  novouefix64-15.efi /r /uu
  goto END
Endif

If %1 == "/ln" then 
  novouefix64-15.efi /r /ln
  goto END
Endif

If %1 == "/mt" then
  novouefix64-15.efi /r /mt
  goto END
Endif

If %1 == "/pn" then
  novouefix64-15.efi /r /pn
  goto END
Endif

goto END


:END
