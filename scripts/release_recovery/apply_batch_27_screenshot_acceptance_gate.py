#!/usr/bin/env python3
from __future__ import annotations

from report_reconstruction_support import read, require_markers, write_proof

WORKFLOW = ".github/workflows/ambitions-report-screenshots.yml"


def main() -> int:
    text = read(WORKFLOW)
    required = [
        "continue-on-error: false",
        "fails closed",
        "Native/AmbitionsUITests/**",
        "Native/Ambitions/Features/**",
        "Native/Ambitions/App/**",
        "Sources/Components/**",
    ]
    missing = [marker for marker in required if marker not in text]
    if missing:
        raise RuntimeError(
            "Screenshot workflow gate is not installed. "
            "Update .github/workflows/ambitions-report-screenshots.yml outside the train before rerunning Batch 27. "
            f"Missing markers: {missing}"
        )

    require_markers(WORKFLOW, required)
    write_proof(
        "REPORT_BATCH_27_SCREENSHOT_ACCEPTANCE_GATE.md",
        """
# Batch 27 — Screenshot acceptance gate

Status: verified.

Scope:
- Verified the report screenshot workflow is fail-closed.
- Verified screenshot workflow triggers include UI tests, top-level app surfaces, app shell, and shared component changes.
- Kept raw xcresult upload behavior for artifact review.
- Avoided mutating workflow files from inside the Actions train, because the default Actions token cannot push workflow-file changes.

Atlas gates:
- Screenshot proof must be real, not hidden behind continue-on-error.
- Native iPhone quality requires visual proof after shell/surface/component changes.
- Motion screenshot failure must stop the workflow rather than appear Green.
""",
    )
    print("Verified Batch 27 Screenshot acceptance gate.")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
