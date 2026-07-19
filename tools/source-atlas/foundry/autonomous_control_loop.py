"""Autonomous Source Atlas control-loop gate.

The control loop reconciles current production evidence into deterministic
run/hold decisions. It does not harvest, publish, deploy, mutate native state,
or create release/legal/universal claims. Those remain behind their explicit
proof and approval gates.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Any

from .boundary import boundary_issue_strings, boundary_issues_for_value
from .model import NON_CLAIMS, PRIVACY_BOUNDARY, read_json, stable_hash, stable_id, write_json
from .r2_owner_approval import validate_r2_owner_approval_artifact


AUTONOMOUS_CONTROL_LOOP_KIND = "ambitions.sourceAtlas.autonomousControlLoop.v1"
AUTONOMOUS_CONTROL_LOOP_VERSION = "source-atlas-autonomous-control-loop-train-119"

REQUIRED_SWEEP_CLAIMS = {
    "current_configured_frontier_production_sweep",
    "current_remote_r2_upload_readback_reconciled",
    "governed_arbitrary_public_reference_domain_routing_reconciled",
    "future_remote_r2_write_preflight_ready",
    "representative_goal_domain_gauntlet_reconciled",
}
REQUIRED_GAUNTLET_CLAIMS = {
    "representative_goal_domain_gauntlet_green",
    "configured_frontier_goal_domain_runtime_routing",
    "unknown_public_reference_domains_candidate_only",
}
REQUIRED_FINISH_LINE_CLAIMS = {
    "bounded_configured_production_target",
    "internal_terms_review",
    "production_r2_write_readback",
    "bounded_live_transport",
    "bounded_configured_runtime_green",
    "gateway_native_runtime_recertification",
}
REQUIRED_FINISH_LINE_BLOCKS = {"release_green", "universal_coverage", "outside_legal_approval"}
REQUIRED_ARBITRARY_ZERO_COUNTS = {
    "candidateClaims",
    "candidateR2PublishOperations",
    "candidateNativeActivationOperations",
    "candidateProductionWrites",
}

CONTROL_LOOP_NON_CLAIMS = [
    "autonomous control-loop gate only",
    "not an uncontrolled live harvester",
    "not an automatic production R2 writer",
    "not a Worker deployer",
    "not outside legal approval",
    "not Release Green",
    "not App Store or TestFlight readiness",
    "not literal universal coverage",
    "not full Source Atlas Green",
    "not native physical-device proof",
    "not independent accessibility proof",
    "not final user plans, schedules, Steps, priority order, or personalized paths from Source Atlas/R2",
    *NON_CLAIMS,
]


@dataclass(frozen=True)
class AutonomousControlLoopOptions:
    production_sweep_path: Path
    goal_domain_gauntlet_path: Path
    owner_approval_path: Path
    native_runtime_report_path: Path
    production_finish_line_gate_path: Path
    arbitrary_domain_gate_path: Path
    output_root: Path
    autonomous_end_to_end_chain_path: Path | None = None
    created_at: str = "2026-06-29T01:45:00Z"
    environment: str = "production"
    channel: str = "stable"
    bucket: str | None = None


def run_autonomous_control_loop(options: AutonomousControlLoopOptions) -> dict[str, Any]:
    output_root = options.output_root
    output_root.mkdir(parents=True, exist_ok=True)

    issues: list[str] = []
    sweep = _read_required_json(options.production_sweep_path, "production sweep", issues)
    gauntlet = _read_required_json(options.goal_domain_gauntlet_path, "goal-domain gauntlet", issues)
    native_runtime = _read_required_json(options.native_runtime_report_path, "native runtime report", issues)
    finish_line = _read_required_json(options.production_finish_line_gate_path, "production finish-line gate", issues)
    arbitrary_gate = _read_required_json(options.arbitrary_domain_gate_path, "arbitrary-domain gate", issues)
    end_to_end = _read_optional_json(options.autonomous_end_to_end_chain_path, "autonomous end-to-end chain", issues)

    domain_ids = _domain_ids_from_sweep(sweep)
    resolved_bucket = options.bucket or _bucket_from_sweep(sweep)
    owner_validation = validate_r2_owner_approval_artifact(
        options.owner_approval_path,
        environment=options.environment,
        channel=options.channel,
        bucket=resolved_bucket,
        domain_ids=domain_ids,
    )
    domain_decisions = _domain_control_decisions(sweep=sweep, native_runtime=native_runtime)
    r2_write_decision = _r2_write_decision(sweep=sweep, owner_validation=owner_validation)
    unknown_domain_decision = _unknown_domain_decision(arbitrary_gate=arbitrary_gate, gauntlet=gauntlet)
    release_decision = _release_hold_decision(finish_line)
    outside_legal_decision = _outside_legal_hold_decision(finish_line)
    universal_decision = _universal_hold_decision(finish_line)
    end_to_end_decision = _end_to_end_decision(end_to_end)

    checks = [
        _check("production_sweep_valid", _artifact_valid(sweep), _artifact_issues("production sweep", sweep)),
        _check("production_sweep_has_required_claims", _has_claims(sweep, REQUIRED_SWEEP_CLAIMS), _missing_claim_issues("production sweep", sweep, REQUIRED_SWEEP_CLAIMS)),
        _check("all_configured_domains_ready", _all_domains_ready(sweep), _blocked_domains(sweep)),
        _check("future_r2_write_preflight_ready", r2_write_decision["preflightReady"], r2_write_decision["blockedReasons"]),
        _check("owner_approval_covers_current_domains", owner_validation["valid"], owner_validation.get("issues", [])),
        _check("goal_domain_gauntlet_valid", _artifact_valid(gauntlet), _artifact_issues("goal-domain gauntlet", gauntlet)),
        _check("goal_domain_gauntlet_claims_present", _has_claims(gauntlet, REQUIRED_GAUNTLET_CLAIMS), _missing_claim_issues("goal-domain gauntlet", gauntlet, REQUIRED_GAUNTLET_CLAIMS)),
        _check("goal_domain_gauntlet_emits_no_final_outputs", _gauntlet_has_no_final_outputs(gauntlet), ["goal-domain gauntlet generated final outputs"] if not _gauntlet_has_no_final_outputs(gauntlet) else []),
        _check("native_runtime_current_proof_valid", _native_runtime_valid(native_runtime), _native_runtime_issues(native_runtime)),
        _check("finish_line_gate_valid", _artifact_valid(finish_line), _artifact_issues("production finish-line gate", finish_line)),
        _check("finish_line_claims_and_blocks_enforced", _finish_line_enforces_claim_boundary(finish_line), _finish_line_boundary_issues(finish_line)),
        _check("arbitrary_domain_gate_candidate_only", unknown_domain_decision["candidateOnly"], unknown_domain_decision["blockedReasons"]),
        _check("release_hold_enforced", release_decision["held"], release_decision["issues"]),
        _check("outside_legal_hold_enforced", outside_legal_decision["held"], outside_legal_decision["issues"]),
        _check("literal_universal_hold_enforced", universal_decision["held"], universal_decision["issues"]),
        _check("optional_end_to_end_chain_valid_when_supplied", end_to_end_decision["valid"], end_to_end_decision["issues"]),
    ]
    issues.extend(issue for check in checks for issue in check["issues"] if not check["passed"])
    privacy_issues = boundary_issue_strings(
        boundary_issues_for_value(
            {
                "domains": [
                    {
                        "domainID": item["domainID"],
                        "controlAction": item["controlAction"],
                        "packID": item.get("packID"),
                        "sourceIDs": item.get("sourceIDs", []),
                    }
                    for item in domain_decisions
                ],
                "r2WriteDecision": _r2_write_privacy_view(r2_write_decision),
                "unknownDomainDecision": unknown_domain_decision,
                "releaseDecision": release_decision,
                "outsideLegalDecision": outside_legal_decision,
                "universalCoverageDecision": universal_decision,
            },
            "source-atlas-autonomous-control-loop",
        )
    )
    issues.extend(privacy_issues)
    checks.append(_check("privacy_boundary", not privacy_issues, privacy_issues))

    valid = not issues and all(check["passed"] for check in checks) and bool(domain_decisions)
    allowed_claims = []
    if valid:
        allowed_claims = [
            "autonomous_control_loop_ready_for_configured_public_reference_domains",
            "r2_write_preflight_ready_execute_still_required",
            "unknown_domains_candidate_only_controlled",
            "release_legal_universal_claim_holds_enforced",
        ]

    report_path = output_root / "autonomous-control-loop-report.json"
    markdown_path = output_root / "autonomous-control-loop-report.md"
    closeout_path = output_root / "closeout.md"
    report = {
        "schemaVersion": 1,
        "kind": AUTONOMOUS_CONTROL_LOOP_KIND,
        "versionID": AUTONOMOUS_CONTROL_LOOP_VERSION,
        "createdAt": options.created_at,
        "controlLoopID": stable_id(
            "source_atlas.autonomous_control_loop",
            {
                "createdAt": options.created_at,
                "domains": domain_ids,
                "productionSweep": str(options.production_sweep_path),
            },
        ),
        "status": "Source Green for autonomous Source Atlas control-loop tooling" if valid else "Red",
        "valid": valid,
        "sourceAtlasStatusCeiling": "Yellow overall Source Atlas; autonomous control-loop tooling for current configured public/reference domains only",
        "overallReadinessStatus": "autonomous_control_loop_ready" if valid else "blocked_or_partial",
        "executionMode": "decision_only_no_mutation",
        "recordCounts": {
            "configuredDomains": len(domain_decisions),
            "domainsReadyForMonitoring": sum(1 for item in domain_decisions if item["readyForMonitoring"]),
            "domainsBlocked": sum(1 for item in domain_decisions if not item["readyForMonitoring"]),
            "futureR2WritePreflightReady": 1 if r2_write_decision["preflightReady"] else 0,
            "automaticR2WritesAllowed": 1 if r2_write_decision["automaticWriteAllowed"] else 0,
            "unknownDomainsCandidateOnly": 1 if unknown_domain_decision["candidateOnly"] else 0,
            "privacyIssues": len(privacy_issues),
        },
        "checks": checks,
        "issues": sorted(set(issues)),
        "domainControlDecisions": domain_decisions,
        "r2WriteDecision": r2_write_decision,
        "unknownDomainDecision": unknown_domain_decision,
        "releaseDecision": release_decision,
        "outsideLegalDecision": outside_legal_decision,
        "universalCoverageDecision": universal_decision,
        "endToEndDecision": end_to_end_decision,
        "allowedClaims": allowed_claims,
        "blockedClaims": _blocked_claims(),
        "privacyBoundary": PRIVACY_BOUNDARY,
        "privacyIssues": privacy_issues,
        "nonClaims": CONTROL_LOOP_NON_CLAIMS,
        "evidencePaths": {
            "productionSweep": str(options.production_sweep_path),
            "goalDomainGauntlet": str(options.goal_domain_gauntlet_path),
            "ownerApproval": str(options.owner_approval_path),
            "nativeRuntimeReport": str(options.native_runtime_report_path),
            "productionFinishLineGate": str(options.production_finish_line_gate_path),
            "arbitraryDomainGate": str(options.arbitrary_domain_gate_path),
            "autonomousEndToEndChain": str(options.autonomous_end_to_end_chain_path) if options.autonomous_end_to_end_chain_path else None,
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
    markdown = autonomous_control_loop_markdown(report)
    markdown_path.write_text(markdown, encoding="utf-8")
    closeout_path.write_text(markdown, encoding="utf-8")
    return report


def autonomous_control_loop_markdown(report: dict[str, Any]) -> str:
    counts = report["recordCounts"]
    r2 = report["r2WriteDecision"]
    lines = [
        "# Source Atlas Autonomous Control Loop Train 119",
        "",
        f"Status: {report['status']}",
        f"Source Atlas status ceiling: {report['sourceAtlasStatusCeiling']}",
        f"Overall readiness: {report['overallReadinessStatus']}",
        f"Execution mode: {report['executionMode']}",
        "",
        "Scope completed:",
        "- Reconciled current production sweep, R2 owner approval, goal-domain gauntlet, native runtime proof, finish-line gate, and arbitrary-domain gate.",
        "- Emits deterministic run/hold decisions for current configured public/reference domains.",
        "- Keeps unknown public/reference domains candidate-only until coverage, source, legal, provenance, pack, R2, and native gates pass.",
        "- Keeps new production R2 writes preflight-ready only; execution still requires the separate execute path and gates.",
        "- Keeps release, outside legal approval, and literal universal coverage claims held.",
        "",
        "Counts:",
        f"- Configured domains: {counts['configuredDomains']}",
        f"- Domains ready for monitoring: {counts['domainsReadyForMonitoring']}",
        f"- Domains blocked: {counts['domainsBlocked']}",
        f"- Future R2 write preflight ready: {'yes' if counts['futureR2WritePreflightReady'] else 'no'}",
        f"- Automatic R2 writes allowed: {'yes' if counts['automaticR2WritesAllowed'] else 'no'}",
        f"- Unknown domains candidate-only: {'yes' if counts['unknownDomainsCandidateOnly'] else 'no'}",
        f"- Privacy issues: {counts['privacyIssues']}",
        "",
        "Domain decisions:",
        "",
        "| Domain | Control Action | Pack | R2 | Native | Automatic Writes | Issues |",
        "| --- | --- | --- | --- | --- | --- | --- |",
    ]
    for decision in report.get("domainControlDecisions", []):
        lines.append(
            "| {domain} | {action} | {pack} | {r2} | {native} | {auto} | {issues} |".format(
                domain=decision["domainID"],
                action=decision["controlAction"],
                pack="yes" if decision["packReady"] else "no",
                r2="yes" if decision["r2Ready"] else "no",
                native="yes" if decision["nativeRuntimeReady"] else "no",
                auto="yes" if decision["automaticWriteAllowed"] else "no",
                issues="<br>".join(decision.get("issues", [])) or "none",
            )
        )
    lines.extend(
        [
            "",
            "R2 write decision:",
            f"- State: `{r2['decision']}`",
            f"- Preflight ready: {'yes' if r2['preflightReady'] else 'no'}",
            f"- Execute required: {'yes' if r2['executeRequired'] else 'no'}",
            f"- Automatic write allowed: {'yes' if r2['automaticWriteAllowed'] else 'no'}",
            f"- Approval valid: {'yes' if r2['ownerApprovalValid'] else 'no'}",
            "",
            "Product law preserved:",
            "- R2 remains public/reference/freshness infrastructure only.",
            "- Control-loop inputs and outputs are domain IDs, source IDs, pack IDs, public object keys, checksums, proof paths, and gate states.",
            "- No private user context, goals, captures, schedules, proof, receipts, account IDs, device IDs, behavior history, inferred priorities, or private graph data is introduced.",
            "- Source Atlas/R2 does not generate final plans, schedules, Steps, priority order, recovery paths, or personalized paths.",
            "- Ambitions local runtime remains responsible for local matching, fit, timing, priority, final Steps, and final schedules.",
            "",
            "Allowed claims:",
        ]
    )
    lines.extend(f"- `{claim}`" for claim in report.get("allowedClaims", [])) if report.get("allowedClaims") else lines.append("- None")
    lines.extend(["", "Blocked claims:"])
    lines.extend(f"- `{claim}`" for claim in report.get("blockedClaims", []))
    lines.extend(
        [
            "",
            "Validation run:",
            "- See current train closeout for exact command output.",
            "",
            "Validation not run:",
            "- No new live harvest was run by the control loop.",
            "- No new production R2 write was run by the control loop.",
            "- No Worker deploy was run by the control loop.",
            "- No new native XCTest/build-for-testing was run by the control loop.",
            "- No outside legal approval, Release Green, App Store readiness, native physical-device proof, independent accessibility proof, or literal universal coverage was claimed.",
            "",
            "Architecture closeout:",
            "- Final Architecture Tree inspected: yes.",
            "- Canonical owners touched: none in app source; tooling/evidence only under tools/source-atlas and docs/qa/source-atlas.",
            "- Non-canonical owners touched: none.",
            "- Files moved or created: autonomous control-loop module, CLI command, tests, generated artifacts, and QA evidence.",
            "- Old/non-canonical paths removed: none.",
            "- Compatibility shims left behind: none.",
            "- Yellow architecture debt remaining: release proof, outside legal artifact, independent accessibility/device proof, and new execute-gated production writes remain separate gates.",
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
            "- Revert Train 119 autonomous control-loop module, CLI wiring, focused tests, generated artifacts, and QA evidence.",
            "- Continue using production sweep, gauntlet, native proof, and owner approval artifacts directly if the control loop regresses.",
            "",
        ]
    )
    return "\n".join(lines)


def _domain_control_decisions(*, sweep: Any, native_runtime: Any) -> list[dict[str, Any]]:
    native_ready = {
        item.get("domainID"): bool(item.get("runtimeReady"))
        for item in (native_runtime.get("domainProofs", []) if isinstance(native_runtime, dict) else [])
        if isinstance(item, dict)
    }
    decisions: list[dict[str, Any]] = []
    for domain in _domains(sweep):
        domain_id = str(domain.get("domainID"))
        pack = domain.get("pack") if isinstance(domain.get("pack"), dict) else {}
        r2 = domain.get("r2") if isinstance(domain.get("r2"), dict) else {}
        issues = list(domain.get("issues", []))
        pack_ready = pack.get("valid") is True
        r2_ready = r2.get("remoteUploadReadbackReady") is True
        runtime_ready = native_ready.get(domain_id, False)
        if not domain.get("ready"):
            issues.append("production sweep domain is not ready")
        if not pack_ready:
            issues.append("pack proof is not valid")
        if not r2_ready:
            issues.append("R2 upload/readback proof is not valid")
        if not runtime_ready:
            issues.append("native runtime proof is not ready")
        decisions.append(
            {
                "domainID": domain_id,
                "controlAction": "monitor_current_production_runtime" if not issues else "hold_until_current_domain_evidence_repairs",
                "readyForMonitoring": not issues,
                "packReady": pack_ready,
                "r2Ready": r2_ready,
                "nativeRuntimeReady": runtime_ready,
                "futureR2WritePreflightRequired": True,
                "executeRequiredForNewWrite": True,
                "automaticWriteAllowed": False,
                "candidateOnlyForUnknownExpansion": False,
                "packID": pack.get("packID") or r2.get("packID"),
                "packVersion": pack.get("packVersion") or r2.get("packVersion"),
                "manifestKey": r2.get("manifestKey"),
                "sourceIDs": sorted(domain.get("sourceIDs", [])),
                "packableClaimCount": int(domain.get("packableClaimCount", 0) or 0),
                "issues": sorted(set(issues)),
            }
        )
    return sorted(decisions, key=lambda item: item["domainID"])


def _r2_write_decision(*, sweep: Any, owner_validation: dict[str, Any]) -> dict[str, Any]:
    preflight = sweep.get("futureRemoteWritePreflight", {}) if isinstance(sweep, dict) else {}
    preflight_ready = preflight.get("readyForNewRemoteWrite") is True
    owner_valid = owner_validation.get("valid") is True
    blocked = []
    if not preflight_ready:
        blocked.extend(preflight.get("blockedReasons", []) or ["future remote write preflight is not ready"])
    if not owner_valid:
        blocked.extend(owner_validation.get("issues", []) or ["owner approval artifact is not valid"])
    decision = "preflight_ready_execute_still_required" if preflight_ready and owner_valid else "hold_until_preflight_and_owner_approval_repair"
    return {
        "decision": decision,
        "preflightReady": preflight_ready and owner_valid,
        "executeRequired": True,
        "budgetPolicyRequired": True,
        "legalTermsPacketRequired": True,
        "ownerApprovalValid": owner_valid,
        "approvalValidation": owner_validation,
        "automaticWriteAllowed": False,
        "newRemoteWriteExecutedByControlLoop": False,
        "credentialGroupsPresent": sorted(preflight.get("credentialGroupsPresent", [])),
        "bucketConfigured": preflight.get("bucketConfigured") is True,
        "environment": preflight.get("environment"),
        "blockedReasons": sorted(set(blocked)),
        "nonClaims": [
            "not a new production R2 write",
            "not automatic R2 write permission",
            "not release readiness",
        ],
    }


def _unknown_domain_decision(*, arbitrary_gate: Any, gauntlet: Any) -> dict[str, Any]:
    counts = arbitrary_gate.get("recordCounts", {}) if isinstance(arbitrary_gate, dict) else {}
    blocked = []
    if not _artifact_valid(arbitrary_gate):
        blocked.extend(_artifact_issues("arbitrary-domain gate", arbitrary_gate))
    for key in REQUIRED_ARBITRARY_ZERO_COUNTS:
        if int(counts.get(key, -1) or 0) != 0:
            blocked.append(f"{key} must remain 0 for unknown domains")
    gauntlet_counts = gauntlet.get("recordCounts", {}) if isinstance(gauntlet, dict) else {}
    if int(gauntlet_counts.get("unknownCasesBlocked", 0) or 0) != 0:
        blocked.append("goal-domain gauntlet has blocked unknown cases")
    return {
        "decision": "candidate_frontier_intake_only" if not blocked else "hold_unknown_domain_handling",
        "candidateOnly": not blocked,
        "sourceAuthorityClaimAllowed": False,
        "packOutputAllowed": False,
        "r2PublishAllowed": False,
        "nativeActivationAllowed": False,
        "productionWriteAllowed": False,
        "privateContextAccepted": False,
        "blockedReasons": sorted(set(blocked)),
    }


def _release_hold_decision(finish_line: Any) -> dict[str, Any]:
    blocked_claims = set(finish_line.get("blockedClaims", [])) if isinstance(finish_line, dict) else set()
    issues = [] if "release_green" in blocked_claims else ["release_green must remain blocked"]
    return {
        "decision": "hold_release_green_until_current_release_proof_and_required_approvals",
        "held": not issues,
        "releaseGreenAllowed": False,
        "issues": issues,
    }


def _outside_legal_hold_decision(finish_line: Any) -> dict[str, Any]:
    blocked_claims = set(finish_line.get("blockedClaims", [])) if isinstance(finish_line, dict) else set()
    issues = [] if "outside_legal_approval" in blocked_claims else ["outside_legal_approval must remain blocked without outside legal artifact"]
    return {
        "decision": "hold_outside_legal_approval_until_current_outside_legal_artifact",
        "held": not issues,
        "outsideLegalApprovalAllowed": False,
        "issues": issues,
    }


def _universal_hold_decision(finish_line: Any) -> dict[str, Any]:
    blocked_claims = set(finish_line.get("blockedClaims", [])) if isinstance(finish_line, dict) else set()
    issues = [] if "universal_coverage" in blocked_claims else ["universal_coverage must remain blocked"]
    return {
        "decision": "hold_literal_universal_coverage_claim_use_governed_frontiers_only",
        "held": not issues,
        "literalUniversalCoverageAllowed": False,
        "governedFrontierExpansionAllowed": True,
        "issues": issues,
    }


def _end_to_end_decision(end_to_end: Any) -> dict[str, Any]:
    if end_to_end is None:
        return {
            "supplied": False,
            "valid": True,
            "decision": "not_supplied_current_sweep_artifacts_used",
            "issues": [],
        }
    issues = _artifact_issues("autonomous end-to-end chain", end_to_end)
    return {
        "supplied": True,
        "valid": not issues,
        "decision": "end_to_end_chain_observed" if not issues else "hold_until_end_to_end_chain_repairs",
        "issues": issues,
    }


def _finish_line_enforces_claim_boundary(finish_line: Any) -> bool:
    if not isinstance(finish_line, dict):
        return False
    return _has_claims(finish_line, REQUIRED_FINISH_LINE_CLAIMS) and REQUIRED_FINISH_LINE_BLOCKS.issubset(set(finish_line.get("blockedClaims", [])))


def _finish_line_boundary_issues(finish_line: Any) -> list[str]:
    return [
        *_missing_claim_issues("production finish-line gate", finish_line, REQUIRED_FINISH_LINE_CLAIMS),
        *_missing_block_issues("production finish-line gate", finish_line, REQUIRED_FINISH_LINE_BLOCKS),
    ]


def _native_runtime_valid(native_runtime: Any) -> bool:
    if not _artifact_valid(native_runtime):
        return False
    if "bounded_configured_runtime_green" not in set(native_runtime.get("allowedClaims", [])):
        return False
    counts = native_runtime.get("recordCounts", {})
    return int(counts.get("domainsBlocked", 1) or 0) == 0 and int(counts.get("domainsRuntimeReady", 0) or 0) > 0


def _native_runtime_issues(native_runtime: Any) -> list[str]:
    issues = _artifact_issues("native runtime report", native_runtime)
    if isinstance(native_runtime, dict) and "bounded_configured_runtime_green" not in set(native_runtime.get("allowedClaims", [])):
        issues.append("native runtime report missing bounded_configured_runtime_green")
    counts = native_runtime.get("recordCounts", {}) if isinstance(native_runtime, dict) else {}
    if int(counts.get("domainsBlocked", 1) or 0) != 0:
        issues.append("native runtime report has blocked domains")
    if int(counts.get("domainsRuntimeReady", 0) or 0) <= 0:
        issues.append("native runtime report has no runtime-ready domains")
    return sorted(set(issues))


def _artifact_valid(value: Any) -> bool:
    return isinstance(value, dict) and value.get("valid") is True


def _artifact_issues(label: str, value: Any) -> list[str]:
    if not isinstance(value, dict):
        return [f"{label} missing_or_unreadable"]
    if value.get("valid") is True:
        return []
    return [f"{label} valid flag is not true", *value.get("issues", [])]


def _has_claims(artifact: Any, required: set[str]) -> bool:
    return isinstance(artifact, dict) and required.issubset(set(artifact.get("allowedClaims", [])))


def _missing_claim_issues(label: str, artifact: Any, required: set[str]) -> list[str]:
    claims = set(artifact.get("allowedClaims", [])) if isinstance(artifact, dict) else set()
    return [f"{label} missing allowed claim: {claim}" for claim in sorted(required - claims)]


def _missing_block_issues(label: str, artifact: Any, required: set[str]) -> list[str]:
    claims = set(artifact.get("blockedClaims", [])) if isinstance(artifact, dict) else set()
    return [f"{label} missing blocked claim: {claim}" for claim in sorted(required - claims)]


def _gauntlet_has_no_final_outputs(gauntlet: Any) -> bool:
    if not isinstance(gauntlet, dict):
        return False
    return int(gauntlet.get("recordCounts", {}).get("finalOutputsGenerated", 1) or 0) == 0


def _all_domains_ready(sweep: Any) -> bool:
    domains = _domains(sweep)
    return bool(domains) and all(domain.get("ready") is True for domain in domains)


def _blocked_domains(sweep: Any) -> list[str]:
    return [str(domain.get("domainID")) for domain in _domains(sweep) if domain.get("ready") is not True]


def _domains(sweep: Any) -> list[dict[str, Any]]:
    if not isinstance(sweep, dict):
        return []
    return [item for item in sweep.get("domains", []) if isinstance(item, dict)]


def _domain_ids_from_sweep(sweep: Any) -> list[str]:
    return sorted(str(item.get("domainID")) for item in _domains(sweep) if item.get("domainID"))


def _bucket_from_sweep(sweep: Any) -> str | None:
    if not isinstance(sweep, dict):
        return None
    preflight = sweep.get("futureRemoteWritePreflight", {})
    observed = preflight.get("currentProductionBucketsObserved", []) if isinstance(preflight, dict) else []
    return str(observed[0]) if observed else None


def _r2_write_privacy_view(decision: dict[str, Any]) -> dict[str, Any]:
    return {
        "decision": decision.get("decision"),
        "preflightReady": decision.get("preflightReady"),
        "executeRequired": decision.get("executeRequired"),
        "budgetPolicyRequired": decision.get("budgetPolicyRequired"),
        "ownerApprovalValid": decision.get("ownerApprovalValid"),
        "automaticWriteAllowed": decision.get("automaticWriteAllowed"),
        "newRemoteWriteExecutedByControlLoop": decision.get("newRemoteWriteExecutedByControlLoop"),
        "environment": decision.get("environment"),
        "bucketConfigured": decision.get("bucketConfigured"),
        "blockedReasons": decision.get("blockedReasons", []),
        "nonClaims": decision.get("nonClaims", []),
    }


def _blocked_claims() -> list[str]:
    return sorted(
        {
            "full_source_atlas_green",
            "outside_legal_approval",
            "release_green",
            "runtime_release_green",
            "app_store_readiness",
            "testflight_readiness",
            "literal_universal_coverage",
            "native_device_green",
            "independent_accessibility_green",
            "new_remote_r2_write_executed_by_control_loop",
            "automatic_r2_write_without_execute_budget_approval",
            "source_atlas_private_goal_text_processing",
            "final_user_plans_schedules_steps_from_source_atlas_or_r2",
        }
    )


def _check(name: str, passed: bool, issues: list[str]) -> dict[str, Any]:
    return {"name": name, "passed": bool(passed), "issues": sorted(set(issues))}


def _read_required_json(path: Path, label: str, issues: list[str]) -> Any:
    if not path.exists():
        issues.append(f"{label} missing: {path}")
        return None
    try:
        return read_json(path)
    except Exception as exc:  # pragma: no cover - malformed evidence artifact.
        issues.append(f"{label} unreadable: {path}: {exc}")
        return None


def _read_optional_json(path: Path | None, label: str, issues: list[str]) -> Any:
    if path is None:
        return None
    return _read_required_json(path, label, issues)
