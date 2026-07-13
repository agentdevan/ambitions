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
    if registry.supersession_ledger_bytes is None:
        raise CanonError(
            "CANON_PROVENANCE_MISSING",
            "loaded supersession ledger bytes are required for rendering",
            registry.manifest.source_path,
        )
    entries.append(
        (
            "decisions/SUPERSESSION_LEDGER.toml",
            registry.supersession_ledger_bytes,
        )
    )
    if (
        registry.reference_index is None
        or registry.reference_index.source_bytes is None
    ):
        raise CanonError(
            "CANON_PROVENANCE_MISSING",
            "loaded impact reference index bytes are required for rendering",
            registry.manifest.source_path,
        )
    entries.append(
        (
            "migration/impact-reference-index.json",
            registry.reference_index.source_bytes,
        )
    )
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
    from tools.ambitions_canon.conflicts import (
        docket_filename,
        load_conflict_dockets,
        render_conflict_docket,
        validate_conflict_repository,
    )

    dockets = load_conflict_dockets(registry.manifest.repository_root)
    conflict_snapshot = validate_conflict_repository(
        registry.manifest.repository_root,
        dockets,
        (item.requirement_id for item in registry.requirements),
        registry.supersession_entries,
    )
    entries.extend(
        (
            f"decisions/open/{docket_filename(docket).as_posix()}",
            render_conflict_docket(docket).encode("utf-8"),
        )
        for docket in dockets
    )
    if conflict_snapshot is not None:
        entries.extend(
            (
                (
                    "migration/source-catalog.json",
                    conflict_snapshot.source_catalog_bytes,
                ),
                (
                    "migration/claim-dispositions.json",
                    conflict_snapshot.claim_dispositions_bytes,
                ),
                (
                    "migration/conflict-docket-baseline.json",
                    conflict_snapshot.baseline_bytes,
                ),
            )
        )
    return _render_outputs(
        registry,
        _content_sha_entries(entries),
        dockets if conflict_snapshot is not None else None,
    )


