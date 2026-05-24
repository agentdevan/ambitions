#!/usr/bin/env python3
"""Aggregate IOS26 frozen-train review, proof, and claim gaps."""

from __future__ import annotations

import argparse
import json
import re
import sys
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MANIFEST = ROOT / "docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml"
RUNNER = ROOT / "scripts/ios26-flagship-run-sequential.sh"
HASH_FILE = ROOT / "docs/codex/ios26/IOS26_PROMPT_FREEZE_HASHES.json"
REVIEW_DIR = ROOT / "build/reports/ios26-review-sweep"
REPAIR_QUEUE = ROOT / "docs/codex/ios26/IOS26_REPAIR_QUEUE.md"
PROMPT_DIR = ROOT / "prompts/batches"
BATCH_RE = re.compile(r"(IOS26-T\d{2}[A-Z]?-B\d{2})")
OLD_IA = ["Plan tab", "Profile tab", "best next move", "next best move", "Begin Focus", "Start Focus", "overdue", "failed", "streak broken", "productivity dropped"]
BLOCKED_CLAIMS = ["release-ready", "App Store-ready", "TestFlight-ready", "device-verified", "fully accessible", "VoiceOver verified", "Dynamic Type verified", "performance validated", "privacy approved", "legally approved"]


def rel(path: Path) -> str:
    return str(path.relative_to(ROOT))


