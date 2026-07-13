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


class AuthorityReferenceKind(StrEnum):
    SOURCE = "source"
    TEST = "test"
    PROOF = "proof"
    SCENARIO = "scenario"
    FIGMA = "figma"
    LINEAR = "linear"


class FigmaAuthorityRole(StrEnum):
    APPROVED_TARGET = "approved_target"
    CANDIDATE = "candidate"
    SUPERSEDED = "superseded"


class ClaimDisposition(StrEnum):
    KEEP = "keep"
    REWRITE = "rewrite"
    COMPOSE = "compose"
    REJECT = "reject"
    PROVENANCE_ONLY = "provenance_only"
    CONFLICT = "conflict"


class ClaimTargetClass(StrEnum):
    CONSTITUTION = "constitution"
    SPECIFICATION = "specification"
    STANDARD = "standard"
    DECISION_DOCKET = "decision_docket"
    PROVENANCE = "provenance"
    REJECTION = "rejection"


@dataclass(frozen=True, slots=True)
class AtomicClaim:
    """One immutable source claim with provenance and normalized semantics."""

    claim_id: str
    source_id: str
    source_location: str
    concept: str
    subject: str
    predicate: str
    value: str
    modality: Modality
    scope: str
    conditions: tuple[str, ...]
    exceptions: tuple[str, ...]
    authority_claim: bool
    owner_approval: str | None
    disposition: ClaimDisposition
    target_id: str | None
    original_text: str
    target_class: ClaimTargetClass
    rationale: str
    owner_evidence_text: str | None = None
    owner_evidence_rationale: str | None = None

    def __post_init__(self) -> None:
        object.__setattr__(self, "conditions", tuple(self.conditions))
        object.__setattr__(self, "exceptions", tuple(self.exceptions))


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
class ObjectBoundary:
    capabilities: tuple[tuple[str, str], ...]
    laws: tuple[tuple[str, str], ...]

    def __post_init__(self) -> None:
        object.__setattr__(self, "capabilities", tuple(self.capabilities))
        object.__setattr__(self, "laws", tuple(self.laws))


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
    source_bytes: bytes | None = None
    object_boundary: ObjectBoundary | None = None

    def __post_init__(self) -> None:
        object.__setattr__(self, "owns_concepts", tuple(self.owns_concepts))
        object.__setattr__(self, "inherits", tuple(self.inherits))
        object.__setattr__(self, "depends_on", tuple(self.depends_on))
        object.__setattr__(self, "source_owners", tuple(self.source_owners))
        object.__setattr__(self, "sections", frozenset(self.sections))
        object.__setattr__(self, "not_applicable", tuple(self.not_applicable))
        object.__setattr__(self, "requirements", tuple(self.requirements))
        if self.source_bytes is not None:
            object.__setattr__(self, "source_bytes", bytes(self.source_bytes))


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
    repository_root: Path | None = None
    source_bytes: bytes | None = None

    def __post_init__(self) -> None:
        object.__setattr__(self, "normative_files", tuple(self.normative_files))
        object.__setattr__(self, "generated_files", tuple(self.generated_files))
        if self.repository_root is not None:
            object.__setattr__(
                self,
                "repository_root",
                Path(self.repository_root),
            )
        if self.source_bytes is not None:
            object.__setattr__(self, "source_bytes", bytes(self.source_bytes))


@dataclass(frozen=True, slots=True)
class Finding:
    code: str
    severity: GapSeverity
    message: str
    path: Path | None = None
    line: int | None = None


@dataclass(frozen=True, slots=True)
class SupersessionEntry:
    conflict_id: str
    old_ids: tuple[str, ...]
    resulting_id: str | None
    decision_date: str
    owner: str
    decision_source: str
    resolution: str
    decision_base_commit: str
    integration_evidence_sha256: str
    superseded_artifacts: tuple[str, ...]

    def __post_init__(self) -> None:
        object.__setattr__(self, "old_ids", tuple(self.old_ids))
        object.__setattr__(
            self,
            "superseded_artifacts",
            tuple(self.superseded_artifacts),
        )


@dataclass(frozen=True, slots=True)
class AuthorityReference:
    schema_version: int
    reference_id: str
    authority_class: AuthorityClass
    reference_kind: AuthorityReferenceKind
    source: str
    revision: str
    requirement_ids: tuple[str, ...]
    approval_state: str
    approved_by: str | None = None
    implementation_status: str | None = None
    authority_role: FigmaAuthorityRole | None = None

    def __post_init__(self) -> None:
        object.__setattr__(self, "requirement_ids", tuple(self.requirement_ids))


@dataclass(frozen=True, slots=True)
class TaskPackReference:
    schema_version: int
    pack_id: str
    source: str
    canon_revision: int
    canon_sha: str
    requirement_ids: tuple[str, ...]

    def __post_init__(self) -> None:
        object.__setattr__(self, "requirement_ids", tuple(self.requirement_ids))


@dataclass(frozen=True, slots=True)
class SpecificationGapRecord:
    gap_id: str
    severity: GapSeverity
    affected_ids: tuple[str, ...]
    message: str

    def __post_init__(self) -> None:
        object.__setattr__(self, "affected_ids", tuple(self.affected_ids))


@dataclass(frozen=True, slots=True)
class ImpactReferenceIndex:
    schema_version: int
    complete: bool
    authority_references: tuple[AuthorityReference, ...]
    task_packs: tuple[TaskPackReference, ...]
    specification_gaps: tuple[SpecificationGapRecord, ...]
    canon_revision: int | None = None
    indexed_requirement_ids: tuple[str, ...] = ()
    source_path: Path | None = None
    source_bytes: bytes | None = None
    source_sha: str | None = None

    def __post_init__(self) -> None:
        object.__setattr__(
            self,
            "authority_references",
            tuple(self.authority_references),
        )
        object.__setattr__(self, "task_packs", tuple(self.task_packs))
        object.__setattr__(
            self,
            "specification_gaps",
            tuple(self.specification_gaps),
        )
        object.__setattr__(
            self,
            "indexed_requirement_ids",
            tuple(self.indexed_requirement_ids),
        )
        if self.source_path is not None:
            object.__setattr__(self, "source_path", Path(self.source_path))
        if self.source_bytes is not None:
            object.__setattr__(self, "source_bytes", bytes(self.source_bytes))


@dataclass(frozen=True, slots=True)
class CanonRegistry:
    manifest: CanonManifest
    documents: tuple[CanonDocument, ...]
    requirements: tuple[Requirement, ...]
    concept_owners: tuple[tuple[str, str], ...]
    superseded_ids: frozenset[str]
    supersession_entries: tuple[SupersessionEntry, ...] = ()
    supersession_ledger_complete: bool = False
    supersession_ledger_bytes: bytes | None = None
    reference_index: ImpactReferenceIndex | None = None

    def __post_init__(self) -> None:
        object.__setattr__(self, "documents", tuple(self.documents))
        object.__setattr__(self, "requirements", tuple(self.requirements))
        object.__setattr__(
            self,
            "concept_owners",
            tuple(tuple(pair) for pair in self.concept_owners),
        )
        object.__setattr__(self, "superseded_ids", frozenset(self.superseded_ids))
        object.__setattr__(
            self,
            "supersession_entries",
            tuple(self.supersession_entries),
        )
        if self.supersession_ledger_bytes is not None:
            object.__setattr__(
                self,
                "supersession_ledger_bytes",
                bytes(self.supersession_ledger_bytes),
            )
