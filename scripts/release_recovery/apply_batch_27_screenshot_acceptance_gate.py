#!/usr/bin/env python3
from __future__ import annotations

from report_reconstruction_support import read, replace_all, require_markers, write, write_proof

WORKFLOW = ".github/workflows/ambitions-report-screenshots.yml"


def main() -> int:
    text = read(WORKFLOW)
    text = replace_all(text, {
        "continue-on-error: true": "continue-on-error: false",
        "Artifacts include extracted screenshots when xcparse is installed, raw xcresult bundles otherwise, and focused test logs/summaries.": "Artifacts include extracted screenshots when xcparse is installed, raw xcresult bundles otherwise, and focused test logs/summaries. This workflow fails closed when a focused screenshot proof fails.",
    })
    if "paths:" in text and "Native/AmbitionsUITests/**" not in text:
        text = text.replace(
            "      - .github/workflows/ambitions-report-screenshots.yml\n",
            "      - .github/workflows/ambitions-report-screenshots.yml\n      - Native/AmbitionsUITests/**\n      - Native/Ambitions/Features/**\n      - Native/Ambitions/App/**\n      - Sources/Components/**\n",
            1,
        )
    write(WORKFLOW, text)
    require_markers(WORKFLOW, ["continue-on-error: false", "fails closed", "Native/AmbitionsUITests/**", "Sources/Components/**"])
    write_proof(
        "REPORT_BATCH_27_SCREENSHOT_ACCEPTANCE_GATE.md",
        """
# Batch 27 — Screenshot acceptance gate

Status: applied.

Scope:
- Converted the report screenshot workflow from advisory upload to fail-closed screenshot proof.
- Expanded screenshot workflow triggers to UI tests, top-level app surfaces, and shared component changes.
- Kept raw xcresult upload behavior for artifact review.

Atlas gates:
- Screenshot proof must be real, not hidden behind continue-on-error.
- Native iPhone quality requires visual proof after shell/surface/component changes.
- Motion screenshot failure must stop the workflow rather than appear Green.
""",
    )
    print("Applied Batch 27 Screenshot acceptance gate.")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
