"""Current production recertification gate for Source Atlas.

The gate joins the production target ledger, public R2 gateway release proof,
native active refresh registry, and native runtime proof into one deterministic
per-domain answer. It is intentionally bounded: it can certify the configured
frontiers represented by current evidence, and it keeps universal coverage,
release, and legal-approval claims blocked.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Any

from .boundary import boundary_issue_strings, boundary_issues_for_value
from .model import NON_CLAIMS, PRIVACY_BOUNDARY, read_json, stable_id, write_json
from .r2_public_gateway_release import validate_native_registry_coherence


PRODUCTION_RECERTIFICATION_VERSION = "source-atlas-production-recertification-train-104"
PRODUCTION_RECERTIFICATION_KIND = "ambitions.sourceAtlas.productionRecertificationGate.v1"
REQUIRED_GATEWAY_PUBLIC_LABELS = {"current", "manifest", "pack"}
REQUIRED_LEDGER_FLAGS = (
    "frontierConfigured",
    "claimGraphProofComplete",
    "packProductionProofComplete",
    "r2ProductionProofComplete",
    "gatewayProofComplete",
    "nativeRegistryProofComplete",
    "nativeRuntimeBoundaryProofComplete",
    "nativeUsabilityProofComplete",
)

PRODUCTION_RECERTIFICATION_NON_CLAIMS = [
    "not literal universal coverage",
    "not full Source Atlas Green",
    "not outside legal approval",
    "not App Store or TestFlight readiness",
    "not physical-device proof",
    "not independent visual or accessibility proof",
    "not account entitlement readiness",
    "not final user plans, schedules, Steps, or personalized paths from Source Atlas/R2",
    "not approval for future domains without source/frontier/pack/R2/native evidence",
    *NON_CLAIMS,
]


@dataclass(frozen=True)
class ProductionRecertificationOptions:
    production_target_ledger_path: Path
    gateway_release_report_path: Path
    native_runtime_report_path: Path
    output_root: Path
    created_at: str = "2026-06-28T00:00:00Z"
    native_registry_artifact_path: Path | None = None


def run_production_recertification_gate(options: ProductionRecertificationOptions) -> dict[str, Any]:
    output_root = options.output_root
    output_root.mkdir(parents=True, exist_ok=True)

    issues: list[str] = []
    ledger = _read_required_json(options.production_target_ledger_path, "production target ledger", issues)
    gateway = _read_required_json(options.gateway_release_report_path, "gateway release report", issues)
    native_runtime = _read_required_json(options.native_runtime_report_path, "native runtime report", issues)

    selected_reports = _selected_gateway_reports(gateway)
    native_registry_gate = _native_registry_gate(options.native_registry_artifact_path, selected_reports)
    if not native_registry_gate.get("valid", False):
        issues.extend(f"native registry coherence: {issue}" for issue in native_registry_gate.get("issues", []))

    evidence_bundle = {
        "productionTargetLedger": ledger,
        "gatewayReleaseReport": gateway,
        "nativeRuntimeReport": native_runtime,
        "nativeRegistryCoherenceGate": native_registry_gate,
    }
    privacy_issues = boundary_issue_strings(boundary_issues_for_value(evidence_bundle, "source-atlas-production-recertification"))
    issues.extend(privacy_issues)

    domains = _domain_recertifications(
        ledger=ledger,
        gateway=gateway,
        native_runtime=native_runtime,
        native_registry_gate=native_registry_gate,
    )
    domain_blockers = [
        f"{domain['domainID']}: {blocker}"
        for domain in domains
        for blocker in domain.get("blockers", [])
    ]
    issues.extend(domain_blockers)

    checks = [
        _check("production_target_ledger_valid", isinstance(ledger, dict) and ledger.get("valid") is True, _invalid_artifact_issues("production target ledger", ledger)),
        _check("gateway_release_valid", isinstance(gateway, dict) and gateway.get("valid") is True, _invalid_artifact_issues("gateway release report", gateway)),
        _check("gateway_live_verification_valid", _gateway_live_valid(gateway), _gateway_live_issues(gateway)),
        _check("native_runtime_proof_valid", _native_runtime_valid(native_runtime), _native_runtime_issues(native_runtime)),
        _check("native_registry_coherence_valid", native_registry_gate.get("valid") is True, native_registry_gate.get("issues", [])),
        _check("domain_chain_recertification", not domain_blockers and bool(domains), domain_blockers or ([] if domains else ["no domains found for recertification"])),
        _check("privacy_boundary", not privacy_issues, privacy_issues),
    ]
    valid = not issues and all(check["passed"] for check in checks)

    report_path = output_root / "production-recertification-report.json"
    markdown_path = output_root / "production-recertification-report.md"
    closeout_path = output_root / "closeout.md"
    allowed_claims = []
    if valid:
        allowed_claims = [
            "bounded_configured_source_atlas_production_runtime_ready",
            "bounded_configured_frontier_current_production_runtime_ready",
        ]

    report = {
        "schemaVersion": 1,
        "kind": PRODUCTION_RECERTIFICATION_KIND,
        "versionID": PRODUCTION_RECERTIFICATION_VERSION,
        "createdAt": options.created_at,
        "recertificationID": stable_id("source_atlas.production_recertification", {"domains": domains, "createdAt": options.created_at}),
        "status": "Source Green for bounded configured production/runtime recertification" if valid else "Red",
        "valid": valid,
        "sourceAtlasStatusCeiling": "Yellow overall Source Atlas; bounded configured-frontier production/runtime recertification only",
        "overallReadinessStatus": "bounded_configured_production_runtime_recertified" if valid else "blocked_or_partial",
        "universalCoverageClaimAllowed": False,
        "allowedClaims": allowed_claims,
        "blockedClaims": sorted(
            {
                "literal_universal_coverage",
                "full_source_atlas_green",
                "outside_legal_approval",
                "release_green",
                "app_store_readiness",
                "visual_green",
                "accessibility_green",
                "account_entitlement_readiness",
                "future_domain_readiness_without_frontier_source_pack_r2_native_proof",
                "final_user_plans_schedules_steps_from_source_atlas_or_r2",
            }
        ),
        "recordCounts": {
            "ledgerDomains": len(_ledger_domains(ledger)),
            "selectedGatewayReports": len(selected_reports),
            "gatewayLiveDomains": len(_gateway_public_checks_by_domain(gateway)),
            "nativeRegistryMatches": int(native_registry_gate.get("matchedTargetCount", 0) or 0),
            "nativeRuntimeFrontiers": len(_native_runtime_frontiers(native_runtime)),
            "recertifiedDomains": sum(1 for domain in domains if domain.get("recertified") is True),
            "blockedDomains": sum(1 for domain in domains if domain.get("recertified") is not True),
            "privacyIssues": len(privacy_issues),
        },
        "checks": checks,
        "issues": issues,
        "domains": domains,
        "evidencePaths": {
            "productionTargetLedger": str(options.production_target_ledger_path),
            "gatewayReleaseReport": str(options.gateway_release_report_path),
            "nativeRuntimeReport": str(options.native_runtime_report_path),
            "nativeRegistryArtifact": str(options.native_registry_artifact_path) if options.native_registry_artifact_path else None,
        },
        "nativeRegistryCoherenceGate": native_registry_gate,
        "privacyBoundary": PRIVACY_BOUNDARY,
        "privacyIssues": privacy_issues,
        "nonClaims": PRODUCTION_RECERTIFICATION_NON_CLAIMS,
        "outputPaths": {
            "report": str(report_path),
            "markdown": str(markdown_path),
            "closeout": str(closeout_path),
        },
    }
    markdown = production_recertification_markdown(report)
    write_json(report_path, report)
    markdown_path.write_text(markdown, encoding="utf-8")
    closeout_path.write_text(markdown, encoding="utf-8")
    return report


def production_recertification_markdown(report: dict[str, Any]) -> str:
    lines = [
        "# Source Atlas Production Recertification Gate Train 104",
        "",
        f"Status: {report['status']}",
        f"Source Atlas status ceiling: {report['sourceAtlasStatusCeiling']}",
        f"Overall readiness: {report['overallReadinessStatus']}",
        f"Universal coverage claim allowed: {'yes' if report['universalCoverageClaimAllowed'] else 'no'}",
        "",
        "## Scope Completed",
        "",
        "- Joined the current production target ledger, public R2 gateway release proof, native active refresh registry, and native runtime proof.",
        "- Recertified each configured frontier against current R2 pack selection, live gateway current/manifest/pack checks, native registry target, and native runtime coverage.",
        "- Blocks stale ledgers, missing gateway checks, native registry mismatches, missing runtime coverage, and private-context evidence.",
        "",
        "## Domain Recertification",
        "",
        "| Domain | Recertified | Pack | Gateway | Native Registry | Native Runtime | Blockers |",
        "| --- | --- | --- | --- | --- | --- | --- |",
    ]
    for domain in report.get("domains", []):
        blockers = "<br>".join(domain.get("blockers", []))
        lines.append(
            "| {domain} | {ready} | {pack} | {gateway} | {registry} | {runtime} | {blockers} |".format(
                domain=domain["domainID"],
                ready="yes" if domain.get("recertified") else "no",
                pack=domain.get("selectedPackID") or "",
                gateway="yes" if domain.get("gatewayCurrentManifestPackVerified") else "no",
                registry="yes" if domain.get("nativeRegistryMatched") else "no",
                runtime="yes" if domain.get("nativeRuntimeCovered") else "no",
                blockers=blockers,
            )
        )
    lines.extend(["", "## Checks", ""])
    for check in report.get("checks", []):
        lines.append(f"- {check['name']}: {'pass' if check['passed'] else 'fail'}")
        for issue in check.get("issues", []):
            lines.append(f"  - {issue}")
    lines.extend(["", "## Allowed Claims", ""])
    if report.get("allowedClaims"):
        lines.extend(f"- `{claim}`" for claim in report["allowedClaims"])
    else:
        lines.append("- None")
    lines.extend(["", "## Production Non-Claims", ""])
    lines.extend(f"- {claim}" for claim in report.get("nonClaims", []))
    lines.extend(
        [
            "",
            "## Closeout",
            "",
            "Product law preserved:",
            "- R2 remains public/reference/freshness infrastructure only.",
            "- Recertification evidence is public pack, source, hash, freshness, gateway, and native-runtime proof metadata only.",
            "- No private user context, goals, captures, schedules, proof, receipts, account IDs, device IDs, or private graph data is introduced.",
            "- Source Atlas/R2 does not generate final plans, schedules, Steps, or personalized paths.",
            "",
            "Architecture closeout:",
            "- Final Architecture Tree inspected: yes.",
            "- Canonical owners touched: none in app source; tooling/evidence only under tools/source-atlas.",
            "- Non-canonical owners touched: none.",
            "- Compatibility shims left behind: none.",
            "- No equivalent folder/path interpretation was used.",
            "",
            "Rollback plan:",
            "- Revert the Train 104 recertification module, CLI wiring, tests, generated artifacts, and QA evidence.",
            "- Continue using the prior production target ledger, gateway release proof, native registry, and runtime proof artifacts if this gate regresses.",
            "",
        ]
    )
    return "\n".join(lines)


def _domain_recertifications(
    *,
    ledger: Any,
    gateway: Any,
    native_runtime: Any,
    native_registry_gate: dict[str, Any],
) -> list[dict[str, Any]]:
    ledger_domains = _ledger_domains(ledger)
    selected_by_domain = {item["domainID"]: item for item in _selected_gateway_reports(gateway)}
    gateway_checks = _gateway_public_checks_by_domain(gateway)
    native_matches = _native_registry_matches(native_registry_gate)
    runtime_frontiers = _native_runtime_frontiers(native_runtime)
    runtime_valid = _native_runtime_valid(native_runtime)

    rows: list[dict[str, Any]] = []
    for domain_id in sorted(ledger_domains):
        ledger_domain = ledger_domains[domain_id]
        selected = selected_by_domain.get(domain_id)
        gateway_status = _gateway_domain_status(gateway_checks.get(domain_id, []))
        native_match = native_matches.get(domain_id)
        blockers: list[str] = []

        ledger_ready = ledger_domain.get("readinessStatus") == "bounded_production_target_ready" and all(
            ledger_domain.get(flag) is True for flag in REQUIRED_LEDGER_FLAGS
        )
        if not ledger_ready:
            blockers.append("production_target_ledger_domain_not_ready")

        if selected is None:
            blockers.append("gateway_selected_publisher_report_missing")
        elif selected.get("valid") is not True or selected.get("productionR2Uploaded") is not True:
            blockers.append("gateway_selected_publisher_report_not_valid_uploaded_production_r2")

        ledger_r2_path = ledger_domain.get("r2PublisherPath")
        selected_path = selected.get("path") if selected else None
        ledger_path_matches_selected = bool(ledger_r2_path and selected_path and ledger_r2_path == selected_path)
        if not ledger_path_matches_selected:
            blockers.append("production_target_ledger_r2_path_not_current_gateway_selection")

        if not gateway_status["verified"]:
            blockers.extend(gateway_status["blockers"])

        native_registry_matched = bool(native_match and native_match.get("matched") is True)
        if not native_registry_matched:
            blockers.append("native_registry_target_missing_or_mismatched")

        selected_pack_id = selected.get("packID") if selected else None
        target_pack_id = native_match.get("targetPackID") if native_match else None
        if selected_pack_id and target_pack_id and selected_pack_id != target_pack_id:
            blockers.append("native_registry_pack_id_mismatch")

        native_runtime_covered = runtime_valid and domain_id in runtime_frontiers
        if not native_runtime_covered:
            blockers.append("native_runtime_current_r2_proof_missing_for_domain")

        rows.append(
            {
                "domainID": domain_id,
                "recertified": not blockers,
                "ledgerReadinessStatus": ledger_domain.get("readinessStatus"),
                "ledgerR2PublisherPath": ledger_r2_path,
                "selectedPublisherReportPath": selected_path,
                "ledgerR2PathMatchesSelected": ledger_path_matches_selected,
                "selectedPackID": selected_pack_id,
                "nativeTargetPackID": target_pack_id,
                "gatewayCurrentManifestPackVerified": gateway_status["verified"],
                "gatewayVerifiedLabels": gateway_status["verifiedLabels"],
                "nativeRegistryMatched": native_registry_matched,
                "nativeRuntimeCovered": native_runtime_covered,
                "packableClaimCount": ledger_domain.get("packableClaimCount", 0),
                "sourceIDs": ledger_domain.get("sourceIDs", []),
                "allowedClaimScopes": ledger_domain.get("allowedClaimScopes", []),
                "blockers": sorted(set(blockers)),
                "nonClaims": [
                    "not universal coverage",
                    "not outside legal approval",
                    "not Release Green",
                    "not final user plans, schedules, or Steps",
                ],
            }
        )
    return rows


def _read_required_json(path: Path, label: str, issues: list[str]) -> Any:
    if not path.exists():
        issues.append(f"{label} missing: {path}")
        return None
    try:
        return read_json(path)
    except Exception as exc:  # pragma: no cover - defensive.
        issues.append(f"{label} unreadable: {path}: {exc}")
        return None


def _native_registry_gate(registry_path: Path | None, selected_reports: list[dict[str, Any]]) -> dict[str, Any]:
    return validate_native_registry_coherence(
        registry_path=registry_path,
        selected_reports=selected_reports,
    )


def _ledger_domains(ledger: Any) -> dict[str, dict[str, Any]]:
    if not isinstance(ledger, dict):
        return {}
    return {
        item["domainID"]: item
        for item in ledger.get("domains", [])
        if isinstance(item, dict) and isinstance(item.get("domainID"), str)
    }


def _selected_gateway_reports(gateway: Any) -> list[dict[str, Any]]:
    if not isinstance(gateway, dict):
        return []
    reports = []
    for item in gateway.get("discovery", {}).get("selectedReports", []):
        if isinstance(item, dict) and isinstance(item.get("domainID"), str):
            reports.append(item)
    return sorted(reports, key=lambda item: item["domainID"])


def _gateway_public_checks_by_domain(gateway: Any) -> dict[str, list[dict[str, Any]]]:
    if not isinstance(gateway, dict):
        return {}
    live = gateway.get("liveVerification")
    if not isinstance(live, dict):
        return {}
    checks: dict[str, list[dict[str, Any]]] = {}
    for item in live.get("publicChecks", []):
        if isinstance(item, dict) and isinstance(item.get("domain"), str):
            checks.setdefault(item["domain"], []).append(item)
    return checks


def _gateway_domain_status(checks: list[dict[str, Any]]) -> dict[str, Any]:
    verified_labels = sorted(
        {
            str(item.get("label"))
            for item in checks
            if item.get("status") == 200
            and item.get("matched") is True
            and item.get("publicReferenceHeader") == "true"
        }
    )
    missing = sorted(REQUIRED_GATEWAY_PUBLIC_LABELS - set(verified_labels))
    blockers = [f"gateway_live_public_check_missing_or_failed_{label}" for label in missing]
    return {
        "verified": not missing,
        "verifiedLabels": verified_labels,
        "blockers": blockers,
    }


def _native_registry_matches(native_registry_gate: dict[str, Any]) -> dict[str, dict[str, Any]]:
    matches = {}
    for item in native_registry_gate.get("matches", []):
        if isinstance(item, dict) and isinstance(item.get("domainID"), str):
            matches[item["domainID"]] = item
    return matches


def _native_runtime_frontiers(native_runtime: Any) -> set[str]:
    if not isinstance(native_runtime, dict):
        return set()
    return {
        item
        for item in native_runtime.get("configuredFrontiers", [])
        if isinstance(item, str)
    }


def _native_runtime_valid(native_runtime: Any) -> bool:
    if not isinstance(native_runtime, dict):
        return False
    xcode = native_runtime.get("xcodeBuildMCP")
    proof = native_runtime.get("proofSummary")
    return (
        isinstance(xcode, dict)
        and xcode.get("result") == "SUCCEEDED"
        and int(xcode.get("passed", 0)) > 0
        and int(xcode.get("failed", 1)) == 0
        and int(xcode.get("skipped", 1)) == 0
        and isinstance(proof, dict)
        and bool(proof.get("r2RequestPrivacyProof"))
        and bool(proof.get("noPrivateGraphEgressProof"))
        and bool(proof.get("nativeOfflineNoAccountProof"))
        and bool(proof.get("runtimeCompositionProof"))
        and bool(_native_runtime_frontiers(native_runtime))
    )


def _gateway_live_valid(gateway: Any) -> bool:
    if not isinstance(gateway, dict):
        return False
    live = gateway.get("liveVerification")
    return (
        isinstance(live, dict)
        and live.get("valid") is True
        and live.get("headChecksPassed") is True
        and live.get("publicChecksPassed") is True
        and live.get("blockedChecksPassed") is True
    )


def _invalid_artifact_issues(label: str, artifact: Any) -> list[str]:
    if not isinstance(artifact, dict):
        return [f"{label} missing_or_unreadable"]
    if artifact.get("valid") is not True:
        return [f"{label} valid flag is not true"]
    return []


def _gateway_live_issues(gateway: Any) -> list[str]:
    if not isinstance(gateway, dict):
        return ["gateway release report missing_or_unreadable"]
    live = gateway.get("liveVerification")
    if not isinstance(live, dict):
        return ["gateway release report missing liveVerification"]
    issues = list(live.get("issues", []))
    if live.get("valid") is not True:
        issues.append("liveVerification valid flag is not true")
    if live.get("headChecksPassed") is not True:
        issues.append("liveVerification headChecksPassed is not true")
    if live.get("publicChecksPassed") is not True:
        issues.append("liveVerification publicChecksPassed is not true")
    if live.get("blockedChecksPassed") is not True:
        issues.append("liveVerification blockedChecksPassed is not true")
    return issues


def _native_runtime_issues(native_runtime: Any) -> list[str]:
    if not isinstance(native_runtime, dict):
        return ["native runtime report missing_or_unreadable"]
    issues: list[str] = []
    xcode = native_runtime.get("xcodeBuildMCP")
    proof = native_runtime.get("proofSummary")
    if not isinstance(xcode, dict) or xcode.get("result") != "SUCCEEDED":
        issues.append("native runtime xcodeBuildMCP result is not SUCCEEDED")
    elif int(xcode.get("failed", 1)) != 0 or int(xcode.get("skipped", 1)) != 0 or int(xcode.get("passed", 0)) <= 0:
        issues.append("native runtime xcodeBuildMCP counts are not clean")
    if not isinstance(proof, dict):
        issues.append("native runtime proofSummary missing")
    else:
        for key in ("r2RequestPrivacyProof", "noPrivateGraphEgressProof", "nativeOfflineNoAccountProof", "runtimeCompositionProof"):
            if not proof.get(key):
                issues.append(f"native runtime proofSummary missing {key}")
    if not _native_runtime_frontiers(native_runtime):
        issues.append("native runtime configuredFrontiers missing")
    return issues


def _check(name: str, passed: bool, issues: list[str]) -> dict[str, Any]:
    return {
        "name": name,
        "passed": passed,
        "issues": list(issues),
    }
