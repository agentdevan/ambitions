"""Command-line interface for the governance-free product-canon compiler."""

from __future__ import annotations

import argparse
import json
import sys
import time
from pathlib import Path
from typing import Sequence

from tools.ambitions_canon import __version__
from tools.ambitions_canon.compiler import (
    CanonError,
    Document,
    Requirement,
    compile_repository,
    output_drift,
    query,
    query_record,
    render_outputs,
    write_outputs,
)


SUPPORTED_COMMANDS = frozenset({"version", "build", "check", "query"})


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="ambitions-canon",
        description="Compile and query Ambitions product canon.",
    )
    subparsers = parser.add_subparsers(dest="command", required=True)
    subparsers.add_parser("version", help="print compiler version")

    build = subparsers.add_parser(
        "build", help="validate sources and regenerate deterministic indexes"
    )
    build.add_argument(
        "--check",
        action="store_true",
        help="report generated drift without writing",
    )
    subparsers.add_parser(
        "check", help="validate sources and reject generated-output drift"
    )

    query_parser = subparsers.add_parser(
        "query", help="query a specification, requirement, concept, or text"
    )
    selector = query_parser.add_mutually_exclusive_group()
    selector.add_argument("--id", dest="requirement_id")
    selector.add_argument("--concept")
    selector.add_argument("--spec", dest="spec_id")
    query_parser.add_argument("term", nargs="?")
    query_parser.add_argument("--json", action="store_true", dest="as_json")
    query_parser.add_argument(
        "--limit", type=int, default=20, help="maximum text-search results"
    )
    return parser


def _summary(compilation: object, elapsed_ms: int) -> str:
    documents = getattr(compilation, "documents")
    requirements = getattr(compilation, "requirements")
    screens = getattr(compilation, "ux_screen_count")
    contracts = getattr(compilation, "visual_contract_count")
    links = getattr(compilation, "local_link_count")
    json_count = getattr(compilation, "json_count")
    return (
        f"{len(documents)} documents, {len(requirements)} requirements, "
        f"{screens} UX screens, {contracts} visual contracts, "
        f"{links} local links, {json_count} JSON files ({elapsed_ms} ms)"
    )


def _render_query_text(item: Document | Requirement) -> str:
    if isinstance(item, Document):
        return "\n".join(
            (
                f"{item.spec_id} — {item.title}",
                f"Kind: {item.kind}",
                f"Source: docs/canon/{item.source_path}",
                f"Depends on: {', '.join(item.depends_on) or 'none'}",
                f"Inherits: {', '.join(item.inherits) or 'none'}",
                f"Source owners: {', '.join(item.source_owners) or 'none'}",
                f"Requirements: {', '.join(req.requirement_id for req in item.requirements)}",
            )
        )
    return "\n".join(
        (
            f"{item.requirement_id} — {item.title}",
            f"Spec: {item.owner_spec_id}",
            f"Concept: {item.concept}",
            f"Modality: {item.modality}",
            f"Scope: {item.scope}",
            f"Source owners: {', '.join(item.source_owners) or 'none'}",
            f"Verification: {', '.join(item.verification) or 'none'}",
            f"Source: docs/canon/{item.source_path}:{item.line}",
            "",
            item.body,
        )
    )


def main(argv: Sequence[str] | None = None, *, root: Path | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)
    repository_root = (root or Path(__file__).resolve().parents[2]).resolve()
    if args.command == "version":
        print(__version__)
        return 0

    started = time.monotonic()
    try:
        compilation = compile_repository(repository_root)
        if args.command in {"build", "check"}:
            outputs = render_outputs(compilation)
            check_only = args.command == "check" or args.check
            if check_only:
                drift = output_drift(compilation, outputs)
                if drift:
                    for path in drift:
                        print(f"GENERATED_DRIFT docs/canon/{path}", file=sys.stderr)
                    print(
                        "Run: python3 scripts/ambitions-canon.py build",
                        file=sys.stderr,
                    )
                    return 1
            else:
                write_outputs(compilation, outputs)
            elapsed_ms = round((time.monotonic() - started) * 1000)
            verb = "checked" if check_only else "built"
            print(f"Canon {verb}: {_summary(compilation, elapsed_ms)}.")
            return 0

        term: str | None = args.term
        mode = "any"
        if args.requirement_id:
            term, mode = args.requirement_id, "id"
        elif args.concept:
            term, mode = args.concept, "concept"
        elif args.spec_id:
            term, mode = args.spec_id, "spec"
        if not term:
            parser.error("query requires TERM, --id, --concept, or --spec")
        if args.limit < 1:
            parser.error("--limit must be positive")
        matches = query(compilation, term, mode=mode)
        if not matches:
            print(f"No canon match: {term}", file=sys.stderr)
            return 1
        limited = matches[: args.limit]
        if args.as_json:
            print(
                json.dumps(
                    [query_record(item) for item in limited],
                    indent=2,
                    sort_keys=True,
                    ensure_ascii=False,
                )
            )
        else:
            print("\n\n".join(_render_query_text(item) for item in limited))
            if len(matches) > len(limited):
                print(f"\n\n{len(matches) - len(limited)} more matches; raise --limit.")
        return 0
    except CanonError as exc:
        print(f"CANON_ERROR {exc}", file=sys.stderr)
        return 1
