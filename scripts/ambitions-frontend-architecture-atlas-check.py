#!/usr/bin/env python3
from pathlib import Path
import json
import sys

ROOT = Path(__file__).resolve().parents[1]
BASE = ROOT / 'docs/canon/frontend'

msgs = []
required = [
    'AMBITIONS_FRONT_END_ARCHITECTURE_ATLAS_AND_VISUAL_ENCYCLOPEDIA.md',
    'SURFACE_RECIPE_INDEX.md',
    'SURFACE_RECIPE_INVENTORY.yaml',
    'FRONTEND_SURFACE_COVERAGE_MAP.md',
    'trace/PLANNED_TRAIN_FRONTEND_DIRECTION_INVENTORY.md',
    'trace/PLANNED_TRAIN_FRONTEND_DIRECTION_INVENTORY.yaml',
    'trace/FRONTEND_SOURCE_PRECEDENCE_LEDGER.md',
    'trace/SURFACE_RECIPE_SPECIFICITY_REVIEW_LEDGER.md',
    'trace/TRAIN_FAMILY_TO_SURFACE_MATRIX.md',
    'trace/TRAIN_FAMILY_TO_OBJECT_MATRIX.md',
    'trace/TRAIN_FAMILY_TO_PRIMITIVE_MATRIX.md',
    'trace/UNMAPPED_INTENDED_SURFACE_GAPS.md',
    'MRI_HBI_FRONTEND_INTEGRATION_MAP.md',
]
for rel in required:
    if not (BASE / rel).exists():
        msgs.append(f'missing {rel}')

master = (BASE / 'AMBITIONS_FRONT_END_ARCHITECTURE_ATLAS_AND_VISUAL_ENCYCLOPEDIA.md').read_text()
required_phrases = [
    'the atlas now extracts all planned frontend-relevant train/source families, not just MRI/HBI',
    'mri and hbi remain entries in the broader planned train/source-family system',
    'recipes must be specific enough to tell a designer or reviewer exactly what visible ingredients belong on the surface',
    'the final specificity review ledger records the formerly medium recipes as high specificity and leaves only the five locked unresolved direction gaps visible',
    'active ia is `today / goals / capture / time / you`',
    'this document is not an implementation tracker',
    'this document is not screenshot proof',
    'this document is not a current-state audit',
]
for phrase in required_phrases:
    if phrase.lower() not in master.lower():
        msgs.append(f'master missing doctrine phrase: {phrase}')
for banned in ['object bible', 'frontend object bible', 'MRI Integration Map', 'HBI Integration Map']:
    if banned.lower() in master.lower():
        msgs.append(f'master still contains obsolete framing: {banned}')

try:
    inventory = json.loads((BASE / 'SURFACE_RECIPE_INVENTORY.yaml').read_text())
except Exception as exc:
    msgs.append(f'inventory parse failed: {exc}')
else:
    if not isinstance(inventory, list) or not inventory:
        msgs.append('inventory must be a non-empty list')
    if len(inventory) != 159:
        msgs.append(f'inventory count mismatch: {len(inventory)}')

try:
    train_inventory = json.loads((BASE / 'trace/PLANNED_TRAIN_FRONTEND_DIRECTION_INVENTORY.yaml').read_text())
except Exception as exc:
    msgs.append(f'train inventory parse failed: {exc}')
else:
    if not isinstance(train_inventory, list) or not train_inventory:
        msgs.append('train inventory must be a non-empty list')
    required_train_ids = {
        'pk', 'mri', 'hbi', 'lid', 'aos', 'rec', 'si', 'pd', 'moat_runtime',
        'runtime', 'visual_canon', 'planning', 'capture', 'time', 'today',
        'goals', 'you', 'accessibility', 'privacy', 'qa_validation',
        'onboarding_first_run', 'supporting_programs', 'historical_programs',
    }
    found_ids = {item.get('train_family_id') for item in train_inventory if isinstance(item, dict)}
    missing_ids = sorted(required_train_ids - found_ids)
    if missing_ids:
        msgs.append('train inventory missing ids: ' + ', '.join(missing_ids))

if msgs:
    for msg in msgs:
        print('FAIL:', msg)
    sys.exit(1)
print('PASS')
