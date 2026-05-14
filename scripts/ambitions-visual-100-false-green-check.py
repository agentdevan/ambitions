#!/usr/bin/env python3
from __future__ import annotations

from ambitions_visual_100_common import BASE, load_json_like, write_json, REPORT_DIR


REPORT = REPORT_DIR / "visual-100-false-green.json"


def main() -> int:
    risks = []
    dashboard_path = REPORT_DIR / "visual-100-proof-dashboard.json"
    dashboard = {}
    if dashboard_path.exists():
        dashboard = load_json_like(dashboard_path)
    source_debt_path = REPORT_DIR / "visual-100-source-debt.json"
    gate_path = REPORT_DIR / "visual-100-gate.json"
    if source_debt_path.exists():
        source_debt = load_json_like(source_debt_path)
        source_distribution = dashboard.get("source_link_distribution", {})
        visible_count = source_distribution.get("intended_only", 0)
        debt_count = source_debt.get("p0_intended_only_count", 0)
        visible_debt = source_debt.get("p0_visible_debt", [])
        if dashboard.get("Canon Content Status") == "green" and debt_count > 0 and (visible_count == 0 or not visible_debt):
            risks.append("p0-intended-only-hidden")
        if dashboard.get("Source-Linkage Status") == "green" and source_debt.get("status") == "red":
            risks.append("source-debt-red")
    if gate_path.exists():
        gate = load_json_like(gate_path)
        if gate.get("Implementation Proof Status") != "Not In Scope":
            risks.append("implementation-proof-boundary")
        if gate.get("Release / Device Proof Status") != "Not In Scope":
            risks.append("release-device-proof-boundary")
        if gate.get("Accessibility Implementation Proof Status") != "Not In Scope":
            risks.append("accessibility-proof-boundary")
    if dashboard.get("final_100_eligibility") and risks:
        risks.append("false-green-eligibility-mismatch")
    status = "green" if not risks else "red"
    write_json(REPORT, {"risks": risks, "status": status})
    print("PASS" if status == "green" else "FAIL")
    return 0 if status == "green" else 1


if __name__ == "__main__":
    raise SystemExit(main())
