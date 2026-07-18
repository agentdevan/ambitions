#!/usr/bin/env python3
"""Guard against Accepted Yellow being used as required remediation completion."""
from __future__ import annotations

import argparse
import json
import re
import sys
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parents[1]
AUDIT_MD = ROOT / "docs" / "audits" / "architecture-remediation-accepted-yellow-misuse-audit.md"
AUDIT_JSON = ROOT / "docs" / "audits" / "architecture-remediation-accepted-yellow-misuse-audit.json"

REQUIRED_ACCEPTED_YELLOW_ISSUES = {
    "AMB-1665",
    "AMB-1666",
    "AMB-1667",
    "AMB-1668",
    "AMB-1708",
    "AMB-1709",
    "AMB-1710",
    "AMB-1713",
    "AMB-1714",
    "AMB-1715",
    "AMB-1716",
    "AMB-1717",
    "AMB-1718",
    "AMB-1719",
    "AMB-1720",
    "AMB-1721",
    "AMB-1722",
    "AMB-1723",
    "AMB-1724",
    "AMB-1725",
    "AMB-1726",
    "AMB-1727",
    "AMB-1728",
}

M02_REQUIRED_PARENTS = {"AMB-1666", "AMB-1667", "AMB-1668"}
INVALID_CLASSIFICATIONS = {"invalid_required_scope_incomplete", "needs_repair", "reopen_required"}
VALID_CLASSIFICATIONS = {
    "valid_accepted_yellow",
    "invalid_required_scope_incomplete",
    "docs_only_leaf_valid_but_parent_must_remain_open",
    "external_proof_deferred_to_release_or_device",
    "needs_repair",
    "reopen_required",
}

TRUTH_PROCESS_PATHS = [
    ROOT / "AGENTS.md",
    ROOT / "docs" / "canon" / "generated" / "CODEX_START_HERE.md",
    ROOT / "docs" / "canon" / "CONSTITUTION.md",
    ROOT / "docs" / "canon" / "standards" / "validation-and-release.md",
    ROOT / "docs" / "canon" / "migration" / "legacy-semantic-migration.json",
    ROOT / ".agents" / "skills" / "ambitions-release-proof-honesty" / "SKILL.md",
    ROOT / ".agents" / "skills" / "ambitions-architecture-tree-enforcement" / "SKILL.md",
    ROOT / ".agents" / "skills" / "ambitions-runtime-contract-engineering" / "SKILL.md",
    AUDIT_MD,
]

REQUIRED_ENTRY_FIELDS = {
    "linear_id": str,
    "title": str,
    "current_status": str,
    "classification": str,
    "why": str,
    "acceptance_required_actual_change": bool,
    "actual_change_completed": bool,
    "proof_completed": list,
    "proof_missing": list,
    "required_status_after_repair": str,
    "required_source_repairs": list,
    "required_tests": list,
    "required_follow_up_issues": list,
    "blocks_green_claim": bool,
    "blocks_milestone_completion": bool,
}

REQUIRED_CONTEXT_GUARD_FIELDS = {
    "purpose": str,
    "resume_rule": str,
    "required_resume_checks": list,
    "blocked_resume_patterns": list,
}


@dataclass(frozen=True)
class Finding:
    rule: str
    path: str
    detail: str


def load_payload() -> tuple[dict[str, Any] | None, list[Finding]]:
    findings: list[Finding] = []
    if not AUDIT_MD.exists():
        findings.append(Finding("audit-file-missing", rel(AUDIT_MD), "Markdown audit file is missing"))
    if not AUDIT_JSON.exists():
        findings.append(Finding("audit-file-missing", rel(AUDIT_JSON), "JSON audit file is missing"))
        return None, findings

    try:
        payload = json.loads(AUDIT_JSON.read_text(encoding="utf-8"))
    except json.JSONDecodeError as error:
        findings.append(Finding("audit-json-parse", rel(AUDIT_JSON), f"JSON does not parse: {error}"))
        return None, findings

    if not isinstance(payload, dict):
        findings.append(Finding("audit-json-shape", rel(AUDIT_JSON), "top-level JSON must be an object"))
        return None, findings

    return payload, findings


def rel(path: Path) -> str:
    try:
        return path.relative_to(ROOT).as_posix()
    except ValueError:
        return path.as_posix()


