#!/usr/bin/env python3
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
VISUAL = ROOT / "artifacts" / "object-stage-mega-train" / "visual-qa"
RELEASE = ROOT / "artifacts" / "object-stage-mega-train" / "release-readiness"
OUT = ROOT / "artifacts" / "object-stage-mega-train" / "screenshot-visual-release-train-closeout.md"

required = [
    "scripts/visual_qa/capture_object_stage_screenshots.sh",
    "scripts/visual_qa/package_screenshot_proof.py",
    "scripts/visual_qa/screenshot_diff_gate.py",
    "scripts/release_readiness/release_readiness_gate.py",
    "artifacts/object-stage-mega-train/visual-qa/screenshot-capture-matrix.json",
    "artifacts/object-stage-mega-train/visual-qa/screenshot-packaging-report.md",
    "artifacts/object-stage-mega-train/visual-qa/visual-qa-diff-gate-report.md",
    "artifacts/object-stage-mega-train/release-readiness/release-readiness-gates-report.md",
]
missing = [path for path in required if not (ROOT / path).exists()]
if missing:
    raise SystemExit("Missing gate train files: " + ", ".join(missing))

OUT.write_text('''# Screenshot / Visual QA / Release Gate Train Closeout

Status: `GREEN_GATE_TRAIN_INSTALLED`

This closeout verifies the screenshot packaging, screenshot diff, and release-readiness gate train exists in source.

## Installed gate files

- `scripts/visual_qa/capture_object_stage_screenshots.sh`
- `scripts/visual_qa/package_screenshot_proof.py`
- `scripts/visual_qa/screenshot_diff_gate.py`
- `scripts/release_readiness/release_readiness_gate.py`

## Installed proof files

- `artifacts/object-stage-mega-train/visual-qa/screenshot-capture-matrix.json`
- `artifacts/object-stage-mega-train/visual-qa/screenshot-packaging-report.md`
- `artifacts/object-stage-mega-train/visual-qa/visual-qa-diff-gate-report.md`
- `artifacts/object-stage-mega-train/release-readiness/release-readiness-gates-report.md`

## Non-claims

- Screenshot approval is not claimed.
- Visual QA approval is not claimed.
- Release readiness is not claimed.
- TestFlight, App Store, physical-device, privacy/legal, and human release approval remain separate gates.

## Final state

The gate train is installed. It is ready for screenshot capture, baseline comparison, and conservative release-readiness evaluation.
''', encoding="utf-8")
print("Screenshot visual release gate closeout written.")
