"""Deterministic writes for lifecycle creation, review, and correction."""

from __future__ import annotations

from collections.abc import Mapping, Sequence
from dataclasses import replace
from datetime import date, datetime, timezone
import json
from pathlib import Path
import re
import unicodedata
from typing import Any

from .constants import AUTHORITY_CLASSES, DOCUMENTS_ROOT, SKILL_ROOT
from .documents import (
    append_history_event,
    parse_document,
    write_document_atomic,
)
from .errors import Diagnostic, ProductDocsError
from .hashing import compute_contract_hash
from .models import (
    AuthorityClass,
    DocumentStatus,
    DocumentType,
    InputBinding,
    InputKind,
    LifecycleDocument,
    ReviewLane,
    ReviewRecord,
    ReviewVerdict,
)
from .package_identity import (
    MANIFEST_NAME,
    TEMPLATE_PATHS,
    package_hash,
    verify_active_package,
    verify_historical_package,
)
from .repository import GitRepository, validate_commit_id, validate_repository_path
from .validation import derive_freshness_paths, validate_document


_REVIEW_FIELDS = frozenset(
    {
        "review_id",
        "lane",
        "verdict",
        "reviewer_surface",
        "reviewed_at",
        "reviewed_revision",
        "reviewed_contract_hash",
        "blocking_findings",
        "non_blocking_improvements",
        "traceability_gaps",
        "stale_or_conflicting_inputs",
        "required_revisions",
        "next_permitted_lifecycle_phase",
        "drift_assessments",
    }
)
_REVIEW_ARRAY_FIELDS = (
    "blocking_findings",
    "non_blocking_improvements",
    "traceability_gaps",
    "stale_or_conflicting_inputs",
    "required_revisions",
)
_REVIEW_ID = re.compile(r"REV-[A-Z0-9]+(?:-[A-Z0-9]+)*\Z")
_TIMESTAMP = re.compile(r"\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z\Z")
_DRIFT_FIELDS = frozenset({"path", "impact", "rationale"})


def _error(
    code: str,
    message: str,
    *,
    path: str | None = None,
    identifier: str | None = None,
) -> ProductDocsError:
    return ProductDocsError(Diagnostic(code, message, path=path, identifier=identifier))


def _repository_root(root: Path | str | None, path: Path | str | None = None) -> Path:
    if root is not None:
        return Path(root).resolve()
    candidate = Path(path).resolve() if path is not None else Path.cwd().resolve()
    if candidate.is_file():
        candidate = candidate.parent
    for directory in (candidate, *candidate.parents):
        if (directory / ".git").exists():
            return directory
    raise _error("repository-unavailable", "Could not locate the repository root")


def _relative_path(path: Path | str, root: Path) -> str:
    candidate = Path(path)
    absolute = (
        candidate.resolve() if candidate.is_absolute() else (root / candidate).resolve()
    )
    try:
        relative = absolute.relative_to(root).as_posix()
    except ValueError as error:
        raise _error(
            "path-outside-repository",
            "Lifecycle document paths must remain inside the repository",
            path=str(path),
        ) from error
    return validate_repository_path(relative)


def _target_path(path: Path | str, root: Path) -> Path:
    return root / _relative_path(path, root)


def _day(value: date | str | None) -> str:
    if value is None:
        return date.today().isoformat()
    if isinstance(value, date):
        return value.isoformat()
    try:
        return date.fromisoformat(value).isoformat()
    except (TypeError, ValueError) as error:
        raise _error("invalid-date", "Lifecycle dates must use YYYY-MM-DD") from error


def _timestamp(value: str | None) -> str:
    if value is None:
        return (
            datetime.now(timezone.utc)
            .replace(microsecond=0)
            .strftime("%Y-%m-%dT%H:%M:%SZ")
        )
    if not isinstance(value, str) or not _TIMESTAMP.fullmatch(value):
        raise _error(
            "invalid-timestamp",
            "Lifecycle timestamps must use UTC YYYY-MM-DDTHH:MM:SSZ",
        )
    try:
        datetime.strptime(value, "%Y-%m-%dT%H:%M:%SZ")
    except ValueError as error:
        raise _error(
            "invalid-timestamp", "Lifecycle timestamps must name a real UTC instant"
        ) from error
    return value


def _single_line(value: Any, field: str) -> str:
    if (
        not isinstance(value, str)
        or not value.strip()
        or "\n" in value
        or "\r" in value
    ):
        raise _error(
            "invalid-transition-input", f"{field} must be a nonempty single-line string"
        )
    return value.strip()


