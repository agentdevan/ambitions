#!/usr/bin/env python3
from __future__ import annotations

from itertools import combinations
import re

from ambitions_visual_100_common import BASE, read_text, section_has_depth, section_text, write_json, REPORT_DIR


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

LABEL_OFF_DOC = BASE / "objects/LABEL_OFF_SIGNATURE_TESTS.md"
PRIMARY_OBJECT_CANON = BASE / "objects/PRIMARY_OBJECT_ANATOMY_CANON.md"

ANCHORS = {
    "REALITY_MERIDIAN_ANATOMY.md": [
        "Start Here",
        "Now / Next / Later",
        "source / proof seam",
        "task-list failure",
    ],
    "CONSTELLATION_ATLAS_ANATOMY.md": [
        "life-area equality",
        "thread-to-Today",
        "proof density",
        "blocker / waiting",
        "pivot / proof transfer",
    ],
    "ATMOSPHERE_COMPOSER_ANATOMY.md": [
        "bottom-native composer",
        "no feed at rest",
        "no chat bubbles",
        "three-route cap",
        "Held With Dignity",
        "re-place wrong-route recovery",
    ],
    "LIFESHAPE_FIELD_ANATOMY.md": [
        "non-calendar capacity geometry",
        "day/week/month grammar",
        "vacation/away override",
        "no calendar clone",
    ],
    "USER_SYSTEM_PROFILE_ANATOMY.md": [
        "Personal Runtime hero",
        "local runtime trust panel",
        "privacy plain language",
        "no settings clone",
    ],
}


def token_set(text: str) -> set[str]:
    return set(re.findall(r"[a-z0-9]+", text.lower()))


def main() -> int:
    missing = {}
    texts = {}
    label_off = {"missing": [], "pass_count": 0}
    for path in OBJECT_DOCS:
        text = read_text(path)
        texts[str(path.relative_to(BASE))] = text
        hits = [marker for marker in REQUIRED_MARKERS if marker not in text]
        anchor_hits = [anchor for anchor in ANCHORS.get(path.name, []) if anchor.lower() not in text.lower()]
        if anchor_hits:
            hits.extend([f"anchor:{anchor}" for anchor in anchor_hits])
        if path.name != "PRIMARY_OBJECT_ANATOMY_CANON.md" and not section_has_depth(text, "Label-Off Visual Signature", min_nonempty_lines=2, min_words=20):
            hits.append("Label-Off Visual Signature depth")
        if hits:
            missing[str(path.relative_to(BASE))] = hits
        else:
            label_off["pass_count"] += 1
    label_off_text = read_text(LABEL_OFF_DOC)
    if not section_text(label_off_text, "Test Method") or not section_text(label_off_text, "Pass Criteria"):
        label_off["missing"].append("signature test criteria")
    if not section_text(label_off_text, "Fail Criteria") or not section_text(label_off_text, "Required Coverage"):
        label_off["missing"].append("signature test coverage")
    pairwise = []
    for a, b in combinations(OBJECT_DOCS, 2):
        ta = token_set(texts[str(a.relative_to(BASE))])
        tb = token_set(texts[str(b.relative_to(BASE))])
        if not ta or not tb:
            continue
        score = len(ta & tb) / len(ta | tb)
        if score >= 0.82:
            pairwise.append({"a": str(a.relative_to(BASE)), "b": str(b.relative_to(BASE)), "score": round(score, 3)})
    status = "green" if not missing and not pairwise and not label_off["missing"] else "red"
    payload = {"missing_markers": missing, "near_duplicates": pairwise, "label_off": label_off, "status": status}
    write_json(REPORT, payload)
    print("PASS" if status == "green" else "FAIL")
    return 0 if status == "green" else 1


if __name__ == "__main__":
    raise SystemExit(main())
