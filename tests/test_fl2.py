from __future__ import annotations

from pathlib import Path

import pytest

from spiflash.fl2 import parse_fl2


@pytest.mark.parametrize(
    "name",
    [
        "N3GHT68W.FL2",
        "N3GHT69W.FL2",
    ],
)
def test_parse_real_fl2(name: str) -> None:
    path = Path("firmware/ec") / name
    if not path.exists():
        pytest.skip(f"missing fixture file: {path}")

    info = parse_fl2(path)

    assert info.size > 0
    assert info.ec1.is_valid
    assert info.payload_size > 0
    assert info.vector_sp != 0
    assert len(info.signature) == 64


def test_extract_payload_size_matches_header() -> None:
    path = Path("firmware/ec/N3GHT68W.FL2")
    if not path.exists():
        pytest.skip(f"missing fixture file: {path}")

    info = parse_fl2(path)
    payload = info.extract_payload()

    assert len(payload) == info.payload_size
