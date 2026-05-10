#!/usr/bin/env bash
set -Eeuo pipefail

USAGE="Usage:
  bash scripts/ambitions-throughput-plan.sh --help
  bash scripts/ambitions-throughput-plan.sh --status
  bash scripts/ambitions-throughput-plan.sh --next
  bash scripts/ambitions-throughput-plan.sh --classify --limit 20
  bash scripts/ambitions-throughput-plan.sh --known-yellow"

QUEUE_FILE="docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json"

limit=20
mode=""

print_help() {
  cat <<EOF
$USAGE

This script provides read-only, local throughput planning status.
- status: local state + required runner preflight commands.
- next: print next eligible batch from live queue/train lane.
- classify: print batch->lane table for the first N entries.
- known-yellow: print known-yellow scan output.
EOF
}

if [[ "$#" -eq 0 ]]; then
  print_help
  exit 1
fi

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --help|-h)
      print_help
      exit 0
      ;;
    --status)
      mode="status"
      shift
      ;;
    --next)
      mode="next"
      shift
      ;;
    --classify)
      mode="classify"
      shift
      ;;
    --known-yellow)
      mode="known-yellow"
      shift
      ;;
    --limit)
      shift
      if [[ $# -eq 0 ]]; then
        echo "--limit requires an integer" >&2
        exit 2
      fi
      limit="$1"
      shift
      ;;
    *)
      echo "unsupported argument: $1" >&2
      print_help
      exit 2
      ;;
  esac
done

case "$mode" in
  status)
    echo "throughput status"
    git status --short --branch
    echo "--"
    make batch-self-check
    make prompt-audit
    make autonomous-train-status
    make autonomous-train-next
    ;;
  next)
    make autonomous-train-next
    ;;
  classify)
    scripts/ambitions-batch-lane-classifier.py --queue "$QUEUE_FILE" --limit "$limit"
    ;;
  known-yellow)
    bash scripts/ambitions-known-yellow-scan.sh
    ;;
  *)
    print_help
    exit 2
    ;;
esac
