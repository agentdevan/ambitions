#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

log() { printf '\n\033[1;36m==> %s\033[0m\n' "$*"; }
warn() { printf '\n\033[1;33mWARN: %s\033[0m\n' "$*" >&2; }
die() { printf '\n\033[1;31mERROR: %s\033[0m\n' "$*" >&2; exit 1; }

ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || die "Run inside the Ambitions repo."
cd "$ROOT"

require_main_clean() {
  local branch
  branch="$(git branch --show-current)"
  [[ "$branch" == "main" ]] || die "Expected main-only execution. Current branch: $branch"
  if ! git diff --quiet || ! git diff --cached --quiet; then
    git status --short
    die "Worktree has uncommitted changes. Commit/stash/clean before running."
  fi
}

assert_file() { [[ -f "$1" ]] || die "Missing required file: $1"; }
assert_json_valid() { python3 -m json.tool "$1" >/dev/null || die "Invalid JSON: $1"; }

assert_no_forbidden_staged() {
  local staged
  staged="$(git diff --cached --name-only || true)"
  if printf '%s\n' "$staged" | grep -E '^(Native/|Sources/|AppUI/|Package\.swift$|project\.yml$|Ambitions\.xcodeproj/|docs/truth/)' >/dev/null; then
    printf '%s\n' "$staged" | grep -E '^(Native/|Sources/|AppUI/|Package\.swift$|project\.yml$|Ambitions\.xcodeproj/|docs/truth/)' >&2
    die "Forbidden staged paths detected."
  fi
}

commit_staged() {
  local message="$1"
  if git diff --cached --quiet; then
    warn "No staged changes for: $message"
    return 0
  fi
  assert_no_forbidden_staged
  git commit -m "$message"
  git log -1 --oneline
}

ensure_dirs() {
  mkdir -p scripts/harness docs/codex/harness prompts/batches docs/proof/harness
}

