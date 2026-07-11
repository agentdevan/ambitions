"""Command-line entrypoint for the Ambitions canon compiler."""

from __future__ import annotations

import argparse
import sys
from collections.abc import Sequence
from pathlib import Path

from tools.ambitions_canon import __version__
from tools.ambitions_canon.audit import audit_registry
from tools.ambitions_canon.manifest import load_documents, load_manifest
from tools.ambitions_canon.model import CanonError, Finding, GapSeverity
from tools.ambitions_canon.registry import build_registry


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
    arguments = parser.parse_args(argv)

    if arguments.command == "version":
        print(f"ambitions-canon {__version__}")
        return 0

    if arguments.command == "audit":
        return _audit(Path.cwd())

    raise AssertionError(f"unhandled command: {arguments.command}")


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
                finding.path.as_posix()
                if finding.path is not None
                else "<registry>"
            )
            location = f"{location}:{finding.line or 0}"
            print(
                f"{finding.severity.value} {finding.code} "
                f"{location} {finding.message}"
            )
        return 1 if any(
            finding.severity
            in (GapSeverity.P0_BLOCKER, GapSeverity.P1_REQUIRED)
            for finding in findings
        ) else 0

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
