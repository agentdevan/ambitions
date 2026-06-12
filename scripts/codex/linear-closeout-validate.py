#!/usr/bin/env python3
"""Validate Ambitions Goal Mode Linear closeout text locally without network or Linear writes."""
from __future__ import annotations

import argparse
import sys
from pathlib import Path

CODEX_OS_REQUIRED = [
    "Codex OS v2 Goal-Mode Install",
    "Issues covered:",
    "Pushed to main:",
    "Push hash:",
    "App source changed:",
    "New parallel OS created:",
    "Existing OS extended:",
    "Runner removed as active default:",
    "Goal Mode active as default:",
    "Validation run:",
    "Red blockers:",
    "Yellow existing drift:",
    "Owner approval claimed:",
    "Release/TestFlight/App Store readiness claimed:",
    "Next recommended action:",
]
CODEX_OS_FORBID = [
    "owner approval claimed: yes",
    "release/testflight/app store readiness claimed: yes",
    "app source changed: yes",
    "new parallel os created: yes",
]
CODEX_OS_ISSUES = [f"AMB-CODEX-OS-V2-{i:03d}" for i in range(1, 14)]

PLOS_PHASE_ISSUES = [
    "AMB-608",
    "AMB-609",
    "AMB-610",
    "AMB-611",
    "AMB-612",
    "AMB-613",
    "AMB-614",
    "AMB-615",
    "AMB-616",
    "AMB-627",
    "AMB-617",
    "AMB-618",
    "AMB-619",
    "AMB-620",
    "AMB-621",
    "AMB-622",
    "AMB-623",
    "AMB-624",
    "AMB-625",
    "AMB-628",
    "AMB-629",
    "AMB-630",
    "AMB-631",
    "AMB-632",
    "AMB-633",
    "AMB-634",
    "AMB-635",
]
PLOS_REQUIRED = [
    "PLOS autonomous readiness hardening",
    "Linear project:",
    "Issues covered:",
    "Pushed to main:",
    "Push hash:",
    "App source changed:",
    "Runtime features implemented:",
    "PLOS-M00 executed:",
    "Linear identifiers used:",
    "Validation run:",
    "Red blockers:",
    "Yellow limits:",
    "Owner approval claimed:",
    "Release/TestFlight/App Store readiness claimed:",
    "Next recommended action:",
]
PLOS_FORBID = [
    "owner approval claimed: yes",
    "release/testflight/app store readiness claimed: yes",
    "app source changed: yes",
    "runtime features implemented: yes",
    "plos-m00 executed: yes",
    "linear identifiers used: plos-m",
    "linear identifiers used: plos-",
]


def validate(text: str, *, program: str) -> list[str]:
    low = text.lower()
    failures: list[str] = []
    if program == "codex-os-v2":
        for phrase in CODEX_OS_REQUIRED:
            if phrase.lower() not in low:
                failures.append(f"missing required closeout field: {phrase}")
        for issue in CODEX_OS_ISSUES:
            if issue.lower() not in low:
                failures.append(f"missing issue id: {issue}")
        for phrase in CODEX_OS_FORBID:
            if phrase in low:
                failures.append(f"forbidden unproven positive claim: {phrase}")
        return failures

    if program == "plos":
        for phrase in PLOS_REQUIRED:
            if phrase.lower() not in low:
                failures.append(f"missing required PLOS closeout field: {phrase}")
        for issue in PLOS_PHASE_ISSUES:
            if issue.lower() not in low:
                failures.append(f"missing PLOS phase issue id: {issue}")
        for phrase in PLOS_FORBID:
            if phrase in low:
                failures.append(f"forbidden PLOS closeout claim or identifier: {phrase}")
        if "plos-m" in low and "amb-" not in low:
            failures.append("PLOS label appears without an AMB issue binding")
        return failures

    failures.append(f"unsupported program: {program}")
    return failures


def self_test() -> int:
    codex_text = "\n".join(CODEX_OS_REQUIRED + CODEX_OS_ISSUES)
    if validate(codex_text, program="codex-os-v2"):
        print("FAIL self-test rejected valid Codex OS closeout shell")
        return 1
    plos_text = "\n".join(PLOS_REQUIRED + PLOS_PHASE_ISSUES)
    if validate(plos_text, program="plos"):
        print("FAIL self-test rejected valid PLOS closeout shell")
        return 1
    bad = plos_text + "\nRuntime features implemented: yes\nLinear identifiers used: PLOS-M00\n"
    failures = validate(bad, program="plos")
    if not any("forbidden PLOS" in failure for failure in failures):
        print("FAIL self-test did not reject PLOS overclaim")
        return 1
    print("PASS linear closeout validator self-test")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("path", nargs="?")
    parser.add_argument("--program", default="codex-os-v2", choices=["codex-os-v2", "plos"])
    parser.add_argument("--self-test", action="store_true")
    args = parser.parse_args()

    if args.self_test:
        return self_test()

    text = Path(args.path).read_text(encoding="utf-8", errors="ignore") if args.path else sys.stdin.read()
    failures = validate(text, program=args.program)
    for failure in failures:
        print("FAIL " + failure)
    if failures:
        return 1
    print(f"PASS {args.program} linear closeout text has required fields and no forbidden claims")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
