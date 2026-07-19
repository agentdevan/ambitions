import XCTest
@testable import Ambitions

final class ProtectionEngineTests: XCTestCase {
    func testProtectionUsesExplicitDefaultsCorrectionsAndNonNegotiableFixedPointsOnly() {
        let explicit = boundary(id: "explicit", kind: .explicit, startMinute: 60, endMinute: 90)
        let sleep = boundary(id: "sleep", kind: .sleep, startMinute: 0, endMinute: 45)
        let keepClear = boundary(id: "keep-clear", kind: .keepClearCorrection, startMinute: 180, endMinute: 220)
        let negotiableFixed = fixed(id: "movable", startMinute: 240, endMinute: 270, nonNegotiable: false)
        let nonNegotiableFixed = fixed(id: "non-negotiable", startMinute: 300, endMinute: 360, nonNegotiable: true)

        let projection = ProtectionEngine().project(ProtectionEngineInput(
            explicitProtectedBoundaries: [explicit],
            sleepAwayVacationDefaults: [sleep],
            fixedCommitments: [negotiableFixed, nonNegotiableFixed],
            keepClearCorrections: [keepClear]
        ))

        XCTAssertEqual(
            projection.protectedBoundaries.map(\.kind),
            [.sleep, .explicit, .keepClearCorrection, .fixedCommitment]
        )
        XCTAssertFalse(projection.protectedBoundaries.contains { $0.id.contains("movable") })
        XCTAssertTrue(projection.derivation.ruleIDs.map(\.rawValue).contains("lifeshape.protected.explicit-only"))
        XCTAssertTrue(projection.accessibilitySummary.contains("protected boundary"))
    }

    func testNoProtectedInputsProducesNoBoundaryAndNoVibeInference() {
        let projection = ProtectionEngine().project(ProtectionEngineInput())

        XCTAssertTrue(projection.protectedBoundaries.isEmpty)
        XCTAssertEqual(projection.derivation.inputRefs.first?.id, "lifeshape.protection.none")
        XCTAssertEqual(projection.semanticSummary, "No protected boundary is marked yet.")
    }

    private var base: Date {
        Date(timeIntervalSince1970: 1_800_000_000)
    }

    private func boundary(id: String, kind: ProtectedBoundaryKind, startMinute: Int, endMinute: Int) -> ProtectedBoundary {
        ProtectedBoundary(
            id: id,
            title: id,
            start: base.addingTimeInterval(TimeInterval(startMinute * 60)),
            end: base.addingTimeInterval(TimeInterval(endMinute * 60)),
            reason: "Explicit protected input.",
            kind: kind,
            inputRef: LifeShapeInputRef(id: id, kind: .protectedBoundary, label: id)
        )
    }

    private func fixed(id: String, startMinute: Int, endMinute: Int, nonNegotiable: Bool) -> FixedPoint {
        FixedPoint(
            id: id,
            title: id,
            start: base.addingTimeInterval(TimeInterval(startMinute * 60)),
            end: base.addingTimeInterval(TimeInterval(endMinute * 60)),
            isNonNegotiable: nonNegotiable,
            inputRef: LifeShapeInputRef(id: id, kind: .fixedPoint, label: id)
        )
    }
}
