"""Typed lifecycle document records; no arbitrary metadata is retained."""

from __future__ import annotations

from dataclasses import dataclass
from enum import Enum
from pathlib import Path

from .errors import Diagnostic


class DocumentType(str, Enum):
    RESEARCH = "research"
    SCOPE = "scope"
    DESIGN = "design"


class AuthorityClass(str, Enum):
    EVIDENCE = "evidence"
    PRODUCT_COMMITMENT = "product-commitment"
    IMPLEMENTATION_DESIGN = "implementation-design"


class DocumentStatus(str, Enum):
    DRAFT = "draft"
    SEALED = "sealed"
    CONTENT_REVIEWED = "content-reviewed"
    NEEDS_REVISION = "needs-revision"
    PASSED = "passed"
    STALE = "stale"
    SUPERSEDED = "superseded"


class ReviewLane(str, Enum):
    CONTENT = "content"
    CONSUMER = "consumer"


class ReviewVerdict(str, Enum):
    UNREVIEWED = "unreviewed"
    PASS = "pass"
    NEEDS_REVISION = "needs-revision"


class InputKind(str, Enum):
    LIFECYCLE_DOCUMENT = "lifecycle-document"
    CANON = "canon"
    APPROVED_DESIGN = "approved-design"
    REPOSITORY_EVIDENCE = "repository-evidence"


@dataclass(frozen=True, init=False)
class InputBinding:
    kind: InputKind
    authority_id: str
    path: str
    commit: str
    revision: int | None = None
    contract_hash: str | None = None

    def __init__(
        self,
        kind: InputKind,
        authority_id: str,
        path: str,
        revision: int | None = None,
        contract_hash: str | None = None,
        commit: str | None = None,
    ) -> None:
        if not isinstance(commit, str):
            raise TypeError("InputBinding.commit must be a required string")
        object.__setattr__(self, "kind", kind)
        object.__setattr__(self, "authority_id", authority_id)
        object.__setattr__(self, "path", path)
        object.__setattr__(self, "revision", revision)
        object.__setattr__(self, "contract_hash", contract_hash)
        object.__setattr__(self, "commit", commit)


@dataclass(frozen=True)
class EvidenceFile:
    path: str
    sha256: str
    role: str


@dataclass(frozen=True)
class DocumentMetadata:
    schema_version: int
    template_version: str
    template_hash: str
    skill_version: str
    skill_package_hash: str
    authoring_surface: str
    initiative_id: str
    document_id: str
    document_type: DocumentType
    authority_class: AuthorityClass
    entry_point: str
    status: DocumentStatus
    revision: int
    created_at: str
    updated_at: str
    repository_baseline_commit: str
    external_research_as_of: str
    contract_hash: str
    content_review_verdict: ReviewVerdict
    content_review_revision: int
    content_review_hash: str
    content_blocking_findings: int
    consumer_review_verdict: ReviewVerdict
    consumer_review_revision: int
    consumer_review_hash: str
    consumer_blocking_findings: int
    canon_targets: tuple[str, ...]
    canon_delta_ids: tuple[str, ...]
    source_owner_paths: tuple[str, ...]
    test_owner_paths: tuple[str, ...]
    dependency_paths: tuple[str, ...]
    additional_freshness_paths: tuple[str, ...]
    freshness_paths: tuple[str, ...]
    supersedes: tuple[str, ...]
    inputs: tuple[InputBinding, ...]
    evidence_files: tuple[EvidenceFile, ...]


@dataclass(frozen=True)
class Section:
    heading: str
    body: str
    heading_ending: str = "\n"


@dataclass(frozen=True)
class LifecycleDocument:
    metadata: DocumentMetadata
    sections: tuple[Section, ...]
    source_path: Path | None = None
    body_prefix: str = ""


@dataclass(frozen=True)
class ReviewRecord:
    review_id: str
    lane: ReviewLane
    verdict: ReviewVerdict
    reviewed_revision: int
    reviewed_contract_hash: str
    reviewer_surface: str
    reviewed_at: str
    blocking_findings: tuple[str, ...]
    non_blocking_improvements: tuple[str, ...]
    traceability_gaps: tuple[str, ...]
    stale_or_conflicting_inputs: tuple[str, ...]
    required_revisions: tuple[str, ...]
    next_permitted_lifecycle_phase: str


@dataclass(frozen=True)
class DriftAssessment:
    baseline_commit: str
    head_commit: str
    changed_freshness_paths: tuple[str, ...]
    unrelated_paths: tuple[str, ...]
    verdict: ReviewVerdict
    rationale: str


@dataclass(frozen=True)
class ValidationReport:
    document_id: str
    revision: int
    contract_hash: str
    diagnostics: tuple[Diagnostic, ...]
    valid: bool


@dataclass(frozen=True)
class ConsumptionReport:
    document_id: str
    revision: int
    contract_hash: str
    lane: ReviewLane
    verdict: ReviewVerdict
    blockers: tuple[str, ...]
    next_permitted_lifecycle_phase: str
