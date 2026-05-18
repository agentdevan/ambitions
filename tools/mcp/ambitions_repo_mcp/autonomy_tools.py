"""Autonomy control-plane tools for the read-only Ambitions Repo MCP.

These tools are read-only. They compile existing repo truth, active state,
changed-file impact, validation planning, prompt shape, and run artifacts into
small deterministic objects for autonomous Codex routing.
"""

from __future__ import annotations

import json
import re
from pathlib import Path
from typing import Any, Callable

JSON = dict[str, Any]

OBSOLETE_AUTHORITY_PATTERNS = [
    {
        "id": "plan_top_level_tab",
        "pattern": r"\bToday\s*/\s*Goals\s*/\s*Capture\s*/\s*Plan\s*/\s*You\b|\bPlan\b.*\btop[- ]level\b",
        "severity": "high",
        "replacement": "Use active top-level IA: Today / Goals / Capture / Time / You.",
    },
    {
        "id": "start_focus_cta",
        "pattern": r"\b(Start|Begin) Focus\b",
        "severity": "medium",
        "replacement": "Use Start now or Open step depending on destination behavior.",
    },
    {
        "id": "next_best_move_language",
        "pattern": r"\bnext best move\b|\bYour best next move\b",
        "severity": "medium",
        "replacement": "Use Start here / Recommended step language.",
    },
    {
        "id": "generic_dashboard_fallback",
        "pattern": r"\bgeneric dashboard\b|\bcard stack\b|\btask manager\b|\bcalendar clone\b",
        "severity": "medium",
        "replacement": "Use Ambitions-native primary objects and one-primary-object surface rules.",
    },
    {
        "id": "core_external_llm_dependency",
        "pattern": r"\bexternal LLM\b.*\bcore\b|\bcloud LLM\b.*\bcore\b|\bhosted AI\b.*\brequired\b",
        "severity": "high",
        "replacement": "Core intelligence must remain local-first/deterministic; hosted intelligence may only be optional extension scope.",
    },
    {
        "id": "analytics_or_backend_sdk_core",
        "pattern": r"\banalytics SDK\b|\bbackend SDK\b|\btelemetry\b",
        "severity": "high",
        "replacement": "Do not add analytics/backend/telemetry dependencies without explicit future policy.",
    },
]

PROMPT_REQUIRED_MARKERS = [
    "AMBITIONS_RUNNER_REQUIRED: true",
    "RUN_WITH: scripts/ambitions-codex-train.sh",
    "DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner",
]

PROMPT_REQUIRED_TERMS = [
    "Batch ID",
    "Objective",
    "Active source truth",
    "Allowed scope",
    "Forbidden scope",
    "Validation",
    "Hard Red",
    "Rollback",
]


def _read_json(path: Path) -> JSON | None:
    try:
        if not path.exists() or not path.is_file():
            return None
        return json.loads(path.read_text(encoding="utf-8"))
    except Exception:
        return None


def _safe_rel(root: Path, path: Path) -> str:
    try:
        return str(path.relative_to(root))
    except ValueError:
        return str(path)


def _latest_file(root: Path, pattern: str = "*") -> Path | None:
    if not root.exists():
        return None
    files = [path for path in root.rglob(pattern) if path.is_file()]
    if not files:
        return None
    return max(files, key=lambda path: path.stat().st_mtime)


def _latest_run_dir(repo_root: Path, batch_id: str | None = None) -> Path | None:
    runs_root = repo_root / ".codex" / "runs"
    if not runs_root.exists():
        return None
    candidates: list[Path] = []
    if batch_id:
        batch_root = runs_root / batch_id
        if batch_root.exists():
            candidates = [path for path in batch_root.iterdir() if path.is_dir()]
    else:
        candidates = [path for path in runs_root.glob("*/*") if path.is_dir()]
    if not candidates:
        return None
    return max(candidates, key=lambda path: path.stat().st_mtime)


def _collect_lines_with_patterns(text: str, patterns: list[dict[str, str]], path: str) -> list[JSON]:
    findings: list[JSON] = []
    compiled = [(item, re.compile(item["pattern"], re.IGNORECASE)) for item in patterns]
    for line_no, line in enumerate(text.splitlines(), start=1):
        for item, regex in compiled:
            if regex.search(line):
                findings.append({
                    "id": item["id"],
                    "path": path,
                    "line": line_no,
                    "severity": item["severity"],
                    "text": line.strip()[:240],
                    "replacement": item["replacement"],
                })
    return findings


