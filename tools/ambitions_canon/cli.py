"""Command-line entrypoint for the Ambitions canon compiler."""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import stat
import subprocess
import sys
from collections.abc import Sequence
from dataclasses import dataclass
from pathlib import Path

from tools.ambitions_canon import __version__
from tools.ambitions_canon.audit import audit_registry
from tools.ambitions_canon.build import build_canon
from tools.ambitions_canon.build import (
    _open_parent_nofollow,
    _read_descriptor,
)
from tools.ambitions_canon.coverage import coverage_findings, load_profiles
from tools.ambitions_canon.impact import write_amendment_scaffold
from tools.ambitions_canon.manifest import load_documents, load_manifest
from tools.ambitions_canon.migration import (
    claim_coverage,
    import_claim_batches,
    register_repo_sources,
    register_source,
    verify_catalog,
)
from tools.ambitions_canon.model import (
    CanonDocument,
    CanonError,
    Finding,
    GapSeverity,
    Requirement,
)
from tools.ambitions_canon.query import query_by_concept, query_by_id
from tools.ambitions_canon.registry import build_registry
from tools.ambitions_canon.render import stable_json
from tools.ambitions_canon.task_pack import (
    TaskIntake,
    TaskPack,
    build_task_pack,
    read_task_pack_pair,
    validate_task_pack,
    write_task_pack,
)


PUBLIC_AUDIT_CODES = frozenset(
    {
        "CANON_ID_DUPLICATE",
        "CANON_CONCEPT_DUPLICATE_OWNER",
        "CANON_CONCEPT_UNOWNED",
        "CANON_DEPENDENCY_UNKNOWN",
        "CANON_DEPENDENCY_CYCLE",
        "CANON_MODALITY_INVALID",
        "CANON_SUPERSEDED_REFERENCE",
        "CANON_ACTIVE_CONSTITUTION_COUNT",
    }
)
AUDIT_CODE_BY_DISCOVERY_CODE = {
    "CANON_ID_DUPLICATE": "CANON_ID_DUPLICATE",
    "CANON_REQUIREMENT_DUPLICATE": "CANON_ID_DUPLICATE",
    "CANON_CONCEPT_DUPLICATE_OWNER": "CANON_CONCEPT_DUPLICATE_OWNER",
    "CANON_CONCEPT_UNOWNED": "CANON_CONCEPT_UNOWNED",
    "CANON_DEPENDENCY_UNKNOWN": "CANON_DEPENDENCY_UNKNOWN",
    "CANON_DEPENDENCY_CYCLE": "CANON_DEPENDENCY_CYCLE",
    "CANON_REQUIREMENT_MODALITY": "CANON_MODALITY_INVALID",
    "CANON_MODALITY_INVALID": "CANON_MODALITY_INVALID",
    "CANON_SUPERSEDED_REFERENCE": "CANON_SUPERSEDED_REFERENCE",
    "CANON_MANIFEST_CONSTITUTION_REQUIRED": "CANON_ACTIVE_CONSTITUTION_COUNT",
    "CANON_ACTIVE_CONSTITUTION_COUNT": "CANON_ACTIVE_CONSTITUTION_COUNT",
}


@dataclass(frozen=True, slots=True)
class _PackSourceSnapshot:
    canon_revision: int
    canon_sha: str
    repository_sha: str
    intake_sha: str
    intake_content_sha: str
    source_owners: tuple[str, ...]
    pack_content_sha: str


def normalize_audit_error_code(discovery_code: str) -> str:
    """Map a lower-layer validation code to the public audit contract."""

    return AUDIT_CODE_BY_DISCOVERY_CODE.get(discovery_code, discovery_code)


def ensure_supported_python(version: tuple[int, int]) -> None:
    if version < (3, 11):
        raise CanonError(
            "PYTHON_VERSION_UNSUPPORTED",
            "requires Python 3.11+",
        )


