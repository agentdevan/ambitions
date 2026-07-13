"""Generated canon-to-source/test/proof implementation posture."""

from __future__ import annotations

import hashlib
import os
import re
import stat
from dataclasses import dataclass
from pathlib import Path, PurePosixPath
from collections.abc import Iterable, Mapping

from tools.ambitions_canon.coverage import GapClass, GapDescriptor
from tools.ambitions_canon.external_authority import (
    ExternalReferenceSnapshot,
    external_reference_findings,
)
from tools.ambitions_canon.model import (
    AuthorityReference,
    AuthorityReferenceKind,
    CanonRegistry,
    Finding,
    GapSeverity,
)
from tools.ambitions_canon.render import stable_json


IMPLEMENTATION_SUFFIXES = frozenset(
    {".c", ".cc", ".cpp", ".h", ".m", ".mm", ".py", ".sh", ".swift"}
)
SOURCE_SCAN_ROOTS = (Path("Native"), Path("Packages"), Path("scripts"), Path("tools"))


@dataclass(frozen=True, slots=True)
class SourceMapping:
    owner_path: str
    exists: bool
    implementation_files: tuple[str, ...]
    status: str

    @property
    def has_implementation(self) -> bool:
        return bool(self.implementation_files)


@dataclass(frozen=True, slots=True)
class TraceabilityRecord:
    requirement_id: str
    source_owners: tuple[str, ...]
    source_mappings: tuple[SourceMapping, ...]
    verification_ids: tuple[str, ...]
    test_references: tuple[AuthorityReference, ...]
    proof_references: tuple[AuthorityReference, ...]
    figma_references: tuple[AuthorityReference, ...]
    linear_references: tuple[AuthorityReference, ...]
    findings: tuple[Finding, ...]


@dataclass(frozen=True, slots=True)
class TraceabilityReport:
    records: tuple[TraceabilityRecord, ...]
    findings: tuple[Finding, ...]


@dataclass(frozen=True, slots=True)
class TraceabilityInputSnapshot:
    reference_snapshot: ExternalReferenceSnapshot
    implementation_files: tuple[PurePosixPath, ...]
    owner_mappings: tuple[SourceMapping, ...]
    input_sha: str


_GAP_DESCRIPTOR = re.compile(
    r"(?:^|\s)gap_class=(?P<gap_class>[^\s]+) "
    r"affected_ids=(?P<affected_ids>[^\s]+)"
)
_DIRECTIONAL_GAPS = frozenset(
    {
        GapClass.CANON_TO_CODE.value,
        GapClass.CODE_TO_CANON.value,
        GapClass.FIGMA_TO_CANON.value,
        GapClass.LINEAR_TO_CANON.value,
    }
)


