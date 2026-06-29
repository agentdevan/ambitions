from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from foundry.goal_domain_router import GoalDomainRouterOptions, compile_goal_domain_router
from foundry.model import read_json, write_json


CREATED_AT = "2026-06-28T00:00:00Z"
FIXTURE_PATH = Path("tools/source-atlas/fixtures/goal-domain-router/train-88-goal-domain-requests.json")
LEDGER_PATH = Path("tools/source-atlas/generated/production-target-ledger/train-86/production-target-ledger.json")


def test_goal_domain_router_maps_configured_ready_frontier_and_candidates_new_domains(tmp_path: Path):
    result = _compile_fixture(tmp_path)

    assert result["valid"], result["issues"]
    assert result["status"] == "Source Green for goal-domain routing tooling"
    assert result["sourceAtlasStatusCeiling"] == (
        "Yellow overall Source Atlas; configured-frontier production target routing plus candidate-only intake for new domains"
    )
    assert result["recordCounts"]["requests"] == 3
    assert result["recordCounts"]["productionTargetReadyRoutes"] == 1
    assert result["recordCounts"]["candidateIntakeRoutes"] == 2
    assert result["recordCounts"]["claims"] == 0
    assert result["recordCounts"]["packableClaims"] == 0
    assert result["recordCounts"]["r2PackableArtifacts"] == 0
    assert result["recordCounts"]["r2PublishOperations"] == 0
    assert _check(result, "production_ready_routes_require_ledger_ready_domain")
    assert _check(result, "candidate_routes_emit_candidate_intake_only")
    assert _check(result, "router_emits_no_claims_packs_or_r2_operations")

    routing = read_json(Path(result["outputRoot"]) / "goal-domain-routing.json")
    routes = {route["requestID"]: route for route in routing["routes"]}
    known = routes["known-education-credentialing"]
    assert known["route"] == "configured_production_target_ready"
    assert known["matchedDomainID"] == "education_credentialing"
    assert known["readinessStatus"] == "bounded_production_target_ready"
    assert known["allowedClaimScopes"] == ["bounded_production_target"]
    assert known["candidateIntakeRequired"] is False
    assert known["packOutputAllowed"] is True
    assert known["r2PublishAllowed"] is False
    assert known["nativeUsabilityReady"] is True

    language = routes["new-language-learning-public-reference"]
    assert language["route"] == "candidate_frontier_intake_required"
    assert language["candidateIntakeRequired"] is True
    assert language["packOutputAllowed"] is False
    assert language["r2PublishAllowed"] is False
    assert "candidate_only_frontier_intake_required" in language["blockingReasons"]

    ambiguous = routes["ambiguous-public-program-reference"]
    assert ambiguous["route"] == "candidate_frontier_intake_required"
    assert "ambiguous_frontier_match" in ambiguous["blockingReasons"]


def test_goal_domain_router_generates_candidate_only_frontier_intake_for_unmatched_domains(tmp_path: Path):
    result = _compile_fixture(tmp_path)

    assert result["valid"], result["issues"]
    assert result["candidateIntake"]["required"] is True
    assert result["candidateIntake"]["valid"] is True
    assert result["candidateIntake"]["recordCounts"]["proposals"] == 2
    assert result["candidateIntake"]["recordCounts"]["claims"] == 0
    assert result["candidateIntake"]["recordCounts"]["packableClaims"] == 0
    assert result["candidateIntake"]["recordCounts"]["r2PackableArtifacts"] == 0

    intake_root = Path(result["outputRoot"]) / "frontier-intake"
    proposed = read_json(intake_root / "proposed-frontiers.json")["proposedFrontiers"]
    candidates = read_json(intake_root / "candidate-sources.json")["candidateSourceRecords"]
    assert {frontier["frontier_id"] for frontier in proposed} == {
        "public_language_learning_reference",
        "public_program_reference",
    }
    assert all(frontier["status_ceiling"] == "candidate_only" for frontier in proposed)
    assert all(frontier["pack_output_allowed"] is False for frontier in proposed)
    assert all(candidate["review_required"] is True for candidate in candidates)
    assert all(candidate["claim_authority_allowed"] is False for candidate in candidates)
    assert all(candidate["pack_output_allowed"] is False for candidate in candidates)


