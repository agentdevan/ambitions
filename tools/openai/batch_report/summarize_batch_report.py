#!/usr/bin/env python3
"""Extract summary fields from local batch closeout reports."""
from __future__ import annotations

import argparse
import json
import re
from pathlib import Path

STATUS_RE = re.compile(r"\bSTATUS:\s*(GREEN|YELLOW|RED)\b", re.I)
PLAIN_STATUS_RE = re.compile(r"^(GREEN|YELLOW|RED)$", re.I)
COMMAND_EXIT_RE = re.compile(r"^\s*(?:\d+[\).]\s*)?(?P<command>.+?)\s*:\s*(?P<exit_code>\d+)\s*$")
FILE_SECTION_RE = re.compile(r"files|changed files|created/updated", re.I)
VALIDATION_RE = re.compile(r"validation", re.I)
NO_CLAIM_RE = re.compile(r"no-claim|claims not made|do not claim|not claimed|no claims", re.I)
NEXT_RE = re.compile(r"next" , re.I)


def extract_bullets(lines: list[str], start: int) -> list[str]:
    collected: list[str] = []
    for i in range(start + 1, len(lines)):
        if lines[i].startswith("## ") and lines[i-1].strip() == "":
            break
        if lines[i].strip().startswith("- "):
            collected.append(lines[i].strip()[2:].strip())
    return collected


def extract_validation_commands(lines: list[str], start: int) -> list[dict[str, str | int | None]]:
    collected: list[dict[str, str | int | None]] = []
    in_fence = False
    for i in range(start + 1, len(lines)):
        line = lines[i]
        if line.startswith("## ") and not in_fence:
            break
        stripped = line.strip()
        if stripped.startswith("```"):
            in_fence = not in_fence
            continue
        if not stripped:
            continue
        if stripped.startswith("- "):
            candidate = stripped[2:].strip()
            match = COMMAND_EXIT_RE.match(candidate)
            if match:
                collected.append({
                    "command": match.group("command").strip(),
                    "exit_code": int(match.group("exit_code")),
                })
            else:
                collected.append({"command": candidate, "exit_code": None})
            continue
        if in_fence:
            match = COMMAND_EXIT_RE.match(stripped)
            if match:
                collected.append({
                    "command": match.group("command").strip(),
                    "exit_code": int(match.group("exit_code")),
                })
    return collected


def extract_status(text: str, lines: list[str]) -> str | None:
    status_match = STATUS_RE.search(text)
    if status_match:
        return status_match.group(1).upper()
    for i, line in enumerate(lines):
        if line.lower().strip() == "## status":
            for candidate in lines[i + 1:]:
                stripped = candidate.strip()
                if not stripped:
                    continue
                match = PLAIN_STATUS_RE.match(stripped)
                return match.group(1).upper() if match else None
    return None


def summarize(path: Path) -> dict:
    text = path.read_text(encoding="utf-8", errors="ignore")
    lines = text.splitlines()

    status = extract_status(text, lines)

    changed_files = []
    validation_commands = []
    missing_rollback = "rollback" not in text.lower()
    missing_no_claim = not bool(NO_CLAIM_RE.search(text))
    missing_next_handoff = not bool(NEXT_RE.search(text))

    for i, line in enumerate(lines):
        low = line.lower().strip()
        if low.startswith("## ") and FILE_SECTION_RE.search(low):
            changed_files.extend(extract_bullets(lines, i))
        if low.startswith("## ") and VALIDATION_RE.search(low):
            validation_commands.extend(extract_validation_commands(lines, i))

    return {
        "status": status,
        "changed_files": changed_files,
        "validation_commands": validation_commands,
        "rollback_present": not missing_rollback,
        "no_claim_language_present": not missing_no_claim,
        "next_handoff_present": not missing_next_handoff,
        "path": str(path),
    }


def main() -> int:
    parser = argparse.ArgumentParser(description="Summarize closeout report")
    parser.add_argument("report")
    args = parser.parse_args()

    path = Path(args.report)
    if not path.exists():
        print(f"Missing report: {path}")
        return 1

    summary = summarize(path)
    print(json.dumps(summary, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
