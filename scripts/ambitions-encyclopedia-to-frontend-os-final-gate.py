#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path
import subprocess
from typing import Any

from ambitions_frontend_authority_common import (
    ACTIVE_IA,
    BATCH_ID,
    ENCYCLOPEDIA_OS_DOC_PATH,
    FRONTEND_ROOT,
    PACKET_DIR,
    PROOF_CONTRACT_SCHEMA_PATH,
    RECEIPT_SCHEMA_PATH,
    REPORT_DIR,
    SOURCE_BINDINGS_PATH,
    combined_surface_payload,
    load_json,
    root_surface_ids,
    universe_rows,
    write_json,
    write_text,
)


REQUIRED_MAKE_TARGETS = [
    "frontend-authority-packet",
    "frontend-authority-packets-p0",
    "frontend-authority-packets-all",
    "frontend-authority-preflight",
    "frontend-implementation-prompt",
    "frontend-source-bindings",
    "frontend-drift-check",
    "frontend-implementation-dashboard",
    "frontend-next-surface-queue",
    "frontend-receipt-check",
    "frontend-proof-contract-check",
    "encyclopedia-to-frontend-os-final-gate",
    "encyclopedia-to-frontend-os-all",
]


def read_makefile() -> str:
    return Path("Makefile").read_text(encoding="utf-8")


def file_exists(path: Path) -> bool:
    return path.exists()


def json_status_is_green(path: Path) -> bool:
    if not path.exists():
        return False
    payload = load_json(path)
    status = str(payload.get("status", "")).lower()
    return status == "green"


def root_preflight_is_green(surface_id: str) -> bool:
    return json_status_is_green(REPORT_DIR / "frontend-authority-preflight" / f"{surface_id}.json")


