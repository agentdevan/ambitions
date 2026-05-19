#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
PATH = ROOT / "docs" / "release" / "AMB_CLAIM_REGISTRY.md"

REQUIRED_CLAIMS = [
    "Personal Life OS",
    "local-first",
    "private",
    "no custom server",
    "no Ambitions account required",
    "no cloud AI dependency",
    "no analytics SDK",
    "core loop works offline",
    "iCloud / CloudKit continuity",
    "export available",
    "delete/reset available",
    "replayable decisions",
    "deterministic Start Here",
    "source freshness",
    "receipt-backed recommendations",
    "not-chosen reasons",
    "conflict restore proof",
    "VoiceOver accessible",
    "Dynamic Type accessible",
    "Reduce Motion safe",
    "screenshot candidate ready",
    "App Store ready",
    "release ready",
]

REQUIRED_COLUMNS = [
    "Claim",
    "Allowed user-facing wording",
    "Forbidden wording",
    "Source proof required",
    "Validation command",
    "Visual proof required",
    "Accessibility proof required",
    "Privacy proof required",
    "Continuity proof required",
    "Current status",
    "Release blocker",
    "Owner",
    "Last verified date",
    "Notes",
]


def parse_rows(text: str):
    header = []
    rows = []
    lines = [line.strip() for line in text.splitlines() if line.strip()]
    for line in lines:
        if not line.startswith("|"):
            continue
        parts = [p.strip() for p in line.strip("|").split("|")]
        if parts and parts[0] == "Claim":
            header = parts
            continue
        if line.startswith("| ---"):
            continue
        if len(parts) >= 3:
            rows.append(parts)
    return header, rows


def main() -> int:
    if not PATH.exists():
        print("RED")
        print(f"missing file: {PATH}")
        return 1

    text = PATH.read_text(encoding="utf-8")
    header, rows = parse_rows(text)
    column = {name: index for index, name in enumerate(header)}
    by_claim = {row[0].strip().lower(): row for row in rows if row}

    issues = []
    for required_column in REQUIRED_COLUMNS:
        if required_column not in column:
            issues.append(f"missing required column: {required_column}")

    for claim in REQUIRED_CLAIMS:
        key = claim.lower()
        row = by_claim.get(key)
        if not row:
            issues.append(f"missing required claim: {claim}")
            continue

        if len(row) != len(header):
            issues.append(f"claim '{claim}' has {len(row)} columns; expected {len(header)}")
            continue

        status = row[column["Current status"]].strip().lower()
        if status not in {"red", "yellow", "green"}:
            issues.append(f"claim '{claim}' has invalid status: {row[column['Current status']]}")
            continue

        release_blocker = row[column["Release blocker"]].strip().lower()
        if release_blocker not in {"yes", "no"}:
            issues.append(f"claim '{claim}' has invalid release blocker: {row[column['Release blocker']]}")

        if status == "green":
            for proof_column in [
                "Source proof required",
                "Validation command",
                "Visual proof required",
                "Accessibility proof required",
                "Privacy proof required",
                "Continuity proof required",
            ]:
                value = row[column[proof_column]].strip().lower()
                if value in {"", "red", "pending", "n/a", "not required", "not_applicable"}:
                    issues.append(f"claim '{claim}' marked Green without {proof_column}")

        claim_name = row[column["Claim"]].strip().lower()
        if claim_name in {"release ready", "app store ready"} and status == "green":
            for proof_column in [
                "Source proof required",
                "Validation command",
                "Visual proof required",
                "Accessibility proof required",
                "Privacy proof required",
                "Continuity proof required",
            ]:
                value = row[column[proof_column]].strip().lower()
                if value in {"", "red", "pending", "n/a", "not required", "not_applicable"}:
                    issues.append(f"claim '{claim}' cannot be Green without full release proof")

    if issues:
        print("RED")
        print("\n".join(issues))
        return 1

    print("GREEN")
    return 0


if __name__ == "__main__":
    import sys
    sys.exit(main())
