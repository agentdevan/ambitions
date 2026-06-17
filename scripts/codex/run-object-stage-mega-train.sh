#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT"

TRAIN_DIR="prompts/object-stage-mega-train"
START_BATCH="${START_BATCH:-auto}"
END_BATCH="${END_BATCH:-auto}"
ACCESS_MODE="${ACCESS_MODE:-full}"
MAX_REPAIR_PASSES="${MAX_REPAIR_PASSES:-2}"
KEEP_GOING_ON_YELLOW="${KEEP_GOING_ON_YELLOW:-0}"
ALLOW_YELLOW_COMMIT="${ALLOW_YELLOW_COMMIT:-0}"
AUTO_PUSH="${AUTO_PUSH:-1}"
RUNNER="scripts/ambitions-codex-train.sh"

if [[ ! -x "$RUNNER" ]]; then
  echo "RED: runner missing or not executable: $RUNNER" >&2
  exit 1
fi

if [[ ! -d "$TRAIN_DIR" ]]; then
  echo "RED: train prompt directory missing: $TRAIN_DIR" >&2
  exit 1
fi

git status --short --branch
git rev-parse HEAD

prompts=()
while IFS= read -r prompt; do
  prompts+=("$prompt")
done < <(find "$TRAIN_DIR" -maxdepth 1 -type f -name 'AMB-AOM-*.md' | sort)

if [[ "${#prompts[@]}" -eq 0 ]]; then
  echo "RED: no AMB-AOM prompts found in $TRAIN_DIR" >&2
  exit 1
fi

selected=()
started=0
for prompt in "${prompts[@]}"; do
  batch_id="$(basename "$prompt" .md)"
  if [[ "$START_BATCH" == "auto" || "$batch_id" == "$START_BATCH" ]]; then
    started=1
  fi
  if [[ "$started" == "1" ]]; then
    selected+=("$prompt")
  fi
  if [[ "$END_BATCH" != "auto" && "$batch_id" == "$END_BATCH" ]]; then
    break
  fi
done

if [[ "${#selected[@]}" -eq 0 ]]; then
  echo "RED: selected train is empty. START_BATCH=$START_BATCH END_BATCH=$END_BATCH" >&2
  exit 1
fi

echo "Object-Stage Mega Train selected prompts:"
for prompt in "${selected[@]}"; do
  echo "- $prompt"
done

for prompt in "${selected[@]}"; do
  batch_id="$(basename "$prompt" .md)"
  echo "== Running $batch_id =="
  git pull --ff-only origin main
  ACCESS_MODE="$ACCESS_MODE" \
  AUTO_BRANCH=0 \
  ALLOW_MAIN_COMMIT=1 \
  AUTO_COMMIT=1 \
  AUTO_PUSH="$AUTO_PUSH" \
  KEEP_GOING_ON_YELLOW="$KEEP_GOING_ON_YELLOW" \
  ALLOW_YELLOW_COMMIT="$ALLOW_YELLOW_COMMIT" \
  MAX_REPAIR_PASSES="$MAX_REPAIR_PASSES" \
  BATCH_TYPE=source-changing \
  "$RUNNER" "$batch_id" "$prompt"
  git pull --ff-only origin main
  git status --short --branch
done

echo "GREEN: object-stage mega train completed selected prompts"
