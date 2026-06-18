#!/usr/bin/env python3
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
TRUTH = ROOT / "docs" / "truth" / "IMPLEMENTATION_TRUTH.md"
FINAL = ROOT / "artifacts" / "object-stage-mega-train" / "AOM-12-final-validation-report.md"
OUT = ROOT / "artifacts" / "object-stage-mega-train" / "reconciliation"
OUT.mkdir(parents=True, exist_ok=True)

if not FINAL.exists():
    raise SystemExit("Missing AOM-12 final validation report")
final_text = FINAL.read_text(encoding="utf-8", errors="ignore")
if "Status: `GREEN_FINAL_VALIDATION`" not in final_text:
    raise SystemExit("AOM-12 final validation is not green")

section = """
---

## AMB-AOM Object-Stage Mega Train Current Source Proof

Status: Source-present and Autopilot-validated through AMB-AOM-12 final validation.

Current source/proof supports these implementation statements only:

- Root runtime IA is Today / Goals / Time / You.
- Capture is represented as a global composer/control path, not a root tab.
- Motion is compatibility and behavior infrastructure, not a root tab.
- Today source owns Reality Meridian / Start Here behavior with live time and a simplified action surface.
- Goals source owns Constellation Atlas with actionable Life Areas and Orbital Lens inspection.
- Time source owns LifeShape Field and explicitly rejects calendar clone, agenda clone, free/busy grid, and metric-dashboard geometry.
- You source owns User System Profile with native settings-quality groups for account/profile, privacy, appearance, notifications, learning, receipts/history, export, and support.

This proof does not establish App Store readiness, TestFlight readiness, device-signing readiness, privacy/legal sufficiency, data migration safety, or production analytics/crash/observability readiness.
"""
truth = TRUTH.read_text(encoding="utf-8", errors="ignore")
if "## AMB-AOM Object-Stage Mega Train Current Source Proof" not in truth:
    TRUTH.write_text(truth.rstrip() + "\n" + section, encoding="utf-8")

proof = """# AMB-AOM-12 Implementation Truth Closeout

Status: `GREEN_TRUTH_UPDATED`

This closeout exists because the first AMB-AOM-12 final-validation batch wrote the final report, but the recovery staging allowlist did not include `docs/truth/IMPLEMENTATION_TRUTH.md`.

## Verified prerequisite

- `artifacts/object-stage-mega-train/AOM-12-final-validation-report.md` exists.
- Final validation status is `GREEN_FINAL_VALIDATION`.

## Truth update

- `docs/truth/IMPLEMENTATION_TRUTH.md` now contains `AMB-AOM Object-Stage Mega Train Current Source Proof`.
- The truth update is bounded to source-present/autopilot-validated object-stage claims.
- The truth update explicitly does not claim release readiness, TestFlight readiness, App Store readiness, legal/privacy sufficiency, migration safety, or production observability readiness.

## Final state

Object-Stage Mega Train is closed after this batch commits.
"""
(OUT / "AMB-AOM-12-implementation-truth-closeout.md").write_text(proof, encoding="utf-8")
print("AMB-AOM-12 implementation truth closeout written.")
