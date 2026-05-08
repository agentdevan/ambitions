#!/usr/bin/env python3
"""ACX Accessibility Packet: generate accessibility proof packet template."""

from __future__ import annotations

import argparse
from pathlib import Path
from typing import Sequence

ROOT = Path(__file__).resolve().parents[2]


def packet(surface: str, changed_files: list[str]) -> str:
    lines = [
        "# ACX Accessibility Proof Packet",
        "",
        f"Surface: {surface}",
        "",
        "## Changed files",
    ]
    lines.extend(f"- {item}" for item in changed_files) if changed_files else lines.append("- Not supplied")
    lines.extend([
        "",
        "## Required checks",
        "- VoiceOver order:",
        "- Dynamic Type behavior:",
        "- Reduce Motion equivalent:",
        "- Tap target risks:",
        "- Color-only meaning check:",
        "- Motion-only meaning check:",
        "- Privacy/redaction readability:",
        "- Known limitations:",
        "- Human/device follow-up:",
        "",
        "## Claims not made",
        "- Public accessibility conformance unless supported by dedicated proof.",
        "- Device verification unless supported by physical-device evidence.",
        "- Release readiness.",
    ])
    return "\n".join(lines) + "\n"


def main(argv: Sequence[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Generate accessibility proof packet template.")
    parser.add_argument("surface")
    parser.add_argument("files", nargs="*")
    parser.add_argument("--write")
    args = parser.parse_args(argv)
    text = packet(args.surface, args.files)
    if args.write:
        target = (ROOT / args.write).resolve()
        try:
            target.relative_to(ROOT)
        except ValueError:
            print("Red: refusing to write outside repo root.")
            return 2
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(text, encoding="utf-8")
        print(f"Wrote {target.relative_to(ROOT)}")
    else:
        print(text)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
