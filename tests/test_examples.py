"""Smoke tests for the ported examples: every one renders offscreen."""

from __future__ import annotations

import subprocess
import sys
from pathlib import Path

import pytest

ROOT = Path(__file__).resolve().parents[1]
EXAMPLES = [
    "hello",
    "todo",
    "settings",
    "notes",
    "dashboard",
    "assistant",
    "mail",
    "music",
    "tracker",
    "finance",
    "caffeine",
]


@pytest.mark.parametrize("name", EXAMPLES)
def test_example_renders_offscreen(name: str, tmp_path: Path) -> None:
    path = tmp_path / f"{name}.png"
    result = subprocess.run(
        [sys.executable, str(ROOT / "examples" / f"{name}.py"), "--shot", str(path)],
        cwd=ROOT,
        capture_output=True,
        text=True,
    )
    assert result.returncode == 0, result.stderr or result.stdout
    assert "DrawData" in result.stdout
    assert path.stat().st_size > 1000
