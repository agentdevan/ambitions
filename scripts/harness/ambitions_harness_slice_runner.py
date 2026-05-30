#!/usr/bin/env python3
"""Run Ambitions harness upgrade slices on main.

This runner is intentionally local-first and main-only. It writes repo files,
commits each slice locally, and never pushes.

Usage:
  python3 scripts/harness/ambitions_harness_slice_runner.py --slice 1
  python3 scripts/harness/ambitions_harness_slice_runner.py --all

Non-claims: this runner does not prove app behavior, build success, test success,
release readiness, accessibility, device validation, privacy/legal approval,
TestFlight readiness, or App Store readiness.
"""

from __future__ import annotations

import argparse
import json
import os
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path
from textwrap import dedent

ROOT = Path(__file__).resolve().parents[2]

SLICE_ISSUES = {
    1: ("AMB-300", "HARNESS-SLICE-001", "Lock Slice 1 harness baseline"),
    2: ("AMB-301", "HARNESS-SLICE-002", "Harden harness artifact hygiene"),
    3: ("AMB-302", "HARNESS-SLICE-003", "Install app-driving proof mode"),
    4: ("AMB-303", "HARNESS-SLICE-004", "Add failure attribution and repair routing"),
    5: ("AMB-304", "HARNESS-SLICE-005", "Add independent review and adversarial gates"),
    6: ("AMB-305", "HARNESS-SLICE-006", "Add task-state resume system"),
    7: ("AMB-306", "HARNESS-SLICE-007", "Integrate Linear, GitHub, and harness OS"),
}

FORBIDDEN_PREFIXES = ("Native/", "Sources/", "AppUI/", "Ambitions.xcodeproj/", "docs/truth/")
FORBIDDEN_EXACT = {"Package.swift", "project.yml"}


