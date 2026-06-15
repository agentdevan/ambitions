#!/usr/bin/env python3
"""Validate active Ambitions Master Build canon and IA locks."""
from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]

ACTIVE_IA = "Today / Goals / Time / Motion / You"
ACTIVE_COMMA_IA = "Today, Goals, Time, Motion, You"
ACTIVE_AND_IA = "Today, Goals, Time, Motion, and You"
LEGACY_ROOT_SEQUENCE = '["Today", "Goals", "Capture", "Time", "You"]'
LEGACY_COMMA_SEQUENCE = "Today, Goals, Capture, Time, You"
LEGACY_SLASH_SEQUENCE = "Today / Goals / Capture / Time / You"

REQUIRED_ACTIVE_FILES = [
    "AGENTS.md",
    "docs/truth/PRODUCT_DESIGN_TRUTH.md",
    "docs/truth/IMPLEMENTATION_TRUTH.md",
    "artifacts/ambitions-master-build/AMB_MASTER_GOAL.md",
    "artifacts/ambitions-master-build/AMB_MASTER_PHASE_GATES.md",
    ".agents/skills/ambitions-master-build/SKILL.md",
]

SOURCE_LOCK_FILES = [
    "Native/Ambitions/App/AppTab.swift",
    "Native/Ambitions/AppIntents/OpenAmbitionsDestinationIntent.swift",
    "Native/Ambitions/Domain/ScreenContractModels.swift",
    "Native/Ambitions/Features/Capture/CaptureScreen.swift",
    "Sources/Components/DynamicAdaptiveVisualPrimitives.swift",
    "Sources/Components/TopLevelSurfaceCompositionPrimitives.swift",
    "Sources/Previews/TopLevelSurfaceCompositionPreviews.swift",
    "Sources/Previews/SignatureInterfaceVisualQAFixtures.swift",
    "Native/Ambitions/Support/ReleasePerformanceResponsivenessReport.swift",
    "Native/Ambitions/Support/ReleaseDeviceQAReadinessReport.swift",
    "Native/AmbitionsTests/App/FrontendRecoveryGateTests.swift",
    "Native/AmbitionsTests/Today/TodayViewModelTests.swift",
    "Native/AmbitionsTests/App/TopLevelSurfaceCompositionTests.swift",
    "Native/AmbitionsTests/App/SignatureInterfaceVisualQAFixtureTests.swift",
    "Native/AmbitionsTests/App/ReleasePerformanceResponsivenessReportTests.swift",
]


def read(rel: str) -> str:
    path = ROOT / rel
    return path.read_text(encoding="utf-8", errors="ignore") if path.exists() else ""


def check(condition: bool, failures: list[str], message: str) -> None:
    if not condition:
        failures.append(message)


