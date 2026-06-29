"""Production sweep for current Source Atlas delivery state.

This sweep is intentionally evidence-reconciliatory. It does not harvest,
publish, deploy, or mutate native runtime state. It verifies that the current
configured-frontier production evidence is internally coherent, then reports
whether the local machine is ready to run a future approved remote R2 write.
"""

from __future__ import annotations

import os
import shutil
from dataclasses import dataclass
from pathlib import Path
from typing import Any

from .boundary import boundary_issue_strings, boundary_issues_for_value, object_key_issues
from .model import NON_CLAIMS, PRIVACY_BOUNDARY, read_json, stable_hash, stable_id, write_json
from .r2_owner_approval import validate_r2_owner_approval_artifact


PRODUCTION_SWEEP_VERSION = "source-atlas-production-sweep-train-116"
PRODUCTION_SWEEP_KIND = "ambitions.sourceAtlas.productionSweep.v1"

SECRET_ENV_NAMES = {
    "CLOUDFLARE_API_TOKEN",
    "CLOUDFLARE_ACCOUNT_ID",
    "CLOUDFLARE_R2_ACCESS_KEY_ID",
    "CLOUDFLARE_R2_SECRET_ACCESS_KEY",
    "AWS_ACCESS_KEY_ID",
    "AWS_SECRET_ACCESS_KEY",
    "SOURCE_ATLAS_R2_ACCESS_KEY_ID",
    "SOURCE_ATLAS_R2_SECRET_ACCESS_KEY",
}
BUCKET_ENV_BY_ENVIRONMENT = {
    "production": "SOURCE_ATLAS_R2_PRODUCTION_BUCKET",
    "staging": "SOURCE_ATLAS_R2_STAGING_BUCKET",
}
REQUIRED_FINISH_LINE_CLAIMS = {
    "bounded_configured_production_target",
    "internal_terms_review",
    "production_r2_write_readback",
    "bounded_live_transport",
    "bounded_configured_runtime_green",
    "gateway_native_runtime_recertification",
}
REQUIRED_R2_CHECKS = {
    "object_keys_public",
    "payloads_public_reference_only",
    "source_license_slices_present",
    "non_private_scan_passed",
    "legal_terms_approval_packet_valid",
    "production_target_ledger_gate",
    "remote_r2_public_reference_transport_only",
    "upload_readback_checksums",
    "current_pointer_after_readback_only",
    "no_final_plan_schedule_step_output",
}
REQUIRED_PACK_CHECKS = {
    "governance_registries_valid",
    "pack_slices_written",
    "pack_contains_only_packable_claims",
    "restricted_and_crosswalk_claims_excluded",
    "manifest_hashes_present",
    "revocation_lkg_rollback_present",
    "private_object_keys_blocked",
    "non_private_scan_passed",
    "required_artifacts_valid",
    "legal_terms_approval_packet_valid",
    "no_final_plan_schedule_step_output",
}
PRODUCTION_SWEEP_NON_CLAIMS = [
    "current configured-frontier production sweep only",
    "not a new harvest",
    "not a new production R2 write",
    "not a Worker deploy",
    "not native device proof",
    "not independent accessibility proof",
    "not outside legal approval",
    "not Release Green",
    "not App Store or TestFlight readiness",
    "not literal universal coverage",
    "not final user plans, schedules, Steps, or personalized paths from Source Atlas/R2",
    *NON_CLAIMS,
]


@dataclass(frozen=True)
class ProductionSweepOptions:
    production_target_ledger_path: Path
    production_finish_line_gate_path: Path
    arbitrary_domain_gate_path: Path
    output_root: Path
    goal_domain_gauntlet_path: Path | None = None
    created_at: str = "2026-06-29T00:20:00Z"
    environment: str = "production"
    r2_bucket: str | None = None
    env_file_paths: tuple[Path, ...] | None = None
    approval_artifact_path: Path | None = None
    legal_approval_packet_path: Path | None = None
    require_new_remote_write_ready: bool = False


