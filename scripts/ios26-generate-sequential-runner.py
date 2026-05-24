#!/usr/bin/env python3
"""Generate the IOS26 sequential runner from the flagship manifest."""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MANIFEST = ROOT / "docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml"
RUNNER = ROOT / "scripts/ios26-flagship-run-sequential.sh"
RUNBOOK = ROOT / "docs/codex/IOS26_FLAGSHIP_SEQUENTIAL_RUNBOOK.md"
PROMPT_DIR = ROOT / "prompts/batches"
BATCH_RE = re.compile(r"(IOS26-T\d{2}[A-Z]?-B\d{2})")


def rel(path: Path) -> str:
    return str(path.relative_to(ROOT))


def parse_manifest() -> list[str]:
    batches: list[str] = []
    section = ""
    in_batches = False
    for raw in MANIFEST.read_text(encoding="utf-8").splitlines():
        line = raw.rstrip()
        stripped = line.strip()
        if stripped == "trains:":
            section = "trains"
            continue
        if section == "trains":
            if line.startswith("  - id: "):
                in_batches = False
            elif stripped == "batches:":
                in_batches = True
            elif in_batches and line.startswith("      - "):
                batches.append(stripped.removeprefix("- "))
    return batches


def prompt_for(batch_id: str) -> Path:
    matches = sorted(PROMPT_DIR.glob(f"{batch_id}-*.md"))
    if not matches:
        raise SystemExit(f"RED: missing prompt for {batch_id}")
    return matches[0]


