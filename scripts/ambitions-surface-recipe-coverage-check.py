#!/usr/bin/env python3
from pathlib import Path
import json
import sys

ROOT = Path(__file__).resolve().parents[1]
BASE = ROOT / 'docs/canon/frontend'
INV = BASE / 'SURFACE_RECIPE_INVENTORY.yaml'

REQUIRED_HEADINGS = [
    'Canon Status', 'Surface ID', 'Destination', 'Surface Type', 'Hierarchy Level',
    'Parent Surface', 'Child Surfaces', 'Final Intended Role', 'User Perception',
    'Why This Surface Exists', 'Primary Object', 'Supporting Objects',
    'Visible Regions', 'Region-by-Region Recipe', 'Primitive Inventory',
    'Object Inventory', 'Typography Recipe', 'Spacing Recipe', 'Material Recipe',
    'Color and State Recipe', 'Icon, Chevron, and Disclosure Recipe', 'CTA Recipe',
    'Label and Microcopy Recipe', 'Receipt / Proof / Source Recipe', 'State Model',
    'Allowed States', 'Forbidden States', 'Motion and Haptic Intent',
    'Accessibility Intent', 'Dynamic Type Intent', 'VoiceOver Intent',
    'Reduce Motion Intent', 'ADHD Usability Intent',
    'Relationship to Planned Train / Source Families', 'Source Truth',
    'Planned Batch Sources', 'Precedence / Conflict Notes', 'Forbidden Generic Drift',
    'Open Direction Gaps',
]
SCALABLE_PATTERNS = [
    'screenshot proof required', 'swiftui preview required',
    'implementation mapping required', 'release-ready', 'testflight-ready',
    'app store-ready',
]

def fail(msgs):
    if msgs:
        for msg in msgs:
            print('FAIL:', msg)
        sys.exit(1)
    print('PASS')

msgs = []
for rel in [
    'SURFACE_RECIPE_INDEX.md', 'SURFACE_RECIPE_INVENTORY.yaml',
    'SURFACE_RECIPE_INVENTORY.md', 'FRONTEND_SURFACE_COVERAGE_MAP.md',
    'trace/PLANNED_TRAIN_FRONTEND_DIRECTION_INVENTORY.md',
    'trace/PLANNED_TRAIN_FRONTEND_DIRECTION_INVENTORY.yaml',
    'trace/FRONTEND_SOURCE_PRECEDENCE_LEDGER.md',
]:
    if not (BASE / rel).exists():
        msgs.append(f'missing {rel}')

try:
    items = json.loads(INV.read_text())
except Exception as exc:
    fail([f'inventory parse failed: {exc}'])

for item in items:
    recipe = ROOT / item.get('recipe_file', '')
    if not recipe.exists():
        msgs.append(f"missing recipe file {recipe}")
        continue
    text = recipe.read_text()
    lowered = text.lower()
    if '## Relationship to Planned Train / Source Families' not in text:
        msgs.append(f"{item.get('name')} missing planned-train relationship section")
    if '## Relationship to MRI' in text or '## Relationship to HBI' in text:
        msgs.append(f"{item.get('name')} retains MRI/HBI-only relationship headings")
    for heading in REQUIRED_HEADINGS:
        if f'## {heading}' not in text:
            msgs.append(f"{item.get('name')} missing heading {heading}")
    for phrase in SCALABLE_PATTERNS:
        if phrase in lowered:
            msgs.append(f"{item.get('name')} contains forbidden proof/release phrase: {phrase}")
    if 'plan as top-level' in lowered or 'plan tab' in lowered:
        msgs.append(f"{item.get('name')} revives Plan as top-level")

fail(msgs)
