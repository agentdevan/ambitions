#!/usr/bin/env python3
from pathlib import Path
import re, sys, json

repo = Path(sys.argv[1]).resolve() if len(sys.argv) > 1 else Path.cwd()
blocked_terms = [''.join(['p','a','n','e','l']), ''.join(['c','a','r','d']), ''.join(['d','a','s','h','b','o','a','r','d']), ''.join(['c','h','a','t','b','o','t'])]
blocked_api = ['.buttonStyle(' + '.bordered', '.navigationBarTitleDisplayMode(.large)', 'Color(#']
source_suffixes = {'.swift'}
findings = []

for path in repo.rglob('*'):
    if '.build' in path.parts or '.git' in path.parts:
        continue
    if path.is_file() and path.suffix in source_suffixes:
        text = path.read_text(errors='ignore')
        lower = text.lower()
        for term in blocked_terms:
            if term in lower:
                findings.append({'severity': 'red', 'file': str(path.relative_to(repo)), 'issue': f'legacy UI language: {term}'})
        for api in blocked_api:
            if api in text:
                findings.append({'severity': 'yellow', 'file': str(path.relative_to(repo)), 'issue': f'API drift: {api}'})
        if re.search(r'#[0-9a-fA-F]{6}', text):
            findings.append({'severity': 'yellow', 'file': str(path.relative_to(repo)), 'issue': 'raw hex literal'})

status = 'green'
if any(f['severity'] == 'red' for f in findings):
    status = 'red'
elif findings:
    status = 'yellow'

report = {'status': status, 'findings': findings[:200], 'findingCount': len(findings)}
out = repo / 'ambitions_experience_kernel_repo_truth_report.json'
out.write_text(json.dumps(report, indent=2), encoding='utf-8')
print(status.upper() + f': repo truth audit complete. findings={len(findings)} report={out}')
sys.exit(0 if status != 'red' else 1)
