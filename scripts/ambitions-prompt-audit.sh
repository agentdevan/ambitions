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

looks_like_batch_prompt() {
  local file="$1"
  grep -Eq '^#[[:space:]]*Batch ID|^##[[:space:]]*Batch ID|make batch BATCH=' "$file"
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
    prompts/_*.md|.codex/templates/*|.codex/templates/**/*)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

looks_runnable() {
  local file="$1"

  case "$file" in
    docs/codex/*)
      has_runner_metadata "$file" && looks_like_batch_prompt "$file"
      return
      ;;
  esac

  case "$file" in
    prompts/batches/*.md)
      has_runner_metadata "$file" && looks_like_batch_prompt "$file"
      ;;
    *)
      if is_template_path "$file" || is_eval_path "$file" || is_historical_path "$file"; then
        return 1
      fi

      has_runner_metadata "$file" && looks_like_batch_prompt "$file"
      return
  esac

  return
}

classification_for() {
  local file="$1"

  if is_historical_path "$file"; then
    printf 'historical/archive\n'
  elif is_eval_path "$file"; then
    printf 'eval prompt\n'
  elif is_template_path "$file"; then
    printf 'template/supporting prompt\n'
  elif looks_runnable "$file"; then
    printf 'active runnable batch prompt\n'
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

missing=()
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
        missing+=("$file")
      fi
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

if [[ "${#missing[@]}" -gt 0 ]]; then
  echo "RED: active runnable prompt files missing runner metadata"
  printf '%s\n' "${missing[@]}"
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
  printf 'Supporting governance docs (%s):\n' "${#support[@]}"
  printf '%s\n' "${support[@]:-}"
fi

if [[ "${#templates[@]}" -gt 0 || "${#evals[@]}" -gt 0 || "${#historical[@]}" -gt 0 || "${#support[@]}" -gt 0 ]]; then
  echo "YELLOW: prompt-like support/eval/template files classified; no active runnable prompt missing metadata"
  printf 'Active runnable prompts audited: %s\n' "${#active[@]}"
  printf 'Support/eval/template/historical files classified: %s\n' "$(( ${#templates[@]} + ${#evals[@]} + ${#historical[@]} + ${#support[@]} ))"
  exit 0
fi

echo "GREEN: all active runnable prompts require the Ambitions runner"
printf 'Active runnable prompts audited: %s\n' "${#active[@]}"
