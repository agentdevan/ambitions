#!/usr/bin/env python3
from __future__ import annotations

from collections import Counter, defaultdict
from pathlib import Path

from visual_final_form_common import (
    CONTRACTS_ROOT,
    DESIGN_TOKENS_ROOT,
    FINAL_BATCH_ID,
    FINAL_PROMPT,
    LOCK_PREP_BATCH_ID,
    LOCK_PREP_PROMPT,
    PROMPTS_ROOT,
    REPORT_DIR,
    ROOT,
    SWIFT_THEME_ROOT,
    TRACE_ROOT,
    load_json,
    load_token_files,
    p0_entries,
    recipe_file_text,
    surface_bible_path,
    surface_identity,
    surface_recipe_path,
    token_entry,
    token_primitive_or_contract,
    token_recipe_mapping,
    token_swift_output,
    visual_item_registry,
    write_json,
    write_json_like_yaml,
    has_any,
)


REPORT_JSON = REPORT_DIR / "visual-no-orphan-graph.json"
DOC_PATH = TRACE_ROOT / "VISUAL_NO_ORPHAN_GRAPH.yaml"


def node(node_id: str, node_type: str, classification: str, title: str, evidence: list[str] | None = None) -> dict[str, object]:
    return {
        "id": node_id,
        "type": node_type,
        "classification": classification,
        "title": title,
        "evidence": evidence or [],
    }


def edge(source: str, relation: str, target: str, note: str = "") -> dict[str, str]:
    return {"from": source, "relation": relation, "to": target, "note": note}


