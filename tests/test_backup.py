from __future__ import annotations

from pathlib import Path

from spiflash.backup import BackupRegistry


def test_backup_registry_roundtrip(tmp_path: Path) -> None:
    dump = tmp_path / "ec_spi_backup.bin"
    dump.write_bytes(b"abc123")

    registry = BackupRegistry.load(tmp_path)
    entry = registry.add(dump, chip="W25Q64JW", target="ec_spi")
    registry.save(tmp_path)

    loaded = BackupRegistry.load(tmp_path)
    latest = loaded.latest("ec_spi")

    assert latest is not None
    assert latest.filename == dump.name
    assert latest.sha256 == entry.sha256
