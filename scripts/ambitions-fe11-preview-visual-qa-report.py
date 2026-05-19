#!/usr/bin/env python3
from __future__ import annotations

import argparse
from pathlib import Path
import re
import subprocess
import sys


ROOT = Path(__file__).resolve().parents[1]
FIXTURE_SOURCE = ROOT / "Sources" / "Previews" / "SignatureInterfaceVisualQAFixtures.swift"
REPORT = ROOT / "docs" / "audits" / "fe-11-preview-visual-qa-report.md"
MATRIX = ROOT / "frontend" / "visual-encyclopedia" / "trace" / "FE11_PREVIEW_VISUAL_QA_MATRIX.md"
SCREENSHOT_MATRIX = ROOT / "frontend" / "visual-encyclopedia" / "trace" / "SCREENSHOT_PROOF_MATRIX.md"
READINESS = ROOT / "frontend" / "visual-encyclopedia" / "gates" / "VISUAL_REGRESSION_READINESS.md"
FE11_EVIDENCE_ROOT = ROOT / "docs" / "audits" / "visual-evidence" / "fe11"
FE11_SCREENSHOT_DIR = FE11_EVIDENCE_ROOT / "screenshots"
FE11_PROOF_MD = FE11_EVIDENCE_ROOT / "fe11-preview-visual-qa-proof.md"
FE11_PROOF_JSON = FE11_EVIDENCE_ROOT / "fe11-preview-visual-qa-proof.json"

EXPECTED_REPORT_MARKERS = [
    "Status: Green, fixture-backed screenshot inventory complete",
    "21 deterministic SI16 preview fixtures",
    "5 surface coverage rows",
    "9 future LDI visual hook fixtures",
    "docs/audits/visual-evidence/fe11/fe11-preview-visual-qa-proof.md",
]

EXPECTED_MATRIX_MARKERS = [
    "Status: fixture-backed, screenshot inventory complete",
    "SI16 preview fixture catalog",
    "Surface Coverage",
    "No device proof is claimed.",
]

EXPECTED_READINESS_MARKERS = [
    "Current FE-11 Artifacts",
    "frontend/visual-encyclopedia/trace/FE11_PREVIEW_VISUAL_QA_MATRIX.md",
    "docs/audits/fe-11-preview-visual-qa-report.md",
    "docs/audits/visual-evidence/fe11/fe11-preview-visual-qa-proof.md",
]

EXPECTED_SCREENSHOT_MATRIX_MARKERS = [
    "Fixture IDs",
    "screenshot inventory complete",
    "accessibility checklist scaffolded",
    "not release or device proof",
]

EXPECTED_PROOF_MD_MARKERS = [
    "Status:",
    "docs/audits/visual-evidence/fe11/screenshots/",
    "Current Screenshot Inventory",
    "Worktree:",
]


def read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def unique(items: list[str]) -> list[str]:
    out: list[str] = []
    seen: set[str] = set()
    for item in items:
        if item in seen:
            continue
        seen.add(item)
        out.append(item)
    return out


def expected_screenshot_names() -> list[str]:
    text = read_text(FIXTURE_SOURCE)
    names = [
        f"si16-{surface.lower()}-{state}.png"
        for state, surface in re.findall(r'fixture\(\.([A-Za-z0-9_]+),\s*"([^"]+)"', text)
    ]
    return unique(names)


def present_screenshot_names() -> list[str]:
    if not FE11_SCREENSHOT_DIR.exists():
        return []
    return sorted(
        path.name
        for path in FE11_SCREENSHOT_DIR.glob("*.png")
        if path.is_file() and path.stat().st_size > 0
    )


def git_stdout(args: list[str]) -> str:
    try:
        return subprocess.check_output(
            ["git", *args],
            cwd=ROOT,
            stderr=subprocess.DEVNULL,
            text=True,
        ).strip()
    except (subprocess.CalledProcessError, FileNotFoundError):
        return "unknown"


def git_metadata() -> dict[str, object]:
    dirty_status = git_stdout(["status", "--porcelain", "--untracked-files=all"])
    return {
        "commit": git_stdout(["rev-parse", "HEAD"]),
        "worktree_dirty": bool(dirty_status),
        "worktree_status": "dirty/uncommitted changes present" if dirty_status else "clean",
    }


