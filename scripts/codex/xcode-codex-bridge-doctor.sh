#!/usr/bin/env bash
set -u

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd -P)"
cd "$ROOT" || exit 1

red=0
yellow=0

section() {
  printf '\n== %s ==\n' "$1"
}

mark_red() {
  red=1
  printf 'RED: %s\n' "$1"
}

mark_yellow() {
  yellow=1
  printf 'YELLOW: %s\n' "$1"
}

have_file() {
  [[ -f "$1" ]]
}

have_exec() {
  [[ -x "$1" ]]
}

section "Repo"
branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || printf 'unknown')"
sha="$(git rev-parse HEAD 2>/dev/null || printf 'unknown')"
printf 'branch: %s\n' "$branch"
printf 'sha: %s\n' "$sha"
git status --short --branch || mark_yellow "git status unavailable"
if [[ "$branch" != "main" ]]; then
  mark_red "expected main branch for Ambitions bridge work"
fi
if git diff --name-only --diff-filter=U | grep -q .; then
  mark_red "unmerged git conflict files are present"
fi

section "Xcode"
if command -v xcodebuild >/dev/null 2>&1; then
  xcodebuild -version
else
  mark_red "xcodebuild is missing"
fi

if command -v xcode-select >/dev/null 2>&1; then
  xcode-select -p || mark_red "xcode-select cannot resolve a developer directory"
else
  mark_red "xcode-select is missing"
fi

section "Codex MCP"
codex_mcp_visible=0
if command -v codex >/dev/null 2>&1; then
  codex_mcp_output="$(codex mcp list 2>&1)"
  codex_mcp_status=$?
  printf '%s\n' "$codex_mcp_output"
  if [[ "$codex_mcp_status" -eq 0 ]]; then
    codex_mcp_visible=1
  else
    mark_yellow "codex mcp list failed"
  fi
else
  mark_yellow "codex CLI is not in PATH"
fi

section "Xcode Agent CLI"
agent_cli_visible=0
agent_skill_export_visible=0
agent_find_output="$(xcrun --find agent 2>&1)"
agent_find_status=$?
printf '%s\n' "$agent_find_output"
if [[ "$agent_find_status" -eq 0 ]]; then
  agent_cli_visible=1
else
  mark_yellow "xcrun agent CLI is not visible"
fi

section "Xcode Agent Skill Export"
agent_export_output="$(xcrun agent skills export 2>&1)"
agent_export_status=$?
printf '%s\n' "$agent_export_output"
if [[ "$agent_export_status" -eq 0 ]]; then
  agent_skill_export_visible=1
else
  mark_yellow "xcrun agent skills export is not visible"
fi

section "xcodebuildmcp Fallback"
xcodebuildmcp_fallback=0
if have_file ".xcodebuildmcp/config.yaml"; then
  xcodebuildmcp_fallback=1
  printf '%s\n' ".xcodebuildmcp/config.yaml:"
  sed -n '1,220p' .xcodebuildmcp/config.yaml
else
  mark_red ".xcodebuildmcp/config.yaml is missing"
fi

if have_file ".xcodebuildmcp/codex-timeout-policy.json"; then
  printf '%s\n' ".xcodebuildmcp/codex-timeout-policy.json:"
  sed -n '1,220p' .xcodebuildmcp/codex-timeout-policy.json
else
  mark_yellow ".xcodebuildmcp/codex-timeout-policy.json is missing"
fi

section "Project Configuration"
if have_file "project.yml"; then
  printf 'project.yml: present\n'
  printf 'deployment targets:\n'
  awk '/deploymentTarget:|IPHONEOS_DEPLOYMENT_TARGET:/ { print "  " $0 }' project.yml
  printf 'swift version:\n'
  awk '/SWIFT_VERSION:/ { print "  " $0 }' project.yml
else
  mark_red "project.yml is missing"
fi

if have_file "Package.swift"; then
  printf 'Package.swift swift tools/platform lines:\n'
  awk '/swift-tools-version|\.iOS|\.macOS/ { print "  " $0 }' Package.swift
fi

unsupported_deployment=0
if have_file "project.yml"; then
  while IFS= read -r value; do
    [[ -z "$value" ]] && continue
    if [[ "$value" != "26.0" ]]; then
      unsupported_deployment=1
      printf 'unsupported deployment target value: %s\n' "$value"
    fi
  done < <(awk '
    /IPHONEOS_DEPLOYMENT_TARGET:/ { gsub(/"/, "", $2); print $2 }
    /deploymentTarget:/ { gsub(/"/, "", $2); print $2 }
  ' project.yml)
fi
if [[ "$unsupported_deployment" -eq 1 ]]; then
  mark_red "deployment target drift from supported iOS 26.0 baseline"
fi

section "Simulator Availability"
if command -v xcrun >/dev/null 2>&1; then
  xcrun simctl list devices available 2>/dev/null | sed -n '1,80p' || mark_yellow "simctl devices unavailable"
else
  mark_yellow "xcrun is not available for simulator inspection"
fi

section "Repo Validation Scripts"
validation_bridge=0
if have_exec "scripts/ambitions-xcode-validate.sh"; then
  validation_bridge=1
  printf 'present executable: scripts/ambitions-xcode-validate.sh\n'
else
  mark_red "scripts/ambitions-xcode-validate.sh is missing or not executable"
fi

for script in \
  "scripts/ambitions-xcodebuildmcp-register.sh" \
  "scripts/codex/program-preflight.sh" \
  "scripts/ambitions-codex-os-doctor.py"; do
  if [[ -e "$script" ]]; then
    printf 'present: %s\n' "$script"
  else
    mark_yellow "$script is missing"
  fi
done

section "Interpretation"
if [[ "$red" -eq 1 ]]; then
  printf 'RED: Xcode or repo validation bridge is missing, deployment target drift exists, branch is unsafe, or git conflicts are present.\n'
  exit 1
fi

if [[ "$agent_cli_visible" -eq 1 && "$agent_skill_export_visible" -eq 1 && "$validation_bridge" -eq 1 ]]; then
  printf 'GREEN: Xcode is present, Apple-native Xcode agent surface is visible, and repo validation scripts are present.\n'
  exit 0
fi

if [[ "$xcodebuildmcp_fallback" -eq 1 && "$validation_bridge" -eq 1 ]]; then
  printf 'YELLOW: Apple-native Xcode MCP/agent skill export is not fully visible, but xcodebuildmcp fallback and repo validation scripts are present.\n'
  exit 0
fi

printf 'RED: no usable Apple-native Xcode agent surface or xcodebuildmcp fallback was found.\n'
exit 1
