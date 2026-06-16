#!/usr/bin/env python3
from __future__ import annotations

from report_reconstruction_support import read, require_markers, write, write_proof

DEGRADED = "Native/Ambitions/Features/Shared/DegradedStateOrchestrator.swift"


def main() -> int:
    text = read(DEGRADED)
    text = text.replace("Start Here waits for one real goal, capture, or promise instead of inventing urgency.", "No recommended step fits right now. Ambitions will stay quiet instead of inventing urgency.")
    text = text.replace("The rail can stay open; empty space is not treated as failure.", "The Reality Meridian can stay open; quiet space is part of the day.")
    text = text.replace("Your Direction waits for a goal with enough local shape to inspect.", "Your Direction waits for a goal thread with enough shape to inspect.")
    text = text.replace("The composer stays quiet until there is a capture that needs a place.", "The composer stays quiet until something needs a place.")
    text = text.replace("The LifeShape Field can stay open when no real constraints need shaping.", "The LifeShape Field can stay open when no real pressure needs shaping.")
    text = text.replace("Your System starts with setup and trust controls before it shows deeper history.", "Your System starts with profile, defaults, privacy, and history controls.")
    text = text.replace("Search stays quiet until explicit local evidence makes recall useful.", "Search stays quiet until local evidence makes recall useful.")
    write(DEGRADED, text)

    require_markers(DEGRADED, ["No recommended step fits right now", "quiet space is part of the day", "profile, defaults, privacy, and history controls", "no real pressure"])

    write_proof(
        "REPORT_BATCH_42_QUIET_EMPTY_STATE_REBUILD.md",
        """
# Batch 42 — Quiet Empty State Rebuild

Status: applied.

Scope:
- Rebuilt object empty-state language to collapse quietly instead of overexplaining architecture.
- Replaced generic/source-shaped empty copy with user-operable state language.
- Clarified Today, Reality Meridian, Goals, Time, You, and Search empty states.

Native interaction law:
- Empty, low-data, and inactive states need grace.

Validation:
- Source markers prove quiet empty-state copy exists.
- Xcode build remains the blocking gate.
""",
    )
    print("Applied Batch 42 Quiet Empty State Rebuild.")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
