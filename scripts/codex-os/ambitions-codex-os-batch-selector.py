#!/usr/bin/env python3
from __future__ import annotations

import json
from datetime import datetime, timezone
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))

from ambitions_codex_os_common import (  # noqa: E402
    BUILD_ROOT,
    batch_selection_candidates,
    ensure_dir,
    git_head_commit_iso,
    load_json_from_generated,
    prompt_file_for_batch,
    queue_entry_for_batch,
    write_json,
    write_text,
)


def main() -> int:
    ensure_dir(BUILD_ROOT)

    next_action = load_json_from_generated("next-action.json", {})
    selection = batch_selection_candidates()
    selected_batch = str(selection.get("selected_batch", ""))
    queue_entry = queue_entry_for_batch(selected_batch) if selected_batch else {}
    prompt_file = str(selection.get("prompt_file", "")) or prompt_file_for_batch(selected_batch)
    lane = str(selection.get("lane", "unknown"))
    classification = str(queue_entry.get("classification", "unknown"))
    reason = ""
    blockers: list[str] = []

    if not selected_batch:
        reason = "No executable batch was found in the live queue."
    else:
        reason = f"Selected the safest live batch from current state: {selected_batch}."
        blocked = selection.get("blocked_forward_queue", {})
        if isinstance(blocked, dict):
            blocked_batch = str(blocked.get("blocked_batch", ""))
            blocked_reason = str(blocked.get("reason", ""))
            if blocked_batch and blocked_batch != "none":
                blockers.append(f"blocked_forward_queue:{blocked_batch}")
            if blocked_reason and blocked_reason != "none":
                blockers.append(f"blocked_reason:{blocked_reason}")
        prereqs = str(queue_entry.get("blocking_prerequisites", ""))
        if prereqs and prereqs.lower() != "none":
            blockers.append(f"queue_prerequisites:{prereqs}")

    preflight = [
        "python3 scripts/governance/ambitions-repo-doctor.py",
        "python3 scripts/codex-os/ambitions-codex-os-sync-governance.py",
    ]
    postflight = [
        "python3 scripts/governance/ambitions-repo-doctor.py",
        "python3 scripts/codex-os/ambitions-codex-os-sync-governance.py",
    ]

    command = ""
    if selected_batch and prompt_file:
        command = f"make authorized-batch BATCH={selected_batch} PROMPT={prompt_file}"

    data = {
        "generated_at": git_head_commit_iso(),
        "selected_batch": selected_batch,
        "prompt_file": prompt_file,
        "lane": lane,
        "classification": classification,
        "reason": reason,
        "blockers": blockers,
        "preflight_commands": preflight,
        "postflight_commands": postflight,
        "run_command": command,
        "next_action_command": str(next_action.get("command", "")),
    }
    write_json("build/codex-os/batch-selection.json", data)

    lines = [
        "# Codex OS Batch Selection",
        "",
        f"Generated: {data['generated_at']}",
        "",
        f"Selected batch: {selected_batch or 'none'}",
        f"Prompt file: {prompt_file or 'none'}",
        f"Lane: {lane}",
        f"Queue classification: {classification}",
        "",
        "## Reason",
        "",
        reason,
        "",
        "## Blockers",
        "",
    ]
    lines.extend(f"- {item}" for item in blockers) if blockers else lines.append("- None")
    lines += [
        "",
        "## Preflight Commands",
        "",
    ]
    lines.extend(f"- `{item}`" for item in preflight)
    lines += ["", "## Postflight Commands", ""]
    lines.extend(f"- `{item}`" for item in postflight)
    lines += ["", "## Run Command", "", command or "No executable batch is available."]
    write_text("build/codex-os/batch-selection.md", "\n".join(lines).rstrip() + "\n")
    print(json.dumps(data, indent=2, sort_keys=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
