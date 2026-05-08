#!/usr/bin/env python3
"""ACX Repair: non-mutating repair diagnosis/proposal tool for Ambitions Codex OS.

Default behavior is read-only and narrow. It will not scan all logs or mutate repair
state unless explicitly requested.
"""

from __future__ import annotations

import argparse
import re
from pathlib import Path
from typing import Sequence

ROOT = Path(__file__).resolve().parents[2]
ACTIVE_REPAIR = ROOT / ".codex" / "state" / "active-repair.yml"
REPAIR_LEDGER = ROOT / ".codex" / "state" / "repair-ledger.md"
LOG_ROOT = ROOT / ".codex" / "logs"

CLASSIFIERS = [
    ("SafetyExpected-invalid-profile", [r"Unknown profile rejected before execution", r"invalid-profile", r"__invalid_profile__"]),
    ("R10-hard-red-stop", [r"Hard Red", r"STOPPED ON RED", r"unknown dirty tree", r"privacy/security/legal ambiguity"]),
    ("R9-source-truth-conflict", [r"source-truth conflict", r"owner conflict", r"contradiction"]),
    ("R8-test-failure", [r"TEST FAILED", r"XCTest", r"failed test"]),
    ("R7-build-failure", [r"BUILD FAILED", r"\berror:", r"\.swift:\d*"]),
    ("R6-xcodegen-project-drift", [r"xcodegen", r"project.yml", r"generated project"]),
    ("R5-cqs-advisory", [r"CQS", r"Accepted Yellow", r"advisory"]),
    ("R4-unsupported-release-claim", [r"production-ready", r"release-ready", r"TestFlight ready", r"App Store ready", r"device verified", r"fully accessible"]),
    ("R3-deprecated-language", [r"next best move", r"Your best next move", r"\bInsights\b"]),
    ("R2-docs-drift", [r"stale route", r"missing index", r"docs drift"]),
    ("R1-formatting-whitespace", [r"trailing whitespace", r"whitespace error", r"git diff --check"]),
]

AUTO_SAFE = {
    "R1-formatting-whitespace",
    "R2-docs-drift",
    "R3-deprecated-language",
    "R4-unsupported-release-claim",
}
SAFETY_EXPECTED = {"SafetyExpected-invalid-profile"}
HARD_STOP = {"R9-source-truth-conflict", "R10-hard-red-stop"}


def read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8", errors="replace") if path.exists() else ""


def safe_repo_path(raw: str) -> Path | None:
    target = (ROOT / raw).resolve()
    try:
        target.relative_to(ROOT)
    except ValueError:
        return None
    return target


def latest_logs(limit: int = 8) -> list[Path]:
    if not LOG_ROOT.exists():
        return []
    files = [p for p in LOG_ROOT.rglob("*.raw.log") if p.is_file()]
    return sorted(files, key=lambda p: p.stat().st_mtime, reverse=True)[:limit]


def classify_text(text: str) -> list[str]:
    hits: list[str] = []
    for name, patterns in CLASSIFIERS:
        if any(re.search(pattern, text, flags=re.IGNORECASE) for pattern in patterns):
            hits.append(name)

    # Intentional safety-test logs should not also become hard Red because they
    # contain the word "Red" in their summary.
    if any(hit in SAFETY_EXPECTED for hit in hits):
        hits = [hit for hit in hits if hit in SAFETY_EXPECTED]

    return hits or ["NoActiveRepairEvidence"]


def result_for(classes: list[str]) -> tuple[str, bool, bool]:
    hard = any(item in HARD_STOP for item in classes)
    safety_expected = all(item in SAFETY_EXPECTED for item in classes)
    no_evidence = classes == ["NoActiveRepairEvidence"]
    auto_safe = all(item in AUTO_SAFE for item in classes)

    if hard:
        return "Red", auto_safe, True
    if safety_expected:
        return "Green", False, False
    if no_evidence:
        return "Yellow", False, False
    if auto_safe:
        return "Green", True, False
    return "Yellow", False, False


def write_active(result: str, source: str, classes: list[str]) -> None:
    ACTIVE_REPAIR.parent.mkdir(parents=True, exist_ok=True)
    ACTIVE_REPAIR.write_text(
        "status: active\n"
        f"source: \"{source}\"\n"
        f"result: \"{result}\"\n"
        "classes:\n"
        + "".join(f"  - {item}\n" for item in classes)
        + "rules:\n"
        + "  default_diagnose_is_read_only: true\n"
        + "  all_logs_requires_all_logs_flag: true\n"
        + "  state_writes_require_write_state_flag: true\n"
        + "  invalid_profile_safety_logs_are_expected: true\n"
        + "  hard_stop_on_source_truth_conflict: true\n"
        + "  hard_stop_on_privacy_security_legal_ambiguity: true\n",
        encoding="utf-8",
    )


