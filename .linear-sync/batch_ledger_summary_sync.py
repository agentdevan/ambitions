#!/usr/bin/env python3
from __future__ import annotations

import json
import os
import sys
import urllib.error
import urllib.request
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]

LEDGER_JSON = ROOT / "docs" / "ops" / "batch-ledger" / "batch-ledger.json"
CONFLICT_JSON = ROOT / "docs" / "ops" / "batch-ledger" / "conflict-report.json"
SUMMARY_REPORT_MD = ROOT / "docs" / "ops" / "batch-ledger" / "linear-summary-sync-report.md"
SUMMARY_REPORT_JSON = ROOT / "docs" / "ops" / "batch-ledger" / "linear-summary-sync-report.json"

LINEAR_ENDPOINT = "https://api.linear.app/graphql"
SYNC_KEY_PREFIX = "ambitions-batch-ledger-summary"

LOCAL_ENV_FILES = (
    ROOT / ".env.local",
    ROOT / ".linear-sync" / ".env",
    ROOT / ".linear-sync" / ".env.local",
)

SUMMARY_KEYS = [
    "batch-ledger-summary",
    "conflict-report-summary",
    "red-high-priority-conflict-summary",
    "source-only-missing-proof-summary",
    "active-ios26-sequence-summary",
]

ARTIFACT_PATHS = [
    "docs/ops/batch-ledger/batch-ledger.json",
    "docs/ops/batch-ledger/batch-ledger.md",
    "docs/ops/batch-ledger/touchpoint-report.md",
    "docs/ops/batch-ledger/implementation-proof-status-report.md",
    "docs/ops/batch-ledger/conflict-report.md",
    "docs/ops/batch-ledger/conflict-report.json",
    "docs/ops/batch-ledger/linear-summary-sync-report.md",
    "docs/ops/batch-ledger/linear-summary-sync-report.json",
]


@dataclass
class SummaryRecord:
    key: str
    title: str
    priority: int
    description: str


def rel(path: Path) -> str:
    try:
        return path.relative_to(ROOT).as_posix()
    except ValueError:
        return path.as_posix()


def load_local_env() -> list[str]:
    loaded: list[str] = []
    for path in LOCAL_ENV_FILES:
        if not path.exists():
            continue

        for line in path.read_text(encoding="utf-8").splitlines():
            stripped = line.strip()
            if not stripped or stripped.startswith("#") or "=" not in stripped:
                continue

            key, value = stripped.split("=", 1)
            key = key.strip()
            value = value.strip().strip("'\"")

            if not key or key in os.environ:
                continue

            os.environ[key] = value

        loaded.append(rel(path))

    return loaded


def load_json(path: Path) -> dict[str, Any]:
    if not path.exists():
        raise FileNotFoundError(f"missing required artifact: {rel(path)}")
    text = path.read_text(encoding="utf-8")
    if not text.strip():
        raise ValueError(f"empty required artifact: {rel(path)}")
    return json.loads(text)


def graphql(token: str, query: str, variables: dict[str, Any]) -> dict[str, Any]:
    payload = json.dumps({"query": query, "variables": variables}).encode("utf-8")
    request = urllib.request.Request(
        LINEAR_ENDPOINT,
        data=payload,
        headers={
            "Authorization": token,
            "Content-Type": "application/json",
        },
        method="POST",
    )

    try:
        with urllib.request.urlopen(request, timeout=30) as response:
            body = response.read().decode("utf-8")
    except urllib.error.HTTPError as exc:
        body = exc.read().decode("utf-8", errors="replace")
        raise RuntimeError(f"Linear API HTTP {exc.code}: {body[:1000]}") from exc

    payload = json.loads(body)
    if payload.get("errors"):
        raise RuntimeError(json.dumps(payload["errors"], indent=2))

    return payload["data"]


def label_ids_for(labels: list[str]) -> list[str]:
    raw = os.environ.get("LINEAR_LABEL_IDS_JSON")
    if not raw:
        return []
    try:
        mapping = json.loads(raw)
    except json.JSONDecodeError:
        return []
    if not isinstance(mapping, dict):
        return []
    return [str(mapping[label]) for label in labels if label in mapping]


def find_existing(token: str, team_id: str, sync_key: str) -> list[dict[str, Any]]:
    query = """
    query ExistingSummaryIssues($teamId: ID!, $syncKey: String!) {
      issues(
        filter: {
          team: { id: { eq: $teamId } }
          description: { contains: $syncKey }
        }
        first: 20
      ) {
        nodes { id identifier title description url }
      }
    }
    """
    data = graphql(token, query, {"teamId": team_id, "syncKey": sync_key})
    return data["issues"]["nodes"]


