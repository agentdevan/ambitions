#!/usr/bin/env python3
from __future__ import annotations

import json
import re
import subprocess
from collections import Counter, defaultdict
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]

LEDGER_JSON = ROOT / "docs" / "ops" / "batch-ledger" / "batch-ledger.json"
CONFLICT_MD = ROOT / "docs" / "ops" / "batch-ledger" / "conflict-report.md"
CONFLICT_JSON = ROOT / "docs" / "ops" / "batch-ledger" / "conflict-report.json"

ACTIVE_ITEM_TYPES = {"batch", "prompt", "train"}
NON_ACTIVE_STATUSES = {"canceled", "retired", "superseded", "historical"}
NON_ACTIVE_IMPL_STATUSES = {"canceled", "retired", "superseded"}

RETIRED_IA_TERMS = [
    ("Plan tab", "old_ia_language"),
    ("Profile tab", "old_ia_language"),
    ("Captures tab", "old_ia_language"),
    ("Insights tab", "old_ia_language"),
    ("Habits tab", "old_ia_language"),
    ("Momentum tab", "old_ia_language"),
]

RETIRED_TERMS = [
    ("next best move", "retired_product_language"),
    ("best next move", "retired_product_language"),
    ("Begin Focus", "retired_product_language"),
    ("Start Focus", "retired_product_language"),
    ("Hero Step Panel", "retired_internal_ui_label"),
    ("overdue", "shaming_or_deprecated_state_language"),
    ("failed", "shaming_or_deprecated_state_language"),
    ("streak", "pressure_language"),
    ("productivity score", "pressure_language"),
    ("AI recommends", "cloud_ai_or_generic_ai_framing"),
    ("dashboard", "generic_dashboard_language"),
]

ACTION_VALUES = {"retire", "expedite", "finish", "merge", "rewrite"}

REPORT_LIMIT_PER_SECTION = 500


def run(cmd: list[str], *, check: bool = True) -> str:
    proc = subprocess.run(
        cmd,
        cwd=ROOT,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )
    if check and proc.returncode != 0:
        raise RuntimeError(
            f"command failed: {' '.join(cmd)}\nstdout:\n{proc.stdout}\nstderr:\n{proc.stderr}"
        )
    return proc.stdout.strip()


def read_text(path: str) -> str:
    try:
        return (ROOT / path).read_text(encoding="utf-8", errors="ignore")
    except Exception:
        return ""


def load_ledger() -> dict[str, Any]:
    if not LEDGER_JSON.exists():
        raise FileNotFoundError(f"missing {LEDGER_JSON.relative_to(ROOT)}")
    text = LEDGER_JSON.read_text(encoding="utf-8")
    if not text.strip():
        raise ValueError(f"{LEDGER_JSON.relative_to(ROOT)} is empty")
    payload = json.loads(text)
    if "items" not in payload or not isinstance(payload["items"], list):
        raise ValueError("batch-ledger.json missing items[]")
    return payload


def active_item(item: dict[str, Any]) -> bool:
    if item.get("item_type") not in ACTIVE_ITEM_TYPES:
        return False
    if item.get("current_status") in NON_ACTIVE_STATUSES:
        return False
    if item.get("implementation_status") in NON_ACTIVE_IMPL_STATUSES:
        return False
    return True


def item_ref(item: dict[str, Any]) -> dict[str, Any]:
    return {
        "stable_id": item.get("stable_id", "unknown"),
        "repo_path": item.get("repo_path", "unknown"),
        "item_type": item.get("item_type", "unknown"),
        "current_status": item.get("current_status", "unknown"),
        "implementation_status": item.get("implementation_status", "unknown"),
        "proof_state": item.get("amb27_proof_state", item.get("proof_state", "unknown")),
    }


def make_conflict(
    conflict_type: str,
    title: str,
    involved: list[dict[str, Any]],
    recommendation: str,
    rationale: str,
    severity: str = "yellow",
    evidence: dict[str, Any] | None = None,
) -> dict[str, Any]:
    if recommendation not in ACTION_VALUES:
        raise ValueError(f"invalid recommendation: {recommendation}")

    normalized = [item_ref(item) for item in involved]
    return {
        "conflict_id": f"AMB28-{conflict_type}-{abs(hash((title, tuple(i['repo_path'] for i in normalized)))) % 100000000}",
        "conflict_type": conflict_type,
        "severity": severity,
        "title": title,
        "involved": normalized,
        "recommended_action": recommendation,
        "recommendation_rationale": rationale,
        "linear_issue_ready": True,
        "auto_resolved": False,
        "evidence": evidence or {},
    }


