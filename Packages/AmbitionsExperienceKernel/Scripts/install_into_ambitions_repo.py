#!/usr/bin/env python3
from pathlib import Path
import argparse, shutil, json, datetime

parser = argparse.ArgumentParser()
parser.add_argument('repo', help='Path to agentdevan/ambitions')
parser.add_argument('--dry-run', action='store_true')
args = parser.parse_args()

source_root = Path(__file__).resolve().parents[1]
repo = Path(args.repo).resolve()
target = repo / 'Packages' / 'AmbitionsExperienceKernel'
report_path = repo / 'ambitions_experience_kernel_install_report.md'

if not repo.exists():
    raise SystemExit(f'Repo path does not exist: {repo}')

repo.mkdir(parents=True, exist_ok=True)
(repo / 'Packages').mkdir(exist_ok=True)

actions = []
if target.exists():
    actions.append(f'Replace existing {target}')
else:
    actions.append(f'Create {target}')

if not args.dry_run:
    if target.exists():
        shutil.rmtree(target)
    shutil.copytree(source_root, target, ignore=shutil.ignore_patterns('.build', '*.zip'))

project_files = list(repo.glob('*.xcodeproj')) + list(repo.glob('*.xcworkspace'))
root_package = repo / 'Package.swift'

report = f'''# AmbitionsExperienceKernel Install Report

Generated: {datetime.datetime.utcnow().isoformat()}Z

Target: `{target}`

Actions:
- {'; '.join(actions)}

Detected project files:
{chr(10).join(f'- `{p.name}`' for p in project_files) if project_files else '- none detected'}

Root package manifest: {'present' if root_package.exists() else 'not present'}

Next Codex steps:
1. Add local package dependency to the app target.
2. Import `AmbitionsExperienceKernel` in top-level surface modules.
3. Run `python Packages/AmbitionsExperienceKernel/Scripts/repo_truth_audit.py .`.
4. Run Xcode build and test commands from `Docs/ValidationCommands.md`.
5. Execute `Codex/Batches` sequentially.

Rollback:
Remove `Packages/AmbitionsExperienceKernel` and revert the commit that wires the app target dependency.
'''
if not args.dry_run:
    report_path.write_text(report, encoding='utf-8')
print(report)