def _validation_plan_for_categories(categories: set[str], required_proof: list[str]) -> JSON:
    validations: list[str] = ["repo_claim_scan"]
    optional: list[str] = []
    xcode_lane = "none"

    if categories & {"user_facing_app", "domain_intelligence_or_contract", "persistence", "services_side_effects", "tests", "build_configuration"}:
        validations.append("xcode_validate_build")
        xcode_lane = "build"
    if categories & {"domain_intelligence_or_contract", "persistence", "services_side_effects", "tests"}:
        validations.append("xcode_validate_focused_test")
        optional.append("xcode_validate_build_for_testing")
        xcode_lane = "focused-test"
    if "build_configuration" in categories:
        validations.append("xcode_validate_build_for_testing")
        xcode_lane = "build-for-testing"
    if categories & {"user_facing_app", "product_design_canon"}:
        optional.extend(["visual_proof_packet", "accessibility_shadow_packet"])
    if "privacy_proof" in required_proof:
        optional.append("local_first_privacy_scan")

    ordered = []
    for item in validations:
        if item not in ordered:
            ordered.append(item)
    return {
        "required_validations": ordered,
        "optional_validations": optional,
        "xcode_lane": xcode_lane,
        "commit_gate": "all required validations Green or accepted Yellow with ledger evidence",
        "release_claim_allowed": False,
    }


