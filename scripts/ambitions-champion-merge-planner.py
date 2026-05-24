#!/usr/bin/env python3
"""Generate Champion Merge queue and concept lock registry.

Conservative planner: no source rewrites, no deletion. Missing or incomplete
evidence produces Yellow unless a required owner map is absent.
"""

from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
AUDIT = ROOT / "docs/audits/intelligence-consolidation"
REPORT = ROOT / "build/reports/intelligence-consolidation"
OWNER_YML = ROOT / "docs/codex/canonical-owner-map.yml"
CONCEPT_LOCKS = ROOT / "docs/codex/concept-lock-registry.yml"
QUEUE = AUDIT / "CHAMPION_MERGE_QUEUE.md"
OUT_MD = REPORT / "champion-merge-plan.md"
OUT_JSON = REPORT / "champion-merge-plan.json"

CONCEPTS = [
    {
        "id": "today_start_here",
        "name": "Today / Start Here / HeroStepPanel",
        "owner": "today_root",
        "classification": "UNKNOWN_REQUIRES_OWNER_REVIEW",
        "active": "Native/Ambitions/Features/Today",
        "competing": ["Sources/Previews/**", "DayTimelineRail/HeroStepPanel historical references"],
        "rescue": "Reality Meridian / Start Here visual, state, accessibility fragments",
        "batch": "AMB-CHAMPION-MERGE-TODAY-01",
        "paths": ["Native/Ambitions/Features/Today", "Sources/Previews"],
    },
    {
        "id": "capture_routing",
        "name": "Capture parser/routing/SmartAttachment",
        "owner": "capture_root",
        "classification": "UNKNOWN_REQUIRES_OWNER_REVIEW",
        "active": "Native/Ambitions/Features/Capture; Native/Ambitions/Services/SmartAttachmentService.swift",
        "competing": ["CaptureSemanticExtraction", "CaptureRuntimeFactoring", "PlacementPreview"],
        "rescue": "Best parsing, placement, correction, review behavior",
        "batch": "AMB-CHAMPION-MERGE-CAPTURE-01",
        "paths": ["Native/Ambitions/Features/Capture", "Native/Ambitions/Services/SmartAttachmentService.swift"],
    },
    {
        "id": "runtime_recommendation_compiler",
        "name": "Recommendation engine / Step candidate / Goal compiler",
        "owner": "private_life_runtime",
        "classification": "UNKNOWN_REQUIRES_OWNER_REVIEW",
        "active": "Native/Ambitions/Runtime; Native/Ambitions/Domain; Native/Ambitions/Services",
        "competing": ["Source Atlas bridge", "Goal compiler", "step optionality", "life context"],
        "rescue": "Candidate generation, simulation, source bridge, learning signals",
        "batch": "AMB-CHAMPION-MERGE-RUNTIME-01",
        "paths": ["Native/Ambitions/Runtime", "Native/Ambitions/Domain", "Native/Ambitions/Services"],
    },
    {
        "id": "proof_receipt_replay",
        "name": "Proof / Receipt / ReplayTrace",
        "owner": "proof_receipt_replay",
        "classification": "UNKNOWN_REQUIRES_OWNER_REVIEW",
        "active": "Native/Ambitions/Domain; Native/Ambitions/Services; Native/Ambitions/Runtime",
        "competing": ["proof drawer/service", "receipt lineage", "replay trace paths"],
        "rescue": "Best trust, closure, recovery, replay behavior",
        "batch": "AMB-CHAMPION-MERGE-PROOF-RECEIPT-REPLAY-01",
        "paths": ["Native/Ambitions/Domain", "Native/Ambitions/Services", "Native/Ambitions/Runtime"],
    },
    {
        "id": "time_plan_lifeshape",
        "name": "Time / Plan / LifeShape provider",
        "owner": "time_root",
        "classification": "UNKNOWN_REQUIRES_OWNER_REVIEW",
        "active": "Native/Ambitions/Features/Time",
        "competing": ["Native/Ambitions/Features/Plan", "schedule provider", "availability/conflict engines"],
        "rescue": "Plan-era useful planning behavior and LifeShape/time provider depth",
        "batch": "AMB-CHAMPION-MERGE-TIME-01",
        "paths": ["Native/Ambitions/Features/Time", "Native/Ambitions/Features/Plan", "Native/Ambitions/Integrations/CalendarReminders"],
    },
    {
        "id": "you_profile_personal_runtime",
        "name": "You / Profile / Personal Runtime",
        "owner": "you_root",
        "classification": "UNKNOWN_REQUIRES_OWNER_REVIEW",
        "active": "Native/Ambitions/Features/You",
        "competing": ["Profile-era controls", "What Ambitions knows", "Trust & Automation"],
        "rescue": "Inspection, reset/delete, trust controls",
        "batch": "AMB-CHAMPION-MERGE-YOU-01",
        "paths": ["Native/Ambitions/Features/You"],
    },
    {
        "id": "design_primitives",
        "name": "Design tokens/materials/primitives",
        "owner": "design_system",
        "classification": "RESCUE_AND_MERGE",
        "active": "Sources; AppUI/Sources; Native/Ambitions/UI",
        "competing": ["feature-local primitives", "package-only primitives", "preview-only references"],
        "rescue": "Package-only better primitives, motion, haptics, accessibility helpers",
        "batch": "AMB-CHAMPION-MERGE-DESIGN-SYSTEM-01",
        "paths": ["Sources", "AppUI/Sources", "Native/Ambitions/UI"],
    },
]


