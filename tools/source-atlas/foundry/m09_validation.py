"""M09 validation, repair, evidence, and known-issue routing helpers."""

from __future__ import annotations

import json
import shutil
from pathlib import Path
from typing import Any

from .model import NON_CLAIMS, PRIVACY_BOUNDARY, read_json, stable_id, utc_now, write_json


REQUIRED_COMMAND_AREAS = {
    "boundary",
    "no-private-egress",
    "foundry",
    "schema",
    "cache",
    "runtime",
    "inspection-ui",
    "accessibility",
    "privacy-security",
    "golden-benchmarks",
    "source-state-repair",
    "evidence-generation",
    "known-issue-router",
    "xcode-build-for-testing",
}

REQUIRED_GOLDEN_SCENARIOS = [
    "nasa-astronaut",
    "us-president",
    "college-football-player",
    "professional-football-player",
    "nurse",
    "pilot",
    "teacher",
    "software-engineer",
    "small-business-owner",
    "music-artist",
    "audio-engineer",
    "marathon-runner",
    "electrician-apprenticeship",
    "lawyer",
    "medical-school-path",
    "career-pivot",
    "still-counts-pivot",
]

REQUIRED_SOURCE_STATES = [
    "current",
    "unavailable",
    "stale",
    "stale-critical",
    "conflicted",
    "revoked",
    "unsupported",
    "review-required",
]

REQUIRED_REPAIR_STATES = [
    "stale",
    "stale-critical",
    "unavailable",
    "conflicted",
    "revoked",
    "unsupported",
    "review-required",
]

SAFE_NON_CURRENT_ROUTES = {
    "fallback-local-only",
    "quarantine-and-fallback",
    "repair-required",
    "review-required",
    "unsupported-source-fallback",
}

RUNTIME_BLOCKED_STATES = {
    "stale-critical",
    "conflicted",
    "revoked",
    "unsupported",
    "review-required",
}

KNOWN_ISSUE_IDS = [
    "AMB-ISSUE-2001",
    "AMB-ISSUE-2004",
    "AMB-ISSUE-2005",
    "AMB-ISSUE-2007",
    "AMB-ISSUE-2010",
    "AMB-ISSUE-2011",
    "AMB-ISSUE-2012",
]


def validate_command_matrix(matrix_path: Path, repo_root: Path, output_path: Path | None = None) -> dict[str, Any]:
    matrix = read_json(matrix_path)
    commands = matrix.get("commands", [])
    issues: list[str] = []
    areas = {command.get("area") for command in commands}
    for area in sorted(REQUIRED_COMMAND_AREAS - areas):
        issues.append(f"missing required command area: {area}")
    for command in commands:
        issues.extend(_validate_command_entry(command, repo_root))
    result = {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.m09.validationCommandMatrixResult",
        "matrixPath": str(matrix_path),
        "valid": not issues,
        "commandCount": len(commands),
        "availableCommandCount": sum(1 for item in commands if item.get("availability") == "available"),
        "notAvailableCount": sum(1 for item in commands if item.get("availability") == "not_available"),
        "areas": sorted(area for area in areas if area),
        "issues": issues,
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": NON_CLAIMS,
    }
    if output_path:
        write_json(output_path, result)
    return result


def validate_golden_benchmark_matrix(matrix_path: Path, output_path: Path | None = None) -> dict[str, Any]:
    matrix = read_json(matrix_path)
    scenarios = matrix.get("scenarios", [])
    variants = matrix.get("sourceStateVariants", {})
    scenario_ids = [scenario.get("id") for scenario in scenarios]
    issues: list[str] = []

    if scenario_ids != REQUIRED_GOLDEN_SCENARIOS:
        issues.append("scenario order or membership does not match the required 17-scenario matrix")
    for state in REQUIRED_SOURCE_STATES:
        if state not in variants:
            issues.append(f"missing source-state variant: {state}")
    default_assertions = matrix.get("defaultSourceStateAssertions", {})
    for scenario in scenarios:
        issues.extend(_validate_golden_scenario(scenario, variants, default_assertions))

    result = {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.m09.goldenBenchmarkResult",
        "id": stable_id("m09.golden", {"matrix": matrix}),
        "matrixPath": str(matrix_path),
        "valid": not issues,
        "scenarioCount": len(scenarios),
        "variantCount": len(variants),
        "expandedCaseCount": len(scenarios) * len(variants),
        "noFalseCompletionAssertions": len(scenarios) * len(variants),
        "productionSourceAtlasTruthClaimed": False,
        "issues": issues,
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": NON_CLAIMS,
    }
    if output_path:
        write_json(output_path, result)
    return result