def main(argv: Sequence[str] | None = None) -> int:
    ensure_supported_python((sys.version_info.major, sys.version_info.minor))

    parser = argparse.ArgumentParser(prog="ambitions-canon")
    subparsers = parser.add_subparsers(dest="command", required=True)
    subparsers.add_parser("version", help="print the compiler version")
    subparsers.add_parser("audit", help="audit the canonical registry")
    build_parser = subparsers.add_parser(
        "build", help="generate deterministic canon projections"
    )
    build_parser.add_argument(
        "--check",
        action="store_true",
        help="compare generated outputs without writing",
    )
    coverage_parser = subparsers.add_parser(
        "coverage", help="check specification completeness profiles"
    )
    coverage_parser.add_argument(
        "--fail-on-p0-gap",
        action="store_true",
        help="exit nonzero when a P0 completeness gap exists",
    )
    query_parser = subparsers.add_parser(
        "query", help="query the canonical registry by exact ID or concept"
    )
    query_selector = query_parser.add_mutually_exclusive_group(required=True)
    query_selector.add_argument(
        "--id",
        dest="identifier",
        help="exact specification or requirement ID",
    )
    query_selector.add_argument(
        "--concept",
        help="exact normalized concept",
    )
    pack_parser = subparsers.add_parser(
        "pack", help="generate a bounded, stale-safe Codex task pack"
    )
    pack_parser.add_argument(
        "--issue-json",
        type=Path,
        required=True,
        help="closed task-intake JSON contract",
    )
    pack_parser.add_argument(
        "--check",
        action="store_true",
        help="reject a stored pack that does not match current state",
    )
    amend_parser = subparsers.add_parser(
        "amend", help="prepare a governed temporary canon amendment"
    )
    amend_subparsers = amend_parser.add_subparsers(dest="amend_command", required=True)
    scaffold_parser = amend_subparsers.add_parser(
        "scaffold", help="write a complete non-normative amendment docket"
    )
    scaffold_parser.add_argument(
        "--concept",
        required=True,
        help="exact normalized concept key under amendment",
    )
    scaffold_parser.add_argument(
        "--output",
        required=True,
        type=Path,
        help="output below .codex/canon-migration",
    )
    migration_parser = subparsers.add_parser(
        "migration", help="register and verify offline migration sources"
    )
    migration_subparsers = migration_parser.add_subparsers(
        dest="migration_command", required=True
    )
    register_parser = migration_subparsers.add_parser(
        "register", help="register exact ignored connector bytes"
    )
    register_parser.add_argument("--catalog", type=Path, required=True)
    register_parser.add_argument("--raw", type=Path, required=True)
    register_parser.add_argument("--source-id", required=True)
    register_parser.add_argument("--kind", required=True)
    register_parser.add_argument("--title", required=True)
    register_parser.add_argument("--locator", required=True)
    register_parser.add_argument("--updated-at", required=True)
    register_parser.add_argument("--owner", required=True)
    register_parser.add_argument("--authority-claim", required=True)
    repo_parser = migration_subparsers.add_parser(
        "register-repo", help="register clean tracked repo authority sources"
    )
    repo_parser.add_argument("--catalog", type=Path, required=True)
    repo_parser.add_argument("--pathspec", action="append", required=True)
    verify_parser = migration_subparsers.add_parser(
        "verify", help="verify all migration sources offline"
    )
    verify_parser.add_argument(
        "--catalog",
        type=Path,
        default=Path("docs/canon/migration/source-catalog.json"),
    )
    claims_parser = migration_subparsers.add_parser(
        "claims", help="import and check atomic migration claims"
    )
    claims_subparsers = claims_parser.add_subparsers(
        dest="claims_command", required=True
    )
    claims_import_parser = claims_subparsers.add_parser(
        "import", help="validate and integrate ignored atomic-claim batches"
    )
    claims_import_parser.add_argument("--input-dir", type=Path, required=True)
    claims_import_parser.add_argument(
        "--catalog",
        type=Path,
        default=Path("docs/canon/migration/source-catalog.json"),
    )
    claims_import_parser.add_argument(
        "--output",
        type=Path,
        default=Path("docs/canon/migration/claim-dispositions.json"),
    )
    claims_coverage_parser = claims_subparsers.add_parser(
        "coverage", help="check registered source-section claim coverage"
    )
    claims_coverage_parser.add_argument(
        "--dispositions",
        type=Path,
        default=Path("docs/canon/migration/claim-dispositions.json"),
    )
    claims_coverage_parser.add_argument("--concept-prefix")
    claims_coverage_parser.add_argument("--target-class")
    claims_coverage_parser.add_argument("--output", type=Path)
    arguments = parser.parse_args(argv)

    if arguments.command == "version":
        print(f"ambitions-canon {__version__}")
        return 0

    if arguments.command == "audit":
        return _audit(Path.cwd())

    if arguments.command == "build":
        return _build(Path.cwd(), check=arguments.check)

    if arguments.command == "coverage":
        return _coverage(
            Path.cwd(),
            fail_on_p0_gap=arguments.fail_on_p0_gap,
        )

    if arguments.command == "query":
        return _query(
            Path.cwd(),
            identifier=arguments.identifier,
            concept=arguments.concept,
        )

    if arguments.command == "pack":
        issue_path = arguments.issue_json
        if not issue_path.is_absolute():
            issue_path = Path.cwd() / issue_path
        return _pack(Path.cwd(), issue_path, check=arguments.check)

    if arguments.command == "amend":
        assert arguments.amend_command == "scaffold"
        return _amend_scaffold(
            Path.cwd(),
            concept=arguments.concept,
            output=arguments.output,
        )

    if arguments.command == "migration":
        return _migration(Path.cwd(), arguments)

    raise AssertionError(f"unhandled command: {arguments.command}")