def _render_outputs(
    registry: CanonRegistry,
    content_sha: str,
    dockets: tuple[object, ...] | None = None,
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
            metadata, documents, dockets
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
            metadata, registry
        ),
        Path("object-boundary-matrix.md"): _object_boundary_matrix(
            metadata, documents, requirements
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


def _object_boundary_matrix(
    metadata: Mapping[str, object],
    documents: tuple[object, ...],
    requirements: tuple[object, ...],
) -> bytes:
    """Render the executable Step/Event/Reminder/Note distinction contract."""

    columns = (
        ("OBJECT-STEP", "Step"),
        ("OBJECT-EVENT", "Event"),
        ("OBJECT-REMINDER", "Reminder"),
        ("OBJECT-NOTE", "Note"),
    )
    capabilities = (
        ("executable_completable", "Executable / completable"),
        ("occupies_duration", "Occupies duration"),
        ("consumes_capacity", "Consumes capacity"),
        ("due_date", "Due date"),
        ("recurrence", "Recurrence"),
        ("substeps", "Substeps"),
        ("goal_path_node", "Goal Path node"),
        ("proof_requirement", "Proof requirement"),
        ("attendees_rsvp", "Attendees / RSVP"),
        ("alerts", "Alerts"),
        ("type_conversion", "Type conversion"),
    )
    law_references = (
        ("schedule_placement_nonduplication", "Schedule Placement nonduplication", "OBJ-SCHEDULE-PLACEMENT-IDENTITY-001"),
        ("future_step_singularity", "Future Step singularity", "OBJECT-FUTURE-STEP-IDENTITY-001"),
        ("reminder_acknowledgement_noncompletion", "Reminder acknowledgement noncompletion", "OBJECT-REMINDER-COMPLETION-001"),
        ("proof_receipt_separation", "Proof / Receipt separation", "OBJECT-PROOF-REQUIREMENT-001"),
    )
    by_spec = {document.spec_id: document for document in documents}
    present = {spec_id for spec_id, _ in columns if spec_id in by_spec}
    lines = _markdown_header("Object Boundary Matrix", metadata)
    if not present:
        lines.extend(
            [
                "- Representation status: `unrepresented`",
                "- Reason: Step, Event, Reminder, and Note specifications are not all materialized.",
            ]
        )
        return ("\n".join(lines) + "\n").encode("utf-8")
    required_specs = {spec_id for spec_id, _ in columns}
    if present != required_specs:
        missing = sorted(required_specs - present)
        raise CanonError(
            "CANON_OBJECT_BOUNDARY_MISSING",
            f"object boundary contract is missing specifications: {','.join(missing)}",
            by_spec[next(iter(present))].source_path,
        )
    boundary_documents = tuple(by_spec[spec_id] for spec_id, _ in columns)
    if any(document.object_boundary is None for document in boundary_documents):
        missing = next(
            document for document in boundary_documents if document.object_boundary is None
        )
        raise CanonError(
            "CANON_OBJECT_BOUNDARY_MISSING",
            f"object boundary data is missing: {missing.spec_id}",
            missing.source_path,
        )
    boundary_values = tuple(
        dict(document.object_boundary.capabilities) for document in boundary_documents
    )
    expected_laws = dict((key, requirement_id) for key, _, requirement_id in law_references)
    for document in boundary_documents:
        if dict(document.object_boundary.laws) != expected_laws:
            raise CanonError(
                "CANON_OBJECT_BOUNDARY_LAW_INVALID",
                f"object boundary law references drifted: {document.spec_id}",
                document.source_path,
            )
    requirement_by_id = {
        requirement.requirement_id: requirement for requirement in requirements
    }
    resolved_laws = []
    for key, label, requirement_id in law_references:
        requirement = requirement_by_id.get(requirement_id)
        if requirement is None:
            raise CanonError(
                "CANON_OBJECT_BOUNDARY_LAW_INVALID",
                f"object boundary law does not resolve: {key}={requirement_id}",
            )
        first_paragraph = requirement.body.strip().split("\n\n", 1)[0]
        resolved_laws.append(
            (label, requirement_id, " ".join(first_paragraph.splitlines()))
        )
    rows = tuple(
        (label, *(values[key] for values in boundary_values))
        for key, label in capabilities
    )
    lines.extend(
        [
            "- Representation status: `materialized`",
            "- Scope: validated spec-owned semantic boundaries; not implementation proof",
            "",
            "| Capability | Step | Event | Reminder | Note |",
            "|---|---|---|---|---|",
            *("| " + " | ".join(row) + " |" for row in rows),
            "",
            "## Owning boundary laws",
            "",
            *(
                f"- **{label}** (`{requirement_id}`): {body}"
                for label, requirement_id, body in resolved_laws
            ),
        ]
    )
    return ("\n".join(lines) + "\n").encode("utf-8")


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


def _unresolved_conflicts(metadata, documents, dockets=None) -> bytes:
    if dockets is not None:
        from tools.ambitions_canon.conflicts import render_unresolved_report

        return render_unresolved_report(
            dockets,
            canon_revision=int(metadata["canon_revision"]),
            canon_content_sha=str(metadata["canon_content_sha"]),
            compiler_version=str(metadata["compiler_version"]),
            authority_state=str(metadata["authority_state"]),
        )
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


def _supersession_manifest(metadata, registry) -> bytes:
    rows = [
        {
            "conflict_id": entry.conflict_id,
            "old_ids": list(entry.old_ids),
            "resulting_id": entry.resulting_id,
            "decision_date": entry.decision_date,
            "owner": entry.owner,
            "decision_source": entry.decision_source,
            "resolution": entry.resolution,
            "decision_base_commit": entry.decision_base_commit,
            "integration_evidence_sha256": entry.integration_evidence_sha256,
            "superseded_artifacts": list(entry.superseded_artifacts),
        }
        for entry in registry.supersession_entries
    ]
    return stable_json({**metadata, "supersessions": rows})
