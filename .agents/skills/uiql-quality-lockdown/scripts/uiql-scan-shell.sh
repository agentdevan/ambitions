#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

mkdir -p artifacts/ui-quality-lockdown/script-output
log="artifacts/ui-quality-lockdown/script-output/uiql-shell.log"
changed_log="artifacts/ui-quality-lockdown/script-output/uiql-shell-changed-files.log"

{
  echo "UIQL shell scan"
  echo "scope=${UIQL_SCAN_SCOPE:-changed}"
  echo "head=$(git rev-parse --short HEAD)"
  echo
  echo "Repo-wide shell reference findings, for classification only:"
  rg -n "AppTab|Capture|Motion|Pulse|Plan|Tab\\(" Native/Ambitions/App Native/AmbitionsTests/App 2>/dev/null || true
} > "$log"

python3 - <<'PY' >> "$log"
from pathlib import Path
import re
app_tab = Path("Native/Ambitions/App/AppTab.swift").read_text(encoding="utf-8")
root = Path("Native/Ambitions/App/AmbitionsRootView.swift").read_text(encoding="utf-8")
issues = []
all_cases = re.search(r"static var allCases:\s*\[AppTab\]\s*\{\s*\[(.*?)\]\s*\}", app_tab, re.S)
if not all_cases:
    issues.append("AppTab.allCases block not found")
else:
    cases = re.findall(r"\.([a-zA-Z]+)", all_cases.group(1))
    if cases != ["today", "goals", "time", "motion", "you"]:
        issues.append(f"AppTab.allCases is {cases}, expected ['today', 'goals', 'time', 'motion', 'you']")
tab_values = re.findall(r"value:\s*AppTab\.([a-zA-Z]+)\)", root)
if tab_values != ["today", "goals", "time", "motion", "you"]:
    issues.append(f"AmbitionsRootView Tab values are {tab_values}, expected ['today', 'goals', 'time', 'motion', 'you']")
root_tab_lines = [line.strip() for line in root.splitlines() if line.strip().startswith("Tab(")]
if any("capture" in line.lower() for line in root_tab_lines):
    issues.append("AmbitionsRootView root Tab lines reference Capture; Capture must remain global/supporting")
if issues:
    print("FAIL active shell source contract")
    for issue in issues:
        print(f"- {issue}")
    raise SystemExit(1)
print("PASS active shell source contract: Today / Goals / Time / Motion / You; Capture is not in root TabView values")
PY

files=()
while IFS= read -r file; do files+=("$file"); done < <(git diff --name-only HEAD -- Native/Ambitions/App Native/AmbitionsTests/App | rg '\.swift$' || true)
{
  echo "UIQL changed-shell findings"
  echo "files=${#files[@]}"
  if [ "${#files[@]}" -eq 0 ]; then
    echo "PASS no changed shell Swift files"
    exit 0
  fi
  rg -n "Pulse|Tab\\([^\\n]*AppTab\\.capture|Tab\\([^\\n]*Capture|case capture.*allCases|Plan tab|Profile tab" "${files[@]}" 2>/dev/null || true
} > "$changed_log"

if [ "${#files[@]}" -gt 0 ] && rg -n "Pulse|Tab\\([^\\n]*AppTab\\.capture|Tab\\([^\\n]*Capture|Plan tab|Profile tab" "${files[@]}" >/tmp/uiql-shell.$$ 2>/dev/null; then
  cat /tmp/uiql-shell.$$ >> "$changed_log"
  rm -f /tmp/uiql-shell.$$
  echo "FAIL changed shell source contains stale IA/top-level Capture risk. See $changed_log"
  exit 1
fi
rm -f /tmp/uiql-shell.$$
echo "PASS shell scan. Logs: $log $changed_log"
