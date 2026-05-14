#!/usr/bin/env python3
from __future__ import annotations

from itertools import combinations
import re

from ambitions_visual_100_common import read_text, write_json, BASE, REPORT_DIR


REPORT = REPORT_DIR / "visual-100-object-depth.json"
OBJECT_DOCS = [
    BASE / "objects/PRIMARY_OBJECT_ANATOMY_CANON.md",
    BASE / "objects/LABEL_OFF_SIGNATURE_TESTS.md",
    BASE / "objects/REALITY_MERIDIAN_ANATOMY.md",
    BASE / "objects/CONSTELLATION_ATLAS_ANATOMY.md",
    BASE / "objects/ATMOSPHERE_COMPOSER_ANATOMY.md",
    BASE / "objects/LIFESHAPE_FIELD_ANATOMY.md",
    BASE / "objects/USER_SYSTEM_PROFILE_ANATOMY.md",
]
REQUIRED_MARKERS = [
    "ASCII Anatomy",
    "Required Zones",
    "Zone Order",
    "Density Budget",
    "Anti-Generic Failure Examples",
    "Source-Link Status Summary",
    "Label-Off Recognition Criteria",
]


def token_set(text: str) -> set[str]:
    return set(re.findall(r"[a-z0-9]+", text.lower()))


def main() -> int:
    missing = {}
    texts = {}
    for path in OBJECT_DOCS:
        text = read_text(path)
        texts[str(path.relative_to(BASE))] = text
        hits = [marker for marker in REQUIRED_MARKERS if marker not in text]
        if hits:
            missing[str(path.relative_to(BASE))] = hits
    pairwise = []
    for a, b in combinations(OBJECT_DOCS, 2):
        ta = token_set(texts[str(a.relative_to(BASE))])
        tb = token_set(texts[str(b.relative_to(BASE))])
        if not ta or not tb:
            continue
        score = len(ta & tb) / len(ta | tb)
        if score >= 0.82:
            pairwise.append({"a": str(a.relative_to(BASE)), "b": str(b.relative_to(BASE)), "score": round(score, 3)})
    status = "green" if not missing and not pairwise else "red"
    payload = {"missing_markers": missing, "near_duplicates": pairwise, "status": status}
    write_json(REPORT, payload)
    print("PASS" if status == "green" else "FAIL")
    return 0 if status == "green" else 1


if __name__ == "__main__":
    raise SystemExit(main())
