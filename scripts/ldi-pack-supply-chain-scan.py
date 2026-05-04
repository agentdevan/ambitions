#!/usr/bin/env python3
import json
from pathlib import Path
print("ldi-pack-supply-chain-scan: advisory pack manifest field scan")
files = list(Path("docs").rglob("*pack*.json"))
if not files:
    print("YELLOW advisory: no pack manifest JSON files found; expected in LDI06/LDI07 implementation batches.")
    raise SystemExit(0)
required = {"pack_id", "version", "schema_version", "checksum", "provenance", "source_state", "quality_state", "freshness_policy"}
status = 0
for f in files:
    try:
        data = json.loads(f.read_text())
    except Exception:
        continue
    missing = sorted(required - set(data))
    if missing:
        print(f"RED: {f} missing supply-chain fields: {', '.join(missing)}")
        status = 1
print("PASS: pack supply-chain scan completed." if status == 0 else "RED: pack supply-chain scan found missing fields.")
raise SystemExit(status)
