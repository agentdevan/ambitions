"""Command-line adapter for the Ambitions product-document lifecycle."""

from __future__ import annotations

import argparse
from dataclasses import fields
from enum import Enum
import json
import os
from pathlib import Path
import subprocess
import tempfile
from typing import Any, Sequence, TextIO

from .constants import DOCUMENTS_ROOT, SKILL_ROOT
from .documents import parse_document
from .errors import Diagnostic, ProductDocsError
from .hashing import compute_contract_hash
from .models import LifecycleDocument, ReviewVerdict
from .package_identity import (
    MANIFEST_NAME,
    build_manifest,
    canonical_manifest_bytes,
    package_hash,
    verify_active_package,
)
from .repository import validate_repository_path
from .transitions import (
    create_document,
    mark_stale,
    record_review,
    reopen_document,
    seal_document,
    supersede_document,
)
from .validation import consume_document, validate_document


EXIT_SUCCESS = 0
EXIT_DOMAIN_FAILURE = 1
EXIT_USAGE = 2
EXIT_REPOSITORY = 3
_TOP_LEVEL_KEYS = (
    "command",
    "status",
    "document",
    "changes",
    "diagnostics",
    "next_action",
)
_DOCUMENT_FILENAMES = ("research.md", "scope.md", "design.md")
_REPOSITORY_DIAGNOSTICS = frozenset({"repository-unavailable", "git-read-failed"})


class _ParserExit(Exception):
    def __init__(self, status: int, message: str | None = None) -> None:
        self.status = status
        self.message = message
        super().__init__(message)


class _ArgumentParser(argparse.ArgumentParser):
    def exit(self, status: int = 0, message: str | None = None) -> None:
        raise _ParserExit(status, message)

    def error(self, message: str) -> None:
        raise _ParserExit(
            EXIT_USAGE, f"{self.format_usage()}{self.prog}: error: {message}\n"
        )


def _add_json_argument(parser: argparse.ArgumentParser) -> None:
    parser.add_argument("--json", action="store_true", dest="json_output")


def build_parser() -> argparse.ArgumentParser:
    """Build the exact version-one command grammar."""
    parser = _ArgumentParser(prog="ambitions_product_docs.py")
    commands = parser.add_subparsers(dest="command", required=True)

    package = commands.add_parser("package")
    package_mode = package.add_mutually_exclusive_group(required=True)
    package_mode.add_argument("--check", action="store_true")
    package_mode.add_argument("--write", action="store_true")
    _add_json_argument(package)

    new = commands.add_parser("new")
    new.add_argument("--initiative", required=True)
    new.add_argument("--phase", choices=("research", "scope", "design"), required=True)
    new.add_argument("--initiative-id")
    new.add_argument("--input")
    new.add_argument("--authority-file")
    _add_json_argument(new)

    check = commands.add_parser("check")
    check_target = check.add_mutually_exclusive_group(required=True)
    check_target.add_argument("path", nargs="?")
    check_target.add_argument("--initiative")
    check_target.add_argument("--all", action="store_true", dest="check_all")
    _add_json_argument(check)

    hash_command = commands.add_parser("hash")
    hash_command.add_argument("path")
    _add_json_argument(hash_command)

    seal = commands.add_parser("seal")
    seal.add_argument("path")
    _add_json_argument(seal)

    review = commands.add_parser("review")
    review.add_argument("path")
    review.add_argument("--review-file", required=True)
    _add_json_argument(review)

    reconcile = commands.add_parser("reconcile")
    reconcile.add_argument("path")
    reconcile_mode = reconcile.add_mutually_exclusive_group(required=True)
    reconcile_mode.add_argument("--mark-stale", action="store_true")
    reconcile_mode.add_argument("--reopen", action="store_true")
    reconcile.add_argument("--reason-file")
    reconcile.add_argument("--baseline")
    reconcile.add_argument("--input")
    reconcile.add_argument("--authority-file")
    _add_json_argument(reconcile)

    consume = commands.add_parser("consume")
    consume.add_argument("path")
    consume.add_argument("--as-of")
    _add_json_argument(consume)

    supersede = commands.add_parser("supersede")
    supersede.add_argument("path")
    supersede.add_argument("--replacement", required=True)
    supersede.add_argument("--reason-file", required=True)
    _add_json_argument(supersede)

    return parser