def create_issue(token: str, team_id: str, project_id: str | None, record: SummaryRecord) -> dict[str, Any]:
    mutation = """
    mutation CreateSummaryIssue($input: IssueCreateInput!) {
      issueCreate(input: $input) {
        success
        issue { id identifier title url }
      }
    }
    """
    issue_input: dict[str, Any] = {
        "teamId": team_id,
        "title": record.title,
        "description": record.description,
        "priority": record.priority,
    }

    if project_id:
        issue_input["projectId"] = project_id

    labels = label_ids_for(["area: batch-ledger", "area: process"])
    if labels:
        issue_input["labelIds"] = labels

    data = graphql(token, mutation, {"input": issue_input})
    return data["issueCreate"]["issue"]


def update_issue(token: str, issue_id: str, project_id: str | None, record: SummaryRecord) -> dict[str, Any]:
    mutation = """
    mutation UpdateSummaryIssue($id: String!, $input: IssueUpdateInput!) {
      issueUpdate(id: $id, input: $input) {
        success
        issue { id identifier title url }
      }
    }
    """
    issue_input: dict[str, Any] = {
        "title": record.title,
        "description": record.description,
        "priority": record.priority,
    }

    if project_id:
        issue_input["projectId"] = project_id

    labels = label_ids_for(["area: batch-ledger", "area: process"])
    if labels:
        issue_input["labelIds"] = labels

    data = graphql(token, mutation, {"id": issue_id, "input": issue_input})
    return data["issueUpdate"]["issue"]


def bullet_counts(counts: dict[str, Any]) -> str:
    if not counts:
        return "- None"
    lines = []
    for key, value in sorted(counts.items()):
        lines.append(f"- `{key}`: `{value}`")
    return "\n".join(lines)


def artifact_links() -> str:
    return "\n".join(f"- `{path}`" for path in ARTIFACT_PATHS)


def non_claims() -> str:
    return "\n".join(
        [
            "- Linear status is not repo truth.",
            "- Batch ledger sync is summary-level only.",
            "- Summary sync does not prove implementation, build, tests, accessibility, performance, device, privacy, legal, TestFlight, App Store, or release readiness.",
            "- Full row-level detail remains in repo artifacts.",
        ]
    )


def header(sync_key: str, title: str) -> list[str]:
    return [
        f"<!-- AMB_BATCH_LEDGER_SUMMARY_SYNC_KEY: {sync_key} -->",
        "",
        f"# {title}",
        "",
        "Generated from repo-owned batch ledger artifacts.",
        "",
    ]


def build_batch_ledger_summary(ledger: dict[str, Any], conflict: dict[str, Any]) -> SummaryRecord:
    key = f"{SYNC_KEY_PREFIX}:batch-ledger-summary"
    counts = ledger.get("counts", {})
    amb26 = ledger.get("amb26_touchpoints", {})
    amb27 = ledger.get("amb27_status_classification", {})
    amb28 = ledger.get("amb28_conflict_report", {})

    lines = header(key, "Batch Ledger Summary")
    lines.extend(
        [
            "## Repo artifacts",
            "",
            artifact_links(),
            "",
            "## Ledger counts",
            "",
            f"- Total items: `{counts.get('total', len(ledger.get('items', [])))}`",
            f"- Unknown first-added dates: `{counts.get('unknown_dates', 'unknown')}`",
            f"- Duplicate stable IDs: `{counts.get('duplicate_stable_ids', 'unknown')}`",
            "",
            "## Item types",
            "",
            bullet_counts(counts.get("by_item_type", {})),
            "",
            "## AMB-26 touchpoints",
            "",
            f"- Status: `{amb26.get('status', 'unknown')}`",
            f"- Unknown surface count: `{amb26.get('unknown_surface_count', 'unknown')}`",
            f"- Unknown system count: `{amb26.get('unknown_system_count', 'unknown')}`",
            f"- Validation command item count: `{amb26.get('validation_command_item_count', 'unknown')}`",
            f"- Proof path item count: `{amb26.get('proof_path_item_count', 'unknown')}`",
            "",
            "## AMB-27 implementation/proof status",
            "",
            f"- Status: `{amb27.get('status', 'unknown')}`",
            "- Implementation status counts:",
            bullet_counts(amb27.get("implementation_status_counts", {})),
            "- Proof state counts:",
            bullet_counts(amb27.get("proof_state_counts", {})),
            "",
            "## AMB-28 conflict summary",
            "",
            f"- Status: `{amb28.get('status', conflict.get('status', 'unknown'))}`",
            f"- Total conflicts: `{conflict.get('summary', {}).get('total', 'unknown')}`",
            f"- Auto-resolved conflicts: `{conflict.get('summary', {}).get('auto_resolved', 'unknown')}`",
            "",
            "## No-claim boundary",
            "",
            non_claims(),
        ]
    )

    return SummaryRecord(
        key=key,
        title="Batch ledger summary",
        priority=2,
        description="\n".join(lines),
    )


