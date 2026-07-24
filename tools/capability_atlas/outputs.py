"""Sharded deterministic outputs for capability discovery."""

from __future__ import annotations

import hashlib
from collections import Counter
from pathlib import Path
from typing import Iterable, Mapping, Sequence, TypeVar

from tools.capability_atlas.discover import DiscoveryCompilation
from tools.capability_atlas.model import CandidateRecord, SourceFile, canonical_json


CORE_OUTPUT_PATHS = (
    Path("docs/capabilities/candidate-capabilities.json"),
    Path("docs/capabilities/CANDIDATE_CAPABILITY_INVENTORY.md"),
    Path("docs/capabilities/discovery-coverage.json"),
    Path("docs/capabilities/discovery-sources.json"),
)
CANDIDATE_SHARD_DIRECTORY = Path("docs/capabilities/candidates")
SOURCE_SHARD_DIRECTORY = Path("docs/capabilities/sources")
CANDIDATE_SHARD_SIZE = 500
SOURCE_SHARD_SIZE = 1500

T = TypeVar("T")


def _chunks(items: Sequence[T], size: int) -> Iterable[Sequence[T]]:
    for start in range(0, len(items), size):
        yield items[start : start + size]


def _sha256_text(content: str) -> str:
    return hashlib.sha256(content.encode("utf-8")).hexdigest()


def _candidate_family(candidate: CandidateRecord) -> str:
    if not candidate.evidence:
        return "SRC-UNKNOWN"
    return candidate.evidence[0].family_id


def _render_candidate_shards(
    compilation: DiscoveryCompilation,
) -> tuple[dict[Path, str], list[dict[str, object]]]:
    candidates = [
        item
        for item in compilation.candidates
        if item.authority_status == "repository_candidate"
    ]
    candidates.sort(
        key=lambda item: (
            _candidate_family(item),
            item.normalized_name_hint.casefold(),
            item.candidate_id,
        )
    )
    outputs: dict[Path, str] = {}
    manifest: list[dict[str, object]] = []
    for index, chunk in enumerate(_chunks(candidates, CANDIDATE_SHARD_SIZE), start=1):
        path = CANDIDATE_SHARD_DIRECTORY / f"repository-{index:04d}.json"
        family_counts = Counter(_candidate_family(item) for item in chunk)
        payload = {
            "authority": "non_normative_repository_candidate_shard",
            "baseline_ref": compilation.baseline_ref,
            "candidate_count": len(chunk),
            "candidates": [item.as_record() for item in chunk],
            "family_counts": dict(sorted(family_counts.items())),
            "repository": compilation.repository,
            "schema_version": 1,
            "shard_index": index,
        }
        content = canonical_json(payload)
        outputs[path] = content
        manifest.append(
            {
                "candidate_count": len(chunk),
                "family_counts": dict(sorted(family_counts.items())),
                "path": path.as_posix(),
                "sha256": _sha256_text(content),
                "shard_index": index,
            }
        )
    return outputs, manifest


def _render_source_shards(
    compilation: DiscoveryCompilation,
) -> tuple[dict[Path, str], list[dict[str, object]]]:
    source_files = sorted(
        compilation.source_files,
        key=lambda item: (item.family_id, item.path),
    )
    outputs: dict[Path, str] = {}
    manifest: list[dict[str, object]] = []
    for index, chunk in enumerate(_chunks(source_files, SOURCE_SHARD_SIZE), start=1):
        family_counts = Counter(item.family_id for item in chunk)
        path = SOURCE_SHARD_DIRECTORY / f"source-files-{index:04d}.json"
        payload = {
            "authority": "non_normative_source_fingerprint_shard",
            "baseline_ref": compilation.baseline_ref,
            "family_counts": dict(sorted(family_counts.items())),
            "repository": compilation.repository,
            "schema_version": 1,
            "shard_index": index,
            "source_file_count": len(chunk),
            "source_files": [item.as_record() for item in chunk],
        }
        content = canonical_json(payload)
        outputs[path] = content
        manifest.append(
            {
                "family_counts": dict(sorted(family_counts.items())),
                "path": path.as_posix(),
                "sha256": _sha256_text(content),
                "shard_index": index,
                "source_file_count": len(chunk),
            }
        )
    return outputs, manifest


