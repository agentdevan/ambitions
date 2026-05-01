#!/usr/bin/env bash
set -u

echo "== Ambitions batch train gate check =="
status=$(git status --short)
if [[ -n "$status" ]]; then
  echo "YELLOW_HINT working tree has changes"
  printf '%s\n' "$status"
else
  echo "GREEN_HINT working tree clean"
fi

changed=$(git diff --name-only HEAD 2>/dev/null || true)
if printf '%s\n' "$changed" | grep -q '^\.github/workflows/'; then
  echo "RED_HINT workflow file changed"
fi
if printf '%s\n' "$changed" | grep -Eq '^(Package.swift|project.yml|Brewfile)$'; then
  echo "YELLOW_HINT dependency/build manifest changed; verify scope"
fi
if git diff --name-only --cached | grep -Eq '^(output/|logs/|DerivedData|.*\.xcresult)'; then
  echo "YELLOW_HINT generated output appears staged"
fi

git diff --check || exit 1

if [[ "${RUN_BUILD:-0}" == "1" ]]; then
  scripts/build-local.sh || exit 1
else
  echo "INFO set RUN_BUILD=1 to include scripts/build-local.sh"
fi

echo "Gate hints complete; Codex judgment still required."
