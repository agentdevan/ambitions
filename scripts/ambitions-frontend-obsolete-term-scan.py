#!/usr/bin/env python3
from pathlib import Path
import sys
ROOT=Path(__file__).resolve().parents[1]
BASE=ROOT/'docs/canon/frontend'
msgs=[]
if not (BASE/'SURFACE_RECIPE_INVENTORY.yaml').exists(): msgs.append('missing SURFACE_RECIPE_INVENTORY.yaml')
scan_paths = list((BASE/'recipes').glob('**/*.md')) + [
    BASE/'AMBITIONS_FRONT_END_ARCHITECTURE_ATLAS_AND_VISUAL_ENCYCLOPEDIA.md',
    BASE/'SURFACE_RECIPE_INDEX.md',
    BASE/'SURFACE_RECIPE_INVENTORY.md',
    BASE/'SURFACE_RECIPE_INVENTORY.yaml',
    BASE/'FRONTEND_SURFACE_COVERAGE_MAP.md',
    BASE/'VISUAL_DIRECTION_CHANGE_PROTOCOL.md',
    BASE/'trace/PLANNED_TRAIN_FRONTEND_DIRECTION_INVENTORY.yaml',
]
for p in scan_paths:
    if not p.exists():
        continue
    t=p.read_text().lower()
    if 'plan tab' in t or 'plan as top-level' in t:
        msgs.append(f'{p} revives Plan as top-level')
    if 'object bible' in t or 'frontend object bible' in t or 'mri/hbi are objects' in t or 'shared object system' in t:
        msgs.append(f'{p} treats MRI/HBI as object framing')
    if p.name in {'commitment_staging_tray.md','reflow_preview_tray.md'}:
        for bad in ['odds','stake','bet slip','parlay','cash-out','cash out','wager','line movement','boost']:
            if bad in t: msgs.append(f'{p} contains wagering term {bad}')
if msgs:
    for m in msgs: print('FAIL:',m)
    sys.exit(1)
print('PASS')
