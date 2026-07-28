#!/usr/bin/env python3
"""Write and validate the still-only R13 Native Foundry evidence manifests."""

from __future__ import annotations

import argparse
import hashlib
import json
import struct
from pathlib import Path


ROOT = Path(__file__).resolve().parent
SCREENSHOTS = ROOT / "screenshots"
CONTACT_SHEETS = ROOT / "contact-sheets"
REFERENCES = ROOT / "owner-references"

EXPECTED_SCREENSHOTS = [
    "R13-F01-today-root-light.png",
    "R13-F02-today-root-dark.png",
    "R13-F03-natural-scroll.png",
    "R13-F04-dock-expanded.png",
    "R13-F05-adaptive-navigation.png",
    "R13-F06-focused-step.png",
    "R13-F07-consequential-review.png",
    "R13-F08-saving.png",
    "R13-F09-settlement.png",
    "R13-F10-returned-today.png",
    "R13-F11-full-day.png",
    "R13-F12-interrupted-step.png",
    "R13-F13-recovery-sheet.png",
    "R13-D01-goal-detail.png",
    "R13-D02-time-transfer.png",
    "R13-D03-consequence-details.png",
    "R13-D04-local-history-entry.png",
    "R13-D05-history-filters.png",
    "R13-D06-offline-mode.png",
    "R13-D07-stale-context.png",
    "R13-D08-undo-available.png",
    "R13-D09-failed-settlement.png",
    "R13-D11-cancelled-unchanged.png",
    "R13-A01-accessibility-root.png",
    "R13-A02-accessibility-review.png",
    "R13-A03-increased-contrast.png",
    "R13-A04-differentiate-without-color.png",
    "R13-A05-reduce-transparency.png",
    "R13-A06-reduce-motion.png",
    "R13-L01-long-root.png",
    "R13-L02-long-focused.png",
    "R13-Q01-quiet-day.png",
    "R13-N01-dense-day.png",
    "R13-N02-very-dense-day.png",
    "R13-DK01-low-brightness-dark.png",
    "R13-CI01-compact-iphone.png",
    "R13-PM01-pro-max.png",
]

EXPECTED_CONTACT_SHEETS = [
    "R13-C01-full-matrix.png",
    "R13-C02-b02-comparison.png",
    "R13-C03-owner-reference-translation.png",
    "R13-C04-accessibility-transformations.png",
]

EXPECTED_REFERENCES = [
    "R13-REF-ROOT.jpg",
    "R13-REF-FOCUSED.jpg",
    "R13-REF-REVIEW.jpg",
    "R13-REF-SAVING.jpg",
    "R13-REF-SETTLEMENT.jpg",
    "R13-REF-RETURNED.jpg",
    "R13-REF-FULL-DAY.jpg",
    "R13-REF-RECOVERY.jpg",
]


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def png_dimensions(path: Path) -> tuple[int, int]:
    with path.open("rb") as handle:
        signature = handle.read(24)
    if signature[:8] != b"\x89PNG\r\n\x1a\n":
        raise ValueError(f"not a PNG: {path}")
    return struct.unpack(">II", signature[16:24])


def device_for(filename: str) -> dict[str, str]:
    if "CI01" in filename:
        return {"name": "iPhone 17e", "udid": "0BA18BA4-EFB6-483E-8318-FF344741F8DE"}
    if any(token in filename for token in ("PM01", "F04", "F07", "F08", "D11")):
        return {"name": "iPhone 17 Pro Max", "udid": "E6B10AFA-E54B-45F3-B3C2-A864AB632090"}
    return {"name": "iPhone 17 Pro", "udid": "396F4B4A-2DAD-4345-B26E-ABD2EF69BF5E"}


def settings_for(filename: str) -> list[str]:
    settings: list[str] = []
    if any(token in filename for token in ("F05", "A01", "A02")):
        settings.append("Accessibility Dynamic Type 5")
    if "A03" in filename:
        settings.append("Increased Contrast")
    if "A04" in filename:
        settings.append("Differentiate Without Color")
    if "A05" in filename:
        settings.append("Reduce Transparency")
    if "A06" in filename:
        settings.append("Reduce Motion")
    if "DK01" in filename:
        settings.append("low-brightness visual inspection reference")
    return settings or ["standard evaluation settings"]


