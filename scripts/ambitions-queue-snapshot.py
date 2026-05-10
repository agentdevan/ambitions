#!/usr/bin/env python3
"""Ambitions queue/state snapshot.

Read-only control-plane checker. It prints the next safe action, active state
summary, stale mirror warnings, queue counts, and release/claim warnings without
mutating the repo.
"""

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parents[1]

FORBIDDEN_RELEASE_CLAIMS = [
    "production-ready",
    "release-ready",
    "App Store-ready",
    "TestFlight-ready",
    "device-verified",
    "physical-device validated",
    "fully accessible",
    "performance validated",
    "privacy approved",
    "legally approved",
    "sync-ready",
    "cloud-ready",
]

REQUIRED_CONTROL_PLANE_FILES = [
    "docs/codex/AMB_REMAINING_BATCH_REFERENCE.md",
    "docs/codex/AMB_REMAINING_BATCH_REFERENCE.json",
    "docs/codex/AMB_GLOBAL_BATCH_TRAIN_SEQUENCE.md",
]


def read_text(path: str) -> str:
    file_path = ROOT / path
    if not file_path.exists():
        return ""
    return file_path.read_text(encoding="utf-8", errors="replace")


def extract_after(label: str, text: str) -> str:
    pattern = rf"^{re.escape(label)}\s*:?\s*[\"`']?([^\"`'\n]+)"
    match = re.search(pattern, text, flags=re.MULTILINE | re.IGNORECASE)
    return match.group(1).strip() if match else ""


def extract_yaml_value(path: str, key: str) -> str:
    text = read_text(path)
    match = re.search(rf"^\s*{re.escape(key)}:\s*[\"']?([^\"'\n]+)", text, flags=re.MULTILINE)
    return match.group(1).strip() if match else ""


def load_json(path: str) -> dict[str, Any]:
    text = read_text(path)
    if not text:
        return {}
    try:
        return json.loads(text)
    except json.JSONDecodeError as exc:
        return {"__json_error__": str(exc)}


def batch_id_from_phrase(value: str) -> str:
    match = re.search(r"\b([A-Z]+[0-9]+[A-Z]?)\b", value or "")
    return match.group(1) if match else ""


def queue_counts(reference: dict[str, Any]) -> dict[str, int]:
    counts: dict[str, int] = {}
    batches = reference.get("batches", []) if isinstance(reference, dict) else []
    for batch in batches:
        status = str(batch.get("status", "unknown"))
        counts[status] = counts.get(status, 0) + 1
    return dict(sorted(counts.items()))


def generic_sa_labels(canonical: dict[str, Any]) -> list[str]:
    defects: list[str] = []
    batches = canonical.get("batches", []) if isinstance(canonical, dict) else []
    for batch in batches:
        batch_id = str(batch.get("id", ""))
        title = str(batch.get("title", ""))
        if re.fullmatch(r"SA(1[1-9]|2[0-9]|3[0-2])", batch_id) and title == batch_id:
            defects.append(batch_id)
    return defects


def claim_warnings(paths: list[str]) -> list[str]:
    warnings: list[str] = []
    for path in paths:
        text = read_text(path)
        for claim in FORBIDDEN_RELEASE_CLAIMS:
            if claim.lower() in text.lower():
                warnings.append(
                    f"{path}: contains forbidden-readiness phrase '{claim}' — "
                    "verify it is framed as forbidden/non-claim."
                )
    return warnings