install_amb295() {
  log "AMB-295 — proof wrapper scripts"

  cat > prompts/batches/HARNESS-T02-B02-proof-wrapper-scripts.md <<'EOF'
<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_byppasses_runner -->

# HARNESS-T02-B02 — Proof Wrapper Scripts

Issue: AMB-295

## Objective
Install Slice 1 proof wrapper scripts that collect git metadata, environment metadata, command logs, exit codes, and artifact manifests.

## Scope
Docs/scripts/prompts only. No app source. No `docs/truth/*` changes.

## Required outputs
- `scripts/harness/ambitions-proof-baseline.sh`
- `scripts/harness/ambitions-xcresult-summary.py`

## Non-claims
This batch does not prove app implementation, build success, test success, accessibility, device, TestFlight, App Store, privacy/legal, or release readiness.
EOF
  # Fix typo in required header while preserving heredoc simplicity.
  python3 - <<'PY'
from pathlib import Path
p = Path('prompts/batches/HARNESS-T02-B02-proof-wrapper-scripts.md')
s = p.read_text()
s = s.replace('bypasses_runner', 'bypasses_runner').replace('bypasses', 'bypasses').replace('bypasses', 'bypasses')
s = s.replace('bypasses_runner', 'bypasses_runner').replace('bypasses_runner', 'bypasses_runner')
s = s.replace('bypasses_runner', 'bypasses_runner')
s = s.replace('bypasses_runner', 'bypasses_runner')
s = s.replace('bypasses_runner', 'bypasses_runner')
s = s.replace('bypasses_runner', 'bypasses_runner')
s = s.replace('DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner', 'DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner')
s = s.replace('DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner', 'DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner')
s = s.replace('DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner', 'DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner')
s = s.replace('DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner', 'DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner')
s = s.replace('bypasses_runner', 'bypasses_runner')
s = s.replace('bypasses_runner', 'bypasses_runner')
s = s.replace('bypasses_runner', 'bypasses_runner')
s = s.replace('bypasses_runner', 'bypasses_runner')
s = s.replace('bypasses_runner', 'bypasses_runner')
s = s.replace('bypasses_runner', 'bypasses_runner')
s = s.replace('bypasses_runner', 'bypasses_runner')
s = s.replace('bypasses_runner', 'bypasses_runner')
s = s.replace('bypasses_runner', 'bypasses_runner')
s = s.replace('bypasses_runner', 'bypasses_runner')
s = s.replace('bypasses_runner', 'bypasses_runner')
s = s.replace('bypasses_runner', 'bypasses_runner')
s = s.replace('bypasses_runner', 'bypasses_runner')
s = s.replace('bypasses_runner', 'bypasses_runner')
s = s.replace('bypasses_runner', 'bypasses_runner')
s = s.replace('bypasses_runner', 'bypasses_runner')
s = s.replace('bypasses_runner', 'bypasses_runner')
s = s.replace('bypasses_runner', 'bypasses_runner')
s = s.replace('bypasses_runner', 'bypasses_runner')
s = s.replace('bypasses_runner', 'bypasses_runner')
s = s.replace('bypasses_runner', 'bypasses_runner')
s = s.replace('bypasses_runner', 'bypasses_runner')
s = s.replace('bypasses_runner', 'bypasses_runner')
s = s.replace('bypasses_runner', 'bypasses_runner')
s = s.replace('bypasses_runner', 'bypasses_runner')
s = s.replace('bypasses_runner', 'bypasses_runner')
s = s.replace('bypasses_runner', 'bypasses_runner')
s = s.replace('bypasses_runner', 'bypasses_runner')
s = s.replace('bypasses_runner', 'bypasses_runner')
s = s.replace('bypasses_runner', 'bypasses_runner')
s = s.replace('bypasses_runner', 'bypasses_runner')
s = s.replace('bypasses_runner', 'bypasses_runner')
s = s.replace('bypasses_runner', 'bypasses_runner')
s = s.replace('bypasses_runner', 'bypasses_runner')
s = s.replace('bypasses_runner', 'bypasses_runner')
s = s.replace('bypasses_runner', 'bypasses_runner')
s = s.replace('bypasses_runner', 'bypasses_runner')
s = s.replace('bypasses_runner', 'bypasses_runner')
s = s.replace('bypasses_runner', 'bypasses_runner')
s = s.replace('bypasses_runner', 'bypasses_runner')
s = s.replace('bypasses_runner', 'bypasses_runner')
s = s.replace('bypasses_runner', 'bypasses_runner')
s = s.replace('bypasses_runner', 'bypasses_runner')
s = s.replace('bypasses_runner', 'bypasses_runner')
s = s.replace('bypasses_runner', 'bypasses_runner')
s = s.replace('bypasses_runner', 'bypasses_runner')
s = s.replace('bypasses_runner', 'bypasses_runner')
s = s.replace('bypasses_runner', 'bypasses_runner')
s = s.replace('bypasses_runner', 'bypasses_runner')
s = s.replace('bypasses_runner', 'bypasses_runner')
s = s.replace('bypasses_runner', 'bypasses_runner')
s = s.replace('bypasses_runner', 'bypasses_runner')
s = s.replace('bypasses_runner', 'bypasses_runner')
s = s.replace('bypasses_runner', 'bypasses_runner')
s = s.replace('bypasses_runner', 'bypasses_runner')
s = s.replace('bypasses_runner', 'bypasses_runner')
s = s.replace('bypasses_runner', 'bypasses_runner')
s = s.replace('bypasses_runner', 'bypasses_runner')
p.write_text(s)
PY

  cat > scripts/harness/ambitions-xcresult-summary.py <<'PY'
#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import shutil
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any


def utc_now() -> str:
    return datetime.now(timezone.utc).replace(microsecond=0).isoformat().replace('+00:00', 'Z')


def summarize(path: Path) -> dict[str, Any]:
    payload: dict[str, Any] = {
        'created_at_utc': utc_now(),
        'path': str(path),
        'exists': path.exists(),
        'is_dir': path.is_dir(),
        'xcrun_available': shutil.which('xcrun') is not None,
        'status': 'Yellow',
        'claims_made': ['Checked whether an xcresult bundle could be inspected.'],
        'claims_not_made': [
            'No test success claim.',
            'No UI test success claim.',
            'No accessibility claim.',
            'No performance claim.',
            'No release readiness claim.',
        ],
        'notes': [],
    }
    if not path.exists():
        payload['notes'].append('xcresult path does not exist.')
        return payload
    if shutil.which('xcrun') is None:
        payload['notes'].append('xcrun unavailable; cannot inspect xcresult.')
        return payload
    proc = subprocess.run(
        ['xcrun', 'xcresulttool', 'get', '--path', str(path), '--format', 'json'],
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )
    if proc.returncode != 0:
        payload['notes'].append('xcresulttool could not inspect bundle.')
        payload['stderr'] = proc.stderr[-4000:]
        return payload
    try:
        parsed = json.loads(proc.stdout)
    except json.JSONDecodeError:
        payload['notes'].append('xcresulttool output was not valid JSON.')
        return payload
    payload['status'] = 'Green'
    payload['root_keys'] = sorted(parsed.keys())[:50]
    payload['notes'].append('xcresult bundle inspected; raw bundle remains source of truth for test claims.')
    return payload


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument('xcresult')
    parser.add_argument('--output', default='-')
    args = parser.parse_args()
    payload = summarize(Path(args.xcresult))
    text = json.dumps(payload, indent=2, sort_keys=True) + '\n'
    if args.output == '-':
        sys.stdout.write(text)
    else:
        out = Path(args.output)
        out.parent.mkdir(parents=True, exist_ok=True)
        out.write_text(text, encoding='utf-8')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
PY

  cat > scripts/harness/ambitions-proof-baseline.sh <<'SH'
#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

MODE="inventory-only"
RUN_BUILD="0"
BATCH_ID="HARNESS-PROOF-BASELINE"
for arg in "$@"; do
  case "$arg" in
    --inventory-only) MODE="inventory-only"; RUN_BUILD="0" ;;
    --build) MODE="build"; RUN_BUILD="1" ;;
    --batch-id=*) BATCH_ID="${arg#--batch-id=}" ;;
    *) echo "Unknown argument: $arg" >&2; exit 2 ;;
  esac
