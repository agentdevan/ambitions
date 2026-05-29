#!/usr/bin/env python3
from __future__ import annotations

import json
from collections import Counter, defaultdict
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]

LEDGER_JSON = ROOT / "docs/ops/batch-ledger/batch-ledger.json"
CONFLICT_JSON = ROOT / "docs/ops/batch-ledger/conflict-report.json"
WORKFLOW = ROOT / "docs/ops/batch-ledger/conflict-action-workflow.md"
HISTORICAL_POLICY = ROOT / "docs/truth/HISTORICAL_POLICY.md"
CODEX_PROCESS_TRUTH = ROOT / "docs/truth/CODEX_PROCESS_TRUTH.md"

OUT_DIR = ROOT / "docs/ops/canon-collapse"
OUT_MD = OUT_DIR / "active-canon-collapse-candidates.md"
OUT_JSON = OUT_DIR / "active-canon-collapse-candidates.json"
SOURCE_ONLY_RESOLUTION_JSON = ROOT / "docs/ops/canon-collapse/source-only-proof-resolution.json"

ACTIVE_ITEM_TYPES = {"batch", "prompt", "train"}
NON_ACTIVE_CURRENT_STATUSES = {"canceled", "retired", "superseded", "historical"}
NON_ACTIVE_IMPLEMENTATION_STATUSES = {"canceled", "retired", "superseded"}

ACTION_MAP = {
    "retire": "Retire",
    "expedite": "Expedite",
    "merge": "Merge",
    "rewrite": "Rewrite",
    "finish": "Finish proof",
    "finish proof": "Finish proof",
    "cancel": "Cancel",
    "keep_planned": "Keep planned",
    "keep planned": "Keep planned",
}

ACTION_RANK = {
    "Rewrite": 0,
    "Finish proof": 1,
    "Merge": 2,
    "Expedite": 3,
    "Retire": 4,
    "Cancel": 5,
    "Keep planned": 6,
}

CONFLICT_RANK = {
    "retired_ia_or_terminology_reference": 0,
    "source_only_implementation_missing_proof": 1,
    "duplicate_stable_id": 2,
    "same_source_file_targeted_by_multiple_active_batches": 3,
    "same_surface_multiple_active_batches": 4,
    "missing_source_of_truth_reference": 5,
    "stale_or_unknown_active_status": 6,
}

REQUIRED_READ_ORDER = [
    "docs/truth/README.md",
    "docs/truth/PRODUCT_DESIGN_TRUTH.md",
    "docs/truth/PRODUCT_MOAT_TRUTH.md",
    "docs/truth/IMPLEMENTATION_TRUTH.md",
    "docs/truth/RELEASE_TRUTH.md",
    "docs/truth/CODEX_PROCESS_TRUTH.md",
    "docs/truth/HISTORICAL_POLICY.md",
    "docs/ops/batch-ledger/batch-ledger.json",
    "docs/ops/batch-ledger/conflict-report.json",
    "docs/ops/batch-ledger/conflict-action-workflow.md",
    "docs/ops/change-protocol/change-request-template.md",
    "docs/ops/change-protocol/change-impact-check.md",
    "docs/ops/change-protocol/implementation-prompt-template.md",
    "docs/ops/change-protocol/post-implementation-proof-reconciliation.md",
]


def rel(path: Path) -> str:
    return path.relative_to(ROOT).as_posix()



def load_resolved_source_only_ids() -> set[str]:
    if not SOURCE_ONLY_RESOLUTION_JSON.exists():
        return set()
    try:
        payload = json.loads(SOURCE_ONLY_RESOLUTION_JSON.read_text(encoding="utf-8"))
    except Exception:
        return set()
    if payload.get("status") != "GREEN":
        return set()
    return set(payload.get("resolved_conflict_ids", []))


