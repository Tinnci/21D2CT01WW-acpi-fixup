#bcfg boot add 3 %CTL_DRV%\%MTSN%\Helix\bootx64.efi "ThinkPad Maintenance Utilities"

#cls
#message6.nsh
#pause

cls
%CTL_DRV%\message.nsh
echo =   
echo =   This ThinkPad is not supported by current U1 tool.  Please download
echo =   ThinkPad Maintenance Utility from Lenovo Support website to flash
echo =   SN/MT/PN/UUID:
echo =   "https://support.lenovo.com/us/en/downloads/DS102472"
echo =   or short URL -> https://tinyurl.com/ycgf5cjs 
pause
