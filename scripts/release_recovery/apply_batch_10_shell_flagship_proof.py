#!/usr/bin/env python3
from __future__ import annotations
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
ADAPTER = ROOT / "Native/Ambitions/App/ShellChromeFlagshipAdapter.swift"
SHELL = ROOT / "Native/Ambitions/App/AppShellView.swift"
MARKER = "shell.flagship.chrome.header"


def need(path: Path, markers: list[str]) -> None:
    text = path.read_text(encoding="utf-8")
    missing = [marker for marker in markers if marker not in text]
    if missing:
        raise RuntimeError(f"{path.relative_to(ROOT)} missing {missing}")


def main() -> int:
    text = SHELL.read_text(encoding="utf-8")
    if MARKER not in text:
        anchor = "                )\n"
        index = text.find("                AppShellHeaderRail(")
        if index == -1:
            raise RuntimeError("shell header anchor missing")
        end = text.find(anchor, index)
        if end == -1:
            raise RuntimeError("shell header close anchor missing")
        insert_at = end + len(anchor)
        text = text[:insert_at] + "                .accessibilityIdentifier(\"" + MARKER + "\")\n" + text[insert_at:]
        SHELL.write_text(text, encoding="utf-8")
    need(ADAPTER, ["ShellChromeFlagshipAdapter", "FlagshipRuntimeStage(", "dynamicTypeSize", "accessibilityReduceMotion", "shell.flagship.chrome"])
    need(SHELL, [MARKER])
    print("Applied Batch 10 shell flagship proof capsule.")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