def _candidate_index_payload(
    compilation: DiscoveryCompilation,
    candidate_manifest: list[dict[str, object]],
) -> dict[str, object]:
    owner_seeds = [
        item.as_record()
        for item in compilation.candidates
        if item.authority_status == "owner_seed"
    ]
    family_counts = Counter(
        _candidate_family(item)
        for item in compilation.candidates
        if item.authority_status == "repository_candidate"
    )
    repository_candidate_count = sum(family_counts.values())
    return {
        "authority": "non_normative_discovery_inventory_index",
        "baseline_ref": compilation.baseline_ref,
        "counts": {
            "owner_seed_candidates": len(owner_seeds),
            "repository_candidates": repository_candidate_count,
            "total_candidates": len(owner_seeds) + repository_candidate_count,
        },
        "owner_seed_candidates": owner_seeds,
        "repository": compilation.repository,
        "repository_candidate_family_counts": dict(sorted(family_counts.items())),
        "repository_candidate_shards": candidate_manifest,
        "schema_version": 2,
    }


def _source_index_payload(
    compilation: DiscoveryCompilation,
    source_manifest: list[dict[str, object]],
) -> dict[str, object]:
    family_counts = Counter(item.family_id for item in compilation.source_files)
    return {
        "authority": "non_normative_source_fingerprint_index",
        "baseline_ref": compilation.baseline_ref,
        "repository": compilation.repository,
        "schema_version": 2,
        "source_family_counts": dict(sorted(family_counts.items())),
        "source_file_count": len(compilation.source_files),
        "source_file_shards": source_manifest,
    }


def _coverage_payload(
    compilation: DiscoveryCompilation,
    candidate_manifest: list[dict[str, object]],
    source_manifest: list[dict[str, object]],
) -> dict[str, object]:
    candidate_paths_by_family: dict[str, list[str]] = {}
    for shard in candidate_manifest:
        family_counts = shard["family_counts"]
        assert isinstance(family_counts, dict)
        for family_id in family_counts:
            candidate_paths_by_family.setdefault(family_id, []).append(str(shard["path"]))
    source_paths_by_family: dict[str, list[str]] = {}
    for shard in source_manifest:
        family_counts = shard["family_counts"]
        assert isinstance(family_counts, dict)
        for family_id in family_counts:
            source_paths_by_family.setdefault(family_id, []).append(str(shard["path"]))

    statuses = Counter(item.status for item in compilation.coverage)
    families: list[dict[str, object]] = []
    for item in compilation.coverage:
        record: dict[str, object] = {
            "blocker_count": len(item.blockers),
            "blockers": list(item.blockers),
            "candidate_shards": candidate_paths_by_family.get(item.family_id, []),
            "extracted_candidate_count": item.extracted_candidate_count,
            "family_id": item.family_id,
            "matched_path_count": len(item.matched_paths),
            "source_inventory_shards": source_paths_by_family.get(item.family_id, []),
            "status": item.status,
        }
        if item.note is not None:
            record["note"] = item.note
        families.append(record)
    return {
        "authority": "non_normative_discovery_coverage",
        "baseline_ref": compilation.baseline_ref,
        "coverage_summary": dict(sorted(statuses.items())),
        "repository": compilation.repository,
        "schema_version": 2,
        "source_families": families,
    }


def _candidate_samples(
    compilation: DiscoveryCompilation,
) -> dict[str, list[CandidateRecord]]:
    samples: dict[str, list[CandidateRecord]] = {}
    repository_candidates = [
        item
        for item in compilation.candidates
        if item.authority_status == "repository_candidate"
    ]
    repository_candidates.sort(
        key=lambda item: (
            _candidate_family(item),
            item.normalized_name_hint.casefold(),
            item.candidate_id,
        )
    )
    for item in repository_candidates:
        family_samples = samples.setdefault(_candidate_family(item), [])
        if len(family_samples) < 12:
            family_samples.append(item)
    return samples


