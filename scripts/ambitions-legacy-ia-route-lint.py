#!/usr/bin/env python3
"""Lint active route APIs for retired top-level IA seams."""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

CHECKS: list[tuple[str, str, str]] = [
    ("Native/Ambitions/App/AppTab.swift", r"\bcase\s+habits\b", "AppTab must not expose Habits as an active tab case."),
    ("Native/Ambitions/App/AppTab.swift", r"\bcase\s+insights\b", "AppTab must not expose Insights as an active tab case."),
    ("Native/Ambitions/App/AppTab.swift", r"static\s+let\s+(captures|plan|profile)\b", "Legacy AppTab aliases must live in compatibility adapters, not active tab API."),
    ("Native/Ambitions/App/AppExternalRouting.swift", r"\bopenInsightsRoute\b", "External route API must use openYouRoute; insights is inbound compatibility only."),
    ("Native/Ambitions/App/ShellCommandModels.swift", r"\bcase\s+planRoute\b", "Shell command destinations must use timeRoute, not planRoute."),
    ("Native/Ambitions/App/ShellCommandModels.swift", r"\bquickPlanPatch\b", "Shell command intent case name must use Time naming; raw legacy value may remain."),
    ("Native/Ambitions/AppIntents/OpenAmbitionsDestinationIntent.swift", r"\bcase\s+plan\b", "App Intent destination case name must use Time naming; raw legacy value may remain."),
    ("Native/Ambitions/AppIntents/OpenAmbitionsDestinationIntent.swift", r"\bquickPlanPatch\b", "App Intent quick route case name must use Time naming; raw legacy value may remain."),
]

REQUIRED_MARKERS: list[tuple[str, str, str]] = [
    ("Native/Ambitions/App/AppTab.swift", "enum LegacyIARouteCompatibility", "Legacy IA compatibility adapter is required."),
    ("Native/Ambitions/App/AppNavigation.swift", "init(legacyTabRawValue", "Legacy stored-tab navigation seed adapter is required."),
    ("Native/Ambitions/App/AppExternalRouting.swift", "LegacyIARouteCompatibility.externalRoute", "External route translator must use the legacy IA adapter."),
]


def read(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")


def main() -> int:
    errors: list[str] = []
    for rel_path, pattern, message in CHECKS:
        text = read(rel_path)
        if re.search(pattern, text):
            errors.append(f"{rel_path}: {message}")

    for rel_path, marker, message in REQUIRED_MARKERS:
        text = read(rel_path)
        if marker not in text:
            errors.append(f"{rel_path}: {message}")

    if errors:
        print("RED: legacy IA route lint failed")
        for error in errors:
            print(f"- {error}")
        return 1

    print("GREEN: active route APIs are canonical; legacy IA is adapter-bounded")
    return 0


if __name__ == "__main__":
    sys.exit(main())
