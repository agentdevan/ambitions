#!/usr/bin/env python3
"""Audit active source for root-level architecture-as-UI regressions."""

from __future__ import annotations

from pathlib import Path
import re
import sys


ROOT = Path(__file__).resolve().parents[1]

ACTIVE_SOURCE_ROOTS = [
    ROOT / "Native" / "Ambitions",
    ROOT / "Sources",
    ROOT / "Packages",
]

EXCLUDED_PATH_PARTS = {
    "Native/AmbitionsTests",
    "Native/AmbitionsUITests",
    "docs/quality",
    "docs/qa",
}

INSPECTION_ALLOWED_PARTS = {
    "Trust/",
    "Inspection",
    "WhyThis",
}

POLICY_DEFINITION_PARTS = {
    "ForbiddenTopLevelTerms.swift",
    "Language/",
}

DISALLOWED_ROOT_TERMS = {
    "Shell context crown": "describe the surface or object directly",
    "Motion Current": "Stage Motion behavior or the changed object",
    "Proof seam": "saved/history/review state",
    "route reveal": "placement preview",
    "route-reveal": "placement-preview",
    "Local source:": "Started from",
    "Open receipt": "History",
    "Re-enter thread": "Return",
}

STRUCTURAL_GATES = [
    (
        "Native/Ambitions/Surfaces/Goals/GoalsObjectView.swift",
        "LazyVGrid(",
        "Goals root must be a connected Life Area Atlas object, not a card/grid surface.",
    ),
    (
        "Native/Ambitions/Surfaces/Goals/GoalsObjectView.swift",
        "LifeAreaRegionButton",
        "Goals life areas must be object nodes inside the atlas, not card buttons.",
    ),
    (
        "Native/Ambitions/Surfaces/Goals/GoalsObjectView.swift",
        "CurrentStepLift",
        "The current Step must live inside the atlas object, not below it as a separate card.",
    ),
    (
        "Native/Ambitions/Surfaces/You/YouRootSurface.swift",
        "PersonalSystemCenterRootView",
        "You root must be the User System Profile, not a governance/control-center surface.",
    ),
    (
        "Native/Ambitions/Surfaces/You/YouRootSurface.swift",
        "YouPersonalSystemNavigation(",
        "You root must use native profile/settings rows, not custom grouped navigation chrome.",
    ),
    (
        "Native/Ambitions/Stage/Motion/StageMotionCurrentView.swift",
        "projection ??",
        "Stage Motion must not synthesize a production fallback projection.",
    ),
    (
        "Native/Ambitions/Stage/Motion/StageMotionState.swift",
        "objectConsequence(renderState:",
        "Motion fixture projection must not be the production object-consequence path.",
    ),
    (
        "Native/Ambitions/Stage/Overlays/QuietCommandCaptureOverlay.swift",
        "CaptureObjectView(",
        "Quick Capture overlay must route to the activated composer instead of rendering a second composer.",
    ),
    (
        "Native/Ambitions/Stage/Overlays/QuietCommandCaptureOverlay.swift",
        "saveCapture()",
        "Quick Capture overlay must not save from a sheet fallback.",
    ),
    (
        "Native/Ambitions/DesignSystem/ProductObjects/LifeShapeFieldView.swift",
        "if Self.screenshotFocusesQuietReflow() {\n                reflowTrustSeam",
        "LifeShape reflow must be embedded in the Time object, not rendered as a root sibling before the field.",
    ),
]

REQUIRED_STRUCTURAL_MARKERS = [
    (
        "Native/Ambitions/Surfaces/Goals/GoalsObjectView.swift",
        "LifeAreaAtlasField(",
        "Goals root must render the connected LifeAreaAtlasField.",
    ),
    (
        "Native/Ambitions/Surfaces/You/YouObjectView.swift",
        "UserSystemProfileRootView(",
        "You root adapter must render the native User System Profile root.",
    ),
    (
        "Native/Ambitions/DesignSystem/ProductObjects/LifeShapeFieldView.swift",
        "objectCanvasWithEmbeddedConsequences",
        "Time must embed mutation/reflow consequences in the LifeShape object.",
    ),
]

PRIMARY_UI_FILES = (
    "Surface.swift",
    "ObjectView.swift",
    "AppShell",
    "StageMotion",
    "MotionCurrent",
    "Capture",
    "StageDock",
    "HeaderRail",
    "ContextCrown",
    "Flagship",
)


def rel(path: Path) -> str:
    return str(path.relative_to(ROOT))


def is_excluded(path: Path) -> bool:
    relative = rel(path)
    return any(part in relative for part in EXCLUDED_PATH_PARTS)


def is_inspection_allowed(path: Path) -> bool:
    relative = rel(path)
    return any(part in relative for part in INSPECTION_ALLOWED_PARTS)


def is_policy_definition(path: Path) -> bool:
    relative = rel(path)
    return any(part in relative for part in POLICY_DEFINITION_PARTS)


def is_primary_ui_file(path: Path) -> bool:
    name = path.name
    relative = rel(path)
    return any(marker in name or marker in relative for marker in PRIMARY_UI_FILES)


def string_literals(line: str) -> list[str]:
    return re.findall(r'"([^"\\]*(?:\\.[^"\\]*)*)"', line)


def line_number_for(contents: str, pattern: str) -> int:
    index = contents.find(pattern)
    if index < 0:
        return 1
    return contents.count("\n", 0, index) + 1


def main() -> int:
    failures: list[str] = []
    for relative, pattern, message in STRUCTURAL_GATES:
        path = ROOT / relative
        if not path.exists():
            continue
        text = path.read_text(encoding="utf-8")
        if pattern in text:
            failures.append(
                f"{relative}:{line_number_for(text, pattern)}: `{pattern.splitlines()[0]}` is blocked; {message}"
            )

    for relative, marker, message in REQUIRED_STRUCTURAL_MARKERS:
        path = ROOT / relative
        if not path.exists():
            failures.append(f"{relative}:1: required file is missing; {message}")
            continue
        text = path.read_text(encoding="utf-8")
        if marker not in text:
            failures.append(f"{relative}:1: `{marker}` missing; {message}")

    for root in ACTIVE_SOURCE_ROOTS:
        if not root.exists():
            continue
        for path in sorted(root.rglob("*.swift")):
            if is_excluded(path):
                continue
            if is_policy_definition(path):
                continue
            if not is_primary_ui_file(path) and not is_inspection_allowed(path):
                continue
            text = path.read_text(encoding="utf-8")
            for line_number, line in enumerate(text.splitlines(), start=1):
                stripped = line.strip()
                if stripped.startswith("//"):
                    continue
                literals = " ".join(string_literals(line))
                if not literals:
                    continue
                for term, replacement in DISALLOWED_ROOT_TERMS.items():
                    if term.lower() not in literals.lower():
                        continue
                    if is_inspection_allowed(path) and term in {"Open receipt", "Local source:"}:
                        continue
                    failures.append(
                        f"{rel(path)}:{line_number}: `{term}` appears in active UI string; use {replacement}"
                    )

    print("# Ambitions Green Standard Audit")
    if failures:
        for failure in failures:
            print(f"RED: {failure}", file=sys.stderr)
        return 1

    print("GREEN: no disallowed architecture-as-UI strings found in active primary UI source")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
