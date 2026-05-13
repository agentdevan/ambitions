#!/usr/bin/env python3
from pathlib import Path
import json, re, sys
ROOT = Path(__file__).resolve().parents[1]
BASE = ROOT / 'docs/canon/frontend'
INV = BASE / 'SURFACE_RECIPE_INVENTORY.yaml'
REQUIRED_FIELDS = ['surface_id','name','canon_status','destination','surface_type','hierarchy_level','parent_surface','child_surfaces','primary_object','supporting_objects','visible_regions','recipe_file','source_truth','planned_batch_sources','precedence_notes','direction_conflicts','open_direction_questions','forbidden_patterns']
ALLOWED_STATUSES = {'intended_canon','planned_canon','directional_candidate','unresolved_direction','historical_reference','obsolete','excluded'}
ALLOWED_TYPES = {'app_shell','top_level_surface','drill_down','sheet','drawer','tray','modal','overlay','row','state_surface','empty_state','error_state','onboarding','settings_detail','receipt_detail','proof_detail','source_detail','composer_state','navigation_chrome'}
ALLOWED_LEVELS = {'global','destination_root','primary_surface','secondary_surface','tertiary_surface','transient_surface','component_surface','state_variant'}
RECIPE_HEADINGS = ['Canon Status', 'Surface ID', 'Destination', 'Surface Type', 'Hierarchy Level', 'Parent Surface', 'Child Surfaces', 'Final Intended Role', 'User Perception', 'Why This Surface Exists', 'Primary Object', 'Supporting Objects', 'Visible Regions', 'Region-by-Region Recipe', 'Primitive Inventory', 'Object Inventory', 'Typography Recipe', 'Spacing Recipe', 'Material Recipe', 'Color and State Recipe', 'Icon, Chevron, and Disclosure Recipe', 'CTA Recipe', 'Label and Microcopy Recipe', 'Receipt / Proof / Source Recipe', 'State Model', 'Allowed States', 'Forbidden States', 'Motion and Haptic Intent', 'Accessibility Intent', 'Dynamic Type Intent', 'VoiceOver Intent', 'Reduce Motion Intent', 'ADHD Usability Intent', 'Relationship to MRI', 'Relationship to HBI', 'Source Truth', 'Planned Batch Sources', 'Precedence / Conflict Notes', 'Forbidden Generic Drift', 'Open Direction Gaps']
MINIMUM_SURFACES = ['Global App Shell', 'Destination Dock', 'Destination Tab Item', 'Compact Surface Header', 'Context Crown', 'Back Navigation', 'Sheet Chrome', 'Tray Chrome', 'Receipt Toast / Inline Confirmation', 'Global Empty State Shell', 'Global Error / Fallback Shell', 'Today Root / Reality Meridian', 'Today Current Context Header', 'Today Start Here Region', 'Today Reality Meridian Rail', 'Today Recommended Step Object', 'Today Now / Next / Later Sequence', 'Today Upcoming Commitments Region', 'Today Closure Prompt Region', 'Today Receipt Shelf', 'Today Source Freshness Indicator', 'Step Detail', 'Step Session', 'Recommendation Source Sheet', 'Closure Sheet', 'Receipt Detail', 'Proof Attachment Detail', 'Adjust Plan / Reflow Preview Entry', 'Blocked Detail', 'Waiting Detail', 'Goal Thread Context from Today', 'Local Runtime Source Detail from Today', 'Today Empty State', 'Today No Schedule Data State', 'Today Overloaded State', 'Today Recovery State', 'Today Vacation / Away State', 'Today Protected Time State', 'Today Stale Recommendation State', 'Goals Root / Constellation Atlas', 'Goals Life Area Map', 'Selected Life Area Surface', 'Ambition Graph', 'Goal Thread Detail', 'Goal Detail', 'Commitment Detail', 'Proof Trail', 'Proof Detail', 'Proof Gap State', 'Blocker Detail', 'Alternate Path Detail', 'Milestone Detail', 'Recommended Step Context from Goals', 'Reflection / Recovery Detail', 'Goals Empty State', 'Goals Review State', 'Goals Blocked State', 'Goals Archive / Historical Goal State', 'Capture Root / Atmosphere Composer', 'Capture Idle Composer', 'Capture Active Text Entry', 'Capture Dictation State', 'Capture Attachment / Proof Picker', 'Capture Post-Input Route Reveal', 'Capture Save as Proof Route', 'Capture Make Commitment Route', 'Capture Grow into Goal Route', 'Capture Mark Constraint Route', 'Capture Reflect Route', 'Capture Hold / Needs a Place Route', 'Capture Receipt', 'Capture Parse Uncertain State', 'Capture Offline Local-Only State', 'Capture Error / Failed Attachment State', 'Capture Empty First-Use State', 'Time Root / LifeShape Field', 'Time Scope Control', 'Day LifeShape Surface', 'Week LifeShape Surface', 'Month LifeShape Surface', 'Open Time Region', 'Protected Time Region', 'Pressure Region', 'Best Fit Region', 'Recovery / Flex Region', 'Review Pressure Surface', 'Best Fit Explanation Sheet', 'Protected Time Detail', 'Day Detail', 'Week Detail', 'Month Detail', 'Reflow Preview Tray', 'Shape Day Flow', 'Reflow Week Flow', 'Shape Month Flow', 'Time Receipt Detail', 'Schedule & Availability Entry', 'Planning Defaults Entry', 'Vacation / Away Time Entry', 'Time No Calendar Data State', 'Time Overloaded State', 'Time Protected Block State', 'Time Vacation / Away State', 'Time Stale Source State', 'You Root / User System Profile', 'User Profile Header', 'Local Runtime Trust Panel', 'Planning Setup Section', 'Schedule & Availability', 'Planning Defaults', 'Vacation / Away Time', 'Automation & Trust', 'Notifications', 'Capture Preferences', 'Focus / Session Defaults', 'Privacy', 'Personal Runtime', 'Local Data / Reset / Forget', 'Help', 'About Ambitions', 'You Empty / First-Run State', 'You Trust Warning State', 'You Offline Local-Only State', 'Commitment Staging Tray', 'Reflow Preview Tray', 'Receipt System', 'Closure System', 'Proof Trail System', 'Recommendation Source System', 'Why This Sheet', 'Source Freshness Badge', 'Still Counts State', 'Moved State', 'Skipped / Not Needed State', 'Blocked State', 'Waiting State', 'Needs Recovery State', 'Needs Review State', 'Protected Marker', 'Pressure Marker', 'Best Fit Marker', 'Open Marker', 'Primary CTA', 'Secondary CTA', 'Destructive CTA', 'Disabled CTA', 'Chevron / Disclosure Row', 'QuietGlass Wrapper', 'GraphiteRecess Base', 'LuminousTrace State Line', 'CelestialField Semantic Layer', 'First Run Root', 'Schedule Setup Prompt', 'Planning Defaults Prompt', 'Privacy / Local Runtime Explanation', 'Capture First-Use Prompt', 'Goals First-Use Prompt', 'Time First-Use Prompt', 'Today First-Use State']
def load_inventory():
    return json.loads(INV.read_text())
