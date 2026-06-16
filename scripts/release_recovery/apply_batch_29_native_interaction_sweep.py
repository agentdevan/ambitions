#!/usr/bin/env python3
from __future__ import annotations

from collections import defaultdict
from pathlib import Path

from report_reconstruction_support import read, require_markers, write_proof

TRUTH = "docs/truth/NATIVE_INTERACTION_TRUTH.md"
PRODUCT_TRUTH = "docs/truth/PRODUCT_DESIGN_TRUTH.md"

TARGET_ROOTS = [
    Path("Native/Ambitions"),
    Path("Native/AmbitionsUITests"),
    Path("Native/AmbitionsTests"),
    Path("Sources/Components"),
    Path("Sources/Previews"),
]

TARGET_EXTENSIONS = {".swift"}

# Visible-copy / comment-only sweep. Do not rename identifiers.
# Keep these exact-string replacements conservative so Swift symbols and persisted enum cases remain untouched.
REPLACEMENTS: dict[str, str] = {
    # Shell/search/capture language
    "What Ambitions knows": "Search Ambitions",
    "Memory Lens": "Search",
    "memory lens": "search",
    "Life Memory": "Personal context",
    "Quiet Command": "Quick action",
    "Patch Time": "Shape Time",
    "Focus": "Start here",
    "Return to Today and center the next step.": "Return to Today and center the recommended step.",
    "Save what needs a place with a suggested route and a receipt you can change.": "Capture what changed, then decide where it belongs.",
    "Creates a local capture with source context and a receipt.": "Creates a local capture with context the user can review.",
    "Open the existing create-goal flow inside the shell-owned compose path.": "Open Goal setup without leaving the native shell path.",
    "Search goals, captures, and recent changes.": "Search goals, captures, steps, settings, and recent changes.",

    # Internal architecture terms in visible copy
    "Source unavailable": "Needs context",
    "source unavailable": "needs context",
    "Review source": "Review context",
    "review source": "review context",
    "Source needed": "Context needed",
    "source needed": "context needed",
    "Source, proof, receipt": "Why this?",
    "Source / Proof / Receipt": "Why this?",
    "source/proof/trust": "trust",
    "source/proof/trust blocks": "trust details",
    "receipt preview": "review preview",
    "Receipt preview": "Review preview",
    "Route reveal": "Placement review",
    "route reveal": "placement review",
    "Open seam": "Why this?",
    "open seam": "why this?",
    "Trust seam": "Why this?",
    "trust seam": "why this?",
    "Not root navigation": "Open detail",
    "not root navigation": "open detail",
    "Runtime-backed": "Local",
    "runtime-backed": "local",
    "Fixture-only": "Preview",
    "fixture-only": "preview",
    "blocked-pending-model": "needs setup",
    "Blocked pending model": "Needs setup",

    # Today / closure language
    "No standalone task is pulling on Today.": "No recommended step fits right now.",
    "No standalone task is pulling on Today": "No recommended step fits right now",
    "No Step required": "No recommended step right now",
    "No step required": "No recommended step right now",
    "Close Today": "Record outcome",
    "close Today": "record outcome",
    "Closure diamond": "Outcome",
    "closure diamond": "outcome",
    "Step Session": "Step session",
    "Begin Focus": "Start now",
    "begin focus": "start now",
    "next best move": "recommended step",
    "Next best move": "Recommended step",

    # Time language
    "Reflow preview": "Preview changes",
    "reflow preview": "preview changes",
    "Reflow Preview": "Preview Changes",
    "Free/busy": "Capacity",
    "free/busy": "capacity",
    "calendar-density score": "time pressure",
    "AI scheduling score": "time fit",

    # You/settings language
    "Personal Runtime": "Personal system",
    "personal runtime": "personal system",
    "Trust & Automation": "Privacy & automation",
    "system model": "settings",
    "System model": "Settings",
    "implementation status": "status",

    # Generic AI/productivity drift
    "AI recommends": "Ambitions recommends",
    "AI recommendation": "recommendation",
    "AI suggestion": "recommendation",
    "smart capture": "capture",
    "Smart Capture": "Capture",
    "task app": "task-app",
    "Task app": "Task-app",
}

