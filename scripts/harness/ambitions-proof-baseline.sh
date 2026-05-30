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
