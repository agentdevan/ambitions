#!/usr/bin/env python3
from __future__ import annotations

import json
import os
import re
import subprocess
import hashlib
from collections import Counter
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

REPO_ROOT = Path(__file__).resolve().parents[2]
BUILD_ROOT = REPO_ROOT / "build" / "codex-os"
GENERATED_ROOT = REPO_ROOT / "docs" / "governance" / "generated"

ACTIVE_TRUTH_FILES = [
    "docs/truth/README.md",
    "docs/truth/PRODUCT_DESIGN_TRUTH.md",
    "docs/truth/PRODUCT_MOAT_TRUTH.md",
    "docs/truth/IMPLEMENTATION_TRUTH.md",
    "docs/truth/RELEASE_TRUTH.md",
    "docs/truth/CODEX_PROCESS_TRUTH.md",
    "docs/truth/HISTORICAL_POLICY.md",
]

CODEx_OS_DOC_FILES = [
    ".codex/os/AMBITIONS_OPERATING_CONTEXT.md",
    ".codex/os/ACTIVE_AUTHORITY_MAP.md",
    ".codex/os/CODEX_DECISION_POLICY.md",
    ".codex/os/AUTONOMY_RULES.md",
    ".codex/os/FAILURE_RECOVERY_POLICY.md",
    ".codex/os/TOOL_USE_POLICY.md",
    ".codex/os/BATCH_SELECTION_POLICY.md",
    ".codex/os/GOVERNANCE_INPUTS.md",
    ".codex/os/PERFORMANCE_PROFILE.md",
    ".codex/os/AGENT_ROLES.md",
]

GOVERNANCE_OUTPUT_FILES = [
    "docs/governance/GOVERNANCE_DASHBOARD.md",
    "docs/governance/generated/repo_doctor_summary.md",
    "docs/governance/generated/repo_doctor_summary.json",
    "docs/governance/generated/canon_impact_plan.md",
    "docs/governance/generated/canon_impact_map.json",
    "docs/governance/generated/implementation_expectation_map.json",
    "docs/governance/generated/global_train_resequence.json",
    "docs/governance/generated/mature_spec_synthesis.md",
    "docs/governance/generated/prompt_rewrite_plan.md",
    "docs/governance/generated/supersession_rewrite_plan.md",
    "docs/governance/generated/cleanup_action_plan.md",
    "docs/governance/generated/orphan_prompt_audit.md",
    "docs/governance/generated/stale_overlay_audit.md",
    "docs/governance/generated/architecture_debt_score.json",
    "docs/governance/generated/governance_reconciliation_summary.json",
    "docs/governance/generated/train_lineage_graph.json",
    "docs/governance/generated/proof_linkage_graph.json",
    "docs/governance/generated/train_to_implementation_map.json",
]

CODEx_OS_OUTPUT_FILES = [
    "build/codex-os/active-authority-map.json",
    "build/codex-os/ambitions-context-pack.md",
    "build/codex-os/next-action.json",
    "build/codex-os/next-action.md",
    "build/codex-os/batch-selection.json",
    "build/codex-os/batch-selection.md",
    "build/codex-os/repair-plan.json",
    "build/codex-os/repair-plan.md",
    "build/codex-os/performance-check.json",
    "build/codex-os/performance-check.md",
    "build/codex-os/sync-report.json",
    "build/codex-os/sync-report.md",
]

REQUIRED_OUTPUT_FILES = GOVERNANCE_OUTPUT_FILES + CODEx_OS_OUTPUT_FILES


def resolve_path(path: os.PathLike[str] | str) -> Path:
    candidate = Path(path)
    return candidate if candidate.is_absolute() else REPO_ROOT / candidate


def ensure_dir(path: Path) -> Path:
    path.mkdir(parents=True, exist_ok=True)
    return path


def read_text(path: os.PathLike[str] | str, default: str = "") -> str:
    candidate = resolve_path(path)
    if not candidate.exists():
        return default
    return candidate.read_text(encoding="utf-8", errors="replace")


def write_text(path: os.PathLike[str] | str, text: str) -> Path:
    candidate = resolve_path(path)
    ensure_dir(candidate.parent)
    candidate.write_text(text, encoding="utf-8")
    return candidate