def fail(msgs):
    if msgs:
        for m in msgs: print('FAIL:', m)
        sys.exit(1)
    print('PASS')

msgs=[]
for rel in ['SURFACE_RECIPE_INDEX.md','SURFACE_RECIPE_INVENTORY.yaml','SURFACE_RECIPE_INVENTORY.md','FRONTEND_SURFACE_COVERAGE_MAP.md','trace/PLANNED_BATCH_FRONTEND_DIRECTION_INVENTORY.md','trace/FRONTEND_SOURCE_PRECEDENCE_LEDGER.md']:
    if not (BASE/rel).exists(): msgs.append(f'missing {rel}')
for rel in ['objects/MRI_FRONTEND_OBJECTS.md','objects/HBI_FRONTEND_OBJECTS.md']:
    if (BASE/rel).exists(): msgs.append(f'{rel} must not exist as an active object file')
for rel in ['source-families/MRI_FRONTEND_SOURCE_FAMILY.md','source-families/HBI_FRONTEND_SOURCE_FAMILY.md']:
    if not (BASE/rel).exists(): msgs.append(f'missing source-family map {rel}')
try:
    items=load_inventory()
except Exception as e:
    fail([f'inventory parse failed: {e}'])
if not isinstance(items,list) or not items: msgs.append('inventory must be a non-empty list')
seen={}
for item in items:
    for f in REQUIRED_FIELDS:
        if f not in item: msgs.append(f"{item.get('name','<unknown>')} missing {f}")
    if item.get('canon_status') not in ALLOWED_STATUSES: msgs.append(f"{item.get('name')} invalid canon_status")
    if item.get('surface_type') not in ALLOWED_TYPES: msgs.append(f"{item.get('name')} invalid surface_type")
    if item.get('hierarchy_level') not in ALLOWED_LEVELS: msgs.append(f"{item.get('name')} invalid hierarchy_level")
    seen[item.get('name')]=item
    recipe = ROOT / item.get('recipe_file','')
    if item.get('canon_status') in {'intended_canon','planned_canon','directional_candidate','unresolved_direction'} and not recipe.exists(): msgs.append(f"{item.get('name')} missing recipe file {recipe}")
for name in MINIMUM_SURFACES:
    if name not in seen: msgs.append(f'missing minimum surface {name}')
for root in ['Today Root / Reality Meridian','Goals Root / Constellation Atlas','Capture Root / Atmosphere Composer','Time Root / LifeShape Field','You Root / User System Profile']:
    if root not in seen: msgs.append(f'missing top-level root {root}')
ledger=(BASE/'trace/FRONTEND_SOURCE_PRECEDENCE_LEDGER.md').read_text() if (BASE/'trace/FRONTEND_SOURCE_PRECEDENCE_LEDGER.md').exists() else ''
if 'ranking uses explicit registry metadata' not in ledger.lower(): msgs.append('source precedence ledger missing planned-batch recency doctrine')
planned_path = BASE/'trace/PLANNED_BATCH_FRONTEND_DIRECTION_INVENTORY.md'
if planned_path.exists():
    planned = planned_path.read_text().splitlines()
    concrete_decisions = {}
    for line in planned:
        if not line.startswith('|'):
            continue
        if 'batch id' in line.lower() or '---' in line:
            continue
        row = line.lower()
        if 'no concrete visual direction found' in row:
            continue
        if not any(term in row for term in ['reality meridian','constellation atlas','atmosphere composer','lifeshape field','user system profile','proof','receipt','source freshness','accessibility','start here']):
            msgs.append('planned batch inventory row lacks extracted concrete visual direction or explicit no-concrete-direction marker')
            break
        cells=[c.strip() for c in line.strip('|').split('|')]
        if len(cells) >= 8:
            concrete_decisions[cells[7]]=concrete_decisions.get(cells[7],0)+1
    repeated=[decision for decision,count in concrete_decisions.items() if count > 1]
    if repeated:
        msgs.append('planned batch inventory repeats concrete direction boilerplate instead of source-specific extraction')
fail(msgs)