def load_json(path: Path) -> dict[str, Any]:
    if not path.exists():
        raise FileNotFoundError(f"missing required artifact: {rel(path)}")
    text = path.read_text(encoding="utf-8")
    if not text.strip():
        raise ValueError(f"empty required artifact: {rel(path)}")
    return json.loads(text)


def read_text(path: Path) -> str:
    if not path.exists():
        return ""
    return path.read_text(encoding="utf-8", errors="ignore")


def normalize_action(action: str) -> str:
    key = (action or "").strip().lower()
    return ACTION_MAP.get(key, action or "Expedite")


def ledger_index(ledger: dict[str, Any]) -> dict[tuple[str, str], dict[str, Any]]:
    index = {}
    for item in ledger.get("items", []):
        stable_id = item.get("stable_id", "")
        repo_path = item.get("repo_path", "")
        if stable_id or repo_path:
            index[(stable_id, repo_path)] = item
    return index


def item_active_from_fields(item: dict[str, Any]) -> bool:
    if not item:
        return False
    if item.get("item_type") not in ACTIVE_ITEM_TYPES:
        return False
    if item.get("current_status") in NON_ACTIVE_CURRENT_STATUSES:
        return False
    if item.get("implementation_status") in NON_ACTIVE_IMPLEMENTATION_STATUSES:
        return False
    return True


def item_historical_only(item: dict[str, Any]) -> bool:
    if not item:
        return False
    if item.get("current_status") in {"historical", "retired", "superseded", "canceled"}:
        return True
    if item.get("implementation_status") in {"retired", "superseded", "canceled"}:
        return True
    if item.get("proof_state") == "historical_only" or item.get("amb27_proof_state") == "historical_only":
        return True
    return False


def lookup_item(index: dict[tuple[str, str], dict[str, Any]], involved: dict[str, Any]) -> dict[str, Any]:
    stable_id = involved.get("stable_id", "")
    repo_path = involved.get("repo_path", "")
    exact = index.get((stable_id, repo_path))
    if exact:
        return exact

    if stable_id:
        for (sid, _), item in index.items():
            if sid == stable_id:
                return item

    if repo_path:
        for (_, path), item in index.items():
            if path == repo_path:
                return item

    return {}


def classify_conflict_activity(conflict: dict[str, Any], index: dict[tuple[str, str], dict[str, Any]]) -> tuple[str, list[dict[str, Any]], list[dict[str, Any]]]:
    active = []
    historical = []

    for involved in conflict.get("involved", []):
        item = lookup_item(index, involved)
        material = item or involved
        if item_active_from_fields(item):
            active.append(material)
        elif item_historical_only(item):
            historical.append(material)
        else:
            # If lookup failed, preserve as inactive/unknown rather than treating as active.
            historical.append(material)

    if active:
        return "active", active, historical
    return "historical_only", active, historical


def candidate_reason(conflict: dict[str, Any], action: str, active_items: list[dict[str, Any]]) -> str:
    ctype = conflict.get("conflict_type", "unknown")

    if ctype == "retired_ia_or_terminology_reference":
        return "Active item contains retired IA, retired terminology, or unsafe language; rewrite or retire before reuse."
    if ctype == "missing_source_of_truth_reference":
        return "Active item lacks required source-of-truth references; rewrite before implementation use."
    if ctype == "source_only_implementation_missing_proof":
        return "Active item is partial/source-only/missing-proof; finish proof before treating as complete."
    if ctype == "duplicate_stable_id":
        return "Duplicate stable ID appears in active work; merge, namespace, or retire duplicate authority."
    if ctype == "same_source_file_targeted_by_multiple_active_batches":
        return "Multiple active work items target the same source file; merge or sequence ownership before implementation."
    if ctype == "same_surface_multiple_active_batches":
        return "Multiple active work items target the same surface; expedite owner/sequence decision before more work."
    if ctype == "stale_or_unknown_active_status":
        return "Active item status is unknown or stale; expedite clarification before implementation depends on it."
    if action == "Retire":
        return "Candidate appears obsolete or superseded but still active enough to require explicit retirement handling."
    if action == "Keep planned":
        return "Candidate may remain planned only if evidence confirms it does not block active sequence."
    return "Candidate requires bounded owner decision before canon cleanup or implementation proceeds."