def group_by_surface(items: list[dict[str, Any]]) -> list[dict[str, Any]]:
    surface_to_items: dict[str, list[dict[str, Any]]] = defaultdict(list)

    for item in items:
        for surface in item.get("touched_surfaces") or ["unknown"]:
            if surface != "unknown":
                surface_to_items[surface].append(item)

    conflicts = []
    for surface, entries in sorted(surface_to_items.items()):
        if len(entries) < 2:
            continue

        # Only report as conflict when multiple active work orders touch the surface.
        recommendation = "merge" if len(entries) <= 12 else "expedite"
        rationale = (
            "Multiple active ledger items touch the same surface; review sequence ownership and merge overlapping work."
            if recommendation == "merge"
            else "Many active ledger items touch the same surface; expedite sequence ownership through batch-ledger planning before running more work."
        )

        conflicts.append(
            make_conflict(
                "same_surface_multiple_active_batches",
                f"Same surface touched by multiple active items: {surface}",
                entries,
                recommendation,
                rationale,
                severity="yellow",
                evidence={"surface": surface, "active_item_count": len(entries)},
            )
        )

    return conflicts


def group_by_touched_file(items: list[dict[str, Any]]) -> list[dict[str, Any]]:
    file_to_items: dict[str, list[dict[str, Any]]] = defaultdict(list)

    for item in items:
        for touched_file in item.get("touched_files") or []:
            if touched_file and touched_file != "unknown":
                file_to_items[touched_file].append(item)

    conflicts = []
    for touched_file, entries in sorted(file_to_items.items()):
        if len(entries) < 2:
            continue

        conflicts.append(
            make_conflict(
                "same_source_file_targeted_by_multiple_active_batches",
                f"Same source file targeted by multiple active items: {touched_file}",
                entries,
                "merge",
                "Multiple active ledger items reference the same source file; merge, sequence, or assign ownership before implementation.",
                severity="yellow",
                evidence={"touched_file": touched_file, "active_item_count": len(entries)},
            )
        )

    return conflicts


def retired_language_conflicts(items: list[dict[str, Any]]) -> list[dict[str, Any]]:
    conflicts = []

    for item in items:
        text = "\n".join(
            [
                str(item.get("stable_id", "")),
                str(item.get("title", "")),
                str(item.get("repo_path", "")),
                read_text(item.get("repo_path", ""))[:120000],
            ]
        )

        matches = []
        for term, category in RETIRED_IA_TERMS + RETIRED_TERMS:
            if re.search(re.escape(term), text, flags=re.IGNORECASE):
                matches.append({"term": term, "category": category})

        if not matches:
            continue

        severity = "red" if any(m["category"] == "old_ia_language" for m in matches) else "yellow"
        conflicts.append(
            make_conflict(
                "retired_ia_or_terminology_reference",
                f"Retired IA/terminology reference in {item.get('stable_id', 'unknown')}",
                [item],
                "rewrite",
                "Retired IA or product language should be rewritten or explicitly quarantined before this work becomes active.",
                severity=severity,
                evidence={"matches": matches},
            )
        )

    return conflicts


def missing_source_truth_conflicts(items: list[dict[str, Any]]) -> list[dict[str, Any]]:
    conflicts = []

    for item in items:
        source_docs = item.get("source_of_truth_docs") or []
        item_type = item.get("item_type")
        status = item.get("implementation_status", item.get("current_status"))

        if item_type not in ACTIVE_ITEM_TYPES:
            continue
        if status in NON_ACTIVE_IMPL_STATUSES:
            continue

        if source_docs:
            continue

        conflicts.append(
            make_conflict(
                "missing_source_of_truth_reference",
                f"Missing source-of-truth references in {item.get('stable_id', 'unknown')}",
                [item],
                "rewrite",
                "Active batch/prompt/train should cite governing truth or authority files before execution.",
                severity="yellow",
                evidence={"source_of_truth_docs": source_docs},
            )
        )

    return conflicts