def utc_now() -> str:
    return datetime.now(timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")


def run(args: list[str], *, check: bool = True) -> subprocess.CompletedProcess[str]:
    proc = subprocess.run(args, cwd=ROOT, text=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=False)
    if check and proc.returncode != 0:
        sys.stderr.write(proc.stdout)
        sys.stderr.write(proc.stderr)
        raise SystemExit(proc.returncode)
    return proc


def git(args: list[str], *, check: bool = True) -> subprocess.CompletedProcess[str]:
    return run(["git", *args], check=check)


def git_text(args: list[str]) -> str:
    return git(args).stdout.strip()


def require_main_clean() -> None:
    branch = git_text(["branch", "--show-current"])
    if branch != "main":
        raise SystemExit(f"Expected main-only execution. Current branch: {branch}")
    status = git_text(["status", "--porcelain"])
    if status:
        print(status)
        raise SystemExit("Worktree must be clean before running a harness slice.")


def write(path: str, content: str) -> None:
    p = ROOT / path
    p.parent.mkdir(parents=True, exist_ok=True)
    p.write_text(dedent(content).lstrip("\n"), encoding="utf-8")


def append_unique(path: str, lines: list[str]) -> None:
    p = ROOT / path
    current = p.read_text(encoding="utf-8") if p.exists() else ""
    new = current
    for line in lines:
        if line not in new.splitlines():
            if new and not new.endswith("\n"):
                new += "\n"
            new += line + "\n"
    if new != current:
        p.write_text(new, encoding="utf-8")


def stage(paths: list[str]) -> None:
    git(["add", *paths])


def staged_paths() -> list[str]:
    out = git_text(["diff", "--cached", "--name-only"])
    return [line for line in out.splitlines() if line]


def validate_staged(paths: list[str], *, allow_source: bool = False, allow_dot_codex_state: bool = False) -> None:
    for path in paths:
        if path in FORBIDDEN_EXACT or path.startswith("docs/truth/"):
            raise SystemExit(f"Forbidden staged path: {path}")
        if not allow_source and any(path.startswith(prefix) for prefix in FORBIDDEN_PREFIXES if prefix != "docs/truth/"):
            raise SystemExit(f"Source/config staged path not allowed for this slice: {path}")
        if path.startswith(".codex/state/") and not allow_dot_codex_state:
            raise SystemExit(f".codex state path not allowed for this slice: {path}")
        if path.startswith("build/reports/"):
            raise SystemExit(f"Generated report path must not be committed: {path}")


def commit(message: str, *, allow_source: bool = False, allow_dot_codex_state: bool = False) -> None:
    paths = staged_paths()
    if not paths:
        print(f"No staged changes for {message}; skipping commit.")
        return
    validate_staged(paths, allow_source=allow_source, allow_dot_codex_state=allow_dot_codex_state)
    git(["commit", "-m", message])
    print(git_text(["log", "-1", "--oneline"]))


def make_prompt(slice_n: int) -> str:
    issue, batch, title = SLICE_ISSUES[slice_n]
    return f"""<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# {batch} — {title}

Issue: {issue}

## Control Plane

- Main-only execution.
- Use active truth files and AGENTS.md as authority.
- Do not edit `docs/truth/*`.
- Do not commit generated `build/reports/**` runtime output.
- Do not make release, TestFlight, App Store, device, accessibility, privacy/legal, or app-completion claims.
"""


def slice1() -> None:
    write("prompts/batches/HARNESS-SLICE-001-lock-baseline.md", make_prompt(1))
    write("docs/codex/harness/HARNESS_SLICE_1_CLOSEOUT.md", """
    # Harness Slice 1 Closeout

    Status: Baseline locked
    Issue: AMB-300

    ## What Slice 1 Installed

    - Active canon cleanup and stale-doc quarantine posture.
    - Artifact manifest schema.
    - Proof wrapper scripts.
    - Static gates.
    - First proof wrapper run.
    - App-driving proof path decision.
    - Generated residue cleanup.

    ## Green / Yellow / Red State

    | Area | Status | Evidence |
    | --- | --- | --- |
    | Canon cleanup | Green | AMB-291 closeout and canon-collapse reports |
    | Artifact manifest schema | Green | `docs/codex/harness/HARNESS_ARTIFACT_SCHEMA.md` |
    | Proof wrapper scripts | Green | `scripts/harness/ambitions-proof-baseline.sh` and `scripts/harness/ambitions-xcresult-summary.py` |
    | Static gates | Green | `scripts/harness/ambitions-*-gate.py` |
    | First proof wrapper run | Yellow | `docs/proof/harness/AMB-297-first-proof-wrapper-run-summary.md` |
    | App-driving proof decision | Yellow | `docs/codex/harness/AMB-298-app-driving-proof-decision.md` |

    ## Known Yellow

    AMB-297 recorded build wrapper exit `65`. Slice 1 therefore does not claim app build proof or test proof.

    ## Claims Not Made

    - No app implementation completion claim.
    - No build success claim.
    - No test success claim.
    - No accessibility validation claim.
    - No performance validation claim.
    - No device validation claim.
    - No privacy/legal approval claim.
    - No TestFlight claim.
    - No App Store claim.
    - No release readiness claim.
    """)
    stage(["prompts/batches/HARNESS-SLICE-001-lock-baseline.md", "docs/codex/harness/HARNESS_SLICE_1_CLOSEOUT.md"])
    commit("AMB-300 lock Slice 1 harness baseline")


def slice2() -> None:
    append_unique(".gitignore", ["build/reports/harness/", "build/reports/parallel-implementation-guard/"])
    write("prompts/batches/HARNESS-SLICE-002-artifact-hygiene.md", make_prompt(2))
    write("docs/codex/harness/HARNESS_ARTIFACT_HYGIENE.md", """
    # Harness Artifact Hygiene

    Status: Active support protocol
    Issue: AMB-301

    Runtime-generated harness packets belong under `build/reports/harness/**` and are ignored by default. Committed proof packets belong under `docs/proof/harness/**` only when a slice explicitly promotes them as durable evidence.

    ## Rules

    - Do not commit generated `build/reports/**` output.
    - Commit small durable proof summaries under `docs/proof/harness/**` when a slice requires evidence.
    - Docs/tooling slices must not stage app source, `project.yml`, `Package.swift`, Xcode project output, or `docs/truth/*`.
    - Cleanup tools must be main-only and path-limited.

    ## Claims Not Made

    This protocol does not prove app behavior, build success, tests, accessibility, privacy/legal, device validation, TestFlight, App Store, or release readiness.
    """)
    write("scripts/harness/ambitions-harness-scope-check.py", r'''
    #!/usr/bin/env python3
    from __future__ import annotations
    import argparse, subprocess, sys
    FORBIDDEN_PREFIXES = ("Native/", "Sources/", "AppUI/", "Ambitions.xcodeproj/", "docs/truth/", "build/reports/")
    FORBIDDEN_EXACT = {"Package.swift", "project.yml"}
    def git(args):
        return subprocess.check_output(["git", *args], text=True).strip()
    def main():
        parser = argparse.ArgumentParser()
        parser.add_argument("--staged", action="store_true")
        parser.add_argument("--allow-source", action="store_true")
        args = parser.parse_args()
        cmd = ["diff", "--cached", "--name-only"] if args.staged else ["status", "--porcelain"]
        out = git(cmd)
        paths = []
        for line in out.splitlines():
            paths.append(line if args.staged else line[3:])
        bad = []
        for p in paths:
            if p in FORBIDDEN_EXACT or p.startswith("docs/truth/") or p.startswith("build/reports/"):
                bad.append(p)
            elif not args.allow_source and any(p.startswith(x) for x in FORBIDDEN_PREFIXES if x not in {"docs/truth/", "build/reports/"}):
                bad.append(p)
        if bad:
            print("Forbidden paths:")
            print("\n".join(bad))
            return 1
        print("Scope check passed")
        return 0
    if __name__ == "__main__":
        raise SystemExit(main())
    ''')
    write("scripts/harness/ambitions-harness-clean.py", r'''
    #!/usr/bin/env python3
    from __future__ import annotations
    import shutil, subprocess
    from pathlib import Path
    ROOT = Path(__file__).resolve().parents[2]
    def main():
        branch = subprocess.check_output(["git", "branch", "--show-current"], cwd=ROOT, text=True).strip()
        if branch != "main":
            raise SystemExit(f"Expected main, got {branch}")
        shutil.rmtree(ROOT / "build" / "reports" / "harness", ignore_errors=True)
        print("Removed generated build/reports/harness runtime output if present.")
        return 0
    if __name__ == "__main__":
        raise SystemExit(main())
    ''')
    stage([".gitignore", "prompts/batches/HARNESS-SLICE-002-artifact-hygiene.md", "docs/codex/harness/HARNESS_ARTIFACT_HYGIENE.md", "scripts/harness/ambitions-harness-scope-check.py", "scripts/harness/ambitions-harness-clean.py"])
    commit("AMB-301 harden harness artifact hygiene")


def slice3() -> None:
    write("prompts/batches/HARNESS-SLICE-003-app-driving-proof.md", make_prompt(3))
    write("docs/codex/harness/HARNESS_APP_DRIVING_PROOF.md", """
    # Harness App-Driving Proof

    Status: Yellow proof-mode plan installed
    Issue: AMB-302

    ## Decision

    The harness now records the required app-driving proof contract. It does not yet claim the app-driving moat proof is complete.

    ## Required Moat Scenario

    - Same user intent.
    - Two different local contexts.
    - Deterministically different Start Here / Reality Meridian outputs.
    - Proof/freshness/receipt/closure/replay artifacts.
    - Protected-time and local-only/privacy boundaries.

    ## Current Slice 3 Result

    Yellow: source seams for a production-safe proof-mode launch router still need bounded app-source implementation. This document and fixture define the required proof contract without silently mutating user data.

    ## Claims Not Made

    - No app-driving proof completion claim.
    - No app implementation completion claim.
    - No build success claim.
    - No test success claim.
    - No release readiness claim.
    """)
    write("docs/codex/harness/app-driving-proof-fixtures.json", json.dumps({
        "schema_version": "app-driving-proof-fixtures.v1",
        "issue": "AMB-302",
        "scenario": "same_intent_two_local_contexts",
        "intent": "prepare for a certification exam without burning out",
        "contexts": [
            {"id": "protected_time_heavy", "protected_time_minutes": 420, "energy": "low", "expected_recommendation_shape": "recovery-aware short step"},
            {"id": "open_deep_work_window", "protected_time_minutes": 60, "energy": "medium", "expected_recommendation_shape": "longer focused step"},
        ],
        "status": "Yellow",
        "claims_not_made": ["No app-driving proof completion claim", "No app build claim", "No release readiness claim"],
    }, indent=2) + "\n")
    write("scripts/harness/ambitions-app-driving-proof.py", r'''
    #!/usr/bin/env python3
    from __future__ import annotations
    import json
    from pathlib import Path
    ROOT = Path(__file__).resolve().parents[2]
    def main():
        fixture = ROOT / "docs/codex/harness/app-driving-proof-fixtures.json"
        payload = json.loads(fixture.read_text())
        print(json.dumps({
            "status": "Yellow",
            "reason": "Proof contract installed; bounded app-source launch router still required.",
            "fixture": str(fixture.relative_to(ROOT)),
            "claims_not_made": payload["claims_not_made"],
        }, indent=2))
        return 0
    if __name__ == "__main__":
        raise SystemExit(main())
    ''')
    stage(["prompts/batches/HARNESS-SLICE-003-app-driving-proof.md", "docs/codex/harness/HARNESS_APP_DRIVING_PROOF.md", "docs/codex/harness/app-driving-proof-fixtures.json", "scripts/harness/ambitions-app-driving-proof.py"])
    commit("AMB-302 install app-driving proof contract")


def slice4() -> None:
    write("prompts/batches/HARNESS-SLICE-004-failure-routing.md", make_prompt(4))
    write("docs/codex/harness/HARNESS_FAILURE_TAXONOMY.md", """
    # Harness Failure Taxonomy

    Status: Active support taxonomy
    Issue: AMB-303

    ## Failure Classes

    - `prompt_scope_failure`
    - `missing_source_truth`
    - `build_tooling_failure`
    - `test_failure`
    - `product_canon_drift`
    - `architecture_drift`
    - `claim_drift`
    - `artifact_hygiene_failure`
    - `app_driving_proof_failure`

    Each Yellow or Red packet should map to one class plus a next repair action.
    """)
    write("scripts/harness/ambitions-failure-classifier.py", r'''
    #!/usr/bin/env python3
    from __future__ import annotations
    import argparse, json
    from pathlib import Path
    RULES = [
        ("build_tooling_failure", ["build exit", "xcodebuild", "exit 65"]),
        ("artifact_hygiene_failure", ["build/reports", "generated residue"]),
        ("claim_drift", ["release ready", "app store ready", "testflight ready"]),
        ("product_canon_drift", ["next best move", "top-level plan"]),
        ("app_driving_proof_failure", ["app-driving", "proof-mode"]),
    ]
    def classify(text: str):
        lower = text.lower()
        for name, needles in RULES:
            if any(n in lower for n in needles):
                return name
        return "unclassified_yellow"
    def main():
        ap = argparse.ArgumentParser()
        ap.add_argument("path")
        ap.add_argument("--json", action="store_true")
        args = ap.parse_args()
        text = Path(args.path).read_text(encoding="utf-8", errors="ignore")
        cls = classify(text)
        payload = {"status": "Yellow", "failure_class": cls, "next_repair_action": f"Open a bounded repair issue for {cls}.", "claims_not_made": ["No release readiness claim"]}
        print(json.dumps(payload, indent=2) if args.json else payload)
        return 0
    if __name__ == "__main__":
        raise SystemExit(main())
    ''')
    stage(["prompts/batches/HARNESS-SLICE-004-failure-routing.md", "docs/codex/harness/HARNESS_FAILURE_TAXONOMY.md", "scripts/harness/ambitions-failure-classifier.py"])
    commit("AMB-303 add failure attribution and repair routing")


def slice5() -> None:
    write("prompts/batches/HARNESS-SLICE-005-independent-review.md", make_prompt(5))
    write("docs/codex/harness/HARNESS_REVIEW_PROTOCOL.md", """
    # Harness Review Protocol

    Status: Active support protocol
    Issue: AMB-304

    The implementer packet and reviewer packet are separate. Review must record changed files, scope class, claims made, claims not made, proof gaps, Yellow/Red items, and human closeout notes.
    """)
    write("scripts/harness/ambitions-diff-classifier.py", r'''
    #!/usr/bin/env python3
    from __future__ import annotations
    import subprocess, json
    def main():
        files = subprocess.check_output(["git", "diff", "--name-only", "HEAD~1..HEAD"], text=True).splitlines()
        classes = []
        for f in files:
            if f.startswith("Native/") or f.startswith("Sources/"):
                kind = "source"
            elif f.startswith("docs/"):
                kind = "docs"
            elif f.startswith("scripts/"):
                kind = "tooling"
            else:
                kind = "other"
            classes.append({"path": f, "class": kind})
        print(json.dumps({"files": classes, "claims_not_made": ["No release readiness claim"]}, indent=2))
    if __name__ == "__main__":
        raise SystemExit(main())
    ''')
    write("scripts/harness/ambitions-review-packet.py", r'''
    #!/usr/bin/env python3
    from __future__ import annotations
    import json, subprocess
    from datetime import datetime, timezone
    def main():
        sha = subprocess.check_output(["git", "rev-parse", "HEAD"], text=True).strip()
        files = subprocess.check_output(["git", "diff", "--name-only", "HEAD~1..HEAD"], text=True).splitlines()
        print(json.dumps({"created_at_utc": datetime.now(timezone.utc).isoformat(), "reviewed_sha": sha, "changed_files": files, "status": "Yellow", "claims_not_made": ["No release readiness claim", "No app completion claim"]}, indent=2))
    if __name__ == "__main__":
        raise SystemExit(main())
    ''')
    stage(["prompts/batches/HARNESS-SLICE-005-independent-review.md", "docs/codex/harness/HARNESS_REVIEW_PROTOCOL.md", "scripts/harness/ambitions-diff-classifier.py", "scripts/harness/ambitions-review-packet.py"])
    commit("AMB-304 add independent review and adversarial gates")


def slice6() -> None:
    write("prompts/batches/HARNESS-SLICE-006-task-state-resume.md", make_prompt(6))
    write("docs/codex/harness/HARNESS_RESUME_PROTOCOL.md", """
    # Harness Resume Protocol

    Status: Active support protocol
    Issue: AMB-305

    A fresh session should inspect branch, SHA, dirty worktree, active harness slice, next eligible slice, blocked reason, resume command, rollback command, and proof packet status.
    """)
    state = {"schema_version": "harness-state.v1", "updated_at_utc": utc_now(), "active_project": "HARNESS-10-10-001", "last_completed_slice": 5, "next_eligible_slice": 6, "claims_not_made": ["No release readiness claim"]}
    write(".codex/state/harness-state.json", json.dumps(state, indent=2) + "\n")
    write("scripts/harness/ambitions-harness-state.py", r'''
    #!/usr/bin/env python3
    from __future__ import annotations
    import json, subprocess
    from pathlib import Path
    ROOT = Path(__file__).resolve().parents[2]
    def main():
        state_path = ROOT / ".codex/state/harness-state.json"
        state = json.loads(state_path.read_text()) if state_path.exists() else {}
        state["branch"] = subprocess.check_output(["git", "branch", "--show-current"], cwd=ROOT, text=True).strip()
        state["sha"] = subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=ROOT, text=True).strip()
        state["dirty"] = bool(subprocess.check_output(["git", "status", "--porcelain"], cwd=ROOT, text=True).strip())
        state["resume_command"] = "python3 scripts/harness/ambitions_harness_slice_runner.py --slice <next>"
        state["rollback_command"] = "git revert <sha>"
        print(json.dumps(state, indent=2))
        return 0
    if __name__ == "__main__":
        raise SystemExit(main())
    ''')
    stage(["prompts/batches/HARNESS-SLICE-006-task-state-resume.md", "docs/codex/harness/HARNESS_RESUME_PROTOCOL.md", ".codex/state/harness-state.json", "scripts/harness/ambitions-harness-state.py"])
    commit("AMB-305 add task-state resume system", allow_dot_codex_state=True)


def slice7() -> None:
    write("prompts/batches/HARNESS-SLICE-007-operating-system.md", make_prompt(7))
    write("docs/codex/harness/HARNESS_OPERATING_SYSTEM.md", """
    # Harness Operating System

    Status: Active support protocol
    Issue: AMB-306

    The harness operating layer integrates Linear issue mapping, GitHub commit verification, local runner commands, proof packets, next eligible work, and closeout templates. Linear and GitHub mirror execution state; product truth remains in `docs/truth/*` and AGENTS.md.
    """)
    write("docs/codex/harness/HARNESS_PROOF_INDEX.md", """
    # Harness Proof Index

    Status: Active support index

    - Slice 1 closeout: `docs/codex/harness/HARNESS_SLICE_1_CLOSEOUT.md`
    - First proof wrapper run: `docs/proof/harness/AMB-297-first-proof-wrapper-run-summary.md`
    - App-driving proof decision: `docs/codex/harness/AMB-298-app-driving-proof-decision.md`
    """)
    write("scripts/harness/ambitions-harness-next.py", r'''
    #!/usr/bin/env python3
    from __future__ import annotations
    import json
    from pathlib import Path
    ROOT = Path(__file__).resolve().parents[2]
    def main():
        state_path = ROOT / ".codex/state/harness-state.json"
        state = json.loads(state_path.read_text()) if state_path.exists() else {}
        next_slice = state.get("next_eligible_slice", 7)
        print(json.dumps({"next_eligible_slice": next_slice, "command": f"python3 scripts/harness/ambitions_harness_slice_runner.py --slice {next_slice}", "claims_not_made": ["No release readiness claim"]}, indent=2))
        return 0
    if __name__ == "__main__":
        raise SystemExit(main())
    ''')
    write("scripts/harness/ambitions-linear-closeout-template.py", r'''
    #!/usr/bin/env python3
    from __future__ import annotations
    import argparse, subprocess
    def main():
        ap = argparse.ArgumentParser()
        ap.add_argument("issue")
        ap.add_argument("status", choices=["Green", "Yellow", "Red"])
        args = ap.parse_args()
        sha = subprocess.check_output(["git", "rev-parse", "HEAD"], text=True).strip()
        files = subprocess.check_output(["git", "diff", "--name-only", "HEAD~1..HEAD"], text=True).splitlines()
        print(f"Verified {args.issue}\n\nCommit: `{sha}`\nStatus: {args.status}\n\nChanged files:\n" + "\n".join(f"- `{f}`" for f in files) + "\n\nClaims not made: no release/app/TestFlight/App Store/device/accessibility/privacy/legal readiness claim.")
        return 0
    if __name__ == "__main__":
        raise SystemExit(main())
    ''')
    stage(["prompts/batches/HARNESS-SLICE-007-operating-system.md", "docs/codex/harness/HARNESS_OPERATING_SYSTEM.md", "docs/codex/harness/HARNESS_PROOF_INDEX.md", "scripts/harness/ambitions-harness-next.py", "scripts/harness/ambitions-linear-closeout-template.py"])
    commit("AMB-306 integrate Linear GitHub and harness OS")


SLICE_FUNCS = {1: slice1, 2: slice2, 3: slice3, 4: slice4, 5: slice5, 6: slice6, 7: slice7}


def main() -> int:
    parser = argparse.ArgumentParser()
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("--slice", type=int, choices=range(1, 8))
    group.add_argument("--all", action="store_true")
    args = parser.parse_args()

    require_main_clean()
    targets = range(1, 8) if args.all else [args.slice]
    for n in targets:
        print(f"\n==> Running harness slice {n}: {SLICE_ISSUES[n][0]} {SLICE_ISSUES[n][2]}")
        SLICE_FUNCS[n]()
        require_main_clean()

    print("\nHarness slice runner complete.")
    print("Push command: git push origin main")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
