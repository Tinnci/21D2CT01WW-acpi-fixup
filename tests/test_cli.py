from __future__ import annotations

import pytest

from spiflash.cli import main


def test_cli_without_subcommand_returns_zero(capsys: pytest.CaptureFixture[str]) -> None:
    rc = main([])
    out = capsys.readouterr().out

    assert rc == 0
    assert "usage:" in out


def test_cli_help_exits_zero() -> None:
    with pytest.raises(SystemExit) as exc:
        main(["--help"])

    assert exc.value.code == 0
