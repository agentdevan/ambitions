#!/usr/bin/env python3
from __future__ import annotations

import json
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path
from textwrap import dedent

ROOT = Path(__file__).resolve().parents[2]
PROMPT = ROOT / "prompts/batches/PROOFMODE-002-repair-focused-test.md"
SUMMARY = ROOT / "docs/proof/harness/PROOFMODE-002-focused-test-repair-summary.md"
LOG_DIR = ROOT / "build/reports/harness/PROOFMODE-002"
COMMIT_MESSAGE = "AMB-308 repair focused app-driving proof test"

def utc_now() -> str:
    return datetime.now(timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")

def run(args: list[str]) -> subprocess.CompletedProcess[str]:
    return subprocess.run(args, cwd=ROOT, text=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=False)

def git(args: list[str], check: bool = True) -> subprocess.CompletedProcess[str]:
    proc = run(["git", *args])
    if check and proc.returncode != 0:
        sys.stderr.write(proc.stdout)
        sys.stderr.write(proc.stderr)
        raise SystemExit(proc.returncode)
    return proc

def git_text(args: list[str]) -> str:
    return git(args).stdout.strip()

def require_main_clean() -> None:
    branch = git_text(["branch", "--show-current"])
    if branch != "main":
        raise SystemExit(f"Expected main-only execution. Current branch: {branch}")
    status = git_text(["status", "--porcelain"])
    if status:
        print(status)
        raise SystemExit("Worktree must be clean before running AMB-308.")

def write(path: Path, content: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(dedent(content).lstrip("\n"), encoding="utf-8")

def choose_destination() -> tuple[str, str]:
    proc = run(["xcrun", "simctl", "list", "devices", "available", "--json"])
    if proc.returncode != 0:
        return "platform=iOS Simulator", "simctl unavailable; used generic iOS Simulator destination"

    try:
        payload = json.loads(proc.stdout)
    except json.JSONDecodeError:
        return "platform=iOS Simulator", "simctl JSON parse failed; used generic iOS Simulator destination"

    candidates: list[tuple[str, str, str]] = []
    for runtime, devices in payload.get("devices", {}).items():
        if "iOS" not in runtime:
            continue
        for device in devices:
            name = str(device.get("name", ""))
            udid = str(device.get("udid", ""))
            if device.get("isAvailable") and "iPhone" in name and udid:
                candidates.append((name, udid, runtime))

    if not candidates:
        return "platform=iOS Simulator", "no available iPhone simulator found; used generic iOS Simulator destination"

    name, udid, runtime = candidates[-1]
    return f"platform=iOS Simulator,id={udid}", f"selected {name} from {runtime}"

def classify_failure(log_text: str) -> str:
    lower = log_text.lower()
    if "unable to find a destination" in lower or ("destination" in lower and "not found" in lower):
        return "simulator_destination_failure"
    if "no such module" in lower:
        return "module_import_failure"
    if "cannot find" in lower or "cannot convert" in lower or "is inaccessible" in lower:
        return "swift_compile_failure"
    if "testing failed" in lower or "test failed" in lower:
        return "test_execution_failure"
    if "build failed" in lower:
        return "build_failure"
    return "xcodebuild_exit_65_unclassified"

def run_validation(destination: str, label: str) -> tuple[int, Path, str]:
    LOG_DIR.mkdir(parents=True, exist_ok=True)
    log = LOG_DIR / f"{label}.log"
    cmd = [
        "xcodebuild",
        "test",
        "-project", "Ambitions.xcodeproj",
        "-scheme", "Ambitions",
        "-destination", destination,
        "-only-testing:AmbitionsTests/AppDrivingProofModeRouterTests",
        "CODE_SIGNING_ALLOWED=NO",
    ]
    proc = run(cmd)
    log.write_text("$ " + " ".join(cmd) + "\n\n" + proc.stdout + proc.stderr, encoding="utf-8")
    return proc.returncode, log, " ".join(cmd)

def install_prompt() -> None:
    write(PROMPT, """
    <!-- AMBITIONS_RUNNER_REQUIRED: true -->
    <!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
    <!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

    # PROOFMODE-002 — Repair Focused App-Driving Proof Test

    Issue: AMB-308

    ## Control Plane

    - Main-only execution.
    - Bounded repair only.
    - No `docs/truth/*` edits.
    - No production user-data mutation.
    - No release, TestFlight, App Store, device, accessibility, privacy/legal, or app-completion claims.
    """)

def write_summary(
    xcodegen_exit: int,
    first_exit: int | None,
    first_log: Path | None,
    first_cmd: str | None,
    retry_exit: int | None,
    retry_log: Path | None,
    retry_cmd: str | None,
    destination_note: str,
) -> None:
    final_exit = retry_exit if retry_exit is not None else first_exit
    status = "Green" if xcodegen_exit == 0 and final_exit == 0 else "Yellow"
    active_log = retry_log or first_log
    failure_class = "none"
    if status != "Green" and active_log and active_log.exists():
        failure_class = classify_failure(active_log.read_text(encoding="utf-8", errors="ignore"))

    write(SUMMARY, f"""
    # PROOFMODE-002 Focused Test Repair Summary

    Status: {status}
    Issue: AMB-308
    Created UTC: {utc_now()}

    ## Destination Discovery

    - {destination_note}

    ## Validation

    - xcodegen generate exit: {xcodegen_exit}

    ### Focused Test Attempt

    - exit: {first_exit if first_exit is not None else "not_run"}
    - command: `{first_cmd if first_cmd else "not_run"}`
    - log: `{first_log.relative_to(ROOT) if first_log else "not_run"}`

    ### Retry Attempt

    - exit: {retry_exit if retry_exit is not None else "not_run"}
    - command: `{retry_cmd if retry_cmd else "not_run"}`
    - log: `{retry_log.relative_to(ROOT) if retry_log else "not_run"}`

    ## Classification

    - `{failure_class}`

    ## Result

    {"Focused app-driving proof test passed locally." if status == "Green" else "Focused app-driving proof remains Yellow. Inspect the recorded log for the next bounded repair."}

    ## Claims Not Made

    - No full app-driving proof completion claim unless reviewed.
    - No release readiness claim.
    - No TestFlight readiness claim.
    - No App Store readiness claim.
    - No device validation claim.
    - No accessibility validation claim.
    - No privacy/legal approval claim.
    """)

def stage_and_commit() -> None:
    git(["add", str(PROMPT.relative_to(ROOT)), str(SUMMARY.relative_to(ROOT)), "scripts/harness/ambitions_repair_proofmode_002.py"])
    staged = git_text(["diff", "--cached", "--name-only"]).splitlines()
    forbidden = [p for p in staged if p.startswith("docs/truth/") or p.startswith("build/reports/") or p in {"project.yml", "Package.swift"}]
    if forbidden:
        raise SystemExit("Forbidden staged paths:\n" + "\n".join(forbidden))
    if not staged:
        print("No staged changes.")
        return
    git(["commit", "-m", COMMIT_MESSAGE])
    print(git_text(["log", "-1", "--oneline"]))

def main() -> int:
    require_main_clean()
    install_prompt()

    xcodegen = run(["xcodegen", "generate"])
    LOG_DIR.mkdir(parents=True, exist_ok=True)
    (LOG_DIR / "xcodegen-generate.log").write_text(xcodegen.stdout + xcodegen.stderr, encoding="utf-8")

    first_exit = None
    first_log = None
    first_cmd = None
    retry_exit = None
    retry_log = None
    retry_cmd = None
    destination_note = "not_run"

    if xcodegen.returncode == 0:
        destination, destination_note = choose_destination()
        first_exit, first_log, first_cmd = run_validation(destination, "focused-test-discovered-destination")

        if first_exit != 0 and destination != "platform=iOS Simulator":
            retry_exit, retry_log, retry_cmd = run_validation("platform=iOS Simulator", "focused-test-generic-destination")

    write_summary(
        xcodegen.returncode,
        first_exit,
        first_log,
        first_cmd,
        retry_exit,
        retry_log,
        retry_cmd,
        destination_note,
    )
    stage_and_commit()

    print("\nPush command:\n  git push origin main")
    print("\nAfter pushing, tell ChatGPT:\n  proofmode repair pushed")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
