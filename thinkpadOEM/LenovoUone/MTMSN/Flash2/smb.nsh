@echo -off
##### Changes #####
# v1.1.0: remove error detect in flash family, which is not needed.
#
###################

@echo -on
@echo version v1.1.0
set BIOS_PROCESS %0

if x%1 == x"" then
  echo Missing one or more parameters.
  goto err
endif

set BIOS_PARAMETER %1

#
# Flash System Machine Type and Model Number
#
set SMB_NSH "Flash System Machine Type and Model Number"
MfgGetString.efi %1 "Machine Type or MTM" "SMB_NSH_MTM" -nv

if not %lasterror% == 0 then
  goto err
endif

if "x%SMB_NSH_MTM%" == "x" then
  goto SSN
endif

#
# Type 1, System Product Name.
#
ShellFlash64.efi /dps "%SMB_NSH_MTM%" /patch /exit /nodelay /silent /nowarn

if not %lasterror% == 0 then
  goto err
endif

#
# Flash System Serial Number
#
:SSN
set SMB_NSH "Flash System Serial Number"
MfgGetString.efi %1 "System Serial Number" "SMB_NSH_SSN" -nv

if not %lasterror% == 0 then
  goto err
endif

if "x%SMB_NSH_SSN%" == "x" then
  goto CSN
endif

#
# Type 1, System Serial Number.
#
ShellFlash64.efi /dss "%SMB_NSH_SSN%" /patch /exit /nodelay /silent /nowarn

if not %lasterror% == 0 then
  goto err
endif

#
# Flash Chassis Serial Number
#
:CSN
set SMB_NSH "Flash Chassis Serial Number"
MfgGetString.efi %1 "Chassis Serial Number" "SMB_NSH_CSN" -nv

if not %lasterror% == 0 then
  goto err
endif

if "x%SMB_NSH_CSN%" == "x" then
  goto BRID
endif

#
# Type 3, Chassis Serial Number.
#
ShellFlash64.efi /dsc "%SMB_NSH_CSN%" /patch /exit /nodelay /silent /nowarn

if not %lasterror% == 0 then
  goto err
endif

#
# Flash System Brand ID
#
:BRID
set SMB_NSH "Flash System Brand ID"
MfgGetString.efi %1 "Brand ID or Product Name" "SMB_NSH_BRID" -nv

if not %lasterror% == 0 then
  goto err
endif

if "x%SMB_NSH_BRID%" == "x" then
  goto FMLY
endif

#
# Type 1, System Version.
#
ShellFlash64.efi /dvs "%SMB_NSH_BRID%" /patch /exit /nodelay /silent /nowarn

if not %lasterror% == 0 then
  goto err
endif

#
# Flash Family
#
:FMLY
set SMB_NSH "Flash Family"
MfgGetString.efi %1 "SMBIOS Family" "SMB_NSH_FMLY" -nv

if not %lasterror% == 0 then
  goto err
endif
 
if "x%SMB_NSH_FMLY%" == "x" then

if "x%SMB_NSH_BRID%" == "x" then
  goto ASTAG
endif

  ShellFlash64.efi /dfs "%SMB_NSH_BRID%" /patch /exit /nodelay /silent /nowarn
  #
  # Type 1, Syatem Family.
  #

   if not %lasterror% == 0 then
   goto err
   endif
   
  goto ASTAG
endif

ShellFlash64.efi /dfs "%SMB_NSH_FMLY%" /patch /exit /nodelay /silent /nowarn

if not %lasterror% == 0 then
  goto err
endif

#
# Flash Chassis Asset Tag
#
:ASTAG
set SMB_NSH "Flash Chassis Asset Tag"
MfgGetString.efi %1 "Asset Tag" "SMB_NSH_ASTAG" -nv

if not %lasterror% == 0 then
  goto err
endif

if "x%SMB_NSH_ASTAG%" == "x" then
  goto OSINFO
endif

#
# Type 3, Chassis Asset Tag.
#
ShellFlash64.efi /dpc "%SMB_NSH_ASTAG%" /patch /exit /nodelay /silent /nowarn

if not %lasterror% == 0 then
  goto err
endif

#
# Flash Base Board Version
#
:OSINFO
set SMB_NSH "Flash Base Board Version"
MfgGetString.efi %1 "OA3 Information" "SMB_NSH_OSINFO" -nv

if not %lasterror% == 0 then
  goto err
endif

if "x%SMB_NSH_OSINFO%" == "x" then
  goto UUID
endif

#
# Type 2, Baseboard Version.
#
ShellFlash64.efi /dvm "%SMB_NSH_OSINFO%" /patch /exit /nodelay /silent /nowarn

if not %lasterror% == 0 then
  goto err
endif


#
# Flash CPU identification (Type 11 string 6)
#
:CPUID
set SMB_NSH "Flash CPU identification"
MfgGetString.efi %1 "CPU identification" "SMB_NSH_CPUID" -nv

if not %lasterror% == 0 then
  goto err
endif

if "x%SMB_NSH_CPUID%" == "x" then
  goto UUID
endif

#
# Type 11, OEM String 6.
#
ShellFlash64.efi /dos 6 "%SMB_NSH_CPUID%" /patch /exit /nodelay /silent /nowarn

if not %lasterror% == 0 then
  goto err
endif


#
# Flash System UUID
#
:UUID
set SMB_NSH "Flash System UUID"

#
# Type 1, System UUID.
#
ShellFlash64.efi /dus /patch /exit /nodelay /silent /nowarn

if not %lasterror% == 0 then
  goto err
endif

goto end

:err
exit /b 0xc000000000000001

:end
if %lasterror% == 0 then
  set -d SMB_NSH
  set -d SMB_NSH_MTM
  set -d SMB_NSH_SSN
  set -d SMB_NSH_CSN
  set -d SMB_NSH_BRID
  set -d SMB_NSH_FMLY
  set -d SMB_NSH_ASTAG
  set -d SMB_NSH_OSINFO
  set -d SMB_NSH_CPUID
  exit /b 0
endif
