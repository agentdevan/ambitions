#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import re
from dataclasses import asdict, dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Iterable

ROOT = Path(__file__).resolve().parents[2]
TEXT_SUFFIXES = {'.md', '.txt', '.json', '.yml', '.yaml', '.py', '.sh'}
EXCLUDED = {'build', '.git', '.codex/runs', '.build', 'DerivedData'}

@dataclass
class Finding:
    path: str
    line: int
    pattern: str
    severity: str
    text: str

def utc_now() -> str:
    return datetime.now(timezone.utc).replace(microsecond=0).isoformat().replace('+00:00', 'Z')

def excluded(path: Path) -> bool:
    rel = str(path.relative_to(ROOT))
    return any(rel == x or rel.startswith(x + '/') for x in EXCLUDED)

def iter_files(paths: Iterable[str]):
    for raw in paths:
        path = ROOT / raw
        if not path.exists():
            continue
        if path.is_file():
            if path.suffix in TEXT_SUFFIXES and not excluded(path):
                yield path
        else:
            for item in path.rglob('*'):
                if item.is_file() and item.suffix in TEXT_SUFFIXES and not excluded(item):
                    yield item

def run_gate(name: str, patterns: dict[str, str]) -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument('--output-dir', default=f'build/reports/harness/static-gates/{name}')
    parser.add_argument('paths', nargs='*', default=['docs', 'prompts', 'AGENTS.md', 'README.md'])
    args = parser.parse_args()
    compiled = [(k, re.compile(v, re.I)) for k, v in patterns.items()]
    findings: list[Finding] = []
    for path in iter_files(args.paths):
        text = path.read_text(encoding='utf-8', errors='ignore')
        rel = str(path.relative_to(ROOT))
        for idx, line in enumerate(text.splitlines(), 1):
            for key, pat in compiled:
                if pat.search(line):
                    findings.append(Finding(rel, idx, key, 'Yellow', line.strip()[:300]))
    status = 'Green' if not findings else 'Yellow'
    out = ROOT / args.output_dir
    out.mkdir(parents=True, exist_ok=True)
    payload = {
        'schema_version': 'ambitions-static-gate.v1',
        'gate': name,
        'created_at_utc': utc_now(),
        'status': status,
        'finding_count': len(findings),
        'findings': [asdict(f) for f in findings],
        'claims_made': ['Static text scan completed for the named gate.'],
        'claims_not_made': ['No app behavior proof.', 'No build/test proof.', 'No release readiness proof.', 'No accessibility proof.', 'No privacy/legal approval.'],
    }
    (out / f'{name}.json').write_text(json.dumps(payload, indent=2, sort_keys=True) + '\n', encoding='utf-8')
    lines = [f'# {name}', '', f'Status: {status}', f'Findings: {len(findings)}', '', '## Findings']
    lines += [f'- `{f.path}:{f.line}` [{f.pattern}] {f.text}' for f in findings[:200]] or ['- none']
    lines += ['', '## Claims Not Made', '- No app behavior proof.', '- No build/test proof.', '- No release readiness proof.', '- No accessibility proof.', '- No privacy/legal approval.']
    (out / f'{name}.md').write_text('\n'.join(lines) + '\n', encoding='utf-8')
    print(f'{name}: {status} ({len(findings)} findings)')
    return 0
