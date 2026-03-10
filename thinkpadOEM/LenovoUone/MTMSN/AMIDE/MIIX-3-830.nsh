echo -off
cls
If %1 == "/uu" then
  AMIDEEFI_514.efi /SU AUTO
    goto END
Endif

If %1 == "/ln" then 
  AMIDEEFI_514.efi /BS %2
  goto END
Endif

If %1 == "/mt" then
  AMIDEEFI_514.efi /SK %2
  goto END
Endif

If %1 == "/pn" then
  AMIDEEFI_514.efi /SP "Lenovo Miix 3-830"
  goto END
Endif

goto END


:END
cd \
echo ===============================================================================
echo " Lenovo Golden Key - U1 Tool for  Lenovo Miix 3-830"
echo ===============================================================================
H1AMIDE.nsh



