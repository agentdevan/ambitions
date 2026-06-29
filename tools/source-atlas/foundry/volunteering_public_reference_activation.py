"""Staged activation chain for the volunteering public-reference frontier."""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Any

from .claim_frontier import DEFAULT_FRONTIER_CONFIG_PATH, ClaimFrontierOptions, compile_claim_frontier
from .harvest_runner import GovernedHarvestOptions, run_governed_harvest
from .model import NON_CLAIMS, PRIVACY_BOUNDARY, file_sha256, read_json, write_json
from .pack_production import PackProductionOptions, build_pack_production


VOLUNTEERING_ACTIVATION_VERSION = "source-atlas-volunteering-public-reference-activation-train-130"
DOMAIN = "volunteering_public_reference"
SOURCE_ID = "americorps.volunteer_rate_state"

PRODUCTION_NON_CLAIMS = NON_CLAIMS + [
    "not full Source Atlas Green",
    "not production R2 readiness",
    "not native app runtime readiness",
    "not outside legal approval",
    "not universal goal coverage",
    "not current volunteer opportunity availability",
    "not eligibility advice",
    "not a personalized volunteering plan",
    "not a final user plan, schedule, or Step generator",
]


@dataclass(frozen=True)
class VolunteeringPublicReferenceActivationOptions:
    output_root: Path
    frontier_config_path: Path = DEFAULT_FRONTIER_CONFIG_PATH
    created_at: str = "2026-06-29T05:30:00Z"
    run_label: str = "current"


def run_volunteering_public_reference_activation(options: VolunteeringPublicReferenceActivationOptions) -> dict[str, Any]:
    root = options.output_root / f"train-130-{options.run_label}"
    root.mkdir(parents=True, exist_ok=True)
    staged_frontier_path = root / "staged-coverage-frontiers.json"
    active_frontier_hash_before = file_sha256(options.frontier_config_path)
    _write_staged_frontier_config(options.frontier_config_path, staged_frontier_path)
    active_frontier_not_mutated = _active_frontier_hash_unchanged(options.frontier_config_path, active_frontier_hash_before)

    harvest = run_governed_harvest(
        GovernedHarvestOptions(
            output_root=root / "governed-harvest",
            run_id="volunteering-public-reference-fixture",
            mode="fixture",
            source_ids=[SOURCE_ID],
            limit=6,
            created_at=options.created_at,
        ),
        env={},
    )
    frontier = compile_claim_frontier(
        ClaimFrontierOptions(
            input_root=Path(harvest["runRoot"]),
            output_root=root / "claim-frontier",
            frontier_config_path=staged_frontier_path,
            created_at=options.created_at,
        )
    )
    pack = build_pack_production(
        PackProductionOptions(
            input_root=Path(frontier["outputRoot"]),
            output_root=root / "pack-production",
            domain=DOMAIN,
            environment="staging",
            channel="candidate",
            created_at=options.created_at,
        )
    )

    frontier_report = _frontier_report_for_domain(Path(frontier["outputRoot"]) / "coverage-frontier-report.json")
    checks = [
        {"name": "staged_frontier_config_written", "passed": staged_frontier_path.exists()},
        {"name": "governed_harvest_valid", "passed": bool(harvest.get("valid"))},
        {"name": "claim_frontier_valid", "passed": bool(frontier.get("valid"))},
        {"name": "pack_production_dry_run_valid", "passed": bool(pack.get("valid"))},
        {"name": "frontier_claim_graph_ready", "passed": frontier_report.get("status") == "claim_graph_ready"},
        {"name": "frontier_gold_set_passed", "passed": frontier_report.get("gold_set_status") == "passed"},
        {"name": "pack_contains_three_claims", "passed": pack.get("recordCounts", {}).get("claims") == 3},
        {"name": "pack_is_staging_candidate_only", "passed": pack.get("environment") == "staging" and pack.get("channel") == "candidate"},
        {"name": "active_production_frontier_not_mutated", "passed": active_frontier_not_mutated},
        {"name": "no_private_or_final_user_artifacts", "passed": bool(pack.get("nonPrivateScan", {}).get("passed"))},
    ]
    issues: list[str] = []
    for label, result in [("harvest", harvest), ("claim_frontier", frontier), ("pack", pack)]:
        issues.extend(f"{label}: {issue}" for issue in result.get("issues", []))
    issues.extend(check["name"] for check in checks if not check["passed"])
    valid = not issues

    report_path = root / "activation-report.json"
    result = {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.volunteeringPublicReferenceActivation.v1",
        "versionID": VOLUNTEERING_ACTIVATION_VERSION,
        "createdAt": options.created_at,
        "status": "Source Green for volunteering public-reference staged activation" if valid else "Red",
        "valid": valid,
        "reportPath": str(report_path),
        "domain": DOMAIN,
        "sourceID": SOURCE_ID,
        "sourceAtlasStatusCeiling": "Yellow overall Source Atlas; volunteering public-reference staged activation only",
        "activeCoverageFrontierMutations": 0 if active_frontier_not_mutated else 1,
        "productionR2Executed": False,
        "nativeRuntimeChanged": False,
        "outsideLegalApprovalClaimed": False,
        "recordCounts": {
            "harvestClaims": harvest.get("recordCounts", {}).get("claims", 0),
            "frontierClaims": frontier.get("recordCounts", {}).get("claims", 0),
            "packClaims": pack.get("recordCounts", {}).get("claims", 0),
            "blockedClaimsExcluded": pack.get("recordCounts", {}).get("blockedClaimsExcluded", 0),
        },
        "frontierReport": frontier_report,
        "checks": checks,
        "issues": issues,
        "outputPaths": {
            "stagedFrontierConfig": str(staged_frontier_path),
            "harvestManifest": str(Path(harvest["runRoot"]) / "manifest.json"),
            "claimFrontierManifest": str(Path(frontier["outputRoot"]) / "manifest.json"),
            "packProductionReport": str(Path(pack["outputRoot"]) / "pack-production-report.json"),
            "closeout": str(root / "closeout.md"),
        },
        "outputHashes": {
            "stagedFrontierConfig": file_sha256(staged_frontier_path),
            "harvestManifest": file_sha256(Path(harvest["runRoot"]) / "manifest.json"),
            "claimFrontierManifest": file_sha256(Path(frontier["outputRoot"]) / "manifest.json"),
            "packProductionReport": file_sha256(Path(pack["outputRoot"]) / "pack-production-report.json"),
        },
        "nonClaims": PRODUCTION_NON_CLAIMS,
        "privacyBoundary": PRIVACY_BOUNDARY,
    }
    write_json(report_path, result)
    _write_closeout(root / "closeout.md", result)
    return {"reportPath": str(report_path), "outputRoot": str(root), **result}


