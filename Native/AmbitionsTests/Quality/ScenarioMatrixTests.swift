import XCTest
@testable import Ambitions

@MainActor
final class ScenarioMatrixTests: XCTestCase {
    func testScenarioMatrixCoversCanonicalSurfacesAndRequiredStates() {
        XCTAssertEqual(ScenarioMatrix.validate(), [])
        XCTAssertEqual(
            ScenarioCatalog.surfaces.filter(\.isPersistentRoot),
            [.today, .goals, .time, .you]
        )
        XCTAssertFalse(ScenarioCatalog.surfaces.filter(\.isPersistentRoot).contains(.captureComposer))
        XCTAssertFalse(ScenarioCatalog.surfaces.filter(\.isPersistentRoot).contains(.stageMotion))
        XCTAssertEqual(ScenarioCatalog.requiredSurfaceStates, RuntimeScenarioState.allCases)
        XCTAssertEqual(ScenarioCatalog.requiredAccessibilityModes, RuntimeScenarioAccessibilityMode.allCases)
        XCTAssertEqual(ScenarioCatalog.requiredDeviceContexts, RuntimeScenarioDeviceContext.allCases)
    }

    func testPostMutationScenarioRowsRequireFullMeaningfulActionProof() {
        let proofSteps = Set(ScenarioCatalog.proofStepsForMeaningfulAction)
        XCTAssertEqual(proofSteps, Set(RuntimeScenarioProofStep.allCases))

        for surface in ScenarioCatalog.surfaces {
            let rows = ScenarioCatalog.previewMatrix.filter { $0.surface == surface && $0.state == .postMutation }
            XCTAssertTrue(rows.contains { Set($0.requiredProof) == proofSteps }, "\(surface.rawValue) needs full proof coverage.")
        }
    }

    func testCanonicalScenarioOwnersFeedPreviewMatrix() {
        let ownerRows: [(String, [RuntimeScenario])] = [
            ("YouScenarios", YouScenarios.all),
            ("CaptureScenarios", CaptureScenarios.all),
            ("SearchScenarios", SearchScenarios.all),
            ("ClosureScenarios", ClosureScenarios.all),
            ("InspectionScenarios", InspectionScenarios.all),
            ("StageMotionScenarios", StageMotionScenarios.all),
            ("CrossSurfaceMotionScenarios", CrossSurfaceMotionScenarios.all),
            ("PostMutationMotionScenarios", PostMutationMotionScenarios.all),
            ("RecoveryMotionScenarios", RecoveryMotionScenarios.all),
            ("AccessibilityScenarios", AccessibilityScenarios.all),
            ("BrokenSourceScenarios", BrokenSourceScenarios.all),
            ("EmptyStateScenarios", EmptyStateScenarios.all),
            ("DenseStateScenarios", DenseStateScenarios.all),
            ("PostMutationScenarios", PostMutationScenarios.all)
        ]
        let previewIDs = Set(ScenarioCatalog.previewMatrix.map(\.id))

        for (owner, rows) in ownerRows {
            XCTAssertFalse(rows.isEmpty, "\(owner) must own at least one runtime scenario row.")
            XCTAssertTrue(rows.allSatisfy { previewIDs.contains($0.id) }, "\(owner) rows must be consumed by the preview matrix.")
        }
    }

    func testQualityGateChecklistIsStrictAndExecutable() {
        XCTAssertEqual(QualityGateChecklist.validationIssues(), [])
        XCTAssertEqual(Set(QualityGateChecklist.contracts.map(\.id)), Set(QualityGateID.allCases))
        XCTAssertTrue(QualityGateChecklist.contracts.allSatisfy(\.failureIsGreenBlocker))
        XCTAssertTrue(
            QualityGateChecklist.contracts.allSatisfy {
                $0.executableCheck == QualityGateChecklist.executableScript
            }
        )
    }

