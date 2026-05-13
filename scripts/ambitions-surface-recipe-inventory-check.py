#!/usr/bin/env python3
from pathlib import Path
import json
import sys

ROOT = Path(__file__).resolve().parents[1]
BASE = ROOT / 'docs/canon/frontend'
INV = BASE / 'SURFACE_RECIPE_INVENTORY.yaml'

REQUIRED_FIELDS = [
    'surface_id', 'name', 'canon_status', 'destination', 'surface_type',
    'hierarchy_level', 'parent_surface', 'child_surfaces', 'primary_object',
    'supporting_objects', 'visible_regions', 'recipe_file', 'source_truth',
    'planned_batch_sources', 'precedence_notes', 'direction_conflicts',
    'open_direction_questions', 'forbidden_patterns', 'train_family_sources',
    'train_family_influence', 'specificity_status',
]
ALLOWED_STATUSES = {
    'intended_canon', 'planned_canon', 'directional_candidate',
    'unresolved_direction', 'historical_reference', 'obsolete', 'excluded',
}
ALLOWED_TYPES = {
    'app_shell', 'top_level_surface', 'drill_down', 'sheet', 'drawer', 'tray',
    'modal', 'overlay', 'row', 'state_surface', 'empty_state', 'error_state',
    'onboarding', 'settings_detail', 'receipt_detail', 'proof_detail',
    'source_detail', 'composer_state', 'navigation_chrome',
}
ALLOWED_LEVELS = {
    'global', 'destination_root', 'primary_surface', 'secondary_surface',
    'tertiary_surface', 'transient_surface', 'component_surface', 'state_variant',
}
ALLOWED_SPECIFICITY = {'high_specificity', 'unresolved_direction'}
MINIMUM_SURFACES = {
    'Global App Shell', 'Destination Dock', 'Destination Tab Item',
    'Compact Surface Header', 'Context Crown', 'Back Navigation',
    'Sheet Chrome', 'Tray Chrome', 'Receipt Toast / Inline Confirmation',
    'Global Empty State Shell', 'Global Error / Fallback Shell',
    'Today Root / Reality Meridian', 'Today Current Context Header',
    'Today Start Here Region', 'Today Reality Meridian Rail',
    'Today Recommended Step Object', 'Today Now / Next / Later Sequence',
    'Today Upcoming Commitments Region', 'Today Closure Prompt Region',
    'Today Receipt Shelf', 'Today Source Freshness Indicator', 'Step Detail',
    'Step Session', 'Recommendation Source Sheet', 'Closure Sheet',
    'Receipt Detail', 'Proof Attachment Detail', 'Adjust Plan / Reflow Preview Entry',
    'Blocked Detail', 'Waiting Detail', 'Goal Thread Context from Today',
    'Local Runtime Source Detail from Today', 'Today Empty State',
    'Today No Schedule Data State', 'Today Overloaded State', 'Today Recovery State',
    'Today Vacation / Away State', 'Today Protected Time State',
    'Today Stale Recommendation State', 'Goals Root / Constellation Atlas',
    'Goals Life Area Map', 'Selected Life Area Surface', 'Ambition Graph',
    'Goal Thread Detail', 'Goal Detail', 'Commitment Detail', 'Proof Trail',
    'Proof Detail', 'Proof Gap State', 'Blocker Detail', 'Alternate Path Detail',
    'Milestone Detail', 'Recommended Step Context from Goals',
    'Reflection / Recovery Detail', 'Goals Empty State', 'Goals Review State',
    'Goals Blocked State', 'Goals Archive / Historical Goal State',
    'Capture Root / Atmosphere Composer', 'Capture Idle Composer',
    'Capture Active Text Entry', 'Capture Dictation State',
    'Capture Attachment / Proof Picker', 'Capture Post-Input Route Reveal',
    'Capture Save as Proof Route', 'Capture Make Commitment Route',
    'Capture Grow into Goal Route', 'Capture Mark Constraint Route',
    'Capture Reflect Route', 'Capture Hold / Needs a Place Route',
    'Capture Receipt', 'Capture Parse Uncertain State',
    'Capture Offline Local-Only State', 'Capture Error / Failed Attachment State',
    'Capture Empty First-Use State', 'Time Root / LifeShape Field',
    'Time Scope Control', 'Day LifeShape Surface', 'Week LifeShape Surface',
    'Month LifeShape Surface', 'Open Time Region', 'Protected Time Region',
    'Pressure Region', 'Best Fit Region', 'Recovery / Flex Region',
    'Review Pressure Surface', 'Best Fit Explanation Sheet',
    'Protected Time Detail', 'Day Detail', 'Week Detail', 'Month Detail',
    'Reflow Preview Tray', 'Shape Day Flow', 'Reflow Week Flow', 'Shape Month Flow',
    'Time Receipt Detail', 'Schedule & Availability Entry',
    'Planning Defaults Entry', 'Vacation / Away Time Entry',
    'Time No Calendar Data State', 'Time Overloaded State',
    'Time Protected Block State', 'Time Vacation / Away State',
    'Time Stale Source State', 'You Root / User System Profile',
    'User Profile Header', 'Local Runtime Trust Panel', 'Planning Setup Section',
    'Schedule & Availability', 'Planning Defaults', 'Vacation / Away Time',
    'Automation & Trust', 'Notifications', 'Capture Preferences',
    'Focus / Session Defaults', 'Privacy', 'Personal Runtime',
    'Local Data / Reset / Forget', 'Help', 'About Ambitions',
    'You Empty / First-Run State', 'You Trust Warning State',
    'You Offline Local-Only State', 'Commitment Staging Tray',
    'Receipt System', 'Closure System', 'Proof Trail System',
    'Recommendation Source System', 'Why This Sheet', 'Source Freshness Badge',
    'Still Counts State', 'Moved State', 'Skipped / Not Needed State',
    'Blocked State', 'Waiting State', 'Needs Recovery State', 'Needs Review State',
    'Protected Marker', 'Pressure Marker', 'Best Fit Marker', 'Open Marker',
    'Primary CTA', 'Secondary CTA', 'Destructive CTA', 'Disabled CTA',
    'Chevron / Disclosure Row', 'QuietGlass Wrapper', 'GraphiteRecess Base',
    'LuminousTrace State Line', 'CelestialField Semantic Layer',
    'First Run Root', 'Schedule Setup Prompt', 'Planning Defaults Prompt',
    'Privacy / Local Runtime Explanation', 'Capture First-Use Prompt',
    'Goals First-Use Prompt', 'Time First-Use Prompt', 'Today First-Use State',
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
for rel in ['objects/MRI_FRONTEND_OBJECTS.md', 'objects/HBI_FRONTEND_OBJECTS.md']:
    if (BASE / rel).exists():
        msgs.append(f'{rel} must not exist as an active object file')
for rel in ['source-families/MRI_FRONTEND_SOURCE_FAMILY.md', 'source-families/HBI_FRONTEND_SOURCE_FAMILY.md']:
    if not (BASE / rel).exists():
        msgs.append(f'missing source-family map {rel}')

try:
    items = json.loads(INV.read_text())
except Exception as exc:
    fail([f'inventory parse failed: {exc}'])

if not isinstance(items, list) or not items:
    msgs.append('inventory must be a non-empty list')
if len(items) != 159:
    msgs.append(f'inventory count mismatch: {len(items)}')

seen = {}
specificity_counts = {'high_specificity': 0, 'medium_specificity': 0, 'low_specificity': 0, 'unresolved_direction': 0}
for item in items:
    for field in REQUIRED_FIELDS:
        if field not in item:
            msgs.append(f"{item.get('name', '<unknown>')} missing {field}")
    if item.get('canon_status') not in ALLOWED_STATUSES:
        msgs.append(f"{item.get('name')} invalid canon_status")
    if item.get('surface_type') not in ALLOWED_TYPES:
        msgs.append(f"{item.get('name')} invalid surface_type")
    if item.get('hierarchy_level') not in ALLOWED_LEVELS:
        msgs.append(f"{item.get('name')} invalid hierarchy_level")
    if item.get('specificity_status') not in ALLOWED_SPECIFICITY:
        msgs.append(f"{item.get('name')} invalid specificity_status")
    if not isinstance(item.get('train_family_sources'), list) or not item.get('train_family_sources'):
        msgs.append(f"{item.get('name')} missing train_family_sources")
    if not isinstance(item.get('train_family_influence'), list) or not item.get('train_family_influence'):
        msgs.append(f"{item.get('name')} missing train_family_influence")
    specificity_counts[item.get('specificity_status')] = specificity_counts.get(item.get('specificity_status'), 0) + 1
    seen[item.get('name')] = item
    recipe = ROOT / item.get('recipe_file', '')
    if not recipe.exists():
        msgs.append(f"{item.get('name')} missing recipe file {recipe}")
    text = recipe.read_text() if recipe.exists() else ''
    if '## Relationship to Planned Train / Source Families' not in text:
        msgs.append(f"{item.get('name')} missing planned-train relationship section")
    if '## Relationship to MRI' in text or '## Relationship to HBI' in text:
        msgs.append(f"{item.get('name')} still uses MRI/HBI-only relationship headings")
    if 'shared object system' in text.lower():
        msgs.append(f"{item.get('name')} still uses shared object system filler")
    if 'plan as top-level' in text.lower() or 'plan tab' in text.lower():
        msgs.append(f"{item.get('name')} revives Plan as top-level")
    if item.get('specificity_status') == 'unresolved_direction':
        unresolved_name = item.get('name', '').lower()
        if unresolved_name not in (BASE / 'trace/UNMAPPED_INTENDED_SURFACE_GAPS.md').read_text().lower() and unresolved_name not in (BASE / 'trace/TRAIN_FAMILY_UNRESOLVED_DIRECTION_GAPS.md').read_text().lower():
            msgs.append(f"{item.get('name')} unresolved direction not listed in gap docs")

if specificity_counts['medium_specificity']:
    msgs.append(f"inventory still has medium specificity recipes: {specificity_counts['medium_specificity']}")
if specificity_counts['low_specificity']:
    msgs.append(f"inventory still has low specificity recipes: {specificity_counts['low_specificity']}")
ledger = (BASE / 'trace/SURFACE_RECIPE_SPECIFICITY_REVIEW_LEDGER.md').read_text().lower() if (BASE / 'trace/SURFACE_RECIPE_SPECIFICITY_REVIEW_LEDGER.md').exists() else ''
if 'remaining medium recipes: 0' not in ledger:
    msgs.append('specificity review ledger must record zero remaining medium recipes')
for unresolved_name in ['local runtime source detail from today', 'review pressure surface', 'month detail', 'shape month flow', 'time stale source state']:
    if unresolved_name not in ledger:
        msgs.append(f'specificity review ledger missing unresolved surface: {unresolved_name}')

for name in MINIMUM_SURFACES:
    if name not in seen:
        msgs.append(f'missing minimum surface {name}')
for root_name in ['Today Root / Reality Meridian', 'Goals Root / Constellation Atlas', 'Capture Root / Atmosphere Composer', 'Time Root / LifeShape Field', 'You Root / User System Profile']:
    if root_name not in seen:
        msgs.append(f'missing top-level root {root_name}')

ledger = (BASE / 'trace/FRONTEND_SOURCE_PRECEDENCE_LEDGER.md').read_text() if (BASE / 'trace/FRONTEND_SOURCE_PRECEDENCE_LEDGER.md').exists() else ''
if 'ranking uses explicit registry metadata' not in ledger.lower():
    msgs.append('source precedence ledger missing planned-batch recency doctrine')
if 'surface recipe specificity review ledger' not in (BASE / 'AMBITIONS_FRONT_END_ARCHITECTURE_ATLAS_AND_VISUAL_ENCYCLOPEDIA.md').read_text().lower():
    msgs.append('atlas missing specificity review ledger link')

fail(msgs)
