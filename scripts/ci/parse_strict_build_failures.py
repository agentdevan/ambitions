#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import re
from datetime import datetime, timezone
from pathlib import Path

SWIFT_LOCATION = re.compile(r"^(?P<file>.*?\.swift):(?P<line>\d+):(?P<column>\d+):\s*(?P<severity>error|warning):\s*(?P<message>.+)$")
GENERIC_LOCATION = re.compile(r"^(?P<file>[^:]+):(?P<line>\d+):(?P<column>\d+):\s*(?P<severity>error|warning):\s*(?P<message>.+)$")
PLAIN_ERROR = re.compile(r"(?P<severity>error|fatal error):\s*(?P<message>.+)", re.IGNORECASE)

NOISE = (
    "Command line invocation:",
    "User defaults from command line:",
    "Resolve Package Graph",
    "Resolved source packages:",
)


def read_status(root: Path) -> list[dict]:
    path = root / "phase-status.json"
    if not path.exists():
        return []
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except json.JSONDecodeError:
        return []


def parse_log(path: Path) -> list[dict]:
    diagnostics: list[dict] = []
    seen: set[tuple] = set()
    for index, raw in enumerate(path.read_text(encoding="utf-8", errors="replace").splitlines(), start=1):
        line = raw.strip()
        if not line or any(line.startswith(prefix) for prefix in NOISE):
            continue
        match = SWIFT_LOCATION.match(line) or GENERIC_LOCATION.match(line)
        if match:
            item = {
                "log": path.as_posix(),
                "log_line": index,
                "file": match.group("file"),
                "line": int(match.group("line")),
                "column": int(match.group("column")),
                "severity": match.group("severity"),
                "message": match.group("message"),
                "raw": raw,
            }
        else:
            plain = PLAIN_ERROR.search(line)
            if not plain:
                continue
            item = {
                "log": path.as_posix(),
                "log_line": index,
                "file": None,
                "line": None,
                "column": None,
                "severity": plain.group("severity").lower(),
                "message": plain.group("message"),
                "raw": raw,
            }
        key = (item["file"], item["line"], item["column"], item["severity"], item["message"])
        if key in seen:
            continue
        seen.add(key)
        diagnostics.append(item)
    return diagnostics


def main() -> int:
    parser = argparse.ArgumentParser(description="Parse strict Ambitions build/launch failures.")
    parser.add_argument("--root", required=True)
    parser.add_argument("--json", default=None)
    parser.add_argument("--markdown", default=None)
    args = parser.parse_args()

    root = Path(args.root)
    log_paths = sorted(root.rglob("*.log")) + sorted(root.rglob("*.txt"))
    diagnostics: list[dict] = []
    for path in log_paths:
        if path.name in {"strict-build-summary.md"}:
            continue
        diagnostics.extend(parse_log(path))

    phase_status = read_status(root)
    failed_phases = [phase for phase in phase_status if phase.get("exit_code") not in (0, None)]
    errors = [item for item in diagnostics if str(item.get("severity", "")).lower().endswith("error") or str(item.get("severity", "")).lower() == "error"]
    warnings = [item for item in diagnostics if str(item.get("severity", "")).lower() == "warning"]
    status = "GREEN_NO_FAILURES_PARSED" if not errors and not failed_phases else "RED_FAILURES_PARSED"
    report = {
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "root": root.as_posix(),
        "status": status,
        "failed_phases": failed_phases,
        "failure_count": len(errors),
        "warning_count": len(warnings),
        "failures": errors,
        "warnings": warnings,
    }

    json_path = Path(args.json) if args.json else root / "strict-build-failures.json"
    md_path = Path(args.markdown) if args.markdown else root / "strict-build-summary.md"
    json_path.parent.mkdir(parents=True, exist_ok=True)
    md_path.parent.mkdir(parents=True, exist_ok=True)
    json_path.write_text(json.dumps(report, indent=2, sort_keys=True) + "\n", encoding="utf-8")

    lines = [
        "# Ambitions Strict Build / Launch Summary",
        "",
        f"Status: `{report['status']}`",
        f"Failure count: `{len(errors)}`",
        f"Warning count: `{len(warnings)}`",
        "",
        "## Failed phases",
        "",
    ]
    if failed_phases:
        lines += ["| Phase | Exit | Log |", "|---|---:|---|"]
        for phase in failed_phases:
            lines.append(f"| `{phase.get('phase')}` | `{phase.get('exit_code')}` | `{phase.get('log')}` |")
    else:
        lines.append("No failed phase recorded.")
    lines += ["", "## Parsed failures", ""]
    if errors:
        lines += ["| File | Line | Column | Severity | Message | Log |", "|---|---:|---:|---|---|---|"]
        for item in errors[:200]:
            file = item.get("file") or ""
            line = item.get("line") or ""
            column = item.get("column") or ""
            message = str(item.get("message") or "").replace("|", "\\|")
            lines.append(f"| `{file}` | `{line}` | `{column}` | `{item.get('severity')}` | {message} | `{item.get('log')}:{item.get('log_line')}` |")
    else:
        lines.append("No compiler-style failures were parsed.")
    lines += ["", "## Parsed warnings", ""]
    if warnings:
        lines += ["| File | Line | Column | Message | Log |", "|---|---:|---:|---|---|"]
        for item in warnings[:200]:
            file = item.get("file") or ""
            line = item.get("line") or ""
            column = item.get("column") or ""
            message = str(item.get("message") or "").replace("|", "\\|")
            lines.append(f"| `{file}` | `{line}` | `{column}` | {message} | `{item.get('log')}:{item.get('log_line')}` |")
    else:
        lines.append("No warnings parsed.")
    lines += [
        "",
        "## Non-claims",
        "",
        "This parser does not fix source, infer release readiness, or replace the raw logs. Warnings are reported separately and do not mark the strict run red unless a phase fails.",
        "",
    ]
    md_path.write_text("\n".join(lines), encoding="utf-8")
    print(md_path.as_posix())
    print(json_path.as_posix())
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
