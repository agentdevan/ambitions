import XCTest
@testable import Ambitions

final class ProtectedStepPlacementPolicyTests: XCTestCase {
    private let policy = ProtectedStepPlacementPolicy()
    private let now = Date(timeIntervalSince1970: 1_780_000_000)

    func testAutomaticMoveInsideSevenDaysIsBlockedFromSilentApplication() throws {
        let decision = policy.evaluate(
            now: now,
            stepID: "step-protected",
            originalPlacement: try window(daysFromNow: 1),
            proposedPlacement: try window(daysFromNow: 2),
            trigger: .automatic,
            explicitUserApproval: false,
            automationPolicy: .allowedByExistingPolicy,
            contextQuality: .sufficient,
            localOnly: true
        )

        XCTAssertEqual(decision.kind, .blockedFromSilentMovement)
        XCTAssertTrue(decision.affectsProtectedWindow)
        XCTAssertTrue(decision.requiresExplicitApproval)
        XCTAssertFalse(decision.canApplySilently)
        XCTAssertEqual(decision.requiresAccount, false)
        XCTAssertTrue(decision.blockedFacts.contains { $0.contains("next seven days") })
    }

    func testAutomaticFutureAdjustmentOnlyAppliesWhenExistingPolicyAllowsIt() throws {
        let decision = policy.evaluate(
            now: now,
            stepID: "step-future",
            originalPlacement: try window(daysFromNow: 10),
            proposedPlacement: try window(daysFromNow: 12),
            trigger: .automatic,
            explicitUserApproval: false,
            automationPolicy: .allowedByExistingPolicy,
            contextQuality: .sufficient,
            localOnly: true
        )

        XCTAssertEqual(decision.kind, .allowed)
        XCTAssertFalse(decision.affectsProtectedWindow)
        XCTAssertTrue(decision.canApplySilently)
        XCTAssertEqual(decision.requiresAccount, false)
    }

    func testAutomaticFutureAdjustmentWithoutMaturePolicyIsPendingReview() throws {
        let decision = policy.evaluate(
            now: now,
            stepID: "step-future-review",
            originalPlacement: try window(daysFromNow: 10),
            proposedPlacement: try window(daysFromNow: 12),
            trigger: .automatic,
            explicitUserApproval: false,
            automationPolicy: .notMature,
            contextQuality: .sufficient,
            localOnly: true
        )

        XCTAssertEqual(decision.kind, .pendingReview)
        XCTAssertFalse(decision.canApplySilently)
        XCTAssertTrue(decision.requiresExplicitApproval)
        XCTAssertTrue(decision.degradedFacts.contains { $0.contains("not mature") })
    }

    func testUserInitiatedMoveInsideSevenDaysRequiresExplicitActionAndThenAllows() throws {
        let withoutApproval = policy.evaluate(
            now: now,
            stepID: "step-user",
            originalPlacement: try window(daysFromNow: 2),
            proposedPlacement: try window(daysFromNow: 3),
            trigger: .userInitiated,
            explicitUserApproval: false,
            automationPolicy: .notApplicable,
            contextQuality: .sufficient,
            localOnly: true
        )
        let approved = policy.evaluate(
            now: now,
            stepID: "step-user",
            originalPlacement: try window(daysFromNow: 2),
            proposedPlacement: try window(daysFromNow: 3),
            trigger: .userInitiated,
            explicitUserApproval: true,
            automationPolicy: .notApplicable,
            contextQuality: .sufficient,
            localOnly: true
        )

        XCTAssertEqual(withoutApproval.kind, .requiresExplicitApproval)
        XCTAssertFalse(withoutApproval.canApplySilently)
        XCTAssertEqual(approved.kind, .allowed)
        XCTAssertTrue(approved.canApplyWithExplicitAction)
        XCTAssertFalse(approved.canApplySilently)
    }

    func testMissedRecoveryMoveItIsUserInitiatedAndNonShaming() throws {
        let decision = policy.evaluate(
            now: now,
            stepID: "step-recovery",
            originalPlacement: try window(daysFromNow: -1),
            proposedPlacement: try window(daysFromNow: 1),
            trigger: .missedRecoveryMoveIt,
            explicitUserApproval: true,
            automationPolicy: .notApplicable,
            contextQuality: .sufficient,
            localOnly: true
        )

        XCTAssertEqual(decision.kind, .allowed)
        XCTAssertEqual(decision.trigger, .missedRecoveryMoveIt)
        XCTAssertTrue(decision.userImpactSummary.contains("Move it"))
        XCTAssertTrue(decision.userImpactSummary.contains("What changed?"))
        XCTAssertTrue(decision.userImpactSummary.contains("Still counts"))
        XCTAssertFalse(decision.userImpactSummary.localizedCaseInsensitiveContains("streak"))
        XCTAssertFalse(decision.userImpactSummary.localizedCaseInsensitiveContains("score"))
        XCTAssertFalse(decision.userImpactSummary.localizedCaseInsensitiveContains("failed"))
    }

    func testLowContextAutomationReturnsPendingReviewInsteadOfFakeSuccess() throws {
        let decision = policy.evaluate(
            now: now,
            stepID: "step-low-context",
            originalPlacement: try window(daysFromNow: 10),
            proposedPlacement: try window(daysFromNow: 11),
            trigger: .automatic,
            explicitUserApproval: false,
            automationPolicy: .allowedByExistingPolicy,
            contextQuality: .lowContext,
            localOnly: true
        )

        XCTAssertEqual(decision.kind, .pendingReview)
        XCTAssertFalse(decision.canApplySilently)
        XCTAssertFalse(decision.canApplyWithExplicitAction)
    }

    func testProtectedPlacementStaysLocalAndAccountFree() throws {
        let localDecision = policy.evaluate(
            now: now,
            stepID: "step-local",
            originalPlacement: try window(daysFromNow: 1),
            proposedPlacement: try window(daysFromNow: 2),
            trigger: .userInitiated,
            explicitUserApproval: true,
            automationPolicy: .notApplicable,
            contextQuality: .sufficient,
            localOnly: true
        )
        let nonLocalDecision = policy.evaluate(
            now: now,
            stepID: "step-network",
            originalPlacement: try window(daysFromNow: 1),
            proposedPlacement: try window(daysFromNow: 2),
            trigger: .automatic,
            explicitUserApproval: false,
            automationPolicy: .allowedByExistingPolicy,
            contextQuality: .sufficient,
            localOnly: false
        )

        XCTAssertEqual(localDecision.kind, .allowed)
        XCTAssertEqual(localDecision.requiresAccount, false)
        XCTAssertTrue(localDecision.localOnly)
        XCTAssertEqual(nonLocalDecision.kind, .blockedFromSilentMovement)
        XCTAssertFalse(nonLocalDecision.localOnly)
        XCTAssertTrue(nonLocalDecision.blockedFacts.contains { $0.contains("account") || $0.contains("network") || $0.contains("R2") })
    }

    private func window(
        daysFromNow: Double,
        durationHours: Double = 1,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws -> ProtectedStepPlacementWindow {
        let start = now.addingTimeInterval(daysFromNow * 24 * 60 * 60)
        return try XCTUnwrap(
            ProtectedStepPlacementWindow(
                start: start,
                end: start.addingTimeInterval(durationHours * 60 * 60)
            ),
            file: file,
            line: line
        )
    }
}
