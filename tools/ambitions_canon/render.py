"""Deterministic renderers for tracked Ambitions canon projections."""

from __future__ import annotations

import json
from collections.abc import Mapping
from pathlib import Path

from tools.ambitions_canon.graph import document_edges, requirement_edges
from tools.ambitions_canon.model import CanonError, CanonRegistry


def stable_json(value: object) -> bytes:
    """Serialize JSON with stable ordering and a terminal newline."""

    return (
        json.dumps(
            value,
            ensure_ascii=False,
            indent=2,
            sort_keys=True,
            separators=(",", ": "),
        )
        + "\n"
    ).encode("utf-8")


def render_outputs(registry: CanonRegistry) -> Mapping[Path, bytes]:
    """Render projections from the exact immutable loaded-corpus snapshot."""

    from tools.ambitions_canon.build import _content_sha_entries

    if (
        registry.manifest.repository_root is None
        or registry.manifest.source_bytes is None
    ):
        raise CanonError(
            "CANON_PROVENANCE_MISSING",
            "loaded manifest provenance is required for rendering",
            registry.manifest.source_path,
        )
    entries: list[tuple[str, bytes]] = [
        ("MANIFEST.toml", registry.manifest.source_bytes)
    ]
    canon_prefix = Path("docs/canon")
    for document in registry.documents:
        if document.source_bytes is None:
            raise CanonError(
                "CANON_PROVENANCE_MISSING",
                "loaded document provenance is required for rendering",
                document.source_path,
            )
        try:
            relative = document.source_path.relative_to(canon_prefix)
        except ValueError as exc:
            raise CanonError(
                "CANON_PROVENANCE_PATH",
                "document provenance is outside docs/canon",
                document.source_path,
            ) from exc
        entries.append((relative.as_posix(), document.source_bytes))
    return _render_outputs(
        registry,
        _content_sha_entries(entries),
    )


def _render_outputs(
    registry: CanonRegistry,
    content_sha: str,
) -> Mapping[Path, bytes]:
    metadata = {
        "schema_version": 1,
        "canon_revision": registry.manifest.canon_revision,
        "authority_state": registry.manifest.authority_state.value,
        "compiler_version": registry.manifest.compiler_version,
        "canon_content_sha": content_sha,
    }
    documents = tuple(
        sorted(
            registry.documents,
            key=lambda item: (item.spec_id, item.source_path.as_posix()),
        )
    )
    requirements = tuple(
        sorted(
            registry.requirements,
            key=lambda item: (
                item.requirement_id,
                item.source_path.as_posix(),
                item.line,
            ),
        )
    )
    concept_owners = tuple(sorted(registry.concept_owners))

    rendered: dict[Path, bytes] = {
        Path("CODEX_START_HERE.md"): _codex_start_here(
            metadata, len(documents), len(requirements), len(concept_owners)
        ),
        Path("INDEX.md"): _index(metadata, documents, requirements),
        Path("canon-index.json"): stable_json(
            {
                **metadata,
                "documents": [
                    {
                        "spec_id": document.spec_id,
                        "title": document.title,
                        "kind": document.kind.value,
                        "status": document.status,
                        "owner_domain": document.owner_domain,
                        "profile": document.profile,
                        "source_path": document.source_path.as_posix(),
                    }
                    for document in documents
                ],
                "requirements": [
                    {
                        "requirement_id": requirement.requirement_id,
                        "title": requirement.title,
                        "concept": requirement.concept,
                        "modality": requirement.modality.value,
                        "status": requirement.status,
                        "source_path": requirement.source_path.as_posix(),
                        "line": requirement.line,
                    }
                    for requirement in requirements
                ],
            }
        ),
        Path("concept-ownership.json"): stable_json(
            {
                **metadata,
                "concepts": [
                    {"concept": concept, "spec_id": spec_id}
                    for concept, spec_id in concept_owners
                ],
            }
        ),
        Path("requirement-graph.json"): stable_json(
            {
                **metadata,
                "document_edges": [
                    {"from": source, "to": destination}
                    for source, destination in document_edges(registry)
                ],
                "requirement_edges": [
                    {"from": source, "to": destination}
                    for source, destination in requirement_edges(registry)
                ],
                "requirement_ids": [
                    requirement.requirement_id for requirement in requirements
                ],
            }
        ),
        Path("specification-coverage.md"): _coverage(metadata, documents),
        Path("unresolved-conflicts.md"): _unresolved_conflicts(
            metadata, documents
        ),
        Path("law-source-map.json"): _law_map(
            metadata, requirements, documents
        ),
        Path("law-test-map.json"): _unrepresented_map(
            metadata,
            requirements,
            "test-specific authority is not represented by the current model",
        ),
        Path("law-proof-map.json"): _unrepresented_map(
            metadata,
            requirements,
            "proof-specific authority is not represented by the current model",
        ),
        Path("visual-authority-manifest.json"): stable_json(
            {
                **metadata,
                "representation_status": "unrepresented",
                "reason": "visual authority inputs are not represented by the current model",
            }
        ),
        Path("external-reference-impact.md"): _external_impact(metadata),
        Path("supersession-manifest.json"): _supersession_manifest(
            metadata, requirements
        ),
    }

    expected = tuple(
        sorted(
            (
                Path(*path.parts[1:])
                for path in registry.manifest.generated_files
            ),
            key=lambda path: path.as_posix(),
        )
    )
    unknown = tuple(path for path in expected if path not in rendered)
    undeclared = tuple(path for path in rendered if path not in expected)
    if unknown or undeclared:
        detail = unknown[0] if unknown else undeclared[0]
        raise CanonError(
            "CANON_GENERATED_MANIFEST_MISMATCH",
            f"generated projection contract mismatch: {detail.as_posix()}",
            registry.manifest.source_path,
        )
    return {
        path: rendered[path]
        for path in sorted(rendered, key=lambda item: item.as_posix())
    }