def build_inventory() -> dict[str, object]:
    expected = expected_screenshot_names()
    present = present_screenshot_names()
    missing = [name for name in expected if name not in present]
    extra = [name for name in present if name not in expected]

    status = "green" if not missing and expected else "yellow"
    if extra and status == "green":
        status = "yellow"

    inventory: dict[str, object] = {
        "status": status,
        "fixture_source": str(FIXTURE_SOURCE.relative_to(ROOT)),
        "evidence_root": str(FE11_EVIDENCE_ROOT.relative_to(ROOT)),
        "screenshot_directory": f"{FE11_SCREENSHOT_DIR.relative_to(ROOT)}/",
        "proof_markdown": str(FE11_PROOF_MD.relative_to(ROOT)),
        "proof_json": str(FE11_PROOF_JSON.relative_to(ROOT)),
        "expected_screenshots": expected,
        "present_screenshots": present,
        "missing_screenshots": missing,
        "unexpected_screenshots": extra,
        "expected_count": len(expected),
        "present_count": len(present),
    }
    inventory.update(git_metadata())
    return inventory


def screenshot_status_phrase(inventory: dict[str, object]) -> str:
    return "screenshot inventory complete" if inventory["status"] == "green" else "screenshot not captured"


def status_line(inventory: dict[str, object]) -> str:
    return f"Status: {str(inventory['status']).capitalize()}, fixture-backed and {screenshot_status_phrase(inventory)}"


def green_claim_boundary(inventory: dict[str, object]) -> str:
    if inventory["status"] == "green":
        return (
            "- Green may be claimed only for FE-11 screenshot inventory completeness; this manifest still is not "
            "device proof, release proof, accessibility conformance, or human visual approval."
        )
    return "- Not allowed to claim Green until all expected screenshots are present in the FE-11 screenshot directory."


def render_report(inventory: dict[str, object]) -> str:
    status = str(inventory["status"]).capitalize()
    expected_count = int(inventory["expected_count"])
    present_count = int(inventory["present_count"])
    missing = inventory["missing_screenshots"]
    unexpected = inventory["unexpected_screenshots"]

    lines = [
        "# FE-11 Preview Visual QA Proof Manifest",
        "",
        status_line(inventory),
        "Date: 2026-05-19",
        "Batch: FE-11-PREVIEWS-VISUAL-QA",
        f"Commit: {inventory['commit']}",
        f"Worktree: {inventory['worktree_status']}",
        "",
        "## Current Screenshot Inventory",
        "",
        f"- Fixture source: `{inventory['fixture_source']}`",
        f"- Evidence root: `{inventory['evidence_root']}`",
        f"- Screenshot directory: `{inventory['screenshot_directory']}`",
        f"- Expected screenshots: `{expected_count}`",
        f"- Present screenshots: `{present_count}`",
        f"- Missing screenshots: `{len(missing)}`",
        f"- Unexpected screenshots: `{len(unexpected)}`",
        "",
        "### Missing Screenshots",
    ]
    lines.extend(f"- `{name}`" for name in missing or ["None"])
    lines.extend(
        [
            "",
            "### Present Screenshots",
        ]
    )
    lines.extend(f"- `{name}`" for name in present_screenshot_names() or ["None"])
    lines.extend(
        [
            "",
            "### Not Allowed",
            green_claim_boundary(inventory),
            "- Not allowed to claim device proof, release proof, or accessibility conformance from this proof manifest alone.",
            "",
            "### Proof Artifacts",
            f"- `{inventory['proof_markdown']}`",
            f"- `{inventory['proof_json']}`",
        ]
    )
    if unexpected:
        lines.extend(["", "### Unexpected Screenshots"])
        lines.extend(f"- `{name}`" for name in unexpected)
    return "\n".join(lines).rstrip() + "\n"