    func testForbiddenLanguageTermsRejectOldRootCanon() {
        XCTAssertEqual(ForbiddenLanguageAudit.violation(in: "Open the Plan tab"), "Plan tab")
        XCTAssertEqual(ForbiddenLanguageAudit.violation(in: "Show the Motion tab"), "Motion tab")
        XCTAssertEqual(ForbiddenLanguageAudit.violation(in: "runtime-backed local projection"), "runtime-backed")
        XCTAssertEqual(ForbiddenLanguageAudit.violation(in: "source unavailable"), "source unavailable")
        XCTAssertNil(ForbiddenLanguageAudit.violation(in: "source unavailable", exposure: .inspectionOnly))
        XCTAssertEqual(ForbiddenLanguageAudit.violation(in: "Open Time and review the LifeShape Field."), "LifeShape Field")
        XCTAssertNil(ForbiddenLanguageAudit.violation(in: "LifeShape Field", exposure: .internal))
    }

    func testM01CaptureToGoalPromotionPersistsGoalDraftCaptureAndReceipt() async throws {
        let harness = try await makeLiveSurfaceHarness()
        let context = try await makePromotedGoalContext(
            in: harness,
            captureText: "Turn captured thought into a real goal"
        )
        let captures = try await harness.repositories.captures.listCaptures()
        let drafts = try await harness.repositories.drafts.listDrafts()
        let goal = try await harness.repositories.goals.goal(id: context.goalID)
        let ledgerEntries = try await harness.repositories.eventLedger.fetchRecent(limit: 20)

        XCTAssertEqual(captures.count, 1)
        XCTAssertEqual(captures.first?.id, context.captureID)
        XCTAssertEqual(captures.first?.linkedGoalID, context.goalID)
        XCTAssertEqual(captures.first?.kind, .goalSeed)
        XCTAssertEqual(captures.first?.route, .goalSeed)
        XCTAssertEqual(goal?.id, context.goalID)
        XCTAssertEqual(goal?.title, "Turn captured thought into a real goal")
        XCTAssertEqual(drafts.count, 1)
        XCTAssertEqual(drafts.first?.plannedGoalID, context.goalID)
        XCTAssertEqual(drafts.first?.draft.title, "Turn captured thought into a real goal")
        XCTAssertNotNil(context.binding.unitOfWorkReceipt)
        XCTAssertEqual(context.binding.unitOfWorkReceipt?.didCommitChanges, true)
        XCTAssertEqual(context.binding.unitOfWorkReceipt?.writeScope, .localSwiftDataSingleContext)
        XCTAssertTrue(ledgerEntries.contains { $0.kind == .captureTriaged && $0.captureID == context.captureID })
    }

    func testM01TodayCompletionWritesFeedbackEvidenceAndEventLedgerProof() async throws {
        let harness = try await makeLiveSurfaceHarness()
        let context = try await makePromotedGoalContext(
            in: harness,
            captureText: "Complete the surfaced goal"
        )
        let loadedGoal = try await harness.repositories.goals.goal(id: context.goalID)
        let goal = try XCTUnwrap(loadedGoal)
        let baselineFeedback = try await harness.repositories.feedback.listEvents(goalID: context.goalID)
        let baselineEvidence = try await harness.repositories.evidence.listEvidence(goalID: context.goalID)
        let action = TodayInlineAction(
            kind: .complete,
            title: "Complete",
            systemImage: "checkmark.circle.fill",
            state: .success,
            target: TodayActionTarget(goalID: context.goalID, stepID: context.stepID)
        )

        let response = try await harness.todayService.performAction(action, now: fixedNow.addingTimeInterval(120))
        let feedback = try await harness.repositories.feedback.listEvents(goalID: context.goalID)
        let evidence = try await harness.repositories.evidence.listEvidence(goalID: context.goalID)
        let ledgerEntries = try await harness.repositories.eventLedger.fetchRecent(limit: 20)

        XCTAssertEqual(response.message?.title, "Completion recorded")
        XCTAssertEqual(feedback.count, baselineFeedback.count + 1)
        XCTAssertEqual(evidence.count, baselineEvidence.count + 1)
        XCTAssertTrue(
            evidence.contains {
                $0.evidenceKind == .stepCompleted &&
                $0.goalID == context.goalID &&
                $0.stepID == context.stepID
            }
        )
        XCTAssertTrue(ledgerEntries.contains { $0.kind == .actionCompleted && $0.goalID == context.goalID })
        XCTAssertEqual(goal.plan?.sections.flatMap(\.steps).first?.id, context.stepID)
    }

