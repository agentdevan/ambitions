#!/usr/bin/env python3
from __future__ import annotations

from collections import Counter

from ambitions_visual_100_common import BASE, load_json_like, load_priority_registry, write_json, REPORT_DIR


REPORT_JSON = REPORT_DIR / "visual-100-proof-dashboard.json"
REPORT_MD = REPORT_DIR / "visual-100-proof-dashboard.md"
FINAL_REPORT = REPORT_DIR / "visual-encyclopedia-100-final-proof-authority-04.md"


def load_report(name: str) -> dict:
    path = REPORT_DIR / name
    if not path.exists():
        return {}
    return load_json_like(path)


def main() -> int:
    registry = load_priority_registry()
    priority = registry.get("priority_recipes", [])
    counts = Counter(entry.get("tier") for entry in priority)
    source_debt = load_report("visual-100-source-debt.json")
    object_depth = load_report("visual-100-object-depth.json")
    recipe_contract = load_report("visual-100-recipe-contract.json")
    accessibility = load_report("visual-100-accessibility-adhd.json")
    anti_generic = load_report("visual-100-anti-generic.json")
    proof_source_receipt = load_report("visual-100-proof-source-receipt.json")
    transaction = load_report("visual-100-transaction.json")
    primitive = load_report("visual-100-primitive-operationality.json")
    prompt = load_report("visual-100-prompt-authority.json")
    gate = load_report("visual-100-gate.json")
    scorecard = load_report("visual-100-scorecard.json")
    native = load_report("visual-100-native-believability.json")
    local_first = load_report("visual-100-local-first-trust.json")
    no_false_momentum = load_report("visual-100-no-false-momentum.json")
    hidden_automation = load_report("visual-100-hidden-automation.json")
    label_off_pass = object_depth.get("label_off", {}).get("pass_count", 0)
    label_off_missing = object_depth.get("label_off", {}).get("missing", [])
    schema_missing = recipe_contract.get("missing_markers", [])
    schema_depth_failures = recipe_contract.get("depth_failures", [])
    final_eligibility = gate.get("status") == "green" and not source_debt.get("p0_hidden_intended_only")

    dashboard = {
        "Canon Content Status": gate.get("Canon Content Status", "red"),
        "Control-Plane Status": gate.get("Control-Plane Status", "red"),
        "Source-Linkage Status": gate.get("Source-Linkage Status", "red"),
        "Implementation Proof Status": "Not In Scope",
        "Release / Device Proof Status": "Not In Scope",
        "Accessibility Implementation Proof Status": "Not In Scope",
        "Prompt / Queue Authority Status": gate.get("Prompt / Queue Authority Status", "red"),
        "counts": {
        "P0": counts.get("P0", 0),
        "P1": counts.get("P1", 0),
        "P2": counts.get("P2", 0),
        },
        "source_link_distribution": source_debt.get("distribution", {}),
        "schema_pass_fail": {
            "recipe_contract_missing": len(schema_missing),
            "recipe_contract_depth_failures": len(schema_depth_failures),
            "object_depth_missing": len(object_depth.get("missing_markers", {})),
            "object_depth_duplicates": len(object_depth.get("near_duplicates", [])),
            "label_off_pass": label_off_pass,
            "label_off_missing": len(label_off_missing),
        },
        "object_depth": object_depth,
        "recipe_contract": recipe_contract,
        "accessibility": accessibility,
        "anti_generic": anti_generic,
        "proof_source_receipt": proof_source_receipt,
        "transaction": transaction,
        "primitive_operationality": primitive,
        "prompt_authority": prompt,
        "scorecard": scorecard,
        "warnings": {
            "vocabulary": load_report("visual-100-vocabulary-full-corpus.json").get("violations", []),
            "anti_generic": anti_generic.get("hits", {}),
            "native_believability": native.get("missing", []),
            "local_first_trust": local_first.get("missing", []),
            "no_false_momentum": no_false_momentum.get("hits", []),
            "hidden_automation": hidden_automation.get("hits", []),
        },
        "blocking_failures": gate.get("blocking_failures", []),
        "final_100_eligibility": final_eligibility and gate.get("status") == "green",
        "status": "green" if gate.get("status") == "green" and final_eligibility else "red",
    }
    write_json(REPORT_JSON, dashboard)

    summary_lines = [
        "# Visual 100 Proof Dashboard",
        "",
        f"- Canon Content Status: {dashboard['Canon Content Status']}",
        f"- Control-Plane Status: {dashboard['Control-Plane Status']}",
        f"- Source-Linkage Status: {dashboard['Source-Linkage Status']}",
        f"- Implementation Proof Status: Not In Scope",
        f"- Release / Device Proof Status: Not In Scope",
        f"- Accessibility Implementation Proof Status: Not In Scope",
        f"- Prompt / Queue Authority Status: {dashboard['Prompt / Queue Authority Status']}",
        f"- P0 count: {dashboard['counts']['P0']}",
        f"- P1 count: {dashboard['counts']['P1']}",
        f"- P2 count: {dashboard['counts']['P2']}",
        f"- Source-link distribution: {dashboard['source_link_distribution']}",
        f"- Intended-only debt visible: {source_debt.get('p0_visible_intended_only_count', 0)}",
        f"- Schema pass/fail: {dashboard['schema_pass_fail']}",
        f"- Vocabulary violations: {len(dashboard['warnings']['vocabulary'])}",
        f"- Native believability warnings: {len(dashboard['warnings']['native_believability'])}",
        f"- Local-first trust warnings: {len(dashboard['warnings']['local_first_trust'])}",
        f"- No false momentum warnings: {len(dashboard['warnings']['no_false_momentum'])}",
        f"- Hidden automation warnings: {len(dashboard['warnings']['hidden_automation'])}",
        f"- False-green risks: {load_report('visual-100-false-green.json').get('risks', [])}",
        f"- Remaining red flags: {dashboard['blocking_failures']}",
        f"- Final 100/100 eligibility: {dashboard['final_100_eligibility']}",
    ]

    REPORT_MD.write_text(
        "\n".join(summary_lines) + "\n",
        encoding="utf-8",
    )

    final_status = "GREEN" if dashboard["status"] == "green" else "RED"
    FINAL_REPORT.write_text(
        f"STATUS: {final_status}\n"
        "Batch: VISUAL-ENCYCLOPEDIA-100-FINAL-PROOF-AUTHORITY-04\n"
        "Bounded patch model: GPT-5.4-mini\n\n"
        f"Canon Content Status: {dashboard['Canon Content Status']}\n"
        f"Control-Plane Status: {dashboard['Control-Plane Status']}\n"
        f"Source-Linkage Status: {dashboard['Source-Linkage Status']}\n"
        "Implementation Proof Status: Not In Scope\n"
        "Release / Device Proof Status: Not In Scope\n"
        "Accessibility Implementation Proof Status: Not In Scope\n"
        f"Prompt / Queue Authority Status: {dashboard['Prompt / Queue Authority Status']}\n\n"
        "Summary:\n"
        "Files changed: control-plane docs/scripts, canon docs, and generated reports; no production UI source changed\n"
        "Prompt authority changes: active successor declared in ledger\n"
        "Validators added: new visual-100 suite\n"
        "Validators upgraded: existing visual canon docs and primitive contracts\n"
        "Docs deepened: primary object anatomies, primitive contracts, gate contracts, and partial recipe hardening\n"
        "P0 registry summary: P0 registry now explicit and visible\n"
        f"P0 recipes upgraded: {'all required P0 recipe schema work' if dashboard['status'] == 'green' else 'partial only; schema depth remains open'}\n"
        f"P0 recipes still failing: {'none' if dashboard['status'] == 'green' else 'recipe_schema_depth across the P0 recipe set'}\n"
        "P1/P2 gaps logged: visible in registry and source debt ledger\n"
        "Object anatomy scores: see object-depth report\n"
        "Destination scores: see scorecards\n"
        "Primitive operationality scores: see primitive report\n"
        "Source-link distribution: see source-debt report\n"
        "Intended-only debt: visible, not hidden\n"
        f"Schema pass/fail: {dashboard['schema_pass_fail']}\n"
        f"False Green risks closed: {'yes' if dashboard['status'] == 'green' else 'partially addressed, not fully closed'}\n"
        f"Red/yellow flags closed: {'yes' if dashboard['status'] == 'green' else 'prompt supersession, source debt visibility, and proof separation improvements added'}\n"
        f"Red flags still open: {dashboard['blocking_failures'] if dashboard['status'] != 'green' else 'none'}\n"
        f"Final 100/100 eligibility: {dashboard['final_100_eligibility']}\n"
        f"Validation run: {dashboard['status']}\n"
        "Reports: build/reports/visual-100-proof-dashboard.json and .md\n"
        "UI implementation changed: no\n"
        "Hosted CI activated: no\n"
        "Release/accessibility/App Store claims: not claimed\n"
        "Rollback notes: restore docs/canon/frontend, build/reports, Makefile, scripts/ambitions-visual-100-*.py\n"
        "Commit: not yet created\n",
        encoding="utf-8",
    )
    print("PASS" if dashboard["status"] == "green" else "FAIL")
    return 0 if dashboard["status"] == "green" else 1


if __name__ == "__main__":
    raise SystemExit(main())