def _migration(root: Path, arguments: argparse.Namespace) -> int:
    if arguments.migration_command == "claims":
        return _migration_claims(root, arguments)
    catalog = arguments.catalog
    if not catalog.is_absolute():
        catalog = root / catalog
    try:
        if arguments.migration_command == "register":
            raw = arguments.raw
            if not raw.is_absolute():
                raw = root / raw
            record = register_source(
                catalog,
                raw,
                {
                    "source_id": arguments.source_id,
                    "kind": arguments.kind,
                    "title": arguments.title,
                    "locator": arguments.locator,
                    "updated_at": arguments.updated_at,
                    "owner": arguments.owner,
                    "authority_claim": arguments.authority_claim,
                },
            )
            print(
                "GREEN ambitions canon migration source "
                f"source_id={record.source_id} sha256={record.raw_sha256}"
            )
            return 0
        if arguments.migration_command == "register-repo":
            records = register_repo_sources(catalog, root, arguments.pathspec)
            print(
                "GREEN ambitions canon migration repo sources "
                f"registered={len(records)}"
            )
            return 0
        if arguments.migration_command == "verify":
            findings = verify_catalog(catalog, root)
            if findings:
                for finding in findings:
                    location = (
                        finding.path.as_posix()
                        if finding.path is not None
                        else "<migration>"
                    )
                    print(
                        f"{finding.severity.value} {finding.code} "
                        f"{location}:{finding.line or 0} {finding.message}"
                    )
                return 1
            from tools.ambitions_canon.migration import load_source_catalog

            records = load_source_catalog(catalog)
            print(f"GREEN ambitions canon migration verify sources={len(records)}")
            return 0
        raise AssertionError(
            f"unhandled migration command: {arguments.migration_command}"
        )
    except CanonError as error:
        location = error.path.as_posix() if error.path is not None else "<migration>"
        print(f"P0_BLOCKER {error.code} {location}:{error.line or 0} {error.message}")
        return 1


def _migration_claims(root: Path, arguments: argparse.Namespace) -> int:
    try:
        if arguments.claims_command == "import":
            input_dir = _rooted(root, arguments.input_dir)
            catalog = _rooted(root, arguments.catalog)
            output = _rooted(root, arguments.output)
            result = import_claim_batches(root, input_dir, catalog, output)
            print(
                "GREEN ambitions canon migration claims import "
                f"sources={result.source_count} sections={result.section_count} "
                f"decisions={result.linear_decision_count} claims={result.claim_count}"
            )
            return 0
        if arguments.claims_command == "coverage":
            dispositions = _rooted(root, arguments.dispositions)
            report = claim_coverage(
                dispositions,
                concept_prefix=arguments.concept_prefix,
                target_class=arguments.target_class,
            )
            if arguments.output is not None:
                from tools.ambitions_canon.migration import _write_claim_json

                _write_claim_json(_rooted(root, arguments.output), report.to_dict())
            if not report.complete:
                for item in report.uncovered:
                    print(
                        "P0_BLOCKER CLAIM_COVERAGE_INCOMPLETE "
                        f"{item['source_id']}:{item['source_location']}"
                    )
                return 1
            print(
                "GREEN ambitions canon migration claims coverage "
                f"sources={report.source_count} sections={report.section_count} "
                f"decisions={report.linear_decision_count} claims={len(report.claims)}"
            )
            return 0
        raise AssertionError(f"unhandled claims command: {arguments.claims_command}")
    except CanonError as error:
        location = error.path.as_posix() if error.path is not None else "<claims>"
        print(f"P0_BLOCKER {error.code} {location}:{error.line or 0} {error.message}")
        return 1