def source_only_missing_proof_conflicts(items: list[dict[str, Any]]) -> list[dict[str, Any]]:
    conflicts = []

    for item in items:
        implementation_status = item.get("implementation_status")
        proof_state = item.get("amb27_proof_state", item.get("proof_state"))
        item_type = item.get("item_type")

        if item_type not in ACTIVE_ITEM_TYPES:
            continue

        is_source_only = proof_state in {"source-only", "none", "audit"}
        is_partial = implementation_status in {"partial_implementation", "unknown"}

        if not (is_source_only and is_partial):
            continue

        recommendation = "finish" if proof_state == "source-only" else "expedite"
        rationale = (
            "Source-only item needs focused proof before it can be considered implemented."
            if recommendation == "finish"
            else "Missing or weak proof should be triaged before execution proceeds."
        )

        conflicts.append(
            make_conflict(
                "source_only_implementation_missing_proof",
                f"Source-only or missing-proof implementation state: {item.get('stable_id', 'unknown')}",
                [item],
                recommendation,
                rationale,
                severity="yellow",
                evidence={
                    "implementation_status": implementation_status,
                    "proof_state": proof_state,
                    "proof_paths": item.get("proof_paths") or [],
                },
            )
        )

    return conflicts


def duplicate_stable_id_conflicts(items: list[dict[str, Any]]) -> list[dict[str, Any]]:
    by_id: dict[str, list[dict[str, Any]]] = defaultdict(list)

    for item in items:
        stable_id = item.get("stable_id")
        if stable_id:
            by_id[stable_id].append(item)

    conflicts = []
    for stable_id, entries in sorted(by_id.items()):
        if len(entries) < 2:
            continue

        active_entries = [item for item in entries if active_item(item)]
        if not active_entries:
            continue

        conflicts.append(
            make_conflict(
                "duplicate_stable_id",
                f"Duplicate stable ID: {stable_id}",
                entries,
                "merge",
                "Duplicate stable IDs must be merged, namespaced, retired, or explicitly classified before Linear sync.",
                severity="yellow",
                evidence={"stable_id": stable_id, "item_count": len(entries), "active_item_count": len(active_entries)},
            )
        )

    return conflicts


def stale_unknown_conflicts(items: list[dict[str, Any]]) -> list[dict[str, Any]]:
    conflicts = []

    for item in items:
        if item.get("item_type") not in ACTIVE_ITEM_TYPES:
            continue

        if item.get("implementation_status") != "unknown":
            continue

        conflicts.append(
            make_conflict(
                "stale_or_unknown_active_status",
                f"Unknown active status: {item.get('stable_id', 'unknown')}",
                [item],
                "expedite",
                "Unknown active batch/prompt/train status should be clarified before it blocks or duplicates future work.",
                severity="yellow",
                evidence={"implementation_status": "unknown"},
            )
        )

    return conflicts


def summarize(conflicts: list[dict[str, Any]]) -> dict[str, Any]:
    return {
        "total": len(conflicts),
        "by_type": dict(sorted(Counter(c["conflict_type"] for c in conflicts).items())),
        "by_severity": dict(sorted(Counter(c["severity"] for c in conflicts).items())),
        "by_recommended_action": dict(sorted(Counter(c["recommended_action"] for c in conflicts).items())),
        "auto_resolved": sum(1 for c in conflicts if c.get("auto_resolved")),
    }


def validate(conflicts: list[dict[str, Any]]) -> list[str]:
    errors = []

    for conflict in conflicts:
        conflict_id = conflict.get("conflict_id", "unknown")
        involved = conflict.get("involved")

        if not involved:
            errors.append(f"{conflict_id}: missing involved items")

        for item in involved or []:
            if not item.get("stable_id"):
                errors.append(f"{conflict_id}: involved item missing stable_id")
            if not item.get("repo_path"):
                errors.append(f"{conflict_id}: involved item missing repo_path")

        if conflict.get("recommended_action") not in ACTION_VALUES:
            errors.append(f"{conflict_id}: invalid recommended_action {conflict.get('recommended_action')}")

        if conflict.get("auto_resolved") is not False:
            errors.append(f"{conflict_id}: conflict was auto-resolved or lacks explicit auto_resolved=false")

        if conflict.get("linear_issue_ready") is not True:
            errors.append(f"{conflict_id}: recommendation is not Linear issue ready")

    return errors