def validate_source_state_repair_fixtures(fixture_path: Path, output_path: Path | None = None) -> dict[str, Any]:
    payload = read_json(fixture_path)
    fixtures = payload.get("fixtures", [])
    issues: list[str] = []
    states = {fixture.get("sourceState") for fixture in fixtures}
    for state in sorted(set(REQUIRED_REPAIR_STATES) - states):
        issues.append(f"missing repair fixture for source state: {state}")
    for fixture in fixtures:
        issues.extend(_validate_repair_fixture(fixture))
    result = {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.m09.sourceStateRepairResult",
        "id": stable_id("m09.repair", {"fixtures": fixtures}),
        "fixturePath": str(fixture_path),
        "valid": not issues,
        "fixtureCount": len(fixtures),
        "statesCovered": sorted(state for state in states if state),
        "unsafeRuntimeDriveBlocked": not any(
            fixture.get("sourceState") in RUNTIME_BLOCKED_STATES and fixture.get("artifactMayDriveRuntime") is not False
            for fixture in fixtures
        ),
        "issues": issues,
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": NON_CLAIMS,
    }
    if output_path:
        write_json(output_path, result)
    return result


def route_known_issues(
    command_result_path: Path,
    golden_result_path: Path,
    repair_result_path: Path,
    output_path: Path | None = None,
) -> dict[str, Any]:
    command_result = read_json(command_result_path)
    golden_result = read_json(golden_result_path)
    repair_result = read_json(repair_result_path)
    validations = {
        "commandMatrix": command_result,
        "goldenBenchmarks": golden_result,
        "sourceStateRepair": repair_result,
    }
    rows = [_known_issue_row(issue_id, validations) for issue_id in KNOWN_ISSUE_IDS]
    result = {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.m09.knownIssueRouterResult",
        "generatedAt": utc_now(),
        "knownIssueClosureAttempted": False,
        "status": "repair_required" if any(row["routeStatus"] == "repair_required" for row in rows) else "proof_gap_routed",
        "issues": rows,
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": NON_CLAIMS + ["does not close known issues"],
    }
    if output_path:
        write_json(output_path, result)
    return result


def generate_evidence_pack(
    output_root: Path,
    command_result_path: Path,
    golden_result_path: Path,
    repair_result_path: Path,
    known_issue_result_path: Path,
    ledger_path: str,
) -> dict[str, Any]:
    output_root.mkdir(parents=True, exist_ok=True)
    command_result = read_json(command_result_path)
    golden_result = read_json(golden_result_path)
    repair_result = read_json(repair_result_path)
    known_issue_result = read_json(known_issue_result_path)
    all_valid = all(result.get("valid") for result in [command_result, golden_result, repair_result])
    pack = {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.m09.releaseEvidencePack",
        "generatedAt": utc_now(),
        "status": "Green" if all_valid else "Red",
        "releaseReadinessClaimed": False,
        "productionR2UploadClaimed": False,
        "knownIssueClosureAttempted": False,
        "validationOutputs": {
            "commandMatrix": str(command_result_path),
            "goldenBenchmarks": str(golden_result_path),
            "sourceStateRepair": str(repair_result_path),
            "knownIssueRouter": str(known_issue_result_path),
        },
        "proofArtifactPaths": {
            "m09Ledger": ledger_path,
            "generatedEvidencePack": str(output_root / "m09-release-evidence-pack.json"),
        },
        "commandOutputSummaries": [
            _summary("validation command matrix", command_result),
            _summary("golden benchmark matrix", golden_result),
            _summary("source-state repair fixtures", repair_result),
            {
                "name": "known issue router",
                "status": known_issue_result.get("status"),
                "issueCount": len(known_issue_result.get("issues", [])),
            },
        ],
        "knownRisks": [
            "Current M09 evidence is local validation evidence only.",
            "No production R2 upload, deployed Worker promotion, account readiness, TestFlight readiness, App Store readiness, or legal/privacy approval is claimed.",
            "Golden benchmarks validate scenario and state-routing contracts; they do not certify production Source Atlas coverage.",
        ],
        "rollbackNotes": [
            "Revert M09 tools, fixtures, tests, and retained docs added by this train.",
            "Remove generated output under output/source-atlas/m09 if a local workspace cleanup is needed.",
        ],
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": NON_CLAIMS
        + [
            "not release readiness",
            "not TestFlight readiness",
            "not App Store readiness",
            "not production R2 upload",
            "not known issue closure",
        ],
    }
    json_path = output_root / "m09-release-evidence-pack.json"
    markdown_path = output_root / "m09-release-evidence-pack.md"
    write_json(json_path, pack)
    markdown_path.write_text(_evidence_pack_markdown(pack), encoding="utf-8")
    pack["proofArtifactPaths"]["generatedEvidencePackMarkdown"] = str(markdown_path)
    write_json(json_path, pack)
    return pack


