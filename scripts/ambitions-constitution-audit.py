#!/usr/bin/env python3
"""Fail-closed Ambitions constitutional registry audit."""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
C = ROOT / "docs" / "constitution"

REQUIRED = [
    "opportunity-register.json",
    "laws.json",
    "law-source-map.json",
    "law-test-map.json",
    "scenarios.json",
    "performance-budgets.json",
    "data-classification.json",
    "dependency-graph.json",
    "ENGINEERING_CONSTITUTION.md",
    "README.md",
    "PR_23_RUTHLESS_REVIEW.md",
]

DIMENSIONS = {
    "constitutional", "product", "architecture", "domain", "runtime",
    "persistence", "concurrency", "frontend", "accessibility",
    "privacy-security", "performance", "reliability", "integration",
    "qa", "visual", "release",
}

PROOFS = {
    "approved-design-spec", "current-source-readback", "automated-tests",
    "failure-injection", "performance-evidence", "security-privacy-review",
    "accessibility-evidence-when-applicable", "independent-review",
    "rollback-plan", "first-class-closeout",
}


def load_json(path: Path):
    if not path.exists():
        raise AssertionError(f"missing required constitutional file: {path}")
    return json.loads(path.read_text())


def load_parts(index_path: Path, key: str):
    index = load_json(index_path)
    items = []
    for part in index.get("parts", []):
        items.extend(load_json(index_path.parent / part)[key])
    expected = index.get("count")
    if expected is not None:
        assert len(items) == expected, f"{index_path.name} expected {expected}, found {len(items)}"
    return items


def unique(values, label):
    seen = set()
    for value in values:
        if value in seen:
            raise AssertionError(f"duplicate {label}: {value}")
        seen.add(value)
    return seen


def assert_acyclic(opportunities):
    deps = {item["id"]: set(item["dependencies"]) for item in opportunities}
    visiting, visited = set(), set()

    def visit(node):
        if node in visiting:
            raise AssertionError(f"dependency cycle at {node}")
        if node in visited:
            return
        visiting.add(node)
        for dep in deps[node]:
            visit(dep)
        visiting.remove(node)
        visited.add(node)

    for node in deps:
        visit(node)


