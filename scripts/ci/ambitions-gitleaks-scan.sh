#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"

MODE="full"
case "${1:-}" in
  "")
    ;;
  --range-only)
    MODE="range-only"
    shift
    ;;
  *)
    echo "usage: $0 [--range-only]" >&2
    exit 2
    ;;
esac
if [[ "$#" -ne 0 ]]; then
  echo "usage: $0 [--range-only]" >&2
  exit 2
fi

if ! command -v gitleaks >/dev/null 2>&1; then
  echo "gitleaks is required. Install it locally with Homebrew or run inside CI." >&2
  exit 127
fi

TIMEOUT_SECONDS="${GITLEAKS_TIMEOUT_SECONDS:-180}"
BASE_REF="${GITHUB_BASE_REF:-main}"
BASE_SHA="${GITHUB_BASE_SHA:-}"
SCAN_ROOT=""

cleanup() {
  if [[ -n "$SCAN_ROOT" && -d "$SCAN_ROOT" ]]; then
    rm -rf "$SCAN_ROOT"
  fi
}
trap cleanup EXIT

resolve_base() {
  if [[ -n "$BASE_SHA" ]] && git cat-file -e "${BASE_SHA}^{commit}" 2>/dev/null; then
    printf '%s\n' "$BASE_SHA"
    return 0
  fi

  if git rev-parse --verify "origin/${BASE_REF}" >/dev/null 2>&1; then
    git merge-base HEAD "origin/${BASE_REF}"
    return 0
  fi

  if git rev-parse --verify origin/main >/dev/null 2>&1; then
    git merge-base HEAD origin/main
    return 0
  fi

  git rev-parse HEAD
}

copy_repo_material_for_dir_scan() {
  local path
  SCAN_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/ambitions-gitleaks.XXXXXX")"
  while IFS= read -r -d '' path; do
    if [[ -f "$path" ]]; then
      mkdir -p "$SCAN_ROOT/$(dirname "$path")"
      cp -p "$path" "$SCAN_ROOT/$path"
    fi
  done < <(git ls-files -z --cached --others --exclude-standard)
}

echo "# Ambitions Gitleaks Scan"
echo "mode=${MODE}"
echo "timeout_seconds=${TIMEOUT_SECONDS}"

if [[ "$MODE" == "full" ]]; then
  echo
  echo "## current repo material"
  copy_repo_material_for_dir_scan
  gitleaks dir "$SCAN_ROOT" \
    --config "$ROOT/.gitleaks.toml" \
    --no-banner \
    --redact \
    --exit-code 1 \
    --timeout "$TIMEOUT_SECONDS"
else
  echo "current repo material skipped: mode=range-only"
fi

echo
echo "## introduced git history"
BASE="$(resolve_base)"
echo "base=${BASE}"
if [[ "$BASE" == "$(git rev-parse HEAD)" ]]; then
  echo "No commit range beyond HEAD; current repo material scan completed."
else
  gitleaks git "$ROOT" \
    --log-opts "${BASE}..HEAD" \
    --config "$ROOT/.gitleaks.toml" \
    --no-banner \
    --redact \
    --exit-code 1 \
    --timeout "$TIMEOUT_SECONDS"
fi

if [[ "$MODE" == "full" ]]; then
  echo "GREEN: Gitleaks found no secrets in current repo material or introduced commit range"
else
  echo "GREEN: Gitleaks found no secrets in introduced commit range"
fi