    func testM01YouDashboardReflectsLocalOnlyDefaultsAndLocalProofSignals() async throws {
        let harness = try await makeLiveSurfaceHarness()
        let context = try await makePromotedGoalContext(
            in: harness,
            captureText: "Feed You with a real local proof trail"
        )

        _ = try await harness.todayService.performAction(
            TodayInlineAction(
                kind: .complete,
                title: "Complete",
                systemImage: "checkmark.circle.fill",
                state: .success,
                target: TodayActionTarget(goalID: context.goalID, stepID: context.stepID)
            ),
            now: fixedNow.addingTimeInterval(120)
        )

        let dashboard = try await harness.youService.loadYouDashboard()
        let trustHistoryItems = dashboard.trustHistoryCenter.items
        let proofReviewItems = dashboard.crossSurfaceProofReview.items
        let systemCenterItems = dashboard.systemCenter.sections.flatMap(\.items)
        let receiptLedgerItem = try XCTUnwrap(
            dashboard.receiptAudit.items.first(where: { $0.id == "you-receipts-ledger" })
        )

        XCTAssertTrue(dashboard.preferences.localOnlyModeEnabled)
        XCTAssertEqual(dashboard.preferences.preferredTab, .today)
        XCTAssertEqual(dashboard.preferences.appearancePreference, .dark)
        XCTAssertEqual(dashboard.preferences.accentFamily, .sage)
        XCTAssertEqual(dashboard.preferences.reviewCadenceDays, 7)
        XCTAssertTrue(trustHistoryItems.contains { $0.category == .proof && $0.title == "Local proof available" })
        XCTAssertTrue(proofReviewItems.contains { $0.id == "cross-review-today-goal-proof" && $0.state == .success })
        XCTAssertTrue(systemCenterItems.contains { $0.id == "what-ambitions-knows" && $0.statusLabel == "Stored on this device" })
        XCTAssertNotEqual(receiptLedgerItem.valueLabel, "No recent events")
    }
}

private extension ScenarioMatrixTests {
    struct LiveSurfaceHarness {
        let repositories: AppRepositories
        let captureService: any CaptureServicing
        let todayService: any TodayServicing
        let youService: any YouServicing
    }

    struct PromotedGoalContext {
        let captureID: String
        let goalID: String
        let stepID: String
        let binding: CaptureGoalBinding
    }

    var fixedNow: Date {
        Date(timeIntervalSince1970: 1_777_113_600)
    }

    @MainActor
    func makeLiveSurfaceHarness() async throws -> LiveSurfaceHarness {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let repositories = try await AppContainerFactory.prepareRepositories(for: .live, store: store)
        let runtime = AmbitionsRuntimeFactory.make(
            repositories: repositories,
            notificationService: StubNotificationService(),
            calendarRemindersService: StubCalendarRemindersService()
        )

        return LiveSurfaceHarness(
            repositories: repositories,
            captureService: runtime.captureService,
            todayService: runtime.todayService,
            youService: runtime.youService
        )
    }

    func makePromotedGoalContext(
        in harness: LiveSurfaceHarness,
        captureText: String
    ) async throws -> PromotedGoalContext {
        let capture = try await harness.captureService.createCapture(
            CreateCaptureRequest(rawText: captureText),
            now: fixedNow
        )
        let createdBinding = try await harness.captureService.turnCaptureIntoGoal(
            TurnCaptureIntoGoalRequest(captureID: capture.id),
            now: fixedNow.addingTimeInterval(60)
        )
        let binding = try XCTUnwrap(createdBinding)
        let goalID = try XCTUnwrap(binding.target.goalID)
        let loadedGoal = try await harness.repositories.goals.goal(id: goalID)
        let goal = try XCTUnwrap(loadedGoal)
        let stepID = try XCTUnwrap(goal.plan?.sections.first?.steps.first?.id)

        return PromotedGoalContext(
            captureID: capture.id,
            goalID: goalID,
            stepID: stepID,
            binding: binding
        )
    }
}
