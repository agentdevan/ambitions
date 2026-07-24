"""Authority-aware Phase B output pipeline."""

from __future__ import annotations

from dataclasses import replace
from pathlib import Path

from tools.capability_atlas import classified_outputs as base
from tools.capability_atlas.classification_refinement import classify_candidates
from tools.capability_atlas.discover import DiscoveryCompilation
from tools.capability_atlas.model import CandidateRecord, canonical_json


AMBIGUOUS_DIRECTORY = base.AMBIGUOUS_DIRECTORY
CLASSIFICATION_CORE_PATHS = base.CLASSIFICATION_CORE_PATHS
EXCLUSION_DIRECTORY = base.EXCLUSION_DIRECTORY
QUALIFIED_DIRECTORY = base.QUALIFIED_DIRECTORY
output_drift = base.output_drift
write_outputs = base.write_outputs


def _precision_filter(candidate: CandidateRecord) -> CandidateRecord:
    """Reject final scope and unsupported-feature fragments from qualification."""

    if (
        candidate.qualification_status != "qualified"
        or candidate.authority_status == "owner_seed"
    ):
        return candidate
    text = candidate.exact_terminology.strip().strip("# \"'`,").casefold()
    if text.startswith("supported scope"):
        return replace(
            candidate,
            classification="requirement",
            qualification_status="supporting",
            classification_reason_code="scope_statement_not_capability",
            classification_rationale=(
                "The statement defines supported ownership or scope boundaries and must "
                "trace beneath a capability rather than becoming the capability identity."
            ),
            classification_confidence=0.94,
            disposition="preserve_as_supporting_requirement",
        )
    if text.startswith("what ambitions knows") or "unsupported" in text:
        return replace(
            candidate,
            classification="ambiguous",
            qualification_status="ambiguous",
            classification_reason_code="decision_fragment_requires_semantic_reconciliation",
            classification_rationale=(
                "The decision fragment references possible product areas and unsupported "
                "scope without expressing one coherent durable promise."
            ),
            classification_confidence=0.76,
            disposition="preserve_for_manual_capability_reconciliation",
        )
    return candidate


def classify_compilation(compilation: DiscoveryCompilation) -> DiscoveryCompilation:
    """Return the immutable authority-refined Phase B compilation."""

    candidates = tuple(
        _precision_filter(item)
        for item in classify_candidates(compilation.candidates)
    )
    return replace(compilation, candidates=candidates)


def render_outputs(compilation: DiscoveryCompilation) -> dict[Path, str]:
    """Render discovery plus authority-refined classification artifacts."""

    classified = classify_compilation(compilation)
    outputs = base.render_discovery_outputs(classified)
    qualified = [
        item for item in classified.candidates if item.qualification_status == "qualified"
    ]
    supporting = [
        item for item in classified.candidates if item.qualification_status == "supporting"
    ]
    ambiguous = [
        item for item in classified.candidates if item.qualification_status == "ambiguous"
    ]

    qualified_outputs, qualified_manifest = base._render_shards(
        compilation=classified,
        candidates=qualified,
        directory=QUALIFIED_DIRECTORY,
        stem="qualified",
        authority="non_normative_qualified_capability_candidate_shard",
    )
    exclusion_outputs, exclusion_manifest = base._render_shards(
        compilation=classified,
        candidates=supporting,
        directory=EXCLUSION_DIRECTORY,
        stem="excluded",
        authority="non_normative_supporting_record_shard",
    )
    ambiguous_outputs, ambiguous_manifest = base._render_shards(
        compilation=classified,
        candidates=ambiguous,
        directory=AMBIGUOUS_DIRECTORY,
        stem="ambiguous",
        authority="non_normative_ambiguous_candidate_shard",
    )

    outputs.update(qualified_outputs)
    outputs.update(exclusion_outputs)
    outputs.update(ambiguous_outputs)
    outputs[CLASSIFICATION_CORE_PATHS[0]] = canonical_json(
        base._summary_payload(classified)
    )
    outputs[CLASSIFICATION_CORE_PATHS[1]] = canonical_json(
        base._index_payload(
            compilation=classified,
            authority="non_normative_exclusion_register_index",
            candidates=supporting,
            manifest=exclusion_manifest,
        )
    )
    outputs[CLASSIFICATION_CORE_PATHS[2]] = canonical_json(
        base._index_payload(
            compilation=classified,
            authority="non_normative_qualified_capability_index",
            candidates=qualified,
            manifest=qualified_manifest,
        )
    )
    outputs[CLASSIFICATION_CORE_PATHS[3]] = canonical_json(
        base._index_payload(
            compilation=classified,
            authority="non_normative_ambiguous_capability_index",
            candidates=ambiguous,
            manifest=ambiguous_manifest,
        )
    )
    outputs[CLASSIFICATION_CORE_PATHS[4]] = base.render_classification_markdown(
        classified
    )
    return outputs