def write_json(conflicts: list[dict[str, Any]], summary: dict[str, Any], errors: list[str]) -> None:
    payload = {
        "schema_version": 1,
        "generated_utc": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "owner": "BATCH-LEDGER-001",
        "linear_issue": "AMB-28",
        "status": "green" if not errors else "red",
        "summary": summary,
        "validation_errors": errors,
        "conflicts": conflicts,
        "non_claims": [
            "Conflicts are reported, not auto-resolved.",
            "Recommended actions are proposed Linear-ready work, not execution.",
            "Linear status is not repo truth.",
            "This report does not prove build, tests, accessibility, performance, device, privacy, legal, TestFlight, App Store, or release readiness.",
        ],
    }

    CONFLICT_JSON.write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")


def involved_lines(conflict: dict[str, Any], limit: int | None = None) -> list[str]:
    lines = []
    involved = conflict.get("involved") or []
    shown = involved if limit is None else involved[:limit]

    for item in shown:
        lines.append(
            f"  - `{item.get('stable_id', 'unknown')}` — `{item.get('repo_path', 'unknown')}` "
            f"({item.get('implementation_status', 'unknown')}; {item.get('proof_state', 'unknown')})"
        )

    if limit is not None and len(involved) > limit:
        lines.append(f"  - ... {len(involved) - limit} more")

    return lines


def write_section(lines: list[str], title: str, conflicts: list[dict[str, Any]], detail_limit: int = 25) -> None:
    lines.extend(["", f"## {title}", ""])

    if not conflicts:
        lines.append("- None detected.")
        return

    for index, conflict in enumerate(conflicts[:REPORT_LIMIT_PER_SECTION], 1):
        lines.append(f"### {index}. {conflict['title']}")
        lines.append("")
        lines.append(f"- Conflict ID: `{conflict['conflict_id']}`")
        lines.append(f"- Type: `{conflict['conflict_type']}`")
        lines.append(f"- Severity: `{conflict['severity']}`")
        lines.append(f"- Recommended action: `{conflict['recommended_action']}`")
        lines.append(f"- Rationale: {conflict['recommendation_rationale']}")
        lines.append(f"- Linear issue ready: `{conflict['linear_issue_ready']}`")
        lines.append(f"- Auto-resolved: `{conflict['auto_resolved']}`")
        lines.append("- Involved:")
        lines.extend(involved_lines(conflict, limit=detail_limit))
        lines.append("")

    if len(conflicts) > REPORT_LIMIT_PER_SECTION:
        lines.append(f"- ... {len(conflicts) - REPORT_LIMIT_PER_SECTION} more conflicts recorded in `docs/ops/batch-ledger/conflict-report.json`.")


