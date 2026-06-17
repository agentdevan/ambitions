#!/usr/bin/env python3
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = ROOT / "artifacts" / "object-stage-mega-train"
OUT = BASE / "reconciliation"
OUT.mkdir(parents=True, exist_ok=True)

required = [
    "AMB-AOM-00-08-reconciliation.md",
    "AMB-AOM-04-repair-proof.md",
    "AMB-AOM-06-schema-review.md",
    "AMB-AOM-03-motion-behavior-review.md",
    "AMB-AOM-07-shell-visual-review.md",
    "AMB-AOM-07-shell-visual-replay.md",
    "AMB-AOM-08-today-blocker-review.md",
    "AMB-AOM-08-today-replay.md",
]
missing = [name for name in required if not (OUT / name).exists()]
if missing:
    raise SystemExit("Missing reconciliation files: " + ", ".join(missing))

reports = ["AMB-AOM-01A", "AMB-AOM-01B", "AMB-AOM-01C", "AMB-AOM-02", "AMB-AOM-05"]
missing_reports = [batch for batch in reports if not (BASE / f"{batch}-report.md").exists()]
if missing_reports:
    raise SystemExit("Missing train reports: " + ", ".join(missing_reports))

rows = [
    ("AMB-AOM-00", "YELLOW_ACCEPTED_AS_AUDIT"),
    ("AMB-AOM-01A", "GREEN_SOURCE_DELTA_YELLOW_PROOF_ACCEPTED"),
    ("AMB-AOM-01B", "GREEN_SOURCE_DELTA_YELLOW_PROOF_ACCEPTED"),
    ("AMB-AOM-01C", "YELLOW_ACCEPTED_TEST_SCOPE"),
    ("AMB-AOM-02", "GREEN_SOURCE_DELTA_YELLOW_PRODUCT_PROOF_ACCEPTED"),
    ("AMB-AOM-03", "GREEN_ACCEPTED_NO_REPLAY"),
    ("AMB-AOM-04", "GREEN_REPAIRED_WITH_SOURCE_AND_TEST_DELTA"),
    ("AMB-AOM-05", "GREEN_SOURCE_DELTA_YELLOW_SCOPE_PROOF_ACCEPTED"),
    ("AMB-AOM-06", "GREEN_ACCEPTED_NO_SCHEMA_REPLAY"),
    ("AMB-AOM-07", "GREEN_REPLAY_SOURCE_DELTA"),
    ("AMB-AOM-08", "GREEN_REPLAY_SOURCE_DELTA"),
]

lines = [
    "# AMB-AOM Pre-09 Closeout",
    "",
    "Status: `GREEN_PRE09_UNBLOCKED`",
    "",
    "AMB-AOM-09 is unblocked only after this file is committed by Autopilot.",
    "",
    "| Batch | Final status |",
    "|---|---|",
]
for batch, status in rows:
    lines.append(f"| {batch} | {status} |")
lines += ["", "## Verified reconciliation files", ""]
for name in required:
    lines.append(f"- `artifacts/object-stage-mega-train/reconciliation/{name}`")
lines += ["", "## Verified train reports", ""]
for batch in reports:
    lines.append(f"- `artifacts/object-stage-mega-train/{batch}-report.md`")
lines += ["", "## Next gate", "", "Proceed to AMB-AOM-09 Goals Reconstruction using deterministic Autopilot batches.", ""]

(OUT / "AMB-AOM-pre09-proof-quality-closeout.md").write_text("\n".join(lines), encoding="utf-8")
print("AMB-AOM pre-09 closeout written.")
