#!/usr/bin/env python3
from pathlib import Path
import sys
ROOT=Path(__file__).resolve().parents[1]
BASE=ROOT/'docs/canon/frontend'
msgs=[]
if not (BASE/'VISUAL_DIRECTION_CHANGE_PROTOCOL.md').exists(): msgs.append('missing VISUAL_DIRECTION_CHANGE_PROTOCOL.md')
if not (BASE/'trace/FRONTEND_SOURCE_PRECEDENCE_LEDGER.md').exists(): msgs.append('missing trace/FRONTEND_SOURCE_PRECEDENCE_LEDGER.md')
if not (BASE/'trace/VISUAL_DIRECTION_SOURCE_FAMILY_EXTRACTION_LEDGER.md').exists(): msgs.append('missing trace/VISUAL_DIRECTION_SOURCE_FAMILY_EXTRACTION_LEDGER.md')
for p in (BASE/'recipes').glob('**/*.md'):
    t=p.read_text().lower()
    if 'plan tab' in t or 'plan as top-level' in t:
        msgs.append(f'{p} revives Plan as top-level')
    if p.name in {'commitment_staging_tray.md','reflow_preview_tray.md'}:
        for bad in ['odds','stake','bet slip','parlay','cash-out','cash out','wager','line movement','boost']:
            if bad in t: msgs.append(f'{p} contains wagering term {bad}')
if msgs:
    for m in msgs: print('FAIL:',m)
    sys.exit(1)
print('PASS')