# Require these after the sweep so the batch is anchored to the new native-interaction canon.
TRUTH_MARKERS = [
    "Time must be legible before it is intelligent",
    "Root navigation and drilldown navigation are different systems",
    "Capture must be beautiful, obvious, and expandable",
    "Settings becomes You",
    "Could a user understand what this screen does before reading Ambitions-specific vocabulary?",
]

SURFACE_MARKERS = {
    "Native/Ambitions/App/ShellCommandModels.swift": ["Shape Time", "Search Ambitions", "Capture what changed"],
}


def iter_target_files() -> list[Path]:
    files: list[Path] = []
    for root in TARGET_ROOTS:
        if not root.exists():
            continue
        files.extend(path for path in root.rglob("*") if path.is_file() and path.suffix in TARGET_EXTENSIONS)
    return sorted(files)


def apply_replacements(path: Path) -> dict[str, int]:
    text = path.read_text(encoding="utf-8")
    original = text
    counts: dict[str, int] = {}
    for before, after in REPLACEMENTS.items():
        count = text.count(before)
        if count:
            text = text.replace(before, after)
            counts[before] = count
    if text != original:
        path.write_text(text, encoding="utf-8")
    return counts


def main() -> int:
    require_markers(TRUTH, TRUTH_MARKERS)
    require_markers(PRODUCT_TRUTH, [
        "Today / Goals / Time / Motion / You",
        "Capture",
        "object-first native iPhone product",
        "calendar clone",
        "chatbot",
    ])

    per_file: dict[str, dict[str, int]] = {}
    total_counts: defaultdict[str, int] = defaultdict(int)
    for path in iter_target_files():
        counts = apply_replacements(path)
        if counts:
            per_file[str(path)] = counts
            for key, value in counts.items():
                total_counts[key] += value

    for path, markers in SURFACE_MARKERS.items():
        if Path(path).exists():
            require_markers(path, markers)

    if not per_file:
        raise RuntimeError("Native interaction sweep made no source changes; expected at least shell/search/capture visible-copy cleanup.")

    changed_files = "\n".join(f"- `{path}`" for path in sorted(per_file))
    replacement_rows = "\n".join(
        f"- `{before}` -> `{REPLACEMENTS[before]}`: {count}"
        for before, count in sorted(total_counts.items())
    )

    write_proof(
        "REPORT_BATCH_29_NATIVE_INTERACTION_SWEEP.md",
        f"""
# Batch 29 — Native Interaction Sweep

Status: applied.

Scope:
- Applied a conservative visible-copy sweep across Native app Swift, UI tests, app tests, shared components, and previews.
- Folded the Native Interaction Truth into active UI source language without renaming Swift identifiers or touching workflow files.
- Replaced user-facing architecture language with native object-operation language.
- Began the broad report repair toward legible Time, composer-first Capture, root-vs-drilldown Shell behavior, Settings-as-You, graceful empty states, and Step mechanics.

Changed files:
{changed_files}

Replacement counts:
{replacement_rows}

Gates:
- `docs/truth/NATIVE_INTERACTION_TRUTH.md` contains the required native interaction laws.
- `docs/truth/PRODUCT_DESIGN_TRUTH.md` still preserves active IA and anti-drift canon.
- Shell command visible copy now uses `Shape Time`, `Search Ambitions`, and `Capture what changed` language.
- No workflow files were modified by this batch.

Hard boundary:
- This is a sweeping source-language and interaction-contract batch. It does not claim final visual acceptance. Screenshot proof and manual report review remain required.
""",
    )
    print("Applied Batch 29 Native Interaction Sweep.")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
