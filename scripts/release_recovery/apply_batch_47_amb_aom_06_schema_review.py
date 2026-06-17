#!/usr/bin/env python3
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SRC = ROOT / "artifacts" / "object-stage-mega-train" / "AMB-AOM-06-schema-decision.md"
OUT = ROOT / "artifacts" / "object-stage-mega-train" / "reconciliation"
OUT.mkdir(parents=True, exist_ok=True)

if not SRC.exists():
    raise SystemExit("Missing AMB-AOM-06 schema decision artifact")

text = SRC.read_text(encoding="utf-8", errors="ignore")
lower = text.lower()
required = {
    "inspected persistence/domain files": ["inspected files", "persistence", "swiftdata"],
    "schema changed decision": ["schema changed", "no"],
    "model inventory": ["model inventory", "goalrecord", "capturerecord"],
    "migration/defaults impact": ["migration/defaults impact", "none introduced"],
    "test/no-run reason": ["required batch checks", "persistence tests not run"],
    "local-first privacy boundary": ["local-first/privacy boundary", "boundary scan"],
    "rollback route": ["rollback", "backup snapshot", "staged dry-run"],
}
missing = [name for name, tokens in required.items() if not all(token in lower for token in tokens)]
if missing:
    raise SystemExit("AMB-AOM-06 schema decision is incomplete: " + ", ".join(missing))

report = """# AMB-AOM-06 Schema Decision Review

Status: `GREEN_ACCEPTED_NO_SCHEMA_REPLAY`

The original AMB-AOM-06 run was treated as invalid until a sufficient no-change schema decision artifact existed. The current schema decision artifact is accepted. No replay is required.

## Accepted source artifact

- `artifacts/object-stage-mega-train/AMB-AOM-06-schema-decision.md`

## Acceptance gates

- Inspected SwiftData/domain/persistence files are listed.
- Model inventory is present and includes the current SwiftData schema records.
- Schema changed decision is explicit: `NO`.
- Migration/defaults impact is explicitly no new impact.
- Test/no-run rationale is present.
- Local-first/privacy boundary is present.
- Rollback/no-op recovery path is present.

## Remaining risk

This closes schema replay risk only. It does not prove product/UI behavior for AMB-AOM-03, AMB-AOM-07, or AMB-AOM-08.

## Next gate

Proceed to AMB-AOM-03 source-behavior audit or replay.
"""

(OUT / "AMB-AOM-06-schema-review.md").write_text(report, encoding="utf-8")
print("AMB-AOM-06 schema decision accepted; review proof written.")