def _normalized_slug(initiative: str) -> str:
    if not isinstance(initiative, str):
        raise _error(
            "invalid-initiative-slug", "Initiative name must produce an ASCII slug"
        )
    ascii_name = (
        unicodedata.normalize("NFKD", initiative)
        .encode("ascii", "ignore")
        .decode("ascii")
    )
    slug = re.sub(r"[^a-z0-9]+", "-", ascii_name.lower()).strip("-")
    if not slug or not re.fullmatch(r"[a-z0-9]+(?:-[a-z0-9]+)*", slug):
        raise _error(
            "invalid-initiative-slug",
            "Initiative name must produce an ASCII kebab-case slug",
        )
    return slug


def _active_identity(
    root: Path, phase: DocumentType
) -> tuple[Path, dict[str, object], str, str]:
    skill_root = root / SKILL_ROOT
    manifest = verify_active_package(skill_root)
    template_version = f"{phase.value}-v1"
    relative_template = TEMPLATE_PATHS[template_version]
    template_digest = next(
        (
            record["sha256"]
            for record in manifest["files"]  # type: ignore[index]
            if record["path"] == relative_template
        ),
        None,
    )
    if not isinstance(template_digest, str):
        raise _error(
            "package-manifest-invalid",
            "Active package manifest does not contain the selected template",
            path=relative_template,
        )
    return (
        skill_root,
        manifest,
        package_hash(manifest),
        f"sha256:{template_digest}",
    )


def is_committed_exact(
    path: Path | str, *, repository_root: Path | str | None = None
) -> bool:
    """Return whether a tracked worktree path has exactly its ``HEAD`` bytes."""
    root = _repository_root(repository_root, path)
    relative = _relative_path(path, root)
    repository = GitRepository(root)
    if not repository.is_tracked_at_head(relative):
        return False
    target = root / relative
    if not target.is_file() or target.is_symlink():
        return False
    try:
        return target.read_bytes() == repository.read_bytes_at(
            repository.head(), relative
        )
    except ProductDocsError:
        return False


def _input_from_record(record: Any, repository: GitRepository) -> InputBinding:
    if not isinstance(record, dict):
        raise _error("invalid-authority-file", "Authority inputs must be JSON objects")
    try:
        kind = InputKind(record.get("kind"))
    except (TypeError, ValueError) as error:
        raise _error(
            "invalid-authority-file", "Authority inputs require a known kind"
        ) from error
    allowed = {
        InputKind.CANON: frozenset({"kind", "authority_id", "path", "commit"}),
        InputKind.REPOSITORY_EVIDENCE: frozenset(
            {"kind", "authority_id", "path", "commit"}
        ),
        InputKind.APPROVED_DESIGN: frozenset(
            {"kind", "authority_id", "path", "revision", "contract_hash", "commit"}
        ),
    }
    if kind is InputKind.LIFECYCLE_DOCUMENT or set(record) != allowed.get(kind):
        raise _error(
            "invalid-authority-file",
            "Reduced-entry authority inputs must use the exact typed record fields",
        )
    authority_id = _single_line(record.get("authority_id"), "authority_id")
    try:
        path = validate_repository_path(record.get("path"))
        commit = validate_commit_id(record.get("commit"))
    except ProductDocsError as error:
        raise ProductDocsError(
            Diagnostic(
                "invalid-authority-file",
                "Reduced-entry authority paths and commits must be canonical",
            )
        ) from error
    if not repository.is_commit_reachable(commit) or not repository.path_exists_at(
        commit, path
    ):
        raise _error(
            "invalid-authority-file",
            "Reduced-entry authority must exist at a reachable declared commit",
            path=path,
        )
    revision = record.get("revision")
    contract_hash = record.get("contract_hash")
    if kind is InputKind.APPROVED_DESIGN:
        if (
            type(revision) is not int
            or revision < 1
            or not isinstance(contract_hash, str)
            or not re.fullmatch(r"sha256:[0-9a-f]{64}", contract_hash)
        ):
            raise _error(
                "invalid-authority-file",
                "Approved-design authority requires a positive revision and contract hash",
            )
    return InputBinding(
        kind=kind,
        authority_id=authority_id,
        path=path,
        revision=revision,
        contract_hash=contract_hash,
        commit=commit,
    )


