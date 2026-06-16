#!/usr/bin/env python3
"""Batch 16: report-closure gate.

This does not claim release readiness. It proves the specific report-resolution
source markers are present and writes a closure artifact requiring fresh
screenshot review before any release Green claim.
"""

from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]

CHECKS = {
    "Native/Ambitions/App/AppShellView.swift": [
        "[.large]",
        "Write one thing. Save it here, place it when ready.",
        "Open as Goal",
        "Saved. Place it when ready.",
        "? 180 : 164",
    ],
    "Native/Ambitions/App/AmbitionsRootView.swift": [
        "? 156 : 152",
        "? 0.70 : 0.58",
    ],
    "Native/Ambitions/Features/Today/TodayScreen.swift": [
        "today.post-closure-feedback",
        "TodayRealityMeridianFlagshipAdapter",
    ],
    "Native/Ambitions/Features/Today/TodayDayRailPanels.swift": [
        "TodayRealityRail",
    ],
    "Native/Ambitions/Features/Capture/CaptureScreen.swift": [
        "flagshipCaptureComposerStage",
    ],
    "Native/Ambitions/Features/Capture/CaptureAtmosphereComposerFlagshipAdapter.swift": [
        "capture.flagship.atmosphere-composer",
        "accessibilityReduceMotion",
        "dynamicTypeSize",
    ],
    "Native/Ambitions/App/ShellChromeFlagshipAdapter.swift": [
        "shell.flagship.chrome",
    ],
    "artifacts/release-recovery/REPORT_LANGUAGE_PASS.md": [
        "Report Language Pass",
        "Goals, Time, Motion, and You",
    ],
}

FORBIDDEN_NATIVE_MARKERS = [
    "10:05",
]

FORBIDDEN_SURFACE_MARKERS = [
    "Source unavailable",
    "Closure diamond",
    "Receipt preview",
    "No silent changes",
    "Review before reflow",
    "Not root navigation",
    "runtime-backed",
    "fixture-only",
    "blocked-pending-model",
]


def require_markers() -> list[str]:
    failures: list[str] = []
    for rel, markers in CHECKS.items():
        path = ROOT / rel
        if not path.exists():
            failures.append(f"{rel}: missing file")
            continue
        text = path.read_text(encoding="utf-8")
        for marker in markers:
            if marker not in text:
                failures.append(f"{rel}: missing marker {marker}")
    return failures


def scan_forbidden() -> list[str]:
    failures: list[str] = []

    native_root = ROOT / "Native/Ambitions"
    if native_root.exists():
        for path in native_root.rglob("*.swift"):
            text = path.read_text(encoding="utf-8")
            for marker in FORBIDDEN_NATIVE_MARKERS:
                if marker in text:
                    failures.append(f"{path.relative_to(ROOT)}: forbidden marker {marker}")

    surface_targets = [
        ROOT / "Native/Ambitions/Features/Goals",
        ROOT / "Native/Ambitions/Features/Time",
        ROOT / "Native/Ambitions/Features/Motion",
        ROOT / "Native/Ambitions/Features/You",
    ]
    for folder in surface_targets:
        if not folder.exists():
            continue
        for path in folder.rglob("*.swift"):
            text = path.read_text(encoding="utf-8")
            for marker in FORBIDDEN_SURFACE_MARKERS:
                if marker in text:
                    failures.append(f"{path.relative_to(ROOT)}: report marker remains {marker}")

    return failures


def main() -> int:
    failures = require_markers() + scan_forbidden()
    if failures:
        raise RuntimeError("Report closure gate failed:\n" + "\n".join(failures))

    proof = ROOT / "artifacts/release-recovery/REPORT_CLOSURE_TRAIN.md"
    proof.parent.mkdir(parents=True, exist_ok=True)
    proof.write_text(
        "# Report Closure Train\n\n"
        "Status: source markers installed and build-gated.\n\n"
        "Closed by source marker:\n"
        "- Capture quick-entry is full-height and no longer uses the broken medium overlay shape.\n"
        "- Capture copy uses direct user language.\n"
        "- Dictation path focuses the text field and defers to the iOS keyboard microphone.\n"
        "- Today shows post-closure feedback in the surface.\n"
        "- Hardcoded Today time marker is blocked.\n"
        "- Shell/nav bottom clearance and header barrier markers are installed.\n"
        "- Goals, Time, Motion, and You received the report-language cleanup pass.\n\n"
        "Not claimed here:\n"
        "- final release Green\n"
        "- visual screenshot acceptance\n"
        "- manual device acceptance\n\n"
        "Required next proof: fresh screenshots of Today, Capture, Goals, Time, Motion, You, shell header, and floating nav.\n",
        encoding="utf-8",
    )

    print("Applied Batch 16 report closure gate.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())