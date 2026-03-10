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
  LvarEfi64V231.efi /w %1 /b "%CandidatesUUID%"
  goto END
Endif

If %1 == "/ln" then 
  LvarEfi64V231.efi /w %1 /c %2
  goto END
Endif

If %1 == "/mt" then
  LvarEfi64V231.efi /w %1 /c %2
  goto END
Endif

If %1 == "/pn" then
  LvarEfi64V231.efi /w %1 /c %2
  goto END
Endif

If %1 == "/fm" then
  LvarEfi64V231.efi /w /fd /c %2
  goto END
Endif

goto END

:Readit

If %1 == "/uu" then
  LvarEfi64V231.efi /r %1
  goto END
Endif

If %1 == "/ln" then 
  LvarEfi64V231.efi /r %1
  goto END
Endif

If %1 == "/mt" then
  LvarEfi64V231.efi /r %1
  goto END
Endif

If %1 == "/pn" then
  LvarEfi64V231.efi /r %1
  LvarEfi64V231.efi /r /fd
  goto END
Endif

If %1 == "/fm" then
  LvarEfi64V231.efi /r /fd
  goto END
Endif

goto END


:END

