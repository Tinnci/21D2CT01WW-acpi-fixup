if %1 == "/w" then 
goto SetFunc
else
goto ErrCmd

:SetFunc
if %2 == "/uu" then 
goto SetUU
else
if %2 == "/ln" then 
goto SetLS
else
if %2 == "/mt" then 
goto SetMT
else
if %2 == "/pn" then 
goto SetPN
else
goto ErrCmd

:SetUU
.\ODMTools\EFI\LBGRW.efi /s UU %3
endif
goto End

:SetLS
.\ODMTools\EFI\LBGRW.efi /s LS %3
endif
goto End

:SetMT
.\ODMTools\EFI\LBGRW.efi /s MT %3
endif
goto End

:SetPN
.\ODMTools\EFI\LBGRW.efi /s PN %3
endif
goto End

:ErrCmd
echo Invalid Command

:End
endif