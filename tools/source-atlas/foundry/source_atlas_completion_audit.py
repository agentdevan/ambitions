"""Goal-level completion audit for Source Atlas.

This module reconciles the current Source Atlas production, R2, native,
legal/terms, and arbitrary-domain evidence into one deterministic gap map. It
does not run live harvests, mutate registries, publish R2 objects, deploy
Workers, mutate native runtime state, or generate final user outputs.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Any

from .boundary import boundary_issue_strings, boundary_issues_for_value
from .model import NON_CLAIMS, PRIVACY_BOUNDARY, read_json, stable_hash, stable_id, write_json


SOURCE_ATLAS_COMPLETION_AUDIT_KIND = "ambitions.sourceAtlas.completionAudit.v1"
SOURCE_ATLAS_COMPLETION_AUDIT_VERSION = "source-atlas-completion-audit-train-132"

STATUS_ORDER = {
    "proven_current": 0,
    "source_green_scoped": 1,
    "yellow_needs_stronger_proof": 2,
    "blocked_missing_artifact": 3,
    "red_boundary_violation": 4,
}

FORBIDDEN_ALLOWED_CLAIMS = {
    "full_source_atlas_green",
    "release_green",
    "runtime_release_green",
    "app_store_readiness",
    "testflight_readiness",
    "outside_legal_approval",
    "literal_universal_coverage",
    "universal_coverage",
    "automatic_r2_write_without_execute_budget_approval",
    "source_atlas_private_goal_text_processing",
    "final_user_plans_schedules_steps_from_source_atlas_or_r2",
}

COMPLETION_NON_CLAIMS = [
    "goal-level completion audit and gap router only",
    "not full Source Atlas Green",
    "not Release Green",
    "not App Store or TestFlight readiness",
    "not outside legal approval",
    "not literal universal coverage",
    "not independent accessibility proof",
    "not native physical-device proof",
    "not an automatic production R2 writer",
    "not uncontrolled live harvest",
    "not a hosted planner, profile engine, or cloud personalization system",
    "not final user plans, schedules, Steps, priority order, recovery paths, or personalized paths from Source Atlas/R2",
    *NON_CLAIMS,
]

COMPLETION_REQUIREMENTS = [
    {
        "requirementID": "governance_registries",
        "label": "Source, legal/terms, and API governance registries",
        "objectiveArea": "production_target",
    },
    {
        "requirementID": "autonomous_supervised_operations",
        "label": "Autonomous supervised production operations",
        "objectiveArea": "production_target",
    },
    {
        "requirementID": "autonomous_domain_expansion",
        "label": "Autonomous discovery/domain expansion through governed frontiers",
        "objectiveArea": "universal_coverage_boundary",
    },
    {
        "requirementID": "live_transport_and_harvest",
        "label": "Live transport and governed harvest proof",
        "objectiveArea": "live_transport",
    },
    {
        "requirementID": "claim_graph_packability",
        "label": "Claim graph, provenance, and packability proof",
        "objectiveArea": "production_target",
    },
    {
        "requirementID": "pack_r2_production",
        "label": "Pack production and R2 upload/readback/checksum proof",
        "objectiveArea": "r2_write",
    },
    {
        "requirementID": "promotion_execute_control",
        "label": "Promotion control, execute gates, and safe command queue",
        "objectiveArea": "r2_write",
    },
    {
        "requirementID": "native_fetch_cache_verify",
        "label": "Native fetch/cache/verify/quarantine/LKG/offline behavior",
        "objectiveArea": "runtime_release_green",
    },
    {
        "requirementID": "runtime_composition_inspection",
        "label": "Local-only runtime composition and source inspection boundary",
        "objectiveArea": "runtime_release_green",
    },
    {
        "requirementID": "legal_terms_approval",
        "label": "Legal/terms approval posture",
        "objectiveArea": "legal_approval",
    },
    {
        "requirementID": "security_privacy_boundary",
        "label": "No-private-graph egress and unsafe-output boundary",
        "objectiveArea": "production_target",
    },
    {
        "requirementID": "release_readiness",
        "label": "Runtime/release Green, device, accessibility, and App Store proof",
        "objectiveArea": "runtime_release_green",
    },
    {
        "requirementID": "universal_coverage_claim_control",
        "label": "Universal-coverage claim control",
        "objectiveArea": "universal_coverage_boundary",
    },
    {
        "requirementID": "near_universal_launch_floor",
        "label": "Near-universal launch-floor counters and proof ledger",
        "objectiveArea": "universal_coverage_boundary",
    },
    {
        "requirementID": "completion_claim_control",
        "label": "Full-goal completion claim control",
        "objectiveArea": "production_target",
    },
]


@dataclass(frozen=True)
class SourceAtlasCompletionAuditOptions:
    production_supervisor_path: Path
    production_sweep_path: Path
    production_finish_line_gate_path: Path
    production_recertification_path: Path
    production_target_ledger_path: Path
    arbitrary_domain_gate_path: Path
    goal_domain_gauntlet_path: Path
    output_root: Path
    source_lane_registry_path: Path | None = None
    legal_terms_registry_path: Path | None = None
    api_governance_registry_path: Path | None = None
    native_runtime_report_path: Path | None = None
    release_proof_packet_path: Path | None = None
    legal_approval_packet_path: Path | None = None
    owner_approval_path: Path | None = None
    launch_floor_ledger_path: Path | None = None
    created_at: str = "2026-06-29T04:45:00Z"
    run_label: str = "current"


def run_source_atlas_completion_audit(options: SourceAtlasCompletionAuditOptions) -> dict[str, Any]:
    output_root = options.output_root
    output_root.mkdir(parents=True, exist_ok=True)

    issues: list[str] = []
    artifacts = {
        "productionSupervisor": _read_required_json(options.production_supervisor_path, "production supervisor", issues),
        "productionSweep": _read_required_json(options.production_sweep_path, "production sweep", issues),
        "productionFinishLineGate": _read_required_json(options.production_finish_line_gate_path, "production finish-line gate", issues),
        "productionRecertification": _read_required_json(options.production_recertification_path, "production recertification", issues),
        "productionTargetLedger": _read_required_json(options.production_target_ledger_path, "production target ledger", issues),
        "arbitraryDomainGate": _read_required_json(options.arbitrary_domain_gate_path, "arbitrary domain gate", issues),
        "goalDomainGauntlet": _read_required_json(options.goal_domain_gauntlet_path, "goal domain gauntlet", issues),
        "sourceLaneRegistry": _read_optional_json(options.source_lane_registry_path, "source lane registry", issues),
        "legalTermsRegistry": _read_optional_json(options.legal_terms_registry_path, "legal/terms registry", issues),
        "apiGovernanceRegistry": _read_optional_json(options.api_governance_registry_path, "API governance registry", issues),
        "nativeRuntimeReport": _read_optional_json(options.native_runtime_report_path, "native runtime report", issues),
        "releaseProofPacket": _read_optional_json(options.release_proof_packet_path, "release proof packet", issues),
        "legalApprovalPacket": _read_optional_json(options.legal_approval_packet_path, "legal approval packet", issues),
        "ownerApproval": _read_optional_json(options.owner_approval_path, "owner approval artifact", issues),
        "launchFloorLedger": _read_optional_json(options.launch_floor_ledger_path, "launch-floor ledger", issues),
    }
    input_paths = _input_paths(options)
    input_privacy_issues = boundary_issue_strings(
        boundary_issues_for_value(
            {
                "runLabel": options.run_label,
                "inputPaths": input_paths,
            },
            "source-atlas-completion-audit-input",
        )
    )
    issues.extend(input_privacy_issues)

    overclaim_issues = _overclaim_issues(artifacts)
    privacy_issues = _artifact_privacy_issues(artifacts)
    requirements = _requirements(artifacts, overclaim_issues, privacy_issues)
    next_work_queue = _next_work_queue(requirements, artifacts)
    counts = _record_counts(requirements, next_work_queue, artifacts, privacy_issues, overclaim_issues)
    checks = _checks(requirements, artifacts, input_privacy_issues, privacy_issues, overclaim_issues)
    issues.extend(overclaim_issues)
    issues.extend(privacy_issues)
    issues.extend(issue for check in checks if not check["passed"] for issue in check["issues"] if check["severity"] == "red")

    valid = not input_privacy_issues and not privacy_issues and not overclaim_issues and all(
        check["passed"] or check["severity"] != "red" for check in checks
    )
    overall_status = _overall_status(requirements, valid)
    completion_readiness = _completion_readiness(requirements, valid)

    requirements_path = output_root / "completion-requirements.json"
    queue_path = output_root / "next-work-queue.json"
    report_path = output_root / "source-atlas-completion-audit-report.json"
    markdown_path = output_root / "source-atlas-completion-audit-report.md"
    closeout_path = output_root / "closeout.md"

    write_json(requirements_path, {"schemaVersion": 1, "requirements": requirements})
    write_json(queue_path, {"schemaVersion": 1, "nextWorkQueue": next_work_queue})

    report = {
        "schemaVersion": 1,
        "kind": SOURCE_ATLAS_COMPLETION_AUDIT_KIND,
        "versionID": SOURCE_ATLAS_COMPLETION_AUDIT_VERSION,
        "createdAt": options.created_at,
        "runLabel": options.run_label,
        "auditID": stable_id(
            "source_atlas.completion_audit",
            {
                "createdAt": options.created_at,
                "runLabel": options.run_label,
                "inputHashes": _input_hashes(artifacts),
            },
        ),
        "status": overall_status,
        "valid": valid,
        "goalComplete": False,
        "goalCompletionClaimed": False,
        "completionClaimAllowed": False,
        "sourceAtlasStatusCeiling": "Yellow overall Source Atlas; scoped Source/Native/R2 Green may exist only where evidence below proves it",
        "overallReadinessStatus": completion_readiness["overallReadinessStatus"],
        "completionReadiness": completion_readiness,
        "recordCounts": counts,
        "checks": checks,
        "issues": sorted(set(issues)),
        "requirementDefinitions": COMPLETION_REQUIREMENTS,
        "requirementEvaluations": requirements,
        "nextWorkQueue": next_work_queue,
        "allowedClaims": _allowed_claims(valid),
        "blockedClaims": _blocked_claims(),
        "privacyBoundary": PRIVACY_BOUNDARY,
        "privacyIssues": sorted(set([*input_privacy_issues, *privacy_issues])),
        "overclaimIssues": sorted(set(overclaim_issues)),
        "productLaw": {
            "r2Role": "public/reference/freshness infrastructure only",
            "privateGraphEgressAllowed": False,
            "finalPersonalizedOutputsAllowed": False,
            "literalUniversalCoverageAllowed": False,
            "sourceAtlasProductCenterAllowed": False,
        },
        "evidencePaths": input_paths,
        "nonClaims": COMPLETION_NON_CLAIMS,
        "outputPaths": {
            "report": str(report_path),
            "markdown": str(markdown_path),
            "closeout": str(closeout_path),
            "requirements": str(requirements_path),
            "nextWorkQueue": str(queue_path),
        },
    }
    report["outputHashes"] = {
        "requirements": stable_hash(read_json(requirements_path)),
        "nextWorkQueue": stable_hash(read_json(queue_path)),
        "reportPayload": stable_hash({key: value for key, value in report.items() if key != "outputHashes"}),
    }
    write_json(report_path, report)
    report["outputHashes"]["report"] = stable_hash(read_json(report_path))
    write_json(report_path, report)
    markdown = source_atlas_completion_audit_markdown(report)
    markdown_path.write_text(markdown, encoding="utf-8")
    closeout_path.write_text(markdown, encoding="utf-8")
    return report


def source_atlas_completion_audit_markdown(report: dict[str, Any]) -> str:
    counts = report["recordCounts"]
    lines = [
        "# Source Atlas Completion Audit Train 132",
        "",
        f"Status: {report['status']}",
        f"Source Atlas status ceiling: {report['sourceAtlasStatusCeiling']}",
        f"Overall readiness: {report['overallReadinessStatus']}",
        f"Goal complete: {str(report['goalComplete']).lower()}",
        f"Completion claim allowed: {str(report['completionClaimAllowed']).lower()}",
        "",
        "Scope completed:",
        "- Reconciled production supervisor, production sweep, finish-line, recertification, target ledger, arbitrary-domain, gauntlet, native, legal, owner approval, and governance-registry evidence into one requirement audit.",
        "- Emitted deterministic requirement statuses and a next-work queue for the remaining production/legal/R2/native/release/universal-coverage gates.",
        "- Blocked full Source Atlas Green, Release Green, outside legal approval, literal universal coverage, automatic R2 writes, and final personalized outputs unless separately proven.",
        "",
        "Counts:",
        f"- Requirements: {counts['requirements']}",
        f"- Proven current: {counts['provenCurrentRequirements']}",
        f"- Scoped Source/Native/R2 Green: {counts['sourceGreenScopedRequirements']}",
        f"- Yellow requirements: {counts['yellowRequirements']}",
        f"- Blocked requirements: {counts['blockedRequirements']}",
        f"- Red requirements: {counts['redRequirements']}",
        f"- Next work items: {counts['nextWorkItems']}",
        f"- Launch-floor targets met: {counts.get('launchFloorTargetsMet', 0)}/{counts.get('launchFloorTargets', 0)}",
        f"- Privacy issues: {counts['privacyIssues']}",
        f"- Overclaim issues: {counts['overclaimIssues']}",
        "",
        "Requirement map:",
        "",
        "| Requirement | Status | Proof scope | Remaining gap |",
        "| --- | --- | --- | --- |",
    ]
    for requirement in report.get("requirementEvaluations", []):
        lines.append(
            "| {label} | `{status}` | {scope} | {gap} |".format(
                label=requirement["label"],
                status=requirement["status"],
                scope=requirement["proofScope"],
                gap="<br>".join(requirement.get("gaps", [])) or "none",
            )
        )
    lines.extend(["", "Next work queue:", ""])
    if report.get("nextWorkQueue"):
        lines.extend(
            "- `{workItemID}` {title} ({status}, {priority})".format(**item)
            for item in report["nextWorkQueue"]
        )
    else:
        lines.append("- None")
    lines.extend(["", "Allowed claims:"])
    lines.extend(f"- `{claim}`" for claim in report.get("allowedClaims", [])) if report.get("allowedClaims") else lines.append("- None")
    lines.extend(["", "Blocked claims:"])
    lines.extend(f"- `{claim}`" for claim in report.get("blockedClaims", []))
    lines.extend(
        [
            "",
            "Product law preserved:",
            "- R2 remains public/reference/freshness infrastructure only.",
            "- The audit reads proof artifacts and registries; it does not send or store private user context.",
            "- No private goal, capture, schedule, proof, receipt, account ID, device ID, behavior history, inferred priority, or private graph data is introduced.",
            "- Source Atlas/R2 does not generate final plans, schedules, Steps, priority order, recovery paths, or personalized paths.",
            "",
            "Validation not run by this audit:",
            "- No live harvest was run.",
            "- No production R2 write was run.",
            "- No Worker deploy was run.",
            "- No native XCTest/build-for-testing was run by the audit itself.",
            "- No outside legal approval, Release Green, App Store readiness, independent accessibility proof, physical-device proof, or literal universal coverage was claimed.",
            "",
            "Architecture closeout:",
            "- Final Architecture Tree inspected: yes.",
            "- Canonical owners touched: none in app source; tooling/evidence only under tools/source-atlas and docs/qa/source-atlas.",
            "- Non-canonical owners touched: none.",
            "- Files moved or created: completion audit module, CLI command, focused tests, generated artifacts, and QA evidence.",
            "- Old/non-canonical paths removed: none.",
            "- Compatibility shims left behind: none.",
            "- Yellow architecture debt remaining: release proof, outside legal artifact, independent accessibility/device proof, and literal universal coverage remain separate gates.",
            "- No equivalent folder/path interpretation was used.",
            "",
            "Production non-claims:",
        ]
    )
    lines.extend(f"- {claim}" for claim in report.get("nonClaims", []))
    lines.extend(
        [
            "",
            "Rollback plan:",
        "- Revert Train 132 completion audit module, CLI wiring, focused tests, generated artifacts, and QA evidence.",
            "- Continue using the production supervisor, sweep, and finish-line reports directly if completion-audit routing regresses.",
            "",
        ]
    )
    return "\n".join(lines)


def _requirements(artifacts: dict[str, Any], overclaim_issues: list[str], privacy_issues: list[str]) -> list[dict[str, Any]]:
    evaluations = [
        _requirement_governance(artifacts),
        _requirement_supervisor(artifacts),
        _requirement_domain_expansion(artifacts),
        _requirement_live_transport(artifacts),
        _requirement_claim_packability(artifacts),
        _requirement_pack_r2(artifacts),
        _requirement_promotion_control(artifacts),
        _requirement_native_fetch_cache(artifacts),
        _requirement_runtime_inspection(artifacts),
        _requirement_legal_terms(artifacts),
        _requirement_security_privacy(artifacts, privacy_issues),
        _requirement_release_readiness(artifacts),
        _requirement_universal_coverage(artifacts),
        _requirement_launch_floor(artifacts),
        _requirement_completion_claim(overclaim_issues, privacy_issues),
    ]
    return sorted(evaluations, key=lambda item: [req["requirementID"] for req in COMPLETION_REQUIREMENTS].index(item["requirementID"]))


def _requirement_governance(artifacts: dict[str, Any]) -> dict[str, Any]:
    source_registry = artifacts["sourceLaneRegistry"]
    legal_registry = artifacts["legalTermsRegistry"]
    api_registry = artifacts["apiGovernanceRegistry"]
    source_count = len(source_registry.get("source_lanes", [])) if isinstance(source_registry, dict) else 0
    license_count = len(legal_registry.get("licenses", [])) if isinstance(legal_registry, dict) else 0
    api_count = len(api_registry.get("api_policies", [])) if isinstance(api_registry, dict) else 0
    missing = []
    if source_count <= 0:
        missing.append("source lane registry missing or empty")
    if license_count <= 0:
        missing.append("legal/terms registry missing or empty")
    if api_count <= 0:
        missing.append("API governance registry missing or empty")
    status = "proven_current" if not missing else "blocked_missing_artifact"
    return _evaluation(
        "governance_registries",
        status,
        proof_scope=f"{source_count} source lanes, {license_count} licenses, {api_count} API policies loaded" if not missing else "registry inputs incomplete",
        evidence=["sourceLaneRegistry", "legalTermsRegistry", "apiGovernanceRegistry"],
        gaps=missing,
        next_actions=["Keep review expiry and source-specific approval artifacts current."],
    )


def _requirement_supervisor(artifacts: dict[str, Any]) -> dict[str, Any]:
    supervisor = artifacts["productionSupervisor"]
    if _valid_report(supervisor) and _claim(supervisor, "supervised_autonomous_source_atlas_work_loop_green"):
        return _evaluation(
            "autonomous_supervised_operations",
            "proven_current",
            "supervised autonomous Source Atlas work loop with safe local/candidate actions and held write gates",
            evidence=["productionSupervisor"],
            next_actions=["Promote only through the explicit execute/approval gates already emitted by supervisor and promotion runner."],
        )
    return _evaluation(
        "autonomous_supervised_operations",
        "blocked_missing_artifact",
        "supervisor proof missing or invalid",
        evidence=["productionSupervisor"],
        gaps=["current autonomous production supervisor proof is missing, invalid, or lacks the expected scoped claim"],
        next_actions=["Rerun autonomous-production-supervisor with current production evidence."],
    )


def _requirement_domain_expansion(artifacts: dict[str, Any]) -> dict[str, Any]:
    arbitrary = artifacts["arbitraryDomainGate"]
    gauntlet = artifacts["goalDomainGauntlet"]
    if (
        _valid_report(arbitrary)
        and _valid_report(gauntlet)
        and _claim(arbitrary, "governed_arbitrary_public_reference_domain_handling")
        and _claim(gauntlet, "unknown_public_reference_domains_candidate_only")
    ):
        return _evaluation(
            "autonomous_domain_expansion",
            "source_green_scoped",
            "unknown public/reference domains route to candidate-only frontier intake; configured domains route to bounded current public reference runtime",
            evidence=["arbitraryDomainGate", "goalDomainGauntlet"],
            gaps=["candidate intake is not authority, claim, pack, R2 publish, or native activation"],
            next_actions=["Review candidate domains, approve source lanes/legal/API posture, then rebuild claim/pack/R2/native proof per domain."],
        )
    return _evaluation(
        "autonomous_domain_expansion",
        "yellow_needs_stronger_proof",
        "domain expansion proof incomplete",
        evidence=["arbitraryDomainGate", "goalDomainGauntlet"],
        gaps=["arbitrary-domain or gauntlet evidence is missing, invalid, or does not keep unknown domains candidate-only"],
        next_actions=["Rerun arbitrary-domain-handling-gate and goal-domain-gauntlet."],
    )


def _requirement_live_transport(artifacts: dict[str, Any]) -> dict[str, Any]:
    finish = artifacts["productionFinishLineGate"]
    recertification = artifacts["productionRecertification"]
    if _valid_report(finish) and _claim(finish, "bounded_live_transport") and _valid_report(recertification):
        return _evaluation(
            "live_transport_and_harvest",
            "source_green_scoped",
            "bounded live transport is proven for configured production frontiers",
            evidence=["productionFinishLineGate", "productionRecertification"],
            gaps=["uncontrolled/high-volume live harvest remains blocked by API governance and execute gates"],
            next_actions=["For each new source, require live flag, execute flag, key/rate/budget policy, and fixture fallback proof."],
        )
    return _evaluation(
        "live_transport_and_harvest",
        "yellow_needs_stronger_proof",
        "live transport proof incomplete",
        evidence=["productionFinishLineGate", "productionRecertification"],
        gaps=["bounded live transport claim missing or recertification invalid"],
        next_actions=["Rerun bounded live transport and recertification gates."],
    )


def _requirement_claim_packability(artifacts: dict[str, Any]) -> dict[str, Any]:
    sweep = artifacts["productionSweep"]
    finish = artifacts["productionFinishLineGate"]
    pack_reports = _count(sweep, "packReportsValid")
    domains_ready = _count(sweep, "domainsReady")
    if _valid_report(sweep) and _valid_report(finish) and pack_reports > 0 and _claim(finish, "bounded_configured_production_target"):
        return _evaluation(
            "claim_graph_packability",
            "source_green_scoped",
            f"{pack_reports} configured pack reports valid across {domains_ready} ready domains",
            evidence=["productionSweep", "productionFinishLineGate"],
            gaps=["claim/provenance completeness is bounded to configured production target frontiers"],
            next_actions=["Keep missing provenance, stale-critical, restricted, and unresolved-conflict claims blocked from packs."],
        )
    return _evaluation(
        "claim_graph_packability",
        "yellow_needs_stronger_proof",
        "claim/packability proof incomplete",
        evidence=["productionSweep", "productionFinishLineGate"],
        gaps=["pack reports or configured production target proof are missing"],
        next_actions=["Rerun pack production and finish-line gate."],
    )


def _requirement_pack_r2(artifacts: dict[str, Any]) -> dict[str, Any]:
    sweep = artifacts["productionSweep"]
    finish = artifacts["productionFinishLineGate"]
    r2_valid = _count(sweep, "r2ReportsValid")
    remote_reconciled = _count(sweep, "remoteR2UploadsReconciled")
    if _valid_report(sweep) and _valid_report(finish) and _claim(finish, "production_r2_write_readback") and remote_reconciled > 0:
        return _evaluation(
            "pack_r2_production",
            "source_green_scoped",
            f"{remote_reconciled} remote R2 upload/readback reports reconciled; {r2_valid} R2 reports valid",
            evidence=["productionSweep", "productionFinishLineGate", "ownerApproval"],
            gaps=["new production R2 writes remain execute-gated and are not performed by this audit"],
            next_actions=["When a new write is needed, use owner approval, legal packet, remote write preflight, upload/readback/SHA-256, revocation, and rollback proof."],
        )
    return _evaluation(
        "pack_r2_production",
        "yellow_needs_stronger_proof",
        "R2 production proof incomplete",
        evidence=["productionSweep", "productionFinishLineGate", "ownerApproval"],
        gaps=["production R2 upload/readback claim or remote reconciliation count missing"],
        next_actions=["Rerun production sweep and R2 publisher proof in the approved environment."],
    )


def _requirement_promotion_control(artifacts: dict[str, Any]) -> dict[str, Any]:
    supervisor = artifacts["productionSupervisor"]
    promotion_count = _count(supervisor, "promotionDecisions")
    if _valid_report(supervisor) and promotion_count > 0 and _claim(supervisor, "promotion_control_integrated"):
        return _evaluation(
            "promotion_execute_control",
            "proven_current",
            f"{promotion_count} promotion decisions emitted with remote/native/final outputs held at zero",
            evidence=["productionSupervisor"],
            next_actions=["Execute only the emitted command queue after explicit owner/legal/API/R2 gates pass."],
        )
    return _evaluation(
        "promotion_execute_control",
        "yellow_needs_stronger_proof",
        "promotion control proof incomplete",
        evidence=["productionSupervisor"],
        gaps=["promotion runner is not integrated or no promotion decisions were emitted"],
        next_actions=["Rerun autonomous-production-supervisor with owner approval and legal packet inputs."],
    )


def _requirement_native_fetch_cache(artifacts: dict[str, Any]) -> dict[str, Any]:
    native = artifacts["nativeRuntimeReport"]
    if (
        isinstance(native, dict)
        and _native_proof(native, "nativeOfflineNoAccountProof")
        and _native_proof(native, "r2RequestPrivacyProof")
        and _native_proof(native, "lkgRollbackProof")
    ):
        return _evaluation(
            "native_fetch_cache_verify",
            "source_green_scoped",
            "configured Source Atlas public-pack live gateway consumption, hash/cache/quarantine/LKG, and offline/no-account behavior are proven by current native evidence packet",
            evidence=["nativeRuntimeReport"],
            gaps=["not native physical-device proof, not independent accessibility proof, and not Release Green"],
            next_actions=["Run current device/offline/account/accessibility release proof before any release claim."],
        )
    return _evaluation(
        "native_fetch_cache_verify",
        "blocked_missing_artifact",
        "native runtime proof missing or incomplete",
        evidence=["nativeRuntimeReport"],
        gaps=["native runtime report must prove public manifest fetch, hash verification, quarantine, revocation, LKG, offline, and no-account behavior"],
        next_actions=["Rerun focused native Source Atlas runtime suites and attach current evidence."],
    )


def _requirement_runtime_inspection(artifacts: dict[str, Any]) -> dict[str, Any]:
    native = artifacts["nativeRuntimeReport"]
    gauntlet = artifacts["goalDomainGauntlet"]
    no_final = _count(gauntlet, "finalOutputsGenerated") == 0 and _check_passed(gauntlet, "no_final_plan_schedule_step_output")
    if isinstance(native, dict) and _native_proof(native, "noPrivateGraphEgressProof") and no_final:
        return _evaluation(
            "runtime_composition_inspection",
            "source_green_scoped",
            "local-only source inspection/runtime composition boundary is proven for configured public-pack behavior",
            evidence=["nativeRuntimeReport", "goalDomainGauntlet"],
            gaps=["rendered visual/device/accessibility proof remains release-gated"],
            next_actions=["Keep Source Atlas as inspection/enrichment only; final user plans and Steps stay local runtime behavior."],
        )
    return _evaluation(
        "runtime_composition_inspection",
        "yellow_needs_stronger_proof",
        "runtime composition/source inspection proof incomplete",
        evidence=["nativeRuntimeReport", "goalDomainGauntlet"],
        gaps=["native no-private proof or no-final-output gauntlet proof missing"],
        next_actions=["Rerun local source inspection/composition proof and no-final-output gauntlet."],
    )


def _requirement_legal_terms(artifacts: dict[str, Any]) -> dict[str, Any]:
    legal = artifacts["legalApprovalPacket"]
    if isinstance(legal, dict) and legal.get("status") == "Green" and legal.get("outsideLegalApprovalClaimed") is False:
        return _evaluation(
            "legal_terms_approval",
            "source_green_scoped",
            "internal legal/terms packet is Green and explicitly does not claim outside legal approval",
            evidence=["legalApprovalPacket", "legalTermsRegistry"],
            gaps=["outside legal approval remains unproven without a current source-specific outside legal artifact"],
            next_actions=["Attach source-specific outside legal approval artifacts before claiming outside legal approval."],
        )
    if isinstance(legal, dict) and legal.get("outsideLegalApprovalClaimed") is True:
        return _evaluation(
            "legal_terms_approval",
            "red_boundary_violation",
            "legal packet overclaims outside legal approval",
            evidence=["legalApprovalPacket"],
            gaps=["outside legal approval was claimed without being allowed by this audit"],
            next_actions=["Remove outside legal approval claim or attach current source-specific approval artifact."],
        )
    return _evaluation(
        "legal_terms_approval",
        "yellow_needs_stronger_proof",
        "legal/terms proof incomplete",
        evidence=["legalApprovalPacket", "legalTermsRegistry"],
        gaps=["internal legal/terms approval packet missing or not Green"],
        next_actions=["Regenerate legal terms approval packet and keep outside legal approval unclaimed unless artifact exists."],
    )


def _requirement_security_privacy(artifacts: dict[str, Any], privacy_issues: list[str]) -> dict[str, Any]:
    supervisor = artifacts["productionSupervisor"]
    sweep = artifacts["productionSweep"]
    native = artifacts["nativeRuntimeReport"]
    unsafe_zero = (
        _count(supervisor, "productionWritesExecuted") == 0
        and _count(supervisor, "remoteMutations") == 0
        and _count(supervisor, "nativeRuntimeMutations") == 0
        and _count(supervisor, "finalOutputsGenerated") == 0
        and _count(sweep, "privacyIssues") == 0
    )
    native_private = not isinstance(native, dict) or bool(native.get("noPrivateGraphEgressProof"))
    if isinstance(native, dict):
        native_private = bool(_native_proof(native, "noPrivateGraphEgressProof"))
    if not privacy_issues and unsafe_zero and native_private:
        return _evaluation(
            "security_privacy_boundary",
            "proven_current",
            "audit inputs and current production/native reports preserve no-private-graph egress and unsafe-output zero counts",
            evidence=["productionSupervisor", "productionSweep", "nativeRuntimeReport"],
            next_actions=["Continue running boundary and no-private-graph egress audits on every train."],
        )
    return _evaluation(
        "security_privacy_boundary",
        "red_boundary_violation" if privacy_issues else "yellow_needs_stronger_proof",
        "privacy or unsafe-output proof incomplete",
        evidence=["productionSupervisor", "productionSweep", "nativeRuntimeReport"],
        gaps=privacy_issues or ["unsafe output counts or no-private native proof missing"],
        next_actions=["Stop promotion until privacy/unsafe-output counts are zero and audits pass."],
    )


def _requirement_release_readiness(artifacts: dict[str, Any]) -> dict[str, Any]:
    native = artifacts["nativeRuntimeReport"]
    release_packet = artifacts["releaseProofPacket"]
    validation_results = native.get("validationResults", {}) if isinstance(native, dict) else {}
    xcode = native.get("xcodeBuildMCP", {}) if isinstance(native, dict) else {}
    has_focused_native = (
        any("SUCCEEDED" in str(value) for value in validation_results.values())
        or (isinstance(xcode, dict) and xcode.get("result") == "SUCCEEDED")
    )
    if isinstance(release_packet, dict) and release_packet.get("valid") is True:
        missing_external = [
            str(gate_id)
            for gate_id in release_packet.get("missingExternalReleaseGateIDs", [])
            if isinstance(gate_id, str)
        ]
        source_inputs_ready = release_packet.get("sourceAtlasReleaseInputsReady") is True
        gaps = [
            "umbrella Release Green is not proven",
            "App Store/TestFlight readiness is not proven",
            "physical-device proof is not proven",
            "independent accessibility/visual proof is not proven",
        ]
        if missing_external:
            gaps.append("release proof packet missing external gates: " + ", ".join(sorted(missing_external)))
        return _evaluation(
            "release_readiness",
            "yellow_needs_stronger_proof",
            (
                "Source Atlas release-input proof packet is current; external release gates remain separate"
                if source_inputs_ready
                else "Source Atlas release proof packet is present but source validation gates are incomplete"
            ),
            evidence=["nativeRuntimeReport", "releaseProofPacket"],
            gaps=gaps,
            next_actions=[
                "Attach current physical-device, independent accessibility/visual, App Store/TestFlight, privacy/legal release signoff, and owner release approval artifacts.",
                "Keep Release Green blocked until external review approves the umbrella release packet.",
            ],
        )
    return _evaluation(
        "release_readiness",
        "yellow_needs_stronger_proof",
        "focused source/native proof may exist, but Release Green/App Store/TestFlight/device/independent accessibility proof is not current",
        evidence=["nativeRuntimeReport", "releaseProofPacket"],
        gaps=[
            "Source Atlas release proof packet is missing",
            "umbrella Release Green is not proven",
            "App Store/TestFlight readiness is not proven",
            "physical-device proof is not proven",
            "independent accessibility/visual proof is not proven",
        ],
        next_actions=[
            "Run current release proof packet with build/test/device/accessibility/privacy/legal/owner approval evidence.",
            "Keep focused native suite proof scoped." if has_focused_native else "Run focused native Source Atlas tests first.",
        ],
    )


def _requirement_universal_coverage(artifacts: dict[str, Any]) -> dict[str, Any]:
    arbitrary = artifacts["arbitraryDomainGate"]
    gauntlet = artifacts["goalDomainGauntlet"]
    ledger = artifacts["productionTargetLedger"]
    universal_blocked = (
        _blocked(arbitrary, "literal_universal_coverage")
        and _blocked(gauntlet, "literal_universal_coverage")
        and (_blocked(ledger, "literal_universal_coverage") or ledger.get("universalCoverageClaimAllowed") is False)
    )
    if universal_blocked:
        return _evaluation(
            "universal_coverage_claim_control",
            "proven_current",
            "literal universal coverage is blocked; arbitrary public/reference domains route through governed coverage frontiers",
            evidence=["productionTargetLedger", "arbitraryDomainGate", "goalDomainGauntlet"],
            gaps=["coverage expansion is frontier-governed, not universal or complete"],
            next_actions=["Continue domain expansion through candidate intake, legal/source/API review, pack production, R2 proof, and native proof."],
        )
    return _evaluation(
        "universal_coverage_claim_control",
        "red_boundary_violation",
        "universal coverage overclaim is not blocked by current evidence",
        evidence=["productionTargetLedger", "arbitraryDomainGate", "goalDomainGauntlet"],
        gaps=["literal universal coverage must remain blocked"],
        next_actions=["Restore blocked literal universal coverage claims before any promotion."],
    )


def _requirement_launch_floor(artifacts: dict[str, Any]) -> dict[str, Any]:
    ledger = artifacts["launchFloorLedger"]
    if not isinstance(ledger, dict):
        return _evaluation(
            "near_universal_launch_floor",
            "blocked_missing_artifact",
            "launch-floor ledger missing; 1M shard, 500-domain, 5,000-subdomain, 50k-intent, fallback-rate, and continuous-expansion counters cannot be claimed",
            evidence=["launchFloorLedger"],
            gaps=[
                "launch-floor ledger artifact missing",
                "full Source Atlas Green and near-universal coverage remain blocked until launch-floor counters are generated and pass",
            ],
            next_actions=["Run source-atlas-launch-floor-ledger with current evidence and attach the generated JSON/Markdown outputs."],
        )
    target_statuses = ledger.get("targetStatuses", [])
    incomplete = [
        f"{item.get('targetID')}: {item.get('status')}"
        for item in target_statuses
        if isinstance(item, dict) and item.get("status") != "met"
    ]
    incomplete_labels = [
        str(item.get("label") or item.get("targetID"))
        for item in target_statuses
        if isinstance(item, dict) and item.get("status") != "met"
    ]
    if ledger.get("valid") is True and ledger.get("launchFloorMet") is True and ledger.get("launchFloorClaimAllowed") is True and not incomplete:
        return _evaluation(
            "near_universal_launch_floor",
            "proven_current",
            "launch-floor ledger proves every near-universal target and allows launch-floor claim",
            evidence=["launchFloorLedger"],
            next_actions=["Keep launch-floor ledger regenerated from current corpus, taxonomy, routing, R2, native, fallback, and missing-shard proof."],
        )
    gaps = incomplete or ["launch-floor ledger is present but does not allow launch-floor claim"]
    return _evaluation(
        "near_universal_launch_floor",
        "yellow_needs_stronger_proof",
        "launch-floor ledger is present and fail-closed; near-universal launch-floor targets are not all met",
        evidence=["launchFloorLedger"],
        gaps=gaps,
        next_actions=[
            "Complete remaining launch-floor targets: " + "; ".join(incomplete_labels or ["all launch-floor counters"]) + ".",
            "Rerun source-atlas-launch-floor-ledger and completion audit after each launch-floor train.",
        ],
    )


def _requirement_completion_claim(overclaim_issues: list[str], privacy_issues: list[str]) -> dict[str, Any]:
    if overclaim_issues or privacy_issues:
        return _evaluation(
            "completion_claim_control",
            "red_boundary_violation",
            "completion claim control found boundary issues",
            evidence=["allInputs"],
            gaps=overclaim_issues + privacy_issues,
            next_actions=["Remove overclaims and private-looking inputs before rerunning completion audit."],
        )
    return _evaluation(
        "completion_claim_control",
        "proven_current",
        "audit emits a full-objective gap map while keeping goalComplete=false and completionClaimAllowed=false",
        evidence=["completionAudit"],
        gaps=["full goal remains incomplete until Yellow/blocked/release/legal/universal gaps are resolved by current proof"],
        next_actions=["Use nextWorkQueue rather than unqualified Source Atlas Green language."],
    )


def _native_proof(native: dict[str, Any], key: str) -> Any:
    value = native.get(key)
    if value:
        return value
    proof_summary = native.get("proofSummary")
    if isinstance(proof_summary, dict):
        return proof_summary.get(key)
    return None


def _evaluation(
    requirement_id: str,
    status: str,
    proof_scope: str,
    *,
    evidence: list[str],
    gaps: list[str] | None = None,
    next_actions: list[str] | None = None,
) -> dict[str, Any]:
    definition = next(item for item in COMPLETION_REQUIREMENTS if item["requirementID"] == requirement_id)
    return {
        "requirementID": requirement_id,
        "label": definition["label"],
        "objectiveArea": definition["objectiveArea"],
        "status": status,
        "proofScope": proof_scope,
        "evidence": evidence,
        "gaps": gaps or [],
        "nextActions": next_actions or [],
        "nonClaims": COMPLETION_NON_CLAIMS,
    }


def _next_work_queue(requirements: list[dict[str, Any]], artifacts: dict[str, Any]) -> list[dict[str, Any]]:
    items: list[dict[str, Any]] = []
    for requirement in requirements:
        if requirement["status"] in {"yellow_needs_stronger_proof", "blocked_missing_artifact", "red_boundary_violation"}:
            items.append(_work_item(requirement, "requirement_gap", _priority(requirement)))
    items.extend(_candidate_work_items(artifacts["productionSupervisor"]))
    items.extend(_strategic_hold_items(requirements))
    unique: dict[str, dict[str, Any]] = {}
    for item in items:
        unique[item["workItemID"]] = item
    return sorted(unique.values(), key=lambda item: (item["sortOrder"], item["workItemID"]))


def _candidate_work_items(supervisor: Any) -> list[dict[str, Any]]:
    if not isinstance(supervisor, dict):
        return []
    queue = supervisor.get("maintenanceQueue") or supervisor.get("workQueue") or []
    items = []
    for entry in queue:
        if not isinstance(entry, dict):
            continue
        if entry.get("nextAction") in {"candidate_frontier_review", "source_lane_review", "terms_review"}:
            domain_id = str(entry.get("domainID") or "unknown_domain")
            items.append(
                {
                    "workItemID": stable_id("source_atlas.completion_work", {"domainID": domain_id, "action": entry.get("nextAction")}),
                    "title": f"Review candidate/source lane for {domain_id}",
                    "sourceRequirementID": "autonomous_domain_expansion",
                    "workType": "candidate_review",
                    "status": "queued_review_only",
                    "priority": "medium",
                    "sortOrder": 40,
                    "blockers": ["candidate/review-only work cannot emit claims, packs, R2 writes, or native activation"],
                    "recommendedCommand": "run catalog/source/legal/API review chain before pack/R2/native activation",
                    "nonClaims": COMPLETION_NON_CLAIMS,
                }
            )
    return items


def _strategic_hold_items(requirements: list[dict[str, Any]]) -> list[dict[str, Any]]:
    requirement_by_id = {item["requirementID"]: item for item in requirements}
    items = []
    if requirement_by_id["legal_terms_approval"]["status"] != "red_boundary_violation":
        items.append(
            _manual_item(
                "outside_legal_approval_artifact",
                "Attach current source-specific outside legal approval artifact before outside legal approval claim",
                "legal_terms_approval",
                "high",
                ["outside legal approval remains unproven by Codex/internal review"],
            )
        )
    items.append(
        _manual_item(
            "release_green_packet",
            "Produce current release/device/accessibility/App Store proof before Release Green",
            "release_readiness",
            "high",
            ["Release Green, TestFlight readiness, App Store readiness, device proof, and independent accessibility proof are not proven"],
        )
    )
    items.append(
        _manual_item(
            "literal_universal_coverage_blocked",
            "Keep literal universal coverage blocked; expand through governed frontiers",
            "universal_coverage_claim_control",
            "medium",
            ["any-goal support means governed expansion, not literal universal coverage"],
        )
    )
    return items


def _work_item(requirement: dict[str, Any], work_type: str, priority: str) -> dict[str, Any]:
    return {
        "workItemID": stable_id("source_atlas.completion_work", {"requirementID": requirement["requirementID"], "status": requirement["status"]}),
        "title": f"Resolve {requirement['label']}",
        "sourceRequirementID": requirement["requirementID"],
        "workType": work_type,
        "status": requirement["status"],
        "priority": priority,
        "sortOrder": {"high": 10, "medium": 40, "low": 70}[priority],
        "blockers": requirement.get("gaps", []),
        "recommendedCommand": "; ".join(requirement.get("nextActions", [])) or "rerun current evidence gate",
        "nonClaims": COMPLETION_NON_CLAIMS,
    }


def _manual_item(item_id: str, title: str, requirement_id: str, priority: str, blockers: list[str]) -> dict[str, Any]:
    return {
        "workItemID": f"source_atlas.completion_work.{item_id}",
        "title": title,
        "sourceRequirementID": requirement_id,
        "workType": "manual_or_external_proof_gate",
        "status": "yellow_needs_stronger_proof",
        "priority": priority,
        "sortOrder": {"high": 10, "medium": 40, "low": 70}[priority],
        "blockers": blockers,
        "recommendedCommand": "attach current proof artifact and rerun source-atlas-completion-audit",
        "nonClaims": COMPLETION_NON_CLAIMS,
    }


def _priority(requirement: dict[str, Any]) -> str:
    if requirement["status"] in {"red_boundary_violation", "blocked_missing_artifact"}:
        return "high"
    if requirement["requirementID"] in {"release_readiness", "legal_terms_approval", "native_fetch_cache_verify"}:
        return "high"
    return "medium"


def _completion_readiness(requirements: list[dict[str, Any]], valid: bool) -> dict[str, Any]:
    counts = {
        "verifiedRequirementCount": sum(1 for item in requirements if item["status"] in {"proven_current", "source_green_scoped"}),
        "unprovenRequirementCount": sum(1 for item in requirements if item["status"] not in {"proven_current", "source_green_scoped"}),
        "redRequirementCount": sum(1 for item in requirements if item["status"] == "red_boundary_violation"),
        "yellowRequirementCount": sum(1 for item in requirements if item["status"] == "yellow_needs_stronger_proof"),
        "blockedRequirementCount": sum(1 for item in requirements if item["status"] == "blocked_missing_artifact"),
    }
    if not valid or counts["redRequirementCount"]:
        readiness = "red_boundary_or_overclaim_blocked"
    elif counts["unprovenRequirementCount"]:
        readiness = "yellow_goal_incomplete_gap_mapped"
    else:
        readiness = "yellow_goal_incomplete_external_release_legal_universal_ceiling"
    return {
        **counts,
        "overallReadinessStatus": readiness,
        "goalComplete": False,
        "completionClaimAllowed": False,
        "completionRatioName": "verified scoped requirement ratio; not goal-completion percentage",
        "verifiedScopedRequirementRatio": f"{counts['verifiedRequirementCount']}/{len(requirements)}",
    }


def _record_counts(
    requirements: list[dict[str, Any]],
    next_work_queue: list[dict[str, Any]],
    artifacts: dict[str, Any],
    privacy_issues: list[str],
    overclaim_issues: list[str],
) -> dict[str, int]:
    return {
        "requirements": len(requirements),
        "provenCurrentRequirements": sum(1 for item in requirements if item["status"] == "proven_current"),
        "sourceGreenScopedRequirements": sum(1 for item in requirements if item["status"] == "source_green_scoped"),
        "yellowRequirements": sum(1 for item in requirements if item["status"] == "yellow_needs_stronger_proof"),
        "blockedRequirements": sum(1 for item in requirements if item["status"] == "blocked_missing_artifact"),
        "redRequirements": sum(1 for item in requirements if item["status"] == "red_boundary_violation"),
        "nextWorkItems": len(next_work_queue),
        "configuredDomains": _count(artifacts["productionSweep"], "configuredDomains"),
        "domainsReady": _count(artifacts["productionSweep"], "domainsReady"),
        "promotionDecisions": _count(artifacts["productionSupervisor"], "promotionDecisions"),
        "remoteR2UploadsReconciled": _count(artifacts["productionSweep"], "remoteR2UploadsReconciled"),
        "launchFloorTargets": len(artifacts["launchFloorLedger"].get("targetStatuses", [])) if isinstance(artifacts["launchFloorLedger"], dict) else 0,
        "launchFloorTargetsMet": sum(
            1
            for item in artifacts["launchFloorLedger"].get("targetStatuses", [])
            if isinstance(item, dict) and item.get("status") == "met"
        )
        if isinstance(artifacts["launchFloorLedger"], dict)
        else 0,
        "privacyIssues": len(privacy_issues),
        "overclaimIssues": len(overclaim_issues),
    }


def _checks(
    requirements: list[dict[str, Any]],
    artifacts: dict[str, Any],
    input_privacy_issues: list[str],
    privacy_issues: list[str],
    overclaim_issues: list[str],
) -> list[dict[str, Any]]:
    return [
        _check("input_privacy_scan_passed", not input_privacy_issues, input_privacy_issues, "red"),
        _check("artifact_privacy_scan_passed", not privacy_issues, privacy_issues, "red"),
        _check("overclaim_scan_passed", not overclaim_issues, overclaim_issues, "red"),
        _check("production_supervisor_loaded", _valid_report(artifacts["productionSupervisor"]), ["production supervisor report is missing or invalid"], "red"),
        _check("production_sweep_loaded", _valid_report(artifacts["productionSweep"]), ["production sweep report is missing or invalid"], "red"),
        _check("requirements_evaluated", len(requirements) == len(COMPLETION_REQUIREMENTS), ["not all completion requirements were evaluated"], "red"),
        _check("completion_claim_blocked", True, [], "yellow"),
        _check("full_source_atlas_green_not_claimed", not any(item["status"] == "proven_complete" for item in requirements), [], "red"),
        _check(
            "release_and_universal_gaps_remain_explicit",
            any(item["requirementID"] == "release_readiness" and item["status"] == "yellow_needs_stronger_proof" for item in requirements)
            and any(item["requirementID"] == "universal_coverage_claim_control" for item in requirements),
            ["release/universal gates are not explicit"],
            "yellow",
        ),
    ]


def _check(name: str, passed: bool, issues: list[str], severity: str) -> dict[str, Any]:
    return {"name": name, "passed": passed, "issues": issues if not passed else [], "severity": severity}


def _overall_status(requirements: list[dict[str, Any]], valid: bool) -> str:
    if not valid or any(item["status"] == "red_boundary_violation" for item in requirements):
        return "Red: Source Atlas completion audit found boundary or overclaim violation"
    return "Source Green for Source Atlas completion-audit/gap-router tooling / Yellow overall Source Atlas"


def _allowed_claims(valid: bool) -> list[str]:
    if not valid:
        return []
    return [
        "source_atlas_completion_audit_green",
        "full_objective_gap_map_emitted",
        "completion_overclaim_blocked",
        "next_work_queue_emitted",
        "source_atlas_status_ceiling_preserved",
    ]


def _blocked_claims() -> list[str]:
    return [
        "full_source_atlas_green",
        "goal_complete",
        "production_ready_without_scope",
        "runtime_release_green",
        "release_green",
        "app_store_readiness",
        "testflight_readiness",
        "outside_legal_approval",
        "literal_universal_coverage",
        "automatic_r2_write_without_execute_budget_approval",
        "uncontrolled_live_harvest",
        "source_atlas_private_goal_text_processing",
        "final_user_plans_schedules_steps_from_source_atlas_or_r2",
        "hosted_private_life_graph",
    ]


def _input_paths(options: SourceAtlasCompletionAuditOptions) -> dict[str, str | None]:
    return {
        "productionSupervisor": str(options.production_supervisor_path),
        "productionSweep": str(options.production_sweep_path),
        "productionFinishLineGate": str(options.production_finish_line_gate_path),
        "productionRecertification": str(options.production_recertification_path),
        "productionTargetLedger": str(options.production_target_ledger_path),
        "arbitraryDomainGate": str(options.arbitrary_domain_gate_path),
        "goalDomainGauntlet": str(options.goal_domain_gauntlet_path),
        "sourceLaneRegistry": str(options.source_lane_registry_path) if options.source_lane_registry_path else None,
        "legalTermsRegistry": str(options.legal_terms_registry_path) if options.legal_terms_registry_path else None,
        "apiGovernanceRegistry": str(options.api_governance_registry_path) if options.api_governance_registry_path else None,
        "nativeRuntimeReport": str(options.native_runtime_report_path) if options.native_runtime_report_path else None,
        "releaseProofPacket": str(options.release_proof_packet_path) if options.release_proof_packet_path else None,
        "legalApprovalPacket": str(options.legal_approval_packet_path) if options.legal_approval_packet_path else None,
        "ownerApproval": str(options.owner_approval_path) if options.owner_approval_path else None,
        "launchFloorLedger": str(options.launch_floor_ledger_path) if options.launch_floor_ledger_path else None,
    }


def _read_required_json(path: Path, label: str, issues: list[str]) -> Any:
    try:
        return read_json(path)
    except FileNotFoundError:
        issues.append(f"{label} missing: {path}")
    except Exception as exc:  # pragma: no cover - defensive for malformed operator input
        issues.append(f"{label} unreadable: {path}: {exc}")
    return None


def _read_optional_json(path: Path | None, label: str, issues: list[str]) -> Any:
    if path is None:
        return None
    try:
        return read_json(path)
    except FileNotFoundError:
        issues.append(f"optional {label} missing: {path}")
    except Exception as exc:  # pragma: no cover - defensive for malformed operator input
        issues.append(f"optional {label} unreadable: {path}: {exc}")
    return None


def _valid_report(value: Any) -> bool:
    if not isinstance(value, dict):
        return False
    if value.get("valid") is True:
        return True
    status = str(value.get("status") or "")
    return bool(status) and not value.get("issues")


def _claim(value: Any, claim: str) -> bool:
    return isinstance(value, dict) and claim in value.get("allowedClaims", [])


def _blocked(value: Any, claim: str) -> bool:
    return isinstance(value, dict) and claim in value.get("blockedClaims", [])


def _check_passed(value: Any, name: str) -> bool:
    if not isinstance(value, dict):
        return False
    return any(isinstance(check, dict) and check.get("name") == name and check.get("passed") is True for check in value.get("checks", []))


def _count(value: Any, key: str) -> int:
    if not isinstance(value, dict):
        return 0
    for bucket in ("recordCounts", "queueCounts", "maintenanceCounts", "promotionCounts"):
        counts = value.get(bucket)
        if isinstance(counts, dict) and key in counts:
            try:
                return int(counts.get(key) or 0)
            except (TypeError, ValueError):
                return 0
    try:
        return int(value.get(key) or 0)
    except (TypeError, ValueError):
        return 0


def _overclaim_issues(artifacts: dict[str, Any]) -> list[str]:
    issues: list[str] = []
    for label, artifact in artifacts.items():
        if not isinstance(artifact, dict):
            continue
        allowed = set(str(claim) for claim in artifact.get("allowedClaims", []) if isinstance(claim, str))
        forbidden_allowed = sorted(allowed & FORBIDDEN_ALLOWED_CLAIMS)
        for claim in forbidden_allowed:
            issues.append(f"{label} allows forbidden claim: {claim}")
        if artifact.get("outsideLegalApprovalClaimed") is True:
            issues.append(f"{label} claims outside legal approval")
        if artifact.get("literalUniversalCoverageClaimed") is True or artifact.get("universalCoverageClaimAllowed") is True:
            issues.append(f"{label} claims literal universal coverage")
        if artifact.get("goalComplete") is True or artifact.get("completionClaimAllowed") is True:
            issues.append(f"{label} claims full goal completion")
    return sorted(set(issues))


def _artifact_privacy_issues(artifacts: dict[str, Any]) -> list[str]:
    privacy_view = {}
    for label, artifact in artifacts.items():
        if not isinstance(artifact, dict):
            continue
        privacy_view[label] = {
            "status": artifact.get("status"),
            "allowedClaims": artifact.get("allowedClaims", []),
            "blockedClaims": artifact.get("blockedClaims", []),
            "recordCounts": artifact.get("recordCounts", {}),
            "queueCounts": artifact.get("queueCounts", {}),
            "maintenanceCounts": artifact.get("maintenanceCounts", {}),
            "promotionCounts": artifact.get("promotionCounts", {}),
            "privacyIssues": artifact.get("privacyIssues", []),
            "workQueue": _queue_privacy_view(artifact.get("workQueue", [])),
            "maintenanceQueue": _queue_privacy_view(artifact.get("maintenanceQueue", [])),
            "domains": _domain_privacy_view(artifact.get("domains", [])),
        }
    return boundary_issue_strings(boundary_issues_for_value(privacy_view, "source-atlas-completion-audit-artifacts"))


def _queue_privacy_view(queue: Any) -> list[dict[str, Any]]:
    if not isinstance(queue, list):
        return []
    return [
        {
            "domainID": item.get("domainID"),
            "nextAction": item.get("nextAction"),
            "status": item.get("status") or item.get("state"),
            "requiredGate": item.get("requiredGate"),
            "productionWriteExecuted": item.get("productionWriteExecuted", False),
            "remoteMutation": item.get("remoteMutation", False),
            "nativeRuntimeMutation": item.get("nativeRuntimeMutation", False),
            "finalOutputGenerated": item.get("finalOutputGenerated", False),
        }
        for item in queue
        if isinstance(item, dict)
    ]


def _domain_privacy_view(domains: Any) -> list[dict[str, Any]]:
    if not isinstance(domains, list):
        return []
    return [
        {
            "domainID": item.get("domainID") or item.get("domain"),
            "ready": item.get("ready"),
            "packableClaimCount": item.get("packableClaimCount"),
            "sourceIDs": item.get("sourceIDs", []),
        }
        for item in domains
        if isinstance(item, dict)
    ]


def _input_hashes(artifacts: dict[str, Any]) -> dict[str, str | None]:
    return {
        label: stable_hash(artifact) if isinstance(artifact, dict) else None
        for label, artifact in sorted(artifacts.items())
    }
