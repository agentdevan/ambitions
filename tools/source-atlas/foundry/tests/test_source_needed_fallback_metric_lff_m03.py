from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from foundry.model import write_json  # noqa: E402
from foundry.source_needed_fallback_metric import (  # noqa: E402
    SOURCE_ATLAS_SOURCE_NEEDED_FALLBACK_METRIC_KIND,
    SourceNeededFallbackMetricOptions,
    compile_source_needed_fallback_metric,
)


REPO_ROOT = Path(__file__).resolve().parents[4]
GOLDEN_INTENT_CORPUS_REPORT = REPO_ROOT / "docs" / "qa" / "source-atlas" / "source-atlas-launch-floor-golden-intent-corpus-lff-m03.json"
NORMALIZED_CORPUS = (
    REPO_ROOT
    / "tools"
    / "source-atlas"
    / "generated"
    / "source-atlas-launch-floor-golden-intent-corpus"
    / "lff-m03-l02-current"
    / "launch-floor-golden-intent-corpus.json"
)
CREATED_AT = "2026-07-01T00:00:00Z"


def test_current_lff_m03_corpus_measures_fallback_under_5_percent_and_emits_events(tmp_path: Path):
    result = compile_source_needed_fallback_metric(
        SourceNeededFallbackMetricOptions(
            golden_intent_corpus_report_path=GOLDEN_INTENT_CORPUS_REPORT,
            normalized_corpus_path=NORMALIZED_CORPUS,
            output_root=tmp_path / "fallback-metric",
            created_at=CREATED_AT,
            run_label="current-corpus-test",
        )
    )

    counts = result["recordCounts"]
    assert result["valid"], result["issues"]
    assert result["sourceNeededFallbackUnder5Percent"] is True
    assert result["fallbackRate"] == 200 / 50_000
    assert counts["lawfulGoals"] == 50_000
    assert counts["sourceNeededFallbacks"] == 200
    assert counts["missingShardFallbacks"] == 50
    assert counts["missingFreshnessFallbacks"] == 50
    assert counts["missingDomainFallbacks"] == 50
    assert counts["insufficientSourceFallbacks"] == 50
    assert counts["privateBlockedControlsExcluded"] == 500
    assert counts["illegalOutOfScopeControlsExcluded"] == 500
    assert counts["missingShardEventsEmitted"] == 200
    assert counts["privacyIssues"] == 0
    assert counts["finalOutputsGenerated"] == 0
    assert result["targetStatus"]["privateAndUnlawfulControlsExcluded"] is True
    assert "source_needed_fallback_under_5_percent_met" in result["allowedClaims"]


def test_fallback_metric_fails_closed_without_lawful_denominator(tmp_path: Path):
    paths = _write_fixture_corpus(tmp_path, [])

    result = compile_source_needed_fallback_metric(
        SourceNeededFallbackMetricOptions(
            golden_intent_corpus_report_path=paths["report"],
            normalized_corpus_path=paths["corpus"],
            output_root=tmp_path / "missing-denominator",
            created_at=CREATED_AT,
            run_label="missing-denominator",
        )
    )

    assert result["valid"] is False
    assert result["sourceNeededFallbackUnder5Percent"] is False
    assert result["recordCounts"]["lawfulGoals"] == 0
    assert result["fallbackRate"] is None
    assert "source_needed_fallback_under_5_percent_met" in result["blockedClaims"]
    assert any("lawful-goal denominator is missing or zero" in issue for issue in result["issues"])