def _rooted(root: Path, path: Path) -> Path:
    return path if path.is_absolute() else root / path


def _amend_scaffold(root: Path, *, concept: str, output: Path) -> int:
    try:
        written = write_amendment_scaffold(root, output, concept)
    except CanonError as error:
        location = error.path.as_posix() if error.path is not None else "<registry>"
        location = f"{location}:{error.line or 0}"
        print(f"{error.code} {location} {error.message}")
        return 1
    print(f"GREEN ambitions canon amendment scaffold {written.as_posix()}")
    return 0


def _audit(root: Path) -> int:
    try:
        manifest = load_manifest(root)
        documents = load_documents(root, manifest)
        registry = build_registry(manifest, documents)
        findings = audit_registry(registry)
    except CanonError as error:
        findings = (
            Finding(
                code=normalize_audit_error_code(error.code),
                severity=GapSeverity.P0_BLOCKER,
                message=error.message,
                path=error.path,
                line=error.line,
            ),
        )
        manifest = None
        documents = ()
        registry = None

    if findings:
        for finding in findings:
            location = (
                finding.path.as_posix() if finding.path is not None else "<registry>"
            )
            location = f"{location}:{finding.line or 0}"
            print(
                f"{finding.severity.value} {finding.code} {location} {finding.message}"
            )
        return (
            1
            if any(
                finding.severity in (GapSeverity.P0_BLOCKER, GapSeverity.P1_REQUIRED)
                for finding in findings
            )
            else 0
        )

    assert manifest is not None
    assert registry is not None
    print(
        "GREEN ambitions canon audit "
        f"documents={len(documents)} "
        f"requirements={len(registry.requirements)} "
        f"concepts={len(registry.concept_owners)} "
        f"authority_state={manifest.authority_state.value}"
    )
    return 0


def _build(root: Path, *, check: bool) -> int:
    try:
        findings = build_canon(root, check=check)
    except CanonError as error:
        location = error.path.as_posix() if error.path is not None else "<registry>"
        location = f"{location}:{error.line or 0}"
        print(f"P0_BLOCKER {error.code} {location} {error.message}")
        return 1

    if findings:
        for finding in findings:
            location = (
                finding.path.as_posix() if finding.path is not None else "<registry>"
            )
            location = f"{location}:{finding.line or 0}"
            print(
                f"{finding.severity.value} {finding.code} {location} {finding.message}"
            )
        return 1

    print("GREEN ambitions canon generated outputs")
    return 0


def _coverage(root: Path, *, fail_on_p0_gap: bool) -> int:
    try:
        manifest = load_manifest(root)
        documents = load_documents(root, manifest)
        registry = build_registry(manifest, documents)
        profiles = load_profiles(root / "docs/canon/schemas/completeness-profiles.toml")
        findings = coverage_findings(registry, profiles)
    except CanonError as error:
        location = error.path.as_posix() if error.path is not None else "<registry>"
        location = f"{location}:{error.line or 0}"
        print(f"P0_BLOCKER {error.code} {location} {error.message}")
        return 1

    if findings:
        for finding in findings:
            location = (
                finding.path.as_posix() if finding.path is not None else "<registry>"
            )
            location = f"{location}:{finding.line or 0}"
            print(
                f"{finding.severity.value} {finding.code} {location} {finding.message}"
            )
        if fail_on_p0_gap and any(
            finding.severity is GapSeverity.P0_BLOCKER for finding in findings
        ):
            return 1
        return 0

    print(
        "GREEN ambitions canon coverage "
        f"documents={len(documents)} "
        f"profiles={len(profiles)} "
        f"authority_state={manifest.authority_state.value}"
    )
    return 0