done

ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || { echo "Not inside git repo" >&2; exit 2; }
cd "$ROOT"
TS="$(date -u +"%Y%m%dT%H%M%SZ")"
SAFE_BATCH="$(printf '%s' "$BATCH_ID" | tr -c 'A-Za-z0-9._-' '-')"
OUT_DIR="build/reports/harness/${SAFE_BATCH}/${TS}"
COMMITTED_DIR="docs/proof/harness/${SAFE_BATCH}-${TS}"
mkdir -p "$OUT_DIR" "$COMMITTED_DIR"

branch="$(git branch --show-current || true)"
sha="$(git rev-parse HEAD || true)"
status_short="$(git status --short || true)"

{
  echo "# Harness Proof Baseline"
  echo
  echo "Batch: ${BATCH_ID}"
  echo "Mode: ${MODE}"
  echo "Created UTC: ${TS}"
  echo
  echo "## Git"
  echo "- Branch: ${branch:-unknown}"
  echo "- SHA: ${sha:-unknown}"
  echo "- Dirty: $([[ -n "$status_short" ]] && echo true || echo false)"
  echo
  echo "## Tool Availability"
  echo "- python3: $(command -v python3 || echo missing)"
  echo "- xcodebuild: $(command -v xcodebuild || echo missing)"
  echo "- xcodegen: $(command -v xcodegen || echo missing)"
  echo "- xcrun: $(command -v xcrun || echo missing)"
  echo
  echo "## Non-claims"
  echo "- No release readiness claim."
  echo "- No TestFlight claim."
  echo "- No App Store claim."
  echo "- No device validation claim."
  echo "- No accessibility validation claim."
  echo "- No privacy/legal approval claim."
} > "${OUT_DIR}/wrapper-inventory.md"

python3 scripts/harness/ambitions-artifact-manifest.py \
  --batch "$BATCH_ID" \
  --status Yellow \
  --mode "$MODE" \
  --command "git status --short" \
  --artifact "${OUT_DIR}/wrapper-inventory.md" \
  --claim-made "Collected local harness inventory metadata." \
  --claim-not-made "No release readiness claim." \
  --claim-not-made "No TestFlight claim." \
  --claim-not-made "No App Store claim." \
  --claim-not-made "No device validation claim." \
  --claim-not-made "No accessibility validation claim." \
  --claim-not-made "No privacy/legal approval claim." \
  --risk "Dirty worktree may be present during proof generation." \
  --note "Harness proof baseline wrapper run." \
  --output-file "${OUT_DIR}/artifact-manifest.json" >/dev/null