def render_json(inventory: dict[str, object]) -> str:
    import json

    payload = {
        "batch": "FE-11-PREVIEWS-VISUAL-QA",
        "commit": inventory["commit"],
        "worktree_dirty": inventory["worktree_dirty"],
        "worktree_status": inventory["worktree_status"],
        "status": inventory["status"],
        "fixture_source": inventory["fixture_source"],
        "evidence_root": inventory["evidence_root"],
        "screenshot_directory": inventory["screenshot_directory"],
        "proof_markdown": inventory["proof_markdown"],
        "proof_json": inventory["proof_json"],
        "expected_screenshots": inventory["expected_screenshots"],
        "present_screenshots": inventory["present_screenshots"],
        "missing_screenshots": inventory["missing_screenshots"],
        "unexpected_screenshots": inventory["unexpected_screenshots"],
    }
    return json.dumps(payload, indent=2, sort_keys=True) + "\n"


def validate_text(path: Path, markers: list[str], label: str, issues: list[str]) -> None:
    text = read_text(path)
    for marker in markers:
        if marker not in text:
            issues.append(f"{label} missing marker: {marker}")


def validate() -> list[str]:
    issues: list[str] = []

    validate_text(REPORT, EXPECTED_REPORT_MARKERS, "report", issues)
    validate_text(MATRIX, EXPECTED_MATRIX_MARKERS, "matrix", issues)
    validate_text(SCREENSHOT_MATRIX, EXPECTED_SCREENSHOT_MATRIX_MARKERS, "screenshot matrix", issues)
    validate_text(READINESS, EXPECTED_READINESS_MARKERS, "readiness", issues)
    validate_text(FE11_PROOF_MD, EXPECTED_PROOF_MD_MARKERS, "proof manifest", issues)

    inventory = build_inventory()
    if inventory["status"] == "green" and inventory["missing_screenshots"]:
        issues.append("inventory cannot be green while screenshots are missing")

    proof_text = read_text(FE11_PROOF_MD)
    expected_status_line = status_line(inventory)
    if expected_status_line not in proof_text:
        issues.append(f"proof manifest missing current status line: {expected_status_line}")
    expected_green_boundary = green_claim_boundary(inventory)
    if expected_green_boundary not in proof_text:
        issues.append(f"proof manifest missing current Green boundary: {expected_green_boundary}")

    return issues


def write_proof_artifacts(inventory: dict[str, object]) -> None:
    FE11_EVIDENCE_ROOT.mkdir(parents=True, exist_ok=True)
    FE11_PROOF_MD.write_text(render_report(inventory), encoding="utf-8")
    FE11_PROOF_JSON.write_text(render_json(inventory), encoding="utf-8")


def render_checklist() -> str:
    inventory = build_inventory()
    lines = [
        "# FE-11 Preview Visual QA Report Check",
        "",
        status_line(inventory),
        "",
        "Validated artifacts:",
        f"- {REPORT.relative_to(ROOT)}",
        f"- {MATRIX.relative_to(ROOT)}",
        f"- {SCREENSHOT_MATRIX.relative_to(ROOT)}",
        f"- {READINESS.relative_to(ROOT)}",
        f"- {FE11_PROOF_MD.relative_to(ROOT)}",
        f"- {FE11_PROOF_JSON.relative_to(ROOT)}",
    ]
    return "\n".join(lines) + "\n"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Validate and package the FE-11 preview visual QA proof seam.")
    parser.add_argument(
        "--write-proof",
        action="store_true",
        help="Write the FE-11 proof manifest files under docs/audits/visual-evidence/fe11/",
    )
    parser.add_argument(
        "--require-screenshots",
        action="store_true",
        help="Exit non-zero if any expected FE-11 screenshots are missing.",
    )
    parser.add_argument(
        "--print",
        action="store_true",
        help="Compatibility alias for the default report check output.",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    inventory = build_inventory()

    if args.write_proof:
        write_proof_artifacts(inventory)

    if args.require_screenshots and inventory["missing_screenshots"]:
        print("Missing FE-11 screenshots:", file=sys.stderr)
        for name in inventory["missing_screenshots"]:
            print(f"- {name}", file=sys.stderr)
        return 1

    issues = validate()
    if issues:
        for issue in issues:
            print(issue, file=sys.stderr)
        return 1

    print(render_checklist(), end="")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
