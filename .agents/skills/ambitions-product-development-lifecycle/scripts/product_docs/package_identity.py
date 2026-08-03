"""Deterministic identity checks for the lifecycle skill package."""

from __future__ import annotations

import hashlib
import json
from pathlib import Path
import stat
from typing import Any, Mapping

from .constants import SKILL_VERSION
from .errors import Diagnostic, ProductDocsError
from .repository import GitRepository, validate_repository_path


MANIFEST_SCHEMA = 1
MANIFEST_NAME = "package-manifest.json"
OPERATIONAL_DIRECTORIES = ("agents", "assets", "references", "scripts")
SUPPORTED_DOCUMENT_CONTRACTS = (
    {"schema_version": 1, "template_versions": ("research-v1", "scope-v1", "design-v1")},
)
TEMPLATE_PATHS = {
    "research-v1": "assets/templates/v1/research.md",
    "scope-v1": "assets/templates/v1/scope.md",
    "design-v1": "assets/templates/v1/design.md",
}


def _sha256(contents: bytes) -> str:
    return hashlib.sha256(contents).hexdigest()


def _prefixed_sha256(contents: bytes) -> str:
    return f"sha256:{_sha256(contents)}"


def _manifest_contracts() -> list[dict[str, object]]:
    return [
        {
            "schema_version": contract["schema_version"],
            "template_versions": list(contract["template_versions"]),
        }
        for contract in SUPPORTED_DOCUMENT_CONTRACTS
    ]


def _operational_files(skill_root: Path) -> tuple[Path, ...]:
    skill_root = Path(skill_root)
    if skill_root.is_symlink():
        raise ProductDocsError(Diagnostic("unsafe-operational-path", "Skill package root must not be a symbolic link"))
    required = skill_root / "SKILL.md"
    if required.is_symlink():
        raise ProductDocsError(Diagnostic("unsafe-operational-path", "SKILL.md must not be a symbolic link"))
    if not required.is_file():
        raise ProductDocsError(Diagnostic("package-operational-file-missing", "SKILL.md must be a regular operational file"))
    files = [required]
    for directory_name in OPERATIONAL_DIRECTORIES:
        directory = skill_root / directory_name
        try:
            mode = directory.lstat().st_mode
        except FileNotFoundError:
            continue
        if stat.S_ISLNK(mode) or not stat.S_ISDIR(mode):
            raise ProductDocsError(Diagnostic("unsafe-operational-path", "Operational package directories must be regular directories"))
        for candidate in directory.rglob("*"):
            if candidate.is_symlink():
                raise ProductDocsError(Diagnostic("unsafe-operational-path", "Operational package paths must not be symbolic links", path=candidate.relative_to(skill_root).as_posix()))
            if not candidate.is_file():
                continue
            relative_parts = candidate.relative_to(skill_root).parts
            if "__pycache__" in relative_parts or candidate.suffix == ".pyc":
                continue
            files.append(candidate)
    return tuple(sorted(files, key=lambda file: file.relative_to(skill_root).as_posix()))


def build_manifest(skill_root: Path | str) -> dict[str, object]:
    """Build the complete version-one manifest from exact operational bytes."""
    root = Path(skill_root)
    files = [
        {
            "path": path.relative_to(root).as_posix(),
            "sha256": _sha256(path.read_bytes()),
        }
        for path in _operational_files(root)
    ]
    return {
        "manifest_schema": MANIFEST_SCHEMA,
        "skill_version": SKILL_VERSION,
        "supported_document_contracts": _manifest_contracts(),
        "files": files,
    }


def canonical_manifest_bytes(manifest: Mapping[str, Any]) -> bytes:
    return json.dumps(manifest, sort_keys=True, separators=(",", ":"), ensure_ascii=False).encode("utf-8") + b"\n"


def package_hash(manifest: Mapping[str, Any] | bytes) -> str:
    contents = manifest if isinstance(manifest, bytes) else canonical_manifest_bytes(manifest)
    return _prefixed_sha256(contents)


def _load_manifest_bytes(contents: bytes, *, path: str, diagnostic_code: str) -> dict[str, object]:
    try:
        manifest = json.loads(contents.decode("utf-8"))
    except (UnicodeDecodeError, json.JSONDecodeError) as error:
        raise ProductDocsError(Diagnostic(diagnostic_code, "Package manifest must be UTF-8 JSON", path=path)) from error
    if not isinstance(manifest, dict):
        raise ProductDocsError(Diagnostic(diagnostic_code, "Package manifest must be a JSON object", path=path))
    if contents != canonical_manifest_bytes(manifest):
        raise ProductDocsError(Diagnostic(diagnostic_code, "Package manifest must use canonical JSON with one terminal LF", path=path))
    return manifest


def _file_records(manifest: Mapping[str, object], *, diagnostic_code: str) -> tuple[dict[str, str], ...]:
    files = manifest.get("files")
    if not isinstance(files, list):
        raise ProductDocsError(Diagnostic(diagnostic_code, "Package manifest files must be an array"))
    records: list[dict[str, str]] = []
    for record in files:
        if not isinstance(record, dict) or set(record) != {"path", "sha256"}:
            raise ProductDocsError(Diagnostic(diagnostic_code, "Package manifest file records must contain path and sha256"))
        path = record.get("path")
        digest = record.get("sha256")
        if not isinstance(path, str) or not isinstance(digest, str) or len(digest) != 64 or any(character not in "0123456789abcdef" for character in digest):
            raise ProductDocsError(Diagnostic(diagnostic_code, "Package manifest file records are invalid"))
        path = validate_repository_path(path)
        if path == MANIFEST_NAME or path.startswith("tests/") or not (path == "SKILL.md" or path.split("/", 1)[0] in OPERATIONAL_DIRECTORIES):
            raise ProductDocsError(Diagnostic(diagnostic_code, "Package manifest includes a non-operational path", path=path))
        records.append({"path": path, "sha256": digest})
    paths = [record["path"] for record in records]
    if paths != sorted(paths) or len(paths) != len(set(paths)):
        raise ProductDocsError(Diagnostic(diagnostic_code, "Package manifest paths must be sorted and unique"))
    return tuple(records)


