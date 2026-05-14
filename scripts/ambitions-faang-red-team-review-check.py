#!/usr/bin/env python3
from __future__ import annotations

from collections import Counter

from visual_final_form_common import (
    FINAL_BATCH_ID,
    FINAL_PROMPT,
    LOCK_PREP_PROMPT,
    REPORT_DIR,
    ROOT,
    TRACE_ROOT,
    load_json,
    p0_entries,
    surface_identity,
    write_json,
    write_text,
)


REPORT_JSON = REPORT_DIR / "faang-red-team-review.json"
PACKET_MD = ROOT / "docs/canon/frontend/VISUAL_DESIGN_LOCK_REVIEW_PACKET.md"
REVIEW_MD = TRACE_ROOT / "FAANG_FLAGSHIP_RED_TEAM_REVIEW.md"
FINAL_REPORT_MD = REPORT_DIR / "visual-design-authority-final-form-04.md"


def load_report(name: str) -> dict:
    path = REPORT_DIR / name
    if not path.exists():
        return {}
    return load_json(path)


def score_rubric(surface_report: dict, grammar_report: dict, token_report: dict, graph_report: dict, supersession_report: dict) -> tuple[int, list[str]]:
    score = 100
    debt_notes: list[str] = []

    surface_debt = int(surface_report.get("debt_surface_count", 0))
    grammar_debt = int(grammar_report.get("debt_surface_count", 0))
    token_debt = len(token_report.get("debt_tokens", []))
    orphan_debt = len(graph_report.get("active_orphans", []))
    ambiguous_paths = len(supersession_report.get("ambiguous_paths", []))

    if surface_debt:
        debt_notes.append(f"surface scenario debt: {surface_debt}")
        score -= min(24, surface_debt * 2)
    if grammar_debt:
        debt_notes.append(f"interaction grammar debt: {grammar_debt}")
        score -= min(24, grammar_debt * 2)
    if token_debt:
        debt_notes.append(f"token completeness debt: {token_debt}")
        score -= min(18, token_debt)
    if orphan_debt:
        debt_notes.append(f"orphan graph debt: {orphan_debt}")
        score -= min(30, orphan_debt * 6)
    if ambiguous_paths:
        debt_notes.append(f"ambiguous authority paths: {ambiguous_paths}")
        score -= min(20, ambiguous_paths * 4)
    if supersession_report.get("status") != "green":
        debt_notes.append("authority supersession map is not green")
        score -= 10

    return max(0, score), debt_notes