def _usage_error(arguments: argparse.Namespace) -> str | None:
    if arguments.command != "reconcile":
        return None
    if arguments.mark_stale:
        if arguments.reason_file is None:
            return "reconcile --mark-stale requires --reason-file"
        if (
            arguments.baseline is not None
            or arguments.input is not None
            or arguments.authority_file is not None
        ):
            return "reconcile --mark-stale does not accept reopen inputs"
    elif arguments.reason_file is not None:
        return "reconcile --reopen does not accept --reason-file"
    return None


def _payload(
    command: str,
    *,
    status: str,
    document: object = None,
    changes: Sequence[object] = (),
    diagnostics: Sequence[Diagnostic | dict[str, object]] = (),
    next_action: str | None = None,
) -> dict[str, object]:
    diagnostic_values = [
        item.as_dict() if isinstance(item, Diagnostic) else dict(item)
        for item in diagnostics
    ]
    values: dict[str, object] = {
        "command": command,
        "status": status,
        "document": document,
        "changes": list(changes),
        "diagnostics": diagnostic_values,
        "next_action": next_action,
    }
    return {key: values[key] for key in _TOP_LEVEL_KEYS}


def _emit(
    payload: dict[str, object], *, as_json: bool, stdout: TextIO, stderr: TextIO
) -> None:
    if as_json:
        stdout.write(
            json.dumps(
                payload, sort_keys=False, separators=(",", ":"), ensure_ascii=False
            )
            + "\n"
        )
        return
    command = str(payload["command"] or "command")
    status = str(payload["status"])
    stream = stdout if status == "success" else stderr
    stream.write(f"{command}: {status}\n")
    document = payload["document"]
    if isinstance(document, dict) and document.get("path"):
        stream.write(f"document: {document['path']}\n")
    for diagnostic in payload["diagnostics"]:  # type: ignore[union-attr]
        if isinstance(diagnostic, dict):
            location = f" [{diagnostic['path']}]" if diagnostic.get("path") else ""
            stream.write(
                f"{diagnostic.get('code', 'error')}{location}: {diagnostic.get('message', '')}\n"
            )
    if payload["next_action"]:
        stream.write(f"next: {payload['next_action']}\n")


def _repository_root(candidate: Path | str | None) -> Path:
    start = Path.cwd() if candidate is None else Path(candidate)
    try:
        accessible = start.is_dir()
    except OSError as error:
        raise ProductDocsError(
            Diagnostic(
                "repository-unavailable",
                "Repository root could not be accessed",
                path=str(start),
            )
        ) from error
    if not accessible:
        raise ProductDocsError(
            Diagnostic(
                "repository-unavailable",
                "Repository root is not an accessible directory",
                path=str(start),
            )
        )
    try:
        result = subprocess.run(
            ["git", "-C", str(start.resolve()), "rev-parse", "--show-toplevel"],
            check=False,
            capture_output=True,
            shell=False,
            text=True,
        )
    except OSError as error:
        raise ProductDocsError(
            Diagnostic(
                "repository-unavailable",
                "Git is unavailable while locating the repository",
                path=str(start),
            )
        ) from error
    if result.returncode != 0:
        raise ProductDocsError(
            Diagnostic(
                "repository-unavailable",
                "Could not access a Git repository",
                path=str(start),
            )
        )
    root = Path(result.stdout.strip()).resolve()
    if not root.is_dir():
        raise ProductDocsError(
            Diagnostic(
                "repository-unavailable",
                "Git reported an inaccessible repository root",
                path=str(root),
            )
        )
    return root


def _path_in_repository(path: Path | str, root: Path) -> tuple[Path, str]:
    candidate = Path(path)
    target = (
        candidate.resolve() if candidate.is_absolute() else (root / candidate).resolve()
    )
    try:
        relative = target.relative_to(root).as_posix()
    except ValueError as error:
        raise ProductDocsError(
            Diagnostic(
                "path-outside-repository",
                "Path must remain inside the repository",
                path=str(path),
            )
        ) from error
    return target, validate_repository_path(relative)


def _document_summary(document: LifecycleDocument, path: str) -> dict[str, object]:
    metadata = document.metadata
    return {
        "path": path,
        "document_id": metadata.document_id,
        "document_type": metadata.document_type.value,
        "status": metadata.status.value,
        "revision": metadata.revision,
        "contract_hash": metadata.contract_hash,
    }


def _normal(value: Any) -> Any:
    if isinstance(value, Enum):
        return value.value
    if isinstance(value, tuple):
        return [_normal(item) for item in value]
    if hasattr(value, "__dataclass_fields__"):
        return {
            field.name: _normal(getattr(value, field.name)) for field in fields(value)
        }
    return value