def validate_entries(payload: dict[str, Any]) -> tuple[list[dict[str, Any]], list[Finding]]:
    findings: list[Finding] = []
    entries = payload.get("entries")
    if not isinstance(entries, list):
        return [], [Finding("audit-json-shape", rel(AUDIT_JSON), "entries must be a list")]

    by_id: dict[str, dict[str, Any]] = {}
    for index, entry in enumerate(entries):
        path = f"{rel(AUDIT_JSON)}#/entries/{index}"
        if not isinstance(entry, dict):
            findings.append(Finding("entry-shape", path, "entry must be an object"))
            continue
        linear_id = str(entry.get("linear_id", f"index-{index}"))
        by_id[linear_id] = entry

        for field, expected_type in REQUIRED_ENTRY_FIELDS.items():
            if field not in entry:
                findings.append(Finding("entry-required-field", path, f"missing {field}"))
                continue
            if not isinstance(entry[field], expected_type):
                findings.append(Finding("entry-type", path, f"{field} must be {expected_type.__name__}"))

        classification = entry.get("classification")
        if isinstance(classification, str) and classification not in VALID_CLASSIFICATIONS:
            findings.append(Finding("entry-classification", path, f"unknown classification {classification}"))

        proof_missing = entry.get("proof_missing")
        if isinstance(proof_missing, list) and not proof_missing:
            findings.append(Finding("entry-proof-missing", path, "proof_missing must not be empty"))

        required_status = str(entry.get("required_status_after_repair", ""))
        if classification in INVALID_CLASSIFICATIONS:
            if entry.get("blocks_green_claim") is not True:
                findings.append(Finding("invalid-allows-green", path, "invalid required scope must block Green claims"))
            if entry.get("blocks_milestone_completion") is not True:
                findings.append(Finding("invalid-allows-milestone", path, "invalid required scope must block milestone completion"))
            if not re.search(r"\b(Needs Repair|In Progress)\b", required_status):
                findings.append(
                    Finding(
                        "invalid-required-status",
                        path,
                        "invalid required scope must require Needs Repair or In Progress",
                    )
                )

        if (
            entry.get("acceptance_required_actual_change") is True
            and entry.get("actual_change_completed") is False
            and (entry.get("blocks_green_claim") is not True or entry.get("blocks_milestone_completion") is not True)
        ):
            findings.append(
                Finding(
                    "incomplete-required-scope-allows-completion",
                    path,
                    "actual-change incomplete issue must block Green and milestone completion",
                )
            )

        if linear_id in M02_REQUIRED_PARENTS:
            if classification == "valid_accepted_yellow":
                findings.append(
                    Finding(
                        "m02-parent-valid-yellow",
                        path,
                        f"{linear_id} cannot be classified as valid Accepted Yellow while required work is incomplete",
                    )
                )
            if entry.get("actual_change_completed") is not False:
                findings.append(
                    Finding(
                        "m02-parent-actual-change",
                        path,
                        f"{linear_id} must remain actual_change_completed=false until source/runtime/test repair is complete",
                    )
                )
            if entry.get("blocks_green_claim") is not True or entry.get("blocks_milestone_completion") is not True:
                findings.append(
                    Finding(
                        "m02-parent-unblocked",
                        path,
                        f"{linear_id} must block Green and milestone completion",
                    )
                )

    missing = sorted(REQUIRED_ACCEPTED_YELLOW_ISSUES - set(by_id))
    for linear_id in missing:
        findings.append(Finding("missing-required-accepted-yellow-entry", rel(AUDIT_JSON), linear_id))

    return entries, findings


