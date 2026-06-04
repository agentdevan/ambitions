#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import os
import re
from collections import Counter, defaultdict
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]

LEDGER_JSON = ROOT / "docs/ops/batch-ledger/batch-ledger.json"
CONFLICT_JSON = ROOT / "docs/ops/batch-ledger/conflict-report.json"
ACTION_POLICY = ROOT / "docs/ops/batch-ledger" / ("conflict-action-" "work" "flow.md")
CHANGE_TEMPLATE = ROOT / "docs/ops/change-protocol/change-request-template.md"

OUT_MD = ROOT / "docs/ops/change-protocol/change-impact-check.md"
OUT_JSON = ROOT / "docs/ops/change-protocol/change-impact-check.json"

TRUTH_DOCS = [
    "docs/truth/README.md",
    "docs/truth/PRODUCT_DESIGN_TRUTH.md",
    "docs/truth/PRODUCT_MOAT_TRUTH.md",
    "docs/truth/IMPLEMENTATION_TRUTH.md",
    "docs/truth/RELEASE_TRUTH.md",
    "docs/truth/CODEX_PROCESS_TRUTH.md",
    "docs/truth/HISTORICAL_POLICY.md",
    "docs/codex/GLOBAL_BATCH_SEQUENCE.md",
    "docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json",
    "docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml",
    "docs/ops/batch-ledger/batch-ledger.json",
    "docs/ops/batch-ledger/conflict-report.json",
    "docs/ops/batch-ledger/conflict-action-" "work" "flow.md",
    "docs/ops/change-protocol/change-request-template.md",
]

SURFACES = {"Today", "Goals", "Capture", "Time", "Motion", "You", "Global", "None", "Unknown"}
SYSTEMS = {
    "IA",
    "chrome",
    "shell",
    "frontend",
    "runtime",
    "persistence",
    "privacy",
    "accessibility",
    "monetization",
    "branding",
    "proof",
    "release",
    "Linear",
    "Codex",
    "repo hygiene",
    "None",
    "Unknown",
}

ACTION_VALUES = {"Retire", "Expedite", "Merge", "Rewrite", "Finish proof", "Cancel", "Keep planned"}

RETIRED_LANGUAGE = [
    "Plan tab",
    "Profile tab",
    "Captures tab",
    "Capture tab",
    "Pulse",
    "Habits tab",
    "Insights tab",
    "Momentum tab",
    "next best move",
    "best next move",
    "Begin Focus",
    "Start Focus",
    "overdue",
    "failed",
    "streak",
    "productivity score",
    "dashboard",
]

CANON_TAG_TO_FILES = {
    "product-design-truth": ["docs/truth/PRODUCT_DESIGN_TRUTH.md"],
    "product-moat-truth": ["docs/truth/PRODUCT_MOAT_TRUTH.md"],
    "implementation-truth": ["docs/truth/IMPLEMENTATION_TRUTH.md"],
    "release-truth": ["docs/truth/RELEASE_TRUTH.md"],
    "codex-process-truth": ["docs/truth/CODEX_PROCESS_TRUTH.md"],
    "historical-policy": ["docs/truth/HISTORICAL_POLICY.md"],
    "ios26-sequence-authority": [
        "docs/codex/GLOBAL_BATCH_SEQUENCE.md",
        "docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json",
        "docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml",
    ],
    "batch-ledger": [
        "docs/ops/batch-ledger/batch-ledger.json",
        "docs/ops/batch-ledger/conflict-report.json",
        "docs/ops/batch-ledger/conflict-action-" "work" "flow.md",
    ],
    "linear-control-plane": [
        "docs/codex/LINEAR_CONTROL_PLANE.md",
        "docs/codex/REPO_INTELLIGENCE_CONTROL_PLANE.md",
    ],
    "change-protocol": [
        "docs/ops/change-protocol/change-request-template.md",
        "docs/ops/change-protocol/change-impact-check.md",
    ],
    "monetization-canon": ["docs/truth/PRODUCT_DESIGN_TRUTH.md"],
    "ia-canon": ["docs/truth/PRODUCT_DESIGN_TRUTH.md"],
    "runtime-canon": ["docs/truth/IMPLEMENTATION_TRUTH.md", "docs/truth/PRODUCT_MOAT_TRUTH.md"],
    "visual-canon": ["docs/truth/PRODUCT_DESIGN_TRUTH.md"],
    "proof-canon": ["docs/truth/RELEASE_TRUTH.md", "docs/truth/CODEX_PROCESS_TRUTH.md"],
}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Generate a canon-impact conflict check before installing implementation work."
    )
    parser.add_argument("--change-request", default=os.environ.get("CHANGE_REQUEST", ""))
    parser.add_argument("--source-of-truth-tags", default=os.environ.get("SOURCE_OF_TRUTH_TAGS", ""))
    parser.add_argument("--surfaces", default=os.environ.get("AFFECTED_SURFACES", ""))
    parser.add_argument("--systems", default=os.environ.get("AFFECTED_SYSTEMS", ""))
    parser.add_argument("--files", default=os.environ.get("AFFECTED_FILES", ""))
    parser.add_argument("--batch-path", default=os.environ.get("BATCH_PATH", ""))
    parser.add_argument("--linear-issue", default=os.environ.get("LINEAR_ISSUE", ""))
    parser.add_argument("--strict", action="store_true", default=os.environ.get("CHANGE_IMPACT_STRICT", "") == "1")
    return parser.parse_args()


