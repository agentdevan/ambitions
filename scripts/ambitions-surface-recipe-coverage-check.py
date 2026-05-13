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
items=load_inventory()
priority_files = {
    'Today Root / Reality Meridian': ['Reality Meridian', 'Start Here', 'Source Freshness Badge', 'Proof Trail'],
    'Goals Root / Constellation Atlas': ['Constellation Atlas', 'Source Freshness Badge', 'Proof Trail'],
    'Capture Root / Atmosphere Composer': ['Atmosphere Composer', 'Source Freshness Badge', 'Proof Trail'],
    'Time Root / LifeShape Field': ['LifeShape Field', 'Source Freshness Badge', 'Proof Trail'],
    'You Root / User System Profile': ['User System Profile', 'Privacy', 'Personal Runtime', 'Source Freshness Badge'],
    'Commitment Staging Tray': ['Commitment Staging Tray', 'source', 'receipt'],
    'Reflow Preview Tray': ['Reflow Preview Tray', 'source', 'receipt'],
    'Today Start Here Region': ['Reality Meridian', 'Start Here', 'Source Freshness Badge'],
    'Today Recommended Step Object': ['Reality Meridian', 'Recommendation Source', 'Source Freshness Badge'],
    'Today Reality Meridian Rail': ['Reality Meridian', 'Source Freshness Badge', 'Proof Trail'],
}
scaffold_targets = [
    'recipes/today/today_root_reality_meridian.md',
    'recipes/goals/goals_root_constellation_atlas.md',
    'recipes/capture/capture_root_atmosphere_composer.md',
    'recipes/time/time_root_lifeshape_field.md',
    'recipes/you/you_root_user_system_profile.md',
    'recipes/today/today_start_here_region.md',
    'recipes/today/today_recommended_step_object.md',
    'recipes/today/today_reality_meridian_rail.md',
    'recipes/goals/ambition_graph.md',
    'recipes/goals/proof_trail.md',
    'recipes/cross_surface/commitment_staging_tray.md',
    'recipes/time/reflow_preview_tray.md',
]
scaffold_phrases = [
    'it exists so ambitions has an explicit final-state visual recipe',
    'express the specific visual meaning',
]
for item in items:
    recipe = ROOT / item.get('recipe_file','')
    if not recipe.exists():
        msgs.append(f"missing recipe {item.get('recipe_file')}")
        continue
    t=recipe.read_text()
    if item['name'] in priority_files:
        for needle in priority_files[item['name']]:
            if needle.lower() not in t.lower():
                msgs.append(f"{item['name']} missing priority term {needle}")
    low=t.lower()
    for phrase in scaffold_phrases:
        if phrase in low:
            msgs.append(f"{item['name']} still uses scaffold template phrasing: {phrase}")
    rel = item.get('recipe_file','')
    if rel in scaffold_targets and len(t.split()) < 650:
        msgs.append(f"{item['name']} priority recipe is too thin for final-state recipe specificity")
    for h in RECIPE_HEADINGS:
        if f'## {h}' not in t: msgs.append(f"{item['name']} missing heading {h}")
    if re.search(r'plan\s+(tab|top-level|destination)', low): msgs.append(f"{item['name']} treats Plan as top-level")
    if item['name'] in {'Commitment Staging Tray','Reflow Preview Tray'}:
        for bad in ['odds','stake','bet slip','parlay','cash-out','cash out','wager','line movement','boost']:
            if bad in low: msgs.append(f"{item['name']} uses wagering term {bad}")
    for bad in ['screenshot proof required','swiftui preview required','implementation mapping required','release-ready','testflight-ready','app store-ready']:
        if bad in low: msgs.append(f"{item['name']} includes forbidden proof/release framing {bad}")
registry=json.loads((BASE/'VISUAL_ITEM_REGISTRY.yaml').read_text())
ids={r.get('visual_id') for r in registry}
for item in items:
    if item['surface_id'] not in ids: msgs.append(f"registry missing surface {item['surface_id']}")
fail(msgs)