def _authority_bindings(
    authority_file: Path | str, repository: GitRepository
) -> tuple[tuple[InputBinding, ...], str]:
    path = Path(authority_file)
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, UnicodeDecodeError, json.JSONDecodeError) as error:
        raise _error(
            "invalid-authority-file", "Authority file must be readable UTF-8 JSON"
        ) from error
    if not isinstance(data, dict) or set(data) != {"inputs", "rationale"}:
        raise _error(
            "invalid-authority-file",
            "Authority JSON requires exactly inputs and rationale",
        )
    rationale = _single_line(data.get("rationale"), "rationale")
    records = data.get("inputs")
    if not isinstance(records, list) or not records:
        raise _error(
            "invalid-authority-file", "Authority JSON inputs must be a nonempty array"
        )
    bindings = tuple(_input_from_record(record, repository) for record in records)
    identities = {
        (binding.kind, binding.path, binding.authority_id) for binding in bindings
    }
    if len(identities) != len(bindings):
        raise _error("invalid-authority-file", "Authority JSON inputs must be unique")
    return bindings, rationale


def _upstream_binding(
    root: Path,
    repository: GitRepository,
    path: Path | str,
    expected_phase: DocumentType,
) -> InputBinding:
    relative = _relative_path(path, root)
    target = root / relative
    if not is_committed_exact(target, repository_root=root):
        raise _error(
            "upstream-not-passed",
            "The required upstream lifecycle document must be committed exactly and passed",
            path=relative,
        )
    try:
        upstream = parse_document(target, repository_root=root)
    except (OSError, ProductDocsError) as error:
        raise _error(
            "upstream-not-passed",
            "The required upstream lifecycle document is unavailable or invalid",
            path=relative,
        ) from error
    report = validate_document(upstream, repository_root=root)
    if (
        upstream.metadata.document_type is not expected_phase
        or upstream.metadata.status is not DocumentStatus.PASSED
        or not report.valid
    ):
        raise _error(
            "upstream-not-passed",
            "The required upstream lifecycle document must be a valid passed phase",
            path=relative,
        )
    verify_historical_package(
        repository,
        baseline_commit=upstream.metadata.repository_baseline_commit,
        schema_version=upstream.metadata.schema_version,
        template_version=upstream.metadata.template_version,
        expected_package_hash=upstream.metadata.skill_package_hash,
        expected_template_hash=upstream.metadata.template_hash,
        active_skill_root=root / SKILL_ROOT,
    )
    return InputBinding(
        kind=InputKind.LIFECYCLE_DOCUMENT,
        authority_id=upstream.metadata.document_id,
        path=relative,
        revision=upstream.metadata.revision,
        contract_hash=upstream.metadata.contract_hash,
        commit=repository.head(),
    )


def _replace_draft_sentinel(
    document: LifecycleDocument, heading: str, replacement_text: str
) -> LifecycleDocument:
    sections = []
    found = False
    for section in document.sections:
        if section.heading != heading:
            sections.append(section)
            continue
        found = True
        lines = []
        replaced = False
        for line in section.body.splitlines(keepends=True):
            if "PRODUCT-DOC-DRAFT:" in line and not replaced:
                ending = "\r\n" if line.endswith("\r\n") else "\n"
                lines.append(replacement_text + ending)
                replaced = True
            else:
                lines.append(line)
        sections.append(replace(section, body="".join(lines)))
    if not found:
        raise _error("section-order-mismatch", "Upstream authority section is missing")
    return replace(document, sections=tuple(sections))