def render_runner(batches: list[str]) -> str:
    lines = [
        "#!/usr/bin/env bash",
        "set -Eeuo pipefail",
        "",
        'ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"',
        'cd "$ROOT"',
        "",
        'LOG_ROOT="build/reports/ios26-flagship-sequential"',
        'mkdir -p "$LOG_ROOT"',
        'LOG="$LOG_ROOT/run-$(date -u +%Y%m%dT%H%M%SZ).log"',
        'REPO_INTELLIGENCE_PREFLIGHT="scripts/ambitions-repo-intelligence-preflight.py"',
        'REPO_INTELLIGENCE_SNAPSHOT="scripts/ambitions-repo-intelligence-snapshot.py"',
        'REPO_INTELLIGENCE_ENABLED="${REPO_INTELLIGENCE_ENABLED:-1}"',
        "",
        "for required in scripts/ambitions-codex-train.sh scripts/ios26-flagship-preflight.py scripts/ios26-flagship-proof-packet-check.py docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml; do",
        '  if [[ ! -f "$required" ]]; then',
        '    echo "RED: required IOS26 runner dependency missing: $required" | tee -a "$LOG"',
        "    exit 1",
        "  fi",
        "done",
        "",
        "repo_intelligence_sequence_preflight() {",
        '  if [[ "$REPO_INTELLIGENCE_ENABLED" != "1" || ! -f "$REPO_INTELLIGENCE_PREFLIGHT" ]]; then',
        '    echo "YELLOW: repo-intelligence preflight unavailable or disabled; continuing with existing IOS26 gates" | tee -a "$LOG"',
        "    return 0",
        "  fi",
        '  python3 "$REPO_INTELLIGENCE_PREFLIGHT" --json 2>&1 | tee -a "$LOG"',
        "  local status=${PIPESTATUS[0]}",
        '  case "$status" in',
        "    0)",
        '      echo "GREEN: repo-intelligence sequence preflight" | tee -a "$LOG"',
        "      ;;",
        "    2)",
        '      echo "YELLOW: optional repo-intelligence tools unavailable; continuing with fallback" | tee -a "$LOG"',
        "      ;;",
        "    *)",
        '      echo "RED: repo-intelligence hygiene preflight failed status=$status" | tee -a "$LOG"',
        '      exit "$status"',
        "      ;;",
        "  esac",
        "}",
        "",
        "repo_intelligence_batch_snapshot() {",
        '  local batch_id="$1"',
        '  local phase="$2"',
        '  if [[ "$REPO_INTELLIGENCE_ENABLED" != "1" || ! -f "$REPO_INTELLIGENCE_SNAPSHOT" ]]; then',
        '    echo "YELLOW: repo-intelligence snapshot unavailable or disabled for $batch_id phase=$phase" | tee -a "$LOG"',
        "    return 0",
        "  fi",
        '  python3 "$REPO_INTELLIGENCE_SNAPSHOT" --batch "$batch_id" --phase "$phase" --status GREEN 2>&1 | tee -a "$LOG"',
        "  local status=${PIPESTATUS[0]}",
        '  if [[ "$status" -ne 0 ]]; then',
        '    echo "RED: repo-intelligence snapshot failed for $batch_id phase=$phase status=$status" | tee -a "$LOG"',
        '    echo "NEXT_FAILED_BATCH=$batch_id" | tee -a "$LOG"',
        '    exit "$status"',
        "  fi",
        "}",
        "",
        "run_batch() {",
        '  local batch_id="$1"',
        '  local prompt="$2"',
        '  echo "RUNNING $batch_id $prompt" | tee -a "$LOG"',
        '  repo_intelligence_batch_snapshot "$batch_id" "pre"',
        '  python3 scripts/ios26-flagship-preflight.py --batch "$batch_id" 2>&1 | tee -a "$LOG"',
        "  local preflight_status=${PIPESTATUS[0]}",
        '  if [[ "$preflight_status" -ne 0 ]]; then',
        '    echo "FAILED preflight $batch_id status=$preflight_status" | tee -a "$LOG"',
        '    echo "NEXT_FAILED_BATCH=$batch_id" | tee -a "$LOG"',
        '    exit "$preflight_status"',
        "  fi",
        '  scripts/ambitions-codex-train.sh "$batch_id" "$prompt" 2>&1 | tee -a "$LOG"',
        "  local runner_status=${PIPESTATUS[0]}",
        '  if [[ "$runner_status" -ne 0 ]]; then',
        '    echo "FAILED runner $batch_id status=$runner_status" | tee -a "$LOG"',
        '    echo "NEXT_FAILED_BATCH=$batch_id" | tee -a "$LOG"',
        '    exit "$runner_status"',
        "  fi",
        '  python3 scripts/ios26-flagship-proof-packet-check.py --batch "$batch_id" 2>&1 | tee -a "$LOG"',
        "  local proof_status=${PIPESTATUS[0]}",
        '  if [[ "$proof_status" -ne 0 ]]; then',
        '    echo "FAILED proof-packet $batch_id status=$proof_status" | tee -a "$LOG"',
        '    echo "NEXT_FAILED_BATCH=$batch_id" | tee -a "$LOG"',
        '    exit "$proof_status"',
        "  fi",
        '  repo_intelligence_batch_snapshot "$batch_id" "post"',
        "}",
        "",
        "repo_intelligence_sequence_preflight",
        "",
    ]
    for batch in batches:
        lines.append(f"run_batch {batch} {rel(prompt_for(batch))}")
    lines.extend(
        [
            "",
            'echo "GREEN: IOS26 flagship sequence completed" | tee -a "$LOG"',
            'repo_intelligence_batch_snapshot "IOS26-SEQUENCE" "sequence-end"',
            "",
        ]
    )
    return "\n".join(lines)


