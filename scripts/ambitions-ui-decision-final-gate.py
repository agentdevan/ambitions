#!/usr/bin/env python3
from __future__ import annotations
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
FRONTEND = ROOT / "frontend" / "visual-encyclopedia"
ACTIVE = FRONTEND / "decisions" / "active"
LEDGER = FRONTEND / "decisions" / "UI_DECISION_LEDGER.yaml"
SURFACE_MATRIX = FRONTEND / "trace" / "UI_DECISION_TO_SURFACE_MATRIX.yaml"
SYSTEM_MATRIX = FRONTEND / "trace" / "UI_DECISION_TO_DESIGN_SYSTEM_MATRIX.yaml"
REPORT_ROOT = ROOT / "build" / "reports" / "ui-decisions"
OUT_JSON = ROOT / "build" / "reports" / "ui-decision-final-gate.json"
OUT_MD = ROOT / "build" / "reports" / "ui-decision-final-gate.md"

REQUIRED_REPORTS = [
    "decision-summary.md",
    "design-system-gap-report.md",
    "proof-contract.md",
    "generated-implementation-prompt.md",
]
REQUIRED_PROMPT_MARKERS = [
    "<!-- AMBITIONS_RUNNER_REQUIRED: true -->",
    "<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->",
    "<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->",
]


def load_json(path: Path):
    return json.loads(path.read_text(encoding="utf-8"))


def rel(path: Path) -> str:
    try:
        return str(path.relative_to(ROOT))
    except ValueError:
        return str(path)


def decision_rows() -> list[dict]:
    return [load_json(path) for path in sorted(ACTIVE.glob("*.yaml"))]


def ids_from_matrix(path: Path) -> set[str]:
    if not path.exists():
        return set()
    payload = load_json(path)
    return {str(row.get("id")) for row in payload.get("decisions", []) if row.get("id")}


def write(path: Path, text: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding="utf-8")


def main() -> int:
    rows = decision_rows()
    active_ids = {row.get("id") for row in rows if row.get("status") == "active"}
    surface_ids = ids_from_matrix(SURFACE_MATRIX)
    system_ids = ids_from_matrix(SYSTEM_MATRIX)
    errors: list[str] = []
    checks: dict[str, object] = {
        "decision_count": len(rows),
        "active_decision_count": len(active_ids),
        "ledger_exists": LEDGER.exists(),
        "surface_matrix_exists": SURFACE_MATRIX.exists(),
        "design_system_matrix_exists": SYSTEM_MATRIX.exists(),
    }
    if not LEDGER.exists():
        errors.append("missing UI decision ledger")
    if not SURFACE_MATRIX.exists():
        errors.append("missing UI decision surface matrix")
    if not SYSTEM_MATRIX.exists():
        errors.append("missing UI decision design-system matrix")
    for decision_id in sorted(active_ids):
        if decision_id not in surface_ids:
            errors.append(f"{decision_id}: missing surface matrix row")
        if decision_id not in system_ids:
            errors.append(f"{decision_id}: missing design-system matrix row")
        report_dir = REPORT_ROOT / str(decision_id)
        for name in REQUIRED_REPORTS:
            path = report_dir / name
            if not path.exists():
                errors.append(f"{decision_id}: missing generated report {name}")
        prompt = report_dir / "generated-implementation-prompt.md"
        if prompt.exists():
            text = prompt.read_text(encoding="utf-8")
            for marker in REQUIRED_PROMPT_MARKERS:
                if marker not in text:
                    errors.append(f"{decision_id}: generated prompt missing runner marker {marker}")
    status = "green" if not errors else "red"
    payload = {"status": status, "checks": checks, "errors": errors}
    write(OUT_JSON, json.dumps(payload, indent=2, sort_keys=True) + "\n")
    lines = ["# UI Decision Final Gate", "", f"Status: `{status}`", "", "## Checks"]
    for key, value in checks.items():
        lines.append(f"- {key}: {value}")
    lines.extend(["", "## Errors"])
    lines.extend(f"- {error}" for error in (errors or ["None"]))
    write(OUT_MD, "\n".join(lines).rstrip() + "\n")
    print(status.upper())
    return 0 if status == "green" else 1


if __name__ == "__main__":
    raise SystemExit(main())
