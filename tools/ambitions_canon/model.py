"""Immutable data contracts for the Ambitions canon compiler."""

from __future__ import annotations

import unicodedata
from dataclasses import dataclass
from enum import StrEnum
from pathlib import Path


# Attribution follows Python 3.12's Unicode 15.0.0 semantics on every
# supported host (Python 3.12 through 3.14).
# Upgrade this policy only by regenerating all checked-in range tables from
# authoritative UCD data and proving supported-host equivalence in tests. Never
# infer attribution behavior from the host's unicodedata.unidata_version.
ATTRIBUTION_UNICODE_POLICY_VERSION = "15.0.0"

# Unicode 15.0.0 DerivedCoreProperties.txt, property
# Default_Ignorable_Code_Point (4,174 code points across 27 ranges):
# https://www.unicode.org/Public/15.0.0/ucd/DerivedCoreProperties.txt
_DEFAULT_IGNORABLE_CODE_POINT_RANGES = (
    (0x00AD, 0x00AD),
    (0x034F, 0x034F),
    (0x061C, 0x061C),
    (0x115F, 0x1160),
    (0x17B4, 0x17B5),
    (0x180B, 0x180D),
    (0x180E, 0x180E),
    (0x180F, 0x180F),
    (0x200B, 0x200F),
    (0x202A, 0x202E),
    (0x2060, 0x2064),
    (0x2065, 0x2065),
    (0x2066, 0x206F),
    (0x3164, 0x3164),
    (0xFE00, 0xFE0F),
    (0xFEFF, 0xFEFF),
    (0xFFA0, 0xFFA0),
    (0xFFF0, 0xFFF8),
    (0x1BCA0, 0x1BCA3),
    (0x1D173, 0x1D17A),
    (0xE0000, 0xE0000),
    (0xE0001, 0xE0001),
    (0xE0002, 0xE001F),
    (0xE0020, 0xE007F),
    (0xE0080, 0xE00FF),
    (0xE0100, 0xE01EF),
    (0xE01F0, 0xE0FFF),
)

# Unicode 16.0.0 DerivedAge.txt, property Age=15.1 (627 code points
# across 3 ranges).
# https://www.unicode.org/Public/16.0.0/ucd/DerivedAge.txt
_UNICODE_15_1_ASSIGNED_RANGES = (
    (0x2FFC, 0x2FFF),
    (0x31EF, 0x31EF),
    (0x2EBF0, 0x2EE5D),
)

# Unicode 16.0.0 DerivedAge.txt, property Age=16.0 (5,185 code points
# across 47 ranges). Rejecting every scalar assigned after Unicode 15 before
# host normalization/category checks makes newer Python runtimes emulate the
# pinned Python 3.12 policy without a network or third-party dependency.
# https://www.unicode.org/Public/16.0.0/ucd/DerivedAge.txt
_UNICODE_16_ASSIGNED_RANGES = (
    (0x0897, 0x0897),
    (0x1B4E, 0x1B4F),
    (0x1B7F, 0x1B7F),
    (0x1C89, 0x1C8A),
    (0x2427, 0x2429),
    (0x31E4, 0x31E5),
    (0xA7CB, 0xA7CD),
    (0xA7DA, 0xA7DC),
    (0x105C0, 0x105F3),
    (0x10D40, 0x10D65),
    (0x10D69, 0x10D85),
    (0x10D8E, 0x10D8F),
    (0x10EC2, 0x10EC4),
    (0x10EFC, 0x10EFC),
    (0x11380, 0x11389),
    (0x1138B, 0x1138B),
    (0x1138E, 0x1138E),
    (0x11390, 0x113B5),
    (0x113B7, 0x113C0),
    (0x113C2, 0x113C2),
    (0x113C5, 0x113C5),
    (0x113C7, 0x113CA),
    (0x113CC, 0x113D5),
    (0x113D7, 0x113D8),
    (0x113E1, 0x113E2),
    (0x116D0, 0x116E3),
    (0x11BC0, 0x11BE1),
    (0x11BF0, 0x11BF9),
    (0x11F5A, 0x11F5A),
    (0x13460, 0x143FA),
    (0x16100, 0x16139),
    (0x16D40, 0x16D79),
    (0x18CFF, 0x18CFF),
    (0x1CC00, 0x1CCF9),
    (0x1CD00, 0x1CEB3),
    (0x1E5D0, 0x1E5FA),
    (0x1E5FF, 0x1E5FF),
    (0x1F8B2, 0x1F8BB),
    (0x1F8C0, 0x1F8C1),
    (0x1FA89, 0x1FA89),
    (0x1FA8F, 0x1FA8F),
    (0x1FABE, 0x1FABE),
    (0x1FAC6, 0x1FAC6),
    (0x1FADC, 0x1FADC),
    (0x1FADF, 0x1FADF),
    (0x1FAE9, 0x1FAE9),
    (0x1FBCB, 0x1FBEF),
)


def _is_in_ranges(
    character: str,
    ranges: tuple[tuple[int, int], ...],
) -> bool:
    code_point = ord(character)
    for lower, upper in ranges:
        if code_point < lower:
            return False
        if code_point <= upper:
            return True
    return False


def _validate_attribution_scalars(value: str) -> None:
    for ranges in (
        _UNICODE_15_1_ASSIGNED_RANGES,
        _UNICODE_16_ASSIGNED_RANGES,
    ):
        if any(_is_in_ranges(character, ranges) for character in value):
            raise ValueError("attribution contains a post-Unicode-15.0 code point")
    if any(unicodedata.category(character).startswith("C") for character in value):
        raise ValueError("attribution contains a Unicode control category")
    if any(
        _is_in_ranges(character, _DEFAULT_IGNORABLE_CODE_POINT_RANGES)
        for character in value
    ):
        raise ValueError("attribution contains a default-ignorable code point")


def normalize_visible_attribution(value: object) -> str:
    """Return NFKC, space-collapsed visible attribution or reject it."""

    if not isinstance(value, str):
        raise ValueError("attribution must be a string")
    _validate_attribution_scalars(value)
    normalized = unicodedata.normalize("NFKC", value)
    _validate_attribution_scalars(normalized)
    visible = " ".join(normalized.split())
    if not visible:
        raise ValueError("attribution must contain visible text")
    if not any(
        unicodedata.category(character)[0] in "LNPS"
        for character in visible
    ):
        raise ValueError("attribution must contain a visible base scalar")
    return visible


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
    visual_authority_id: str | None = None
    canon_revision: int | None = None
    frame_version: str | None = None
    swiftui_plausibility: str | None = None
    accessibility_variants: tuple[str, ...] = ()
    reconciliation_status: str | None = None

    def __post_init__(self) -> None:
        object.__setattr__(self, "requirement_ids", tuple(self.requirement_ids))
        object.__setattr__(
            self,
            "accessibility_variants",
            tuple(self.accessibility_variants),
        )


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