def create_document(
    repository_root: Path | str,
    *,
    initiative: str,
    phase: str | DocumentType,
    initiative_id: str | None = None,
    input_path: Path | str | None = None,
    authority_file: Path | str | None = None,
    authoring_surface: str = "chatgpt",
    today: date | str | None = None,
) -> Path:
    """Create a revision-one draft from the immutable active template."""
    root = _repository_root(repository_root)
    repository = GitRepository(root)
    try:
        document_type = (
            phase if isinstance(phase, DocumentType) else DocumentType(phase)
        )
    except ValueError as error:
        raise _error(
            "invalid-document-type", "Phase must be research, scope, or design"
        ) from error
    slug = _normalized_slug(initiative)
    created_at = _day(today)
    expected_initiative_id = f"PD-{created_at[:7]}-{slug.upper()}"
    if initiative_id is not None and initiative_id != expected_initiative_id:
        raise _error(
            "initiative-id-mismatch",
            "Explicit initiative ID must exactly match the normalized name and creation month",
            identifier=initiative_id,
        )
    identity = initiative_id or expected_initiative_id
    target = root / DOCUMENTS_ROOT / slug / f"{document_type.value}.md"
    if target.exists() or target.is_symlink():
        raise _error(
            "document-exists",
            "Lifecycle creation refuses to overwrite an existing path",
            path=target.relative_to(root).as_posix(),
        )

    skill_root, manifest, active_package_hash, template_hash = _active_identity(
        root, document_type
    )
    manifest_path = skill_root / MANIFEST_NAME
    if not is_committed_exact(
        manifest_path, repository_root=root
    ) or repository.has_worktree_change(SKILL_ROOT):
        raise _error(
            "uncommitted-package",
            "Document creation requires an exact committed active package",
            path=f"{SKILL_ROOT}/{MANIFEST_NAME}",
        )
    baseline = repository.head()

    inputs: tuple[InputBinding, ...] = ()
    rationale: str | None = None
    if document_type is not DocumentType.RESEARCH:
        upstream_type = (
            DocumentType.RESEARCH
            if document_type is DocumentType.SCOPE
            else DocumentType.SCOPE
        )
        default_upstream = root / DOCUMENTS_ROOT / slug / f"{upstream_type.value}.md"
        if authority_file is not None:
            if input_path not in (None, ""):
                raise _error(
                    "conflicting-entry-authority",
                    "Choose either one lifecycle input or a reduced-entry authority file",
                )
            inputs, rationale = _authority_bindings(authority_file, repository)
        else:
            selected_input = default_upstream if input_path is None else input_path
            if selected_input == "":
                raise _error(
                    "reduced-entry-authority-required",
                    "Skipping the upstream phase requires a validated authority JSON file",
                )
            inputs = (
                _upstream_binding(root, repository, selected_input, upstream_type),
            )
    elif authority_file is not None or input_path not in (None, ""):
        raise _error(
            "invalid-entry-authority",
            "Research is the first lifecycle phase and does not accept skipped-phase authority",
        )

    template_path = skill_root / TEMPLATE_PATHS[f"{document_type.value}-v1"]
    document = parse_document(template_path, repository_root=root)
    metadata = replace(
        document.metadata,
        template_hash=template_hash,
        skill_package_hash=active_package_hash,
        authoring_surface=_single_line(authoring_surface, "authoring_surface"),
        initiative_id=identity,
        document_id=f"{identity}-{document_type.value.upper()}",
        document_type=document_type,
        authority_class=AuthorityClass(AUTHORITY_CLASSES[document_type.value]),
        entry_point=document_type.value,
        status=DocumentStatus.DRAFT,
        revision=1,
        created_at=created_at,
        updated_at=created_at,
        repository_baseline_commit=baseline,
        external_research_as_of=created_at,
        contract_hash="",
        content_review_verdict=ReviewVerdict.UNREVIEWED,
        content_review_revision=0,
        content_review_hash="",
        content_blocking_findings=0,
        consumer_review_verdict=ReviewVerdict.UNREVIEWED,
        consumer_review_revision=0,
        consumer_review_hash="",
        consumer_blocking_findings=0,
        freshness_paths=(),
        inputs=inputs,
    )
    document = replace(document, metadata=metadata)
    if document_type is not DocumentType.RESEARCH:
        heading = (
            "Research input and authority"
            if document_type is DocumentType.SCOPE
            else "Scope input and authority"
        )
        if rationale is not None:
            binding_ids = ", ".join(binding.authority_id for binding in inputs)
            authority_text = (
                f"Reduced entry authority: {binding_ids}. Rationale: {rationale}"
            )
        else:
            binding = inputs[0]
            authority_text = (
                f"Upstream lifecycle input: {binding.authority_id}, revision "
                f"{binding.revision}, {binding.contract_hash}, commit {binding.commit}."
            )
        document = _replace_draft_sentinel(document, heading, authority_text)
    write_document_atomic(target, document, repository_root=root)
    return target


def _clean_transition_dependencies(
    document: LifecycleDocument, repository: GitRepository
) -> tuple[Diagnostic, ...]:
    paths = {
        *document.metadata.canon_targets,
        *document.metadata.source_owner_paths,
        *document.metadata.test_owner_paths,
        *document.metadata.dependency_paths,
        *document.metadata.additional_freshness_paths,
        *(binding.path for binding in document.metadata.inputs),
        *(evidence.path for evidence in document.metadata.evidence_files),
    }
    diagnostics = []
    for path in sorted(paths):
        if repository.has_worktree_change(path):
            code = (
                "uncommitted-evidence"
                if path in {item.path for item in document.metadata.evidence_files}
                else "uncommitted-dependency"
            )
            diagnostics.append(
                Diagnostic(
                    code,
                    "Seal dependencies and declared owner paths must have no worktree changes",
                    path=path,
                )
            )
    return tuple(diagnostics)


