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
from .documents import parse_document
from .hashing import compute_contract_hash
from .markdown import parse_markdown_table
from .models import (
    ConsumptionReport,
    DocumentMetadata,
    DocumentStatus,
    DocumentType,
    InputKind,
    LifecycleDocument,
    ReviewLane,
    ReviewVerdict,
    Section,
    ValidationReport,
)
from .package_identity import TEMPLATE_PATHS, verify_historical_package
from .repository import GitRepository, validate_repository_path


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
_ALLOWED_REVIEW_LANES = {
    DocumentStatus.DRAFT: frozenset({("clear", "clear")}),
    DocumentStatus.SEALED: frozenset({("clear", "clear")}),
    DocumentStatus.CONTENT_REVIEWED: frozenset({("pass", "clear")}),
    DocumentStatus.NEEDS_REVISION: frozenset(
        {("needs-revision", "clear"), ("pass", "needs-revision")}
    ),
    DocumentStatus.PASSED: frozenset({("pass", "pass")}),
    DocumentStatus.STALE: frozenset({("pass", "pass")}),
    DocumentStatus.SUPERSEDED: frozenset(
        {
            ("clear", "clear"),
            ("pass", "clear"),
            ("needs-revision", "clear"),
            ("pass", "needs-revision"),
            ("pass", "pass"),
        }
    ),
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


def _parse_tables(
    section: Section | None,
) -> tuple[tuple[tuple[dict[str, str], ...], ...], tuple[Diagnostic, ...]]:
    if section is None:
        return (), ()
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
    diagnostics = []
    for block in blocks:
        try:
            parsed.append(parse_markdown_table(block))
        except ProductDocsError as error:
            diagnostics.extend(
                Diagnostic(
                    diagnostic.code,
                    diagnostic.message,
                    path=diagnostic.path,
                    section=section.heading,
                    identifier=diagnostic.identifier,
                    remediation=diagnostic.remediation,
                )
                for diagnostic in error.diagnostics
            )
    return tuple(parsed), tuple(diagnostics)


def _tables(section: Section | None) -> tuple[tuple[dict[str, str], ...], ...]:
    return _parse_tables(section)[0]


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


def _structured_references(text: str) -> tuple[str, ...]:
    normalized = re.sub(r"<br\s*/?>", "\n", text, flags=re.IGNORECASE)
    references = []
    for part in re.split(r"[,;\n]+", normalized):
        candidate = part.strip().strip("`").strip()
        if not candidate:
            continue
        words = candidate.split()
        if len(words) > 1 and all(
            any(_id_valid(word.strip("`"), kind) for kind in _ID_NAMES)
            for word in words
        ):
            references.extend(word.strip("`") for word in words)
        else:
            references.append(candidate)
    return tuple(references)


def _review_lane_state(
    verdict: ReviewVerdict,
    revision: int,
    contract_hash: str,
    blockers: int,
    metadata: DocumentMetadata,
) -> str | None:
    if (
        verdict is ReviewVerdict.UNREVIEWED
        and revision == 0
        and contract_hash == ""
        and blockers == 0
    ):
        return "clear"
    if (
        verdict is ReviewVerdict.PASS
        and revision == metadata.revision
        and contract_hash == metadata.contract_hash
        and blockers == 0
    ):
        return "pass"
    if (
        verdict is ReviewVerdict.NEEDS_REVISION
        and revision == metadata.revision
        and contract_hash == metadata.contract_hash
        and blockers > 0
    ):
        return "needs-revision"
    return None


def _validate_review_state(metadata: DocumentMetadata) -> bool:
    content_lane = _review_lane_state(
        metadata.content_review_verdict,
        metadata.content_review_revision,
        metadata.content_review_hash,
        metadata.content_blocking_findings,
        metadata,
    )
    consumer_lane = _review_lane_state(
        metadata.consumer_review_verdict,
        metadata.consumer_review_revision,
        metadata.consumer_review_hash,
        metadata.consumer_blocking_findings,
        metadata,
    )
    return (
        content_lane is not None
        and consumer_lane is not None
        and (content_lane, consumer_lane) in _ALLOWED_REVIEW_LANES[metadata.status]
    )


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
        diagnostics.extend(_parse_tables(section)[1])
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
    if not finding_rows:
        diagnostics.append(
            _diagnostic(
                "missing-findings",
                "Research requires at least one applicable finding record",
                section="Findings",
            )
        )
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
        references = _structured_references(support)
        unresolved = [
            reference
            for reference in references
            if not (
                (_id_valid(reference, "SRC") and reference in source_ids)
                or reference in repository_evidence
            )
        ]
        if not references or unresolved:
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
        supported = _structured_references(row.get("Supports", ""))
        if not supported or any(
            not _id_valid(reference, "FIND") or reference not in finding_ids
            for reference in supported
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
    if not requirements:
        diagnostics.append(
            _diagnostic(
                "missing-requirements",
                "Scope requires at least one product requirement record",
                section="Product requirements",
            )
        )
    if not acceptances:
        diagnostics.append(
            _diagnostic(
                "missing-acceptance-criteria",
                "Scope requires at least one acceptance criterion record",
                section="Acceptance criteria",
            )
        )
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
        mapped_acceptance = _structured_references(row.get("Acceptance IDs", ""))
        if not mapped_acceptance or any(
            not _id_valid(reference, "AC") or reference not in acceptance_ids
            for reference in mapped_acceptance
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
        requirement_refs = _structured_references(row.get("Requirement IDs", ""))
        if (
            any(not row.get(column, "").strip() for column in required_delta_columns)
            or not requirement_refs
            or any(
                not _id_valid(reference, "REQ") or reference not in requirement_ids
                for reference in requirement_refs
            )
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
    seam_rows = _rows(document, "Implementation seams and dependency order")
    if not trace_rows:
        diagnostics.append(
            _diagnostic(
                "missing-design-traceability",
                "Design requires at least one requirement-to-design traceability record",
                section="Requirement-to-design traceability",
            )
        )
    if not seam_rows:
        diagnostics.append(
            _diagnostic(
                "missing-implementation-seams",
                "Design requires at least one bounded implementation seam",
                section="Implementation seams and dependency order",
            )
        )
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

    for row in seam_rows:
        identifier = row.get("Seam ID", "").strip()
        verification_ids = _structured_references(row.get("Verification IDs", ""))
        if (
            not _id_valid(identifier, "SEAM")
            or not verification_ids
            or any(not _id_valid(reference, "VERIFY") for reference in verification_ids)
        ):
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


def consume_document(
    path: Path | str,
    *,
    repository_root: Path | str | None = None,
    as_of: str | None = None,
) -> ConsumptionReport:
    """Validate one committed lifecycle handoff against the current repository."""
    del as_of  # Source-ledger triggers are explicit semantic review inputs in v1.
    root = Path(repository_root or Path.cwd()).resolve()
    target = Path(path)
    target = target.resolve() if target.is_absolute() else (root / target).resolve()
    try:
        relative = validate_repository_path(target.relative_to(root).as_posix())
    except ValueError as error:
        raise ProductDocsError(
            Diagnostic(
                "path-outside-repository",
                "Lifecycle documents must remain inside the repository",
                path=str(path),
            )
        ) from error
    document = parse_document(target, repository_root=root)
    repository = GitRepository(root)
    metadata = document.metadata
    diagnostics: list[Diagnostic] = []

    def add(
        code: str,
        message: str,
        *,
        item_path: str | None = None,
        identifier: str | None = None,
    ) -> None:
        key = (code, item_path, identifier)
        if all(
            (existing.code, existing.path, existing.identifier) != key
            for existing in diagnostics
        ):
            diagnostics.append(
                Diagnostic(code, message, path=item_path, identifier=identifier)
            )

    canonical = re.fullmatch(
        r"docs/product-development/([a-z0-9]+(?:-[a-z0-9]+)*)/(research|scope|design)\.md",
        relative,
    )
    identity = re.fullmatch(
        r"PD-\d{4}-\d{2}-([A-Z0-9]+(?:-[A-Z0-9]+)*)",
        metadata.initiative_id,
    )
    if (
        canonical is None
        or identity is None
        or canonical.group(1) != identity.group(1).lower()
        or canonical.group(2) != metadata.document_type.value
        or metadata.document_id
        != f"{metadata.initiative_id}-{metadata.document_type.value.upper()}"
    ):
        add(
            "noncanonical-document-path",
            "Lifecycle identity must match its canonical repository path",
            item_path=relative,
        )
    if not repository.is_committed_exact(relative):
        add(
            "document-not-committed-exact",
            "Consumption requires the exact target bytes committed at HEAD",
            item_path=relative,
        )
        return _consumption_report(document, diagnostics, (), ())

    package_dirty = repository.has_worktree_change(SKILL_ROOT)
    if package_dirty:
        add(
            "uncommitted-package",
            "Consumption requires a clean committed operational package",
            item_path=SKILL_ROOT,
        )

    validation = validate_document(document, repository_root=root)
    for diagnostic in validation.diagnostics:
        add(
            diagnostic.code,
            diagnostic.message,
            item_path=diagnostic.path,
            identifier=diagnostic.identifier,
        )

    try:
        baseline_reachable = repository.is_commit_reachable(
            metadata.repository_baseline_commit
        )
    except ProductDocsError:
        baseline_reachable = False
    if not baseline_reachable:
        add(
            "unreachable-baseline",
            "Document baseline commit must be reachable from current HEAD",
            identifier=metadata.repository_baseline_commit,
        )
    elif not package_dirty:
        try:
            verify_historical_package(
                repository,
                baseline_commit=metadata.repository_baseline_commit,
                schema_version=metadata.schema_version,
                template_version=metadata.template_version,
                expected_package_hash=metadata.skill_package_hash,
                expected_template_hash=metadata.template_hash,
                active_skill_root=root / SKILL_ROOT,
            )
        except ProductDocsError as error:
            for diagnostic in error.diagnostics:
                add(
                    diagnostic.code,
                    diagnostic.message,
                    item_path=diagnostic.path,
                    identifier=diagnostic.identifier,
                )

    for evidence in metadata.evidence_files:
        if not repository.is_committed_exact(evidence.path):
            add(
                "uncommitted-evidence",
                "Evidence must have exact current bytes committed at HEAD",
                item_path=evidence.path,
            )
            continue
        actual = hashlib.sha256(
            repository.read_bytes_at(repository.head(), evidence.path)
        ).hexdigest()
        if actual != evidence.sha256:
            add(
                "evidence-hash-mismatch",
                "Current evidence bytes do not match the declared digest",
                item_path=evidence.path,
            )

    for binding in metadata.inputs:
        if not repository.is_committed_exact(binding.path):
            add(
                "uncommitted-upstream",
                "Upstream inputs must have exact current bytes committed at HEAD",
                item_path=binding.path,
            )
            continue
        try:
            bound_reachable = repository.is_commit_reachable(binding.commit)
        except ProductDocsError:
            bound_reachable = False
        if not bound_reachable or not repository.path_exists_at(
            binding.commit, binding.path
        ):
            add(
                "upstream-not-passed-at-bound-commit",
                "Lifecycle upstream must exist and be passed at its bound commit",
                item_path=binding.path,
            )
            continue
        if binding.kind not in {
            InputKind.LIFECYCLE_DOCUMENT,
            InputKind.APPROVED_DESIGN,
        }:
            continue
        try:
            bound = parse_document(
                repository.read_bytes_at(binding.commit, binding.path).decode("utf-8"),
                repository_root=root,
            )
        except (UnicodeDecodeError, ProductDocsError):
            bound = None
        if (
            bound is None
            or bound.metadata.status is not DocumentStatus.PASSED
            or bound.metadata.document_id != binding.authority_id
            or bound.metadata.revision != binding.revision
            or bound.metadata.contract_hash != binding.contract_hash
            or not validate_document(bound).valid
        ):
            add(
                "upstream-not-passed-at-bound-commit",
                "Lifecycle upstream identity must be valid and passed at its bound commit",
                item_path=binding.path,
            )
            continue
        try:
            current = parse_document(root / binding.path, repository_root=root)
        except ProductDocsError:
            current = None
        if (
            current is None
            or current.metadata.status is not DocumentStatus.PASSED
            or current.metadata.document_id != binding.authority_id
            or current.metadata.revision != binding.revision
            or current.metadata.contract_hash != binding.contract_hash
        ):
            add(
                "current-upstream-binding-mismatch",
                "Current upstream revision and contract hash must match the binding",
                item_path=binding.path,
            )

    relevant: tuple[str, ...] = ()
    unrelated: tuple[str, ...] = ()
    if baseline_reachable:
        changed = repository.changed_paths(metadata.repository_baseline_commit)
        relevant = tuple(
            changed_path
            for changed_path in changed
            if any(
                changed_path == freshness
                or changed_path.startswith(f"{freshness.rstrip('/')}/")
                for freshness in metadata.freshness_paths
            )
        )
        relevant_set = set(relevant)
        unrelated = tuple(item for item in changed if item not in relevant_set)
        if relevant:
            add(
                "semantic-review-required",
                "Relevant repository drift requires one assessment per path",
            )

    return _consumption_report(document, diagnostics, relevant, unrelated)


def _consumption_report(
    document: LifecycleDocument,
    diagnostics: list[Diagnostic],
    relevant_paths: tuple[str, ...],
    unrelated_paths: tuple[str, ...],
) -> ConsumptionReport:
    blockers = tuple(diagnostic.code for diagnostic in diagnostics)
    return ConsumptionReport(
        document_id=document.metadata.document_id,
        revision=document.metadata.revision,
        contract_hash=document.metadata.contract_hash,
        lane=ReviewLane.CONSUMER,
        verdict=(ReviewVerdict.PASS if not blockers else ReviewVerdict.NEEDS_REVISION),
        blockers=blockers,
        next_permitted_lifecycle_phase=(
            {
                DocumentType.RESEARCH: "scope",
                DocumentType.SCOPE: "design",
                DocumentType.DESIGN: "canon-reconciliation",
            }[document.metadata.document_type]
            if not blockers
            else "revision"
        ),
        diagnostics=tuple(diagnostics),
        relevant_paths=relevant_paths,
        unrelated_paths=unrelated_paths,
    )
