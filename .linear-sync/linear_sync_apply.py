#!/usr/bin/env python3
from __future__ import annotations

import importlib.util
import json
import os
import re
import sys
import urllib.error
import urllib.request
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
DRY_RUN_SCRIPT = ROOT / "scripts" / "ambitions-linear-sync-dry-run.py"
DRY_RUN_REPORT = ROOT / ".linear-sync" / "reports" / "latest-dry-run.md"
APPLY_REPORT = ROOT / ".linear-sync" / "reports" / "latest-apply.md"
SYNC_KEY_PREFIX = "ambitions-linear-sync"
LINEAR_ENDPOINT = "https://api.linear.app/graphql"


@dataclass
class SyncItem:
    key: str
    title: str
    rule_id: str
    classification: str
    project: str
    project_id: str | None
    labels: list[str]
    priority: int
    repo_paths: list[str]
    description: str


def rel(path: Path) -> str:
    try:
        return path.relative_to(ROOT).as_posix()
    except ValueError:
        return path.as_posix()


def load_dry_run_module() -> Any:
    spec = importlib.util.spec_from_file_location("linear_sync_dry_run", DRY_RUN_SCRIPT)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"cannot load {rel(DRY_RUN_SCRIPT)}")
    module = importlib.util.module_from_spec(spec)
    sys.modules[spec.name] = module
    spec.loader.exec_module(module)
    return module


def project_id_for(project: str) -> str | None:
    if "BATCH-LEDGER-001" in project:
        return os.environ.get("LINEAR_PROJECT_ID_BATCH_LEDGER") or os.environ.get("LINEAR_PROJECT_ID")
    if "OPS-SYNC-001" in project:
        return os.environ.get("LINEAR_PROJECT_ID_OPS_SYNC") or os.environ.get("LINEAR_PROJECT_ID")
    return os.environ.get("LINEAR_PROJECT_ID")


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


def priority_from(rule: Any) -> int:
    values: list[int] = []
    for value in getattr(rule, "priority_rules", {}).values():
        try:
            values.append(int(value))
        except (TypeError, ValueError):
            continue
    return min(values) if values else 3


def build_items() -> list[SyncItem]:
    module = load_dry_run_module()
    if not DRY_RUN_REPORT.exists():
        raise RuntimeError(f"missing dry-run report: {rel(DRY_RUN_REPORT)}")

    include_rules, exclude_rules = module.load_rules()
    files = module.git_files()
    paths_by_rule: dict[str, list[str]] = {rule.id: [] for rule in include_rules}
    for path in files:
        rule = module.classify(path, include_rules, exclude_rules)
        if rule is None or getattr(rule, "kind", "") != "include":
            continue
        paths_by_rule.setdefault(rule.id, []).append(path)

    items: list[SyncItem] = []
    for rule in include_rules:
        if not rule.create_work_items:
            continue
        key = f"{SYNC_KEY_PREFIX}:{rule.id}"
        repo_paths = sorted(paths_by_rule.get(rule.id, []))
        shown_paths = repo_paths[:40]
        omitted = max(0, len(repo_paths) - len(shown_paths))
        path_lines = [f"- `{path}`" for path in shown_paths]
        if omitted:
            path_lines.append(f"- ... {omitted} more")
        description = "\n".join(
            [
                f"<!-- AMB_LINEAR_SYNC_KEY: {key} -->",
                "",
                f"Repo sync rule: `{rule.id}`",
                f"Class: `{rule.classification}`",
                f"Project mapping: `{rule.project}`",
                "Labels: " + (", ".join(f"`{label}`" for label in rule.labels) or "`none`"),
                f"Priority: {priority_from(rule)}",
                "",
                "## Repo Paths",
                *(path_lines or ["- None"]),
                "",
                "## Source",
                f"- Manifest: `.linear-sync/ambitions-linear-sync.yml`",
                f"- Dry-run report: `.linear-sync/reports/latest-dry-run.md`",
                "",
                "## No-Claim Boundary",
                "- Linear status is not repo truth.",
                "- Source presence is not build, test, accessibility, performance, device, or release proof.",
                "- Historical paths do not become active work without repo truth promotion.",
            ]
        )
        items.append(
            SyncItem(
                key=key,
                title=f"Linear sync: {rule.id}",
                rule_id=rule.id,
                classification=rule.classification,
                project=rule.project,
                project_id=project_id_for(rule.project),
                labels=rule.labels,
                priority=priority_from(rule),
                repo_paths=repo_paths,
                description=description,
            )
        )
    return items


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
        raise RuntimeError(f"Linear API HTTP {exc.code}: {body[:500]}") from exc
    payload = json.loads(body)
    if payload.get("errors"):
        raise RuntimeError(json.dumps(payload["errors"], indent=2))
    return payload["data"]


