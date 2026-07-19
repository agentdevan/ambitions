#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PACKAGE_ROOT="${REPO_ROOT}/tools/mcp/ambitions_native_mcp"
BINARY="${AMBITIONS_NATIVE_MCP_BINARY:-${PACKAGE_ROOT}/.build/debug/ambitions-native-mcp}"
EXIT_TIMEOUT_TENTHS="${AMBITIONS_NATIVE_MCP_EXIT_TIMEOUT_TENTHS:-20}"

if [[ ! -x "${BINARY}" ]]; then
  swift build --package-path "${PACKAGE_ROOT}" --product ambitions-native-mcp
fi

failures=0
for toolset in repo visual accessibility swift-semantic instruments apple-docs source-atlas; do
  "${BINARY}" --toolset "${toolset}" </dev/null >/dev/null 2>/dev/null &
  pid=$!
  exited=0

  for ((attempt = 0; attempt < EXIT_TIMEOUT_TENTHS; attempt += 1)); do
    if ! kill -0 "${pid}" 2>/dev/null; then
      wait "${pid}"
      status=$?
      if [[ "${status}" -ne 0 ]]; then
        printf 'FAIL toolset=%s exited status=%s after stdin EOF\n' "${toolset}" "${status}" >&2
        failures=$((failures + 1))
      fi
      exited=1
      break
    fi
    sleep 0.1
  done

  if [[ "${exited}" -eq 0 ]]; then
    printf 'FAIL toolset=%s remained alive after stdin EOF pid=%s\n' "${toolset}" "${pid}" >&2
    kill -TERM "${pid}" 2>/dev/null || true
    wait "${pid}" 2>/dev/null || true
    failures=$((failures + 1))
  fi
done

if [[ "${failures}" -ne 0 ]]; then
  printf 'Ambitions native MCP lifecycle check failed: %s toolset(s) leaked.\n' "${failures}" >&2
  exit 1
fi

printf 'Ambitions native MCP lifecycle check passed: all toolsets exited after stdin EOF.\n'
