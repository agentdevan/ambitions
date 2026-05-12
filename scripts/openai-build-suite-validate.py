#!/usr/bin/env python3
"""Policy validation for OBS OpenAI build suite.

Enforces local-first constraints and blocks runtime/secret violations.
"""
from __future__ import annotations

import re
import subprocess
from pathlib import Path
from typing import Iterable

ROOT = Path(__file__).resolve().parents[1]
RELATIVE_ALLOWED = {
    "docs/",
    "tools/openai/",
    "scripts/openai-build-suite-validate.py",
    "scripts/openai-build-suite-dry-run.py",
    "scripts/ambitions-prompt-queue-consistency.py",
    "scripts/ambitions-codex-os-validate.py",
    "prompts/batches/OBS",
    "prompts/ambitions/",
    ".codex/hooks/",
}
OPENAI_REGEXES = [
    re.compile(r"\bimport\s+OpenAI\b"),
    re.compile(r"\bfrom\s+openai\b"),
    re.compile(r"\bOpenAI\b"),
    re.compile(r"\bOPENAI_API_KEY\b"),
]
SECRET_KEYS = [
    re.compile(r"sk-[A-Za-z0-9]{20,}"),
    re.compile(r"sk-proj-[A-Za-z0-9]{20,}"),
]
RUNTIME_RISK = [
    re.compile(r"required\s+for\s+core\s+runtime", re.I),
    re.compile(r"openai\s+dependency\s+in\s+runtime", re.I),
    re.compile(r"required\s+for\s+runtime", re.I),
]


def iter_tracked_files() -> Iterable[Path]:
    proc = subprocess.run(["git", "ls-files"], cwd=ROOT, capture_output=True, text=True)
    if proc.returncode != 0:
        raise RuntimeError("failed to list tracked files")
    for line in proc.stdout.splitlines():
        path = ROOT / line.strip()
        if path.is_file():
            yield path


def is_allowed_openai_mention(path: Path) -> bool:
    text = str(path.relative_to(ROOT).as_posix())
    return any(
        text.startswith(prefix)
        for prefix in [
            *RELATIVE_ALLOWED,
            "docs/audits/",
            "scripts/openai-build-suite-validate.py",
            "scripts/openai-build-suite-dry-run.py",
            "prompts/batches/OBS00-OPENAI-BUILD-SUITE-INSTALL.md",
        ]
    )


def check_file(path: Path, failures: list[str]) -> None:
    try:
        text = path.read_text(encoding="utf-8", errors="ignore")
    except (OSError, UnicodeDecodeError):
        return
    rel = path.relative_to(ROOT).as_posix()

    # Native runtime hard checks
    if rel.startswith("Native/Ambitions/") and any(r.search(text) for r in OPENAI_REGEXES):
        failures.append(f"Runtime OpenAI use in {path}")

    if "OPENAI_API_KEY" in text and not is_allowed_openai_mention(path):
        failures.append(f"OPENAI_API_KEY appears in non-allowed file {path}")

    for expr in SECRET_KEYS:
        if expr.search(text) and not path.as_posix().startswith("docs"):
            failures.append(f"Possible API key in {path}")

    # Docs/runtime claims outside allowed surfaces
    if ("OpenAI" in text or "openai" in text) and not rel.startswith("docs/") and not rel.startswith("tools/openai/"):
        if any(r.search(text) for r in RUNTIME_RISK):
            failures.append(f"Runtime claim in {path} without allowed boundary")


def main() -> int:
    failures: list[str] = []
    for path in iter_tracked_files():
        rel = path.relative_to(ROOT)
        if rel.as_posix().startswith(".codex/runs/"):
            continue
        if rel.as_posix().startswith("output/"):
            continue
        if rel.as_posix().startswith("build/"):
            continue
        if rel.as_posix().startswith("Native/Ambitions/") and rel.suffix is not None:
            pass
        check_file(path, failures)

    if failures:
        print("RED: OpenAI build-suite policy violations")
        for failure in failures:
            print(f"- {failure}")
        return 1

    print("GREEN: openai-build-suite-validate checks passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
