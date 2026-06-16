#!/usr/bin/env python3
"""Batch 15: report-driven surface-language cleanup.

This batch removes the highest-friction internal/testing vocabulary from the
top-level production surfaces without touching generated artifacts, tests, or
runtime implementation internals.
"""

from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]

TARGETS = [
    "Native/Ambitions/Features/Goals/GoalsScreen.swift",
    "Native/Ambitions/Features/Goals/GoalComponents.swift",
    "Native/Ambitions/Features/Time/TimeScreen.swift",
    "Native/Ambitions/Features/Time/TimeLifeShapeField.swift",
    "Native/Ambitions/Features/Motion/MotionCurrentScreen.swift",
    "Native/Ambitions/Features/You/YouScreen.swift",
    "Native/Ambitions/Features/You/YouRootSurface.swift",
]

REPLACEMENTS = {
    # Today / closure vocabulary
    "Source unavailable. Manual planning still works.": "Context is light. You can still choose the next step.",
    "Source unavailable": "Context is light",
    "Review source": "Review context",
    "Close Today": "Record outcome",
    "Close the loop": "Record outcome",
    "Closure diamond": "Outcome",
    "Receipt preview": "After saving",
    "No silent changes": "Review before changes",

    # Time / shaping vocabulary
    "Review before reflow": "Preview changes",
    "Reflow preview": "Change preview",
    "reflow preview": "change preview",
    "reflow": "reshape",
    "Reflow": "Reshape",
    "Not root navigation": "Open from Time",

    # Motion / debug vocabulary
    "Open seam": "Open path",
    "Receipt path": "Review path",
    "Return point": "Return",
    "Re-enter thread": "Open thread",
    "re-entry thread": "return path",
    "Re-entry lane": "Return lane",
    "Proof lane": "History lane",
    "Recovery lane": "Recovery path",

    # You / diagnostics vocabulary
    "runtime-backed": "on-device",
    "Runtime-backed": "On-device",
    "fixture-only": "preview",
    "Fixture-only": "Preview",
    "blocked-pending-model": "pending",
    "Blocked-pending-model": "Pending",
    "correction-shaped ledger": "correction history",
    "Correction-shaped ledger": "Correction history",

    # Exact visible labels
    "\"Source\"": "\"Context\"",
    "\"Receipt\"": "\"Review\"",
    "\"Proof\"": "\"History\"",
    "\"source\"": "\"context\"",
    "\"receipt\"": "\"review\"",
    "\"proof\"": "\"history\"",

    # Common visible compounds
    "Source / proof / receipt": "Context / history / review",
    "Source/proof/receipt": "Context/history/review",
    "source/proof/receipt": "context/history/review",
    "Source, proof, and receipt": "Context, history, and review",
    "source, proof, and receipt": "context, history, and review",
    "Source and proof": "Context and history",
    "source and proof": "context and history",
    "Source freshness": "Context freshness",
    "source freshness": "context freshness",
    "Receipt rows": "Review rows",
    "receipt rows": "review rows",
    "Receipt saved": "Saved",
    "receipt saved": "saved",
}

BLOCKED_VISIBLE_TERMS = [
    "Source unavailable",
    "Review source",
    "Closure diamond",
    "Receipt preview",
    "No silent changes",
    "Review before reflow",
    "Not root navigation",
    "Receipt path",
    "runtime-backed",
    "fixture-only",
    "blocked-pending-model",
    "correction-shaped ledger",
]


def rewrite_file(path: Path) -> bool:
    original = path.read_text(encoding="utf-8")
    rewritten = original
    for old, new in REPLACEMENTS.items():
        rewritten = rewritten.replace(old, new)
    if rewritten != original:
        path.write_text(rewritten, encoding="utf-8")
        return True
    return False


def main() -> int:
    changed: list[str] = []
    missing_targets: list[str] = []

    for rel in TARGETS:
        path = ROOT / rel
        if not path.exists():
            missing_targets.append(rel)
            continue
        if rewrite_file(path):
            changed.append(rel)

    failures: list[str] = []
    for rel in TARGETS:
        path = ROOT / rel
        if not path.exists():
            continue
        text = path.read_text(encoding="utf-8")
        for term in BLOCKED_VISIBLE_TERMS:
            if term in text:
                failures.append(f"{rel}: {term}")

    proof = ROOT / "artifacts/release-recovery/REPORT_LANGUAGE_PASS.md"
    proof.parent.mkdir(parents=True, exist_ok=True)
    proof.write_text(
        "# Report Language Pass\n\n"
        "Status: applied.\n\n"
        "Scope: Goals, Time, Motion, and You production surfaces.\n\n"
        "Removed or replaced user-facing instances of the highest-friction internal vocabulary called out by the testing report.\n\n"
        "Changed files:\n"
        + "".join(f"- {item}\n" for item in changed)
        + "\nMissing optional targets:\n"
        + ("".join(f"- {item}\n" for item in missing_targets) if missing_targets else "- none\n"),
        encoding="utf-8",
    )

    if failures:
        raise RuntimeError("Report-language blockers remain:\n" + "\n".join(failures))

    print("Applied Batch 15 report surface-language cleanup.")
    for item in changed:
        print(f"- {item}")
    if not changed:
        print("- no source changes required")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())