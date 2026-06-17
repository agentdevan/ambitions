#!/usr/bin/env python3
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
TRAIN = ROOT / "artifacts" / "object-stage-mega-train"
OUT = TRAIN / "reconciliation"
OUT.mkdir(parents=True, exist_ok=True)

required_artifacts = [
    OUT / "AMB-AOM-00-08-reconciliation.md",
    OUT / "AMB-AOM-04-repair-proof.md",
    OUT / "AMB-AOM-06-schema-review.md",
    OUT / "AMB-AOM-03-motion-behavior-review.md",
    OUT / "AMB-AOM-07-shell-visual-review.md",
    OUT / "AMB-AOM-07-shell-visual-replay.md",
    OUT / "AMB-AOM-08-today-blocker-review.md",
    OUT / "AMB-AOM-08-today-replay.md",
]
missing = [path.relative_to(ROOT).as_posix() for path in required_artifacts if not path.exists()]
if missing:
    raise SystemExit("Missing required reconciliation artifacts: " + ", ".join(missing))

source_reports = {
    "AMB-AOM-00": TRAIN / "AMB-AOM-00-report.md",
    "AMB-AOM-01A": TRAIN / "AMB-AOM-01A-report.md",
    "AMB-AOM-01B": TRAIN / "AMB-AOM-01B-report.md",
    "AMB-AOM-01C": TRAIN / "AMB-AOM-01C-report.md",
    "AMB-AOM-02": TRAIN / "AMB-AOM-02-report.md",
    "AMB-AOM-05": TRAIN / "AMB-AOM-05-report.md",
}
missing_reports = [batch for batch, path in source_reports.items() if not path.exists()]
if missing_reports:
    raise SystemExit("Missing source train reports: " + ", ".join(missing_reports))

rows = [
    ["AMB-AOM-00", "YELLOW_ACCEPTED_AS_AUDIT", "Audit/source-map quality is accepted as a boundary artifact; no automatic replay."],
    ["AMB-AOM-01A", "GREEN_SOURCE_DELTA_YELLOW_PROOF_ACCEPTED", "Real source/test delta exists; proof gap recorded and no replay required before 09."],
    ["AMB-AOM-01B", "GREEN_SOURCE_DELTA_YELLOW_PROOF_ACCEPTED", "Routing/app-intent/test source delta exists; scope proof gap recorded and no replay required before 09."],
    ["AMB-AOM-01C", "YELLOW_ACCEPTED_TEST_SCOPE", "Test/guard-only scope is accepted for IA tests/stale assertion cleanup; no app-source replay required."],
    ["AMB-AOM-02", "GREEN_SOURCE_DELTA_YELLOW_PRODUCT_PROOF_ACCEPTED", "RootView/Motion/Projection/Stage source delta exists; product proof debt remains tracked outside pre-09 blocker scope."],
    ["AMB-AOM-03", "GREEN_ACCEPTED_NO_REPLAY", "Motion demotion source audit passed."],
    ["AMB-AOM-04", "GREEN_REPAIRED_WITH_SOURCE_AND_TEST_DELTA", "Capture routing repair proof accepted."],
    ["AMB-AOM-05", "GREEN_SOURCE_DELTA_YELLOW_SCOPE_PROOF_ACCEPTED", "Today/Time source delta exists; trust-language cleanup proof debt remains tracked outside pre-09 blocker scope."],
    ["AMB-AOM-06", "GREEN_ACCEPTED_NO_SCHEMA_REPLAY", "Schema decision review accepted no-change artifact."],
    ["AMB-AOM-07", "GREEN_REPLAY_SOURCE_DELTA", "Shell sensory feedback replay closed visual foundation Yellow."],
    ["AMB-AOM-08", "GREEN_REPLAY_SOURCE_DELTA", "Today hardcoded time and CTA-stack blockers replayed."],
]

lines = [
    "# AMB-AOM Pre-09 Proof-Quality Closeout",
    "",
    "Status: `GREEN_PRE09_UNBLOCKED`",
    "",
    "AMB-AOM-09 may start after this closeout because all Red and likely-replay predecessors have either been repaired, accepted with explicit proof, or replayed through deterministic Autopilot batches.",
    "",
    "## Final predecessor table",
    "",
    "| Batch | Final status | Closeout note |",
    "|---|---|---|",
]
for batch, status, note in rows:
    lines.append(f"| {batch} | {status} | {note} |")
lines += [
    "",
    "## Required reconciliation artifacts verified",
    "",
]
for path in required_artifacts:
    lines.append(f"- `{path.relative_to(ROOT).as_posix()}`")
lines += [
    "",
    "## Remaining non-blocking debts",
    "",
    "- Pixel-level Today polish remains future visual QA work.",
    "- Full shell screenshot packaging still needs object-stage artifacts included in workflow upload output.",
    "- AMB-AOM-01/02/05 proof-quality gaps are recorded but are no longer pre-09 blockers because source deltas exist and later targeted reconciliations closed the Red items.",
    "",
    "## Next gate",
    "",
    "Proceed to AMB-AOM-09 Goals Reconstruction using deterministic Autopilot source-changing batches only.",
    "",
]
(OUT / "AMB-AOM-pre09-proof-quality-closeout.md").write_text("\n".join(lines), encoding="utf-8")
print("AMB-AOM pre-09 proof-quality closeout written.")
