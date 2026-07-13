"""Stable, non-normative Linear, Figma, and proof reference handling."""

from __future__ import annotations

import hashlib
import os
import stat
import tomllib
from collections.abc import Iterable, Mapping
from dataclasses import dataclass
from pathlib import Path, PurePosixPath

from tools.ambitions_canon.coverage import GapClass, GapDescriptor
from tools.ambitions_canon.model import (
    AuthorityClass,
    AuthorityReference,
    AuthorityReferenceKind,
    CanonError,
    CanonRegistry,
    Finding,
    FigmaAuthorityRole,
    GapSeverity,
)


REFERENCE_FILES = (
    (Path("docs/canon/references/figma.toml"), AuthorityReferenceKind.FIGMA),
    (Path("docs/canon/references/linear.toml"), AuthorityReferenceKind.LINEAR),
    (Path("docs/canon/references/proof-sources.toml"), AuthorityReferenceKind.PROOF),
)
_TOP_LEVEL_FIELDS = frozenset({"schema_version", "kind", "references"})
_REFERENCE_REQUIRED = frozenset(
    {
        "reference_id",
        "source",
        "revision",
        "requirement_ids",
        "approval_state",
        "implementation_status",
    }
)
_REFERENCE_ALLOWED = _REFERENCE_REQUIRED | {"approved_by", "authority_role"}
_APPROVAL_STATES = frozenset({"unreviewed", "approved", "rejected", "stale"})
_ALLOWED_EXTERNAL_PROOF_PREFIXES = (
    "figma:",
    "linear:",
    "linear-comment:",
    "linear-ledger:",
    "https://",
)


@dataclass(frozen=True, slots=True)
class ExternalReferenceSnapshot:
    references: tuple[AuthorityReference, ...]
    source_bytes: tuple[tuple[Path, bytes], ...]
    input_sha: str


def load_external_references(repo_root: Path) -> tuple[AuthorityReference, ...]:
    """Load the fixed tracked reference files without granting them authority."""

    return load_external_reference_snapshot(repo_root).references


def load_external_reference_snapshot(repo_root: Path) -> ExternalReferenceSnapshot:
    """Read all fixed reference bytes without following any path component."""

    records: list[AuthorityReference] = []
    inputs: list[tuple[Path, bytes]] = []
    for relative_path, expected_kind in REFERENCE_FILES:
        try:
            source_bytes = _read_regular_nofollow(repo_root, relative_path)
        except FileNotFoundError as exc:
            raise CanonError(
                "CANON_EXTERNAL_REFERENCE_MISSING",
                "required external reference input is missing",
                repo_root / relative_path,
            ) from exc
        except OSError as exc:
            raise CanonError(
                "CANON_EXTERNAL_REFERENCE_READ",
                "unable to read external reference input without following links",
                repo_root / relative_path,
            ) from exc
        inputs.append((relative_path, source_bytes))
        records.extend(
            _load_reference_file_bytes(
                source_bytes,
                repo_root / relative_path,
                expected_kind,
            )
        )
    ordered = tuple(sorted(records, key=lambda item: item.reference_id))
    identifiers = tuple(item.reference_id for item in ordered)
    if len(identifiers) != len(set(identifiers)):
        raise CanonError(
            "CANON_EXTERNAL_REFERENCE_DUPLICATE",
            "external reference IDs must be unique across reference files",
        )
    source_bytes = tuple(sorted(inputs, key=lambda item: item[0].as_posix()))
    return ExternalReferenceSnapshot(
        references=ordered,
        source_bytes=source_bytes,
        input_sha=_input_sha(source_bytes),
    )


def validate_external_reference_snapshot(
    repo_root: Path,
    snapshot: ExternalReferenceSnapshot,
) -> None:
    """Reject reference changes after a caller pins an immutable snapshot."""

    current = load_external_reference_snapshot(repo_root)
    if current.input_sha != snapshot.input_sha or current.source_bytes != snapshot.source_bytes:
        raise CanonError(
            "CANON_TRACEABILITY_INPUT_CHANGED",
            "external reference inputs changed during traceability generation",
            repo_root / "docs/canon/references",
        )


