#!/usr/bin/env python3
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
REL = ROOT / "scripts" / "release_readiness"
ARTIFACT = ROOT / "artifacts" / "object-stage-mega-train" / "release-readiness"
REL.mkdir(parents=True, exist_ok=True)
ARTIFACT.mkdir(parents=True, exist_ok=True)

(REL / "release_readiness_gate.py").write_text('''#!/usr/bin/env python3
import argparse
import json
from pathlib import Path
from datetime import datetime, timezone

parser = argparse.ArgumentParser()
parser.add_argument("--output", default="artifacts/object-stage-mega-train/release-readiness/release-readiness-report.json")
parser.add_argument("--strict", action="store_true")
args = parser.parse_args()

checks = []
def exists(label, path):
    p = Path(path)
    checks.append({"label": label, "path": path, "passed": p.exists()})

exists("AOM-12 final validation", "artifacts/object-stage-mega-train/AOM-12-final-validation-report.md")
exists("Implementation truth closeout", "artifacts/object-stage-mega-train/reconciliation/AMB-AOM-12-implementation-truth-closeout.md")
exists("Screenshot packaging manifest", "artifacts/object-stage-mega-train/visual-qa/screenshot-packaging/screenshot-package-manifest.json")
exists("Screenshot diff report", "artifacts/object-stage-mega-train/visual-qa/screenshot-diff-report.json")
exists("Release truth", "docs/truth/RELEASE_TRUTH.md")
exists("Privacy manifest", "Native/Ambitions/Resources/PrivacyInfo.xcprivacy")
exists("Entitlements", "Native/Ambitions/Support/Ambitions.entitlements")
exists("Project config", "project.yml")

missing = [item for item in checks if not item["passed"]]
status = "GREEN_RELEASE_GATE_INPUTS_PRESENT" if not missing else "YELLOW_RELEASE_PROOF_INCOMPLETE"
report = {
    "generated_at": datetime.now(timezone.utc).isoformat(),
    "status": status,
    "checks": checks,
    "release_claim": "not ready" if missing else "gate inputs present, still requires human release approval",
    "non_claims": [
        "This gate does not claim TestFlight readiness.",
        "This gate does not claim App Store readiness.",
        "This gate does not replace privacy/legal review.",
        "This gate does not replace physical-device QA."
    ]
}
Path(args.output).parent.mkdir(parents=True, exist_ok=True)
Path(args.output).write_text(json.dumps(report, indent=2, sort_keys=True) + "\n", encoding="utf-8")
print(status)
if args.strict and status != "GREEN_RELEASE_GATE_INPUTS_PRESENT":
    raise SystemExit(1)
''', encoding="utf-8")
(REL / "release_readiness_gate.py").chmod(0o755)

(ARTIFACT / "release-readiness-gates-report.md").write_text('''# Release Readiness Gates Batch

Status: `GREEN_GATES_INSTALLED`

This batch installs a conservative release-readiness gate.

## Added

- `scripts/release_readiness/release_readiness_gate.py`

## Current gate posture

The gate checks final object-stage validation, implementation-truth closeout, screenshot package manifest, screenshot diff report, release truth, privacy manifest, entitlements, and project config.

## Non-claims

- Release readiness is not claimed.
- TestFlight readiness is not claimed.
- App Store readiness is not claimed.
- Physical-device QA is not claimed.
- Privacy/legal approval is not claimed.
''', encoding="utf-8")
print("Release readiness gate installed.")
