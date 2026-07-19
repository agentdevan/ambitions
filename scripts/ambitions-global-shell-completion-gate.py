#!/usr/bin/env python3
from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MANIFEST = ROOT / "docs/implementation/global_shell_full_bleed_manifest.yml"
ARTIFACTS = ROOT / "docs/validation/global_shell_artifacts.json"
TARGET = ROOT / "docs/design/targets/time/lifeshape_field_visual_target.md"
RUBRIC = ROOT / "docs/design/targets/time/lifeshape_field_acceptance_rubric.md"
ROUTES = ["today.root", "goals.root", "time.root", "you.root", "capture.keyboard", "search.overlay", "closure.overlay", "inspection.proof"]


def t(path: Path) -> str:
    return path.read_text(encoding="utf-8", errors="replace")


def main() -> int:
    findings = []
    for path in [MANIFEST, ARTIFACTS, TARGET, RUBRIC]:
        if not path.exists():
            findings.append(f"missing {path.relative_to(ROOT).as_posix()}")
    if MANIFEST.exists():
        manifest = t(MANIFEST)
        for route in ROUTES:
            if route not in manifest:
                findings.append(f"manifest missing {route}")
        for marker in ["status: not_started", "status: implemented", "status: validated", "status: attached"]:
            if marker in manifest:
                findings.append(f"manifest has incomplete marker {marker}")
    if ARTIFACTS.exists():
        artifacts = t(ARTIFACTS)
        for route in ROUTES:
            if route not in artifacts:
                findings.append(f"artifacts missing {route}")
        for marker in ["missing_evidence", "false"]:
            if marker in artifacts:
                findings.append(f"artifacts have incomplete marker {marker}")
    if TARGET.exists():
        target = t(TARGET)
        for snippet in ["full-bleed", "LifeShape Field Band", "not a radial dial"]:
            if snippet not in target:
                findings.append(f"target missing {snippet}")
    if RUBRIC.exists():
        rubric = t(RUBRIC)
        for snippet in ["Shell Integration", "No hard header slab", "No pasted dock pill"]:
            if snippet not in rubric:
                findings.append(f"rubric missing {snippet}")
    if findings:
        print("ambitions-global-shell-completion-gate RED")
        for finding in findings:
            print(f"- {finding}")
        return 1
    print("ambitions-global-shell-completion-gate GREEN")
    return 0


if __name__ == "__main__":
    sys.exit(main())
