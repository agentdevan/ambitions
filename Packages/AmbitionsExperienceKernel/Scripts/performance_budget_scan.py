#!/usr/bin/env python3
from pathlib import Path
import json, sys

repo = Path(sys.argv[1]).resolve() if len(sys.argv) > 1 else Path.cwd()
findings = []
for path in repo.rglob('*.swift'):
    if '.build' in path.parts or '.git' in path.parts:
        continue
    text = path.read_text(errors='ignore')
    blur_count = text.count('.blur(')
    animation_count = text.count('.animation(') + text.count('withAnimation')
    material_count = text.count('Material') + text.count('material')
    if blur_count > 2:
        findings.append({'file': str(path.relative_to(repo)), 'severity': 'yellow', 'issue': f'blur use {blur_count}'})
    if animation_count > 6:
        findings.append({'file': str(path.relative_to(repo)), 'severity': 'yellow', 'issue': f'animation use {animation_count}'})
    if material_count > 5:
        findings.append({'file': str(path.relative_to(repo)), 'severity': 'yellow', 'issue': f'material use {material_count}'})
status = 'green' if not findings else 'yellow'
out = repo / 'ambitions_experience_kernel_performance_report.json'
out.write_text(json.dumps({'status': status, 'findings': findings, 'findingCount': len(findings)}, indent=2), encoding='utf-8')
print(status.upper() + f': performance scan complete. findings={len(findings)} report={out}')