def render_inventory_markdown(
    compilation: DiscoveryCompilation,
    candidate_manifest: list[dict[str, object]],
    source_manifest: list[dict[str, object]],
) -> str:
    owner_seeds = [
        item for item in compilation.candidates if item.authority_status == "owner_seed"
    ]
    family_candidate_counts = Counter(
        _candidate_family(item)
        for item in compilation.candidates
        if item.authority_status == "repository_candidate"
    )
    family_source_counts = Counter(item.family_id for item in compilation.source_files)
    samples = _candidate_samples(compilation)
    lines = [
        "# Candidate Capability Inventory",
        "",
        "> Non-normative discovery output. Inclusion is not canonization, approval,",
        "> implementation readiness, or evidence that current code fulfills the promise.",
        "",
        "The complete evidence-preserving inventory is stored in deterministic JSON",
        "shards referenced by `candidate-capabilities.json` and `discovery-sources.json`.",
        "",
        "## Discovery summary",
        "",
        f"- Owner-originated seeds: **{len(owner_seeds)}**",
        f"- Repository-derived candidate hints: **{sum(family_candidate_counts.values())}**",
        f"- Fingerprinted source files: **{len(compilation.source_files)}**",
        f"- Candidate shards: **{len(candidate_manifest)}**",
        f"- Source fingerprint shards: **{len(source_manifest)}**",
        f"- Configured source families: **{len(compilation.coverage)}**",
        "",
        "## Source-family coverage",
        "",
        "| Source family | Status | Paths | Candidate hints | Blockers |",
        "|---|---:|---:|---:|---:|",
    ]
    for item in compilation.coverage:
        lines.append(
            f"| `{item.family_id}` | {item.status} | {len(item.matched_paths)} | "
            f"{item.extracted_candidate_count} | {len(item.blockers)} |"
        )

    lines.extend(["", "## Owner-originated seeds", ""])
    for item in owner_seeds:
        lines.extend(
            [
                f"### {item.candidate_id} — {item.normalized_name_hint}",
                "",
                f"- Owner wording: {item.exact_terminology}",
                f"- Authority: `{item.authority_status}`",
                f"- Disposition: `{item.disposition}`",
                "",
            ]
        )

    lines.extend(["## Repository-derived candidate families", ""])
    for family_id in sorted(family_candidate_counts):
        lines.extend(
            [
                f"### {family_id}",
                "",
                f"- Candidate hints: **{family_candidate_counts[family_id]}**",
                f"- Fingerprinted source files: **{family_source_counts.get(family_id, 0)}**",
                "- Representative sample:",
            ]
        )
        for item in samples.get(family_id, []):
            evidence = item.evidence[0]
            lines.append(
                f"  - {item.normalized_name_hint} — "
                f"`{evidence.source_path}:{evidence.start_line}`"
            )
        lines.append("")

    lines.extend(["## Candidate shard manifest", ""])
    for shard in candidate_manifest:
        lines.append(
            f"- `{shard['path']}` — {shard['candidate_count']} candidates — "
            f"SHA-256 `{shard['sha256']}`"
        )
    lines.extend(["", "## Source fingerprint shard manifest", ""])
    for shard in source_manifest:
        lines.append(
            f"- `{shard['path']}` — {shard['source_file_count']} files — "
            f"SHA-256 `{shard['sha256']}`"
        )
    lines.append("")
    return "\n".join(lines)


def render_outputs(compilation: DiscoveryCompilation) -> dict[Path, str]:
    candidate_outputs, candidate_manifest = _render_candidate_shards(compilation)
    source_outputs, source_manifest = _render_source_shards(compilation)
    outputs: dict[Path, str] = {
        CORE_OUTPUT_PATHS[0]: canonical_json(
            _candidate_index_payload(compilation, candidate_manifest)
        ),
        CORE_OUTPUT_PATHS[1]: render_inventory_markdown(
            compilation,
            candidate_manifest,
            source_manifest,
        ),
        CORE_OUTPUT_PATHS[2]: canonical_json(
            _coverage_payload(compilation, candidate_manifest, source_manifest)
        ),
        CORE_OUTPUT_PATHS[3]: canonical_json(
            _source_index_payload(compilation, source_manifest)
        ),
    }
    outputs.update(candidate_outputs)
    outputs.update(source_outputs)
    return outputs


def _existing_shards(repository_root: Path) -> set[Path]:
    existing: set[Path] = set()
    for directory in (CANDIDATE_SHARD_DIRECTORY, SOURCE_SHARD_DIRECTORY):
        absolute = repository_root / directory
        if not absolute.exists():
            continue
        for path in absolute.glob("*.json"):
            if path.is_file():
                existing.add(path.relative_to(repository_root))
    return existing


def output_drift(repository_root: Path, outputs: Mapping[Path, str]) -> tuple[Path, ...]:
    drift: set[Path] = set(_existing_shards(repository_root) - set(outputs))
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
    stale = _existing_shards(repository_root) - set(outputs)
    for relative_path in sorted(stale, key=lambda item: item.as_posix()):
        (repository_root / relative_path).unlink()
    for relative_path, content in sorted(
        outputs.items(),
        key=lambda item: item[0].as_posix(),
    ):
        absolute_path = repository_root / relative_path
        absolute_path.parent.mkdir(parents=True, exist_ok=True)
        absolute_path.write_text(content, encoding="utf-8")