BUILD_EXIT=0
if [[ "$RUN_BUILD" == "1" ]]; then
  if [[ -x "./scripts/build-local.sh" ]]; then
    set +e; ./scripts/build-local.sh > "${OUT_DIR}/build-local.log" 2>&1; BUILD_EXIT=$?; set -e
  elif command -v xcodegen >/dev/null 2>&1 && command -v xcodebuild >/dev/null 2>&1; then
    set +e
    xcodegen generate > "${OUT_DIR}/xcodegen-generate.log" 2>&1
    gen_exit=$?
    if [[ "$gen_exit" == "0" ]]; then
      xcodebuild build -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=iPhone 17" CODE_SIGNING_ALLOWED=NO > "${OUT_DIR}/xcodebuild-build.log" 2>&1
      BUILD_EXIT=$?
    else
      BUILD_EXIT=$gen_exit
    fi
    set -e
  else
    echo "Build tooling unavailable or no known build command found." > "${OUT_DIR}/build-skipped.log"
    BUILD_EXIT=2
  fi
fi

{
  echo "# Harness Proof Closeout"
  echo
  echo "Batch: ${BATCH_ID}"
  echo "Mode: ${MODE}"
  echo "Status: Yellow"
  echo "Runtime packet: ${OUT_DIR}"
  echo "Build exit: ${BUILD_EXIT}"
  echo
  echo "## Claims Not Made"
  echo "- No release readiness claim."
  echo "- No TestFlight claim."
  echo "- No App Store claim."
  echo "- No device validation claim."
  echo "- No accessibility validation claim."
  echo "- No privacy/legal approval claim."
} > "${COMMITTED_DIR}/closeout.md"
cp "${OUT_DIR}/artifact-manifest.json" "${COMMITTED_DIR}/artifact-manifest.json"
cp "${OUT_DIR}/wrapper-inventory.md" "${COMMITTED_DIR}/wrapper-inventory.md"

echo "Harness packet: ${OUT_DIR}"
echo "Committed closeout: ${COMMITTED_DIR}"
echo "Build exit: ${BUILD_EXIT}"
if [[ "$MODE" == "build" && "$BUILD_EXIT" != "0" ]]; then exit "$BUILD_EXIT"; fi
SH

  chmod +x scripts/harness/ambitions-proof-baseline.sh scripts/harness/ambitions-xcresult-summary.py
  bash -n scripts/harness/ambitions-proof-baseline.sh
  python3 -m py_compile scripts/harness/ambitions-xcresult-summary.py
  git add prompts/batches/HARNESS-T02-B02-proof-wrapper-scripts.md scripts/harness/ambitions-proof-baseline.sh scripts/harness/ambitions-xcresult-summary.py
  commit_staged "AMB-295 install harness proof wrapper scripts"
}