def validate() -> list[str]:
    failures: list[str] = []

    for rel in REQUIRED_ACTIVE_FILES + SOURCE_LOCK_FILES:
        check((ROOT / rel).exists(), failures, f"missing required canon/IA file: {rel}")
    if failures:
        return failures

    product_truth = read("docs/truth/PRODUCT_DESIGN_TRUTH.md")
    implementation_truth = read("docs/truth/IMPLEMENTATION_TRUTH.md")
    agents = read("AGENTS.md")
    combined_authority = "\n".join(read(rel) for rel in REQUIRED_ACTIVE_FILES)

    check(ACTIVE_IA in combined_authority, failures, "active IA literal missing from authority stack")
    check("Capture is always available, but it is not a tab." in product_truth, failures, "Capture not-tab law missing from product truth")
    check("Plan is not a top-level tab." in product_truth, failures, "Plan not-top-level law missing from product truth")
    check("Pulse is prior working-name / historical context only" in combined_authority, failures, "Pulse historical-only law missing from authority")
    check(
        "global Atmosphere Composer/action layer, not a tab" in agents,
        failures,
        "AGENTS global Capture law missing",
    )
    check(
        "global Atmosphere Composer/action layer, not a tab" in implementation_truth,
        failures,
        "implementation truth global Capture law missing",
    )
    check("The fourth tab is Motion." not in product_truth, failures, "ambiguous Motion ordinal sentence remains in product truth")

    app_tab = read("Native/Ambitions/App/AppTab.swift")
    check(re.search(r"static var allCases: \[AppTab\]\s*\{\s*\[\.today, \.goals, \.time, \.motion, \.you\]", app_tab, re.S) is not None, failures, "AppTab.allCases does not lock Today/Goals/Time/Motion/You")
    check('case "capture": self = .capture' not in app_tab, failures, "AppTab raw capture case must not reappear as a root tab")
    check('case "capture", "captures":\n            .today' in app_tab, failures, "Capture compatibility must map to Today, not a root tab")
    check('case "capture", "captures":\n            return .openTimeRoute(.captureInbox)' in app_tab, failures, "Capture external compatibility must route to the global Capture overlay/inbox path")
    check('case "pulse":\n            .motion' in app_tab, failures, "Pulse compatibility must map to Motion")
    app_intent = read("Native/Ambitions/AppIntents/OpenAmbitionsDestinationIntent.swift")
    check("Open Today, Goals, Time, Motion, You, global Capture" in app_intent, failures, "Open Ambitions app intent description is stale")

    screen_contracts = read("Native/Ambitions/Domain/ScreenContractModels.swift")
    check('static let canonicalTopLevelTabs = ["Today", "Goals", "Time", "Motion", "You"]' in screen_contracts, failures, "ScreenContractValidator canonical tabs are stale")

    top_level = read("Sources/Components/TopLevelSurfaceCompositionPrimitives.swift")
    check("case motion" in top_level, failures, "Top-level composition missing Motion")
    check("case capture" not in top_level, failures, "Top-level composition still declares Capture as a root surface")
    check('public static let activeTopLevelSurfaces = ["Today", "Goals", "Time", "Motion", "You"]' in top_level, failures, "AFI14 active top-level surfaces are stale")
    check('stage("Inspect", promise: "See what moved and what can re-enter.", surfaces: ["Motion"], object: "Motion Current")' in top_level, failures, "AFI14 grammar does not assign Motion")
    top_level_previews = read("Sources/Previews/TopLevelSurfaceCompositionPreviews.swift")
    check("surface == .motion ? .selected : .default" in top_level_previews, failures, "Top-level composition preview still selects stale root surface")
    capture_screen = read("Native/Ambitions/Features/Capture/CaptureScreen.swift")
    check("TopLevelSurfaceCompositionBar(surface: .capture)" not in capture_screen, failures, "Capture screen treats Capture as a top-level composition surface")
    check("Capture stays text-first and route choices stay editable after input." in capture_screen, failures, "Capture screen missing global composer prompt contract")
    living_context = read("Sources/Components/DynamicAdaptiveVisualPrimitives.swift")
    check("case motion" in living_context, failures, "LivingTabContext missing Motion")

    si16 = read("Sources/Previews/SignatureInterfaceVisualQAFixtures.swift")
    check('public static let canonicalTopLevelSurfaces = ["Today", "Goals", "Time", "Motion", "You"]' in si16, failures, "SI16 canonical top-level surfaces are stale")
    check('public static let activeTopLevelSurfaces = ["Today", "Goals", "Time", "Motion", "You"]' in si16, failures, "AFI13 active top-level surfaces are stale")
    check('scorecard(\n            "Motion"' in si16, failures, "AFI13 missing Motion scorecard")
    check('surfaceRow(\n            "Motion"' in si16, failures, "SI16 missing Motion coverage row")

    performance = read("Native/Ambitions/Support/ReleasePerformanceResponsivenessReport.swift")
    check("case motion" in performance, failures, "Release performance surface enum missing Motion")
    check("case capture" not in performance, failures, "Release performance surface enum still treats Capture as a root performance surface")
    check('M12 shell continuity tests cover Today, Goals, Time, Motion, You, global Capture, and review routes' in performance, failures, "Release performance tab-switching evidence is stale")

    for rel in SOURCE_LOCK_FILES:
        text = read(rel)
        for legacy in (LEGACY_ROOT_SEQUENCE, LEGACY_COMMA_SEQUENCE, LEGACY_SLASH_SEQUENCE):
            for line_number, line in enumerate(text.splitlines(), start=1):
                if legacy not in line:
                    continue
                allowed_negative = any(marker in line for marker in ("XCTAssertFalse", "obsolete", "superseded", "LEGACY", "legacy"))
                if not allowed_negative:
                    failures.append(f"{rel}:{line_number}: stale root IA sequence remains active: {legacy}")

    for rel in SOURCE_LOCK_FILES:
        text = read(rel)
        if rel == "Sources/Components/DynamicAdaptiveVisualPrimitives.swift":
            continue
        if rel.endswith("Tests.swift") or rel.endswith("Fixtures.swift") or rel.endswith("Primitives.swift") or rel.endswith("Report.swift"):
            check(
                ACTIVE_COMMA_IA in text or ACTIVE_AND_IA in text or "Time\", \"Motion\", \"You" in text,
                failures,
                f"{rel}: missing active IA evidence",
            )

    return failures


def main() -> int:
    failures = validate()
    for failure in failures:
        print("FAIL " + failure)
    if failures:
        return 1
    print("PASS amb-master canon IA lock matches Today/Goals/Time/Motion/You with global Capture")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
