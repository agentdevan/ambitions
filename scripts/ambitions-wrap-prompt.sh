#!/usr/bin/env bash
set -Eeuo pipefail

usage() {
  cat <<'EOF'
Usage:
  scripts/ambitions-wrap-prompt.sh BATCH_ID input-prompt.md [output-prompt.md]

Default output:
  prompts/batches/<BATCH_ID>.md
EOF
}

die() {
  echo "ERROR: $*" >&2
  exit 1
}

[[ "${1:-}" != "-h" && "${1:-}" != "--help" ]] || {
  usage
  exit 0
}

[[ "$#" -ge 2 && "$#" -le 3 ]] || {
  usage >&2
  exit 2
}

BATCH_ID="$1"
INPUT="$2"
OUTPUT="${3:-prompts/batches/$BATCH_ID.md}"
HEADER="prompts/_RUNNER_REQUIRED_HEADER.md"

[[ -f "$INPUT" ]] || die "input file missing: $INPUT"
[[ -f "$HEADER" ]] || die "runner header missing: $HEADER"

mkdir -p "$(dirname "$OUTPUT")"

if grep -q 'AMBITIONS_RUNNER_REQUIRED' "$INPUT"; then
  cp "$INPUT" "$OUTPUT"
else
  {
    cat "$HEADER"
    printf '\n'
    printf 'Runner command:\n\n'
    printf '```bash\n'
    printf 'make batch BATCH=%s PROMPT=%s\n' "$BATCH_ID" "$OUTPUT"
    printf '```\n\n'
    printf '%s\n\n' '--- ORIGINAL PROMPT BELOW ---'
    cat "$INPUT"
  } >"$OUTPUT"
fi

printf 'Wrapped prompt: %s\n' "$OUTPUT"
printf 'Runner command: make batch BATCH=%s PROMPT=%s\n' "$BATCH_ID" "$OUTPUT"