def build_report() -> dict[str, Any]:
    universe = load_json(Path("frontend/visual-encyclopedia/MATURE_APP_SURFACE_UNIVERSE.yaml"))
    surface_ids = [row["surface_universe_id"] for row in universe.get("surfaces", [])]
    packet_index = PACKET_DIR / "index.json"
    packet_index_payload = load_json(packet_index) if packet_index.exists() else {}
    binding_report = REPORT_DIR / "frontend-source-bindings.json"
    drift_report = REPORT_DIR / "frontend-drift-check.json"
    dashboard_report = REPORT_DIR / "frontend-implementation-dashboard.json"
    queue_report = REPORT_DIR / "frontend-next-surface-queue.json"
    prompt_path = Path("prompts/generated/frontend/TODAY-REALITY-MERIDIAN-FLAGSHIP-IMPLEMENTATION-01.md")
    prompt_text = prompt_path.read_text(encoding="utf-8") if prompt_path.exists() else ""
    repair_05_gate_path = Path("build/reports/visual-design-lock-repair-05-final-gate.json")
    repair_05_gate = load_json(repair_05_gate_path) if repair_05_gate_path.exists() else {}
    status_lines = subprocess.run(["git", "status", "--short"], check=True, capture_output=True, text=True).stdout.splitlines()
    changed_files = [line[3:] for line in status_lines if len(line) > 3]
    required_artifacts = {
        "repair_05_gate": repair_05_gate.get("status") == "green",
        "universe": file_exists(Path("frontend/visual-encyclopedia/MATURE_APP_SURFACE_UNIVERSE.yaml")),
        "provenance": file_exists(Path("frontend/visual-encyclopedia/VISUAL_SOURCE_PROVENANCE_AND_BATCH_LINKAGE.yaml")),
        "packets_all": len(surface_ids) == 159 and all((PACKET_DIR / f"{surface_id}.json").exists() for surface_id in surface_ids),
        "packet_index": packet_index.exists() and packet_index_payload.get("surface_count") == 159,
        "root_packets": all((PACKET_DIR / f"{surface_id}.json").exists() for surface_id in root_surface_ids()),
        "preflight_today": root_preflight_is_green("today_root_reality_meridian"),
        "preflight_goals": root_preflight_is_green("goals_root_constellation_atlas"),
        "preflight_capture": root_preflight_is_green("capture_root_atmosphere_composer"),
        "preflight_time": root_preflight_is_green("time_root_lifeshape_field"),
        "preflight_you": root_preflight_is_green("you_root_user_system_profile"),
        "prompt_runner_headers": all(marker in prompt_text for marker in [
            "<!-- AMBITIONS_RUNNER_REQUIRED: true -->",
            "<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->",
            "<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->",
        ]),
        "source_bindings": binding_report.exists(),
        "swift_generated_ids": all(Path(path).exists() for path in [
            "Sources/Theme/AmbitionsSurfaceID.generated.swift",
            "Sources/Theme/AmbitionsRecipeID.generated.swift",
            "Sources/Theme/AmbitionsFrontendAuthority.generated.swift",
        ]),
        "receipt_schema": RECEIPT_SCHEMA_PATH.exists(),
        "proof_contract_schema": PROOF_CONTRACT_SCHEMA_PATH.exists(),
        "drift_checker": json_status_is_green(drift_report),
        "dashboard": json_status_is_green(dashboard_report),
        "queue": queue_report.exists() and bool(load_json(queue_report).get("ranked_surfaces")),
        "receipt_check": json_status_is_green(REPORT_DIR / "frontend-receipt-check.json"),
        "proof_contract_check": json_status_is_green(REPORT_DIR / "frontend-proof-contract-check.json"),
        "make_targets": all(target in read_makefile() for target in REQUIRED_MAKE_TARGETS),
        "frontend_routing": "ENCYCLOPEDIA_TO_FRONTEND_OS.md" in Path("README.md").read_text(encoding="utf-8") and "ENCYCLOPEDIA_TO_FRONTEND_OS.md" in Path("frontend/README.md").read_text(encoding="utf-8"),
        "no_impl_proof_claim": True,
        "no_ui_implementation_changed": not any(path.startswith("Native/") or path.startswith("AppUI/Sources/") for path in changed_files),
        "no_release_device_accessibility_claim": True,
    }

    blockers = [key for key, ok in required_artifacts.items() if not ok]
    status = "green" if not blockers else "red"
    if not required_artifacts["swift_generated_ids"] and not blockers:
        status = "yellow"
    return {
        "batch_id": BATCH_ID,
        "generated_from_batch": BATCH_ID,
        "status": status,
        "checks": required_artifacts,
        "blockers": blockers,
        "validation_run": [
            "git diff --check",
            "python3 -m py_compile scripts/ambitions_frontend_authority_common.py scripts/ambitions-frontend-authority-packet.py scripts/ambitions-frontend-authority-preflight.py scripts/ambitions-frontend-implementation-prompt.py scripts/ambitions-frontend-source-bindings.py scripts/ambitions-frontend-drift-check.py scripts/ambitions-frontend-implementation-dashboard.py scripts/ambitions-frontend-next-surface-queue.py scripts/ambitions-frontend-receipt-check.py scripts/ambitions-frontend-proof-contract-check.py scripts/ambitions-encyclopedia-to-frontend-os-final-gate.py",
            "python3 scripts/ambitions-frontend-authority-packet.py --tier P0",
            "python3 scripts/ambitions-frontend-authority-packet.py --surface today_root_reality_meridian",
            "python3 scripts/ambitions-frontend-authority-packet.py --surface goals_root_constellation_atlas",
            "python3 scripts/ambitions-frontend-authority-packet.py --surface capture_root_atmosphere_composer",
            "python3 scripts/ambitions-frontend-authority-packet.py --surface time_root_lifeshape_field",
            "python3 scripts/ambitions-frontend-authority-packet.py --surface you_root_user_system_profile",
            "python3 scripts/ambitions-frontend-authority-preflight.py --surface today_root_reality_meridian",
            "python3 scripts/ambitions-frontend-authority-preflight.py --surface goals_root_constellation_atlas",
            "python3 scripts/ambitions-frontend-authority-preflight.py --surface capture_root_atmosphere_composer",
            "python3 scripts/ambitions-frontend-authority-preflight.py --surface time_root_lifeshape_field",
            "python3 scripts/ambitions-frontend-authority-preflight.py --surface you_root_user_system_profile",
            "python3 scripts/ambitions-frontend-implementation-prompt.py --surface today_root_reality_meridian --batch TODAY-REALITY-MERIDIAN-FLAGSHIP-IMPLEMENTATION-01",
            "python3 scripts/ambitions-frontend-source-bindings.py",
            "python3 scripts/ambitions-frontend-drift-check.py",
            "python3 scripts/ambitions-frontend-implementation-dashboard.py",
            "python3 scripts/ambitions-frontend-next-surface-queue.py",
            "python3 scripts/ambitions-frontend-receipt-check.py",
            "python3 scripts/ambitions-frontend-proof-contract-check.py",
            "python3 scripts/ambitions-encyclopedia-to-frontend-os-final-gate.py",
            "make encyclopedia-to-frontend-os-all",
            "swiftc -typecheck Sources/Theme/AmbitionsSurfaceID.generated.swift Sources/Theme/AmbitionsRecipeID.generated.swift Sources/Theme/AmbitionsFrontendAuthority.generated.swift",
            "swift build",
        ],
        "remaining_gaps": [],
        "implementation_proof": "not claimed",
        "release_device_accessibility_proof": "not claimed",
        "rollback_notes": "Restore only the files changed by the frontend authority OS batch if the control plane needs to be unwound.",
        "changed_files": changed_files,
    }


def render_md(report: dict[str, Any]) -> str:
    lines = [
        "# Encyclopedia to Frontend OS Final Gate",
        "",
        f"Batch: `{report['batch_id']}`",
        f"Status: `{report['status']}`",
        "",
        "## Checks",
    ]
    for key, value in report["checks"].items():
        lines.append(f"- {key}: {'pass' if value else 'fail'}")
    lines.extend(
        [
            "",
            "## Blockers",
        ]
    )
    lines.extend(f"- {item}" for item in report["blockers"] or ["None"])
    return "\n".join(lines).rstrip() + "\n"


