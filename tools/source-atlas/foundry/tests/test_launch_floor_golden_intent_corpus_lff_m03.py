from __future__ import annotations

import copy
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from foundry.launch_floor_golden_intent_corpus import (  # noqa: E402
    SOURCE_ATLAS_LAUNCH_FLOOR_GOLDEN_INTENT_CORPUS_KIND,
    LaunchFloorGoldenIntentCorpusOptions,
    compile_launch_floor_golden_intent_corpus,
    launch_floor_golden_intent_corpus_summary,
)
from foundry.model import read_json, write_json  # noqa: E402


REPO_ROOT = Path(__file__).resolve().parents[4]
GOAL_DOMAIN_GAUNTLET = REPO_ROOT / "docs" / "qa" / "source-atlas" / "source-atlas-goal-domain-gauntlet-train-131.json"
LAUNCH_FLOOR_TAXONOMY = REPO_ROOT / "tools" / "source-atlas" / "frontier" / "launch-floor-domain-taxonomy.json"
SOURCE_LANE_REGISTRY = REPO_ROOT / "tools" / "source-atlas" / "governance" / "source-lane-registry.json"
PRODUCTION_TARGET_LEDGER = (
    REPO_ROOT
    / "tools"
    / "source-atlas"
    / "generated"
    / "production-target-ledger"
    / "train-131-tetradeca-current"
    / "production-target-ledger.json"
)
CREATED_AT = "2026-07-01T00:00:00Z"


def test_current_goal_domain_gauntlet_imports_as_small_valid_golden_intent_seed(tmp_path: Path):
    gauntlet = read_json(GOAL_DOMAIN_GAUNTLET)
    expected_records = sum(
        len(case.get("intentClasses", []))
        for case in gauntlet.get("configuredCases", [])
        if isinstance(case, dict)
    ) + len(gauntlet.get("unknownCases", []))

    result = compile_launch_floor_golden_intent_corpus(
        LaunchFloorGoldenIntentCorpusOptions(
            input_paths=(GOAL_DOMAIN_GAUNTLET,),
            input_format="goal-domain-gauntlet",
            output_root=tmp_path / "golden-intents",
            created_at=CREATED_AT,
            run_label="current-gauntlet-test",
        )
    )

    assert result["valid"], result["issues"]
    assert result["recordCounts"]["intentRecords"] == expected_records
    assert result["recordCounts"]["goldenIntentCount"] == expected_records
    assert result["recordCounts"]["adjudicatedIntentCount"] == expected_records
    assert result["recordCounts"]["candidateOnlyCount"] == len(gauntlet.get("unknownCases", []))
    assert result["launchFloorGoldenIntentTargetMet"] is False
    assert result["targetStatus"]["goldenIntents50000"] is False
    assert "golden_intent_corpus_counter_measurable" in result["allowedClaims"]
    assert "launch_floor_golden_intents_50000_met" in result["blockedClaims"]
    assert "final_user_plans_schedules_steps_from_source_atlas_or_r2" in result["blockedClaims"]


def test_launch_floor_golden_intent_summary_accepts_50k_adjudicated_public_records():
    summary = launch_floor_golden_intent_corpus_summary(
        {
            "schemaVersion": 1,
            "kind": SOURCE_ATLAS_LAUNCH_FLOOR_GOLDEN_INTENT_CORPUS_KIND,
            "versionID": "synthetic-50k-contract",
            "createdAt": CREATED_AT,
            "publicReferenceOnly": True,
            "privateContextAllowed": False,
            "finalOutputAllowed": False,
            "intents": list(_records_50k()),
            "nonClaims": ["not final user plans, schedules, or Steps"],
        }
    )

    assert summary["issues"] == []
    assert summary["recordCounts"]["goldenIntentCount"] == 50_000
    assert summary["recordCounts"]["domainCount"] == 500
    assert summary["recordCounts"]["subdomainCount"] == 5_000
    assert summary["recordCounts"]["adjudicatedIntentCount"] == 50_000
    assert summary["launchFloorTargets"]["goldenIntents50000"] is True
    assert summary["launchFloorTargets"]["domainCoverage500"] is True
    assert summary["launchFloorTargets"]["subdomainCoverage5000"] is True
    assert summary["launchFloorTargets"]["adjudicationComplete"] is True


def test_launch_floor_taxonomy_import_generates_balanced_50k_adjudicated_corpus(tmp_path: Path):
    result = compile_launch_floor_golden_intent_corpus(
        LaunchFloorGoldenIntentCorpusOptions(
            input_paths=(LAUNCH_FLOOR_TAXONOMY,),
            input_format="launch-floor-taxonomy",
            output_root=tmp_path / "taxonomy-golden-intents",
            created_at=CREATED_AT,
            run_label="taxonomy-balanced-test",
            source_lane_registry_path=SOURCE_LANE_REGISTRY,
            production_target_ledger_path=PRODUCTION_TARGET_LEDGER,
        )
    )

    counts = result["recordCounts"]
    assert result["valid"], result["issues"]
    assert result["launchFloorGoldenIntentTargetMet"] is True
    assert counts["goldenIntentCount"] == 50_000
    assert counts["intentRecords"] == 51_000
    assert counts["adjudicatedIntentCount"] == 51_000
    assert counts["lawfulIntentCount"] == 50_000
    assert counts["domainCount"] == 500
    assert counts["subdomainCount"] == 5_000
    assert counts["coveredCount"] == 49_800
    assert counts["sourceNeededCount"] == 50
    assert counts["staleSourceCount"] == 50
    assert counts["candidateOnlyCount"] == 50
    assert counts["insufficientSourceCount"] == 50
    assert counts["privateBlockedCount"] == 500
    assert counts["illegalOutOfScopeCount"] == 500
    assert counts["excludedControlRecords"] == 1_000
    assert counts["publicIntentTextCount"] == 0
    assert counts["sanitizedClassOnlyCount"] == 51_000
    assert counts["privacyIssues"] == 0
    assert counts["finalOutputsGenerated"] == 0
    assert result["targetStatus"]["goldenIntents50000"] is True
    assert result["targetStatus"]["domainCoverage500"] is True
    assert result["targetStatus"]["subdomainCoverage5000"] is True
    assert result["targetStatus"]["adjudicationComplete"] is True
    assert "launch_floor_golden_intents_50000_met" in result["allowedClaims"]
    assert result["sourceSummaries"][0]["samplingContract"]["countedRecords"] == 50_000
    assert result["sourceSummaries"][0]["samplingContract"]["excludedControlRecords"] == 1_000