def split_csv(value: str) -> list[str]:
    if not value:
        return []
    raw = re.split(r"[,;\n]", value)
    return [item.strip() for item in raw if item.strip()]


def load_json(path: Path, required: bool = True) -> dict[str, Any]:
    if not path.exists():
        if required:
            raise FileNotFoundError(f"missing {path.relative_to(ROOT)}")
        return {}
    text = path.read_text(encoding="utf-8")
    if not text.strip():
        if required:
            raise ValueError(f"empty {path.relative_to(ROOT)}")
        return {}
    return json.loads(text)


def read_text(path: str | Path) -> str:
    p = Path(path)
    if not p.is_absolute():
        p = ROOT / p
    try:
        return p.read_text(encoding="utf-8", errors="ignore")
    except Exception:
        return ""


def normalize_path(path: str) -> str:
    path = path.strip().strip("`").strip().strip(",.;")
    while path.startswith("./"):
        path = path[2:]
    return path


def parse_change_request(path: str) -> dict[str, Any]:
    if not path:
        return {}
    p = Path(path)
    if not p.is_absolute():
        p = ROOT / p
    if not p.exists():
        return {"missing_change_request": str(path)}

    text = read_text(p)
    result: dict[str, Any] = {"path": p.relative_to(ROOT).as_posix(), "raw_text": text}

    simple_keys = [
        "source_of_truth_tag",
        "owning_canon_file",
        "canon_file",
        "linear_issue",
        "implementation_prompt_or_batch",
    ]

    for key in simple_keys:
        match = re.search(rf"(?im)^\s*{re.escape(key)}:\s*(.+?)\s*$", text)
        if match:
            result[key] = match.group(1).strip()

    list_blocks = {
        "affected_surfaces": "surfaces",
        "affected_systems": "systems",
        "affected_active_batches": "active_batches",
        "affected_active_prompts": "active_prompts",
        "affected_active_trains": "active_trains",
        "affected_ledger_paths": "ledger_paths",
        "recommended_conflict_actions": "recommended_actions",
    }

    lines = text.splitlines()
    for source_key, dest_key in list_blocks.items():
        values: list[str] = []
        in_block = False
        for line in lines:
            if re.match(rf"^\s*{re.escape(source_key)}:\s*$", line):
                in_block = True
                continue
            if in_block:
                if re.match(r"^\s*[A-Za-z0-9_ -]+:\s*", line) and not line.strip().startswith("-"):
                    break
                m = re.match(r"^\s*-\s*(.+?)\s*$", line)
                if m:
                    values.append(m.group(1).strip())
        if values:
            result[dest_key] = values

    return result


def derive_inputs(args: argparse.Namespace) -> dict[str, Any]:
    parsed = parse_change_request(args.change_request)

    source_tags = split_csv(args.source_of_truth_tags)
    if not source_tags and parsed.get("source_of_truth_tag"):
        source_tags = split_csv(str(parsed["source_of_truth_tag"]))

    surfaces = split_csv(args.surfaces)
    if not surfaces and parsed.get("surfaces"):
        surfaces = list(parsed["surfaces"])

    systems = split_csv(args.systems)
    if not systems and parsed.get("systems"):
        systems = list(parsed["systems"])

    files = split_csv(args.files)
    if not files:
        for key in ["owning_canon_file", "canon_file", "implementation_prompt_or_batch"]:
            value = parsed.get(key)
            if value:
                files.append(str(value))
        files.extend(parsed.get("ledger_paths", []))

    batch_path = args.batch_path or str(parsed.get("implementation_prompt_or_batch", "") or "")
    linear_issue = args.linear_issue or str(parsed.get("linear_issue", "") or "")

    source_tags = [x for x in source_tags if x and x.lower() != "unchecked"]
    surfaces = [x for x in surfaces if x and x.lower() != "unchecked"]
    systems = [x for x in systems if x and x.lower() != "unchecked"]
    files = [normalize_path(x) for x in files if x and x.lower() != "unchecked"]

    if not source_tags:
        source_tags = ["Unknown"]
    if not surfaces:
        surfaces = ["Unknown"]
    if not systems:
        systems = ["Unknown"]

    return {
        "change_request": parsed,
        "change_request_path": args.change_request,
        "source_tags": source_tags,
        "surfaces": surfaces,
        "systems": systems,
        "files": files,
        "batch_path": normalize_path(batch_path) if batch_path else "",
        "linear_issue": linear_issue,
        "strict": args.strict,
    }


