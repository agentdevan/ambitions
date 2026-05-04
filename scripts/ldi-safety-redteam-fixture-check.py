#!/usr/bin/env python3
from pathlib import Path
print("ldi-safety-redteam-fixture-check: advisory 45-family fixture coverage")
manifest = Path("docs/codex/fixtures/ldi/redteam-fixture-manifest.md")
if not manifest.exists():
    print("YELLOW advisory: LDI red-team fixture manifest does not exist yet; expected before LDI21 Green.")
    raise SystemExit(0)
text = manifest.read_text()
missing = [str(i) for i in range(1, 46) if f"{i} " not in text and f"{i}." not in text and f"| {i} |" not in text]
if missing:
    print("RED: missing fixture families: " + ", ".join(missing))
    raise SystemExit(1)
print("PASS: 45 LDI fixture families are represented.")