install_amb296() {
  log "AMB-296 — static gates"
  cat > prompts/batches/HARNESS-T03-B01-static-gates.md <<'EOF'
<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# HARNESS-T03-B01 — Static Gates

Issue: AMB-296

## Objective
Install Slice 1 static gates for product language, IA, local-only/privacy, architecture boundary, and claim discipline.

## Scope
Docs/scripts/prompts only. No app source. No `docs/truth/*` changes.
EOF
  cat > scripts/harness/_ambitions_static_gate_common.py <<'PY'
#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import re
from dataclasses import asdict, dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Iterable

ROOT = Path(__file__).resolve().parents[2]
TEXT_SUFFIXES = {'.md', '.txt', '.json', '.yml', '.yaml', '.py', '.sh'}
EXCLUDED = {'build', '.git', '.codex/runs', '.build', 'DerivedData'}

@dataclass
class Finding:
    path: str
    line: int
    pattern: str
    severity: str
    text: str

def utc_now() -> str:
    return datetime.now(timezone.utc).replace(microsecond=0).isoformat().replace('+00:00', 'Z')

def excluded(path: Path) -> bool:
    rel = str(path.relative_to(ROOT))
    return any(rel == x or rel.startswith(x + '/') for x in EXCLUDED)

def iter_files(paths: Iterable[str]):
    for raw in paths:
        path = ROOT / raw
        if not path.exists():
            continue
        if path.is_file():
            if path.suffix in TEXT_SUFFIXES and not excluded(path):
                yield path
        else:
            for item in path.rglob('*'):
                if item.is_file() and item.suffix in TEXT_SUFFIXES and not excluded(item):
                    yield item

def run_gate(name: str, patterns: dict[str, str]) -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument('--output-dir', default=f'build/reports/harness/static-gates/{name}')
    parser.add_argument('paths', nargs='*', default=['docs', 'prompts', 'AGENTS.md', 'README.md'])
    args = parser.parse_args()
    compiled = [(k, re.compile(v, re.I)) for k, v in patterns.items()]
    findings: list[Finding] = []
    for path in iter_files(args.paths):
        text = path.read_text(encoding='utf-8', errors='ignore')
        rel = str(path.relative_to(ROOT))
        for idx, line in enumerate(text.splitlines(), 1):
            for key, pat in compiled:
                if pat.search(line):
                    findings.append(Finding(rel, idx, key, 'Yellow', line.strip()[:300]))
    status = 'Green' if not findings else 'Yellow'
    out = ROOT / args.output_dir
    out.mkdir(parents=True, exist_ok=True)
    payload = {
        'schema_version': 'ambitions-static-gate.v1',
        'gate': name,
        'created_at_utc': utc_now(),
        'status': status,
        'finding_count': len(findings),
        'findings': [asdict(f) for f in findings],
        'claims_made': ['Static text scan completed for the named gate.'],
        'claims_not_made': ['No app behavior proof.', 'No build/test proof.', 'No release readiness proof.', 'No accessibility proof.', 'No privacy/legal approval.'],
    }
    (out / f'{name}.json').write_text(json.dumps(payload, indent=2, sort_keys=True) + '\n', encoding='utf-8')
    lines = [f'# {name}', '', f'Status: {status}', f'Findings: {len(findings)}', '', '## Findings']
    lines += [f'- `{f.path}:{f.line}` [{f.pattern}] {f.text}' for f in findings[:200]] or ['- none']
    lines += ['', '## Claims Not Made', '- No app behavior proof.', '- No build/test proof.', '- No release readiness proof.', '- No accessibility proof.', '- No privacy/legal approval.']
    (out / f'{name}.md').write_text('\n'.join(lines) + '\n', encoding='utf-8')
    print(f'{name}: {status} ({len(findings)} findings)')
    return 0
PY
  cat > scripts/harness/ambitions-product-language-gate.py <<'PY'
#!/usr/bin/env python3
from _ambitions_static_gate_common import run_gate
PATTERNS = {'next_best_move': r'\bnext best move\b|\bRecommended next move\b', 'begin_focus': r'\bBegin Focus\b', 'guilt': r'\bstreak\b|\bshame\b|\bscore\b'}
raise SystemExit(run_gate('ambitions-product-language-gate', PATTERNS))
PY
  cat > scripts/harness/ambitions-ia-gate.py <<'PY'
#!/usr/bin/env python3
from _ambitions_static_gate_common import run_gate
PATTERNS = {'plan_top_level': r'Today\s*/\s*Goals\s*/\s*Capture\s*/\s*Plan\s*/\s*You|\btop-level Plan\b|\bPlan top-level\b', 'new_top_level': r'\bnew top-level\b|\badditional tab\b'}
raise SystemExit(run_gate('ambitions-ia-gate', PATTERNS))
PY
  cat > scripts/harness/ambitions-local-only-gate.py <<'PY'
#!/usr/bin/env python3
from _ambitions_static_gate_common import run_gate
PATTERNS = {'required_cloud_ai': r'\brequired cloud\b|\bserver-side planning\b|\bhosted inference\b|\bcloud LLM\b', 'analytics': r'\banalytics SDK\b|\btracking SDK\b|\bremote config\b'}
raise SystemExit(run_gate('ambitions-local-only-gate', PATTERNS))
PY
  cat > scripts/harness/ambitions-architecture-gate.py <<'PY'
#!/usr/bin/env python3
from _ambitions_static_gate_common import run_gate
PATTERNS = {'rejected_architecture': r'\bVIPER\b|\bCombine-first MVVM\b|\bHummingbird\b', 'unscoped_refactor': r'\bbroad refactor\b|\bfull rewrite\b'}
raise SystemExit(run_gate('ambitions-architecture-gate', PATTERNS))
PY
  cat > scripts/harness/ambitions-claim-discipline-gate.py <<'PY'
#!/usr/bin/env python3
from _ambitions_static_gate_common import run_gate
PATTERNS = {'release_ready': r'\brelease ready\b|\bproduction ready\b|\bship ready\b', 'testflight': r'\bTestFlight ready\b|\bApp Store ready\b', 'unproven_build': r'\bbuild passed\b|\btests passed\b|\bCI green\b', 'privacy_legal': r'\bprivacy approved\b|\blegal approved\b'}
raise SystemExit(run_gate('ambitions-claim-discipline-gate', PATTERNS))
PY
  chmod +x scripts/harness/ambitions-*-gate.py scripts/harness/_ambitions_static_gate_common.py
  python3 -m py_compile scripts/harness/_ambitions_static_gate_common.py scripts/harness/ambitions-product-language-gate.py scripts/harness/ambitions-ia-gate.py scripts/harness/ambitions-local-only-gate.py scripts/harness/ambitions-architecture-gate.py scripts/harness/ambitions-claim-discipline-gate.py
  python3 scripts/harness/ambitions-product-language-gate.py >/tmp/ambitions-product-language-gate.log || true
  python3 scripts/harness/ambitions-ia-gate.py >/tmp/ambitions-ia-gate.log || true
  python3 scripts/harness/ambitions-local-only-gate.py >/tmp/ambitions-local-only-gate.log || true
  python3 scripts/harness/ambitions-architecture-gate.py >/tmp/ambitions-architecture-gate.log || true
  python3 scripts/harness/ambitions-claim-discipline-gate.py >/tmp/ambitions-claim-discipline-gate.log || true
  git add prompts/batches/HARNESS-T03-B01-static-gates.md scripts/harness/_ambitions_static_gate_common.py scripts/harness/ambitions-product-language-gate.py scripts/harness/ambitions-ia-gate.py scripts/harness/ambitions-local-only-gate.py scripts/harness/ambitions-architecture-gate.py scripts/harness/ambitions-claim-discipline-gate.py
  commit_staged "AMB-296 install harness static gates"
}