def _template_history_list(values: Sequence[str]) -> str:
    if not values:
        return "- None"
    return "\n".join(f"- {value}" for value in values)


def seal_document(
    path: Path | str,
    *,
    repository_root: Path | str | None = None,
    sealed_at: str | None = None,
) -> LifecycleDocument:
    """Validate and atomically seal one tracked draft."""
    root = _repository_root(repository_root, path)
    target = _target_path(path, root)
    relative = target.relative_to(root).as_posix()
    document = parse_document(target, repository_root=root)
    if document.metadata.status is not DocumentStatus.DRAFT:
        raise _error("invalid-transition", "Only a draft document may be sealed")
    repository = GitRepository(root)
    if not repository.is_tracked_at_head(relative):
        raise _error(
            "document-untracked",
            "Seal requires a document tracked at HEAD",
            path=relative,
        )
    skill_root, manifest, active_package_hash, template_hash = _active_identity(
        root, document.metadata.document_type
    )
    if repository.has_worktree_change(SKILL_ROOT) or not is_committed_exact(
        skill_root / MANIFEST_NAME, repository_root=root
    ):
        raise _error(
            "uncommitted-dependency",
            "Seal requires a clean committed operational package",
            path=SKILL_ROOT,
        )
    dependency_diagnostics = _clean_transition_dependencies(document, repository)
    if dependency_diagnostics:
        raise ProductDocsError(dependency_diagnostics)
    verify_historical_package(
        repository,
        baseline_commit=document.metadata.repository_baseline_commit,
        schema_version=document.metadata.schema_version,
        template_version=document.metadata.template_version,
        expected_package_hash=active_package_hash,
        expected_template_hash=template_hash,
        active_skill_root=skill_root,
    )
    instant = _timestamp(sealed_at)
    current_day = instant[:10]
    draft = replace(
        document,
        metadata=replace(
            document.metadata,
            template_hash=template_hash,
            skill_package_hash=active_package_hash,
            updated_at=current_day,
            contract_hash="",
            freshness_paths=(),
            content_review_verdict=ReviewVerdict.UNREVIEWED,
            content_review_revision=0,
            content_review_hash="",
            content_blocking_findings=0,
            consumer_review_verdict=ReviewVerdict.UNREVIEWED,
            consumer_review_revision=0,
            consumer_review_hash="",
            consumer_blocking_findings=0,
        ),
    )
    draft_report = validate_document(draft, repository_root=root)
    if not draft_report.valid:
        raise ProductDocsError(draft_report.diagnostics)
    freshness = derive_freshness_paths(draft.metadata)
    sealed = replace(
        draft,
        metadata=replace(
            draft.metadata,
            status=DocumentStatus.SEALED,
            freshness_paths=freshness,
        ),
    )
    contract_hash = compute_contract_hash(sealed)
    sealed = replace(
        sealed,
        metadata=replace(sealed.metadata, contract_hash=contract_hash),
    )
    event = (
        "### Seal event\n\n"
        f"- Sealed at: `{instant}`\n"
        f"- Revision: `{sealed.metadata.revision}`\n"
        f"- Contract hash: `{contract_hash}`\n"
        "- Freshness paths:\n"
        f"{_template_history_list(freshness)}\n"
    )
    sealed = append_history_event(sealed, event)
    report = validate_document(sealed, repository_root=root)
    if not report.valid:
        raise ProductDocsError(report.diagnostics)
    write_document_atomic(target, sealed, repository_root=root)
    return sealed


def _load_review(source: Path | str | Mapping[str, Any]) -> dict[str, Any]:
    if isinstance(source, Mapping):
        data = dict(source)
    else:
        try:
            data = json.loads(Path(source).read_text(encoding="utf-8"))
        except (OSError, UnicodeDecodeError, json.JSONDecodeError) as error:
            raise _error(
                "invalid-review-file", "Review file must be readable UTF-8 JSON"
            ) from error
    if not isinstance(data, dict) or set(data) != _REVIEW_FIELDS:
        raise _error(
            "invalid-review-file",
            "Review JSON must contain exactly the formal review fields",
        )
    return data


def _string_array(data: Mapping[str, Any], field: str) -> tuple[str, ...]:
    value = data.get(field)
    if not isinstance(value, list) or not all(
        isinstance(item, str) and item.strip() and "\n" not in item and "\r" not in item
        for item in value
    ):
        raise _error(
            "invalid-review-file",
            f"{field} must be an array of nonempty single-line strings",
        )
    return tuple(item.strip() for item in value)