def _supports_contract(manifest: Mapping[str, object], schema_version: int, template_version: str) -> bool:
    contracts = manifest.get("supported_document_contracts")
    if not isinstance(contracts, list):
        return False
    for contract in contracts:
        if not isinstance(contract, dict):
            continue
        if contract.get("schema_version") == schema_version and template_version in contract.get("template_versions", []):
            return True
    return False


def _validate_manifest_shape(manifest: Mapping[str, object], *, diagnostic_code: str) -> tuple[dict[str, str], ...]:
    if manifest.get("manifest_schema") != MANIFEST_SCHEMA or not isinstance(manifest.get("skill_version"), str):
        raise ProductDocsError(Diagnostic(diagnostic_code, "Package manifest has an unsupported schema"))
    return _file_records(manifest, diagnostic_code=diagnostic_code)


def verify_active_package(skill_root: Path | str) -> dict[str, object]:
    """Verify that the stored active manifest exactly represents its package."""
    root = Path(skill_root)
    manifest_path = root / MANIFEST_NAME
    if manifest_path.is_symlink():
        raise ProductDocsError(Diagnostic("unsafe-operational-path", "Active package manifest must not be a symbolic link", path=MANIFEST_NAME))
    if not manifest_path.is_file():
        raise ProductDocsError(Diagnostic("package-manifest-missing", "Active package manifest is missing", path=MANIFEST_NAME))
    stored = _load_manifest_bytes(manifest_path.read_bytes(), path=MANIFEST_NAME, diagnostic_code="package-manifest-invalid")
    _validate_manifest_shape(stored, diagnostic_code="package-manifest-invalid")
    expected = build_manifest(root)
    if stored != expected:
        raise ProductDocsError(Diagnostic("package-manifest-mismatch", "Active package files do not match the stored manifest"))
    return stored


def _template_hash_from_manifest(manifest: Mapping[str, object], template_version: str, *, diagnostic_code: str) -> str:
    template_path = TEMPLATE_PATHS.get(template_version)
    if template_path is None:
        raise ProductDocsError(Diagnostic("unsupported-document-contract", "Template version is not supported", identifier=template_version))
    for record in _file_records(manifest, diagnostic_code=diagnostic_code):
        if record["path"] == template_path:
            return f"sha256:{record['sha256']}"
    raise ProductDocsError(Diagnostic(diagnostic_code, "Package manifest does not list the selected template", path=template_path))


def verify_historical_package(
    repository: GitRepository,
    *,
    baseline_commit: str,
    schema_version: int,
    template_version: str,
    expected_package_hash: str,
    expected_template_hash: str,
    active_skill_root: Path | str,
) -> dict[str, object]:
    """Verify a document's baseline package, then its active contract support."""
    if not repository.is_commit_reachable(baseline_commit):
        raise ProductDocsError(Diagnostic("unreachable-baseline", "Document baseline commit is not reachable", identifier=baseline_commit))
    active_root = Path(active_skill_root).resolve()
    try:
        historical_root = active_root.relative_to(repository.root).as_posix()
    except ValueError as error:
        raise ProductDocsError(Diagnostic("noncanonical-path", "Active skill root must be inside the repository")) from error
    active_manifest = verify_active_package(active_root)
    if not _supports_contract(active_manifest, schema_version, template_version):
        raise ProductDocsError(Diagnostic("unsupported-document-contract", "Active package does not support the document schema and template", identifier=template_version))
    manifest_path = f"{historical_root}/{MANIFEST_NAME}"
    historical_bytes = repository.read_bytes_at(baseline_commit, manifest_path)
    historical_manifest = _load_manifest_bytes(historical_bytes, path=manifest_path, diagnostic_code="historical-manifest-invalid")
    records = _validate_manifest_shape(historical_manifest, diagnostic_code="historical-manifest-invalid")
    for record in records:
        historical_path = f"{historical_root}/{record['path']}"
        if _sha256(repository.read_bytes_at(baseline_commit, historical_path)) != record["sha256"]:
            raise ProductDocsError(Diagnostic("historical-package-mismatch", "Historical operational file hash does not match the manifest", path=historical_path))
    actual_package_hash = package_hash(historical_manifest)
    if actual_package_hash != expected_package_hash:
        raise ProductDocsError(Diagnostic("historical-package-mismatch", "Historical package hash does not match the document", identifier=expected_package_hash))
    actual_template_hash = _template_hash_from_manifest(historical_manifest, template_version, diagnostic_code="historical-manifest-invalid")
    if actual_template_hash != expected_template_hash:
        raise ProductDocsError(Diagnostic("historical-package-mismatch", "Historical template hash does not match the document", identifier=expected_template_hash))
    return {
        "baseline_commit": baseline_commit,
        "package_hash": actual_package_hash,
        "template_hash": actual_template_hash,
    }
