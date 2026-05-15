#!/usr/bin/env python3
from __future__ import annotations

import json
import subprocess
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
REPORT_DIR = ROOT / "build" / "reports"
BATCH_ID = "SIGNATURE-VISUAL-INSTRUMENTS-ENCYCLOPEDIA-07"


def run_command(command: list[str]) -> dict[str, Any]:
    proc = subprocess.run(command, cwd=ROOT, text=True, capture_output=True)
    return {
        "command": " ".join(command),
        "exit_code": proc.returncode,
        "stdout": proc.stdout[-12000:],
        "stderr": proc.stderr[-12000:],
    }


def write_json(path: Path, payload: Any) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload, indent=2, sort_keys=True, ensure_ascii=False) + "\n", encoding="utf-8")


def write_text(path: Path, text: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding="utf-8")


def patch_makefile() -> bool:
    path = ROOT / "Makefile"
    text = path.read_text(encoding="utf-8")
    original = text

    phony_line = ".PHONY: frontend-authority-packet frontend-authority-packets-p0 frontend-authority-packets-all frontend-authority-preflight frontend-implementation-prompt frontend-source-bindings frontend-drift-check frontend-implementation-dashboard frontend-next-surface-queue frontend-receipt-check frontend-proof-contract-check encyclopedia-to-frontend-os-final-gate encyclopedia-to-frontend-os-all"
    phony_replacement = ".PHONY: frontend-authority-packet frontend-authority-packets-p0 frontend-authority-packets-all frontend-authority-preflight frontend-implementation-prompt frontend-source-bindings frontend-drift-check frontend-implementation-dashboard frontend-next-surface-queue frontend-receipt-check frontend-proof-contract-check signature-visual-instruments-check encyclopedia-to-frontend-os-final-gate encyclopedia-to-frontend-os-all"
    if phony_line in text:
        text = text.replace(phony_line, phony_replacement)

    target = "signature-visual-instruments-check:\n\t@python3 scripts/ambitions-signature-visual-instruments-check.py\n\n"
    anchor = "frontend-proof-contract-check:\n\t@python3 scripts/ambitions-frontend-proof-contract-check.py\n\n"
    if "signature-visual-instruments-check:" not in text and anchor in text:
        text = text.replace(anchor, anchor + target)

    final_gate_line = "\t$(MAKE) encyclopedia-to-frontend-os-final-gate\n"
    signature_line = "\t$(MAKE) signature-visual-instruments-check\n"
    if signature_line not in text and final_gate_line in text:
        text = text.replace(final_gate_line, signature_line + final_gate_line)

    if text != original:
        path.write_text(text, encoding="utf-8")
        return True
    return False


def render_md(report: dict[str, Any]) -> str:
    lines = [
        f"STATUS: {report['status'].upper()}",
        f"Batch: {BATCH_ID}",
        "Model path: GitHub API direct install -> generated local validation script -> optional GitHub Actions validation",
        f"Summary: {report['summary']}",
        "Files changed:",
    ]
    for item in report["changed_files"]:
        lines.append(f"- {item}")
    lines.extend([
        f"Instrument doctrine: {report['instrument_doctrine']}",
        f"Instrument matrix: {report['instrument_matrix']}",
        f"Packet generator integration: {report['packet_generator_integration']}",
        f"Implementation prompt integration: {report['implementation_prompt_integration']}",
        f"Source binding integration: {report['source_binding_integration']}",
        f"Drift checker integration: {report['drift_checker_integration']}",
        f"Dashboard integration: {report['dashboard_integration']}",
        f"Next queue integration: {report['next_queue_integration']}",
        "Validation run:",
    ])
    for result in report["validation_run"]:
        lines.append(f"- `{result['command']}` -> {result['exit_code']}")
        if result["exit_code"] != 0:
            if result.get("stdout"):
                lines.append("  - stdout tail:")
                lines.extend(f"    {line}" for line in result["stdout"].splitlines()[-20:])
            if result.get("stderr"):
                lines.append("  - stderr tail:")
                lines.extend(f"    {line}" for line in result["stderr"].splitlines()[-20:])
    lines.extend([
        f"Remaining gaps: {', '.join(report['remaining_gaps']) if report['remaining_gaps'] else 'None'}",
        f"Implementation proof: {report['implementation_proof']}",
        f"Rollback notes: {report['rollback_notes']}",
        f"Commit: {report['commit']}",
    ])
    return "\n".join(lines).rstrip() + "\n"


def print_failure_summary(failures: list[dict[str, Any]]) -> None:
    if not failures:
        return
    print("\nFAILED INTERNAL VALIDATION COMMANDS")
    print("===================================")
    for result in failures:
        print(f"\nCOMMAND: {result['command']}")
        print(f"EXIT: {result['exit_code']}")
        if result.get("stdout"):
            print("STDOUT TAIL:")
            print(result["stdout"][-4000:])
        if result.get("stderr"):
            print("STDERR TAIL:")
            print(result["stderr"][-4000:])


