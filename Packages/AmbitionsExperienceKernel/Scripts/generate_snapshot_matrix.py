#!/usr/bin/env python3
from pathlib import Path
import json
ROOT = Path(__file__).resolve().parents[1]
manifest = ROOT / 'Sources' / 'AmbitionsExperienceKernel' / 'Resources' / 'Manifests' / 'preview_matrix.json'
fixtures = json.loads(manifest.read_text())['fixtures']
out = ROOT / 'snapshot_matrix_checklist.md'
lines = ['# Ambitions Snapshot Matrix', '']
for item in fixtures:
    lines.append(f"- [ ] {item['surface']} / {item['state']} — screenshot, VoiceOver, Reduce Motion, contrast")
out.write_text('\n'.join(lines) + '\n', encoding='utf-8')
print(f'GREEN: snapshot matrix checklist generated: {out}')
