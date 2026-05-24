#!/usr/bin/env python3
"""Validate repo-intelligence packet shape, budgets, and advisory-proof boundaries."""
from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]

REQUIRED_TOP_LEVEL = [
    "batch_id",
    "cache_key",
    "budgets",
    "tool_suggestions",
    "direct_path_candidates",
    "owner_candidates",
    "proof_lookup_matrix",
    "runtime_wiring_checklist",
    "parallel_system_risks",
    "advisory_red_risks",
    "requires_direct_verification",
    "accepted_findings_policy",
    "non_claims",
]

ADVISORY_COLLECTIONS = [
    "tool_suggestions",
    "proof_lookup_matrix",
    "runtime_wiring_checklist",
    "parallel_system_risks",
    "advisory_red_risks",
]


def rel(path: Path) -> str:
    return str(path.relative_to(ROOT))


def load_packet(path: Path) -> dict[str, Any]:
    try:
        payload = json.loads(path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as exc:
        raise SystemExit(f"RED: invalid JSON: {path}: {exc}") from exc
    if not isinstance(payload, dict):
        raise SystemExit("RED: packet root must be an object")
    return payload


def path_is_local_relative(path: str) -> bool:
    if not path:
        return True
    return not path.startswith("/") and ".." not in Path(path).parts


def check_packet(packet: dict[str, Any]) -> tuple[str, list[str], list[str]]:
    errors: list[str] = []
    warnings: list[str] = []

    for key in REQUIRED_TOP_LEVEL:
        if key not in packet:
            errors.append(f"missing required key: {key}")

    budgets = packet.get("budgets", {})
    if not isinstance(budgets, dict):
        errors.append("budgets must be an object")
        budgets = {}

    budget_pairs = [
        ("owner_candidates", "max_owner_candidates"),
        ("direct_path_candidates", "max_direct_path_candidates"),
        ("proof_lookup_matrix", "max_proof_rows"),
    ]
    for collection, budget_key in budget_pairs:
        value = packet.get(collection, [])
        limit = budgets.get(budget_key)
        if not isinstance(value, list):
            errors.append(f"{collection} must be a list")
        elif isinstance(limit, int) and len(value) > limit:
            errors.append(f"{collection} exceeds budget {budget_key}={limit}: {len(value)}")

    for collection in ADVISORY_COLLECTIONS:
        for index, row in enumerate(packet.get(collection, []) or []):
            if isinstance(row, dict) and row.get("advisory_only") is not True:
                errors.append(f"{collection}[{index}] missing advisory_only=true")

    for collection in ("direct_path_candidates", "proof_lookup_matrix", "runtime_wiring_checklist"):
        for index, row in enumerate(packet.get(collection, []) or []):
            if not isinstance(row, dict):
                errors.append(f"{collection}[{index}] must be an object")
                continue
            for key in ("path", "source_path", "test_path", "expected_proof", "discovered_proof_path", "likely_source_path", "likely_test_path", "likely_proof_path"):
                value = row.get(key)
                if isinstance(value, str) and not path_is_local_relative(value):
                    errors.append(f"{collection}[{index}].{key} is not a local relative path: {value}")

    for row in packet.get("proof_lookup_matrix", []) or []:
        if isinstance(row, dict) and row.get("discovered_proof_path") and row.get("advisory_only") is True:
            warnings.append("proof lookup row found an artifact path, but it remains advisory until directly inspected")

    if packet.get("advisory_red_risks"):
        warnings.append(f"advisory Red risks present: {len(packet['advisory_red_risks'])}")

    non_claims = "\n".join(str(item).lower() for item in packet.get("non_claims", []) or [])
    for required in ("advisory", "not source truth", "validation proof"):
        if required not in non_claims:
            errors.append(f"non_claims missing boundary text containing: {required}")

    return ("GREEN" if not errors else "RED"), errors, warnings


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("packet", help="repo-intelligence packet JSON path")
    parser.add_argument("--json", action="store_true", help="print machine-readable result")
    args = parser.parse_args()

    packet_path = (ROOT / args.packet).resolve() if not Path(args.packet).is_absolute() else Path(args.packet)
    if not packet_path.exists():
        raise SystemExit(f"RED: packet missing: {args.packet}")

    packet = load_packet(packet_path)
    status, errors, warnings = check_packet(packet)
    result = {
        "status": status,
        "packet": rel(packet_path) if str(packet_path).startswith(str(ROOT)) else str(packet_path),
        "errors": errors,
        "warnings": warnings,
    }
    if args.json:
        print(json.dumps(result, indent=2, sort_keys=True))
    else:
        print(f"{status}: repo-intelligence packet shape")
        print(f"packet: {result['packet']}")
        for error in errors:
            print(f"RED: {error}")
        for warning in warnings:
            print(f"YELLOW: {warning}")
    return 0 if status == "GREEN" else 1


if __name__ == "__main__":
    raise SystemExit(main())