def main() -> int:
    nodes: list[dict[str, object]] = []
    edges: list[dict[str, str]] = []
    node_index: dict[str, dict[str, object]] = {}

    def add_node(node_id: str, node_type: str, classification: str, title: str, evidence: list[str] | None = None) -> None:
        if node_id in node_index:
            return
        payload = node(node_id, node_type, classification, title, evidence)
        node_index[node_id] = payload
        nodes.append(payload)

    def add_edge(source: str, relation: str, target: str, note: str = "") -> None:
        edges.append(edge(source, relation, target, note))

    # Truth index nodes.
    truth_docs = [
        "docs/truth/README.md",
        "docs/truth/PRODUCT_DESIGN_TRUTH.md",
        "docs/truth/PRODUCT_MOAT_TRUTH.md",
        "docs/truth/IMPLEMENTATION_TRUTH.md",
        "docs/truth/RELEASE_TRUTH.md",
        "docs/truth/CODEX_PROCESS_TRUTH.md",
        "docs/truth/HISTORICAL_POLICY.md",
    ]
    for path in truth_docs:
        node_id = f"truth:{path}"
        add_node(node_id, "truth_doc", "active_authority", path, [path])
    for path in truth_docs[1:]:
        add_edge("truth:docs/truth/README.md", "governs", f"truth:{path}")

    add_node("prompt:current_final_form", "batch_prompt", "report_only", str(FINAL_PROMPT.relative_to(ROOT)), [str(FINAL_PROMPT.relative_to(ROOT))])
    add_node("prompt:lock_prep_03", "batch_prompt", "historical", str(LOCK_PREP_PROMPT.relative_to(ROOT)), [str(LOCK_PREP_PROMPT.relative_to(ROOT))])
    add_edge("prompt:lock_prep_03", "superseded_by", "prompt:current_final_form", "final form replaces lock prep 03")

    # Visual item registry nodes.
    for item in visual_item_registry():
        visual_id = str(item.get("visual_id", item.get("name", "unknown")))
        node_id = f"visual_item:{visual_id}"
        classification = "active_authority" if str(item.get("canon_status", "")).startswith("intended") else "supporting_authority"
        add_node(node_id, "visual_item", classification, str(item.get("name", visual_id)), [str(item.get("recipe_file", ""))])
        add_edge(node_id, "depends_on", "truth:docs/truth/PRODUCT_DESIGN_TRUTH.md")
        add_edge(node_id, "depends_on", "truth:docs/truth/IMPLEMENTATION_TRUTH.md")
        recipe_path = str(item.get("recipe_file", ""))
        if recipe_path:
            recipe_node = f"recipe:{recipe_path}"
            add_node(recipe_node, "recipe", "active_authority", recipe_path, [recipe_path])
            add_edge(node_id, "has_recipe", recipe_node)
        for source_truth in item.get("source_truth", []):
            truth_node = f"truth:{source_truth}"
            add_node(truth_node, "truth_doc", "active_authority" if "docs/truth/" in source_truth else "supporting_authority", source_truth, [source_truth])
            add_edge(node_id, "depends_on", truth_node)
        for batch_prompt in item.get("planned_batch_sources", []):
            prompt_node = f"prompt:{batch_prompt}"
            add_node(prompt_node, "batch_prompt", "report_only", batch_prompt, [batch_prompt])
            add_edge(node_id, "planned_by_batch", prompt_node)

    # Priority surfaces and source candidates.
    for entry in p0_entries():
        sid = str(entry.get("surface_id"))
        surface_node = f"surface:{sid}"
        recipe_path = str(entry.get("recipe_path", ""))
        add_node(surface_node, "surface", "active_authority", str(entry.get("surface_name", sid)), [recipe_path])
        if recipe_path:
            recipe_node = f"recipe:{recipe_path}"
            add_node(recipe_node, "recipe", "active_authority", recipe_path, [recipe_path])
            add_edge(surface_node, "has_recipe", recipe_node)
        bible = surface_bible_path(entry)
        if bible and bible.exists():
            bible_node = f"bible:{bible.relative_to(ROOT)}"
            add_node(bible_node, "surface_bible", "supporting_authority", str(bible.relative_to(ROOT)), [str(bible.relative_to(ROOT))])
            add_edge(surface_node, "depends_on", bible_node)
        for source_truth in [
            "docs/truth/PRODUCT_DESIGN_TRUTH.md",
            "docs/truth/IMPLEMENTATION_TRUTH.md",
            "docs/truth/RELEASE_TRUTH.md",
        ]:
            add_edge(surface_node, "depends_on", f"truth:{source_truth}")
        for batch_prompt in entry.get("planned_batch_sources", []):
            prompt_node = f"prompt:{batch_prompt}"
            add_node(prompt_node, "batch_prompt", "report_only", batch_prompt, [batch_prompt])
            add_edge(surface_node, "planned_by_batch", prompt_node)

    # Contract and primitive nodes needed by the token layer.
    contract_paths = [
        "docs/canon/frontend/contracts/TRUST_SEAM_CONTRACT.md",
        "docs/canon/frontend/contracts/PROOF_CHIP_CONTRACT.md",
        "docs/canon/frontend/contracts/SOURCE_FRESHNESS_BADGE_CONTRACT.md",
        "docs/canon/frontend/contracts/RECEIPT_CONTRACT.md",
        "docs/canon/frontend/contracts/PRIMARY_CTA_CONTRACT.md",
        "docs/canon/frontend/contracts/DISCLOSURE_ROW_CONTRACT.md",
        "docs/canon/frontend/contracts/REDUCE_MOTION_CONTRACT.md",
        "docs/canon/frontend/contracts/DYNAMIC_TYPE_CONTRACT.md",
        "docs/canon/frontend/contracts/VOICEOVER_ORDER_CONTRACT.md",
        "docs/canon/frontend/contracts/REDUCE_TRANSPARENCY_CONTRACT.md",
        "docs/canon/frontend/contracts/DIFFERENTIATE_WITHOUT_COLOR_CONTRACT.md",
    ]
    for path in contract_paths:
        contract_node = f"contract:{path}"
        add_node(contract_node, "contract", "active_authority", path, [path])
        add_edge("truth:docs/truth/PRODUCT_DESIGN_TRUTH.md", "governs", contract_node)
        add_edge("truth:docs/truth/IMPLEMENTATION_TRUTH.md", "governs", contract_node)

    primitive_paths = [
        "docs/canon/frontend/primitives/COLOR_AND_STATE_TOKENS.md",
        "docs/canon/frontend/primitives/PRESSURE_AND_CAPACITY_PRIMITIVES.md",
        "docs/canon/frontend/primitives/PROTECTED_TIME_PRIMITIVES.md",
        "docs/canon/frontend/primitives/CTA_SYSTEM.md",
        "docs/canon/frontend/primitives/WRAPPERS_AND_CONTAINERS.md",
        "docs/canon/frontend/primitives/PROOF_PRIMITIVES.md",
        "docs/canon/frontend/primitives/DYNAMIC_TYPE_COLLAPSE_PRIMITIVES.md",
        "docs/canon/frontend/primitives/VOICEOVER_ORDER_PRIMITIVES.md",
        "docs/canon/frontend/primitives/BADGES_MARKERS_AND_STATE_GLYPHS.md",
        "docs/canon/frontend/primitives/TRANSACTION_PRIMITIVES.md",
        "docs/canon/frontend/primitives/ADHD_DENSITY_PRIMITIVES.md",
    ]
    for path in primitive_paths:
        primitive_node = f"primitive:{path}"
        add_node(primitive_node, "primitive", "active_authority", path, [path])
        add_edge("truth:docs/truth/PRODUCT_DESIGN_TRUTH.md", "governs", primitive_node)

    behavior_paths = [
        "docs/canon/frontend/behavior/MOTION_AND_HAPTICS.md",
        "docs/canon/frontend/behavior/REDUCE_MOTION.md",
    ]
    for path in behavior_paths:
        behavior_node = f"behavior:{path}"
        add_node(behavior_node, "behavior", "active_authority", path, [path])
        add_edge("truth:docs/truth/PRODUCT_DESIGN_TRUTH.md", "governs", behavior_node)

    # Token nodes and generated outputs.
    for item in load_token_files():
        entry = token_entry(item)
        token_id = f"token:{entry['category']}/{entry['token_name']}"
        add_node(token_id, "token", "active_authority", entry["token_name"], [entry["generation_source"]])
        token_file = f"token_file:{entry['generation_source']}"
        add_node(token_file, "token_file", "generated_output", entry["generation_source"], [entry["generation_source"]])
        add_edge(token_id, "generated_from", token_file)
        swift_output = f"swift:{token_swift_output(entry['category'])}"
        add_node(swift_output, "generated_swift", "generated_output", token_swift_output(entry["category"]), [token_swift_output(entry["category"])])
        add_edge(token_id, "generated_from", swift_output)
        primitive = entry["mapped_primitive_or_contract"]
        if primitive:
            primitive_node = ("contract:" if "contracts/" in primitive else "primitive:") + primitive
            add_node(
                primitive_node,
                "support_doc",
                "supporting_authority" if "contracts/" in primitive else "active_authority",
                primitive,
                [primitive],
            )
            add_edge(token_id, "uses_contract", primitive_node)
        for recipe_id in entry["mapped_recipe_ids"]:
            recipe_node = f"recipe:docs/canon/frontend/recipes/{recipe_id}.md"
            add_node(recipe_node, "recipe", "active_authority", recipe_id, [recipe_id])
            add_edge(token_id, "uses_token", recipe_node)
        for surface_id in entry["mapped_surface_ids"]:
            surface_node = f"surface:{surface_id}"
            add_node(surface_node, "surface", "active_authority", surface_id, [surface_id])
            add_edge(token_id, "uses_token", surface_node)

    # Existing reports and validator scripts that form the current control plane.
    report_paths = [
        "build/reports/visual-100-proof-dashboard.json",
        "build/reports/visual-100-proof-dashboard.md",
        "build/reports/design-system-15-systems-dashboard.json",
        "build/reports/design-system-15-systems-dashboard.md",
        "build/reports/visual-design-authority-lock-prep-03-install.md",
        "build/reports/visual-encyclopedia-100-final-proof-authority-04.md",
        "build/reports/visual-encyclopedia-dashboard.json",
        "build/reports/visual-encyclopedia-dashboard.md",
        "build/reports/visual-no-orphan-graph.json",
        "build/reports/surface-scenario-coverage.json",
        "build/reports/native-iphone-interaction-grammar.json",
        "build/reports/design-token-completeness.json",
        "build/reports/authority-supersession.json",
        "build/reports/faang-red-team-review.json",
        "build/reports/visual-design-authority-final-form-04.md",
    ]
    for path in report_paths:
        add_node(f"report:{path}", "report", "report_only", path, [path])
    for script in [
        "scripts/ambitions-visual-dashboard.py",
        "scripts/ambitions-visual-100-proof-dashboard.py",
        "scripts/ambitions-design-system-dashboard.py",
        "scripts/ambitions-visual-no-orphan-graph-check.py",
        "scripts/ambitions-surface-scenario-coverage-check.py",
        "scripts/ambitions-native-iphone-interaction-grammar-check.py",
        "scripts/ambitions-design-token-completeness-check.py",
        "scripts/ambitions-authority-supersession-check.py",
        "scripts/ambitions-faang-red-team-review-check.py",
    ]:
        add_node(f"script:{script}", "validator", "report_only", script, [script])

    add_edge("report:build/reports/visual-100-proof-dashboard.json", "generated_from", "script:scripts/ambitions-visual-100-proof-dashboard.py")
    add_edge("report:build/reports/design-system-15-systems-dashboard.json", "generated_from", "script:scripts/ambitions-design-system-dashboard.py")
    add_edge("report:build/reports/visual-100-proof-dashboard.md", "generated_from", "script:scripts/ambitions-visual-100-proof-dashboard.py")
    add_edge("report:build/reports/design-system-15-systems-dashboard.md", "generated_from", "script:scripts/ambitions-design-system-dashboard.py")
    add_edge("report:build/reports/visual-encyclopedia-dashboard.json", "generated_from", "script:scripts/ambitions-visual-dashboard.py")
    add_edge("report:build/reports/visual-encyclopedia-dashboard.md", "generated_from", "script:scripts/ambitions-visual-dashboard.py")
    add_edge("report:build/reports/visual-encyclopedia-100-final-proof-authority-04.md", "generated_from", "script:scripts/ambitions-visual-100-proof-dashboard.py")
    add_edge("report:build/reports/visual-design-authority-lock-prep-03-install.md", "generated_from", "prompt:lock_prep_03")
    add_edge("report:build/reports/visual-no-orphan-graph.json", "generated_from", "script:scripts/ambitions-visual-no-orphan-graph-check.py")
    add_edge("report:build/reports/surface-scenario-coverage.json", "generated_from", "script:scripts/ambitions-surface-scenario-coverage-check.py")
    add_edge("report:build/reports/native-iphone-interaction-grammar.json", "generated_from", "script:scripts/ambitions-native-iphone-interaction-grammar-check.py")
    add_edge("report:build/reports/design-token-completeness.json", "generated_from", "script:scripts/ambitions-design-token-completeness-check.py")
    add_edge("report:build/reports/authority-supersession.json", "generated_from", "script:scripts/ambitions-authority-supersession-check.py")
    add_edge("report:build/reports/faang-red-team-review.json", "generated_from", "script:scripts/ambitions-faang-red-team-review-check.py")
    add_edge("report:build/reports/visual-design-authority-final-form-04.md", "generated_from", "script:scripts/ambitions-faang-red-team-review-check.py")

    # Makefile and top-level target nodes.
    add_node("target:visual-design-authority-all", "make_target", "report_only", "visual-design-authority-all", ["Makefile"])
    add_node("target:visual-design-final-form-all", "make_target", "report_only", "visual-design-final-form-all", ["Makefile"])
    add_edge("target:visual-design-final-form-all", "depends_on", "prompt:current_final_form")
    add_edge("target:visual-design-final-form-all", "depends_on", "target:visual-design-authority-all")
    add_edge("target:visual-design-final-form-all", "generated_from", "script:scripts/ambitions-faang-red-team-review-check.py")

    incident_counts: Counter[str] = Counter()
    for item in edges:
        incident_counts[item["from"]] += 1
        incident_counts[item["to"]] += 1

    active_orphans = [
        item["id"]
        for item in nodes
        if item["classification"] in {"active_authority", "supporting_authority", "generated_output", "report_only"}
        and incident_counts[item["id"]] == 0
    ]

    status = "green" if not active_orphans else "red"
    payload = {
        "batch": FINAL_BATCH_ID,
        "generated_from_batch": FINAL_BATCH_ID,
        "node_count": len(nodes),
        "edge_count": len(edges),
        "active_orphans": active_orphans,
        "status": status,
        "nodes": nodes,
        "edges": edges,
    }
    write_json(REPORT_JSON, payload)
    write_json_like_yaml(DOC_PATH, payload)
    print("PASS" if status == "green" else "FAIL")
    return 0 if status == "green" else 1


if __name__ == "__main__":
    raise SystemExit(main())
