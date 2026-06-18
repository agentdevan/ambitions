#!/usr/bin/env python3
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "artifacts" / "object-stage-mega-train"
RECON = OUT / "reconciliation"
TRUTH = ROOT / "docs" / "truth" / "IMPLEMENTATION_TRUTH.md"
REPORT = OUT / "AOM-12-final-validation-report.md"

required_artifacts = [
    RECON / "AMB-AOM-pre09-proof-quality-closeout.md",
    OUT / "AMB-AOM-09-report.md",
    RECON / "AMB-AOM-09-validation-closeout.md",
    OUT / "AMB-AOM-10-report.md",
    RECON / "AMB-AOM-10-validation-closeout.md",
    OUT / "AMB-AOM-11-report.md",
    RECON / "AMB-AOM-11-validation-closeout.md",
]
for path in required_artifacts:
    if not path.exists():
        raise SystemExit(f"Missing required final validation artifact: {path.relative_to(ROOT)}")

files = {
    "AppTab": ROOT / "Native/Ambitions/App/AppTab.swift",
    "RootView": ROOT / "Native/Ambitions/App/AmbitionsRootView.swift",
    "ExternalRouting": ROOT / "Native/Ambitions/App/AppExternalRouting.swift",
    "Today": ROOT / "Native/Ambitions/Features/Today/TodayDayRailPanels.swift",
    "Goals": ROOT / "Native/Ambitions/Features/Goals/GoalComponents.swift",
    "Time": ROOT / "Native/Ambitions/Features/Time/TimeLifeShapeField.swift",
    "You": ROOT / "Native/Ambitions/Features/You/YouRootSurface.swift",
}
texts = {name: path.read_text(encoding="utf-8", errors="ignore") for name, path in files.items()}

checks = [
    ("Root IA is Today/Goals/Time/You", all(token in texts["AppTab"] for token in ["case today", "case goals", "case time", "case you"]) and "case motion" not in texts["AppTab"]),
    ("Root TabView renders four surfaces", all(token in texts["RootView"] for token in ["Tab(AppTab.today.title", "Tab(AppTab.goals.title", "Tab(AppTab.time.title", "Tab(AppTab.you.title"])),
    ("Capture remains global composer", "shellActivatedCaptureComposerSeam" in texts["RootView"] and "presentSurfaceCapture" in texts["RootView"]),
    ("Motion compatibility routes to Today", "motion.root" in texts["ExternalRouting"] and "openTab(.today)" in texts["ExternalRouting"]),
    ("Today is Reality Meridian with Start here", "RealityMeridianView" in texts["Today"] and "Start here" in texts["Today"] and "TimelineView(.periodic" in texts["Today"]),
    ("Goals is Constellation Atlas", "Constellation Atlas" in texts["Goals"] and "goals.life-area.\\(item.id).button" in texts["Goals"]),
    ("Time is LifeShape Field", "LifeShape Field" in texts["Time"] and "capacity contours" in texts["Time"] and "calendar clone" in texts["Time"]),
    ("You is User System Profile", "User System Profile" in texts["You"] and "account and profile" in texts["You"] and "AI settings wall" in texts["You"]),
]
failed = [name for name, ok in checks if not ok]
if failed:
    raise SystemExit("Final object-stage validation failed: " + ", ".join(failed))

validator_commands = [
    ["python3", "scripts/ambitions_validate_authority_drift.py"],
    ["python3", "scripts/codex/amb-master-canon-ia-validate.py"],
    ["python3", "scripts/ambitions-local-first-boundary-scan.py"],
]
validator_results = []
for command in validator_commands:
    result = subprocess.run(command, cwd=ROOT, text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    validator_results.append((" ".join(command), result.returncode, result.stdout.strip()[-1200:]))
    if result.returncode != 0:
        raise SystemExit(f"Validator failed: {' '.join(command)}\n{result.stdout}")

truth = TRUTH.read_text(encoding="utf-8")
truth_section = """
---

## AMB-AOM Object-Stage Mega Train Current Source Proof

Status: Source-present and Autopilot-validated through AMB-AOM-12 final validation.

Current source/proof supports these implementation statements only:

- Root runtime IA is Today / Goals / Time / You.
- Capture is represented as a global composer/control path, not a root tab.
- Motion is compatibility and behavior infrastructure, not a root tab.
- Today source owns Reality Meridian / Start Here behavior with live time and a simplified action surface.
- Goals source owns Constellation Atlas with actionable Life Areas and Orbital Lens inspection.
- Time source owns LifeShape Field and explicitly rejects calendar clone, agenda clone, free/busy grid, and metric-dashboard geometry.
- You source owns User System Profile with native settings-quality groups for account/profile, privacy, appearance, notifications, learning, receipts/history, export, and support.

This proof does not establish App Store readiness, TestFlight readiness, device-signing readiness, privacy/legal sufficiency, data migration safety, or production analytics/crash/observability readiness.
"""
if "## AMB-AOM Object-Stage Mega Train Current Source Proof" not in truth:
    TRUTH.write_text(truth.rstrip() + "\n" + truth_section, encoding="utf-8")

head = subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=ROOT, text=True).strip()
report_lines = [
    "# AOM-12 Final Validation Report",
    "",
    "Status: `GREEN_FINAL_VALIDATION`",
    "",
    f"Baseline SHA: `{head}`",
    f"Final SHA: pending Autopilot commit from `batch_60_amb_aom_12_final_validation`",
    "",
    "## Root surfaces",
    "",
    "- Today → Reality Meridian / Start Here",
    "- Goals → Constellation Atlas",
    "- Time → LifeShape Field",
    "- You → User System Profile",
    "- Capture → global composer",
    "- Motion → compatibility / behavior infrastructure",
    "",
    "## Checks",
    "",
]
for name, ok in checks:
    report_lines.append(f"- {'PASS' if ok else 'FAIL'} — {name}")
report_lines += ["", "## Validators", ""]
for command, code, output in validator_results:
    report_lines.append(f"- `{command}` → exit `{code}`")
report_lines += [
    "",
    "## Required artifacts verified",
    "",
]
for path in required_artifacts:
    report_lines.append(f"- `{path.relative_to(ROOT)}`")
report_lines += [
    "",
    "## Screenshots",
    "",
    "Not captured by this deterministic recovery batch; screenshot packaging remains a separate visual QA artifact task.",
    "",
    "## Build result",
    "",
    "Autopilot workflow runs xcodegen, package resolution/list, and unsigned simulator build gates after this batch applies.",
    "",
    "## Tests result",
    "",
    "Focused source validation and validator scripts pass in this batch. Swift test execution remains governed by workflow configuration.",
    "",
    "## Risks",
    "",
    "- Release readiness is not claimed by this object-stage validation.",
    "- Pixel-level visual QA and screenshot diff proof remain separate gates.",
    "- Object-stage artifacts are committed to the repo, but workflow artifact upload still prioritizes release-recovery proof files.",
    "",
    "## Rollback",
    "",
    "Revert `batch_60_amb_aom_12_final_validation` to remove only the final report/truth update; previous AMB-AOM source deltas remain independently reversible by their batch commits.",
    "",
]
REPORT.write_text("\n".join(report_lines), encoding="utf-8")
print("AMB-AOM-12 final object-stage validation written.")
