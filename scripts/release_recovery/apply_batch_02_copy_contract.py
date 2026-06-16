#!/usr/bin/env python3
"""Batch 02: production copy cleanup."""

from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
TARGET_PREFIXES = (
    "Native/Ambitions/App/",
    "Native/Ambitions/Features/",
    "Sources/Accessibility/",
    "Sources/Components/",
)
EXCLUDED_PARTS = {".git", ".build", "DerivedData", "artifacts", "build", "__pycache__", "PreviewSupport", "Previews", "Tests", "UITests"}
REPLACEMENTS = (
    ("receipt seam", "review history"),
    ("Receipt seam", "Review history"),
    ("route reveal", "suggested path"),
    ("Route reveal", "Suggested path"),
    ("replay trace", "review path"),
    ("Replay trace", "Review path"),
    ("no silent changes", "changes stay reviewable"),
    ("No silent changes", "Changes stay reviewable"),
    ("runtime-backed", "on-device"),
    ("Runtime-backed", "On-device"),
    ("fixture-only", "example"),
    ("blocked-pending-model", "pending"),
    ("not root navigation", "context stays together"),
    ("Not root navigation", "Context stays together"),
)


def should_scan(path: Path) -> bool:
    if path.suffix != ".swift":
        return False
    if any(part in EXCLUDED_PARTS for part in path.parts):
        return False
    rel = path.relative_to(ROOT).as_posix()
    return rel.startswith(TARGET_PREFIXES)


def main() -> int:
    changed = []
    for path in sorted(ROOT.rglob("*.swift")):
        if not should_scan(path):
            continue
        original = path.read_text(encoding="utf-8")
        updated = original
        for old, new in REPLACEMENTS:
            updated = updated.replace(old, new)
        if updated != original:
            path.write_text(updated, encoding="utf-8")
            changed.append(path.relative_to(ROOT).as_posix())
    print("Applied Batch 02 copy cleanup.")
    for item in changed:
        print(f"- {item}")
    if not changed:
        print("- no source changes required")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