def test_goal_domain_router_blocks_private_goal_text_before_routing_or_intake(tmp_path: Path):
    input_path = tmp_path / "private-goal-domain-request.json"
    write_json(
        input_path,
        {
            "goalDomainRequests": [
                {
                    "request_id": "private-language-request",
                    "domain": "public_language_learning_reference",
                    "goal_text": "I need a private plan for my schedule",
                    "claim_classes": ["learning_resource_reference"],
                    "jurisdictions": ["US"],
                    "candidate_sources": [],
                }
            ]
        },
    )

    result = compile_goal_domain_router(
        GoalDomainRouterOptions(
            input_path=input_path,
            output_root=tmp_path / "goal-domain-router",
            production_target_ledger_path=LEDGER_PATH,
            created_at=CREATED_AT,
        )
    )

    assert not result["valid"]
    assert not _check(result, "input_privacy_scan_passed")
    assert result["recordCounts"]["blockedPrivateRoutes"] == 1
    assert result["recordCounts"]["candidateIntakeRoutes"] == 0
    assert result["candidateIntake"]["required"] is False
    assert any("goal_text" in issue or "first_person_private_context" in issue for issue in result["issues"])


def test_goal_domain_router_does_not_mark_configured_domain_ready_without_ledger(tmp_path: Path):
    missing_ledger = tmp_path / "missing-ledger.json"
    result = compile_goal_domain_router(
        GoalDomainRouterOptions(
            input_path=FIXTURE_PATH,
            output_root=tmp_path / "goal-domain-router",
            production_target_ledger_path=missing_ledger,
            created_at=CREATED_AT,
        )
    )

    assert result["valid"], result["issues"]
    routing = read_json(Path(result["outputRoot"]) / "goal-domain-routing.json")
    known = next(route for route in routing["routes"] if route["requestID"] == "known-education-credentialing")
    assert known["route"] == "configured_frontier_not_production_ready"
    assert known["productionTargetReady"] is False
    assert known["candidateIntakeRequired"] is False
    assert "production_target_ledger_domain_not_ready" in known["blockingReasons"]


def test_goal_domain_router_stable_ordering_is_deterministic(tmp_path: Path):
    first = _compile_fixture(tmp_path / "first")
    second = _compile_fixture(tmp_path / "second")

    first_routes = read_json(Path(first["outputRoot"]) / "goal-domain-routing.json")["routes"]
    second_routes = read_json(Path(second["outputRoot"]) / "goal-domain-routing.json")["routes"]
    assert [route["requestID"] for route in first_routes] == [route["requestID"] for route in second_routes]
    assert first_routes == sorted(first_routes, key=lambda item: item["requestID"])