def _validate_command_entry(command: dict[str, Any], repo_root: Path) -> list[str]:
    issues: list[str] = []
    entry_id = command.get("id", "<missing-id>")
    availability = command.get("availability")
    if command.get("area") not in REQUIRED_COMMAND_AREAS:
        issues.append(f"{entry_id}: unknown or missing area")
    if availability == "available":
        text = str(command.get("command", "")).strip()
        if not text:
            issues.append(f"{entry_id}: available command is empty")
        else:
            issues.extend(_validate_local_command_references(entry_id, text, repo_root))
    elif availability == "not_available":
        if not command.get("notAvailableReason"):
            issues.append(f"{entry_id}: unavailable command must include notAvailableReason")
    else:
        issues.append(f"{entry_id}: availability must be available or not_available")
    if not command.get("proofExpectation"):
        issues.append(f"{entry_id}: missing proofExpectation")
    return issues


def _validate_local_command_references(entry_id: str, command: str, repo_root: Path) -> list[str]:
    issues: list[str] = []
    parts = command.split()
    if not parts:
        return [f"{entry_id}: empty command"]
    executable = parts[0]
    if executable in {"python3", "bash", "git", "xcodebuild", "xcodegen"}:
        if shutil.which(executable) is None:
            issues.append(f"{entry_id}: executable not found on PATH: {executable}")
    elif executable.startswith("scripts/") or executable.startswith("tools/"):
        if not (repo_root / executable).exists():
            issues.append(f"{entry_id}: referenced executable is missing: {executable}")
    for token in parts[1:]:
        clean = token.rstrip(",")
        if clean.startswith(("scripts/", "tools/", "docs/", "Native/", "Packages/", "AppUI/")):
            if not (repo_root / clean).exists():
                issues.append(f"{entry_id}: referenced path is missing: {clean}")
    return issues


def _validate_golden_scenario(
    scenario: dict[str, Any],
    variants: dict[str, Any],
    default_assertions: dict[str, Any],
) -> list[str]:
    issues: list[str] = []
    scenario_id = scenario.get("id", "<missing-scenario>")
    if not scenario.get("publicReferenceFocus"):
        issues.append(f"{scenario_id}: missing publicReferenceFocus")
    if len(scenario.get("requiredPublicSourceRefs", [])) < 2:
        issues.append(f"{scenario_id}: expected at least two public source references")
    if len(scenario.get("requiredReusableAtoms", [])) < 3:
        issues.append(f"{scenario_id}: expected at least three reusable atoms")
    assertions = {**default_assertions, **scenario.get("sourceStateAssertions", {})}
    for state in REQUIRED_SOURCE_STATES:
        assertion = assertions.get(state)
        variant = variants.get(state, {})
        if not assertion:
            issues.append(f"{scenario_id}: missing assertion for {state}")
            continue
        route = assertion.get("expectedRoute")
        if state == "current":
            if route not in {"source-backed-reference-only", "candidate-reference-only"}:
                issues.append(f"{scenario_id}:{state}: current route must stay reference-only")
        elif route not in SAFE_NON_CURRENT_ROUTES:
            issues.append(f"{scenario_id}:{state}: unsafe route does not repair/review/fallback")
        if assertion.get("completionClaimAllowed") is not False:
            issues.append(f"{scenario_id}:{state}: completion claim must be forbidden")
        if assertion.get("finalUserPathClaimAllowed") is not False:
            issues.append(f"{scenario_id}:{state}: final user path claim must be forbidden")
        if variant.get("mayDriveRuntime") is False and assertion.get("artifactMayDriveRuntime") is not False:
            issues.append(f"{scenario_id}:{state}: blocked state may not drive runtime")
    return issues


