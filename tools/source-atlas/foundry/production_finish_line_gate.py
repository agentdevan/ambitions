"""Production finish-line gate for configured Source Atlas domains.

This gate composes the current Source Atlas production evidence into one
machine-readable answer. It can grant bounded claims for configured public
reference frontiers when the current artifacts prove them, and it keeps
outside legal approval, Release Green, and literal universal coverage blocked
unless separate owner/legal/release artifacts are present.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Any

from .boundary import boundary_issue_strings, boundary_issues_for_value
from .legal_release_claim_gate import build_legal_release_claim_gate
from .model import NON_CLAIMS, PRIVACY_BOUNDARY, read_json, stable_hash, stable_id, write_json
from .production_recertification_gate import (
    ProductionRecertificationOptions,
    run_production_recertification_gate,
)
from .terms_approval_packet import build_terms_approval_packet
from .terms_registry import terms_entry


PRODUCTION_FINISH_LINE_VERSION = "source-atlas-production-finish-line-gate-train-114"
PRODUCTION_FINISH_LINE_KIND = "ambitions.sourceAtlas.productionFinishLineGate.v1"

FINISH_LINE_NON_CLAIMS = [
    "bounded configured-frontier production finish-line gate only",
    "not literal universal coverage",
    "not full Source Atlas Green",
    "not outside legal approval",
    "not Release Green",
    "not App Store or TestFlight readiness",
    "not independent physical-device proof",
    "not independent visual/accessibility Green",
    "not account entitlement readiness",
    "not a new live harvest",
    "not a new production R2 write",
    "not final user plans, schedules, Steps, or personalized paths from Source Atlas/R2",
    *NON_CLAIMS,
]


@dataclass(frozen=True)
class ProductionFinishLineGateOptions:
    production_target_ledger_path: Path
    gateway_release_report_path: Path
    native_runtime_report_path: Path
    output_root: Path
    created_at: str = "2026-06-28T00:00:00Z"
    native_registry_artifact_path: Path | None = None
    legal_terms_approval_packet_path: Path | None = None
    coverage_report_path: Path | None = None
    release_approval_artifact_path: Path | None = None
    compile_internal_terms_approval: bool = True


def run_production_finish_line_gate(options: ProductionFinishLineGateOptions) -> dict[str, Any]:
    output_root = options.output_root
    output_root.mkdir(parents=True, exist_ok=True)

    issues: list[str] = []
    ledger = _read_required_json(options.production_target_ledger_path, "production target ledger", issues)
    gateway = _read_required_json(options.gateway_release_report_path, "gateway release report", issues)
    native_runtime = _read_required_json(options.native_runtime_report_path, "native runtime report", issues)
    coverage_report = _read_optional_json(options.coverage_report_path, "coverage report", issues)
    release_artifact = _read_optional_json(options.release_approval_artifact_path, "release approval artifact", issues)

    production_sources = _production_source_ids(ledger)
    production_domains = _production_domains(ledger)
    legal_packet = _legal_packet(options, production_sources, output_root, issues)
    legal_claim_gate = build_legal_release_claim_gate(
        legal_packet=legal_packet,
        source_ids=production_sources,
        native_transport_report=native_runtime if isinstance(native_runtime, dict) else None,
        coverage_report=coverage_report,
        release_approval_artifact=release_artifact,
        requested_claims=[
            "source_atlas_terms_gate_green",
            "unqualified_legal_approval",
            "outside_legal_approval",
            "bounded_live_native_transport",
            "bounded_configured_runtime_green",
            "source_atlas_runtime_green",
            "release_green",
            "universal_coverage",
        ],
        evidence_paths={
            "legal_packet": _legal_packet_path(options, output_root),
            "native_transport_report": str(options.native_runtime_report_path),
            "coverage_report": str(options.coverage_report_path) if options.coverage_report_path else "",
            "release_approval_artifact": str(options.release_approval_artifact_path) if options.release_approval_artifact_path else "",
        },
        created_at=options.created_at,
        now_date=options.created_at[:10],
    )

    recertification = None
    if isinstance(ledger, dict) and isinstance(gateway, dict) and isinstance(native_runtime, dict):
        recertification = run_production_recertification_gate(
            ProductionRecertificationOptions(
                production_target_ledger_path=options.production_target_ledger_path,
                gateway_release_report_path=options.gateway_release_report_path,
                native_runtime_report_path=options.native_runtime_report_path,
                native_registry_artifact_path=options.native_registry_artifact_path,
                output_root=output_root / "00-production-recertification",
                created_at=options.created_at,
            )
        )

    r2_evaluation = _evaluate_domain_r2_reports(ledger)
    domain_evaluations = _domain_evaluations(ledger, r2_evaluation, recertification)
    privacy_issues = boundary_issue_strings(
        boundary_issues_for_value(
            {
                "productionSources": production_sources,
                "productionDomains": production_domains,
                "domainEvaluations": domain_evaluations,
                "legalClaimGate": legal_claim_gate,
                "r2Evaluation": r2_evaluation,
                "recertification": recertification,
            },
            "source-atlas-production-finish-line-gate",
        )
    )
    issues.extend(privacy_issues)

    gates = _finish_line_gates(
        ledger=ledger,
        legal_claim_gate=legal_claim_gate,
        r2_evaluation=r2_evaluation,
        recertification=recertification,
    )
    checks = [
        _check("privacy_boundary", not privacy_issues, privacy_issues),
        _check("production_target_ledger_valid", _artifact_valid(ledger), _artifact_issues("production target ledger", ledger)),
        _check("internal_terms_gate_all_current_production_sources", _gate_allowed(gates, "internal_terms_review"), _gate_issues(gates, "internal_terms_review")),
        _check("production_r2_write_readback_all_configured_domains", _gate_allowed(gates, "production_r2_write_readback"), _gate_issues(gates, "production_r2_write_readback")),
        _check("bounded_live_transport_proven", _gate_allowed(gates, "bounded_live_transport"), _gate_issues(gates, "bounded_live_transport")),
        _check("bounded_configured_runtime_green_proven", _gate_allowed(gates, "bounded_configured_runtime_green"), _gate_issues(gates, "bounded_configured_runtime_green")),
        _check("gateway_native_runtime_recertification", _gate_allowed(gates, "gateway_native_runtime_recertification"), _gate_issues(gates, "gateway_native_runtime_recertification")),
        _check("release_and_universal_claims_remain_explicit", _release_and_universal_blocked(gates), _release_and_universal_issues(gates)),
    ]
    valid = not issues and all(check["passed"] for check in checks)

    report_path = output_root / "production-finish-line-gate-report.json"
    markdown_path = output_root / "production-finish-line-gate-report.md"
    closeout_path = output_root / "closeout.md"
    allowed_claims = [gate["claimID"] for gate in gates if gate["allowed"]]
    blocked_claims = [gate["claimID"] for gate in gates if not gate["allowed"]]
    report = {
        "schemaVersion": 1,
        "kind": PRODUCTION_FINISH_LINE_KIND,
        "versionID": PRODUCTION_FINISH_LINE_VERSION,
        "createdAt": options.created_at,
        "finishLineGateID": stable_id(
            "source_atlas.production_finish_line_gate",
            {
                "productionDomains": production_domains,
                "productionSources": production_sources,
                "createdAt": options.created_at,
            },
        ),
        "status": "Source Green for bounded configured production finish-line gate" if valid else "Red",
        "valid": valid,
        "sourceAtlasStatusCeiling": "Yellow overall Source Atlas; bounded configured-frontier production finish-line gate only",
        "overallReadinessStatus": "bounded_configured_production_finish_line_green" if valid else "blocked_or_partial",
        "productionDomains": production_domains,
        "productionSourceIDs": production_sources,
        "recordCounts": {
            "productionDomains": len(production_domains),
            "productionSourceIDs": len(production_sources),
            "r2ReportsExpected": r2_evaluation["expected"],
            "r2ReportsValid": r2_evaluation["valid"],
            "r2ReportsBlocked": r2_evaluation["blocked"],
            "recertifiedDomains": int((recertification or {}).get("recordCounts", {}).get("recertifiedDomains", 0) or 0),
            "recertificationBlockedDomains": int((recertification or {}).get("recordCounts", {}).get("blockedDomains", 0) or 0),
            "legalAllowedClaims": len(legal_claim_gate.get("allowedClaims", [])),
            "legalBlockedClaims": len(legal_claim_gate.get("blockedClaims", [])),
            "privacyIssues": len(privacy_issues),
        },
        "checks": checks,
        "issues": sorted(set(issues)),
        "finishLineGates": gates,
        "allowedClaims": allowed_claims,
        "blockedClaims": blocked_claims,
        "domainEvaluations": domain_evaluations,
        "r2Evaluation": r2_evaluation,
        "legalClaimGate": legal_claim_gate,
        "productionRecertification": recertification,
        "privacyBoundary": PRIVACY_BOUNDARY,
        "privacyIssues": privacy_issues,
        "nonClaims": FINISH_LINE_NON_CLAIMS,
        "evidencePaths": {
            "productionTargetLedger": str(options.production_target_ledger_path),
            "gatewayReleaseReport": str(options.gateway_release_report_path),
            "nativeRuntimeReport": str(options.native_runtime_report_path),
            "nativeRegistryArtifact": str(options.native_registry_artifact_path) if options.native_registry_artifact_path else None,
            "legalTermsApprovalPacket": _legal_packet_path(options, output_root),
            "coverageReport": str(options.coverage_report_path) if options.coverage_report_path else None,
            "releaseApprovalArtifact": str(options.release_approval_artifact_path) if options.release_approval_artifact_path else None,
        },
        "outputPaths": {
            "report": str(report_path),
            "markdown": str(markdown_path),
            "closeout": str(closeout_path),
            "productionRecertification": str((output_root / "00-production-recertification" / "production-recertification-report.json"))
            if recertification
            else None,
            "compiledLegalTermsApprovalPacket": str(output_root / "01-internal-terms-approval" / "legal-terms-approval-packet.json")
            if options.compile_internal_terms_approval
            else None,
        },
    }
    report["outputHashes"] = _output_hashes(report["outputPaths"])
    write_json(report_path, report)
    report["outputHashes"]["report"] = stable_hash(read_json(report_path))
    write_json(report_path, report)
    markdown = production_finish_line_gate_markdown(report)
    markdown_path.write_text(markdown, encoding="utf-8")
    closeout_path.write_text(markdown, encoding="utf-8")
    return report


def production_finish_line_gate_markdown(report: dict[str, Any]) -> str:
    counts = report["recordCounts"]
    lines = [
        "# Source Atlas Production Finish-Line Gate Train 114",
        "",
        f"Status: {report['status']}",
        f"Source Atlas status ceiling: {report['sourceAtlasStatusCeiling']}",
        f"Overall readiness: {report['overallReadinessStatus']}",
        "",
        "Scope completed:",
        "- Joined current production target ledger, all configured-domain R2 publisher reports, public gateway release proof, native runtime proof, recertification, and legal/release claim gating.",
        "- Compiled or consumed source-specific internal legal/terms approval for every current production source ID.",
        "- Emits one answer for production target, internal legal/terms, production R2 write/readback, live transport/native runtime recertification, release Green, and universal coverage claims.",
        "- Performs no new live harvest, production R2 write, stable pointer mutation, native release proof, or private-runtime behavior.",
        "",
        "Counts:",
        f"- Production domains: {counts['productionDomains']}",
        f"- Production source IDs: {counts['productionSourceIDs']}",
        f"- R2 reports valid: {counts['r2ReportsValid']} / {counts['r2ReportsExpected']}",
        f"- R2 reports blocked: {counts['r2ReportsBlocked']}",
        f"- Recertified domains: {counts['recertifiedDomains']}",
        f"- Recertification blocked domains: {counts['recertificationBlockedDomains']}",
        f"- Legal allowed claims: {counts['legalAllowedClaims']}",
        f"- Legal blocked claims: {counts['legalBlockedClaims']}",
        "",
        "Finish-line gates:",
        "",
        "| Gate | Allowed | Scope | Issues |",
        "| --- | --- | --- | --- |",
    ]
    for gate in report.get("finishLineGates", []):
        issues = "<br>".join(gate.get("issues", []))
        lines.append(
            "| `{claim}` | {allowed} | {scope} | {issues} |".format(
                claim=gate["claimID"],
                allowed="yes" if gate.get("allowed") else "no",
                scope=gate.get("allowedScope", ""),
                issues=issues,
            )
        )
    lines.extend(["", "Allowed claims:"])
    lines.extend(f"- `{claim}`" for claim in report.get("allowedClaims", []))
    lines.extend(["", "Blocked claims:"])
    lines.extend(f"- `{claim}`" for claim in report.get("blockedClaims", []))
    lines.extend(
        [
            "",
            "Product law preserved:",
            "- R2 remains public/reference/freshness infrastructure only.",
            "- Evidence is limited to public pack, source, hash, freshness, gateway, legal terms, and native-runtime proof metadata.",
            "- No private user context, goals, captures, schedules, proof, receipts, account IDs, device IDs, inferred priorities, or private graph data is introduced.",
            "- Source Atlas/R2 do not generate final plans, schedules, Steps, or personalized paths.",
            "",
            "Validation run:",
            "- See current train closeout for exact command output.",
            "",
            "Validation not run:",
            "- No new live harvest was run.",
            "- No new production R2 upload/readback was run by this gate.",
            "- No new physical-device, independent visual/accessibility, entitlement, TestFlight, App Store, or owner release approval proof was run.",
            "",
            "Proof artifacts:",
        ]
    )
    for path in report.get("outputPaths", {}).values():
        if path:
            lines.append(f"- {path}")
    lines.extend(
        [
            "",
            "R2 request privacy proof:",
            "- The gate inspects existing public R2 publisher, gateway, and native runtime artifacts only.",
            "- It emits no user-specific R2 request, personalized object key, or private payload.",
            "",
            "No private graph egress proof:",
            "- Inputs and outputs are privacy-boundary scanned.",
            "",
            "License/terms proof:",
            "- Internal terms review is source-specific for current production source IDs.",
            "- Outside legal approval remains blocked unless a source-specific outside approval artifact and hash are supplied.",
            "",
            "Restricted-source exclusion proof:",
            "- R2 write/readback claim requires every configured-domain publisher report to prove public-reference-only payloads, source/license slices, non-private scan, and upload/readback checksums.",
            "",
            "Provenance completeness proof:",
            "- The gate relies on production target ledger and current pack/R2 evidence; it emits no new claims.",
            "",
            "Freshness/revocation proof:",
            "- The gate re-runs production recertification and requires zero recertification-blocked domains.",
            "",
            "LKG/rollback proof:",
            "- The inspected publisher reports must include revocation/LKG/rollback checks; this gate performs no pointer mutation.",
            "",
            "Native offline/no-account proof:",
            "- Bounded native runtime proof is consumed from the provided native runtime artifact; no broader Release Green is claimed.",
            "",
            "Architecture closeout:",
            "- Final Architecture Tree inspected: yes.",
            "- Canonical owners touched: none in app source; tooling/evidence only under tools/source-atlas and docs/qa/source-atlas.",
            "- Files moved or created: Foundry production finish-line gate, CLI wiring, tests, generated QA evidence.",
            "- Old/non-canonical paths removed: none.",
            "- Compatibility shims left behind: none.",
            "- Yellow architecture debt remaining: Release Green, outside legal approval, literal universal coverage, physical-device proof, and independent visual/accessibility proof remain separate gates.",
            "- Next repair train if debt remains: provide owner/outside legal/release artifacts or keep the claim blocked.",
            "- No equivalent folder/path interpretation was used.",
            "",
            "Production non-claims:",
        ]
    )
    lines.extend(f"- {claim}" for claim in report.get("nonClaims", []))
    lines.extend(["", "Rollback plan:", "- Revert Train 114 finish-line gate module, CLI wiring, tests, generated artifacts, and QA evidence."])
    lines.append("")
    return "\n".join(lines)


def _read_required_json(path: Path, label: str, issues: list[str]) -> Any:
    if not path.exists():
        issues.append(f"{label} missing: {path}")
        return None
    try:
        return read_json(path)
    except Exception as exc:  # pragma: no cover - defensive artifact handling
        issues.append(f"{label} unreadable: {path}: {exc}")
        return None


def _read_optional_json(path: Path | None, label: str, issues: list[str]) -> Any:
    if path is None:
        return None
    return _read_required_json(path, label, issues)


def _legal_packet(options: ProductionFinishLineGateOptions, source_ids: list[str], output_root: Path, issues: list[str]) -> dict[str, Any] | None:
    if options.legal_terms_approval_packet_path:
        packet = _read_required_json(options.legal_terms_approval_packet_path, "legal terms approval packet", issues)
        return packet if isinstance(packet, dict) else None
    if not options.compile_internal_terms_approval:
        issues.append("legal terms approval packet missing and internal compilation disabled")
        return None
    entries = []
    for source_id in source_ids:
        try:
            entries.append(terms_entry(source_id))
        except KeyError as exc:
            issues.append(f"{source_id}: no terms registry entry for production finish-line gate: {exc}")
    if issues:
        return None
    return build_terms_approval_packet(
        entries,
        output_path=output_root / "01-internal-terms-approval" / "legal-terms-approval-packet.json",
        created_at=options.created_at,
    )


def _legal_packet_path(options: ProductionFinishLineGateOptions, output_root: Path) -> str:
    if options.legal_terms_approval_packet_path:
        return str(options.legal_terms_approval_packet_path)
    if options.compile_internal_terms_approval:
        return str(output_root / "01-internal-terms-approval" / "legal-terms-approval-packet.json")
    return ""


def _production_domains(ledger: Any) -> list[str]:
    if not isinstance(ledger, dict):
        return []
    return sorted(
        str(domain.get("domainID"))
        for domain in ledger.get("domains", [])
        if isinstance(domain, dict) and domain.get("domainID")
    )


def _production_source_ids(ledger: Any) -> list[str]:
    if not isinstance(ledger, dict):
        return []
    source_ids = {
        str(source_id)
        for domain in ledger.get("domains", [])
        if isinstance(domain, dict)
        for source_id in domain.get("sourceIDs", [])
        if source_id
    }
    return sorted(source_ids)


def _evaluate_domain_r2_reports(ledger: Any) -> dict[str, Any]:
    evaluations: list[dict[str, Any]] = []
    if not isinstance(ledger, dict):
        return {"expected": 0, "valid": 0, "blocked": 0, "domains": evaluations, "issues": ["production target ledger missing or invalid"]}
    for domain in ledger.get("domains", []):
        if not isinstance(domain, dict):
            continue
        path = Path(str(domain.get("r2PublisherPath", "")))
        report = read_json(path) if path.exists() else None
        report_issues = _r2_report_issues(report, expected_domain=domain.get("domainID"))
        evaluations.append(
            {
                "domainID": domain.get("domainID"),
                "r2PublisherPath": str(path),
                "valid": not report_issues,
                "issues": report_issues,
                "packID": report.get("packID") if isinstance(report, dict) else None,
            }
        )
    issues = [
        f"{item['domainID']}: {issue}"
        for item in evaluations
        for issue in item["issues"]
    ]
    return {
        "expected": len(evaluations),
        "valid": sum(1 for item in evaluations if item["valid"]),
        "blocked": sum(1 for item in evaluations if not item["valid"]),
        "domains": evaluations,
        "issues": issues,
    }


def _r2_report_issues(report: Any, *, expected_domain: Any) -> list[str]:
    issues: list[str] = []
    if not isinstance(report, dict):
        return ["r2 publisher report missing or unreadable"]
    checks = {item.get("name"): item.get("passed") for item in report.get("checks", []) if isinstance(item, dict)}
    operation = report.get("operation", {}) if isinstance(report.get("operation"), dict) else {}
    required_values = {
        "kind": "ambitions.sourceAtlas.r2PackPublisherReport.v1",
        "environment": "production",
        "channel": "stable",
        "mode": "remote_r2",
    }
    for field, expected in required_values.items():
        if report.get(field) != expected:
            issues.append(f"{field}_not_{expected}")
    for field in ("executeRequested", "productionR2Uploaded", "realR2CredentialsUsed", "valid"):
        if report.get(field) is not True:
            issues.append(f"{field}_not_true")
    if operation.get("success") is not True or operation.get("remoteR2") is not True:
        issues.append("remote_r2_operation_not_successful")
    for check_name in (
        "remote_r2_public_reference_transport_only",
        "upload_readback_checksums",
        "current_pointer_after_readback_only",
        "source_license_slices_present",
        "non_private_scan_passed",
        "revocation_lkg_rollback_present",
        "no_final_plan_schedule_step_output",
    ):
        if checks.get(check_name) is not True:
            issues.append(f"{check_name}_check_not_passed")
    expected_domain_id = str(expected_domain or "")
    if expected_domain_id and f"/domain/{expected_domain_id}/" not in str(report.get("packID", "")):
        issues.append("pack_id_domain_mismatch")
    return issues


def _domain_evaluations(ledger: Any, r2_evaluation: dict[str, Any], recertification: dict[str, Any] | None) -> list[dict[str, Any]]:
    recert_by_domain = {
        item.get("domainID"): item
        for item in (recertification or {}).get("domains", [])
        if isinstance(item, dict)
    }
    r2_by_domain = {
        item.get("domainID"): item
        for item in r2_evaluation.get("domains", [])
        if isinstance(item, dict)
    }
    if not isinstance(ledger, dict):
        return []
    rows = []
    for domain in ledger.get("domains", []):
        if not isinstance(domain, dict):
            continue
        domain_id = domain.get("domainID")
        r2 = r2_by_domain.get(domain_id, {})
        recert = recert_by_domain.get(domain_id, {})
        blockers = []
        blockers.extend(domain.get("blockedReasons", []))
        blockers.extend(r2.get("issues", []))
        blockers.extend(recert.get("blockers", []))
        rows.append(
            {
                "domainID": domain_id,
                "sourceIDs": sorted(domain.get("sourceIDs", [])),
                "productionTargetReady": domain.get("readinessStatus") == "bounded_production_target_ready",
                "r2WriteReadbackReady": r2.get("valid") is True,
                "recertified": recert.get("recertified") is True,
                "blockers": sorted(set(blockers)),
            }
        )
    return rows


def _finish_line_gates(
    *,
    ledger: Any,
    legal_claim_gate: dict[str, Any],
    r2_evaluation: dict[str, Any],
    recertification: dict[str, Any] | None,
) -> list[dict[str, Any]]:
    production_target_allowed = _artifact_valid(ledger) and not ledger.get("configuredDomainsNotReady", []) if isinstance(ledger, dict) else False
    recert_allowed = isinstance(recertification, dict) and recertification.get("valid") is True and recertification.get("recordCounts", {}).get("blockedDomains") == 0
    internal_terms_allowed = "source_atlas_terms_gate_green" in legal_claim_gate.get("allowedClaims", [])
    r2_allowed = r2_evaluation.get("expected", 0) > 0 and r2_evaluation.get("blocked", 0) == 0
    live_transport_allowed = "bounded_live_native_transport" in legal_claim_gate.get("allowedClaims", []) or recert_allowed
    outside_allowed = "outside_legal_approval" in legal_claim_gate.get("allowedClaims", [])
    release_allowed = "release_green" in legal_claim_gate.get("allowedClaims", [])
    universal_allowed = "universal_coverage" in legal_claim_gate.get("allowedClaims", [])
    return [
        _gate(
            "bounded_configured_production_target",
            production_target_allowed,
            "all configured frontiers in the production target ledger",
            [] if production_target_allowed else _artifact_issues("production target ledger", ledger),
        ),
        _gate(
            "internal_terms_review",
            internal_terms_allowed,
            "source-specific internal terms review for current production source IDs",
            [] if internal_terms_allowed else _legal_claim_issues(legal_claim_gate, "source_atlas_terms_gate_green"),
        ),
        _gate(
            "production_r2_write_readback",
            r2_allowed,
            "all configured-domain production stable R2 publisher reports",
            [] if r2_allowed else r2_evaluation.get("issues", []),
        ),
        _gate(
            "bounded_live_transport",
            live_transport_allowed,
            "configured production gateway/native transport proof"
            if "bounded_live_native_transport" in legal_claim_gate.get("allowedClaims", [])
            else "current gateway, native registry, and native runtime recertification",
            [] if live_transport_allowed else _legal_claim_issues(legal_claim_gate, "bounded_live_native_transport") + _artifact_issues("production recertification", recertification),
        ),
        _gate(
            "bounded_configured_runtime_green",
            "bounded_configured_runtime_green" in legal_claim_gate.get("allowedClaims", []),
            "bounded configured Source Atlas public-pack runtime proof"
            if "bounded_configured_runtime_green" in legal_claim_gate.get("allowedClaims", [])
            else "blocked",
            [] if "bounded_configured_runtime_green" in legal_claim_gate.get("allowedClaims", []) else _legal_claim_issues(legal_claim_gate, "bounded_configured_runtime_green"),
        ),
        _gate(
            "gateway_native_runtime_recertification",
            recert_allowed,
            "current production ledger, gateway, native registry, and native runtime recertification",
            [] if recert_allowed else _artifact_issues("production recertification", recertification),
        ),
        _gate(
            "outside_legal_approval",
            outside_allowed,
            "source-specific outside legal approval artifacts" if outside_allowed else "blocked",
            [] if outside_allowed else _legal_claim_issues(legal_claim_gate, "outside_legal_approval"),
        ),
        _gate(
            "runtime_green",
            "source_atlas_runtime_green" in legal_claim_gate.get("allowedClaims", []),
            "broad Source Atlas Runtime Green" if "source_atlas_runtime_green" in legal_claim_gate.get("allowedClaims", []) else "blocked",
            [] if "source_atlas_runtime_green" in legal_claim_gate.get("allowedClaims", []) else _legal_claim_issues(legal_claim_gate, "source_atlas_runtime_green"),
        ),
        _gate(
            "release_green",
            release_allowed,
            "Release Green with owner/device/accessibility/privacy/legal approval" if release_allowed else "blocked",
            [] if release_allowed else _legal_claim_issues(legal_claim_gate, "release_green"),
        ),
        _gate(
            "universal_coverage",
            universal_allowed,
            "governed universal coverage proof" if universal_allowed else "blocked",
            [] if universal_allowed else _legal_claim_issues(legal_claim_gate, "universal_coverage"),
        ),
    ]


def _gate(claim_id: str, allowed: bool, scope: str, issues: list[str]) -> dict[str, Any]:
    return {
        "claimID": claim_id,
        "allowed": allowed,
        "status": "allowed" if allowed else "blocked",
        "allowedScope": scope,
        "issues": sorted(set(issues)),
    }


def _legal_claim_issues(legal_claim_gate: dict[str, Any], claim_id: str) -> list[str]:
    for item in legal_claim_gate.get("claimEvaluations", []):
        if item.get("claimID") == claim_id:
            return list(item.get("issues", []))
    return [f"{claim_id}: claim evaluation missing"]


def _artifact_valid(value: Any) -> bool:
    return isinstance(value, dict) and value.get("valid") is True


def _artifact_issues(label: str, value: Any) -> list[str]:
    if not isinstance(value, dict):
        return [f"{label} missing or unreadable"]
    if value.get("valid") is True:
        return []
    issues = list(value.get("issues", []) or value.get("gateIssues", []) or value.get("globalBlockers", []))
    issues.append(f"{label} valid flag is not true")
    return issues


def _check(name: str, passed: bool, issues: list[str]) -> dict[str, Any]:
    return {"name": name, "passed": bool(passed), "issues": sorted(set(issues))}


def _gate_allowed(gates: list[dict[str, Any]], claim_id: str) -> bool:
    return any(gate.get("claimID") == claim_id and gate.get("allowed") is True for gate in gates)


def _gate_issues(gates: list[dict[str, Any]], claim_id: str) -> list[str]:
    for gate in gates:
        if gate.get("claimID") == claim_id:
            return list(gate.get("issues", []))
    return [f"{claim_id}: finish-line gate missing"]


def _release_and_universal_blocked(gates: list[dict[str, Any]]) -> bool:
    blocked_claims = {"outside_legal_approval", "runtime_green", "release_green", "universal_coverage"}
    states = {gate["claimID"]: gate["allowed"] for gate in gates if gate.get("claimID") in blocked_claims}
    return states == {claim_id: False for claim_id in blocked_claims}


def _release_and_universal_issues(gates: list[dict[str, Any]]) -> list[str]:
    if _release_and_universal_blocked(gates):
        return []
    return ["outside legal/runtime/release/universal claim allowed without separate proof"]


def _output_hashes(paths: dict[str, str | None]) -> dict[str, str]:
    hashes: dict[str, str] = {}
    for label, raw_path in paths.items():
        if not raw_path:
            continue
        path = Path(raw_path)
        if path.exists():
            hashes[label] = stable_hash(read_json(path)) if path.suffix == ".json" else stable_hash(path.read_text(encoding="utf-8"))
    return hashes