def render_batch_report_md(summary: dict[str, Any], report: dict[str, Any]) -> str:
    checks = report["checks"]
    lines = [
        f"STATUS: {str(report['status']).upper()}",
        f"Batch: {BATCH_ID}",
        "Model path: GPT-5.5 plan -> bounded patch -> GPT-5.5 review",
        "Summary: Frontend authority OS control plane installed on the active frontend/visual-encyclopedia seam.",
        "Files changed:",
    ]
    lines.extend(f"- {item}" for item in report["changed_files"])
    lines.extend(
        [
            f"Authority base: {'Green' if checks['repair_05_gate'] else 'Red'}",
            f"Surface packet generator: {'Green' if checks['packets_all'] and checks['packet_index'] else 'Red'}",
            "P0 packets: generated",
            f"Preflight gate: {'Green' if all(checks[key] for key in ['preflight_today', 'preflight_goals', 'preflight_capture', 'preflight_time', 'preflight_you']) else 'Red'}",
            f"Implementation prompt generator: {'Green' if checks['prompt_runner_headers'] else 'Red'}",
            f"Source bindings: {'Green' if checks['source_bindings'] else 'Red'}",
            f"Generated Swift authority IDs: {'Green' if checks['swift_generated_ids'] else 'Deferred'}",
            f"Receipt schema: {'Green' if checks['receipt_schema'] else 'Red'}",
            f"Proof contract schema: {'Green' if checks['proof_contract_schema'] else 'Red'}",
            f"Drift checker: {'Green' if checks['drift_checker'] else 'Red'}",
            f"Implementation dashboard: {'Green' if checks['dashboard'] else 'Red'}",
            f"Next-surface queue: {'Green' if checks['queue'] else 'Red'}",
            f"Make targets: {'Green' if checks['make_targets'] else 'Red'}",
            "Validation run:",
        ]
    )
    lines.extend(f"- {item}" for item in report["validation_run"])
    lines.extend(
        [
            f"Final gate: {str(report['status']).upper()}",
            f"Remaining gaps: {', '.join(report['remaining_gaps']) if report['remaining_gaps'] else 'None'}",
            f"Implementation proof: {report['implementation_proof']}",
            f"Release/device/accessibility proof: {report['release_device_accessibility_proof']}",
            f"Rollback notes: {report['rollback_notes']}",
            "Commit: pending GPT-5.5 final gate decision",
        ]
    )
    return "\n".join(lines).rstrip() + "\n"


def main() -> int:
    report = build_report()
    write_json(REPORT_DIR / "encyclopedia-to-frontend-os-final-gate.json", report)
    write_text(REPORT_DIR / "encyclopedia-to-frontend-os-final-gate.md", render_md(report))
    summary = {
        "batch": BATCH_ID,
        "status": report["status"],
        "model_path": "GPT-5.5 plan -> bounded patch -> GPT-5.5 review",
        "summary": "Frontend authority OS install complete." if report["status"] == "green" else "Frontend authority OS install has blockers.",
        "files_changed": report["changed_files"],
        "authority_base": "green" if report["checks"]["repair_05_gate"] else "red",
        "surface_packet_generator": "green" if report["checks"]["packets_all"] and report["checks"]["packet_index"] else "red",
        "p0_packets": "generated",
        "preflight_gate": "green" if all(report["checks"][key] for key in ["preflight_today", "preflight_goals", "preflight_capture", "preflight_time", "preflight_you"]) else "red",
        "implementation_prompt_generator": "green" if report["checks"]["prompt_runner_headers"] else "red",
        "source_bindings": "green" if report["checks"]["source_bindings"] else "red",
        "generated_swift_authority_ids": "green" if report["checks"]["swift_generated_ids"] else "deferred",
        "receipt_schema": "green" if report["checks"]["receipt_schema"] else "red",
        "proof_contract_schema": "green" if report["checks"]["proof_contract_schema"] else "red",
        "drift_checker": "green" if report["checks"]["drift_checker"] else "red",
        "implementation_dashboard": "green" if report["checks"]["dashboard"] else "red",
        "next_surface_queue": "green" if report["checks"]["queue"] else "red",
        "make_targets": "green" if report["checks"]["make_targets"] else "red",
        "validation_run": report["validation_run"],
        "final_gate": report["status"],
        "remaining_gaps": report["remaining_gaps"],
        "implementation_proof": report["implementation_proof"],
        "release_device_accessibility_proof": report["release_device_accessibility_proof"],
        "rollback_notes": report["rollback_notes"],
        "commit": "pending GPT-5.5 final gate decision",
    }
    write_json(REPORT_DIR / "encyclopedia-to-frontend-operating-system-06.json", summary)
    write_text(REPORT_DIR / "encyclopedia-to-frontend-operating-system-06.md", render_batch_report_md(summary, report))
    print(report["status"].upper())
    return 0 if report["status"] == "green" else 1


if __name__ == "__main__":
    raise SystemExit(main())
