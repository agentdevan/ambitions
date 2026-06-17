#!/usr/bin/env python3
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "artifacts" / "object-stage-mega-train" / "reconciliation"
OUT.mkdir(parents=True, exist_ok=True)

files = {
    "AppTab.swift": ROOT / "Native/Ambitions/App/AppTab.swift",
    "AmbitionsRootView.swift": ROOT / "Native/Ambitions/App/AmbitionsRootView.swift",
    "AppMeridianShell.swift": ROOT / "Native/Ambitions/App/AppMeridianShell.swift",
    "AppShellView.swift": ROOT / "Native/Ambitions/App/AppShellView.swift",
    "NavigationPrimitives.swift": ROOT / "Sources/Components/NavigationPrimitives.swift",
}
text = {name: path.read_text(encoding="utf-8", errors="ignore") for name, path in files.items() if path.exists()}

checks = [
    ("Root shell is four-surface only", "[.today, .goals, .time, .you]" in text.get("AppTab.swift", "") and "case motion" not in text.get("AppTab.swift", "")),
    ("Root TabView renders Today/Goals/Time/You", all(token in text.get("AmbitionsRootView.swift", "") for token in ["Tab(AppTab.today.title", "Tab(AppTab.goals.title", "Tab(AppTab.time.title", "Tab(AppTab.you.title"])),
    ("System tab bar is hidden for custom shell", ".toolbar(.hidden, for: .tabBar)" in text.get("AmbitionsRootView.swift", "")),
    ("Bottom rail is AppMeridianDestinationRail", "AppMeridianDestinationRail" in text.get("AmbitionsRootView.swift", "") and "struct AppMeridianDestinationRail" in text.get("AppMeridianShell.swift", "")),
    ("Capture remains global/contextual", "shellActivatedCaptureComposerSeam" in text.get("AmbitionsRootView.swift", "") and "presentSurfaceCapture" in text.get("AmbitionsRootView.swift", "")),
    ("Liquid-glass/material tokens exist", "AmbitionsIOS26SemanticTokens.LiquidGlass" in text.get("AppMeridianShell.swift", "") or "glassEffect" in text.get("NavigationPrimitives.swift", "")),
    ("Dynamic Type accessibility branch exists", "dynamicTypeSize.isAccessibilitySize" in text.get("AppMeridianShell.swift", "") and "accessibilityIdentifier" in text.get("AppMeridianShell.swift", "")),
    ("Motion policy exists elsewhere in shell stack", "accessibilityReduceMotion" in text.get("AppShellView.swift", "") or "setReduceMotionEnabled" in text.get("AmbitionsRootView.swift", "")),
]
missing = [name for name, ok in checks if not ok]
haptic_missing = True
for source in text.values():
    if "sensoryFeedback" in source or "UIImpactFeedbackGenerator" in source or "haptic" in source.lower():
        haptic_missing = False

status = "YELLOW_REPLAY_REQUIRED" if missing or haptic_missing else "GREEN_ACCEPTED_NO_REPLAY"
report = [
    "# AMB-AOM-07 Shell Visual Foundation Review",
    "",
    f"Status: `{status}`",
    "",
    "AMB-AOM-07 was suspicious because its original report showed only `Sources/Components/NavigationPrimitives.swift` changed. This deterministic review checks the current shell stack before deciding whether to accept or replay.",
    "",
    "## Verified checks",
    "",
]
for name, ok in checks:
    report.append(f"- {'PASS' if ok else 'FAIL'} — {name}")
report += [
    f"- {'FAIL' if haptic_missing else 'PASS'} — Shared haptic/sensory feedback policy present",
    "",
    "## Decision",
    "",
]
if status == "GREEN_ACCEPTED_NO_REPLAY":
    report.append("Current shell source satisfies AMB-AOM-07 scope. No replay required.")
else:
    report.append("Replay is required before AMB-AOM-09. The current shell foundation is improved, but AMB-AOM-07 cannot be fully accepted because at least one scope element is missing or under-proven.")
report += [
    "",
    "## Evidence files",
    "",
]
for name, path in files.items():
    report.append(f"- `{path.relative_to(ROOT)}`")
report += [
    "",
    "## Next gate",
    "",
    "If Yellow, create a source-changing AMB-AOM-07 replay batch before AMB-AOM-08. If Green, proceed to AMB-AOM-08 Today blocker validation.",
    "",
]
(OUT / "AMB-AOM-07-shell-visual-review.md").write_text("\n".join(report), encoding="utf-8")
print(f"AMB-AOM-07 shell visual review written: {status}")