def main() -> int:
    for name in REQUIRED:
        assert (C / name).exists(), f"missing required constitutional file: {C / name}"

    product = (ROOT / "docs" / "truth" / "PRODUCT_DESIGN_TRUTH.md").read_text()
    assert "## AUTH-005A — Normative engineering annex binding" in product, "parent Product Constitution does not bind the engineering annex"

    index = load_json(C / "opportunity-register.json")
    referenced_parts = {C / part for part in index["parts"]}
    actual_parts = set((C / "opportunities").glob("P*.json"))
    assert actual_parts == referenced_parts, (
        f"orphan/missing opportunity files extra={sorted(str(x.relative_to(C)) for x in actual_parts - referenced_parts)} "
        f"missing={sorted(str(x.relative_to(C)) for x in referenced_parts - actual_parts)}"
    )

    opportunities = []
    for part in index["parts"]:
        opportunities.extend(load_json(C / part)["opportunities"])

    ids = unique([item["id"] for item in opportunities], "opportunity id")
    p0 = [item for item in opportunities if item["priority"] == "P0"]
    p1 = [item for item in opportunities if item["priority"] == "P1"]
    assert len(p0) == 18, f"expected 18 P0, found {len(p0)}"
    assert len(p1) == 100, f"expected 100 P1, found {len(p1)}"
    assert len(opportunities) == 118
    assert index["counts"] == {"P0": 18, "P1": 100, "total": 118}
    assert all(item.get("launch_required") is True for item in opportunities)
    assert index["launch_gate"]["accepted_yellow_allowed_at_final_launch"] is False

    required_fields = {
        "id", "title", "priority", "launch_required", "status", "wave",
        "primary_project", "related_projects", "project_disposition",
        "coverage_status", "dependencies", "law_prefixes", "source_owners",
        "required_acceptance_dimensions", "required_proof", "claim_ceiling",
    }
    for item in opportunities:
        missing = required_fields - set(item)
        assert not missing, f"{item.get('id')} missing fields: {sorted(missing)}"
        assert item["source_owners"], f"{item['id']} has no source owners"
        assert item["law_prefixes"], f"{item['id']} has no law prefixes"
        assert set(item["required_acceptance_dimensions"]) == DIMENSIONS, f"{item['id']} lacks complete First-Class Green dimensions"
        assert PROOFS <= set(item["required_proof"]), f"{item['id']} lacks complete proof obligations"
        for dep in item["dependencies"]:
            assert dep in ids, f"{item['id']} has unknown dependency {dep}"
    assert_acyclic(opportunities)

    laws = load_parts(C / "laws.json", "laws")
    registry_law_ids = unique([item["id"] for item in laws], "law id")
    law_prefixes = {item["prefix"] for item in laws}

    source_map = load_parts(C / "law-source-map.json", "prefix_mappings")
    test_map = load_parts(C / "law-test-map.json", "prefix_mappings")
    source_prefixes = unique([item["law_prefix"] for item in source_map], "source-map prefix")
    test_prefixes = unique([item["law_prefix"] for item in test_map], "test-map prefix")
    used_prefixes = {prefix for item in opportunities for prefix in item["law_prefixes"]}
    assert used_prefixes <= source_prefixes, f"missing source prefixes: {sorted(used_prefixes - source_prefixes)}"
    assert used_prefixes <= test_prefixes, f"missing test prefixes: {sorted(used_prefixes - test_prefixes)}"
    assert law_prefixes <= source_prefixes, f"registered laws missing source mapping: {sorted(law_prefixes - source_prefixes)}"
    assert law_prefixes <= test_prefixes, f"registered laws missing test mapping: {sorted(law_prefixes - test_prefixes)}"
    assert all(item["canonical_source_owners"] for item in source_map)
    assert all(item["required_test_families"] for item in test_map)

    article_law_ids = set()
    for path in sorted((C / "articles").glob("ARTICLE_*.md")):
        article_law_ids.update(re.findall(r"^##\s+([A-Z][A-Z0-9-]+-\d{3})\b", path.read_text(), re.MULTILINE))
    parent_law_ids = set(re.findall(
        r"^##\s+([A-Z][A-Z0-9-]+-\d{3})\b",
        (ROOT / "docs" / "truth" / "PRODUCT_DESIGN_TRUTH.md").read_text(),
        re.MULTILINE,
    ))
    constitutional_law_ids = article_law_ids | parent_law_ids
    assert article_law_ids <= registry_law_ids, (
        f"Article 25–43 laws missing from registry: {sorted(article_law_ids - registry_law_ids)}"
    )
    assert registry_law_ids <= constitutional_law_ids, (
        f"law registry entries missing from parent or annex: {sorted(registry_law_ids - constitutional_law_ids)}"
    )

    graph = load_json(C / "dependency-graph.json")
    assert graph["node_count"] == len(ids)
    assert set(graph["edge_source_parts"]) == set(index["parts"])
    for edge in graph["p0_edges"]:
        assert edge["from"] in ids and edge["to"] in ids

    scenarios = load_json(C / "scenarios.json")["scenarios"]
    unique([item["id"] for item in scenarios], "scenario id")
    assert len(scenarios) >= 16
    scenario_ops = set()
    for scenario in scenarios:
        for op in scenario["opportunities"]:
            assert op in ids, f"{scenario['id']} references unknown opportunity {op}"
            scenario_ops.add(op)
    p0_ids = {item["id"] for item in p0}
    assert p0_ids <= scenario_ops, f"P0 domains missing scenario coverage: {sorted(p0_ids - scenario_ops)}"

    classifications = load_json(C / "data-classification.json")["classifications"]
    unique([item["id"] for item in classifications], "data classification id")
    assert any(item["id"] == "DC-PRIVATE-GRAPH" for item in classifications)

    budgets = load_json(C / "performance-budgets.json")["budgets"]
    unique([item["id"] for item in budgets], "performance budget id")
    assert len(budgets) >= 9

    engineering_index = (C / "ENGINEERING_CONSTITUTION.md").read_text()
    for article in range(25, 44):
        assert f"Article {article}" in engineering_index, f"index missing Article {article}"
        matches = list((C / "articles").glob(f"ARTICLE_{article}_*.md"))
        assert len(matches) == 1, f"expected one Article {article} file, found {len(matches)}"

    print("GREEN ambitions constitutional registry audit")
    print(f"opportunities={len(opportunities)} p0={len(p0)} p1={len(p1)}")
    print(f"laws={len(laws)} source_maps={len(source_map)} test_maps={len(test_map)}")
    print(f"scenarios={len(scenarios)} budgets={len(budgets)} classifications={len(classifications)}")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (AssertionError, KeyError, json.JSONDecodeError) as exc:
        print(f"RED {exc}", file=sys.stderr)
        raise SystemExit(1)
