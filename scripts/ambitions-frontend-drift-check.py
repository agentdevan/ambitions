#!/usr/bin/env python3
from __future__ import annotations

import argparse
import re
from pathlib import Path
from typing import Any

from ambitions_frontend_authority_common import (
    ACTIVE_IA,
    BATCH_ID,
    FRONTEND_ROOT,
    REPORT_DIR,
    SOURCE_BINDINGS_PATH,
    load_json,
    universe_rows,
    write_json,
    write_text,
)
from ambitions_signature_visual_instruments import (
    DOCTRINE_PATH,
    MATRIX_PATH,
    ROOT_SURFACES,
    missing_top_level_instruments,
)


FORBIDDEN_PHRASES = [
    "plan as an active destination",
    "chatbot ui",
    "generic dashboard",
    "card stack",
    "task list",
    "release-ready",
    "device-verified",
    "accessibility verified",
]

NEGATIVE_CONTEXT_WORDS = [
    "forbidden",
    "avoid",
    "avoids",
    "avoiding",
    "no",
    "not",
    "never",
    "do not",
    "don't",
    "reject",
    "without",
    "forbidden_patterns",
    "forbidden drift",
    "visual regression guardrails",
]

RULE_ONLY_PATH_MARKERS = [
    "build/reports/frontend-authority-packets/",
    "prompts/generated/frontend/",
    "frontend/visual-encyclopedia/SIGNATURE_VISUAL_INSTRUMENTS.md",
    "frontend/visual-encyclopedia/trace/SIGNATURE_VISUAL_INSTRUMENTS_MATRIX.yaml",
]


def in_negative_context(line: str) -> bool:
    text = line.lower()
    return any(word in text for word in NEGATIVE_CONTEXT_WORDS)


def is_rule_only_path(path: Path) -> bool:
    rel = str(path.relative_to(Path.cwd())) if path.is_absolute() else str(path)
    return any(marker in rel for marker in RULE_ONLY_PATH_MARKERS)


def scan_text_paths(paths: list[Path]) -> dict[str, list[str]]:
    hits: dict[str, list[str]] = {}
    for path in paths:
        if not path.exists():
            continue
        rule_only = is_rule_only_path(path)
        for line in path.read_text(encoding="utf-8").splitlines():
            lower = line.lower()
            if in_negative_context(lower) or rule_only:
                continue
            for phrase in FORBIDDEN_PHRASES:
                if phrase in lower:
                    hits.setdefault(str(path.relative_to(Path.cwd())), []).append(line.strip())
                    break
    return hits


def parse_swift_cases(path: Path, prefix: str) -> list[str]:
    if not path.exists():
        return []
    cases: list[str] = []
    pattern = re.compile(r"^\s*case\s+([A-Za-z0-9_]+)\s*=\s*\"([^\"]+)\"")
    for line in path.read_text(encoding="utf-8").splitlines():
        match = pattern.match(line)
        if match and prefix in path.name:
            cases.append(match.group(2))
    return cases


def load_bindings() -> list[dict[str, Any]]:
    if not SOURCE_BINDINGS_PATH.exists():
        return []
    payload = load_json(SOURCE_BINDINGS_PATH)
    return [row for row in payload.get("bindings", []) if isinstance(row, dict)]


