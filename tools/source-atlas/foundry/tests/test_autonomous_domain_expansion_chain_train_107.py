from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from foundry.autonomous_domain_expansion_chain import (  # noqa: E402
    AutonomousDomainExpansionChainOptions,
    run_autonomous_domain_expansion_chain,
)
from foundry.model import read_json, write_json  # noqa: E402


CREATED_AT = "2026-06-28T21:40:00Z"


def test_autonomous_domain_expansion_chain_advances_candidate_frontier_to_review_packets(tmp_path: Path):
    paths = _fixture_paths(tmp_path)

    result = run_autonomous_domain_expansion_chain(
        AutonomousDomainExpansionChainOptions(
            executor_report_path=paths["executor_report"],
            output_root=tmp_path / "chain",
            frontier_config_path=paths["frontiers"],
            mode="fixture",
            reviewer="source-atlas-reviewer",
            created_at=CREATED_AT,
        )
    )

    assert result["valid"], result["issues"]
    assert result["status"] == "Source Green for autonomous domain expansion chain"
    assert result["recordCounts"]["candidateInputs"] == 1
    assert result["recordCounts"]["routes"] == 1
    assert result["recordCounts"]["candidateRoutes"] == 1
    assert result["recordCounts"]["workOrders"] == 13
    assert result["recordCounts"]["candidateWorkOrders"] == 13
    assert result["recordCounts"]["completedSafeChecks"] == 2
    assert result["recordCounts"]["blockedReviewRequired"] == 4
    assert result["recordCounts"]["reviewPackets"] == 4
    assert result["recordCounts"]["completedReviewPackets"] == 0
    assert result["recordCounts"]["activeRegistryMutations"] == 0
    assert result["recordCounts"]["claims"] == 0
    assert result["recordCounts"]["packableClaims"] == 0
    assert result["recordCounts"]["r2PublishOperations"] == 0
    assert result["recordCounts"]["nativeActivationOperations"] == 0
    assert _check(result, "review_stage_matches_execution_path")
    assert _check(result, "chain_emits_no_claims_packs_r2_or_native_activation")

    templates = read_json(Path(result["outputPaths"]["reviewPacketTemplates"]))
    review_lanes = {packet["reviewLane"] for packet in templates["reviewPackets"]}
    assert review_lanes == {
        "api_governance_review",
        "direct_source_authority_resolution",
        "legal_terms_review",
        "source_lane_governance",
    }
    assert all(packet["manualReviewRequired"] is True for packet in templates["reviewPackets"])
    assert all(packet["approvalArtifactEmitted"] is False for packet in templates["reviewPackets"])
    assert all(packet["r2PublishAllowed"] is False for packet in templates["reviewPackets"])


def test_autonomous_domain_expansion_chain_routes_known_public_benefits_to_maintenance_lane(tmp_path: Path):
    paths = _fixture_paths(tmp_path)
    _write_finance_public_reference_frontier(paths["frontiers"])
    ledger = paths["root"] / "production-target-ledger.json"
    _write_finance_public_reference_ledger(ledger)
    chain_root = tmp_path / "chain"
    stale_review_dir = chain_root / "04-review-packets"
    stale_review_dir.mkdir(parents=True)
    (stale_review_dir / "goal-domain-review-packets.json").write_text("{}", encoding="utf-8")
    (stale_review_dir / "review-packet-templates.json").write_text("{}", encoding="utf-8")

    result = run_autonomous_domain_expansion_chain(
        AutonomousDomainExpansionChainOptions(
            executor_report_path=paths["executor_report"],
            output_root=chain_root,
            frontier_config_path=paths["frontiers"],
            production_target_ledger_path=ledger,
            mode="fixture",
            reviewer="source-atlas-reviewer",
            created_at=CREATED_AT,
        )
    )

    assert result["valid"], result["issues"]
    assert result["recordCounts"]["candidateInputs"] == 1
    assert result["recordCounts"]["routes"] == 1
    assert result["recordCounts"]["candidateRoutes"] == 0
    assert result["recordCounts"]["productionReadyRoutes"] == 1
    assert result["recordCounts"]["workOrders"] == 4
    assert result["recordCounts"]["candidateWorkOrders"] == 0
    assert result["recordCounts"]["completedSafeChecks"] == 4
    assert result["recordCounts"]["blockedReviewRequired"] == 0
    assert result["recordCounts"]["reviewPackets"] == 0
    assert result["recordCounts"]["completedReviewPackets"] == 0
    assert result["recordCounts"]["claims"] == 0
    assert result["recordCounts"]["packableClaims"] == 0
    assert result["recordCounts"]["r2PublishOperations"] == 0
    assert result["recordCounts"]["nativeActivationOperations"] == 0
    assert _check(result, "review_stage_matches_execution_path")
    assert _check(result, "chain_emits_no_claims_packs_r2_or_native_activation")

    routing = read_json(Path(result["stages"]["goalDomainRouter"]["outputPaths"]["goalDomainRouting"]))
    route = routing["routes"][0]
    assert route["route"] == "configured_production_target_ready"
    assert route["matchedDomainID"] == "finance_public_reference"
    assert route["packOutputAllowed"] is True
    assert route["r2PublishAllowed"] is False

    review_stage = read_json(Path(result["outputPaths"]["reviewPackets"]))
    assert review_stage["kind"] == "ambitions.sourceAtlas.goalDomainReviewPacketsNotRequired.v1"
    assert review_stage["valid"] is True
    assert review_stage["recordCounts"]["reviewPackets"] == 0
    assert review_stage["recordCounts"]["approvalArtifactsEmitted"] == 0
    assert not (stale_review_dir / "goal-domain-review-packets.json").exists()
    assert not (stale_review_dir / "review-packet-templates.json").exists()


