#!/usr/bin/env python3
from __future__ import annotations

import json
import re
from collections import defaultdict
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

TARGET_FILES = [
    "docs/codex/batches/BATCH-01-pre-phase9-cleanup-and-captures-tab.md",
    "docs/codex/batches/BATCH-04-canon-batch-2-first-class-capture-core.md",
    "docs/codex/batches/BATCH-35-post-2.0-hardening-shell-truth-navigation-and-plan-canon-recovery.md",
    "docs/codex/repo-audit-baseline.md",
    "prompts/batches/FRONTEND-SURFACE-RECIPE-COMPLETENESS-REVIEW-001.md",
    "prompts/batches/IR-01-FRONTEND-RECOVERY-GATE.md",
    "prompts/batches/SHELL-CONTINUITY-DOCK-MATERIALS-01.md",
    "prompts/batches/TOP-LEVEL-IA-PLAN-LEAK-REGRESSION-01.md",
    "prompts/batches/amb-fe-be/FE-06-SHELL-MIGRATION.md",
]

OUT_MD = ROOT / "docs/ops/canon-collapse/red-retired-terminology-rewrite-report.md"
OUT_JSON = ROOT / "docs/ops/canon-collapse/red-retired-terminology-rewrite-report.json"

BUNDLE_ID = "canon-collapse-red-rewrite-bundle"
LINEAR_ISSUE = "AMB-287"

PHRASE_REPLACEMENTS = [
    (r"\bPlan tab\b", "Time surface"),
    (r"\bplan tab\b", "Time surface"),
    (r"\bProfile tab\b", "You surface"),
    (r"\bprofile tab\b", "You surface"),
    (r"\bCaptures tab\b", "Capture surface"),
    (r"\bcaptures tab\b", "Capture surface"),
    (r"\bInsights tab\b", "proof inspection surface"),
    (r"\binsights tab\b", "proof inspection surface"),
    (r"\bHabits tab\b", "goal/step routine surface"),
    (r"\bhabits tab\b", "goal/step routine surface"),
    (r"\bMomentum tab\b", "proof/progress surface"),
    (r"\bmomentum tab\b", "proof/progress surface"),
    (r"\bbest next move\b", "Recommended step"),
    (r"\bBest next move\b", "Recommended step"),
    (r"\bnext best move\b", "Recommended step"),
    (r"\bNext best move\b", "Recommended step"),
    (r"\bBegin Focus\b", "Start now"),
    (r"\bbegin focus\b", "Start now"),
    (r"\bStart Focus\b", "Start now"),
    (r"\bstart focus\b", "Start now"),
    (r"\boverdue\b", "needs closure"),
    (r"\bOverdue\b", "Needs closure"),
    (r"\bfailed\b", "needs review"),
    (r"\bFailed\b", "Needs review"),
    (r"\bstreaks\b", "proof threads"),
    (r"\bStreaks\b", "Proof threads"),
    (r"\bstreak\b", "proof thread"),
    (r"\bStreak\b", "Proof thread"),
    (r"\bproductivity score\b", "proof signal"),
    (r"\bProductivity score\b", "Proof signal"),
    (r"(?<![-_/A-Za-z0-9])dashboard(?![-_/A-Za-z0-9])", "surface"),
    (r"(?<![-_/A-Za-z0-9])Dashboard(?![-_/A-Za-z0-9])", "Surface"),
]

RETIRED_PATTERNS = [
    r"\bPlan tab\b",
    r"\bProfile tab\b",
    r"\bCaptures tab\b",
    r"\bInsights tab\b",
    r"\bHabits tab\b",
    r"\bMomentum tab\b",
    r"\bnext best move\b",
    r"\bbest next move\b",
    r"\bBegin Focus\b",
    r"\bStart Focus\b",
    r"\boverdue\b",
    r"\bfailed\b",
    r"\bstreak\b",
    r"\bstreaks\b",
    r"\bproductivity score\b",
    r"(?<![-_/A-Za-z0-9])dashboard(?![-_/A-Za-z0-9])",
]

CANONICAL_REPLACEMENT_NOTES = {
    "Plan tab": "Time surface",
    "Profile tab": "You surface",
    "Captures tab": "Capture surface",
    "Insights tab": "proof inspection surface",
    "Habits tab": "goal/step routine surface",
    "Momentum tab": "proof/progress surface",
    "next best move": "Recommended step",
    "best next move": "Recommended step",
    "Begin Focus": "Start now",
    "Start Focus": "Start now",
    "overdue": "needs closure",
    "failed": "needs review",
    "streak": "proof thread",
    "productivity score": "proof signal",
    "dashboard": "surface",
}


def rel(path: Path) -> str:
    return path.relative_to(ROOT).as_posix()


def count_matches(text: str) -> dict[str, int]:
    counts: dict[str, int] = {}
    for pattern in RETIRED_PATTERNS:
        matches = re.findall(pattern, text, flags=re.IGNORECASE)
        if matches:
            label = pattern
            counts[label] = len(matches)
    return counts