def _query(
    root: Path,
    *,
    identifier: str | None,
    concept: str | None,
) -> int:
    """Render one deterministic exact registry query as stable JSON."""

    try:
        manifest = load_manifest(root)
        documents = load_documents(root, manifest)
        registry = build_registry(manifest, documents)
        findings = audit_registry(registry)
        if findings:
            finding = findings[0]
            raise CanonError(
                normalize_audit_error_code(finding.code),
                finding.message,
                finding.path,
                finding.line,
            )
        if identifier is not None:
            payload = _query_item_payload(query_by_id(registry, identifier))
        else:
            assert concept is not None
            requirements = query_by_concept(registry, concept)
            if not requirements:
                raise CanonError(
                    "CANON_QUERY_NOT_FOUND",
                    f"canonical concept was not found: {concept}",
                    manifest.source_path,
                )
            payload = {
                "schema_version": 1,
                "concept": concept,
                "requirements": [
                    _requirement_payload(requirement)
                    for requirement in sorted(
                        requirements,
                        key=lambda item: item.requirement_id,
                    )
                ],
            }
        print(stable_json(payload).decode("utf-8"), end="")
        return 0
    except CanonError as error:
        location = error.path.as_posix() if error.path is not None else "<registry>"
        location = f"{location}:{error.line or 0}"
        print(f"{error.code} {location} {error.message}")
        return 1


def _query_item_payload(item: object) -> dict[str, object]:
    if isinstance(item, CanonDocument):
        return {
            "schema_version": 1,
            "item_type": "specification",
            "spec_id": item.spec_id,
            "title": item.title,
            "kind": item.kind.value,
            "status": item.status,
            "owner_domain": item.owner_domain,
            "canon_revision": item.canon_revision,
            "profile": item.profile,
            "owns_concepts": sorted(item.owns_concepts),
            "inherits": sorted(item.inherits),
            "depends_on": sorted(item.depends_on),
            "source_owners": sorted(item.source_owners),
            "not_applicable": [
                {
                    "section": entry.section,
                    "rationale": entry.rationale,
                    "owner": entry.owner,
                }
                for entry in sorted(
                    item.not_applicable,
                    key=lambda entry: entry.section,
                )
            ],
            "requirement_ids": sorted(
                requirement.requirement_id for requirement in item.requirements
            ),
            "source_path": item.source_path.as_posix(),
        }
    if isinstance(item, Requirement):
        return {
            "schema_version": 1,
            "item_type": "requirement",
            **_requirement_payload(item),
        }
    raise CanonError(
        "CANON_QUERY_RESULT_INVALID",
        "query returned an unsupported registry item",
    )


def _requirement_payload(requirement: Requirement) -> dict[str, object]:
    return {
        "requirement_id": requirement.requirement_id,
        "title": requirement.title,
        "concept": requirement.concept,
        "modality": requirement.modality.value,
        "scope": requirement.scope,
        "status": requirement.status,
        "verification": sorted(requirement.verification),
        "supersedes": sorted(requirement.supersedes),
        "body": requirement.body,
        "source_path": requirement.source_path.as_posix(),
        "line": requirement.line,
    }


