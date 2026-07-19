"""Deterministic dependency graphs for the Ambitions canon registry."""

from __future__ import annotations

from collections.abc import Iterable

from tools.ambitions_canon.model import CanonRegistry


Edge = tuple[str, str]
Cycle = tuple[str, ...]


def document_edges(registry: CanonRegistry) -> tuple[Edge, ...]:
    """Return sorted specification dependency edges."""

    return tuple(
        sorted(
            {
                (document.spec_id, dependency)
                for document in registry.documents
                for dependency in document.depends_on
            }
        )
    )


def requirement_edges(registry: CanonRegistry) -> tuple[Edge, ...]:
    """Return sorted edges from each local requirement to inherited laws."""

    return tuple(
        sorted(
            {
                (requirement.requirement_id, inherited)
                for document in registry.documents
                for requirement in document.requirements
                for inherited in document.inherits
            }
        )
    )


def _canonical_cycle(cycle: list[str]) -> Cycle:
    body = cycle[:-1]
    rotations = tuple(
        tuple(body[index:] + body[:index])
        for index in range(len(body))
    )
    canonical = min(rotations)
    return canonical + (canonical[0],)


def dependency_cycles(edges: Iterable[Edge]) -> tuple[Cycle, ...]:
    """Return sorted, deduplicated, closed directed dependency cycles."""

    adjacency: dict[str, set[str]] = {}
    for source, destination in edges:
        adjacency.setdefault(source, set()).add(destination)
        adjacency.setdefault(destination, set())

    found: set[Cycle] = set()

    def visit(start: str, node: str, path: list[str], seen: set[str]) -> None:
        for destination in sorted(adjacency[node]):
            if destination == start:
                found.add(_canonical_cycle(path + [start]))
            elif destination not in seen and destination >= start:
                visit(
                    start,
                    destination,
                    path + [destination],
                    seen | {destination},
                )

    for start in sorted(adjacency):
        visit(start, start, [start], {start})

    return tuple(sorted(found))