def write_md(conflicts: list[dict[str, Any]], summary: dict[str, Any], errors: list[str]) -> None:
    by_type: dict[str, list[dict[str, Any]]] = defaultdict(list)
    for conflict in conflicts:
        by_type[conflict["conflict_type"]].append(conflict)

    generated_utc = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")

    lines = [
        "# Batch Duplicate-Work and Conflict Report",
        "",
        f"Generated UTC: {generated_utc}",
        "Owner: BATCH-LEDGER-001",
        "Linear issue: AMB-28",
        "",
        "## Status",
        "",
        f"- Validation: `{'green' if not errors else 'red'}`",
        f"- Total conflicts: `{summary['total']}`",
        f"- Auto-resolved conflicts: `{summary['auto_resolved']}`",
        "",
        "## Counts by conflict type",
        "",
    ]

    for key, value in summary["by_type"].items():
        lines.append(f"- `{key}`: `{value}`")

    lines.extend(["", "## Counts by recommended action", ""])

    for key, value in summary["by_recommended_action"].items():
        lines.append(f"- `{key}`: `{value}`")

    if errors:
        lines.extend(["", "## Validation errors", ""])
        for error in errors:
            lines.append(f"- {error}")

    write_section(
        lines,
        "Same surface touched by multiple active batches",
        by_type.get("same_surface_multiple_active_batches", []),
        detail_limit=40,
    )

    write_section(
        lines,
        "Same source file targeted by multiple active batches",
        by_type.get("same_source_file_targeted_by_multiple_active_batches", []),
        detail_limit=30,
    )

    write_section(
        lines,
        "Batches referencing retired IA or terminology",
        by_type.get("retired_ia_or_terminology_reference", []),
        detail_limit=10,
    )

    write_section(
        lines,
        "Batches missing source-of-truth references",
        by_type.get("missing_source_of_truth_reference", []),
        detail_limit=10,
    )

    write_section(
        lines,
        "Batches with source-only implementation and missing proof",
        by_type.get("source_only_implementation_missing_proof", []),
        detail_limit=10,
    )

    write_section(
        lines,
        "Duplicate stable IDs",
        by_type.get("duplicate_stable_id", []),
        detail_limit=20,
    )

    write_section(
        lines,
        "Stale or unknown active statuses",
        by_type.get("stale_or_unknown_active_status", []),
        detail_limit=10,
    )

    lines.extend(
        [
            "",
            "## Recommendation semantics",
            "",
            "- `retire`: remove from active execution or mark historical/superseded.",
            "- `expedite`: clarify priority/status/owner before downstream execution.",
            "- `finish`: add missing proof or complete the partially implemented work.",
            "- `merge`: combine duplicate or overlapping scopes into one authority/work item.",
            "- `rewrite`: update retired language, stale IA, or missing authority references.",
            "",
            "## Non-claims",
            "",
            "- This report does not auto-resolve any conflict.",
            "- Recommended actions are Linear-ready proposals, not execution.",
            "- Linear status is not repo truth.",
            "- This report does not prove build, tests, accessibility, performance, device, privacy, legal, TestFlight, App Store, or release readiness.",
            "",
        ]
    )

    CONFLICT_MD.write_text("\n".join(lines), encoding="utf-8")


def main() -> int:
    payload = load_ledger()
    items = payload["items"]

    active_items = [item for item in items if active_item(item)]

    conflicts: list[dict[str, Any]] = []
    conflicts.extend(group_by_surface(active_items))
    conflicts.extend(group_by_touched_file(active_items))
    conflicts.extend(retired_language_conflicts(active_items))
    conflicts.extend(missing_source_truth_conflicts(active_items))
    conflicts.extend(source_only_missing_proof_conflicts(active_items))
    conflicts.extend(duplicate_stable_id_conflicts(items))
    conflicts.extend(stale_unknown_conflicts(active_items))

    conflicts.sort(
        key=lambda c: (
            c["severity"] != "red",
            c["conflict_type"],
            c["recommended_action"],
            c["title"],
        )
    )

    summary = summarize(conflicts)
    errors = validate(conflicts)

    # Store AMB-28 summary in the main ledger without auto-resolving anything.
    payload["amb28_conflict_report"] = {
        "status": "green" if not errors else "red",
        "generated_utc": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "linear_issue": "AMB-28",
        "conflict_report_path": "docs/ops/batch-ledger/conflict-report.md",
        "conflict_report_json_path": "docs/ops/batch-ledger/conflict-report.json",
        "summary": summary,
        "validation_errors": errors,
        "auto_resolved": False,
        "recommended_actions": sorted(ACTION_VALUES),
    }

    LEDGER_JSON.write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    write_json(conflicts, summary, errors)
    write_md(conflicts, summary, errors)

    print(f"wrote {LEDGER_JSON.relative_to(ROOT)}")
    print(f"wrote {CONFLICT_MD.relative_to(ROOT)}")
    print(f"wrote {CONFLICT_JSON.relative_to(ROOT)}")
    print(f"active items: {len(active_items)}")
    print(f"conflicts: {summary['total']}")
    print(f"auto_resolved: {summary['auto_resolved']}")
    print(f"validation: {'green' if not errors else 'red'}")
    print("conflicts by type:")
    for key, value in summary["by_type"].items():
        print(f"  {key}: {value}")
    print("recommended actions:")
    for key, value in summary["by_recommended_action"].items():
        print(f"  {key}: {value}")

    if errors:
        for error in errors[:100]:
            print(f"ERROR: {error}")
        if len(errors) > 100:
            print(f"... {len(errors) - 100} more errors")
        return 1

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
