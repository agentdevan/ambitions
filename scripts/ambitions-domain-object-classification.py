#!/usr/bin/env python3
"""Classify Core/Domain Swift files for AMB-1676.

The script is intentionally evidence-producing, not aspirational: every current
Core/Domain Swift file must be assigned one AMB-1676 category, an orchestration
loop role, and a migration action. Remaining debt is reported without upgrading
the parent issue to Green.
"""
from __future__ import annotations

import argparse
import json
import re
import sys
from collections import Counter
from dataclasses import asdict, dataclass
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
DOMAIN_ROOT = ROOT / "Native/Ambitions/Core/Domain"
QUALITY_SCREEN_CONTRACT_ROOT = ROOT / "Native/Ambitions/Quality/ScreenContracts"
ARTIFACT_JSON = ROOT / "docs/audits/domain-object-classification.json"
ARTIFACT_MD = ROOT / "docs/audits/domain-object-classification.md"

ALLOWED_CATEGORIES = (
    "canonical_entity",
    "value_object",
    "command_payload",
    "event_payload",
    "projection_dto",
    "ui_model",
    "adapter_dto",
    "obsolete",
)

CANONICAL_ENTITY_FILES = {
    "Step.swift",
    "GoalThread.swift",
    "LifeArea.swift",
    "RealityWindow.swift",
    "CapacityShape.swift",
    "CaptureIntake.swift",
    "ClosureOutcome.swift",
    "ProofEvent.swift",
    "RecoveryState.swift",
    "UserSystemProfile.swift",
}

OBSOLETE_PATTERNS = (
    re.compile(r"^AmbitionsOS"),
    re.compile(r"^AmbitionsProductCanonV2Models\.swift$"),
    re.compile(r"TailGate"),
    re.compile(r"LivingDream"),
)

UI_MODEL_TOKENS = (
    "ScreenContract",
    "TodayModels",
    "YouModels",
    "GoalsModels",
    "RealityModels",
    "LifeAreaSummary",
    "CanonicalNowState",
)

PROJECTION_TOKENS = (
    "Projection",
    "Snapshot",
    "Summary",
    "Reading",
    "Bucket",
    "Fallback",
)

EVENT_TOKENS = (
    "Event",
    "Receipt",
    "Proof",
    "Ledger",
    "History",
    "Audit",
    "Tombstone",
)

COMMAND_TOKENS = (
    "Command",
    "Operation",
    "Mutation",
    "Action",
    "Route",
    "Capture",
    "Parser",
    "Reschedule",
)

ADAPTER_TOKENS = (
    "Boundary",
    "Interoperability",
    "Integration",
    "Knowledge",
    "Pack",
    "Source",
    "Privacy",
    "Performance",
    "External",
    "Handoff",
    "ControlPlane",
)

LOOP_ROLE_RULES = (
    ("Intent", ("Intent", "Capture", "GoalEngineIntake", "StartingPosition")),
    ("Context", ("Context", "Capacity", "Knowledge", "Source", "Privacy", "Boundary")),
    ("Path", ("Path", "Planning", "Plan", "Graph", "Goal", "Step", "Ambition")),
    ("Time Fit", ("Time", "Commitment", "Reminder", "Ritual", "FixedPoint", "Protected", "Schedule", "Reschedule")),
    ("Reflow", ("Recovery", "Correction", "Drift", "Adaptation", "Alternate", "Conflict")),
    ("Action", ("Operation", "Action", "Closure", "Execution", "Automation")),
    ("Proof", ("Proof", "Receipt", "Ledger", "Event", "Trust", "Audit")),
    ("Learning", ("Learning", "Anticipation", "User", "Profile", "Believability")),
)


@dataclass(frozen=True)
class Classification:
    path: str
    category: str
    loopRole: str
    migrationAction: str
    reason: str
    confidence: str


def rel(path: Path) -> str:
    return str(path.relative_to(ROOT))


def has_mechanical_suffix(path: Path) -> bool:
    return re.search(r"\+\d\d", path.name) is not None


def matches_any(name: str, tokens: tuple[str, ...]) -> bool:
    return any(token in name for token in tokens)


def loop_role_for(name: str) -> str:
    for role, tokens in LOOP_ROLE_RULES:
        if any(token in name for token in tokens):
            return role
    return "Context"