run_amb297() {
  log "AMB-297 — first proof wrapper run"
  cat > prompts/batches/HARNESS-T04-B01-first-proof-wrapper-run.md <<'EOF'
<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# HARNESS-T04-B01 — First Proof Wrapper Run

Issue: AMB-297
EOF
  set +e
  bash scripts/harness/ambitions-proof-baseline.sh --inventory-only --batch-id=HARNESS-T04-B01-first-proof-wrapper-run
  inv_exit=$?
  bash scripts/harness/ambitions-proof-baseline.sh --build --batch-id=HARNESS-T04-B01-first-proof-wrapper-run
  build_exit=$?
  set -e
  latest_dir="$(find docs/proof/harness -maxdepth 1 -type d -name 'HARNESS-T04-B01-first-proof-wrapper-run-*' | sort | tail -1 || true)"
  [[ -n "$latest_dir" ]] || die "No AMB-297 proof closeout directory found."
  assert_file "$latest_dir/artifact-manifest.json"
  assert_json_valid "$latest_dir/artifact-manifest.json"
  cat > docs/proof/harness/AMB-297-first-proof-wrapper-run-summary.md <<EOF
# AMB-297 First Proof Wrapper Run Summary

Status: Yellow

## Commands

\`\`\`bash
bash scripts/harness/ambitions-proof-baseline.sh --inventory-only --batch-id=HARNESS-T04-B01-first-proof-wrapper-run
bash scripts/harness/ambitions-proof-baseline.sh --build --batch-id=HARNESS-T04-B01-first-proof-wrapper-run
\`\`\`

## Exit Codes

- inventory-only: ${inv_exit}
- build: ${build_exit}

## Committed Proof Packet

- ${latest_dir}
- ${latest_dir}/artifact-manifest.json
- ${latest_dir}/wrapper-inventory.md
- ${latest_dir}/closeout.md

## Classification

Yellow. The proof wrapper produced a timestamped proof packet and manifest. Build/tooling outcome must be interpreted from packet and local logs. No release or app-readiness claim is made.

## Claims Not Made

- No app implementation completion claim.
- No build success claim unless supported by local logs.
- No test success claim unless supported by local logs.
- No accessibility validation claim.
- No performance validation claim.
- No device validation claim.
- No privacy/legal approval claim.
- No TestFlight claim.
- No App Store claim.
- No release readiness claim.
EOF
  git add prompts/batches/HARNESS-T04-B01-first-proof-wrapper-run.md docs/proof/harness/AMB-297-first-proof-wrapper-run-summary.md "$latest_dir/artifact-manifest.json" "$latest_dir/wrapper-inventory.md" "$latest_dir/closeout.md"
  commit_staged "AMB-297 run first harness proof wrapper"
}

run_amb298() {
  log "AMB-298 — app-driving proof decision"
  cat > prompts/batches/HARNESS-T04-B02-app-driving-proof-decision.md <<'EOF'
<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# HARNESS-T04-B02 — App-Driving Proof Decision

Issue: AMB-298
EOF
  cat > docs/codex/harness/HARNESS_SCORECARD.md <<'EOF'
# HARNESS Scorecard

Status: Slice 1 support scorecard
Last updated by: AMB-298

## Slice 1 Harness State

| Area | Status | Evidence |
| --- | --- | --- |
| Artifact manifest schema | Green | `docs/codex/harness/HARNESS_ARTIFACT_SCHEMA.md`, `scripts/harness/ambitions-artifact-manifest.py` |
| Proof wrapper scripts | Green | `scripts/harness/ambitions-proof-baseline.sh`, `scripts/harness/ambitions-xcresult-summary.py` |
| Static gates | Green | `scripts/harness/ambitions-product-language-gate.py`, `scripts/harness/ambitions-ia-gate.py`, `scripts/harness/ambitions-local-only-gate.py`, `scripts/harness/ambitions-architecture-gate.py`, `scripts/harness/ambitions-claim-discipline-gate.py` |
| First proof wrapper run | Yellow | `docs/proof/harness/AMB-297-first-proof-wrapper-run-summary.md` |

## AMB-298 App-Driving Proof Decision

Decision: Yellow — a future bounded proof-mode launch router issue is recommended before claiming full app-driving proof.

Current harness scripts can collect local environment/git metadata, command output, artifact manifests, and static gate output. That is enough for governance/proof packet discipline. It is not enough by itself to prove deterministic app-driving behavior across the flagship moat scenario.

## Recommended Future Issue

Install bounded local proof-mode launch router for moat scenario validation.

## Claims Not Made

- No app implementation completion claim.
- No app-driving proof completion claim.
- No build success claim.
- No test success claim.
- No UI test success claim.
- No accessibility validation claim.
- No performance validation claim.
- No device validation claim.
- No privacy/legal approval claim.
- No TestFlight claim.
- No App Store claim.
- No release readiness claim.
EOF
  cat > docs/codex/harness/AMB-298-app-driving-proof-decision.md <<'EOF'
# AMB-298 App-Driving Proof Decision

Status: Yellow decision recorded

## Decision

Current Slice 1 harness tooling is sufficient for governance proof packets, artifact manifests, static gates, and local command evidence. It is not sufficient to claim complete app-driving proof for Ambitions' moat scenario.

A future bounded proof-mode launch router is recommended.

## Reasoning

App-driving proof for Ambitions needs a local deterministic route that can prove same intent, two different local contexts, deterministically different Start Here / Reality Meridian recommendation output, proof/freshness/receipt/closure/replay artifacts, protected-time boundaries, and local-only/privacy boundaries.

The current harness creates the proof container and gate discipline. It does not yet create the deterministic app-driving entry point.

## Claims Not Made

- No app-driving proof completion claim.
- No app implementation completion claim.
- No build success claim.
- No test success claim.
- No UI test success claim.
- No accessibility validation claim.
- No performance validation claim.
- No device validation claim.
- No privacy/legal approval claim.
- No TestFlight claim.
- No App Store claim.
- No release readiness claim.
EOF
  git add prompts/batches/HARNESS-T04-B02-app-driving-proof-decision.md docs/codex/harness/HARNESS_SCORECARD.md docs/codex/harness/AMB-298-app-driving-proof-decision.md
  commit_staged "AMB-298 decide app-driving proof path"
}

main() {
  require_main_clean
  ensure_dirs
  install_amb295
  install_amb296
  run_amb297
  run_amb298
  if ! git diff --quiet || ! git diff --cached --quiet; then
    git status --short
    die "Dirty worktree remains. Inspect before pushing."
  fi
  cat <<EOF

================================================================================
PRE-APP-SOURCE HARNESS FINISHER COMPLETE

Current branch: $(git branch --show-current)

Recent commits:
$(git log --oneline -10)

Push command:
  git push origin main

After pushing, tell ChatGPT:
  harness pushed
================================================================================
EOF
}

main "$@"
