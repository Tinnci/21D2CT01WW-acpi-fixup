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
  ShellFlash64.efi /patch /dus "%CandidatesUUID%" /exit
  goto END
Endif

If %1 == "/ln" then 
  ShellFlash64.efi /patch /dsm %2 /exit
  goto END
Endif

If %1 == "/mt" then
  ShellFlash64.efi /patch /dos 1 %2 /exit
  goto END
Endif

If %1 == "/pn" then
  ShellFlash64.efi /patch /dvs %2 /exit
  goto END
Endif

goto END

:Readit

goto END

:END
