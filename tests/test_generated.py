"""The generated layer stays in sync with CUI's headers."""

from __future__ import annotations

import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent


def test_generated_files_are_up_to_date():
    result = subprocess.run(
        [sys.executable, str(ROOT / "tools" / "gen_cui.py"), "--check"],
        capture_output=True,
        text=True,
        cwd=ROOT,
    )
    assert result.returncode == 0, result.stderr or result.stdout


def test_coverage_report_exists():
    report = (ROOT / "src" / "cui" / "_gen" / "COVERAGE.md").read_text(encoding="utf-8")
    assert "callable CUI functions" in report
    assert "## Not wrapped yet" in report


def test_wrapped_api_is_importable_and_documented():
    import cui._api as api

    functions = [name for name in dir(api) if not name.startswith("_")]
    assert len(functions) > 300
    for name in ("button", "switch", "input", "select", "tabs", "heading", "text"):
        assert hasattr(api, name), name