def screenshot_records() -> list[dict[str, object]]:
    records = []
    for filename in EXPECTED_SCREENSHOTS:
        path = SCREENSHOTS / filename
        width, height = png_dimensions(path)
        records.append(
            {
                "id": filename.removesuffix(".png"),
                "path": f"screenshots/{filename}",
                "sha256": sha256(path),
                "width": width,
                "height": height,
                "device": device_for(filename),
                "os": "iOS 26.5",
                "locale": "en-US",
                "layout_direction": "left-to-right",
                "accessibility_settings": settings_for(filename),
                "fixture_id": "today-flagship/preparing-for-baby/still-counts/v1",
                "branch_sha": "fa648ff1e1a5d9b07a9acab8645cd3b4ad82735a",
                "evaluation_reference": True,
                "production_baseline": False,
            }
        )
    return records


def comparison_records() -> list[dict[str, object]]:
    return [
        {
            "id": filename.removesuffix(".png"),
            "path": f"contact-sheets/{filename}",
            "sha256": sha256(CONTACT_SHEETS / filename),
            "production_baseline": False,
        }
        for filename in EXPECTED_CONTACT_SHEETS
    ]


def reference_records() -> list[dict[str, str]]:
    return [
        {
            "id": filename.removesuffix(".jpg"),
            "path": f"owner-references/{filename}",
            "sha256": sha256(REFERENCES / filename),
        }
        for filename in EXPECTED_REFERENCES
    ]


def write_manifests() -> None:
    manifests = {
        "screenshot-metadata.json": {
            "schema_version": 1,
            "production_baseline": False,
            "screenshots": screenshot_records(),
        },
        "comparison-metadata.json": {
            "schema_version": 1,
            "production_baseline": False,
            "contact_sheets": comparison_records(),
        },
        "reference-hashes.json": {
            "schema_version": 1,
            "references": reference_records(),
        },
    }
    for filename, payload in manifests.items():
        (ROOT / filename).write_text(json.dumps(payload, indent=2) + "\n")


def validate() -> None:
    actual_screenshots = sorted(path.name for path in SCREENSHOTS.glob("*.png"))
    assert actual_screenshots == sorted(EXPECTED_SCREENSHOTS), "screenshot inventory mismatch"
    actual_sheets = sorted(path.name for path in CONTACT_SHEETS.glob("*.png"))
    assert actual_sheets == sorted(EXPECTED_CONTACT_SHEETS), "contact-sheet inventory mismatch"
    actual_references = sorted(path.name for path in REFERENCES.glob("*.jpg"))
    assert actual_references == sorted(EXPECTED_REFERENCES), "reference inventory mismatch"

    screenshot_manifest = json.loads((ROOT / "screenshot-metadata.json").read_text())
    comparison_manifest = json.loads((ROOT / "comparison-metadata.json").read_text())
    reference_manifest = json.loads((ROOT / "reference-hashes.json").read_text())
    assert screenshot_manifest == {
        "schema_version": 1,
        "production_baseline": False,
        "screenshots": screenshot_records(),
    }
    assert comparison_manifest == {
        "schema_version": 1,
        "production_baseline": False,
        "contact_sheets": comparison_records(),
    }
    assert reference_manifest == {"schema_version": 1, "references": reference_records()}

    prohibited = [path for path in ROOT.rglob("*") if path.is_file() and "recording" in path.name.lower()]
    assert prohibited == [], f"recording artifacts are prohibited: {prohibited}"
    assert not any(path.suffix.lower() in {".mp4", ".mov", ".m4v"} for path in ROOT.rglob("*"))
    print(f"validated {len(EXPECTED_SCREENSHOTS)} screenshots, {len(EXPECTED_CONTACT_SHEETS)} contact sheets, and {len(EXPECTED_REFERENCES)} owner references")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--write", action="store_true")
    args = parser.parse_args()
    if args.write:
        write_manifests()
    validate()


if __name__ == "__main__":
    main()
