"""Command-line adapter for lightweight product-development documents."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
import re
import subprocess
from typing import Sequence, TextIO

from .constants import DOCUMENTS_ROOT, SKILL_ROOT
from .documents import parse_document, write_document_atomic
from .errors import Diagnostic, ProductDocsError
from .models import DocumentStatus, DocumentType, ProductDocument
from .validation import validate_initiative


EXIT_SUCCESS = 0
EXIT_DOMAIN_FAILURE = 1
EXIT_USAGE = 2
EXIT_REPOSITORY = 3
_PHASES = tuple(document_type.value for document_type in DocumentType)
_INITIATIVE_SLUG = re.compile(r"[a-z0-9]+(?:-[a-z0-9]+)*\Z")


class _ParserExit(Exception):
    def __init__(self, status: int, message: str | None = None) -> None:
        self.status = status
        self.message = message
        super().__init__(message)


class _ArgumentParser(argparse.ArgumentParser):
    def exit(self, status: int = 0, message: str | None = None) -> None:
        raise _ParserExit(status, message)

    def error(self, message: str) -> None:
        raise _ParserExit(EXIT_USAGE, f"{self.format_usage()}{self.prog}: error: {message}\n")


def _add_json_argument(parser: argparse.ArgumentParser) -> None:
    parser.add_argument("--json", action="store_true", dest="json_output")


def build_parser() -> argparse.ArgumentParser:
    """Build the two-command product-document grammar."""
    parser = _ArgumentParser(prog="ambitions_product_docs.py")
    commands = parser.add_subparsers(dest="command", required=True)

    new = commands.add_parser("new")
    new.add_argument("phase", choices=_PHASES)
    new.add_argument("--initiative", required=True)
    _add_json_argument(new)

    check = commands.add_parser("check")
    check.add_argument("path")
    _add_json_argument(check)
    return parser


def _payload(
    command: str,
    *,
    status: str,
    documents: Sequence[dict[str, str]] = (),
    diagnostics: Sequence[Diagnostic] = (),
    next_action: str,
) -> dict[str, object]:
    return {
        "command": command,
        "status": status,
        "documents": list(documents),
        "diagnostics": [diagnostic.as_dict() for diagnostic in diagnostics],
        "next_action": next_action,
    }


def _emit(payload: dict[str, object], *, as_json: bool, stdout: TextIO, stderr: TextIO) -> None:
    if as_json:
        stdout.write(json.dumps(payload, separators=(",", ":"), ensure_ascii=False) + "\n")
        return
    stream = stdout if payload["status"] == "success" else stderr
    stream.write(f"{payload['command']}: {payload['status']}\n")
    for diagnostic in payload["diagnostics"]:
        assert isinstance(diagnostic, dict)
        location = f" [{diagnostic['path']}]" if diagnostic.get("path") else ""
        stream.write(f"{diagnostic['code']}{location}: {diagnostic['message']}\n")
    stream.write(f"next: {payload['next_action']}\n")


def _repository_root(candidate: Path | str | None) -> Path:
    try:
        start = Path.cwd() if candidate is None else Path(candidate)
        result = subprocess.run(
            ["git", "-C", str(start.resolve()), "rev-parse", "--show-toplevel"],
            check=False,
            capture_output=True,
            text=True,
        )
    except OSError as error:
        raise ProductDocsError(Diagnostic("repository-unavailable", "Git is unavailable while locating the repository")) from error
    if result.returncode != 0 or not result.stdout.strip():
        raise ProductDocsError(Diagnostic("repository-unavailable", "Could not access a Git repository", path=str(start)))
    try:
        root = Path(result.stdout.strip()).resolve()
    except OSError as error:
        raise ProductDocsError(Diagnostic("repository-unavailable", "Git repository root could not be resolved")) from error
    if not root.is_dir():
        raise ProductDocsError(Diagnostic("repository-unavailable", "Git reported an inaccessible repository root", path=str(root)))
    return root


def _relative_path(path: Path | str, root: Path) -> tuple[Path, str]:
    candidate = Path(path)
    target = candidate.resolve() if candidate.is_absolute() else (root / candidate).resolve()
    try:
        return target, target.relative_to(root).as_posix()
    except ValueError as error:
        raise ProductDocsError(Diagnostic("path-outside-repository", "Path must remain inside the repository", path=str(path))) from error


def _initiative_directory(path: Path, relative: str) -> Path:
    relative_path = Path(relative)
    root = Path(DOCUMENTS_ROOT)
    if relative_path.parent != root or not _INITIATIVE_SLUG.fullmatch(relative_path.name):
        raise ProductDocsError(Diagnostic("canonical-path", "Initiative directories must be docs/product-development/<initiative>", path=relative))
    if not path.is_dir():
        raise ProductDocsError(Diagnostic("document-unavailable", "Initiative directory does not exist", path=relative))
    return path


def _document_path(path: Path, relative: str) -> Path:
    relative_path = Path(relative)
    root = Path(DOCUMENTS_ROOT)
    if (
        relative_path.parent.parent != root
        or not _INITIATIVE_SLUG.fullmatch(relative_path.parent.name)
        or relative_path.name not in {f"{phase}.md" for phase in _PHASES}
    ):
        raise ProductDocsError(Diagnostic("canonical-path", "Documents must be docs/product-development/<initiative>/<phase>.md", path=relative))
    if not path.is_file():
        raise ProductDocsError(Diagnostic("document-unavailable", "Document does not exist", path=relative))
    return path


def _document_record(document: ProductDocument, relative: str) -> dict[str, str]:
    return {
        "path": relative,
        "type": document.document_type.value,
        "status": document.status.value,
    }


def _template_path(root: Path, phase: str) -> Path:
    template = root / SKILL_ROOT / "assets" / "templates" / "v1" / f"{phase}.md"
    if not template.is_file():
        raise ProductDocsError(Diagnostic("template-unavailable", "Product document template is unavailable", path=template.relative_to(root).as_posix()))
    return template


def _run_new(arguments: argparse.Namespace, root: Path) -> tuple[int, dict[str, object]]:
    initiative = arguments.initiative
    if not _INITIATIVE_SLUG.fullmatch(initiative):
        raise ProductDocsError(Diagnostic("invalid-initiative", "initiative must be a lowercase hyphenated slug"))

    phase = arguments.phase
    directory = root / DOCUMENTS_ROOT / initiative
    target = directory / f"{phase}.md"
    relative = target.relative_to(root).as_posix()
    if target.exists():
        raise ProductDocsError(Diagnostic("document-exists", "Document already exists", path=relative))
    if phase != DocumentType.RESEARCH.value:
        upstream = directory / f"{DocumentType.RESEARCH.value if phase == DocumentType.SCOPE.value else DocumentType.SCOPE.value}.md"
        if not upstream.is_file():
            raise ProductDocsError(Diagnostic("upstream-unavailable", "Create the upstream document before this phase", path=upstream.relative_to(root).as_posix()))
        upstream_document = parse_document(upstream, repository_root=root)
        if upstream_document.status is not DocumentStatus.APPROVED:
            raise ProductDocsError(
                Diagnostic(
                    "upstream-not-approved",
                    "Approve the upstream document before creating this phase",
                    path=upstream.relative_to(root).as_posix(),
                )
            )

    contents = _template_path(root, phase).read_text(encoding="utf-8").replace('initiative = ""', f'initiative = "{initiative}"', 1)
    write_document_atomic(target, contents, repository_root=root)
    document = parse_document(target, repository_root=root)
    return EXIT_SUCCESS, _payload(
        "new",
        status="success",
        documents=(_document_record(document, relative),),
        next_action=f"complete {phase}",
    )


def _next_action(documents: Sequence[ProductDocument]) -> str:
    by_type = {document.document_type: document for document in documents}
    research = by_type.get(DocumentType.RESEARCH)
    scope = by_type.get(DocumentType.SCOPE)
    design = by_type.get(DocumentType.DESIGN)
    if research is None or research.status is not DocumentStatus.APPROVED:
        return "complete research"
    if scope is None:
        return "create scope"
    if scope.status is not DocumentStatus.APPROVED:
        return "complete scope"
    if design is None:
        return "create design"
    if design.status is not DocumentStatus.APPROVED:
        return "complete design"
    return "groom implementation"


def _run_check(arguments: argparse.Namespace, root: Path) -> tuple[int, dict[str, object]]:
    target, relative = _relative_path(arguments.path, root)
    diagnostics: list[Diagnostic] = []
    documents: list[ProductDocument] = []
    records: list[dict[str, str]] = []
    if target.is_dir():
        directory = _initiative_directory(target, relative)
        report = validate_initiative(directory)
        diagnostics.extend(report.diagnostics)
        paths = [directory / f"{phase}.md" for phase in _PHASES]
        if not any(path.is_file() for path in paths):
            diagnostics.append(
                Diagnostic("no-documents", "No product documents found", path=relative)
            )
    else:
        document_path = _document_path(target, relative)
        report = validate_initiative(document_path.parent)
        diagnostics.extend(report.diagnostics)
        paths = [document_path]

    for path in paths:
        if not path.is_file():
            continue
        path_relative = path.relative_to(root).as_posix()
        try:
            document = parse_document(path, repository_root=root)
        except ProductDocsError as error:
            diagnostics.extend(
                diagnostic
                for diagnostic in error.diagnostics
                if diagnostic not in diagnostics
            )
            continue
        documents.append(document)
        records.append(_document_record(document, path_relative))

    status = "success" if not diagnostics else "failure"
    return (
        EXIT_SUCCESS if not diagnostics else EXIT_DOMAIN_FAILURE,
        _payload(
            "check",
            status=status,
            documents=records,
            diagnostics=diagnostics,
            next_action=_next_action(documents) if not diagnostics else "correct the reported diagnostics",
        ),
    )


def _error_exit(error: ProductDocsError) -> int:
    return EXIT_REPOSITORY if any(item.code == "repository-unavailable" for item in error.diagnostics) else EXIT_DOMAIN_FAILURE


def main(
    argv: Sequence[str] | None = None,
    *,
    repository_root: Path | str | None = None,
    stdout: TextIO | None = None,
    stderr: TextIO | None = None,
) -> int:
    """Parse, dispatch, emit one result, and return the CLI exit code."""
    import sys

    arguments_list = list(sys.argv[1:] if argv is None else argv)
    stdout = sys.stdout if stdout is None else stdout
    stderr = sys.stderr if stderr is None else stderr
    as_json = "--json" in arguments_list
    command = arguments_list[0] if arguments_list and not arguments_list[0].startswith("-") else ""
    try:
        arguments = build_parser().parse_args(arguments_list)
    except _ParserExit as error:
        diagnostic = Diagnostic("usage-error", (error.message or "Invalid command usage").strip())
        _emit(_payload(command, status="failure", diagnostics=(diagnostic,), next_action="correct the command syntax"), as_json=as_json, stdout=stdout, stderr=stderr)
        return EXIT_USAGE

    try:
        root = _repository_root(repository_root)
        exit_code, payload = _run_new(arguments, root) if arguments.command == "new" else _run_check(arguments, root)
    except ProductDocsError as error:
        exit_code = _error_exit(error)
        payload = _payload(
            arguments.command,
            status="failure",
            diagnostics=error.diagnostics,
            next_action="restore access to the repository and retry" if exit_code == EXIT_REPOSITORY else "correct the reported diagnostics",
        )
    _emit(payload, as_json=arguments.json_output, stdout=stdout, stderr=stderr)
    return exit_code
