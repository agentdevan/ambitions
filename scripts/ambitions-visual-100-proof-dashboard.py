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
        "object_depth": object_depth,
        "recipe_contract": recipe_contract,
        "accessibility": accessibility,
        "anti_generic": anti_generic,
        "proof_source_receipt": proof_source_receipt,
        "transaction": transaction,
        "primitive_operationality": primitive,
        "prompt_authority": prompt,
        "status": "green" if gate.get("status") == "green" else "red",
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
        f"- False-green risks: {load_report('visual-100-false-green.json').get('risks', [])}",
        f"- Remaining red flags: {[] if dashboard['status'] == 'green' else ['see gate outputs']}",
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
        f"Files changed: {len(priority)} priority recipe records + control-plane docs/scripts\n"
        "Prompt authority changes: active successor declared in ledger\n"
        "Validators added: new visual-100 suite\n"
        "Validators upgraded: existing visual canon docs and primitive contracts\n"
        "Docs deepened: primary object anatomies, primitive contracts, recipe appendices\n"
        "P0 registry summary: P0 registry now explicit and visible\n"
        "P0 recipes upgraded: appendix applied to P0 recipe set\n"
        f"P0 recipes still failing: {'none' if dashboard['status'] == 'green' else 'see validator outputs'}\n"
        "P1/P2 gaps logged: visible in registry and source debt ledger\n"
        "Object anatomy scores: see object-depth report\n"
        "Destination scores: see scorecards\n"
        "Primitive operationality scores: see primitive report\n"
        "Source-link distribution: see source-debt report\n"
        "Intended-only debt: visible, not hidden\n"
        f"False Green risks closed: {'yes' if dashboard['status'] == 'green' else 'partially addressed, not fully closed'}\n"
        f"Red/yellow flags closed: {'yes' if dashboard['status'] == 'green' else 'prompt supersession and visibility work added'}\n"
        f"Red flags still open: {'none' if dashboard['status'] == 'green' else 'validator output remains red until all gates pass'}\n"
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
