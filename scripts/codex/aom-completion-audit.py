#!/usr/bin/env python3
"""Audit Object-Stage Mega Train completed batch records.

This script is intentionally independent from the train runner so a broken runner
cannot certify itself. It reconstructs each recorded batch interval from
train-state.json start SHAs and the next recorded start SHA, classifies durable
changed files, and reports false Greens.
"""
from __future__ import annotations

import argparse
import json
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
import subprocess
import sys
from typing import Iterable

ROOT = Path(__file__).resolve().parents[2]

IGNORED_PREFIXES = (
    ".codex/runs/",
    "artifacts/codex-train-v3/",
)


@dataclass
class AuditRow:
    batch_id: str
    title: str
    batch_type: str
    recorded_status: str
    audit_status: str
    start_sha: str
    end_ref: str
    reason: str
    changed_files: list[str]
    changed_files_by_kind: dict[str, list[str]]
    source_delta_count: int
    test_delta_count: int
    schema_delta_count: int
    artifact_delta_count: int
    off_path_changes: list[str]


def now_utc() -> str:
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def normalize(path: str) -> str:
    return path.replace("\\", "/")


def run(command: list[str], check: bool = True) -> str:
    process = subprocess.run(
        command,
        cwd=ROOT,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        check=False,
    )
    if check and process.returncode != 0:
        raise RuntimeError(process.stdout)
    return process.stdout.strip()


def git(args: list[str], check: bool = True) -> str:
    return run(["git", *args], check=check)


def load_json(path: Path) -> dict:
    if not path.is_absolute():
        path = ROOT / path
    return json.loads(path.read_text(encoding="utf-8"))


def batch_order(manifest: dict) -> list[str]:
    return [str(batch["id"]) for batch in manifest.get("batches", [])]


def batch_map(manifest: dict) -> dict[str, dict]:
    return {str(batch["id"]): batch for batch in manifest.get("batches", [])}


def selected_order(order: list[str], start: str, end: str) -> list[str]:
    selected: list[str] = []
    started = start == "auto"
    for batch_id in order:
        if batch_id == start:
            started = True
        if started:
            selected.append(batch_id)
        if end != "auto" and batch_id == end:
            break
    return selected


def ordered_record_history(state: dict) -> list[dict]:
    history: list[dict] = []
    for item in state.get("completed_batches", []):
        if isinstance(item, dict) and item.get("id"):
            history.append(item)
    return history


def diff_files(base: str, head: str) -> list[str]:
    if not base or not head:
        return []
    out = git(["diff", "--name-only", base, head], check=False)
    return sorted({normalize(line.strip()) for line in out.splitlines() if line.strip()})


def path_allowed(path: str, allowed: Iterable[str]) -> bool:
    normalized = normalize(path)
    for prefix in allowed:
        clean = normalize(str(prefix))
        if clean.endswith("/"):
            if normalized.startswith(clean):
                return True
        elif normalized == clean:
            return True
    if normalized.startswith(IGNORED_PREFIXES):
        return True
    return False


def classify(files: Iterable[str], train_id: str) -> dict[str, list[str]]:
    kinds: dict[str, list[str]] = {
        "app_source": [],
        "tests": [],
        "persistence_schema": [],
        "scripts": [],
        "truth_docs": [],
        "schema_decision": [],
        "train_artifacts": [],
        "runner_artifacts": [],
        "other": [],
    }
    for raw in files:
        path = normalize(raw)
        if path.startswith(IGNORED_PREFIXES):
            kinds["runner_artifacts"].append(path)
        elif path.startswith("Native/AmbitionsTests/") or path.startswith("Native/AmbitionsUITests/"):
            kinds["tests"].append(path)
        elif path.startswith("Native/Ambitions/Persistence/") or path.startswith("Native/Ambitions/Domain/"):
            kinds["persistence_schema"].append(path)
        elif path.startswith("Native/Ambitions/") or path.startswith("Sources/") or path.startswith("AppUI/"):
            kinds["app_source"].append(path)
        elif path.startswith("scripts/"):
            kinds["scripts"].append(path)
        elif path.startswith("docs/truth/") or path == "AGENTS.md":
            kinds["truth_docs"].append(path)
        elif path.startswith(f"artifacts/{train_id}/") and path.endswith("-schema-decision.md"):
            kinds["schema_decision"].append(path)
        elif path.startswith(f"artifacts/{train_id}/"):
            kinds["train_artifacts"].append(path)
        else:
            kinds["other"].append(path)
    return kinds