def test_autonomous_domain_expansion_chain_supports_dry_run_executor_mode(tmp_path: Path):
    paths = _fixture_paths(tmp_path)

    result = run_autonomous_domain_expansion_chain(
        AutonomousDomainExpansionChainOptions(
            executor_report_path=paths["executor_report"],
            output_root=tmp_path / "chain",
            frontier_config_path=paths["frontiers"],
            mode="dry_run",
            created_at=CREATED_AT,
        )
    )

    assert result["valid"], result["issues"]
    executor_counts = result["stages"]["workOrderExecutor"]["recordCounts"]
    assert executor_counts["completedFixtureChecks"] == 0
    assert executor_counts["completedDryRunChecks"] == 2
    assert result["recordCounts"]["completedSafeChecks"] == 2


def test_autonomous_domain_expansion_chain_rejects_private_executor_report_before_stages(tmp_path: Path):
    paths = _fixture_paths(tmp_path)
    report = read_json(paths["executor_report"])
    report["goalText"] = "my schedule for this week"
    write_json(paths["executor_report"], report)

    result = run_autonomous_domain_expansion_chain(
        AutonomousDomainExpansionChainOptions(
            executor_report_path=paths["executor_report"],
            output_root=tmp_path / "chain",
            frontier_config_path=paths["frontiers"],
            created_at=CREATED_AT,
        )
    )

    assert not result["valid"]
    assert result["stages"] == {}
    assert result["recordCounts"]["routes"] == 0
    assert result["recordCounts"]["reviewPackets"] == 0
    assert any("goal_text" in issue or "first_person_private_context" in issue for issue in result["issues"])


def test_autonomous_domain_expansion_chain_requires_candidate_inputs(tmp_path: Path):
    paths = _fixture_paths(tmp_path)
    report = read_json(paths["executor_report"])
    report["artifacts"] = []
    report["actionResults"][0]["artifactPaths"] = []
    write_json(paths["executor_report"], report)

    result = run_autonomous_domain_expansion_chain(
        AutonomousDomainExpansionChainOptions(
            executor_report_path=paths["executor_report"],
            output_root=tmp_path / "chain",
            frontier_config_path=paths["frontiers"],
            created_at=CREATED_AT,
        )
    )

    assert not result["valid"]
    assert "executor report contains no candidate frontier intake inputs" in result["issues"]
    assert result["recordCounts"]["candidateInputs"] == 0
    assert result["stages"] == {}


def _fixture_paths(tmp_path: Path) -> dict[str, Path]:
    root = tmp_path / "fixtures"
    root.mkdir(parents=True, exist_ok=True)
    frontiers = root / "coverage-frontiers.json"
    frontier_input = root / "frontier-intake-input.json"
    executor_report = root / "executor-report.json"
    write_json(frontiers, {"schemaVersion": 1, "kind": "ambitions.sourceAtlas.coverageFrontiers.v1", "frontiers": []})
    write_json(frontier_input, _frontier_intake_input())
    write_json(executor_report, _executor_report(frontier_input))
    return {
        "root": root,
        "frontiers": frontiers,
        "frontier_input": frontier_input,
        "executor_report": executor_report,
    }


