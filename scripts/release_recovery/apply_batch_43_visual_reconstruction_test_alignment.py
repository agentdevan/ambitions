#!/usr/bin/env python3
from __future__ import annotations

from report_reconstruction_support import read, require_markers, write, write_proof

TESTS = "Native/AmbitionsUITests/AmbitionsUITests.swift"


def main() -> int:
    text = read(TESTS)
    text = text.replace('app.staticTexts["Planning Setup"]', 'app.staticTexts["Planning defaults"]')
    text = text.replace('scrollUntilYouRowExists(named: "Proof", in: app, maxAttempts: 6)', 'scrollUntilYouRowExists(named: "History", in: app, maxAttempts: 6)')
    text = text.replace('app.descendants(matching: .any)["time.life-shape-field.reflow-trust-seam"]', 'app.descendants(matching: .any)["time.life-shape-field.reflow-trust-seam"]')
    write(TESTS, text)

    require_markers(TESTS, ["Planning defaults", "History", "Today", "Goals", "Time", "Motion", "You"])

    write_proof(
        "REPORT_BATCH_43_VISUAL_RECONSTRUCTION_TEST_ALIGNMENT.md",
        """
# Batch 43 — Visual Reconstruction Test Alignment

Status: applied.

Scope:
- Updated UI assertions to match the new You native settings hierarchy copy.
- Preserved canonical five-tab shell assertions.
- Kept visual reconstruction proof tied to current surface language.

Validation:
- Source markers prove updated You settings expectations exist in UI tests.
- Xcode build remains the blocking gate; screenshot workflow remains the visual gate.
""",
    )
    print("Applied Batch 43 Visual Reconstruction Test Alignment.")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
