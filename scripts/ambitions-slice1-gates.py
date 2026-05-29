#!/usr/bin/env python3
from __future__ import annotations

import json
from pathlib import Path

ROOT = Path('.')
CHECKS = [
    ('docs/codex/HARNESS_README.md', 'doc'),
    ('docs/codex/HARNESS_PLAN.md', 'doc'),
    ('docs/codex/HARNESS_ARTIFACT_SCHEMA.md', 'doc'),
    ('docs/codex/HARNESS_LINEAR.md', 'doc'),
    ('docs/codex/HARNESS_RUNS.md', 'doc'),
    ('scripts/harness/install-harness-slice1.py', 'script'),
    ('scripts/harness/check-slice1.py', 'script'),
    ('scripts/ambitions-slice1-status.py', 'script'),
    ('prompts/batches/HARNESS-T00-B01-baseline-audit.md', 'prompt'),
    ('prompts/batches/HARNESS-T01-B01-docs.md', 'prompt'),
]

missing = []
present = []
for path, kind in CHECKS:
    if (ROOT / path).exists():
        present.append({'path': path, 'kind': kind})
    else:
        missing.append({'path': path, 'kind': kind})

result = {
    'schema_version': '1.0',
    'status': 'Green' if not missing else 'Yellow',
    'present': present,
    'missing': missing,
    'boundaries': {
        'app_source_changed_by_this_script': False,
        'truth_files_changed_by_this_script': False,
    },
}

out_dir = ROOT / 'build' / 'reports' / 'harness'
out_dir.mkdir(parents=True, exist_ok=True)
(out_dir / 'slice1-gates.json').write_text(json.dumps(result, indent=2, sort_keys=True) + '\n', encoding='utf-8')
print(json.dumps(result, indent=2, sort_keys=True))
raise SystemExit(0 if not missing else 1)
