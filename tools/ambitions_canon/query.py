"""Deterministic queries over the immutable Ambitions canon registry."""

from __future__ import annotations

from tools.ambitions_canon.model import (
    CanonError,
    CanonRegistry,
    Requirement,
)


def query_by_id(registry: CanonRegistry, identifier: str) -> object:
    """Return the uniquely registered specification or requirement by ID."""

    for document in registry.documents:
        if document.spec_id == identifier:
            return document
    for requirement in registry.requirements:
        if requirement.requirement_id == identifier:
            return requirement
    raise CanonError(
        "CANON_QUERY_NOT_FOUND",
        f"canonical identifier was not found: {identifier}",
        registry.manifest.source_path,
    )


def query_by_concept(
    registry: CanonRegistry,
    concept: str,
) -> tuple[Requirement, ...]:
    """Return requirements that own the exact normalized concept."""

    return tuple(
        requirement
        for requirement in registry.requirements
        if requirement.concept == concept
    )