def validate_context_compaction_guard(payload: dict[str, Any]) -> list[Finding]:
    findings: list[Finding] = []
    guard = payload.get("context_compaction_guard")
    path = f"{rel(AUDIT_JSON)}#/context_compaction_guard"
    if not isinstance(guard, dict):
        return [
            Finding(
                "context-compaction-guard-missing",
                rel(AUDIT_JSON),
                "context_compaction_guard object is required",
            )
        ]

    for field, expected_type in REQUIRED_CONTEXT_GUARD_FIELDS.items():
        if field not in guard:
            findings.append(Finding("context-compaction-guard-field", path, f"missing {field}"))
            continue
        if not isinstance(guard[field], expected_type):
            findings.append(Finding("context-compaction-guard-type", path, f"{field} must be {expected_type.__name__}"))

    resume_rule = str(guard.get("resume_rule", "")).lower()
    if "newest user" not in resume_rule or ("summary" not in resume_rule and "summaries" not in resume_rule):
        findings.append(
            Finding(
                "context-compaction-resume-rule",
                path,
                "resume_rule must say newest user instruction wins over summaries/stale context",
            )
        )

    checks = guard.get("required_resume_checks", [])
    if isinstance(checks, list):
        joined_checks = "\n".join(str(check).lower() for check in checks)
        required_snippets = [
            "git status",
            "ambitions-accepted-yellow-misuse-audit.py --json",
            "linear statuses",
            "latest user",
        ]
        for snippet in required_snippets:
            if snippet not in joined_checks:
                findings.append(
                    Finding(
                        "context-compaction-required-check",
                        path,
                        f"required_resume_checks must include {snippet}",
                    )
                )
    if isinstance(guard.get("blocked_resume_patterns"), list) and not guard["blocked_resume_patterns"]:
        findings.append(
            Finding(
                "context-compaction-blocked-patterns",
                path,
                "blocked_resume_patterns must not be empty",
            )
        )

    return findings


def context_window(lines: list[str], index: int, radius: int = 1) -> str:
    start = max(0, index - radius)
    end = min(len(lines), index + radius + 1)
    return " ".join(line.strip() for line in lines[start:end])


def has_m02_correction(context: str) -> bool:
    lowered = context.lower()
    if "does not claim" in lowered or "do not claim" in lowered:
        return True
    return (
        ("not green" in lowered or "invalid as green" in lowered or "partially remediated" in lowered)
        and ("repair" in lowered or "incomplete" in lowered or "remaining" in lowered or "residual" in lowered)
    )


def scan_text_claims(paths: list[Path] | None = None) -> list[Finding]:
    findings: list[Finding] = []
    scan_paths = paths or TRUTH_PROCESS_PATHS
    m02_complete_pattern = re.compile(
        r"(\bM02\b.{0,100}\b(100\s*%|100 percent|complete|completed|done|closed)\b)"
        r"|(\b(100\s*%|100 percent|complete|completed|done|closed)\b.{0,100}\bM02\b)"
        r"|(\bRuntime Strangler\b.{0,100}\b(100\s*%|100 percent|complete|completed|done|closed)\b)",
        re.IGNORECASE,
    )
    accepted_yellow_bad_pattern = re.compile(
        r"Accepted Yellow.{0,120}(normal closure|close required|complete required|required scope|substitute for required)",
        re.IGNORECASE,
    )

    for path in scan_paths:
        if not path.exists():
            findings.append(Finding("scan-path-missing", rel(path), "claim-scan path is missing"))
            continue
        text = path.read_text(encoding="utf-8", errors="replace")
        lines = text.splitlines()
        for index, line in enumerate(lines):
            context = context_window(lines, index)
            if m02_complete_pattern.search(line) and not has_m02_correction(context):
                findings.append(
                    Finding(
                        "m02-complete-without-correction",
                        f"{rel(path)}:{index + 1}",
                        "M02/Runtime Strangler completion wording must be adjacent to not-Green and repair-required language",
                    )
                )
            if accepted_yellow_bad_pattern.search(line):
                lowered_context = context.lower()
                if (
                    "forbidden" not in lowered_context
                    and "not allowed" not in lowered_context
                    and "not implementation acceptance" not in lowered_context
                ):
                    findings.append(
                        Finding(
                            "accepted-yellow-required-scope-encouraged",
                            f"{rel(path)}:{index + 1}",
                            "truth/process text must not encourage Accepted Yellow closure for required scope",
                        )
                    )

    return findings


def build_payload(findings: list[Finding], entries: list[dict[str, Any]]) -> dict[str, Any]:
    checked = [
        str(entry.get("linear_id"))
        for entry in entries
        if entry.get("current_status") == "Accepted Yellow"
    ]
    invalid = [
        str(entry.get("linear_id"))
        for entry in entries
        if entry.get("current_status") == "Accepted Yellow"
        and entry.get("classification") in INVALID_CLASSIFICATIONS
    ]
    return {
        "valid": not findings,
        "findingCount": len(findings),
        "checkedAcceptedYellowIssues": checked,
        "invalidAcceptedYellowIssues": invalid,
        "checkedPaths": [rel(path) for path in TRUTH_PROCESS_PATHS],
        "findings": [asdict(finding) for finding in findings],
    }


