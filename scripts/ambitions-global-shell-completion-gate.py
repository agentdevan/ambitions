#!/usr/bin/env python3
from __future__ import annotations

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MANIFEST = ROOT / "docs" / "implementation" / "global_shell_full_bleed_manifest.yml"
ARTIFACTS = ROOT / "docs" / "validation" / "global_shell_artifacts.json"
REQUIRED_DOCS = [
    ROOT / "docs" / "truth" / "GLOBAL_SHELL_INTEGRATION_LAW.md",
    ROOT / "docs" / "design" / "targets" / "global_shell" / "full_bleed_shell_visual_target.md",
    ROOT / "docs" / "design" / "targets" / "global_shell" / "full_bleed_shell_acceptance_rubric.md",
]
REQUIRED_ROUTE_IDS = [
    "today.root",
    "today.step_detail",
    "goals.root",
    "goals.goal_detail",
    "time.root",
    "time.bucket_detail",
    "you.root",
    "you.settings_detail",
    "capture.keyboard",
    "search.overlay",
    "closure.overlay",
    "inspection.proof",
]


def main() -> int:
    findings: list[str] = []
    for path in REQUIRED_DOCS:
        if not path.exists():
            findings.append(f"{path.relative_to(ROOT)} missing")
    if not MANIFEST.exists():
        findings.append(f"{MANIFEST.relative_to(ROOT)} missing")
    else:
        text = MANIFEST.read_text(encoding="utf-8", errors="replace")
        for route_id in REQUIRED_ROUTE_IDS:
            if f"  {route_id}:" not in text:
                findings.append(f"manifest missing route {route_id}")
    if not ARTIFACTS.exists():
        findings.append(f"{ARTIFACTS.relative_to(ROOT)} missing")
    else:
        payload = json.loads(ARTIFACTS.read_text(encoding="utf-8"))
        listed = set(payload.get("required_routes", []))
        for route_id in REQUIRED_ROUTE_IDS:
            if route_id not in listed:
                findings.append(f"artifact manifest missing route {route_id}")
    if findings:
        print("ambitions-global-shell-completion-gate RED")
        for finding in findings:
            print(f"- {finding}")
        return 1
    print("ambitions-global-shell-completion-gate GREEN")
    return 0


if __name__ == "__main__":
    sys.exit(main())
