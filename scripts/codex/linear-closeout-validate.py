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
PLOS_PROJECT_REQUIRED = [
    "PLOS autonomous readiness hardening",
    "Linear project:",
    "Issues covered:",
    "Green/Yellow/Red status:",
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
PLOS_PROJECT_FORBID = [
    "owner approval claimed: yes",
    "release/testflight/app store readiness claimed: yes",
    "app source changed: yes",
    "runtime features implemented: yes",
    "plos-m00 executed: yes",
    "linear identifiers used: plos-m",
    "linear identifiers used: plos-",
]
PLOS_CHILD_REQUIRED = [
    "PLOS child closeout",
    "Linear issue:",
    "Parent issue:",
    "Green/Yellow/Red status:",
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
PLOS_CHILD_FORBID = [
    "owner approval claimed: yes",
    "release/testflight/app store readiness claimed: yes",
    "app source changed: yes",
    "runtime features implemented: yes",
    "linear issue: plos-",
    "parent issue: plos-",
    "linear identifiers used: plos-m",
    "linear identifiers used: plos-",
]

AMB_MASTER_REQUIRED_ISSUES = ["AMB-1126", "AMB-1046", "AMB-1047", "AMB-1048"]
AMB_MASTER_PROJECT_REQUIRED = [
    "Ambitions Master Build project closeout",
    "Linear project:",
    "Issues covered:",
    "Baseline SHA:",
    "Final SHA:",
    "Pushed SHAs:",
    "Implemented work:",
    "Validation run:",
    "Changed files by train/subsystem:",
    "Authority/canon updates:",
    "Stale canon superseded:",
    "Proof artifacts:",
    "Remaining Yellow limits:",
    "Red blockers:",
    "Rollback commands:",
    "Release/TestFlight/App Store readiness claimed:",
    "Next smallest safe repair train:",
]
AMB_MASTER_CHILD_REQUIRED = [
    "Ambitions Master Build train closeout",
    "Linear project:",
    "Linear issue:",
    "Train label:",
    "Green/Yellow/Red status:",
    "Pushed to main:",
    "Push hash:",
    "App source changed:",
    "Runtime behavior changed:",
    "Linear identifiers used:",
    "Files changed:",
    "Validation run:",
    "Proof artifacts:",
    "Red blockers:",
    "Yellow limits:",
    "Owner approval claimed:",
    "Release/TestFlight/App Store readiness claimed:",
    "Accessibility certification claimed:",
    "Privacy/legal approval claimed:",
    "Rollback:",
    "Next train:",
]
AMB_MASTER_FORBID = [
    "owner approval claimed: yes",
    "release/testflight/app store readiness claimed: yes",
    "accessibility certification claimed: yes",
    "privacy/legal approval claimed: yes",
    "linear issue: m00",
    "linear issue: m01",
    "linear issue: m02",
    "linear issue: m03",
    "linear identifiers used: m00",
    "linear identifiers used: train",
]


def validate(text: str, *, program: str, scope: str = "project") -> list[str]:
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
        if scope == "project":
            required = PLOS_PROJECT_REQUIRED
            forbidden = PLOS_PROJECT_FORBID
            required_issues = PLOS_PHASE_ISSUES
        elif scope in {"phase", "child"}:
            required = PLOS_CHILD_REQUIRED
            forbidden = PLOS_CHILD_FORBID
            required_issues = []
        else:
            return [f"unsupported PLOS closeout scope: {scope}"]

        for phrase in required:
            if phrase.lower() not in low:
                failures.append(f"missing required PLOS closeout field: {phrase}")
        for issue in required_issues:
            if issue.lower() not in low:
                failures.append(f"missing PLOS phase issue id: {issue}")
        for phrase in forbidden:
            if phrase in low:
                failures.append(f"forbidden PLOS closeout claim or identifier: {phrase}")
        if scope in {"phase", "child"}:
            if "linear issue: amb-" not in low:
                failures.append("PLOS child/phase closeout must include an AMB-bound Linear issue")
            if "parent issue: amb-" not in low:
                failures.append("PLOS child/phase closeout must include an AMB-bound parent issue")
        if "plos-m" in low and "amb-" not in low:
            failures.append("PLOS label appears without an AMB issue binding")
        return failures

    if program == "amb-master":
        if "ca716546-e3d4-4d5b-a399-03076ccba9ee" not in low:
            failures.append("missing Ambitions Master Build Linear project id")
        if scope == "project":
            required = AMB_MASTER_PROJECT_REQUIRED
            required_issues = AMB_MASTER_REQUIRED_ISSUES
        elif scope in {"phase", "child"}:
            required = AMB_MASTER_CHILD_REQUIRED
            required_issues = []
        else:
            return [f"unsupported amb-master closeout scope: {scope}"]
        for phrase in required:
            if phrase.lower() not in low:
                failures.append(f"missing required amb-master closeout field: {phrase}")
        for issue in required_issues:
            if issue.lower() not in low:
                failures.append(f"missing amb-master issue id: {issue}")
        for phrase in AMB_MASTER_FORBID:
            if phrase in low:
                failures.append(f"forbidden amb-master closeout claim or identifier: {phrase}")
        if scope in {"phase", "child"} and "linear issue: `amb-" not in low and "linear issue: amb-" not in low:
            failures.append("amb-master child/phase closeout must include an AMB-bound Linear issue")
        return failures

    failures.append(f"unsupported program: {program}")
    return failures


def self_test() -> int:
    codex_text = "\n".join(CODEX_OS_REQUIRED + CODEX_OS_ISSUES)
    if validate(codex_text, program="codex-os-v2"):
        print("FAIL self-test rejected valid Codex OS closeout shell")
        return 1
    plos_text = "\n".join(PLOS_PROJECT_REQUIRED + PLOS_PHASE_ISSUES)
    if validate(plos_text, program="plos"):
        print("FAIL self-test rejected valid PLOS closeout shell")
        return 1
    bad = plos_text + "\nRuntime features implemented: yes\nLinear identifiers used: PLOS-M00\n"
    failures = validate(bad, program="plos")
    if not any("forbidden PLOS" in failure for failure in failures):
        print("FAIL self-test did not reject PLOS overclaim")
        return 1
    child_text = "\n".join(PLOS_CHILD_REQUIRED) + "\nLinear issue: AMB-636\nParent issue: AMB-608\nPLOS-M00 executed: yes, parent in progress only\nLinear identifiers used: AMB issue identifiers only\n"
    if validate(child_text, program="plos", scope="child"):
        print("FAIL self-test rejected valid PLOS child closeout shell")
        return 1
    bad_child = child_text.replace("Linear issue: AMB-636", "Linear issue: PLOS-000")
    failures = validate(bad_child, program="plos", scope="child")
    if not any("forbidden PLOS" in failure for failure in failures):
        print("FAIL self-test did not reject child PLOS identifier")
        return 1
    amb_child = "\n".join(AMB_MASTER_CHILD_REQUIRED) + "\nLinear project: Ambitions Personal Life OS Runtime + Native iPhone App Master Build Program (`ca716546-e3d4-4d5b-a399-03076ccba9ee`)\nLinear issue: `AMB-1046`\n"
    if validate(amb_child, program="amb-master", scope="child"):
        print("FAIL self-test rejected valid amb-master child closeout shell")
        return 1
    bad_amb_child = amb_child.replace("Linear issue: `AMB-1046`", "Linear issue: M00.T00")
    failures = validate(bad_amb_child, program="amb-master", scope="child")
    if not any("AMB-bound" in failure or "forbidden amb-master" in failure for failure in failures):
        print("FAIL self-test did not reject amb-master train label identifier")
        return 1
    print("PASS linear closeout validator self-test")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("path", nargs="?")
    parser.add_argument("--program", default="codex-os-v2", choices=["codex-os-v2", "plos", "amb-master"])
    parser.add_argument("--scope", default="project", choices=["project", "phase", "child"])
    parser.add_argument("--self-test", action="store_true")
    args = parser.parse_args()

    if args.self_test:
        return self_test()

    text = Path(args.path).read_text(encoding="utf-8", errors="ignore") if args.path else sys.stdin.read()
    failures = validate(text, program=args.program, scope=args.scope)
    for failure in failures:
        print("FAIL " + failure)
    if failures:
        return 1
    print(f"PASS {args.program} linear closeout text has required fields and no forbidden claims")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
