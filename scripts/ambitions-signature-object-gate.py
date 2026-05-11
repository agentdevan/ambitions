#!/usr/bin/env python3
"""Verify Signature Object documentation covers moat-critical objects and anti-patterns."""

from __future__ import annotations

from pathlib import Path
import sys


ROOT = Path(__file__).resolve().parents[1]

SIGNATURE_FILE = ROOT / "docs/AmbitionsCanon/03_Signature_Object_Specs.md"
PRODUCT_CANON_GAP = ROOT / "docs/AmbitionsCanon/17_Ambitions_Product_Grammar.md"

REQUIRED_OBJECTS = [
    "Reality Meridian",
    "Atmosphere Composer",
    "LifeShape Field",
    "Constellation Atlas",
    "Orbital Lens",
    "User System Profile",
    "Start Here Surface",
]

REQUIRED_SOFT_REQUIREMENTS = [
    "Hard Red",
    "Proof",
    "Recovery",
    "Trust Seam",
    "Accessibility",
    "Preview Fixtures",
]


def _contains_all_terms(path: Path, terms: list[str]) -> list[str]:
    text = path.read_text(encoding="utf-8").lower()
    missing = [term for term in terms if term.lower() not in text]
    return missing


def main() -> int:
    errors: list[str] = []

    for path in (SIGNATURE_FILE, PRODUCT_CANON_GAP):
        if not path.exists():
            errors.append(f"missing required file: {path}")
            continue

    if SIGNATURE_FILE.exists():
        missing_objects = _contains_all_terms(SIGNATURE_FILE, REQUIRED_OBJECTS)
        if missing_objects:
            errors.extend(f"signature spec missing required object term: {term}" for term in missing_objects)

        missing_requirements = _contains_all_terms(SIGNATURE_FILE, REQUIRED_SOFT_REQUIREMENTS)
        if missing_requirements:
            errors.extend(f"signature spec missing required documentation area: {requirement}" for requirement in missing_requirements)

    if PRODUCT_CANON_GAP.exists():
        gap_text = PRODUCT_CANON_GAP.read_text(encoding="utf-8").lower()
        for requirement in ("closure", "recovery", "proof", "recommend", "still counts", "time"):
            if requirement not in gap_text:
                errors.append(f"product grammar gap map does not document required area: {requirement}")

    print("# Signature Object Gate")
    if errors:
        for error in errors:
            print(f"RED: {error}", file=sys.stderr)
        return 1
    print("GREEN: signature-object moat coverage and anti-pattern documentation present")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
