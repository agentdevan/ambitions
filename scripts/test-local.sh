#!/usr/bin/env bash
set -Eeuo pipefail

usage() {
  cat <<'USAGE'
Usage:
  scripts/test-local.sh [--lane build|test-plan|focused-test|build-for-testing] [--batch BATCH] [--test TEST_ID] [--test-plan PLAN_NAME] [--json]

Defaults:
  --batch LOCAL
  --lane build

This compatibility entrypoint routes through scripts/ambitions-xcode-validate.sh.
Use that wrapper directly for new automation.
USAGE
}

BATCH="${BATCH:-LOCAL}"
LANE="${LANE:-build}"
TEST="${TEST:-}"
TEST_PLAN="${TEST_PLAN:-}"
JSON=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --batch)
      BATCH="${2:?--batch requires a value}"
      shift 2
      ;;
    --lane)
      LANE="${2:?--lane requires a value}"
      shift 2
      ;;
    --test)
      TEST="${2:?--test requires a value}"
      shift 2
      ;;
    --test-plan)
      TEST_PLAN="${2:?--test-plan requires a value}"
      shift 2
      ;;
    --json)
      JSON=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

case "$LANE" in
  none|build|build-for-testing|ui-proof|terminal-device-proof)
    ;;
  focused-test)
    if [[ -z "$TEST" ]]; then
      echo "--lane focused-test requires --test <TEST_ID>." >&2
      exit 2
    fi
    ;;
  test-plan)
    TEST_PLAN="${TEST_PLAN:-Ambitions}"
    ;;
  *)
    echo "Unsupported lane for scripts/test-local.sh: $LANE" >&2
    usage >&2
    exit 2
    ;;
esac

args=(--batch "$BATCH" --lane "$LANE")

if [[ "$LANE" == "focused-test" ]]; then
  args+=(--test "$TEST")
fi

if [[ "$LANE" == "test-plan" ]]; then
  args+=(--test-plan "$TEST_PLAN")
fi

if [[ "$JSON" -eq 1 ]]; then
  args+=(--json)
fi

echo "Routing local validation through scripts/ambitions-xcode-validate.sh"
exec scripts/ambitions-xcode-validate.sh "${args[@]}"
