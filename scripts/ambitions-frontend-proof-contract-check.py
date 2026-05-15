#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path
from typing import Any

from ambitions_frontend_authority_common import BATCH_ID, PROOF_CONTRACT_SCHEMA_PATH, REPORT_DIR, write_json, write_text


REQUIRED_PROMPT_MARKERS = [
    "## Scenario Proof Requirements",
    "## Interaction Grammar Requirements",
    "## Accessibility Requirements",
    "## Visual Proof Requirements",
    "## Implementation Receipt Requirements",
    "## Hard Red Conditions",
]


def build_report() -> dict[str, Any]:
    prompt_dir = Path("prompts/generated/frontend")
    prompt_paths = sorted(prompt_dir.glob("*.md")) if prompt_dir.exists() else []
    issues: list[str] = []
    if not PROOF_CONTRACT_SCHEMA_PATH.exists():
        issues.append(f"missing schema: {PROOF_CONTRACT_SCHEMA_PATH.relative_to(Path.cwd())}")
    for path in prompt_paths:
        text = path.read_text(encoding="utf-8")
        if not all(marker in text for marker in REQUIRED_PROMPT_MARKERS):
            issues.append(f"prompt missing proof contract sections: {path.relative_to(Path.cwd())}")
    return {
        "batch_id": BATCH_ID,
        "generated_from_batch": BATCH_ID,
        "status": "green" if not issues else "red",
        "prompt_count": len(prompt_paths),
        "issues": issues,
    }


def render_md(report: dict[str, Any]) -> str:
    lines = [
        "# Frontend Proof Contract Check",
        "",
        f"Batch: `{report['batch_id']}`",
        f"Status: `{report['status']}`",
        f"Prompt count: `{report['prompt_count']}`",
        "",
        "## Issues",
    ]
    lines.extend(f"- {item}" for item in report["issues"] or ["None"])
    return "\n".join(lines).rstrip() + "\n"


def main() -> int:
    report = build_report()
    write_json(REPORT_DIR / "frontend-proof-contract-check.json", report)
    write_text(REPORT_DIR / "frontend-proof-contract-check.md", render_md(report))
    print(report["status"].upper())
    return 0 if report["status"] == "green" else 1


if __name__ == "__main__":
    raise SystemExit(main())