def _parse_review(
    source: Path | str | Mapping[str, Any],
) -> tuple[ReviewRecord, tuple[dict[str, str], ...]]:
    data = _load_review(source)
    review_id = _single_line(data.get("review_id"), "review_id")
    if not _REVIEW_ID.fullmatch(review_id):
        raise _error(
            "invalid-review-id", "Review IDs must use stable uppercase REV-* form"
        )
    try:
        lane = ReviewLane(data.get("lane"))
        verdict = ReviewVerdict(data.get("verdict"))
    except (TypeError, ValueError) as error:
        raise _error(
            "invalid-review-file", "Review lane or verdict is invalid"
        ) from error
    if verdict is ReviewVerdict.UNREVIEWED:
        raise _error(
            "invalid-review-file", "A recorded review must have a final verdict"
        )
    revision = data.get("reviewed_revision")
    if type(revision) is not int or revision < 1:
        raise _error(
            "invalid-review-file", "reviewed_revision must be a positive integer"
        )
    contract_hash = data.get("reviewed_contract_hash")
    if not isinstance(contract_hash, str) or not re.fullmatch(
        r"sha256:[0-9a-f]{64}", contract_hash
    ):
        raise _error(
            "invalid-review-file", "reviewed_contract_hash must be lowercase sha256"
        )
    arrays = {field: _string_array(data, field) for field in _REVIEW_ARRAY_FIELDS}
    if verdict is ReviewVerdict.NEEDS_REVISION and not arrays["blocking_findings"]:
        raise _error(
            "review-blockers-required", "NEEDS REVISION requires blocking findings"
        )
    if verdict is ReviewVerdict.PASS and arrays["blocking_findings"]:
        raise _error(
            "review-pass-has-blockers", "PASS must not contain blocking findings"
        )
    assessments = data.get("drift_assessments")
    if not isinstance(assessments, list):
        raise _error("invalid-review-file", "drift_assessments must be an array")
    parsed_assessments = []
    for assessment in assessments:
        if not isinstance(assessment, dict) or set(assessment) != _DRIFT_FIELDS:
            raise _error(
                "invalid-review-file",
                "Drift assessments require path, impact, and rationale",
            )
        path = validate_repository_path(assessment.get("path"))
        impact = assessment.get("impact")
        rationale = _single_line(assessment.get("rationale"), "drift rationale")
        if impact not in {"none", "material"}:
            raise _error("invalid-review-file", "Drift impact must be none or material")
        parsed_assessments.append(
            {"path": path, "impact": impact, "rationale": rationale}
        )
    record = ReviewRecord(
        review_id=review_id,
        lane=lane,
        verdict=verdict,
        reviewer_surface=_single_line(data.get("reviewer_surface"), "reviewer_surface"),
        reviewed_at=_timestamp(data.get("reviewed_at")),
        reviewed_revision=revision,
        reviewed_contract_hash=contract_hash,
        blocking_findings=arrays["blocking_findings"],
        non_blocking_improvements=arrays["non_blocking_improvements"],
        traceability_gaps=arrays["traceability_gaps"],
        stale_or_conflicting_inputs=arrays["stale_or_conflicting_inputs"],
        required_revisions=arrays["required_revisions"],
        next_permitted_lifecycle_phase=_single_line(
            data.get("next_permitted_lifecycle_phase"),
            "next_permitted_lifecycle_phase",
        ),
    )
    return record, tuple(parsed_assessments)


def _review_event(record: ReviewRecord, assessments: tuple[dict[str, str], ...]) -> str:
    lane = record.lane.value.upper()
    verdict = "PASS" if record.verdict is ReviewVerdict.PASS else "NEEDS REVISION"
    lines = [
        f"### Review event: {record.review_id}",
        "",
        f"- Review lane: `{lane}`",
        f"- Verdict: `{verdict}`",
        f"- Reviewer surface: `{record.reviewer_surface}`",
        f"- Reviewed at: `{record.reviewed_at}`",
        f"- Reviewed revision: `{record.reviewed_revision}`",
        f"- Reviewed contract hash: `{record.reviewed_contract_hash}`",
    ]
    groups = (
        ("Blocking findings", record.blocking_findings),
        ("Non-blocking improvements", record.non_blocking_improvements),
        ("Traceability gaps", record.traceability_gaps),
        ("Stale or conflicting inputs", record.stale_or_conflicting_inputs),
        ("Required revisions", record.required_revisions),
    )
    for heading, values in groups:
        lines.extend(("", f"#### {heading}", "", _template_history_list(values)))
    lines.extend(
        (
            "",
            "#### Next permitted lifecycle phase",
            "",
            record.next_permitted_lifecycle_phase,
            "",
            "#### Drift assessments",
            "",
        )
    )
    if assessments:
        lines.extend(
            f"- `{item['path']}`: `{item['impact']}` — {item['rationale']}"
            for item in assessments
        )
    else:
        lines.append("- None")
    return "\n".join(lines) + "\n"


