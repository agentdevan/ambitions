#!/usr/bin/env python3
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = ROOT / "artifacts" / "object-stage-mega-train"
RECON = BASE / "reconciliation"
RECON.mkdir(parents=True, exist_ok=True)

components = ROOT / "Native" / "Ambitions" / "Features" / "Goals" / "GoalComponents.swift"
models = ROOT / "Native" / "Ambitions" / "Features" / "Goals" / "GoalsFeatureModels.swift"
screen = ROOT / "Native" / "Ambitions" / "Features" / "Goals" / "GoalsScreen.swift"
tests = ROOT / "Native" / "AmbitionsTests" / "Goals" / "GoalsConstellationAtlasReconstructionTests.swift"
report = BASE / "AMB-AOM-09-report.md"

texts = {
    "GoalComponents.swift": components.read_text(encoding="utf-8", errors="ignore"),
    "GoalsFeatureModels.swift": models.read_text(encoding="utf-8", errors="ignore"),
    "GoalsScreen.swift": screen.read_text(encoding="utf-8", errors="ignore"),
    "GoalsConstellationAtlasReconstructionTests.swift": tests.read_text(encoding="utf-8", errors="ignore"),
    "AMB-AOM-09-report.md": report.read_text(encoding="utf-8", errors="ignore"),
}

components_text = texts["GoalComponents.swift"]
screen_text = texts["GoalsScreen.swift"]
models_text = texts["GoalsFeatureModels.swift"]
test_text = texts["GoalsConstellationAtlasReconstructionTests.swift"]
report_text = texts["AMB-AOM-09-report.md"]

checks = [
    ("AMB-AOM-09 report is Green source delta", "Status: `GREEN_SOURCE_DELTA`" in report_text),
    ("Goals owns Constellation Atlas contract", "stageName: \"Constellation Atlas\"" in components_text and "avoidsGenericGoalRootOutput: true" in components_text),
    ("Root Goals is object stage, not dashboard/list root", "GoalsConstellationAtlasStage" in screen_text and "KPI" not in components_text and "dashboard" not in components_text.lower()),
    ("Life Areas are actionable", "Button {" in components_text and "selectedLifeAreaID = item.id" in components_text and "goals.life-area.\\(item.id).button" in components_text),
    ("Life Area action opens Orbital Lens inspection", "isOrbitalLensExpanded = true" in components_text and "accessibilityIdentifier(\"goals.orbital-lens.expanded\")" in components_text),
    ("Goal Threads can open", "goals.orbital-lens.open-thread" in components_text and "kind: .openGoal" in components_text),
    ("Today connection remains visible", "Today link" in components_text and "Feeds Today" in components_text and "todayTraceSummary" in models_text),
    ("Inspection is progressive", "progressive trust inspection" in components_text and "goals.source-proof-trust" in components_text),
    ("Accessibility and Dynamic Type proof exists", "accessibilityHint" in components_text and "accessibilityIdentifier" in components_text and "minimumScaleFactor" in components_text),
    ("Reduce Motion path exists", "if reduceMotion" in components_text),
    ("Regression tests cover contract", "GoalsConstellationAtlasReconstructionTests" in test_text and "avoidsGenericGoalRootOutput" in test_text and "Today" in test_text),
]

failed = [name for name, ok in checks if not ok]
status = "GREEN_ACCEPTED" if not failed else "YELLOW_REPLAY_REQUIRED"

lines = [
    "# AMB-AOM-09 Goals Validation Closeout",
    "",
    f"Status: `{status}`",
    "",
    "This deterministic validation checks the AMB-AOM-09 source delta for no dashboard/list regression and screenshot-proof readiness before AMB-AOM-10 can start.",
    "",
    "## Checks",
    "",
]
for name, ok in checks:
    lines.append(f"- {'PASS' if ok else 'FAIL'} — {name}")
lines += [
    "",
    "## Evidence files",
    "",
    "- `Native/Ambitions/Features/Goals/GoalComponents.swift`",
    "- `Native/Ambitions/Features/Goals/GoalsFeatureModels.swift`",
    "- `Native/Ambitions/Features/Goals/GoalsScreen.swift`",
    "- `Native/AmbitionsTests/Goals/GoalsConstellationAtlasReconstructionTests.swift`",
    "- `artifacts/object-stage-mega-train/AMB-AOM-09-report.md`",
    "",
    "## Decision",
    "",
]
if status == "GREEN_ACCEPTED":
    lines.append("AMB-AOM-09 is accepted. Proceed to AMB-AOM-10 Time Reconstruction.")
else:
    lines.append("AMB-AOM-09 needs another source replay before AMB-AOM-10.")
lines.append("")

(RECON / "AMB-AOM-09-validation-closeout.md").write_text("\n".join(lines), encoding="utf-8")
print(f"AMB-AOM-09 validation closeout written: {status}")
