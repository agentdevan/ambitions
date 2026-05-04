#!/usr/bin/env python3
import json
from pathlib import Path
print("ldi-source-pack-schema-check: advisory source pack fixture validation")
roots = [Path("docs/codex/fixtures/ldi"), Path("docs/reference/ldi")]
files = []
for root in roots:
    if root.exists():
        files.extend(root.rglob("*.json"))
if not files:
    print("YELLOW advisory: no LDI source pack fixture JSON files exist yet; expected before LDI06/LDI07 Green.")
    raise SystemExit(0)
required = {"pack_id", "version", "schema_version", "checksum", "provenance", "source_state", "quality_state", "freshness_policy"}
status = 0
for file in files:
    try:
        data = json.loads(file.read_text())
    except Exception as exc:
        print(f"RED: invalid JSON {file}: {exc}")
        status = 1
        continue
    missing = sorted(required - set(data))
    if missing:
        print(f"RED: {file} missing required pack fields: {', '.join(missing)}")
        status = 1
if status == 0:
    print(f"PASS: validated {len(files)} LDI source pack fixture(s).")
raise SystemExit(status)
