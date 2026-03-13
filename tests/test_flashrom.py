from __future__ import annotations

from pathlib import Path

import pytest

from spiflash.flashrom import ChipInfo, FlashResult, Flashrom, FlashromError


def test_build_cmd_with_chip() -> None:
    fr = Flashrom(chip="W25Q64JW", flashrom_bin="/usr/local/bin/flashrom", use_sudo=False)
    cmd = fr._build_cmd("-r", "dump.bin")
    assert cmd == ["/usr/local/bin/flashrom", "-p", "ch341a_spi", "-c", "W25Q64JW", "-r", "dump.bin"]


def test_voltage_warning_for_1v8_chip() -> None:
    fr = Flashrom(flashrom_bin="/usr/local/bin/flashrom", use_sudo=False)
    warning = fr.check_voltage_warning(ChipInfo(name="W25Q64JW", size_kb=8192))
    assert warning is not None
    assert "1.8V" in warning


def test_probe_parses_flashrom_output(monkeypatch: pytest.MonkeyPatch) -> None:
    fr = Flashrom(flashrom_bin="/usr/local/bin/flashrom", use_sudo=False)

    def fake_run(*_args: str, **_kwargs: int) -> FlashResult:
        out = 'Found Winbond flash chip "W25Q64JW" (8192 kB, SPI) on ch341a_spi.\nRDID returned 0xEF 80 17\n'
        return FlashResult(True, [], out, "", 0)

    monkeypatch.setattr(fr, "_run", fake_run)

    chips = fr.probe()
    assert len(chips) == 1
    assert chips[0].name == "W25Q64JW"
    assert chips[0].size_kb == 8192
    assert chips[0].jedec_id is not None


def test_read_verified_detects_mismatch(tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> None:
    fr = Flashrom(chip="W25Q64JW", flashrom_bin="/usr/local/bin/flashrom", use_sudo=False)

    calls = {"n": 0}

    def fake_read(path: Path) -> FlashResult:
        calls["n"] += 1
        path.write_bytes(b"abc" if calls["n"] == 1 else b"xyz")
        return FlashResult(
            success=True,
            command=[],
            stdout="",
            stderr="",
            returncode=0,
            output_file=path,
            sha256="sha1" if calls["n"] == 1 else "sha2",
        )

    monkeypatch.setattr(fr, "read", fake_read)

    with pytest.raises(FlashromError):
        fr.read_verified(tmp_path / "dump.bin")