def classify_path(path: Path) -> Classification:
    name = path.name
    relative_path = rel(path)
    suffix_debt = has_mechanical_suffix(path)

    if name in CANONICAL_ENTITY_FILES:
        category = "canonical_entity"
        reason = "final-architecture-tree-core-domain-owner"
        confidence = "high"
    elif any(pattern.search(name) for pattern in OBSOLETE_PATTERNS):
        category = "obsolete"
        reason = "product-doctrine-or-tail-gate-bucket"
        confidence = "medium"
    elif matches_any(name, UI_MODEL_TOKENS):
        category = "ui_model"
        reason = "surface-or-screen-state-marker"
        confidence = "medium"
    elif matches_any(name, PROJECTION_TOKENS):
        category = "projection_dto"
        reason = "projection-or-read-model-marker"
        confidence = "medium"
    elif matches_any(name, EVENT_TOKENS):
        category = "event_payload"
        reason = "event-proof-receipt-history-marker"
        confidence = "medium"
    elif matches_any(name, COMMAND_TOKENS):
        category = "command_payload"
        reason = "command-operation-action-route-marker"
        confidence = "medium"
    elif matches_any(name, ADAPTER_TOKENS):
        category = "adapter_dto"
        reason = "boundary-source-pack-or-interoperability-marker"
        confidence = "medium"
    else:
        category = "value_object"
        reason = "domain-value-default-no-special-marker"
        confidence = "low"

    if suffix_debt:
        migration_action = "rename-mechanical-suffix-to-semantic-owner"
        if category == "obsolete":
            migration_action = "split-rename-or-delete-obsolete-bucket"
    elif category == "canonical_entity":
        migration_action = "keep-in-core-domain"
    elif category == "ui_model":
        migration_action = "move-out-of-core-domain-to-surface-quality-or-projection-owner"
    elif category == "obsolete":
        migration_action = "split-rename-or-delete-before-amb-1676-green"
    elif category == "projection_dto":
        migration_action = "move-to-projection-or-feature-local-projection-when-touched"
    elif category == "adapter_dto":
        migration_action = "move-to-boundary-sourceatlas-externalwrites-or-relevant-adapter-owner-when-touched"
    else:
        migration_action = "review-for-semantic-file-name-or-keep-as-domain-value"

    return Classification(
        path=relative_path,
        category=category,
        loopRole=loop_role_for(name),
        migrationAction=migration_action,
        reason=reason,
        confidence=confidence,
    )


def domain_swift_files(root: Path = DOMAIN_ROOT) -> list[Path]:
    if not root.exists():
        return []
    return sorted(path for path in root.rglob("*.swift") if path.is_file())


def screen_contract_owner_status() -> dict[str, object]:
    old_domain_files = sorted(rel(path) for path in DOMAIN_ROOT.glob("ScreenContractModels*.swift"))
    quality_files = sorted(rel(path) for path in QUALITY_SCREEN_CONTRACT_ROOT.glob("ScreenContract*.swift"))
    return {
        "oldDomainFiles": old_domain_files,
        "qualityFiles": quality_files,
        "passed": not old_domain_files and len(quality_files) == 5,
    }


def build_report() -> dict[str, object]:
    entries = [classify_path(path) for path in domain_swift_files()]
    categories = Counter(entry.category for entry in entries)
    loop_roles = Counter(entry.loopRole for entry in entries)
    migration_actions = Counter(entry.migrationAction for entry in entries)
    unallowed = sorted({entry.category for entry in entries if entry.category not in ALLOWED_CATEGORIES})
    fallback_entries = [entry.path for entry in entries if entry.reason == "domain-value-default-no-special-marker"]
    suffix_entries = [entry.path for entry in entries if "mechanical-suffix" in entry.migrationAction]
    ui_model_entries = [entry.path for entry in entries if entry.category == "ui_model"]
    obsolete_entries = [entry.path for entry in entries if entry.category == "obsolete"]
    screen_contract_status = screen_contract_owner_status()

    return {
        "schema": "ambitions.domain-object-classification.v1",
        "issue": "AMB-1676",
        "sourceRoot": rel(DOMAIN_ROOT),
        "allowedCategories": list(ALLOWED_CATEGORIES),
        "status": "passed" if not unallowed and screen_contract_status["passed"] else "failed",
        "summary": {
            "totalDomainSwiftFiles": len(entries),
            "categoryCounts": dict(sorted(categories.items())),
            "loopRoleCounts": dict(sorted(loop_roles.items())),
            "migrationActionCounts": dict(sorted(migration_actions.items())),
            "mechanicalSuffixDebtCount": len(suffix_entries),
            "uiModelDebtCount": len(ui_model_entries),
            "obsoleteBucketDebtCount": len(obsolete_entries),
            "lowConfidenceDefaultCount": len(fallback_entries),
        },
        "screenContractOwnerStatus": screen_contract_status,
        "debt": {
            "mechanicalSuffixFiles": suffix_entries,
            "uiModelFilesStillInDomain": ui_model_entries,
            "obsoleteBucketFiles": obsolete_entries,
            "lowConfidenceDefaultFiles": fallback_entries,
        },
        "entries": [asdict(entry) for entry in entries],
    }


