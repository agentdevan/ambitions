from __future__ import annotations

import copy
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from foundry.model import read_json, write_json
from foundry.production_target_ledger import ProductionTargetLedgerOptions, build_production_target_ledger


CREATED_AT = "2026-06-28T00:00:00Z"
SOURCE_ATLAS_ROOT = Path(__file__).resolve().parents[2]
REPO_ROOT = Path(__file__).resolve().parents[4]

FRONTIER_CONFIG = SOURCE_ATLAS_ROOT / "frontier" / "coverage-frontiers.json"
SOURCE_LANE_REGISTRY = SOURCE_ATLAS_ROOT / "governance" / "source-lane-registry.json"
CLAIM_REPORT_ROOT = SOURCE_ATLAS_ROOT / "generated" / "claim-frontier"
PACK_REPORT_ROOT = SOURCE_ATLAS_ROOT / "generated" / "pack-production"
R2_REPORT_ROOT = SOURCE_ATLAS_ROOT / "generated" / "r2-publisher"
GATEWAY_RELEASE = (
    SOURCE_ATLAS_ROOT
    / "generated"
    / "r2-public-gateway"
    / "train-131-tetradeca-ledger-gated-live-verify"
    / "public-gateway-release-report.json"
)
NATIVE_REGISTRY_REPORT = (
    SOURCE_ATLAS_ROOT
    / "generated"
    / "native-refresh-registry"
    / "train-131-tetradeca-domain-active-ledger-gated"
    / "native-refresh-registry-report.json"
)
NATIVE_REGISTRY_ARTIFACT = (
    SOURCE_ATLAS_ROOT
    / "generated"
    / "native-refresh-registry"
    / "train-131-tetradeca-domain-active-ledger-gated"
    / "source-atlas-public-refresh-targets.json"
)
NATIVE_RUNTIME_CLOSEOUT = (
    SOURCE_ATLAS_ROOT
    / "generated"
    / "native-runtime-current-proof"
    / "train-117-current"
    / "native-runtime-current-proof-report.json"
)


def test_production_target_ledger_marks_all_configured_frontiers_ready(tmp_path: Path):
    ledger = _build(tmp_path)

    assert ledger["valid"], ledger["privacyIssues"]
    assert ledger["status"] == "Source Green for production target ledger"
    expected_count = _configured_frontier_count(frontier_config_path=FRONTIER_CONFIG)
    assert ledger["recordCounts"]["configuredFrontiers"] == expected_count
    assert ledger["recordCounts"]["productionR2Domains"] == expected_count
    assert ledger["recordCounts"]["gatewayReadyDomains"] == expected_count
    assert ledger["recordCounts"]["nativeRegistryDomains"] == expected_count
    assert ledger["recordCounts"]["boundedProductionTargetReady"] == expected_count
    assert ledger["recordCounts"]["orphanProductionDomains"] == 0
    assert ledger["recordCounts"]["configuredDomainsNotReady"] == 0
    assert ledger["overallReadinessStatus"] == "configured_frontiers_bounded_production_target_ready"
    assert ledger["universalCoverageClaimAllowed"] is False
    assert ledger["allowedClaims"] == [
        "bounded_production_target_for_configured_frontiers",
        "bounded_production_target_per_ready_frontier",
    ]

    statcan = _domain(ledger, "health_wellness_reference_ca_statistics")
    assert statcan["frontierConfigured"] is True
    assert statcan["claimGraphProofComplete"] is True
    assert statcan["packProductionProofComplete"] is True
    assert statcan["r2ProductionProofComplete"] is True
    assert statcan["gatewayProofComplete"] is True
    assert statcan["nativeUsabilityProofComplete"] is True
    assert statcan["blockedReasons"] == []


def test_orphan_production_domain_blocks_configured_frontier_claim(tmp_path: Path):
    frontier = copy.deepcopy(read_json(FRONTIER_CONFIG))
    frontier["frontiers"] = [
        item
        for item in frontier["frontiers"]
        if item.get("frontier_id") != "health_wellness_reference_ca_statistics"
    ]
    frontier_path = tmp_path / "coverage-frontiers-without-statcan.json"
    write_json(frontier_path, frontier)

    ledger = _build(tmp_path, frontier_config_path=frontier_path)

    assert ledger["valid"]
    assert "health_wellness_reference_ca_statistics" in ledger["orphanProductionDomains"]
    assert "bounded_production_target_for_configured_frontiers" not in ledger["allowedClaims"]
    statcan = _domain(ledger, "health_wellness_reference_ca_statistics")
    assert statcan["readinessStatus"] == "orphan_production_evidence_blocked"
    assert "frontier_config_missing" in statcan["blockedReasons"]
    assert any("production evidence exists without configured frontier" in issue for issue in ledger["globalBlockers"])


def test_missing_native_runtime_closeout_blocks_native_usability(tmp_path: Path):
    ledger = _build(tmp_path, native_runtime_closeout_path=None)

    assert ledger["valid"]
    assert ledger["overallReadinessStatus"] == "blocked_or_partial"
    assert ledger["recordCounts"]["boundedProductionTargetReady"] == 0
    occupation = _domain(ledger, "occupation_foundation")
    assert occupation["r2ProductionProofComplete"] is True
    assert occupation["nativeRegistryProofComplete"] is True
    assert occupation["nativeRuntimeBoundaryProofComplete"] is False
    assert "native_runtime_boundary_proof_missing_or_incomplete" in occupation["blockedReasons"]


def test_private_context_in_gateway_evidence_rejects_ledger(tmp_path: Path):
    gateway = copy.deepcopy(read_json(GATEWAY_RELEASE))
    gateway["goalText"] = "blocked synthetic value"
    gateway_path = tmp_path / "private-gateway-release.json"
    write_json(gateway_path, gateway)

    ledger = _build(tmp_path, gateway_release_report_path=gateway_path)

    assert ledger["valid"] is False
    assert ledger["status"] == "Red"
    assert ledger["privacyIssues"]


def _build(
    tmp_path: Path,
    *,
    frontier_config_path: Path = FRONTIER_CONFIG,
    gateway_release_report_path: Path = GATEWAY_RELEASE,
    native_runtime_closeout_path: Path | None = NATIVE_RUNTIME_CLOSEOUT,
) -> dict:
    return build_production_target_ledger(
        ProductionTargetLedgerOptions(
            frontier_config_path=frontier_config_path,
            source_lane_registry_path=SOURCE_LANE_REGISTRY,
            claim_frontier_report_root=CLAIM_REPORT_ROOT,
            pack_production_report_root=PACK_REPORT_ROOT,
            r2_publisher_report_root=R2_REPORT_ROOT,
            gateway_release_report_path=gateway_release_report_path,
            native_registry_report_path=NATIVE_REGISTRY_REPORT,
            native_registry_artifact_path=NATIVE_REGISTRY_ARTIFACT,
            native_runtime_closeout_path=native_runtime_closeout_path,
            output_root=tmp_path / "ledger",
            created_at=CREATED_AT,
        )
    )


def _domain(ledger: dict, domain_id: str) -> dict:
    return next(item for item in ledger["domains"] if item["domainID"] == domain_id)


def _configured_frontier_count(*, frontier_config_path: Path) -> int:
    return len(read_json(frontier_config_path)["frontiers"])