def read_json(path: os.PathLike[str] | str, default: Any | None = None) -> Any:
    candidate = resolve_path(path)
    if not candidate.exists():
        return default
    return json.loads(candidate.read_text(encoding="utf-8"))


def write_json(path: os.PathLike[str] | str, data: Any) -> Path:
    candidate = resolve_path(path)
    ensure_dir(candidate.parent)
    candidate.write_text(json.dumps(data, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    return candidate


def run_command(args: list[str], *, check: bool = False) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        args,
        cwd=REPO_ROOT,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=check,
    )


def git_output(args: list[str]) -> str:
    return run_command(["git", *args]).stdout


def git_changed_paths(prefixes: tuple[str, ...] | None = None) -> list[str]:
    changed = set()
    for raw in [
        git_output(["diff", "--name-only", "HEAD"]),
        git_output(["ls-files", "--others", "--exclude-standard", "--", "."]),
    ]:
        for line in raw.splitlines():
            candidate = line.strip()
            if not candidate:
                continue
            if prefixes and not candidate.startswith(prefixes):
                continue
            changed.add(candidate)
    return sorted(changed)


def git_head_sha() -> str:
    return git_output(["rev-parse", "HEAD"]).strip()


def git_head_commit_iso() -> str:
    value = git_output(["show", "-s", "--format=%cI", "HEAD"]).strip()
    return value or git_head_sha()


def current_branch() -> str:
    return git_output(["rev-parse", "--abbrev-ref", "HEAD"]).strip()


def parse_scalar(value: str) -> Any:
    text = value.strip()
    if text in {"", "null", "None"}:
        return ""
    if text.lower() == "true":
        return True
    if text.lower() == "false":
        return False
    if (text.startswith('"') and text.endswith('"')) or (text.startswith("'") and text.endswith("'")):
        return text[1:-1]
    if re.fullmatch(r"-?\d+", text):
        try:
            return int(text)
        except ValueError:
            return text
    return text


def parse_active_batch_state() -> dict[str, Any]:
    path = resolve_path(".codex/state/active-batch.yml")
    data: dict[str, Any] = {"source_of_truth": []}
    if not path.exists():
        return data

    section: str | None = None
    for raw in path.read_text(encoding="utf-8", errors="replace").splitlines():
        if not raw.strip() or raw.lstrip().startswith("#"):
            continue
        indent = len(raw) - len(raw.lstrip(" "))
        line = raw.strip()

        if indent == 0:
            if line.endswith(":"):
                section = line[:-1]
                if section not in data:
                    data[section] = [] if section == "source_of_truth" else {}
            elif ":" in line:
                key, value = line.split(":", 1)
                data[key.strip()] = parse_scalar(value)
            continue

        if section is None:
            continue

        if section == "source_of_truth" and line.startswith("- "):
            data.setdefault("source_of_truth", []).append(parse_scalar(line[2:]))
            continue

        container = data.get(section)
        if not isinstance(container, dict):
            continue

        if indent == 2 and line.endswith(":"):
            subsection = line[:-1]
            container[subsection] = {}
            continue

        if indent >= 2 and ":" in line:
            key, value = line.split(":", 1)
            target: dict[str, Any] = container
            if indent >= 4:
                for maybe in list(container.values()):
                    if isinstance(maybe, dict) and key.strip() not in container:
                        target = maybe
                        break
            target[key.strip()] = parse_scalar(value)

    return data


def load_json_from_generated(name: str, default: Any | None = None) -> Any:
    return read_json(GENERATED_ROOT / name, default)


def load_text_from_generated(name: str, default: str = "") -> str:
    return read_text(GENERATED_ROOT / name, default)


def file_snapshot(path: os.PathLike[str] | str) -> dict[str, Any]:
    candidate = resolve_path(path)
    snapshot = {
        "path": candidate.relative_to(REPO_ROOT).as_posix() if candidate.exists() else str(path),
        "exists": candidate.exists(),
    }
    if candidate.exists():
        stat = candidate.stat()
        snapshot.update(
            {
                "size": stat.st_size,
                "sha256": hashlib.sha256(candidate.read_bytes()).hexdigest(),
            }
        )
    return snapshot


def markdown_excerpt(path: os.PathLike[str] | str, limit: int = 2400) -> str:
    text = read_text(path, "")
    if not text:
        return "MISSING"
    if len(text) <= limit:
        return text
    return text[:limit].rstrip() + "\n\n[truncated]"


def summarize_markdown_sections(path: os.PathLike[str] | str, limit: int = 8) -> list[str]:
    text = read_text(path, "")
    if not text:
        return ["MISSING"]
    lines = []
    for raw in text.splitlines():
        if raw.startswith("#"):
            lines.append(raw.strip())
            if len(lines) >= limit:
                break
    return lines or ["(no headings found)"]


def required_output_status() -> dict[str, dict[str, Any]]:
    return {str(p): file_snapshot(p) for p in REQUIRED_OUTPUT_FILES}


def active_authority_map() -> dict[str, Any]:
    active_batch = parse_active_batch_state()
    truth_files = [file_snapshot(path) for path in ACTIVE_TRUTH_FILES]
    codex_docs = [file_snapshot(path) for path in CODEx_OS_DOC_FILES]
    governance_outputs = [file_snapshot(path) for path in GOVERNANCE_OUTPUT_FILES]
    codex_outputs = [file_snapshot(path) for path in CODEx_OS_OUTPUT_FILES]
    return {
        "generated_at": git_head_commit_iso(),
        "repo_root": REPO_ROOT.as_posix(),
        "branch": current_branch(),
        "head_sha": git_head_sha(),
        "active_truth_files": truth_files,
        "codex_os_docs": codex_docs,
        "governance_outputs": governance_outputs,
        "codex_os_outputs": codex_outputs,
        "top_level_ia": ["Today", "Goals", "Capture", "Time", "You"],
        "compatibility_seams": ["Plan"],
        "active_batch_state": active_batch,
        "authority_order": [
            "docs/truth",
            "docs/governance",
            ".codex/os",
            "docs/governance/generated",
            "build/codex-os",
        ],
    }


def semantic_code_graph_summary() -> dict[str, Any]:
    file_counter: Counter[str] = Counter()
    ext_counter: Counter[str] = Counter()
    source_roots = {
        "Native": "native app source",
        "Sources": "shared packages",
        "AppUI": "shared app UI",
        "scripts": "repo automation",
        "docs": "governance and product docs",
        "prompts": "batch prompts",
        ".codex": "control plane state",
        "tools": "local tooling",
    }

    for path in REPO_ROOT.rglob("*"):
        if not path.is_file():
            continue
        rel = path.relative_to(REPO_ROOT).as_posix()
        if rel.startswith(("build/", ".git/", "DerivedData/", "output/")):
            continue
        root = rel.split("/", 1)[0]
        file_counter[root] += 1
        ext_counter[path.suffix.lower() or "[no_ext]"] += 1

    notable_paths = {
        "app_entry": file_snapshot("Native/Ambitions/App/AmbitionsApp.swift"),
        "shell": file_snapshot("Native/Ambitions/App/AmbitionsRootView.swift"),
        "governance": file_snapshot("scripts/governance/ambitions-repo-doctor.py"),
        "codex_os": file_snapshot("scripts/codex-os/ambitions-codex-os-next-action.py"),
    }

    return {
        "generated_at": git_head_commit_iso(),
        "top_level_file_counts": dict(sorted(file_counter.items())),
        "extension_counts": dict(sorted(ext_counter.items(), key=lambda item: (-item[1], item[0]))),
        "source_root_roles": source_roots,
        "notable_paths": notable_paths,
    }


def architecture_debt_snapshot() -> dict[str, Any]:
    data = load_json_from_generated("architecture_debt_score.json", {})
    if not isinstance(data, dict):
        data = {}
    score = data.get("score", 0)
    debt = data.get("debt", {})
    return {
        "generated_at": git_head_commit_iso(),
        "score": score,
        "debt": debt,
    }


def repo_doctor_summary_snapshot() -> dict[str, Any]:
    data = load_json_from_generated("repo_doctor_summary.json", {})
    if isinstance(data, dict) and data:
        return data
    md = read_text(GENERATED_ROOT / "repo_doctor_summary.md", "")
    return {
        "generated_at": "",
        "overall_status": "missing",
        "failures": [],
        "command_results": [],
        "markdown": md,
    }


def generated_freshness_state(paths: list[str] | None = None) -> dict[str, Any]:
    items = paths or REQUIRED_OUTPUT_FILES
    output = []
    missing = []
    for item in items:
        snapshot = file_snapshot(item)
        output.append(snapshot)
        if not snapshot["exists"]:
            missing.append(item)
    return {
        "generated_at": git_head_commit_iso(),
        "present_count": len(items) - len(missing),
        "missing_count": len(missing),
        "missing": missing,
        "outputs": output,
    }


def queue_data() -> dict[str, Any]:
    data = read_json("docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json", {})
    return data if isinstance(data, dict) else {}


def queue_entries() -> list[dict[str, Any]]:
    data = queue_data()
    items = data.get("batches", [])
    return items if isinstance(items, list) else []


def prompt_file_for_batch(batch_id: str) -> str:
    candidates = [
        REPO_ROOT / "prompts" / "batches" / f"{batch_id}.md",
        REPO_ROOT / "prompts" / "batches" / f"{batch_id}-FINALIZE-01.md",
        REPO_ROOT / "prompts" / "batches" / f"{batch_id}-REPAIR-01.md",
    ]
    for candidate in candidates:
        if candidate.exists():
            return candidate.relative_to(REPO_ROOT).as_posix()
    return ""


def batch_id_from_label(value: str) -> str:
    candidate = value.strip().split(" ", 1)[0]
    if re.fullmatch(r"[A-Z]+[0-9A-Z]+", candidate):
        return candidate
    return value.strip()


def latest_active_batch_id() -> str:
    state = parse_active_batch_state()
    current = state.get("current", {})
    if isinstance(current, dict):
        batch = current.get("batch")
        if isinstance(batch, str):
            return batch_id_from_label(batch)
    return ""


def next_eligible_queue_batch() -> str:
    state = parse_active_batch_state()
    current = state.get("current", {})
    if isinstance(current, dict):
        candidate = current.get("next_eligible_batch")
        if isinstance(candidate, str) and candidate:
            return batch_id_from_label(candidate)

    queue = queue_entries()
    for item in queue:
        classification = str(item.get("classification", ""))
        if classification in {"executable_now", "active", "queued", "active_partial"}:
            batch_id = str(item.get("id", ""))
            if batch_id:
                return batch_id
    return ""


def queue_entry_for_batch(batch_id: str) -> dict[str, Any]:
    for item in queue_entries():
        if str(item.get("id", "")) == batch_id:
            return item
    return {}


def batch_lane(batch_id: str) -> str:
    prefix = re.match(r"^[A-Z]+", batch_id or "")
    if not prefix:
        return "unknown"
    value = prefix.group(0)
    return {
        "AFI": "canon",
        "CQS": "governance",
        "DAV": "frontend",
        "EB": "platform",
        "FCP": "flagship",
        "FET": "frontend",
        "PK": "platform",
        "PFC": "platform",
        "PD": "product-depth",
        "SA": "source-atlas",
        "SI": "surface",
        "CS": "compatibility",
        "AIR": "overlay",
    }.get(value, value.lower())


def batch_selection_candidates() -> dict[str, Any]:
    state = parse_active_batch_state()
    current = state.get("current", {})
    blocked = state.get("blocked_forward_queue", {})
    candidate = next_eligible_queue_batch() or latest_active_batch_id()
    queue_entry = queue_entry_for_batch(candidate) if candidate else {}
    prompt = prompt_file_for_batch(candidate) if candidate else ""
    lane = batch_lane(candidate)
    return {
        "generated_at": git_head_commit_iso(),
        "selected_batch": candidate,
        "prompt_file": prompt,
        "lane": lane,
        "queue_entry": queue_entry,
        "current_state": current,
        "blocked_forward_queue": blocked,
    }


def count_markdown_rows(path: os.PathLike[str] | str) -> int:
    text = read_text(path, "")
    if not text:
        return 0
    return sum(1 for line in text.splitlines() if line.startswith("- ") or line.startswith("| "))
