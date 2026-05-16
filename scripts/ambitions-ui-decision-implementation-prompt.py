#!/usr/bin/env python3
from __future__ import annotations
import argparse, json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ACTIVE = ROOT / "frontend" / "visual-encyclopedia" / "decisions" / "active"
REPORTS = ROOT / "build" / "reports" / "ui-decisions"
RUNNER_HEADER = """<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
"""

def bullets(items) -> str:
    if not items: return "- None"
    out = []
    for item in items:
        if isinstance(item, dict): out.append(f"- `{item.get('name') or item}` — {item.get('status', 'declared')}")
        else: out.append(f"- `{item}`")
    return "\n".join(out)

def primitives(row: dict) -> list[dict]:
    return [item if isinstance(item, dict) else {"name": str(item), "status": "missing"} for item in (row.get("affected_design_system_primitives", []) or [])]

def prompt(row: dict, batch: str | None) -> str:
    batch_id = batch or f"{row['id']}-IMPLEMENTATION-01"
    return "\n".join([RUNNER_HEADER.rstrip(), "", f"# UI Decision Implementation Prompt: {batch_id}", "", f"Batch ID: `{batch_id}`", f"Decision ID: `{row['id']}`", "", "## Objective", str(row.get("decision", "")), "", "Implement only within the declared UI-decision scope unless a Yellow report justifies a smaller safe follow-up.", "", "## Active Source Truth to Inspect", "- `docs/truth/PRODUCT_DESIGN_TRUTH.md`", "- `docs/truth/PRODUCT_MOAT_TRUTH.md`", "- `docs/truth/IMPLEMENTATION_TRUTH.md`", "- `docs/truth/RELEASE_TRUTH.md`", "- `frontend/visual-encyclopedia/FRONTEND_AUTHORITY_INDEX.md`", "- `frontend/visual-encyclopedia/ENCYCLOPEDIA_TO_FRONTEND_OS.md`", "- `frontend/visual-encyclopedia/DESIGN_SYSTEM_TO_VISUAL_ENCYCLOPEDIA_BRIDGE.md`", f"- `frontend/visual-encyclopedia/decisions/active/{row['id']}.yaml`", "", "## Allowed Scope", bullets(row.get("allowed_scope", []) or row.get("affected_swift_candidates", [])), "", "## Forbidden Scope", bullets(row.get("forbidden_scope", ["Unrelated surfaces", "Top-level IA changes", "Release or device proof claims"])), "", "## Design System Expectations", bullets(primitives(row)), "", "## Visual Proof Expectations", "- Update or add previews when visual primitives change.", "- Do not claim screenshot/device/accessibility proof from generated docs alone.", "", "## Validation Expectations", "- `python3 scripts/ambitions-ui-decision-check.py`", f"- `python3 scripts/ambitions-ui-decision-sync.py --decision {row['id']}`", "- `git diff --check`", "", "## Hard Red Stop Conditions", bullets(row.get("hard_reds", [])), "", "## Rollback Expectations", bullets(row.get("rollback_expectations", [])), "", "## Runner Command", "```bash", f"scripts/ambitions-codex-train.sh {batch_id} build/reports/ui-decisions/{row['id']}/generated-implementation-prompt.md", "```", ""]) + "\n"

def main() -> int:
    parser = argparse.ArgumentParser(description="Generate an Ambitions runner-compatible prompt from one UI decision.")
    parser.add_argument("--decision", required=True)
    parser.add_argument("--batch")
    args = parser.parse_args()
    path = ACTIVE / f"{args.decision}.yaml"
    if not path.exists():
        raise SystemExit(f"Unknown UI decision: {args.decision}")
    row = json.loads(path.read_text(encoding="utf-8"))
    out = REPORTS / args.decision / "generated-implementation-prompt.md"
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(prompt(row, args.batch), encoding="utf-8")
    print(str(out.relative_to(ROOT)))
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