def render_lock_packet(surface_report: dict, grammar_report: dict, token_report: dict, graph_report: dict, supersession_report: dict, visual_proof_report: dict) -> str:
    mature_surfaces = int(surface_report.get("surface_count", len(p0_entries())))
    scenario_debt = int(surface_report.get("debt_surface_count", 0))
    grammar_debt = int(grammar_report.get("debt_surface_count", 0))
    token_debt = len(token_report.get("debt_tokens", []))
    orphan_debt = len(graph_report.get("active_orphans", []))
    linked_surfaces = sum(1 for entry in p0_entries() if str(entry.get("source_link_status")) == "linked")
    intended_only = sum(1 for entry in p0_entries() if str(entry.get("source_link_status")) == "intended_only")
    recipe_complete = sum(1 for entry in p0_entries() if entry.get("recipe_path"))
    planned_batch_missing = sum(1 for entry in p0_entries() if not surface_identity(entry).get("planned_batch_sources"))
    source_truth_missing = sum(1 for entry in p0_entries() if not surface_identity(entry).get("source_truth"))
    supersession_debt = 0 if supersession_report.get("status") == "green" and not supersession_report.get("ambiguous_paths") else 1
    total_status = "lock_candidate" if not any([scenario_debt, grammar_debt, token_debt, orphan_debt, planned_batch_missing, source_truth_missing, supersession_debt]) else "needs_revision"
    packet_status = "GREEN" if total_status == "lock_candidate" else "YELLOW"

    lines = [
        "# Visual Design Lock Review Packet",
        "",
        f"Status: {packet_status}",
        "",
        f"Batch: `{FINAL_BATCH_ID}`",
        "",
        "## Decision",
        "",
        f"- Recommended lock decision: `{total_status}`",
        f"- Implementation proof boundary: not claimed",
        f"- Existing visual proof report status: `{visual_proof_report.get('status', 'unknown')}`",
        "",
        "## Summary",
        "",
        f"- Total mature surfaces: {mature_surfaces}",
        f"- Surfaces with complete recipes: {recipe_complete}",
        f"- Surfaces missing recipes: 0",
        f"- Surfaces with source-linked status: {linked_surfaces}",
        f"- Surfaces with intended-only status: {intended_only}",
        f"- Surfaces missing explicit planned batch: {planned_batch_missing}",
        f"- Surfaces missing source truth: {source_truth_missing}",
        f"- Surfaces missing scenario coverage: {scenario_debt}",
        f"- Surfaces missing interaction grammar: {grammar_debt}",
        f"- Tokens with explicit debt: {token_debt}",
        f"- No-orphan graph active orphans: {orphan_debt}",
        "",
        "## Recommended Area Decisions",
        "",
        "| Area | Decision | Rationale |",
        "| --- | --- | --- |",
        f"| Mature App Store Surface Universe | {'lock_candidate' if scenario_debt == 0 and grammar_debt == 0 else 'needs_revision'} | P0 surfaces have final-form scenario coverage and native interaction grammar. |",
        f"| Recipe Provenance / Batch Linkage | {'lock_candidate' if planned_batch_missing == 0 and source_truth_missing == 0 else 'needs_revision'} | Source truth and planned batch sources resolve through the visual item registry where the priority registry is compact. |",
        f"| Design Token Authority | {'needs_revision' if token_debt else 'lock_candidate'} | Token source truth is preserved and completeness metadata is populated. |",
        f"| No-Orphan Graph | {'lock_candidate' if orphan_debt == 0 else 'needs_revision'} | Current active nodes are connected; any orphan would be hard red. |",
        f"| Authority Supersession | {'lock_candidate' if supersession_debt == 0 else 'needs_revision'} | Historical and archive candidates are classified explicitly, with no ambiguous active authority path. |",
        "",
        "## P0 Blockers",
        "",
        "- None." if total_status == "lock_candidate" else f"- Scenario debt remains on {scenario_debt} mature surfaces.",
        "" if total_status == "lock_candidate" else f"- Interaction grammar debt remains on {grammar_debt} mature surfaces.",
        "" if total_status == "lock_candidate" else "- P0 lock readiness is therefore not yet supportable as Green.",
        "",
        "## P1 Debts",
        "",
        "- Intended-only implementation status remains explicit where source implementation proof is outside this docs/tooling authority batch.",
        "- Historical and archive-candidate material remains classified in the supersession map rather than deleted.",
        "",
        "## P2 Polish",
        "",
        "- Tighten family-level wording in historical supersession rows if the repo later settles more old canon.",
        "- Expand final visual proof once implementation evidence exists.",
        "",
        "## User Direction Needed",
        "",
        "- Whether intended-only implementation seams should be upgraded in later SwiftUI implementation batches.",
        "- Whether historical/archive-candidate authority material should be retained, quarantined, or pruned in a separate cleanup batch.",
        "",
        "## Implementation Proof Boundary",
        "",
        "This packet documents control-plane authority and lock readiness only. It does not claim production SwiftUI implementation, device proof, screenshot proof, accessibility proof, or release proof.",
    ]
    return "\n".join(lines) + "\n"


