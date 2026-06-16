#!/usr/bin/env python3
"""Batch 28: repair Motion re-entry acceptance copy.

The report screenshot proof is now fail-closed. AMB-965 correctly requires the
Motion re-entry render state to expose the user-facing phrase
`Re-entry available` so the top-level Motion surface reads as an actionable
return point rather than a generic return label.

This batch is intentionally narrow and idempotent:
- no test weakening
- no workflow mutation
- no source/proof/receipt language expansion
- no visual primitive churn
"""

from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
MOTION_SCREEN = ROOT / "Native" / "Ambitions" / "Features" / "Motion" / "MotionCurrentScreen.swift"
REPORT = ROOT / "artifacts" / "release-recovery" / "REPORT_BATCH_28_MOTION_REENTRY_ACCEPTANCE_COPY.md"


def replace_once_or_confirm(text: str, old: str, new: str, label: str) -> tuple[str, str]:
    if new in text and old not in text:
        return text, f"- {label}: already green; `{new}` present and stale `{old}` absent."
    if old not in text:
        raise RuntimeError(f"Batch 28 marker missing for {label}: {old!r}")
    return text.replace(old, new), f"- {label}: replaced `{old}` with `{new}`."


def main() -> int:
    text = MOTION_SCREEN.read_text(encoding="utf-8")
    notes: list[str] = []

    text, note = replace_once_or_confirm(
        text,
        'title: "Return available",',
        'title: "Re-entry available",',
        "re-entry lane item title"
    )
    notes.append(note)

    text, note = replace_once_or_confirm(
        text,
        'title: "Return available"\n',
        'title: "Re-entry available"\n',
        "re-entry field title"
    )
    notes.append(note)

    required = [
        "Re-entry available",
        "Last honest point",
        "Start again",
        "motion.current.action.reenter-thread",
    ]
    missing = [marker for marker in required if marker not in text]
    if missing:
        raise RuntimeError(f"Batch 28 acceptance markers missing after patch: {missing}")

    MOTION_SCREEN.write_text(text, encoding="utf-8")

    REPORT.parent.mkdir(parents=True, exist_ok=True)
    REPORT.write_text(
        "# Batch 28 — Motion Re-entry Acceptance Copy\n\n"
        "Status: applied\n\n"
        "## Scope\n\n"
        "Narrow repair for the fail-closed AMB-965 screenshot gate. The screenshot proof failed because the Motion re-entry render state exposed `Return available` while the acceptance contract requires `Re-entry available`.\n\n"
        "## Changes\n\n"
        + "\n".join(notes)
        + "\n\n## Acceptance markers\n\n"
        + "\n".join(f"- `{marker}`" for marker in required)
        + "\n\n## Guardrails\n\n"
        "- Does not weaken AMB-965.\n"
        "- Does not edit GitHub workflow files.\n"
        "- Does not introduce broad visual churn.\n"
        "- Preserves the existing Motion action identifier `motion.current.action.reenter-thread`.\n",
        encoding="utf-8",
    )

    print("Applied Batch 28 Motion re-entry acceptance copy repair.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