def canon_files_for_tags(tags: list[str]) -> list[str]:
    files: set[str] = set()
    for tag in tags:
        key = tag.strip()
        if key in CANON_TAG_TO_FILES:
            files.update(CANON_TAG_TO_FILES[key])
        elif key != "Unknown":
            for truth in TRUTH_DOCS:
                if key.lower() in truth.lower():
                    files.add(truth)
    return sorted(files)


def item_is_active(item: dict[str, Any]) -> bool:
    if item.get("item_type") not in {"batch", "prompt", "train"}:
        return False
    if item.get("current_status") in {"canceled", "retired", "superseded", "historical"}:
        return False
    if item.get("implementation_status") in {"canceled", "retired", "superseded"}:
        return False
    return True


def matches_item(item: dict[str, Any], inputs: dict[str, Any], canon_files: list[str]) -> tuple[bool, list[str]]:
    reasons: list[str] = []

    item_surfaces = set(item.get("touched_surfaces") or [])
    item_systems = set(item.get("touched_systems") or [])
    item_files = set(item.get("touched_files") or [])
    item_truth = set(item.get("source_of_truth_docs") or [])
    item_path = item.get("repo_path", "")

    surfaces = {s for s in inputs["surfaces"] if s != "Unknown" and s != "None"}
    systems = {s for s in inputs["systems"] if s != "Unknown" and s != "None"}
    files = {f for f in inputs["files"] if f}
    canon = set(canon_files)

    if surfaces and item_surfaces.intersection(surfaces):
        reasons.append("surface_overlap")
    if systems and item_systems.intersection(systems):
        reasons.append("system_overlap")
    if files and (item_files.intersection(files) or item_path in files):
        reasons.append("file_overlap")
    if canon and (item_truth.intersection(canon) or item_path in canon):
        reasons.append("canon_overlap")

    batch_path = inputs.get("batch_path")
    if batch_path and item_path == batch_path:
        reasons.append("same_batch_path")

    return bool(reasons), reasons


def conflict_involves_item(conflict: dict[str, Any], item: dict[str, Any]) -> bool:
    stable_id = item.get("stable_id")
    repo_path = item.get("repo_path")
    for involved in conflict.get("involved", []):
        if stable_id and involved.get("stable_id") == stable_id:
            return True
        if repo_path and involved.get("repo_path") == repo_path:
            return True
    return False


def retired_language_findings(paths: list[str], batch_path: str) -> list[dict[str, Any]]:
    findings = []
    checked = list(paths)
    if batch_path:
        checked.append(batch_path)

    for path in sorted(set(filter(None, checked))):
        text = read_text(path)
        if not text:
            continue
        matches = [term for term in RETIRED_LANGUAGE if re.search(re.escape(term), text, flags=re.IGNORECASE)]
        if matches:
            findings.append({"repo_path": path, "matches": matches})
    return findings


