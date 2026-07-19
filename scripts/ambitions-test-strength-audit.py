#!/usr/bin/env python3
from __future__ import annotations

import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TEST_ROOTS = [ROOT / "Native" / "AmbitionsTests", ROOT / "Native" / "AmbitionsUITests"]

VISUAL_TERMS = ("visual", "swiftui", "lifeshapefieldview", "reconstruction", "flagship")
RENDERED_TERMS = ("XCUIApplication", ".frame", "screenshot", "XCUIScreenshot", "addAttachment")


def changed_paths() -> set[str]:
    result = subprocess.run(
        ["git", "diff", "--name-only", "HEAD", "--"],
        cwd=ROOT,
        check=False,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    paths = set(result.stdout.splitlines())
    status = subprocess.run(
        ["git", "status", "--porcelain"],
        cwd=ROOT,
        check=False,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    for line in status.stdout.splitlines():
        if line:
            paths.add(line[3:].strip())
    return paths


def main() -> int:
    findings: list[str] = []
    changed = changed_paths()
    changed_texts: list[tuple[str, str]] = []

    for root in TEST_ROOTS:
        if not root.exists():
            continue
        for path in root.rglob("*.swift"):
            relative = path.relative_to(ROOT).as_posix()
            if relative not in changed:
                continue
            text = path.read_text(encoding="utf-8", errors="replace")
            changed_texts.append((relative, text))

    has_rendered_visual_proof = any(
        any(term in f"{relative}\n{text}".lower() for term in VISUAL_TERMS) and
        any(term in text for term in RENDERED_TERMS)
        for relative, text in changed_texts
    )

    for relative, text in changed_texts:
            lower = relative.lower()
            if not any(term in lower for term in VISUAL_TERMS):
                continue
            source_only = ".contains(" in text or re.search(r"\bsource\s*\(", text) is not None
            rendered = any(term in text for term in RENDERED_TERMS)
            if source_only and not rendered and not has_rendered_visual_proof:
                findings.append(relative)

    if findings:
        print("ambitions-test-strength-audit RED")
        for finding in findings:
            print(f"- {finding}: source-string visual proof without rendered UI/frame/screenshot evidence")
        return 1

    print("ambitions-test-strength-audit GREEN")
    return 0


if __name__ == "__main__":
    sys.exit(main())
