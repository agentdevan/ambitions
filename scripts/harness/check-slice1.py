#!/usr/bin/env python3
from pathlib import Path

REQUIRED = [
    'docs/codex/HARNESS_README.md',
    'docs/codex/HARNESS_PLAN.md',
    'docs/codex/HARNESS_ARTIFACT_SCHEMA.md',
    'docs/codex/HARNESS_LINEAR.md',
    'docs/codex/HARNESS_RUNS.md',
    'scripts/harness/install-harness-slice1.py',
    'prompts/batches/HARNESS-T00-B01-baseline-audit.md',
]

missing = [p for p in REQUIRED if not Path(p).exists()]
print('Slice 1 verifier')
print(f'present={len(REQUIRED) - len(missing)}')
print(f'missing={len(missing)}')
for item in missing:
    print(f'MISSING {item}')
raise SystemExit(1 if missing else 0)
