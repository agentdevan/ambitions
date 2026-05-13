#!/usr/bin/env python3
from pathlib import Path
import json
import sys

ROOT = Path(__file__).resolve().parents[1]
BASE = ROOT / 'docs/canon/frontend'

msgs = []
md = BASE / 'trace/PLANNED_TRAIN_FRONTEND_DIRECTION_INVENTORY.md'
yaml = BASE / 'trace/PLANNED_TRAIN_FRONTEND_DIRECTION_INVENTORY.yaml'
if not md.exists():
    msgs.append('missing planned-train inventory markdown')
if not yaml.exists():
    msgs.append('missing planned-train inventory yaml')

try:
    items = json.loads(yaml.read_text())
except Exception as exc:
    items = []
    msgs.append(f'planned-train inventory parse failed: {exc}')

if not isinstance(items, list) or not items:
    msgs.append('planned-train inventory must be a non-empty list')
if len(items) != 23:
    msgs.append(f'planned-train inventory count mismatch: {len(items)}')

required_ids = {
    'pk', 'mri', 'hbi', 'lid', 'aos', 'rec', 'si', 'pd', 'moat_runtime', 'runtime',
    'visual_canon', 'planning', 'capture', 'time', 'today', 'goals', 'you',
    'accessibility', 'privacy', 'qa_validation', 'onboarding_first_run',
    'supporting_programs', 'historical_programs',
}
found_ids = set()
for item in items:
    if not isinstance(item, dict):
        msgs.append('planned-train inventory contains a non-object entry')
        continue
    for field in [
        'train_family_id', 'display_name', 'aliases', 'source_paths', 'batch_ids',
        'status', 'frontend_relevance', 'affected_destinations', 'affected_surfaces',
        'affected_objects', 'affected_primitives', 'affected_states',
        'direction_decisions', 'conflicts', 'precedence_rank', 'recency_evidence',
        'recency_confidence', 'canon_impact', 'open_questions',
    ]:
        if field not in item:
            msgs.append(f"{item.get('display_name', '<unknown>')} missing {field}")
    if not isinstance(item.get('source_paths'), list) or not item.get('source_paths'):
        msgs.append(f"{item.get('display_name', '<unknown>')} missing source_paths")
    if not isinstance(item.get('batch_ids'), list) or not item.get('batch_ids'):
        msgs.append(f"{item.get('display_name', '<unknown>')} missing batch_ids")
    if not isinstance(item.get('aliases'), list) or not item.get('aliases'):
        msgs.append(f"{item.get('display_name', '<unknown>')} missing aliases")
    if not isinstance(item.get('precedence_rank'), int):
        msgs.append(f"{item.get('display_name', '<unknown>')} missing numeric precedence_rank")
    found_ids.add(item.get('train_family_id'))

missing = sorted(required_ids - found_ids)
if missing:
    msgs.append('inventory missing required families: ' + ', '.join(missing))

md_text = md.read_text().lower()
for phrase in [
    'active all-train source-family inventory for intended frontend direction',
    'extracts planned frontend-relevant train/source families',
    'mri and hbi remain entries inside the broader system rather than the only source-family overlays',
]:
    if phrase not in md_text:
        msgs.append(f'md missing phrase: {phrase}')

if 'mri' not in found_ids or 'hbi' not in found_ids or 'pk' not in found_ids or 'lid' not in found_ids or 'aos' not in found_ids:
    msgs.append('required core families not present in inventory')

if msgs:
    for msg in msgs:
        print('FAIL:', msg)
    sys.exit(1)
print('PASS')
