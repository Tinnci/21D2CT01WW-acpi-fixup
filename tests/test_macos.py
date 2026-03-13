from __future__ import annotations

import subprocess
from types import SimpleNamespace

import pytest

import spiflash.macos as macos


def test_find_ch341a_from_system_profiler(monkeypatch: pytest.MonkeyPatch) -> None:
    sample = """
USB UART-LPT:

  Product ID: 0x5512
  Vendor ID: 0x1a86
  Serial Number: 1234
  Location ID: 0x01100000
"""

    monkeypatch.setattr(macos, "is_macos", lambda: True)
    monkeypatch.setattr(
        subprocess,
        "run",
        lambda *args, **kwargs: SimpleNamespace(stdout=sample),
    )

    dev = macos.find_ch341a()
    assert dev is not None
    assert dev.vendor_id.lower() == "0x1a86"
    assert dev.product_id.lower() == "0x5512"


def test_check_prerequisites_reports_missing(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setattr(macos, "is_macos", lambda: True)
    monkeypatch.setattr(macos, "find_ch341a", lambda: None)
    monkeypatch.setattr(macos, "check_usb_serial_conflict", lambda: None)
    monkeypatch.setattr(macos, "is_root", lambda: False)

    import shutil

    monkeypatch.setattr(shutil, "which", lambda _name: None)

    issues = macos.check_prerequisites()
    assert any("flashrom" in s for s in issues)
    assert any("CH341A" in s for s in issues)
