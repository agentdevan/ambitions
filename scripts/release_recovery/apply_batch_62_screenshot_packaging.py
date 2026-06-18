#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
VISUAL = ROOT / "scripts" / "visual_qa"
ARTIFACT = ROOT / "artifacts" / "object-stage-mega-train" / "visual-qa"
WORKFLOW = ROOT / ".github" / "workflows" / "ambitions-autopilot-train.yml"
VISUAL.mkdir(parents=True, exist_ok=True)
ARTIFACT.mkdir(parents=True, exist_ok=True)

capture = VISUAL / "capture_object_stage_screenshots.sh"
capture.write_text(
    '''#!/usr/bin/env bash
set -euo pipefail

SCHEME="${SCHEME:-Ambitions}"
DESTINATION="${DESTINATION:-platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5}"
OUTPUT_ROOT="${OUTPUT_ROOT:-artifacts/object-stage-mega-train/visual-qa/screenshot-packaging}"
RESULT_ROOT="$OUTPUT_ROOT/result-bundles"
mkdir -p "$RESULT_ROOT"

if command -v xcodegen >/dev/null 2>&1; then
  xcodegen generate
fi

run_ui_test() {
  local name="$1"
  local only_testing="$2"
  local bundle="$RESULT_ROOT/${name}.xcresult"
  rm -rf "$bundle"
  xcodebuild \
    -project Ambitions.xcodeproj \
    -scheme "$SCHEME" \
    -destination "$DESTINATION" \
    -resultBundlePath "$bundle" \
    -only-testing:"$only_testing" \
    test CODE_SIGNING_ALLOWED=NO
}

run_ui_test "canonical-shell-tabs" "AmbitionsUITests/AmbitionsUITests/testAFRI005ShellScreenshotBaselineCapturesCanonicalTabs"
run_ui_test "today-reconstruction-matrix" "AmbitionsUITests/AmbitionsUITests/testAMB962TodayReconstructionScreenshotMatrix"
run_ui_test "you-reconstruction-matrix" "AmbitionsUITests/AmbitionsUITests/testAMB966YouReconstructionScreenshotMatrix"
run_ui_test "capture-composer-matrix" "AmbitionsUITests/AmbitionsUITests/testAMB967CaptureCreateGoalScreenshotMatrix"

python3 scripts/visual_qa/package_screenshot_proof.py \
  --root "$OUTPUT_ROOT" \
  --output "$OUTPUT_ROOT/screenshot-package-manifest.json"
''',
    encoding="utf-8",
)
capture.chmod(0o755)

packager = VISUAL / "package_screenshot_proof.py"
packager.write_text(
    '''#!/usr/bin/env python3
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
from datetime import datetime, timezone


def sha256(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def main() -> int:
    parser = argparse.ArgumentParser(description="Package Ambitions screenshot proof artifacts.")
    parser.add_argument("--root", default="artifacts/object-stage-mega-train/visual-qa/screenshot-packaging")
    parser.add_argument("--output", default=None)
    args = parser.parse_args()

    root = Path(args.root)
    root.mkdir(parents=True, exist_ok=True)
    images = sorted([p for p in root.rglob("*.png") if p.is_file()])
    result_bundles = sorted([p for p in root.rglob("*.xcresult") if p.exists()])
    manifest = {
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "status": "GREEN_SCREENSHOTS_PACKAGED" if images else "YELLOW_NO_SCREENSHOT_IMAGES_FOUND",
        "root": root.as_posix(),
        "image_count": len(images),
        "result_bundle_count": len(result_bundles),
        "images": [
            {"path": p.as_posix(), "bytes": p.stat().st_size, "sha256": sha256(p)}
            for p in images
        ],
        "result_bundles": [{"path": p.as_posix()} for p in result_bundles],
        "non_claims": [
            "Packaging screenshots does not prove visual approval.",
            "Packaging screenshots does not prove accessibility conformance.",
            "Packaging screenshots does not prove release readiness."
        ],
    }
    output = Path(args.output) if args.output else root / "screenshot-package-manifest.json"
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps(manifest, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    print(f"Wrote {output} with {len(images)} images and {len(result_bundles)} result bundles.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
''',
    encoding="utf-8",
)
packager.chmod(0o755)

matrix = ARTIFACT / "screenshot-capture-matrix.json"
matrix.write_text(
    '''{
  "status": "GREEN_MATRIX_DEFINED",
  "device": "iPhone 17 Pro simulator",
  "scheme": "Ambitions",
  "result_root": "artifacts/object-stage-mega-train/visual-qa/screenshot-packaging/result-bundles",
  "matrix": [
    {"id": "canonical-shell-tabs", "ui_test": "testAFRI005ShellScreenshotBaselineCapturesCanonicalTabs", "surfaces": ["Today", "Goals", "Time", "You"]},
    {"id": "today-reconstruction-matrix", "ui_test": "testAMB962TodayReconstructionScreenshotMatrix", "surfaces": ["Today"]},
    {"id": "you-reconstruction-matrix", "ui_test": "testAMB966YouReconstructionScreenshotMatrix", "surfaces": ["You"]},
    {"id": "capture-composer-matrix", "ui_test": "testAMB967CaptureCreateGoalScreenshotMatrix", "surfaces": ["Capture"]}
  ]
}
''',
    encoding="utf-8",
)

workflow_text = WORKFLOW.read_text(encoding="utf-8")
if "artifacts/object-stage-mega-train/visual-qa/**/*.json" not in workflow_text:
    workflow_text = workflow_text.replace(
        "            artifacts/release-recovery/**/screenshots/**/*.png\n",
        "            artifacts/release-recovery/**/screenshots/**/*.png\n            artifacts/object-stage-mega-train/visual-qa/**/*.md\n            artifacts/object-stage-mega-train/visual-qa/**/*.json\n            artifacts/object-stage-mega-train/visual-qa/**/*.txt\n            artifacts/object-stage-mega-train/visual-qa/**/*.png\n",
    )
    WORKFLOW.write_text(workflow_text, encoding="utf-8")

report = ARTIFACT / "screenshot-packaging-report.md"
report.write_text(
    '''# Screenshot Packaging Batch

Status: `GREEN_PACKAGING_READY`

This batch installs the deterministic screenshot packaging lane.

## Added

- `scripts/visual_qa/capture_object_stage_screenshots.sh`
- `scripts/visual_qa/package_screenshot_proof.py`
- `artifacts/object-stage-mega-train/visual-qa/screenshot-capture-matrix.json`

## Workflow packaging

The Autopilot proof upload now includes `artifacts/object-stage-mega-train/visual-qa` markdown, JSON, text, and PNG files.

## Non-claims

- Screenshots have not been approved by this batch.
- Screenshot diff has not run in this batch.
- Release readiness is not claimed.
''',
    encoding="utf-8",
)
print("Screenshot packaging batch installed.")
