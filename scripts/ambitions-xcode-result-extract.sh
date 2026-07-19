#!/usr/bin/env bash
set -Eeuo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd -P)"
cd "$REPO_ROOT"

RESULT=""
OUT_DIR=""
MODE="full"
EXPECTED_TEST_FILTERS=()
while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --result) RESULT="$2"; shift 2 ;;
    --output-dir) OUT_DIR="$2"; shift 2 ;;
    --mode) MODE="${2:-}"; shift 2 ;;
    --expected-test-filter) EXPECTED_TEST_FILTERS+=("${2:-}"); shift 2 ;;
    -h|--help)
      echo "Usage: scripts/ambitions-xcode-result-extract.sh --result <path> --output-dir <dir> [--mode full|metadata] [--expected-test-filter <target[/suite[/test]]>]..." >&2
      exit 0
      ;;
    *)
      echo "unsupported arg: $1" >&2
      exit 1
      ;;
  esac
done

case "$MODE" in
  full|metadata) ;;
  *)
    echo "unsupported extraction mode: $MODE (expected full or metadata)" >&2
    exit 2
    ;;
esac

if [[ -z "$RESULT" || -z "$OUT_DIR" ]]; then
  echo "Usage: scripts/ambitions-xcode-result-extract.sh --result <path> --output-dir <dir> [--mode full|metadata] [--expected-test-filter <target[/suite[/test]]>]..." >&2
  exit 1
fi

if [[ ! -e "$RESULT" ]]; then
  echo "result bundle missing: $RESULT" >&2
  exit 1
fi

if [[ ! -f "$RESULT/Info.plist" ]]; then
  mkdir -p "$OUT_DIR"
  summary_file="$OUT_DIR/summary.json"
  corrupt_xcparse_available=false
  if command -v xcparse >/dev/null 2>&1; then
    corrupt_xcparse_available=true
  fi
  corrupt_rich_artifacts_requested=false
  if [[ "$MODE" == "full" ]]; then
    corrupt_rich_artifacts_requested=true
  fi
  cat > "$summary_file" <<JSON
{
  "result_bundle": "$RESULT",
  "result_bundle_retained": true,
  "extraction_mode": "$MODE",
  "xcparse_available": $corrupt_xcparse_available,
  "xcparse_invoked": false,
  "xcparse_pass_count": 0,
  "xcparse_success_count": 0,
  "rich_artifacts_requested": $corrupt_rich_artifacts_requested,
  "rich_artifacts_extracted": false,
  "attachments": null,
  "screenshots": null,
  "logs": null,
  "coverage": null,
  "status": "failed",
  "failure_category": "corrupt_xcresult",
  "reason": "result bundle is missing Info.plist"
}
JSON
  echo "corrupt_xcresult: result bundle missing Info.plist: $RESULT" >&2
  echo "$summary_file"
  exit 65
fi

mkdir -p "$OUT_DIR"
xcparse_available=false
xcparse_invoked=false
xcparse_pass_count=0
xcparse_success_count=0
rich_artifacts_requested=false
rich_artifacts_extracted=false
attachments_path=""
screenshots_path=""
logs_path=""
coverage_path=""
test_validation_file=""
test_validation_status=0

if command -v xcparse >/dev/null 2>&1; then
  xcparse_available=true
fi

if [[ "$MODE" == "full" ]]; then
  rich_artifacts_requested=true
  attachments_path="$OUT_DIR/attachments"
  screenshots_path="$OUT_DIR/screenshots"
  logs_path="$OUT_DIR/logs"
  coverage_path="$OUT_DIR/coverage"
  mkdir -p "$attachments_path" "$screenshots_path" "$logs_path" "$coverage_path"

  if [[ "$xcparse_available" == "true" ]]; then
    xcparse_invoked=true
    xcparse_log="$OUT_DIR/xcparse.log"
    : > "$xcparse_log"
    for artifact in attachments screenshots logs coverage; do
      ((xcparse_pass_count += 1))
      artifact_path="$OUT_DIR/$artifact"
      if xcparse "$artifact" "$RESULT" "$artifact_path" >>"$xcparse_log" 2>&1; then
        ((xcparse_success_count += 1))
      fi
    done
    if [[ "$xcparse_success_count" -eq 4 ]]; then
      rich_artifacts_extracted=true
    fi
  else
    echo "xcparse missing: install with brew install chargepoint/xcparse/xcparse (or run scripts/ambitions-build-lab-doctor.sh --json for full matrix)" >&2
  fi
fi

