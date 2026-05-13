#!/usr/bin/env python3
from pathlib import Path
import json, sys
ROOT = Path(__file__).resolve().parents[1]
BASE = ROOT / 'docs/canon/frontend'
msgs=[]
required=['AMBITIONS_FRONT_END_ARCHITECTURE_ATLAS_AND_VISUAL_ENCYCLOPEDIA.md','SURFACE_RECIPE_INDEX.md','SURFACE_RECIPE_INVENTORY.yaml','FRONTEND_SURFACE_COVERAGE_MAP.md','trace/PLANNED_BATCH_FRONTEND_DIRECTION_INVENTORY.md','trace/FRONTEND_SOURCE_PRECEDENCE_LEDGER.md','trace/INTENDED_STATE_COVERAGE_MATRIX.md','trace/UNMAPPED_INTENDED_SURFACE_GAPS.md','MRI_HBI_FRONTEND_INTEGRATION_MAP.md']
for r in required:
    if not (BASE/r).exists(): msgs.append(f'missing {r}')
master=(BASE/'AMBITIONS_FRONT_END_ARCHITECTURE_ATLAS_AND_VISUAL_ENCYCLOPEDIA.md').read_text()
for phrase in ['The intended final-state visual recipe encyclopedia','not an implementation tracker','not screenshot proof','not a current-state audit','Today / Goals / Capture / Time / You','If a visible surface, object, primitive, state, label, CTA, chevron, material, wrapper, receipt, source affordance, or visible behavior is absent from this atlas','MRI and HBI Source Families','Source Family Extraction Ledger']:
    if phrase not in master: msgs.append(f'master missing doctrine phrase: {phrase}')
for banned in ['MRI Integration Map','HBI Integration Map','object bible','frontend object bible']:
    if banned in master: msgs.append(f'master still contains obsolete framing: {banned}')
try: json.loads((BASE/'SURFACE_RECIPE_INVENTORY.yaml').read_text())
except Exception as e: msgs.append(f'inventory parse failed: {e}')
if msgs:
    for m in msgs: print('FAIL:',m)
    sys.exit(1)
print('PASS')