def build_traceability(
    registry: CanonRegistry,
    repo_root: Path,
    references: Iterable[AuthorityReference],
    *,
    snapshot: TraceabilityInputSnapshot | None = None,
) -> TraceabilityReport:
    """Build current posture from a live filesystem snapshot and stable links."""

    reference_rows = tuple(sorted(references, key=lambda item: item.reference_id))
    if snapshot is None:
        reference_snapshot = ExternalReferenceSnapshot(
            references=reference_rows,
            source_bytes=(),
            input_sha=_reference_value_sha(reference_rows),
        )
        snapshot = capture_traceability_input_snapshot(
            registry,
            repo_root,
            reference_snapshot,
        )
    references_by_requirement: dict[str, list[AuthorityReference]] = {}
    for reference in reference_rows:
        for requirement_id in reference.requirement_ids:
            references_by_requirement.setdefault(requirement_id, []).append(reference)

    documents_by_requirement = {
        requirement.requirement_id: document
        for document in registry.documents
        for requirement in document.requirements
    }
    records: list[TraceabilityRecord] = []
    external_findings = external_reference_findings(registry, reference_rows, repo_root)
    findings: list[Finding] = list(external_findings)
    invalid_reference_ids = {
        match.group(1)
        for finding in external_findings
        if (match := re.search(r"reference_id=([^\s]+)", finding.message))
    }
    owner_values = tuple(
        sorted(
            {
                owner
                for document in registry.documents
                for owner in document.source_owners
            }
        )
    )
    implementation_files = snapshot.implementation_files
    mapping_by_owner = {item.owner_path: item for item in snapshot.owner_mappings}
    normalized_owners = tuple(
        owner
        for owner in (_safe_relative(value) for value in owner_values)
        if owner is not None
    )
    for requirement in sorted(
        registry.requirements,
        key=lambda item: (item.requirement_id, item.source_path.as_posix(), item.line),
    ):
        document = documents_by_requirement.get(requirement.requirement_id)
        owners = tuple(sorted(set(document.source_owners if document else ())))
        mappings = tuple(mapping_by_owner[owner] for owner in owners)
        record_findings: list[Finding] = []
        if not mappings:
            record_findings.append(_canon_to_code_finding(requirement.requirement_id, None))
        for mapping in mappings:
            if not mapping.has_implementation:
                record_findings.append(
                    _canon_to_code_finding(requirement.requirement_id, mapping.owner_path)
                )
        linked = tuple(
            sorted(
                (
                    item
                    for item in references_by_requirement.get(
                        requirement.requirement_id, ()
                    )
                    if item.reference_id not in invalid_reference_ids
                    and item.approval_state == "approved"
                ),
                key=lambda item: item.reference_id,
            )
        )
        records.append(
            TraceabilityRecord(
                requirement_id=requirement.requirement_id,
                source_owners=owners,
                source_mappings=mappings,
                verification_ids=tuple(sorted(set(requirement.verification))),
                test_references=_of_kind(linked, AuthorityReferenceKind.TEST),
                proof_references=_of_kind(linked, AuthorityReferenceKind.PROOF),
                figma_references=_of_kind(linked, AuthorityReferenceKind.FIGMA),
                linear_references=_of_kind(linked, AuthorityReferenceKind.LINEAR),
                findings=tuple(record_findings),
            )
        )
        findings.extend(record_findings)

    for relative in implementation_files:
        if not any(_owned_by(relative, owner) for owner in normalized_owners):
            descriptor = GapDescriptor(GapClass.CODE_TO_CANON, (relative.as_posix(),))
            findings.append(
                Finding(
                    code="CANON_TRACE_CODE_TO_CANON",
                    severity=descriptor.severity,
                    message=f"{descriptor.serialize()} unowned implementation file",
                    path=relative,
                )
            )
    return TraceabilityReport(
        records=tuple(records),
        findings=tuple(
            sorted(
                findings,
                key=lambda item: (
                    item.code,
                    item.path.as_posix() if item.path else "",
                    item.message,
                ),
            )
        ),
    )


def capture_traceability_input_snapshot(
    registry: CanonRegistry,
    repo_root: Path,
    reference_snapshot: ExternalReferenceSnapshot,
) -> TraceabilityInputSnapshot:
    """Pin external bytes and the live path inventory used by projections."""

    owner_values = tuple(
        sorted(
            {
                owner
                for document in registry.documents
                for owner in document.source_owners
            }
        )
    )
    implementation_files = _implementation_files(repo_root)
    owner_mappings = tuple(
        _source_mapping(repo_root, owner, implementation_files)
        for owner in owner_values
    )
    digest = hashlib.sha256()
    digest.update(reference_snapshot.input_sha.encode("ascii"))
    for path in implementation_files:
        value = path.as_posix().encode("utf-8")
        digest.update(len(value).to_bytes(8, "big"))
        digest.update(value)
    for mapping in owner_mappings:
        value = (
            f"{mapping.owner_path}\0{int(mapping.exists)}\0{mapping.status}\0"
            f"{','.join(mapping.implementation_files)}"
        ).encode("utf-8")
        digest.update(len(value).to_bytes(8, "big"))
        digest.update(value)
    return TraceabilityInputSnapshot(
        reference_snapshot=reference_snapshot,
        implementation_files=implementation_files,
        owner_mappings=owner_mappings,
        input_sha=digest.hexdigest(),
    )


def validate_traceability_input_snapshot(
    registry: CanonRegistry,
    repo_root: Path,
    snapshot: TraceabilityInputSnapshot,
) -> None:
    current = capture_traceability_input_snapshot(
        registry,
        repo_root,
        snapshot.reference_snapshot,
    )
    if current.input_sha != snapshot.input_sha:
        from tools.ambitions_canon.model import CanonError

        raise CanonError(
            "CANON_TRACEABILITY_INPUT_CHANGED",
            "live source-owner inventory changed during traceability generation",
            repo_root,
        )