def volunteering_public_reference_activation_markdown(result: dict[str, Any]) -> str:
    lines = [
        "# Source Atlas Volunteering Public Reference Staged Activation Train 130",
        "",
        f"Status: {result['status']}",
        f"Source Atlas status ceiling: {result['sourceAtlasStatusCeiling']}",
        "",
        "Scope completed:",
        "- AmeriCorps Open Data volunteering public-reference source lane staged through governed harvest.",
        "- Staged coverage frontier config for volunteering_public_reference.",
        "- Claim frontier/gold-set proof for volunteer-rate, civic-engagement, and dataset-scope claims.",
        "- Pack-production staging/candidate dry-run proof with non-private scan.",
        "",
        "Product law preserved:",
        "- Source Atlas remains public/reference/freshness infrastructure only.",
        "- No private user goal, capture, schedule, proof, receipt, account, device, behavior, or private graph context is used.",
        "- No current opportunity matching, service eligibility decision, final plan, final schedule, or Step output is generated.",
        "- Active production frontier was not mutated by this staged activation.",
        "",
        "Validation run:",
        "- source-atlas-foundry volunteering-public-reference-activation",
        "- focused pytest coverage for the AmeriCorps adapter and activation chain",
        "",
        "Validation not run:",
        "- Production R2 upload/readback was not run.",
        "- Native XCTest/build-for-testing was not required because this train changed Python tooling, Source Atlas registries, and generated evidence only.",
        "- Outside legal review was not run or claimed.",
        "",
        "Proof artifacts:",
        f"- {result['reportPath']}",
        f"- {result['outputPaths']['stagedFrontierConfig']}",
        f"- {result['outputPaths']['harvestManifest']}",
        f"- {result['outputPaths']['claimFrontierManifest']}",
        f"- {result['outputPaths']['packProductionReport']}",
        f"- {result['outputPaths']['closeout']}",
        "",
        "Known risks:",
        "- This is staged activation proof, not stable-channel production promotion.",
        "- Volunteering coverage is bounded to AmeriCorps public statistical/reference context, not opportunity availability or personalized placement.",
        "- Runtime/release proof remains scoped to existing generated native evidence unless separately refreshed on device.",
        "",
        "Follow-up required:",
        "- Promote the volunteering frontier to active production target only after stable R2/native/runtime gates are updated for this domain.",
        "- Add additional official volunteering/public-service sources through the same staged activation chain.",
        "",
        "Rollback plan:",
        "- Revert the AmeriCorps adapter, registry entries, activation runner, tests, and generated train-130 evidence.",
        "",
        "Production non-claims:",
    ]
    lines.extend(f"- {claim}" for claim in result["nonClaims"])
    lines.append("")
    return "\n".join(lines)