def involved_refs(items: list[dict[str, Any]]) -> list[dict[str, Any]]:
    refs = []
    for item in items:
        refs.append(
            {
                "stable_id": item.get("stable_id", "unknown"),
                "repo_path": item.get("repo_path", "unknown"),
                "item_type": item.get("item_type", "unknown"),
                "current_status": item.get("current_status", "unknown"),
                "implementation_status": item.get("implementation_status", "unknown"),
                "proof_state": item.get("amb27_proof_state", item.get("proof_state", "unknown")),
                "touched_surfaces": item.get("touched_surfaces", []),
                "touched_systems": item.get("touched_systems", []),
            }
        )
    return refs


def build_candidates(ledger: dict[str, Any], conflict_payload: dict[str, Any]) -> tuple[list[dict[str, Any]], list[dict[str, Any]]]:
    index = ledger_index(ledger)
    active_candidates = []
    historical_residue = []

    resolved_source_only_ids = load_resolved_source_only_ids()

    for conflict in conflict_payload.get("conflicts", []):
        if conflict.get("conflict_type") == "source_only_implementation_missing_proof" and conflict.get("conflict_id") in resolved_source_only_ids:
            continue
        activity, active_items, historical_items = classify_conflict_activity(conflict, index)
        action = normalize_action(conflict.get("recommended_action", "Expedite"))

        base = {
            "conflict_id": conflict.get("conflict_id", "unknown"),
            "conflict_type": conflict.get("conflict_type", "unknown"),
            "severity": conflict.get("severity", "unknown"),
            "recommended_action": action,
            "linear_issue_ready": bool(conflict.get("linear_issue_ready", False)),
            "auto_resolved": bool(conflict.get("auto_resolved", False)),
            "title": conflict.get("title", "untitled"),
            "evidence_type": conflict.get("conflict_type", "unknown"),
            "evidence": conflict.get("evidence", {}),
            "repo_paths": sorted(
                {
                    item.get("repo_path", "unknown")
                    for item in active_items if item.get("repo_path")
                }
            ),
        }

        if activity == "active":
            active_candidates.append(
                {
                    **base,
                    "activity": "active",
                    "reason": candidate_reason(conflict, action, active_items),
                    "involved": involved_refs(active_items),
                    "historical_related": involved_refs(historical_items),
                }
            )
        else:
            historical_residue.append(
                {
                    **base,
                    "activity": "historical_only",
                    "reason": "Historical/non-forward residue retained for traceability; not active by default.",
                    "involved": involved_refs(historical_items),
                    "historical_related": involved_refs(historical_items),
                }
            )

    active_candidates.sort(
        key=lambda item: (
            item["severity"] != "red",
            ACTION_RANK.get(item["recommended_action"], 99),
            CONFLICT_RANK.get(item["conflict_type"], 99),
            item["conflict_id"],
        )
    )
    historical_residue.sort(
        key=lambda item: (
            CONFLICT_RANK.get(item["conflict_type"], 99),
            item["conflict_id"],
        )
    )

    return active_candidates, historical_residue


