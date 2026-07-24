"""Phase B classified projections for the Capability Atlas program."""

from __future__ import annotations

import hashlib
from collections import Counter
from dataclasses import replace
from pathlib import Path
from typing import Mapping, Sequence, TypeVar

from tools.capability_atlas.classification import classify_candidates
from tools.capability_atlas.discover import DiscoveryCompilation
from tools.capability_atlas.model import CandidateRecord, canonical_json
from tools.capability_atlas.outputs import render_outputs as render_discovery_outputs


CLASSIFICATION_CORE_PATHS = (
    Path("docs/capabilities/classification-summary.json"),
    Path("docs/capabilities/exclusion-register.json"),
    Path("docs/capabilities/qualified-capability-candidates.json"),
    Path("docs/capabilities/ambiguous-capability-candidates.json"),
    Path("docs/capabilities/CLASSIFIED_CAPABILITY_INVENTORY.md"),
)
EXCLUSION_DIRECTORY = Path("docs/capabilities/exclusions")
QUALIFIED_DIRECTORY = Path("docs/capabilities/qualified")
AMBIGUOUS_DIRECTORY = Path("docs/capabilities/ambiguous")
CLASSIFICATION_DIRECTORIES = (
    EXCLUSION_DIRECTORY,
    QUALIFIED_DIRECTORY,
    AMBIGUOUS_DIRECTORY,
)
CLASSIFICATION_SHARD_SIZE = 500

T = TypeVar("T")


def _chunks(items: Sequence[T], size: int) -> list[Sequence[T]]:
    return [items[start : start + size] for start in range(0, len(items), size)]


def _sha256_text(content: str) -> str:
    return hashlib.sha256(content.encode("utf-8")).hexdigest()


def _compact_record(candidate: CandidateRecord) -> dict[str, object]:
    evidence = candidate.evidence[0]
    record: dict[str, object] = {
        "authority_status": candidate.authority_status,
        "candidate_id": candidate.candidate_id,
        "classification": candidate.classification,
        "classification_confidence": candidate.classification_confidence,
        "classification_rationale": candidate.classification_rationale,
        "classification_reason_code": candidate.classification_reason_code,
        "disposition": candidate.disposition,
        "exact_terminology": candidate.exact_terminology,
        "normalized_name_hint": candidate.normalized_name_hint,
        "qualification_status": candidate.qualification_status,
        "source": {
            "authority_class": evidence.authority_class,
            "end_line": evidence.end_line,
            "evidence_fingerprint": evidence.evidence_fingerprint,
            "extraction_kind": evidence.extraction_kind,
            "family_id": evidence.family_id,
            "path": evidence.source_path,
            "start_line": evidence.start_line,
        },
    }
    if candidate.owner_seed_id is not None:
        record["owner_seed_id"] = candidate.owner_seed_id
    if candidate.note is not None:
        record["note"] = candidate.note
    return record


def _sort_candidates(candidates: Sequence[CandidateRecord]) -> list[CandidateRecord]:
    return sorted(
        candidates,
        key=lambda item: (
            item.classification,
            item.normalized_name_hint.casefold(),
            item.candidate_id,
        ),
    )


def _render_shards(
    *,
    compilation: DiscoveryCompilation,
    candidates: Sequence[CandidateRecord],
    directory: Path,
    stem: str,
    authority: str,
) -> tuple[dict[Path, str], list[dict[str, object]]]:
    outputs: dict[Path, str] = {}
    manifest: list[dict[str, object]] = []
    ordered = _sort_candidates(candidates)
    for index, chunk in enumerate(_chunks(ordered, CLASSIFICATION_SHARD_SIZE), start=1):
        path = directory / f"{stem}-{index:04d}.json"
        classification_counts = Counter(item.classification for item in chunk)
        reason_counts = Counter(item.classification_reason_code for item in chunk)
        payload = {
            "authority": authority,
            "baseline_ref": compilation.baseline_ref,
            "candidate_count": len(chunk),
            "candidates": [_compact_record(item) for item in chunk],
            "classification_counts": dict(sorted(classification_counts.items())),
            "reason_counts": dict(sorted(reason_counts.items())),
            "repository": compilation.repository,
            "schema_version": 1,
            "shard_index": index,
        }
        content = canonical_json(payload)
        outputs[path] = content
        manifest.append(
            {
                "candidate_count": len(chunk),
                "classification_counts": dict(sorted(classification_counts.items())),
                "path": path.as_posix(),
                "reason_counts": dict(sorted(reason_counts.items())),
                "sha256": _sha256_text(content),
                "shard_index": index,
            }
        )
    return outputs, manifest