def external_reference_findings(
    registry: CanonRegistry,
    references: Iterable[AuthorityReference],
    repo_root: Path | None = None,
) -> tuple[Finding, ...]:
    """Validate external links while retaining their exact gap direction."""

    effective_root = repo_root or registry.manifest.repository_root
    active_ids = {item.requirement_id for item in registry.requirements}
    findings: list[Finding] = []
    approved_targets: dict[str, list[str]] = {}
    for reference in sorted(references, key=lambda item: item.reference_id):
        gap_class = _external_gap_class(reference.reference_kind)
        for requirement_id in sorted(reference.requirement_ids):
            if requirement_id in registry.superseded_ids:
                findings.append(
                    Finding(
                        code="CANON_EXTERNAL_REQUIREMENT_SUPERSEDED",
                        severity=GapSeverity.P0_BLOCKER,
                        message=(
                            f"{_descriptor(gap_class, requirement_id).serialize()} "
                            f"superseded requirement reference_id={reference.reference_id}"
                        ),
                    )
                )
            elif requirement_id not in active_ids:
                findings.append(
                    Finding(
                        code=_unknown_code(reference.reference_kind),
                        severity=(
                            _descriptor(gap_class, requirement_id).severity
                            if gap_class is not None
                            else GapSeverity.P1_REQUIRED
                        ),
                        message=(
                            f"{_descriptor(gap_class, requirement_id).serialize()} "
                            f"unknown requirement reference_id={reference.reference_id}"
                        ),
                    )
                )

        if reference.reference_kind is AuthorityReferenceKind.FIGMA:
            if reference.authority_role is None:
                affected = reference.requirement_ids or (reference.reference_id,)
                findings.append(
                    Finding(
                        code="CANON_FIGMA_AUTHORITY_ROLE_REQUIRED",
                        severity=GapSeverity.P1_REQUIRED,
                        message=(
                            f"{GapDescriptor(GapClass.FIGMA_TO_CANON, affected).serialize()} "
                            "visual authority requires a typed authority role "
                            f"reference_id={reference.reference_id}"
                        ),
                    )
                )
            elif reference.authority_role is FigmaAuthorityRole.APPROVED_TARGET:
                for requirement_id in reference.requirement_ids:
                    approved_targets.setdefault(requirement_id, []).append(
                        reference.reference_id
                    )
            if (
                reference.authority_role is not None
                and not _figma_role_state_valid(
                    reference.authority_role,
                    reference.approval_state,
                    reference.approved_by,
                )
            ):
                affected = reference.requirement_ids or (reference.reference_id,)
                findings.append(
                    Finding(
                        code="CANON_FIGMA_AUTHORITY_STATE_INVALID",
                        severity=GapSeverity.P1_REQUIRED,
                        message=(
                            f"{GapDescriptor(GapClass.FIGMA_TO_CANON, affected).serialize()} "
                            "authority role, approval state, and approver do not form a "
                            f"legal combination reference_id={reference.reference_id}"
                        ),
                    )
                )
            if (
                reference.authority_role is FigmaAuthorityRole.APPROVED_TARGET
                and (
                    reference.approval_state != "approved"
                    or not reference.approved_by
                )
            ):
                affected = reference.requirement_ids or (reference.reference_id,)
                findings.append(
                    Finding(
                        code="CANON_FIGMA_OWNER_APPROVAL_REQUIRED",
                        severity=GapSeverity.P1_REQUIRED,
                        message=(
                            f"{GapDescriptor(GapClass.FIGMA_TO_CANON, affected).serialize()} "
                            "visual authority requires explicit owner approval "
                            f"reference_id={reference.reference_id}"
                        ),
                    )
                )

        if reference.reference_kind is AuthorityReferenceKind.PROOF:
            if not _valid_proof_source(reference.source, effective_root):
                findings.append(
                    Finding(
                        code="CANON_PROOF_SOURCE_INVALID",
                        severity=GapSeverity.P0_BLOCKER,
                        message=(
                            "proof source must be repository-confined or use an allowed "
                            f"stable external locator reference_id={reference.reference_id}"
                        ),
                    )
                )

    for requirement_id, reference_ids in sorted(approved_targets.items()):
        if len(reference_ids) > 1:
            descriptor = GapDescriptor(GapClass.FIGMA_TO_CANON, (requirement_id,))
            findings.append(
                Finding(
                    code="CANON_FIGMA_MULTIPLE_APPROVED_TARGETS",
                    severity=GapSeverity.P1_REQUIRED,
                    message=(
                        f"{descriptor.serialize()} multiple approved visual targets "
                        f"reference_ids={','.join(sorted(reference_ids))}"
                    ),
                )
            )

    return tuple(
        sorted(
            findings,
            key=lambda item: (item.code, item.message),
        )
    )


