#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import subprocess
import sys
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
DEFAULT_MANIFEST = ROOT / "docs" / "audits" / "amb-1749-frontend-evidence-harness.json"

REQUIRED_JOURNEYS = {
    "root_shell",
    "capture",
    "today",
    "goals",
    "time",
    "you",
    "inspection",
}

REQUIRED_LANES = {
    "fast_frontend_local": "fast_local",
    "frontend_screenshot_artifacts": "slow_local",
    "frontend_release_index": "slow_release",
}

REQUIRED_DENIALS = {
    "frontend_green_from_unit_tests",
    "visual_green_without_independent_review",
    "accessibility_conformance_without_manual_or_tool_evidence",
    "device_claim_without_device_evidence",
    "testflight_or_app_store_readiness_from_harness_only",
    "release_green_from_frontend_index_only",
}

LOCAL_ARTIFACT_PREFIXES = (
    ".codex/xcode-results/AMB_1749_",
    ".codex/xcode-logs/AMB_1749_",
    ".codex/xcode-summaries/AMB_1749_",
)


def load_manifest(path: Path) -> dict[str, Any]:
    with path.open(encoding="utf-8") as handle:
        data = json.load(handle)
    if not isinstance(data, dict):
        raise ValueError("manifest root must be an object")
    return data


def repo_path(relative: str) -> Path:
    return ROOT / relative


def command_exists(command: list[str]) -> bool:
    if not command:
        return False
    executable = command[0]
    if executable in {"python3", "bash", "xcodebuild"}:
        return True
    return repo_path(executable).exists()


def file_contains_symbol(relative: str, symbol: str) -> bool:
    path = repo_path(relative)
    if not path.exists():
        return False
    text = path.read_text(encoding="utf-8", errors="replace")
    return symbol in text


def validate_artifact_root(path: str) -> bool:
    if path.startswith("docs/audits/amb-1749-"):
        return True
    return path.startswith(LOCAL_ARTIFACT_PREFIXES)


def validate_manifest(data: dict[str, Any]) -> list[str]:
    findings: list[str] = []

    if data.get("issue") != "AMB-1749":
        findings.append("manifest issue must be AMB-1749")

    claim_boundary = str(data.get("claim_boundary", "")).lower()
    for forbidden in ["release green", "app store readiness", "accessibility conformance"]:
        if forbidden not in claim_boundary:
            findings.append(f"claim_boundary must explicitly deny {forbidden}")

    locks = data.get("acceptance_locks", {})
    for key in [
        "covers_sibling_frontend_recovery_project",
        "screenshot_artifacts_have_stable_paths",
        "slow_release_checks_are_separated_from_fast_local_checks",
        "unit_tests_cannot_infer_frontend_green",
    ]:
        if locks.get(key) is not True:
            findings.append(f"acceptance_locks.{key} must be true")

    sibling = data.get("sibling_frontend_recovery_project", {})
    linked = set(sibling.get("linked_issue_range", []))
    for issue in ["AMB-1733", "AMB-1734", "AMB-1735", "AMB-1736", "AMB-1737", "AMB-1738", "AMB-1739", "AMB-1740", "AMB-1741", "AMB-1742", "AMB-1743", "AMB-1744", "AMB-1751"]:
        if issue not in linked:
            findings.append(f"sibling frontend recovery issue missing from manifest: {issue}")

    artifact_roots = data.get("artifact_roots", {})
    if not isinstance(artifact_roots, dict) or not artifact_roots:
        findings.append("artifact_roots must be a non-empty object")
    else:
        for name, path in artifact_roots.items():
            if not isinstance(path, str) or not validate_artifact_root(path):
                findings.append(f"artifact root {name} is not an approved stable AMB-1749 path: {path}")

    lanes = data.get("lanes", [])
    lane_by_id = {lane.get("id"): lane for lane in lanes if isinstance(lane, dict)}
    for lane_id, speed_class in REQUIRED_LANES.items():
        lane = lane_by_id.get(lane_id)
        if lane is None:
            findings.append(f"required lane missing: {lane_id}")
            continue
        if lane.get("speed_class") != speed_class:
            findings.append(f"{lane_id} must use speed_class {speed_class}")
        lane_boundary = str(lane.get("claim_boundary", "")).lower()
        if "visual" not in lane_boundary or ("green" not in lane_boundary and "acceptance" not in lane_boundary):
            findings.append(f"{lane_id} claim boundary must deny visual acceptance or Green overclaim")
        for artifact_root in lane.get("artifact_roots", []):
            if not isinstance(artifact_root, str) or not validate_artifact_root(artifact_root):
                findings.append(f"{lane_id} has unstable artifact root: {artifact_root}")
        for command in lane.get("commands", []):
            if not isinstance(command, list) or not command_exists(command):
                findings.append(f"{lane_id} command does not start with a known executable: {command}")

    journeys = data.get("ui_journeys", [])
    journey_ids = {journey.get("id") for journey in journeys if isinstance(journey, dict)}
    missing_journeys = REQUIRED_JOURNEYS - journey_ids
    if missing_journeys:
        findings.append(f"missing UI journey coverage: {', '.join(sorted(missing_journeys))}")

    for journey in journeys:
        if not isinstance(journey, dict):
            findings.append("ui_journeys entries must be objects")
            continue
        source_file = journey.get("source_file", "")
        if not isinstance(source_file, str) or not repo_path(source_file).exists():
            findings.append(f"{journey.get('id', '<unknown>')} source file missing: {source_file}")
            continue
        for symbol in journey.get("test_symbols", []):
            if not isinstance(symbol, str) or not file_contains_symbol(source_file, symbol):
                findings.append(f"{journey.get('id', '<unknown>')} missing test symbol {symbol} in {source_file}")
        required_artifacts = journey.get("required_artifacts", [])
        if not required_artifacts or "screenshot_or_explicit_not_run_reason" not in required_artifacts:
            findings.append(f"{journey.get('id', '<unknown>')} must require screenshot_or_explicit_not_run_reason")

    accessibility = data.get("accessibility_smoke", [])
    accessibility_text = json.dumps(accessibility).lower()
    if "dynamic" not in accessibility_text or "reduce_motion" not in accessibility_text:
        findings.append("accessibility_smoke must include Dynamic Type and Reduce Motion checks")
    for smoke in accessibility:
        if not isinstance(smoke, dict):
            findings.append("accessibility_smoke entries must be objects")
            continue
        source_file = smoke.get("source_file", "")
        if not isinstance(source_file, str) or not repo_path(source_file).exists():
            findings.append(f"{smoke.get('id', '<unknown>')} source file missing: {source_file}")
            continue
        for symbol in smoke.get("test_symbols", []):
            if not isinstance(symbol, str) or not file_contains_symbol(source_file, symbol):
                findings.append(f"{smoke.get('id', '<unknown>')} missing test symbol {symbol} in {source_file}")
        boundary = str(smoke.get("claim_boundary", "")).lower()
        if "conformance" not in boundary and "green" not in boundary:
            findings.append(f"{smoke.get('id', '<unknown>')} must include a proof ceiling")

    for source in data.get("source_paths", []):
        if not isinstance(source, str) or not repo_path(source).exists():
            findings.append(f"source path missing: {source}")

    denials = set(data.get("required_claim_denials", []))
    missing_denials = REQUIRED_DENIALS - denials
    if missing_denials:
        findings.append(f"missing required claim denials: {', '.join(sorted(missing_denials))}")

    return findings


