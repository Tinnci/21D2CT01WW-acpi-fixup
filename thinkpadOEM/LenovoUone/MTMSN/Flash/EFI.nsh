If %2 == "/uu" then
  ODMTools\EFI\ShellFlash64.efi /patch /dus %3 /exit
Endif

If %2 == "/ln" then 
  ODMTools\EFI\ShellFlash64.efi /patch /dsm %3 /exit
Endif

If %2 == "/mt" then
  ODMTools\EFI\ShellFlash64.efi /patch /dps %3 /exit
Endif

If %2 == "/pn" then
  ODMTools\EFI\ShellFlash64.efi /patch /dvs %3 /exit
Endif