def markdown_for(report: dict[str, object]) -> str:
    summary = report["summary"]
    assert isinstance(summary, dict)
    lines = [
        "# AMB-1676 Domain Object Classification",
        "",
        "Status: executable classification inventory, not AMB-1676 Green.",
        "",
        "This artifact tags every current `Native/Ambitions/Core/Domain` Swift file with the AMB-1676 category set. It does not close the remaining split/rename/delete work.",
        "",
        "## Summary",
        "",
        f"- Total Core/Domain Swift files: {summary['totalDomainSwiftFiles']}",
        f"- Mechanical suffix debt files: {summary['mechanicalSuffixDebtCount']}",
        f"- UI model debt files still in Domain: {summary['uiModelDebtCount']}",
        f"- Obsolete/product-doctrine bucket files: {summary['obsoleteBucketDebtCount']}",
        f"- Low-confidence default classifications: {summary['lowConfidenceDefaultCount']}",
        "",
        "## Category Counts",
        "",
        "| category | count |",
        "|---|---:|",
    ]
    for category, count in summary["categoryCounts"].items():
        lines.append(f"| `{category}` | {count} |")

    lines.extend([
        "",
        "## Entries",
        "",
        "| path | category | loop role | migration action | reason | confidence |",
        "|---|---|---|---|---|---|",
    ])
    for entry in report["entries"]:
        lines.append(
            "| `{path}` | `{category}` | {loopRole} | `{migrationAction}` | {reason} | {confidence} |".format(
                **entry
            )
        )
    lines.append("")
    return "\n".join(lines)


def write_artifacts(report: dict[str, object]) -> None:
    ARTIFACT_JSON.parent.mkdir(parents=True, exist_ok=True)
    ARTIFACT_JSON.write_text(json.dumps(report, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    ARTIFACT_MD.write_text(markdown_for(report), encoding="utf-8")


def self_test() -> int:
    assert classify_path(DOMAIN_ROOT / "Step.swift").category == "canonical_entity"
    assert classify_path(DOMAIN_ROOT / "ScreenContractModels.swift").category == "ui_model"
    assert classify_path(DOMAIN_ROOT / "AmbitionsOSExperienceModels.swift").category == "obsolete"
    assert classify_path(DOMAIN_ROOT / "CaptureModels+03-CaptureRoute.swift").migrationAction == "rename-mechanical-suffix-to-semantic-owner"
    assert classify_path(DOMAIN_ROOT / "AmbitionGraphProjectionStore.swift").category == "projection_dto"
    assert classify_path(DOMAIN_ROOT / "LifeKnowledgeOperationModels.swift").category == "command_payload"
    assert loop_role_for("LearningAnticipationModels.swift") == "Learning"
    assert set(ALLOWED_CATEGORIES) == {
        "canonical_entity",
        "value_object",
        "command_payload",
        "event_payload",
        "projection_dto",
        "ui_model",
        "adapter_dto",
        "obsolete",
    }
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--write", action="store_true", help="Write docs/audits/domain-object-classification artifacts.")
    parser.add_argument("--markdown", action="store_true", help="Print Markdown instead of JSON.")
    parser.add_argument("--self-test", action="store_true", help="Run script self-tests.")
    args = parser.parse_args()

    if args.self_test:
        return self_test()

    report = build_report()
    if args.write:
        write_artifacts(report)

    if args.markdown:
        sys.stdout.write(markdown_for(report))
    else:
        sys.stdout.write(json.dumps(report, indent=2, sort_keys=True) + "\n")

    return 0 if report["status"] == "passed" else 1


if __name__ == "__main__":
    raise SystemExit(main())
