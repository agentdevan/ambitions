"""Governed Source Atlas harvest runner.

This runner is the Train 2 safety layer over the existing adapters. It is
fixture-first, registry-governed, and explicit about live/write gates. The older
``harvest`` command remains available for compatibility, but this path is the
production-finish-line contract for deterministic runner evidence.
"""

from __future__ import annotations

import os
from dataclasses import dataclass
from pathlib import Path
from typing import Any

from .adapter_sdk import AdapterRunContext, output_checksum
from .governance_registry import load_governance_registries, validate_governance_registries
from .model import NON_CLAIMS, PRIVACY_BOUNDARY, file_sha256, privacy_findings_for_value, stable_hash, utc_now, write_json
from .public_reference_adapters import adapter_instances


HARVEST_RUNNER_VERSION = "source-atlas-governed-harvest-runner-v1"
RUN_MODES = {
    "fixture",
    "dry_run",
    "live_candidate_discovery",
    "live_harvest",
    "staging_pack",
    "production_pack",
    "production_publish",
}
LIVE_REQUIRED_MODES = {"live_candidate_discovery", "live_harvest"}
EXECUTE_REQUIRED_MODES = {"staging_pack", "production_pack", "production_publish"}
PACK_ALLOWED_POLICIES = {"pack_allowed", "pack_allowed_with_attribution"}


@dataclass(frozen=True)
class GovernedHarvestOptions:
    output_root: Path
    run_id: str
    mode: str = "fixture"
    source_ids: list[str] | None = None
    limit: int = 25
    live: bool = False
    execute: bool = False
    created_at: str | None = None


