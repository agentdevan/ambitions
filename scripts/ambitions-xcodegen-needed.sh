#!/usr/bin/env bash
set -Eeuo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd -P)"
cd "$REPO_ROOT"

PROJECT_FILE="project.yml"
SCHEME_FILE="Ambitions.xcodeproj/project.pbxproj"
PACKAGE_FILE="Package.swift"
STAMP_FILE=".xcode-version"

if [[ ! -f "$PROJECT_FILE" ]]; then
  echo "XCODEGEN_NEEDED=unknown"
  echo "REASON=project.yml missing"
  exit 2
fi

if ! command -v xcodegen >/dev/null 2>&1; then
  echo "XCODEGEN_NEEDED=unknown"
  echo "REASON=xcodegen not installed"
  exit 2
fi

need=0
reason=""

if [[ ! -f "$SCHEME_FILE" ]]; then
  need=1
  reason="generated project missing"
elif [[ "$PROJECT_FILE" -nt "$SCHEME_FILE" ]]; then
  need=1
  reason="project.yml changed after generated project"
elif [[ -f "$PACKAGE_FILE" && "$PACKAGE_FILE" -nt "$SCHEME_FILE" ]]; then
  need=1
  reason="Package.swift changed after generated project"
elif [[ -f "$STAMP_FILE" && "${STAMP_FILE}" -nt "$SCHEME_FILE" ]]; then
  need=1
  reason="toolchain metadata changed"
fi

if [[ "$need" -eq 0 ]]; then
  while IFS= read -r changed_path; do
    [[ -z "$changed_path" ]] && continue
    case "$changed_path" in
      "$PACKAGE_FILE")
        need=1
        reason="Package.swift changed"
        ;;
      *.swift|*.storyboard|*.xib|*.xcassets|*.xcmappingmodel|*.xcdatamodel|*.strings|*.stringsdict|*.entitlements)
        need=1
        reason="source/resource changed: $changed_path"
        ;;
      Native/TestPlans/*.xctestplan|*.xctestplan|project.yml|Ambitions.xcodeproj/*|*.xctproj*|Package.resolved)
        need=1
        reason="project or test plan input changed"
        ;;
    esac
    [[ "$need" -eq 1 ]] && break
  done < <(git status --porcelain --untracked-files=no -- . | awk '{print $2}')
fi

if [[ "$need" -eq 1 ]]; then
  echo "XCODEGEN_NEEDED=1"
  echo "REASON=$reason"
  exit 0
fi

echo "XCODEGEN_NEEDED=0"
echo "REASON=project build inputs unchanged"
exit 0
