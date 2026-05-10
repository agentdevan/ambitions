#!/usr/bin/env bash
set -Eeuo pipefail

LOCK_FILE=".codex/state/global-train.lock"

usage() {
  cat <<'USAGE'
Usage:
  scripts/ambitions-process-preflight.sh --status
  scripts/ambitions-process-preflight.sh --assert-clear
  scripts/ambitions-process-preflight.sh --json
USAGE
}

die() {
  echo "RED: $*" >&2
  exit 1
}

if [ "$#" -ne 1 ]; then
  usage >&2
  exit 1
fi

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd -P)"
cd "$REPO_ROOT"

MODE="$1"
case "$MODE" in
  --status|--assert-clear|--json)
    ;;
  *)
    usage >&2
    die "unsupported mode: $MODE"
    ;;
esac

PROCESS_LINES=""
SELF_TREE=""
SELF_PID_FOR_TREE="${PROCESS_PREFLIGHT_SELF_PID:-$$}"
BLOCKER_LINES=()
IGNORED_LINES=()

load_processes() {
  if [ -n "${PROCESS_PREFLIGHT_PS_FILE:-}" ] && [ -f "$PROCESS_PREFLIGHT_PS_FILE" ]; then
    PROCESS_LINES="$(cat "$PROCESS_PREFLIGHT_PS_FILE")"
  else
    PROCESS_LINES="$(ps -axo pid=,ppid=,command=)"
  fi

  if [ -z "$PROCESS_LINES" ]; then
    return 1
  fi
  return 0
}

get_parent_pid() {
  local target_pid="$1"
  printf '%s' "$PROCESS_LINES" | awk -v pid="$target_pid" '$1 == pid {print $2; exit}'
}

collect_self_tree() {
  local current="$1"
  local limit=0
  local tree=""

  while [ -n "$current" ] && [ "$current" != "0" ] && [ "$current" != "1" ]; do
    case " $tree " in
      *" $current "*)
        break
        ;;
      *)
        if [ -n "$tree" ]; then
          tree="$tree $current"
        else
          tree="$current"
        fi
        ;;
    esac

    local parent
    parent="$(get_parent_pid "$current")"
    if [ -z "$parent" ]; then
      break
    fi

    current="$parent"
    limit=$((limit + 1))
    [ "$limit" -gt 4096 ] && break
  done

  printf '%s' "$tree"
}

get_command_for_pid() {
  local target_pid="$1"
  printf '%s' "$PROCESS_LINES" | awk -v pid="$target_pid" '$1 == pid {$1=""; $2=""; sub(/^[[:space:]]+/, ""); print; exit}'
}

add_pid_to_tree() {
  local tree="$1"
  local pid="$2"
  case " $tree " in
    *" $pid "*)
      printf '%s' "$tree"
      ;;
    *)
      if [ -n "$tree" ]; then
        printf '%s %s' "$tree" "$pid"
      else
        printf '%s' "$pid"
      fi
      ;;
  esac
}

current_runner_seeds() {
  local seeds=""
  local pid
  local cmd

  for pid in $SELF_TREE; do
    cmd="$(get_command_for_pid "$pid")"
    if is_ambitions_train_process "$cmd" || is_codex_exec_process "$cmd"; then
      seeds="$(add_pid_to_tree "$seeds" "$pid")"
    fi
  done

  printf '%s' "$seeds"
}

expand_tree_with_descendants() {
  local tree="$1"
  local changed=1
  local limit=0
  local line
  local pid
  local ppid

  while [ "$changed" -eq 1 ] && [ "$limit" -lt 4096 ]; do
    changed=0
    while IFS= read -r line; do
      [ -n "$line" ] || continue
      set -- $line
      pid="$1"
      ppid="$2"
      case "$pid" in
        ''|*[!0-9]*)
          continue
          ;;
      esac
      case "$ppid" in
        ''|*[!0-9-]*)
          continue
          ;;
      esac
      case " $tree " in
        *" $pid "*)
          continue
          ;;
      esac
      case " $tree " in
        *" $ppid "*)
          tree="$(add_pid_to_tree "$tree" "$pid")"
          changed=1
          ;;
      esac
    done <<< "$PROCESS_LINES"
    limit=$((limit + 1))
  done

  printf '%s' "$tree"
}

