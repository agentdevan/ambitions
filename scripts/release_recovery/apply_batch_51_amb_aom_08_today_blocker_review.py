#!/usr/bin/env python3
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "artifacts" / "object-stage-mega-train" / "reconciliation"
OUT.mkdir(parents=True, exist_ok=True)

today_panels_path = ROOT / "Native/Ambitions/Features/Today/TodayDayRailPanels.swift"
adapter_path = ROOT / "Native/Ambitions/Features/Today/TodayRealityMeridianFlagshipAdapter.swift"
view_model_path = ROOT / "Native/Ambitions/Features/Today/TodayViewModel.swift"
service_path = ROOT / "Native/Ambitions/Features/Today/TodayFeatureService.swift"

panels = today_panels_path.read_text(encoding="utf-8", errors="ignore")
adapter = adapter_path.read_text(encoding="utf-8", errors="ignore")
view_model = view_model_path.read_text(encoding="utf-8", errors="ignore")
service = service_path.read_text(encoding="utf-8", errors="ignore")

hardcoded_ticks = [tick for tick in ['timeTick("6 AM"', 'timeTick("12 PM"', 'timeTick("4 PM"', 'timeTick("8 PM"'] if tick in panels]
visible_cta_markers = [marker for marker in ["Trust details", "Why this?", "TodayMFPAdjust", "TodayRealityRailPrimaryAction"] if marker in panels]

checks = [
    ("Live current time uses TimelineView", "TimelineView(.periodic(from: .now" in panels and "Text(date, format: .dateTime.hour().minute())" in panels),
    ("No hardcoded time spine ticks", not hardcoded_ticks),
    ("Start Here has one recommended Step path or no-step state", "if let heroStep = state.heroStep" in panels and "No clear step yet" in panels and "Start here" in panels),
    ("Today refreshes after inline actions", "performAction(action" in view_model and "await refresh" in view_model),
    ("Today refreshes after closure recording", "recordActionClosure" in view_model and "await refresh" in view_model),
    ("Repository service performs action through command handlers", "TodayCommandActionHandler" in service and "TodayCommandHandler" in service),
    ("Reality Meridian adapter owns Start Here surface", "FlagshipRuntimeStage" in adapter and "RealityMeridianView" in adapter),
    ("Start Here does not expose a CTA stack", len(visible_cta_markers) <= 2),
    ("Source/proof inspection is behind detail affordance", "Trust details" in panels and "onOpenStepDetail" in panels),
    ("Accessibility and Reduce Motion are present", "dynamicTypeSize.isAccessibilitySize" in panels and "accessibilityIdentifier" in panels and "reduceMotion" in panels),
]

failed = [name for name, ok in checks if not ok]
status = "GREEN_ACCEPTED_NO_REPLAY" if not failed else "YELLOW_REPLAY_REQUIRED"

report = [
    "# AMB-AOM-08 Today Blocker Review",
    "",
    f"Status: `{status}`",
    "",
    "This deterministic review checks AMB-AOM-08 against the known Today blockers before AMB-AOM-09 can start.",
    "",
    "## Checks",
    "",
]
for name, ok in checks:
    report.append(f"- {'PASS' if ok else 'FAIL'} — {name}")
report += [
    "",
    "## Findings",
    "",
    f"- Hardcoded time ticks found: `{', '.join(hardcoded_ticks) if hardcoded_ticks else 'none'}`",
    f"- Visible CTA markers found: `{', '.join(visible_cta_markers) if visible_cta_markers else 'none'}`",
    "",
    "## Decision",
    "",
]
if status == "GREEN_ACCEPTED_NO_REPLAY":
    report.append("Current Today implementation satisfies AMB-AOM-08. No replay required.")
else:
    report.append("Replay is required before AMB-AOM-09. Today has meaningful improvements, but it still fails one or more launch-critical blockers.")
report += [
    "",
    "## Evidence files",
    "",
    f"- `{today_panels_path.relative_to(ROOT)}`",
    f"- `{adapter_path.relative_to(ROOT)}`",
    f"- `{view_model_path.relative_to(ROOT)}`",
    f"- `{service_path.relative_to(ROOT)}`",
    "",
    "## Next gate",
    "",
    "If Yellow, create a source-changing AMB-AOM-08 replay batch focused on live time-spine derivation and Start Here action simplification.",
    "",
]
(OUT / "AMB-AOM-08-today-blocker-review.md").write_text("\n".join(report), encoding="utf-8")
print(f"AMB-AOM-08 Today blocker review written: {status}")