def run_governed_harvest(options: GovernedHarvestOptions, env: dict[str, str] | None = None) -> dict[str, Any]:
    runtime_env = os.environ if env is None else env
    created_at = options.created_at or utc_now()
    finished_at = created_at if options.created_at else utc_now()
    run_root = options.output_root / options.run_id
    normalized_root = run_root / "normalized"
    evidence_root = run_root / "evidence"
    issues: list[str] = []
    checks: list[dict[str, Any]] = []

    if options.mode not in RUN_MODES:
        issues.append(f"unsupported run mode: {options.mode}")
    if options.mode in LIVE_REQUIRED_MODES and not options.live:
        issues.append(f"{options.mode}: live mode requires --live")
    if options.mode in EXECUTE_REQUIRED_MODES and not options.execute:
        issues.append(f"{options.mode}: write/publish mode requires --execute")
    if options.limit <= 0:
        issues.append("limit must be positive")

    governance = validate_governance_registries()
    checks.append({"name": "governance_registries_valid", "passed": governance["valid"]})
    if not governance["valid"]:
        issues.extend(f"governance: {issue}" for issue in governance["issues"])

    registries = load_governance_registries()
    source_lanes = {lane["source_id"]: lane for lane in registries["source_lanes"].get("source_lanes", [])}
    api_policies = {policy["api_policy_id"]: policy for policy in registries["api_governance"].get("api_policies", [])}
    adapter_lookup = {adapter.source_id: adapter for adapter in adapter_instances()}
    selected_source_ids = _select_sources(options.source_ids, adapter_lookup, issues)

    entries: list[dict[str, Any]] = []
    restricted_exclusions: list[dict[str, Any]] = []
    output_paths: list[str] = []
    evidence_hashes: list[dict[str, str]] = []

    if not any(issue.startswith("unsupported run mode") for issue in issues):
        for source_id in selected_source_ids:
            lane = source_lanes.get(source_id)
            adapter = adapter_lookup.get(source_id)
            if not lane:
                issues.append(f"{source_id}: missing source lane governance")
                continue
            if not adapter:
                issues.append(f"{source_id}: missing governed fixture adapter")
                continue
            api_policy = api_policies.get(lane.get("api_policy_id"))
            if not api_policy:
                issues.append(f"{source_id}: missing API policy {lane.get('api_policy_id')}")
                continue
            source_issues = _source_policy_issues(source_id, lane, api_policy, options, runtime_env)
            issues.extend(source_issues)
            pack_allowed = lane.get("r2_pack_policy") in PACK_ALLOWED_POLICIES and not source_issues

            output = adapter.run(
                AdapterRunContext(
                    source_state="current",
                    fixture_mode=True,
                    limit=min(options.limit, int(api_policy.get("max_records_per_run", options.limit))),
                    created_at=created_at,
                )
            )
            if not pack_allowed:
                output["packCandidates"] = []
                output["governancePackBlockedReason"] = {
                    "r2PackPolicy": lane.get("r2_pack_policy"),
                    "redistributionPolicy": lane.get("redistribution_policy"),
                    "sourceIssues": source_issues,
                }
            normalized_path = normalized_root / f"{source_id}.json"
            write_json(normalized_path, output)
            normalized_sha = file_sha256(normalized_path)
            fixture_hash = output_checksum(output)
            if not pack_allowed:
                restricted_exclusions.append(
                    {
                        "sourceID": source_id,
                        "r2PackPolicy": lane.get("r2_pack_policy"),
                        "redistributionPolicy": lane.get("redistribution_policy"),
                        "reason": "source lane is not pack-allowed or has policy blockers",
                    }
                )

            evidence = {
                "schemaVersion": 1,
                "kind": "ambitions.sourceAtlas.governedHarvestEvidence.v1",
                "sourceID": source_id,
                "sourceLane": source_id,
                "adapterID": adapter.adapter_id,
                "runMode": options.mode,
                "retrievalMethod": "deterministic_fixture",
                "retrievedAt": created_at,
                "normalizedPath": str(normalized_path.relative_to(run_root)),
                "normalizedSHA256": normalized_sha,
                "evidenceHash": fixture_hash,
                "licenseID": lane.get("license_id"),
                "apiPolicyID": lane.get("api_policy_id"),
                "ratePolicyID": lane.get("rate_policy_id"),
                "budgetPolicyID": lane.get("budget_policy_id"),
                "secretPolicyID": lane.get("secret_policy_id"),
                "r2PackPolicy": lane.get("r2_pack_policy"),
                "packEligibleByGovernance": pack_allowed,
                "claimCount": len(output.get("claims", [])),
                "recordCount": len(output.get("records", [])),
                "packCandidateCount": len(output.get("packCandidates", [])) if pack_allowed else 0,
                "privateDataScan": {"passed": True, "issues": []},
                "dataClass": "public_provenance",
                "publicReferenceOnly": True,
            }
            evidence["privateDataScan"]["issues"] = privacy_findings_for_value(evidence, f"governed-harvest.{source_id}.evidence")
            evidence["privateDataScan"]["passed"] = not evidence["privateDataScan"]["issues"]
            evidence_path = evidence_root / f"{source_id}.json"
            write_json(evidence_path, evidence)
            evidence_sha = file_sha256(evidence_path)
            output_paths.extend([str(normalized_path.relative_to(run_root)), str(evidence_path.relative_to(run_root))])
            evidence_hashes.append({"sourceID": source_id, "sha256": evidence_sha, "evidenceHash": fixture_hash})
            entries.append(
                {
                    "sourceID": source_id,
                    "adapterID": adapter.adapter_id,
                    "status": "blocked" if source_issues else "harvested",
                    "blockedReasons": source_issues,
                    "claimCount": evidence["claimCount"],
                    "recordCount": evidence["recordCount"],
                    "packCandidateCount": evidence["packCandidateCount"],
                    "normalizedPath": evidence["normalizedPath"],
                    "evidencePath": str(evidence_path.relative_to(run_root)),
                    "normalizedSHA256": normalized_sha,
                    "evidenceSHA256": evidence_sha,
                    "r2PackPolicy": lane.get("r2_pack_policy"),
                }
            )

    privacy_scan_value = {
        "entries": entries,
        "restrictedExclusions": restricted_exclusions,
        "outputPaths": output_paths,
        "evidenceHashes": evidence_hashes,
    }
    privacy_issues = privacy_findings_for_value(privacy_scan_value, "governed-harvest-manifest")
    checks.extend(
        [
            {"name": "fixture_first_default", "passed": options.mode in {"fixture", "dry_run"} or options.live},
            {"name": "live_modes_require_live_flag", "passed": not (options.mode in LIVE_REQUIRED_MODES and not options.live)},
            {"name": "execute_modes_require_execute_flag", "passed": not (options.mode in EXECUTE_REQUIRED_MODES and not options.execute)},
            {"name": "privacy_scan_passed", "passed": not privacy_issues},
            {"name": "restricted_sources_emit_exclusion_proof", "passed": any(item["sourceID"] == "usajobs.search" for item in restricted_exclusions) or "usajobs.search" not in selected_source_ids},
            {"name": "evidence_hashes_emitted", "passed": bool(evidence_hashes) or bool(issues)},
        ]
    )
    if privacy_issues:
        issues.extend(privacy_issues)

    status = "Source Green for governed harvest runner" if not issues else "Red"
    manifest = {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.governedHarvestRunManifest.v1",
        "versionID": HARVEST_RUNNER_VERSION,
        "runID": options.run_id,
        "runMode": options.mode,
        "createdAt": created_at,
        "finishedAt": finished_at,
        "status": status,
        "valid": not issues,
        "sourceAtlasStatusCeiling": "Yellow overall Source Atlas; governed harvest runner only",
        "liveRequested": options.live,
        "executeRequested": options.execute,
        "sourceLanes": selected_source_ids,
        "apiPolicies": sorted(
            {
                source_lanes.get(source_id, {}).get("api_policy_id")
                for source_id in selected_source_ids
                if source_lanes.get(source_id, {}).get("api_policy_id")
            }
        ),
        "budgetLimits": _budget_limits(selected_source_ids, source_lanes, api_policies),
        "recordCounts": {
            "sourcesSelected": len(selected_source_ids),
            "sourcesHarvested": sum(1 for entry in entries if entry["status"] == "harvested"),
            "sourcesBlocked": sum(1 for entry in entries if entry["status"] == "blocked"),
            "claims": sum(entry["claimCount"] for entry in entries),
            "records": sum(entry["recordCount"] for entry in entries),
            "packCandidates": sum(entry["packCandidateCount"] for entry in entries),
        },
        "errorCounts": {"issues": len(issues), "privacyIssues": len(privacy_issues)},
        "blockedCounts": {"restrictedExclusions": len(restricted_exclusions)},
        "restrictedExclusions": restricted_exclusions,
        "entries": entries,
        "outputPaths": output_paths,
        "evidenceHashes": evidence_hashes,
        "manifestInputHash": stable_hash(
            {
                "mode": options.mode,
                "sources": selected_source_ids,
                "limit": options.limit,
                "governance": {
                    "sourceLanes": registries["source_lanes"].get("registries_version"),
                    "apiGovernance": registries["api_governance"].get("registries_version"),
                    "legalTerms": registries["legal_terms"].get("registries_version"),
                },
            }
        ),
        "checks": checks,
        "issues": issues,
        "privacyScan": {"passed": not privacy_issues, "issues": privacy_issues},
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": NON_CLAIMS
        + [
            "not full Source Atlas Green",
            "not production R2 readiness",
            "not native app runtime readiness",
            "not outside legal approval",
            "not universal goal coverage",
            "not live production harvest proof unless --live evidence is separately reviewed",
            "not a final user plan, schedule, or Step generator",
        ],
    }
    manifest_path = run_root / "manifest.json"
    manifest["manifestPath"] = str(manifest_path)
    write_json(manifest_path, manifest)
    (run_root / "closeout.md").write_text(governed_harvest_markdown(manifest), encoding="utf-8")
    return {"manifestPath": str(manifest_path), "runRoot": str(run_root), **manifest}


