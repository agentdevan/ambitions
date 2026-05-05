#!/usr/bin/env bash
set -u
set -o pipefail

LOG_DIR="output/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/ci-local-parity-$(date +%Y%m%d-%H%M%S).log"

run_step() {
  local name="$1"
  shift

  echo
  echo "== $name =="
  echo "+ $*"
  "$@"
}

record_step() {
  local name="$1"
  shift

  run_step "$name" "$@"
  local status=$?
  if [[ "$status" -ne 0 ]]; then
    echo "STEP_STATUS $name FAIL $status"
  else
    echo "STEP_STATUS $name PASS"
  fi
  return "$status"
}

main() {
  local overall=0

  echo "Ambitions local CI parity"
  echo "========================="
  echo "Log: $LOG_FILE"
  echo "RUN_BUILD=${RUN_BUILD:-0}"
  echo "RUN_TESTS=${RUN_TESTS:-0}"
  echo "RUN_DOC_QA=${RUN_DOC_QA:-1}"
  echo "RUN_GATE=${RUN_GATE:-1}"
  echo
  echo "This wrapper does not claim release, TestFlight, App Store, device, or public"
  echo "accessibility readiness. It records local evidence only."

  record_step "git-status" git status --short || overall=1
  record_step "tool-validation" scripts/validate-dev-tools.sh || overall=1
  record_step "xcodegen" xcodegen generate || overall=1
  record_step "diff-check" git diff --check || overall=1

  if [[ "${RUN_DOC_QA:-1}" == "1" ]]; then
    record_step "docs-qa" scripts/run-doc-qa.sh || overall=1
  else
    echo
    echo "SKIP docs-qa because RUN_DOC_QA is not 1."
  fi

  if [[ "${RUN_BUILD:-0}" == "1" ]]; then
    record_step "build-local" scripts/build-local.sh || overall=1
  else
    echo
    echo "SKIP build-local because RUN_BUILD is not 1."
  fi

  if [[ "${RUN_TESTS:-0}" == "1" ]]; then
    record_step "test-local" scripts/test-local.sh || overall=1
  else
    echo
    echo "SKIP test-local because RUN_TESTS is not 1."
  fi

  if [[ "${RUN_GATE:-1}" == "1" ]]; then
    record_step "batch-train-gate" scripts/batch-train-gate-check.sh || overall=1
  else
    echo
    echo "SKIP batch-train-gate because RUN_GATE is not 1."
  fi

  echo
  if [[ "$overall" -eq 0 ]]; then
    echo "CI_LOCAL_PARITY_STATUS PASS"
  else
    echo "CI_LOCAL_PARITY_STATUS FAIL"
  fi
  return "$overall"
}

main "$@" 2>&1 | tee "$LOG_FILE"
exit "${PIPESTATUS[0]}"