def _frontier_intake_input() -> dict:
    return {
        "domainProposals": [
            {
                "proposal_id": "frontier_intake_proposal.public_benefits_reference",
                "frontier_id": "public_benefits_reference",
                "domain": "public_benefits_reference",
                "goal_intent_classes": ["public_benefits_reference"],
                "claim_classes": [
                    "official_benefit_program_reference",
                    "public_eligibility_reference",
                    "public_deadline_reference",
                ],
                "jurisdictions": ["US"],
                "source_classes_required": ["official_government", "official_institution", "public_catalog"],
                "minimum_authority_classes": ["official_government", "official_institution"],
                "freshness_slas": ["30d critical requirements", "90d informational references"],
                "candidate_sources": [
                    {
                        "discovery_method": "executor_seed",
                        "publisher_name": "USA.gov",
                        "publisher_url": "https://www.usa.gov/benefits",
                        "declared_jurisdiction": "US",
                        "declared_license": "",
                        "declared_rights": "",
                        "terms_url": "https://www.usa.gov/about",
                        "rights_url": "",
                        "dataset_url": "https://www.usa.gov/benefits",
                        "distribution_urls": [],
                        "api_docs_url": "",
                        "source_class_guess": "official_government",
                        "authority_class_guess": "official_government",
                        "claim_class_guess": ["official_benefit_program_reference", "public_eligibility_reference"],
                        "redistribution_guess": "terms_sensitive",
                    },
                    {
                        "discovery_method": "executor_seed",
                        "publisher_name": "Data.gov Catalog",
                        "publisher_url": "https://catalog.data.gov/",
                        "declared_jurisdiction": "US",
                        "declared_license": "",
                        "declared_rights": "",
                        "terms_url": "https://www.data.gov/privacy-policy/",
                        "rights_url": "",
                        "dataset_url": "https://catalog.data.gov/dataset",
                        "distribution_urls": [],
                        "api_docs_url": "https://catalog.data.gov/api/3/",
                        "source_class_guess": "public_catalog",
                        "authority_class_guess": "public_catalog",
                        "claim_class_guess": ["official_benefit_program_reference", "public_eligibility_reference"],
                        "redistribution_guess": "terms_sensitive",
                    },
                ],
            }
        ]
    }


def _executor_report(frontier_input: Path) -> dict:
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.autonomousOperationsExecutor.v1",
        "versionID": "source-atlas-autonomous-operations-executor-train-106",
        "createdAt": CREATED_AT,
        "status": "Source Green for gated autonomous operations execution",
        "valid": True,
        "actionResults": [
            {
                "domainID": "public_benefits_reference",
                "nextAction": "define_coverage_frontier",
                "status": "executed_safe",
                "artifactPaths": [str(frontier_input)],
            }
        ],
        "artifacts": [
            {
                "domainID": "public_benefits_reference",
                "kind": "frontier_intake",
                "path": str(frontier_input),
            }
        ],
        "privacyBoundary": "public/reference/freshness only; no private user context",
        "nonClaims": ["not full Source Atlas Green", "not final user plans, schedules, or Steps"],
    }


def _write_finance_public_reference_frontier(path: Path) -> None:
    write_json(
        path,
        {
            "schemaVersion": 1,
            "kind": "ambitions.sourceAtlas.coverageFrontiers.v1",
            "frontiers": [
                {
                    "frontier_id": "finance_public_reference",
                    "domain": "finance_public_reference",
                    "goal_intent_classes": [
                        "financial_education_reference",
                        "benefit_program_reference",
                        "public_benefit_reference",
                        "public_benefits_reference",
                    ],
                    "claim_classes": [
                        "public_financial_education",
                        "official_benefit_program_reference",
                    ],
                    "jurisdictions": ["US"],
                }
            ],
        },
    )


def _write_finance_public_reference_ledger(path: Path) -> None:
    write_json(
        path,
        {
            "schemaVersion": 1,
            "valid": True,
            "domains": [
                {
                    "domainID": "finance_public_reference",
                    "readinessStatus": "bounded_production_target_ready",
                    "allowedClaimScopes": ["bounded_production_target"],
                    "r2ProductionProofComplete": True,
                    "gatewayProofComplete": True,
                    "nativeUsabilityProofComplete": True,
                }
            ],
        },
    )


def _check(result: dict, name: str) -> bool:
    return next(check for check in result["checks"] if check["name"] == name)["passed"]
