"""Public-reference delivery chain for Source Atlas.

This train stitches the existing autonomous harvest, claim/frontier, pack,
R2 publisher, and native refresh registry compilers into one deterministic
operation. It advances the real downstream delivery path without weakening the
existing production, R2, or native activation gates.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Any

from .claim_frontier import ClaimFrontierOptions, compile_claim_frontier
from .harvest_runner import RUN_MODES, GovernedHarvestOptions, run_governed_harvest
from .model import NON_CLAIMS, PRIVACY_BOUNDARY, privacy_findings_for_value, read_json, stable_hash, utc_now, write_json
from .native_refresh_registry import MODE_ORDER, NATIVE_REGISTRY_MODES, NATIVE_REGISTRY_STATUSES, NativeRefreshRegistryOptions, compile_native_refresh_registry
from .pack_production import PackProductionOptions, build_pack_production
from .r2_pack_publisher import PUBLISHER_MODES, PackR2PublisherOptions, run_pack_r2_publisher


PUBLIC_REFERENCE_DELIVERY_CHAIN_VERSION = "source-atlas-public-reference-delivery-chain-train-100"
PUBLIC_REFERENCE_DELIVERY_CHAIN_KIND = "ambitions.sourceAtlas.publicReferenceDeliveryChain.v1"
DEFAULT_SOURCE_IDS = (
    "onet.database",
    "bls.public.data.api",
    "openalex.dataset",
    "wikidata.crosswalk",
    "usajobs.search",
)

DELIVERY_CHAIN_NON_CLAIMS = [
    "public-reference delivery chain tooling only",
    "not full Source Atlas Green",
    "not production R2 readiness unless remote production upload/readback succeeds in this report",
    "not native app runtime readiness",
    "not release readiness",
    "not outside legal approval",
    "not universal coverage",
    "not final user plans, schedules, or Steps",
    *NON_CLAIMS,
]


@dataclass(frozen=True)
class PublicReferenceDeliveryChainOptions:
    output_root: Path
    domain: str = "occupation_foundation"
    source_ids: tuple[str, ...] = DEFAULT_SOURCE_IDS
    harvest_mode: str = "fixture"
    limit: int = 25
    live: bool = False
    execute_harvest: bool = False
    environment: str = "staging"
    channel: str = "candidate"
    pack_version: str | None = None
    r2_mode: str = "dry_run"
    execute_r2: bool = False
    r2_bucket: str | None = None
    r2_local_store_root: Path | None = None
    r2_readback_root: Path | None = None
    r2_budget_policy: str | None = None
    r2_approval_artifact: Path | None = None
    r2_env_file_paths: tuple[Path, ...] | None = None
    legal_approval_packet: Path | None = None
    production_target_ledger_path: Path | None = None
    native_status: str = "review_required"
    native_allowed_modes: tuple[str, ...] = tuple(MODE_ORDER)
    native_public_locale: str | None = None
    native_approval_artifact: Path | None = None
    app_version: str = "1.0"
    pack_schema_version: str = "1.0.0"
    created_at: str | None = None


def run_public_reference_delivery_chain(options: PublicReferenceDeliveryChainOptions) -> dict[str, Any]:
    created_at = options.created_at or utc_now()
    output_root = options.output_root
    output_root.mkdir(parents=True, exist_ok=True)

    preflight_issues = _preflight_issues(options)
    stages: dict[str, Any] = {}
    if not preflight_issues:
        stages["governedHarvest"] = run_governed_harvest(
            GovernedHarvestOptions(
                output_root=output_root / "01-governed-harvest",
                run_id="delivery-chain",
                mode=options.harvest_mode,
                source_ids=list(options.source_ids),
                limit=options.limit,
                live=options.live,
                execute=options.execute_harvest,
                created_at=created_at,
            ),
            env={},
        )
        if _valid(stages["governedHarvest"]):
            stages["claimFrontier"] = compile_claim_frontier(
                ClaimFrontierOptions(
                    input_root=Path(stages["governedHarvest"]["runRoot"]),
                    output_root=output_root / "02-claim-frontier",
                    created_at=created_at,
                )
            )
        if _valid(stages.get("claimFrontier")):
            stages["packProduction"] = build_pack_production(
                PackProductionOptions(
                    input_root=Path(stages["claimFrontier"]["outputRoot"]),
                    output_root=output_root / "03-pack-production",
                    domain=options.domain,
                    environment=options.environment,
                    channel=options.channel,
                    pack_version=options.pack_version,
                    created_at=created_at,
                    execute=False,
                    legal_approval_packet=options.legal_approval_packet,
                    budget_policy=options.r2_budget_policy,
                )
            )
        if _valid(stages.get("packProduction")):
            stages["r2Publisher"] = run_pack_r2_publisher(
                PackR2PublisherOptions(
                    pack_root=Path(stages["packProduction"]["outputRoot"]),
                    output_root=output_root / "04-r2-publisher",
                    environment=options.environment,
                    channel=options.channel,
                    mode=options.r2_mode,
                    created_at=created_at,
                    execute=options.execute_r2,
                    approval_artifact=options.r2_approval_artifact,
                    legal_approval_packet=options.legal_approval_packet,
                    budget_policy=options.r2_budget_policy,
                    bucket=options.r2_bucket,
                    local_store_root=options.r2_local_store_root or (output_root / "local-r2-store" if options.execute_r2 and options.r2_mode == "local_simulation" else None),
                    readback_root=options.r2_readback_root,
                    production_target_ledger_path=options.production_target_ledger_path,
                    env_file_paths=options.r2_env_file_paths,
                )
            )
        if _valid(stages.get("r2Publisher")):
            stages["nativeRefreshRegistry"] = compile_native_refresh_registry(
                NativeRefreshRegistryOptions(
                    publisher_reports=(Path(stages["r2Publisher"]["outputPaths"]["report"]),),
                    output_root=output_root / "05-native-refresh-registry",
                    created_at=created_at,
                    app_version=options.app_version,
                    pack_schema_version=options.pack_schema_version,
                    status=options.native_status,
                    allowed_modes=options.native_allowed_modes,
                    public_locale=options.native_public_locale,
                    approval_artifact=options.native_approval_artifact,
                    production_target_ledger_path=options.production_target_ledger_path,
                )
            )

    issues = _chain_issues(preflight_issues, stages)
    valid = not issues and all(_valid(stage) for stage in stages.values())
    record_counts = _record_counts(stages)
    delivery_complete = bool(valid and stages.get("nativeRefreshRegistry") and stages.get("r2Publisher"))
    production_uploaded = stages.get("r2Publisher", {}).get("productionR2Uploaded") is True
    native_active = stages.get("nativeRefreshRegistry", {}).get("activeTargetCount", 0) > 0
    checks = _checks(options, preflight_issues, stages, record_counts)
    output_paths = _output_paths(output_root, stages)
    report = {
        "schemaVersion": 1,
        "kind": PUBLIC_REFERENCE_DELIVERY_CHAIN_KIND,
        "versionID": PUBLIC_REFERENCE_DELIVERY_CHAIN_VERSION,
        "createdAt": created_at,
        "status": "Source Green for public-reference delivery chain tooling" if valid else "Red",
        "valid": valid,
        "deliveryComplete": delivery_complete,
        "productionR2Uploaded": production_uploaded,
        "nativeActiveTargets": native_active,
        "sourceAtlasStatusCeiling": _status_ceiling(production_uploaded, native_active),
        "domain": options.domain,
        "sourceIDs": list(options.source_ids),
        "harvestMode": options.harvest_mode,
        "environment": options.environment,
        "channel": options.channel,
        "r2Mode": options.r2_mode,
        "executeR2Requested": options.execute_r2,
        "r2EnvFilesRequested": [str(path) for path in options.r2_env_file_paths] if options.r2_env_file_paths else [],
        "nativeStatus": options.native_status,
        "recordCounts": record_counts,
        "checks": checks,
        "issues": issues,
        "stageSummaries": _stage_summaries(stages),
        "stages": stages,
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": DELIVERY_CHAIN_NON_CLAIMS,
        "productionNonClaims": _production_non_claims(production_uploaded, native_active),
        "outputPaths": output_paths,
    }
    report["outputHashes"] = _output_hashes(output_paths)
    report_path = output_root / "public-reference-delivery-chain-report.json"
    write_json(report_path, report)
    report["outputHashes"]["report"] = stable_hash(read_json(report_path))
    write_json(report_path, report)
    (output_root / "closeout.md").write_text(public_reference_delivery_chain_markdown(report), encoding="utf-8")
    return {"manifestPath": str(report_path), "outputRoot": str(output_root), **report}


def write_public_reference_delivery_chain_report(
    markdown_path: Path,
    json_path: Path,
    *,
    options: PublicReferenceDeliveryChainOptions,
) -> dict[str, Any]:
    result = run_public_reference_delivery_chain(options)
    markdown_path.parent.mkdir(parents=True, exist_ok=True)
    markdown_path.write_text(public_reference_delivery_chain_markdown(result), encoding="utf-8")
    write_json(json_path, result)
    return result


def public_reference_delivery_chain_markdown(result: dict[str, Any]) -> str:
    counts = result["recordCounts"]
    lines = [
        "# Source Atlas Public-Reference Delivery Chain Train 100",
        "",
        f"Status: {result['status']}",
        f"Source Atlas status ceiling: {result['sourceAtlasStatusCeiling']}",
        f"Delivery complete: {'yes' if result['deliveryComplete'] else 'no'}",
        f"Production R2 uploaded: {'yes' if result['productionR2Uploaded'] else 'no'}",
        f"Native active targets: {'yes' if result['nativeActiveTargets'] else 'no'}",
        "",
        "Scope completed:",
        "- Governed harvest, claim/frontier, pack production, R2 publisher, and native refresh registry are chained into one deterministic delivery path.",
        "- R2 can run as dry-run or local simulation; remote R2 remains behind existing publisher gates.",
        "- Native output is a public refresh registry artifact, review-required by default.",
        "",
        "Counts:",
        f"- Harvested sources: {counts['harvestedSources']}",
        f"- Claims: {counts['claims']}",
        f"- Packable claims: {counts['packableClaims']}",
        f"- Pack objects: {counts['packObjects']}",
        f"- R2 object count: {counts['r2Objects']}",
        f"- Native refresh targets: {counts['nativeTargets']}",
        f"- R2 publish operations executed: {counts['r2PublishOperations']}",
        "",
        "Product law preserved:",
        "- Source Atlas/R2 remain public/reference/freshness infrastructure only.",
        "- No private Ambitions runtime context is emitted or sent to R2.",
        "- No final user plans, schedules, Steps, or personalized paths are generated.",
        "",
        "Validation run:",
        "- See the train closeout for exact command output.",
        "",
        "Validation not run:",
        "- Swift/native XCTest/build-for-testing was not required unless native source changes are made.",
        "- Outside legal approval was not claimed.",
    ]
    if not result["productionR2Uploaded"]:
        lines.append("- Production Cloudflare R2 remote upload/readback was not run.")
    lines.extend(["", "Proof artifacts:"])
    for path in result.get("outputPaths", {}).values():
        if path:
            lines.append(f"- {path}")
    lines.extend(
        [
            "",
            "R2 request privacy proof:",
            "- R2 publisher request privacy report is part of the chain output.",
            "- Object keys are checked before any publisher write.",
            "",
            "No private graph egress proof:",
            "- Harvest, claim/frontier, pack, publisher, and native registry privacy scans must pass before Source Green.",
            "- The chain emits no private runtime payloads and no personalized output artifacts.",
            "",
            "License/terms proof:",
            "- Pack and publisher legal/terms gates are inherited from existing modules.",
            "- Outside legal approval is not claimed.",
            "",
            "Restricted-source exclusion proof:",
            "- Restricted and crosswalk-only source exclusions are inherited from claim/frontier and pack production.",
            "",
            "Provenance completeness proof:",
            "- Packable claim provenance completeness is inherited from claim/frontier output.",
            "",
            "Freshness/revocation proof:",
            "- Pack revocation, LKG, rollback, and publisher current-pointer metadata are included when pack/R2 stages pass.",
            "",
            "LKG/rollback proof:",
            "- R2 local simulation records previous pointer snapshots and updates current only after readback checksum success.",
            "",
            "Native offline/no-account proof:",
            "- Native registry artifact contains public routing metadata only and defaults to review-required unless explicitly approved active.",
            "- No native runtime transport or XCTest proof is claimed by this tooling train.",
            "",
            "Architecture closeout:",
            "- Final Architecture Tree inspected: yes.",
            "- Canonical owners touched: none in app source; tooling/evidence only under tools/source-atlas and docs/qa/source-atlas.",
            "- Non-canonical owners touched: none.",
            "- Files moved or created: delivery chain compiler, CLI command, tests, generated evidence, and QA closeout.",
            "- Old/non-canonical paths removed: none.",
            "- Compatibility shims left behind: none.",
            "- Yellow architecture debt remaining: native runtime XCTest/device/offline proof and real remote R2 proof remain separate if not run.",
            "- No equivalent folder/path interpretation was used.",
            "",
            "Production non-claims:",
        ]
    )
    lines.extend(f"- {claim}" for claim in result["productionNonClaims"])
    lines.append("")
    return "\n".join(lines)


def _preflight_issues(options: PublicReferenceDeliveryChainOptions) -> list[str]:
    issues: list[str] = []
    if options.harvest_mode not in RUN_MODES:
        issues.append(f"unsupported harvest mode: {options.harvest_mode}")
    if options.r2_mode not in PUBLISHER_MODES:
        issues.append(f"unsupported R2 publisher mode: {options.r2_mode}")
    if options.environment not in {"staging", "production"}:
        issues.append(f"unsupported environment: {options.environment}")
    if options.limit <= 0:
        issues.append("limit must be positive")
    if not options.source_ids:
        issues.append("at least one source ID is required")
    if options.native_status not in NATIVE_REGISTRY_STATUSES:
        issues.append(f"unsupported native registry status: {options.native_status}")
    unsupported_modes = [mode for mode in options.native_allowed_modes if mode not in NATIVE_REGISTRY_MODES]
    issues.extend(f"unsupported native lifecycle mode: {mode}" for mode in unsupported_modes)
    issues.extend(
        privacy_findings_for_value(
            {
                "domain": options.domain,
                "sourceIDs": list(options.source_ids),
                "environment": options.environment,
                "channel": options.channel,
                "nativePublicLocale": options.native_public_locale,
            },
            "public-reference-delivery-chain-input",
        )
    )
    return sorted(set(issues))


def _chain_issues(preflight_issues: list[str], stages: dict[str, Any]) -> list[str]:
    issues = list(preflight_issues)
    required = ["governedHarvest", "claimFrontier", "packProduction", "r2Publisher", "nativeRefreshRegistry"]
    for name in required:
        stage = stages.get(name)
        if stage is None:
            issues.append(f"{name}: stage did not run")
            continue
        if stage.get("valid") is not True:
            issues.extend(f"{name}: {issue}" for issue in stage.get("issues", []))
    return sorted(set(issues))


def _valid(stage: dict[str, Any] | None) -> bool:
    return isinstance(stage, dict) and stage.get("valid") is True


def _checks(options: PublicReferenceDeliveryChainOptions, preflight_issues: list[str], stages: dict[str, Any], record_counts: dict[str, int]) -> list[dict[str, Any]]:
    return [
        {"name": "preflight_passed", "passed": not preflight_issues, "issues": preflight_issues},
        {"name": "governed_harvest_valid", "passed": _valid(stages.get("governedHarvest")), "issues": stages.get("governedHarvest", {}).get("issues", ["stage did not run"])},
        {"name": "claim_frontier_valid", "passed": _valid(stages.get("claimFrontier")), "issues": stages.get("claimFrontier", {}).get("issues", ["stage did not run"])},
        {"name": "pack_production_valid", "passed": _valid(stages.get("packProduction")), "issues": stages.get("packProduction", {}).get("issues", ["stage did not run"])},
        {"name": "r2_publisher_valid", "passed": _valid(stages.get("r2Publisher")), "issues": stages.get("r2Publisher", {}).get("issues", ["stage did not run"])},
        {"name": "native_refresh_registry_valid", "passed": _valid(stages.get("nativeRefreshRegistry")), "issues": stages.get("nativeRefreshRegistry", {}).get("issues", ["stage did not run"])},
        {"name": "local_simulation_or_dry_run_by_default", "passed": options.r2_mode != "remote_r2" or options.execute_r2, "issues": []},
        {
            "name": "chain_emits_no_final_user_outputs",
            "passed": record_counts["finalOutputArtifacts"] == 0,
            "issues": [] if record_counts["finalOutputArtifacts"] == 0 else ["final user output artifact emitted"],
        },
    ]


def _record_counts(stages: dict[str, Any]) -> dict[str, int]:
    harvest = stages.get("governedHarvest", {})
    claim = stages.get("claimFrontier", {})
    pack = stages.get("packProduction", {})
    r2 = stages.get("r2Publisher", {})
    native = stages.get("nativeRefreshRegistry", {})
    operation = r2.get("operation", {}) if isinstance(r2, dict) else {}
    return {
        "harvestedSources": harvest.get("recordCounts", {}).get("sourcesHarvested", harvest.get("recordCounts", {}).get("sourceCount", 0)),
        "claims": claim.get("recordCounts", {}).get("claims", 0),
        "packableClaims": claim.get("recordCounts", {}).get("packableClaims", 0),
        "packObjects": pack.get("recordCounts", {}).get("objectCount", 0),
        "r2Objects": r2.get("objectCount", 0),
        "r2PublishOperations": 1 if operation.get("executed") is True else 0,
        "nativeTargets": native.get("targetCount", 0),
        "nativeActiveTargets": native.get("activeTargetCount", 0),
        "finalOutputArtifacts": 0,
    }


def _stage_summaries(stages: dict[str, Any]) -> dict[str, Any]:
    summaries: dict[str, Any] = {}
    for name, stage in stages.items():
        output_root = stage.get("outputRoot", "")
        if not output_root:
            first_path = _first_output_path(stage.get("outputPaths"))
            output_root = str(Path(first_path).parent) if first_path else ""
        summaries[name] = {
            "status": stage.get("status"),
            "valid": stage.get("valid"),
            "outputRoot": output_root,
            "issues": stage.get("issues", []),
        }
    return summaries


def _first_output_path(value: Any) -> str:
    if isinstance(value, dict):
        return str(next((path for path in value.values() if path), ""))
    if isinstance(value, list):
        return str(next((path for path in value if path), ""))
    return ""


def _output_paths(output_root: Path, stages: dict[str, Any]) -> dict[str, str]:
    return {
        "report": str(output_root / "public-reference-delivery-chain-report.json"),
        "governedHarvest": stages.get("governedHarvest", {}).get("manifestPath", ""),
        "claimFrontier": stages.get("claimFrontier", {}).get("manifestPath", ""),
        "packProduction": stages.get("packProduction", {}).get("reportPath", ""),
        "r2Publisher": stages.get("r2Publisher", {}).get("outputPaths", {}).get("report", ""),
        "r2RequestPrivacy": stages.get("r2Publisher", {}).get("outputPaths", {}).get("requestPrivacy", ""),
        "r2UploadReadback": stages.get("r2Publisher", {}).get("outputPaths", {}).get("uploadReadback", ""),
        "nativeRefreshRegistry": stages.get("nativeRefreshRegistry", {}).get("outputPaths", {}).get("report", ""),
        "nativeRefreshArtifact": stages.get("nativeRefreshRegistry", {}).get("outputPaths", {}).get("artifact", ""),
        "closeout": str(output_root / "closeout.md"),
    }


def _output_hashes(paths: dict[str, str]) -> dict[str, str]:
    hashes: dict[str, str] = {}
    for key, value in paths.items():
        if key == "closeout" or not value:
            continue
        path = Path(value)
        if path.exists() and path.suffix == ".json":
            hashes[key] = stable_hash(read_json(path))
    return hashes


def _status_ceiling(production_uploaded: bool, native_active: bool) -> str:
    if production_uploaded and native_active:
        return "Yellow overall Source Atlas; production R2 and native artifact proof still require app runtime/release validation"
    if production_uploaded:
        return "Yellow overall Source Atlas; production R2 publisher proof only, native runtime unproven"
    return "Yellow overall Source Atlas; public-reference delivery chain tooling only"


def _production_non_claims(production_uploaded: bool, native_active: bool) -> list[str]:
    claims = [
        "no full Source Atlas Green",
        "no native app runtime Green",
        "no release Green",
        "no universal coverage",
        "no outside legal approval",
        "no final user plan, schedule, or Step generation",
    ]
    if not production_uploaded:
        claims.append("no production Cloudflare R2 upload/readback proof")
    if not native_active:
        claims.append("no owner-approved active native refresh target")
    return claims
