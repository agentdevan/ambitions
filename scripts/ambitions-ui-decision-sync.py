#!/usr/bin/env python3
from __future__ import annotations
import argparse, json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
FRONTEND = ROOT / "frontend" / "visual-encyclopedia"
ACTIVE = FRONTEND / "decisions" / "active"
LEDGER = FRONTEND / "decisions" / "UI_DECISION_LEDGER.yaml"
TRACE = FRONTEND / "trace"
SURFACE_MATRIX = TRACE / "UI_DECISION_TO_SURFACE_MATRIX.yaml"
SYSTEM_MATRIX = TRACE / "UI_DECISION_TO_DESIGN_SYSTEM_MATRIX.yaml"
REPORTS = ROOT / "build" / "reports" / "ui-decisions"
RUNNER_HEADER = """<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
"""

def rel(path: Path) -> str:
    try: return str(path.relative_to(ROOT))
    except ValueError: return str(path)

def write(path: Path, text: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding="utf-8")

def write_json(path: Path, payload) -> None:
    write(path, json.dumps(payload, indent=2, sort_keys=True, ensure_ascii=False) + "\n")

def load_rows() -> list[dict]:
    rows = []
    for path in sorted(ACTIVE.glob("*.yaml")):
        payload = json.loads(path.read_text(encoding="utf-8"))
        payload.setdefault("path", rel(path))
        rows.append(payload)
    return rows

def primitives(row: dict) -> list[dict]:
    out = []
    for item in row.get("affected_design_system_primitives", []) or []:
        out.append(item if isinstance(item, dict) else {"name": str(item), "status": "missing"})
    return out

def bullets(items) -> str:
    if not items: return "- None"
    lines = []
    for item in items:
        if isinstance(item, dict): lines.append(f"- `{item.get('name') or item}` — {item.get('status', 'declared')}")
        else: lines.append(f"- `{item}`")
    return "\n".join(lines)

def prompt(row: dict) -> str:
    batch = f"{row['id']}-IMPLEMENTATION-01"
    return "\n".join([RUNNER_HEADER.rstrip(), "", f"# UI Decision Implementation Prompt: {batch}", "", f"Batch ID: `{batch}`", f"Decision ID: `{row['id']}`", "", "## Objective", str(row.get("decision", "")), "", "Implement the decision only where declared by the generated UI-decision reports. If implementation requires wider scope, stop with a Yellow report and propose the smallest safe follow-up.", "", "## Active Source Truth to Inspect", "- `docs/truth/PRODUCT_DESIGN_TRUTH.md`", "- `docs/truth/PRODUCT_MOAT_TRUTH.md`", "- `docs/truth/IMPLEMENTATION_TRUTH.md`", "- `docs/truth/RELEASE_TRUTH.md`", "- `frontend/visual-encyclopedia/FRONTEND_AUTHORITY_INDEX.md`", "- `frontend/visual-encyclopedia/ENCYCLOPEDIA_TO_FRONTEND_OS.md`", "- `frontend/visual-encyclopedia/DESIGN_SYSTEM_TO_VISUAL_ENCYCLOPEDIA_BRIDGE.md`", f"- `frontend/visual-encyclopedia/decisions/active/{row['id']}.yaml`", f"- `build/reports/ui-decisions/{row['id']}/design-system-gap-report.md`", "", "## Allowed Scope", bullets(row.get("allowed_scope", []) or row.get("affected_swift_candidates", [])), "", "## Forbidden Scope", bullets(row.get("forbidden_scope", ["Unrelated surfaces", "Top-level IA changes", "Runtime/persistence changes unless explicitly required", "Release or device proof claims"])), "", "## Design System Expectations", bullets(primitives(row)), "", "## Visual Proof Expectations", "- Update or add previews when visual primitives change.", "- Add screenshot or rendered proof only if app UI changes land.", "- Do not claim screenshot/device/accessibility proof from generated docs alone.", "", "## Validation Expectations", "- `python3 scripts/ambitions-ui-decision-check.py`", f"- `python3 scripts/ambitions-ui-decision-sync.py --decision {row['id']}`", "- `git diff --check`", "", "## Hard Red Stop Conditions", bullets(row.get("hard_reds", [])), "", "## Rollback Expectations", bullets(row.get("rollback_expectations", [])), "", "## Runner Command", "```bash", f"scripts/ambitions-codex-train.sh {batch} build/reports/ui-decisions/{row['id']}/generated-implementation-prompt.md", "```", ""]) + "\n"