def _pack(root: Path, issue_path: Path, *, check: bool) -> int:
    """Build or validate one issue-scoped task pack."""

    try:
        try:
            raw_bytes = _read_intake_bytes(issue_path)
            raw = raw_bytes.decode("utf-8")
        except (OSError, UnicodeError) as exc:
            raise CanonError(
                "PACK_INTAKE_READ",
                "unable to read UTF-8 issue intake",
                issue_path,
            ) from exc
        try:
            data = json.loads(raw)
        except json.JSONDecodeError as exc:
            raise CanonError(
                "PACK_INTAKE_INVALID",
                "issue intake is not valid JSON",
                issue_path,
            ) from exc
        if not isinstance(data, dict):
            raise CanonError(
                "PACK_INTAKE_INVALID",
                "issue intake must be a JSON object",
                issue_path,
            )
        intake = TaskIntake.from_json(data).with_source_path(
            _display_path(root, issue_path)
        )
        try:
            manifest = load_manifest(root)
            documents = load_documents(root, manifest)
            registry = build_registry(manifest, documents)
        except CanonError as exc:
            if check:
                raise CanonError(
                    "PACK_CANON_STALE",
                    "canon changed during task-pack use",
                ) from exc
            raise
        findings = audit_registry(registry)
        if findings:
            finding = findings[0]
            raise CanonError(
                finding.code,
                finding.message,
                finding.path,
                finding.line,
            )
        repository_sha = _repository_state_sha(root)
        pack = build_task_pack(registry, intake, repository_sha, ())
        source_snapshot = _pack_source_snapshot(pack, raw_bytes)

        if check:
            (
                markdown_path,
                json_path,
                markdown_bytes,
                json_bytes,
            ) = read_task_pack_pair(root, pack)
            try:
                stored = json.loads(json_bytes.decode("utf-8"))
            except (UnicodeError, json.JSONDecodeError) as exc:
                raise CanonError(
                    "PACK_READ_FAILED",
                    "unable to read stored task pack",
                    json_path,
                ) from exc
            if not isinstance(stored, dict):
                raise CanonError(
                    "PACK_READ_FAILED",
                    "stored task pack must be a JSON object",
                    json_path,
                )
            validate_task_pack(
                stored,
                canon_sha=pack.canon_sha,
                repository_sha=pack.repository_sha,
                intake_sha=pack.intake_sha,
            )
            if stored != pack.to_dict():
                raise CanonError(
                    "PACK_CONTENT_STALE",
                    "stored task-pack content differs from deterministic output",
                    json_path,
                )
            try:
                markdown = markdown_bytes.decode("utf-8")
            except UnicodeError as exc:
                raise CanonError(
                    "PACK_READ_FAILED",
                    "unable to read stored Markdown task pack",
                    markdown_path,
                ) from exc
            if markdown != pack.to_markdown():
                raise CanonError(
                    "PACK_CONTENT_STALE",
                    "stored Markdown task pack differs from deterministic output",
                    markdown_path,
                )
            _require_source_snapshot(root, issue_path, source_snapshot)
            print(
                "GREEN ambitions canon task pack check "
                f"issue={pack.issue_id} authority_state={pack.authority_state}"
            )
            return 0

        markdown_path, json_path = write_task_pack(
            root,
            pack,
            source_precondition=lambda: _require_source_snapshot(
                root,
                issue_path,
                source_snapshot,
            ),
        )
        print(
            "GREEN ambitions canon task pack "
            f"markdown={_display_path(root, markdown_path)} "
            f"json={_display_path(root, json_path)} "
            f"authority_state={pack.authority_state}"
        )
        if manifest.authority_state.value == "shadow":
            print("SHADOW task pack cannot authorize implementation")
        return 0
    except CanonError as error:
        location = error.path.as_posix() if error.path is not None else "<pack>"
        location = f"{location}:{error.line or 0}"
        print(f"P0_BLOCKER {error.code} {location} {error.message}")
        return 1


def _repository_state_sha(root: Path) -> str:
    """Return HEAD when clean, otherwise a HEAD-bound deterministic diff SHA."""

    head = _git(root, "rev-parse", "HEAD").decode("ascii").strip()
    status = _git(
        root,
        "status",
        "--porcelain=v2",
        "-z",
        "--untracked-files=all",
    )
    if not status:
        return head
    diff = _git(root, "diff", "--binary", "--no-ext-diff", "HEAD", "--")
    digest = hashlib.sha256()
    for label, content in (
        (b"HEAD", head.encode("ascii")),
        (b"STATUS", status),
        (b"DIFF", diff),
    ):
        digest.update(len(label).to_bytes(8, "big"))
        digest.update(label)
        digest.update(len(content).to_bytes(8, "big"))
        digest.update(content)
    for path in _untracked_paths(root):
        encoded = path.as_posix().encode("utf-8", "surrogateescape")
        absolute = root / path
        try:
            path_stat = absolute.lstat()
            if stat.S_ISREG(path_stat.st_mode):
                content = absolute.read_bytes()
            elif stat.S_ISLNK(path_stat.st_mode):
                content = os.readlink(absolute).encode("utf-8", "surrogateescape")
            else:
                content = b""
        except OSError as exc:
            raise CanonError(
                "PACK_REPOSITORY_STATE",
                "unable to hash untracked repository state",
                path,
            ) from exc
        digest.update(len(encoded).to_bytes(8, "big"))
        digest.update(encoded)
        digest.update(len(content).to_bytes(8, "big"))
        digest.update(content)
    return f"{head}-dirty-{digest.hexdigest()}"


