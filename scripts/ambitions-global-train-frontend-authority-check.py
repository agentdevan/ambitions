#!/usr/bin/env python3
"""Gate global-train frontend/UI batches through the Encyclopedia Frontend OS.

This script is intentionally conservative: non-frontend batches pass, but any
frontend/UI/visual batch must explicitly consume the generated frontend authority
packet/preflight workflow before the global train supervisor launches it.
"""
from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OS_FINAL_GATE = ROOT / "build/reports/encyclopedia-to-frontend-os-final-gate.json"
OS_GUIDE = ROOT / "frontend/visual-encyclopedia/ENCYCLOPEDIA_TO_FRONTEND_OS.md"
PACKET_INDEX = ROOT / "build/reports/frontend-authority-packets/index.json"
IMPLEMENTATION_DASHBOARD = ROOT / "build/reports/frontend-implementation-dashboard.json"

FRONTEND_BATCH_PREFIXES = (
    "AFI",
    "FCP",
    "FET",
    "SI",
    "PD",
    "PX",
    "VISUAL",
    "DESIGN-SYSTEM",
    "ENCYCLOPEDIA",
    "FRONTEND",
    "TODAY",
    "GOALS",
    "CAPTURE",
    "TIME",
    "YOU",
)

FRONTEND_CONTENT_RE = re.compile(
    r"\b(SwiftUI|frontend|front-end|screen|screenshot|preview|rendered|rendering|first-viewport|bottom chrome|surface recipe|surface ID|surface_id|Reality Meridian|LifeShape Field|Constellation Atlas|Atmosphere Composer|User System Profile)\b",
    re.IGNORECASE,
)

AUTHORITY_MARKERS = (
    "ENCYCLOPEDIA_TO_FRONTEND_OS",
    "frontend-authority-packet",
    "frontend-authority-preflight",
    "build/reports/frontend-authority-packets",
    "Surface ID:",
    "surface_id",
    "Packet path:",
    "Preflight path:",
)

REQUIRED_HEADER_LINES = (
    "<!-- AMBITIONS_RUNNER_REQUIRED: true -->",
    "<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->",
    "<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->",
)

ROOT_SURFACES = {
    "today_root_reality_meridian",
    "goals_root_constellation_atlas",
    "capture_root_atmosphere_composer",
    "time_root_lifeshape_field",
    "you_root_user_system_profile",
}


def load_json(path: Path) -> dict:
    if not path.exists():
        raise FileNotFoundError(str(path.relative_to(ROOT)))
    with path.open("r", encoding="utf-8") as fh:
        return json.load(fh)


def read_text(path: Path) -> str:
    if not path.exists():
        raise FileNotFoundError(str(path.relative_to(ROOT)))
    return path.read_text(encoding="utf-8")


def is_frontend_relevant(batch: str, prompt_path: Path, prompt_text: str) -> bool:
    upper_batch = batch.upper()
    if upper_batch.startswith(FRONTEND_BATCH_PREFIXES):
        return True
    if "prompts/generated/frontend" in prompt_path.as_posix():
        return True
    return bool(FRONTEND_CONTENT_RE.search(prompt_text))


def extract_surface_ids(prompt_text: str) -> set[str]:
    found: set[str] = set()
    for pattern in (
        r"Surface ID:\s*`?([a-z0-9_]+)`?",
        r"surface_id:\s*`?([a-z0-9_]+)`?",
        r"--surface\s+([a-z0-9_]+)",
        r"SURFACE=([a-z0-9_]+)",
    ):
        found.update(re.findall(pattern, prompt_text))
    return found


def validate_os_base() -> list[str]:
    blockers: list[str] = []
    if not OS_GUIDE.exists():
        blockers.append(f"missing OS guide: {OS_GUIDE.relative_to(ROOT)}")

    try:
        gate = load_json(OS_FINAL_GATE)
        if gate.get("status") != "green":
            blockers.append(f"OS final gate is not green: {gate.get('status')}")
        if gate.get("implementation_proof") != "not claimed":
            blockers.append("OS final gate appears to claim implementation proof")
    except Exception as exc:  # noqa: BLE001 - report exact gate issue
        blockers.append(f"could not read OS final gate: {exc}")

    try:
        index = load_json(PACKET_INDEX)
        packets = index.get("packets", [])
        surface_ids = {p.get("surface_id") for p in packets}
        if len(packets) < 159:
            blockers.append(f"packet index has fewer than 159 packets: {len(packets)}")
        missing_roots = sorted(ROOT_SURFACES - surface_ids)
        if missing_roots:
            blockers.append(f"packet index missing root surfaces: {', '.join(missing_roots)}")
    except Exception as exc:  # noqa: BLE001
        blockers.append(f"could not read packet index: {exc}")

    try:
        dashboard = load_json(IMPLEMENTATION_DASHBOARD)
        if dashboard.get("active_ia_status") != "green":
            blockers.append("frontend implementation dashboard active IA is not green")
    except Exception as exc:  # noqa: BLE001
        blockers.append(f"could not read frontend implementation dashboard: {exc}")

    return blockers