def choose_next_bundle(candidates: list[dict[str, Any]]) -> dict[str, Any]:
    if not candidates:
        return {
            "bundle_id": "none",
            "title": "No active canon-collapse candidates detected",
            "recommended_action": "Keep planned",
            "reason": "No active candidate bundle is required from current evidence.",
            "candidate_count": 0,
            "candidate_ids": [],
            "repo_paths": [],
        }

    red_rewrite = [
        c for c in candidates
        if c["severity"] == "red" and c["recommended_action"] == "Rewrite"
    ]
    finish_proof = [
        c for c in candidates
        if c["recommended_action"] == "Finish proof"
    ]
    merge = [
        c for c in candidates
        if c["recommended_action"] == "Merge"
    ]
    missing_truth_rewrite = [
        c for c in candidates
        if c["conflict_type"] == "missing_source_of_truth_reference"
    ]

    if red_rewrite:
        selected = red_rewrite
        return bundle_from_candidates(
            "canon-collapse-red-rewrite-bundle",
            "Rewrite active Red retired IA / terminology references",
            "Rewrite",
            "Red retired IA/terminology references should be resolved before broader canon cleanup.",
            selected,
        )

    if finish_proof:
        selected = finish_proof[:100]
        return bundle_from_candidates(
            "canon-collapse-finish-proof-bundle",
            "Finish proof for active source-only / missing-proof items",
            "Finish proof",
            "Source-only or missing-proof work cannot be treated as complete.",
            selected,
        )

    if merge:
        selected = merge[:100]
        return bundle_from_candidates(
            "canon-collapse-merge-overlap-bundle",
            "Merge or sequence overlapping active canon/work ownership",
            "Merge",
            "Duplicate and overlapping active work should be merged or sequenced before implementation.",
            selected,
        )

    selected = missing_truth_rewrite[:100] if missing_truth_rewrite else candidates[:100]
    return bundle_from_candidates(
        "canon-collapse-authority-rewrite-bundle",
        "Rewrite active items missing source-of-truth references",
        "Rewrite",
        "Active items missing source-of-truth references should be rewritten before future implementation use.",
        selected,
    )


def bundle_from_candidates(bundle_id: str, title: str, action: str, reason: str, selected: list[dict[str, Any]]) -> dict[str, Any]:
    repo_paths = []
    candidate_ids = []
    for item in selected:
        candidate_ids.append(item["conflict_id"])
        repo_paths.extend(item.get("repo_paths", []))
        for involved in item.get("involved", []):
            path = involved.get("repo_path")
            if path:
                repo_paths.append(path)

    return {
        "bundle_id": bundle_id,
        "title": title,
        "recommended_action": action,
        "reason": reason,
        "candidate_count": len(selected),
        "candidate_ids": candidate_ids,
        "repo_paths": sorted(set(repo_paths)),
    }


def validate_payload(payload: dict[str, Any]) -> list[str]:
    errors = []

    for path in [LEDGER_JSON, CONFLICT_JSON, WORKFLOW, HISTORICAL_POLICY, CODEX_PROCESS_TRUTH, OUT_MD, OUT_JSON]:
        if not path.exists():
            errors.append(f"missing required artifact: {rel(path)}")

    for candidate in payload.get("active_candidates", []):
        if not candidate.get("conflict_id"):
            errors.append("candidate missing conflict_id")
        if not candidate.get("recommended_action"):
            errors.append(f"{candidate.get('conflict_id', 'unknown')}: missing recommended_action")
        if candidate.get("activity") != "active":
            errors.append(f"{candidate.get('conflict_id', 'unknown')}: active candidate not marked active")
        if not candidate.get("involved"):
            errors.append(f"{candidate.get('conflict_id', 'unknown')}: missing involved active item refs")
        if candidate.get("auto_resolved"):
            errors.append(f"{candidate.get('conflict_id', 'unknown')}: candidate was auto-resolved")

    for residue in payload.get("historical_only_residue", []):
        if residue.get("activity") != "historical_only":
            errors.append(f"{residue.get('conflict_id', 'unknown')}: residue not marked historical_only")

    next_bundle = payload.get("next_bounded_action_bundle", {})
    if not next_bundle.get("bundle_id"):
        errors.append("missing next bounded action bundle")

    return errors


