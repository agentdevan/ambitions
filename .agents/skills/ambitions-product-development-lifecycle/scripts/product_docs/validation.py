"""Deterministic structure, freshness, source, and traceability validation."""

from __future__ import annotations

from collections import Counter
import hashlib
from pathlib import Path
import re

from .constants import (
    AUTHORITY_CLASSES,
    GENERATED_CANON_PATHS,
    SKILL_ROOT,
    TEMPLATE_PROFILES,
)
from .errors import Diagnostic, ProductDocsError
from .hashing import compute_contract_hash
from .markdown import parse_markdown_table
from .models import (
    DocumentMetadata,
    DocumentStatus,
    DocumentType,
    LifecycleDocument,
    ReviewVerdict,
    Section,
    ValidationReport,
)
from .package_identity import TEMPLATE_PATHS
from .repository import GitRepository


_HASH = re.compile(r"sha256:[0-9a-f]{64}\Z")
_RAW_HASH = re.compile(r"[0-9a-f]{64}\Z")
_WORD = re.compile(r"\b[\w'-]+\b", re.UNICODE)
_DRAFT_SENTINEL = "PRODUCT-DOC-DRAFT:"
_ID_NAMES = (
    "FIND",
    "SRC",
    "RISK",
    "REQ",
    "AC",
    "DESIGN",
    "VERIFY",
    "CANON-DELTA",
    "SEAM",
)
_ID_PATTERNS = {
    name: re.compile(rf"{re.escape(name)}-([0-9]{{3}})\Z") for name in _ID_NAMES
}
_TOKEN_PATTERNS = {
    name: re.compile(rf"(?<![A-Z0-9-]){re.escape(name)}-[0-9]{{3}}(?![A-Z0-9-])")
    for name in _ID_NAMES
}
_DEFINITION_COLUMNS = {
    "Findings": ("Finding ID", "FIND"),
    "Source ledger": ("Source ID", "SRC"),
    "Product requirements": ("Requirement ID", "REQ"),
    "Acceptance criteria": ("Acceptance ID", "AC"),
    "Canon impact and proposed canon deltas": ("Canon delta ID", "CANON-DELTA"),
    "Implementation seams and dependency order": ("Seam ID", "SEAM"),
}


def _diagnostic(
    code: str,
    message: str,
    *,
    section: str | None = None,
    identifier: str | None = None,
    path: str | None = None,
) -> Diagnostic:
    return Diagnostic(code, message, path=path, section=section, identifier=identifier)


def _active_template_path(metadata: DocumentMetadata) -> str:
    relative = TEMPLATE_PATHS.get(metadata.template_version)
    if relative is None:
        return f"{SKILL_ROOT}/assets/templates/v1/{metadata.document_type.value}.md"
    return f"{SKILL_ROOT}/{relative}"


def derive_freshness_paths(
    metadata: DocumentMetadata,
    *,
    active_template_path: str | None = None,
) -> tuple[str, ...]:
    """Return the non-weakenable version-one freshness union."""
    paths = {
        *metadata.canon_targets,
        *metadata.source_owner_paths,
        *metadata.test_owner_paths,
        *metadata.dependency_paths,
        *metadata.additional_freshness_paths,
        *(binding.path for binding in metadata.inputs),
        *(evidence.path for evidence in metadata.evidence_files),
        f"{SKILL_ROOT}/package-manifest.json",
        active_template_path or _active_template_path(metadata),
    }
    if metadata.canon_targets:
        paths.update(GENERATED_CANON_PATHS)
    return tuple(sorted(paths))


def _section(document: LifecycleDocument, heading: str) -> Section | None:
    return next(
        (section for section in document.sections if section.heading == heading), None
    )


def _tables(section: Section | None) -> tuple[tuple[dict[str, str], ...], ...]:
    if section is None:
        return ()
    blocks: list[str] = []
    current: list[str] = []
    for line in section.body.splitlines():
        if line.strip().startswith("|") and line.strip().endswith("|"):
            current.append(line.strip())
        elif current:
            blocks.append("\n".join(current))
            current = []
    if current:
        blocks.append("\n".join(current))
    parsed = []
    for block in blocks:
        try:
            parsed.append(parse_markdown_table(block))
        except ProductDocsError:
            continue
    return tuple(parsed)


def _rows(document: LifecycleDocument, heading: str) -> tuple[dict[str, str], ...]:
    tables = _tables(_section(document, heading))
    return tuple(row for table in tables for row in table)


