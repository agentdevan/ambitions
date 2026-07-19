#!/usr/bin/env python3
"""Generate a release evidence summary packet without running release commands."""

from __future__ import annotations

import argparse
import json
import platform
import subprocess
import sys
import tempfile
from datetime import datetime, timezone
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parents[1]

DEFAULT_NON_CLAIMS = [
    "No Release Green is claimed by this generated summary.",
    "No TestFlight readiness is claimed by this generated summary.",
    "No App Store readiness is claimed by this generated summary.",
    "No device readiness is claimed by this generated summary.",
    "No accessibility conformance is claimed by this generated summary.",
    "No privacy/legal approval is claimed by this generated summary.",
]


def run_text(command: list[str]) -> str:
    result = subprocess.run(
        command,
        cwd=ROOT,
        check=False,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    return result.stdout.strip()


def git_text(*args: str) -> str:
    return run_text(["git", *args])


def xcode_version() -> str:
    output = run_text(["xcodebuild", "-version"])
    if not output:
        return "not available"
    return "; ".join(line.strip() for line in output.splitlines() if line.strip())


def parse_json_record(raw: str, required: set[str], label: str) -> dict[str, Any]:
    try:
        data = json.loads(raw)
    except json.JSONDecodeError as error:
        raise SystemExit(f"invalid {label} JSON: {error}") from error
    if not isinstance(data, dict):
        raise SystemExit(f"{label} must be a JSON object")
    missing = sorted(required - data.keys())
    if missing:
        raise SystemExit(f"{label} missing required keys: {', '.join(missing)}")
    return data


def markdown_escape(value: Any) -> str:
    return str(value).replace("|", "\\|").replace("\n", "<br>")


def command_rows(records: list[dict[str, Any]]) -> str:
    if not records:
        return "| none | n/a | n/a | n/a | No command results were supplied. |\n"
    rows = []
    for record in records:
        rows.append(
            "| {id} | `{command}` | {exit_code} | {artifact_path} | {result} |".format(
                id=markdown_escape(record.get("id", "")),
                command=markdown_escape(record.get("command", "")),
                exit_code=markdown_escape(record.get("exit_code", "")),
                artifact_path=markdown_escape(record.get("artifact_path", "")),
                result=markdown_escape(record.get("result", "")),
            )
        )
    return "\n".join(rows) + "\n"


def skipped_rows(records: list[dict[str, Any]]) -> str:
    if not records:
        return "| none | n/a | n/a |\n"
    rows = []
    for record in records:
        rows.append(
            "| {id} | {reason} | {proof_ceiling} |".format(
                id=markdown_escape(record.get("id", "")),
                reason=markdown_escape(record.get("reason", "")),
                proof_ceiling=markdown_escape(record.get("proof_ceiling", "")),
            )
        )
    return "\n".join(rows) + "\n"


def build_packet(args: argparse.Namespace) -> tuple[dict[str, Any], str]:
    commands = [
        parse_json_record(
            raw,
            {"id", "command", "exit_code", "artifact_path", "result"},
            "command-record",
        )
        for raw in args.command_record
    ]
    skipped = [
        parse_json_record(raw, {"id", "reason", "proof_ceiling"}, "skipped-check")
        for raw in args.skipped_check
    ]

    branch = git_text("rev-parse", "--abbrev-ref", "HEAD") or "unknown"
    commit = git_text("rev-parse", "HEAD") or "unknown"
    remote_main = git_text("ls-remote", "origin", "refs/heads/main")
    generated_at = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    artifact_paths = [
        "release-evidence-summary.md",
        "release-evidence-summary.json",
        *args.artifact,
    ]
    non_claims = [*DEFAULT_NON_CLAIMS, *args.non_claim]

    packet: dict[str, Any] = {
        "issue": args.issue,
        "title": args.title,
        "status": args.status,
        "generated_at": generated_at,
        "branch": branch,
        "commit_sha": commit,
        "remote_main": remote_main,
        "environment": {
            "cwd": str(ROOT),
            "platform": platform.platform(),
            "python": platform.python_version(),
        },
        "xcode_version": xcode_version(),
        "simulator_or_device": args.simulator_or_device,
        "artifact_paths": artifact_paths,
        "command_records": commands,
        "skipped_checks": skipped,
        "known_risks": args.known_risk,
        "non_claims": non_claims,
        "claim_boundary": (
            "This packet summarizes supplied evidence records only. It does not run "
            "build, test, device, archive, upload, privacy/legal, accessibility, or "
            "release procedures."
        ),
    }

    markdown = f"""# {args.title}

Status: {args.status}
Generated at: {generated_at}
Branch: `{branch}`
Commit SHA: `{commit}`
Environment: `{ROOT}`
Xcode version: {packet["xcode_version"]}
Simulator or device: {args.simulator_or_device}
Artifact paths: {", ".join(f"`{path}`" for path in artifact_paths)}

## Claim Boundary

This generated packet summarizes supplied evidence records only. It does not run
build, test, device, archive, upload, privacy/legal, accessibility, or release
procedures.

## Command Results

| ID | Command | Exit code | Artifact path | Result |
| --- | --- | ---: | --- | --- |
{command_rows(commands)}
## Validation Not Run / Skipped Checks

| ID | Reason | Proof ceiling |
| --- | --- | --- |
{skipped_rows(skipped)}
## Known Risks

{chr(10).join(f"- {risk}" for risk in args.known_risk) if args.known_risk else "- No known risks were supplied to the generator."}

## Non-Claims

{chr(10).join(f"- {claim}" for claim in non_claims)}

## Rollback

Delete this generated packet if its supplied evidence records, skipped-check
records, artifact paths, or non-claims are wrong or stale.
"""
    return packet, markdown


def write_packet(packet: dict[str, Any], markdown: str, output_dir: Path) -> None:
    output_dir.mkdir(parents=True, exist_ok=True)
    (output_dir / "release-evidence-summary.json").write_text(
        json.dumps(packet, indent=2, sort_keys=True) + "\n",
        encoding="utf-8",
    )
    (output_dir / "release-evidence-summary.md").write_text(markdown, encoding="utf-8")


def self_test() -> int:
    with tempfile.TemporaryDirectory(prefix="ambitions-release-evidence-") as raw_dir:
        output_dir = Path(raw_dir)
        args = argparse.Namespace(
            issue="AMB-1817",
            title="AMB-1817 Release Evidence Summary Self Test",
            status="Self-test summary only; no release readiness claim",
            simulator_or_device="not used",
            output_dir=output_dir,
            command_record=[
                json.dumps(
                    {
                        "id": "static_gate",
                        "command": "git diff --check",
                        "exit_code": 0,
                        "artifact_path": "n/a",
                        "result": "passed",
                    }
                )
            ],
            skipped_check=[
                json.dumps(
                    {
                        "id": "xcodebuild",
                        "reason": "not run in generator self-test",
                        "proof_ceiling": "no build success claim",
                    }
                )
            ],
            artifact=[],
            known_risk=["self-test output is temporary"],
            non_claim=[],
        )
        packet, markdown = build_packet(args)
        write_packet(packet, markdown, output_dir)
        reloaded = json.loads((output_dir / "release-evidence-summary.json").read_text())
        required = {"issue", "command_records", "skipped_checks", "non_claims"}
        missing = required - reloaded.keys()
        if missing:
            print(f"self-test missing keys: {', '.join(sorted(missing))}", file=sys.stderr)
            return 1
        if "No Release Green is claimed by this generated summary." not in reloaded["non_claims"]:
            print("self-test missing default release non-claim", file=sys.stderr)
            return 1
    print("ambitions-release-evidence-summary self-test passed")
    return 0


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(
        description=(
            "Generate a release evidence summary from supplied command and skipped-check "
            "records. This tool does not execute release validation commands."
        )
    )
    parser.add_argument("--self-test", action="store_true")
    parser.add_argument("--issue", default="")
    parser.add_argument("--title", default="Ambitions Release Evidence Summary")
    parser.add_argument(
        "--status",
        default="Evidence summary generated; no release readiness claim",
    )
    parser.add_argument("--simulator-or-device", default="not provided")
    parser.add_argument("--output-dir", type=Path)
    parser.add_argument("--command-record", action="append", default=[])
    parser.add_argument("--skipped-check", action="append", default=[])
    parser.add_argument("--artifact", action="append", default=[])
    parser.add_argument("--known-risk", action="append", default=[])
    parser.add_argument("--non-claim", action="append", default=[])
    args = parser.parse_args(argv)

    if args.self_test:
        return self_test()

    if not args.issue:
        parser.error("--issue is required unless --self-test is used")
    if args.output_dir is None:
        parser.error("--output-dir is required unless --self-test is used")

    packet, markdown = build_packet(args)
    write_packet(packet, markdown, args.output_dir)
    print(f"wrote {args.output_dir / 'release-evidence-summary.md'}")
    print(f"wrote {args.output_dir / 'release-evidence-summary.json'}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