def render_visual_authority_manifest(
    registry: CanonRegistry,
    references: Iterable[AuthorityReference],
) -> dict[str, object]:
    """Project Figma approval posture without claiming implementation readiness."""

    authorities = []
    for reference in sorted(references, key=lambda item: item.reference_id):
        if reference.reference_kind is not AuthorityReferenceKind.FIGMA:
            continue
        approved = (
            reference.authority_role is FigmaAuthorityRole.APPROVED_TARGET
            and
            reference.approval_state == "approved"
            and bool(reference.approved_by)
        )
        authorities.append(
            {
                "approval_state": reference.approval_state,
                "approved_by": reference.approved_by,
                "authority_status": "approved" if approved else "non_authoritative",
                "authority_role": (
                    reference.authority_role.value
                    if reference.authority_role is not None
                    else None
                ),
                "implementation_status": reference.implementation_status,
                "reference_id": reference.reference_id,
                "requirement_ids": list(sorted(reference.requirement_ids)),
                "revision": reference.revision,
                "source": reference.source,
            }
        )
    approval_complete = bool(authorities) and all(
        item["authority_status"] == "approved" for item in authorities
    )
    return {
        "schema_version": 1,
        "authority_state": registry.manifest.authority_state.value,
        "canon_revision": registry.manifest.canon_revision,
        "authorities": authorities,
        "owner_approval_complete": approval_complete,
        "ui_readiness": False,
        "ui_readiness_reason": (
            "visual authority references do not prove implementation, accessibility, "
            "device, visual, or release readiness"
        ),
    }


def render_external_reference_impact(
    registry: CanonRegistry,
    references: Iterable[AuthorityReference],
    findings: Iterable[Finding],
    metadata: Mapping[str, object],
) -> bytes:
    """Render a truthful shadow summary of the loaded external inputs."""

    ordered = tuple(sorted(references, key=lambda item: item.reference_id))
    invalid = tuple(sorted(findings, key=lambda item: (item.code, item.message)))
    counts = {
        kind: sum(item.reference_kind is kind for item in ordered)
        for kind in (
            AuthorityReferenceKind.LINEAR,
            AuthorityReferenceKind.FIGMA,
            AuthorityReferenceKind.PROOF,
        )
    }
    lines = [
        "# Ambitions External Reference Impact",
        "",
        f"- Canon revision: `{registry.manifest.canon_revision}`",
        f"- Authority state: `{registry.manifest.authority_state.value}`",
        f"- Traceability input SHA: `{metadata.get('traceability_input_sha', 'unknown')}`",
        "",
        "**Representation status:** Represented",
        "",
        f"- Stable references: `{len(ordered)}`",
        f"- Linear references: `{counts[AuthorityReferenceKind.LINEAR]}`",
        f"- Figma references: `{counts[AuthorityReferenceKind.FIGMA]}`",
        f"- Proof references: `{counts[AuthorityReferenceKind.PROOF]}`",
        f"- Invalid external findings: `{len(invalid)}`",
        "",
        "This stable-link inventory is non-normative shadow input and does not prove implementation or readiness.",
        "",
        "| Reference | Kind | Role | Approval | Requirements |",
        "| --- | --- | --- | --- | --- |",
    ]
    for reference in ordered:
        role = reference.authority_role.value if reference.authority_role else "n/a"
        requirements = ", ".join(f"`{item}`" for item in reference.requirement_ids)
        lines.append(
            f"| `{_markdown_cell(reference.reference_id)}` | "
            f"{reference.reference_kind.value} | {role} | "
            f"{reference.approval_state} | {requirements} |"
        )
    if not ordered:
        lines.append("| none | none | none | none | none |")
    return ("\n".join(lines) + "\n").encode("utf-8")