def build_conflict_report_summary(conflict: dict[str, Any]) -> SummaryRecord:
    key = f"{SYNC_KEY_PREFIX}:conflict-report-summary"
    summary = conflict.get("summary", {})

    lines = header(key, "Conflict Report Summary")
    lines.extend(
        [
            "## Repo artifact",
            "",
            "- `docs/ops/batch-ledger/conflict-report.md`",
            "- `docs/ops/batch-ledger/conflict-report.json`",
            "",
            "## Summary",
            "",
            f"- Status: `{conflict.get('status', 'unknown')}`",
            f"- Total conflicts: `{summary.get('total', 'unknown')}`",
            f"- Auto-resolved conflicts: `{summary.get('auto_resolved', 'unknown')}`",
            "",
            "## Conflicts by type",
            "",
            bullet_counts(summary.get("by_type", {})),
            "",
            "## Recommended actions",
            "",
            bullet_counts(summary.get("by_recommended_action", {})),
            "",
            "## No-claim boundary",
            "",
            non_claims(),
        ]
    )

    return SummaryRecord(
        key=key,
        title="Batch ledger conflict summary",
        priority=2,
        description="\n".join(lines),
    )


def build_red_conflict_summary(conflict: dict[str, Any]) -> SummaryRecord:
    key = f"{SYNC_KEY_PREFIX}:red-high-priority-conflict-summary"
    conflicts = conflict.get("conflicts", [])
    red = [entry for entry in conflicts if entry.get("severity") == "red"]
    high_priority = [
        entry for entry in conflicts
        if entry.get("severity") == "red"
        or entry.get("recommended_action") in {"rewrite", "finish"}
    ]

    lines = header(key, "Red / High-Priority Conflict Summary")
    lines.extend(
        [
            "## Repo artifact",
            "",
            "- `docs/ops/batch-ledger/conflict-report.md`",
            "- `docs/ops/batch-ledger/conflict-report.json`",
            "",
            "## Counts",
            "",
            f"- Red conflicts: `{len(red)}`",
            f"- Red or high-priority conflicts: `{len(high_priority)}`",
            "",
            "## Top red/high-priority conflicts",
            "",
        ]
    )

    for entry in high_priority[:50]:
        involved = entry.get("involved", [])
        first = involved[0] if involved else {}
        lines.extend(
            [
                f"- `{entry.get('conflict_id', 'unknown')}` — {entry.get('title', 'untitled')}",
                f"  - Type: `{entry.get('conflict_type', 'unknown')}`",
                f"  - Severity: `{entry.get('severity', 'unknown')}`",
                f"  - Recommended action: `{entry.get('recommended_action', 'unknown')}`",
                f"  - First involved: `{first.get('stable_id', 'unknown')}` — `{first.get('repo_path', 'unknown')}`",
            ]
        )

    if len(high_priority) > 50:
        lines.append(f"- ... {len(high_priority) - 50} more in `docs/ops/batch-ledger/conflict-report.json`")

    lines.extend(
        [
            "",
            "## No-claim boundary",
            "",
            non_claims(),
        ]
    )

    return SummaryRecord(
        key=key,
        title="Batch ledger red/high-priority conflicts",
        priority=1 if red else 2,
        description="\n".join(lines),
    )