collect_runner_family_tree() {
  local tree="$1"
  local seeds
  local seed

  seeds="$(current_runner_seeds)"
  if [ -n "$seeds" ]; then
    for seed in $seeds; do
      tree="$(add_pid_to_tree "$tree" "$seed")"
    done
    tree="$(expand_tree_with_descendants "$tree")"
  fi

  printf '%s' "$tree"
}

is_self_or_ancestor() {
  local pid="$1"
  case " $SELF_TREE " in
    *" $pid "*)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

is_ignored_helper() {
  local cmd="$1"
  case "$cmd" in
    *xcodebuildmcp*|*xcodebuild-mcp*|*xcodebuild_mcp*|*/xcodebuildmcp*|*grep*|*pgrep*)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

is_ambitions_train_process() {
  local cmd="$1"
  case "$cmd" in
    bash\ scripts/ambitions-codex-train.sh*|\
    bash\ ./scripts/ambitions-codex-train.sh*|\
    bash\ */scripts/ambitions-codex-train.sh*|\
    /bin/bash\ scripts/ambitions-codex-train.sh*|\
    /bin/bash\ ./scripts/ambitions-codex-train.sh*|\
    /bin/bash\ */scripts/ambitions-codex-train.sh*|\
    scripts/ambitions-codex-train.sh*|\
    ./scripts/ambitions-codex-train.sh*|\
    */scripts/ambitions-codex-train.sh\ *)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

is_codex_exec_process() {
  local cmd="$1"
  case "$cmd" in
    codex\ exec*|*/codex\ exec*)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

is_real_xcodebuild_process() {
  local cmd="$1"
  case "$cmd" in
    *xcodebuild*)
      case "$cmd" in
        *xcodebuildmcp*|*xcodebuild-mcp*|*xcodebuild_mcp*)
          return 1
          ;;
        *)
          return 0
          ;;
      esac
      ;;
    *)
      return 1
      ;;
  esac
}

read_lock_pid() {
  awk -F': ' '/^pid:[[:space:]]*/ {print $2; exit}' "$LOCK_FILE" 2>/dev/null || true
}

classify_lock() {
  if [ ! -f "$LOCK_FILE" ]; then
    return 0
  fi

  local lock_pid
  lock_pid="$(read_lock_pid)"
  if [ -z "$lock_pid" ]; then
    IGNORED_LINES+=("STALE_LOCK|lock missing pid|0|$LOCK_FILE")
    return 0
  fi

  if kill -0 "$lock_pid" 2>/dev/null; then
    BLOCKER_LINES+=("BLOCKER|global-train-lock|$lock_pid|$LOCK_FILE")
    return 1
  fi

  if rm -f "$LOCK_FILE"; then
    IGNORED_LINES+=("IGNORED|stale-lock-cleared|$lock_pid|$LOCK_FILE")
  fi
}

format_json_escape() {
  local text="$1"
  text="${text//\\/\\\\}"
  text="${text//\"/\\\"}"
  text="${text//$'\n'/\\n}"
  printf '%s' "$text"
}

append_blocker() {
  local line="$1"
  BLOCKER_LINES+=("$line")
  if [ "$status" = "CLEAR" ]; then
    status="BLOCKED"
  fi
}

append_ignored() {
  IGNORED_LINES+=("$1")
}

array_count() {
  local array_name="$1"
  local count
  set +u
  eval "count=\${#${array_name}[@]}"
  set -u
  printf '%s' "$count"
}

status="CLEAR"

if ! load_processes; then
  status="UNKNOWN"
fi

if [ "$status" != "UNKNOWN" ]; then
  SELF_TREE="$(collect_self_tree "$SELF_PID_FOR_TREE")"
  SELF_TREE="$(collect_runner_family_tree "$SELF_TREE")"
