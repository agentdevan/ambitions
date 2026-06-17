#!/usr/bin/env python3
"""Validate active Ambitions canon and IA locks.

This validator intentionally checks authority/docs contracts, not app build success.
"""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]

ACTIVE_SURFACES = "Today / Goals / Time / You"
ACTIVE_COMMA = "Today, Goals, Time, You"
GLOBAL_CAPTURE = "Capture"
BEHAVIOR_MOTION = "Motion"

REQUIRED_ACTIVE_FILES = [
    "AGENTS.md",
    ".codex/os/AMBITIONS_OPERATING_CONTEXT.md",
    "docs/truth/PRODUCT_DESIGN_TRUTH.md",
    "docs/truth/IMPLEMENTATION_TRUTH.md",
    "docs/truth/CODEX_PROCESS_TRUTH.md",
]

FORBIDDEN_ACTIVE_IA = [
    "Today / Goals / Time / Motion / You",
    "Today, Goals, Time, Motion, You",
    "Today, Goals, Time, Motion, and You",
    "Today / Goals / Capture / Time / You",
    "Today, Goals, Capture, Time, You",
]


def read(rel: str) -> str:
    path = ROOT / rel
    return path.read_text(encoding="utf-8", errors="ignore") if path.exists() else ""


def check(condition: bool, failures: list[str], message: str) -> None:
    if not condition:
        failures.append(message)


def allowed_legacy_line(line: str) -> bool:
    lowered = line.lower()
    return any(
        marker in lowered
        for marker in (
            "legacy",
            "historical",
            "compatibility",
            "superseded",
            "forbidden",
            "stale",
            "migration debt",
            "not active",
            "not current",
            "must not",
            "do not",
            "red if",
        )
    )


def validate() -> list[str]:
    failures: list[str] = []

    for rel in REQUIRED_ACTIVE_FILES:
        check((ROOT / rel).exists(), failures, f"missing required canon/IA file: {rel}")
    if failures:
        return failures

    product_truth = read("docs/truth/PRODUCT_DESIGN_TRUTH.md")
    implementation_truth = read("docs/truth/IMPLEMENTATION_TRUTH.md")
    agents = read("AGENTS.md")
    operating_context = read(".codex/os/AMBITIONS_OPERATING_CONTEXT.md")
    combined = "\n".join(read(rel) for rel in REQUIRED_ACTIVE_FILES)

    check(ACTIVE_SURFACES in product_truth, failures, "product truth missing active four-surface law")
    check("Capture is the global composer" in product_truth, failures, "product truth missing Capture global composer law")
    check("Motion is cross-surface behavior" in product_truth, failures, "product truth missing Motion behavior law")
    check("Ambitions supports custom Ambitions Accounts at launch" in product_truth, failures, "product truth missing Ambitions Account launch law")
    check("R2 is not a user-data backend" in product_truth, failures, "product truth missing R2 user-data boundary")
    check("Hosted AI services and cloud LLMs are not core architecture" in product_truth, failures, "product truth missing hosted AI/cloud LLM boundary")

    check(ACTIVE_SURFACES in agents, failures, "AGENTS missing active four-surface law")
    check(ACTIVE_SURFACES in operating_context, failures, "operating context missing active four-surface law")
    check("Motion is not a tab" in agents or "Motion is not a destination" in agents, failures, "AGENTS missing Motion-not-root law")
    check("Motion is not current product root IA" in implementation_truth or "Motion is not current product root IA" in combined or "Motion source is now compatibility" in implementation_truth, failures, "implementation truth missing Motion compatibility classification")

    for rel in REQUIRED_ACTIVE_FILES:
        text = read(rel)
        for legacy in FORBIDDEN_ACTIVE_IA:
            for line_no, line in enumerate(text.splitlines(), start=1):
                if legacy in line and not allowed_legacy_line(line):
                    failures.append(f"{rel}:{line_no}: stale active IA literal remains: {legacy}")

    forbidden_motion_patterns = [
        r"Motion\s+replaces\s+Pulse\s+as\s+the\s+approved\s+fifth\s+tab",
        r"Motion\s+is\s+the\s+approved\s+fifth\s+tab",
        r"Motion\s+is\s+active\s+product/design\s+truth\s+and\s+is\s+now\s+source-wired\s+as\s+a\s+top-level\s+canonical\s+tab",
    ]
    for pattern in forbidden_motion_patterns:
        check(re.search(pattern, combined, re.I) is None, failures, f"stale Motion root-canon phrase remains: {pattern}")

    app_tab = read("Native/Ambitions/App/AppTab.swift")
    if app_tab:
        if ".motion" in app_tab:
            failures.append("Native/Ambitions/App/AppTab.swift still appears to include .motion; under current product truth this is migration debt and should not pass canonical IA validation")
        if ".capture" in app_tab and "compat" not in app_tab.lower():
            failures.append("Native/Ambitions/App/AppTab.swift includes .capture without clear compatibility context")

    return failures


def main() -> int:
    failures = validate()
    for failure in failures:
        print("FAIL " + failure)
    if failures:
        return 1
    print("PASS amb-master canon IA lock matches Today/Goals/Time/You, global Capture, Motion behavior, optional Ambitions Account, and R2 reference boundary")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