def build_source_only_missing_proof_summary(ledger: dict[str, Any], conflict: dict[str, Any]) -> SummaryRecord:
    key = f"{SYNC_KEY_PREFIX}:source-only-missing-proof-summary"
    items = ledger.get("items", [])
    source_only = [
        item for item in items
        if item.get("implementation_status") == "partial_implementation"
        and item.get("amb27_proof_state") in {"source-only", "none", "audit"}
        and item.get("item_type") in {"batch", "prompt", "train"}
    ]

    conflicts = [
        entry for entry in conflict.get("conflicts", [])
        if entry.get("conflict_type") == "source_only_implementation_missing_proof"
    ]

    lines = header(key, "Source-Only / Missing-Proof Summary")
    lines.extend(
        [
            "## Repo artifacts",
            "",
            "- `docs/ops/batch-ledger/implementation-proof-status-report.md`",
            "- `docs/ops/batch-ledger/conflict-report.md`",
            "- `docs/ops/batch-ledger/batch-ledger.json`",
            "",
            "## Counts",
            "",
            f"- Source-only/missing-proof ledger items: `{len(source_only)}`",
            f"- Source-only/missing-proof conflicts: `{len(conflicts)}`",
            "",
            "## Top items",
            "",
        ]
    )

    for item in source_only[:60]:
        lines.extend(
            [
                f"- `{item.get('stable_id', 'unknown')}` — `{item.get('repo_path', 'unknown')}`",
                f"  - Implementation: `{item.get('implementation_status', 'unknown')}`",
                f"  - Proof: `{item.get('amb27_proof_state', 'unknown')}`",
                f"  - Rationale: {item.get('implementation_status_rationale', 'none')}",
            ]
        )

    if len(source_only) > 60:
        lines.append(f"- ... {len(source_only) - 60} more in `docs/ops/batch-ledger/batch-ledger.json`")

    lines.extend(
        [
            "",
            "## No-claim boundary",
            "",
            non_claims(),
        ]
    )

    return SummaryRecord(
        key=key,
        title="Batch ledger source-only / missing-proof summary",
        priority=1 if source_only else 3,
        description="\n".join(lines),
    )


def build_active_ios26_summary(ledger: dict[str, Any]) -> SummaryRecord:
    key = f"{SYNC_KEY_PREFIX}:active-ios26-sequence-summary"
    items = ledger.get("items", [])

    ios26 = [
        item for item in items
        if "IOS26" in str(item.get("stable_id", ""))
        or "IOS26" in str(item.get("repo_path", ""))
        or "ios26" in str(item.get("repo_path", "")).lower()
    ]

    active_ios26 = [
        item for item in ios26
        if item.get("implementation_status") not in {"canceled", "retired", "superseded"}
        and item.get("current_status") not in {"canceled", "retired", "superseded", "historical"}
    ]

    status_counts = {}
    for item in active_ios26:
        status = item.get("implementation_status", "unknown")
        status_counts[status] = status_counts.get(status, 0) + 1

    lines = header(key, "Active IOS26 Sequence Summary")
    lines.extend(
        [
            "## Repo artifacts",
            "",
            "- `docs/codex/GLOBAL_BATCH_SEQUENCE.md`",
            "- `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`",
            "- `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`",
            "- `docs/ops/batch-ledger/batch-ledger.json`",
            "",
            "## Counts",
            "",
            f"- IOS26-related ledger items: `{len(ios26)}`",
            f"- Active IOS26-related ledger items: `{len(active_ios26)}`",
            "",
            "## Active IOS26 implementation statuses",
            "",
            bullet_counts(status_counts),
            "",
            "## Top active IOS26 items",
            "",
        ]
    )

    for item in active_ios26[:80]:
        lines.extend(
            [
                f"- `{item.get('stable_id', 'unknown')}` — `{item.get('repo_path', 'unknown')}`",
                f"  - Current status: `{item.get('current_status', 'unknown')}`",
                f"  - Implementation: `{item.get('implementation_status', 'unknown')}`",
                f"  - Proof: `{item.get('amb27_proof_state', 'unknown')}`",
            ]
        )

    if len(active_ios26) > 80:
        lines.append(f"- ... {len(active_ios26) - 80} more in `docs/ops/batch-ledger/batch-ledger.json`")

    lines.extend(
        [
            "",
            "## No-claim boundary",
            "",
            non_claims(),
        ]
    )

    return SummaryRecord(
        key=key,
        title="Batch ledger active IOS26 sequence summary",
        priority=2,
        description="\n".join(lines),
    )


def build_records(ledger: dict[str, Any], conflict: dict[str, Any]) -> list[SummaryRecord]:
    return [
        build_batch_ledger_summary(ledger, conflict),
        build_conflict_report_summary(conflict),
        build_red_conflict_summary(conflict),
        build_source_only_missing_proof_summary(ledger, conflict),
        build_active_ios26_summary(ledger),
    ]


