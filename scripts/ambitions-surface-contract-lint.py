#!/usr/bin/env python3
"""Validate active surface references against the canonical app surface contract."""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

CANONICAL_SURFACES = [
    ("today", "Today", "Reality Meridian"),
    ("goals", "Goals", "Constellation Atlas"),
    ("capture", "Capture", "Atmosphere Composer"),
    ("time", "Time", "LifeShape Field"),
    ("you", "You", "User System Profile"),
]

COMPATIBILITY_ROUTES = {
    "captures": "capture",
    "plan": "time",
    "habits": "time",
    "profile": "you",
    "insights": "you",
}

REQUIRED_RUNTIME_TERMS = [
    "SourceRecord",
    "Receipt",
    "ReplayTrace",
    "You / What Ambitions knows",
]

ROUTE_MAP = ROOT / "docs/proof/afri/afri-020-surface-route-map.md"


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
    external_routing = read("Native/Ambitions/App/AppExternalRouting.swift")
    app_intent = read("Native/Ambitions/AppIntents/OpenAmbitionsDestinationIntent.swift")
    preview_matrix = read("Native/Ambitions/PreviewSupport/ShellPreviewMatrix.swift")
    afri019_proof = read("docs/proof/afri/afri-019-surface-contract-proof.md")
    afri005_proof = read("docs/proof/afri/afri-005-shell-preview-screenshot-proof.md")
    route_map = read(ROUTE_MAP)

    require(
        "[.today, .goals, .capture, .time, .you]" in app_tab,
        errors,
        "AppTab.allCases must remain Today, Goals, Capture, Time, You.",
    )

    for raw, title, primary in CANONICAL_SURFACES:
        contract_snippet = f'AmbitionsSurfaceContract(tab: .{raw}, title: "{title}", primaryObjectTitle: "{primary}")'
        require(contract_snippet in app_tab, errors, f"AppTab.swift missing surface contract {title} -> {primary}.")
        require(f'Tab(AppTab.{raw}.title' in root_view, errors, f"AmbitionsRootView missing shell tab for {title}.")
        require(f"AppTab.{raw}.systemImage" in root_view, errors, f"AmbitionsRootView missing tab icon source for {title}.")
        require(f"| {title} | `{raw}` | {primary} |" in route_map, errors, f"Route map missing active row for {title}.")

    for term in REQUIRED_RUNTIME_TERMS:
        require(term in app_tab, errors, f"AppTab surface contract must preserve runtime term {term}.")
        require(term in afri019_proof, errors, f"AFRI-019 proof must preserve runtime term {term}.")

    require(
        not re.search(r"\bcase\s+(captures|plan|profile|habits|insights)\b", app_tab),
        errors,
        "AppTab must not expose compatibility names as active enum cases.",
    )

    for legacy, canonical in COMPATIBILITY_ROUTES.items():
        require(f'case "{legacy}"' in app_tab, errors, f"Legacy route adapter missing {legacy} inbound mapping.")
        require(
            f"| `{legacy}` | `{canonical}` |" in route_map,
            errors,
            f"Route map missing compatibility row for {legacy} -> {canonical}.",
        )

    require(
        "LegacyIARouteCompatibility.externalRoute" in external_routing,
        errors,
        "External routing must use the bounded legacy IA adapter.",
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
        "shell.\\(tab.rawValue).memory-lens-button" in root_view,
        errors,
        "Shell utility accessibility identifiers must derive from canonical tab raw values.",
    )
    require(
        "AppTab.allCases" in preview_matrix,
        errors,
        "Shell preview matrix must derive screenshot rows from AppTab.allCases.",
    )
    require(
        "case time" in app_intent and not re.search(r"\bcase\s+plan\b", app_intent),
        errors,
        "Open destination App Intent must expose Time, not a competing Plan destination case.",
    )

    for _, title, primary in CANONICAL_SURFACES:
        require(title in afri005_proof or title in afri019_proof, errors, f"Proof artifacts missing surface title {title}.")
        require(primary in afri019_proof, errors, f"AFRI-019 proof missing primary object {primary}.")

    if errors:
        print("RED: surface contract lint failed")
        for error in errors:
            print(f"- {error}")
        return 1

    print("GREEN: active route, shell, App Intent, preview, accessibility identifier, and proof references align with the surface contract")
    for raw, title, primary in CANONICAL_SURFACES:
        print(f"- {title} ({raw}) -> {primary}")
    print("Compatibility routes remain adapter-bounded and non-user-facing:")
    for legacy, canonical in COMPATIBILITY_ROUTES.items():
        print(f"- {legacy} -> {canonical}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
