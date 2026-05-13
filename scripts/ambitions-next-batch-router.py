#!/usr/bin/env python3
"""Fast next-batch router for Ambitions autonomous train.

This is a speed/orchestration helper only. It does not implement product code and it
must not be treated as build, release, privacy, device, or accessibility proof.
"""
from __future__ import annotations

import argparse
import json
import subprocess
import sys
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
QUEUE_PATH = ROOT / "docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json"
HBI_MANIFEST_PATH = ROOT / "docs/codex/HISTORICAL_BASELINE_GLOBAL_TRAIN_MANIFEST.json"
MRI_STATE_PATH = ROOT / ".codex/state/mri-autonomous-state.json"

HBI_KEYWORDS = {
    "SA", "HBI", "SCI", "IRQ", "PRI", "RHE", "PPL", "LSF", "MGP", "RRE",
    "AOS", "LDI", "FCP", "PFC", "RHC",
}
MRI_KEYWORDS = {"MRI", "OBJECT", "MOAT", "RUNTIME"}


def run(cmd: list[str]) -> tuple[int, str, str]:
    proc = subprocess.run(cmd, cwd=ROOT, text=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    return proc.returncode, proc.stdout, proc.stderr


def load_json(path: Path) -> Any:
    if not path.exists():
        return None
    with path.open("r", encoding="utf-8") as handle:
        return json.load(handle)


def flatten_batches(node: Any) -> list[str]:
    found: list[str] = []
    if isinstance(node, dict):
        for key, value in node.items():
            if key in {"id", "batch_id", "batchId"} and isinstance(value, str):
                found.append(value)
            else:
                found.extend(flatten_batches(value))
    elif isinstance(node, list):
        for item in node:
            found.extend(flatten_batches(item))
    elif isinstance(node, str):
        if node.isupper() and ("-" in node or any(node.startswith(prefix) for prefix in ["PK", "SA", "MRI", "HBI", "SCI", "IRQ", "PRI", "RHE", "PPL", "LSF", "MGP", "RRE"])):
            found.append(node)
    return found


def queue_snapshot_next() -> str | None:
    script = ROOT / "scripts/ambitions-queue-snapshot.py"
    if not script.exists():
        return None
    code, stdout, _ = run([sys.executable, str(script)])
    if code != 0:
        return None
    for line in stdout.splitlines():
        text = line.strip()
        if "executable_now" in text and any(token in text for token in ["PK", "SA", "HBI", "MRI"]):
            # Try to recover the first batch-like token.
            for raw in text.replace('"', ' ').replace("'", " ").replace(",", " ").split():
                token = raw.strip()
                if (token[:2].isalpha() and any(char.isdigit() for char in token)) or token.startswith(("HBI-", "SCI-", "IRQ-", "PRI-", "RHE-", "PPL-", "LSF-", "MGP-", "RRE-")):
                    return token
        if text.lower().startswith("next batch:"):
            return text.split(":", 1)[1].strip().split()[0]
    return None


def first_existing_prompt(candidates: list[str]) -> str | None:
    for batch_id in candidates:
        prompt = ROOT / "prompts/batches" / f"{batch_id}.md"
        if prompt.exists():
            return batch_id
    return None


def next_from_files() -> str | None:
    queue = load_json(QUEUE_PATH)
    candidates = flatten_batches(queue)
    # Preserve order while de-duping.
    ordered = list(dict.fromkeys(candidates))
    return first_existing_prompt(ordered)


def next_from_hbi_manifest() -> str | None:
    manifest = load_json(HBI_MANIFEST_PATH)
    if not isinstance(manifest, dict):
        return None
    for entry in manifest.get("batches", []):
        batch_id = entry.get("id") if isinstance(entry, dict) else None
        if isinstance(batch_id, str) and (ROOT / "prompts/batches" / f"{batch_id}.md").exists():
            return batch_id
    return None


def classify_overlay(batch_id: str) -> tuple[str, str]:
    upper = batch_id.upper()
    hbi = "required" if any(upper.startswith(prefix) for prefix in HBI_KEYWORDS) else "check_if_scope_touches_sources_or_runtime"
    mri = "required" if any(prefix in upper for prefix in MRI_KEYWORDS) else "check_if_scope_touches_runtime_or_moat"
    return hbi, mri


def build_route(batch_id: str | None) -> dict[str, Any]:
    if not batch_id:
        return {
            "next_batch_id": None,
            "prompt": None,
            "runner_command": None,
            "hbi_applicability": "unknown",
            "mri_applicability": "unknown",
            "required_guards": [],
            "hard_red_reasons": ["unable_to_resolve_next_batch"],
        }
    prompt = f"prompts/batches/{batch_id}.md"
    hbi, mri = classify_overlay(batch_id)
    guards = ["python3 scripts/ambitions-historical-baseline-train-guard.py"]
    if (ROOT / "scripts/ambitions-mri-autonomous-router.py").exists():
        guards.append("python3 scripts/ambitions-mri-autonomous-router.py --help || true")
    return {
        "next_batch_id": batch_id,
        "prompt": prompt,
        "runner_command": f"make batch BATCH={batch_id} PROMPT={prompt}",
        "hbi_applicability": hbi,
        "mri_applicability": mri,
        "required_guards": guards,
        "allowed_scope_summary": "Resolve and execute the next canonical batch with HBI/MRI overlays applied when applicable.",
        "hard_red_reasons": [],
    }


def main() -> int:
    parser = argparse.ArgumentParser(description="Resolve the next Ambitions batch quickly.")
    parser.add_argument("--dry-run", action="store_true", help="Print route JSON only.")
    parser.add_argument("--prefer-hbi", action="store_true", help="Prefer the HBI manifest sequence when canonical queue has no prompt.")
    args = parser.parse_args()

    batch_id = queue_snapshot_next() or next_from_files()
    if not batch_id and args.prefer_hbi:
        batch_id = next_from_hbi_manifest()
    route = build_route(batch_id)
    print(json.dumps(route, indent=2, sort_keys=True))
    return 1 if route["hard_red_reasons"] else 0


if __name__ == "__main__":
    raise SystemExit(main())