def lane_commands(data: dict[str, Any], lane_id: str) -> list[list[str]]:
    for lane in data.get("lanes", []):
        if isinstance(lane, dict) and lane.get("id") == lane_id:
            return lane.get("commands", [])
    raise KeyError(f"unknown lane: {lane_id}")


def list_lanes(data: dict[str, Any]) -> None:
    for lane in data.get("lanes", []):
        if not isinstance(lane, dict):
            continue
        print(f"{lane.get('id')} [{lane.get('speed_class')}]")
        print(f"  purpose: {lane.get('purpose')}")
        print(f"  claim_boundary: {lane.get('claim_boundary')}")
        for command in lane.get("commands", []):
            print("  command: " + " ".join(command))


def run_lane(data: dict[str, Any], lane_id: str) -> int:
    commands = lane_commands(data, lane_id)
    if not commands:
        print(f"lane has no commands: {lane_id}", file=sys.stderr)
        return 2

    for command in commands:
        print("+ " + " ".join(command))
        result = subprocess.run(command, cwd=ROOT, check=False)
        if result.returncode != 0:
            return result.returncode
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description="Validate or run the AMB-1749 frontend evidence harness.")
    parser.add_argument("--manifest", default=str(DEFAULT_MANIFEST), help="Path to the AMB-1749 harness manifest.")
    parser.add_argument("--check", action="store_true", help="Validate the harness manifest and referenced source/test symbols.")
    parser.add_argument("--list", action="store_true", help="List harness lanes and commands.")
    parser.add_argument("--run-lane", help="Run a named lane from the manifest.")
    parser.add_argument("--json", action="store_true", help="Emit JSON summary for check/list operations.")
    args = parser.parse_args()

    manifest_path = Path(args.manifest)
    if not manifest_path.is_absolute():
        manifest_path = ROOT / manifest_path

    try:
        data = load_manifest(manifest_path)
    except Exception as error:
        payload = {
            "status": "failed",
            "failure_category": "manifest_load_failed",
            "manifest": str(manifest_path.relative_to(ROOT) if manifest_path.is_relative_to(ROOT) else manifest_path),
            "error": str(error),
        }
        print(json.dumps(payload, indent=2, sort_keys=True) if args.json else payload["error"])
        return 1

    findings = validate_manifest(data)
    if args.json:
        payload = {
            "issue": data.get("issue"),
            "status": "passed" if not findings else "failed",
            "failure_category": "passed" if not findings else "harness_manifest_invalid",
            "manifest": manifest_path.relative_to(ROOT).as_posix() if manifest_path.is_relative_to(ROOT) else str(manifest_path),
            "findings": findings,
            "lanes": [lane.get("id") for lane in data.get("lanes", []) if isinstance(lane, dict)],
            "claim_boundary": data.get("claim_boundary"),
        }
        print(json.dumps(payload, indent=2, sort_keys=True))
    elif findings:
        print("ambitions-frontend-evidence-harness RED")
        for finding in findings:
            print(f"- {finding}")
    else:
        print("ambitions-frontend-evidence-harness GREEN")

    if findings:
        return 1

    if args.list:
        list_lanes(data)

    if args.run_lane:
        return run_lane(data, args.run_lane)

    if not args.check and not args.list and not args.run_lane:
        parser.print_help()

    return 0


if __name__ == "__main__":
    sys.exit(main())