def _document_changes(
    path: str,
    previous: LifecycleDocument | None,
    current: LifecycleDocument,
) -> list[dict[str, object]]:
    changes: list[dict[str, object]] = []
    if previous is None:
        changes.append(
            {
                "path": path,
                "field": "document",
                "previous": None,
                "new": current.metadata.status.value,
            }
        )
        return changes
    for field in fields(current.metadata):
        before = getattr(previous.metadata, field.name)
        after = getattr(current.metadata, field.name)
        if before != after:
            changes.append(
                {
                    "path": path,
                    "field": field.name,
                    "previous": _normal(before),
                    "new": _normal(after),
                }
            )
    if previous.sections != current.sections:
        changes.append(
            {
                "path": path,
                "field": "review_history",
                "previous": "unchanged",
                "new": "appended",
            }
        )
    return changes


def _read_text_file(path: Path | str, *, kind: str) -> str:
    try:
        value = Path(path).read_text(encoding="utf-8").strip()
    except (OSError, UnicodeDecodeError) as error:
        raise ProductDocsError(
            Diagnostic(
                f"invalid-{kind}-file",
                f"{kind.replace('-', ' ').title()} file must be readable UTF-8",
                path=str(path),
            )
        ) from error
    if not value:
        raise ProductDocsError(
            Diagnostic(
                f"invalid-{kind}-file",
                f"{kind.replace('-', ' ').title()} file must not be empty",
                path=str(path),
            )
        )
    return value


def _write_atomic(path: Path, contents: bytes) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    descriptor, temporary_name = tempfile.mkstemp(
        prefix=f".{path.name}.", dir=path.parent
    )
    temporary = Path(temporary_name)
    try:
        with os.fdopen(descriptor, "wb") as handle:
            handle.write(contents)
            handle.flush()
            os.fsync(handle.fileno())
        temporary.replace(path)
    except BaseException:
        temporary.unlink(missing_ok=True)
        raise


def _check_paths(
    arguments: argparse.Namespace, root: Path
) -> tuple[tuple[Path, str], ...]:
    if arguments.path:
        return (_path_in_repository(arguments.path, root),)
    if arguments.initiative:
        directory, _ = _path_in_repository(arguments.initiative, root)
        if not directory.is_dir():
            raise ProductDocsError(
                Diagnostic(
                    "initiative-unavailable",
                    "Initiative directory does not exist",
                    path=str(arguments.initiative),
                )
            )
        candidates = tuple(
            directory / name
            for name in _DOCUMENT_FILENAMES
            if (directory / name).is_file()
        )
    else:
        documents_root = root / DOCUMENTS_ROOT
        candidates = (
            tuple(
                sorted(
                    (
                        path
                        for path in documents_root.rglob("*.md")
                        if path.name in _DOCUMENT_FILENAMES and path.is_file()
                    ),
                    key=lambda path: path.relative_to(root).as_posix(),
                )
            )
            if documents_root.is_dir()
            else ()
        )
    if not candidates:
        raise ProductDocsError(
            Diagnostic("no-documents", "No lifecycle documents matched the selection")
        )
    return tuple(_path_in_repository(path, root) for path in candidates)


def _run_package(
    arguments: argparse.Namespace, root: Path
) -> tuple[int, dict[str, object]]:
    skill_root = root / SKILL_ROOT
    manifest_path = skill_root / MANIFEST_NAME
    relative_manifest = f"{SKILL_ROOT}/{MANIFEST_NAME}"
    if arguments.check:
        manifest = verify_active_package(skill_root)
        return EXIT_SUCCESS, _payload(
            "package",
            status="success",
            document={
                "path": relative_manifest,
                "package_hash": package_hash(manifest),
                "file_count": len(manifest["files"]),  # type: ignore[arg-type]
            },
            next_action="package is ready",
        )
    previous: object = None
    if manifest_path.is_file() and not manifest_path.is_symlink():
        try:
            previous = json.loads(manifest_path.read_text(encoding="utf-8"))
        except (OSError, UnicodeDecodeError, json.JSONDecodeError):
            previous = "invalid manifest"
    manifest = build_manifest(skill_root)
    _write_atomic(manifest_path, canonical_manifest_bytes(manifest))
    verify_active_package(skill_root)
    return EXIT_SUCCESS, _payload(
        "package",
        status="success",
        document={
            "path": relative_manifest,
            "package_hash": package_hash(manifest),
            "file_count": len(manifest["files"]),  # type: ignore[arg-type]
        },
        changes=(
            {
                "path": relative_manifest,
                "field": MANIFEST_NAME,
                "previous": previous,
                "new": manifest,
            },
        ),
        next_action="commit the regenerated package manifest",
    )


