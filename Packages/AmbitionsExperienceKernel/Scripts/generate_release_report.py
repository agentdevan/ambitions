#!/usr/bin/env python3
from pathlib import Path
import json, subprocess, sys

ROOT = Path(__file__).resolve().parents[1]
assets = ROOT / 'Sources' / 'AmbitionsExperienceKernel' / 'Resources' / 'AmbitionsExperienceTokens.xcassets'
report = {
    'package': 'AmbitionsExperienceKernel',
    'colorAssetCount': len(list(assets.glob('*.colorset'))),
    'inventionSpecs': len(list((ROOT / 'Codex' / 'Inventions').glob('*.md'))),
    'codexBatches': len(list((ROOT / 'Codex' / 'Batches').glob('*.md'))),
    'surfaceContracts': json.loads((ROOT / 'Sources' / 'AmbitionsExperienceKernel' / 'Resources' / 'Manifests' / 'surface_contracts.json').read_text())
}
(ROOT / 'release_readiness_report.json').write_text(json.dumps(report, indent=2), encoding='utf-8')
print('GREEN: release readiness report generated')