def test_goal_domain_router_does_not_treat_request_self_alias_as_frontier_exact_match(tmp_path: Path):
    input_path = tmp_path / "goal-domain-request.json"
    frontier_path = tmp_path / "coverage-frontiers.json"
    ledger_path = tmp_path / "production-target-ledger.json"
    write_json(
        input_path,
        {
            "goalDomainRequests": [
                {
                    "request_id": "candidate-public-benefits",
                    "domain": "public_benefits_reference",
                    "domain_aliases": ["public_benefits_reference"],
                    "claim_classes": ["official_benefit_program_reference"],
                    "jurisdictions": ["US"],
                    "source_classes_required": ["official_government"],
                    "minimum_authority_classes": ["official_government"],
                    "candidate_sources": [],
                }
            ]
        },
    )
    write_json(
        frontier_path,
        {
            "schemaVersion": 1,
            "frontiers": [
                {
                    "frontier_id": "finance_public_reference",
                    "domain": "finance_public_reference",
                    "goal_intent_classes": ["finance_public_reference"],
                    "claim_classes": ["official_benefit_program_reference"],
                    "jurisdictions": ["US"],
                }
            ],
        },
    )
    write_json(
        ledger_path,
        {
            "schemaVersion": 1,
            "valid": True,
            "domains": [
                {
                    "domainID": "finance_public_reference",
                    "readinessStatus": "bounded_production_target_ready",
                    "nativeUsabilityProofComplete": True,
                }
            ],
        },
    )

    result = compile_goal_domain_router(
        GoalDomainRouterOptions(
            input_path=input_path,
            output_root=tmp_path / "goal-domain-router",
            frontier_config_path=frontier_path,
            production_target_ledger_path=ledger_path,
            created_at=CREATED_AT,
        )
    )

    assert result["valid"], result["issues"]
    routing = read_json(Path(result["outputRoot"]) / "goal-domain-routing.json")
    route = routing["routes"][0]
    assert route["route"] == "candidate_frontier_intake_required"
    assert route["matchedDomainID"] is None
    assert "no_configured_frontier_match" in route["blockingReasons"]


def test_goal_domain_router_routes_public_benefits_alias_to_finance_production_target(tmp_path: Path):
    input_path = tmp_path / "goal-domain-request.json"
    frontier_path = tmp_path / "coverage-frontiers.json"
    ledger_path = tmp_path / "production-target-ledger.json"
    write_json(
        input_path,
        {
            "goalDomainRequests": [
                {
                    "request_id": "public-benefits-reference",
                    "domain": "public_benefits_reference",
                    "domain_aliases": ["public_benefits_reference"],
                    "goal_intent_classes": ["public_benefits_reference"],
                    "claim_classes": ["official_benefit_program_reference"],
                    "jurisdictions": ["US"],
                    "source_classes_required": ["official_government"],
                    "minimum_authority_classes": ["official_government"],
                    "candidate_sources": [],
                }
            ]
        },
    )
    write_json(
        frontier_path,
        {
            "schemaVersion": 1,
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
                    "claim_classes": ["public_financial_education", "official_benefit_program_reference"],
                    "jurisdictions": ["US"],
                }
            ],
        },
    )
    write_json(
        ledger_path,
        {
            "schemaVersion": 1,
            "valid": True,
            "domains": [
                {
                    "domainID": "finance_public_reference",
                    "readinessStatus": "bounded_production_target_ready",
                    "allowedClaimScopes": ["bounded_production_target"],
                    "nativeUsabilityProofComplete": True,
                }
            ],
        },
    )

    result = compile_goal_domain_router(
        GoalDomainRouterOptions(
            input_path=input_path,
            output_root=tmp_path / "goal-domain-router",
            frontier_config_path=frontier_path,
            production_target_ledger_path=ledger_path,
            created_at=CREATED_AT,
        )
    )

    assert result["valid"], result["issues"]
    assert result["recordCounts"]["productionTargetReadyRoutes"] == 1
    assert result["recordCounts"]["candidateIntakeRoutes"] == 0
    routing = read_json(Path(result["outputRoot"]) / "goal-domain-routing.json")
    route = routing["routes"][0]
    assert route["route"] == "configured_production_target_ready"
    assert route["matchedDomainID"] == "finance_public_reference"
    assert route["productionTargetReady"] is True
    assert route["packOutputAllowed"] is True
    assert route["r2PublishAllowed"] is False
    assert "goal_intent_overlap" in route["matchReasons"]


def _compile_fixture(tmp_path: Path) -> dict[str, object]:
    return compile_goal_domain_router(
        GoalDomainRouterOptions(
            input_path=FIXTURE_PATH,
            output_root=tmp_path / "goal-domain-router",
            production_target_ledger_path=LEDGER_PATH,
            created_at=CREATED_AT,
        )
    )


def _check(result: dict[str, object], name: str) -> bool:
    return next(check for check in result["checks"] if check["name"] == name)["passed"]
