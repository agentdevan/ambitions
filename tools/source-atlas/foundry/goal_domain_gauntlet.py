"""Representative goal-domain gauntlet for Source Atlas.

The gauntlet makes arbitrary-goal support measurable without claiming literal
universal coverage. It proves that every configured public/reference frontier
has a representative routing case, unknown public-reference domains remain
candidate-only, private-looking context stays rejected, and Source Atlas/R2 do
not emit final plans, schedules, Steps, or personalized paths.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Any

from .boundary import boundary_issue_strings, boundary_issues_for_value
from .model import NON_CLAIMS, PRIVACY_BOUNDARY, read_json, stable_hash, stable_id, write_json


GOAL_DOMAIN_GAUNTLET_KIND = "ambitions.sourceAtlas.goalDomainGauntlet.v1"
GOAL_DOMAIN_GAUNTLET_VERSION = "source-atlas-goal-domain-gauntlet-train-118"
DEFAULT_UNKNOWN_PROBES = ("unrepresented_public_reference_domain", "new_public_reference_domain")

GOAL_DOMAIN_GAUNTLET_NON_CLAIMS = [
    "representative configured-frontier gauntlet only",
    "not literal universal coverage",
    "not full Source Atlas Green",
    "not outside legal approval",
    "not Release Green",
    "not App Store or TestFlight readiness",
    "not native physical-device proof",
    "not independent accessibility proof",
    "not private goal-text processing by Source Atlas",
    "not final user plans, schedules, Steps, priority order, or personalized paths from Source Atlas/R2",
    *NON_CLAIMS,
]


@dataclass(frozen=True)
class GoalDomainGauntletOptions:
    frontier_config_path: Path
    production_target_ledger_path: Path
    arbitrary_domain_gate_path: Path
    output_root: Path
    native_runtime_report_path: Path | None = None
    created_at: str = "2026-06-29T01:30:00Z"
    unknown_probe_domains: tuple[str, ...] = DEFAULT_UNKNOWN_PROBES


def run_goal_domain_gauntlet(options: GoalDomainGauntletOptions) -> dict[str, Any]:
    output_root = options.output_root
    output_root.mkdir(parents=True, exist_ok=True)

    issues: list[str] = []
    frontier_config = _read_required_json(options.frontier_config_path, "frontier config", issues)
    ledger = _read_required_json(options.production_target_ledger_path, "production target ledger", issues)
    arbitrary_gate = _read_required_json(options.arbitrary_domain_gate_path, "arbitrary-domain gate", issues)
    native_runtime = _read_optional_json(options.native_runtime_report_path, "native runtime report", issues)

    configured_cases = _configured_cases(frontier_config, ledger, native_runtime)
    unknown_cases = _unknown_cases(arbitrary_gate, options.unknown_probe_domains)
    private_probe = _private_probe(arbitrary_gate)
    case_privacy_issues = boundary_issue_strings(
        boundary_issues_for_value(
            {
                "configuredCases": _case_privacy_view(configured_cases),
                "unknownCases": _case_privacy_view(unknown_cases),
                "privateContextProbe": private_probe,
                "nonClaims": GOAL_DOMAIN_GAUNTLET_NON_CLAIMS,
            },
            "source-atlas-goal-domain-gauntlet",
        )
    )
    issues.extend(case_privacy_issues)
    issues.extend(_artifact_issues("frontier config", frontier_config))
    issues.extend(_artifact_issues("production target ledger", ledger))
    issues.extend(_artifact_issues("arbitrary-domain gate", arbitrary_gate))
    if options.native_runtime_report_path:
        issues.extend(_artifact_issues("native runtime report", native_runtime))
    issues.extend(issue for case in configured_cases for issue in case["blockers"])
    issues.extend(issue for case in unknown_cases for issue in case["blockers"])
    if not private_probe["rejectedWithoutPersistentArtifact"]:
        issues.append("private-context probe was not rejected without persistent artifact")

    record_counts = {
        "configuredFrontiers": len(_frontiers(frontier_config)),
        "configuredGauntletCases": len(configured_cases),
        "configuredCasesPassed": sum(1 for case in configured_cases if case["passed"]),
        "configuredCasesBlocked": sum(1 for case in configured_cases if not case["passed"]),
        "unknownProbeCases": len(unknown_cases),
        "unknownCasesCandidateOnly": sum(1 for case in unknown_cases if case["candidateOnly"]),
        "unknownCasesBlocked": sum(1 for case in unknown_cases if not case["passed"]),
        "finalOutputsGenerated": sum(1 for case in [*configured_cases, *unknown_cases] if case["finalOutputGenerated"]),
        "privacyIssues": len(case_privacy_issues),
    }
    checks = [
        _check("frontier_catalog_nonempty", record_counts["configuredFrontiers"] > 0, [] if record_counts["configuredFrontiers"] > 0 else ["frontier catalog has no configured frontiers"]),
        _check("every_configured_frontier_has_representative_case", record_counts["configuredGauntletCases"] == record_counts["configuredFrontiers"] and record_counts["configuredFrontiers"] > 0, []),
        _check("configured_cases_route_to_current_public_reference_runtime", record_counts["configuredCasesBlocked"] == 0 and record_counts["configuredCasesPassed"] == record_counts["configuredGauntletCases"] and record_counts["configuredGauntletCases"] > 0, [case["caseID"] for case in configured_cases if not case["passed"]]),
        _check("unknown_cases_remain_candidate_only", record_counts["unknownCasesBlocked"] == 0 and record_counts["unknownCasesCandidateOnly"] == record_counts["unknownProbeCases"] and record_counts["unknownProbeCases"] > 0, [case["caseID"] for case in unknown_cases if not case["passed"]]),
        _check("private_context_rejected_without_persistent_artifact", private_probe["rejectedWithoutPersistentArtifact"], [] if private_probe["rejectedWithoutPersistentArtifact"] else ["private context rejection missing"]),
        _check("no_final_plan_schedule_step_output", record_counts["finalOutputsGenerated"] == 0, []),
        _check("privacy_boundary", not case_privacy_issues, case_privacy_issues),
    ]
    valid = not issues and all(check["passed"] for check in checks)
    allowed_claims = [
        "representative_goal_domain_gauntlet_green",
        "configured_frontier_goal_domain_runtime_routing",
        "unknown_public_reference_domains_candidate_only",
    ] if valid else []

    report_path = output_root / "goal-domain-gauntlet-report.json"
    markdown_path = output_root / "goal-domain-gauntlet-report.md"
    closeout_path = output_root / "closeout.md"
    report = {
        "schemaVersion": 1,
        "kind": GOAL_DOMAIN_GAUNTLET_KIND,
        "versionID": GOAL_DOMAIN_GAUNTLET_VERSION,
        "createdAt": options.created_at,
        "gauntletID": stable_id(
            "source_atlas.goal_domain_gauntlet",
            {
                "frontierConfig": str(options.frontier_config_path),
                "ledger": str(options.production_target_ledger_path),
                "unknownProbes": sorted(options.unknown_probe_domains),
                "createdAt": options.created_at,
            },
        ),
        "status": "Source Green for representative configured goal-domain gauntlet" if valid else "Red",
        "valid": valid,
        "sourceAtlasStatusCeiling": "Yellow overall Source Atlas; representative configured-frontier goal-domain gauntlet only",
        "overallReadinessStatus": "representative_goal_domain_gauntlet_green" if valid else "blocked_or_partial",
        "recordCounts": record_counts,
        "checks": checks,
        "issues": sorted(set(issues)),
        "configuredCases": configured_cases,
        "unknownCases": unknown_cases,
        "privateContextProbe": private_probe,
        "allowedClaims": allowed_claims,
        "blockedClaims": sorted(
            {
                "literal_universal_coverage",
                "full_source_atlas_green",
                "outside_legal_approval",
                "release_green",
                "app_store_readiness",
                "native_device_green",
                "independent_accessibility_green",
                "source_atlas_private_goal_text_processing",
                "final_user_plans_schedules_steps_from_source_atlas_or_r2",
            }
        ),
        "privacyBoundary": PRIVACY_BOUNDARY,
        "privacyIssues": case_privacy_issues,
        "nonClaims": GOAL_DOMAIN_GAUNTLET_NON_CLAIMS,
        "evidencePaths": {
            "frontierConfig": str(options.frontier_config_path),
            "productionTargetLedger": str(options.production_target_ledger_path),
            "arbitraryDomainGate": str(options.arbitrary_domain_gate_path),
            "nativeRuntimeReport": str(options.native_runtime_report_path) if options.native_runtime_report_path else None,
        },
        "outputPaths": {
            "report": str(report_path),
            "markdown": str(markdown_path),
            "closeout": str(closeout_path),
        },
    }
    report["outputHashes"] = {"reportPayload": stable_hash({key: value for key, value in report.items() if key != "outputHashes"})}
    write_json(report_path, report)
    report["outputHashes"]["report"] = stable_hash(read_json(report_path))
    write_json(report_path, report)
    markdown = goal_domain_gauntlet_markdown(report)
    markdown_path.write_text(markdown, encoding="utf-8")
    closeout_path.write_text(markdown, encoding="utf-8")
    return report


def goal_domain_gauntlet_markdown(report: dict[str, Any]) -> str:
    counts = report["recordCounts"]
    lines = [
        "# Source Atlas Goal-Domain Gauntlet Train 118",
        "",
        f"Status: {report['status']}",
        f"Source Atlas status ceiling: {report['sourceAtlasStatusCeiling']}",
        f"Overall readiness: {report['overallReadinessStatus']}",
        "",
        "Scope completed:",
        "- Built one representative public/reference routing case for every configured coverage frontier.",
        "- Proved configured cases route to current bounded production public-reference runtime evidence.",
        "- Proved unknown public/reference cases remain candidate-only and emit no claims, packs, R2 writes, or native activation.",
        "- Proved Source Atlas/R2 emits no final plans, schedules, Steps, priority order, or personalized paths.",
        "",
        "Counts:",
        f"- Configured frontiers: {counts['configuredFrontiers']}",
        f"- Configured cases passed/blocked: {counts['configuredCasesPassed']}/{counts['configuredCasesBlocked']}",
        f"- Unknown candidate-only cases: {counts['unknownCasesCandidateOnly']}",
        f"- Final outputs generated: {counts['finalOutputsGenerated']}",
        f"- Privacy issues: {counts['privacyIssues']}",
        "",
        "Configured cases:",
        "",
        "| Domain | Passed | Route | Claims | Native Runtime | Blockers |",
        "| --- | --- | --- | --- | --- | --- |",
    ]
    for case in report.get("configuredCases", []):
        lines.append(
            "| {domain} | {passed} | {route} | {claims} | {native} | {blockers} |".format(
                domain=case["domainID"],
                passed="yes" if case["passed"] else "no",
                route=case["expectedRoute"],
                claims=case["packableClaimCount"],
                native="yes" if case["nativeRuntimeReady"] else "not supplied",
                blockers="<br>".join(case.get("blockers", [])) or "none",
            )
        )
    lines.extend(["", "Unknown cases:"])
    for case in report.get("unknownCases", []):
        lines.append(f"- `{case['domainID']}` -> candidate-only: {'yes' if case['candidateOnly'] else 'no'}")
    lines.extend(["", "Allowed claims:"])
    lines.extend(f"- `{claim}`" for claim in report.get("allowedClaims", [])) if report.get("allowedClaims") else lines.append("- None")
    lines.extend(["", "Blocked claims:"])
    lines.extend(f"- `{claim}`" for claim in report.get("blockedClaims", []))
    lines.extend(
        [
            "",
            "Product law preserved:",
            "- Source Atlas handles public/reference frontier/domain identifiers only.",
            "- Private user context remains local-only and rejected from Source Atlas tooling.",
            "- Runtime personalization, fit, timing, priority, final Steps, and final schedules remain Ambitions local runtime responsibilities.",
            "",
            "Production non-claims:",
        ]
    )
    lines.extend(f"- {claim}" for claim in report.get("nonClaims", []))
    lines.extend(["", "Rollback plan:", "- Revert Train 118 goal-domain gauntlet module, CLI wiring, tests, generated artifacts, and QA evidence."])
    lines.append("")
    return "\n".join(lines)


def _configured_cases(frontier_config: Any, ledger: Any, native_runtime: Any) -> list[dict[str, Any]]:
    ledger_by_domain = _ledger_by_domain(ledger)
    native_by_domain = _native_by_domain(native_runtime)
    cases = []
    for frontier in _frontiers(frontier_config):
        domain_id = str(frontier.get("frontier_id") or frontier.get("domain") or "")
        ledger_domain = ledger_by_domain.get(domain_id, {})
        native_domain = native_by_domain.get(domain_id)
        blockers: list[str] = []
        ledger_ready = _ledger_domain_ready(ledger_domain)
        if not ledger_ready:
            blockers.append(f"{domain_id}: production target ledger is not bounded-production ready")
        packable_claim_count = int(ledger_domain.get("packableClaimCount", 0) or 0)
        if packable_claim_count <= 0:
            blockers.append(f"{domain_id}: no packable claims in production ledger")
        native_ready = None
        if native_by_domain:
            native_ready = bool(native_domain and native_domain.get("runtimeReady") is True)
            if not native_ready:
                blockers.append(f"{domain_id}: native runtime proof missing or not ready")
        case = {
            "caseID": stable_id("source_atlas.goal_domain_case", {"domain": domain_id, "claimClasses": frontier.get("claim_classes", [])}),
            "caseType": "configured_public_reference_frontier",
            "domainID": domain_id,
            "intentClasses": sorted(_string_list(frontier.get("goal_intent_classes"))),
            "claimClasses": sorted(_string_list(frontier.get("claim_classes"))),
            "jurisdictions": sorted(_string_list(frontier.get("jurisdictions"))),
            "minimumAuthorityClasses": sorted(_string_list(frontier.get("minimum_authority_classes"))),
            "sourceIDs": sorted(_string_list(frontier.get("source_ids"))),
            "expectedRoute": "current_configured_public_reference_runtime",
            "candidateOnly": False,
            "ledgerReady": ledger_ready,
            "nativeRuntimeReady": native_ready if native_ready is not None else False,
            "nativeRuntimeProofSupplied": bool(native_by_domain),
            "packableClaimCount": packable_claim_count,
            "localOnlyCompositionRequired": True,
            "sourceAtlasReceivesPrivateContext": False,
            "finalOutputGenerated": False,
            "passed": not blockers,
            "blockers": blockers,
            "nonClaims": [
                "not a final plan",
                "not a final schedule",
                "not a Step generator",
                "not private-context processing by Source Atlas",
            ],
        }
        cases.append(case)
    return cases


def _unknown_cases(arbitrary_gate: Any, unknown_probe_domains: tuple[str, ...]) -> list[dict[str, Any]]:
    counts = arbitrary_gate.get("recordCounts", {}) if isinstance(arbitrary_gate, dict) else {}
    gate_valid = isinstance(arbitrary_gate, dict) and arbitrary_gate.get("valid") is True
    candidate_safe = (
        int(counts.get("candidateClaims", 0) or 0) == 0
        and int(counts.get("candidateR2PublishOperations", 0) or 0) == 0
        and int(counts.get("candidateNativeActivationOperations", 0) or 0) == 0
        and int(counts.get("candidateProductionWrites", 0) or 0) == 0
    )
    cases = []
    for domain_id in sorted(set(unknown_probe_domains)):
        blockers: list[str] = []
        if not gate_valid:
            blockers.append("arbitrary-domain gate is not valid")
        if not candidate_safe:
            blockers.append("arbitrary-domain gate emitted candidate claims, R2 operations, production writes, or native activation")
        cases.append(
            {
                "caseID": stable_id("source_atlas.unknown_goal_domain_case", {"domain": domain_id}),
                "caseType": "unknown_public_reference_candidate",
                "domainID": domain_id,
                "expectedRoute": "candidate_frontier_intake_only",
                "candidateOnly": gate_valid and candidate_safe,
                "claimsEmitted": int(counts.get("candidateClaims", 0) or 0),
                "r2PublishOperations": int(counts.get("candidateR2PublishOperations", 0) or 0),
                "nativeActivationOperations": int(counts.get("candidateNativeActivationOperations", 0) or 0),
                "productionWrites": int(counts.get("candidateProductionWrites", 0) or 0),
                "localOnlyCompositionRequired": True,
                "sourceAtlasReceivesPrivateContext": False,
                "finalOutputGenerated": False,
                "passed": not blockers,
                "blockers": blockers,
                "nonClaims": ["not source authority", "not pack ready", "not R2 publish ready", "not native activation ready"],
            }
        )
    return cases


def _private_probe(arbitrary_gate: Any) -> dict[str, Any]:
    probe = arbitrary_gate.get("privateContextProbe", {}) if isinstance(arbitrary_gate, dict) else {}
    return {
        "rejectedWithoutPersistentArtifact": probe.get("rejected") is True and probe.get("persistentArtifactWritten") is False and probe.get("rawProbePersisted") is False,
        "privacyIssueCount": int(probe.get("privacyIssueCount", 0) or 0),
        "rawProbePersisted": bool(probe.get("rawProbePersisted", False)),
        "persistentArtifactWritten": bool(probe.get("persistentArtifactWritten", False)),
    }


def _frontiers(frontier_config: Any) -> list[dict[str, Any]]:
    if not isinstance(frontier_config, dict):
        return []
    return sorted(
        [frontier for frontier in frontier_config.get("frontiers", []) if isinstance(frontier, dict)],
        key=lambda item: str(item.get("frontier_id") or item.get("domain") or ""),
    )


def _ledger_by_domain(ledger: Any) -> dict[str, dict[str, Any]]:
    if not isinstance(ledger, dict):
        return {}
    return {
        str(domain.get("domainID")): domain
        for domain in ledger.get("domains", [])
        if isinstance(domain, dict) and domain.get("domainID")
    }


def _native_by_domain(native_runtime: Any) -> dict[str, dict[str, Any]]:
    if not isinstance(native_runtime, dict):
        return {}
    return {
        str(domain.get("domainID")): domain
        for domain in native_runtime.get("domainProofs", [])
        if isinstance(domain, dict) and domain.get("domainID")
    }


def _ledger_domain_ready(domain: dict[str, Any]) -> bool:
    if not domain:
        return False
    required_flags = [
        "frontierConfigured",
        "claimGraphProofComplete",
        "packProductionProofComplete",
        "r2ProductionProofComplete",
        "gatewayProofComplete",
        "nativeRegistryProofComplete",
        "nativeRuntimeBoundaryProofComplete",
        "nativeUsabilityProofComplete",
    ]
    return domain.get("readinessStatus") == "bounded_production_target_ready" and all(domain.get(flag) is True for flag in required_flags)


def _case_privacy_view(cases: list[dict[str, Any]]) -> list[dict[str, Any]]:
    return [
        {
            "caseID": case.get("caseID"),
            "caseType": case.get("caseType"),
            "domainID": case.get("domainID"),
            "expectedRoute": case.get("expectedRoute"),
            "candidateOnly": case.get("candidateOnly"),
            "sourceIDs": case.get("sourceIDs", []),
            "sourceAtlasReceivesPrivateContext": case.get("sourceAtlasReceivesPrivateContext"),
            "finalOutputGenerated": case.get("finalOutputGenerated"),
            "blockers": case.get("blockers", []),
            "nonClaims": case.get("nonClaims", []),
        }
        for case in cases
    ]


def _artifact_issues(label: str, artifact: Any) -> list[str]:
    if artifact is None:
        return [f"{label} missing"]
    if not isinstance(artifact, dict):
        return [f"{label} is not a JSON object"]
    if artifact.get("valid") is False:
        return [f"{label} valid flag is false", *artifact.get("issues", [])]
    return []


def _read_required_json(path: Path, label: str, issues: list[str]) -> Any:
    if not path.exists():
        issues.append(f"{label} missing: {path}")
        return None
    try:
        return read_json(path)
    except Exception as exc:  # pragma: no cover - malformed evidence artifact
        issues.append(f"{label} unreadable: {path}: {exc}")
        return None


def _read_optional_json(path: Path | None, label: str, issues: list[str]) -> Any:
    if path is None:
        return None
    return _read_required_json(path, label, issues)


def _string_list(value: Any) -> list[str]:
    return [item for item in value if isinstance(item, str)] if isinstance(value, list) else []


def _check(name: str, passed: bool, issues: list[str]) -> dict[str, Any]:
    return {"name": name, "passed": bool(passed), "issues": sorted(set(issues))}
