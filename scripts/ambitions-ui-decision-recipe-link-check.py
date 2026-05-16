#!/usr/bin/env python3
from __future__ import annotations
import argparse, json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
FRONTEND = ROOT / "frontend" / "visual-encyclopedia"
ACTIVE = FRONTEND / "decisions" / "active"
SURFACE_MATRIX = FRONTEND / "trace" / "UI_DECISION_TO_SURFACE_MATRIX.yaml"
SYSTEM_MATRIX = FRONTEND / "trace" / "UI_DECISION_TO_DESIGN_SYSTEM_MATRIX.yaml"


def load_json(path: Path):
    return json.loads(path.read_text(encoding="utf-8"))


def active_decisions() -> list[dict]:
    return [load_json(path) for path in sorted(ACTIVE.glob("*.yaml"))]


def decision_ids(payload: dict) -> set[str]:
    return {str(row.get("id")) for row in payload.get("decisions", []) if row.get("id")}


def main() -> int:
    parser = argparse.ArgumentParser(description="Validate UI decision trace linkage into recipes and design-system primitive expectations.")
    parser.add_argument("--json", action="store_true")
    args = parser.parse_args()

    errors: list[str] = []
    rows = active_decisions()
    surface_payload = load_json(SURFACE_MATRIX) if SURFACE_MATRIX.exists() else {"decisions": []}
    system_payload = load_json(SYSTEM_MATRIX) if SYSTEM_MATRIX.exists() else {"decisions": []}
    surface_ids = decision_ids(surface_payload)
    system_ids = decision_ids(system_payload)

    for row in rows:
        did = row.get("id")
        if did not in surface_ids:
            errors.append(f"{did}: missing from UI_DECISION_TO_SURFACE_MATRIX.yaml")
        if did not in system_ids:
            errors.append(f"{did}: missing from UI_DECISION_TO_DESIGN_SYSTEM_MATRIX.yaml")
        if row.get("status") == "active" and not row.get("owner_surface_ids"):
            errors.append(f"{did}: active decision has no owner_surface_ids")
        if row.get("status") == "active" and not row.get("affected_encyclopedia_files"):
            errors.append(f"{did}: active decision has no affected_encyclopedia_files")
        primitives = row.get("affected_design_system_primitives", []) or []
        if row.get("status") == "active" and not primitives:
            errors.append(f"{did}: active decision has no design-system primitive expectation")
        for primitive in primitives:
            if isinstance(primitive, dict):
                name = primitive.get("name")
                status = primitive.get("status")
                if not name:
                    errors.append(f"{did}: primitive missing name")
                if status not in ("existing", "missing", "not_applicable"):
                    errors.append(f"{did}: primitive `{name}` has invalid status `{status}`")

    result = {"status": "green" if not errors else "red", "decision_count": len(rows), "errors": errors}
    if args.json:
        print(json.dumps(result, indent=2, sort_keys=True))
    elif errors:
        print("UI decision recipe link check: RED")
        print("\n".join(f"- {error}" for error in errors))
    else:
        print(f"UI decision recipe link check: GREEN ({len(rows)} decisions)")
    return 0 if not errors else 1


if __name__ == "__main__":
    raise SystemExit(main())