def validate_prompt_contract(prompt_path: Path, prompt_text: str) -> tuple[list[str], list[str]]:
    blockers: list[str] = []
    warnings: list[str] = []

    missing_headers = [line for line in REQUIRED_HEADER_LINES if line not in prompt_text]
    if missing_headers:
        blockers.append("prompt is missing Ambitions runner header lines: " + ", ".join(missing_headers))

    marker_count = sum(1 for marker in AUTHORITY_MARKERS if marker in prompt_text)
    if marker_count < 2:
        blockers.append(
            "frontend/UI batch prompt does not explicitly consume Encyclopedia Frontend OS packet/preflight workflow"
        )

    surface_ids = extract_surface_ids(prompt_text)
    if not surface_ids:
        blockers.append("frontend/UI batch prompt does not declare a surface ID")
    else:
        try:
            index = load_json(PACKET_INDEX)
            known = {p.get("surface_id") for p in index.get("packets", [])}
            unknown = sorted(surface_ids - known)
            if unknown:
                blockers.append("prompt declares unknown surface IDs: " + ", ".join(unknown))
        except Exception as exc:  # noqa: BLE001
            blockers.append(f"could not validate declared surface IDs: {exc}")

    if "Plan" in prompt_text and "compatibility" not in prompt_text.lower():
        warnings.append("prompt mentions Plan; verify this is not active top-level IA leakage")

    if "release readiness" in prompt_text.lower() and "not" not in prompt_text.lower():
        warnings.append("prompt mentions release readiness; verify proof boundary")

    if "prompts/generated/frontend" not in prompt_path.as_posix():
        warnings.append(
            "frontend-relevant prompt is not generated under prompts/generated/frontend; ensure it intentionally uses the authority packet"
        )

    return blockers, warnings


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--batch", required=True)
    parser.add_argument("--prompt", required=True)
    parser.add_argument("--json", action="store_true")
    args = parser.parse_args()

    prompt_path = (ROOT / args.prompt).resolve()
    if not prompt_path.exists():
        print(f"RED: prompt missing: {args.prompt}", file=sys.stderr)
        return 2

    try:
        prompt_text = read_text(prompt_path)
    except Exception as exc:  # noqa: BLE001
        print(f"RED: could not read prompt: {exc}", file=sys.stderr)
        return 2

    frontend_relevant = is_frontend_relevant(args.batch, prompt_path, prompt_text)
    blockers: list[str] = []
    warnings: list[str] = []

    if frontend_relevant:
        blockers.extend(validate_os_base())
        prompt_blockers, prompt_warnings = validate_prompt_contract(prompt_path, prompt_text)
        blockers.extend(prompt_blockers)
        warnings.extend(prompt_warnings)

    result = {
        "batch": args.batch,
        "prompt": args.prompt,
        "frontend_relevant": frontend_relevant,
        "status": "red" if blockers else "green",
        "blockers": blockers,
        "warnings": warnings,
        "required_action": None,
    }

    if blockers:
        result["required_action"] = (
            "Generate or patch the frontend implementation prompt through "
            "scripts/ambitions-frontend-implementation-prompt.py and rerun the global train."
        )

    if args.json:
        print(json.dumps(result, indent=2, sort_keys=True))
    elif blockers:
        print("RED: frontend authority hook blocked global train launch", file=sys.stderr)
        for blocker in blockers:
            print(f"- {blocker}", file=sys.stderr)
        if warnings:
            print("Warnings:", file=sys.stderr)
            for warning in warnings:
                print(f"- {warning}", file=sys.stderr)
    else:
        scope = "frontend/UI" if frontend_relevant else "non-frontend"
        print(f"Frontend authority hook: GREEN ({scope} batch)")
        for warning in warnings:
            print(f"warning: {warning}", file=sys.stderr)

    return 1 if blockers else 0


if __name__ == "__main__":
    raise SystemExit(main())
