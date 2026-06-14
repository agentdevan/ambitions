#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd -P)"
cd "$ROOT"

include_docs=0
while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --include-docs)
      include_docs=1
      shift
      ;;
    -h|--help)
      cat <<'USAGE'
Usage:
  bash scripts/codex/scan-sdk27-swiftui-usage.sh [--include-docs]

Scans Swift source under Native, Sources, AppUI, and Packages for known
SDK 27-only SwiftUI API names. Docs/artifacts are ignored unless --include-docs
is supplied.
USAGE
      exit 0
      ;;
    *)
      echo "unsupported arg: $1" >&2
      exit 2
      ;;
  esac
done

patterns=(
  "toolbarMinimizeBehavior"
  "topBarPinnedTrailing"
  "toolbarOverflowMenu"
  "visibilityPriority"
  "swipeActionsContainer"
  "ContentBuilder"
  "asyncImageURLSession"
)

roots=()
for dir in Native Sources AppUI Packages; do
  if [[ -d "$dir" ]]; then
    roots+=("$dir")
  fi
done

if [[ "$include_docs" -eq 1 ]]; then
  for dir in docs artifacts .agents .codex; do
    if [[ -d "$dir" ]]; then
      roots+=("$dir")
    fi
  done
fi

if [[ "${#roots[@]}" -eq 0 ]]; then
  echo "YELLOW: no scan roots found"
  exit 0
fi

pattern_expr="$(IFS='|'; printf '%s' "${patterns[*]}")"
globs=(--glob '*.swift')
if [[ "$include_docs" -eq 1 ]]; then
  globs+=(--glob '*.md' --glob '*.yml' --glob '*.yaml' --glob '*.json')
fi

set +e
matches="$(rg -n "${globs[@]}" "$pattern_expr" "${roots[@]}" 2>/dev/null)"
status=$?
set -e

if [[ "$status" -eq 0 && -n "$matches" ]]; then
  echo "RED: known SDK 27-only API names found:"
  printf '%s\n' "$matches"
  exit 1
fi

if [[ "$status" -gt 1 ]]; then
  echo "RED: scan failed"
  exit "$status"
fi

echo "GREEN: no known SDK 27-only SwiftUI API names found in scanned roots: ${roots[*]}"
