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
PRIORITY_RECIPE_NAMES = {
    'today_root_reality_meridian.md',
    'today_start_here_region.md',
    'today_reality_meridian_rail.md',
    'goals_root_constellation_atlas.md',
    'goals_proof_trail.md',
    'capture_root_atmosphere_composer.md',
    'time_root_lifeshape_field.md',
    'you_root_user_system_profile.md',
    'commitment_staging_tray.md',
    'reflow_preview_tray.md',
    'recommendation_source_system.md',
    'receipt_system.md',
    'proof_trail_system.md',
}

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
    'trace/SURFACE_RECIPE_SPECIFICITY_REVIEW_LEDGER.md',
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

counts = {'high_specificity': 0, 'medium_specificity': 0, 'low_specificity': 0, 'unresolved_direction': 0}
by_destination = {}
for item in items:
    status = item.get('specificity_status')
    counts[status] = counts.get(status, 0) + 1
    dest = item.get('destination')
    by_destination.setdefault(dest, {'total': 0, 'high_specificity': 0, 'medium_specificity': 0, 'low_specificity': 0, 'unresolved_direction': 0})
    by_destination[dest]['total'] += 1
    by_destination[dest][status] += 1

if counts['medium_specificity']:
    msgs.append(f'coverage inventory still has medium specificity recipes: {counts["medium_specificity"]}')
if counts['low_specificity']:
    msgs.append(f'coverage inventory still has low specificity recipes: {counts["low_specificity"]}')
if counts['unresolved_direction'] != 0:
    msgs.append(f'coverage inventory unresolved count mismatch: {counts["unresolved_direction"]}')

coverage_lines = (BASE / 'FRONTEND_SURFACE_COVERAGE_MAP.md').read_text().splitlines() if (BASE / 'FRONTEND_SURFACE_COVERAGE_MAP.md').exists() else []
for dest, expected in by_destination.items():
    row = next((line for line in coverage_lines if line.startswith(f'| {dest} |')), None)
    if row is None:
        msgs.append(f'coverage map missing destination row: {dest}')
        continue
    pieces = [piece.strip() for piece in row.strip('|').split('|')]
    if len(pieces) < 7:
        msgs.append(f'coverage map row malformed for {dest}')
        continue
    actual = {
        'total': int(pieces[1]),
        'high_specificity': int(pieces[2]),
        'medium_specificity': int(pieces[3]),
        'low_specificity': int(pieces[4]),
        'unresolved_direction': int(pieces[5]),
    }
    if actual != expected:
        msgs.append(f'coverage map mismatch for {dest}: {actual} != {expected}')

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
    if recipe.name in PRIORITY_RECIPE_NAMES:
        for phrase in [
            'this recipe defines the intended final-state visual contract',
            'it remains design canon only; it is not swiftui instruction, screenshot proof, implementation status, or release evidence',
            'visual canon: quiet-luxury hierarchy, native primitives, and no generic dashboard drift',
        ]:
            if phrase in lowered:
                msgs.append(f"{item.get('name')} still contains scaffold phrase: {phrase}")
    if 'plan as top-level' in lowered or 'plan tab' in lowered:
        msgs.append(f"{item.get('name')} revives Plan as top-level")

fail(msgs)