def run_validation() -> tuple[dict[str, Any], int]:
    payload, findings = load_payload()
    entries: list[dict[str, Any]] = []
    if payload is not None:
        findings.extend(validate_context_compaction_guard(payload))
        entries, entry_findings = validate_entries(payload)
        findings.extend(entry_findings)
    findings.extend(scan_text_claims())
    result = build_payload(findings, entries)
    return result, 0 if result["valid"] else 1


def self_test() -> int:
    good_entry = {
        "linear_id": "AMB-1666",
        "title": "Parent Feature - Legacy Runtime Strangler",
        "current_status": "Accepted Yellow",
        "classification": "invalid_required_scope_incomplete",
        "why": "Required source repair remains.",
        "acceptance_required_actual_change": True,
        "actual_change_completed": False,
        "proof_completed": ["classification"],
        "proof_missing": ["source removal"],
        "required_status_after_repair": "Needs Repair",
        "required_source_repairs": ["remove live legacy authority"],
        "required_tests": ["focused tests"],
        "required_follow_up_issues": ["repair leaf"],
        "blocks_green_claim": True,
        "blocks_milestone_completion": True,
    }
    _, findings = validate_entries({"entries": [good_entry]})
    assert not any(f.rule in {"invalid-allows-green", "invalid-allows-milestone", "m02-parent-valid-yellow"} for f in findings)

    bad_entry = dict(good_entry)
    bad_entry["classification"] = "valid_accepted_yellow"
    bad_entry["actual_change_completed"] = True
    bad_entry["blocks_milestone_completion"] = False
    _, findings = validate_entries({"entries": [bad_entry]})
    rules = {finding.rule for finding in findings}
    assert "m02-parent-valid-yellow" in rules
    assert "m02-parent-actual-change" in rules
    assert "m02-parent-unblocked" in rules

    assert has_m02_correction("M02 is administratively complete but not Green; required repair remains.")
    assert not has_m02_correction("M02 is complete.")

    context_findings = validate_context_compaction_guard(
        {
            "context_compaction_guard": {
                "purpose": "test",
                "resume_rule": "newest user instruction wins over summaries",
                "required_resume_checks": [
                    "read latest user request",
                    "git status --short --branch",
                    "python3 scripts/ambitions-accepted-yellow-misuse-audit.py --json",
                    "refresh Linear statuses",
                ],
                "blocked_resume_patterns": ["stale summary"],
            }
        }
    )
    assert context_findings == []
    context_findings = validate_context_compaction_guard({"context_compaction_guard": {}})
    assert any(f.rule.startswith("context-compaction") for f in context_findings)

    temp = ROOT / ".tmp-accepted-yellow-self-test.md"
    temp.write_text("M02 Runtime Strangler is complete.\n", encoding="utf-8")
    try:
        findings = scan_text_claims([temp])
        assert any(f.rule == "m02-complete-without-correction" for f in findings)
        temp.write_text(
            "M02 Runtime Strangler is administratively complete only.\n"
            "It is not Green and required repair remains.\n",
            encoding="utf-8",
        )
        findings = scan_text_claims([temp])
        assert not any(f.rule == "m02-complete-without-correction" for f in findings)
    finally:
        temp.unlink(missing_ok=True)

    print("ambitions-accepted-yellow-misuse-audit self-test passed")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description="Check Accepted Yellow misuse in architecture remediation.")
    parser.add_argument("--json", action="store_true", help="Emit machine-readable output.")
    parser.add_argument("--self-test", action="store_true", help="Run script self-tests.")
    args = parser.parse_args()

    if args.self_test:
        return self_test()

    payload, exit_code = run_validation()
    if args.json:
        print(json.dumps(payload, indent=2, sort_keys=True))
    else:
        print("ambitions-accepted-yellow-misuse-audit")
        print(f"valid={str(payload['valid']).lower()}")
        print(f"checkedAcceptedYellowIssues={len(payload['checkedAcceptedYellowIssues'])}")
        print(f"invalidAcceptedYellowIssues={len(payload['invalidAcceptedYellowIssues'])}")
        if payload["findings"]:
            print(f"RED {payload['findingCount']} finding(s)")
            for finding in payload["findings"]:
                print(f"- {finding['rule']} {finding['path']}: {finding['detail']}")
        else:
            print("GREEN accepted-yellow misuse is blocked by local audit policy")
    return exit_code


if __name__ == "__main__":
    sys.exit(main())
