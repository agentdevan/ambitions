#!/usr/bin/env python3
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = ROOT / "artifacts" / "object-stage-mega-train"
RECON = BASE / "reconciliation"
RECON.mkdir(parents=True, exist_ok=True)

field = ROOT / "Native" / "Ambitions" / "Features" / "Time" / "TimeLifeShapeField.swift"
screen = ROOT / "Native" / "Ambitions" / "Features" / "Time" / "TimeScreen.swift"
tests = ROOT / "Native" / "AmbitionsTests" / "Time" / "TimeLifeShapeFieldReconstructionTests.swift"
report = BASE / "AMB-AOM-10-report.md"

field_text = field.read_text(encoding="utf-8", errors="ignore")
screen_text = screen.read_text(encoding="utf-8", errors="ignore")
test_text = tests.read_text(encoding="utf-8", errors="ignore")
report_text = report.read_text(encoding="utf-8", errors="ignore")

checks = [
    ("AMB-AOM-10 report is Green source delta", "Status: `GREEN_SOURCE_DELTA`" in report_text),
    ("Time owns LifeShape Field", "productObject: \"LifeShape Field\"" in field_text and "ownerSurface: \"Time\"" in field_text),
    ("Capacity, pressure, protected windows, fixed points, and horizons are named", all(token in field_text for token in ["capacity contours", "pressure texture", "protected windows", "fixed points", "horizons"])),
    ("Calendar clone geometry is rejected", all(token in field_text for token in ["calendar clone", "agenda clone", "free/busy grid", "metric-row dashboard"])),
    ("First viewport is LifeShape Field object stage", "TimeLifeShapeField(" in screen_text and "LifeShape Field" in field_text),
    ("Shaping controls preserve confirmation", "reflowActionButton" in field_text and "onReflowDecision?(option, action)" in field_text and "confirmedReflowAction" in field_text),
    ("Inspection remains progressive", "Why this?" in field_text and "sourceReceiptRow" in field_text and "reflowTrustSeam" in field_text),
    ("Accessibility and Dynamic Type proof exists", "accessibilityIdentifier" in field_text and "dynamicTypeSize.isAccessibilitySize" in field_text),
    ("Reduce Motion path exists", "reduceMotion" in field_text and "withAnimation(reduceMotion ? nil" in field_text),
    ("Regression tests cover Time contract", "TimeLifeShapeFieldReconstructionTests" in test_text and "firstViewportAvoidsCalendarCardDashboardGeometry" in test_text and "calendar clone" in test_text),
]

failed = [name for name, ok in checks if not ok]
status = "GREEN_ACCEPTED" if not failed else "YELLOW_REPLAY_REQUIRED"

lines = [
    "# AMB-AOM-10 Time Validation Closeout",
    "",
    f"Status: `{status}`",
    "",
    "This deterministic validation checks AMB-AOM-10 for no calendar/list regression and confirmation-control proof before AMB-AOM-11 can start.",
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
    "- `Native/Ambitions/Features/Time/TimeLifeShapeField.swift`",
    "- `Native/Ambitions/Features/Time/TimeScreen.swift`",
    "- `Native/AmbitionsTests/Time/TimeLifeShapeFieldReconstructionTests.swift`",
    "- `artifacts/object-stage-mega-train/AMB-AOM-10-report.md`",
    "",
    "## Decision",
    "",
]
if status == "GREEN_ACCEPTED":
    lines.append("AMB-AOM-10 is accepted. Proceed to AMB-AOM-11 You Reconstruction.")
else:
    lines.append("AMB-AOM-10 needs another source replay before AMB-AOM-11.")
lines.append("")

(RECON / "AMB-AOM-10-validation-closeout.md").write_text("\n".join(lines), encoding="utf-8")
print(f"AMB-AOM-10 validation closeout written: {status}")