def _pack_source_snapshot(
    pack: TaskPack,
    intake_bytes: bytes,
) -> _PackSourceSnapshot:
    return _PackSourceSnapshot(
        canon_revision=pack.canon_revision,
        canon_sha=pack.canon_sha,
        repository_sha=pack.repository_sha,
        intake_sha=pack.intake_sha,
        intake_content_sha=hashlib.sha256(intake_bytes).hexdigest(),
        source_owners=pack.source_owners,
        pack_content_sha=hashlib.sha256(pack.to_json_bytes()).hexdigest(),
    )


def _require_source_snapshot(
    root: Path,
    issue_path: Path,
    expected: _PackSourceSnapshot,
) -> None:
    raw_bytes = _read_intake_bytes(issue_path)
    try:
        data = json.loads(raw_bytes.decode("utf-8"))
    except (UnicodeError, json.JSONDecodeError) as exc:
        raise CanonError(
            "PACK_INTAKE_STALE",
            "issue intake changed and is no longer valid UTF-8 JSON",
            issue_path,
        ) from exc
    if not isinstance(data, dict):
        raise CanonError("PACK_INTAKE_STALE", "issue intake root changed", issue_path)
    intake = TaskIntake.from_json(data).with_source_path(
        _display_path(root, issue_path)
    )
    repository_sha = _repository_state_sha(root)
    try:
        manifest = load_manifest(root)
        documents = load_documents(root, manifest)
        registry = build_registry(manifest, documents)
        pack = build_task_pack(registry, intake, repository_sha, ())
    except CanonError as exc:
        raise CanonError(
            "PACK_CANON_STALE",
            "canon changed during task-pack use",
        ) from exc
    current = _pack_source_snapshot(pack, raw_bytes)
    if (
        current.canon_revision != expected.canon_revision
        or current.canon_sha != expected.canon_sha
    ):
        raise CanonError("PACK_CANON_STALE", "canon changed during task-pack use")
    if (
        current.intake_sha != expected.intake_sha
        or current.intake_content_sha != expected.intake_content_sha
    ):
        raise CanonError("PACK_INTAKE_STALE", "intake changed during task-pack use")
    if current.repository_sha != expected.repository_sha:
        raise CanonError(
            "PACK_REPOSITORY_STALE",
            "repository changed during task-pack use",
        )
    if (
        current.source_owners != expected.source_owners
        or current.pack_content_sha != expected.pack_content_sha
    ):
        raise CanonError("PACK_SOURCE_STALE", "pack source inputs changed")


def _read_intake_bytes(path: Path) -> bytes:
    try:
        with _open_parent_nofollow(path) as (parent_descriptor, name, absolute):
            descriptor = os.open(
                name,
                os.O_RDONLY | os.O_NOFOLLOW | getattr(os, "O_CLOEXEC", 0),
                dir_fd=parent_descriptor,
            )
            try:
                if not stat.S_ISREG(os.fstat(descriptor).st_mode):
                    raise OSError("intake is not a regular file")
                return _read_descriptor(descriptor)
            finally:
                os.close(descriptor)
    except (OSError, CanonError) as exc:
        raise CanonError(
            "PACK_INTAKE_READ",
            "unable to read issue intake without following links",
            path,
        ) from exc


def _untracked_paths(root: Path) -> tuple[Path, ...]:
    output = _git(root, "ls-files", "--others", "--exclude-standard", "-z")
    return tuple(
        sorted(
            (
                Path(value.decode("utf-8", "surrogateescape"))
                for value in output.split(b"\0")
                if value
            ),
            key=lambda path: path.as_posix(),
        )
    )


def _git(root: Path, *arguments: str) -> bytes:
    try:
        result = subprocess.run(
            ("git", *arguments),
            cwd=root,
            check=False,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )
    except OSError as exc:
        raise CanonError(
            "PACK_REPOSITORY_STATE",
            "unable to execute Git for task-pack provenance",
            root,
        ) from exc
    if result.returncode != 0:
        raise CanonError(
            "PACK_REPOSITORY_STATE",
            "unable to read Git repository state",
            root,
        )
    return result.stdout


def _display_path(root: Path, path: Path) -> str:
    try:
        return path.resolve().relative_to(root.resolve()).as_posix()
    except (OSError, ValueError):
        return path.as_posix()