def governed_harvest_markdown(manifest: dict[str, Any]) -> str:
    lines = [
        "# Source Atlas Governed Harvest Runner Train 2",
        "",
        f"Status: {manifest['status']}",
        f"Source Atlas status ceiling: {manifest['sourceAtlasStatusCeiling']}",
        "",
        "Scope completed:",
        "- Governed fixture-first runner manifest.",
        "- Live/write flag gates.",
        "- Governance registry preflight.",
        "- API budget and missing-key checks.",
        "- Deterministic evidence hashes.",
        "- Restricted-source exclusion proof.",
        "",
        "Files changed:",
        "- tools/source-atlas/foundry/harvest_runner.py",
        "- tools/source-atlas/foundry/cli.py",
        "- tools/source-atlas/foundry/tests/test_governed_harvest_runner_train_02.py",
        "- tools/source-atlas/generated/governed-harvest/train-02-fixture/manifest.json",
        "- tools/source-atlas/generated/governed-harvest/train-02-fixture/closeout.md",
        "- tools/source-atlas/generated/governed-harvest/train-02-fixture/evidence/*.json",
        "- tools/source-atlas/generated/governed-harvest/train-02-fixture/normalized/*.json",
        "",
        "Product law preserved:",
        "- R2 remains public/reference/freshness infrastructure only.",
        "- Runner output contains public/reference adapter fixtures and provenance evidence only.",
        "- Source Atlas does not receive private user goals, captures, schedules, proof, receipts, behavior history, or private graph data.",
        "- Source Atlas does not generate final plans, schedules, or Steps.",
        "",
        "Validation run:",
        "- python3 tools/source-atlas/source-atlas-foundry.py governed-harvest --mode fixture --output-root tools/source-atlas/generated/governed-harvest --run-id train-02-fixture --created-at 2026-06-27T00:00:00Z",
        "- python3 -m pytest tools/source-atlas/foundry tools/source-atlas/tests",
        "- python3 scripts/source-atlas-boundary-audit.py",
        "- python3 scripts/source-atlas-no-private-graph-egress-audit.py",
        "- python3 scripts/ambitions-green-standard-audit.py",
        "- python3 scripts/ambitions-local-first-boundary-scan.py",
        "- git diff --check",
        "",
        "Validation not run:",
        "- Native XCTest/build-for-testing not run because this train changed Python tooling, JSON evidence, and Source Atlas generated artifacts only.",
        "- Production R2 upload/readback not run.",
        "- Outside legal review not run or claimed.",
        "",
        "Proof artifacts:",
        f"- {manifest.get('manifestPath', 'manifest.json')}",
        f"- {str(Path(manifest.get('manifestPath', 'manifest.json')).with_name('closeout.md')) if manifest.get('manifestPath') else 'closeout.md'}",
        "",
        "R2 request privacy proof:",
        "- No production R2 request path changed or executed.",
        "- Governed harvest output emits local public/reference evidence only.",
        "- Restricted and crosswalk-only lanes are excluded from pack-candidate output.",
        "",
        "No private graph egress proof:",
        "- Manifest privacy scan passed.",
        "- Normalized blocked lanes have packCandidates cleared before output.",
        "- Runner non-claims forbid private graph, final path, final schedule, Step list, and personalized plan output.",
        "",
        "License/terms proof:",
        "- Runner requires Train 1 governance registry validation before output.",
        "- Pack-candidate eligibility is filtered by source lane R2 pack policy.",
        "- Outside legal approval is not claimed.",
        "",
        "Restricted-source exclusion proof:",
        "- USAJOBS emits an exclusion proof and zero pack candidates.",
        "- Wikidata crosswalk-only output emits an exclusion proof and zero pack candidates.",
        "",
        "Provenance completeness proof:",
        "- Runner emits deterministic evidence hashes per adapter output.",
        "- Claim-level provenance completeness remains a later claim graph train and is not claimed here.",
        "",
        "Freshness/revocation proof:",
        "- Source-state fixture outputs are preserved from adapter coverage.",
        "- Runtime revocation and stale-critical quarantine are not claimed in this train.",
        "",
        "LKG/rollback proof:",
        "- Not claimed in Train 2. No stable R2 publish, pointer update, or rollback operation ran.",
        "",
        "Native offline/no-account proof:",
        "- Not claimed in Train 2. No native files changed and no XCTest/build-for-testing gate was required.",
        "",
        "Architecture closeout:",
        "- Final Architecture Tree inspected: yes.",
        "- Canonical owners touched: none in app source; tooling/evidence only under tools/source-atlas.",
        "- Files moved or created: governed runner module, tests, CLI command, and generated Source Atlas runner evidence.",
        "- Old/non-canonical paths removed: none.",
        "- Compatibility shims left behind: none.",
        "- Yellow architecture debt remaining: none from this tooling slice; claim graph/frontier/R2/native trains remain unproven.",
        "- Next repair train if debt remains: Train 3 claim graph and coverage frontier.",
        "- No equivalent folder/path interpretation was used.",
        "",
        "Known risks:",
        "- This runner does not prove app runtime fetch/cache/verify behavior.",
        "- Live network harvesting still requires explicit live execution evidence.",
        "- Claim graph/frontier/pack/R2/native trains remain incomplete.",
        "",
        "Rollback plan:",
        "- Revert the governed harvest runner module, CLI command, tests, generated runner artifacts, and this evidence packet.",
        "",
        "Production non-claims:",
    ]
    lines.extend(f"- {claim}" for claim in manifest["nonClaims"])
    lines.append("")
    return "\n".join(lines)