def read(path: Path) -> str:
    return path.read_text(encoding="utf-8", errors="replace") if path.exists() else ""


def required_missing() -> list[str]:
    required = [
        AUDIT / "CHAMPION_SELECTION_LEDGER.md",
        AUDIT / "BEST_CODE_RESCUE_LEDGER.md",
        AUDIT / "SUPERSESSION_LEDGER.md",
        AUDIT / "PRIVATE_LIFE_RUNTIME_WIRING_MAP.md",
        AUDIT / "EXISTING_CODE_CHAMPION_COVERAGE.md",
        OWNER_YML,
    ]
    return [str(path.relative_to(ROOT)) for path in required if not path.exists()]


def write_queue() -> None:
    AUDIT.mkdir(parents=True, exist_ok=True)
    lines = [
        "# Champion Merge Queue",
        "",
        "Status: Bootstrap Yellow - owner review and source merge batches required.",
        "",
        "| Queue ID | Concept | Current classification | Canonical champion owner | Active implementation path | Competing implementation paths | Better fragments to rescue | Runtime wiring gaps | Accessibility gaps | Test/proof gaps | Risk level | Required merge batch | Blocking status | Owner review needed | Next action |",
        "| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |",
    ]
    for item in CONCEPTS:
        lines.append(
            f"| CMQ-{item['id']} | {item['name']} | {item['classification']} | {item['owner']} | `{item['active']}` | {', '.join(item['competing'])} | {item['rescue']} | Requires runtime wiring proof where runtime-affecting | Requires preservation check | Requires deterministic tests/proof | High | {item['batch']} | BLOCKED_OWNER_UNKNOWN | yes | Run owner review then Champion Merge batch |"
        )
    QUEUE.write_text("\n".join(lines) + "\n", encoding="utf-8")


def write_locks() -> None:
    lines = ["locked_concepts:"]
    for item in CONCEPTS:
        lines.extend(
            [
                f'  - concept_id: "{item["id"]}"',
                f'    concept_name: "{item["name"]}"',
                '    reason: "Duplicate/supersession risk requires Champion Merge resolution before feature work."',
                f'    classification: "{item["classification"]}"',
                f'    canonical_owner_id: "{item["owner"]}"',
                '    blocked_status: "BLOCKED_OWNER_UNKNOWN"',
                "    allowed_batch_prefixes:",
                '      - "AMB-CHAMPION-MERGE-"',
                '      - "AMB-INTELLIGENCE-CONSOLIDATION-CHAMPION-"',
                "    blocked_paths:",
                *[f'      - "{path}"' for path in item["paths"]],
                "    allowed_paths:",
                *[f'      - "{path}"' for path in item["paths"]],
                "    required_resolution_artifacts:",
                '      - "docs/audits/intelligence-consolidation/CHAMPION_MERGE_QUEUE.md"',
                '      - "docs/audits/intelligence-consolidation/SUPERSESSION_LEDGER.md"',
                '      - "docs/audits/intelligence-consolidation/BEST_CODE_RESCUE_LEDGER.md"',
                '    no_claim_boundary: "No feature train may claim this concept final until Champion Merge proof closes."',
                '    created_by_batch: "AMB-INTELLIGENCE-CONSOLIDATION-CHAMPION-MERGE-PLAN-02"',
                '    last_updated: "2026-05-24"',
            ]
        )
    CONCEPT_LOCKS.write_text("\n".join(lines) + "\n", encoding="utf-8")


def write_reports(status: str, missing: list[str]) -> None:
    REPORT.mkdir(parents=True, exist_ok=True)
    payload = {"status": status, "missing_inputs": missing, "locked_concepts": CONCEPTS, "queue": str(QUEUE.relative_to(ROOT)), "concept_lock_registry": str(CONCEPT_LOCKS.relative_to(ROOT))}
    OUT_JSON.write_text(json.dumps(payload, indent=2), encoding="utf-8")
    lines = [
        "# Champion Merge Plan",
        "",
        f"Status: {status}",
        "",
        "## Missing Inputs",
        *(f"- {item}" for item in missing or ["none"]),
        "",
        "## Required Merge Batches",
        *(f"- `{item['batch']}`: {item['name']}" for item in CONCEPTS),
        "",
        "## Source-Changing Feature Trains Blocked",
        "",
        "Feature/runtime/product trains touching locked concepts are blocked unless they are Champion Merge or owner-review resolution batches.",
    ]
    OUT_MD.write_text("\n".join(lines) + "\n", encoding="utf-8")


def main() -> int:
    missing = required_missing()
    if not OWNER_YML.exists():
        status = "RED"
    elif missing:
        status = "YELLOW"
    else:
        status = "YELLOW"
    write_queue()
    write_locks()
    write_reports(status, missing)
    print(f"STATUS: {status}")
    print(f"Queue: {QUEUE}")
    print(f"Concept locks: {CONCEPT_LOCKS}")
    print(f"Report: {OUT_MD}")
    return {"GREEN": 0, "YELLOW": 2, "RED": 1}[status]


if __name__ == "__main__":
    raise SystemExit(main())
