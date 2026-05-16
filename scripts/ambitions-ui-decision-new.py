#!/usr/bin/env python3
from __future__ import annotations
import argparse, json, re
from datetime import date
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ACTIVE = ROOT / "frontend" / "visual-encyclopedia" / "decisions" / "active"
LEDGER = ROOT / "frontend" / "visual-encyclopedia" / "decisions" / "UI_DECISION_LEDGER.yaml"
ID_RE = re.compile(r"^UID-\d{4}-\d{2}-\d{2}-[a-z0-9][a-z0-9-]*$")

def rel(path: Path) -> str:
    try: return str(path.relative_to(ROOT))
    except ValueError: return str(path)

def write_json(path: Path, payload: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload, indent=2, sort_keys=True, ensure_ascii=False) + "\n", encoding="utf-8")

def load_decisions() -> list[dict]:
    rows = []
    for path in sorted(ACTIVE.glob("*.yaml")):
        rows.append(json.loads(path.read_text(encoding="utf-8")))
    return rows

def refresh_ledger() -> None:
    rows = load_decisions()
    write_json(LEDGER, {
        "schema_version": 1,
        "status": "active",
        "authority": "subordinate_to_docs_truth",
        "description": "Machine-readable index of frontend UI decisions.",
        "decisions": [{"id": r.get("id"), "status": r.get("status"), "decision_type": r.get("decision_type"), "owner_surface_ids": r.get("owner_surface_ids", []), "path": rel(ACTIVE / f"{r.get('id')}.yaml")} for r in rows],
    })

def main() -> int:
    parser = argparse.ArgumentParser(description="Create a new Ambitions frontend UI decision.")
    parser.add_argument("--id")
    parser.add_argument("--decision", required=True)
    parser.add_argument("--reason", default="Decision captured for frontend authority propagation.")
    parser.add_argument("--type", default="visual_behavior", dest="decision_type")
    parser.add_argument("--surface", action="append", default=[])
    parser.add_argument("--encyclopedia-file", action="append", default=[])
    parser.add_argument("--primitive", action="append", default=[])
    parser.add_argument("--swift-candidate", action="append", default=[])
    parser.add_argument("--status", default="draft", choices=["draft", "active", "superseded"])
    args = parser.parse_args()
    decision_id = args.id or f"UID-{date.today().isoformat()}-" + re.sub(r"[^a-z0-9]+", "-", args.decision.lower()).strip("-")[:64]
    if not ID_RE.match(decision_id):
        raise SystemExit("Invalid decision id. Use UID-YYYY-MM-DD-kebab-slug.")
    path = ACTIVE / f"{decision_id}.yaml"
    if path.exists():
        raise SystemExit(f"Decision already exists: {rel(path)}")
    payload = {
        "schema_version": 1,
        "id": decision_id,
        "status": args.status,
        "decision_type": args.decision_type,
        "decision": args.decision,
        "reason": args.reason,
        "replaces": [],
        "owner_surface_ids": args.surface,
        "affected_encyclopedia_files": args.encyclopedia_file,
        "affected_design_system_primitives": [{"name": item, "status": "missing"} for item in args.primitive],
        "affected_swift_candidates": args.swift_candidate,
        "proof_required": ["visual_recipe_updated_or_confirmed", "design_system_primitive_exists_or_gap_recorded", "implementation_prompt_generated"],
        "hard_reds": ["Do not claim implementation, screenshot, device, accessibility, CI, release, or App Store readiness from decision docs alone.", "Do not reintroduce Plan as an active top-level destination."],
        "rollback_expectations": ["Remove or supersede the decision file.", "Regenerate UI decision matrices and reports."],
        "implementation_proof_status": "not_proven",
    }
    write_json(path, payload)
    refresh_ledger()
    print(f"Created {rel(path)}")
    print(f"Next: python3 scripts/ambitions-ui-decision-sync.py --decision {decision_id}")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