def _validate_repair_fixture(fixture: dict[str, Any]) -> list[str]:
    issues: list[str] = []
    fixture_id = fixture.get("id", "<missing-fixture>")
    state = fixture.get("sourceState")
    route = fixture.get("expectedRepairRoute")
    if state not in REQUIRED_REPAIR_STATES:
        issues.append(f"{fixture_id}: unknown repair state {state}")
    if route not in SAFE_NON_CURRENT_ROUTES:
        issues.append(f"{fixture_id}: expectedRepairRoute must repair, review, quarantine, or fallback")
    if fixture.get("completionAllowed") is not False:
        issues.append(f"{fixture_id}: completionAllowed must be false")
    if fixture.get("silentWinnerSelectionAllowed") is not False:
        issues.append(f"{fixture_id}: silentWinnerSelectionAllowed must be false")
    if state in RUNTIME_BLOCKED_STATES and fixture.get("artifactMayDriveRuntime") is not False:
        issues.append(f"{fixture_id}: unsafe source state may not drive runtime")
    if state in {"revoked", "stale-critical"} and fixture.get("artifactQuarantined") is not True:
        issues.append(f"{fixture_id}: revoked or stale-critical artifact must be quarantined")
    if not fixture.get("repairRecommendation"):
        issues.append(f"{fixture_id}: missing repairRecommendation")
    return issues


def _known_issue_row(issue_id: str, validations: dict[str, dict[str, Any]]) -> dict[str, Any]:
    valid = all(result.get("valid") for result in validations.values())
    if issue_id == "AMB-ISSUE-2012":
        covered_by = ["commandMatrix", "goldenBenchmarks", "sourceStateRepair"]
        recommendation = "Keep open; M09 routes Source Atlas/R2 validation gaps; production R2, account entitlement, and release readiness remain outside M09."
    elif issue_id in {"AMB-ISSUE-2007", "AMB-ISSUE-2011"}:
        covered_by = ["commandMatrix", "sourceStateRepair"]
        recommendation = "Keep open; current evidence is local public/reference boundary and repair routing only, not privacy/legal or security release approval."
    elif issue_id in {"AMB-ISSUE-2004", "AMB-ISSUE-2005"}:
        covered_by = ["commandMatrix"]
        recommendation = "Keep open; M09 records account-related validation routes but does not implement or validate account provider flows."
    elif issue_id == "AMB-ISSUE-2001":
        covered_by = ["commandMatrix", "sourceStateRepair"]
        recommendation = "Keep open; M09 does not implement the canonical runtime command spine."
    else:
        covered_by = ["commandMatrix", "sourceStateRepair"]
        recommendation = "Keep open; M09 routes persistence/store-health evidence gaps but does not close import/export or store-health proof."
    return {
        "issueID": issue_id,
        "routeStatus": "proof_gap_routed" if valid else "repair_required",
        "coveredBy": covered_by,
        "closeKnownIssue": False,
        "repairRecommendation": recommendation,
        "validationSignals": {name: result.get("valid") for name, result in validations.items() if name in covered_by},
    }


def _summary(name: str, result: dict[str, Any]) -> dict[str, Any]:
    return {
        "name": name,
        "valid": result.get("valid"),
        "issueCount": len(result.get("issues", [])),
        "path": result.get("matrixPath") or result.get("fixturePath"),
    }


def _evidence_pack_markdown(pack: dict[str, Any]) -> str:
    lines = [
        "# Source Atlas M09 Release Evidence Pack",
        "",
        f"Status: {pack['status']}",
        "",
        "## Non-Claims",
    ]
    lines.extend(f"- {item}" for item in pack["nonClaims"])
    lines.extend(["", "## Validation Outputs"])
    lines.extend(f"- {name}: `{path}`" for name, path in pack["validationOutputs"].items())
    lines.extend(["", "## Known Risks"])
    lines.extend(f"- {item}" for item in pack["knownRisks"])
    lines.extend(["", "## Rollback Notes"])
    lines.extend(f"- {item}" for item in pack["rollbackNotes"])
    lines.append("")
    return "\n".join(lines)
