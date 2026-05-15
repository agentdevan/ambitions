#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path
from typing import Any

from ambitions_frontend_authority_common import BATCH_ID, RECEIPT_DIR, write_json, write_text


REQUIRED_FIELDS = {
    "batch_id",
    "surface_ids",
    "recipe_ids",
    "source_files_changed",
    "generated_packet_paths",
    "tokens_used",
    "contracts_used",
    "scenario_proof",
    "interaction_proof",
    "accessibility_proof",
    "dynamic_type_proof",
    "reduce_motion_proof",
    "visual_proof",
    "preview_targets",
    "screenshots",
    "tests_run",
    "drift_check_result",
    "known_gaps",
    "implementation_status",
    "proof_status",
    "rollback_notes",
}


def build_report() -> dict[str, Any]:
    receipts = sorted(RECEIPT_DIR.glob("**/*.json")) if RECEIPT_DIR.exists() else []
    issues: list[str] = []
    for path in receipts:
        try:
            payload = __import__("json").loads(path.read_text(encoding="utf-8"))
        except Exception as exc:  # pragma: no cover
            issues.append(f"{path.relative_to(Path.cwd())}: invalid json ({exc})")
            continue
        missing = sorted(REQUIRED_FIELDS - set(payload))
        if missing:
            issues.append(f"{path.relative_to(Path.cwd())}: missing {missing}")
        for field in ("source_files_changed", "generated_packet_paths"):
            for item in payload.get(field, []):
                if not Path(item).exists():
                    issues.append(f"{path.relative_to(Path.cwd())}: missing referenced path {item}")
    return {
        "batch_id": BATCH_ID,
        "generated_from_batch": BATCH_ID,
        "status": "green" if not issues else "red",
        "receipt_count": len(receipts),
        "issues": issues,
    }


def render_md(report: dict[str, Any]) -> str:
    lines = [
        "# Frontend Receipt Check",
        "",
        f"Batch: `{report['batch_id']}`",
        f"Status: `{report['status']}`",
        f"Receipt count: `{report['receipt_count']}`",
        "",
        "## Issues",
    ]
    lines.extend(f"- {item}" for item in report["issues"] or ["None"])
    return "\n".join(lines).rstrip() + "\n"


def main() -> int:
    report = build_report()
    write_json(Path("build/reports/frontend-receipt-check.json"), report)
    write_text(Path("build/reports/frontend-receipt-check.md"), render_md(report))
    print(report["status"].upper())
    return 0 if report["status"] == "green" else 1


if __name__ == "__main__":
    raise SystemExit(main())
