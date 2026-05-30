#!/usr/bin/env python3
from __future__ import annotations
import json
from pathlib import Path
ROOT = Path(__file__).resolve().parents[2]
def main():
    fixture = ROOT / "docs/codex/harness/app-driving-proof-fixtures.json"
    payload = json.loads(fixture.read_text())
    print(json.dumps({
        "status": "Yellow",
        "reason": "Proof contract installed; bounded app-source launch router still required.",
        "fixture": str(fixture.relative_to(ROOT)),
        "claims_not_made": payload["claims_not_made"],
    }, indent=2))
    return 0
if __name__ == "__main__":
    raise SystemExit(main())
