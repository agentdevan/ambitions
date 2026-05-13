#!/usr/bin/env python3
from pathlib import Path
import json
import sys

ROOT = Path(__file__).resolve().parents[1]
BASE = ROOT / 'docs/canon/frontend'

required = [
    'visual_id', 'name', 'canon_status', 'kind', 'hierarchy_level', 'destination',
    'surface_owner', 'object_family', 'appears_on', 'intended_role', 'user_value',
    'visual_description', 'hierarchy_behavior', 'state_model', 'allowed_states',
    'visual_tokens', 'interaction_meaning', 'label_rules', 'accessibility_intent',
    'dynamic_type_intent', 'voiceover_intent', 'reduce_motion_intent',
    'adhd_usability_intent', 'source_truth', 'planned_batch_sources',
    'precedence_notes', 'direction_change_triggers', 'forbidden_uses',
    'open_direction_questions', 'train_family_sources', 'train_family_influence',
    'specificity_status',
]
allowed = {
    'intended_canon', 'planned_canon', 'directional_candidate',
    'unresolved_direction', 'historical_reference', 'obsolete', 'excluded',
}
allowed_specificity = {'high_specificity', 'medium_specificity', 'low_specificity', 'unresolved_direction'}

msgs = []
try:
    items = json.loads((BASE / 'VISUAL_ITEM_REGISTRY.yaml').read_text())
except Exception as exc:
    print('FAIL:', exc)
    sys.exit(1)

if not isinstance(items, list) or not items:
    msgs.append('registry must be non-empty list')
if len(items) != 174:
    msgs.append(f'registry count mismatch: {len(items)}')
if (BASE / 'objects/MRI_FRONTEND_OBJECTS.md').exists() or (BASE / 'objects/HBI_FRONTEND_OBJECTS.md').exists():
    msgs.append('MRI/HBI must not be present as active object files')

for item in items:
    for field in required:
        if field not in item:
            msgs.append(f"{item.get('name', '<unknown>')} missing {field}")
    if item.get('canon_status') not in allowed:
        msgs.append(f"{item.get('name')} invalid canon_status")
    if item.get('specificity_status') not in allowed_specificity:
        msgs.append(f"{item.get('name')} invalid specificity_status")
    if not isinstance(item.get('train_family_sources'), list) or not item.get('train_family_sources'):
        msgs.append(f"{item.get('name')} missing train_family_sources")
    if not isinstance(item.get('train_family_influence'), list) or not item.get('train_family_influence'):
        msgs.append(f"{item.get('name')} missing train_family_influence")
    if 'color' not in str(item.get('accessibility_intent', '')).lower():
        msgs.append(f"{item.get('name')} missing non-color accessibility intent")
    for field in ['visual_id', 'name', 'object_family', 'intended_role']:
        value = str(item.get(field, ''))
        if ('MRI' in value or 'HBI' in value) and not any(fam in [s.lower() for s in item.get('train_family_sources', [])] for fam in ['mri', 'hbi']):
            msgs.append(f"{item.get('name')} still treats source-family text as object framing in {field}")

ids = {i.get('visual_id') for i in items}
for s in json.loads((BASE / 'SURFACE_RECIPE_INVENTORY.yaml').read_text()):
    if s['surface_id'] not in ids:
        msgs.append(f"registry missing recipe surface {s['surface_id']}")

if msgs:
    for msg in msgs:
        print('FAIL:', msg)
    sys.exit(1)
print('PASS')
