#!/usr/bin/env python3
"""Autonomous MRI intervention router.

MRI is a sidecar moat-runtime integration overlay. This router decides when an
MRI bundle should run before the normal global train continues, without adding
all MRI batches directly to the canonical global queue.
"""
from __future__ import annotations

import argparse
import json
import subprocess
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
QUEUE = ROOT / "docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json"
OVERLAY = ROOT / "docs/codex/MOAT_RUNTIME_BATCH_OVERLAY.json"
STATE = ROOT / ".codex/state/mri-autonomous-state.json"
MATERIALIZER = ROOT / "scripts/ambitions-mri-materialize-prompts.py"


@dataclass(frozen=True)
class Milestone:
    name: str
    trigger_next: tuple[str, ...]
    bundle: tuple[str, ...]
    reason: str


MILESTONES: tuple[Milestone, ...] = (
    Milestone(
        name="after-source-atlas-core",
        trigger_next=("SA11",),
        bundle=tuple(f"MRI{number:02d}" for number in range(1, 9)),
        reason="SA core claim/proof/freshness/projection foundation is complete enough to lock Ambition Lifecycle loops before deeper Source Atlas runtime continues.",
    ),
    Milestone(
        name="after-source-atlas-runtime",
        trigger_next=("SA17",),
        bundle=tuple(f"MRI{number:02d}" for number in range(9, 17)),
        reason="Source Atlas store/query/source-needed/container runtime is complete enough to wire inspectable intelligence before importers expand scope.",
    ),
    Milestone(
        name="after-source-atlas-importers",
        trigger_next=("SA25",),
        bundle=tuple(f"MRI{number:02d}" for number in range(17, 25)),
        reason="Source import/extraction/classification is complete enough to connect Reality Fit and LifeShape loops before review/pack/freshness handoff.",
    ),
    Milestone(
        name="after-source-atlas-complete",
        trigger_next=("AOS24", "AOS25", "LDI17", "FCP27", "PFC31", "RHC01"),
        bundle=tuple(f"MRI{number:02d}" for number in range(25, 35)),
        reason="Source Atlas is complete enough to run Native Signature Interface integration before visual/product/platform closeout work continues.",
    ),
    Milestone(
        name="before-terminal-assurance",
        trigger_next=("RHC01", "RHC02", "DPTG01", "FINAL01", "PFC37", "PFC38", "PFC39", "PFC40"),
        bundle=tuple(f"MRI{number:02d}" for number in range(35, 45)),
        reason="Terminal cleanup/release-adjacent work requires Assurance Lab scenarios and claim-safety checks before readiness-style gates.",
    ),
    Milestone(
        name="final-moat-integration",
        trigger_next=("FINAL01", "DPTG01", "RELEASE01"),
        bundle=tuple(f"MRI{number:02d}" for number in range(45, 51)),
        reason="Final release-candidate style work requires cross-surface moat coherence, journey proof, native surface coherence, narrative proof draft, repo hygiene, and founder acceptance gates.",
    ),
)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Route autonomous MRI interventions.")
    parser.add_argument("--status", action="store_true", help="Print routing status.")
    parser.add_argument("--next", action="store_true", help="Print next MRI intervention as '<batch> <prompt> <milestone>', or NONE.")
    parser.add_argument("--json", action="store_true", help="Emit JSON status.")
    parser.add_argument("--materialize-if-needed", action="store_true", help="Materialize MRI prompts before returning an intervention.")
    parser.add_argument("--mark-complete", help="Mark an MRI batch complete in MRI autonomous state.")
    return parser.parse_args()


def load_json(path: Path, default: Any) -> Any:
    if not path.exists():
        return default
    return json.loads(path.read_text(encoding="utf-8"))


def write_json(path: Path, data: Any) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")


def overlay_batches() -> dict[str, dict[str, Any]]:
    data = load_json(OVERLAY, {"batches": []})
    return {entry["id"]: entry for entry in data.get("batches", [])}


def current_next() -> str:
    data = load_json(QUEUE, {"batches": []})
    for entry in data.get("batches", []):
        if entry.get("classification") == "executable_now":
            return entry.get("id", "")
    return data.get("next_eligible_batch", "")


def state() -> dict[str, Any]:
    loaded = load_json(STATE, {})
    loaded.setdefault("schema_version", 1)
    loaded.setdefault("completed_batches", [])
    loaded.setdefault("history", [])
    return loaded


def normalize_batch_id(value: str, batches: dict[str, dict[str, Any]]) -> str:
    stem = Path(value).stem
    prefix = stem.split("-", 1)[0]
    if prefix in batches:
        return prefix
    if value in batches:
        return value
    raise SystemExit(f"ERROR: unknown MRI batch id: {value}")


def prompt_exists(batch: dict[str, Any]) -> bool:
    return (ROOT / batch["prompt_file"]).exists()


def materialize() -> None:
    subprocess.run(["python3", str(MATERIALIZER)], cwd=ROOT, check=True)


def next_intervention() -> dict[str, Any] | None:
    batches = overlay_batches()
    completed = set(state().get("completed_batches", []))
    next_id = current_next()
    for milestone in MILESTONES:
        if next_id not in milestone.trigger_next:
            continue
        for mri_id in milestone.bundle:
            if mri_id not in completed:
                batch = batches[mri_id]
                return {
                    "batch_prefix": mri_id,
                    "batch_id": Path(batch["prompt_file"]).stem,
                    "prompt": batch["prompt_file"],
                    "milestone": milestone.name,
                    "reason": milestone.reason,
                    "trigger_next": next_id,
                }
    return None


def mark_complete(value: str) -> None:
    batches = overlay_batches()
    mri_id = normalize_batch_id(value, batches)
    data = state()
    if mri_id not in data["completed_batches"]:
        data["completed_batches"].append(mri_id)
    data["history"].append({
        "batch": mri_id,
        "prompt": batches[mri_id]["prompt_file"],
        "marked_complete_at": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
    })
    write_json(STATE, data)
    print(f"MARKED_COMPLETE {mri_id}")


def status_dict() -> dict[str, Any]:
    intervention = next_intervention()
    return {
        "current_global_next": current_next(),
        "completed_mri_batches": state().get("completed_batches", []),
        "next_intervention": intervention,
        "milestones": [
            {"name": m.name, "trigger_next": list(m.trigger_next), "bundle": list(m.bundle), "reason": m.reason}
            for m in MILESTONES
        ],
    }


def main() -> int:
    args = parse_args()
    if args.mark_complete:
        mark_complete(args.mark_complete)
        return 0
    if args.materialize_if_needed:
        intervention = next_intervention()
        if intervention:
            batch = overlay_batches()[intervention["batch_prefix"]]
            if not prompt_exists(batch):
                materialize()
    if args.json:
        print(json.dumps(status_dict(), indent=2))
        return 0
    if args.next:
        intervention = next_intervention()
        if intervention:
            print(f"{intervention['batch_id']} {intervention['prompt']} {intervention['milestone']}")
        else:
            print("NONE")
        return 0
    # default/status
    data = status_dict()
    print(f"Current global next: {data['current_global_next']}")
    print(f"Completed MRI count: {len(data['completed_mri_batches'])}")
    if data["next_intervention"]:
        i = data["next_intervention"]
        print(f"Next MRI intervention: {i['batch_id']} ({i['milestone']})")
        print(f"Prompt: {i['prompt']}")
        print(f"Reason: {i['reason']}")
    else:
        print("Next MRI intervention: NONE")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
