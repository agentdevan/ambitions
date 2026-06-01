#!/usr/bin/env python3
from pathlib import Path
import json, re, sys

ROOT = Path(__file__).resolve().parents[1]
TEXT_SUFFIXES = {'.swift', '.md', '.json', '.yml', '.yaml', '.py', '.sh'}


def text_files():
    for path in ROOT.rglob('*'):
        if path.is_file() and path.suffix in TEXT_SUFFIXES:
            yield path


def fail(title, detail):
    print(f'RED: {title}: {detail}')
    return False


def main():
    ok = True
    manifest = ROOT / 'Package.swift'
    if not manifest.exists():
        ok = fail('missing package manifest', manifest)

    assets = ROOT / 'Sources' / 'AmbitionsExperienceKernel' / 'Resources' / 'AmbitionsExperienceTokens.xcassets'
    color_count = len(list(assets.glob('*.colorset')))
    if not (60 <= color_count <= 130):
        ok = fail('controlled token range failed', color_count)

    contracts_path = ROOT / 'Sources' / 'AmbitionsExperienceKernel' / 'Resources' / 'Manifests' / 'surface_contracts.json'
    contracts = json.loads(contracts_path.read_text())
    today = contracts['surfaces']['today']
    if today['primaryObject'] != 'realityMeridian':
        ok = fail('today primary object mismatch', today['primaryObject'])
    if 'startHere' not in today['decisionLayers']:
        ok = fail('missing startHere decision layer', today['decisionLayers'])

    blocked = [''.join(['p','a','n','e','l']), ''.join(['c','a','r','d']), ''.join(['d','a','s','h','b','o','a','r','d']), ''.join(['c','h','a','t','b','o','t'])]
    for path in text_files():
        rel = path.relative_to(ROOT)
        text = path.read_text(errors='ignore')
        lowered = text.lower()
        if path.name == 'ambitions_kernel_lint.py':
            lowered_for_shape = lowered.replace("''.join(['p','a','n','e','l'])", '').replace("''.join(['c','a','r','d'])", '')
        else:
            lowered_for_shape = lowered
        for term in blocked:
            if term in lowered_for_shape:
                ok = fail('legacy UI language found', f'{rel}: {term}')
        if path.suffix == '.swift' and re.search(r'#[0-9a-fA-F]{6}', text):
            ok = fail('raw hex in Swift source', rel)
        if path.suffix == '.swift' and ('.buttonStyle(' + '.bordered') in text:
            ok = fail('default command style found', rel)

    inv_count = len(list((ROOT / 'Codex' / 'Inventions').glob('*.md')))
    if inv_count != 32:
        ok = fail('invention spec count mismatch', inv_count)

    batch_count = len(list((ROOT / 'Codex' / 'Batches').glob('*.md')))
    if batch_count != 16:
        ok = fail('Codex batch count mismatch', batch_count)

    required = [
        ROOT / 'Scripts' / 'repo_truth_audit.py',
        ROOT / 'Sources' / 'AmbitionsExperienceKernel' / 'AmbitionsExperienceCompiler.swift',
        ROOT / 'Sources' / 'AmbitionsExperienceKernel' / 'AmbitionsRuntimeBridge.swift',
        ROOT / 'Sources' / 'AmbitionsExperienceKernel' / 'Resources' / 'Manifests' / 'compiler_calibration.json',
    ]
    for item in required:
        if not item.exists():
            ok = fail('required artifact missing', item.relative_to(ROOT))

    if ok:
        print('GREEN: AmbitionsExperienceKernel release gates passed')
        print(f'colorAssets={color_count} inventions={inv_count} batches={batch_count}')
        return 0
    return 1

if __name__ == '__main__':
    raise SystemExit(main())