def _section_has_authority_content(section: Section) -> bool:
    non_table_lines = [
        line.strip()
        for line in section.body.splitlines()
        if line.strip()
        and not line.strip().startswith("|")
        and not re.fullmatch(r"<!--.*-->", line.strip())
    ]
    if non_table_lines:
        return True
    tables = _tables(section)
    return any(table for table in tables)


def _id_valid(identifier: str, kind: str) -> bool:
    match = _ID_PATTERNS[kind].fullmatch(identifier.strip())
    return match is not None and int(match.group(1)) != 0


def _ids(text: str, kind: str) -> tuple[str, ...]:
    return tuple(match.group(0) for match in _TOKEN_PATTERNS[kind].finditer(text))


def _review_lane_is_clear(
    verdict: ReviewVerdict, revision: int, contract_hash: str, blockers: int
) -> bool:
    return (
        verdict is ReviewVerdict.UNREVIEWED
        and revision == 0
        and contract_hash == ""
        and blockers == 0
    )


def _review_lane_is_pass(
    verdict: ReviewVerdict,
    review_revision: int,
    review_hash: str,
    blockers: int,
    metadata: DocumentMetadata,
) -> bool:
    return (
        verdict is ReviewVerdict.PASS
        and review_revision == metadata.revision
        and review_hash == metadata.contract_hash
        and blockers == 0
    )


def _review_lane_needs_revision(
    verdict: ReviewVerdict,
    review_revision: int,
    review_hash: str,
    blockers: int,
    metadata: DocumentMetadata,
) -> bool:
    return (
        verdict is ReviewVerdict.NEEDS_REVISION
        and review_revision == metadata.revision
        and review_hash == metadata.contract_hash
        and blockers > 0
    )


def _validate_review_state(metadata: DocumentMetadata) -> bool:
    content_clear = _review_lane_is_clear(
        metadata.content_review_verdict,
        metadata.content_review_revision,
        metadata.content_review_hash,
        metadata.content_blocking_findings,
    )
    consumer_clear = _review_lane_is_clear(
        metadata.consumer_review_verdict,
        metadata.consumer_review_revision,
        metadata.consumer_review_hash,
        metadata.consumer_blocking_findings,
    )
    content_pass = _review_lane_is_pass(
        metadata.content_review_verdict,
        metadata.content_review_revision,
        metadata.content_review_hash,
        metadata.content_blocking_findings,
        metadata,
    )
    consumer_pass = _review_lane_is_pass(
        metadata.consumer_review_verdict,
        metadata.consumer_review_revision,
        metadata.consumer_review_hash,
        metadata.consumer_blocking_findings,
        metadata,
    )
    content_revision = _review_lane_needs_revision(
        metadata.content_review_verdict,
        metadata.content_review_revision,
        metadata.content_review_hash,
        metadata.content_blocking_findings,
        metadata,
    )
    consumer_revision = _review_lane_needs_revision(
        metadata.consumer_review_verdict,
        metadata.consumer_review_revision,
        metadata.consumer_review_hash,
        metadata.consumer_blocking_findings,
        metadata,
    )
    if metadata.status in (DocumentStatus.DRAFT, DocumentStatus.SEALED):
        return content_clear and consumer_clear
    if metadata.status is DocumentStatus.CONTENT_REVIEWED:
        return content_pass and consumer_clear
    if metadata.status is DocumentStatus.PASSED:
        return content_pass and consumer_pass
    if metadata.status is DocumentStatus.NEEDS_REVISION:
        return content_revision or consumer_revision
    return True


def _definition_ids(document: LifecycleDocument) -> tuple[tuple[str, str, str], ...]:
    definitions = []
    for heading, (column, kind) in _DEFINITION_COLUMNS.items():
        for row in _rows(document, heading):
            if column in row:
                definitions.append((row[column].strip(), kind, heading))
    return tuple(definitions)