def schema_decision_valid(batch_id: str, train_id: str, changed: dict[str, list[str]]) -> tuple[bool, str]:
    expected = f"artifacts/{train_id}/{batch_id}-schema-decision.md"
    if expected not in changed.get("schema_decision", []):
        return False, f"missing {expected}"
    path = ROOT / expected
    if not path.exists():
        return False, f"{expected} missing on disk"
    lower = path.read_text(encoding="utf-8", errors="ignore").lower()
    required = {
        "inspected SwiftData/domain/persistence files": ["inspected", "swiftdata", "persistence"],
        "model inventory": ["model inventory"],
        "schema changed yes/no": ["schema changed", "no"],
        "migration/defaults impact": ["migration", "default"],
        "tests run or not-run reason": ["test"],
        "local-first/privacy boundary": ["local-first", "privacy"],
        "rollback": ["rollback"],
    }
    missing = [label for label, tokens in required.items() if not all(token in lower for token in tokens)]
    if missing:
        return False, "schema decision missing sections: " + ", ".join(missing)
    return True, "valid schema no-change decision"


def audit_batch(
    batch: dict,
    record: dict,
    end_ref: str,
    train_id: str,
) -> AuditRow:
    batch_id = str(batch["id"])
    batch_type = str(batch.get("type", "source")).lower()
    start_sha = str(record.get("start_sha", ""))
    recorded_status = str(record.get("status", "green"))
    files = diff_files(start_sha, end_ref)
    changed = classify(files, train_id)
    durable = [path for path in files if not path.startswith(IGNORED_PREFIXES)]
    durable_changed = classify(durable, train_id)
    source_count = len(durable_changed["app_source"])
    test_count = len(durable_changed["tests"])
    schema_count = len(durable_changed["persistence_schema"])
    artifact_count = len(durable_changed["train_artifacts"]) + len(durable_changed["schema_decision"])
    allowed = list(batch.get("allowed_paths") or [])
    off_path = [path for path in files if not path_allowed(path, allowed)]

    status = "green"
    reason = "recorded completion has acceptable durable delta"

    if recorded_status == "invalidated":
        status = "yellow"
        reason = "record is already invalidated"
    elif off_path:
        status = "red"
        reason = f"off-path changes detected: {off_path}"
    elif batch_type == "audit":
        source_like = durable_changed["app_source"] + durable_changed["tests"] + durable_changed["persistence_schema"]
        if source_like:
            status = "red"
            reason = f"audit batch changed source/test/schema paths: {source_like}"
        elif not artifact_count:
            status = "yellow"
            reason = "audit batch has no durable artifact delta"
    elif batch_type == "source":
        if source_count + test_count == 0:
            status = "red"
            reason = "source batch has no app source or test delta"
        elif source_count == 0 and test_count > 0:
            status = "yellow"
            reason = "source batch changed tests only; verify source was already compliant or replay"
    elif batch_type == "schema":
        if schema_count + test_count > 0:
            status = "green"
            reason = "schema batch changed persistence/domain or tests"
        else:
            valid, detail = schema_decision_valid(batch_id, train_id, durable_changed)
            if valid:
                status = "green"
                reason = detail
            else:
                status = "red"
                reason = f"schema batch has no schema/test delta and no valid decision artifact: {detail}"
    elif batch_type == "visual":
        if source_count + test_count == 0:
            status = "red"
            reason = "visual batch has no app/UI source or test delta"
        elif source_count <= 1 and test_count == 0:
            status = "yellow"
            reason = "thin visual delta; verify scope completion against screenshots/product report"
    elif batch_type == "validation":
        if not artifact_count and not test_count and not durable_changed["scripts"]:
            status = "red"
            reason = "validation batch has no validation artifacts/tests/scripts"
    elif not durable:
        status = "red"
        reason = f"unknown batch type {batch_type!r} has no durable delta"

    return AuditRow(
        batch_id=batch_id,
        title=str(batch.get("title", "")),
        batch_type=batch_type,
        recorded_status=recorded_status,
        audit_status=status,
        start_sha=start_sha,
        end_ref=end_ref,
        reason=reason,
        changed_files=files,
        changed_files_by_kind=changed,
        source_delta_count=source_count,
        test_delta_count=test_count,
        schema_delta_count=schema_count,
        artifact_delta_count=artifact_count,
        off_path_changes=off_path,
    )