def write_markdown(payload: dict[str, Any]) -> None:
    summary = payload["summary"]
    bundle = payload["next_bounded_action_bundle"]

    lines = [
        "# Active Canon Collapse Candidates",
        "",
        f"Status: {payload['status']}",
        f"Generated UTC: {payload['generated_utc']}",
        "Owner: CANON-COLLAPSE-002",
        "Linear issue: AMB-286",
        "",
        "## Purpose",
        "",
        "This report identifies evidence-backed active canon cleanup candidates from repo truth, the batch ledger, and conflict reports.",
        "",
        "This report does not modify canon, source code, prompts, trains, or Linear. It does not delete or archive anything.",
        "",
        "## Required read order",
        "",
    ]

    for item in REQUIRED_READ_ORDER:
        lines.append(f"- `{item}`")

    lines.extend(
        [
            "",
            "## Summary",
            "",
            f"- Active candidates: `{summary['active_candidate_count']}`",
            f"- Historical-only residue: `{summary['historical_only_residue_count']}`",
            f"- Red active candidates: `{summary['red_active_candidate_count']}`",
            f"- Auto-resolved candidates: `{summary['auto_resolved_candidate_count']}`",
            "",
            "### Active candidates by action",
            "",
        ]
    )

    for action, count in summary["active_by_action"].items():
        lines.append(f"- `{action}`: `{count}`")

    lines.extend(["", "### Active candidates by conflict type", ""])

    for ctype, count in summary["active_by_conflict_type"].items():
        lines.append(f"- `{ctype}`: `{count}`")

    lines.extend(
        [
            "",
            "## Next bounded action bundle",
            "",
            f"- Bundle ID: `{bundle['bundle_id']}`",
            f"- Title: {bundle['title']}",
            f"- Recommended action: `{bundle['recommended_action']}`",
            f"- Candidate count: `{bundle['candidate_count']}`",
            f"- Reason: {bundle['reason']}",
            "",
            "### Bundle candidate IDs",
            "",
        ]
    )

    for cid in bundle.get("candidate_ids", [])[:80]:
        lines.append(f"- `{cid}`")

    if len(bundle.get("candidate_ids", [])) > 80:
        lines.append(f"- ... {len(bundle['candidate_ids']) - 80} more in JSON")

    lines.extend(["", "### Bundle repo paths", ""])

    for path in bundle.get("repo_paths", [])[:120]:
        lines.append(f"- `{path}`")

    if len(bundle.get("repo_paths", [])) > 120:
        lines.append(f"- ... {len(bundle['repo_paths']) - 120} more in JSON")

    lines.extend(
        [
            "",
            "## Active candidates",
            "",
        ]
    )

    for index, candidate in enumerate(payload["active_candidates"][:300], 1):
        lines.append(f"### {index}. {candidate['title']}")
        lines.append("")
        lines.append(f"- Candidate ID: `{candidate['conflict_id']}`")
        lines.append(f"- Evidence type: `{candidate['evidence_type']}`")
        lines.append(f"- Severity: `{candidate['severity']}`")
        lines.append(f"- Recommended action: `{candidate['recommended_action']}`")
        lines.append(f"- Linear-ready: `{candidate['linear_issue_ready']}`")
        lines.append(f"- Auto-resolved: `{candidate['auto_resolved']}`")
        lines.append(f"- Reason: {candidate['reason']}")
        lines.append("- Involved active paths:")
        for involved in candidate.get("involved", [])[:10]:
            lines.append(
                f"  - `{involved.get('stable_id', 'unknown')}` — `{involved.get('repo_path', 'unknown')}` "
                f"({involved.get('implementation_status', 'unknown')}; {involved.get('proof_state', 'unknown')})"
            )
        if len(candidate.get("involved", [])) > 10:
            lines.append(f"  - ... {len(candidate['involved']) - 10} more")
        lines.append("")

    if len(payload["active_candidates"]) > 300:
        lines.append(f"- ... {len(payload['active_candidates']) - 300} more active candidates in JSON")

    lines.extend(
        [
            "",
            "## Historical-only residue",
            "",
            "Historical-only residue is retained for traceability and must not become active by default.",
            "",
        ]
    )

    for residue in payload["historical_only_residue"][:120]:
        lines.append(
            f"- `{residue['conflict_id']}` — `{residue['conflict_type']}` — `{residue['recommended_action']}`"
        )

    if len(payload["historical_only_residue"]) > 120:
        lines.append(f"- ... {len(payload['historical_only_residue']) - 120} more in JSON")

    lines.extend(
        [
            "",
            "## Non-claims",
            "",
            "- This report does not modify canon.",
            "- This report does not modify source code.",
            "- This report does not modify prompts or trains.",
            "- This report does not delete or archive anything.",
            "- This report does not create one issue per candidate.",
            "- This report does not prove implementation, build, tests, accessibility, performance, device, privacy, legal, TestFlight, App Store, or release readiness.",
            "- Linear status is not repo truth.",
            "",
        ]
    )

    OUT_MD.write_text("\n".join(lines), encoding="utf-8")


