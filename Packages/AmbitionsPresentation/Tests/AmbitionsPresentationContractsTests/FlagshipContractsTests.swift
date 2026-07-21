import Foundation
import XCTest
@testable import AmbitionsPresentationContracts

final class FlagshipContractsTests: XCTestCase {
    func testNavigationAndRestorationRoundTripWithoutLegacyState() throws {
        let restoration = FlagshipRestorationState(
            root: .goals,
            path: [
                .object(kind: "goal", id: "goal.001"),
                .receipt(id: "receipt.001")
            ],
            presentedSheet: .capture(
                FlagshipCaptureDraft(id: "draft.001", text: "Run a marathon")
            ),
            interruptedIntent: nil
        )

        let data = try JSONEncoder().encode(restoration)
        let decoded = try JSONDecoder().decode(
            FlagshipRestorationState.self,
            from: data
        )

        XCTAssertEqual(decoded, restoration)
        XCTAssertEqual(decoded.schemaVersion, 1)
    }

    func testFixtureKeyHasOneCanonicalSurfaceEnvironmentSchemaIdentity() throws {
        let key = FlagshipFixtureKey(
            surface: .today,
            fixture: "needs-a-place",
            environment: .accessibility,
            schemaVersion: 1
        )

        XCTAssertEqual(
            key.rawValue,
            "today/needs-a-place/accessibility/v1"
        )
        XCTAssertEqual(try FlagshipFixtureKey(rawValue: key.rawValue), key)
        XCTAssertThrowsError(
            try FlagshipFixtureKey(rawValue: "today/unknown")
        )
    }

    func testIntentResultDistinguishesEveryCanonicalAndEffectState() {
        let receipt = FlagshipReceiptReference(
            id: "receipt.001",
            projectionCursors: ["today": "cursor.1"],
            recoveryAction: nil,
            semanticUndoEligible: true
        )
        let results: [FlagshipIntentResult] = [
            .committedProjectionReady(receipt),
            .committedCatchUpRequired(receipt),
            .rejectedBeforeMutation(
                code: "invalid",
                recoveryAction: .editIntent
            ),
            .revisionConflict(
                expected: 1,
                actual: 2,
                recoveryAction: .refreshAndRetry
            ),
            .externalEffectPending(receipt, effectIDs: ["effect.1"]),
            .externalEffectReconciled(receipt, effectIDs: ["effect.1"]),
            .externalEffectFailed(
                receipt,
                effectIDs: ["effect.1"],
                recoveryAction: .retryExternalEffect
            )
        ]

        XCTAssertEqual(Set(results.map(\.state)), Set(FlagshipIntentState.allCases))
    }

    func testProjectionEnvelopeCarriesCursorAndDegradedState() throws {
        let envelope = FlagshipProjectionEnvelope(
            request: .root(.today),
            cursor: "cursor.12",
            generatedAt: Date(timeIntervalSince1970: 12),
            state: .degraded(
                FlagshipDegradedState(
                    reason: .projectionCatchUp,
                    message: "Updating Today",
                    recoveryAction: .waitForProjection
                )
            )
        )

        let data = try JSONEncoder().encode(envelope)
        XCTAssertEqual(
            try JSONDecoder().decode(FlagshipProjectionEnvelope.self, from: data),
            envelope
        )
    }
}
