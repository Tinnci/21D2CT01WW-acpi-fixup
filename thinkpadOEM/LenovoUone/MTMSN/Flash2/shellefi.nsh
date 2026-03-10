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
 ShellFlash64.efi /dus /patch "%candidatesUUID%" /exit /nodelay /silent /nowarn
  goto END
Endif

If %1 == "/ln" then 
  ShellFlash64.efi /dss %2 /patch /exit /nodelay /silent /nowarn

  goto END
Endif

If %1 == "/mt" then
  ShellFlash64.efi /dps %2 /patch /exit /nodelay /silent /nowarn
  goto END
Endif

If %1 == "/pn" then
  ShellFlash64.efi /dvs %2 /patch /exit /nodelay /silent /nowarn
  goto END
Endif

goto END

:Readit

goto END

:END
