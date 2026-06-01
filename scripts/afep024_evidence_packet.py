#!/usr/bin/env python3
"""Generate and validate AFEP-024 evidence packets.

The packet is intentionally conservative:
- it stays repo-local,
- it records proof boundaries and explicit non-claims,
- it never upgrades local validation into release readiness,
- and missing optional proof stays `notVerified` or `blocked`.
"""

from __future__ import annotations

import argparse
import json
import subprocess
import sys
import tempfile
from collections.abc import Iterable
from datetime import datetime, timezone
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parents[1]
FIXTURE_DIR = ROOT / "fixtures" / "afep024"
DEFAULT_EXPECTED = FIXTURE_DIR / "expected-evidence-packet.json"
OPTIONAL_ARTIFACT_SECTIONS = ("screenshots", "accessibility", "performance", "privacy", "replay")
PROVENANCE_KEYS = (
    "SourceRecord",
    "Receipt",
    "ReplayTrace",
    "You / What Ambitions knows",
)
FORBIDDEN_CLAIM_PATTERNS = (
    "release ready",
    "release-ready",
    "production ready",
    "production-ready",
    "App Store ready",
    "App Store-ready",
    "TestFlight ready",
    "TestFlight-ready",
    "fully accessible",
    "VoiceOver verified",
    "Dynamic Type verified",
    "Reduce Motion verified",
    "performance validated",
    "privacy approved",
    "legally approved",
    "device verified",
    "CI proven",
)


def rel(path: Path) -> str:
    return path.resolve().relative_to(ROOT).as_posix()


def run_git(args: list[str]) -> str:
    result = subprocess.run(
        ["git", *args],
        cwd=ROOT,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )
    if result.returncode != 0:
        raise RuntimeError(result.stderr.strip() or f"git {' '.join(args)} failed")
    return result.stdout.strip()


def git_metadata() -> dict[str, str]:
    commit = run_git(["rev-parse", "HEAD"])
    branch = run_git(["rev-parse", "--abbrev-ref", "HEAD"])
    return {"commit": commit, "branch": branch}


