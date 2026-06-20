@testable import Ambitions
import Foundation
import XCTest

final class CoreDomainCanonicalOwnershipTests: XCTestCase {
    func testCanonicalCoreDomainOwnerFilesExist() {
        let root = repoRoot()
        for requiredPath in [
            "Native/Ambitions/Core/Domain/Step.swift",
            "Native/Ambitions/Core/Domain/GoalThread.swift",
            "Native/Ambitions/Core/Domain/LifeArea.swift",
            "Native/Ambitions/Core/Domain/RealityWindow.swift",
            "Native/Ambitions/Core/Domain/CapacityShape.swift",
            "Native/Ambitions/Core/Domain/CaptureIntake.swift",
            "Native/Ambitions/Core/Domain/ClosureOutcome.swift",
            "Native/Ambitions/Core/Domain/ProofEvent.swift",
            "Native/Ambitions/Core/Domain/RecoveryState.swift",
            "Native/Ambitions/Core/Domain/UserSystemProfile.swift",
        ] {
            XCTAssertTrue(
                FileManager.default.fileExists(atPath: root.appendingPathComponent(requiredPath).path),
                "Missing canonical Core/Domain owner: \(requiredPath)"
            )
        }
    }

    func testStepOwnsExecutableDomainContract() {
        let step = Step(
            id: "step-start",
            sectionID: "section-active",
            title: "Open step",
            summary: "Start the smallest reviewable action.",
            type: .actionUnit,
            state: .active,
            owner: GoalActor(actorID: "user", displayName: "User", ownership: .self, roleLabel: nil, isPrimary: true),
            timing: GoalTiming(
                tempo: .ongoing,
                timingType: .suggestedNext,
                startsOn: nil,
                dueAt: nil,
                targetBy: nil,
                windowStart: nil,
                windowEnd: nil,
                suggestedNextAt: "2026-04-15T12:00:00.000Z",
                repeatEveryDays: nil,
                progressReviewCadenceDays: nil
            ),
            dependencyStepIDs: ["blocked-by-proof"],
            isOptional: false,
            isRepeatable: false,
            evidenceRequired: true,
            successSignals: ["proof attached"],
            actionability: StepActionability(
                action: "Start now",
                completionDefinition: "The first proof-backed action is done.",
                evidenceOfCompletion: ["receipt"],
                fallbackMicroStep: "Open the source.",
                contextRequirements: ["quiet room"]
            )
        )

        XCTAssertEqual(step.id, "step-start")
        XCTAssertEqual(step.actionability.fallbackMicroStep, "Open the source.")
        XCTAssertTrue(step.evidenceRequired)
    }

    func testGoalThreadKeepsStableUniqueGoalIDs() {
        let thread = GoalThread(
            id: "thread-career",
            ambitionID: "ambition-1",
            lifeAreaID: "career",
            name: "Career thread",
            goalIDs: ["goal-b", "goal-a", "goal-b"],
            createdAt: "2026-04-15T12:00:00.000Z",
            updatedAt: "2026-04-15T12:00:00.000Z"
        )

        XCTAssertEqual(thread.goalIDs, ["goal-b", "goal-a"])
        XCTAssertTrue(thread.isActive)
    }

    func testLifeAreaOwnsCanonicalIdentityAndDefinitionBridge() {
        let career = LifeArea.canonical.first { $0.domainKey == .career }
        let definition = LifeAreaDefinition.canonical.first { $0.domainKey == .career }

        XCTAssertEqual(career?.id, LifeAreaID(domain: .career))
        XCTAssertEqual(career?.displayName, "Career")
        XCTAssertEqual(definition?.id, career?.id)
        XCTAssertEqual(definition?.canonicalOrder, career?.canonicalOrder)
    }

    func testRealityWindowOwnsLocalPrivacyAndDurationContract() throws {
        let start = try XCTUnwrap(DomainTimestamp.date(from: "2026-04-15T12:00:00.000Z"))
        let end = try XCTUnwrap(DomainTimestamp.date(from: "2026-04-15T13:30:00.000Z"))
        let window = RealityWindow(
            id: "calendar-window",
            kind: .calendarDerivedBusy,
            source: .calendarDerived,
            start: start,
            end: end,
            title: "Calendar block",
            eventLedgerEntryIDs: ["event-2", "event-1", "event-2"]
        )

        XCTAssertEqual(window.durationMinutes, 90)
        XCTAssertTrue(window.isCalendarDerived)
        XCTAssertTrue(window.localOnly)
        XCTAssertEqual(window.privacy, .calendarDerived)
        XCTAssertEqual(window.eventLedgerEntryIDs, ["event-1", "event-2"])
    }

