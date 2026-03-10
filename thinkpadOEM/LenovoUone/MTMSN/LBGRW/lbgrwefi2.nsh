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
  LBGRW.efi /s UU "%CandidatesUUID%"
  goto END
Endif

If %1 == "/ln" then 
  LBGRW.efi /s LS %2
  goto END
Endif

If %1 == "/mt" then
  LBGRW.efi /s MT %2
  goto END
Endif

If %1 == "/pn" then
  LBGRW.efi /s PN %2
  goto END
Endif

goto END

:Readit

If %1 == "/uu" then
  LBGRW.efi /R UU
  goto END
Endif

If %1 == "/ln" then 
  LBGRW.efi /R LS
  goto END
Endif

If %1 == "/mt" then
  LBGRW.efi /R MT
  goto END
Endif

If %1 == "/pn" then
  LBGRW.efi /R PN
  goto END
Endif

goto END

:END