def now_utc() -> str:
    return datetime.now(timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")


def load_json(path: Path) -> dict[str, Any]:
    data = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(data, dict):
        raise ValueError(f"{rel(path)} must contain a JSON object")
    return data


def normalize_status(value: str) -> str:
    status = value.strip()
    aliases = {
        "pass": "passed",
        "ok": "passed",
        "green": "passed",
        "warn": "blocked",
        "yellow": "blocked",
        "red": "failed",
        "skip": "skipped",
        "not verified": "notVerified",
        "not-verified": "notVerified",
    }
    return aliases.get(status.lower(), status)


def repo_relative_path(value: str) -> str:
    path = Path(value)
    if path.is_absolute():
        raise ValueError(f"artifact paths must be repo-relative, got absolute path: {value}")
    resolved = (ROOT / path).resolve()
    try:
        return resolved.relative_to(ROOT).as_posix()
    except ValueError as exc:
        raise ValueError(f"artifact paths must stay inside the repo: {value}") from exc


def sort_records(records: list[dict[str, Any]], key_fields: tuple[str, ...]) -> list[dict[str, Any]]:
    return sorted(records, key=lambda row: tuple(str(row.get(field, "")) for field in key_fields))


def normalize_paths(values: Iterable[Any]) -> list[str]:
    paths: list[str] = []
    for value in values:
        if value is None:
            continue
        if isinstance(value, Path):
            paths.append(rel(value))
        else:
            text = str(value).strip()
            if text:
                paths.append(repo_relative_path(text))
    return sorted(dict.fromkeys(paths))


def artifact_entry(category: str, raw_items: list[dict[str, Any]], missing_status: str = "notVerified") -> dict[str, Any]:
    items: list[dict[str, Any]] = []
    for raw in raw_items:
        artifact_paths = normalize_paths(raw.get("artifact_paths", []))
        status = normalize_status(str(raw.get("status", ""))) if raw.get("status") else None
        if not status:
            status = "linked" if artifact_paths and all((ROOT / path).exists() for path in artifact_paths) else missing_status
        items.append(
            {
                "name": str(raw.get("name", category)),
                "status": status,
                "artifact_paths": artifact_paths,
                "notes": str(raw.get("notes", "")).strip(),
            }
        )

    if not items:
        items.append(
            {
                "name": category,
                "status": missing_status,
                "artifact_paths": [],
                "notes": "no optional proof supplied",
            }
        )

    return {
        "category": category,
        "items": sort_records(items, ("name",)),
    }


def default_optional_sections(input_data: dict[str, Any]) -> list[dict[str, Any]]:
    sections: list[dict[str, Any]] = []
    raw_artifacts = input_data.get("artifacts", {}) if isinstance(input_data.get("artifacts"), dict) else {}
    for section_name in OPTIONAL_ARTIFACT_SECTIONS:
        raw_items = raw_artifacts.get(section_name, [])
        if not isinstance(raw_items, list):
            raw_items = []
        sections.append(artifact_entry(section_name, [item for item in raw_items if isinstance(item, dict)]))
    return sections


def compute_validation_status(packet: dict[str, Any]) -> str:
    command_statuses = {row["status"] for row in packet["command_records"]}
    check_statuses = {row["status"] for row in packet["checks"]}
    artifact_statuses = {
        item["status"]
        for section in packet["optional_proof"]
        for item in section["items"]
    }

    if "failed" in command_statuses or "failed" in check_statuses:
        return "Red"
    if "blocked" in command_statuses or "blocked" in check_statuses or "blocked" in artifact_statuses:
        return "Yellow"
    if "skipped" in command_statuses or "skipped" in check_statuses or "notVerified" in artifact_statuses:
        return "Yellow"
    return "Green"


def build_packet(input_data: dict[str, Any], input_path: Path) -> dict[str, Any]:
    metadata = git_metadata()
    generated_at = str(input_data.get("generated_at") or now_utc())
    command_records: list[dict[str, Any]] = []
    for raw in input_data.get("command_records", []):
        if not isinstance(raw, dict):
            continue
        command_records.append(
            {
                "command": str(raw.get("command", "")).strip(),
                "status": normalize_status(str(raw.get("status", "notVerified"))),
                "exit_code": int(raw.get("exit_code", 0)),
                "environment": {
                    key: raw.get("environment", {}).get(key)
                    for key in sorted(raw.get("environment", {}).keys())
                }
                if isinstance(raw.get("environment"), dict)
                else {},
                "artifact_paths": normalize_paths(raw.get("artifact_paths", [])),
                "notes": str(raw.get("notes", "")).strip(),
            }
        )
    command_records = sort_records(command_records, ("command",))

    checks: list[dict[str, Any]] = []
    for raw in input_data.get("checks", []):
        if not isinstance(raw, dict):
            continue
        checks.append(
            {
                "name": str(raw.get("name", "")).strip(),
                "status": normalize_status(str(raw.get("status", "notVerified"))),
                "notes": str(raw.get("notes", "")).strip(),
            }
        )
    checks = sort_records(checks, ("name",))

    non_claims = sorted({str(item).strip() for item in input_data.get("non_claims", []) if str(item).strip()})
    provenance_raw = input_data.get("provenance", {}) if isinstance(input_data.get("provenance"), dict) else {}
    provenance = {key: str(provenance_raw.get(key, key)).strip() for key in PROVENANCE_KEYS}

    closeout_raw = input_data.get("closeout", {}) if isinstance(input_data.get("closeout"), dict) else {}
    rollback_raw = input_data.get("rollback", {}) if isinstance(input_data.get("rollback"), dict) else {}
    rollback = {
        "available": bool(rollback_raw.get("available", True)),
        "manual_fallback_path": str(rollback_raw.get("manual_fallback_path", "docs/audits/afep024-manual-proof-fallback.md")).strip(),
        "steps": [str(step).strip() for step in rollback_raw.get("steps", []) if str(step).strip()],
    }

    packet: dict[str, Any] = {
        "batch_id": str(input_data.get("batch_id", "AFEP-024")).strip(),
        "source": {
            "commit": str(input_data.get("commit") or metadata["commit"]).strip(),
            "branch": str(input_data.get("branch") or metadata["branch"]).strip(),
            "generated_at": generated_at,
            "input_path": rel(input_path),
        },
        "command_records": command_records,
        "checks": checks,
        "optional_proof": default_optional_sections(input_data),
        "provenance": provenance,
        "non_claims": non_claims,
        "release_boundary": {
            "release_readiness": "notClaimed",
            "accessibility_readiness": "notClaimed",
            "privacy_readiness": "notClaimed",
            "performance_readiness": "notClaimed",
            "device_readiness": "notClaimed",
            "testflight_readiness": "notClaimed",
            "app_store_readiness": "notClaimed",
            "ci_readiness": "notClaimed",
            "production_readiness": "notClaimed",
        },
        "closeout": {
            "status": str(closeout_raw.get("status", "")).strip() or "Yellow",
            "owner": str(closeout_raw.get("owner", "AFEP-024")).strip(),
            "yellow_accepted_reason": str(closeout_raw.get("yellow_accepted_reason", "")).strip(),
            "red_blockers": [str(item).strip() for item in closeout_raw.get("red_blockers", []) if str(item).strip()],
        },
        "rollback": rollback,
    }
    packet["closeout"]["status"] = normalize_status(packet["closeout"]["status"]).title()
    packet["closeout"]["status"] = packet["closeout"]["status"] if packet["closeout"]["status"] in {"Green", "Yellow", "Red"} else "Yellow"
    packet["closeout"]["yellow_accepted_reason"] = packet["closeout"]["yellow_accepted_reason"] or "Local validation is not release proof; optional artifacts remain notVerified."
    packet["closeout"]["red_blockers"] = sorted(dict.fromkeys(packet["closeout"]["red_blockers"]))
    packet["summary"] = {
        "command_count": len(packet["command_records"]),
        "passed_commands": sum(1 for row in packet["command_records"] if row["status"] == "passed"),
        "blocked_commands": sum(1 for row in packet["command_records"] if row["status"] == "blocked"),
        "skipped_commands": sum(1 for row in packet["command_records"] if row["status"] == "skipped"),
        "not_verified_artifacts": sum(
            1 for section in packet["optional_proof"] for item in section["items"] if item["status"] == "notVerified"
        ),
    }
    packet["validation_status"] = compute_validation_status(packet)
    return packet


def validate_packet(packet: dict[str, Any]) -> list[str]:
    issues: list[str] = []
    required_top_level = [
        "batch_id",
        "source",
        "command_records",
        "checks",
        "optional_proof",
        "provenance",
        "non_claims",
        "release_boundary",
        "closeout",
        "rollback",
        "summary",
        "validation_status",
    ]
    for field in required_top_level:
        if field not in packet:
            issues.append(f"missing top-level field: {field}")

    if packet.get("closeout", {}).get("status") not in {"Green", "Yellow", "Red"}:
        issues.append("closeout.status must be Green, Yellow, or Red")

    for key in PROVENANCE_KEYS:
        value = packet.get("provenance", {}).get(key, "")
        if not value:
            issues.append(f"missing provenance reference: {key}")

    if packet.get("release_boundary", {}).get("release_readiness") != "notClaimed":
        issues.append("release_boundary.release_readiness must remain notClaimed")

    if not packet.get("rollback", {}).get("available", False):
        issues.append("rollback must remain available")
    if not packet.get("rollback", {}).get("manual_fallback_path"):
        issues.append("rollback manual fallback path missing")

    optional = packet.get("optional_proof", [])
    for section in optional:
        if not isinstance(section, dict) or "category" not in section:
            issues.append("optional proof section malformed")
            continue
        for item in section.get("items", []):
            if item.get("status") not in {"linked", "notVerified", "blocked"}:
                issues.append(f"{section['category']}: invalid optional proof status {item.get('status')}")

    markdown = render_markdown(packet).lower().splitlines()
    for line in markdown:
        if "notclaim" in line or "not verified" in line or "no " in line or "blocked" in line:
            continue
        for phrase in FORBIDDEN_CLAIM_PATTERNS:
            if phrase.lower() in line:
                issues.append(f"forbidden claim phrase present: {phrase}")
    return issues


def render_markdown(packet: dict[str, Any]) -> str:
    lines = [
        "# AFEP-024 Evidence Packet",
        "",
        f"Batch: `{packet['batch_id']}`",
        f"Commit: `{packet['source']['commit']}`",
        f"Branch: `{packet['source']['branch']}`",
        f"Generated: `{packet['source']['generated_at']}`",
        f"Validation status: `{packet['validation_status']}`",
        f"Closeout status: `{packet['closeout']['status']}`",
        "",
        "## Command Records",
        "| Command | Status | Exit | Artifacts | Notes |",
        "| --- | --- | ---: | --- | --- |",
    ]
    for row in packet["command_records"]:
        artifact_text = "<br>".join(row["artifact_paths"]) if row["artifact_paths"] else "none"
        notes = row["notes"] or "none"
        lines.append(
            f"| `{row['command']}` | `{row['status']}` | `{row['exit_code']}` | {artifact_text} | {notes} |"
        )

    lines.extend(
        [
            "",
            "## Checks",
            "| Check | Status | Notes |",
            "| --- | --- | --- |",
        ]
    )
    for row in packet["checks"]:
        lines.append(f"| {row['name']} | `{row['status']}` | {row['notes'] or 'none'} |")

    lines.extend(["", "## Optional Proof"])
    for section in packet["optional_proof"]:
        lines.append(f"### {section['category']}")
        for item in section["items"]:
            artifact_text = ", ".join(f"`{path}`" for path in item["artifact_paths"]) if item["artifact_paths"] else "none"
            lines.append(f"- `{item['name']}`: `{item['status']}`")
            lines.append(f"  - artifact paths: {artifact_text}")
            lines.append(f"  - notes: {item['notes'] or 'none'}")

    lines.extend(
        [
            "",
            "## Provenance",
        ]
    )
    for key in PROVENANCE_KEYS:
        lines.append(f"- {key}: `{packet['provenance'][key]}`")

    lines.extend(
        [
            "",
            "## Non-Claims",
        ]
    )
    for claim in packet["non_claims"]:
        lines.append(f"- {claim}")

    lines.extend(
        [
            "",
            "## Release Boundary",
        ]
    )
    for key, value in packet["release_boundary"].items():
        lines.append(f"- {key}: `{value}`")

    lines.extend(
        [
            "",
            "## Closeout",
            f"- status: `{packet['closeout']['status']}`",
            f"- owner: `{packet['closeout']['owner']}`",
            f"- yellow accepted reason: {packet['closeout']['yellow_accepted_reason']}",
        ]
    )
    if packet["closeout"]["red_blockers"]:
        lines.append("- red blockers:")
        for blocker in packet["closeout"]["red_blockers"]:
            lines.append(f"  - {blocker}")
    else:
        lines.append("- red blockers: none")

    lines.extend(
        [
            "",
            "## Rollback / Manual Fallback",
            f"- available: `{packet['rollback']['available']}`",
            f"- manual fallback path: `{packet['rollback']['manual_fallback_path']}`",
        ]
    )
    if packet["rollback"]["steps"]:
        lines.append("- steps:")
        for step in packet["rollback"]["steps"]:
            lines.append(f"  - {step}")
    else:
        lines.append("- steps: none")

    lines.extend(
        [
            "",
            "## Summary",
            f"- command_count: `{packet['summary']['command_count']}`",
            f"- passed_commands: `{packet['summary']['passed_commands']}`",
            f"- blocked_commands: `{packet['summary']['blocked_commands']}`",
            f"- skipped_commands: `{packet['summary']['skipped_commands']}`",
            f"- not_verified_artifacts: `{packet['summary']['not_verified_artifacts']}`",
        ]
    )
    return "\n".join(lines).rstrip() + "\n"


def write_output(path: Path, packet: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(render_markdown(packet), encoding="utf-8")


def write_expected_if_requested(packet: dict[str, Any], expected_path: Path) -> None:
    expected_path.parent.mkdir(parents=True, exist_ok=True)
    expected_path.write_text(json.dumps(packet, indent=2, sort_keys=True) + "\n", encoding="utf-8")


def load_expected(path: Path) -> dict[str, Any]:
    if not path.exists():
        raise FileNotFoundError(f"expected packet not found: {rel(path)}")
    return load_json(path)


def self_test() -> int:
    sample_input = {
        "batch_id": "AFEP-024",
        "commit": "deadbeefdeadbeefdeadbeefdeadbeefdeadbeef",
        "branch": "main",
        "generated_at": "2026-06-01T20:29:18Z",
        "command_records": [
            {
                "command": "python3 scripts/afep024_evidence_packet.py --self-test",
                "status": "passed",
                "exit_code": 0,
                "artifact_paths": [],
                "notes": "self-check",
            }
        ],
        "checks": [
            {"name": "schema", "status": "passed", "notes": "required fields present"},
            {"name": "claim boundary", "status": "passed", "notes": "no release claim language"},
        ],
        "artifacts": {},
        "non_claims": ["No release readiness claim."],
        "provenance": {key: f"{key}.afep024.sample" for key in PROVENANCE_KEYS},
        "closeout": {
            "status": "Yellow",
            "owner": "AFEP-024",
            "yellow_accepted_reason": "optional proof remains notVerified in the sample packet",
            "red_blockers": [],
        },
        "rollback": {
            "available": True,
            "manual_fallback_path": "docs/audits/afep024-manual-proof-fallback.md",
            "steps": ["Switch to manual AFRI proof packet workflow."],
        },
    }
    packet = build_packet(sample_input, FIXTURE_DIR / "self-test.json")
    issues = validate_packet(packet)
    if issues:
        raise AssertionError("; ".join(issues))
    markdown = render_markdown(packet)
    if any(phrase in markdown.lower() for phrase in FORBIDDEN_CLAIM_PATTERNS):
        raise AssertionError("forbidden claim text leaked into markdown")
    if packet["validation_status"] != "Yellow":
        raise AssertionError("sample packet should remain Yellow when optional proof is missing")
    try:
        normalize_paths(["/etc/hosts"])
    except ValueError:
        pass
    else:
        raise AssertionError("absolute artifact paths must be rejected")
    try:
        normalize_paths(["../outside-repo-proof.txt"])
    except ValueError:
        pass
    else:
        raise AssertionError("artifact paths outside the repo must be rejected")
    with tempfile.TemporaryDirectory() as tmp:
        temp_path = Path(tmp) / "packet.md"
        write_output(temp_path, packet)
        if not temp_path.read_text(encoding="utf-8").startswith("# AFEP-024 Evidence Packet"):
            raise AssertionError("markdown output missing packet heading")
    print("GREEN: AFEP-024 evidence packet self-test passed")
    return 0


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--input", type=Path, help="Repo-local JSON input describing packet fields.")
    parser.add_argument("--write", type=Path, help="Write the rendered Markdown packet here.")
    parser.add_argument("--expected", type=Path, default=DEFAULT_EXPECTED, help="Expected JSON packet for --check.")
    parser.add_argument("--check", action="store_true", help="Validate the generated packet against the expected schema.")
    parser.add_argument("--write-expected", action="store_true", help="Write the generated packet JSON to --expected.")
    parser.add_argument("--self-test", action="store_true", help="Run an internal deterministic self-test.")
    args = parser.parse_args(argv)

    if args.self_test:
        return self_test()

    if not args.input:
        parser.error("--input is required unless --self-test is used")

    input_data = load_json(args.input)
    packet = build_packet(input_data, args.input)
    issues = validate_packet(packet)
    if issues:
        print("RED: AFEP-024 evidence packet validation failed")
        for issue in issues:
            print(f"- {issue}")
        return 1

    if args.write:
        write_output(args.write, packet)

    if args.write_expected:
        write_expected_if_requested(packet, args.expected)

    if args.check:
        expected = load_expected(args.expected)
        if expected != packet:
            print("RED: AFEP-024 evidence packet did not match expected JSON")
            print(f"- expected: {rel(args.expected)}")
            return 1

    print(f"{packet['validation_status'].upper()}: AFEP-024 evidence packet ready")
    print(f"closeout={packet['closeout']['status']}")
    print(f"optional_not_verified={packet['summary']['not_verified_artifacts']}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
