#!/usr/bin/env python3
from __future__ import annotations

from report_reconstruction_support import read, require_markers, write, write_proof

TIME = "Native/Ambitions/Features/Time/TimeLifeShapeField.swift"


def main() -> int:
    text = read(TIME)
    text = text.replace(
        'Text("Horizon")',
        'Text("Future pressure")',
    )
    text = text.replace(
        'subtitle: "Day, Week, and Month change the field without changing root navigation."',
        'subtitle: "Today, tomorrow, week, month, and later stay inside the same field."',
    )
    text = text.replace(
        'accessibilityLabel("Time horizon")',
        'accessibilityLabel("Future pressure")',
    )
    write(TIME, text)

    require_markers(TIME, ["Future pressure", "Today, tomorrow, week, month, and later", "LifeShape zoom"])

    write_proof(
        "REPORT_BATCH_39_TIME_FUTURE_BUCKETS.md",
        """
# Batch 39 — Time Future Buckets

Status: applied.

Scope:
- Reframed the horizon control around future pressure buckets.
- Added Today / tomorrow / week / month / later language inside the LifeShape Field.
- Kept the behavior inside Time instead of creating a calendar clone or extra root tabs.

Native interaction law:
- Time must be legible before it is intelligent.
- Scheduled future grouping is useful only when translated into capacity and pressure.

Validation:
- Source markers prove future pressure bucket language exists.
- Xcode build remains the blocking gate.
""",
    )
    print("Applied Batch 39 Time Future Buckets.")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