def _index_payload(
    *,
    compilation: DiscoveryCompilation,
    authority: str,
    candidates: Sequence[CandidateRecord],
    manifest: list[dict[str, object]],
) -> dict[str, object]:
    classification_counts = Counter(item.classification for item in candidates)
    reason_counts = Counter(item.classification_reason_code for item in candidates)
    return {
        "authority": authority,
        "baseline_ref": compilation.baseline_ref,
        "candidate_count": len(candidates),
        "classification_counts": dict(sorted(classification_counts.items())),
        "reason_counts": dict(sorted(reason_counts.items())),
        "repository": compilation.repository,
        "schema_version": 1,
        "shards": manifest,
    }


def _summary_payload(compilation: DiscoveryCompilation) -> dict[str, object]:
    qualification_counts = Counter(
        item.qualification_status for item in compilation.candidates
    )
    classification_counts = Counter(item.classification for item in compilation.candidates)
    reason_counts = Counter(
        item.classification_reason_code for item in compilation.candidates
    )
    source_family_counts: dict[str, Counter[str]] = {}
    for item in compilation.candidates:
        family_id = item.evidence[0].family_id
        source_family_counts.setdefault(family_id, Counter())[item.qualification_status] += 1
    return {
        "authority": "non_normative_phase_b_classification_summary",
        "baseline_ref": compilation.baseline_ref,
        "classification_counts": dict(sorted(classification_counts.items())),
        "classification_method": "deterministic_rule_based_preserving_uncertainty",
        "qualification_counts": dict(sorted(qualification_counts.items())),
        "reason_counts": dict(sorted(reason_counts.items())),
        "repository": compilation.repository,
        "schema_version": 1,
        "source_family_qualification_counts": {
            family_id: dict(sorted(counts.items()))
            for family_id, counts in sorted(source_family_counts.items())
        },
        "total_candidates": len(compilation.candidates),
    }


def _sample_by_classification(
    candidates: Sequence[CandidateRecord],
    limit: int = 8,
) -> dict[str, list[CandidateRecord]]:
    samples: dict[str, list[CandidateRecord]] = {}
    for item in _sort_candidates(candidates):
        bucket = samples.setdefault(item.classification, [])
        if len(bucket) < limit:
            bucket.append(item)
    return samples


def render_classification_markdown(compilation: DiscoveryCompilation) -> str:
    qualification_counts = Counter(
        item.qualification_status for item in compilation.candidates
    )
    classification_counts = Counter(item.classification for item in compilation.candidates)
    samples = _sample_by_classification(compilation.candidates)
    lines = [
        "# Classified Candidate Capability Inventory",
        "",
        "> Non-normative Phase B output. Classification separates likely capabilities",
        "> from requirements, behaviors, objects, surfaces, systems, implementation,",
        "> design expression, projects, and evidence. It does not canonize anything.",
        "",
        "## Result",
        "",
        f"- Qualified capability candidates: **{qualification_counts.get('qualified', 0)}**",
        f"- Supporting non-capability records: **{qualification_counts.get('supporting', 0)}**",
        f"- Ambiguous records preserved for reconciliation: **{qualification_counts.get('ambiguous', 0)}**",
        f"- Total classified records: **{len(compilation.candidates)}**",
        "",
        "## Classification counts",
        "",
        "| Classification | Count |",
        "|---|---:|",
    ]
    for classification, count in sorted(classification_counts.items()):
        lines.append(f"| `{classification}` | {count} |")

    lines.extend(["", "## Representative records", ""])
    for classification in sorted(samples):
        lines.extend([f"### {classification}", ""])
        for item in samples[classification]:
            evidence = item.evidence[0]
            lines.append(
                f"- **{item.normalized_name_hint}** — `{item.classification_reason_code}` — "
                f"`{evidence.source_path}:{evidence.start_line}`"
            )
        lines.append("")

    lines.extend(
        [
            "## Interpretation",
            "",
            "Qualified candidates proceed to taxonomy and reconciliation. Supporting records",
            "remain traceable as evidence or product-genome links. Ambiguous records remain",
            "preserved and cannot be silently discarded or promoted.",
            "",
        ]
    )
    return "\n".join(lines)


