"""Fail-closed deterministic audits for the Ambitions canon registry."""

from __future__ import annotations

from collections import Counter
from pathlib import Path

from tools.ambitions_canon.graph import (
    dependency_cycles,
    document_edges,
    requirement_edges,
)
from tools.ambitions_canon.model import (
    AuthorityState,
    CanonRegistry,
    DocumentKind,
    Finding,
    GapSeverity,
    Modality,
)


def _finding(
    code: str,
    message: str,
    path: Path | None = None,
    line: int | None = None,
) -> Finding:
    return Finding(
        code=code,
        severity=GapSeverity.P0_BLOCKER,
        message=message,
        path=path,
        line=line,
    )


def _sort_key(finding: Finding) -> tuple[str, str, str, int, str]:
    return (
        finding.severity.value,
        finding.code,
        finding.path.as_posix() if finding.path is not None else "",
        finding.line if finding.line is not None else 0,
        finding.message,
    )


def audit_registry(registry: CanonRegistry) -> tuple[Finding, ...]:
    """Return deterministic hard-red findings for an arbitrary registry."""

    findings: list[Finding] = []
    documents = tuple(registry.documents)
    requirements = tuple(registry.requirements)

    identities = sorted(
        (
            (document.spec_id, document.source_path, None, "specification")
            for document in documents
        ),
        key=lambda item: (item[0], item[1].as_posix(), item[3]),
    ) + sorted(
        (
            (
                requirement.requirement_id,
                requirement.source_path,
                requirement.line,
                "requirement",
            )
            for requirement in requirements
        ),
        key=lambda item: (item[0], item[1].as_posix(), item[2]),
    )
    identities.sort(
        key=lambda item: (
            item[0],
            item[1].as_posix(),
            item[2] or 0,
            item[3],
        )
    )
    seen_ids: set[str] = set()
    for identifier, path, line, identity_kind in identities:
        if identifier in seen_ids:
            findings.append(
                _finding(
                    "CANON_ID_DUPLICATE",
                    f"duplicate global ID: {identifier} ({identity_kind})",
                    path,
                    line,
                )
            )
        seen_ids.add(identifier)

    declarations = sorted(
        (
            (concept, document.spec_id, document.source_path)
            for document in documents
            for concept in document.owns_concepts
        ),
        key=lambda item: (item[0], item[1], item[2].as_posix()),
    )
    seen_concepts: set[str] = set()
    for concept, spec_id, path in declarations:
        if concept in seen_concepts:
            findings.append(
                _finding(
                    "CANON_CONCEPT_DUPLICATE_OWNER",
                    f"concept has more than one owner: {concept} ({spec_id})",
                    path,
                )
            )
        seen_concepts.add(concept)

    documents_by_id = {document.spec_id for document in documents}
    requirements_by_id = {requirement.requirement_id for requirement in requirements}
    superseded = set(registry.superseded_ids)
    for document in documents:
        owned = set(document.owns_concepts)
        for requirement in document.requirements:
            if requirement.concept not in owned:
                findings.append(
                    _finding(
                        "CANON_CONCEPT_UNOWNED",
                        (
                            f"requirement concept is not owned by "
                            f"{document.spec_id}: {requirement.concept}"
                        ),
                        requirement.source_path,
                        requirement.line,
                    )
                )
            if not isinstance(requirement.modality, Modality):
                findings.append(
                    _finding(
                        "CANON_MODALITY_INVALID",
                        f"invalid modality: {requirement.modality}",
                        requirement.source_path,
                        requirement.line,
                    )
                )
        for inherited in document.inherits:
            if inherited not in requirements_by_id and inherited not in superseded:
                findings.append(
                    _finding(
                        "CANON_DEPENDENCY_UNKNOWN",
                        f"unknown inherited requirement ID: {inherited}",
                        document.source_path,
                    )
                )
        for dependency in document.depends_on:
            if dependency not in documents_by_id and dependency not in superseded:
                findings.append(
                    _finding(
                        "CANON_DEPENDENCY_UNKNOWN",
                        f"unknown dependent spec_id: {dependency}",
                        document.source_path,
                    )
                )

    for graph_name, edges in (
        ("document", document_edges(registry)),
        ("requirement", requirement_edges(registry)),
    ):
        for cycle in dependency_cycles(edges):
            findings.append(
                _finding(
                    "CANON_DEPENDENCY_CYCLE",
                    f"{graph_name} dependency cycle: {' -> '.join(cycle)}",
                )
            )

    for document in documents:
        for inherited in document.inherits:
            if inherited in superseded:
                findings.append(
                    _finding(
                        "CANON_SUPERSEDED_REFERENCE",
                        f"inherited requirement is superseded: {inherited}",
                        document.source_path,
                    )
                )
        for dependency in document.depends_on:
            if dependency in superseded:
                findings.append(
                    _finding(
                        "CANON_SUPERSEDED_REFERENCE",
                        f"dependent specification is superseded: {dependency}",
                        document.source_path,
                    )
                )
    for requirement in requirements:
        if requirement.requirement_id in superseded:
            findings.append(
                _finding(
                    "CANON_SUPERSEDED_REFERENCE",
                    f"superseded ID is still active: {requirement.requirement_id}",
                    requirement.source_path,
                    requirement.line,
                )
            )
    for document in documents:
        if document.spec_id in superseded:
            findings.append(
                _finding(
                    "CANON_SUPERSEDED_REFERENCE",
                    f"superseded ID is still active: {document.spec_id}",
                    document.source_path,
                )
            )

    if registry.manifest.authority_state is AuthorityState.ACTIVE:
        constitution_count = Counter(
            document.kind for document in documents
        )[DocumentKind.CONSTITUTION]
        if constitution_count != 1:
            findings.append(
                _finding(
                    "CANON_ACTIVE_CONSTITUTION_COUNT",
                    (
                        "active authority requires exactly one Constitution; "
                        f"found {constitution_count}"
                    ),
                    registry.manifest.source_path,
                )
            )

    return tuple(sorted(findings, key=_sort_key))