def infer_end_refs(history: list[dict], head_ref: str) -> dict[int, str]:
    end_refs: dict[int, str] = {}
    for index, _record in enumerate(history):
        next_start = ""
        for following in history[index + 1 :]:
            if following.get("start_sha"):
                next_start = str(following["start_sha"])
                break
        end_refs[index] = next_start or head_ref
    return end_refs


def render_markdown(rows: list[AuditRow], output_json: str) -> str:
    lines = [
        "# AMB-AOM Completed Batch Audit",
        "",
        f"Generated: {now_utc()}",
        f"JSON: `{output_json}`",
        "",
        "## Verdict table",
        "",
        "| Batch | Type | Recorded | Audit | Source | Tests | Schema | Artifacts | Reason |",
        "|---|---|---:|---:|---:|---:|---:|---:|---|",
    ]
    for row in rows:
        lines.append(
            "| {batch} | {type} | {recorded} | {audit} | {source} | {tests} | {schema} | {artifacts} | {reason} |".format(
                batch=row.batch_id,
                type=row.batch_type,
                recorded=row.recorded_status,
                audit=row.audit_status,
                source=row.source_delta_count,
                tests=row.test_delta_count,
                schema=row.schema_delta_count,
                artifacts=row.artifact_delta_count,
                reason=row.reason.replace("|", "\\|"),
            )
        )
    lines.extend(["", "## Changed files by batch", ""])
    for row in rows:
        lines.extend(
            [
                f"### {row.batch_id} — {row.title}",
                "",
                f"- Start SHA: `{row.start_sha}`",
                f"- End ref: `{row.end_ref}`",
                f"- Audit status: `{row.audit_status}`",
                f"- Reason: {row.reason}",
                "",
            ]
        )
        for kind, paths in row.changed_files_by_kind.items():
            if not paths:
                continue
            lines.append(f"#### {kind}")
            for path in paths:
                lines.append(f"- `{path}`")
            lines.append("")
    return "\n".join(lines) + "\n"


def parse_args(argv: Iterable[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Audit AMB-AOM completed batch records.")
    parser.add_argument("--train", default="trains/object-stage-mega-train/train.json")
    parser.add_argument("--state", default="artifacts/object-stage-mega-train/train-state.json")
    parser.add_argument("--from", dest="start_batch", default="auto")
    parser.add_argument("--to", dest="end_batch", default="auto")
    parser.add_argument("--head-ref", default="HEAD")
    parser.add_argument("--fail-on-invalid-green", action="store_true")
    return parser.parse_args(list(argv))


def main(argv: Iterable[str] = sys.argv[1:]) -> int:
    args = parse_args(argv)
    manifest = load_json(Path(args.train))
    state = load_json(Path(args.state))
    train_id = str(manifest["id"])
    order = selected_order(batch_order(manifest), args.start_batch, args.end_batch)
    batches = batch_map(manifest)
    history = ordered_record_history(state)
    end_refs = infer_end_refs(history, args.head_ref)

    rows: list[AuditRow] = []
    for index, record in enumerate(history):
        batch_id = str(record.get("id", ""))
        if batch_id not in order or batch_id not in batches:
            continue
        rows.append(audit_batch(batches[batch_id], record, end_refs[index], train_id))

    out_dir = ROOT / "artifacts" / train_id / "audits"
    out_dir.mkdir(parents=True, exist_ok=True)
    json_path = out_dir / "AMB-AOM-completed-batch-audit.json"
    md_path = out_dir / "AMB-AOM-completed-batch-audit.md"

    payload = {
        "generated_at": now_utc(),
        "train_id": train_id,
        "rows": [
            {
                "batch_id": row.batch_id,
                "title": row.title,
                "batch_type": row.batch_type,
                "recorded_status": row.recorded_status,
                "audit_status": row.audit_status,
                "start_sha": row.start_sha,
                "end_ref": row.end_ref,
                "reason": row.reason,
                "source_delta_count": row.source_delta_count,
                "test_delta_count": row.test_delta_count,
                "schema_delta_count": row.schema_delta_count,
                "artifact_delta_count": row.artifact_delta_count,
                "off_path_changes": row.off_path_changes,
                "changed_files": row.changed_files,
                "changed_files_by_kind": row.changed_files_by_kind,
            }
            for row in rows
        ],
    }
    json_path.write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    md_path.write_text(render_markdown(rows, json_path.relative_to(ROOT).as_posix()), encoding="utf-8")

    for row in rows:
        print(f"{row.batch_id}: {row.audit_status.upper()} — {row.reason}")

    has_red = any(row.audit_status == "red" for row in rows)
    if args.fail_on_invalid_green and has_red:
        return 2
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
