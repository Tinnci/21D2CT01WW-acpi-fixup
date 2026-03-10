@echo -off
if .%2 == . then 
ODMTools\EFI\NovoUefix64.efi %1
else 
if .%3 == . then 
ODMTools\EFI\NovoUefix64.efi %1 %2 
else
ODMTools\EFI\NovoUefix64.efi %1 %2 %3
endif
endif