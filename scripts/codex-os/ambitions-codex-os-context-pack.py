#!/usr/bin/env python3
from __future__ import annotations

import json
from datetime import datetime, timezone
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))

from ambitions_codex_os_common import (  # noqa: E402
    BUILD_ROOT,
    architecture_debt_snapshot,
    active_authority_map,
    ensure_dir,
    generated_freshness_state,
    git_head_commit_iso,
    load_json_from_generated,
    markdown_excerpt,
    repo_doctor_summary_snapshot,
    semantic_code_graph_summary,
    summarize_markdown_sections,
    write_json,
    write_text,
)


def section(title: str, body: str) -> str:
    return f"## {title}\n\n{body.strip()}\n"


def render_json_block(data: object) -> str:
    return "```json\n" + json.dumps(data, indent=2, sort_keys=True) + "\n```"


def markdown_list(items: list[str]) -> str:
    if not items:
        return "- None"
    return "\n".join(f"- {item}" for item in items)


def main() -> int:
    ensure_dir(BUILD_ROOT)

    authority = active_authority_map()
    write_json("build/codex-os/active-authority-map.json", authority)

    next_action = load_json_from_generated("next-action.json", {})
    repo_doctor = repo_doctor_summary_snapshot()
    governance_dashboard = markdown_excerpt("docs/governance/GOVERNANCE_DASHBOARD.md", 6000)
    canon_impact = markdown_excerpt("docs/governance/generated/canon_impact_plan.md", 6000)
    implementation_expectation = load_json_from_generated("implementation_expectation_map.json", {})
    resequence = load_json_from_generated("global_train_resequence.json", {})
    cleanup_plan = markdown_excerpt("docs/governance/generated/cleanup_action_plan.md", 5000)
    stale_overlay = markdown_excerpt("docs/governance/generated/stale_overlay_audit.md", 5000)
    orphan_prompt = markdown_excerpt("docs/governance/generated/orphan_prompt_audit.md", 5000)
    freshness = generated_freshness_state()
    semantic_graph = semantic_code_graph_summary()
    debt = architecture_debt_snapshot()

    next_reason = str(next_action.get("reason", "No next action recorded."))
    next_command = str(next_action.get("command", "python3 scripts/codex-os/ambitions-codex-os-next-action.py"))
    blocked_reason = str(next_action.get("blocked_reason", ""))
    next_decision = str(next_action.get("decision", "unknown"))

    lines = [
        "# Ambitions Codex OS Context Pack",
        "",
        f"Generated: {git_head_commit_iso()}",
        "",
        "This pack is generated from live repo files and current governance outputs.",
        "",
        section("Active Authority Map", render_json_block(authority)),
        section("Governance Dashboard", governance_dashboard),
        section("Repo Doctor Summary", markdown_excerpt("docs/governance/generated/repo_doctor_summary.md", 8000)),
        section("Canon Impact Plan", canon_impact),
        section("Implementation Expectation Map", render_json_block(implementation_expectation)),
        section("Global Train Resequence", render_json_block(resequence)),
        section("Semantic Code Graph Summary", render_json_block(semantic_graph)),
        section("Architecture Debt Score", render_json_block(debt)),
        section("Cleanup Action Plan", cleanup_plan),
        section("Stale Overlay Audit Summary", stale_overlay),
        section("Orphan Prompt Audit Summary", orphan_prompt),
        section("Next Recommended Codex Action", next_reason),
        section("Blocked Action Reason", blocked_reason or "None"),
        section("Exact Next Command", next_command),
        section("Generated Output Freshness", render_json_block(freshness)),
        section("Repo Doctor Status", render_json_block(repo_doctor)),
    ]

    out = write_text("build/codex-os/ambitions-context-pack.md", "\n".join(lines).rstrip() + "\n")
    print(out)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