def apply_rewrites(text: str) -> tuple[str, dict[str, int]]:
    replacement_counts: dict[str, int] = {}
    new_text = text

    for pattern, replacement in PHRASE_REPLACEMENTS:
        new_text, count = re.subn(pattern, replacement, new_text, flags=re.IGNORECASE)
        if count:
            replacement_counts[pattern] = count

    return new_text, replacement_counts


def main() -> int:
    changed_files = []
    missing_files = []
    before_counts_by_file: dict[str, dict[str, int]] = {}
    after_counts_by_file: dict[str, dict[str, int]] = {}
    replacement_counts_by_file: dict[str, dict[str, int]] = {}

    for raw_path in TARGET_FILES:
        path = ROOT / raw_path
        if not path.exists():
            missing_files.append(raw_path)
            continue

        before = path.read_text(encoding="utf-8", errors="ignore")
        before_counts = count_matches(before)
        after, replacement_counts = apply_rewrites(before)
        after_counts = count_matches(after)

        before_counts_by_file[raw_path] = before_counts
        after_counts_by_file[raw_path] = after_counts
        replacement_counts_by_file[raw_path] = replacement_counts

        if after != before:
            path.write_text(after, encoding="utf-8")
            changed_files.append(raw_path)

    remaining_retired = {
        path: counts
        for path, counts in after_counts_by_file.items()
        if counts
    }

    status = "GREEN" if not missing_files and not remaining_retired else "YELLOW"

    payload = {
        "schema_version": 1,
        "generated_utc": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "owner": "CANON-COLLAPSE-002",
        "linear_issue": LINEAR_ISSUE,
        "bundle_id": BUNDLE_ID,
        "status": status,
        "target_files": TARGET_FILES,
        "changed_files": changed_files,
        "missing_files": missing_files,
        "before_counts_by_file": before_counts_by_file,
        "after_counts_by_file": after_counts_by_file,
        "remaining_retired_patterns": remaining_retired,
        "replacement_counts_by_file": replacement_counts_by_file,
        "replacement_notes": CANONICAL_REPLACEMENT_NOTES,
        "non_claims": [
            "This rewrite does not modify source code.",
            "This rewrite does not modify product truth files.",
            "This rewrite does not delete or archive files.",
            "This rewrite does not prove implementation, build, tests, accessibility, performance, device, privacy, legal, TestFlight, App Store, or release readiness.",
            "Linear status is not repo truth.",
        ],
    }

    lines = [
        "# Red Retired Terminology Rewrite Report",
        "",
        f"Status: {status}",
        f"Generated UTC: {payload['generated_utc']}",
        "Owner: CANON-COLLAPSE-002",
        f"Linear issue: {LINEAR_ISSUE}",
        f"Bundle: {BUNDLE_ID}",
        "",
        "## Scope",
        "",
        "This report covers only the 9 active Red retired IA / terminology candidates identified by AMB-286.",
        "",
        "No source code, product truth files, deletion, archive operation, or broad purge is included.",
        "",
        "## Changed files",
        "",
    ]

    if changed_files:
        for path in changed_files:
            lines.append(f"- `{path}`")
    else:
        lines.append("- None")

    lines.extend(["", "## Missing files", ""])

    if missing_files:
        for path in missing_files:
            lines.append(f"- `{path}`")
    else:
        lines.append("- None")

    lines.extend(["", "## Replacement summary", ""])

    for path in TARGET_FILES:
        replacements = replacement_counts_by_file.get(path, {})
        if not replacements:
            continue
        lines.append(f"### `{path}`")
        for pattern, count in sorted(replacements.items()):
            lines.append(f"- `{pattern}` -> `{count}` replacement(s)")
        lines.append("")

    lines.extend(["", "## Remaining retired patterns", ""])

    if remaining_retired:
        for path, counts in remaining_retired.items():
            lines.append(f"### `{path}`")
            for pattern, count in sorted(counts.items()):
                lines.append(f"- `{pattern}` remains `{count}` time(s)")
            lines.append("")
    else:
        lines.append("- None in scoped files.")

    lines.extend(
        [
            "",
            "## Canonical replacement notes",
            "",
        ]
    )

    for old, new in CANONICAL_REPLACEMENT_NOTES.items():
        lines.append(f"- `{old}` -> `{new}`")

    lines.extend(
        [
            "",
            "## Non-claims",
            "",
        ]
    )

    for claim in payload["non_claims"]:
        lines.append(f"- {claim}")

    OUT_MD.write_text("\n".join(lines) + "\n", encoding="utf-8")
    OUT_JSON.write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")

    print(f"wrote {rel(OUT_MD)}")
    print(f"wrote {rel(OUT_JSON)}")
    print(f"status: {status}")
    print(f"changed files: {len(changed_files)}")
    print(f"missing files: {len(missing_files)}")
    print(f"remaining retired pattern files: {len(remaining_retired)}")

    if missing_files:
        print("Missing target files:")
        for path in missing_files:
            print(f"- {path}")

    if remaining_retired:
        print("Remaining retired terms found in scoped files; review report.")
        return 2

    print("AMB-287 scoped rewrite validation passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
