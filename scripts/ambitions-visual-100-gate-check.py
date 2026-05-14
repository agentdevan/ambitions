#!/usr/bin/env python3
from __future__ import annotations

from ambitions_visual_100_common import load_json_like, write_json, REPORT_DIR


REPORT_JSON = REPORT_DIR / "visual-100-gate.json"
REPORT_MD = REPORT_DIR / "visual-100-gate.md"


def status_from_report(path, red_ok=False):
    if not path.exists():
        return "red"
    data = load_json_like(path)
    return data.get("status", "red")


def dashboard_separation_status() -> str:
    path = REPORT_DIR / "visual-100-proof-dashboard.json"
    if not path.exists():
        return "red"
    data = load_json_like(path)
    required_fields = [
        "Canon Content Status",
        "Control-Plane Status",
        "Source-Linkage Status",
        "Implementation Proof Status",
        "Release / Device Proof Status",
        "Accessibility Implementation Proof Status",
        "Prompt / Queue Authority Status",
        "final_100_eligibility",
    ]
    if not all(field in data for field in required_fields):
        return "red"
    return "green"


def main() -> int:
    checks = {
        "priority_registry": status_from_report(REPORT_DIR / "visual-100-priority-registry.json"),
        "recipe_contract": status_from_report(REPORT_DIR / "visual-100-recipe-contract.json"),
        "object_depth": status_from_report(REPORT_DIR / "visual-100-object-depth.json"),
        "object_uniqueness": status_from_report(REPORT_DIR / "visual-100-object-depth.json"),
        "label_off_recognizability": status_from_report(REPORT_DIR / "visual-100-object-depth.json"),
        "recipe_schema_depth": status_from_report(REPORT_DIR / "visual-100-recipe-contract.json"),
        "source_debt": status_from_report(REPORT_DIR / "visual-100-source-debt.json"),
        "intended_only_debt_visibility": status_from_report(REPORT_DIR / "visual-100-source-debt.json"),
        "vocabulary": status_from_report(REPORT_DIR / "visual-100-vocabulary-full-corpus.json"),
        "microcopy_boundaries": status_from_report(REPORT_DIR / "visual-100-vocabulary-full-corpus.json"),
        "anti_generic": status_from_report(REPORT_DIR / "visual-100-anti-generic.json"),
        "accessibility": status_from_report(REPORT_DIR / "visual-100-accessibility-adhd.json"),
        "proof_source_receipt": status_from_report(REPORT_DIR / "visual-100-proof-source-receipt.json"),
        "transaction": status_from_report(REPORT_DIR / "visual-100-transaction.json"),
        "primitive_operationality": status_from_report(REPORT_DIR / "visual-100-primitive-operationality.json"),
        "false_green": status_from_report(REPORT_DIR / "visual-100-false-green.json"),
        "prompt_authority": status_from_report(REPORT_DIR / "visual-100-prompt-authority.json"),
        "atlas_subordination": status_from_report(REPORT_DIR / "visual-100-atlas-subordination.json"),
        "native_believability": status_from_report(REPORT_DIR / "visual-100-native-believability.json"),
        "local_first_trust": status_from_report(REPORT_DIR / "visual-100-local-first-trust.json"),
        "no_false_momentum": status_from_report(REPORT_DIR / "visual-100-no-false-momentum.json"),
        "hidden_automation": status_from_report(REPORT_DIR / "visual-100-hidden-automation.json"),
        "dashboard_proof_separation": dashboard_separation_status(),
    }
    canonical_keys = [
        "object_depth",
        "object_uniqueness",
        "label_off_recognizability",
        "recipe_schema_depth",
        "source_debt",
        "intended_only_debt_visibility",
        "vocabulary",
        "microcopy_boundaries",
        "anti_generic",
        "accessibility",
        "proof_source_receipt",
        "transaction",
        "primitive_operationality",
        "native_believability",
        "local_first_trust",
        "no_false_momentum",
        "hidden_automation",
    ]
    control_plane_keys = canonical_keys + [
        "priority_registry",
        "false_green",
        "prompt_authority",
        "atlas_subordination",
        "dashboard_proof_separation",
    ]
    canon_status = "green" if all(checks[key] == "green" for key in canonical_keys) else "red"
    control_plane_status = "green" if all(checks[key] == "green" for key in control_plane_keys) else "red"
    source_linkage_status = "green" if checks["source_debt"] == "green" and checks["intended_only_debt_visibility"] == "green" else "red"
    prompt_status = "green" if checks["prompt_authority"] == "green" else "red"
    implementation_status = "Not In Scope"
    release_status = "Not In Scope"
    accessibility_proof_status = "Not In Scope"
    blocking_failures = [key for key in control_plane_keys if checks.get(key) != "green"]
    payload = {
        "Canon Content Status": canon_status,
        "Control-Plane Status": control_plane_status,
        "Source-Linkage Status": source_linkage_status,
        "Implementation Proof Status": implementation_status,
        "Release / Device Proof Status": release_status,
        "Accessibility Implementation Proof Status": accessibility_proof_status,
        "Prompt / Queue Authority Status": prompt_status,
        "checks": checks,
        "blocking_failures": blocking_failures,
        "status": "green" if canon_status == control_plane_status == source_linkage_status == prompt_status == "green" and not blocking_failures else "red",
    }
    write_json(REPORT_JSON, payload)
    REPORT_MD.write_text(
        "# North Star 100 Gate Results\n\n"
        f"- Canon Content Status: {canon_status}\n"
        f"- Control-Plane Status: {control_plane_status}\n"
        f"- Source-Linkage Status: {source_linkage_status}\n"
        f"- Implementation Proof Status: {implementation_status}\n"
        f"- Release / Device Proof Status: {release_status}\n"
        f"- Accessibility Implementation Proof Status: {accessibility_proof_status}\n"
        f"- Prompt / Queue Authority Status: {prompt_status}\n",
        encoding="utf-8",
    )
    print("PASS" if payload["status"] == "green" else "FAIL")
    return 0 if payload["status"] == "green" else 1


if __name__ == "__main__":
    raise SystemExit(main())
