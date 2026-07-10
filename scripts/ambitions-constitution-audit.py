#!/usr/bin/env python3
"""Fail-closed Ambitions constitutional registry audit."""

from __future__ import annotations
import json
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
]


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
    deps = {x["id"]: set(x["dependencies"]) for x in opportunities}
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
        if not (C / name).exists():
            raise AssertionError(f"missing required constitutional file: {C / name}")

    index = load_json(C / "opportunity-register.json")
    opportunities = []
    for part in index["parts"]:
        opportunities.extend(load_json(C / part)["opportunities"])

    ids = unique([x["id"] for x in opportunities], "opportunity id")
    p0 = [x for x in opportunities if x["priority"] == "P0"]
    p1 = [x for x in opportunities if x["priority"] == "P1"]
    assert len(p0) == 18, f"expected 18 P0, found {len(p0)}"
    assert len(p1) == 100, f"expected 100 P1, found {len(p1)}"
    assert len(opportunities) == 118
    assert index["counts"] == {"P0": 18, "P1": 100, "total": 118}
    assert all(x.get("launch_required") is True for x in opportunities)
    assert index["launch_gate"]["accepted_yellow_allowed_at_final_launch"] is False

    required_fields = {
        "id", "title", "priority", "launch_required", "status", "wave",
        "primary_project", "dependencies", "law_prefixes", "source_owners",
        "required_proof", "claim_ceiling",
    }
    for op in opportunities:
        missing = required_fields - set(op)
        assert not missing, f"{op.get('id')} missing fields: {sorted(missing)}"
        assert op["source_owners"], f"{op['id']} has no source owners"
        assert op["law_prefixes"], f"{op['id']} has no law prefixes"
        assert op["required_proof"], f"{op['id']} has no proof obligations"
        for dep in op["dependencies"]:
            assert dep in ids, f"{op['id']} has unknown dependency {dep}"
    assert_acyclic(opportunities)

    laws = load_parts(C / "laws.json", "laws")
    unique([x["id"] for x in laws], "law id")
    source_map = load_parts(C / "law-source-map.json", "prefix_mappings")
    test_map = load_parts(C / "law-test-map.json", "prefix_mappings")
    source_prefixes = unique([x["law_prefix"] for x in source_map], "source-map prefix")
    test_prefixes = unique([x["law_prefix"] for x in test_map], "test-map prefix")
    used_prefixes = {p for op in opportunities for p in op["law_prefixes"]}
    assert used_prefixes <= source_prefixes, f"missing source prefixes: {sorted(used_prefixes - source_prefixes)}"
    assert used_prefixes <= test_prefixes, f"missing test prefixes: {sorted(used_prefixes - test_prefixes)}"
    assert all(x["canonical_source_owners"] for x in source_map)
    assert all(x["required_test_families"] for x in test_map)

    graph = load_json(C / "dependency-graph.json")
    assert graph["node_count"] == len(ids)
    assert set(graph["edge_source_parts"]) == set(index["parts"])
    for edge in graph["p0_edges"]:
        assert edge["from"] in ids and edge["to"] in ids

    scenarios = load_json(C / "scenarios.json")["scenarios"]
    unique([x["id"] for x in scenarios], "scenario id")
    assert len(scenarios) >= 10
    for scenario in scenarios:
        for op in scenario["opportunities"]:
            assert op in ids, f"{scenario['id']} references unknown opportunity {op}"

    classifications = load_json(C / "data-classification.json")["classifications"]
    unique([x["id"] for x in classifications], "data classification id")
    assert any(x["id"] == "DC-PRIVATE-GRAPH" for x in classifications)

    budgets = load_json(C / "performance-budgets.json")["budgets"]
    unique([x["id"] for x in budgets], "performance budget id")
    assert len(budgets) >= 9

    index_text = (C / "ENGINEERING_CONSTITUTION.md").read_text()
    for article in range(25, 44):
        assert f"Article {article}" in index_text, f"index missing Article {article}"
        matches = list((C / "articles").glob(f"ARTICLE_{article}_*.md"))
        assert len(matches) == 1, f"expected one file for Article {article}, found {len(matches)}"

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
