#!/usr/bin/env bash
set -Eeuo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd -P)"
cd "$REPO_ROOT"

DEFAULT_PATH="$REPO_ROOT/.codex/DerivedData/Ambitions"
COMMAND="${1:-}"
shift || true

if [[ -z "$COMMAND" ]]; then
  echo "Usage: scripts/ambitions-deriveddata-manager.sh path|status|clean --batch <id> [--reason <text>]" >&2
  exit 1
fi

case "$COMMAND" in
  path)
    if [[ -n "${1:-}" ]]; then
      printf '%s\n' "$1"
    else
      printf '%s\n' "$DEFAULT_PATH"
    fi
    ;;
  status)
    if [[ ! -d "$DEFAULT_PATH" ]]; then
      echo "status=missing"
      exit 0
    fi
    size=$(du -sh "$DEFAULT_PATH" 2>/dev/null | awk '{print $1}')
    file_count=$(find "$DEFAULT_PATH" -type f | wc -l | tr -d ' ')
    echo "status=present"
      echo "path=$DEFAULT_PATH"
      echo "size=$size"
      echo "files=$file_count"
    ;;
  clean)
    batch="${1:-}"
    if [[ "$batch" != "--batch" ]]; then
      echo "usage: ... clean --batch <batch-id> [--reason <reason>]" >&2
      exit 1
    fi
    shift
    batch_id="${1:-}"
    [[ -n "$batch_id" ]] || { echo "batch id required" >&2; exit 1; }
    shift || true
    if [[ "${1:-}" == "--reason" ]]; then
      reason="${2:-unspecified}"
    else
      reason="unqualified"
    fi
    [[ -d "$DEFAULT_PATH" ]] || { echo "status=already-clean"; exit 0; }
    rm -rf "$DEFAULT_PATH" || true
    echo "status=cleaned"
    echo "batch=$batch_id"
    echo "reason=$reason"
    echo "path=$DEFAULT_PATH"
    ;;
  *)
    echo "unsupported command: $COMMAND" >&2
    exit 1
    ;;
esac