def validate_structure(document: LifecycleDocument) -> tuple[Diagnostic, ...]:
    """Validate immutable headings, completeness, IDs, hashes, and state bindings."""
    diagnostics: list[Diagnostic] = []
    metadata = document.metadata
    expected_headings = TEMPLATE_PROFILES.get(metadata.document_type.value, ())
    headings = tuple(section.heading for section in document.sections)
    if headings != expected_headings:
        diagnostics.append(
            _diagnostic(
                "section-order-mismatch",
                "Document headings must match its template profile",
            )
        )
    for section in document.sections:
        if _DRAFT_SENTINEL in section.body:
            diagnostics.append(
                _diagnostic(
                    "draft-sentinel",
                    "Draft sentinel remains in an authority section",
                    section=section.heading,
                )
            )
        if section.heading != "Review history" and not _section_has_authority_content(
            section
        ):
            diagnostics.append(
                _diagnostic(
                    "empty-section",
                    "Authority sections must not be empty",
                    section=section.heading,
                )
            )
    summary = _section(document, "Agent handoff summary")
    if summary is not None and len(_WORD.findall(summary.body)) > 1200:
        diagnostics.append(
            _diagnostic(
                "summary-too-long",
                "Agent handoff summary exceeds 1,200 words",
                section=summary.heading,
            )
        )
    expected_authority = AUTHORITY_CLASSES.get(metadata.document_type.value)
    if (
        expected_authority != metadata.authority_class.value
        or metadata.entry_point != metadata.document_type.value
    ):
        diagnostics.append(
            _diagnostic(
                "authority-class-mismatch",
                "Document type, authority class, and entry point must use the exact phase mapping",
            )
        )

    definitions = _definition_ids(document)
    for identifier, kind, heading in definitions:
        if not _id_valid(identifier, kind):
            diagnostics.append(
                _diagnostic(
                    "invalid-id",
                    f"{kind} IDs must be anchored nonzero three-digit IDs",
                    section=heading,
                    identifier=identifier,
                )
            )
    counts = Counter(identifier for identifier, _, _ in definitions)
    for identifier, count in counts.items():
        if identifier and count > 1:
            diagnostics.append(
                _diagnostic(
                    "duplicate-id",
                    "Primary stable IDs must be unique",
                    identifier=identifier,
                )
            )
    body = "\n".join(
        section.body
        for section in document.sections
        if section.heading != "Review history"
    )
    for kind in _ID_NAMES:
        zero = f"{kind}-000"
        if zero in _ids(body, kind):
            diagnostics.append(
                _diagnostic(
                    "invalid-id",
                    f"{zero} is reserved and cannot be used",
                    identifier=zero,
                )
            )

    prefixed_hashes = (
        ("template_hash", metadata.template_hash),
        ("skill_package_hash", metadata.skill_package_hash),
        *(
            ("inputs.contract_hash", binding.contract_hash)
            for binding in metadata.inputs
            if binding.contract_hash is not None
        ),
    )
    for field, value in prefixed_hashes:
        if value and not _HASH.fullmatch(value):
            diagnostics.append(
                _diagnostic(
                    "malformed-hash", f"{field} must be lowercase sha256:<64 hex>"
                )
            )
    for evidence in metadata.evidence_files:
        if not _RAW_HASH.fullmatch(evidence.sha256):
            diagnostics.append(
                _diagnostic(
                    "malformed-hash",
                    "Evidence sha256 must be 64 lowercase hexadecimal characters",
                    path=evidence.path,
                )
            )
    if metadata.status is not DocumentStatus.DRAFT:
        if not _HASH.fullmatch(metadata.contract_hash):
            diagnostics.append(
                _diagnostic(
                    "malformed-hash",
                    "Sealed lifecycle states require a lowercase contract hash",
                )
            )
        elif metadata.contract_hash != compute_contract_hash(document):
            diagnostics.append(
                _diagnostic(
                    "contract-hash-mismatch",
                    "Stored contract hash does not match authority-bearing content",
                )
            )
    elif metadata.contract_hash:
        diagnostics.append(
            _diagnostic(
                "invalid-draft-state", "Draft documents must not carry a contract hash"
            )
        )
    if not _validate_review_state(metadata):
        diagnostics.append(
            _diagnostic(
                "invalid-review-state",
                "Review verdicts, revisions, hashes, and blockers do not match document state",
            )
        )
    expected_freshness = derive_freshness_paths(metadata)
    if metadata.status is DocumentStatus.DRAFT:
        if metadata.freshness_paths:
            diagnostics.append(
                _diagnostic(
                    "freshness-mismatch",
                    "New draft freshness must remain empty until seal",
                )
            )
    elif metadata.freshness_paths != expected_freshness:
        diagnostics.append(
            _diagnostic(
                "freshness-mismatch",
                "Freshness paths must equal the complete sorted derived set",
            )
        )
    return tuple(diagnostics)