def test_fallback_metric_threshold_fail_excludes_private_and_unlawful_controls(tmp_path: Path):
    records = [_record(f"covered-{index}", coverage_label="covered") for index in range(94)]
    records.extend(_record(f"fallback-{index}", coverage_label="source_needed", source_needed_cause="missing_shard") for index in range(6))
    records.append(_record("private-control", coverage_label="private_blocked", lawful=False, counts=False))
    records.append(_record("illegal-control", coverage_label="illegal_out_of_scope", lawful=False, counts=False))
    paths = _write_fixture_corpus(tmp_path, records)

    result = compile_source_needed_fallback_metric(
        SourceNeededFallbackMetricOptions(
            golden_intent_corpus_report_path=paths["report"],
            normalized_corpus_path=paths["corpus"],
            output_root=tmp_path / "threshold-fail",
            created_at=CREATED_AT,
            run_label="threshold-fail",
        )
    )

    assert result["valid"] is True
    assert result["sourceNeededFallbackUnder5Percent"] is False
    assert result["recordCounts"]["lawfulGoals"] == 100
    assert result["recordCounts"]["sourceNeededFallbacks"] == 6
    assert result["fallbackRate"] == 0.06
    assert result["recordCounts"]["privateBlockedControlsExcluded"] == 1
    assert result["recordCounts"]["illegalOutOfScopeControlsExcluded"] == 1
    assert result["allowedClaims"] == []


def test_fallback_metric_regression_compares_previous_metric(tmp_path: Path):
    records = [_record(f"covered-{index}", coverage_label="covered") for index in range(99)]
    records.append(_record("fallback-0", coverage_label="source_needed", source_needed_cause="missing_shard"))
    paths = _write_fixture_corpus(tmp_path, records)
    previous = tmp_path / "previous.json"
    write_json(
        previous,
        {
            "kind": SOURCE_ATLAS_SOURCE_NEEDED_FALLBACK_METRIC_KIND,
            "valid": True,
            "recordCounts": {"sourceNeededFallbacks": 2, "lawfulGoals": 100},
        },
    )

    result = compile_source_needed_fallback_metric(
        SourceNeededFallbackMetricOptions(
            golden_intent_corpus_report_path=paths["report"],
            normalized_corpus_path=paths["corpus"],
            previous_metric_path=previous,
            output_root=tmp_path / "regression",
            created_at=CREATED_AT,
            run_label="regression",
        )
    )

    assert result["regression"]["previousMetricPresent"] is True
    assert result["regression"]["previousRate"] == 0.02
    assert result["regression"]["currentRate"] == 0.01
    assert result["regression"]["delta"] == -0.01
    assert result["regression"]["regressionStatus"] == "improved_or_flat"


def _write_fixture_corpus(tmp_path: Path, records: list[dict]) -> dict[str, Path]:
    corpus = tmp_path / "corpus.json"
    report = tmp_path / "report.json"
    write_json(
        corpus,
        {
            "schemaVersion": 1,
            "kind": "ambitions.sourceAtlas.launchFloorGoldenIntentCorpus.v1",
            "publicReferenceOnly": True,
            "privateContextAllowed": False,
            "finalOutputAllowed": False,
            "intents": records,
        },
    )
    write_json(
        report,
        {
            "schemaVersion": 1,
            "kind": "ambitions.sourceAtlas.launchFloorGoldenIntentCorpusReport.v1",
            "valid": True,
            "evidencePaths": {"normalizedCorpus": str(corpus)},
        },
    )
    return {"corpus": corpus, "report": report}


def _record(
    intent_id: str,
    *,
    coverage_label: str,
    source_needed_cause: str = "not_required",
    lawful: bool = True,
    counts: bool = True,
) -> dict:
    expected_routing_state = "launch_floor_public_reference_supported"
    if coverage_label == "source_needed":
        expected_routing_state = "source_needed"
    if coverage_label == "candidate_only":
        expected_routing_state = "candidate_only"
    if coverage_label == "insufficient_source":
        expected_routing_state = "insufficient_source"
    return {
        "intentID": intent_id,
        "sanitizedIntentClass": f"{intent_id}-class",
        "domainID": "domain",
        "subdomainID": f"domain-{intent_id}",
        "lawfulIntent": lawful,
        "publicReferenceOnly": True,
        "privateContextAllowed": False,
        "finalOutputAllowed": False,
        "expectedRoutingState": expected_routing_state,
        "coverageLabel": coverage_label,
        "sourceNeededCause": source_needed_cause,
        "countsTowardGoldenIntent": counts,
    }
