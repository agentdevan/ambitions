#!/usr/bin/env bash
set -euo pipefail
echo 'Running Ambitions Flagship Remediation validation...'
FAIL=0
require_file() { if [ ! -f "$1" ]; then echo "MISSING: $1"; FAIL=1; else echo "OK: $1"; fi; }
require_dir() { if [ ! -d "$1" ]; then echo "MISSING: $1"; FAIL=1; else echo "OK: $1"; fi; }
require_file AGENTS.md
require_file project.yml
require_file Package.swift
require_dir Native/Ambitions
require_dir Native/AmbitionsTests
require_dir Native/AmbitionsUITests
require_file .linear/projects/AMB-FLAGSHIP-REMEDIATION/project.md
require_file .linear/projects/AMB-FLAGSHIP-REMEDIATION/linear_issues.csv
require_file .linear/projects/AMB-FLAGSHIP-REMEDIATION/linear_issues.json
require_file .codex/manifests/ambitions-flagship-remediation.json
require_file prompts/projects/AMB-FLAGSHIP-REMEDIATION.md
python3 - <<'CHECKPY'
import json
from pathlib import Path
data = json.loads(Path('.linear/projects/AMB-FLAGSHIP-REMEDIATION/linear_issues.json').read_text())
issues = data['issues']
ids = [i['id'] for i in issues]
assert len(ids) == 24, f'Expected 24 issues, found {len(ids)}'
assert len(set(ids)) == len(ids), 'Duplicate issue IDs'
required = {'id','title','priority','severity','train','milestone','labels','dependencies','affected_files','problem','implementation','acceptance','validation','rollback'}
for issue in issues:
    missing = required - set(issue)
    assert not missing, f"{issue.get('id')} missing {missing}"
print('OK: issue manifest contains 24 complete issues')
CHECKPY
git diff --check || FAIL=1
if command -v xcodegen >/dev/null 2>&1; then xcodegen generate || FAIL=1; else echo 'xcodegen not found. Skipping project generation.'; fi
if command -v xcodebuild >/dev/null 2>&1 && [ -d Ambitions.xcodeproj ]; then xcodebuild -list -project Ambitions.xcodeproj || FAIL=1; else echo 'Skipping xcodebuild scheme listing.'; fi
if [ "$FAIL" -ne 0 ]; then echo 'Ambitions Flagship Remediation validation: RED'; exit 1; fi
echo 'Ambitions Flagship Remediation validation: GREEN'
