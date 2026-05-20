#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

case " $* " in
  *" --json "*|*" --field "*) ;;
  *) echo "global-train-next-batch.sh: Ambitions authoritative next-batch resolver" ;;
esac
python3 scripts/ambitions-next-batch-resolver.py "$@"