def record_review(
    path: Path | str,
    review: Path | str | Mapping[str, Any],
    *,
    repository_root: Path | str | None = None,
) -> LifecycleDocument:
    """Record one revision/hash-bound content or consumer review."""
    root = _repository_root(repository_root, path)
    target = _target_path(path, root)
    if not is_committed_exact(target, repository_root=root):
        raise _error(
            "document-not-committed-exact",
            "Reviews require the exact document bytes committed at HEAD",
            path=target.relative_to(root).as_posix(),
        )
    document = parse_document(target, repository_root=root)
    record, assessments = _parse_review(review)
    history = next(
        section.body
        for section in document.sections
        if section.heading == "Review history"
    )
    if re.search(rf"(?m)^### Review event: {re.escape(record.review_id)}$", history):
        raise _error(
            "duplicate-review-id",
            "Review IDs are append-only and must be unique",
            identifier=record.review_id,
        )
    expected_status = (
        DocumentStatus.SEALED
        if record.lane is ReviewLane.CONTENT
        else DocumentStatus.CONTENT_REVIEWED
    )
    if document.metadata.status is not expected_status:
        raise _error(
            "invalid-transition",
            f"{record.lane.value} review is not permitted from {document.metadata.status.value}",
        )
    if (
        record.reviewed_revision != document.metadata.revision
        or record.reviewed_contract_hash != document.metadata.contract_hash
    ):
        raise _error(
            "review-binding-mismatch",
            "Review revision and contract hash must match the sealed document exactly",
        )
    report = validate_document(document, repository_root=root)
    if not report.valid:
        raise ProductDocsError(report.diagnostics)

    status = (
        DocumentStatus.NEEDS_REVISION
        if record.verdict is ReviewVerdict.NEEDS_REVISION
        else (
            DocumentStatus.CONTENT_REVIEWED
            if record.lane is ReviewLane.CONTENT
            else DocumentStatus.PASSED
        )
    )
    metadata = document.metadata
    if record.lane is ReviewLane.CONTENT:
        metadata = replace(
            metadata,
            status=status,
            updated_at=record.reviewed_at[:10],
            content_review_verdict=record.verdict,
            content_review_revision=record.reviewed_revision,
            content_review_hash=record.reviewed_contract_hash,
            content_blocking_findings=len(record.blocking_findings),
        )
    else:
        metadata = replace(
            metadata,
            status=status,
            updated_at=record.reviewed_at[:10],
            consumer_review_verdict=record.verdict,
            consumer_review_revision=record.reviewed_revision,
            consumer_review_hash=record.reviewed_contract_hash,
            consumer_blocking_findings=len(record.blocking_findings),
        )
    reviewed = append_history_event(
        replace(document, metadata=metadata), _review_event(record, assessments)
    )
    final_report = validate_document(reviewed, repository_root=root)
    if not final_report.valid:
        raise ProductDocsError(final_report.diagnostics)
    write_document_atomic(target, reviewed, repository_root=root)
    return reviewed


def mark_stale(
    path: Path | str,
    *,
    reason: str,
    repository_root: Path | str | None = None,
    marked_at: str | None = None,
) -> LifecycleDocument:
    """Persist detected drift on a passed lifecycle document."""
    root = _repository_root(repository_root, path)
    target = _target_path(path, root)
    document = parse_document(target, repository_root=root)
    if document.metadata.status is not DocumentStatus.PASSED:
        raise _error("invalid-transition", "Only a passed document may be marked stale")
    instant = _timestamp(marked_at)
    reason = _single_line(reason, "reason")
    stale = replace(
        document,
        metadata=replace(
            document.metadata,
            status=DocumentStatus.STALE,
            updated_at=instant[:10],
        ),
    )
    stale = append_history_event(
        stale,
        f"### Stale event\n\n- Marked at: `{instant}`\n- Reason: {reason}\n",
    )
    report = validate_document(stale, repository_root=root)
    if not report.valid:
        raise ProductDocsError(report.diagnostics)
    write_document_atomic(target, stale, repository_root=root)
    return stale