def _run_new(
    arguments: argparse.Namespace, root: Path
) -> tuple[int, dict[str, object]]:
    path = create_document(
        root,
        initiative=arguments.initiative,
        phase=arguments.phase,
        initiative_id=arguments.initiative_id,
        input_path=arguments.input,
        authority_file=arguments.authority_file,
    )
    document = parse_document(path, repository_root=root)
    relative = path.relative_to(root).as_posix()
    return EXIT_SUCCESS, _payload(
        "new",
        status="success",
        document=_document_summary(document, relative),
        changes=_document_changes(relative, None, document),
        next_action="complete every required section, then commit and seal the draft",
    )


def _run_check(
    arguments: argparse.Namespace, root: Path
) -> tuple[int, dict[str, object]]:
    records = []
    diagnostics: list[Diagnostic] = []
    for target, relative in _check_paths(arguments, root):
        try:
            document = parse_document(target, repository_root=root)
            report = validate_document(document, repository_root=root)
            records.append(
                {
                    **_document_summary(document, relative),
                    "valid": report.valid,
                }
            )
            diagnostics.extend(
                Diagnostic(
                    item.code,
                    item.message,
                    path=item.path or relative,
                    section=item.section,
                    identifier=item.identifier,
                    remediation=item.remediation,
                )
                for item in report.diagnostics
            )
        except ProductDocsError as error:
            diagnostics.extend(error.diagnostics)
        except (OSError, UnicodeDecodeError) as error:
            diagnostics.append(
                Diagnostic("document-unavailable", str(error), path=relative)
            )
    status = "success" if not diagnostics else "failure"
    return (EXIT_SUCCESS if not diagnostics else EXIT_DOMAIN_FAILURE), _payload(
        "check",
        status=status,
        document={"count": len(records), "documents": records},
        diagnostics=diagnostics,
        next_action="documents are valid"
        if not diagnostics
        else "correct the reported document diagnostics",
    )


def _run_hash(
    arguments: argparse.Namespace, root: Path
) -> tuple[int, dict[str, object]]:
    target, relative = _path_in_repository(arguments.path, root)
    document = parse_document(target, repository_root=root)
    summary = _document_summary(document, relative)
    summary["contract_hash"] = compute_contract_hash(document)
    return EXIT_SUCCESS, _payload(
        "hash",
        status="success",
        document=summary,
        next_action="use this hash only for the current authority bytes",
    )


def _run_document_transition(
    command: str,
    path: Path | str,
    root: Path,
    operation: Any,
    *,
    next_action: str,
) -> tuple[int, dict[str, object]]:
    target, relative = _path_in_repository(path, root)
    previous = parse_document(target, repository_root=root)
    current = operation(target)
    return EXIT_SUCCESS, _payload(
        command,
        status="success",
        document=_document_summary(current, relative),
        changes=_document_changes(relative, previous, current),
        next_action=next_action,
    )


def _run_command(
    arguments: argparse.Namespace, root: Path
) -> tuple[int, dict[str, object]]:
    command = arguments.command
    if command == "package":
        return _run_package(arguments, root)
    if command == "new":
        return _run_new(arguments, root)
    if command == "check":
        return _run_check(arguments, root)
    if command == "hash":
        return _run_hash(arguments, root)
    if command == "seal":
        return _run_document_transition(
            command,
            arguments.path,
            root,
            lambda path: seal_document(path, repository_root=root),
            next_action="commit the sealed revision, then run content review",
        )
    if command == "review":
        return _run_document_transition(
            command,
            arguments.path,
            root,
            lambda path: record_review(
                path, arguments.review_file, repository_root=root
            ),
            next_action="commit the review result before the next lifecycle phase",
        )
    if command == "reconcile" and arguments.mark_stale:
        reason = _read_text_file(arguments.reason_file, kind="reason")
        return _run_document_transition(
            command,
            arguments.path,
            root,
            lambda path: mark_stale(path, reason=reason, repository_root=root),
            next_action="reopen the stale document before editing authority content",
        )
    if command == "reconcile":
        return _run_document_transition(
            command,
            arguments.path,
            root,
            lambda path: reopen_document(
                path,
                repository_root=root,
                baseline_commit=arguments.baseline,
                input_path=arguments.input,
                authority_file=arguments.authority_file,
            ),
            next_action="perform the required corrections, then commit and seal the new revision",
        )
    if command == "consume":
        target, relative = _path_in_repository(arguments.path, root)
        report = consume_document(target, repository_root=root, as_of=arguments.as_of)
        document = {
            "path": relative,
            "document_id": report.document_id,
            "revision": report.revision,
            "contract_hash": report.contract_hash,
            "verdict": report.verdict.value,
            "relevant_paths": list(report.relevant_paths),
            "unrelated_paths": list(report.unrelated_paths),
        }
        success = report.verdict is ReviewVerdict.PASS
        return (EXIT_SUCCESS if success else EXIT_DOMAIN_FAILURE), _payload(
            command,
            status="success" if success else "failure",
            document=document,
            diagnostics=report.diagnostics,
            next_action=report.next_permitted_lifecycle_phase,
        )
    if command == "supersede":
        reason = _read_text_file(arguments.reason_file, kind="reason")
        return _run_document_transition(
            command,
            arguments.path,
            root,
            lambda path: supersede_document(
                path,
                replacement=arguments.replacement,
                reason=reason,
                repository_root=root,
            ),
            next_action="use the replacement document for all future lifecycle work",
        )
    raise ProductDocsError(
        Diagnostic("unsupported-command", "Command is not supported")
    )


