#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path

from report_reconstruction_support import require_markers, write_proof

TRUTH = "docs/truth/NATIVE_INTERACTION_TRUTH.md"

REQUIRED = [
    "apply_batch_30_shell_drilldown_visual_reconstruction.py",
    "apply_batch_31_composer_choreography.py",
    "apply_batch_32_today_live_meridian_reconstruction.py",
    "apply_batch_33_time_lifeshape_zoom_reconstruction.py",
    "apply_batch_34_atlas_threads.py",
    "apply_batch_35_you_native_settings_hierarchy.py",
    "apply_batch_36_flagship_reconstruction_primitives.py",
    "apply_batch_37_shell_native_chrome_rebuild.py",
    "apply_batch_38_today_section_modes.py",
    "apply_batch_39_time_future_buckets.py",
    "apply_batch_40_you_settings_studio_rebuild.py",
    "apply_batch_41_motion_reentry_visual_rebuild.py",
    "apply_batch_42_quiet_empty_state_rebuild.py",
    "apply_batch_43_visual_reconstruction_test_alignment.py",
]


def main() -> int:
    base = Path("scripts/release_recovery")
    missing = [name for name in REQUIRED if not (base / name).exists()]
    if missing:
        raise RuntimeError(f"Missing visual rebuild batches: {missing}")

    require_markers(TRUTH, [
        "Time must be legible before it is intelligent",
        "Root navigation and drilldown navigation are different systems",
        "Capture must be beautiful, obvious, and expandable",
        "Settings becomes You",
        "Empty, low-data, and inactive states need grace",
    ])

    write_proof(
        "REPORT_BATCH_44_VISUAL_REBUILD_GATE.md",
        """
# Batch 44 — Visual Rebuild Gate

Status: verified.

Scope:
- Verified the visual rebuild continuation train exists from Batch 30 through Batch 43.
- Verified Native Interaction Truth remains present.
- This gate closes the source-changing train setup before screenshot proof.

Acceptance boundary:
- Build gates prove compilation only.
- Screenshot proof and manual review remain required before release readiness.
""",
    )
    print("Verified Batch 44 Visual Rebuild Gate.")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
