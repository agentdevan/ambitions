#!/usr/bin/env python3
"""Focused Source Atlas no-private-graph egress audit."""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(REPO_ROOT / "tools" / "source-atlas"))

from foundry.boundary import boundary_issue_strings, boundary_issues_for_json_file, object_key_issues
from foundry.model import read_json


DEFAULT_TARGETS = [
    "Native/Ambitions/Core/LocalRuntimeOS/SourceAtlas",
    "tools/source-atlas/foundry",
    "tools/source-atlas/fixtures",
    "tools/source-atlas/foundry/contracts",
    "docs/platform/SOURCE_ATLAS_FOUNDRY_BLUEPRINT.md",
]

NATIVE_SOURCE_ATLAS_ROOT = "Native/Ambitions/Core/LocalRuntimeOS/SourceAtlas/"

PRIVATE_AUTHORITY_PATTERNS = {
    "PersonalizationFactorLedger": "personal profiling ledger authority",
    "PersonalizationFactorLedgerBuilder": "personal profiling builder authority",
    "PersonalizationFactorLedgerInput": "personal profiling input authority",
    "PrivateLifeRuntimeKernel": "private runtime kernel authority",
    "DecisionKernel": "private runtime decision authority",
    "RecommendationKernel": "private runtime recommendation authority",
    "AmbitionsCommand": "direct command mutation marker",
    "CommandEnvelope": "direct command mutation marker",
    "CommandCompiler": "direct command mutation marker",
    "CommandJournal": "direct command mutation marker",
    "CommandReducer": "direct command mutation marker",
    "RuntimeTransaction": "canonical mutation transaction marker",
    "RuntimeMutation": "canonical mutation marker",
    "RuntimeEventStore": "event-journal mutation authority",
    "ProjectionMaterializer": "projection materialization authority",
    "GoalThreadStore": "private graph object-state store",
    "LifeAreaStore": "private graph object-state store",
    "StepStore": "private graph object-state store",
    "CaptureStore": "private graph object-state store",
    "TimeBlockStore": "private graph object-state store",
    "ClosureStore": "private graph object-state store",
    "ProofStore": "private graph object-state store",
    "ReceiptStore": "private graph object-state store",
    "UserSystemStore": "private graph object-state store",
    "AppStateStore": "canonical app-state store",
    "ModelContext": "SwiftData mutation context",
    "SwiftData": "SwiftData persistence authority",
    "SideEffectOutbox": "side-effect mutation authority",
    "CloudKitContinuityAdapter": "sync continuity authority",
    "SyncEnvelope": "sync continuity payload authority",
}


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Audit Source Atlas for private graph egress markers")
    parser.add_argument("targets", nargs="*", default=DEFAULT_TARGETS)
    parser.add_argument("--json", action="store_true")
    parser.add_argument("--self-test", action="store_true", help="Run denylist self-tests.")
    args = parser.parse_args(argv)

    if args.self_test:
        return self_test()

    issues: list[str] = []
    for target in args.targets:
        path = (REPO_ROOT / target).resolve()
        if not path.exists():
            issues.append(f"{target}: missing target")
            continue
        if path.is_dir():
            for json_path in sorted(path.rglob("*.json")):
                issues.extend(audit_json(json_path))
            for py_path in sorted(path.rglob("*.py")):
                issues.extend(audit_text(py_path))
            for swift_path in sorted(path.rglob("*.swift")):
                issues.extend(audit_text(swift_path))
        elif path.suffix == ".json":
            issues.extend(audit_json(path))
        else:
            issues.extend(audit_text(path))

    payload = {"valid": not issues, "issueCount": len(issues), "issues": issues}
    if args.json:
        print(json.dumps(payload, indent=2, sort_keys=True))
    else:
        print(f"Source Atlas no-private-graph egress audit: {'PASS' if payload['valid'] else 'FAIL'}")
        for issue in issues:
            print(f"- {issue}")
    return 0 if payload["valid"] else 1


def audit_json(path: Path) -> list[str]:
    value = read_json(path)
    if isinstance(value, dict) and value.get("expectedValid") is False:
        return []
    expected = value.get("expectedBoundaryResult") if isinstance(value, dict) else None
    if expected == "reject":
        return []
    relative = display_path(path)
    issues = boundary_issue_strings(boundary_issues_for_json_file(path, relative))
    if isinstance(value, dict) and isinstance(value.get("objectKey"), str):
        issues.extend(issue.format() for issue in object_key_issues(value["objectKey"], relative))
    return issues


def audit_text(path: Path) -> list[str]:
    relative = display_path(path)
    findings: list[str] = []
    if relative.startswith(NATIVE_SOURCE_ATLAS_ROOT):
        findings.extend(audit_native_source_text(path, relative))

    for index, line in enumerate(path.read_text(encoding="utf-8", errors="replace").splitlines(), start=1):
        lowered = line.lower()
        if "r2" not in lowered and "urlsession" not in lowered and "objectkey" not in lowered and "upload" not in lowered:
            continue
        if any(term in lowered for term in ["goaltext", "capturetext", "privatelif egraph".replace(" ", "")]):
            findings.append(f"{relative}:{index}: possible private graph egress marker")
        if any(term in lowered for term in ["private life graph", "goals", "captures", "receipts", "proof payload", "proofpayload"]):
            if not any(marker in lowered for marker in ["must not", "never", "no private", "not a", "forbidden", "forbid", "reject", "not store", "not receive", "only", "public/reference", "private life graph in r2", "staging proof"]):
                findings.append(f"{relative}:{index}: review Source Atlas private graph egress wording")
    return findings


def audit_native_source_text(path: Path, relative: str) -> list[str]:
    return audit_native_source_text_from_string(
        path.read_text(encoding="utf-8", errors="replace"),
        relative,
    )


def audit_native_source_text_from_string(text: str, relative: str) -> list[str]:
    findings: list[str] = []
    for index, line in enumerate(text.splitlines(), start=1):
        stripped = line.strip()
        if stripped.startswith("//"):
            continue
        for token, reason in PRIVATE_AUTHORITY_PATTERNS.items():
            if re.search(rf"(?<![A-Za-z0-9_]){re.escape(token)}(?![A-Za-z0-9_])", line):
                findings.append(f"{relative}:{index}: Source Atlas must not reference {reason}: {token}")
    return findings


def self_test() -> int:
    invalid = "let ledger: PersonalizationFactorLedger?\nlet command = AmbitionsCommand.capture\nlet context: ModelContext\n"
    invalid_path = f"{NATIVE_SOURCE_ATLAS_ROOT}SelfTest.swift"
    issues = audit_native_source_text_from_string(invalid, invalid_path)
    assert len(issues) == 3
    assert any("PersonalizationFactorLedger" in issue for issue in issues)
    assert any("AmbitionsCommand" in issue for issue in issues)
    assert any("ModelContext" in issue for issue in issues)

    valid = "let signal = SourceAtlasLocalInfluenceSet(stableFingerprint: \"local\", signals: [])\n"
    assert audit_native_source_text_from_string(valid, invalid_path) == []
    print("source-atlas-no-private-graph-egress-audit self-test passed")
    return 0


def display_path(path: Path) -> str:
    try:
        return str(path.relative_to(REPO_ROOT))
    except ValueError:
        return str(path)


if __name__ == "__main__":
    raise SystemExit(main())
