#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT"

VERBOSE="${VERBOSE:-0}"

has_runner_metadata() {
  local file="$1"
  grep -Eq '^[[:space:]]*<!--[[:space:]]*AMBITIONS_RUNNER_REQUIRED:[[:space:]]*true[[:space:]]*-->' "$file" \
    && grep -Eq '^[[:space:]]*<!--[[:space:]]*RUN_WITH:[[:space:]]*scripts/ambitions-codex-train\.sh[[:space:]]*-->' "$file" \
    && grep -Eq '^[[:space:]]*<!--[[:space:]]*DIRECT_CODEX_EXECUTION:[[:space:]]*forbidden_unless_user_explicitly_bypasses_runner[[:space:]]*-->' "$file"
}

is_historical_path() {
  local file="$1"
  local lower_path
  lower_path="$(printf '%s' "$file" | tr '[:upper:]' '[:lower:]')"

  case "$lower_path" in
    *"/archive/"*|*"/archives/"*|*"/archived/"*|*"/historical/"*|*"/history/"*|*"/archive.md"*)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

is_eval_path() {
  local file="$1"
  case "$file" in
    .codex/evals/prompts/*|.codex/evals/prompts/**/*)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

is_template_path() {
  local file="$1"
  case "$file" in
    prompts/README.md|prompts/*/README.md|prompts/_*.md|prompts/desktop/*|prompts/desktop/**/*|prompts/templates/*|prompts/templates/**/*|prompts/trains/*|prompts/trains/**/*|docs/codex/chatgpt/*|docs/codex/chatgpt/**/*|.codex/templates/*|.codex/templates/**/*)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

is_active_prompt_path() {
  local file="$1"
  local dir

  if is_template_path "$file" || is_eval_path "$file" || is_historical_path "$file"; then
    return 1
  fi

  dir="${file%/*}"
  case "$dir" in
    prompts|prompts/ambitions|prompts/batches|prompts/batches/*|prompts/generated|prompts/generated/*|prompts/moat-install|prompts/moat-install/*)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

has_runner_metadata_outside_active_prompt_path() {
  local file="$1"

  ! is_active_prompt_path "$file" \
    && ! is_template_path "$file" \
    && ! is_eval_path "$file" \
    && ! is_historical_path "$file" \
    && has_runner_metadata "$file"
}

classification_for() {
  local file="$1"

  if is_historical_path "$file"; then
    printf 'historical/archive\n'
  elif is_eval_path "$file"; then
    printf 'eval prompt\n'
  elif is_template_path "$file"; then
    printf 'template/supporting prompt\n'
  elif is_active_prompt_path "$file"; then
    printf 'active runnable batch prompt\n'
  elif has_runner_metadata_outside_active_prompt_path "$file"; then
    printf 'mislocated runnable prompt\n'
  else
    printf 'supporting prompt/governance doc\n'
  fi
}

find_prompt_like_files() {
  local roots=(
    "prompts"
    ".codex/evals/prompts"
    ".codex/templates"
    "docs/codex"
  )

  local root
  for root in "${roots[@]}"; do
    [[ -d "$root" ]] || continue
    find "$root" -type f -name '*.md'
  done | sort -u
}

missing_metadata=()
mislocated=()
active=()
support=()
evals=()
templates=()
historical=()

while IFS= read -r file; do
  [[ -n "$file" ]] || continue
  classification="$(classification_for "$file")"

  case "$classification" in
    "active runnable batch prompt")
      active+=("$file")
      if ! has_runner_metadata "$file"; then
        missing_metadata+=("$file")
      fi
      ;;
    "mislocated runnable prompt")
      mislocated+=("$file")
      ;;
    "eval prompt")
      evals+=("$file")
      ;;
    "template/supporting prompt")
      templates+=("$file")
      ;;
    "historical/archive")
      historical+=("$file")
      ;;
    *)
      support+=("$file")
      ;;
  esac
done < <(find_prompt_like_files)

if [[ "${#missing_metadata[@]}" -gt 0 ]]; then
  echo "RED: active runnable prompt files missing exact Ambitions runner metadata"
  printf '%s\n' "${missing_metadata[@]}"
  exit 1
fi

if [[ "$VERBOSE" == "1" ]]; then
  printf 'Active runnable prompts (%s):\n' "${#active[@]}"
  printf '%s\n' "${active[@]:-}"
  printf 'Template/supporting prompts (%s):\n' "${#templates[@]}"
  printf '%s\n' "${templates[@]:-}"
  printf 'Eval prompts (%s):\n' "${#evals[@]}"
  printf '%s\n' "${evals[@]:-}"
  printf 'Historical/archive prompts (%s):\n' "${#historical[@]}"
  printf '%s\n' "${historical[@]:-}"
  printf 'Mislocated runnable prompts (%s):\n' "${#mislocated[@]}"
  printf '%s\n' "${mislocated[@]:-}"
  printf 'Supporting governance docs (%s):\n' "${#support[@]}"
  printf '%s\n' "${support[@]:-}"
fi

if [[ "${#mislocated[@]}" -gt 0 ]]; then
  echo "YELLOW: runner-wrapped prompts found outside prompts/batches; move them, classify them as templates/evals/historical, or remove runnable metadata"
  printf '%s\n' "${mislocated[@]}"
  exit 1
fi

echo "GREEN: all active runnable prompts have exact Ambitions runner metadata"
printf 'Active runnable prompts audited: %s\n' "${#active[@]}"
printf 'Support/eval/template/historical files classified as non-actionable: %s\n' "$(( ${#templates[@]} + ${#evals[@]} + ${#historical[@]} + ${#support[@]} ))"
