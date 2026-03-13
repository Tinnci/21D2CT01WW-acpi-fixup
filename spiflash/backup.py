"""备份管理 — SHA256 跟踪、备份历史。"""

from __future__ import annotations

import hashlib
import json
from dataclasses import asdict, dataclass, field
from datetime import datetime, timezone
from pathlib import Path
from typing import Optional


@dataclass
class BackupEntry:
    """一次备份记录。"""

    filename: str
    sha256: str
    size: int
    chip: str
    timestamp: str
    target: str  # "main_spi" 或 "ec_spi"
    notes: Optional[str] = None


@dataclass
class BackupRegistry:
    """备份注册表 — 管理所有 SPI dump 的 SHA256 历史。"""

    entries: list[BackupEntry] = field(default_factory=list)

    REGISTRY_NAME = "spi_backup_registry.json"

    @classmethod
    def load(cls, directory: Path) -> BackupRegistry:
        reg_path = directory / cls.REGISTRY_NAME
        if reg_path.exists():
            data = json.loads(reg_path.read_text())
            entries = [BackupEntry(**e) for e in data.get("entries", [])]
            return cls(entries=entries)
        return cls()

    def save(self, directory: Path) -> None:
        reg_path = directory / self.REGISTRY_NAME
        directory.mkdir(parents=True, exist_ok=True)
        data = {"entries": [asdict(e) for e in self.entries]}
        reg_path.write_text(json.dumps(data, indent=2, ensure_ascii=False))

    def add(
        self,
        file_path: Path,
        chip: str,
        target: str,
        notes: Optional[str] = None,
    ) -> BackupEntry:
        data = file_path.read_bytes()
        sha256 = hashlib.sha256(data).hexdigest()

        entry = BackupEntry(
            filename=file_path.name,
            sha256=sha256,
            size=len(data),
            chip=chip,
            timestamp=datetime.now(timezone.utc).isoformat(),
            target=target,
            notes=notes,
        )
        self.entries.append(entry)
        return entry

    def find_by_sha256(self, sha256: str) -> Optional[BackupEntry]:
        for e in self.entries:
            if e.sha256 == sha256:
                return e
        return None

    def latest(self, target: Optional[str] = None) -> Optional[BackupEntry]:
        filtered = self.entries
        if target:
            filtered = [e for e in filtered if e.target == target]
        return filtered[-1] if filtered else None
