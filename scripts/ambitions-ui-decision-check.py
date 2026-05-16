#!/usr/bin/env python3
from __future__ import annotations
import argparse, json, re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DECISIONS = ROOT / "frontend" / "visual-encyclopedia" / "decisions"
ACTIVE = DECISIONS / "active"
LEDGER = DECISIONS / "UI_DECISION_LEDGER.yaml"
ID_RE = re.compile(r"^UID-\d{4}-\d{2}-\d{2}-[a-z0-9][a-z0-9-]*$")
REQUIRED = ("id", "status", "decision_type", "decision", "reason", "owner_surface_ids", "proof_required", "rollback_expectations", "implementation_proof_status")
BANNED = ("dashboard", "assistant tab", "chatbot ui", "ai recommendation card", "daytimelinerail", "best next move", "overdue", "streak broken")
FALSE_PROOF = ("release ready", "app store ready", "device proven", "screenshot proven", "accessibility conformant", "ci proven", "ship ready")

def rel(path: Path) -> str:
    try: return str(path.relative_to(ROOT))
    except ValueError: return str(path)

def write_json(path: Path, payload) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload, indent=2, sort_keys=True, ensure_ascii=False) + "\n", encoding="utf-8")

def load_rows() -> list[dict]:
    rows = []
    for path in sorted(ACTIVE.glob("*.yaml")):
        payload = json.loads(path.read_text(encoding="utf-8"))
        payload.setdefault("path", rel(path))
        rows.append(payload)
    return rows

def refresh_ledger(rows: list[dict]) -> None:
    write_json(LEDGER, {"schema_version": 1, "status": "active", "authority": "subordinate_to_docs_truth", "description": "Machine-readable index of frontend UI decisions.", "decisions": [{"id": r.get("id"), "status": r.get("status"), "decision_type": r.get("decision_type"), "owner_surface_ids": r.get("owner_surface_ids", []), "path": r.get("path")} for r in rows]})

def validate(row: dict) -> list[str]:
    errors = []
    decision_id = str(row.get("id", ""))
    if not ID_RE.match(decision_id):
        errors.append(f"{decision_id or '<missing>'}: invalid id format")
    for field in REQUIRED:
        if row.get(field) in (None, "", [], {}):
            errors.append(f"{decision_id}: missing `{field}`")
    if row.get("status") not in ("draft", "active", "superseded"):
        errors.append(f"{decision_id}: invalid status `{row.get('status')}`")
    if row.get("implementation_proof_status") not in ("not_proven", "proof_required_after_implementation", "superseded"):
        errors.append(f"{decision_id}: implementation_proof_status must not claim proof")
    for primitive in row.get("affected_design_system_primitives", []) or []:
        if isinstance(primitive, dict) and primitive.get("status") not in ("existing", "missing", "not_applicable"):
            errors.append(f"{decision_id}: invalid primitive status `{primitive.get('status')}`")
    text = (str(row.get("decision", "")) + "\n" + str(row.get("reason", "")) + "\n" + " ".join(map(str, row.get("replaces", []) or []))).lower()
    for term in BANNED:
        if term in text:
            errors.append(f"{decision_id}: banned active term `{term}`")
    for term in FALSE_PROOF:
        if term in text:
            errors.append(f"{decision_id}: false proof wording `{term}`")
    return errors

def main() -> int:
    parser = argparse.ArgumentParser(description="Validate frontend UI decision files.")
    parser.add_argument("--json", action="store_true")
    args = parser.parse_args()
    rows = load_rows()
    refresh_ledger(rows)
    errors = []
    for row in rows:
        errors.extend(validate(row))
    payload = {"status": "green" if not errors else "red", "decision_count": len(rows), "errors": errors}
    if args.json:
        print(json.dumps(payload, indent=2, sort_keys=True))
    elif errors:
        print("UI decision check: RED")
        print("\n".join(f"- {error}" for error in errors))
    else:
        print(f"UI decision check: GREEN ({len(rows)} decisions)")
    return 0 if not errors else 1

if __name__ == "__main__":
    raise SystemExit(main())
