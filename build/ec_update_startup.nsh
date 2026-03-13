@echo -off

echo ""
echo "======================================================="
echo "  ThinkPad Z13 Gen 1 -- EC ONLY Firmware Update v3"
echo "  Target EC: N3GHT69W (v6.9)"
echo "  !! BIOS / Main SPI will NOT be touched !!"
echo "======================================================="
echo ""
echo "  FlashCommand parameters:"
echo "    ECFW Update"
echo "    Skip part number checking"
echo "    Skip ECFW image check"
echo "    Skip Battery check"
echo "    Skip AC Adapter check"
echo "======================================================="
echo ""
echo "Press any key to ABORT, or wait 10 seconds to start..."
echo ""

stall 10000000

echo ""
echo "[STEP 1] Trying fs0:\Flash\NoDCCheck_BootX64.efi ..."
echo ""

if exist fs0:\Flash\NoDCCheck_BootX64.efi then
  fs0:\Flash\NoDCCheck_BootX64.efi "ECFW Update" "Skip part number checking" "Skip ECFW image check" "Skip Battery check" "Skip AC Adapter check"
  goto DONE
endif

echo "[STEP 2] Trying fs1:\Flash\NoDCCheck_BootX64.efi ..."
echo ""

if exist fs1:\Flash\NoDCCheck_BootX64.efi then
  fs1:\Flash\NoDCCheck_BootX64.efi "ECFW Update" "Skip part number checking" "Skip ECFW image check" "Skip Battery check" "Skip AC Adapter check"
  goto DONE
endif

echo "[STEP 3] Trying fs2:\Flash\NoDCCheck_BootX64.efi ..."
echo ""

if exist fs2:\Flash\NoDCCheck_BootX64.efi then
  fs2:\Flash\NoDCCheck_BootX64.efi "ECFW Update" "Skip part number checking" "Skip ECFW image check" "Skip Battery check" "Skip AC Adapter check"
  goto DONE
endif

echo "[STEP 4] Trying fs3:\Flash\NoDCCheck_BootX64.efi ..."
echo ""

if exist fs3:\Flash\NoDCCheck_BootX64.efi then
  fs3:\Flash\NoDCCheck_BootX64.efi "ECFW Update" "Skip part number checking" "Skip ECFW image check" "Skip Battery check" "Skip AC Adapter check"
  goto DONE
endif

echo ""
echo "[ERROR] NoDCCheck_BootX64.efi not found on fs0: to fs3:"
echo "        Please run manually:"
echo "          fsX:\Flash\NoDCCheck_BootX64.efi"
echo "            \"ECFW Update\""
echo "            \"Skip part number checking\""
echo "            \"Skip ECFW image check\""
echo "            \"Skip Battery check\""
echo "            \"Skip AC Adapter check\""
echo ""

:DONE
echo ""
echo "======================================================="
echo "  Script finished."
echo "  If EC update started -> wait for automatic reboot."
echo ""
echo "  Common errors:"
echo "    signed ECFW image only   -> needs CH341A physical flash"
echo "    unsigned ECFW image only -> good, no signature check"
echo "    Failed to initialize SMI -> needs CH341A physical flash"
echo "======================================================="
echo ""
pause