def render_traceability_maps(
    report: TraceabilityReport,
    metadata: Mapping[str, object] | None = None,
) -> Mapping[Path, bytes]:
    """Render the three law maps with stable IDs, records, and gap posture."""

    base = dict(metadata or {"schema_version": 1})
    finding_inventory = _finding_inventory(report)
    return {
        Path("law-source-map.json"): stable_json(
            {
                **base,
                "source_inventory": _source_inventory(report),
                "finding_inventory": finding_inventory,
                "mappings": [_source_row(item) for item in report.records],
            }
        ),
        Path("law-test-map.json"): stable_json(
            {
                **base,
                "mappings": [
                    _reference_row(item, item.test_references, "test")
                    for item in report.records
                ],
            }
        ),
        Path("law-proof-map.json"): stable_json(
            {
                **base,
                "mappings": [
                    _reference_row(item, item.proof_references, "proof")
                    for item in report.records
                ],
            }
        ),
    }


def _source_mapping(
    repo_root: Path,
    owner: str,
    implementation_files: tuple[PurePosixPath, ...],
) -> SourceMapping:
    relative = _safe_relative(owner)
    if relative is None:
        return SourceMapping(owner, False, (), "invalid_owner_path")
    path_kind = _path_kind_nofollow(repo_root, relative)
    if path_kind == "invalid":
        return SourceMapping(owner, False, (), "invalid_owner_path")
    exists = path_kind is not None
    mapped_files: tuple[str, ...] = ()
    if path_kind == "file":
        if relative.suffix.lower() in IMPLEMENTATION_SUFFIXES:
            mapped_files = (relative.as_posix(),)
    elif path_kind == "directory":
        mapped_files = tuple(
            item.as_posix()
            for item in implementation_files
            if _owned_by(item, relative)
        )
    status = (
        "source_files_present"
        if mapped_files
        else "owner_path_present_without_implementation"
        if exists
        else "owner_path_absent"
    )
    return SourceMapping(owner, exists, mapped_files, status)


def _implementation_files(repo_root: Path) -> tuple[PurePosixPath, ...]:
    files: list[PurePosixPath] = []
    for scan_root in SOURCE_SCAN_ROOTS:
        root = repo_root / scan_root
        if root.is_symlink() or not root.is_dir():
            continue
        files.extend(
            PurePosixPath(item.relative_to(repo_root).as_posix())
            for item in root.rglob("*")
            if not item.is_symlink()
            and item.is_file()
            and item.suffix.lower() in IMPLEMENTATION_SUFFIXES
        )
    return tuple(sorted(set(files), key=lambda item: item.as_posix()))


def _safe_relative(value: str) -> PurePosixPath | None:
    path = PurePosixPath(value.rstrip("/"))
    if path.is_absolute() or not path.parts or ".." in path.parts:
        return None
    return path


def _path_kind_nofollow(
    repo_root: Path,
    relative: PurePosixPath,
) -> str | None:
    directory_flags = (
        os.O_RDONLY
        | os.O_DIRECTORY
        | os.O_NOFOLLOW
        | getattr(os, "O_CLOEXEC", 0)
    )
    descriptors: list[int] = []
    try:
        current = os.open(repo_root, directory_flags)
        descriptors.append(current)
        for component in relative.parts[:-1]:
            current = os.open(component, directory_flags, dir_fd=current)
            descriptors.append(current)
        info = os.stat(relative.parts[-1], dir_fd=current, follow_symlinks=False)
        if stat.S_ISLNK(info.st_mode):
            return "invalid"
        if stat.S_ISDIR(info.st_mode):
            descriptor = os.open(relative.parts[-1], directory_flags, dir_fd=current)
            descriptors.append(descriptor)
            return "directory"
        if stat.S_ISREG(info.st_mode):
            return "file"
        return "invalid"
    except FileNotFoundError:
        return None
    except OSError:
        return "invalid"
    finally:
        for descriptor in reversed(descriptors):
            os.close(descriptor)


def _owned_by(path: PurePosixPath, owner: PurePosixPath) -> bool:
    path_value = path.as_posix()
    owner_value = owner.as_posix().rstrip("/")
    return path_value == owner_value or path_value.startswith(owner_value + "/")


