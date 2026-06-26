#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"

CONTINUE=false
if [[ "${1:-}" == "--continue" ]]; then
  CONTINUE=true
elif [[ "${1:-}" != "" ]]; then
  echo "usage: $0 [--continue]" >&2
  exit 2
fi

failures=()
passed=()
failure_count=0
pass_count=0

run_step() {
  local name="$1"
  local command="$2"

  echo
  echo "## ${name}"
  if bash -o pipefail -c "$command"; then
    passed+=("$name")
    pass_count=$((pass_count + 1))
    echo "PASS ${name}"
  else
    local status=$?
    failures+=("${name} (${status})")
    failure_count=$((failure_count + 1))
    echo "FAIL ${name} (${status})" >&2
    if [[ "$CONTINUE" != true ]]; then
      print_summary
      exit "$status"
    fi
  fi
}

print_summary() {
  echo
  echo "# Ambitions PR Review Local Summary"
  echo "passed=${pass_count}"
  if ((pass_count > 0)); then
    for item in "${passed[@]}"; do
      echo "PASS $item"
    done
  fi
  echo "failed=${failure_count}"
  if ((failure_count > 0)); then
    for item in "${failures[@]}"; do
      echo "FAIL $item"
    done
  fi
}

run_step "git diff whitespace" "git diff --check"
run_step "repo hygiene" "bash scripts/ci/ambitions-pr-hygiene.sh"
run_step "ambitions green standard audit" "python3 scripts/ambitions-green-standard-audit.py"
run_step "privacy boundary scan" "bash scripts/privacy-boundary-scan.sh"
run_step "release claim safety scan" "bash scripts/release-claim-safety-scan.sh"
run_step "weak implementation scan" "python3 scripts/ci/ambitions-no-weak-implementation-scan.py"
run_step "source atlas boundary audit" "python3 scripts/source-atlas-boundary-audit.py"
run_step "source atlas no private graph egress audit" "python3 scripts/source-atlas-no-private-graph-egress-audit.py"
run_step "swiftlint" "swiftlint lint --strict"
run_step "semgrep local" "semgrep scan --config .semgrep/ambitions-source-atlas.yml --error"
run_step "shellcheck" "find scripts -name '*.sh' -print0 | xargs -0 shellcheck"
run_step "actionlint" "actionlint"
run_step "markdownlint" "markdownlint-cli2 '**/*.md' '#Pods' '#DerivedData' '#.build'"
run_step "yamllint" "yamllint .github .semgrep .yamllint.yml .markdownlint-cli2.yaml"
run_step "gitleaks" "bash scripts/ci/ambitions-gitleaks-scan.sh"
run_step "python tests" "python3 -m pytest tools/source-atlas/foundry tools/source-atlas/tests"

print_summary

if ((failure_count > 0)); then
  exit 1
fi

echo "GREEN: local PR review stack passed"