def _load_reference_file_bytes(
    source_bytes: bytes,
    path: Path,
    expected_kind: AuthorityReferenceKind,
) -> tuple[AuthorityReference, ...]:
    try:
        data = tomllib.loads(source_bytes.decode("utf-8"))
    except (UnicodeError, tomllib.TOMLDecodeError) as exc:
        raise CanonError(
            "CANON_EXTERNAL_REFERENCE_PARSE",
            "unable to parse external reference TOML",
            path,
        ) from exc
    if not isinstance(data, dict) or set(data) != _TOP_LEVEL_FIELDS:
        raise _schema_error(path, "top-level fields are closed")
    if data.get("schema_version") != 1:
        raise _schema_error(path, "schema_version must be 1")
    if data.get("kind") != expected_kind.value:
        raise _schema_error(path, f"kind must be {expected_kind.value}")
    rows = data.get("references")
    if not isinstance(rows, list) or any(not isinstance(row, dict) for row in rows):
        raise _schema_error(path, "references must be an array of tables")
    authority_class = {
        AuthorityReferenceKind.FIGMA: AuthorityClass.FIGMA,
        AuthorityReferenceKind.LINEAR: AuthorityClass.LINEAR,
        AuthorityReferenceKind.PROOF: AuthorityClass.SOURCE_AND_TESTS,
    }[expected_kind]
    parsed: list[AuthorityReference] = []
    for row in rows:
        assert isinstance(row, dict)
        if not _REFERENCE_REQUIRED <= set(row) or not set(row) <= _REFERENCE_ALLOWED:
            raise _schema_error(path, "reference fields are closed")
        requirement_ids = _string_list(row["requirement_ids"], path, "requirement_ids")
        approval_state = _string(row["approval_state"], path, "approval_state")
        if approval_state not in _APPROVAL_STATES:
            raise _schema_error(path, "approval_state is invalid")
        approved_by = row.get("approved_by")
        if approved_by is not None:
            approved_by = _string(approved_by, path, "approved_by")
        authority_role = None
        if expected_kind is AuthorityReferenceKind.FIGMA:
            if "authority_role" not in row:
                raise _schema_error(path, "Figma reference requires authority_role")
            try:
                authority_role = FigmaAuthorityRole(
                    _string(row["authority_role"], path, "authority_role")
                )
            except ValueError as exc:
                raise _schema_error(path, "authority_role is invalid") from exc
            _validate_figma_role(
                authority_role,
                approval_state,
                approved_by,
                path,
            )
        elif "authority_role" in row:
            raise _schema_error(path, "authority_role is only valid for Figma")
        parsed.append(
            AuthorityReference(
                schema_version=1,
                reference_id=_string(row["reference_id"], path, "reference_id"),
                authority_class=authority_class,
                reference_kind=expected_kind,
                source=_string(row["source"], path, "source"),
                revision=_string(row["revision"], path, "revision"),
                requirement_ids=requirement_ids,
                approval_state=approval_state,
                approved_by=approved_by,
                implementation_status=_string(
                    row["implementation_status"], path, "implementation_status"
                ),
                authority_role=authority_role,
            )
        )
    ordered = tuple(sorted(parsed, key=lambda item: item.reference_id))
    if tuple(item.reference_id for item in ordered) != tuple(
        sorted(set(item.reference_id for item in ordered))
    ):
        raise CanonError(
            "CANON_EXTERNAL_REFERENCE_DUPLICATE",
            "reference IDs must be unique",
            path,
        )
    return ordered


def _valid_proof_source(source: str, repo_root: Path | None) -> bool:
    if source.startswith(_ALLOWED_EXTERNAL_PROOF_PREFIXES):
        return True
    if "://" in source:
        return False
    pure = PurePosixPath(source)
    if pure.is_absolute() or not pure.parts or ".." in pure.parts:
        return False
    if repo_root is None:
        return False
    try:
        _read_regular_nofollow(repo_root, Path(*pure.parts))
    except (OSError, ValueError):
        return False
    return True