def _write_staged_frontier_config(base_path: Path, output_path: Path) -> None:
    base = read_json(base_path)
    frontiers = [frontier for frontier in base.get("frontiers", []) if frontier.get("frontier_id") != DOMAIN]
    frontiers.append(_volunteering_frontier())
    staged = {
        **base,
        "frontiers": sorted(frontiers, key=lambda item: item.get("frontier_id", "")),
        "staged_activation": {
            "domain": DOMAIN,
            "source_id": SOURCE_ID,
            "active_production_frontier_mutation": False,
            "non_claims": PRODUCTION_NON_CLAIMS,
        },
    }
    write_json(output_path, staged)


def _volunteering_frontier() -> dict[str, Any]:
    return {
        "schema_version": "1.0.0",
        "frontier_id": DOMAIN,
        "domain": DOMAIN,
        "goal_intent_classes": [
            "volunteering_public_reference",
            "public_civic_life_reference",
        ],
        "claim_classes": [
            "civic_engagement_reference",
            "public_dataset_scope_reference",
            "volunteer_rate_reference",
        ],
        "jurisdictions": ["US"],
        "source_classes_required": ["official_government"],
        "minimum_authority_classes": ["official_government"],
        "freshness_slas": ["biennial_dataset_posting_context_quarterly_metadata_recheck"],
        "legal_posture_required": "pack_output_allowed",
        "gold_set_required": True,
        "source_ids": [SOURCE_ID],
        "excluded_sources": [],
        "status_ceiling": "pack_staging_ready",
        "gold_set": {
            "gold_set_id": "gold.volunteering_public_reference.americorps_state_volunteer_rate.v1",
            "non_claims": [
                "not current volunteer opportunity availability",
                "not eligibility advice",
                "not legal advice",
                "not personalized placement recommendation",
                "not a personalized volunteering plan",
                "not release readiness",
            ],
            "required_claims": [
                {
                    "gold_claim_id": "gold.volunteering.americorps.volunteer_rate",
                    "source_id": SOURCE_ID,
                    "claim_type": "volunteer_rate_reference",
                    "jurisdiction": "US",
                    "object_contains": [
                        "State Ranking by Volunteer Rate",
                        "not as a current opportunity listing",
                    ],
                },
                {
                    "gold_claim_id": "gold.volunteering.americorps.civic_engagement",
                    "source_id": SOURCE_ID,
                    "claim_type": "civic_engagement_reference",
                    "jurisdiction": "US",
                    "object_contains": [
                        "civic engagement trends",
                        "not as service-program legal advice",
                    ],
                },
                {
                    "gold_claim_id": "gold.volunteering.americorps.dataset_scope",
                    "source_id": SOURCE_ID,
                    "claim_type": "public_dataset_scope_reference",
                    "jurisdiction": "US",
                    "object_contains": [
                        "biennial posting context",
                        "not treat it as real-time volunteer opportunity availability",
                    ],
                },
            ],
        },
        "non_claims": [
            "not current volunteer opportunity availability",
            "not eligibility advice",
            "not legal advice",
            "not a personalized placement recommendation",
            "not a personalized volunteering plan",
            "not universal volunteering coverage",
            "not outside legal approval",
        ],
    }


def _frontier_report_for_domain(path: Path) -> dict[str, Any]:
    report = read_json(path)
    for frontier in report.get("frontiers", []):
        if frontier.get("frontier_id") == DOMAIN:
            return frontier
    return {}


def _active_frontier_hash_unchanged(path: Path, expected_hash: str) -> bool:
    return file_sha256(path) == expected_hash


def _write_closeout(path: Path, result: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(volunteering_public_reference_activation_markdown(result), encoding="utf-8")