def register_autonomy_tools(
    register: Callable[[Any], None],
    tool_def_cls: Any,
    tool_schema: Callable[[JSON | None, list[str] | None], JSON],
    repo_root: Path,
    read_text: Callable[[str], str],
    exists: Callable[[str], bool],
    path_category: Callable[[str], str],
    required_proof_for_categories: Callable[[set[str]], list[str]],
    hard_red_risks: Callable[[list[str], set[str]], list[str]],
    get_active_batch: Callable[[JSON], JSON],
    summarize_repo_posture: Callable[[JSON], JSON],
    check_efc_applicability: Callable[[JSON], JSON],
) -> None:
    """Register autonomy tools onto the existing MCP server."""

    def tool_required_validation_plan(args: JSON) -> JSON:
        changed_files = args.get("changed_files") or []
        if not isinstance(changed_files, list):
            raise ValueError("changed_files must be a list")
        paths = [str(item) for item in changed_files]
        categories = {path_category(path) for path in paths}
        required_proof = required_proof_for_categories(categories)
        plan = _validation_plan_for_categories(categories, required_proof)
        return {
            "changed_files": paths,
            "categories": sorted(categories),
            "required_proof": required_proof,
            "hard_red_risks": hard_red_risks(paths, categories),
            **plan,
            "non_claims": [
                "validation plan is routing guidance only",
                "not release proof",
                "not device proof",
                "not public accessibility proof",
            ],
        }

    def tool_resolve_active_truth(args: JSON) -> JSON:
        query = str(args.get("query") or "").strip()
        if not query:
            raise ValueError("query is required")
        terms = [term for term in re.split(r"[^A-Za-z0-9]+", query.lower()) if len(term) >= 3]
        stack = [item for item in summarize_repo_posture({}).items()]
        candidate_roots = ["docs/truth", "docs/AmbitionsCanon", "docs/status", "docs/codex", ".codex", "prompts/batches"]
        matches: list[JSON] = []
        for root_name in candidate_roots:
            root = repo_root / root_name
            if not root.exists():
                continue
            for path in root.rglob("*.md"):
                rel = _safe_rel(repo_root, path)
                haystack = rel.lower()
                score = sum(1 for term in terms if term in haystack)
                role = "supporting"
                if rel.startswith("docs/truth/"):
                    role = "active"
                    score += 4
                elif rel.startswith("docs/status/"):
                    role = "implementation-or-evidence-status"
                    score += 2
                elif rel.startswith("docs/AmbitionsCanon/"):
                    role = "product-canon-supporting"
                    score += 2
                elif rel.startswith("docs/codex/") or rel.startswith(".codex/"):
                    role = "codex-process-supporting"
                    score += 1
                if score > 0:
                    matches.append({"path": rel, "role": role, "score": score, "exists": True})
        matches.sort(key=lambda item: (-int(item["score"]), str(item["path"])))
        return {
            "query": query,
            "active": [item for item in matches if item["role"] == "active"][:10],
            "supporting": [item for item in matches if item["role"] != "active"][:25],
            "obsolete_scan_required": True,
            "precedence_note": "docs/truth/* wins conflicts; live source and status evidence own implementation/proof status.",
        }

    def tool_obsolete_authority_scan(args: JSON) -> JSON:
        paths = args.get("paths") or []
        if isinstance(paths, str):
            paths = [paths]
        if not isinstance(paths, list):
            raise ValueError("paths must be a list")
        findings: list[JSON] = []
        for raw in [str(path) for path in paths]:
            try:
                findings.extend(_collect_lines_with_patterns(read_text(raw), OBSOLETE_AUTHORITY_PATTERNS, raw))
            except FileNotFoundError:
                findings.append({"path": raw, "severity": "missing", "text": "file not found"})
        return {
            "finding_count": len(findings),
            "findings": findings,
            "status": "review_required" if findings else "clean",
            "note": "Findings flag stale or risky authority language; they are not automatic rewrite permission.",
        }

    def tool_batch_prompt_preflight(args: JSON) -> JSON:
        prompt_path = args.get("prompt_path")
        if not isinstance(prompt_path, str):
            raise ValueError("prompt_path is required")
        text = read_text(prompt_path)
        missing_markers = [marker for marker in PROMPT_REQUIRED_MARKERS if marker not in text]
        missing_terms = [term for term in PROMPT_REQUIRED_TERMS if term.lower() not in text.lower()]
        direct_codex_risk = "codex exec" in text and "DIRECT_CODEX_EXECUTION" not in text
        return {
            "prompt_path": prompt_path,
            "valid": not missing_markers and not missing_terms and not direct_codex_risk,
            "missing_markers": missing_markers,
            "missing_terms": missing_terms,
            "direct_codex_risk": direct_codex_risk,
            "runner_required": True,
        }

    def tool_latest_run_summary(args: JSON) -> JSON:
        batch_id = args.get("batch_id")
        if batch_id is not None and not isinstance(batch_id, str):
            raise ValueError("batch_id must be a string")
        run_dir = _latest_run_dir(repo_root, batch_id)
        if run_dir is None:
            return {"found": False, "batch_id": batch_id, "run": None}
        final_summary = run_dir / "final-summary.md"
        status_files = sorted((run_dir / "status").glob("*.status.txt")) if (run_dir / "status").exists() else []
        diffstat = _latest_file(run_dir / "diff", "*.diffstat.txt")
        final_text = final_summary.read_text(encoding="utf-8", errors="replace") if final_summary.exists() else ""
        status = "UNKNOWN"
        match = re.search(r"Final status:\s*(GREEN|YELLOW|RED)", final_text, re.IGNORECASE)
        if match:
            status = match.group(1).upper()
        return {
            "found": True,
            "run_dir": _safe_rel(repo_root, run_dir),
            "status": status,
            "final_summary_path": _safe_rel(repo_root, final_summary) if final_summary.exists() else None,
            "status_files": [_safe_rel(repo_root, path) for path in status_files[-10:]],
            "latest_diffstat": _safe_rel(repo_root, diffstat) if diffstat else None,
            "final_summary_tail": final_text[-4000:],
        }

    def tool_continuation_oracle(args: JSON) -> JSON:
        status = str(args.get("status") or "").upper().strip()
        batch_id = args.get("batch_id")
        run_summary = None
        if not status:
            run_summary = tool_latest_run_summary({"batch_id": batch_id} if isinstance(batch_id, str) else {})
            status = str(run_summary.get("status") or "UNKNOWN").upper()
        yellow_accepted = bool(args.get("yellow_accepted", False))
        hard_red_risks_arg = args.get("hard_red_risks") or []
        if not isinstance(hard_red_risks_arg, list):
            raise ValueError("hard_red_risks must be a list when provided")
        if hard_red_risks_arg:
            decision = "STOP_HARD_RED"
        elif status == "GREEN":
            decision = "CONTINUE"
        elif status == "YELLOW" and yellow_accepted:
            decision = "CONTINUE_WITH_LEDGER"
        elif status == "YELLOW":
            decision = "FINALIZE_OR_ACCEPT_YELLOW"
        elif status == "RED":
            decision = "REPAIR_PROMPT_REQUIRED"
        else:
            decision = "OWNER_NEEDED"
        return {
            "decision": decision,
            "status": status,
            "run_summary": run_summary,
            "hard_red_risks": hard_red_risks_arg,
            "rules": [
                "Green may continue after required proof exists.",
                "Yellow requires accepted-Yellow ledger evidence before continuation.",
                "Red routes to repair prompt unless hard-red risks require owner unblock.",
                "Release/device/accessibility/legal/privacy claims remain blocked without evidence.",
            ],
        }

    def tool_autonomy_preflight(args: JSON) -> JSON:
        changed_files = args.get("changed_files") or []
        if not isinstance(changed_files, list):
            raise ValueError("changed_files must be a list")
        active = get_active_batch({})
        posture = summarize_repo_posture({})
        efc = check_efc_applicability({"changed_files": changed_files})
        plan = tool_required_validation_plan({"changed_files": changed_files})
        return {
            "active_batch": active.get("current"),
            "repo_posture": posture,
            "efc": efc,
            "validation_plan": plan,
            "go_no_go": "blocked" if efc.get("hard_red_risks") else "go_with_required_proof",
            "next_required_action": "run required validations, then continuation_oracle",
        }

    def tool_queue_next_action(_: JSON) -> JSON:
        next_action_json = _read_json(repo_root / "build" / "codex-os" / "next-action.json")
        sync_json = _read_json(repo_root / "build" / "codex-os" / "sync-report.json")
        active = get_active_batch({})
        return {
            "active_batch": active.get("current"),
            "next_action": next_action_json,
            "sync_report_available": sync_json is not None,
            "sync_report_status": sync_json.get("status") if isinstance(sync_json, dict) else None,
            "note": "This is read-only queue guidance. Execute only through the Ambitions runner.",
        }

    register(tool_def_cls(
        "required_validation_plan",
        "Plan required proof validations from changed files for autonomous Codex routing.",
        tool_schema({"changed_files": {"type": "array", "items": {"type": "string"}}}, ["changed_files"]),
        tool_required_validation_plan,
    ))
    register(tool_def_cls(
        "resolve_active_truth",
        "Resolve query-specific active/supporting truth candidates with Ambitions precedence notes.",
        tool_schema({"query": {"type": "string"}}, ["query"]),
        tool_resolve_active_truth,
    ))
    register(tool_def_cls(
        "obsolete_authority_scan",
        "Scan selected files for stale Ambitions authority, terminology, or architecture drift.",
        tool_schema({"paths": {"type": "array", "items": {"type": "string"}}}, ["paths"]),
        tool_obsolete_authority_scan,
    ))
    register(tool_def_cls(
        "batch_prompt_preflight",
        "Validate that a batch prompt has required Ambitions runner shape before execution.",
        tool_schema({"prompt_path": {"type": "string"}}, ["prompt_path"]),
        tool_batch_prompt_preflight,
    ))
    register(tool_def_cls(
        "latest_run_summary",
        "Summarize the latest .codex/runs artifact for a batch or globally.",
        tool_schema({"batch_id": {"type": "string"}}, []),
        tool_latest_run_summary,
    ))
    register(tool_def_cls(
        "continuation_oracle",
        "Return CONTINUE/REPAIR/FINALIZE/OWNER_NEEDED decision guidance from status and risk evidence.",
        tool_schema({"status": {"type": "string"}, "batch_id": {"type": "string"}, "yellow_accepted": {"type": "boolean"}, "hard_red_risks": {"type": "array", "items": {"type": "string"}}}, []),
        tool_continuation_oracle,
    ))
    register(tool_def_cls(
        "autonomy_preflight",
        "Compile active batch, repo posture, EFC applicability, and validation plan into one preflight object.",
        tool_schema({"changed_files": {"type": "array", "items": {"type": "string"}}}, []),
        tool_autonomy_preflight,
    ))
    register(tool_def_cls(
        "queue_next_action",
        "Read current Codex OS next-action artifacts and active batch state.",
        tool_schema(),
        tool_queue_next_action,
    ))