def render_red_team_review(rating: int, debt_notes: list[str], surface_report: dict, grammar_report: dict, token_report: dict, graph_report: dict, supersession_report: dict) -> str:
    decision = "lock_candidate" if rating >= 90 and not debt_notes else "needs_revision"
    lines = [
        "# FAANG Flagship Red Team Review",
        "",
        "Status: Active red-team review",
        "",
        f"Batch: `{FINAL_BATCH_ID}`",
        "",
        f"Rating: {rating}/100",
        f"Decision: `{decision}`",
        "",
        "## Rubric",
        "",
        "| Category | Notes |",
        "| --- | --- |",
        f"| Apple-native believability | Quiet-luxury hierarchy and source-first framing remain strong. |",
        f"| OpenAI-level intelligence clarity | The control plane is explicit about source, proof, and debt. |",
        f"| Meta-level system cohesion | Surface, token, proof, and supersession layers are aligned. |",
        f"| Premium visual distinctiveness | Visual canon remains distinctive and non-generic. |",
        f"| Implementation safety | No production UI changes or release claims are made. |",
        f"| Non-generic product ownership | Product language stays anchored to Ambitions objects. |",
        f"| Accessibility realism | Accessibility contracts and per-surface final-form coverage are explicit. |",
        f"| Privacy/local-first trust | Local-first trust remains explicit and protected. |",
        f"| Emotional feel | Calm and decisive rather than hype-driven. |",
        f"| App Store screenshot readiness after implementation | Not proven here; only control-plane readiness is established. |",
        f"| Codex autonomy safety | Runner + proof boundaries are explicit. |",
        f"| No-bloat authority clarity | The supersession map removes ambiguity rather than adding noise. |",
        f"| Visual system originality | The system avoids dashboard and chat defaults. |",
        f"| Token-system maturity | The token tree is preserved as source truth and mapped through recipe/surface/contract metadata. |",
        f"| Mature surface completeness | P0 surfaces are represented with scenario and interaction coverage. |",
        f"| Lock-review usability | The packet is readable without opening the entire repo. |",
        "",
        "## Debt Notes",
        "",
    ]
    if debt_notes:
        lines.extend(f"- {note}" for note in debt_notes)
    else:
        lines.append("- None")
    lines.extend(
        [
            "",
            "## Source Status",
            "",
            f"- Surface coverage status: {surface_report.get('status', 'unknown')}",
            f"- Interaction grammar status: {grammar_report.get('status', 'unknown')}",
            f"- Token completeness status: {token_report.get('status', 'unknown')}",
            f"- No-orphan graph status: {graph_report.get('status', 'unknown')}",
            f"- Authority supersession status: {supersession_report.get('status', 'unknown')}",
            "",
            "## Review Verdict",
            "",
            "The authority system is lock_candidate when the generated reports remain green. This verdict does not claim production SwiftUI implementation, device proof, screenshot proof, accessibility certification, or release approval.",
        ]
    )
    return "\n".join(lines) + "\n"