def _error_exit(error: ProductDocsError) -> int:
    return (
        EXIT_REPOSITORY
        if any(item.code in _REPOSITORY_DIAGNOSTICS for item in error.diagnostics)
        else EXIT_DOMAIN_FAILURE
    )


def main(
    argv: Sequence[str] | None = None,
    *,
    repository_root: Path | str | None = None,
    stdout: TextIO | None = None,
    stderr: TextIO | None = None,
) -> int:
    """Parse, dispatch, emit one result, and return the stable CLI exit code."""
    import sys

    arguments_list = list(sys.argv[1:] if argv is None else argv)
    stdout = sys.stdout if stdout is None else stdout
    stderr = sys.stderr if stderr is None else stderr
    as_json = "--json" in arguments_list
    command = (
        arguments_list[0]
        if arguments_list and not arguments_list[0].startswith("-")
        else ""
    )
    parser = build_parser()
    try:
        arguments = parser.parse_args(arguments_list)
        usage_error = _usage_error(arguments)
        if usage_error is not None:
            raise _ParserExit(EXIT_USAGE, f"{parser.prog}: error: {usage_error}\n")
    except _ParserExit as error:
        if error.status == EXIT_SUCCESS:
            (
                stdout if not error.message or "usage:" in error.message else stderr
            ).write(error.message or "")
            return EXIT_SUCCESS
        diagnostic = Diagnostic(
            "usage-error", (error.message or "Invalid command usage").strip()
        )
        payload = _payload(
            command,
            status="failure",
            diagnostics=(diagnostic,),
            next_action="correct the command syntax",
        )
        _emit(payload, as_json=as_json, stdout=stdout, stderr=stderr)
        return EXIT_USAGE

    try:
        root = _repository_root(repository_root)
        exit_code, payload = _run_command(arguments, root)
    except ProductDocsError as error:
        exit_code = _error_exit(error)
        payload = _payload(
            arguments.command,
            status="failure",
            diagnostics=error.diagnostics,
            next_action=(
                "restore access to the repository and retry"
                if exit_code == EXIT_REPOSITORY
                else "correct the reported diagnostics and retry"
            ),
        )
    except OSError as error:
        git_unavailable = Path(str(error.filename)).name == "git"
        exit_code = EXIT_REPOSITORY if git_unavailable else EXIT_DOMAIN_FAILURE
        payload = _payload(
            arguments.command,
            status="failure",
            diagnostics=(
                Diagnostic(
                    "repository-unavailable" if git_unavailable else "file-unavailable",
                    str(error),
                    path=str(error.filename) if error.filename else None,
                ),
            ),
            next_action=(
                "restore access to Git and the repository, then retry"
                if git_unavailable
                else "restore or correct the requested file and retry"
            ),
        )
    except (UnicodeDecodeError, json.JSONDecodeError) as error:
        exit_code = EXIT_DOMAIN_FAILURE
        payload = _payload(
            arguments.command,
            status="failure",
            diagnostics=(Diagnostic("file-unavailable", str(error)),),
            next_action="restore or correct the requested file and retry",
        )
    _emit(payload, as_json=arguments.json_output, stdout=stdout, stderr=stderr)
    return exit_code


__all__ = ["build_parser", "main"]
