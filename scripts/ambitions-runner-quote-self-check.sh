#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || {
  echo "RED: not inside a git repo" >&2
  exit 1
}
cd "$ROOT"

tmpdir="$(mktemp -d)"
cleanup() {
  rm -rf "$tmpdir"
}
trap cleanup EXIT

cat >"$tmpdir/codex" <<'SH'
#!/usr/bin/env bash
set -Eeuo pipefail

final=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --output-last-message)
      final="$2"
      shift 2
      ;;
    *)
      shift
      ;;
  esac
done

[[ -n "$final" ]] || {
  echo "missing --output-last-message" >&2
  exit 2
}

cat >/dev/null
cat >"$final" <<'EOF'
Quote regression fixture:
- double quotes: "quoted value"
- apostrophe: user's proof
- parentheses: (bounded patch)
- brackets: [allowed files]
- markdown fence:
```bash
printf '%s\n' "nested quote"
```

STATUS: GREEN
EOF
printf '{"type":"turn.completed"}\n'
SH
chmod +x "$tmpdir/codex"

prompt="$tmpdir/quote prompt (fixture).md"
cat >"$prompt" <<'EOF'
<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# Runner Quote Self Check

This prompt intentionally contains "quotes", apostrophe's text, (parentheses),
[brackets], and markdown fences.

```text
STATUS: GREEN
```
EOF

PATH="$tmpdir:$PATH" \
ALLOW_DIRTY=1 \
ALLOW_HISTORICAL_BATCH=1 \
AUTO_BRANCH=0 \
AUTO_COMMIT=0 \
AUTO_PUSH=0 \
ALLOW_NESTED_BATCH=1 \
BATCH_TYPE=docs-install \
STRUCTURED_OUTPUT=0 \
CONDUCTOR_MODEL=mock \
PATCH_MODEL=mock \
REVIEW_MODEL=mock \
REPAIR_MODEL=mock \
scripts/ambitions-codex-train.sh RUNNER-QUOTE-SELF-CHECK "$prompt" >/tmp/ambitions-runner-quote-self-check.out

if ! grep -q "Final status: GREEN" /tmp/ambitions-runner-quote-self-check.out; then
  cat /tmp/ambitions-runner-quote-self-check.out >&2
  echo "RED: quote self-check did not complete Green" >&2
  exit 1
fi

cat /tmp/ambitions-runner-quote-self-check.out
echo "GREEN: runner quote self-check passed"