def validate_sources(document: LifecycleDocument) -> tuple[Diagnostic, ...]:
    """Validate research finding support and complete source ledger records."""
    if document.metadata.document_type is not DocumentType.RESEARCH:
        return ()
    diagnostics: list[Diagnostic] = []
    finding_rows = _rows(document, "Findings")
    source_rows = _rows(document, "Source ledger")
    source_ids = {
        row.get("Source ID", "").strip()
        for row in source_rows
        if _id_valid(row.get("Source ID", ""), "SRC")
    }
    finding_ids = {
        row.get("Finding ID", "").strip()
        for row in finding_rows
        if _id_valid(row.get("Finding ID", ""), "FIND")
    }
    repository_evidence = {
        *document.metadata.canon_targets,
        *document.metadata.source_owner_paths,
        *document.metadata.test_owner_paths,
        *document.metadata.dependency_paths,
        *document.metadata.additional_freshness_paths,
        *(binding.path for binding in document.metadata.inputs),
        *(evidence.path for evidence in document.metadata.evidence_files),
    }
    for row in finding_rows:
        identifier = row.get("Finding ID", "").strip()
        support = row.get("Source IDs", "")
        references = _ids(support, "SRC")
        unresolved = [
            reference for reference in references if reference not in source_ids
        ]
        has_repository_evidence = any(path in support for path in repository_evidence)
        if unresolved or (not references and not has_repository_evidence):
            diagnostics.append(
                _diagnostic(
                    "unresolved-source",
                    "Every finding must resolve to Source ledger IDs or declared repository evidence",
                    section="Findings",
                    identifier=identifier,
                )
            )
    required_source_columns = (
        "Source ID",
        "Title or repository path",
        "Accessed",
        "Temporal sensitivity",
        "Recheck trigger",
        "Supports",
        "Evidence summary",
    )
    for row in source_rows:
        identifier = row.get("Source ID", "").strip()
        if any(not row.get(column, "").strip() for column in required_source_columns):
            diagnostics.append(
                _diagnostic(
                    "incomplete-source",
                    "Source ledger records require provenance, freshness, support, and summary detail",
                    section="Source ledger",
                    identifier=identifier,
                )
            )
        supported = _ids(row.get("Supports", ""), "FIND")
        if not supported or any(
            reference not in finding_ids for reference in supported
        ):
            diagnostics.append(
                _diagnostic(
                    "source-support-mismatch",
                    "Source ledger support IDs must resolve to findings",
                    section="Source ledger",
                    identifier=identifier,
                )
            )
        title = row.get("Title or repository path", "").strip()
        if not row.get("Publisher", "").strip() and title not in repository_evidence:
            diagnostics.append(
                _diagnostic(
                    "incomplete-source",
                    "External sources require a publisher; repository sources require a declared path",
                    section="Source ledger",
                    identifier=identifier,
                )
            )
    return tuple(diagnostics)