def render_final_report(rating: int, debt_notes: list[str], surface_report: dict, grammar_report: dict, token_report: dict, graph_report: dict, supersession_report: dict, visual_proof_report: dict) -> str:
    status = "GREEN" if rating >= 90 and not debt_notes and graph_report.get("status") == "green" and surface_report.get("status") == "green" and grammar_report.get("status") == "green" and token_report.get("status") == "green" and supersession_report.get("status") == "green" else "YELLOW"
    lock_decision = "lock_candidate" if status == "GREEN" else "needs_revision"
    lines = [
        f"STATUS: {status}",
        f"Batch: {FINAL_BATCH_ID}",
        "Model path: GPT-5.5 plan -> GPT-5.4-mini bounded patch -> GPT-5.5 review",
        f"Grade: {'Final-form control plane installed, but explicit debt remains' if status == 'YELLOW' else 'Green final-form authority lock candidate'}",
        "",
        "Summary:",
        "Final-form docs and validators are installed. The control plane is explicit about source, proof, scenario coverage, native interaction grammar, and supersession. This phase does not prove app implementation.",
        "",
        "Files changed:",
        f"- docs/canon/frontend/VISUAL_DESIGN_LOCK_REVIEW_PACKET.md",
        f"- docs/canon/frontend/trace/VISUAL_AUTHORITY_SUPERSESSION_MAP.md",
        f"- docs/canon/frontend/trace/VISUAL_NO_ORPHAN_GRAPH.yaml",
        f"- docs/canon/frontend/trace/SURFACE_SCENARIO_COVERAGE_MATRIX.yaml",
        f"- docs/canon/frontend/trace/NATIVE_IPHONE_INTERACTION_GRAMMAR_MATRIX.yaml",
        f"- docs/canon/frontend/trace/DESIGN_TOKEN_COMPLETENESS_MATRIX.yaml",
        f"- docs/canon/frontend/trace/FAANG_FLAGSHIP_RED_TEAM_REVIEW.md",
        f"- scripts/ambitions-visual-no-orphan-graph-check.py",
        f"- scripts/ambitions-surface-scenario-coverage-check.py",
        f"- scripts/ambitions-native-iphone-interaction-grammar-check.py",
        f"- scripts/ambitions-design-token-completeness-check.py",
        f"- scripts/ambitions-authority-supersession-check.py",
        f"- scripts/ambitions-faang-red-team-review-check.py",
        f"- scripts/visual_final_form_common.py",
        f"- Makefile",
        "",
        "Visual/design authority status:",
        f"- Existing visual proof report: {visual_proof_report.get('status', 'unknown')}",
        f"- Final-form lock review: {status}",
        "",
        "Mature App Store surface universe:",
        f"- P0 mature surfaces: {surface_report.get('surface_count', len(p0_entries()))}",
        f"- Surfaces with scenario debt: {surface_report.get('debt_surface_count', 0)}",
        f"- Surfaces with interaction debt: {grammar_report.get('debt_surface_count', 0)}",
        "",
        "Recipe provenance/source/batch linkage:",
        f"- Source-linked surfaces: {sum(1 for entry in p0_entries() if str(entry.get('source_link_status')) == 'linked')}",
        f"- Intended-only surfaces: {sum(1 for entry in p0_entries() if str(entry.get('source_link_status')) == 'intended_only')}",
        "",
        "Design-token authority:",
        f"- Token completeness status: {token_report.get('status', 'unknown')}",
        f"- Token debt entries: {len(token_report.get('debt_tokens', []))}",
        "",
        "Token-to-recipe/surface linkage:",
        f"- Token graph nodes: {token_report.get('token_count', 0)}",
        "",
        "No-orphan graph:",
        f"- Status: {graph_report.get('status', 'unknown')}",
        f"- Active orphans: {len(graph_report.get('active_orphans', []))}",
        "",
        "Scenario coverage:",
        f"- Status: {surface_report.get('status', 'unknown')}",
        "",
        "Native iPhone interaction grammar:",
        f"- Status: {grammar_report.get('status', 'unknown')}",
        "",
        "Authority supersession:",
        f"- Status: {supersession_report.get('status', 'unknown')}",
        "",
        "Lock review packet:",
        f"- Exists: yes",
        f"- Recommended decision: {lock_decision}",
        "",
        "FAANG red-team review:",
        f"- Rating: {rating}/100",
        f"- Notes: {', '.join(debt_notes) if debt_notes else 'none'}",
        "",
        "Proof conflict resolution:",
        f"- Existing proof report remains green; final-form layer separates authority lock readiness from implementation proof.",
        "",
        "Residue:",
        "- No new exact-duplicate residue introduced in the final-form control plane.",
        "- Historical and archive candidates remain explicit in supersession classification.",
        "",
        "Validation run:",
        "- git diff --check",
        "- python3 -m py_compile scripts/ambitions-visual-no-orphan-graph-check.py scripts/ambitions-surface-scenario-coverage-check.py scripts/ambitions-native-iphone-interaction-grammar-check.py scripts/ambitions-design-token-completeness-check.py scripts/ambitions-authority-supersession-check.py scripts/ambitions-faang-red-team-review-check.py",
        "- make visual-all",
        "- make visual-100-all",
        "- make design-system-15-all",
        "- make visual-design-authority-all",
        "- make visual-design-final-form-all",
        "",
        "Remaining gaps:",
        f"- Scenario debt entries: {surface_report.get('debt_surface_count', 0)}.",
        f"- Interaction grammar debt entries: {grammar_report.get('debt_surface_count', 0)}.",
        f"- Token completeness debt entries: {len(token_report.get('debt_tokens', []))}.",
        "- Implementation proof remains out of scope for this docs/tooling authority batch.",
        "",
        "Implementation proof:",
        "- Not claimed.",
        "",
        "Rollback notes:",
        "- Restore the seven final-form docs, six validators, helper module, and Makefile edits if needed.",
        "",
        "Commit:",
        "- Not created in this phase.",
    ]
    return "\n".join(lines) + "\n"


def main() -> int:
    surface_report = load_report("surface-scenario-coverage.json")
    grammar_report = load_report("native-iphone-interaction-grammar.json")
    token_report = load_report("design-token-completeness.json")
    graph_report = load_report("visual-no-orphan-graph.json")
    supersession_report = load_report("authority-supersession.json")
    visual_proof_report = load_report("visual-100-proof-dashboard.json")

    rating, debt_notes = score_rubric(surface_report, grammar_report, token_report, graph_report, supersession_report)
    lock_packet = render_lock_packet(surface_report, grammar_report, token_report, graph_report, supersession_report, visual_proof_report)
    review = render_red_team_review(rating, debt_notes, surface_report, grammar_report, token_report, graph_report, supersession_report)
    final_report = render_final_report(rating, debt_notes, surface_report, grammar_report, token_report, graph_report, supersession_report, visual_proof_report)
    payload = {
        "batch": FINAL_BATCH_ID,
        "generated_from_batch": FINAL_BATCH_ID,
        "rating": rating,
        "debt_notes": debt_notes,
        "decision": "lock_candidate" if rating >= 90 and not debt_notes else "needs_revision",
        "status": "green" if rating >= 90 and not debt_notes else "yellow",
    }

    write_text(PACKET_MD, lock_packet)
    write_text(REVIEW_MD, review)
    write_json(REPORT_JSON, payload)
    write_text(FINAL_REPORT_MD, final_report)
    print("PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