fi

if ! classify_lock; then
  :
fi

if [ "$status" != "UNKNOWN" ]; then
  while IFS= read -r line; do
    [ -n "$line" ] || continue

    set -- $line
    pid="$1"
    ppid="$2"
    shift 2
    cmd="$*"

    case "$pid" in
      ''|*[!0-9]*)
        continue
        ;;
    esac
    case "$ppid" in
      ''|*[!0-9-]*)
        continue
        ;;
    esac

    if is_self_or_ancestor "$pid"; then
      append_ignored "IGNORED|self-tree-process|$pid|$cmd"
      continue
    fi

    if is_ignored_helper "$cmd"; then
      append_ignored "IGNORED|helper-process|$pid|$cmd"
      continue
    fi

    if is_ambitions_train_process "$cmd"; then
      append_blocker "BLOCKER|ambitions-codex-train|$pid|$cmd"
      continue
    fi

    if is_codex_exec_process "$cmd"; then
      append_blocker "BLOCKER|codex-exec|$pid|$cmd"
      continue
    fi

    if is_real_xcodebuild_process "$cmd"; then
      append_blocker "BLOCKER|real-xcodebuild|$pid|$cmd"
      continue
    fi
  done <<< "$PROCESS_LINES"
fi

if [ "$MODE" = "--json" ]; then
  printf '{\n'
  printf '  "status": "%s",\n' "$status"
  printf '  "self_pid": %s,\n' "$SELF_PID_FOR_TREE"
  printf '  "repo_root": "%s",\n' "$REPO_ROOT"
  printf '  "processes": {\n'
  printf '    "blockers": ['
  sep=""
  if [ "$(array_count BLOCKER_LINES)" -gt 0 ]; then
    for entry in "${BLOCKER_LINES[@]}"; do
      IFS='|' read -r kind subtype pid detail <<EOF_JSON
$entry
EOF_JSON
      printf '%s\n      {"kind":"%s","subtype":"%s","pid":%s,"command":"%s"}' "$sep" "$kind" "$subtype" "$pid" "$(format_json_escape "$detail")"
      sep=",";
    done
  else
    printf '\n'
  fi
  printf '\n    ],\n'
  printf '    "ignored": ['
  sep=""
  if [ "$(array_count IGNORED_LINES)" -gt 0 ]; then
    for entry in "${IGNORED_LINES[@]}"; do
      IFS='|' read -r kind subtype pid detail <<EOF_JSON
$entry
EOF_JSON
      printf '%s\n      {"kind":"%s","subtype":"%s","pid":%s,"command":"%s"}' "$sep" "$kind" "$subtype" "$pid" "$(format_json_escape "$detail")"
      sep=",";
    done
  else
    printf '\n'
  fi
  printf '\n    ]\n  }\n}\n'
else
  if [ "$status" = "CLEAR" ]; then
    echo "STATUS: CLEAR"
  elif [ "$status" = "BLOCKED" ]; then
    echo "STATUS: BLOCKED"
  else
    echo "STATUS: UNKNOWN"
  fi

  printf 'SELF_PID=%s\n' "$SELF_PID_FOR_TREE"
  printf 'SELF_TREE=%s\n' "$SELF_TREE"
  printf -- '---\n'
  echo 'BLOCKERS:'
  if [ "$(array_count BLOCKER_LINES)" -eq 0 ]; then
    echo "none"
  else
    for entry in "${BLOCKER_LINES[@]}"; do
      echo "$entry"
    done
  fi
  printf -- '---\n'
  echo 'IGNORED:'
  if [ "$(array_count IGNORED_LINES)" -eq 0 ]; then
    echo "none"
  else
    for entry in "${IGNORED_LINES[@]}"; do
      echo "$entry"
    done
  fi
fi

if [ "$MODE" = "--assert-clear" ]; then
  if [ "$status" = "BLOCKED" ]; then
    exit 86
  fi
  if [ "$status" = "CLEAR" ]; then
    exit 0
  fi
  exit 87
fi