def utc_now() -> str:
    return datetime.now(timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")


def parse_manifest() -> tuple[list[str], list[str]]:
    batches: list[str] = []
    proof_roots: list[str] = []
    section = ""
    in_batches = False
    for raw in MANIFEST.read_text(encoding="utf-8").splitlines():
        line = raw.rstrip()
        stripped = line.strip()
        if stripped == "proof_artifact_roots:":
            section = "proof"
            in_batches = False
            continue
        if stripped == "trains:":
            section = "trains"
            in_batches = False
            continue
        if section == "proof" and line.startswith("  - "):
            proof_roots.append(stripped.removeprefix("- "))
        elif section == "trains":
            if line.startswith("  - id: "):
                in_batches = False
            elif stripped == "batches:":
                in_batches = True
            elif in_batches and line.startswith("      - "):
                batches.append(stripped.removeprefix("- "))
    return batches, proof_roots


def prompt_for(batch_id: str) -> list[Path]:
    return sorted(PROMPT_DIR.glob(f"{batch_id}-*.md"))


def runner_batches() -> list[str]:
    if not RUNNER.exists():
        return []
    return [match.group(1) for match in re.finditer(r"run_batch\s+(IOS26-T\d{2}[A-Z]?-B\d{2})\s+", RUNNER.read_text(encoding="utf-8"))]


def hash_entries() -> dict[str, dict[str, str]]:
    if not HASH_FILE.exists():
        return {}
    data = json.loads(HASH_FILE.read_text(encoding="utf-8"))
    return {entry["prompt_path"]: entry for entry in data.get("entries", [])}


def status_for_batch(batch_id: str) -> str:
    reports = sorted((ROOT / "build/reports").glob(f"**/*{batch_id}*"))
    text = "\n".join(path.read_text(encoding="utf-8", errors="ignore")[:4000] for path in reports if path.is_file() and path.suffix in {".md", ".txt", ".json"})
    match = re.search(r"STATUS:\s*(GREEN|YELLOW|RED)|Status:\s*(GREEN|YELLOW|RED)", text, re.IGNORECASE)
    if match:
        return (match.group(1) or match.group(2)).upper()
    return "MISSING_PROOF"


def scan_terms(paths: list[Path], terms: list[str]) -> list[str]:
    hits: list[str] = []
    for path in paths:
        if not path.exists() or not path.is_file():
            continue
        text = path.read_text(encoding="utf-8", errors="ignore")
        for term in terms:
            if term in text:
                hits.append(f"{rel(path)}: {term}")
    return hits


def build_report() -> dict[str, object]:
    batches, proof_roots = parse_manifest()
    runner = runner_batches()
    hashes = hash_entries()
    prompt_paths = [path for batch in batches for path in prompt_for(batch)]
    prompt_hash_paths = set(hashes)
    statuses = {batch: status_for_batch(batch) for batch in batches}
    missing_prompts = [batch for batch in batches if not prompt_for(batch)]
    missing_hashes = [rel(path) for path in prompt_paths if rel(path) not in prompt_hash_paths]
    missing_proof_roots = [root for root in proof_roots if not (ROOT / root).exists()]
    old_ia_hits = scan_terms(prompt_paths + [ROOT / "docs/codex/IOS26_FLAGSHIP_SEQUENTIAL_RUNBOOK.md"], OLD_IA)
    stale_claim_hits = scan_terms(prompt_paths + [ROOT / "docs/codex/IOS26_FLAGSHIP_SEQUENTIAL_RUNBOOK.md"], BLOCKED_CLAIMS)
    missing_proof = [batch for batch, status in statuses.items() if status == "MISSING_PROOF"]
    return {
        "generated_at": utc_now(),
        "manifest_batches": len(batches),
        "prompt_files_found": len(prompt_paths),
        "missing_prompts": missing_prompts,
        "runner_coverage": {
            "runner_batches": len(runner),
            "missing_from_runner": [batch for batch in batches if batch not in runner],
            "extra_in_runner": [batch for batch in runner if batch not in batches],
            "order_matches_manifest": runner == batches,
        },
        "prompt_hash_coverage": {
            "hash_entries": len(hashes),
            "missing_hashes": missing_hashes,
        },
        "proof_root_coverage": {
            "declared": len(proof_roots),
            "missing": missing_proof_roots,
        },
        "statuses": statuses,
        "missing_proof": missing_proof,
        "stale_claims": stale_claim_hits,
        "old_ia_or_naming_drift": old_ia_hits,
        "accessibility_proof_gaps": missing_proof,
        "performance_proof_gaps": [batch for batch in batches if "-T14-" in batch and statuses[batch] == "MISSING_PROOF"],
        "privacy_local_first_proof_gaps": missing_proof,
        "parallel_owner_duplicate_implementation_warnings": "Review champion/parallel guard reports for each source-changing batch; this sweep does not invent owner changes.",
    }


def status(report: dict[str, object]) -> str:
    if report["missing_prompts"] or report["runner_coverage"]["missing_from_runner"] or report["prompt_hash_coverage"]["missing_hashes"]:  # type: ignore[index]
        return "RED"
    if report["missing_proof"] or report["stale_claims"] or report["old_ia_or_naming_drift"]:
        return "YELLOW"
    return "GREEN"


def render_md(report: dict[str, object]) -> str:
    result = status(report)
    lines = [
        "# IOS26 Review Sweep",
        "",
        f"Generated: {report['generated_at']}",
        f"Status: {result}",
        "",
        f"- Manifest batches: {report['manifest_batches']}",
        f"- Prompt files found: {report['prompt_files_found']}",
        f"- Missing prompts: {', '.join(report['missing_prompts']) or 'none'}",
        f"- Runner missing: {', '.join(report['runner_coverage']['missing_from_runner']) or 'none'}",
        f"- Prompt hashes missing: {', '.join(report['prompt_hash_coverage']['missing_hashes']) or 'none'}",
        f"- Missing proof roots: {', '.join(report['proof_root_coverage']['missing']) or 'none'}",
        f"- Missing proof by batch: {len(report['missing_proof'])}",
        f"- Stale claim hits: {len(report['stale_claims'])}",
        f"- Old IA/naming drift hits: {len(report['old_ia_or_naming_drift'])}",
        "",
        "This sweep creates bounded repair inputs only. It does not prove release readiness or invent feature scope.",
        "",
    ]
    return "\n".join(lines)


def render_repair_queue(report: dict[str, object]) -> str:
    lines = ["# IOS26 Repair Queue", "", "Generated by `scripts/ios26-review-sweep.py`.", "", "Repairs must stay inside the sealed batch boundary and cannot invent feature scope.", ""]
    for batch in report["missing_prompts"]:
        lines.append(f"- RED `{batch}`: missing prompt. Owner: IOS26 orchestration. Gate: regenerate/freeze prompt.")
    for item in report["prompt_hash_coverage"]["missing_hashes"]:  # type: ignore[index]
        lines.append(f"- RED `{item}`: missing prompt freeze hash. Owner: IOS26 orchestration. Gate: rerun prompt freeze.")
    for batch in report["missing_proof"][:50]:
        lines.append(f"- YELLOW `{batch}`: proof status not found. Owner: batch implementer. No-claim boundary: no validation/accessibility/performance/privacy/release claim.")
    if len(lines) == 6:
        lines.append("- No bounded repairs found.")
    return "\n".join(lines) + "\n"


def write() -> dict[str, object]:
    REVIEW_DIR.mkdir(parents=True, exist_ok=True)
    REPAIR_QUEUE.parent.mkdir(parents=True, exist_ok=True)
    report = build_report()
    (REVIEW_DIR / "ios26-review-sweep.md").write_text(render_md(report), encoding="utf-8")
    (REVIEW_DIR / "ios26-review-sweep.json").write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    REPAIR_QUEUE.write_text(render_repair_queue(report), encoding="utf-8")
    return report


def check() -> int:
    required = [REVIEW_DIR / "ios26-review-sweep.md", REVIEW_DIR / "ios26-review-sweep.json", REPAIR_QUEUE]
    missing = [rel(path) for path in required if not path.exists()]
    if missing:
        for path in missing:
            print(f"RED: missing {path}")
        return 1
    report = json.loads((REVIEW_DIR / "ios26-review-sweep.json").read_text(encoding="utf-8"))
    if report["missing_prompts"] or report["runner_coverage"]["missing_from_runner"] or report["prompt_hash_coverage"]["missing_hashes"]:
        print("RED: review sweep has blocking coverage gaps")
        return 1
    print(f"GREEN: IOS26 review sweep check passed status={status(report)}")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    if args.check:
        return check()
    report = write()
    print(f"{status(report)}: IOS26 review sweep written")
    return 0


if __name__ == "__main__":
    sys.exit(main())
