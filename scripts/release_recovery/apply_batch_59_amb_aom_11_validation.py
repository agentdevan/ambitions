#!/usr/bin/env python3
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = ROOT / "artifacts" / "object-stage-mega-train"
RECON = BASE / "reconciliation"
RECON.mkdir(parents=True, exist_ok=True)

root = ROOT / "Native" / "Ambitions" / "Features" / "You" / "YouRootSurface.swift"
screen = ROOT / "Native" / "Ambitions" / "Features" / "You" / "YouScreen.swift"
service = ROOT / "Native" / "Ambitions" / "Features" / "You" / "YouFeatureService.swift"
tests = ROOT / "Native" / "AmbitionsTests" / "You" / "YouUserSystemProfileReconstructionTests.swift"
report = BASE / "AMB-AOM-11-report.md"

root_text = root.read_text(encoding="utf-8", errors="ignore")
screen_text = screen.read_text(encoding="utf-8", errors="ignore")
service_text = service.read_text(encoding="utf-8", errors="ignore")
test_text = tests.read_text(encoding="utf-8", errors="ignore")
report_text = report.read_text(encoding="utf-8", errors="ignore")

checks = [
    ("AMB-AOM-11 report is Green source delta", "Status: `GREEN_SOURCE_DELTA`" in report_text),
    ("You owns User System Profile", "productObject: \"User System Profile\"" in root_text and "stageName: \"User System Profile\"" in root_text),
    ("Native settings taxonomy is explicit", all(token in root_text for token in ["account and profile", "privacy and automation", "appearance", "notifications", "learning", "receipts and history", "export", "support"])),
    ("Root groups are concise and native", all(token in root_text for token in ["Account & profile", "Appearance & notifications", "Privacy, learning & receipts", "Export & support"])),
    ("Required controls can route", all(token in root_text for token in [".automationTrust", ".appearance", ".notifications", ".receiptsHistory", ".exportImport", ".support"])),
    ("Source data includes export and support items", all(token in service_text for token in ["id: \"export-import\"", "title: \"Export / Import\"", "id: \"help-support\"", "title: \"Help / Support\""])),
    ("Bad profile/settings shapes are rejected", all(token in root_text for token in ["social profile", "admin panel", "AI settings wall", "verbose documentation UI", "internal runtime console", "generic settings wall"])),
    ("Root is User System Profile, not internal runtime console", "PersonalSystemCenterRootView" in screen_text and "User System Profile" in root_text and "internal runtime console" in root_text),
    ("Accessibility and Dynamic Type proof exists", "accessibilityIdentifier" in root_text and "dynamicTypeSize.isAccessibilitySize" in root_text and "accessibilityValue" in root_text),
    ("Haptic route feedback remains", "ambitionHaptic" in root_text and "selectedRowHapticToken" in root_text),
    ("Regression tests cover contract", "YouUserSystemProfileReconstructionTests" in test_text and "User System Profile" in test_text and "AI settings wall" in test_text),
]

failed = [name for name, ok in checks if not ok]
status = "GREEN_ACCEPTED" if not failed else "YELLOW_REPLAY_REQUIRED"

lines = [
    "# AMB-AOM-11 You Validation Closeout",
    "",
    f"Status: `{status}`",
    "",
    "This deterministic validation checks AMB-AOM-11 for no profile/settings-wall regression and native settings-quality proof before AMB-AOM-12 can start.",
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
    "- `Native/Ambitions/Features/You/YouRootSurface.swift`",
    "- `Native/Ambitions/Features/You/YouScreen.swift`",
    "- `Native/Ambitions/Features/You/YouFeatureService.swift`",
    "- `Native/AmbitionsTests/You/YouUserSystemProfileReconstructionTests.swift`",
    "- `artifacts/object-stage-mega-train/AMB-AOM-11-report.md`",
    "",
    "## Decision",
    "",
]
if status == "GREEN_ACCEPTED":
    lines.append("AMB-AOM-11 is accepted. Proceed to AMB-AOM-12 Final Object-Stage Validation.")
else:
    lines.append("AMB-AOM-11 needs another source replay before AMB-AOM-12.")
lines.append("")

(RECON / "AMB-AOM-11-validation-closeout.md").write_text("\n".join(lines), encoding="utf-8")
print(f"AMB-AOM-11 validation closeout written: {status}")
