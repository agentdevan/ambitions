#!/usr/bin/env python3
"""Reconcile IOS26 batch execution state for resume-safe sequential runs."""

from __future__ import annotations

import argparse
import json
import re
from datetime import datetime, timezone
from pathlib import Path
from typing import Iterable

ROOT = Path(__file__).resolve().parents[1]
MANIFEST = ROOT / "docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml"
STATE_FILE = ROOT / "docs/codex/IOS26_FLAGSHIP_EXECUTION_STATE.yml"
REPORT_DIR = ROOT / "build/reports/ios26-execution-state"
REPORT_MD = REPORT_DIR / "reconcile.md"
REPORT_JSON = REPORT_DIR / "reconcile.json"
BATCH_RE = re.compile(r"IOS26-T\d{2}[A-Z]?-B\d{2}")
STATUS_RE = re.compile(r"^\s*(?:Status|STATUS)\s*:\s*`?([A-Za-z _-]+)`?", re.IGNORECASE | re.MULTILINE)

COMPLETE_STATUSES = {"proven_green", "accepted_yellow", "user_reported_complete_unproven"}


def utc_now() -> str:
    return datetime.now(timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")


def rel(path: Path) -> str:
    return str(path.relative_to(ROOT))


def parse_manifest() -> list[dict[str, str]]:
    rows: list[dict[str, str]] = []
    section = ""
    current_train = ""
    current_title = ""
    in_batches = False
    for raw in MANIFEST.read_text(encoding="utf-8").splitlines():
        line = raw.rstrip()
        stripped = line.strip()
        if stripped == "trains:":
            section = "trains"
            continue
        if section != "trains":
            continue
        if line.startswith("  - id: "):
            current_train = stripped.removeprefix("- id: ")
            current_title = ""
            in_batches = False
        elif current_train and line.startswith("    title: "):
            current_title = stripped.removeprefix("title: ")
        elif current_train and stripped == "batches:":
            in_batches = True
        elif current_train and in_batches and line.startswith("      - "):
            batch = stripped.removeprefix("- ")
            rows.append({"batch_id": batch, "train_id": current_train, "train_title": current_title})
    return rows


def manifest_ids(rows: list[dict[str, str]]) -> list[str]:
    return [row["batch_id"] for row in rows]


def read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8", errors="ignore")


def text_directly_describes_batch(text: str, batch: str) -> bool:
    escaped = re.escape(batch)
    patterns = [
        rf"^\s*#.*{escaped}",
        rf"^\s*[-*]?\s*Batch\s*:\s*`?{escaped}`?",
        rf'"batch(?:_id|ID)?"\s*:\s*"{escaped}"',
        rf"\bBATCH={escaped}\b",
        rf"\brun_batch\s+{escaped}\b",
        rf"\b{escaped}\b.*\b(Status|STATUS|Commands Run|Validation Status|Claims Allowed)\b",
    ]
    return any(re.search(pattern, text, re.IGNORECASE | re.MULTILINE) for pattern in patterns)


def build_artifact_index(batch_ids: list[str]) -> dict[str, list[Path]]:
    wanted = set(batch_ids)
    index: dict[str, set[Path]] = {batch: set() for batch in batch_ids}
    roots = [ROOT / "build/reports", ROOT / ".codex/runs"]
    for root in roots:
        if not root.exists():
            continue
        for path in root.rglob("*"):
            if not path.is_file() or path.suffix.lower() not in {".md", ".txt", ".json", ".log", ".yml", ".yaml"}:
                continue
            is_codex_run = ".codex" in path.parts and "runs" in path.parts
            if is_codex_run and path.name not in {"final-summary.md", "result.json", "result.yml", "result.yaml"}:
                continue
            path_text = str(path)
            for batch in wanted:
                if batch in path_text:
                    index[batch].add(path)
            try:
                text = read_text(path)
            except OSError:
                continue
            for batch in set(BATCH_RE.findall(text)) & wanted:
                if text_directly_describes_batch(text[:6000], batch):
                    index[batch].add(path)
    return {batch: sorted(paths) for batch, paths in index.items()}


def classify_status_text(texts: Iterable[str]) -> tuple[str | None, str]:
    saw_yellow = False
    saw_green = False
    saw_red = False
    saw_pass = False
    saw_artifact = False
    for text in texts:
        if not text.strip():
            continue
        saw_artifact = True
        for match in STATUS_RE.finditer(text):
            value = match.group(1).strip().lower().replace("_", " ")
            if "red" in value:
                saw_red = True
            elif "yellow" in value:
                saw_yellow = True
            elif "green" in value:
                saw_green = True
        lower = text.lower()
        if any(token in lower for token in ["status: `green`", "status: green", "passed", "0 failures", "proof passed", "completed successfully"]):
            saw_pass = True
    if saw_red:
        return "blocked_red", "status line or report text indicated Red"
    if saw_yellow:
        return "accepted_yellow", "status line indicated Yellow or accepted Yellow"
    if saw_green:
        return "proven_green", "status line indicated Green"
    if saw_artifact and saw_pass:
        return "accepted_yellow", "artifact has pass evidence but no explicit Green status; treated as accepted Yellow"
    if saw_artifact:
        return "unknown_requires_operator_review", "artifact exists but status is ambiguous"
    return None, "no artifact found"


def parse_state_user_report() -> tuple[str | None, list[str]]:
    if not STATE_FILE.exists():
        return None, []
    text = read_text(STATE_FILE)
    complete = None
    likely: list[str] = []
    match = re.search(r"complete_through:\s*(IOS26-T\d{2}[A-Z]?-B\d{2})", text)
    if match:
        complete = match.group(1)
    likely.extend(re.findall(r"likely_complete:\s*(IOS26-T\d{2}[A-Z]?-B\d{2})", text))
    likely.extend(re.findall(r"-\s*(IOS26-T\d{2}[A-Z]?-B\d{2})\s*#\s*likely_complete", text))
    return complete, likely


def ids_through(ids: list[str], through: str | None) -> set[str]:
    if not through:
        return set()
    if through not in ids:
        raise SystemExit(f"RED: batch not in manifest for --user-complete-through: {through}")
    return set(ids[: ids.index(through) + 1])


def reconcile(user_complete_through: str | None, user_likely_complete: list[str]) -> dict[str, object]:
    rows = parse_manifest()
    ids = manifest_ids(rows)
    artifact_index = build_artifact_index(ids)
    state_complete, state_likely = parse_state_user_report()
    complete_through = user_complete_through or state_complete
    likely_complete = list(dict.fromkeys([*state_likely, *user_likely_complete]))
    for batch in likely_complete:
        if batch not in ids:
            raise SystemExit(f"RED: likely-complete batch not in manifest: {batch}")
    user_complete_ids = ids_through(ids, complete_through)
    classifications: list[dict[str, object]] = []
    for index, row in enumerate(rows, start=1):
        batch_id = row["batch_id"]
        artifacts = artifact_index.get(batch_id, [])
        texts = []
        evidence_paths = []
        for path in artifacts[:20]:
            try:
                texts.append(read_text(path)[:12000])
                evidence_paths.append(rel(path))
            except OSError:
                continue
        status, reason = classify_status_text(texts)
        source = "proof_artifacts"
        user_reported = batch_id in user_complete_ids or batch_id in likely_complete
        if status is None:
            if batch_id in user_complete_ids or batch_id in likely_complete:
                status = "user_reported_complete_unproven"
                source = "operator_report"
                reason = "operator reported complete/likely complete; not proof"
            else:
                status = "not_started"
                source = "no_evidence"
        elif status == "unknown_requires_operator_review" and user_reported:
            status = "user_reported_complete_unproven"
            source = "operator_report_with_ambiguous_artifact"
            reason = "operator reported complete/likely complete; ambiguous artifacts are not proof"
        elif status == "blocked_red" and user_reported and not any(path.startswith("build/reports/") for path in evidence_paths):
            status = "user_reported_complete_unproven"
            source = "operator_report_with_stale_runner_artifact"
            reason = "operator reported complete/likely complete; stale runner artifacts are not treated as current Red proof"
        classifications.append(
            {
                "index": index,
                **row,
                "status": status,
                "state_source": source,
                "reason": reason,
                "evidence": evidence_paths[:8],
                "no_claim_boundary": boundary_for(status),
            }
        )
    first_incomplete = next((item["batch_id"] for item in classifications if item["status"] not in COMPLETE_STATUSES), None)
    recommended = first_incomplete or "COMPLETE"
    return {
        "generated_at": utc_now(),
        "manifest_batches": len(rows),
        "user_complete_through": complete_through,
        "user_likely_complete": likely_complete,
        "first_incomplete_batch": first_incomplete,
        "recommended_start_at": recommended,
        "classifications": classifications,
        "counts": counts(classifications),
    }


def boundary_for(status: str) -> str:
    if status == "proven_green":
        return "May skip as proof-backed Green; do not infer release/accessibility/performance/privacy readiness."
    if status == "accepted_yellow":
        return "May skip as accepted Yellow only with recorded no-claim boundaries; do not claim full proof."
    if status == "user_reported_complete_unproven":
        return "Operational skip only; no Green, validation, accessibility, performance, privacy, release, or implementation-complete claim."
    if status == "blocked_red":
        return "Do not skip or continue; Red requires repair or operator decision."
    if status == "unknown_requires_operator_review":
        return "Do not skip automatically without operator review or explicit override."
    return "Not started; eligible next batch only when previous dependencies are accepted."


def counts(items: list[dict[str, object]]) -> dict[str, int]:
    out: dict[str, int] = {}
    for item in items:
        status = str(item["status"])
        out[status] = out.get(status, 0) + 1
    return out


def render_md(report: dict[str, object]) -> str:
    rows: list[dict[str, object]] = report["classifications"]  # type: ignore[assignment]
    lines = [
        "# IOS26 Execution State Reconcile",
        "",
        f"Generated: {report['generated_at']}",
        "Status: YELLOW" if report["counts"].get("user_reported_complete_unproven", 0) else "Status: GREEN",
        "",
        f"- Manifest batches: {report['manifest_batches']}",
        f"- User complete through: {report.get('user_complete_through') or 'none'}",
        f"- User likely complete: {', '.join(report.get('user_likely_complete') or []) or 'none'}",
        f"- First incomplete batch: {report.get('first_incomplete_batch') or 'none'}",
        f"- Recommended START_AT: {report.get('recommended_start_at')}",
        f"- Counts: `{json.dumps(report['counts'], sort_keys=True)}`",
        "",
        "User-reported progress is operational context only. It is not proof.",
        "",
        "## Completed / Skippable",
    ]
    for item in rows:
        if item["status"] in COMPLETE_STATUSES:
            lines.append(f"- `{item['batch_id']}`: {item['status']} ({item['state_source']}) - {item['no_claim_boundary']}")
    lines.extend(["", "## Incomplete / Review"])
    for item in rows:
        if item["status"] not in COMPLETE_STATUSES:
            lines.append(f"- `{item['batch_id']}`: {item['status']} - {item['reason']}")
    return "\n".join(lines) + "\n"


def write_report(report: dict[str, object]) -> None:
    REPORT_DIR.mkdir(parents=True, exist_ok=True)
    REPORT_JSON.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    REPORT_MD.write_text(render_md(report), encoding="utf-8")


def render_state(report: dict[str, object]) -> str:
    lines = [
        "program_id: IOS26-FLAGSHIP",
        "last_reconciled_by: scripts/ios26-execution-state-reconcile.py",
        f"last_reconciled_at: {report['generated_at']}",
        "state_source_policy:",
        "  user_reported_state_is_operational_context_not_proof: true",
        "  manifest_status_is_install_state_not_execution_proof: true",
        "  closeout_artifacts_required_for_green_completion_claims: true",
        "resume:",
        f"  first_incomplete_batch: {report.get('first_incomplete_batch') or 'none'}",
        f"  recommended_start_at: {report.get('recommended_start_at')}",
        f"  user_complete_through: {report.get('user_complete_through') or 'none'}",
        "  user_likely_complete:",
    ]
    likely = report.get("user_likely_complete") or []
    if likely:
        lines.extend(f"    - {batch}" for batch in likely)
    else:
        lines.append("    - none")
    lines.extend(
        [
            "global_claim_boundaries:",
            "  - no_release_readiness_claim",
            "  - no_app_store_readiness_claim",
            "  - no_accessibility_verification_claim_without_current_evidence",
            "  - no_performance_validation_claim_without_measurements",
            "  - no_privacy_approval_claim_without_scan_and_proof_packet",
            "  - no_private_life_runtime_moat_claim_without_replayable_local_proof",
            "classifications:",
        ]
    )
    for item in report["classifications"]:  # type: ignore[index]
        lines.extend(
            [
                f"  - batch_id: {item['batch_id']}",
                f"    train_id: {item['train_id']}",
                f"    status: {item['status']}",
                f"    state_source: {item['state_source']}",
                f"    no_claim_boundary: \"{str(item['no_claim_boundary']).replace(chr(34), chr(39))}\"",
            ]
        )
    return "\n".join(lines) + "\n"


def print_runner_plan(report: dict[str, object], start_at: str | None, complete_through: str | None, skip_completed: bool) -> None:
    rows: list[dict[str, object]] = report["classifications"]  # type: ignore[assignment]
    ids = [str(row["batch_id"]) for row in rows]
    if start_at and start_at not in ids:
        raise SystemExit(f"RED: START_AT batch not in manifest: {start_at}")
    if complete_through and complete_through not in ids:
        raise SystemExit(f"RED: COMPLETE_THROUGH batch not in manifest: {complete_through}")
    start_seen = not bool(start_at)
    complete_cutoff = ids.index(complete_through) if complete_through and not start_at else -1
    for index, item in enumerate(rows):
        batch = str(item["batch_id"])
        action = "RUN"
        reason = "next runnable"
        if start_at:
            if batch == start_at:
                start_seen = True
            if not start_seen:
                action = "SKIP"
                reason = "before START_AT"
        elif complete_cutoff >= 0 and index <= complete_cutoff:
            action = "SKIP"
            reason = "operator COMPLETE_THROUGH"
        elif skip_completed and item["status"] in COMPLETE_STATUSES:
            action = "SKIP"
            reason = str(item["status"])
        if action == "RUN":
            print(f"NEXT_RUN_BATCH\t{batch}\t{item['status']}\t{reason}")
            return
        print(f"SKIPPED_BATCH\t{batch}\t{item['status']}\t{reason}\t{item['no_claim_boundary']}")
    print("NEXT_RUN_BATCH\tCOMPLETE\tCOMPLETE\tno runnable batches")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true", help="Check that reconciliation artifacts exist and have a next batch.")
    parser.add_argument("--user-complete-through")
    parser.add_argument("--user-likely-complete", action="append", default=[])
    parser.add_argument("--write-state", action="store_true", help="Update docs/codex/IOS26_FLAGSHIP_EXECUTION_STATE.yml.")
    parser.add_argument("--runner-plan", action="store_true", help="Print tab-separated skip/run plan for the shell runner.")
    parser.add_argument("--start-at")
    parser.add_argument("--complete-through")
    parser.add_argument("--skip-completed", action="store_true")
    args = parser.parse_args()

    if args.check:
        missing = [path for path in [REPORT_MD, REPORT_JSON, STATE_FILE] if not path.exists()]
        if missing:
            for path in missing:
                print(f"RED: missing {rel(path)}")
            return 1
        data = json.loads(REPORT_JSON.read_text(encoding="utf-8"))
        if not data.get("recommended_start_at"):
            print("RED: missing recommended_start_at")
            return 1
        print(f"GREEN: IOS26 execution state reconcile check passed recommended_start_at={data['recommended_start_at']}")
        return 0

    report = reconcile(args.user_complete_through, args.user_likely_complete)
    if args.runner_plan:
        print_runner_plan(report, args.start_at, args.complete_through, args.skip_completed)
        return 0
    write_report(report)
    if args.write_state:
        STATE_FILE.write_text(render_state(report), encoding="utf-8")
    status = "YELLOW" if report["counts"].get("user_reported_complete_unproven", 0) else "GREEN"
    print(f"{status}: IOS26 execution state reconciled recommended_start_at={report['recommended_start_at']}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