def build_report(surface_id: str | None, strict: bool) -> dict[str, Any]:
    universe = {row["surface_universe_id"]: row for row in universe_rows()}
    expected_active_ia = ["Today", "Goals", "Capture", "Time", "You"]
    bindings = load_bindings()
    packet_paths = list((REPORT_DIR / "frontend-authority-packets").glob("*.md"))
    prompt_paths = list((Path.cwd() / "prompts" / "generated" / "frontend").glob("*.md"))
    generated_swift_paths = [
        Path("Sources/Theme/AmbitionsSurfaceID.generated.swift"),
        Path("Sources/Theme/AmbitionsRecipeID.generated.swift"),
        Path("Sources/Theme/AmbitionsFrontendAuthority.generated.swift"),
    ]

    report = {
        "batch_id": BATCH_ID,
        "generated_from_batch": BATCH_ID,
        "strict": strict,
        "surface_id": surface_id,
        "active_ia": list(ACTIVE_IA),
        "active_ia_expected": expected_active_ia,
        "active_ia_status": "green" if list(ACTIVE_IA) == expected_active_ia else "red",
        "prompt_header_status": "green",
        "surface_id_registration_status": "green",
        "recipe_id_registration_status": "green",
        "binding_consistency_status": "green",
        "proof_claim_status": "green",
        "signature_instrument_status": "green",
        "doctrine_status": "green" if DOCTRINE_PATH.exists() and MATRIX_PATH.exists() else "red",
        "violations": [],
        "warnings": [],
    }

    if list(ACTIVE_IA) != expected_active_ia:
        report["violations"].append("active IA labels are not the required Today / Goals / Capture / Time / You set")

    if not DOCTRINE_PATH.exists() or not MATRIX_PATH.exists():
        report["violations"].append("signature visual instrument doctrine or matrix is missing")

    text_targets = [
        FRONTEND_ROOT / "README.md",
        FRONTEND_ROOT / "FRONTEND_AUTHORITY_INDEX.md",
        FRONTEND_ROOT / "ENCYCLOPEDIA_TO_FRONTEND_OS.md",
        DOCTRINE_PATH,
    ] + packet_paths + prompt_paths
    scan_hits = scan_text_paths(text_targets)
    if scan_hits:
        report["warnings"].append({"active_text_scan_hits": scan_hits})

    prompt_header_required = [
        "<!-- AMBITIONS_RUNNER_REQUIRED: true -->",
        "<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->",
        "<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->",
    ]
    prompt_status = "green"
    for path in prompt_paths:
        text = path.read_text(encoding="utf-8")
        if not all(marker in text for marker in prompt_header_required):
            prompt_status = "red"
            report["violations"].append(f"prompt missing required header: {path}")
        if "Signature Visual Instrument Requirements" not in text:
            prompt_status = "red"
            report["violations"].append(f"generated implementation prompt missing signature instrument requirements: {path}")
    report["prompt_header_status"] = prompt_status

    universe_ids = set(universe)
    surface_cases = parse_swift_cases(Path("Sources/Theme/AmbitionsSurfaceID.generated.swift"), "AmbitionsSurfaceID")
    recipe_cases = parse_swift_cases(Path("Sources/Theme/AmbitionsRecipeID.generated.swift"), "AmbitionsRecipeID")
    if surface_cases and not set(surface_cases).issubset(universe_ids):
        report["surface_id_registration_status"] = "red"
        report["violations"].append("generated surface IDs reference unregistered encyclopedia IDs")
    recipe_ids = {str(row.get("recipe_inventory_id") or row.get("surface_universe_id")) for row in universe_rows()}
    if recipe_cases and not set(recipe_cases).issubset(recipe_ids):
        report["recipe_id_registration_status"] = "red"
        report["violations"].append("generated recipe IDs reference IDs absent from the encyclopedia")

    if bindings:
        binding_payloads = [
            {
                "surface_id": row.get("surface_id"),
                "signature_visual_instrument": {
                    "signature_instrument_id": row.get("signature_instrument_id"),
                },
            }
            for row in bindings
        ]
        missing_roots = missing_top_level_instruments(binding_payloads)
        if missing_roots:
            report["signature_instrument_status"] = "red"
            report["violations"].append("top-level surfaces missing signature instruments: " + ", ".join(missing_roots))
        for binding in bindings:
            if binding.get("surface_id") in ROOT_SURFACES and not binding.get("signature_instrument_id"):
                report["signature_instrument_status"] = "red"
                report["violations"].append(f"root binding missing signature instrument: {binding.get('surface_id')}")
            if binding.get("implementation_status") == "proven" and not binding.get("last_receipt"):
                report["binding_consistency_status"] = "red"
                report["violations"].append(f"binding marks proven without receipt: {binding.get('surface_id')}")
                break
            if binding.get("proof_status") == "proven" and not binding.get("last_receipt"):
                report["proof_claim_status"] = "red"
                report["violations"].append(f"proof status is proven without receipt: {binding.get('surface_id')}")
                break
    else:
        report["warnings"].append("source bindings have not been generated yet")

    if surface_id and surface_id not in universe_ids:
        report["violations"].append(f"surface id not registered: {surface_id}")

    report["status"] = "green" if not report["violations"] else "red"
    if strict and report["warnings"]:
        report["status"] = "red"
        report["violations"].extend([f"strict warning: {item}" for item in report["warnings"]])
    return report


def render_md(report: dict[str, Any]) -> str:
    lines = [
        "# Frontend Drift Check",
        "",
        f"Batch: `{report['batch_id']}`",
        f"Status: `{report['status']}`",
        f"Strict: `{report['strict']}`",
        "",
        "## Statuses",
        f"- active IA: {report['active_ia_status']}",
        f"- doctrine: {report['doctrine_status']}",
        f"- prompt headers: {report['prompt_header_status']}",
        f"- surface IDs: {report['surface_id_registration_status']}",
        f"- recipe IDs: {report['recipe_id_registration_status']}",
        f"- binding consistency: {report['binding_consistency_status']}",
        f"- proof claims: {report['proof_claim_status']}",
        f"- signature instruments: {report['signature_instrument_status']}",
        "",
        "## Violations",
    ]
    lines.extend(f"- {item}" for item in report["violations"] or ["None"])
    lines.extend(["", "## Warnings"])
    warnings = report.get("warnings", [])
    if warnings:
        for item in warnings:
            lines.append(f"- {item}")
    else:
        lines.append("- None")
    return "\n".join(lines).rstrip() + "\n"


def main() -> int:
    parser = argparse.ArgumentParser(description="Run frontend drift checks.")
    parser.add_argument("--surface")
    parser.add_argument("--strict", action="store_true")
    args = parser.parse_args()

    report = build_report(args.surface, args.strict)
    write_json(REPORT_DIR / "frontend-drift-check.json", report)
    write_text(REPORT_DIR / "frontend-drift-check.md", render_md(report))
    print(report["status"].upper())
    return 0 if report["status"] == "green" else 1


if __name__ == "__main__":
    raise SystemExit(main())