if ((${#EXPECTED_TEST_FILTERS[@]} > 0)); then
  test_results_json="$OUT_DIR/test-results.json"
  test_results_error="$OUT_DIR/test-results.stderr.log"
  test_validation_file="$OUT_DIR/test-validation.json"
  set +e
  xcrun xcresulttool get test-results tests --path "$RESULT" --compact \
    >"$test_results_json" 2>"$test_results_error"
  xcresulttool_status=$?
  python3 - \
    "$test_results_json" \
    "$test_validation_file" \
    "$xcresulttool_status" \
    "${EXPECTED_TEST_FILTERS[@]}" <<'PY'
import json
import sys
from pathlib import Path

raw_path = Path(sys.argv[1])
output_path = Path(sys.argv[2])
tool_status = int(sys.argv[3])
expected = sys.argv[4:]

result = {
    "expected_test_filters": expected,
    "matched_test_filters": [],
    "missing_test_filters": expected,
    "executed_test_identifiers": [],
    "simulator_udids": [],
    "test_results_validated": False,
}

if not expected or len(set(expected)) != len(expected) or any(
    not value or len(value.split("/")) not in {1, 2, 3} or any(not part for part in value.split("/"))
    for value in expected
):
    result.update(status="failed", failure_category="invalid_expected_test_filter")
    output_path.write_text(json.dumps(result, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    raise SystemExit(2)

if tool_status != 0:
    result.update(status="failed", failure_category="xcresult_test_results_unavailable")
    output_path.write_text(json.dumps(result, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    raise SystemExit(65)

try:
    document = json.loads(raw_path.read_text(encoding="utf-8"))
except (OSError, UnicodeError, json.JSONDecodeError):
    result.update(status="failed", failure_category="xcresult_test_results_unavailable")
    output_path.write_text(json.dumps(result, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    raise SystemExit(65)

devices = document.get("devices")
nodes = document.get("testNodes")
if not isinstance(devices, list) or not isinstance(nodes, list):
    result.update(status="failed", failure_category="xcresult_test_results_unavailable")
    output_path.write_text(json.dumps(result, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    raise SystemExit(65)

records = []

def walk(node, target=None, suite=None):
    if not isinstance(node, dict):
        return
    node_type = node.get("nodeType")
    name = node.get("name")
    if node_type in {"Unit test bundle", "UI test bundle", "Test bundle"} and isinstance(name, str):
        target = name
    elif node_type == "Test Suite" and isinstance(name, str):
        suite = name
    elif node_type == "Test Case" and all(isinstance(value, str) and value for value in (target, suite, name)):
        method = name[:-2] if name.endswith("()") else name
        if node.get("result") == "Passed":
            records.append((target, suite, method))
    children = node.get("children", [])
    if isinstance(children, list):
        for child in children:
            walk(child, target, suite)

for node in nodes:
    walk(node)

records = sorted(set(records))
executed = ["/".join(record) for record in records]
simulators = sorted(
    {
        row.get("deviceId")
        for row in devices
        if isinstance(row, dict) and isinstance(row.get("deviceId"), str) and row.get("deviceId")
    }
)

def matches(test_filter):
    parts = test_filter.split("/")
    for target, suite, method in records:
        if parts[0] != target:
            continue
        if len(parts) >= 2 and parts[1] != suite:
            continue
        if len(parts) == 3 and parts[2] != method:
            continue
        return True
    return False

matched = [value for value in expected if matches(value)]
missing = [value for value in expected if value not in matched]
result.update(
    matched_test_filters=matched,
    missing_test_filters=missing,
    executed_test_identifiers=executed,
    simulator_udids=simulators,
    test_results_validated=not missing,
)
if missing:
    result.update(status="failed", failure_category="test_selector_not_executed")
else:
    result.update(status="passed", failure_category=None)
output_path.write_text(json.dumps(result, indent=2, sort_keys=True) + "\n", encoding="utf-8")
raise SystemExit(65 if missing else 0)
PY
  test_validation_status=$?
  set -e
fi

summary_file="$OUT_DIR/summary.json"
python3 - \
  "$summary_file" \
  "$RESULT" \
  "$MODE" \
  "$xcparse_available" \
  "$xcparse_invoked" \
  "$xcparse_pass_count" \
  "$xcparse_success_count" \
  "$rich_artifacts_requested" \
  "$rich_artifacts_extracted" \
  "$attachments_path" \
  "$screenshots_path" \
  "$logs_path" \
  "$coverage_path" \
  "$test_validation_file" <<'PY'
import json
import sys
from pathlib import Path

(
    summary_file,
    result_bundle,
    extraction_mode,
    xcparse_available,
    xcparse_invoked,
    xcparse_pass_count,
    xcparse_success_count,
    rich_artifacts_requested,
    rich_artifacts_extracted,
    attachments,
    screenshots,
    logs,
    coverage,
    test_validation_file,
) = sys.argv[1:]

payload = {
    "result_bundle": result_bundle,
    "result_bundle_retained": True,
    "extraction_mode": extraction_mode,
    "xcparse_available": xcparse_available == "true",
    "xcparse_invoked": xcparse_invoked == "true",
    "xcparse_pass_count": int(xcparse_pass_count),
    "xcparse_success_count": int(xcparse_success_count),
    "rich_artifacts_requested": rich_artifacts_requested == "true",
    "rich_artifacts_extracted": rich_artifacts_extracted == "true",
    "attachments": attachments or None,
    "screenshots": screenshots or None,
    "logs": logs or None,
    "coverage": coverage or None,
    "claim_boundary": (
        "metadata-only result preservation; rich artifacts were not extracted"
        if extraction_mode == "metadata"
        else "rich artifact extraction attempt; individual pass counts report actual extraction"
    ),
}
validation = {
    "expected_test_filters": [],
    "matched_test_filters": [],
    "missing_test_filters": [],
    "executed_test_identifiers": [],
    "simulator_udids": [],
    "test_results_validated": False,
}
if test_validation_file:
    validation.update(json.loads(Path(test_validation_file).read_text(encoding="utf-8")))
payload.update(validation)
Path(summary_file).write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")
PY

echo "$summary_file"
exit "$test_validation_status"