def find_existing(token: str, team_id: str, sync_key: str) -> list[dict[str, Any]]:
    query = """
    query ExistingSyncIssues($teamId: String!, $syncKey: String!) {
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


def create_issue(token: str, team_id: str, item: SyncItem) -> dict[str, Any]:
    mutation = """
    mutation CreateSyncIssue($input: IssueCreateInput!) {
      issueCreate(input: $input) {
        success
        issue { id identifier title url }
      }
    }
    """
    issue_input: dict[str, Any] = {
        "teamId": team_id,
        "title": item.title,
        "description": item.description,
        "priority": item.priority,
    }
    if item.project_id:
        issue_input["projectId"] = item.project_id
    label_ids = label_ids_for(item.labels)
    if label_ids:
        issue_input["labelIds"] = label_ids
    data = graphql(token, mutation, {"input": issue_input})
    return data["issueCreate"]["issue"]


def update_issue(token: str, issue_id: str, item: SyncItem) -> dict[str, Any]:
    mutation = """
    mutation UpdateSyncIssue($id: String!, $input: IssueUpdateInput!) {
      issueUpdate(id: $id, input: $input) {
        success
        issue { id identifier title url }
      }
    }
    """
    issue_input: dict[str, Any] = {
        "title": item.title,
        "description": item.description,
        "priority": item.priority,
    }
    if item.project_id:
        issue_input["projectId"] = item.project_id
    label_ids = label_ids_for(item.labels)
    if label_ids:
        issue_input["labelIds"] = label_ids
    data = graphql(token, mutation, {"id": issue_id, "input": issue_input})
    return data["issueUpdate"]["issue"]


def write_report(status: str, rows: list[str], yellow: list[str]) -> None:
    now = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    APPLY_REPORT.parent.mkdir(parents=True, exist_ok=True)
    APPLY_REPORT.write_text(
        "\n".join(
            [
                "# Linear Sync Apply",
                "",
                f"Status: {status}",
                f"Generated UTC: {now}",
                "Deletes: never",
                "",
                "## Results",
                *(rows or ["- No writes attempted"]),
                "",
                "## Yellow",
                *(yellow or ["- None"]),
                "",
                "## Non-Claims",
                "- Linear status is not repo truth.",
                "- This apply report is not build, test, accessibility, performance, device, TestFlight, App Store, privacy, legal, or release proof.",
                "",
            ]
        ),
        encoding="utf-8",
    )


def main() -> int:
    items = build_items()
    rows = [f"- Planned sync item `{item.key}` -> `{item.title}` ({len(item.repo_paths)} paths)" for item in items]
    yellow: list[str] = []

    token = os.environ.get("LINEAR_API_KEY") or os.environ.get("LINEAR_TOKEN")
    team_id = os.environ.get("LINEAR_TEAM_ID")
    allow_writes = os.environ.get("LINEAR_SYNC_ALLOW_WRITES") == "1"

    missing = []
    if not token:
        missing.append("LINEAR_API_KEY or LINEAR_TOKEN")
    if not team_id:
        missing.append("LINEAR_TEAM_ID")
    if missing:
        yellow.append("Missing local Linear config: " + ", ".join(missing))
    if not allow_writes:
        yellow.append("LINEAR_SYNC_ALLOW_WRITES=1 is required before any create/update call")
    missing_project = sorted({item.project for item in items if not item.project_id})
    if allow_writes and missing_project:
        yellow.append("Missing project id config for: " + ", ".join(missing_project))

    if yellow:
        write_report("YELLOW", rows, yellow)
        print(f"YELLOW: wrote {rel(APPLY_REPORT)}")
        print("linear writes: none")
        return 0

    assert token is not None
    assert team_id is not None
    result_rows: list[str] = []
    for item in items:
        existing = find_existing(token, team_id, item.key)
        if len(existing) > 1:
            yellow.append(f"Multiple existing Linear issues for `{item.key}`; skipped unsafe update")
            continue
        if len(existing) == 1:
            issue = update_issue(token, existing[0]["id"], item)
            result_rows.append(f"- Updated `{item.key}` -> {issue['identifier']} {issue['url']}")
        else:
            issue = create_issue(token, team_id, item)
            result_rows.append(f"- Created `{item.key}` -> {issue['identifier']} {issue['url']}")

    status = "YELLOW" if yellow else "GREEN"
    write_report(status, result_rows, yellow)
    print(f"{status}: wrote {rel(APPLY_REPORT)}")
    print("linear deletes: none")
    return 0 if status == "GREEN" else 2


if __name__ == "__main__":
    raise SystemExit(main())