def append_ledger(source: str, result: str, classes: list[str], auto_safe: bool, hard: bool) -> None:
    REPAIR_LEDGER.parent.mkdir(parents=True, exist_ok=True)
    existing = read_text(REPAIR_LEDGER).rstrip()
    if not existing:
        existing = "# Repair Ledger\n\nStatus: Compact repair history. Full raw proof remains in local logs.\n"
    entry = (
        "\n\n## Repair diagnosis\n\n"
        f"- Source: `{source}`\n"
        f"- Result: `{result}`\n"
        "- Classes:\n"
        + "".join(f"  - `{item}`\n" for item in classes)
        + f"- Auto-safe: {'yes' if auto_safe else 'no'}\n"
        + f"- Hard stop: {'yes' if hard else 'no'}\n"
    )
    REPAIR_LEDGER.write_text(existing + entry + "\n", encoding="utf-8")


def diagnose_text(text: str, source: str, write_state: bool) -> int:
    classes = classify_text(text)
    result, auto_safe, hard = result_for(classes)

    if write_state:
        write_active(result, source, classes)
        append_ledger(source, result, classes, auto_safe, hard)

    print("# ACX Repair Diagnosis")
    print(f"- Source: `{source}`")
    print(f"- Result: {result}")
    print("- Classes:")
    for item in classes:
        print(f"  - {item}")
    print(f"- Auto-safe repair: {'yes' if auto_safe else 'no'}")
    print(f"- Hard stop: {'yes' if hard else 'no'}")
    print(f"- State written: {'yes' if write_state else 'no'}")

    print("\n## Next action")
    if hard:
        print("Stop and produce a hard-Red restart/decision prompt. Do not continue automatically.")
        return 1
    if all(item in SAFETY_EXPECTED for item in classes):
        print("Intentional safety-test Red recognized as expected. No repair required.")
        return 0
    if classes == ["NoActiveRepairEvidence"]:
        print("No active repair evidence supplied. Use --log <file> for a specific failure or --all-logs for broad triage.")
        return 0
    if auto_safe:
        print("Safe for Codex to propose a narrow docs/tooling/copy repair, then rerun the mapped validation bundle.")
        return 0

    print("Produce a repair proposal. Do not mutate app source automatically.")
    return 0


def command_diagnose(args: argparse.Namespace) -> int:
    if args.log:
        path = safe_repo_path(args.log)
        if path is None or not path.is_file():
            print("Red: requested log is unavailable or outside repo root.")
            return 2
        return diagnose_text(read_text(path), str(path.relative_to(ROOT)), args.write_state)

    if args.all_logs:
        logs = latest_logs(args.limit)
        if not logs:
            return diagnose_text("", "all-logs requested, no raw logs found", args.write_state)
        text = "\n".join(read_text(path) for path in logs)
        return diagnose_text(text, f"latest {len(logs)} raw logs", args.write_state)

    return diagnose_text("", "no log supplied; default diagnose is read-only and narrow", args.write_state)


def command_propose(_: argparse.Namespace) -> int:
    text = read_text(ACTIVE_REPAIR)
    print("# ACX Repair Proposal")
    if not text or "status: idle" in text or "active_repair: null" in text:
        print("Yellow: no active repair state. Run `python3 scripts/ai/acx_repair.py diagnose --log <file> --write-state` for a specific failure.")
        return 0

    print(text)
    if "R9-source-truth-conflict" in text or "R10-hard-red-stop" in text:
        print("Recommended: stop, preserve evidence, and use `.codex/templates/hard-red-restart-prompt.md`.")
        return 1
    if "SafetyExpected-invalid-profile" in text:
        print("Recommended: no repair required for intentional invalid-profile safety test.")
        return 0
    if any(item in text for item in AUTO_SAFE):
        print("Recommended: perform only narrow docs/tooling/copy repair, then rerun mapped validation bundle and closeout.")
        return 0

    print("Recommended: write a repair plan first; do not auto-mutate Swift/runtime source.")
    return 0


def command_closeout(_: argparse.Namespace) -> int:
    text = read_text(ACTIVE_REPAIR)
    print("# ACX Repair Closeout")
    if not text or "status: idle" in text or "active_repair: null" in text:
        print("Yellow: no active repair state recorded.")
        return 0
    print(text)
    print("Required closeout: rerun mapped bundle, update repair ledger if --write-state was used, report Green/Yellow/Red, and name claims not made.")
    return 0


def main(argv: Sequence[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Diagnose and propose repair loops without mutating app source.")
    sub = parser.add_subparsers(dest="command", required=True)

    diagnose = sub.add_parser("diagnose")
    diagnose.add_argument("--log")
    diagnose.add_argument("--all-logs", action="store_true")
    diagnose.add_argument("--limit", type=int, default=8)
    diagnose.add_argument("--write-state", action="store_true")

    sub.add_parser("propose")
    sub.add_parser("closeout")

    args = parser.parse_args(argv)

    if args.command == "diagnose":
        return command_diagnose(args)
    if args.command == "propose":
        return command_propose(args)
    if args.command == "closeout":
        return command_closeout(args)
    return 2


if __name__ == "__main__":
    raise SystemExit(main())
