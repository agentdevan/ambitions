#!/usr/bin/env python3
"""Validate active surface references against the canonical app surface contract."""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

ROOT_SURFACES = [
    ("today", "Today", "Reality Meridian"),
    ("goals", "Goals", "Constellation Atlas"),
    ("time", "Time", "LifeShape Field"),
    ("you", "You", "User System Profile"),
]

COMPATIBILITY_ROUTES = {
    "capture": "today",
    "captures": "today",
    "motion": "today",
    "pulse": "today",
    "plan": "time",
    "habits": "time",
    "profile": "you",
    "insights": "you",
}

REQUIRED_RUNTIME_TERMS = [
    "SourceRecord",
    "Receipt",
    "ReplayTrace",
    "You / Search Ambitions",
]


def read(path: str | Path) -> str:
    full = path if isinstance(path, Path) else ROOT / path
    return full.read_text(encoding="utf-8", errors="replace") if full.exists() else ""


def require(condition: bool, errors: list[str], message: str) -> None:
    if not condition:
        errors.append(message)


def main() -> int:
    errors: list[str] = []

    app_tab = read("Native/Ambitions/App/AppTab.swift")
    root_view = read("Native/Ambitions/App/AmbitionsRootView.swift")
    meridian_shell = read("Native/Ambitions/App/AppMeridianShell.swift")
    shell_mode = read("Native/Ambitions/App/AppShellPresentationMode.swift")
    navigation = read("Native/Ambitions/App/AppNavigation.swift")
    external_routing = read("Native/Ambitions/App/AppExternalRouting.swift")
    app_intent = read("Native/Ambitions/AppIntents/OpenAmbitionsDestinationIntent.swift")
    preview_matrix = read("Native/Ambitions/PreviewSupport/ShellPreviewMatrix.swift")

    require(
        "[.today, .goals, .time, .you]" in app_tab,
        errors,
        "AppTab.allCases must remain Today, Goals, Time, You.",
    )

    for raw, title, primary in ROOT_SURFACES:
        contract_snippet = f'AmbitionsSurfaceContract(tab: .{raw}, title: "{title}", primaryObjectTitle: "{primary}")'
        require(contract_snippet in app_tab, errors, f"AppTab.swift missing surface contract {title} -> {primary}.")
        require(f'Tab(AppTab.{raw}.title' in root_view, errors, f"AmbitionsRootView missing shell tab for {title}.")
        require(f"AppTab.{raw}.systemImage" in root_view, errors, f"AmbitionsRootView missing tab icon source for {title}.")

    for term in REQUIRED_RUNTIME_TERMS:
        require(term in app_tab, errors, f"AppTab surface contract must preserve runtime term {term}.")

    require(
        not re.search(r"\bcase\s+(capture|captures|motion|plan|profile|habits|insights|pulse)\b", app_tab),
        errors,
        "AppTab must not expose Capture, Motion, or compatibility names as active enum cases.",
    )
    require(
        'case "capture", "captures":' in app_tab,
        errors,
        "Legacy route adapter must route capture/captures inbound values through compatibility.",
    )
    require(
        'case "motion", "pulse":' in app_tab,
        errors,
        "Legacy route adapter must route motion/pulse inbound values through compatibility.",
    )

    for legacy, canonical in COMPATIBILITY_ROUTES.items():
        require(
            f'case "{legacy}"' in app_tab or f'case "{legacy}",' in app_tab or f', "{legacy}":' in app_tab,
            errors,
            f"Legacy route adapter missing {legacy} inbound mapping to {canonical}.",
        )

    require(
        "LegacyIARouteCompatibility.externalRoute" in external_routing,
        errors,
        "External routing must use the bounded legacy IA adapter.",
    )
    require(
        ".openCaptureComposer" in app_tab and "presentCaptureCompatibilityRoute" in navigation,
        errors,
        "Capture compatibility must resolve to the global composer overlay, not a root tab.",
    )
    require(
        "target == .captureInbox" in navigation and "presentCaptureCompatibilityRoute" in navigation,
        errors,
        "Capture inbox compatibility route must stay overlay-owned by navigation.",
    )
    require(
        "Legacy Motion destination maps to Today for compatibility." in external_routing,
        errors,
        "Motion compatibility must route to Today instead of a root Motion destination.",
    )
    require(
        "shell.meridian.destination.\\(tab.rawValue)" in shell_mode,
        errors,
        "Meridian shell accessibility identifiers must derive from canonical tab raw values.",
    )
    require(
        "destination.accessibilityIdentifier" in meridian_shell,
        errors,
        "Meridian shell must use canonical destination accessibility identifiers.",
    )
    require(
        ".toolbar(.hidden, for: .tabBar)" in root_view and "navigation.hasRootNavigationChrome" in root_view,
        errors,
        "Root shell chrome must hide native tab chrome and gate the custom dock by root-navigation state.",
    )
    require(
        "AppTab.allCases" in preview_matrix,
        errors,
        "Shell preview matrix must derive screenshot rows from AppTab.allCases.",
    )
    require(
        "renderedScreenshotProofClaim: false" in preview_matrix
        and "accessibilityCertificationClaim: false" in preview_matrix
        and "releaseReadinessClaim: false" in preview_matrix
        and "deviceProofClaim: false" in preview_matrix
        and "ciProofClaim: false" in preview_matrix,
        errors,
        "Scenario matrix must keep screenshot, accessibility, release, device, and CI proof claims false.",
    )
    require(
        "case time" in app_intent and not re.search(r"\bcase\s+plan\b", app_intent),
        errors,
        "Open destination App Intent must expose Time, not a competing Plan destination case.",
    )

    if errors:
        print("RED: surface contract lint failed")
        for error in errors:
            print(f"- {error}")
        return 1

    print("GREEN: Train 2 surface contract lint passed")
    print("- Root surfaces are Today, Goals, Time, You.")
    print("- Capture remains a global composer/overlay compatibility path, not a root surface.")
    print("- Motion remains a Stage/Motion behavior compatibility path, not a root surface.")
    print("- Shell chrome, App Intent destinations, scenario matrix rows, and proof-boundary non-claims are source-aligned.")
    for raw, title, primary in ROOT_SURFACES:
        print(f"- {title} ({raw}) -> {primary}")
    print("Compatibility routes remain adapter-bounded:")
    for legacy, canonical in COMPATIBILITY_ROUTES.items():
        print(f"- {legacy} -> {canonical}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