def _scope_traceability(document: LifecycleDocument) -> tuple[Diagnostic, ...]:
    diagnostics: list[Diagnostic] = []
    requirements = _rows(document, "Product requirements")
    acceptances = _rows(document, "Acceptance criteria")
    acceptance_ids = {
        row.get("Acceptance ID", "").strip()
        for row in acceptances
        if _id_valid(row.get("Acceptance ID", ""), "AC")
    }
    requirement_ids = {
        row.get("Requirement ID", "").strip()
        for row in requirements
        if _id_valid(row.get("Requirement ID", ""), "REQ")
    }
    for row in requirements:
        identifier = row.get("Requirement ID", "").strip()
        if (
            not row.get("Observable obligation", "").strip()
            or not row.get("Owner domain", "").strip()
        ):
            diagnostics.append(
                _diagnostic(
                    "incomplete-requirement",
                    "Requirements need an observable obligation and owner domain",
                    section="Product requirements",
                    identifier=identifier,
                )
            )
        authority = row.get("Finding or authority IDs", "").strip()
        if not authority:
            diagnostics.append(
                _diagnostic(
                    "missing-requirement-authority",
                    "Requirements must cite findings or authority",
                    section="Product requirements",
                    identifier=identifier,
                )
            )
        else:
            authority_ids = {
                binding.authority_id for binding in document.metadata.inputs
            }
            references = tuple(
                token.strip("`")
                for token in re.split(r"[,;\s]+", authority)
                if token.strip("`")
            )
            if not references or any(
                not _id_valid(reference, "FIND") and reference not in authority_ids
                for reference in references
            ):
                diagnostics.append(
                    _diagnostic(
                        "unresolved-requirement-authority",
                        "Requirement authority references must be finding IDs or declared input authority IDs",
                        section="Product requirements",
                        identifier=identifier,
                    )
                )
        mapped_acceptance = _ids(row.get("Acceptance IDs", ""), "AC")
        if not mapped_acceptance or any(
            reference not in acceptance_ids for reference in mapped_acceptance
        ):
            diagnostics.append(
                _diagnostic(
                    "unresolved-acceptance",
                    "Requirement acceptance IDs must resolve",
                    section="Product requirements",
                    identifier=identifier,
                )
            )
    for row in acceptances:
        identifier = row.get("Acceptance ID", "").strip()
        if (
            not row.get("Verifiable condition", "").strip()
            or not row.get("Required evidence", "").strip()
        ):
            diagnostics.append(
                _diagnostic(
                    "incomplete-acceptance",
                    "Acceptance criteria require an inspectable condition and evidence",
                    section="Acceptance criteria",
                    identifier=identifier,
                )
            )

    delta_rows = _rows(document, "Canon impact and proposed canon deltas")
    delta_ids = {row.get("Canon delta ID", "").strip() for row in delta_rows}
    if set(document.metadata.canon_delta_ids) != delta_ids:
        diagnostics.append(
            _diagnostic(
                "canon-delta-mismatch",
                "Frontmatter canon delta IDs must exactly match detailed delta rows",
                section="Canon impact and proposed canon deltas",
            )
        )
    required_delta_columns = (
        "Current authority",
        "Proposed change",
        "Rationale",
        "Requirement IDs",
        "Migration or compatibility impact",
        "Proof obligation",
    )
    for row in delta_rows:
        identifier = row.get("Canon delta ID", "").strip()
        requirement_refs = _ids(row.get("Requirement IDs", ""), "REQ")
        if (
            any(not row.get(column, "").strip() for column in required_delta_columns)
            or not requirement_refs
            or any(reference not in requirement_ids for reference in requirement_refs)
        ):
            diagnostics.append(
                _diagnostic(
                    "incomplete-canon-delta",
                    "Canon deltas require authority, proposed change, rationale, affected requirements, compatibility impact, and proof",
                    section="Canon impact and proposed canon deltas",
                    identifier=identifier,
                )
            )
    return tuple(diagnostics)


def _design_traceability(document: LifecycleDocument) -> tuple[Diagnostic, ...]:
    diagnostics: list[Diagnostic] = []
    trace_rows = _rows(document, "Requirement-to-design traceability")
    traced_requirements: set[str] = set()
    traced_acceptances: set[str] = set()
    traced_designs: set[str] = set()
    for row in trace_rows:
        requirement = row.get("Requirement ID", "").strip()
        acceptance = row.get("Acceptance ID", "").strip()
        design = row.get("Design ID", "").strip()
        verification = row.get("Verification ID", "").strip()
        authority = row.get("Finding or authority ID", "").strip()
        if _id_valid(requirement, "REQ"):
            traced_requirements.add(requirement)
        if _id_valid(acceptance, "AC"):
            traced_acceptances.add(acceptance)
        if _id_valid(design, "DESIGN"):
            traced_designs.add(design)
        if (
            not authority
            or not _id_valid(requirement, "REQ")
            or not _id_valid(acceptance, "AC")
        ):
            diagnostics.append(
                _diagnostic(
                    "incomplete-design-trace",
                    "Design trace rows require authority, requirement, and acceptance IDs",
                    section="Requirement-to-design traceability",
                    identifier=design,
                )
            )
        if not _id_valid(design, "DESIGN") or not _id_valid(verification, "VERIFY"):
            diagnostics.append(
                _diagnostic(
                    "unverified-design",
                    "Each design decision must map to requirement, acceptance, and verification IDs",
                    section="Requirement-to-design traceability",
                    identifier=design,
                )
            )

    authority_body = "\n".join(
        section.body
        for section in document.sections
        if section.heading != "Review history"
    )
    all_requirements = set(_ids(authority_body, "REQ"))
    all_acceptances = set(_ids(authority_body, "AC"))
    all_designs = set(_ids(authority_body, "DESIGN"))
    if not all_requirements.issubset(
        traced_requirements
    ) or not all_acceptances.issubset(traced_acceptances):
        diagnostics.append(
            _diagnostic(
                "incomplete-design-coverage",
                "Every referenced requirement and acceptance must appear in design traceability",
                section="Requirement-to-design traceability",
            )
        )
    if not all_designs.issubset(traced_designs):
        diagnostics.append(
            _diagnostic(
                "unverified-design",
                "Every design decision must appear in design traceability",
                section="Requirement-to-design traceability",
            )
        )

    for row in _rows(document, "Implementation seams and dependency order"):
        identifier = row.get("Seam ID", "").strip()
        verification_ids = _ids(row.get("Verification IDs", ""), "VERIFY")
        if not _id_valid(identifier, "SEAM") or not verification_ids:
            diagnostics.append(
                _diagnostic(
                    "unverified-seam",
                    "Implementation seams require anchored IDs and verification mappings",
                    section="Implementation seams and dependency order",
                    identifier=identifier,
                )
            )
    return tuple(diagnostics)