def render_outputs(compilation: DiscoveryCompilation) -> dict[Path, str]:
    classified = replace(
        compilation,
        candidates=classify_candidates(compilation.candidates),
    )
    outputs = render_discovery_outputs(classified)
    qualified = [
        item for item in classified.candidates if item.qualification_status == "qualified"
    ]
    supporting = [
        item for item in classified.candidates if item.qualification_status == "supporting"
    ]
    ambiguous = [
        item for item in classified.candidates if item.qualification_status == "ambiguous"
    ]

    qualified_outputs, qualified_manifest = _render_shards(
        compilation=classified,
        candidates=qualified,
        directory=QUALIFIED_DIRECTORY,
        stem="qualified",
        authority="non_normative_qualified_capability_candidate_shard",
    )
    exclusion_outputs, exclusion_manifest = _render_shards(
        compilation=classified,
        candidates=supporting,
        directory=EXCLUSION_DIRECTORY,
        stem="excluded",
        authority="non_normative_supporting_record_shard",
    )
    ambiguous_outputs, ambiguous_manifest = _render_shards(
        compilation=classified,
        candidates=ambiguous,
        directory=AMBIGUOUS_DIRECTORY,
        stem="ambiguous",
        authority="non_normative_ambiguous_candidate_shard",
    )

    outputs.update(qualified_outputs)
    outputs.update(exclusion_outputs)
    outputs.update(ambiguous_outputs)
    outputs[CLASSIFICATION_CORE_PATHS[0]] = canonical_json(_summary_payload(classified))
    outputs[CLASSIFICATION_CORE_PATHS[1]] = canonical_json(
        _index_payload(
            compilation=classified,
            authority="non_normative_exclusion_register_index",
            candidates=supporting,
            manifest=exclusion_manifest,
        )
    )
    outputs[CLASSIFICATION_CORE_PATHS[2]] = canonical_json(
        _index_payload(
            compilation=classified,
            authority="non_normative_qualified_capability_index",
            candidates=qualified,
            manifest=qualified_manifest,
        )
    )
    outputs[CLASSIFICATION_CORE_PATHS[3]] = canonical_json(
        _index_payload(
            compilation=classified,
            authority="non_normative_ambiguous_capability_index",
            candidates=ambiguous,
            manifest=ambiguous_manifest,
        )
    )
    outputs[CLASSIFICATION_CORE_PATHS[4]] = render_classification_markdown(classified)
    return outputs


def _existing_generated_paths(repository_root: Path) -> set[Path]:
    existing: set[Path] = set()
    for directory in (
        Path("docs/capabilities/candidates"),
        Path("docs/capabilities/sources"),
        *CLASSIFICATION_DIRECTORIES,
    ):
        absolute = repository_root / directory
        if not absolute.exists():
            continue
        for path in absolute.glob("*.json"):
            if path.is_file():
                existing.add(path.relative_to(repository_root))
    return existing


def output_drift(repository_root: Path, outputs: Mapping[Path, str]) -> tuple[Path, ...]:
    drift: set[Path] = set(_existing_generated_paths(repository_root) - set(outputs))
    for relative_path, expected in outputs.items():
        absolute_path = repository_root / relative_path
        try:
            actual = absolute_path.read_text(encoding="utf-8")
        except (OSError, UnicodeDecodeError):
            drift.add(relative_path)
            continue
        if actual != expected:
            drift.add(relative_path)
    return tuple(sorted(drift, key=lambda item: item.as_posix()))


def write_outputs(repository_root: Path, outputs: Mapping[Path, str]) -> None:
    stale = _existing_generated_paths(repository_root) - set(outputs)
    for relative_path in sorted(stale, key=lambda item: item.as_posix()):
        (repository_root / relative_path).unlink()
    for relative_path, content in sorted(
        outputs.items(),
        key=lambda item: item[0].as_posix(),
    ):
        absolute_path = repository_root / relative_path
        absolute_path.parent.mkdir(parents=True, exist_ok=True)
        absolute_path.write_text(content, encoding="utf-8")