def build_impact(inputs: dict[str, Any]) -> dict[str, Any]:
    ledger = load_json(LEDGER_JSON)
    conflict_payload = load_json(CONFLICT_JSON)

    canon_files = canon_files_for_tags(inputs["source_tags"])

    active_items = [item for item in ledger.get("items", []) if item_is_active(item)]
    affected_items = []
    for item in active_items:
        matched, reasons = matches_item(item, inputs, canon_files)
        if matched:
            affected_items.append(
                {
                    "stable_id": item.get("stable_id", "unknown"),
                    "repo_path": item.get("repo_path", "unknown"),
                    "item_type": item.get("item_type", "unknown"),
                    "current_status": item.get("current_status", "unknown"),
                    "implementation_status": item.get("implementation_status", "unknown"),
                    "proof_state": item.get("amb27_proof_state", item.get("proof_state", "unknown")),
                    "touched_surfaces": item.get("touched_surfaces", []),
                    "touched_systems": item.get("touched_systems", []),
                    "match_reasons": reasons,
                }
            )

    affected_lookup = {(item["stable_id"], item["repo_path"]) for item in affected_items}
    relevant_conflicts = []
    for conflict in conflict_payload.get("conflicts", []):
        for involved in conflict.get("involved", []):
            key = (involved.get("stable_id"), involved.get("repo_path"))
            if key in affected_lookup:
                relevant_conflicts.append(conflict)
                break

    retired_findings = retired_language_findings(inputs["files"], inputs["batch_path"])

    missing_inputs = []
    if inputs["source_tags"] == ["Unknown"]:
        missing_inputs.append("source_of_truth_tags")
    if inputs["surfaces"] == ["Unknown"]:
        missing_inputs.append("affected_surfaces")
    if inputs["systems"] == ["Unknown"]:
        missing_inputs.append("affected_systems")
    if not inputs["linear_issue"]:
        missing_inputs.append("linear_issue")
    if not inputs["files"] and not inputs["batch_path"]:
        missing_inputs.append("affected_files_or_batch_path")

    high_conflicts = [
        conflict for conflict in relevant_conflicts
        if conflict.get("severity") == "red"
        or conflict.get("recommended_action") in {"rewrite", "finish", "merge", "expedite"}
    ]

    implementation_blocked = bool(missing_inputs or high_conflicts or retired_findings)

    status = "RED" if missing_inputs else "YELLOW" if implementation_blocked else "GREEN"

    recommended_actions = sorted(
        set(
            conflict.get("recommended_action", "")
            for conflict in relevant_conflicts
            if conflict.get("recommended_action")
        )
    )

    action_map = {
        "retire": "Retire",
        "expedite": "Expedite",
        "merge": "Merge",
        "rewrite": "Rewrite",
        "finish": "Finish proof",
        "cancel": "Cancel",
        "keep_planned": "Keep planned",
        "keep planned": "Keep planned",
    }

    normalized_actions = sorted(set(action_map.get(action, action) for action in recommended_actions))

    return {
        "schema_version": 1,
        "generated_utc": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "owner": "CHANGE-PROTOCOL-001",
        "linear_issue": "AMB-35",
        "status": status,
        "implementation_blocked": implementation_blocked,
        "missing_inputs": missing_inputs,
        "input": {
            "change_request_path": inputs["change_request_path"],
            "source_tags": inputs["source_tags"],
            "surfaces": inputs["surfaces"],
            "systems": inputs["systems"],
            "files": inputs["files"],
            "batch_path": inputs["batch_path"],
            "linear_issue": inputs["linear_issue"],
        },
        "affected_canon_files": canon_files,
        "affected_active_ledger_items": affected_items,
        "affected_active_item_count": len(affected_items),
        "relevant_conflicts": relevant_conflicts,
        "relevant_conflict_count": len(relevant_conflicts),
        "retired_or_conflicting_language": retired_findings,
        "required_actions": normalized_actions,
        "required_action_policy": "docs/ops/batch-ledger/conflict-action-" "work" "flow.md",
        "required_template": "docs/ops/change-protocol/change-request-template.md",
        "non_claims": [
            "Impact check output is not implementation proof.",
            "Impact check output is not build proof.",
            "Impact check output is not test proof.",
            "Impact check output is not accessibility proof.",
            "Impact check output is not release proof.",
            "Linear status is not repo truth.",
        ],
    }


