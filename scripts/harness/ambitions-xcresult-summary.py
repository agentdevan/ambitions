#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import shutil
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any


def utc_now() -> str:
    return datetime.now(timezone.utc).replace(microsecond=0).isoformat().replace('+00:00', 'Z')


def summarize(path: Path) -> dict[str, Any]:
    payload: dict[str, Any] = {
        'created_at_utc': utc_now(),
        'path': str(path),
        'exists': path.exists(),
        'is_dir': path.is_dir(),
        'xcrun_available': shutil.which('xcrun') is not None,
        'status': 'Yellow',
        'claims_made': ['Checked whether an xcresult bundle could be inspected.'],
        'claims_not_made': [
            'No test success claim.',
            'No UI test success claim.',
            'No accessibility claim.',
            'No performance claim.',
            'No release readiness claim.',
        ],
        'notes': [],
    }
    if not path.exists():
        payload['notes'].append('xcresult path does not exist.')
        return payload
    if shutil.which('xcrun') is None:
        payload['notes'].append('xcrun unavailable; cannot inspect xcresult.')
        return payload
    proc = subprocess.run(
        ['xcrun', 'xcresulttool', 'get', '--path', str(path), '--format', 'json'],
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )
    if proc.returncode != 0:
        payload['notes'].append('xcresulttool could not inspect bundle.')
        payload['stderr'] = proc.stderr[-4000:]
        return payload
    try:
        parsed = json.loads(proc.stdout)
    except json.JSONDecodeError:
        payload['notes'].append('xcresulttool output was not valid JSON.')
        return payload
    payload['status'] = 'Green'
    payload['root_keys'] = sorted(parsed.keys())[:50]
    payload['notes'].append('xcresult bundle inspected; raw bundle remains source of truth for test claims.')
    return payload


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument('xcresult')
    parser.add_argument('--output', default='-')
    args = parser.parse_args()
    payload = summarize(Path(args.xcresult))
    text = json.dumps(payload, indent=2, sort_keys=True) + '\n'
    if args.output == '-':
        sys.stdout.write(text)
    else:
        out = Path(args.output)
        out.parent.mkdir(parents=True, exist_ok=True)
        out.write_text(text, encoding='utf-8')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
