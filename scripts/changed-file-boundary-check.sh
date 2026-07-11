#!/usr/bin/env bash
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT" || exit
name="$(basename "$0")"
echo "$name: Codex OS deterministic advisory scan"

allow_workflows=0
while [ "$#" -gt 0 ]; do
  case "$1" in
    --allow-workflows) allow_workflows=1; shift ;;
    -h|--help)
      echo "Usage: scripts/changed-file-boundary-check.sh [--allow-workflows]"
      exit 0
      ;;
    *)
      echo "unsupported arg: $1" >&2
      exit 2
      ;;
  esac
done

changed=$(git diff --name-only HEAD --)
pattern='^(Native/|Packages/AmbitionsDesignSystem/Sources/|Packages/AmbitionsDesignSystem/AppUI/Sources/|project.yml|Package.resolved|.*\.xcodeproj|.*PrivacyInfo\.xcprivacy)'
if [ "$allow_workflows" -eq 0 ]; then
  pattern='^(Native/|Packages/AmbitionsDesignSystem/Sources/|Packages/AmbitionsDesignSystem/AppUI/Sources/|project.yml|Package.resolved|\.github/workflows/|.*\.xcodeproj|.*PrivacyInfo\.xcprivacy)'
fi
if echo "$changed" | rg -q "$pattern"; then
  echo "RED forbidden boundary touched"
  echo "$changed" | rg "$pattern"
  exit 1
fi
echo "GREEN changed-file boundary contains no forbidden production families"
