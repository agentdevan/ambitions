#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"

BASE_REF="${GITHUB_BASE_REF:-main}"
BASE_SHA="${GITHUB_BASE_SHA:-}"

resolve_base() {
  if [[ -n "$BASE_SHA" ]] && git cat-file -e "${BASE_SHA}^{commit}" 2>/dev/null; then
    printf '%s\n' "$BASE_SHA"
    return
  fi

  if git rev-parse --verify "origin/${BASE_REF}" >/dev/null 2>&1; then
    git merge-base HEAD "origin/${BASE_REF}"
    return
  fi

  if git rev-parse --verify origin/main >/dev/null 2>&1; then
    git merge-base HEAD origin/main
    return
  fi

  git rev-parse HEAD
}

BASE_COMMIT="$(resolve_base)"
approved_log_path_regex='^(docs/qa/evidence/|docs/validation/|artifacts/)'

failures=()

add_failure() {
  failures+=("$1")
}

echo "# Ambitions PR Hygiene"
echo "base=${BASE_COMMIT}"

git diff --check
git status --short

if rg -n '^(<<<<<<<|=======|>>>>>>>)' --glob '!build/**' --glob '!DerivedData/**' --glob '!*.xcresult/**' .; then
  add_failure "unresolved merge conflict markers found"
fi

changed_files=()
while IFS= read -r file; do
  [[ -n "$file" ]] && changed_files+=("$file")
done < <(
  {
    git diff --name-only --diff-filter=ACMR "$BASE_COMMIT" -- || true
    git diff --name-only --diff-filter=ACMR -- || true
    git ls-files --others --exclude-standard || true
  } | sort -u
)

new_files=()
while IFS= read -r file; do
  [[ -n "$file" ]] && new_files+=("$file")
done < <(
  {
    git diff --name-only --diff-filter=A "$BASE_COMMIT" -- || true
    git ls-files --others --exclude-standard || true
  } | sort -u
)

bad_path_regex='(^|/)(DerivedData|node_modules|Pods|Carthage/Checkouts|\.build|\.swiftpm|vendor/bundle)(/|$)|\.xcresult(/|$)|(^|/)\.DS_Store$|(^|/)(build|dist|DerivedData)/|(\.ipa|\.app|\.dSYM|\.xcarchive|\.profdata|\.profraw)$'
sim_log_regex='(^|/)(CoreSimulator|Simulator|simulator).*\.(log|trace|txt|json)$|(\.crash|\.ips|\.spin)$'

for file in "${new_files[@]}"; do
  [[ -z "$file" ]] && continue
  if [[ "$file" =~ $bad_path_regex ]]; then
    add_failure "forbidden generated/build/dependency artifact added: $file"
  fi
  if [[ "$file" =~ $sim_log_regex ]] && [[ ! "$file" =~ $approved_log_path_regex ]]; then
    add_failure "simulator/device log added outside approved proof paths: $file"
  fi
done

for file in "${changed_files[@]}"; do
  [[ -z "$file" || ! -f "$file" ]] && continue
  case "$file" in
    *.png|*.jpg|*.jpeg|*.gif|*.pdf|*.ico|*.ipa|*.app|*.xcresult|*.zip|*.gz|*.xz)
      continue
      ;;
  esac
  if LC_ALL=C rg -n '[[:blank:]]$' "$file" >/tmp/ambitions-pr-hygiene-trailing.$$ 2>/dev/null; then
    while IFS= read -r hit; do
      add_failure "trailing whitespace: $hit"
    done < /tmp/ambitions-pr-hygiene-trailing.$$
  fi
  rm -f /tmp/ambitions-pr-hygiene-trailing.$$
done

if ((${#failures[@]} > 0)); then
  printf 'RED: repo hygiene failures\n' >&2
  printf '%s\n' "${failures[@]}" >&2
  exit 1
fi

echo "GREEN: repo hygiene checks passed"