def run_production_sweep(options: ProductionSweepOptions) -> dict[str, Any]:
    output_root = options.output_root
    output_root.mkdir(parents=True, exist_ok=True)

    issues: list[str] = []
    ledger = _read_required_json(options.production_target_ledger_path, "production target ledger", issues)
    finish_line = _read_required_json(options.production_finish_line_gate_path, "production finish-line gate", issues)
    arbitrary_gate = _read_required_json(options.arbitrary_domain_gate_path, "arbitrary-domain gate", issues)
    goal_domain_gauntlet = _read_optional_json(options.goal_domain_gauntlet_path, "goal-domain gauntlet", issues)

    domain_sweeps = _domain_sweeps(ledger)
    domain_issues = [issue for domain in domain_sweeps for issue in domain["issues"]]
    finish_line_eval = _finish_line_eval(finish_line)
    arbitrary_eval = _arbitrary_gate_eval(arbitrary_gate)
    gauntlet_eval = _goal_domain_gauntlet_eval(goal_domain_gauntlet)
    write_preflight = _write_preflight(options, domain_sweeps)
    privacy_issues = boundary_issue_strings(
        boundary_issues_for_value(
            {
                "domains": _domain_privacy_view(domain_sweeps),
                "finishLine": finish_line_eval,
                "arbitraryDomainGate": arbitrary_eval,
                "goalDomainGauntlet": gauntlet_eval,
                "writePreflight": _write_preflight_privacy_view(write_preflight),
            },
            "source-atlas-production-sweep",
        )
    )
    issues.extend(domain_issues)
    issues.extend(finish_line_eval["issues"])
    issues.extend(arbitrary_eval["issues"])
    issues.extend(gauntlet_eval["issues"])
    issues.extend(privacy_issues)
    if options.require_new_remote_write_ready and not write_preflight["readyForNewRemoteWrite"]:
        issues.extend(write_preflight["blockedReasons"])

    record_counts = {
        "configuredDomains": len(domain_sweeps),
        "domainsReady": sum(1 for domain in domain_sweeps if domain["ready"]),
        "domainsBlocked": sum(1 for domain in domain_sweeps if not domain["ready"]),
        "packReportsValid": sum(1 for domain in domain_sweeps if domain["pack"]["valid"]),
        "r2ReportsValid": sum(1 for domain in domain_sweeps if domain["r2"]["valid"]),
        "remoteR2UploadsReconciled": sum(1 for domain in domain_sweeps if domain["r2"]["remoteUploadReadbackReady"]),
        "unknownDomainsCandidateOnly": arbitrary_eval["unknownDomainsCandidateOnly"],
        "goalDomainGauntletCases": gauntlet_eval["recordCounts"].get("configuredGauntletCases", 0),
        "goalDomainGauntletValid": gauntlet_eval["valid"],
        "privacyIssues": len(privacy_issues),
        "newRemoteWriteBlockedReasons": len(write_preflight["blockedReasons"]),
    }
    checks = [
        _check("production_target_ledger_loaded", isinstance(ledger, dict), [] if isinstance(ledger, dict) else ["production target ledger missing"]),
        _check("all_ledger_domains_ready", record_counts["domainsReady"] == record_counts["configuredDomains"] and bool(domain_sweeps), [domain["domainID"] for domain in domain_sweeps if not domain["ready"]]),
        _check("pack_reports_valid_for_all_domains", record_counts["packReportsValid"] == record_counts["configuredDomains"] and bool(domain_sweeps), [domain["domainID"] for domain in domain_sweeps if not domain["pack"]["valid"]]),
        _check("remote_r2_upload_readback_reconciled_for_all_domains", record_counts["remoteR2UploadsReconciled"] == record_counts["configuredDomains"] and bool(domain_sweeps), [domain["domainID"] for domain in domain_sweeps if not domain["r2"]["remoteUploadReadbackReady"]]),
        _check("finish_line_gate_valid_for_current_production", finish_line_eval["valid"], finish_line_eval["issues"]),
        _check("arbitrary_domain_gate_valid", arbitrary_eval["valid"], arbitrary_eval["issues"]),
        _check("unknown_domains_remain_candidate_only", arbitrary_eval["unknownDomainsCandidateOnly"], arbitrary_eval["candidateIssues"]),
        _check("goal_domain_gauntlet_valid_when_supplied", gauntlet_eval["valid"], gauntlet_eval["issues"]),
        _check("current_write_preflight_reported_without_secret_values", write_preflight["secretValuesPrinted"] is False, []),
        _check("future_remote_write_ready_when_required", (not options.require_new_remote_write_ready) or write_preflight["readyForNewRemoteWrite"], write_preflight["blockedReasons"]),
        _check("privacy_boundary", not privacy_issues, privacy_issues),
    ]
    valid = not issues and all(check["passed"] for check in checks)
    overall = (
        "current_configured_production_operational_sweep_green"
        if valid
        else "blocked_or_partial"
    )
    allowed_claims = []
    if valid:
        allowed_claims.extend(
            [
                "current_configured_frontier_production_sweep",
                "current_remote_r2_upload_readback_reconciled",
                "governed_arbitrary_public_reference_domain_routing_reconciled",
            ]
        )
    if write_preflight["readyForNewRemoteWrite"]:
        allowed_claims.append("future_remote_r2_write_preflight_ready")
    if gauntlet_eval["supplied"] and gauntlet_eval["valid"]:
        allowed_claims.append("representative_goal_domain_gauntlet_reconciled")

    report_path = output_root / "production-sweep-report.json"
    markdown_path = output_root / "production-sweep-report.md"
    closeout_path = output_root / "closeout.md"
    report = {
        "schemaVersion": 1,
        "kind": PRODUCTION_SWEEP_KIND,
        "versionID": PRODUCTION_SWEEP_VERSION,
        "createdAt": options.created_at,
        "sweepID": stable_id(
            "source_atlas.production_sweep",
            {
                "ledger": str(options.production_target_ledger_path),
                "finishLine": str(options.production_finish_line_gate_path),
                "arbitraryDomainGate": str(options.arbitrary_domain_gate_path),
                "createdAt": options.created_at,
                "domains": [domain["domainID"] for domain in domain_sweeps],
            },
        ),
        "status": "Source Green for current configured production sweep" if valid else "Red",
        "valid": valid,
        "sourceAtlasStatusCeiling": "Yellow overall Source Atlas; current configured-frontier production sweep only",
        "overallReadinessStatus": overall,
        "recordCounts": record_counts,
        "checks": checks,
        "issues": sorted(set(issues)),
        "domains": domain_sweeps,
        "finishLineEvaluation": finish_line_eval,
        "arbitraryDomainEvaluation": arbitrary_eval,
        "goalDomainGauntletEvaluation": gauntlet_eval,
        "futureRemoteWritePreflight": write_preflight,
        "allowedClaims": allowed_claims,
        "blockedClaims": _blocked_claims(write_preflight),
        "privacyBoundary": PRIVACY_BOUNDARY,
        "privacyIssues": privacy_issues,
        "nonClaims": PRODUCTION_SWEEP_NON_CLAIMS,
        "evidencePaths": {
            "productionTargetLedger": str(options.production_target_ledger_path),
            "productionFinishLineGate": str(options.production_finish_line_gate_path),
            "arbitraryDomainGate": str(options.arbitrary_domain_gate_path),
            "goalDomainGauntlet": str(options.goal_domain_gauntlet_path) if options.goal_domain_gauntlet_path else None,
            "approvalArtifact": str(options.approval_artifact_path) if options.approval_artifact_path else None,
            "legalApprovalPacket": str(options.legal_approval_packet_path) if options.legal_approval_packet_path else None,
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
    markdown = production_sweep_markdown(report)
    markdown_path.write_text(markdown, encoding="utf-8")
    closeout_path.write_text(markdown, encoding="utf-8")
    return report


def production_sweep_markdown(report: dict[str, Any]) -> str:
    counts = report["recordCounts"]
    lines = [
        "# Source Atlas Production Sweep Train 116",
        "",
        f"Status: {report['status']}",
        f"Source Atlas status ceiling: {report['sourceAtlasStatusCeiling']}",
        f"Overall readiness: {report['overallReadinessStatus']}",
        "",
        "Scope completed:",
        "- Reconciled the current production target ledger, production finish-line gate, arbitrary-domain gate, pack reports, and remote R2 upload/readback reports.",
        "- Verified every configured production domain has current pack, R2, gateway/native, and candidate-only expansion boundary evidence.",
        "- Reported future remote R2 write preflight separately without printing secret values or mutating R2.",
        "",
        "Counts:",
        f"- Configured domains: {counts['configuredDomains']}",
        f"- Domains ready: {counts['domainsReady']}",
        f"- Pack reports valid: {counts['packReportsValid']}",
        f"- R2 reports valid: {counts['r2ReportsValid']}",
        f"- Remote R2 uploads reconciled: {counts['remoteR2UploadsReconciled']}",
        f"- Unknown domains candidate-only: {'yes' if counts['unknownDomainsCandidateOnly'] else 'no'}",
        f"- Goal-domain gauntlet cases: {counts['goalDomainGauntletCases']}",
        "",
        "Domain sweep:",
        "",
        "| Domain | Ready | Pack | R2 Remote Upload/Readback | Packable Claims | Issues |",
        "| --- | --- | --- | --- | --- | --- |",
    ]
    for domain in report.get("domains", []):
        lines.append(
            "| {domain} | {ready} | {pack} | {r2} | {claims} | {issues} |".format(
                domain=domain["domainID"],
                ready="yes" if domain["ready"] else "no",
                pack="yes" if domain["pack"]["valid"] else "no",
                r2="yes" if domain["r2"]["remoteUploadReadbackReady"] else "no",
                claims=domain.get("packableClaimCount", 0),
                issues="<br>".join(domain.get("issues", [])) or "none",
            )
        )
    preflight = report["futureRemoteWritePreflight"]
    lines.extend(
        [
            "",
            "Future remote R2 write preflight:",
            f"- Wrangler installed: {'yes' if preflight['wranglerInstalled'] else 'no'}",
            f"- Credential groups present: {', '.join(preflight['credentialGroupsPresent']) or 'none'}",
            f"- Bucket configured for new writes: {'yes' if preflight['bucketConfigured'] else 'no'}",
            f"- Approval artifact present: {'yes' if preflight['approvalArtifactPresent'] else 'no'}",
            f"- Legal packet present: {'yes' if preflight['legalApprovalPacketPresent'] else 'no'}",
            f"- Ready for a future new remote write: {'yes' if preflight['readyForNewRemoteWrite'] else 'no'}",
            "",
            "Product law preserved:",
            "- R2 remains public/reference/freshness infrastructure only.",
            "- Sweep inputs and outputs are domain IDs, source IDs, pack IDs, public object keys, checksums, and proof artifact paths.",
            "- No private user context, goals, captures, schedules, proof, receipts, account IDs, device IDs, behavior history, inferred priorities, or private graph data is introduced.",
            "- Source Atlas/R2 does not generate final plans, schedules, Steps, or personalized paths.",
            "",
            "Production non-claims:",
        ]
    )
    lines.extend(f"- {claim}" for claim in report.get("nonClaims", []))
    lines.extend(
        [
            "",
            "Rollback plan:",
            "- Revert Train 116 production sweep module, CLI wiring, focused tests, generated sweep artifacts, and QA evidence.",
            "- Prior production target ledger, finish-line gate, and arbitrary-domain gate remain usable independently.",
            "",
        ]
    )
    return "\n".join(lines)


def _domain_sweeps(ledger: Any) -> list[dict[str, Any]]:
    if not isinstance(ledger, dict):
        return []
    sweeps = []
    for domain in sorted(ledger.get("domains", []), key=lambda item: item.get("domainID", "")):
        domain_id = domain.get("domainID", "")
        pack = _pack_eval(Path(domain.get("packProductionPath", "")), domain_id)
        r2 = _r2_eval(Path(domain.get("r2PublisherPath", "")), domain_id)
        issues = []
        if domain.get("readinessStatus") != "bounded_production_target_ready":
            issues.append(f"{domain_id}: ledger readiness is {domain.get('readinessStatus')}")
        for field in [
            "frontierConfigured",
            "claimGraphProofComplete",
            "packProductionProofComplete",
            "r2ProductionProofComplete",
            "gatewayProofComplete",
            "nativeRegistryProofComplete",
            "nativeRuntimeBoundaryProofComplete",
            "nativeUsabilityProofComplete",
        ]:
            if domain.get(field) is not True:
                issues.append(f"{domain_id}: ledger field {field} is not true")
        issues.extend(pack["issues"])
        issues.extend(r2["issues"])
        ready = not issues
        sweeps.append(
            {
                "domainID": domain_id,
                "ready": ready,
                "packableClaimCount": domain.get("packableClaimCount", 0),
                "sourceIDs": sorted(domain.get("sourceIDs", [])),
                "pack": pack,
                "r2": r2,
                "ledgerReadinessStatus": domain.get("readinessStatus"),
                "issues": issues,
            }
        )
    return sweeps


def _pack_eval(path: Path, domain_id: str) -> dict[str, Any]:
    issues: list[str] = []
    report = _read_json_if_exists(path)
    if not isinstance(report, dict):
        return {"path": str(path), "valid": False, "issues": [f"{domain_id}: pack report missing or unreadable: {path}"]}
    if report.get("valid") is not True:
        issues.append(f"{domain_id}: pack report invalid")
    if report.get("environment") != "production":
        issues.append(f"{domain_id}: pack environment is not production")
    if report.get("channel") != "stable":
        issues.append(f"{domain_id}: pack channel is not stable")
    if report.get("domain") != domain_id:
        issues.append(f"{domain_id}: pack domain mismatch: {report.get('domain')}")
    missing_checks = sorted(REQUIRED_PACK_CHECKS - _passed_check_names(report))
    if missing_checks:
        issues.append(f"{domain_id}: pack missing passed checks: {', '.join(missing_checks)}")
    if report.get("nonPrivateScan", {}).get("passed") is not True:
        issues.append(f"{domain_id}: pack non-private scan did not pass")
    return {
        "path": str(path),
        "valid": not issues,
        "packID": report.get("packID"),
        "packVersion": report.get("packVersion"),
        "claimCount": int(report.get("recordCounts", {}).get("claims", 0) or 0),
        "sourceCount": int(report.get("recordCounts", {}).get("sources", 0) or 0),
        "issues": issues,
    }


def _r2_eval(path: Path, domain_id: str) -> dict[str, Any]:
    issues: list[str] = []
    report = _read_json_if_exists(path)
    if not isinstance(report, dict):
        return {"path": str(path), "valid": False, "remoteUploadReadbackReady": False, "issues": [f"{domain_id}: R2 report missing or unreadable: {path}"]}
    pack_domain = _domain_from_pack_id(str(report.get("packID", "")))
    if pack_domain != domain_id:
        issues.append(f"{domain_id}: R2 pack domain mismatch: {pack_domain}")
    if report.get("valid") is not True:
        issues.append(f"{domain_id}: R2 report invalid")
    if report.get("environment") != "production":
        issues.append(f"{domain_id}: R2 environment is not production")
    if report.get("channel") != "stable":
        issues.append(f"{domain_id}: R2 channel is not stable")
    if report.get("mode") != "remote_r2":
        issues.append(f"{domain_id}: R2 mode is not remote_r2")
    if report.get("executeRequested") is not True:
        issues.append(f"{domain_id}: R2 executeRequested is not true")
    if report.get("productionR2Uploaded") is not True:
        issues.append(f"{domain_id}: production R2 upload is not true")
    if report.get("realR2CredentialsUsed") is not True:
        issues.append(f"{domain_id}: real R2 credentials used is not true")
    missing_checks = sorted(REQUIRED_R2_CHECKS - _passed_check_names(report))
    if missing_checks:
        issues.append(f"{domain_id}: R2 missing passed checks: {', '.join(missing_checks)}")
    operation = report.get("operation", {})
    if operation.get("success") is not True or operation.get("executed") is not True:
        issues.append(f"{domain_id}: R2 operation did not execute successfully")
    pointer = report.get("currentPointer", {})
    for key_name in ["manifestKey", "lastKnownGoodKey", "revocationManifestKey"]:
        key = str(pointer.get(key_name, ""))
        key_issues = [issue.format() for issue in object_key_issues(key, label=f"{domain_id}.{key_name}")]
        if key_issues:
            issues.extend(key_issues)
        if domain_id and f"/{domain_id}/" not in key:
            issues.append(f"{domain_id}: pointer {key_name} does not include domain ID")
    if pointer.get("publicReferenceOnly") is not True:
        issues.append(f"{domain_id}: current pointer is not publicReferenceOnly")
    return {
        "path": str(path),
        "valid": not issues,
        "remoteUploadReadbackReady": not issues,
        "packID": report.get("packID"),
        "packVersion": report.get("packVersion"),
        "bucket": operation.get("bucket"),
        "objectCount": int(report.get("objectCount", 0) or 0),
        "manifestKey": pointer.get("manifestKey"),
        "currentKey": operation.get("currentPointer", {}).get("key"),
        "issues": issues,
    }


def _finish_line_eval(finish_line: Any) -> dict[str, Any]:
    issues: list[str] = []
    if not isinstance(finish_line, dict):
        return {"valid": False, "issues": ["production finish-line gate missing"], "allowedClaims": []}
    if finish_line.get("valid") is not True:
        issues.append("production finish-line gate is not valid")
    allowed = set(finish_line.get("allowedClaims", []))
    missing = sorted(REQUIRED_FINISH_LINE_CLAIMS - allowed)
    if missing:
        issues.append(f"production finish-line gate missing allowed claims: {', '.join(missing)}")
    if "release_green" not in finish_line.get("blockedClaims", []):
        issues.append("production finish-line gate must keep release_green blocked")
    if "universal_coverage" not in finish_line.get("blockedClaims", []):
        issues.append("production finish-line gate must keep universal_coverage blocked")
    return {
        "valid": not issues,
        "allowedClaims": sorted(allowed),
        "blockedClaims": sorted(finish_line.get("blockedClaims", [])),
        "issues": issues,
    }


def _arbitrary_gate_eval(arbitrary_gate: Any) -> dict[str, Any]:
    issues: list[str] = []
    candidate_issues: list[str] = []
    if not isinstance(arbitrary_gate, dict):
        return {"valid": False, "unknownDomainsCandidateOnly": False, "candidateIssues": ["arbitrary-domain gate missing"], "issues": ["arbitrary-domain gate missing"]}
    if arbitrary_gate.get("valid") is not True:
        issues.append("arbitrary-domain gate is not valid")
    counts = arbitrary_gate.get("recordCounts", {})
    candidate_expectations = {
        "candidateClaims": 0,
        "candidateR2PublishOperations": 0,
        "candidateNativeActivationOperations": 0,
        "candidateProductionWrites": 0,
    }
    for key, expected in candidate_expectations.items():
        if counts.get(key) != expected:
            candidate_issues.append(f"{key} expected {expected}, got {counts.get(key)}")
    unknown_candidate_only = not candidate_issues and int(counts.get("unknownProbeDomains", 0) or 0) >= 0
    issues.extend(candidate_issues)
    return {
        "valid": not issues,
        "overallReadinessStatus": arbitrary_gate.get("overallReadinessStatus"),
        "unknownDomainsCandidateOnly": unknown_candidate_only,
        "candidateIssues": candidate_issues,
        "recordCounts": counts,
        "issues": issues,
    }


def _goal_domain_gauntlet_eval(gauntlet: Any) -> dict[str, Any]:
    if gauntlet is None:
        return {
            "supplied": False,
            "valid": True,
            "overallReadinessStatus": "not_supplied",
            "allowedClaims": [],
            "blockedClaims": [],
            "recordCounts": {},
            "issues": [],
        }
    issues: list[str] = []
    if not isinstance(gauntlet, dict):
        return {
            "supplied": True,
            "valid": False,
            "overallReadinessStatus": "blocked_or_partial",
            "allowedClaims": [],
            "blockedClaims": [],
            "recordCounts": {},
            "issues": ["goal-domain gauntlet missing or unreadable"],
        }
    if gauntlet.get("valid") is not True:
        issues.append("goal-domain gauntlet valid flag is not true")
    required_claims = {
        "representative_goal_domain_gauntlet_green",
        "configured_frontier_goal_domain_runtime_routing",
        "unknown_public_reference_domains_candidate_only",
    }
    missing_claims = sorted(required_claims - set(gauntlet.get("allowedClaims", [])))
    if missing_claims:
        issues.append(f"goal-domain gauntlet missing allowed claims: {', '.join(missing_claims)}")
    counts = gauntlet.get("recordCounts", {})
    if int(counts.get("configuredCasesBlocked", 0) or 0) != 0:
        issues.append("goal-domain gauntlet has blocked configured cases")
    if int(counts.get("unknownCasesBlocked", 0) or 0) != 0:
        issues.append("goal-domain gauntlet has blocked unknown cases")
    if int(counts.get("finalOutputsGenerated", 0) or 0) != 0:
        issues.append("goal-domain gauntlet generated final outputs")
    return {
        "supplied": True,
        "valid": not issues,
        "overallReadinessStatus": gauntlet.get("overallReadinessStatus"),
        "allowedClaims": sorted(gauntlet.get("allowedClaims", [])),
        "blockedClaims": sorted(gauntlet.get("blockedClaims", [])),
        "recordCounts": counts,
        "issues": issues,
    }


def _write_preflight(options: ProductionSweepOptions, domain_sweeps: list[dict[str, Any]]) -> dict[str, Any]:
    runtime_env, loaded = _runtime_env(options.env_file_paths)
    bucket_env_name = BUCKET_ENV_BY_ENVIRONMENT.get(options.environment, "SOURCE_ATLAS_R2_PRODUCTION_BUCKET")
    explicit_bucket = options.r2_bucket or ""
    env_bucket = runtime_env.get(bucket_env_name, "").strip()
    resolved_bucket = explicit_bucket or env_bucket
    credential_names = sorted(name for name in SECRET_ENV_NAMES if runtime_env.get(name))
    credential_groups = _credential_groups(credential_names)
    approval_present = bool(options.approval_artifact_path and options.approval_artifact_path.exists())
    legal_present = bool(options.legal_approval_packet_path and options.legal_approval_packet_path.exists())
    approval_validation = validate_r2_owner_approval_artifact(
        options.approval_artifact_path,
        environment=options.environment,
        channel="stable",
        bucket=resolved_bucket or None,
        domain_ids=[domain["domainID"] for domain in domain_sweeps],
    )
    blocked: list[str] = []
    if shutil.which("wrangler") is None:
        blocked.append("wrangler is not installed")
    if not credential_names:
        blocked.append("no Cloudflare/R2 credential environment names are present")
    if not resolved_bucket:
        blocked.append(f"new remote writes require --r2-bucket or {bucket_env_name}")
    if not approval_validation["valid"]:
        blocked.append("new production/stable remote writes require a valid owner approval artifact")
        if approval_present:
            blocked.extend(f"owner approval: {issue}" for issue in approval_validation.get("issues", []))
    if not legal_present:
        blocked.append("new production/stable remote writes require a legal approval packet path")
    buckets_from_current_reports = sorted({str(domain["r2"].get("bucket")) for domain in domain_sweeps if domain["r2"].get("bucket")})
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.futureRemoteWritePreflight.v1",
        "environment": options.environment,
        "wranglerInstalled": shutil.which("wrangler") is not None,
        "credentialEnvNameCount": len(credential_names),
        "credentialGroupsPresent": credential_groups,
        "credentialsAvailable": bool(credential_names),
        "envFilesLoaded": loaded,
        "bucketEnvName": bucket_env_name,
        "bucketConfigured": bool(explicit_bucket or env_bucket),
        "bucketSource": "explicit" if explicit_bucket else ("env" if env_bucket else "missing"),
        "currentProductionBucketsObserved": buckets_from_current_reports,
        "approvalArtifactPresent": approval_present,
        "approvalArtifactValidation": {
            "valid": approval_validation["valid"],
            "status": approval_validation["status"],
            "kind": approval_validation.get("kind"),
            "domainCount": approval_validation.get("domainCount", 0),
            "approvedDomains": approval_validation.get("approvedDomains", []),
            "issues": approval_validation.get("issues", []),
        },
        "legalApprovalPacketPresent": legal_present,
        "readyForNewRemoteWrite": not blocked,
        "blockedReasons": blocked,
        "secretValuesPrinted": False,
    }


def _runtime_env(env_file_paths: tuple[Path, ...] | None) -> tuple[dict[str, str], list[str]]:
    runtime_env = dict(os.environ)
    loaded: list[str] = []
    for path in _default_env_files() if env_file_paths is None else env_file_paths:
        if _load_env_file(path, runtime_env):
            loaded.append(_safe_env_file_path(path))
    return runtime_env, loaded


def _default_env_files() -> list[Path]:
    foundry_root = Path(__file__).resolve().parent
    source_atlas_root = foundry_root.parents[0]
    repo_root = foundry_root.parents[2]
    return [foundry_root / ".env", source_atlas_root / ".env", repo_root / ".env"]


def _load_env_file(path: Path, target: dict[str, str]) -> bool:
    if not path.exists():
        return False
    parsed = False
    for line in path.read_text(encoding="utf-8").splitlines():
        stripped = line.strip()
        if not stripped or stripped.startswith("#") or "=" not in stripped:
            continue
        key, value = stripped.split("=", 1)
        key = key.strip()
        value = value.strip().strip('"').strip("'")
        if key and key not in target:
            target[key] = value
        parsed = True
    return parsed


def _safe_env_file_path(path: Path) -> str:
    try:
        return str(path.resolve().relative_to(Path.cwd().resolve()))
    except ValueError:
        return path.name


def _domain_privacy_view(domain_sweeps: list[dict[str, Any]]) -> list[dict[str, Any]]:
    return [
        {
            "domainID": domain["domainID"],
            "ready": domain["ready"],
            "packID": domain["pack"].get("packID"),
            "r2PackID": domain["r2"].get("packID"),
            "manifestKey": domain["r2"].get("manifestKey"),
            "sourceIDs": domain.get("sourceIDs", []),
            "issues": domain.get("issues", []),
        }
        for domain in domain_sweeps
    ]


def _write_preflight_privacy_view(preflight: dict[str, Any]) -> dict[str, Any]:
    return {
        "environment": preflight["environment"],
        "wranglerInstalled": preflight["wranglerInstalled"],
        "credentialEnvNameCount": preflight["credentialEnvNameCount"],
        "credentialGroupsPresent": preflight["credentialGroupsPresent"],
        "bucketConfigured": preflight["bucketConfigured"],
        "bucketSource": preflight["bucketSource"],
        "approvalArtifactPresent": preflight["approvalArtifactPresent"],
        "approvalArtifactValidation": {
            "valid": preflight["approvalArtifactValidation"]["valid"],
            "status": preflight["approvalArtifactValidation"]["status"],
            "domainCount": preflight["approvalArtifactValidation"]["domainCount"],
        },
        "legalApprovalPacketPresent": preflight["legalApprovalPacketPresent"],
        "readyForNewRemoteWrite": preflight["readyForNewRemoteWrite"],
        "blockedReasons": preflight["blockedReasons"],
        "secretValuesPrinted": preflight["secretValuesPrinted"],
    }


def _blocked_claims(write_preflight: dict[str, Any]) -> list[str]:
    claims = {
        "literal_universal_coverage",
        "full_source_atlas_green",
        "outside_legal_approval",
        "release_green",
        "app_store_readiness",
        "new_remote_r2_write_executed_by_this_sweep",
        "native_device_green",
        "independent_accessibility_green",
        "final_user_plans_schedules_steps_from_source_atlas_or_r2",
    }
    if not write_preflight["readyForNewRemoteWrite"]:
        claims.add("future_remote_r2_write_preflight_ready")
    return sorted(claims)


def _credential_groups(credential_names: list[str]) -> list[str]:
    groups = set()
    names = set(credential_names)
    if "CLOUDFLARE_API_TOKEN" in names or "CLOUDFLARE_ACCOUNT_ID" in names:
        groups.add("cloudflare_control")
    if {"CLOUDFLARE_R2_ACCESS_KEY_ID", "CLOUDFLARE_R2_SECRET_ACCESS_KEY"} <= names:
        groups.add("cloudflare_r2_access_pair")
    if {"SOURCE_ATLAS_R2_ACCESS_KEY_ID", "SOURCE_ATLAS_R2_SECRET_ACCESS_KEY"} <= names:
        groups.add("source_atlas_r2_access_pair")
    if {"AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY"} <= names:
        groups.add("aws_compatible_access_pair")
    return sorted(groups)


def _passed_check_names(report: dict[str, Any]) -> set[str]:
    return {check.get("name") for check in report.get("checks", []) if check.get("passed") is True}


def _domain_from_pack_id(pack_id: str) -> str:
    parts = pack_id.split("/")
    if len(parts) >= 5 and parts[:3] == ["source-atlas", "v1", "domain"]:
        return parts[3]
    return ""


def _read_required_json(path: Path, label: str, issues: list[str]) -> Any:
    if not path.exists():
        issues.append(f"{label} missing: {path}")
        return None
    try:
        return read_json(path)
    except Exception as exc:  # pragma: no cover - defensive path for malformed evidence files
        issues.append(f"{label} unreadable: {path}: {exc}")
        return None


def _read_optional_json(path: Path | None, label: str, issues: list[str]) -> Any:
    if path is None:
        return None
    return _read_required_json(path, label, issues)


def _read_json_if_exists(path: Path) -> Any:
    if not path.exists():
        return None
    try:
        return read_json(path)
    except Exception:
        return None


def _check(name: str, passed: bool, issues: list[str]) -> dict[str, Any]:
    return {"name": name, "passed": passed, "issues": issues}
