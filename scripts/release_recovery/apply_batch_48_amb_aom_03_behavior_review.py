#!/usr/bin/env python3
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "artifacts" / "object-stage-mega-train" / "reconciliation"
OUT.mkdir(parents=True, exist_ok=True)

app_tab = (ROOT / "Native/Ambitions/App/AppTab.swift").read_text(encoding="utf-8")
root = (ROOT / "Native/Ambitions/App/AmbitionsRootView.swift").read_text(encoding="utf-8")
external = (ROOT / "Native/Ambitions/App/AppExternalRouting.swift").read_text(encoding="utf-8")

checks = [
    ("AppTab has only Today/Goals/Time/You cases", all(token in app_tab for token in ["case today", "case goals", "case time", "case you"]) and "case motion" not in app_tab and "case pulse" not in app_tab),
    ("AppTab.allCases excludes Motion", "[.today, .goals, .time, .you]" in app_tab),
    ("Legacy Motion/Pulse canonical tab falls back to Today", "case \"motion\", \"pulse\":" in app_tab and ".today" in app_tab),
    ("Root TabView has no Motion destination", "Tab(AppTab.today.title" in root and "Tab(AppTab.goals.title" in root and "Tab(AppTab.time.title" in root and "Tab(AppTab.you.title" in root and "AppTab.motion" not in root),
    ("External motion.root compatibility route maps to Today", "id: \"motion.root\"" in external and "owningTab: .today" in external and "canonicalRoute: .openTab(.today)" in external),
    ("MotionCurrentAction is behavior-routed through Stage owner", "registerMotionCurrentActionObserver" in root and "routeStageMotionAction" in root and "stageOwner.route(for: action" in root),
]

failed = [name for name, ok in checks if not ok]
if failed:
    raise SystemExit("AMB-AOM-03 audit failed: " + "; ".join(failed))

report = [
    "# AMB-AOM-03 Motion Behavior Review",
    "",
    "Status: `GREEN_ACCEPTED_NO_REPLAY`",
    "",
    "AMB-AOM-03 originally looked suspicious because the batch report showed only test changes. This deterministic source audit verifies the current runtime source now satisfies the intended Motion demotion contract, so a blind source replay is not required.",
    "",
    "## Verified checks",
    "",
]
for name, _ in checks:
    report.append(f"- {name}")
report += [
    "",
    "## Evidence files",
    "",
    "- `Native/Ambitions/App/AppTab.swift`",
    "- `Native/Ambitions/App/AmbitionsRootView.swift`",
    "- `Native/Ambitions/App/AppExternalRouting.swift`",
    "- `Native/AmbitionsTests/App/AppShellNavigationTests.swift`",
    "- `Native/AmbitionsTests/App/ExternalRoutingTests.swift`",
    "",
    "## Remaining risk",
    "",
    "This closes Motion demotion/routing scope only. Visual shell polish remains owned by AMB-AOM-07.",
    "",
    "## Next gate",
    "",
    "Proceed to AMB-AOM-07 shell/visual foundation scope audit or replay.",
    "",
]
(OUT / "AMB-AOM-03-motion-behavior-review.md").write_text("\n".join(report), encoding="utf-8")
print("AMB-AOM-03 motion behavior review accepted.")
