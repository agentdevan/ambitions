#!/usr/bin/env python3
"""Advance Ambitions batch state mirrors after a verified or proof-light install.

This helper is intentionally deterministic and conservative. It updates the
compact state mirrors and canonical queue, but does not fabricate validation
proof. Use --write to mutate files; dry-run is the default.
"""
from __future__ import annotations

import argparse
import json
import re
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
QUEUE = ROOT / "docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json"
ACTIVE = ROOT / ".codex/state/active-batch.yml"
RUN_STATE = ROOT / ".codex/reports/current-run-state.md"
TRAIN_STATE = ROOT / ".codex/reports/current-batch-train-state.md"
ATTEMPT_LEDGER = ROOT / ".codex/state/global-train-attempt-ledger.md"

STATUS_TO_CLASSIFICATION = {
    "green": "historical_complete_do_not_run",
    "accepted_yellow": "historical_complete_do_not_run",
    "installed_unverified": "historical_complete_do_not_run",
}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Advance Ambitions batch state mirrors.")
    parser.add_argument("--completed", required=True, help="Completed batch id, e.g. SA07")
    parser.add_argument("--next", required=True, help="Next batch id, e.g. SA08")
    parser.add_argument("--status", required=True, choices=sorted(STATUS_TO_CLASSIFICATION), help="Completion status")
    parser.add_argument("--commit", default="", help="Commit SHA for completed batch")
    parser.add_argument("--report", default="", help="Closeout report path")
    parser.add_argument("--proof", default="focused/proof-light closeout recorded", help="Proof summary")
    parser.add_argument("--write", action="store_true", help="Write files. Default is dry-run.")
    return parser.parse_args()


def load_queue() -> dict[str, Any]:
    return json.loads(QUEUE.read_text(encoding="utf-8"))


def batch_title(queue: dict[str, Any], batch_id: str) -> str:
    for entry in queue.get("batches", []):
        if entry.get("id") == batch_id:
            return entry.get("title", "Untitled")
    return "Untitled"


def update_queue(queue: dict[str, Any], completed: str, next_batch: str, status: str, commit: str, report: str) -> dict[str, Any]:
    found_completed = False
    found_next = False
    for entry in queue.get("batches", []):
        if entry.get("id") == completed:
            found_completed = True
            entry["classification"] = STATUS_TO_CLASSIFICATION[status]
            status_label = status.replace("_", " ").title()
            commit_note = f" and commit {commit} committed on local main" if commit else ""
            report_note = f" in {report}" if report else ""
            entry["reason"] = (
                f"{completed} {entry.get('title', '')} is complete / {status_label} with closeout{report_note}{commit_note}. "
                "Do not rerun as an implementation batch."
            )
            entry["blocking_prerequisites"] = f"Complete / {status_label}; do not rerun through normal fallback."
        elif entry.get("id") == next_batch:
            found_next = True
            entry["classification"] = "executable_now"
            entry["reason"] = f"{completed} is complete / {status.replace('_', ' ')}. {next_batch} is the next implementation batch."
            entry["blocking_prerequisites"] = f"Complete prior batch {completed}."
        elif entry.get("classification") == "executable_now":
            entry["classification"] = "executable_later"
            entry["reason"] = f"Demoted from executable_now by state advancement after {completed}; remains serial/dependency gated."
    if not found_completed:
        raise SystemExit(f"ERROR: completed batch not found in queue: {completed}")
    if not found_next:
        raise SystemExit(f"ERROR: next batch not found in queue: {next_batch}")
    queue["next_eligible_batch"] = next_batch
    queue["next_eligible_title"] = batch_title(queue, next_batch)
    queue["date"] = datetime.now(timezone.utc).strftime("%Y-%m-%d")
    return queue


