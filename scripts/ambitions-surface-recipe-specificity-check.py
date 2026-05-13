#!/usr/bin/env python3
from pathlib import Path
import json
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
BASE = ROOT / 'docs/canon/frontend'
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
    'relationship to mri', 'relationship to hbi',
]
GENERIC_FILLER_PHRASES = [
    'it exists so ambitions has an explicit final-state visual recipe',
    'express the specific visual meaning',
]

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

    specificity = item.get('specificity_status')
    if specificity not in {'high_specificity', 'medium_specificity', 'low_specificity', 'unresolved_direction'}:
        msgs.append(f"{item.get('name')} has invalid specificity status")

    if specificity in {'high_specificity', 'medium_specificity'}:
        for heading in REQUIRED_GENERAL_HEADINGS:
            if f'## {heading}' not in text:
                msgs.append(f"{item.get('name')} missing heading {heading}")
        if len(text.split()) < 450:
            msgs.append(f"{item.get('name')} high/medium specificity recipe is too thin")

    if specificity == 'unresolved_direction':
        unresolved_name = item.get('name', '').lower()
        if unresolved_name not in gap_doc and unresolved_name not in train_gap_doc:
            msgs.append(f"{item.get('name')} unresolved direction not listed in gap docs")

    if item.get('name') in {'Commitment Staging Tray', 'Reflow Preview Tray'}:
        for bad in ['odds', 'stake', 'bet slip', 'parlay', 'cash-out', 'cash out', 'wager', 'line movement', 'boost']:
            if bad in lowered:
                msgs.append(f"{item.get('name')} uses wagering term {bad}")

    if 'screenshot proof required' in lowered or 'implementation proof required' in lowered:
        msgs.append(f"{item.get('name')} requires screenshot or implementation proof")

fail(msgs)
