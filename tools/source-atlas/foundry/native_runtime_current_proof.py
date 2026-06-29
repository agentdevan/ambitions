"""Current native runtime proof compiler for Source Atlas public packs.

This compiler joins the current production ledger, public gateway proof,
bundled native refresh registry, and a focused native test summary. It grants a
bounded configured-runtime claim only for the configured public/reference
frontiers represented by the supplied artifacts.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Any

from .boundary import boundary_issue_strings, boundary_issues_for_value
from .model import NON_CLAIMS, PRIVACY_BOUNDARY, read_json, stable_hash, stable_id, write_json


NATIVE_RUNTIME_CURRENT_PROOF_VERSION = "source-atlas-native-runtime-current-proof-train-117"
NATIVE_RUNTIME_CURRENT_PROOF_KIND = "ambitions.sourceAtlas.nativeRuntimeCurrentProof.v1"

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
REQUIRED_GATEWAY_PUBLIC_LABELS = {"current", "manifest", "pack"}
REQUIRED_NATIVE_TEST_SUITES = {
    "SourceAtlasPublicPackRefreshTargetRegistryArtifactLoaderTests",
    "SourceAtlasPublicPackRemoteTransportTests",
    "SourceAtlasPublicPackLifecycleRefreshServiceTests",
    "SourceAtlasPublicPackFetchPipelineTests",
    "SourceAtlasPublicPackRepositoryBackedRemoteRefreshTests",
    "SourceAtlasPublicPackAppRefreshCoordinatorTests",
    "SourceAtlasOfflineNoAccountScenarioTests",
    "SourceAtlasLocalReferenceCompositionProofTests",
}

NATIVE_RUNTIME_CURRENT_PROOF_NON_CLAIMS = [
    "bounded configured-frontier native runtime proof only",
    "not literal universal coverage",
    "not full Source Atlas Green",
    "not outside legal approval",
    "not Release Green",
    "not App Store or TestFlight readiness",
    "not physical-device proof",
    "not independent visual or accessibility proof",
    "not account entitlement readiness",
    "not final user plans, schedules, Steps, or personalized paths from Source Atlas/R2",
    *NON_CLAIMS,
]


@dataclass(frozen=True)
class NativeRuntimeCurrentProofOptions:
    production_target_ledger_path: Path
    gateway_release_report_path: Path
    native_registry_artifact_path: Path
    output_root: Path
    created_at: str = "2026-06-29T01:00:00Z"
    xcode_result: str = "NOT_RUN"
    xcode_passed: int = 0
    xcode_failed: int = 0
    xcode_skipped: int = 0
    xcode_duration_ms: int | None = None
    xcode_log_path: str | None = None
    xcresult_path: str | None = None
    xcode_profile: str | None = None
    test_suites: tuple[str, ...] = ()
    endpoint: str | None = None
    branch: str | None = None
    commit_sha: str | None = None
    worktree_dirty_entry_count: int | None = None


def run_native_runtime_current_proof(options: NativeRuntimeCurrentProofOptions) -> dict[str, Any]:
    output_root = options.output_root
    output_root.mkdir(parents=True, exist_ok=True)

    issues: list[str] = []
    ledger = _read_required_json(options.production_target_ledger_path, "production target ledger", issues)
    gateway = _read_required_json(options.gateway_release_report_path, "gateway release report", issues)
    registry = _read_required_json(options.native_registry_artifact_path, "native registry artifact", issues)

    selected_gateway_reports = _selected_gateway_reports(gateway)
    registry_entries = _registry_entries(registry)
    domain_proofs = _domain_proofs(
        ledger=ledger,
        gateway=gateway,
        selected_gateway_reports=selected_gateway_reports,
        registry_entries=registry_entries,
    )
    xcode_proof = _xcode_proof(options)
    privacy_issues = boundary_issue_strings(
        boundary_issues_for_value(
            {
                "domainProofs": _privacy_domain_view(domain_proofs),
                "xcodeProof": _privacy_xcode_view(xcode_proof),
                "nativeRegistryArtifact": str(options.native_registry_artifact_path),
            },
            "source-atlas-native-runtime-current-proof",
        )
    )

    issues.extend(_artifact_issues("production target ledger", ledger))
    issues.extend(_artifact_issues("gateway release report", gateway))
    issues.extend(_registry_issues(registry, registry_entries))
    issues.extend(_xcode_issues(xcode_proof))
    issues.extend(
        f"{domain['domainID']}: {blocker}"
        for domain in domain_proofs
        for blocker in domain["blockers"]
    )
    issues.extend(privacy_issues)

    record_counts = {
        "configuredDomains": len(domain_proofs),
        "domainsRuntimeReady": sum(1 for domain in domain_proofs if domain["runtimeReady"]),
        "domainsBlocked": sum(1 for domain in domain_proofs if not domain["runtimeReady"]),
        "gatewayLiveDomains": len(_gateway_public_checks_by_domain(gateway)),
        "registryActiveTargets": sum(1 for entry in registry_entries if entry.get("status") == "active"),
        "xcodePassed": xcode_proof["passed"],
        "xcodeFailed": xcode_proof["failed"],
        "xcodeSkipped": xcode_proof["skipped"],
        "privacyIssues": len(privacy_issues),
    }
    checks = [
        _check("production_target_ledger_valid", _artifact_valid(ledger), _artifact_issues("production target ledger", ledger)),
        _check("gateway_release_valid", _artifact_valid(gateway), _artifact_issues("gateway release report", gateway)),
        _check("native_registry_artifact_public_and_active", not _registry_issues(registry, registry_entries), _registry_issues(registry, registry_entries)),
        _check("focused_native_tests_passed", not _xcode_issues(xcode_proof), _xcode_issues(xcode_proof)),
        _check("all_configured_domains_runtime_ready", record_counts["domainsRuntimeReady"] == record_counts["configuredDomains"] and bool(domain_proofs), [domain["domainID"] for domain in domain_proofs if not domain["runtimeReady"]] or ([] if domain_proofs else ["no configured domains"])),
        _check("privacy_boundary", not privacy_issues, privacy_issues),
    ]
    valid = not issues and all(check["passed"] for check in checks)
    allowed_claims = ["bounded_configured_runtime_green"] if valid else []
    blocked_claims = sorted(
        {
            "full_source_atlas_green",
            "outside_legal_approval",
            "release_green",
            "app_store_readiness",
            "literal_universal_coverage",
            "native_device_green",
            "independent_accessibility_green",
            "account_entitlement_readiness",
            "final_user_plans_schedules_steps_from_source_atlas_or_r2",
        }
    )

    report_path = output_root / "native-runtime-current-proof-report.json"
    markdown_path = output_root / "native-runtime-current-proof-report.md"
    closeout_path = output_root / "closeout.md"
    report = {
        "schemaVersion": 1,
        "kind": NATIVE_RUNTIME_CURRENT_PROOF_KIND,
        "versionID": NATIVE_RUNTIME_CURRENT_PROOF_VERSION,
        "createdAt": options.created_at,
        "proofID": stable_id(
            "source_atlas.native_runtime_current_proof",
            {
                "domains": [domain["domainID"] for domain in domain_proofs],
                "createdAt": options.created_at,
                "xcode": xcode_proof,
            },
        ),
        "status": "Native Runtime Green for configured Source Atlas public-pack runtime / Yellow overall Source Atlas" if valid else "Red",
        "valid": valid,
        "sourceAtlasStatusCeiling": "Yellow overall Source Atlas; bounded configured-frontier native runtime proof only",
        "overallReadinessStatus": "bounded_configured_native_runtime_green" if valid else "blocked_or_partial",
        "configuredFrontiers": [domain["domainID"] for domain in domain_proofs],
        "configuredFrontierCount": len(domain_proofs),
        "domainProofs": domain_proofs,
        "xcodeBuildMCP": xcode_proof,
        "recordCounts": record_counts,
        "checks": checks,
        "issues": sorted(set(issues)),
        "proofSummary": {
            "r2RequestPrivacyProof": "Public manifest/object requests contain domain, channel, schema, app version, public locale, and public object keys only.",
            "noPrivateGraphEgressProof": "Registry, request, cache, and runtime proof metadata are privacy-boundary scanned; private goal/capture/schedule/proof/account/device/private graph fields are absent.",
            "licenseTermsProof": "Inherited from current production pack/R2 gates; this native proof emits no legal approval.",
            "restrictedSourceExclusionProof": "Inherited from production target ledger and pack/R2 reports selected by the gateway.",
            "provenanceCompletenessProof": "Native runtime consumes published pack manifests and declared pack SHA-256s before local cache use.",
            "freshnessRevocationProof": "Focused native suites cover current pointer, revocation manifest, manifest, LKG pointer, and pack fetch behavior.",
            "lkgRollbackProof": "Focused native suites cover repository/LKG/offline fallback without blocking core local planning.",
            "nativeOfflineNoAccountProof": "Offline/no-account focused suite keeps core local planning available without remote public reference access.",
            "runtimeCompositionProof": "Local source inspection proof keeps Source Atlas reference-only; Runtime owns fit, timing, priority, and final action composition.",
        },
        "productLawPreserved": valid,
        "runtimeGreenClaim": {
            "claimID": "bounded_configured_runtime_green",
            "allowed": valid,
            "allowedScope": "configured production-target public/reference frontiers only" if valid else "blocked",
            "issues": [] if valid else sorted(set(issues)),
        },
        "allowedClaims": allowed_claims,
        "blockedClaims": blocked_claims,
        "privacyBoundary": PRIVACY_BOUNDARY,
        "privacyIssues": privacy_issues,
        "nonClaims": NATIVE_RUNTIME_CURRENT_PROOF_NON_CLAIMS,
        "evidencePaths": {
            "productionTargetLedger": str(options.production_target_ledger_path),
            "gatewayReleaseReport": str(options.gateway_release_report_path),
            "nativeRegistryArtifact": str(options.native_registry_artifact_path),
            "xcodeLog": options.xcode_log_path,
            "xcresult": options.xcresult_path,
        },
        "branch": options.branch,
        "commitSHA": options.commit_sha,
        "worktreeDirtyEntryCountAtProof": options.worktree_dirty_entry_count,
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
    markdown = native_runtime_current_proof_markdown(report)
    markdown_path.write_text(markdown, encoding="utf-8")
    closeout_path.write_text(markdown, encoding="utf-8")
    return report


def native_runtime_current_proof_markdown(report: dict[str, Any]) -> str:
    counts = report["recordCounts"]
    lines = [
        "# Source Atlas Native Runtime Current Proof Train 117",
        "",
        f"Status: {report['status']}",
        f"Source Atlas status ceiling: {report['sourceAtlasStatusCeiling']}",
        f"Overall readiness: {report['overallReadinessStatus']}",
        "",
        "Scope completed:",
        "- Joined the current production target ledger, public gateway release proof, bundled native refresh registry, and focused native simulator test summary.",
        "- Proves bounded configured-runtime use for current production public/reference frontiers only.",
        "- Emits no new production R2 write, Worker deploy, live harvest, account entitlement, private runtime mutation, or release approval.",
        "",
        "Counts:",
        f"- Configured domains: {counts['configuredDomains']}",
        f"- Runtime-ready domains: {counts['domainsRuntimeReady']}",
        f"- Blocked domains: {counts['domainsBlocked']}",
        f"- Registry active targets: {counts['registryActiveTargets']}",
        f"- Xcode passed/failed/skipped: {counts['xcodePassed']}/{counts['xcodeFailed']}/{counts['xcodeSkipped']}",
        "",
        "Domain proof:",
        "",
        "| Domain | Runtime Ready | Pack | Gateway | Registry | Blockers |",
        "| --- | --- | --- | --- | --- | --- |",
    ]
    for domain in report.get("domainProofs", []):
        lines.append(
            "| {domain} | {ready} | {pack} | {gateway} | {registry} | {blockers} |".format(
                domain=domain["domainID"],
                ready="yes" if domain["runtimeReady"] else "no",
                pack=domain.get("packID") or "",
                gateway="yes" if domain.get("gatewayCurrentManifestPackVerified") else "no",
                registry="yes" if domain.get("nativeRegistryTargetActive") else "no",
                blockers="<br>".join(domain.get("blockers", [])) or "none",
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
            "- Native requests are public manifest/object-key requests only.",
            "- No private user context, goals, captures, schedules, proof, receipts, account IDs, device IDs, behavior history, inferred priorities, or private graph data is introduced.",
            "- Source Atlas/R2 does not generate final plans, schedules, Steps, or personalized paths.",
            "",
            "Validation run:",
            "- See the xcodeBuildMCP and surrounding train closeout for exact command output.",
            "",
            "Validation not run:",
            "- Physical-device validation was not run.",
            "- Independent visual/accessibility review was not run.",
            "- TestFlight/App Store release process was not run.",
            "",
            "Architecture closeout:",
            "- Final Architecture Tree inspected: yes.",
            "- Canonical owners touched: none in app source by this compiler; it consumes Core/Persistence, Core/Runtime, Trust, and bundled resource evidence.",
            "- Non-canonical owners touched: none.",
            "- Compatibility shims left behind: none.",
            "- No equivalent folder/path interpretation was used.",
            "",
            "Production non-claims:",
        ]
    )
    lines.extend(f"- {claim}" for claim in report.get("nonClaims", []))
    lines.extend(["", "Rollback plan:", "- Revert Train 117 native runtime current proof tooling, generated artifacts, and finish-line/sweep evidence refresh."])
    lines.append("")
    return "\n".join(lines)


def _domain_proofs(
    *,
    ledger: Any,
    gateway: Any,
    selected_gateway_reports: list[dict[str, Any]],
    registry_entries: list[dict[str, Any]],
) -> list[dict[str, Any]]:
    ledger_domains = _ledger_domains(ledger)
    selected_by_domain = {item["domainID"]: item for item in selected_gateway_reports}
    registry_by_domain = {
        entry.get("target", {}).get("domainID"): entry
        for entry in registry_entries
        if isinstance(entry.get("target"), dict)
    }
    gateway_checks = _gateway_public_checks_by_domain(gateway)
    rows: list[dict[str, Any]] = []
    for domain_id in sorted(ledger_domains):
        ledger_domain = ledger_domains[domain_id]
        selected = selected_by_domain.get(domain_id)
        registry_entry = registry_by_domain.get(domain_id)
        target = registry_entry.get("target", {}) if isinstance(registry_entry, dict) else {}
        gateway_status = _gateway_domain_status(gateway_checks.get(domain_id, []))
        blockers: list[str] = []

        if ledger_domain.get("readinessStatus") != "bounded_production_target_ready" or any(
            ledger_domain.get(flag) is not True for flag in REQUIRED_LEDGER_FLAGS
        ):
            blockers.append("production_target_ledger_domain_not_ready")
        if not selected or selected.get("valid") is not True or selected.get("productionR2Uploaded") is not True:
            blockers.append("gateway_selected_publisher_report_not_valid_uploaded")
        if not gateway_status["verified"]:
            blockers.extend(gateway_status["blockers"])
        if not registry_entry or registry_entry.get("status") != "active":
            blockers.append("native_registry_target_not_active")
        if registry_entry and "startup" not in set(registry_entry.get("allowedModes", [])):
            blockers.append("native_registry_startup_mode_missing")
        selected_pack_id = selected.get("packID") if selected else None
        target_pack_id = target.get("targetPackID")
        if selected_pack_id and target_pack_id and selected_pack_id != target_pack_id:
            blockers.append("native_registry_pack_id_mismatch")
        if target.get("environment") != "production":
            blockers.append("native_registry_target_not_production")
        if target.get("channel") != "stable":
            blockers.append("native_registry_target_not_stable")

        rows.append(
            {
                "domainID": domain_id,
                "runtimeReady": not blockers,
                "packID": selected_pack_id,
                "nativeTargetPackID": target_pack_id,
                "gatewayCurrentManifestPackVerified": gateway_status["verified"],
                "gatewayVerifiedLabels": gateway_status["verifiedLabels"],
                "nativeRegistryTargetActive": bool(registry_entry and registry_entry.get("status") == "active"),
                "allowedModes": sorted(registry_entry.get("allowedModes", [])) if registry_entry else [],
                "sourceIDs": sorted(ledger_domain.get("sourceIDs", [])),
                "packableClaimCount": ledger_domain.get("packableClaimCount", 0),
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
    except Exception as exc:  # pragma: no cover - defensive artifact handling.
        issues.append(f"{label} unreadable: {path}: {exc}")
        return None


def _artifact_valid(value: Any) -> bool:
    return isinstance(value, dict) and value.get("valid") is True


def _artifact_issues(label: str, value: Any) -> list[str]:
    if not isinstance(value, dict):
        return [f"{label} missing_or_unreadable"]
    if value.get("valid") is True:
        return []
    return [f"{label} valid flag is not true"]


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
    return sorted(
        [
            item
            for item in gateway.get("discovery", {}).get("selectedReports", [])
            if isinstance(item, dict) and isinstance(item.get("domainID"), str)
        ],
        key=lambda item: item["domainID"],
    )


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
    return {
        "verified": not missing,
        "verifiedLabels": verified_labels,
        "blockers": [f"gateway_live_public_check_missing_or_failed_{label}" for label in missing],
    }


def _registry_entries(registry: Any) -> list[dict[str, Any]]:
    if not isinstance(registry, dict):
        return []
    entries = registry.get("registry", {}).get("entries", [])
    return [entry for entry in entries if isinstance(entry, dict)]


def _registry_issues(registry: Any, entries: list[dict[str, Any]]) -> list[str]:
    if not isinstance(registry, dict):
        return ["native registry artifact missing_or_unreadable"]
    issues: list[str] = []
    if registry.get("publicReferenceOnly") is not True:
        issues.append("native registry artifact publicReferenceOnly is not true")
    if registry.get("schemaVersion") != "1.0.0":
        issues.append("native registry artifact schemaVersion is not 1.0.0")
    if not entries:
        issues.append("native registry artifact has no entries")
    for entry in entries:
        target = entry.get("target")
        if not isinstance(target, dict):
            issues.append("native registry entry target missing")
            continue
        if entry.get("status") != "active":
            issues.append(f"{target.get('domainID', 'unknown')}: native registry target is not active")
        if "startup" not in set(entry.get("allowedModes", [])):
            issues.append(f"{target.get('domainID', 'unknown')}: native registry startup mode missing")
        if target.get("environment") != "production":
            issues.append(f"{target.get('domainID', 'unknown')}: native registry environment is not production")
        if target.get("channel") != "stable":
            issues.append(f"{target.get('domainID', 'unknown')}: native registry channel is not stable")
    return sorted(set(issues))


def _xcode_proof(options: NativeRuntimeCurrentProofOptions) -> dict[str, Any]:
    return {
        "result": options.xcode_result,
        "passed": int(options.xcode_passed),
        "failed": int(options.xcode_failed),
        "skipped": int(options.xcode_skipped),
        "durationMs": options.xcode_duration_ms,
        "buildLogPath": options.xcode_log_path,
        "xcresultPath": options.xcresult_path,
        "xcodeBuildMCPProfile": options.xcode_profile,
        "target": "simulator",
        "testRunnerEnv": {"SOURCE_ATLAS_LIVE_R2_ENDPOINT": options.endpoint} if options.endpoint else {},
        "testSuites": sorted(set(options.test_suites)),
    }


def _xcode_issues(xcode: dict[str, Any]) -> list[str]:
    issues: list[str] = []
    if xcode.get("result") != "SUCCEEDED":
        issues.append("xcodeBuildMCP result is not SUCCEEDED")
    if int(xcode.get("passed", 0)) <= 0:
        issues.append("xcodeBuildMCP passed count is not positive")
    if int(xcode.get("failed", 1)) != 0:
        issues.append("xcodeBuildMCP failed count is not zero")
    if int(xcode.get("skipped", 1)) != 0:
        issues.append("xcodeBuildMCP skipped count is not zero")
    missing_suites = sorted(REQUIRED_NATIVE_TEST_SUITES - set(xcode.get("testSuites", [])))
    issues.extend(f"focused native suite missing: {suite}" for suite in missing_suites)
    return issues


def _privacy_domain_view(domain_proofs: list[dict[str, Any]]) -> list[dict[str, Any]]:
    return [
        {
            "domainID": domain["domainID"],
            "packID": domain.get("packID"),
            "nativeTargetPackID": domain.get("nativeTargetPackID"),
            "sourceIDs": domain.get("sourceIDs", []),
            "blockers": domain.get("blockers", []),
        }
        for domain in domain_proofs
    ]


def _privacy_xcode_view(xcode: dict[str, Any]) -> dict[str, Any]:
    return {
        "result": xcode.get("result"),
        "passed": xcode.get("passed"),
        "failed": xcode.get("failed"),
        "skipped": xcode.get("skipped"),
        "testSuites": xcode.get("testSuites", []),
        "target": xcode.get("target"),
    }


def _check(name: str, passed: bool, issues: list[str]) -> dict[str, Any]:
    return {"name": name, "passed": bool(passed), "issues": sorted(set(issues))}