def _validate_figma_role(
    role: FigmaAuthorityRole,
    approval_state: str,
    approved_by: str | None,
    path: Path,
) -> None:
    if not _figma_role_state_valid(role, approval_state, approved_by):
        raise _schema_error(
            path,
            "authority_role, approval_state, and approved_by combination is invalid",
        )


def _figma_role_state_valid(
    role: FigmaAuthorityRole,
    approval_state: str,
    approved_by: str | None,
) -> bool:
    return (
        role is FigmaAuthorityRole.APPROVED_TARGET
        and approval_state == "approved"
        and bool(approved_by)
    ) or (
        role is FigmaAuthorityRole.CANDIDATE
        and approval_state == "unreviewed"
        and approved_by is None
    ) or (
        role is FigmaAuthorityRole.SUPERSEDED
        and approval_state == "stale"
        and bool(approved_by)
    )


def _read_regular_nofollow(root: Path, relative_path: Path) -> bytes:
    if relative_path.is_absolute() or not relative_path.parts or ".." in relative_path.parts:
        raise ValueError("path must be repository-relative")
    directory_flags = (
        os.O_RDONLY
        | os.O_DIRECTORY
        | os.O_NOFOLLOW
        | getattr(os, "O_CLOEXEC", 0)
    )
    file_flags = os.O_RDONLY | os.O_NOFOLLOW | getattr(os, "O_CLOEXEC", 0)
    descriptors: list[int] = []
    try:
        current = os.open(root, directory_flags)
        descriptors.append(current)
        for component in relative_path.parts[:-1]:
            current = os.open(component, directory_flags, dir_fd=current)
            descriptors.append(current)
        descriptor = os.open(relative_path.parts[-1], file_flags, dir_fd=current)
        descriptors.append(descriptor)
        if not stat.S_ISREG(os.fstat(descriptor).st_mode):
            raise OSError("reference input is not a regular file")
        chunks: list[bytes] = []
        while chunk := os.read(descriptor, 64 * 1024):
            chunks.append(chunk)
        return b"".join(chunks)
    finally:
        for descriptor in reversed(descriptors):
            os.close(descriptor)


def _input_sha(entries: tuple[tuple[Path, bytes], ...]) -> str:
    digest = hashlib.sha256()
    for path, content in entries:
        label = path.as_posix().encode("utf-8")
        digest.update(len(label).to_bytes(8, "big"))
        digest.update(label)
        digest.update(len(content).to_bytes(8, "big"))
        digest.update(content)
    return digest.hexdigest()


def _external_gap_class(kind: AuthorityReferenceKind) -> GapClass | None:
    return {
        AuthorityReferenceKind.FIGMA: GapClass.FIGMA_TO_CANON,
        AuthorityReferenceKind.LINEAR: GapClass.LINEAR_TO_CANON,
    }.get(kind)


def _descriptor(gap_class: GapClass | None, identifier: str) -> GapDescriptor:
    return GapDescriptor(gap_class or GapClass.CANON_TO_CODE, (identifier,))


def _unknown_code(kind: AuthorityReferenceKind) -> str:
    return {
        AuthorityReferenceKind.FIGMA: "CANON_FIGMA_REQUIREMENT_UNKNOWN",
        AuthorityReferenceKind.LINEAR: "CANON_LINEAR_REQUIREMENT_UNKNOWN",
    }.get(kind, "CANON_EXTERNAL_REQUIREMENT_UNKNOWN")


def _string(value: object, path: Path, field: str) -> str:
    if not isinstance(value, str) or not value or value != value.strip():
        raise _schema_error(path, f"{field} must be a non-empty trimmed string")
    return value


def _string_list(value: object, path: Path, field: str) -> tuple[str, ...]:
    if not isinstance(value, list) or not value:
        raise _schema_error(path, f"{field} must be a non-empty string array")
    values = tuple(_string(item, path, field) for item in value)
    if values != tuple(sorted(set(values))):
        raise _schema_error(path, f"{field} must be sorted and unique")
    return values


def _schema_error(path: Path, message: str) -> CanonError:
    return CanonError("CANON_EXTERNAL_REFERENCE_SCHEMA", message, path)


def _markdown_cell(value: str) -> str:
    return value.replace("|", "&#124;").replace("`", "&#96;")
