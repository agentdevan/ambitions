#!/usr/bin/env python3
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
VISUAL = ROOT / "scripts" / "visual_qa"
ARTIFACT = ROOT / "artifacts" / "object-stage-mega-train" / "visual-qa"
VISUAL.mkdir(parents=True, exist_ok=True)
ARTIFACT.mkdir(parents=True, exist_ok=True)

(VISUAL / "screenshot_diff_gate.py").write_text('''#!/usr/bin/env python3
import argparse
import json
from pathlib import Path
from datetime import datetime, timezone

parser = argparse.ArgumentParser()
parser.add_argument("--baseline", default="artifacts/object-stage-mega-train/visual-qa/baseline/screenshot-package-manifest.json")
parser.add_argument("--current", default="artifacts/object-stage-mega-train/visual-qa/screenshot-packaging/screenshot-package-manifest.json")
parser.add_argument("--output", default="artifacts/object-stage-mega-train/visual-qa/screenshot-diff-report.json")
parser.add_argument("--strict", action="store_true")
args = parser.parse_args()

def read_json(path):
    path = Path(path)
    if not path.exists():
        return None
    return json.loads(path.read_text(encoding="utf-8"))

def key(entry):
    return Path(entry.get("path", "")).name

baseline = read_json(args.baseline)
current = read_json(args.current)
report = {
    "generated_at": datetime.now(timezone.utc).isoformat(),
    "status": "UNKNOWN",
    "missing_inputs": [],
    "missing_images": [],
    "changed_images": [],
    "added_images": []
}
if baseline is None:
    report["missing_inputs"].append(args.baseline)
if current is None:
    report["missing_inputs"].append(args.current)
if report["missing_inputs"]:
    report["status"] = "YELLOW_DIFF_INPUTS_MISSING"
else:
    old = {key(item): item for item in baseline.get("images", [])}
    new = {key(item): item for item in current.get("images", [])}
    for name, item in old.items():
        if name not in new:
            report["missing_images"].append(name)
        elif item.get("sha256") != new[name].get("sha256") or item.get("bytes") != new[name].get("bytes"):
            report["changed_images"].append(name)
    for name in new:
        if name not in old:
            report["added_images"].append(name)
    report["status"] = "GREEN_SCREENSHOT_HASHES_MATCH" if not report["missing_images"] and not report["changed_images"] and not report["added_images"] else "RED_SCREENSHOT_DIFF_DETECTED"

Path(args.output).parent.mkdir(parents=True, exist_ok=True)
Path(args.output).write_text(json.dumps(report, indent=2, sort_keys=True) + "\n", encoding="utf-8")
print(report["status"])
if args.strict and report["status"] != "GREEN_SCREENSHOT_HASHES_MATCH":
    raise SystemExit(1)
''', encoding="utf-8")
(VISUAL / "screenshot_diff_gate.py").chmod(0o755)

(ARTIFACT / "screenshot-diff-proof-contract.json").write_text('''{
  "status": "GREEN_DIFF_GATE_READY",
  "gate": "scripts/visual_qa/screenshot_diff_gate.py",
  "baseline_manifest": "artifacts/object-stage-mega-train/visual-qa/baseline/screenshot-package-manifest.json",
  "current_manifest": "artifacts/object-stage-mega-train/visual-qa/screenshot-packaging/screenshot-package-manifest.json"
}
''', encoding="utf-8")

(ARTIFACT / "visual-qa-diff-gate-report.md").write_text('''# Visual QA Screenshot Diff Gate Batch

Status: `GREEN_DIFF_GATE_READY`

This batch installs a deterministic screenshot manifest comparator.

## Added

- `scripts/visual_qa/screenshot_diff_gate.py`
- `artifacts/object-stage-mega-train/visual-qa/screenshot-diff-proof-contract.json`

## Non-claims

- This batch does not approve visual quality.
- This batch does not claim screenshots are release-ready.
''', encoding="utf-8")
print("Visual QA screenshot diff gate installed.")