def reopen_document(
    path: Path | str,
    *,
    repository_root: Path | str | None = None,
    baseline_commit: str | None = None,
    input_path: Path | str | None = None,
    authority_file: Path | str | None = None,
    reopened_at: str | None = None,
) -> LifecycleDocument:
    """Reopen a stale or rejected document as exactly one new draft revision."""
    root = _repository_root(repository_root, path)
    target = _target_path(path, root)
    document = parse_document(target, repository_root=root)
    if document.metadata.status not in {
        DocumentStatus.NEEDS_REVISION,
        DocumentStatus.STALE,
    }:
        raise _error(
            "invalid-transition",
            "Only needs-revision or stale documents may reopen",
        )
    repository = GitRepository(root)
    new_baseline = document.metadata.repository_baseline_commit
    if baseline_commit is not None:
        new_baseline = validate_commit_id(baseline_commit)
        if not repository.is_commit_reachable(new_baseline):
            raise _error(
                "unreachable-baseline", "Replacement baseline must be reachable"
            )
    new_inputs = document.metadata.inputs
    rationale: str | None = None
    if authority_file is not None:
        if input_path not in (None, ""):
            raise _error(
                "conflicting-entry-authority",
                "Choose either one lifecycle input or a reduced-entry authority file",
            )
        new_inputs, rationale = _authority_bindings(authority_file, repository)
    elif input_path not in (None, ""):
        upstream_type = (
            DocumentType.RESEARCH
            if document.metadata.document_type is DocumentType.SCOPE
            else DocumentType.SCOPE
        )
        new_inputs = (_upstream_binding(root, repository, input_path, upstream_type),)
    instant = _timestamp(reopened_at)
    reopened = replace(
        document,
        metadata=replace(
            document.metadata,
            status=DocumentStatus.DRAFT,
            revision=document.metadata.revision + 1,
            updated_at=instant[:10],
            repository_baseline_commit=new_baseline,
            contract_hash="",
            freshness_paths=(),
            content_review_verdict=ReviewVerdict.UNREVIEWED,
            content_review_revision=0,
            content_review_hash="",
            content_blocking_findings=0,
            consumer_review_verdict=ReviewVerdict.UNREVIEWED,
            consumer_review_revision=0,
            consumer_review_hash="",
            consumer_blocking_findings=0,
            inputs=new_inputs,
        ),
    )
    detail = "Bindings preserved."
    if authority_file is not None:
        detail = f"Reduced-entry authority replaced. Rationale: {rationale}"
    elif input_path not in (None, ""):
        detail = "Lifecycle input binding replaced."
    reopened = append_history_event(
        reopened,
        "### Reopen event\n\n"
        f"- Reopened at: `{instant}`\n"
        f"- Revision: `{reopened.metadata.revision}`\n"
        f"- Repository baseline: `{new_baseline}`\n"
        f"- Corrective work: {detail}\n",
    )
    report = validate_document(reopened, repository_root=root)
    if not report.valid:
        raise ProductDocsError(report.diagnostics)
    write_document_atomic(target, reopened, repository_root=root)
    return reopened


def supersede_document(
    path: Path | str,
    *,
    replacement: Path | str,
    reason: str,
    repository_root: Path | str | None = None,
    superseded_at: str | None = None,
) -> LifecycleDocument:
    """Supersede a document without changing its authority-bearing body."""
    root = _repository_root(repository_root, path)
    target = _target_path(path, root)
    document = parse_document(target, repository_root=root)
    if document.metadata.status is DocumentStatus.SUPERSEDED:
        raise _error(
            "invalid-transition", "A superseded document cannot be superseded again"
        )
    replacement_path = _relative_path(replacement, root)
    if replacement_path == target.relative_to(root).as_posix():
        raise _error("invalid-replacement", "A document cannot supersede itself")
    reason = _single_line(reason, "reason")
    instant = _timestamp(superseded_at)
    superseded = replace(
        document,
        metadata=replace(
            document.metadata,
            status=DocumentStatus.SUPERSEDED,
            updated_at=instant[:10],
        ),
    )
    superseded = append_history_event(
        superseded,
        "### Supersede event\n\n"
        f"- Superseded at: `{instant}`\n"
        f"- Replacement: `{replacement_path}`\n"
        f"- Reason: {reason}\n",
    )
    if document.metadata.contract_hash:
        report = validate_document(superseded, repository_root=root)
        if not report.valid:
            raise ProductDocsError(report.diagnostics)
    write_document_atomic(target, superseded, repository_root=root)
    return superseded