def refresh(rows: list[dict]) -> None:
    write_json(LEDGER, {"schema_version": 1, "status": "active", "authority": "subordinate_to_docs_truth", "description": "Machine-readable index of frontend UI decisions.", "decisions": [{"id": r.get("id"), "status": r.get("status"), "decision_type": r.get("decision_type"), "owner_surface_ids": r.get("owner_surface_ids", []), "path": r.get("path")} for r in rows]})
    write_json(SURFACE_MATRIX, {"schema_version": 1, "status": "generated", "description": "Generated map from active UI decisions to affected frontend surfaces and encyclopedia files.", "decisions": [{"id": r["id"], "status": r.get("status"), "owner_surface_ids": r.get("owner_surface_ids", []), "affected_encyclopedia_files": r.get("affected_encyclopedia_files", [])} for r in rows]})
    write_json(SYSTEM_MATRIX, {"schema_version": 1, "status": "generated", "description": "Generated map from active UI decisions to AmbitionsDesignSystem primitive expectations and source candidates.", "decisions": [{"id": r["id"], "status": r.get("status"), "affected_design_system_primitives": primitives(r), "affected_swift_candidates": r.get("affected_swift_candidates", []), "proof_required": r.get("proof_required", [])} for r in rows]})

def sync_one(row: dict) -> list[str]:
    out = REPORTS / row["id"]
    reports = {
        "decision-summary.md": f"# UI Decision Summary: {row['id']}\n\nStatus: generated control-plane report\nProof status: not implementation proof\n\n## Decision\n{row.get('decision','')}\n\n## Why\n{row.get('reason','')}\n\n## Owner Surfaces\n{bullets(row.get('owner_surface_ids', []))}\n\n## Proof Boundary\nThis report is not SwiftUI proof, screenshot proof, device proof, accessibility conformance proof, hosted-CI proof, release proof, or App Store readiness.\n",
        "encyclopedia-impact.md": f"# Encyclopedia Impact: {row['id']}\n\nStatus: generated impact report\nProof status: not implementation proof\n\n## Affected Encyclopedia Files\n{bullets(row.get('affected_encyclopedia_files', []))}\n\n## Affected Surfaces\n{bullets(row.get('owner_surface_ids', []))}\n",
        "design-system-gap-report.md": f"# Design System Gap Report: {row['id']}\n\nStatus: generated design-system trace\nProof status: not implementation proof\n\n## Primitive Expectations\n{bullets(primitives(row))}\n\n## Swift Source Candidates\n{bullets(row.get('affected_swift_candidates', []))}\n",
        "implementation-scope.md": f"# Implementation Scope: {row['id']}\n\nStatus: generated implementation planning artifact\nProof status: not implementation proof\n\n## Allowed Source Candidates\n{bullets(row.get('allowed_scope', []) or row.get('affected_swift_candidates', []))}\n\n## Forbidden Scope\n{bullets(row.get('forbidden_scope', []))}\n",
        "proof-contract.md": f"# Proof Contract: {row['id']}\n\nStatus: generated proof contract\nProof status: not implementation proof\n\n## Required Proof\n{bullets(row.get('proof_required', []))}\n\n## Explicit Non-Proof\n- UI decision docs do not prove SwiftUI implementation.\n- Generated reports do not prove screenshot parity.\n- Generated prompts do not prove accessibility conformance.\n- Receipts are not proof unless they describe current evidence from landed changes.\n",
        "rollback-plan.md": f"# Rollback Plan: {row['id']}\n\nStatus: generated rollback artifact\n\n## Rollback Expectations\n{bullets(row.get('rollback_expectations', []))}\n\n## Generated Artifact Cleanup\n- Remove `build/reports/ui-decisions/{row['id']}/` if the decision is deleted.\n- Regenerate UI decision matrices.\n",
        "generated-implementation-prompt.md": prompt(row),
        "summary.json": json.dumps({"id": row["id"], "status": row.get("status"), "owner_surface_ids": row.get("owner_surface_ids", []), "proof_status": "not_implementation_proof"}, indent=2, sort_keys=True) + "\n",
    }
    written = []
    for name, text in reports.items():
        path = out / name
        write(path, text)
        written.append(rel(path))
    return written

def main() -> int:
    parser = argparse.ArgumentParser(description="Sync active UI decisions into frontend control-plane reports.")
    parser.add_argument("--decision")
    parser.add_argument("--include-draft", action="store_true")
    args = parser.parse_args()
    rows = load_rows()
    refresh(rows)
    chosen = [r for r in rows if r["id"] == args.decision] if args.decision else [r for r in rows if args.include_draft or r.get("status") == "active"]
    generated = []
    for row in chosen:
        generated.extend(sync_one(row))
    print(json.dumps({"synced": [r["id"] for r in chosen], "generated": generated}, indent=2))
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