def _canon_to_code_finding(requirement_id: str, owner: str | None) -> Finding:
    descriptor = GapDescriptor(GapClass.CANON_TO_CODE, (requirement_id,))
    detail = "no source owner mapping" if owner is None else f"owner={owner}"
    return Finding(
        code="CANON_TRACE_CANON_TO_CODE",
        severity=descriptor.severity,
        message=(
            f"{descriptor.serialize()} {detail}; missing mapping is a gap and "
            "does not prove absent implementation"
        ),
        path=Path(owner.rstrip("/")) if owner else None,
    )


def _of_kind(
    references: Iterable[AuthorityReference],
    kind: AuthorityReferenceKind,
) -> tuple[AuthorityReference, ...]:
    return tuple(item for item in references if item.reference_kind is kind)


def _source_row(record: TraceabilityRecord) -> dict[str, object]:
    if any(item.has_implementation for item in record.source_mappings):
        current_claim_posture = "source_present_unverified"
    elif record.source_mappings:
        current_claim_posture = "source_mapping_gap"
    else:
        current_claim_posture = "source_owner_gap"
    return {
        "requirement_id": record.requirement_id,
        "references": list(record.source_owners),
        "source_owners": list(record.source_owners),
        "mappings": [
            {
                "exists": item.exists,
                "has_implementation": item.has_implementation,
                "owner_path": item.owner_path,
                "status": item.status,
            }
            for item in record.source_mappings
        ],
        "gaps": [item.message for item in record.findings],
        "current_claim_posture": current_claim_posture,
    }


def _source_inventory(report: TraceabilityReport) -> list[dict[str, object]]:
    unique = {
        item.owner_path: item
        for record in report.records
        for item in record.source_mappings
    }
    return [
        {
            "exists": item.exists,
            "implementation_file_count": len(item.implementation_files),
            "implementation_files": list(item.implementation_files),
            "owner_path": item.owner_path,
            "status": item.status,
        }
        for item in (unique[key] for key in sorted(unique))
    ]


def _reference_row(
    record: TraceabilityRecord,
    references: tuple[AuthorityReference, ...],
    kind: str,
) -> dict[str, object]:
    verification = tuple(
        item
        for item in record.verification_ids
        if _verification_kind(item) == kind
    )
    mapped = bool(references)
    return {
        "requirement_id": record.requirement_id,
        "references": [
            {
                "approval_state": item.approval_state,
                "reference_id": item.reference_id,
                "revision": item.revision,
                "source": item.source,
            }
            for item in references
        ],
        "required_verification_ids": list(verification),
        "mapping_status": "mapped" if mapped else "gap",
        "current_claim_posture": (
            "current_evidence_mapped"
            if mapped
            else "required_but_unverified"
            if verification
            else "no_current_evidence"
        ),
        "gap_note": (
            None
            if mapped
            else "missing mapping is a gap and does not prove absent implementation"
        ),
    }


def _verification_kind(identifier: str) -> str:
    upper = identifier.upper()
    if upper.startswith("PROOF"):
        return "proof"
    return "test"


def _finding_inventory(report: TraceabilityReport) -> list[dict[str, object]]:
    rows: list[dict[str, object]] = []
    for finding in report.findings:
        match = _GAP_DESCRIPTOR.search(finding.message)
        if match is None or match.group("gap_class") not in _DIRECTIONAL_GAPS:
            continue
        rows.append(
            {
                "affected_ids": match.group("affected_ids").split(","),
                "code": finding.code,
                "gap_class": match.group("gap_class"),
                "message": finding.message,
                "path": finding.path.as_posix() if finding.path else None,
                "severity": finding.severity.value,
            }
        )
    return sorted(
        rows,
        key=lambda item: (
            str(item["gap_class"]),
            str(item["code"]),
            str(item["path"] or ""),
            tuple(item["affected_ids"]),
            str(item["message"]),
        ),
    )


def _reference_value_sha(references: tuple[AuthorityReference, ...]) -> str:
    digest = hashlib.sha256()
    for reference in references:
        value = repr(reference).encode("utf-8")
        digest.update(len(value).to_bytes(8, "big"))
        digest.update(value)
    return digest.hexdigest()
