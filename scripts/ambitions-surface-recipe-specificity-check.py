#!/usr/bin/env python3
from pathlib import Path
import json
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
BASE = ROOT / 'frontend/visual-encyclopedia'
INV = BASE / 'SURFACE_RECIPE_INVENTORY.yaml'

REQUIRED_GENERAL_HEADINGS = [
    'Visible Regions', 'Region-by-Region Recipe', 'Primitive Inventory',
    'Object Inventory', 'Typography Recipe', 'Spacing Recipe', 'Material Recipe',
    'Color and State Recipe', 'Icon, Chevron, and Disclosure Recipe',
    'CTA Recipe', 'Label and Microcopy Recipe', 'Receipt / Proof / Source Recipe',
    'State Model', 'Allowed States', 'Forbidden States', 'Motion and Haptic Intent',
    'Accessibility Intent', 'Dynamic Type Intent', 'VoiceOver Intent',
    'Reduce Motion Intent', 'ADHD Usability Intent',
    'Relationship to Planned Train / Source Families', 'Source Truth',
    'Planned Batch Sources', 'Precedence / Conflict Notes',
    'Forbidden Generic Drift', 'Open Direction Gaps',
]
FORBIDDEN_PHRASES = [
    'screenshot proof required', 'swiftui preview required',
    'implementation mapping required', 'release-ready', 'testflight-ready',
    'app store-ready', 'plan as top-level', 'plan tab',
    'relationship to mri', 'relationship to hbi', 'shared object system',
    'related commitments, proof, source, state markers',
    'sf-first semantic type', 'dense native rhythm',
    'icons clarify navigation',
    'only if the region owns the current decision',
    'generic dashboard modules',
]
GENERIC_FILLER_PHRASES = [
    'it exists so ambitions has an explicit final-state visual recipe',
    'express the specific visual meaning',
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
try:
    items = json.loads(INV.read_text())
except Exception as exc:
    fail([f'inventory parse failed: {exc}'])

gap_doc = (BASE / 'trace/UNMAPPED_INTENDED_SURFACE_GAPS.md').read_text().lower() if (BASE / 'trace/UNMAPPED_INTENDED_SURFACE_GAPS.md').exists() else ''
train_gap_doc = (BASE / 'trace/TRAIN_FAMILY_UNRESOLVED_DIRECTION_GAPS.md').read_text().lower() if (BASE / 'trace/TRAIN_FAMILY_UNRESOLVED_DIRECTION_GAPS.md').exists() else ''
ledger_doc = (BASE / 'trace/SURFACE_RECIPE_SPECIFICITY_REVIEW_LEDGER.md').read_text().lower() if (BASE / 'trace/SURFACE_RECIPE_SPECIFICITY_REVIEW_LEDGER.md').exists() else ''

for item in items:
    recipe_path = ROOT / item.get('recipe_file', '')
    if not recipe_path.exists():
        msgs.append(f"{item.get('name')} missing recipe file {recipe_path}")
        continue
    text = recipe_path.read_text()
    lowered = text.lower()

    if '## Relationship to Planned Train / Source Families' not in text:
        msgs.append(f"{item.get('name')} missing planned-train relationship section")
    if '## Relationship to MRI' in text or '## Relationship to HBI' in text:
        msgs.append(f"{item.get('name')} retains MRI/HBI-only relationship headings")
    if 'plan as top-level' in lowered or 'plan tab' in lowered:
        msgs.append(f"{item.get('name')} revives Plan as top-level")
    for phrase in FORBIDDEN_PHRASES:
        if phrase in lowered:
            msgs.append(f"{item.get('name')} contains forbidden phrase: {phrase}")
    for phrase in GENERIC_FILLER_PHRASES:
        if phrase in lowered:
            msgs.append(f"{item.get('name')} still contains filler phrase: {phrase}")

    priority_phrase_map = {
        'today_root_reality_meridian.md': ['reality meridian', 'source freshness badge', 'receipt system', 'proof trail'],
        'today_start_here_region.md': ['start here', 'now / next / later', 'closure system', 'source freshness badge'],
        'today_reality_meridian_rail.md': ['reality meridian', 'receipt shelf', 'protected time', 'source freshness badge'],
        'goals_root_constellation_atlas.md': ['constellation atlas', 'proof trail', 'life area', 'goal thread'],
        'goals_proof_trail.md': ['proof trail', 'proof gap', 'receipt system', 'recovery'],
        'capture_root_atmosphere_composer.md': ['atmosphere composer', 'route reveal', 'receipt confirmation', 'proof trail'],
        'time_root_lifeshape_field.md': ['lifeshape field', 'protected time', 'pressure', 'best-fit'],
        'you_root_user_system_profile.md': ['user system profile', 'local runtime', 'privacy', 'reset'],
        'commitment_staging_tray.md': ['commitment staging tray', 'confirm', 'cancel', 'undo', 'protected'],
        'reflow_preview_tray.md': ['reflow preview tray', 'before/after', 'best-fit', 'undo'],
        'recommendation_source_system.md': ['recommendation source system', 'source', 'correction', 'why this?'],
        'receipt_system.md': ['receipt system', 'receipt-confirmed', 'undo', 'source'],
        'proof_trail_system.md': ['proof trail system', 'proof', 'receipt', 'source'],
    }
    if recipe_path.name in PRIORITY_RECIPE_NAMES:
        if 'purpose: show how ' in lowered or 'contains: shared object system' in lowered:
            msgs.append(f"{item.get('name')} priority recipe still contains generated purpose phrasing")
        for phrase in priority_phrase_map.get(recipe_path.name, []):
            if phrase not in lowered:
                msgs.append(f"{item.get('name')} is missing priority specificity phrase: {phrase}")

    specificity = item.get('specificity_status')
    if specificity not in {'high_specificity', 'unresolved_direction'}:
        msgs.append(f"{item.get('name')} has invalid specificity status")
    if specificity == 'high_specificity':
        for heading in REQUIRED_GENERAL_HEADINGS:
            if f'## {heading}' not in text:
                msgs.append(f"{item.get('name')} missing heading {heading}")
        if len(text.split()) < 450:
            msgs.append(f"{item.get('name')} high specificity recipe is too thin")

    if specificity == 'unresolved_direction':
        unresolved_name = item.get('name', '').lower()
        if unresolved_name not in gap_doc and unresolved_name not in train_gap_doc:
            msgs.append(f"{item.get('name')} unresolved direction not listed in gap docs")
        if unresolved_name not in ledger_doc:
            msgs.append(f"{item.get('name')} unresolved direction not listed in specificity review ledger")

    if item.get('name') in {'Commitment Staging Tray', 'Reflow Preview Tray'}:
        for bad in ['odds', 'stake', 'bet slip', 'parlay', 'cash-out', 'cash out', 'wager', 'line movement', 'boost']:
            if bad in lowered:
                msgs.append(f"{item.get('name')} uses wagering term {bad}")

    if 'screenshot proof required' in lowered or 'implementation proof required' in lowered:
        msgs.append(f"{item.get('name')} requires screenshot or implementation proof")

if 'remaining medium recipes: 0' not in ledger_doc:
    msgs.append('specificity review ledger must state zero remaining medium recipes')

fail(msgs)
