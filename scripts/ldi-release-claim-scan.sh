#!/usr/bin/env bash
set -u
echo "ldi-release-claim-scan: unsupported Living Dream / release claim scan"
status=0
patterns=(
  "fully autonomous planning"
  "any dream guaranteed"
  "official requirements verified"
  "legal advice"
  "medical advice"
  "financial advice"
  "App Store ready"
  "TestFlight ready"
  "device verified"
  "public accessibility compliant"
  "production AI"
  "hosted AI"
  "backend sync"
  "user-data server"
)
allow='not|\bno\b|without|forbidden|must not|does not claim|future|queued|not implemented|non-claim|not prove|unless|forbidden claims|Forbidden Current Claims|forbidden files|not allowed|no runtime|No runtime|No .* claimed|claim boundary|Must Not Claim|Does Not Prove|Red Criteria|Hard Non-Goals|Release-Claim|Release Claim|unsupported claims|rejects unsupported|must not include|should not claim|do not claim|Do not claim|do not implement|Do not implement|Validation Commands|rg -n|grep -R|cat \|\| true|Never claim'
changed_files=()
while IFS= read -r f; do
  [[ -n "$f" ]] && changed_files+=("$f")
done < <(git diff --name-only --diff-filter=ACMRTUXB HEAD -- README.md docs .codex Native 2>/dev/null || true)
if [[ "${#changed_files[@]}" -eq 0 ]]; then
  echo "PASS: no changed files to scan for LDI/release claims."
  exit 0
fi
for pat in "${patterns[@]}"; do
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    file="${line%%:*}"
    rest="${line#*:}"
    lineno="${rest%%:*}"
    context="$line"
    if [[ -f "$file" && "$lineno" =~ ^[0-9]+$ ]]; then
      start=$(( lineno > 8 ? lineno - 8 : 1 ))
      end=$(( lineno + 2 ))
      context="$(sed -n "${start},${end}p" "$file" 2>/dev/null || printf '%s\n' "$line")"
    fi
    if ! printf '%s
' "$context" | rg -qi "$allow"; then
      echo "RED: unsupported claim candidate: $line"
      status=1
    fi
  done < <(rg -n -i "$pat" "${changed_files[@]}" 2>/dev/null || true)
done
if [[ "$status" -eq 0 ]]; then
  echo "PASS: no unsupported LDI/release claims found outside claim-boundary contexts."
fi
exit "$status"