def main() -> int:
    makefile_patched = patch_makefile()
    commands = [
        ["python3", "-m", "py_compile", "scripts/ambitions_signature_visual_instruments.py", "scripts/ambitions-frontend-authority-packet.py", "scripts/ambitions-frontend-implementation-prompt.py", "scripts/ambitions-frontend-source-bindings.py", "scripts/ambitions-frontend-drift-check.py", "scripts/ambitions-frontend-implementation-dashboard.py", "scripts/ambitions-frontend-next-surface-queue.py", "scripts/ambitions-signature-visual-instruments-check.py"],
        ["python3", "scripts/ambitions-frontend-authority-packet.py", "--tier", "P0"],
        ["python3", "scripts/ambitions-frontend-authority-packet.py", "--all"],
        ["python3", "scripts/ambitions-frontend-authority-preflight.py", "--surface", "today_root_reality_meridian"],
        ["python3", "scripts/ambitions-frontend-authority-preflight.py", "--surface", "goals_root_constellation_atlas"],
        ["python3", "scripts/ambitions-frontend-authority-preflight.py", "--surface", "capture_root_atmosphere_composer"],
        ["python3", "scripts/ambitions-frontend-authority-preflight.py", "--surface", "time_root_lifeshape_field"],
        ["python3", "scripts/ambitions-frontend-authority-preflight.py", "--surface", "you_root_user_system_profile"],
        ["python3", "scripts/ambitions-frontend-implementation-prompt.py", "--surface", "today_root_reality_meridian", "--batch", "TODAY-REALITY-MERIDIAN-FLAGSHIP-IMPLEMENTATION-01"],
        ["python3", "scripts/ambitions-frontend-source-bindings.py"],
        ["python3", "scripts/ambitions-frontend-drift-check.py"],
        ["python3", "scripts/ambitions-frontend-implementation-dashboard.py"],
        ["python3", "scripts/ambitions-frontend-next-surface-queue.py"],
        ["python3", "scripts/ambitions-frontend-receipt-check.py"],
        ["python3", "scripts/ambitions-frontend-proof-contract-check.py"],
        ["python3", "scripts/ambitions-signature-visual-instruments-check.py"],
        ["python3", "scripts/ambitions-encyclopedia-to-frontend-os-final-gate.py"],
        ["git", "diff", "--check"],
    ]
    results = [run_command(command) for command in commands]
    command_failures = [result for result in results if result["exit_code"] != 0]

    signature_report_path = REPORT_DIR / "signature-visual-instruments-check.json"
    signature_report = {}
    if signature_report_path.exists():
        try:
            signature_report = json.loads(signature_report_path.read_text(encoding="utf-8"))
        except json.JSONDecodeError:
            signature_report = {}

    status = "green" if not command_failures and signature_report.get("status") == "green" else "red"
    changed = run_command(["git", "status", "--short"])["stdout"].splitlines()
    changed_files = [line[3:] if len(line) > 3 else line for line in changed]
    report = {
        "status": status,
        "batch_id": BATCH_ID,
        "summary": "Signature Visual Instruments are operationally wired into packets, prompts, bindings, drift, dashboard, queue, and validation." if status == "green" else "Signature Visual Instruments install attempted but validation has blockers.",
        "makefile_patched": makefile_patched,
        "changed_files": changed_files,
        "instrument_doctrine": "installed" if (ROOT / "frontend/visual-encyclopedia/SIGNATURE_VISUAL_INSTRUMENTS.md").exists() else "missing",
        "instrument_matrix": "installed" if (ROOT / "frontend/visual-encyclopedia/trace/SIGNATURE_VISUAL_INSTRUMENTS_MATRIX.yaml").exists() else "missing",
        "packet_generator_integration": "installed",
        "implementation_prompt_integration": "installed",
        "source_binding_integration": "installed",
        "drift_checker_integration": "installed",
        "dashboard_integration": "installed",
        "next_queue_integration": "installed",
        "validation_run": results,
        "remaining_gaps": [result["command"] for result in command_failures],
        "implementation_proof": "not claimed",
        "rollback_notes": "Revert the files changed by SIGNATURE-VISUAL-INSTRUMENTS-ENCYCLOPEDIA-07 and rerun encyclopedia-to-frontend-os-all if needed.",
        "commit": "created by GitHub API or GitHub Actions after this installer runs",
    }
    write_json(REPORT_DIR / "signature-visual-instruments-encyclopedia-07.json", report)
    write_text(REPORT_DIR / "signature-visual-instruments-encyclopedia-07.md", render_md(report))
    print(status.upper())
    print_failure_summary(command_failures)
    return 0 if status == "green" else 1


if __name__ == "__main__":
    raise SystemExit(main())
