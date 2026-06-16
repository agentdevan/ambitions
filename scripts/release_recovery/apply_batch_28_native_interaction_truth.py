#!/usr/bin/env python3
from __future__ import annotations

from report_reconstruction_support import read, require_markers, write_proof

TRUTH = "docs/truth/NATIVE_INTERACTION_TRUTH.md"
PRODUCT_TRUTH = "docs/truth/PRODUCT_DESIGN_TRUTH.md"


def main() -> int:
    native_truth = read(TRUTH)
    product_truth = read(PRODUCT_TRUTH)

    required_native_markers = [
        "Time must be legible before it is intelligent",
        "Root navigation and drilldown navigation are different systems",
        "Capture must be beautiful, obvious, and expandable",
        "Settings becomes You",
        "Ambitions uses living-object transitions, not page-open transitions",
        "Empty, low-data, and inactive states need grace",
        "Steps can have substeps, evidence, attachments, reminders, and repeats, but must not become tasks",
        "ChatGPT | Composer quality | Capture uses premium composer",
        "Could a user understand what this screen does before reading Ambitions-specific vocabulary?",
        "NATIVE_INTERACTION_TRUTH.md",
    ]
    require_markers(TRUTH, required_native_markers)
    require_markers(PRODUCT_TRUTH, [
        "Codex must treat this file as the only active product/design truth",
        "Ambitions is an object-first native iPhone product system",
        "Today / Goals / Time / Motion / You",
        "Capture",
    ])

    if "calendar clone" not in product_truth or "chatbot" not in product_truth:
        raise RuntimeError("Product Design Truth anti-drift canon must remain intact while adding Native Interaction Truth.")

    if "ChatGPT" in native_truth and "copy no product category. Translate interaction law only." not in native_truth:
        raise RuntimeError("Imported app references must remain translated into Ambitions interaction laws, not copied as product direction.")

    write_proof(
        "REPORT_BATCH_28_NATIVE_INTERACTION_TRUTH.md",
        """
# Batch 28 — Native Interaction Truth Canon Gate

Status: verified.

Scope:
- Verified the Native Interaction Truth canon is present under docs/truth.
- Verified imported app references are translated into Ambitions interaction laws, not copied as product direction.
- Verified the Product Design Truth anti-drift canon remains intact.
- Verified the report-repair work now has explicit canon gates for time legibility, root-vs-drilldown navigation, Capture composer quality, You-as-settings, living-object transitions, graceful empty states, and Step mechanics.

Implementation implications:
- Future UI reconstruction batches must identify which native interaction law they satisfy.
- Root navigation must not leak into drilldowns.
- Capture must be composer-first and keyboard-aware.
- Time must orient the user before showing runtime intelligence.
- You must feel like native profile/settings/control/security/appearance, not a runtime manual.
- Empty states must be quiet and useful.

Hard gate:
- A surface fails if the user must decode Ambitions-specific vocabulary before understanding what the screen does.
""",
    )
    print("Verified Batch 28 Native Interaction Truth canon gate.")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
