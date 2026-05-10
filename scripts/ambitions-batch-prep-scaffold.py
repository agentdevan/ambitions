#!/usr/bin/env python3
"""Generate deterministic, read-only batch prep note scaffolds."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import Dict, Iterable

TEMPLATE = """# Prep Note: {batch_id}

- **Batch ID:** {batch_id}
- **Title:** {title}
- **Queue classification:** {queue_classification}
- **Current dependency status:** {dependency_status}
- **Active truth files:**
  - docs/truth/README.md
  - docs/truth/IMPLEMENTATION_TRUTH.md
  - docs/truth/CODEX_PROCESS_TRUTH.md
  - docs/truth/PRODUCT_DESIGN_TRUTH.md
- **Prompt file:** {prompt_file}
- **Prompt availability:** {prompt_status}
- **Likely owner files:** {likely_owner_files}
- **Likely forbidden files:**
  - Native/Ambitions/** production Swift outside pre-approved owner seam
  - Package.swift
  - project.yml
  - .github/workflows/**
  - signing/entitlements
- **Likely tests:** {likely_tests}
- **Validation commands:**
  - make batch-self-check
  - make prompt-audit
  - bash scripts/ambitions-throughput-plan.sh --status
- **EFC applicability:** {efc_applicability}
- **Known yellow caveats:** {yellow_caveats}
- **Senior-only risks:** {senior_risks}
- **Spark-safe work:**
  - prep, scope mapping, command routing, and non-mutating scan output
- **Hard Red triggers:**
  - stale prompt status or missing required boundary files
  - request to run forbidden production behavior edits
- **Rollback notes:** {rollback}
- **Non-claims:**
  - no global completion claim
  - no app-release/readiness claim
  - no privacy/compliance signoff claim
- **Next runner command:** {next_command}

This note is candidate-only. Do not implement from this note.
"""


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Scaffold read-only batch prep notes.")
    parser.add_argument("--batch", help="Generate one prep note")
    parser.add_argument("--from-queue", help="Queue json file", default="docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json")
    parser.add_argument("--output", help="Output file path")
    parser.add_argument("--output-dir", help="Directory for multiple scaffold files")
    parser.add_argument("--limit", type=int, default=10)
    parser.add_argument("--start-at", help="Start queue scaffolding at this batch id")
    parser.add_argument("--force", action="store_true", help="Overwrite existing prep files")
    parser.add_argument("--dry-run", action="store_true", help="Print planned writes without modifying files")
    return parser.parse_args()


def load_queue(path: Path) -> Iterable[Dict]:
    return json.loads(path.read_text(encoding="utf-8")).get("batches", [])


def prompt_exists(batch_id: str) -> bool:
    return Path(f"prompts/batches/{batch_id}.md").exists()


def render(batch: Dict, args: argparse.Namespace) -> str:
    batch_id = batch.get("id", "UNKNOWN")
    title = batch.get("title", "Untitled")
    queue_class = batch.get("classification", "unknown")

    dep_default = "depends on prior queued dependency chain; live queue state should be checked before execution."

    if queue_class == "historical_complete_do_not_run":
        dep_default = "historical_complete_do_not_run in current queue truth"
    elif queue_class == "executable_now":
        dep_default = "next canonical executable batch in this run-state lane"

    owner = "candidate / to be confirmed from live prompt and current-truth owners"
    if batch_id == "PK16":
        owner = "Native/Ambitions/Persistence/* and PK16 docs/audit lanes only if implementation is re-opened"

    tests = "No fixed test set until prompt-level instructions are confirmed."
    if batch_id == "PK16":
        tests = "PK16 prep should re-check focused trust-history repository test path when prompt is executed."

    return TEMPLATE.format(
        batch_id=batch_id,
        title=title,
        queue_classification=queue_class,
        dependency_status=dep_default,
        prompt_file=f"prompts/batches/{batch_id}.md",
        prompt_status="present" if prompt_exists(batch_id) else "missing",
        likely_owner_files=owner,
        likely_tests=tests,
        efc_applicability="invoke when trust/proof/receipt/data-control paths are touched",
        yellow_caveats="Known Yellow: ExternalSurfaceVerificationChecklistTests.testM04ExistingProjectionsCarryStalePrivateAndFallbackBehavior",
        senior_risks="Any product truth boundary, scope drift, proof claim, or release-readiness implication",
        rollback="No mutation is made by this scaffold; restore if manual edits are reverted.",
        next_command=f"make batch BATCH={batch_id} PROMPT=prompts/batches/{batch_id}.md",
    )


def write_note(path: Path, text: str, force: bool) -> bool:
    if path.exists() and not force:
        return False
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding="utf-8")
    return True


def main() -> int:
    args = parse_args()
    queue = list(load_queue(Path(args.from_queue)))

    notes = []

    if args.batch:
        target = args.batch.upper()
        matches = [b for b in queue if b.get("id") == target]
        if not matches:
            print(f"ERROR: batch not found in queue: {target}", file=sys.stderr)
            return 2
        notes = matches[:1]
    else:
        if args.start_at:
            start = args.start_at.upper()
            start_indexes = [i for i, b in enumerate(queue) if b.get("id") == start]
            if not start_indexes:
                print(f"ERROR: start batch not found in queue: {start}", file=sys.stderr)
                return 2
            queue = queue[start_indexes[0] :]
        notes = queue[: args.limit]

    output_dir = Path(args.output_dir) if args.output_dir else None
    for batch in notes:
        batch_id = batch.get("id", "UNKNOWN")
        output = Path(args.output) if args.output else None
        if output_dir:
            output = output_dir / f"{batch_id}.md"
        if not output:
            print("ERROR: either --output or --output-dir is required", file=sys.stderr)
            return 2

        text = render(batch, args)
        if args.dry_run:
            action = "OVERWRITE" if output.exists() and args.force else "WRITE"
            if output.exists() and not args.force:
                action = "SKIP"
            print(f"DRY_RUN {action} {output}")
            continue
        if write_note(output, text, args.force):
            print(f"WROTE {output}")
        else:
            print(f"SKIP {output} (exists; use --force to overwrite)")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