def active_text(completed: str, next_batch: str, queue: dict[str, Any], status: str) -> str:
    next_title = batch_title(queue, next_batch)
    completed_title = batch_title(queue, completed)
    return f'''status: compact-mirror
date: "{datetime.now(timezone.utc).strftime('%Y-%m-%d')}"
source_of_truth:
  - ".codex/reports/current-batch-train-state.md"
  - "docs/codex/BATCH_REGISTRY.md"
  - "docs/codex/GLOBAL_QUEUE_MATURITY_LEDGER.md"
  - "docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json"
  - "docs/codex/BATCH_REGISTRY_EFC_OVERLAY.md"
  - "docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md"
  - "docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER_EFC_PEAK_OVERLAY.md"
  - "docs/codex/EFC_FLAGSHIP_PROOF_OPERATING_LAYER.md"
current:
  train: "Global full-stack execution"
  batch: "{completed} {completed_title}"
  previous_batch: "{completed} {completed_title}"
  previous_result: "{status}"
  next_eligible_batch: "{next_batch} {next_title}"
codex_os_override:
  active_pass: "post-PK accelerated implementation"
  app_feature_implementation_allowed: true
  production_swift_allowed: true
  branch_creation_allowed: false
efc_overlay:
  status: "active proof overlay wired into canonical queue"
  current_batch_preserved: true
  next_batch_must_inherit_efc: true
  peak_optimized_sequence_owner: "docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER_EFC_PEAK_OVERLAY.md"
'''


def state_report_text(kind: str, completed: str, next_batch: str, queue: dict[str, Any], status: str, commit: str, report: str, proof: str) -> str:
    next_title = batch_title(queue, next_batch)
    completed_title = batch_title(queue, completed)
    status_label = status.replace("_", " ").title()
    commit_line = f"- Commit: `{commit}` committed on local `main`.\n" if commit else ""
    report_line = f"- Report: `{report}`.\n" if report else ""
    return f'''# {kind}

Date: {datetime.now(timezone.utc).strftime('%Y-%m-%d')}
Active train: Global full-stack execution
Current batch: {completed} {completed_title} / {status_label}.
Next eligible batch: {next_batch} {next_title}
Scope: {completed} {completed_title} is complete / {status_label} with {proof}; {next_batch} {next_title} is next after prior active dependencies. This state mirror does not claim release readiness, device validation, accessibility conformance, performance validation, sync/cloud behavior, hosted AI, TestFlight/App Store readiness, or global train completion.
AFI source truth is active for product/IA/UI/visual/copy decisions.
The active flagship top-level IA is Today / Goals / Capture / Time / You.
Plan is superseded as a top-level destination and remains valid only as an action/contextual noun, historical evidence, or internal compatibility seam.

## {completed} {completed_title} Closeout

{commit_line}{report_line}- Status: {status_label}.
- Proof: {proof}.
- Canonical queue now marks {completed} complete/do-not-run and {next_batch} executable now.
- No full-suite, device, accessibility, performance, TestFlight/App Store, legal/privacy, release-readiness, sync/cloud, hosted AI, or global-train-completion claim is made.
'''


def ledger_append(completed: str, next_batch: str, status: str, commit: str) -> str:
    existing = ATTEMPT_LEDGER.read_text(encoding="utf-8") if ATTEMPT_LEDGER.exists() else "# Global Train Attempt Ledger\n"
    stamp = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    return existing.rstrip() + f'''

## Post-PK State Advancement — {stamp}

- completed batch: {completed}
- status: {status}
- commit: {commit or 'not-recorded'}
- next batch: {next_batch}
- mode: deterministic state advancement helper
'''


def main() -> int:
    args = parse_args()
    queue = update_queue(load_queue(), args.completed, args.next, args.status, args.commit, args.report)
    outputs = {
        QUEUE: json.dumps(queue, indent=2) + "\n",
        ACTIVE: active_text(args.completed, args.next, queue, args.status),
        RUN_STATE: state_report_text("Current Run State", args.completed, args.next, queue, args.status, args.commit, args.report, args.proof),
        TRAIN_STATE: state_report_text("Current Batch Train State", args.completed, args.next, queue, args.status, args.commit, args.report, args.proof),
        ATTEMPT_LEDGER: ledger_append(args.completed, args.next, args.status, args.commit),
    }
    if args.write:
        for path, text in outputs.items():
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text(text, encoding="utf-8")
        print(f"WROTE: advanced {args.completed} -> {args.next} ({args.status})")
    else:
        print(f"DRY_RUN: would advance {args.completed} -> {args.next} ({args.status})")
        for path in outputs:
            print(f"- {path.relative_to(ROOT)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
