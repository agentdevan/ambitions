#!/usr/bin/env python3
from pathlib import Path
import json, sys
ROOT=Path(__file__).resolve().parents[1]
BASE=ROOT/'docs/canon/frontend'
required=['visual_id','name','canon_status','kind','hierarchy_level','destination','surface_owner','object_family','appears_on','intended_role','user_value','visual_description','hierarchy_behavior','state_model','allowed_states','visual_tokens','interaction_meaning','label_rules','accessibility_intent','dynamic_type_intent','voiceover_intent','reduce_motion_intent','adhd_usability_intent','source_truth','planned_batch_sources','precedence_notes','direction_change_triggers','forbidden_uses','open_direction_questions']
allowed={'intended_canon','planned_canon','directional_candidate','unresolved_direction','historical_reference','obsolete','excluded'}
msgs=[]
try: items=json.loads((BASE/'VISUAL_ITEM_REGISTRY.yaml').read_text())
except Exception as e:
    print('FAIL:',e); sys.exit(1)
if not isinstance(items,list) or not items: msgs.append('registry must be non-empty list')
if (BASE/'objects/MRI_FRONTEND_OBJECTS.md').exists() or (BASE/'objects/HBI_FRONTEND_OBJECTS.md').exists():
    msgs.append('MRI/HBI must not be present as active object files')
if len(items) < 170:
    msgs.append(f'registry unexpectedly small: {len(items)}')
for item in items:
    for f in required:
        if f not in item: msgs.append(f"{item.get('name','<unknown>')} missing {f}")
    if item.get('canon_status') not in allowed: msgs.append(f"{item.get('name')} invalid canon_status")
    if 'color' not in str(item.get('accessibility_intent','')).lower(): msgs.append(f"{item.get('name')} missing non-color accessibility intent")
    for field in ['visual_id','name','object_family','intended_role']:
        value=str(item.get(field,''))
        for banned in ['MRI', 'HBI', 'MRI/HBI', 'object bible', 'frontend object bible']:
            if banned in value:
                msgs.append(f"{item.get('name')} still treats source-family text as object framing in {field}")
inv=json.loads((BASE/'SURFACE_RECIPE_INVENTORY.yaml').read_text())
ids={i.get('visual_id') for i in items}
for s in inv:
    if s['surface_id'] not in ids: msgs.append(f"registry missing recipe surface {s['surface_id']}")
if msgs:
    for m in msgs: print('FAIL:',m)
    sys.exit(1)
print('PASS')
