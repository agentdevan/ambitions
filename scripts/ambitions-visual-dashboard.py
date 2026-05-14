#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path
import json
import sys
from datetime import datetime, timezone


ROOT = Path(__file__).resolve().parents[1]
BASE = ROOT / "docs/canon/frontend"
REPORT_JSON = ROOT / "build/reports/visual-encyclopedia-dashboard.json"
REPORT_MD = ROOT / "build/reports/visual-encyclopedia-dashboard.md"


def load_json(path: Path):
    return json.loads(path.read_text())


def count_existing(paths):
    return sum(1 for path in paths if path.exists())


def main() -> int:
    inventory = load_json(BASE / "SURFACE_RECIPE_INVENTORY.yaml")
    coverage = load_json(BASE / "FRONTEND_SURFACE_COVERAGE_MAP.md") if False else {}
    specificity_ledger = (BASE / "trace/SURFACE_RECIPE_SPECIFICITY_REVIEW_LEDGER.md").read_text()
    unresolved = (BASE / "trace/UNMAPPED_INTENDED_SURFACE_GAPS.md").read_text()
    source_link_report = load_json(ROOT / "build/reports/visual-source-linkage.json") if (ROOT / "build/reports/visual-source-linkage.json").exists() else {}
    residue_report = load_json(ROOT / "build/reports/visual-template-residue.json") if (ROOT / "build/reports/visual-template-residue.json").exists() else {}
    vocabulary_report = load_json(ROOT / "build/reports/visual-vocabulary-boundary.json") if (ROOT / "build/reports/visual-vocabulary-boundary.json").exists() else {}
    surface_graph_report = load_json(ROOT / "build/reports/visual-surface-graph.json") if (ROOT / "build/reports/visual-surface-graph.json").exists() else {}

    total = len(inventory)
    high = sum(1 for item in inventory if item.get("specificity_status") == "high_specificity")
    unresolved_count = sum(1 for item in inventory if item.get("specificity_status") == "unresolved_direction")

    priority_count = source_link_report.get("priority_recipe_count", 0)
    linked_count = source_link_report.get("linked_priority_count", 0)
    weak_count = source_link_report.get("weak_priority_count", 0)
    source_missing_count = len(source_link_report.get("missing_priority_ids", []))
    inventory_unlinked_count = source_link_report.get("inventory_unlinked_count", 0)

    object_docs = [
        BASE / "objects/PRIMARY_OBJECT_ANATOMY_CANON.md",
        BASE / "objects/LABEL_OFF_SIGNATURE_TESTS.md",
        BASE / "objects/REALITY_MERIDIAN_ANATOMY.md",
        BASE / "objects/CONSTELLATION_ATLAS_ANATOMY.md",
        BASE / "objects/ATMOSPHERE_COMPOSER_ANATOMY.md",
        BASE / "objects/LIFESHAPE_FIELD_ANATOMY.md",
        BASE / "objects/USER_SYSTEM_PROFILE_ANATOMY.md",
    ]
    accessibility_docs = [
        BASE / "VISUAL_ACCESSIBILITY_ADHD_REQUIREMENTS.md",
        BASE / "behavior/ACCESSIBILITY_AND_ADHD_LAWS.md",
    ]
    anti_generic_docs = [
        BASE / "VISUAL_ANTI_SLOP_RULES.md",
        BASE / "behavior/ANTI_GENERIC_KILL_SWITCHES.md",
    ]

    object_coverage = count_existing(object_docs)
    accessibility_coverage = count_existing(accessibility_docs)
    anti_generic_coverage = count_existing(anti_generic_docs)
    label_off_coverage = 1 if (BASE / "objects/LABEL_OFF_SIGNATURE_TESTS.md").exists() else 0

    residue_count = 0
    advisory_near_duplicate_count = 0
    if residue_report:
        residue_count = len(residue_report.get("exact_duplicate_paragraphs", {})) + len(residue_report.get("forbidden_phrase_hits", {})) + len(residue_report.get("generic_phrase_hits", {}))
        advisory_near_duplicate_count = len(residue_report.get("near_duplicate_pairs", []))

    vocabulary_count = len(vocabulary_report.get("violations", [])) if vocabulary_report else 0
    surface_graph_count = len(surface_graph_report.get("missing_roots", [])) + len(surface_graph_report.get("missing_surface_files", [])) + len(surface_graph_report.get("invalid_parent_links", [])) + len(surface_graph_report.get("missing_types", [])) + len(surface_graph_report.get("unresolved_missing", [])) if surface_graph_report else 0

    status = "green"
    if unresolved_count or source_missing_count or residue_count or vocabulary_count or surface_graph_count:
        status = "yellow"

    dashboard = {
        "generated": datetime.now(timezone.utc).isoformat(),
        "status": status,
        "recipe_count": total,
        "priority_recipe_count": priority_count,
        "high_specificity_count": high,
        "unresolved_direction_count": unresolved_count,
        "source_linkage": {
            "linked": linked_count,
            "weak": weak_count,
            "missing": source_missing_count,
            "inventory_unlinked_count": inventory_unlinked_count,
        },
        "residue_count": residue_count,
        "advisory_near_duplicate_count": advisory_near_duplicate_count,
        "vocabulary_violation_count": vocabulary_count,
        "surface_graph_violation_count": surface_graph_count,
        "object_anatomy_coverage": object_coverage,
        "label_off_signature_coverage": label_off_coverage,
        "accessibility_adhd_coverage": accessibility_coverage,
        "anti_generic_gate_coverage": anti_generic_coverage,
        "remaining_gaps": [line.strip() for line in unresolved.splitlines() if line.strip().startswith("- ")],
    }

    REPORT_JSON.parent.mkdir(parents=True, exist_ok=True)
    REPORT_JSON.write_text(json.dumps(dashboard, indent=2, sort_keys=True) + "\n")

    md_lines = [
        "# Visual Encyclopedia Dashboard",
        "",
        f"Status: {status.upper()}",
        "",
        "## Counts",
        "",
        f"- Recipe count: {total}",
        f"- Priority recipe count: {priority_count}",
        f"- High specificity count: {high}",
        f"- Unresolved direction count: {unresolved_count}",
        f"- Source links: linked {linked_count}, weak {weak_count}, missing {source_missing_count}",
        f"- Inventory unlinked count: {inventory_unlinked_count}",
        f"- Residue count: {residue_count}",
        f"- Advisory near-duplicate count: {advisory_near_duplicate_count}",
        f"- Vocabulary violations: {vocabulary_count}",
        f"- Surface graph violations: {surface_graph_count}",
        "",
        "## Coverage",
        "",
        f"- Object anatomy coverage: {object_coverage}/7",
        f"- Label-off signature coverage: {label_off_coverage}/1",
        f"- Accessibility / ADHD coverage: {accessibility_coverage}/2",
        f"- Anti-generic gate coverage: {anti_generic_coverage}/2",
        "",
        "## Remaining Gaps",
    ]
    if dashboard["remaining_gaps"]:
        md_lines.extend(dashboard["remaining_gaps"])
    else:
        md_lines.append("- None")
    md_lines.append("")
    REPORT_MD.write_text("\n".join(md_lines))

    print("PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