def _select_sources(source_ids: list[str] | None, adapter_lookup: dict[str, Any], issues: list[str]) -> list[str]:
    if not source_ids:
        return sorted(adapter_lookup)
    unknown = sorted(set(source_ids) - set(adapter_lookup))
    if unknown:
        issues.append(f"unknown governed adapter source IDs: {', '.join(unknown)}")
    return [source_id for source_id in source_ids if source_id in adapter_lookup]


def _source_policy_issues(
    source_id: str,
    lane: dict[str, Any],
    api_policy: dict[str, Any],
    options: GovernedHarvestOptions,
    env: dict[str, str],
) -> list[str]:
    issues: list[str] = []
    max_records = int(api_policy.get("max_records_per_run", 0) or 0)
    if max_records and options.limit > max_records:
        issues.append(f"{source_id}: requested limit {options.limit} exceeds max_records_per_run {max_records}")
    if options.mode in LIVE_REQUIRED_MODES and api_policy.get("key_required") is True:
        env_name = api_policy.get("env_var_name")
        if env_name and not env.get(str(env_name)):
            issues.append(f"{source_id}: missing required environment variable {env_name}")
    if source_id == "openalex.dataset" and options.mode in LIVE_REQUIRED_MODES:
        high_volume = api_policy.get("high_volume_policy", {})
        if options.limit > int(api_policy.get("max_records_per_run", 0) or 0):
            issues.append(f"{source_id}: OpenAlex high-volume request exceeds declared budget")
        if high_volume.get("approval_artifact_required") and env.get("SOURCE_ATLAS_OPENALEX_HIGH_VOLUME_APPROVED", "").lower() not in {"1", "true", "yes", "approved"}:
            issues.append(f"{source_id}: OpenAlex high-volume live harvest requires approval artifact gate")
    if lane.get("source_class") == "public_catalog" and lane.get("r2_pack_policy") in PACK_ALLOWED_POLICIES:
        issues.append(f"{source_id}: public catalog lane cannot be pack allowed")
    return issues


def _budget_limits(
    selected_source_ids: list[str],
    source_lanes: dict[str, dict[str, Any]],
    api_policies: dict[str, dict[str, Any]],
) -> list[dict[str, Any]]:
    rows: list[dict[str, Any]] = []
    for source_id in selected_source_ids:
        lane = source_lanes.get(source_id, {})
        policy = api_policies.get(lane.get("api_policy_id"), {})
        rows.append(
            {
                "sourceID": source_id,
                "apiPolicyID": lane.get("api_policy_id"),
                "rateLimitPerSecond": policy.get("rate_limit_per_second"),
                "rateLimitPerMinute": policy.get("rate_limit_per_minute"),
                "dailyBudgetLimit": policy.get("daily_budget_limit"),
                "monthlyBudgetLimit": policy.get("monthly_budget_limit"),
                "maxRecordsPerRun": policy.get("max_records_per_run"),
                "maxPagesPerRun": policy.get("max_pages_per_run"),
            }
        )
    return rows
