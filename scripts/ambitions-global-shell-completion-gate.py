#!/usr/bin/env python3
from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MANIFEST = ROOT / "docs" / "implementation" / "global_shell_full_bleed_manifest.yml"
ARTIFACTS = ROOT / "docs" / "validation" / "global_shell_artifacts.json"
TARGET = ROOT / "docs" / "design" / "targets" / "time" / "lifeshape_field_visual_target.md"
RUBRIC = ROOT / "docs" / "design" / "targets" / "time" / "lifeshape_field_acceptance_rubric.md"

REQUIRED_ROUTES = [
    "today.root",
    "goals.root",
    "time.root",
    "you.root",
    "today.step_detail",
    "goals.goal_detail",
    "time.bucket_detail",
    "you.settings_detail",
    "capture.keyboard",
    "search.overlay",
    "closure.overlay",
    "inspection.proof",
]

REQUIRED_MANIFEST_SNIPPETS = [
    "codex_max_status: visual_review_ready",
    "global_green_requires_all_routes_accepted: true",
    "local_paths_are_not_proof: true",
    "physical_device_required_for_visual_green: true",
    "no_partial_global_closeout: true",
    "crown_mode:",
    "dock_mode:",
    "atmosphere_mode:",
    "primary_object:",
]

REQUIRED_TARGET_SNIPPETS = [
    "full-bleed",
    "LifeShape Field Band",
    "not a radial dial",
    "Integrated Continuity Dock",
]

REQUIRED_RUBRIC_SNIPPETS = [
    "Shell Integration",
    "No hard header slab",
    "No pasted dock pill",
    "Global Shell Completion Note",
]


def text(path: Path) -> str:
    return path.read_text(encoding="utf-8", errors="replace")


def main() -> int:
    findings: list[str] = []

    for path in [MANIFEST, ARTIFACTS, TARGET, RUBRIC]:
        if not path.exists():
            findings.append(f"missing required file: {path.relative_to(ROOT).as_posix()}")

    if MANIFEST.exists():
        manifest = text(MANIFEST)
        for route in REQUIRED_ROUTES:
            if f"id: {route}" not in manifest:
                findings.append(f"manifest missing required route: {route}")
        for snippet in REQUIRED_MANIFEST_SNIPPETS:
            if snippet not in manifest:
                findings.append(f"manifest missing required contract: {snippet}")

    if ARTIFACTS.exists():
        artifacts = text(ARTIFACTS)
        for route in ["today.root", "goals.root", "time.root", "you.root", "capture.keyboard", "search.overlay", "closure.overlay", "inspection.proof"]:
            if route not in artifacts:
                findings.append(f"artifact manifest missing route evidence: {route}")
        if "\"all_routes_accepted\": true" in artifacts and "independent_visual_reviewer" not in artifacts:
            findings.append("artifact manifest claims accepted routes without independent_visual_reviewer")

    if TARGET.exists():
        target = text(TARGET)
        for snippet in REQUIRED_TARGET_SNIPPETS:
            if snippet not in target:
                findings.append(f"target missing required snippet: {snippet}")

    if RUBRIC.exists():
        rubric = text(RUBRIC)
        for snippet in REQUIRED_RUBRIC_SNIPPETS:
            if snippet not in rubric:
                findings.append(f"rubric missing required snippet: {snippet}")

    if findings:
        print("ambitions-global-shell-completion-gate RED")
        for finding in findings:
            print(f"- {finding}")
        return 1

    print("ambitions-global-shell-completion-gate GREEN")
    return 0


if __name__ == "__main__":
    sys.exit(main())
