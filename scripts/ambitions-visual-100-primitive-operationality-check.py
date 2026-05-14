#!/usr/bin/env python3
from __future__ import annotations

from ambitions_visual_100_common import BASE, read_text, write_json, REPORT_DIR


REPORT = REPORT_DIR / "visual-100-primitive-operationality.json"
PRIMITIVE_DOCS = [
    "primitives/TRUST_SEAM.md",
    "primitives/PROOF_PRIMITIVES.md",
    "primitives/LOCAL_RUNTIME_PRIMITIVES.md",
    "primitives/PRESSURE_AND_CAPACITY_PRIMITIVES.md",
    "primitives/MATERIAL_PRIMITIVE_ROLES.md",
    "primitives/SOURCE_FRESHNESS_PRIMITIVES.md",
    "primitives/RECEIPT_PRIMITIVES.md",
    "primitives/PROTECTED_TIME_PRIMITIVES.md",
    "primitives/TRANSACTION_PRIMITIVES.md",
    "primitives/VOICEOVER_ORDER_PRIMITIVES.md",
    "primitives/DYNAMIC_TYPE_COLLAPSE_PRIMITIVES.md",
    "primitives/ADHD_DENSITY_PRIMITIVES.md",
]
REQUIRED = ["Purpose", "Allowed Use", "Forbidden Use", "Canonical Anatomy", "State Variants", "Accessibility Fallback", "Misuse Examples", "Recipe Examples", "Validator Hooks"]


def main() -> int:
    missing = {}
    for rel in PRIMITIVE_DOCS:
        text = read_text(BASE / rel)
        hits = [marker for marker in REQUIRED if marker not in text]
        if hits:
            missing[rel] = hits
    status = "green" if not missing else "red"
    write_json(REPORT, {"missing": missing, "status": status})
    print("PASS" if status == "green" else "FAIL")
    return 0 if status == "green" else 1


if __name__ == "__main__":
    raise SystemExit(main())
