"""Authority-aware Phase B output pipeline."""

from __future__ import annotations

from dataclasses import replace
from pathlib import Path

from tools.capability_atlas import classified_outputs as base
from tools.capability_atlas.classification_refinement import classify_candidates
from tools.capability_atlas.discover import DiscoveryCompilation
from tools.capability_atlas.model import canonical_json


AMBIGUOUS_DIRECTORY = base.AMBIGUOUS_DIRECTORY
CLASSIFICATION_CORE_PATHS = base.CLASSIFICATION_CORE_PATHS
EXCLUSION_DIRECTORY = base.EXCLUSION_DIRECTORY
QUALIFIED_DIRECTORY = base.QUALIFIED_DIRECTORY
output_drift = base.output_drift
write_outputs = base.write_outputs


def render_outputs(compilation: DiscoveryCompilation) -> dict[Path, str]:
    """Render discovery plus authority-refined classification artifacts."""

    classified = replace(
        compilation,
        candidates=classify_candidates(compilation.candidates),
    )
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
