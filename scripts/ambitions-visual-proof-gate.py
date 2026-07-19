#!/usr/bin/env python3
from __future__ import annotations

import sys
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

REQUIRED = [
    "docs/truth/IMPLEMENTATION_ACCEPTANCE_TRUTH.md",
    "docs/truth/README.md",
    "docs/design/targets/time/lifeshape_field_visual_target.md",
    "docs/design/targets/time/lifeshape_field_acceptance_rubric.md",
    "docs/design/red_fixtures/time/current_failed_lifeshape_field.png",
    "docs/design/red_fixtures/time/current_failed_lifeshape_field.md",
    "docs/implementation/global_shell_full_bleed_manifest.yml",
    "docs/validation/global_shell_artifacts.json",
    "scripts/ambitions-global-shell-completion-gate.py",
]

REQUIRED_SNIPPETS = {
    "docs/truth/README.md": ["Global Shell Integration Law", "Full-bleed means atmosphere bleeds"],
    "docs/design/targets/time/lifeshape_field_visual_target.md": ["full-bleed", "LifeShape Field Band", "not a radial dial", "Integrated Continuity Dock"],
    "docs/design/targets/time/lifeshape_field_acceptance_rubric.md": ["Shell Integration", "No hard header slab", "No pasted dock pill"],
}

FORBIDDEN_CLOSEOUT_PHRASES = ["visual proof inspected"]


def changed_paths() -> set[str]:
    result = subprocess.run(["git", "diff", "--name-only", "HEAD", "--"], cwd=ROOT, check=False, text=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    paths = set(result.stdout.splitlines())
    status = subprocess.run(["git", "status", "--porcelain"], cwd=ROOT, check=False, text=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    for line in status.stdout.splitlines():
        if line:
            paths.add(line[3:].strip())
    return paths


def main() -> int:
    findings: list[str] = []
    changed = changed_paths()

    for relative in REQUIRED:
        if not (ROOT / relative).exists():
            findings.append(f"{relative}: required visual/global-shell artifact is missing")

    for relative, snippets in REQUIRED_SNIPPETS.items():
        path = ROOT / relative
        if not path.exists():
            continue
        text = path.read_text(encoding="utf-8", errors="replace")
        for snippet in snippets:
            if snippet not in text:
                findings.append(f"{relative}: missing required snippet `{snippet}`")

    artifact_manifest = ROOT / "docs" / "validation" / "global_shell_artifacts.json"
    if artifact_manifest.exists():
        manifest_text = artifact_manifest.read_text(encoding="utf-8", errors="replace")
        for route in ["today.root", "goals.root", "time.root", "you.root", "capture.keyboard", "search.overlay", "closure.overlay", "inspection.proof"]:
            if route not in manifest_text:
                findings.append(f"docs/validation/global_shell_artifacts.json: missing route evidence `{route}`")

    for path in (ROOT / "docs").rglob("*.md"):
        relative = path.relative_to(ROOT).as_posix()
        if relative not in changed:
            continue
        if relative.startswith(("docs/truth/", "docs/design/targets/", "docs/design/red_fixtures/")):
            continue
        text = path.read_text(encoding="utf-8", errors="replace").lower()
        for phrase in FORBIDDEN_CLOSEOUT_PHRASES:
            if phrase in text and "independent visual reviewer" not in text:
                findings.append(f"{relative}: '{phrase}' appears without independent visual reviewer")

    if findings:
        print("ambitions-visual-proof-gate RED")
        for finding in findings:
            print(f"- {finding}")
        return 1

    print("ambitions-visual-proof-gate GREEN")
    return 0


if __name__ == "__main__":
    sys.exit(main())
