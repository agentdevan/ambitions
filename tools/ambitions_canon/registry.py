"""Global identity registry for parsed Ambitions canon documents."""

from __future__ import annotations

import re
from collections.abc import Iterable

from tools.ambitions_canon.model import (
    AuthorityState,
    CanonDocument,
    CanonError,
    CanonManifest,
    CanonRegistry,
    DocumentKind,
    Requirement,
)


CONCEPT_KEY = re.compile(r"^[a-z0-9]+(?:[.-][a-z0-9]+)*$")


def build_registry(
    manifest: CanonManifest,
    documents: Iterable[CanonDocument],
) -> CanonRegistry:
    """Build a deterministic registry and reject ambiguous global identity."""

    ordered_documents = tuple(
        sorted(
            documents,
            key=lambda item: (item.spec_id, item.source_path.as_posix()),
        )
    )
    _require_active_constitution(manifest, ordered_documents)
    _reject_duplicate_specs(ordered_documents)

    ordered_requirements = tuple(
        sorted(
            (
                requirement
                for document in ordered_documents
                for requirement in document.requirements
            ),
            key=lambda item: (
                item.requirement_id,
                item.source_path.as_posix(),
                item.line,
            ),
        )
    )
    _reject_duplicate_requirements(ordered_requirements)
    _reject_cross_kind_id_collisions(ordered_documents, ordered_requirements)
    superseded_ids = frozenset(
        superseded
        for requirement in ordered_requirements
        for superseded in requirement.supersedes
    )
    concept_owners = _concept_owners(ordered_documents)
    _require_document_concept_ownership(ordered_documents)
    _resolve_references(
        ordered_documents,
        ordered_requirements,
        superseded_ids,
    )

    active_ids = {item.spec_id for item in ordered_documents} | {
        item.requirement_id for item in ordered_requirements
    }
    reused = sorted(active_ids & superseded_ids)
    if reused:
        retired_id = reused[0]
        active_requirement = next(
            (
                item
                for item in ordered_requirements
                if item.requirement_id == retired_id
            ),
            None,
        )
        active_document = next(
            (item for item in ordered_documents if item.spec_id == retired_id),
            None,
        )
        path = (
            active_requirement.source_path
            if active_requirement is not None
            else active_document.source_path
        )
        line = (
            active_requirement.line
            if active_requirement is not None
            else None
        )
        raise CanonError(
            "CANON_SUPERSEDED_REFERENCE",
            f"retired ID is reused as active: {retired_id}",
            path,
            line,
        )

    return CanonRegistry(
        manifest=manifest,
        documents=ordered_documents,
        requirements=ordered_requirements,
        concept_owners=concept_owners,
        superseded_ids=superseded_ids,
    )


def _require_active_constitution(
    manifest: CanonManifest,
    documents: tuple[CanonDocument, ...],
) -> None:
    if manifest.authority_state is not AuthorityState.ACTIVE:
        return
    count = sum(
        document.kind is DocumentKind.CONSTITUTION for document in documents
    )
    if count != 1:
        raise CanonError(
            "CANON_MANIFEST_CONSTITUTION_REQUIRED",
            f"active authority requires exactly one Constitution; found {count}",
            manifest.source_path,
        )


def _reject_duplicate_specs(documents: tuple[CanonDocument, ...]) -> None:
    for previous, current in zip(documents, documents[1:]):
        if previous.spec_id == current.spec_id:
            raise CanonError(
                "CANON_ID_DUPLICATE",
                f"duplicate spec_id: {current.spec_id}",
                current.source_path,
            )


def _reject_duplicate_requirements(
    requirements: tuple[Requirement, ...],
) -> None:
    for previous, current in zip(requirements, requirements[1:]):
        if previous.requirement_id == current.requirement_id:
            raise CanonError(
                "CANON_ID_DUPLICATE",
                f"duplicate requirement ID: {current.requirement_id}",
                current.source_path,
                current.line,
            )


def _reject_cross_kind_id_collisions(
    documents: tuple[CanonDocument, ...],
    requirements: tuple[Requirement, ...],
) -> None:
    specs = {item.spec_id: item for item in documents}
    requirements_by_id = {item.requirement_id: item for item in requirements}
    collisions = sorted(set(specs) & set(requirements_by_id))
    if collisions:
        identifier = collisions[0]
        requirement = requirements_by_id[identifier]
        raise CanonError(
            "CANON_ID_DUPLICATE",
            f"ID is both a spec_id and requirement ID: {identifier}",
            requirement.source_path,
            requirement.line,
        )


def _concept_owners(
    documents: tuple[CanonDocument, ...],
) -> tuple[tuple[str, str], ...]:
    declarations = sorted(
        (
            (concept, document.spec_id, document.source_path)
            for document in documents
            for concept in document.owns_concepts
        ),
        key=lambda item: (item[0], item[1], item[2].as_posix()),
    )
    for concept, spec_id, path in declarations:
        if CONCEPT_KEY.fullmatch(concept) is None:
            raise CanonError(
                "CANON_CONCEPT_UNOWNED",
                f"invalid normalized concept owner in {spec_id}: {concept!r}",
                path,
            )
    for previous, current in zip(declarations, declarations[1:]):
        if previous[0] == current[0]:
            raise CanonError(
                "CANON_CONCEPT_DUPLICATE_OWNER",
                f"duplicate concept owner: {current[0]}",
                current[2],
            )
    return tuple((concept, spec_id) for concept, spec_id, _ in declarations)


def _require_document_concept_ownership(
    documents: tuple[CanonDocument, ...],
) -> None:
    for document in documents:
        owned = set(document.owns_concepts)
        for requirement in sorted(
            document.requirements,
            key=lambda item: (item.requirement_id, item.line),
        ):
            if requirement.concept not in owned:
                raise CanonError(
                    "CANON_CONCEPT_UNOWNED",
                    (
                        f"requirement concept is not owned by {document.spec_id}: "
                        f"{requirement.concept}"
                    ),
                    requirement.source_path,
                    requirement.line,
                )


def _resolve_references(
    documents: tuple[CanonDocument, ...],
    requirements: tuple[Requirement, ...],
    superseded_ids: frozenset[str],
) -> None:
    requirement_ids = {item.requirement_id for item in requirements}
    spec_ids = {item.spec_id for item in documents}
    for document in documents:
        for requirement_id in sorted(document.inherits):
            if requirement_id not in requirement_ids:
                if requirement_id in superseded_ids:
                    raise CanonError(
                        "CANON_SUPERSEDED_REFERENCE",
                        f"inherited requirement is superseded: {requirement_id}",
                        document.source_path,
                    )
                raise CanonError(
                    "CANON_DEPENDENCY_UNKNOWN",
                    f"unknown inherited requirement ID: {requirement_id}",
                    document.source_path,
                )
        for spec_id in sorted(document.depends_on):
            if spec_id not in spec_ids:
                if spec_id in superseded_ids:
                    raise CanonError(
                        "CANON_SUPERSEDED_REFERENCE",
                        f"dependent specification is superseded: {spec_id}",
                        document.source_path,
                    )
                raise CanonError(
                    "CANON_DEPENDENCY_UNKNOWN",
                    f"unknown dependent spec_id: {spec_id}",
                    document.source_path,
                )
