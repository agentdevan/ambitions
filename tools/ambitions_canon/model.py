"""Immutable data contracts for the Ambitions canon compiler."""

from __future__ import annotations

from dataclasses import dataclass
from enum import StrEnum
from pathlib import Path


class CanonError(Exception):
    """A stable, location-aware canon compiler error."""

    __slots__ = ("code", "message", "path", "line")

    def __init__(
        self,
        code: str,
        message: str,
        path: Path | None = None,
        line: int | None = None,
    ) -> None:
        super().__init__(message)
        self.code = code
        self.message = message
        self.path = path
        self.line = line

    def __str__(self) -> str:
        parts = [self.code]
        if self.path is not None:
            location = str(self.path)
            if self.line is not None:
                location = f"{location}:{self.line}"
            parts.append(location)
        elif self.line is not None:
            parts.append(f"line:{self.line}")
        parts.append(self.message)
        return " ".join(parts)


class AuthorityState(StrEnum):
    SHADOW = "shadow"
    ACTIVE = "active"


class AuthorityClass(StrEnum):
    CONSTITUTION = "constitution"
    SPECIFICATION = "specification"
    STANDARD = "standard"
    DECISION_DOCKET = "decision_docket"
    GENERATED_PROJECTION = "generated_projection"
    SOURCE_AND_TESTS = "source_and_tests"
    LINEAR = "linear"
    FIGMA = "figma"


class DocumentKind(StrEnum):
    CONSTITUTION = "constitution"
    APP = "app"
    SURFACE = "surface"
    GLOBAL = "global"
    OBJECT = "object"
    JOURNEY = "journey"
    SYSTEM = "system"
    STANDARD = "standard"


class Modality(StrEnum):
    MUST = "MUST"
    MUST_NOT = "MUST NOT"
    SHOULD = "SHOULD"
    SHOULD_NOT = "SHOULD NOT"
    MAY = "MAY"
    INFORMATIONAL = "INFORMATIONAL"


class GapSeverity(StrEnum):
    P0_BLOCKER = "P0_BLOCKER"
    P1_REQUIRED = "P1_REQUIRED"
    P2_IMPROVEMENT = "P2_IMPROVEMENT"
    INFORMATIONAL = "INFORMATIONAL"


@dataclass(frozen=True, slots=True)
class Requirement:
    requirement_id: str
    title: str
    concept: str
    modality: Modality
    scope: str
    status: str
    verification: tuple[str, ...]
    supersedes: tuple[str, ...]
    body: str
    source_path: Path
    line: int

    def __post_init__(self) -> None:
        object.__setattr__(self, "verification", tuple(self.verification))
        object.__setattr__(self, "supersedes", tuple(self.supersedes))


@dataclass(frozen=True, slots=True)
class NotApplicable:
    section: str
    rationale: str
    owner: str


@dataclass(frozen=True, slots=True)
class CanonDocument:
    spec_id: str
    title: str
    kind: DocumentKind
    status: str
    owner_domain: str
    canon_revision: int
    profile: str | None
    owns_concepts: tuple[str, ...]
    inherits: tuple[str, ...]
    depends_on: tuple[str, ...]
    source_owners: tuple[str, ...]
    sections: frozenset[str]
    not_applicable: tuple[NotApplicable, ...]
    requirements: tuple[Requirement, ...]
    source_path: Path

    def __post_init__(self) -> None:
        object.__setattr__(self, "owns_concepts", tuple(self.owns_concepts))
        object.__setattr__(self, "inherits", tuple(self.inherits))
        object.__setattr__(self, "depends_on", tuple(self.depends_on))
        object.__setattr__(self, "source_owners", tuple(self.source_owners))
        object.__setattr__(self, "sections", frozenset(self.sections))
        object.__setattr__(self, "not_applicable", tuple(self.not_applicable))
        object.__setattr__(self, "requirements", tuple(self.requirements))


@dataclass(frozen=True, slots=True)
class ManifestEntry:
    path: Path


@dataclass(frozen=True, slots=True)
class CanonManifest:
    schema_version: int
    canon_revision: int
    authority_state: AuthorityState
    compiler_version: str
    normative_files: tuple[ManifestEntry, ...]
    generated_files: tuple[Path, ...]
    source_path: Path

    def __post_init__(self) -> None:
        object.__setattr__(self, "normative_files", tuple(self.normative_files))
        object.__setattr__(self, "generated_files", tuple(self.generated_files))


@dataclass(frozen=True, slots=True)
class Finding:
    code: str
    severity: GapSeverity
    message: str
    path: Path | None = None
    line: int | None = None


@dataclass(frozen=True, slots=True)
class CanonRegistry:
    manifest: CanonManifest
    documents: tuple[CanonDocument, ...]
    requirements: tuple[Requirement, ...]
    concept_owners: tuple[tuple[str, str], ...]
    superseded_ids: frozenset[str]

    def __post_init__(self) -> None:
        object.__setattr__(self, "documents", tuple(self.documents))
        object.__setattr__(self, "requirements", tuple(self.requirements))
        object.__setattr__(
            self,
            "concept_owners",
            tuple(tuple(pair) for pair in self.concept_owners),
        )
        object.__setattr__(self, "superseded_ids", frozenset(self.superseded_ids))