def validate_traceability(document: LifecycleDocument) -> tuple[Diagnostic, ...]:
    """Validate phase-specific source-to-requirement-to-proof mappings."""
    if document.metadata.document_type is DocumentType.SCOPE:
        return _scope_traceability(document)
    if document.metadata.document_type is DocumentType.DESIGN:
        return _design_traceability(document)
    return ()


def _repository_diagnostics(
    document: LifecycleDocument, root: Path | str
) -> tuple[Diagnostic, ...]:
    diagnostics: list[Diagnostic] = []
    repository = GitRepository(root)
    baseline = document.metadata.repository_baseline_commit
    try:
        reachable = repository.is_commit_reachable(baseline)
    except ProductDocsError as error:
        return error.diagnostics
    if not reachable:
        return (
            _diagnostic(
                "unreachable-baseline",
                "Repository baseline commit is not reachable",
                identifier=baseline,
            ),
        )

    declared_paths = {
        *document.metadata.canon_targets,
        *document.metadata.source_owner_paths,
        *document.metadata.test_owner_paths,
        *document.metadata.dependency_paths,
        *document.metadata.additional_freshness_paths,
        *(binding.path for binding in document.metadata.inputs),
    }
    for path in sorted(declared_paths):
        if not repository.path_exists_at(baseline, path):
            diagnostics.append(
                _diagnostic(
                    "baseline-path-missing",
                    "Declared authority path does not exist at the document baseline",
                    path=path,
                )
            )
    for evidence in document.metadata.evidence_files:
        if repository.has_worktree_change(evidence.path):
            diagnostics.append(
                _diagnostic(
                    "uncommitted-evidence",
                    "Evidence files must have no uncommitted change",
                    path=evidence.path,
                )
            )
            continue
        if not repository.path_exists_at(baseline, evidence.path):
            diagnostics.append(
                _diagnostic(
                    "baseline-path-missing",
                    "Evidence files must be committed at the document baseline",
                    path=evidence.path,
                )
            )
            continue
        actual = hashlib.sha256(
            repository.read_bytes_at(baseline, evidence.path)
        ).hexdigest()
        if actual != evidence.sha256:
            diagnostics.append(
                _diagnostic(
                    "evidence-hash-mismatch",
                    "Evidence digest does not match baseline bytes",
                    path=evidence.path,
                )
            )
    return tuple(diagnostics)


def validate_document(
    document: LifecycleDocument,
    *,
    repository_root: Path | str | None = None,
    active_template_path: str | None = None,
) -> ValidationReport:
    """Run every deterministic validation lane and return one stable report."""
    diagnostics = [
        *validate_structure(document),
        *validate_sources(document),
        *validate_traceability(document),
    ]
    if active_template_path is not None:
        expected = derive_freshness_paths(
            document.metadata, active_template_path=active_template_path
        )
        if (
            document.metadata.status is not DocumentStatus.DRAFT
            and document.metadata.freshness_paths != expected
        ):
            diagnostics.append(
                _diagnostic(
                    "freshness-mismatch",
                    "Freshness paths do not use the selected active template",
                )
            )
    if repository_root is not None:
        diagnostics.extend(_repository_diagnostics(document, repository_root))
    metadata = document.metadata
    return ValidationReport(
        document_id=metadata.document_id,
        revision=metadata.revision,
        contract_hash=metadata.contract_hash,
        diagnostics=tuple(diagnostics),
        valid=not diagnostics,
    )