def main() -> int:
    OUT_DIR.mkdir(parents=True, exist_ok=True)

    ledger = load_json(LEDGER_JSON)
    conflict_payload = load_json(CONFLICT_JSON)

    # Touch/read policy files so missing authority fails visibly.
    read_text(HISTORICAL_POLICY)
    read_text(CODEX_PROCESS_TRUTH)
    read_text(WORKFLOW)

    active_candidates, historical_residue = build_candidates(ledger, conflict_payload)
    next_bundle = choose_next_bundle(active_candidates)

    summary = {
        "active_candidate_count": len(active_candidates),
        "historical_only_residue_count": len(historical_residue),
        "red_active_candidate_count": sum(1 for c in active_candidates if c.get("severity") == "red"),
        "auto_resolved_candidate_count": sum(1 for c in active_candidates if c.get("auto_resolved")),
        "active_by_action": dict(sorted(Counter(c["recommended_action"] for c in active_candidates).items())),
        "active_by_conflict_type": dict(sorted(Counter(c["conflict_type"] for c in active_candidates).items())),
        "historical_by_conflict_type": dict(sorted(Counter(c["conflict_type"] for c in historical_residue).items())),
    }

    status = "GREEN"

    payload = {
        "schema_version": 1,
        "generated_utc": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "owner": "CANON-COLLAPSE-002",
        "linear_issue": "AMB-286",
        "status": status,
        "required_read_order": REQUIRED_READ_ORDER,
        "summary": summary,
        "next_bounded_action_bundle": next_bundle,
        "active_candidates": active_candidates,
        "historical_only_residue": historical_residue,
        "non_claims": [
            "This report does not modify canon.",
            "This report does not modify source code.",
            "This report does not modify prompts or trains.",
            "This report does not delete or archive anything.",
            "This report does not create one issue per candidate.",
            "This report does not prove implementation, build, tests, accessibility, performance, device, privacy, legal, TestFlight, App Store, or release readiness.",
            "Linear status is not repo truth.",
        ],
    }

    OUT_JSON.write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    write_markdown(payload)

    errors = validate_payload(payload)
    if errors:
        payload["status"] = "RED"
        payload["validation_errors"] = errors
        OUT_JSON.write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")
        write_markdown(payload)
        print("AMB-286 candidate report validation failed.")
        for error in errors:
            print(f"- {error}")
        return 1

    print(f"wrote {OUT_MD.relative_to(ROOT)}")
    print(f"wrote {OUT_JSON.relative_to(ROOT)}")
    print(f"status: {payload['status']}")
    print(f"active candidates: {summary['active_candidate_count']}")
    print(f"historical-only residue: {summary['historical_only_residue_count']}")
    print(f"next bundle: {next_bundle['bundle_id']}")
    print("AMB-286 canon collapse candidate report validation passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
