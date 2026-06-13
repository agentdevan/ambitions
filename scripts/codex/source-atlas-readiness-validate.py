#!/usr/bin/env python3
"""Validate Source Atlas Factory readiness artifacts without network or writes."""
from __future__ import annotations

import argparse
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SAF_DIR = ROOT / "artifacts" / "source-atlas-factory"

REQUIRED_FILES = [
    SAF_DIR / "SAF_GOAL.md",
    SAF_DIR / "SAF-run-state.md",
    SAF_DIR / "SAF_PACK_RELEASE_LEDGER.md",
    SAF_DIR / "SAF_RISK_REGISTER.md",
    SAF_DIR / "SAF_HARDENING_PLAN.md",
    ROOT / ".agents" / "skills" / "source-atlas-factory" / "SKILL.md",
    ROOT / ".agents" / "skills" / "source-atlas-factory" / "references" / "source-atlas-pack-gates.md",
    ROOT / ".agents" / "skills" / "source-atlas-factory" / "references" / "source-atlas-r2-boundary-standard.md",
    SAF_DIR / "r2" / "R2_STAGING_ACTIVATION_REPORT.md",
    SAF_DIR / "r2" / "R2_CANARY_OBJECT_RECEIPT.md",
    SAF_DIR / "r2" / "R2_NO_PRIVATE_DATA_AUDIT.md",
    SAF_DIR / "r2" / "R2_RELEASE_RECEIPT_TEMPLATE.md",
    SAF_DIR / "r2" / "R2_ROLLBACK_RECEIPT_TEMPLATE.md",
    SAF_DIR / "r2" / "R2_CONNECTOR_CAPABILITY_AUDIT.md",
]

REQUIRED_PLAN_PHRASES = [
    "public-reference-only",
    "private user data",
    "source binding",
    "freshness",
    "revocation",
    "release receipt",
    "runtime eligibility",
    "rollback",
]


def validate_plan_text(text: str) -> list[str]:
    low = text.lower()
    failures: list[str] = []
    for phrase in REQUIRED_PLAN_PHRASES:
        if phrase.lower() not in low:
            failures.append(f"SAF_HARDENING_PLAN.md missing required phrase: {phrase}")
    if "private user data in r2" in low and "red" not in low:
        failures.append("SAF_HARDENING_PLAN.md mentions private user data in R2 without a Red classification")
    return failures


def validate_files() -> list[str]:
    failures: list[str] = []
    for path in REQUIRED_FILES:
        if not path.exists():
            failures.append(f"missing required Source Atlas readiness file: {path.relative_to(ROOT)}")
    plan = SAF_DIR / "SAF_HARDENING_PLAN.md"
    if plan.exists():
        failures.extend(validate_plan_text(plan.read_text(encoding="utf-8", errors="ignore")))
    return failures


def self_test() -> int:
    good = "\n".join(REQUIRED_PLAN_PHRASES) + "\nprivate user data in R2 is Red\n"
    failures = validate_plan_text(good)
    if failures:
        print("FAIL self-test valid Source Atlas plan rejected")
        for failure in failures:
            print("FAIL " + failure)
        return 1
    bad = "source binding\nfreshness\n"
    failures = validate_plan_text(bad)
    if not failures:
        print("FAIL self-test did not reject incomplete Source Atlas plan")
        return 1
    print("PASS source atlas readiness validator self-test")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--self-test", action="store_true", help="Run in-memory validator self-tests.")
    args = parser.parse_args()
    if args.self_test:
        return self_test()
    failures = validate_files()
    for failure in failures:
        print("FAIL " + failure)
    if failures:
        return 1
    print("PASS Source Atlas Factory readiness artifacts are declared and bounded")
    return 0


if __name__ == "__main__":
    sys.exit(main())