def write_reports(status: str, rows: list[str], yellow: list[str], records: list[SummaryRecord]) -> None:
    now = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")

    payload = {
        "schema_version": 1,
        "generated_utc": now,
        "owner": "BATCH-LEDGER-001",
        "linear_issue": "AMB-37",
        "status": status,
        "summary_record_count": len(records),
        "summary_keys": [record.key for record in records],
        "results": rows,
        "yellow": yellow,
        "deletes": "never",
        "bulk_issue_creation": "disabled",
        "non_claims": [
            "Linear status is not repo truth.",
            "Summary sync is not row-level ledger sync.",
            "This sync report does not prove implementation, build, tests, accessibility, performance, device, privacy, legal, TestFlight, App Store, or release readiness.",
        ],
    }

    SUMMARY_REPORT_JSON.write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")

    lines = [
        "# Batch Ledger Linear Summary Sync Report",
        "",
        f"Status: {status}",
        f"Generated UTC: {now}",
        "Owner: BATCH-LEDGER-001",
        "Linear issue: AMB-37",
        "Deletes: never",
        "Bulk issue creation: disabled",
        "",
        "## Summary records",
        "",
    ]

    for record in records:
        lines.append(f"- `{record.key}` — {record.title}")

    lines.extend(["", "## Results", ""])
    lines.extend(rows or ["- No writes attempted"])

    lines.extend(["", "## Yellow", ""])
    lines.extend(yellow or ["- None"])

    lines.extend(
        [
            "",
            "## Non-claims",
            "",
            "- Linear status is not repo truth.",
            "- Summary sync is not row-level ledger sync.",
            "- This sync report does not prove implementation, build, tests, accessibility, performance, device, privacy, legal, TestFlight, App Store, or release readiness.",
            "",
        ]
    )

    SUMMARY_REPORT_MD.write_text("\n".join(lines), encoding="utf-8")


def main() -> int:
    loaded_env = load_local_env()
    ledger = load_json(LEDGER_JSON)
    conflict = load_json(CONFLICT_JSON)
    records = build_records(ledger, conflict)

    rows = []
    yellow = []

    if loaded_env:
        rows.append("- Loaded local Linear config from " + ", ".join(f"`{path}`" for path in loaded_env))

    token = os.environ.get("LINEAR_API_KEY") or os.environ.get("LINEAR_TOKEN")
    team_id = os.environ.get("LINEAR_TEAM_ID")
    project_id = os.environ.get("LINEAR_PROJECT_ID_BATCH_LEDGER") or os.environ.get("LINEAR_PROJECT_ID")
    allow_writes = os.environ.get("BATCH_LEDGER_LINEAR_ALLOW_WRITES") == "1"
    create_limit = int(os.environ.get("BATCH_LEDGER_LINEAR_CREATE_LIMIT", "0"))

    if not token:
        yellow.append("Missing LINEAR_API_KEY or LINEAR_TOKEN")
    if not team_id:
        yellow.append("Missing LINEAR_TEAM_ID")
    if not allow_writes:
        yellow.append("BATCH_LEDGER_LINEAR_ALLOW_WRITES=1 is required before create/update calls")
    if not project_id:
        yellow.append("Missing LINEAR_PROJECT_ID_BATCH_LEDGER or LINEAR_PROJECT_ID")

    if len(records) != 5:
        yellow.append(f"Expected exactly 5 summary records, found {len(records)}")

    if yellow:
        rows.extend(f"- Planned only `{record.key}` -> `{record.title}`" for record in records)
        write_reports("YELLOW", rows, yellow, records)
        print(f"YELLOW: wrote {rel(SUMMARY_REPORT_MD)}")
        print("linear writes: none")
        return 0

    assert token is not None
    assert team_id is not None

    created = 0
    result_rows: list[str] = rows[:]
    unsafe_yellow: list[str] = []

    for record in records:
        existing = find_existing(token, team_id, record.key)

        if len(existing) > 1:
            unsafe_yellow.append(f"Multiple existing Linear issues for `{record.key}`; skipped unsafe update")
            continue

        if len(existing) == 1:
            issue = update_issue(token, existing[0]["id"], project_id, record)
            result_rows.append(f"- Updated `{record.key}` -> {issue['identifier']} {issue['url']}")
            continue

        if created >= create_limit:
            result_rows.append(
                f"- Planned only `{record.key}` -> `{record.title}`; create skipped by BATCH_LEDGER_LINEAR_CREATE_LIMIT={create_limit}"
            )
            continue

        issue = create_issue(token, team_id, project_id, record)
        created += 1
        result_rows.append(f"- Created `{record.key}` -> {issue['identifier']} {issue['url']}")

    status = "YELLOW" if unsafe_yellow else "GREEN"
    write_reports(status, result_rows, unsafe_yellow, records)

    print(f"{status}: wrote {rel(SUMMARY_REPORT_MD)}")
    print("linear deletes: none")
    print("summary records:", len(records))
    print("created:", created)
    print("unsafe_yellow:", len(unsafe_yellow))

    return 0 if status == "GREEN" else 2


if __name__ == "__main__":
    raise SystemExit(main())