    func testCapacityEstimateDerivesCapacityShape() {
        let estimate = CapacityEstimate(
            openMinutes: 180,
            totalOpenMinutes: 220,
            protectedMinutes: 40,
            vacationAwayMinutes: 0,
            blockedBusyMinutes: 20,
            blockedMinutes: 20,
            flexibleMinutes: 60,
            scheduledAmbitionsMinutes: 30,
            calendarBusyMinutes: 10,
            timeFitProofSummary: "Open room exists.",
            deadlineFitProofSummary: "Deadline can fit.",
            capacityLevel: .moderate,
            summary: "Enough room for one believable step.",
            localOnly: true,
            privacy: .standard
        )

        XCTAssertEqual(estimate.shape.openMinutes, 180)
        XCTAssertEqual(estimate.shape.pressureLevel, .moderate)
        XCTAssertTrue(estimate.shape.hasBreathingRoom)
    }

    func testCaptureIntakeOwnsRoutingReviewAndPrivacyContract() {
        let capture = Capture(
            id: "capture-proof",
            createdAt: "2026-04-15T12:00:00.000Z",
            updatedAt: "2026-04-15T12:00:00.000Z",
            rawText: "Finished the draft",
            sourceType: .shellComposer,
            status: .actionable,
            linkedGoalID: "goal-writing",
            kind: .goalSupportingTask,
            route: .proofItem,
            triageStatus: .assumedRoute,
            deadlineText: "Friday",
            privacy: .privateUserText
        )

        let intake = capture.intake

        XCTAssertEqual(intake.text, "Finished the draft")
        XCTAssertEqual(intake.goalIntent, "goal-writing")
        XCTAssertEqual(intake.proofIntent, "Finished the draft")
        XCTAssertTrue(intake.needsReview)
        XCTAssertEqual(intake.privacyClassification, .privateUserText)
    }

    func testClosureOutcomeOwnsDefaultAndAdvancedOptions() {
        XCTAssertEqual(ClosureOutcome.defaultOptions.map(\.title), [
            "Done",
            "Still counts",
            "Move it",
            "Blocked",
            "Not needed"
        ])
        XCTAssertTrue(ClosureOutcome.advancedOptions.map(\.title).contains("Needs recovery"))
        XCTAssertEqual(ClosureOutcome.defaultOptions.first?.proofEventKind, .closure)
        XCTAssertEqual(ClosureOutcome.defaultOptions.first?.osClosureOutcome, .completed)
    }

    func testProofEventOwnsProofProjectionContract() {
        let proof = Proof(
            id: "proof-1",
            ambitionID: "ambition-1",
            goalThreadID: "thread-1",
            commitmentID: "commitment-1",
            closureEventID: "closure-1",
            proofType: .text,
            text: "The smallest useful draft shipped.",
            source: "User",
            userConfirmed: true,
            createdAt: "2026-04-15T12:00:00.000Z"
        )

        let event = proof.proofEvent

        XCTAssertEqual(event.kind, .closure)
        XCTAssertTrue(event.isUsableForRecommendation)
        XCTAssertEqual(event.summary, "The smallest useful draft shipped.")
    }

    func testRecoveryStateOwnsThreadSummaryContract() {
        let thread = RecoveryThread(
            id: "recovery-1",
            ambitionID: "ambition-1",
            goalThreadID: "thread-1",
            trigger: "Reality changed",
            priorProofRefs: ["proof-b", "proof-a", "proof-b"],
            whatChanged: "Calendar conflict",
            status: .stalled,
            createdAt: "2026-04-15T12:00:00.000Z",
            updatedAt: "2026-04-15T12:00:00.000Z"
        )

        let recovery = thread.recoveryState

        XCTAssertEqual(recovery.state, .needsRecovery)
        XCTAssertEqual(recovery.proofEventIDs, ["proof-b", "proof-a"])
        XCTAssertTrue(recovery.needsVisibleRecovery)
    }

    func testUserSystemProfileOwnsInspectableSummaryContract() {
        let profile = UserSystemProfile(
            displayName: "Devan's System",
            planningDefaults: ["Schedule availability"],
            notificationPreferences: ["Notifications allowed"],
            appearancePreferences: ["System"],
            privacyPreferences: ["Stored on this device"],
            permissions: ["Calendar: Review"],
            connectedSources: ["What Ambitions Knows"],
            historyPreferences: ["Local learning"],
            exportSharePreferences: ["Export"],
            securityControls: ["Trust Center"],
            localAuthenticationSettings: ["Reset controls"],
            accountState: "Local-only",
            referencePackState: "Not connected"
        )

        XCTAssertTrue(profile.inspectionSummary.contains("User System Profile"))
        XCTAssertTrue(profile.inspectionSummary.contains("Schedule availability"))
        XCTAssertTrue(profile.inspectionSummary.contains("Source, receipt, and reason"))
    }

    private func repoRoot() -> URL {
        var url = URL(fileURLWithPath: #filePath)
        while url.pathComponents.count > 1 {
            let candidate = url.appendingPathComponent("Native/Ambitions/Core/Domain")
            if FileManager.default.fileExists(atPath: candidate.path) {
                return url
            }
            url.deleteLastPathComponent()
        }
        return URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    }
}