def main() -> int:
    parser = argparse.ArgumentParser(description="Read-only Ambitions queue/state snapshot")
    parser.add_argument("--strict", action="store_true", help="Return non-zero when Red warnings are present")
    parser.add_argument("--json", action="store_true", help="Emit machine-readable JSON")
    args = parser.parse_args()

    active_text = read_text(".codex/state/active-batch.yml")
    batch_state_text = read_text(".codex/reports/current-batch-train-state.md")
    run_state_text = read_text(".codex/reports/current-run-state.md")
    canonical = load_json("docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json")
    remaining = load_json("docs/codex/AMB_REMAINING_BATCH_REFERENCE.json")

    active_current = extract_yaml_value(".codex/state/active-batch.yml", "batch")
    active_next = extract_yaml_value(".codex/state/active-batch.yml", "next_eligible_batch")
    batch_state_current = extract_after("Current batch", batch_state_text)
    batch_state_next = extract_after("Next eligible batch", batch_state_text) or extract_after(
        "Next recommended implementation pass", batch_state_text
    )
    run_state_current = extract_after("Current batch", run_state_text)
    run_state_next = extract_after("Next eligible batch", run_state_text)

    canonical_next = ""
    if isinstance(canonical, dict):
        canonical_next = str(canonical.get("next_eligible_batch", ""))

    active_next_id = batch_id_from_phrase(active_next)
    batch_state_next_id = batch_id_from_phrase(batch_state_next)
    run_state_next_id = batch_id_from_phrase(run_state_next)
    canonical_next_id = batch_id_from_phrase(canonical_next)

    warnings: list[str] = []
    red: list[str] = []

    if not active_text:
        red.append("Missing .codex/state/active-batch.yml")
    if not batch_state_text:
        red.append("Missing .codex/reports/current-batch-train-state.md")
    if not run_state_text:
        red.append("Missing .codex/reports/current-run-state.md")

    next_ids = {
        "active-batch.yml": active_next_id,
        "current-batch-train-state.md": batch_state_next_id,
        "current-run-state.md": run_state_next_id,
        "GLOBAL_QUEUE_CANONICAL_ORDER.json": canonical_next_id,
    }
    present_next_ids = {key: value for key, value in next_ids.items() if value}
    if len(set(present_next_ids.values())) > 1:
        red.append(f"Next-batch mirror mismatch: {present_next_ids}")

    if "Current batch: PK14" in run_state_text or "Next eligible batch: PK15" in run_state_text:
        red.append("Stale mirror detected: current-run-state.md still actively references PK14/PK15.")

    for required in REQUIRED_CONTROL_PLANE_FILES:
        if not (ROOT / required).exists():
            warnings.append(f"Missing control-plane artifact: {required}")

    if isinstance(canonical, dict) and canonical.get("__json_error__"):
        red.append(f"Canonical queue JSON invalid: {canonical['__json_error__']}")

    sa_defects = generic_sa_labels(canonical if isinstance(canonical, dict) else {})
    if sa_defects:
        red.append(f"Generic Source Atlas titles remain in canonical queue: {', '.join(sa_defects)}")

    remaining_reference = read_text("docs/codex/AMB_REMAINING_BATCH_REFERENCE.md")
    if "standalone AIR" in remaining_reference and "Do not create standalone AIR" not in remaining_reference:
        warnings.append("Remaining reference mentions standalone AIR; verify it says not to create one.")

    release_claim_notes = claim_warnings(
        [
            ".codex/state/active-batch.yml",
            ".codex/reports/current-batch-train-state.md",
            ".codex/reports/current-run-state.md",
            "docs/codex/AMB_GLOBAL_BATCH_TRAIN_SEQUENCE.md",
        ]
    )

    if red:
        status = "RED"
        next_safe_action = "Repair control-plane state before running any implementation batch."
    elif warnings:
        status = "YELLOW"
        next_safe_action = active_next_id or canonical_next_id or "Inspect queue manually."
    else:
        status = "GREEN"
        next_safe_action = active_next_id or canonical_next_id or "Inspect queue manually."

    payload = {
        "status": status,
        "next_safe_action": next_safe_action,
        "active_state_summary": {
            "active_current": active_current,
            "active_next": active_next,
            "batch_state_current": batch_state_current,
            "batch_state_next": batch_state_next,
            "run_state_current": run_state_current,
            "run_state_next": run_state_next,
            "canonical_next": canonical_next,
        },
        "queue_counts": queue_counts(remaining if isinstance(remaining, dict) else {}),
        "warnings": warnings,
        "red": red,
        "release_claim_notes": release_claim_notes,
    }

    if args.json:
        print(json.dumps(payload, indent=2, sort_keys=True))
    else:
        print(f"STATUS: {status}")
        print(f"next_safe_action: {next_safe_action}")
        print("\nActive state summary:")
        for key, value in payload["active_state_summary"].items():
            print(f"- {key}: {value or 'UNKNOWN'}")
        print("\nQueue counts:")
        if payload["queue_counts"]:
            for key, value in payload["queue_counts"].items():
                print(f"- {key}: {value}")
        else:
            print("- unavailable")
        print("\nWarnings:")
        for item in warnings or ["none"]:
            print(f"- {item}")
        print("\nRed:")
        for item in red or ["none"]:
            print(f"- {item}")
        print("\nRelease claim notes:")
        for item in release_claim_notes or ["none"]:
            print(f"- {item}")

    return 1 if args.strict and status == "RED" else 0


if __name__ == "__main__":
    raise SystemExit(main())