def render_runbook(batches: list[str]) -> str:
    commands = "\n".join(f"scripts/ambitions-codex-train.sh {batch} {rel(prompt_for(batch))}" for batch in batches)
    return f"""# iOS 26 Flagship Sequential Runbook

Status: installed_not_run. Supporting note: this file supports current Ambitions work but does not override `docs/truth/`.

IOS26 now runs as a three-pass operating model:

1. Plan-freeze: `python3 scripts/ios26-plan-freeze.py`
2. Frozen implementation: `scripts/ios26-flagship-run-sequential.sh`
3. Review/compile/proof sweep: `python3 scripts/ios26-review-sweep.py`

Do not run the implementation pass until the plan-freeze artifacts and prompt hashes are current.

## Plan-Freeze Command

```bash
python3 scripts/ios26-plan-freeze.py
python3 scripts/ios26-generate-sequential-runner.py
python3 scripts/ios26-prompt-freeze-check.py --write
```

## Frozen Implementation Command

```bash
scripts/ios26-flagship-run-sequential.sh
```

For `IOS26-*` batches with prompt freeze hashes, `scripts/ambitions-codex-train.sh` replaces strategic Phase 01 replanning with Boundary Verification. Phase 02 may implement only the sealed work order. Phase 03 reviews actual diff, validation, proof, and no-claim boundaries. Repair remains allowed only inside the sealed boundary.

## Review Sweep Command

```bash
python3 scripts/ios26-review-sweep.py
```

## Replan Escape Hatch

Use `IOS26_REPLAN_ALLOWED=1` only when explicitly authorized to replan and refreeze an IOS26 prompt. After replanning, rerun the plan-freeze, generated-runner, and prompt-freeze commands.

## Prompt Freeze Hashes

Frozen hashes live at `docs/codex/ios26/IOS26_PROMPT_FREEZE_HASHES.json`. Frozen implementation fails when a prompt hash differs unless `IOS26_REPLAN_ALLOWED=1`.

## Generated Sequential Runner

`scripts/ios26-flagship-run-sequential.sh` is generated from `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`; do not hand-maintain batch lines. The generated runner calls:

```bash
python3 scripts/ios26-flagship-preflight.py --batch "$batch_id"
scripts/ambitions-codex-train.sh "$batch_id" "$prompt"
python3 scripts/ios26-flagship-proof-packet-check.py --batch "$batch_id"
```

## Stop Rules

- Stop on Red.
- Never skip Train 0.
- Do not run source-changing trains until Train 0 baseline artifacts exist.
- Do not weaken `stop_on_red`.
- Continue on Yellow only with owner, reason, no-claim boundary, follow-up gate, and affected files.

## Proof Expectations

Proof is written under the manifest proof roots plus `build/reports/ios26-flagship-sequential/`, `build/reports/ios26-planning/`, and `build/reports/ios26-review-sweep/`. Simulator/local proof is not release, TestFlight, App Store, device, public accessibility, performance, privacy/legal, or CI proof.

## No-Claim Boundaries

Do not claim release readiness, TestFlight readiness, App Store readiness, accessibility verification, performance validation, privacy/legal approval, Private Life Runtime moat completion, or implementation completion without current source, test, and proof evidence.

## Full Sequence

```bash
{commands}
```

## Optional Autonomous Loop

The optional sequential script is `scripts/ios26-flagship-run-sequential.sh`. It uses the generated manifest order, stops on the first nonzero exit, writes logs under `build/reports/ios26-flagship-sequential/`, and does not auto-push, auto-release, sign, upload, or bypass the runner.
"""


def check(batches: list[str]) -> int:
    expected = render_runner(batches)
    issues: list[str] = []
    if not RUNNER.exists():
        issues.append(f"missing {rel(RUNNER)}")
    elif RUNNER.read_text(encoding="utf-8") != expected:
        issues.append(f"{rel(RUNNER)} is not generated from manifest")
    if RUNBOOK.exists():
        text = RUNBOOK.read_text(encoding="utf-8")
        for batch in batches:
            if f"scripts/ambitions-codex-train.sh {batch} " not in text:
                issues.append(f"runbook missing {batch}")
    else:
        issues.append(f"missing {rel(RUNBOOK)}")
    if issues:
        for issue in issues:
            print(f"RED: {issue}")
        return 1
    print(f"GREEN: IOS26 sequential runner matches manifest batches={len(batches)}")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    batches = parse_manifest()
    if args.check:
        return check(batches)
    RUNNER.write_text(render_runner(batches), encoding="utf-8")
    RUNNER.chmod(0o755)
    RUNBOOK.write_text(render_runbook(batches), encoding="utf-8")
    print(f"GREEN: generated IOS26 sequential runner batches={len(batches)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