def write_report(payload: dict[str, Any]) -> None:
    lines = [
        "# Change Impact Check",
        "",
        f"Status: {payload['status']}",
        f"Generated UTC: {payload['generated_utc']}",
        "Owner: CHANGE-PROTOCOL-001",
        "Linear issue: AMB-35",
        "",
        "## Implementation gate",
        "",
        f"- Implementation blocked: `{payload['implementation_blocked']}`",
        f"- Missing inputs: `{', '.join(payload['missing_inputs']) if payload['missing_inputs'] else 'none'}`",
        "",
        "## Inputs",
        "",
        f"- Change request: `{payload['input']['change_request_path'] or 'not_provided'}`",
        f"- Source-of-truth tags: `{', '.join(payload['input']['source_tags'])}`",
        f"- Affected surfaces: `{', '.join(payload['input']['surfaces'])}`",
        f"- Affected systems: `{', '.join(payload['input']['systems'])}`",
        f"- Affected files: `{', '.join(payload['input']['files']) if payload['input']['files'] else 'not_provided'}`",
        f"- Batch path: `{payload['input']['batch_path'] or 'not_provided'}`",
        f"- Linear issue: `{payload['input']['linear_issue'] or 'not_provided'}`",
        "",
        "## Affected canon files",
        "",
    ]

    if payload["affected_canon_files"]:
        for path in payload["affected_canon_files"]:
            lines.append(f"- `{path}`")
    else:
        lines.append("- None resolved.")

    lines.extend(
        [
            "",
            "## Affected active ledger items",
            "",
            f"Count: `{payload['affected_active_item_count']}`",
            "",
        ]
    )

    for item in payload["affected_active_ledger_items"][:120]:
        reasons = ", ".join(item["match_reasons"])
        lines.append(
            f"- `{item['stable_id']}` — `{item['repo_path']}` "
            f"({item['implementation_status']}; {item['proof_state']}; {reasons})"
        )

    if payload["affected_active_item_count"] > 120:
        lines.append(f"- ... {payload['affected_active_item_count'] - 120} more in change-impact-check.json")

    lines.extend(
        [
            "",
            "## Relevant conflicts before implementation",
            "",
            f"Count: `{payload['relevant_conflict_count']}`",
            "",
        ]
    )

    for conflict in payload["relevant_conflicts"][:120]:
        first = (conflict.get("involved") or [{}])[0]
        lines.append(f"- `{conflict.get('conflict_id', 'unknown')}` — {conflict.get('title', 'untitled')}")
        lines.append(f"  - Type: `{conflict.get('conflict_type', 'unknown')}`")
        lines.append(f"  - Severity: `{conflict.get('severity', 'unknown')}`")
        lines.append(f"  - Recommended action: `{conflict.get('recommended_action', 'unknown')}`")
        lines.append(f"  - First involved: `{first.get('stable_id', 'unknown')}` — `{first.get('repo_path', 'unknown')}`")

    if payload["relevant_conflict_count"] > 120:
        lines.append(f"- ... {payload['relevant_conflict_count'] - 120} more in change-impact-check.json")

    lines.extend(["", "## Retired or conflicting language findings", ""])

    if payload["retired_or_conflicting_language"]:
        for finding in payload["retired_or_conflicting_language"]:
            lines.append(f"- `{finding['repo_path']}`")
            for match in finding["matches"]:
                lines.append(f"  - `{match}`")
    else:
        lines.append("- None detected in provided files.")

    lines.extend(["", "## Required actions before implementation", ""])

    if payload["required_actions"]:
        for action in payload["required_actions"]:
            lines.append(f"- `{action}`")
    else:
        lines.append("- None from relevant conflicts.")

    lines.extend(
        [
            "",
            "## Required policy links",
            "",
            "- `docs/ops/change-protocol/change-request-template.md`",
            "- `docs/ops/batch-ledger/conflict-action-" "work" "flow.md`",
            "- `docs/ops/batch-ledger/conflict-report.json`",
            "- `docs/ops/batch-ledger/batch-ledger.json`",
            "",
            "## Non-claims",
            "",
        ]
    )

    for claim in payload["non_claims"]:
        lines.append(f"- {claim}")

    OUT_MD.write_text("\n".join(lines) + "\n", encoding="utf-8")
    OUT_JSON.write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")


def validate_artifacts(payload: dict[str, Any]) -> list[str]:
    errors = []

    for path in [LEDGER_JSON, CONFLICT_JSON, ACTION_POLICY, CHANGE_TEMPLATE, OUT_MD, OUT_JSON]:
        if not path.exists():
            errors.append(f"missing required artifact: {path.relative_to(ROOT)}")

    if "implementation_blocked" not in payload:
        errors.append("payload missing implementation_blocked")

    if "affected_canon_files" not in payload:
        errors.append("payload missing affected_canon_files")

    if "affected_active_ledger_items" not in payload:
        errors.append("payload missing affected_active_ledger_items")

    if "relevant_conflicts" not in payload:
        errors.append("payload missing relevant_conflicts")

    for action in payload.get("required_actions", []):
        if action not in ACTION_VALUES:
            errors.append(f"invalid required action: {action}")

    return errors


def main() -> int:
    args = parse_args()
    inputs = derive_inputs(args)

    payload = build_impact(inputs)
    write_report(payload)

    errors = validate_artifacts(payload)

    if errors:
        print("AMB-35 change impact check validation failed.")
        for error in errors:
            print(f"- {error}")
        return 1

    print(f"wrote {OUT_MD.relative_to(ROOT)}")
    print(f"wrote {OUT_JSON.relative_to(ROOT)}")
    print(f"status: {payload['status']}")
    print(f"implementation_blocked: {payload['implementation_blocked']}")
    print(f"affected_active_item_count: {payload['affected_active_item_count']}")
    print(f"relevant_conflict_count: {payload['relevant_conflict_count']}")
    print("AMB-35 change impact check validation passed")

    if args.strict and payload["implementation_blocked"]:
        return 2

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
