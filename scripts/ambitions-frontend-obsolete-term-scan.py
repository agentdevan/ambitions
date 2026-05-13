#!/usr/bin/env python3
from pathlib import Path
import sys
ROOT=Path(__file__).resolve().parents[1]
BASE=ROOT/'docs/canon/frontend'
msgs=[]
if not (BASE/'SURFACE_RECIPE_INVENTORY.yaml').exists(): msgs.append('missing SURFACE_RECIPE_INVENTORY.yaml')
scan_paths = list((BASE/'recipes').glob('**/*.md')) + [
    BASE/'objects/MRI_FRONTEND_OBJECTS.md',
    BASE/'objects/HBI_FRONTEND_OBJECTS.md',
    BASE/'source-families/MRI_FRONTEND_SOURCE_FAMILY.md',
    BASE/'source-families/HBI_FRONTEND_SOURCE_FAMILY.md',
    BASE/'MRI_HBI_FRONTEND_INTEGRATION_MAP.md',
    BASE/'trace/MRI_HBI_TO_FRONTEND_SURFACE_MATRIX.md',
]
for p in [BASE/'objects/MRI_FRONTEND_OBJECTS.md', BASE/'objects/HBI_FRONTEND_OBJECTS.md']:
    if p.exists():
        msgs.append(f'{p} must not remain in active objects/')
for p in scan_paths:
    if not p.exists():
        continue
    t=p.read_text().lower()
    if p.name in {'MRI_FRONTEND_OBJECTS.md','HBI_FRONTEND_OBJECTS.md','MRI_FRONTEND_SOURCE_FAMILY.md','HBI_FRONTEND_SOURCE_FAMILY.md','MRI_HBI_FRONTEND_INTEGRATION_MAP.md','MRI_HBI_TO_FRONTEND_SURFACE_MATRIX.md'}:
        positive_object_framing = [
            'active frontend object bible',
            'is a frontend object',
            'are frontend objects',
            'is an object bible',
            'are object bibles',
            'frontend object family',
            'supports frontend objects',
        ]
        if any(phrase in t for phrase in positive_object_framing):
            msgs.append(f'{p} still frames MRI/HBI as objects')
    if 'plan tab' in t or 'plan as top-level' in t:
        msgs.append(f'{p} revives Plan as top-level')
    if p.name in {'commitment_staging_tray.md','reflow_preview_tray.md'}:
        for bad in ['odds','stake','bet slip','parlay','cash-out','cash out','wager','line movement','boost']:
            if bad in t: msgs.append(f'{p} contains wagering term {bad}')
if msgs:
    for m in msgs: print('FAIL:',m)
    sys.exit(1)
print('PASS')
