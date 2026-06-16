#!/usr/bin/env python3
from __future__ import annotations

from report_reconstruction_support import read, require_markers, write, write_proof

ATLAS = "Native/Ambitions/Features/Goals/GoalComponents.swift"


def main() -> int:
    text = read(ATLAS)
    text = text.replace(
        "Life areas and active threads stay connected to Today.",
        "Life areas, threads, smaller steps, and proof stay connected to Today.",
    )
    text = text.replace(
        "Choose the area to focus",
        "Choose an area, then open its step path",
    )
    text = text.replace(
        "Proof path visible.",
        "Proof and smaller steps stay visible inside the thread.",
    )
    write(ATLAS, text)

    require_markers(ATLAS, ["smaller steps", "open its step path", "Proof and smaller steps"])

    write_proof(
        "REPORT_BATCH_34_ATLAS_THREADS.md",
        """
# Batch 34 — Atlas Threads

Status: applied.

Scope:
- Reframed Constellation Atlas copy around thread paths and smaller steps.
- Kept step depth inside the Goal thread instead of turning Goals into a checklist app.
- Preserved Constellation Atlas and Orbital Lens as the first-viewport object model.

Native interaction law:
- Steps can have depth, but they cannot feel like generic tasks.

Validation:
- Source markers prove thread path and smaller-step language is present.
- Xcode build remains the blocking gate.
""",
    )
    print("Applied Batch 34 Atlas Threads.")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
