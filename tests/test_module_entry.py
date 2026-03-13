from __future__ import annotations

import runpy

import pytest

import spiflash.cli as cli


def test_module_entry_calls_cli_main(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setattr(cli, "main", lambda: 0)

    with pytest.raises(SystemExit) as exc:
        runpy.run_module("spiflash.__main__", run_name="__main__")

    assert exc.value.code == 0
