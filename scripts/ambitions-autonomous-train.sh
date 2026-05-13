#!/usr/bin/env bash
set -Eeuo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd -P)"
cd "$REPO_ROOT"

FASTPATH="scripts/ambitions-autonomous-train-fastpath.py"

usage() {
  cat <<'EOF'
Usage:
  scripts/ambitions-autonomous-train.sh --status
  scripts/ambitions-autonomous-train.sh --next
  scripts/ambitions-autonomous-train.sh --run-current
  scripts/ambitions-autonomous-train.sh --until-complete

This compatibility entry point delegates to:
  python3 scripts/ambitions-autonomous-train-fastpath.py
EOF
}

if [[ ! -f "$FASTPATH" ]]; then
  echo "ERROR: $FASTPATH is missing" >&2
  exit 2
fi

MODE="${1:---status}"
shift || true

case "$MODE" in
  -h|--help)
    usage
    ;;
  --status)
    python3 "$FASTPATH" --status "$@"
    ;;
  --next)
    python3 "$FASTPATH" --next "$@"
    ;;
  --run-current|--once)
    python3 "$FASTPATH" --once "$@"
    ;;
  --until-complete)
    python3 "$FASTPATH" --until-complete "$@"
    ;;
  --dry-run)
    python3 "$FASTPATH" --once --dry-run --no-push "$@"
    ;;
  *)
    usage >&2
    exit 2
    ;;
esac