def _markdown_header(title: str, metadata: Mapping[str, object]) -> list[str]:
    return [
        f"# {title}",
        "",
        "> Shadow, non-authoritative generated projection.",
        "",
        f"- Schema version: `{metadata['schema_version']}`",
        f"- Canon revision: `{metadata['canon_revision']}`",
        f"- Authority state: `{metadata['authority_state']}`",
        f"- Compiler version: `{metadata['compiler_version']}`",
        f"- Canon content SHA: `{metadata['canon_content_sha']}`",
        "",
    ]


def _markdown(lines: list[str]) -> bytes:
    return ("\n".join(lines).rstrip() + "\n").encode("utf-8")


def _codex_start_here(
    metadata: Mapping[str, object],
    document_count: int,
    requirement_count: int,
    concept_count: int,
) -> bytes:
    lines = _markdown_header("Ambitions Canon — Codex Start Here", metadata)
    lines.extend(
        [
            "This generated surface is shadow-only until authority cutover.",
            "",
            "## Registry summary",
            "",
            f"- Specifications: {document_count}",
            f"- Requirements: {requirement_count}",
            f"- Concept owners: {concept_count}",
            "",
            "Run `python3 scripts/ambitions-canon.py audit` before relying on this registry.",
        ]
    )
    return _markdown(lines)


def _index(metadata, documents, requirements) -> bytes:
    lines = _markdown_header("Ambitions Canon Index", metadata)
    lines.extend(["## Specifications", ""])
    if documents:
        lines.extend(
            [
                "| ID | Kind | Title | Source |",
                "| --- | --- | --- | --- |",
            ]
        )
        lines.extend(
            f"| `{_markdown_cell(item.spec_id)}` | {_markdown_cell(item.kind.value)} | "
            f"{_markdown_cell(item.title)} | `{_markdown_cell(item.source_path.as_posix())}` |"
            for item in documents
        )
    else:
        lines.append("No normative specifications are declared.")
    lines.extend(["", "## Requirements", ""])
    if requirements:
        lines.extend(
            [
                "| ID | Modality | Concept | Source |",
                "| --- | --- | --- | --- |",
            ]
        )
        lines.extend(
            f"| `{_markdown_cell(item.requirement_id)}` | "
            f"{_markdown_cell(item.modality.value)} | `{_markdown_cell(item.concept)}` | "
            f"`{_markdown_cell(item.source_path.as_posix())}:{item.line}` |"
            for item in requirements
        )
    else:
        lines.append("No normative requirements are declared.")
    return _markdown(lines)


def _coverage(metadata, documents) -> bytes:
    lines = _markdown_header("Ambitions Specification Coverage", metadata)
    lines.extend(["| Specification | Profile | Section markers |", "| --- | --- | ---: |"])
    if documents:
        lines.extend(
            f"| `{_markdown_cell(item.spec_id)}` | "
            f"{_markdown_cell(item.profile or 'none')} | {len(item.sections)} |"
            for item in documents
        )
    else:
        lines.append("| none | none | 0 |")
    return _markdown(lines)


def _unresolved_conflicts(metadata, documents) -> bytes:
    lines = _markdown_header("Ambitions Unresolved Conflicts", metadata)
    lines.extend(
        [
            "**Representation status:** Unrepresented",
            "",
            "Conflict-docket identity is not represented by the current model.",
        ]
    )
    return _markdown(lines)


def _law_map(metadata, requirements, documents) -> bytes:
    documents_by_path = {item.source_path: item for item in documents}
    mappings = []
    for requirement in requirements:
        document = documents_by_path.get(requirement.source_path)
        values = document.source_owners if document is not None else ()
        mappings.append(
            {
                "requirement_id": requirement.requirement_id,
                "references": sorted(values),
            }
        )
    return stable_json({**metadata, "mappings": mappings})


def _unrepresented_map(metadata, requirements, reason) -> bytes:
    return stable_json(
        {
            **metadata,
            "representation_status": "unrepresented",
            "reason": reason,
            "requirement_ids": [
                requirement.requirement_id for requirement in requirements
            ],
        }
    )


def _external_impact(metadata) -> bytes:
    lines = _markdown_header("Ambitions External Reference Impact", metadata)
    lines.extend(
        [
            "**Representation status:** Unrepresented",
            "",
            "External authority impact inputs are not represented by the current model.",
        ]
    )
    return _markdown(lines)


def _markdown_cell(value: object) -> str:
    return (
        str(value)
        .replace("&", "&amp;")
        .replace("|", "&#124;")
        .replace("`", "&#96;")
        .replace("\r\n", "<br>")
        .replace("\r", "<br>")
        .replace("\n", "<br>")
    )


def _supersession_manifest(metadata, requirements) -> bytes:
    rows = sorted(
        (
            {"retired_id": retired, "replacement_id": requirement.requirement_id}
            for requirement in requirements
            for retired in requirement.supersedes
        ),
        key=lambda row: (row["retired_id"], row["replacement_id"]),
    )
    return stable_json({**metadata, "supersessions": rows})