def test_private_looking_public_intent_text_is_rejected(tmp_path: Path):
    corpus = _corpus([_record("intent.private", public_text="I want to upload my private schedule")])
    path = tmp_path / "private-looking-corpus.json"
    write_json(path, corpus)

    result = compile_launch_floor_golden_intent_corpus(
        LaunchFloorGoldenIntentCorpusOptions(
            input_paths=(path,),
            output_root=tmp_path / "proof",
            created_at=CREATED_AT,
            run_label="private-negative",
        )
    )

    assert result["valid"] is False
    assert result["allowedClaims"] == []
    assert any("first_person_private_context" in issue for issue in result["privacyIssues"])


def test_missing_adjudication_provenance_is_rejected():
    record = _record("intent.no-adjudication")
    del record["adjudication"]
    summary = launch_floor_golden_intent_corpus_summary(_corpus([record]))

    assert summary["launchFloorTargets"]["adjudicationComplete"] is False
    assert any("missing required field adjudication" in issue for issue in summary["issues"])


def test_source_needed_records_must_name_non_default_cause():
    record = _record("intent.bad-source-needed")
    record["expectedRoutingState"] = "source_needed"
    record["coverageLabel"] = "source_needed"
    record["sourceNeededCause"] = "not_required"

    summary = launch_floor_golden_intent_corpus_summary(_corpus([record]))

    assert any("source-needed coverage must name a sourceNeededCause" in issue for issue in summary["issues"])


def test_negative_control_records_do_not_count_toward_golden_intents():
    private_blocked = _record("intent.private-blocked")
    private_blocked["coverageLabel"] = "private_blocked"
    private_blocked["expectedRoutingState"] = "private_blocked"
    private_blocked["lawfulIntent"] = False
    private_blocked["countsTowardGoldenIntent"] = False

    summary = launch_floor_golden_intent_corpus_summary(_corpus([_record("intent.counted"), private_blocked]))

    assert summary["issues"] == []
    assert summary["recordCounts"]["intentRecords"] == 2
    assert summary["recordCounts"]["goldenIntentCount"] == 1
    assert summary["recordCounts"]["privateBlockedCount"] == 1


def _records_50k():
    index = 0
    for domain_index in range(500):
        domain_id = f"domain_{domain_index:03d}"
        for subdomain_index in range(10):
            subdomain_id = f"{domain_id}__subdomain_{subdomain_index:02d}"
            for intent_index in range(10):
                yield _record(
                    f"intent.{index:05d}",
                    domain_id=domain_id,
                    subdomain_id=subdomain_id,
                    public_text=(
                        f"Public reference objective {domain_index:03d} "
                        f"{subdomain_index:02d} {intent_index:02d}"
                    ),
                )
                index += 1


def _corpus(records: list[dict]) -> dict:
    return {
        "schemaVersion": 1,
        "kind": SOURCE_ATLAS_LAUNCH_FLOOR_GOLDEN_INTENT_CORPUS_KIND,
        "versionID": "test-golden-intent-corpus",
        "createdAt": CREATED_AT,
        "publicReferenceOnly": True,
        "privateContextAllowed": False,
        "finalOutputAllowed": False,
        "intents": records,
        "nonClaims": ["not final user plans, schedules, or Steps"],
    }


def _record(
    intent_id: str,
    *,
    domain_id: str = "public_reference_domain",
    subdomain_id: str = "public_reference_domain__requirements",
    public_text: str = "Public reference objective",
) -> dict:
    record = {
        "intentID": intent_id,
        "publicIntentText": public_text,
        "domainID": domain_id,
        "subdomainID": subdomain_id,
        "lawfulIntent": True,
        "publicReferenceOnly": True,
        "privateContextAllowed": False,
        "finalOutputAllowed": False,
        "expectedRoutingState": "launch_floor_public_reference_supported",
        "coverageLabel": "covered",
        "sourceNeededCause": "not_required",
        "countsTowardGoldenIntent": True,
        "sourceRefs": ["synthetic.public.reference"],
        "jurisdictions": ["public"],
        "adjudication": {
            "adjudicationID": f"adjudication.{intent_id}",
            "status": "adjudicated",
            "reviewerType": "deterministic_rule",
            "ruleID": "test-public-reference-rule",
            "adjudicatedAt": CREATED_AT,
            "sourceArtifact": "test",
            "evidenceHash": "a" * 64,
        },
    }
    return copy.deepcopy(record)
