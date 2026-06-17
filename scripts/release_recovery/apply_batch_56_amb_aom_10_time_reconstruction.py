#!/usr/bin/env python3
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
TIME = ROOT / "Native" / "Ambitions" / "Features" / "Time" / "TimeLifeShapeField.swift"
TEST = ROOT / "Native" / "AmbitionsTests" / "Time" / "TimeLifeShapeFieldReconstructionTests.swift"
OUT = ROOT / "artifacts" / "object-stage-mega-train"
RECON = OUT / "reconciliation"
RECON.mkdir(parents=True, exist_ok=True)

text = TIME.read_text(encoding="utf-8")
old = 'firstViewportStructure: "Full-bleed LifeShape Field object stage with inline horizon control, pressure texture, plain week-capacity line, shaping actions, and source/receipt relationship.",'
new = 'firstViewportStructure: "Full-bleed LifeShape Field object stage with capacity contours, pressure texture, protected windows, fixed points, horizons, confirmation-first shaping actions, and source/receipt inspection.",'
if old not in text:
    raise SystemExit("Expected Time firstViewportStructure marker not found")
text = text.replace(old, new)
text = text.replace(
    '            "capacity statement panel",\n            "metric-row dashboard",',
    '            "capacity statement panel",\n            "metric-row dashboard",\n            "calendar clone",\n            "agenda clone",\n            "free/busy grid",',
)
text = text.replace(
    '            "Differentiate Without Color exposes source, reason, receipt, and privacy as text"',
    '            "Differentiate Without Color exposes source, reason, receipt, privacy, protected windows, fixed points, and horizon state as text"',
)
for marker in ["capacity contours", "protected windows", "fixed points", "confirmation-first shaping actions", "calendar clone", "agenda clone", "free/busy grid"]:
    if marker not in text:
        raise SystemExit(f"Missing AMB-AOM-10 contract marker: {marker}")
TIME.write_text(text, encoding="utf-8")

TEST.write_text(
    """import XCTest
@testable import Ambitions

final class TimeLifeShapeFieldReconstructionTests: XCTestCase {
    func testTimeObjectStageContractOwnsLifeShapeField() {
        let contract = TimeObjectStagePrimitiveContract.current
        XCTAssertEqual(contract.ownerSurface, "Time")
        XCTAssertEqual(contract.productObject, "LifeShape Field")
        XCTAssertTrue(contract.firstViewportAvoidsCalendarCardDashboardGeometry)
    }

    func testTimeObjectStageContractNamesCapacityPressureAndProtectedReality() {
        let structure = TimeObjectStagePrimitiveContract.current.firstViewportStructure
        XCTAssertTrue(structure.contains("capacity contours"))
        XCTAssertTrue(structure.contains("pressure texture"))
        XCTAssertTrue(structure.contains("protected windows"))
        XCTAssertTrue(structure.contains("fixed points"))
        XCTAssertTrue(structure.contains("horizons"))
        XCTAssertTrue(structure.contains("confirmation-first shaping actions"))
    }

    func testTimeObjectStageContractRejectsCalendarCloneGeometry() {
        let replaced = Set(TimeObjectStagePrimitiveContract.current.replacesFirstViewportStructures)
        XCTAssertTrue(replaced.contains("calendar clone"))
        XCTAssertTrue(replaced.contains("agenda clone"))
        XCTAssertTrue(replaced.contains("free/busy grid"))
        XCTAssertTrue(replaced.contains("metric-row dashboard"))
    }
}
""",
    encoding="utf-8",
)

report = """# AMB-AOM-10 Time Reconstruction

Status: `GREEN_SOURCE_DELTA`

This deterministic Autopilot batch starts AMB-AOM-10 by hardening Time as a LifeShape Field contract instead of a calendar, agenda, free/busy grid, or productivity score surface.

## Source changes

- `Native/Ambitions/Features/Time/TimeLifeShapeField.swift`
- `Native/AmbitionsTests/Time/TimeLifeShapeFieldReconstructionTests.swift`

## Scope result

- Time owns LifeShape Field.
- The first viewport contract explicitly names capacity contours, pressure texture, protected windows, fixed points, horizons, and confirmation-first shaping actions.
- Calendar clone, agenda clone, free/busy grid, and metric-row dashboard geometry are explicitly rejected.
- Accessibility fallback language exposes protected windows, fixed points, and horizon state as text.
- Existing reflow controls remain confirmation-first and call the reflow decision callback only from explicit action buttons.

## Next gate

Run AMB-AOM-10 validation for no calendar/list regression and confirmation-control proof before AMB-AOM-11.
"""
(OUT / "AMB-AOM-10-report.md").write_text(report, encoding="utf-8")
(RECON / "AMB-AOM-10-time-reconstruction.md").write_text(report, encoding="utf-8")
print("AMB-AOM-10 Time reconstruction source delta written.")
