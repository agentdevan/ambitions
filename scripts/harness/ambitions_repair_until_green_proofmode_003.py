#!/usr/bin/env python3
from __future__ import annotations

import json
import re
import subprocess
import sys
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from textwrap import dedent

ROOT = Path(__file__).resolve().parents[2]

SOURCE = ROOT / "Native/Ambitions/Domain/ProofMode/AppDrivingProofModeRouter.swift"
TEST = ROOT / "Native/AmbitionsTests/ProofMode/AppDrivingProofModeRouterTests.swift"
PROMPT = ROOT / "prompts/batches/PROOFMODE-003-layered-repair-until-green.md"
SUMMARY = ROOT / "docs/proof/harness/PROOFMODE-003-layered-repair-until-green-summary.md"
LOG_ROOT = ROOT / "build/reports/harness/PROOFMODE-003"

COMMIT_MESSAGE = "AMB-309 run layered proofmode repair until green"

@dataclass
class Attempt:
    layer: str
    command: str
    exit_code: int
    log_path: Path
    classification: str
    excerpt: list[str]

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
        raise SystemExit("Worktree must be clean before running PROOFMODE-003.")

def write(path: Path, content: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(dedent(content).lstrip("\n"), encoding="utf-8")

def install_prompt() -> None:
    write(PROMPT, """
    <!-- AMBITIONS_RUNNER_REQUIRED: true -->
    <!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
    <!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

    # PROOFMODE-003 — Layered Repair Until Green

    Issue: AMB-309

    ## Control Plane

    - Main-only execution.
    - Layered bounded repair loop.
    - No `docs/truth/*` edits.
    - No generated `build/reports/**` commits.
    - No production user-data mutation.
    - No cloud AI, analytics, backend, telemetry, tracking, signing, hosted CI, App Store automation, or production dependencies.
    - No release, TestFlight, App Store, device, accessibility, privacy/legal, or app-completion claims.
    """)

def choose_destination() -> tuple[str, str]:
    proc = run(["xcrun", "simctl", "list", "devices", "available", "--json"])
    if proc.returncode != 0:
        return "platform=iOS Simulator", "simctl unavailable; using generic iOS Simulator destination"

    try:
        payload = json.loads(proc.stdout)
    except json.JSONDecodeError:
        return "platform=iOS Simulator", "simctl JSON parse failed; using generic iOS Simulator destination"

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
        return "platform=iOS Simulator", "no available iPhone simulator found; using generic iOS Simulator destination"

    name, udid, runtime = candidates[-1]
    return f"platform=iOS Simulator,id={udid}", f"selected {name} from {runtime}"

def extract_excerpt(text: str) -> list[str]:
    useful: list[str] = []
    patterns = [
        "error:",
        "warning:",
        "failed",
        "cannot find",
        "cannot convert",
        "no such module",
        "ambitions",
        "appdrivingproofmoderouter",
        "xctest",
        "testing failed",
        "build failed",
        "destination",
    ]

    for line in text.splitlines():
        lower = line.lower()
        if any(p in lower for p in patterns):
            stripped = line.strip()
            if stripped and stripped not in useful:
                useful.append(stripped[:500])
        if len(useful) >= 80:
            break

    return useful

def classify(text: str) -> str:
    lower = text.lower()

    if "no such module" in lower:
        return "module_import_failure"
    if "cannot find" in lower and "appdrivingproofmoderouter" in lower:
        return "router_not_visible_to_tests"
    if "cannot find" in lower:
        return "swift_symbol_not_found"
    if "inaccessible due to" in lower:
        return "swift_access_control_failure"
    if "cannot convert value" in lower or "type of expression is ambiguous" in lower:
        return "swift_typecheck_failure"
    if "unable to find a destination" in lower or ("destination" in lower and "not found" in lower):
        return "simulator_destination_failure"
    if "the file" in lower and "couldn’t be opened" in lower:
        return "file_reference_failure"
    if "build failed" in lower:
        return "build_failure"
    if "testing failed" in lower or "test failed" in lower:
        return "test_execution_failure"
    if "exit code 65" in lower or "xcodebuild" in lower:
        return "xcodebuild_failure_unclassified"
    return "unclassified"

def run_logged(layer: str, args: list[str]) -> Attempt:
    LOG_ROOT.mkdir(parents=True, exist_ok=True)
    safe_layer = re.sub(r"[^A-Za-z0-9_.-]+", "-", layer).strip("-")
    log_path = LOG_ROOT / f"{safe_layer}.log"
    proc = run(args)
    command = " ".join(args)
    log_text = "$ " + command + "\n\n" + proc.stdout + proc.stderr
    log_path.write_text(log_text, encoding="utf-8")
    return Attempt(
        layer=layer,
        command=command,
        exit_code=proc.returncode,
        log_path=log_path,
        classification=classify(log_text),
        excerpt=extract_excerpt(log_text),
    )

def xcodegen_generate(layer: str) -> Attempt:
    return run_logged(layer, ["xcodegen", "generate"])

def focused_test(layer: str, destination: str) -> Attempt:
    return run_logged(
        layer,
        [
            "xcodebuild",
            "test",
            "-project", "Ambitions.xcodeproj",
            "-scheme", "Ambitions",
            "-destination", destination,
            "-only-testing:AmbitionsTests/AppDrivingProofModeRouterTests",
            "CODE_SIGNING_ALLOWED=NO",
        ],
    )

def patch_common_swift_test_type_issue() -> bool:
    changed = False
    text = TEST.read_text(encoding="utf-8")

    replacements = {
        "XCTAssertEqual(Set(outputs.map(\\.intent)), [AppDrivingProofModeRouter.certificationExamIntent])":
            "XCTAssertEqual(Set(outputs.map(\\.intent)), Set([AppDrivingProofModeRouter.certificationExamIntent]))",
        "XCTAssertEqual(Set(outputs.map(\\.intent)), [AppDrivingProofModeRouter.certificationExamIntent])":
            "XCTAssertEqual(Set(outputs.map(\\.intent)), Set([AppDrivingProofModeRouter.certificationExamIntent]))",
    }

    new = text
    for old, replacement in replacements.items():
        new = new.replace(old, replacement)

    if new != text:
        TEST.write_text(new, encoding="utf-8")
        changed = True

    return changed

def patch_router_visibility() -> bool:
    text = SOURCE.read_text(encoding="utf-8")
    new = text

    # Keep this bounded to the proof-mode seam. Public is safe here because this is
    # app-target test visibility, not production routing exposure.
    new = new.replace("struct AppDrivingProofModeRouter: Sendable", "struct AppDrivingProofModeRouter: Sendable")

    if new != text:
        SOURCE.write_text(new, encoding="utf-8")
        return True
    return False

def patch_test_invocation_name_if_needed() -> bool:
    # If Xcode cannot find the exact test bundle selector, use class-only in future runner output.
    # No file changes needed; this is handled by command layer.
    return False

def apply_safe_repair(classification: str, attempts: list[Attempt]) -> str:
    if patch_common_swift_test_type_issue():
        return "patched Swift XCTest Set type comparison"

    if classification in {"router_not_visible_to_tests", "swift_access_control_failure"}:
        if patch_router_visibility():
            return "patched router visibility"

    return "no_safe_known_patch_available"

def write_summary(attempts: list[Attempt], repairs: list[str], destination_note: str) -> None:
    final = attempts[-1]
    status = "Green" if final.exit_code == 0 else "Yellow"

    lines: list[str] = [
        "# PROOFMODE-003 Layered Repair Until Green Summary",
        "",
        f"Status: {status}",
        "Issue: AMB-309",
        f"Created UTC: {utc_now()}",
        "",
        "## Destination",
        "",
        f"- {destination_note}",
        "",
        "## Repair Layers",
        "",
    ]

    for idx, attempt in enumerate(attempts, 1):
        lines += [
            f"### Layer {idx}: {attempt.layer}",
            "",
            f"- exit: {attempt.exit_code}",
            f"- classification: `{attempt.classification}`",
            f"- log: `{attempt.log_path.relative_to(ROOT)}`",
            f"- command: `{attempt.command}`",
            "",
            "Excerpt:",
            "",
        ]
        if attempt.excerpt:
            lines.extend(f"- {line}" for line in attempt.excerpt[:30])
        else:
            lines.append("- no targeted excerpt extracted")
        lines.append("")

    lines += [
        "## Repairs Applied",
        "",
    ]

    if repairs:
        lines.extend(f"- {repair}" for repair in repairs)
    else:
        lines.append("- none")

    lines += [
        "",
        "## Final Result",
        "",
        "Focused proof-mode test reached Green." if status == "Green" else "Focused proof-mode test remains Yellow. The committed excerpts above are the next repair source of truth.",
        "",
        "## Claims Not Made",
        "",
        "- No release readiness claim.",
        "- No TestFlight readiness claim.",
        "- No App Store readiness claim.",
        "- No device validation claim.",
        "- No accessibility validation claim.",
        "- No privacy/legal approval claim.",
        "- No full app-driving proof completion claim unless reviewed and Green.",
    ]

    SUMMARY.parent.mkdir(parents=True, exist_ok=True)
    SUMMARY.write_text("\n".join(lines) + "\n", encoding="utf-8")

def stage_and_commit() -> None:
    paths = [
        str(PROMPT.relative_to(ROOT)),
        str(SUMMARY.relative_to(ROOT)),
        "scripts/harness/ambitions_repair_until_green_proofmode_003.py",
    ]

    for candidate in [SOURCE, TEST]:
        if candidate.exists():
            paths.append(str(candidate.relative_to(ROOT)))

    git(["add", *paths])

    staged = git_text(["diff", "--cached", "--name-only"]).splitlines()
    forbidden = [
        p for p in staged
        if p.startswith("docs/truth/")
        or p.startswith("build/reports/")
        or p in {"project.yml", "Package.swift"}
    ]

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

    destination, destination_note = choose_destination()
    attempts: list[Attempt] = []
    repairs: list[str] = []

    attempts.append(xcodegen_generate("01-xcodegen-initial"))
    if attempts[-1].exit_code != 0:
        write_summary(attempts, repairs, destination_note)
        stage_and_commit()
        print("\nPush command:\n  git push origin main")
        return 0

    attempts.append(focused_test("02-focused-test-initial", destination))
    if attempts[-1].exit_code == 0:
        write_summary(attempts, repairs, destination_note)
        stage_and_commit()
        print("\nPush command:\n  git push origin main")
        return 0

    # Layer 3: apply safe compile/test repairs.
    repair = apply_safe_repair(attempts[-1].classification, attempts)
    repairs.append(repair)

    if repair != "no_safe_known_patch_available":
        attempts.append(xcodegen_generate("03-xcodegen-after-safe-repair"))
        if attempts[-1].exit_code == 0:
            attempts.append(focused_test("04-focused-test-after-safe-repair", destination))
            if attempts[-1].exit_code == 0:
                write_summary(attempts, repairs, destination_note)
                stage_and_commit()
                print("\nPush command:\n  git push origin main")
                return 0

    # Layer 5: retry class selector through full test target if selector was the blocker.
    attempts.append(
        run_logged(
            "05-full-ambitions-tests-proofmode-search",
            [
                "xcodebuild",
                "test",
                "-project", "Ambitions.xcodeproj",
                "-scheme", "Ambitions",
                "-destination", destination,
                "CODE_SIGNING_ALLOWED=NO",
            ],
        )
    )

    write_summary(attempts, repairs, destination_note)
    stage_and_commit()
    print("\nPush command:\n  git push origin main")
    print("\nAfter pushing, tell ChatGPT:\n  layered repair pushed")
    return 0

def install_prompt() -> None:
    write(PROMPT, """
    <!-- AMBITIONS_RUNNER_REQUIRED: true -->
    <!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
    <!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

    # PROOFMODE-003 — Layered Repair Until Green

    Issue: AMB-309

    ## Control Plane

    - Main-only execution.
    - Layered bounded repair loop.
    - No `docs/truth/*` edits.
    - No generated `build/reports/**` commits.
    - No production user-data mutation.
    - No cloud AI, analytics, backend, telemetry, tracking, signing, hosted CI, App Store automation, or production dependencies.
    - No release, TestFlight, App Store, device, accessibility, privacy/legal, or app-completion claims.
    """)

if __name__ == "__main__":
    raise SystemExit(main())
