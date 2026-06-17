import XCTest
@testable import Ambitions

final class GoldenVerticalSliceRuntimeTests: XCTestCase {
    func testFirstRunActivationConnectsFirstGoalRecommendedStepAndRecoveryOptionToGoldenSlice() throws {
        let firstRunArtist = try goldenSlice(
            prefix: "first-run-artist",
            displayName: "Sal",
            rawGoal: "Release my first music single with a proof-backed local path.",
            normalizedGoal: "Release a music single through a calm first-run path.",
            lifeContext: "Has one evening window and wants the first action to stay small.",
            capacityProfile: "One short evening block with a weekend review cushion.",
            creativeConstraint: "Needs a checklist before sharing release assets.",
            supportPreference: "Prefers visible local receipts and a recovery-safe fallback."
        )
        let program = GoldenVerticalSliceRuntime().evaluate(
            GoldenVerticalSliceProgramInput(
                slices: [firstRunArtist, try companionSlice()],
                evaluatedAt: "2026-06-14T20:00:00Z"
            )
        )

        let activation = FirstRunActivationRuntime().evaluate(
            FirstRunActivationInput(
                goldenProgram: program,
                selectedSliceID: firstRunArtist.endUserBackground.id,
                activatedAt: "2026-06-14T20:05:00Z"
            )
        )

        XCTAssertTrue(program.canProveBothPersonalizedSlices, "\(program.issues)")
        XCTAssertTrue(activation.canActivateFirstRun, "\(activation.issues)")
        XCTAssertEqual(activation.state, .ready)
        XCTAssertEqual(activation.issues, [])
        XCTAssertEqual(activation.firstGoal?.id, "goal.first-run-artist.music-release")
        XCTAssertEqual(activation.recommendedStep?.id, "step.first-run-artist.release-checklist")
        XCTAssertEqual(activation.recoveryOption?.kind, .shrink)
        XCTAssertEqual(activation.receipt?.topLevelTabs, ["Today", "Goals", "Time", "You"])
        XCTAssertEqual(activation.receipt?.captureRole, "global action")
        XCTAssertFalse(AppTab.allCases.map(\.rawValue).contains("capture"))
        XCTAssertTrue(activation.receipt?.sourceRecordIDs.contains("SourceRecord.first-run-artist.background") == true)
        XCTAssertTrue(activation.receipt?.sourceRecordIDs.contains("SourceRecord.first-run-artist.intake") == true)
        XCTAssertTrue(activation.receipt?.receiptIDs.contains("Receipt.first-run-artist.completion") == true)
        XCTAssertTrue(activation.receipt?.replayTraceIDs.contains("ReplayTrace.first-run-artist.completion") == true)
        XCTAssertTrue(activation.receipt?.whatAmbitionsKnowsRoute?.contains("you://what-ambitions-knows/first-run-activation") == true)
        XCTAssertTrue(activation.receipt?.continuitySummary.contains("Recommended step") == true)
        XCTAssertTrue(activation.receipt?.continuitySummary.contains("recovery option") == true)
        XCTAssertTrue(activation.receipt?.continuitySummary.contains("local receipt replay") == true)
    }

    func testFirstRunActivationBlocksGenericOnboardingTheater() throws {
        let program = GoldenVerticalSliceRuntime().evaluate(
            GoldenVerticalSliceProgramInput(
                slices: [try firstRunSlice(), try companionSlice()],
                evaluatedAt: "2026-06-14T20:10:00Z"
            )
        )

        let activation = FirstRunActivationRuntime().evaluate(
            FirstRunActivationInput(
                goldenProgram: program,
                activatedAt: "2026-06-14T20:11:00Z",
                continuitySummaryOverride: "Finish setup tour before anything real."
            )
        )

        XCTAssertFalse(activation.canActivateFirstRun)
        XCTAssertEqual(activation.state, .blocked)
        XCTAssertTrue(activation.issues.contains(.genericOnboardingTheater), "\(activation.issues)")
        XCTAssertTrue(activation.issues.contains(.calmContinuityMissing), "\(activation.issues)")
    }

    func testFirstRunActivationBlocksWhenGoldenProgramIsNotReady() throws {
        let blockedSlice = try goldenSlice(
            prefix: "first-run-protected-window",
            displayName: "Lane",
            rawGoal: "Release a music track while protecting evening care time.",
            normalizedGoal: "Release a music track without crossing protected time.",
            lifeContext: "Evening care time is protected.",
            capacityProfile: "Morning release prep only.",
            creativeConstraint: "Needs mastering prep away from protected time.",
            supportPreference: "Prefers explicit recovery before schedule install.",
            selectedWindow: .protectedEvening
        )
        let program = GoldenVerticalSliceRuntime().evaluate(
            GoldenVerticalSliceProgramInput(
                slices: [blockedSlice, try companionSlice()],
                evaluatedAt: "2026-06-14T20:15:00Z"
            )
        )

        let activation = FirstRunActivationRuntime().evaluate(
            FirstRunActivationInput(
                goldenProgram: program,
                selectedSliceID: blockedSlice.endUserBackground.id,
                activatedAt: "2026-06-14T20:16:00Z"
            )
        )

        XCTAssertFalse(program.canProveBothPersonalizedSlices)
        XCTAssertFalse(activation.canActivateFirstRun)
        XCTAssertTrue(activation.issues.contains(.goldenProgramNotReady), "\(activation.issues)")
        XCTAssertTrue(activation.issues.contains(.goldenSliceMissing), "\(activation.issues)")
        XCTAssertTrue(activation.issues.contains(.activationReceiptMissing), "\(activation.issues)")
    }

    func testFirstRunActivationRequiresFirstGoalFlow() throws {
        let program = GoldenVerticalSliceRuntime().evaluate(
            GoldenVerticalSliceProgramInput(
                slices: [try firstRunSlice(), try companionSlice()],
                evaluatedAt: "2026-06-14T20:20:00Z"
            )
        )

        let activation = FirstRunActivationRuntime().evaluate(
            FirstRunActivationInput(
                goldenProgram: program,
                onboardingChoice: .enterToday,
                activatedAt: "2026-06-14T20:21:00Z"
            )
        )

        XCTAssertFalse(activation.canActivateFirstRun)
        XCTAssertEqual(activation.state, .blocked)
        XCTAssertTrue(activation.issues.contains(.firstGoalFlowMissing), "\(activation.issues)")
        XCTAssertFalse(activation.issues.contains(.recommendedStepMissing), "\(activation.issues)")
        XCTAssertFalse(activation.issues.contains(.recoveryOptionMissing), "\(activation.issues)")
    }

    func testTwoPersonalizedMusicReleaseSlicesOpenRuntimeCoreAndReplay() throws {
        let touringParent = try goldenSlice(
            prefix: "touring-parent",
            displayName: "Mira",
            rawGoal: "Release my next music single while touring with school pickup constraints.",
            normalizedGoal: "Release a music single with local proof, schedule fit, and calm recovery.",
            lifeContext: "Tours regionally and protects school pickup twice a week.",
            capacityProfile: "Two morning creative blocks and one flexible midday block.",
            creativeConstraint: "Needs a release checklist that works from a hotel room.",
            supportPreference: "Prefers tight steps with visible receipts before sharing."
        )
        let nightShiftProducer = try goldenSlice(
            prefix: "night-shift-producer",
            displayName: "Jonah",
            rawGoal: "Release a music track after night shifts without losing recovery time.",
            normalizedGoal: "Release a track through proof-backed evening preparation.",
            lifeContext: "Works nights and protects post-shift sleep recovery.",
            capacityProfile: "Short evening windows and weekend review time.",
            creativeConstraint: "Needs low-friction export checks before mastering review.",
            supportPreference: "Prefers recovery-safe alternates and explicit time install receipts."
        )

        let program = GoldenVerticalSliceRuntime().evaluate(
            GoldenVerticalSliceProgramInput(
                slices: [touringParent, nightShiftProducer],
                evaluatedAt: "2026-06-14T19:30:00Z"
            )
        )

        XCTAssertTrue(program.canProveBothPersonalizedSlices, "\(program.issues)")
        XCTAssertEqual(program.issues, [])
        XCTAssertEqual(program.slices.count, 2)
        XCTAssertEqual(Set(program.slices.map(\.endUserBackground.id)).count, 2)
        XCTAssertEqual(Set(program.slices.map(\.anyGoalRecord.goalReferenceID)).count, 2)
        XCTAssertEqual(Set(program.slices.map(\.personalizationFingerprint)).count, 2)
        XCTAssertEqual(program.reflowTraceIDs.count, 2)

        for slice in program.slices {
            XCTAssertEqual(slice.state, .ready)
            XCTAssertEqual(slice.issues, [])
            XCTAssertTrue(slice.anyGoalRecord.canGenerateVisibleStep)
            XCTAssertTrue(slice.recommendedStep.canShow)
            XCTAssertTrue(slice.latticeRecord.canDrivePathSelectionSegment)
            XCTAssertTrue(slice.graphRecord.canDriveGraphCompilerSegment)
            XCTAssertTrue(slice.elasticityRecord.canDriveElasticitySegment)
            XCTAssertTrue(slice.scheduleRecord.canDriveScheduleInstallSegment)
            XCTAssertTrue(slice.consequenceRecord.canDriveConsequenceReflowSegment)
            XCTAssertTrue(slice.safetyRecord.canContinueToRuntimeCore)
            XCTAssertTrue(slice.runtimeCoreRecord.canOpenRuntimeCore)
            XCTAssertEqual(slice.runtimeCoreRecord.rows.count, RuntimeCoreChainSegmentKind.requiredOrder.count)
            XCTAssertTrue(slice.runtimeCoreRecord.rows.allSatisfy(\.canDriveSegment))
            XCTAssertEqual(slice.completionProof.completedStepID, slice.recommendedStep.candidateId)
            XCTAssertTrue(Set(slice.endUserBackground.sourceRecordIDs).isSubset(of: Set(slice.replayOutput.sourceRecordIDs)))
            XCTAssertEqual(slice.replayOutput.reflowTraceID, slice.consequenceRecord.trace.id)
            XCTAssertEqual(slice.replayOutput.safetyReceiptID, slice.safetyRecord.receipt.id)
            XCTAssertTrue(slice.replayOutput.replayTraceIDs.contains(slice.consequenceRecord.trace.id))
            XCTAssertTrue(slice.replayOutput.replayTraceIDs.contains(slice.safetyRecord.trace.id))
            XCTAssertTrue(slice.receiptIDs.contains(slice.scheduleRecord.installReceipt?.id ?? ""))
            XCTAssertTrue(slice.replayTraceIDs.contains(slice.consequenceRecord.trace.id))
        }
    }

    func testDuplicateBackgroundBlocksBroadGreen() throws {
        let first = try goldenSlice(
            prefix: "duplicate-a",
            displayName: "Shared Artist",
            rawGoal: "Release a music track with local proof.",
            normalizedGoal: "Release a music track with proof-backed preparation.",
            lifeContext: "Uses the same capacity and creative context.",
            capacityProfile: "One morning block.",
            creativeConstraint: "Needs the same checklist path.",
            supportPreference: "Prefers the same receipt review.",
            backgroundID: "shared-music-release-background"
        )
        let second = try goldenSlice(
            prefix: "duplicate-b",
            displayName: "Shared Artist",
            rawGoal: "Release a music track with local proof.",
            normalizedGoal: "Release a music track with proof-backed preparation.",
            lifeContext: "Uses the same capacity and creative context.",
            capacityProfile: "One morning block.",
            creativeConstraint: "Needs the same checklist path.",
            supportPreference: "Prefers the same receipt review.",
            backgroundID: "shared-music-release-background"
        )

        let program = GoldenVerticalSliceRuntime().evaluate(
            GoldenVerticalSliceProgramInput(slices: [first, second], evaluatedAt: "2026-06-14T19:35:00Z")
        )

        XCTAssertFalse(program.canProveBothPersonalizedSlices)
        XCTAssertTrue(program.issues.contains(.duplicateEndUserBackground), "\(program.issues)")
    }

    func testReplayMismatchBlocksSliceProof() throws {
        let input = try goldenSlice(
            prefix: "replay-mismatch",
            displayName: "Ari",
            rawGoal: "Release a song with a replayable local receipt.",
            normalizedGoal: "Release a song through a replayable proof path.",
            lifeContext: "Balances studio time with family dinners.",
            capacityProfile: "One quiet afternoon block.",
            creativeConstraint: "Needs export checks before artwork review.",
            supportPreference: "Prefers source-backed replay before sharing.",
            replayMutation: .wrongReflowTrace
        )

        let program = GoldenVerticalSliceRuntime().evaluate(
            GoldenVerticalSliceProgramInput(slices: [input, try companionSlice()], evaluatedAt: "2026-06-14T19:40:00Z")
        )
        let slice = try XCTUnwrap(program.slices.first { $0.endUserBackground.id == "background.replay-mismatch" })

        XCTAssertFalse(program.canProveBothPersonalizedSlices)
        XCTAssertEqual(slice.state, .blocked)
        XCTAssertTrue(slice.issues.contains(.replayOutputDoesNotMatchRuntime), "\(slice.issues)")
    }

    func testProtectedScheduleInstallBlocksRuntimeCore() throws {
        let input = try goldenSlice(
            prefix: "protected-window",
            displayName: "Nia",
            rawGoal: "Release an album track while preserving protected family time.",
            normalizedGoal: "Release an album track without crossing protected time.",
            lifeContext: "Keeps evening care time protected.",
            capacityProfile: "Morning production block and protected evening care block.",
            creativeConstraint: "Needs mastering prep to avoid protected time.",
            supportPreference: "Prefers explicit rollback before time install.",
            selectedWindow: .protectedEvening
        )

        let program = GoldenVerticalSliceRuntime().evaluate(
            GoldenVerticalSliceProgramInput(slices: [input, try companionSlice()], evaluatedAt: "2026-06-14T19:45:00Z")
        )
        let slice = try XCTUnwrap(program.slices.first { $0.endUserBackground.id == "background.protected-window" })

        XCTAssertFalse(program.canProveBothPersonalizedSlices)
        XCTAssertEqual(slice.state, .blocked)
        XCTAssertTrue(slice.issues.contains(.scheduleInstallBlocked), "\(slice.issues)")
        XCTAssertTrue(slice.issues.contains(.runtimeCoreBlocked), "\(slice.issues)")
        XCTAssertFalse(slice.scheduleRecord.canDriveScheduleInstallSegment)
        XCTAssertFalse(slice.runtimeCoreRecord.canOpenRuntimeCore)
    }
}

private extension GoldenVerticalSliceRuntimeTests {
    enum SelectedWindow {
        case openMorning
        case protectedEvening
    }

    enum ReplayMutation {
        case none
        case wrongReflowTrace
    }

    func companionSlice() throws -> GoldenVerticalSliceInput {
        try goldenSlice(
            prefix: "companion",
            displayName: "Theo",
            rawGoal: "Release a music single with a weekend proof review.",
            normalizedGoal: "Release a music single through a weekend proof review.",
            lifeContext: "Uses weekend time and protects weekday work focus.",
            capacityProfile: "One weekend block and short weekday check-ins.",
            creativeConstraint: "Needs artwork and export checks before release.",
            supportPreference: "Prefers visible receipts and recovery-safe alternates."
        )
    }

    func firstRunSlice() throws -> GoldenVerticalSliceInput {
        try goldenSlice(
            prefix: "first-run",
            displayName: "Rin",
            rawGoal: "Release a music single through a local first-run path.",
            normalizedGoal: "Release a music single with first-run receipt proof.",
            lifeContext: "Has one focused evening and wants a calm first activation.",
            capacityProfile: "Short evening window with a weekend review buffer.",
            creativeConstraint: "Needs a release checklist before artwork review.",
            supportPreference: "Prefers local receipts and a shrink-safe recovery option."
        )
    }

    func goldenSlice(
        prefix: String,
        displayName: String,
        rawGoal: String,
        normalizedGoal: String,
        lifeContext: String,
        capacityProfile: String,
        creativeConstraint: String,
        supportPreference: String,
        backgroundID: String? = nil,
        selectedWindow: SelectedWindow = .openMorning,
        replayMutation: ReplayMutation = .none
    ) throws -> GoldenVerticalSliceInput {
        let background = GoldenSliceEndUserBackground(
            id: backgroundID ?? "background.\(prefix)",
            displayName: displayName,
            lifeContextSummary: lifeContext,
            capacityProfile: capacityProfile,
            creativeConstraint: creativeConstraint,
            supportPreference: supportPreference,
            sourceRecordIDs: ["SourceRecord.\(prefix).background"],
            receiptIDs: ["Receipt.\(prefix).background"],
            replayTraceID: "ReplayTrace.\(prefix).background",
            whatAmbitionsKnowsRoute: "you://what-ambitions-knows/background/\(prefix)"
        )
        let intake = GoldenSliceGoalIntake(
            id: "intake.\(prefix)",
            rawGoalText: rawGoal,
            normalizedGoal: normalizedGoal,
            intakeSurface: "Global Capture",
            capturedAt: "2026-06-14T19:00:00Z",
            sourceRecordIDs: ["SourceRecord.\(prefix).intake"],
            receiptIDs: ["Receipt.\(prefix).intake"],
            replayTraceID: "ReplayTrace.\(prefix).intake",
            whatAmbitionsKnowsRoute: "you://what-ambitions-knows/intake/\(prefix)"
        )
        let anyGoalInput = anyGoalInput(prefix: prefix, rawGoal: rawGoal)
        let stepQualityInput = stepQualityInput(prefix: prefix, displayName: displayName)
        let latticeInput = latticeInput(prefix: prefix)
        let compiledPath = compiledPath(prefix: prefix)

        let anyGoalRecord = AnyGoalRuntimeCoverageEngine().evaluate(anyGoalInput)
        let latticeRecord = MultiPathLatticeEngine().evaluate(latticeInput)
        let graphRecord = StepGraphCompiler().compile(
            StepGraphCompilerInput(
                goalReferenceID: anyGoalInput.id,
                latticeRecord: latticeRecord,
                compiledPath: compiledPath,
                selectedCompiledCandidateID: primaryCandidateID(prefix),
                graphReceiptID: "Receipt.\(prefix).graph",
                compiledAt: "2026-06-14T19:05:00Z"
            )
        )
        let partialProof = StepElasticityPartialProgressProof(
            id: "partial.\(prefix).release-check",
            summary: "A release prep note was captured and can be replayed.",
            sourceRecordIDs: ["SourceRecord.\(prefix).partial"],
            receiptIDs: ["Receipt.\(prefix).partial"],
            replayTraceID: "ReplayTrace.\(prefix).partial",
            whatAmbitionsKnowsRoute: "you://what-ambitions-knows/partial/\(prefix)",
            occurredAt: "2026-06-14T19:10:00Z"
        )
        let elasticityRecord = StepElasticityEngine().evaluate(
            StepElasticityEngineInput(
                graphRecord: graphRecord,
                partialProgressProof: partialProof,
                originalDurationMinutes: 30,
                availableMinutes: 20,
                evaluatedAt: "2026-06-14T19:12:00Z"
            )
        )
        let selectedVariantID = try XCTUnwrap(elasticityRecord.variants.first { $0.kind == .shrink }?.id)
        let windows = timeWindows(prefix: prefix)
        let selectedWindowID = selectedWindow == .openMorning ? "window.\(prefix).morning" : "window.\(prefix).protected"
        let scheduleDecision = ScheduleInstallDecision(
            kind: .commit,
            selectedWindowID: selectedWindowID,
            userApproved: true,
            decisionReceiptID: "Receipt.\(prefix).schedule-decision",
            decidedAt: "2026-06-14T19:15:00Z",
            sourceRecordIDs: ["SourceRecord.\(prefix).schedule-decision"],
            receiptIDs: ["Receipt.\(prefix).schedule-decision"],
            replayTraceID: "ReplayTrace.\(prefix).schedule-decision",
            whatAmbitionsKnowsRoute: "you://what-ambitions-knows/schedule-decision/\(prefix)"
        )
        let rollback = ScheduleInstallRollbackPlan(
            id: "rollback.\(prefix)",
            previousScheduleSnapshotID: "schedule.snapshot.\(prefix).before",
            rollbackReceiptID: "Receipt.\(prefix).rollback",
            sourceRecordIDs: ["SourceRecord.\(prefix).rollback"],
            receiptIDs: ["Receipt.\(prefix).rollback"],
            replayTraceID: "ReplayTrace.\(prefix).rollback",
            whatAmbitionsKnowsRoute: "you://what-ambitions-knows/schedule-rollback/\(prefix)"
        )
        let protectedProof = ScheduleInstallProtectedTimeProof(
            id: "protected-time.\(prefix)",
            protectedWindowIDs: ["window.\(prefix).protected"],
            sourceRecordIDs: ["SourceRecord.\(prefix).protected-time"],
            receiptIDs: ["Receipt.\(prefix).protected-time"],
            replayTraceID: "ReplayTrace.\(prefix).protected-time",
            whatAmbitionsKnowsRoute: "you://what-ambitions-knows/protected-time/\(prefix)"
        )
        let scheduleRecord = ScheduleInstallKernel().evaluate(
            ScheduleInstallInput(
                elasticityRecord: elasticityRecord,
                selectedVariantID: selectedVariantID,
                candidateWindows: windows,
                decision: scheduleDecision,
                rollbackPlan: rollback,
                protectedTimeProof: protectedProof,
                evaluatedAt: "2026-06-14T19:18:00Z"
            )
        )
        let consequenceRecord = LifeConsequenceEngine().evaluate(
            LifeConsequenceEngineInput(
                scheduleInstallRecord: scheduleRecord,
                impacts: [lifeConsequenceImpact(prefix: prefix)],
                treaties: [],
                visibilityPreference: .balanced,
                evaluatedAt: "2026-06-14T19:20:00Z"
            )
        )
        let safetyRecord = HighRiskSafetyJurisdictionGate().evaluate(
            HighRiskSafetyGateInput(
                anyGoalRecord: anyGoalRecord,
                lifeConsequenceRecord: consequenceRecord,
                context: HighRiskJurisdictionContext(domain: .standard, reviewState: .notRequired),
                evaluatedAt: "2026-06-14T19:22:00Z"
            )
        )
        let completionProof = GoldenSliceCompletionProof(
            id: "completion.\(prefix)",
            completedStepID: stepQualityInput.id,
            completedAt: "2026-06-14T19:24:00Z",
            proofSummary: "The Recommended step was completed with local receipt coverage.",
            sourceRecordIDs: ["SourceRecord.\(prefix).completion"],
            receiptIDs: ["Receipt.\(prefix).completion"],
            replayTraceID: "ReplayTrace.\(prefix).completion",
            whatAmbitionsKnowsRoute: "you://what-ambitions-knows/completion/\(prefix)"
        )
        let optionalShareProof = GoldenSliceOptionalShareProof(
            id: "share.\(prefix)",
            audienceSummary: "User-approved collaborator preview only.",
            redactionSummary: "Private schedule and capacity details stay local.",
            sourceRecordIDs: ["SourceRecord.\(prefix).share"],
            receiptIDs: ["Receipt.\(prefix).share"],
            replayTraceID: "ReplayTrace.\(prefix).share",
            whatAmbitionsKnowsRoute: "you://what-ambitions-knows/share/\(prefix)",
            userApproved: true
        )
        let replayOutput = replayOutput(
            prefix: prefix,
            background: background,
            intake: intake,
            latticeRecord: latticeRecord,
            scheduleRecord: scheduleRecord,
            consequenceRecord: consequenceRecord,
            safetyRecord: safetyRecord,
            completionProof: completionProof,
            mutation: replayMutation
        )

        return GoldenVerticalSliceInput(
            id: "slice.\(prefix)",
            endUserBackground: background,
            intake: intake,
            anyGoalInput: anyGoalInput,
            stepQualityInput: stepQualityInput,
            latticeInput: latticeInput,
            compiledPath: compiledPath,
            selectedCompiledCandidateID: primaryCandidateID(prefix),
            graphReceiptID: "Receipt.\(prefix).graph",
            graphCompiledAt: "2026-06-14T19:05:00Z",
            partialProgressProof: partialProof,
            originalDurationMinutes: 30,
            availableMinutes: 20,
            elasticityEvaluatedAt: "2026-06-14T19:12:00Z",
            selectedVariantID: selectedVariantID,
            candidateWindows: windows,
            scheduleDecision: scheduleDecision,
            rollbackPlan: rollback,
            protectedTimeProof: protectedProof,
            scheduleEvaluatedAt: "2026-06-14T19:18:00Z",
            consequenceImpacts: [lifeConsequenceImpact(prefix: prefix)],
            treaties: [],
            visibilityPreference: .balanced,
            consequenceEvaluatedAt: "2026-06-14T19:20:00Z",
            safetyContext: HighRiskJurisdictionContext(domain: .standard, reviewState: .notRequired),
            safetyEvaluatedAt: "2026-06-14T19:22:00Z",
            completionProof: completionProof,
            optionalShareProof: optionalShareProof,
            replayOutput: replayOutput
        )
    }

    func anyGoalInput(prefix: String, rawGoal: String) -> AnyGoalCoverageInput {
        AnyGoalCoverageInput(
            id: "goal.\(prefix).music-release",
            rawGoalText: rawGoal,
            family: .creative,
            domain: "music_release",
            supportState: .sourceBacked,
            sourceAuthority: AnyGoalSourceAuthoritySnapshot(
                canSupportCurrentUse: true,
                sourceRecordIDs: ["SourceRecord.\(prefix).goal", "SourceRecord.\(prefix).background"],
                sourceFingerprintIDs: ["SourceFingerprint.\(prefix).goal"],
                authorityIssueCodes: [],
                freshnessReviewClass: .unreviewed
            ),
            missingSourceTypes: [],
            seedGapCategories: [],
            receiptID: "Receipt.\(prefix).any-goal",
            replayTraceID: "ReplayTrace.\(prefix).any-goal",
            whatAmbitionsKnowsRoute: "you://what-ambitions-knows/any-goal/\(prefix)"
        )
    }

    func stepQualityInput(prefix: String, displayName: String) -> StepQualityInput {
        let stepText = "Export release checklist for \(displayName)"
        return StepQualityInput(
            id: "step.\(prefix).release-checklist",
            stepText: stepText,
            actionVerb: "Export",
            object: "release checklist for \(displayName)",
            durationMinutes: 30,
            protectedSurfaces: [.today, .goals],
            sourceAuthority: StepQualitySourceAuthority(
                state: .officialCurrent,
                sourceRecordIDs: ["SourceRecord.\(prefix).step"],
                freshnessState: "current",
                reviewState: "approved",
                riskLevel: .low,
                runtimeEligible: true
            ),
            proofExpectation: StepQualityProofExpectation(
                primitive: "recommended_step",
                receiptIDs: ["Receipt.\(prefix).step-quality"],
                proofTraceID: "ProofTrace.\(prefix).step-quality",
                replayTraceID: "ReplayTrace.\(prefix).step-quality"
            ),
            accessibility: StepQualityAccessibilitySemantics(
                voiceOverLabel: stepText,
                voiceOverValue: "Recommended step",
                voiceOverHint: "Opens the release checklist step.",
                nonVisualSummary: "\(stepText) is the Recommended step with source and receipt proof."
            ),
            elasticityCoverage: StepQualityElasticityCoverage(
                minimumViable: true,
                standard: true,
                proofOnly: true,
                recoverySafe: true,
                replacement: true,
                split: true,
                merge: true
            ),
            repairPath: nil
        )
    }

    func latticeInput(prefix: String) -> MultiPathLatticeInput {
        let primaryID = primaryCandidateID(prefix)
        let backupID = backupCandidateID(prefix)
        return MultiPathLatticeInput(
            goalReferenceID: "goal.\(prefix).music-release",
            portfolio: portfolio(prefix: prefix),
            selectedPathID: primaryID,
            selectionReason: "Use the smallest local path that preserves release proof.",
            selectionReceiptID: "Receipt.\(prefix).path-selection",
            selectedAt: "2026-06-14T19:04:00Z",
            sourceRecordIDsByPathID: [
                primaryID: ["SourceRecord.\(prefix).path.primary"],
                backupID: ["SourceRecord.\(prefix).path.backup"]
            ],
            receiptIDsByPathID: [
                primaryID: ["Receipt.\(prefix).path.primary"],
                backupID: ["Receipt.\(prefix).path.backup"]
            ],
            replayTraceIDsByPathID: [
                primaryID: "ReplayTrace.\(prefix).path.primary",
                backupID: "ReplayTrace.\(prefix).path.backup"
            ],
            whatAmbitionsKnowsRoutesByPathID: [
                primaryID: "you://what-ambitions-knows/path/\(prefix)/primary",
                backupID: "you://what-ambitions-knows/path/\(prefix)/backup"
            ],
            tradeoffsByPathID: [
                primaryID: tradeoffs(prefix: prefix, pathID: primaryID),
                backupID: tradeoffs(prefix: prefix, pathID: backupID)
            ]
        )
    }

    func portfolio(prefix: String) -> AmbitionsOSPathPortfolio {
        AmbitionsOSPathPortfolio(
            id: "portfolio.\(prefix).release",
            title: "Music release path portfolio",
            startingPositionSnapshotID: "starting-position.\(prefix)",
            compiledGoalCandidateID: primaryCandidateID(prefix),
            localGoalPackIDs: ["pack.\(prefix).release"],
            paths: [
                path(prefix: prefix, id: primaryCandidateID(prefix), title: "Focused release path", kind: .activePath),
                path(prefix: prefix, id: backupCandidateID(prefix), title: "Recovery release path", kind: .backupPath)
            ],
            pathChangeReceipts: [],
            preservesNorthStar: true,
            mutatesLifeGraph: false,
            runtimeBoundary: .valueModelOnly
        )
    }

    func path(prefix: String, id: String, title: String, kind: AmbitionsOSAlternatePathKind) -> AmbitionsOSAlternatePathCandidate {
        AmbitionsOSAlternatePathCandidate(
            id: id,
            title: title,
            kind: kind,
            summary: "Keeps \(prefix) release work inspectable before schedule install.",
            requirementSlotIDs: ["requirement.\(id)"],
            transferableProofReceiptIDs: ["ProofReceipt.\(id)"],
            requirementOverlapIDs: ["requirement.\(id)"],
            sourceClaimIDs: ["SourceClaim.\(id)"],
            sourceState: .sourceBacked,
            freshnessState: .current,
            reviewState: .ready,
            privacyClass: .privateLife,
            professionalBoundaryApplies: false,
            claimsGuaranteedOutcome: false, // not a release claim; this fixture rejects guaranteed outcomes.
            externalProjectionRequested: false
        )
    }

    func tradeoffs(prefix: String, pathID: String) -> [MultiPathTradeoff] {
        [
            MultiPathTradeoff(
                id: "tradeoff.\(pathID).capacity",
                dimension: .capacity,
                summary: "Fits \(prefix) capacity without crossing protected time.",
                weight: 80
            ),
            MultiPathTradeoff(
                id: "tradeoff.\(pathID).proof",
                dimension: .proofContinuity,
                summary: "Keeps receipt replay visible for release proof.",
                weight: 90
            )
        ]
    }

    func compiledPath(prefix: String) -> GoalCompiledPath {
        GoalCompiledPath(
            schemaVersion: goalPathCompilerSchemaVersion,
            sourceUnderstandingSchemaVersion: goalUnderstandingSchemaVersion,
            overallPosture: .provisional,
            safeForStarterPlanning: true,
            candidates: [
                GoalCompiledPathCandidate(
                    id: primaryCandidateID(prefix),
                    title: "Focused release path",
                    summary: "Compile intake into a local music release step graph.",
                    isPrimary: true,
                    posture: .provisional,
                    safeForStarterPlanning: true,
                    stages: stages(prefix: prefix),
                    dependencies: dependencies(prefix: prefix),
                    branches: [],
                    assumptions: [],
                    risks: [],
                    blockingReasons: [],
                    confidence: GoalCompiledPathConfidence(overall: .high, score: 0.86, uncertaintyTags: [])
                )
            ],
            uncertainty: GoalCompiledPathUncertainty(
                ambiguityActive: false,
                missingContextFields: [],
                unresolvedQuestionIDs: [],
                alternateInterpretationsActive: false,
                knowledgeContextAttached: true,
                knowledgeContextRequired: false
            ),
            audit: GoalCompiledPathAuditMetadata(entries: [])
        )
    }

    func stages(prefix: String) -> [GoalCompiledPathStage] {
        [
            stage(prefix: prefix, id: "stage.\(prefix).setup", kind: .setup, orderIndex: 0),
            stage(prefix: prefix, id: "stage.\(prefix).readiness", kind: .readiness, orderIndex: 1, dependencyIDs: ["dep.\(prefix).setup-readiness"]),
            stage(prefix: prefix, id: "stage.\(prefix).proof", kind: .firstProof, orderIndex: 2, dependencyIDs: ["dep.\(prefix).readiness-proof"]),
            stage(prefix: prefix, id: "stage.\(prefix).advance", kind: .advancement, orderIndex: 3, dependencyIDs: ["dep.\(prefix).proof-advance"]),
            stage(prefix: prefix, id: "stage.\(prefix).review", kind: .reviewFinish, orderIndex: 4, dependencyIDs: ["dep.\(prefix).advance-review"])
        ]
    }

    func stage(prefix: String, id: String, kind: GoalCompiledPathStageKind, orderIndex: Int, dependencyIDs: [String] = []) -> GoalCompiledPathStage {
        GoalCompiledPathStage(
            id: id,
            title: "\(prefix) \(kind.rawValue)",
            summary: "Keeps the \(prefix) release path inspectable.",
            orderIndex: orderIndex,
            kind: kind,
            dependencyIDs: dependencyIDs,
            prerequisiteHints: [],
            readinessHints: [],
            uncertainBecause: []
        )
    }

    func dependencies(prefix: String) -> [GoalCompiledPathDependency] {
        [
            dependency(prefix: prefix, id: "dep.\(prefix).setup-readiness", kind: .stageOrdering, relatedStageID: "stage.\(prefix).readiness"),
            dependency(prefix: prefix, id: "dep.\(prefix).readiness-proof", kind: .readiness, relatedStageID: "stage.\(prefix).proof"),
            dependency(prefix: prefix, id: "dep.\(prefix).proof-advance", kind: .support, relatedStageID: "stage.\(prefix).advance"),
            dependency(prefix: prefix, id: "dep.\(prefix).advance-review", kind: .knowledge, relatedStageID: "stage.\(prefix).review")
        ]
    }

    func dependency(prefix: String, id: String, kind: GoalCompiledPathDependencyKind, relatedStageID: String) -> GoalCompiledPathDependency {
        GoalCompiledPathDependency(
            id: id,
            summary: "Connects \(relatedStageID) to the upstream release context.",
            kind: kind,
            sourceClaimIDs: ["SourceClaim.\(prefix).dependency"],
            sourceRecordIDs: ["SourceRecord.\(prefix).dependency"],
            blocking: false,
            relatedStageID: relatedStageID
        )
    }

    func timeWindows(prefix: String) -> [ScheduleInstallTimeWindow] {
        [
            timeWindow(prefix: prefix, id: "window.\(prefix).midday", label: "Midday open block", startAt: "2026-06-15T16:00:00Z", endAt: "2026-06-15T16:30:00Z", protected: false),
            timeWindow(prefix: prefix, id: "window.\(prefix).protected", label: "Protected evening block", startAt: "2026-06-15T22:00:00Z", endAt: "2026-06-15T22:30:00Z", protected: true),
            timeWindow(prefix: prefix, id: "window.\(prefix).morning", label: "Morning open block", startAt: "2026-06-15T13:00:00Z", endAt: "2026-06-15T13:30:00Z", protected: false)
        ]
    }

    func timeWindow(prefix: String, id: String, label: String, startAt: String, endAt: String, protected: Bool) -> ScheduleInstallTimeWindow {
        ScheduleInstallTimeWindow(
            id: id,
            label: label,
            startAt: startAt,
            endAt: endAt,
            durationMinutes: 30,
            isProtectedTime: protected,
            sourceRecordIDs: ["SourceRecord.\(prefix).\(id)"],
            receiptIDs: ["Receipt.\(prefix).\(id)"],
            replayTraceID: "ReplayTrace.\(prefix).\(id)",
            whatAmbitionsKnowsRoute: "you://what-ambitions-knows/window/\(prefix)/\(id)"
        )
    }

    func lifeConsequenceImpact(prefix: String) -> LifeConsequenceImpact {
        LifeConsequenceImpact(
            id: "impact.\(prefix).capacity",
            affectedGoalID: "goal.\(prefix).capacity",
            affectedGoalTitle: "\(prefix) recovery capacity",
            trigger: .scheduleInstall,
            deadlineMinutesDelta: 10,
            densityMinutesDelta: 15,
            proofValueDelta: 5,
            dependencyIDs: [],
            protectedTimeBroken: false,
            sourceAuthority: .current,
            recoveryImpact: .light,
            materialDisplacement: false,
            highRiskReviewRequired: false,
            unsafeState: false,
            scheduleInstallFailure: false,
            treatyIDs: [],
            sourceRecordIDs: ["SourceRecord.\(prefix).consequence"],
            receiptIDs: ["Receipt.\(prefix).consequence"],
            replayTraceID: "ReplayTrace.\(prefix).consequence",
            whatAmbitionsKnowsRoute: "you://what-ambitions-knows/life-consequence/\(prefix)",
            userVisible: true,
            localOnly: true,
            reversible: true
        )
    }

    func replayOutput(
        prefix: String,
        background: GoldenSliceEndUserBackground,
        intake: GoldenSliceGoalIntake,
        latticeRecord: MultiPathLatticeRecord,
        scheduleRecord: ScheduleInstallRecord,
        consequenceRecord: LifeConsequenceRecord,
        safetyRecord: HighRiskSafetyGateRecord,
        completionProof: GoldenSliceCompletionProof,
        mutation: ReplayMutation
    ) -> GoldenSliceReplayOutput {
        let reflowTraceID = mutation == .wrongReflowTrace ? "ReplayTrace.\(prefix).wrong-reflow" : consequenceRecord.trace.id
        let sourceRecordIDs = background.sourceRecordIDs +
            intake.sourceRecordIDs +
            (scheduleRecord.installReceipt?.sourceRecordIDs ?? []) +
            consequenceRecord.runtimeCoreSegment.sourceRecordIDs +
            safetyRecord.receipt.sourceRecordIDs +
            completionProof.sourceRecordIDs
        let receiptIDs = background.receiptIDs +
            intake.receiptIDs +
            [latticeRecord.selectionReceipt?.id].compactMap { $0 } +
            (scheduleRecord.installReceipt?.receiptIDs ?? []) +
            consequenceRecord.runtimeCoreSegment.receiptIDs +
            [safetyRecord.receipt.id] +
            completionProof.receiptIDs
        let replayTraceIDs = [
            background.replayTraceID,
            intake.replayTraceID,
            latticeRecord.selectionReceipt?.replayTraceID,
            scheduleRecord.trace.id,
            consequenceRecord.trace.id,
            safetyRecord.trace.id,
            completionProof.replayTraceID
        ].compactMap { $0 }

        return GoldenSliceReplayOutput(
            id: "replay.\(prefix)",
            replayedAt: "2026-06-14T19:26:00Z",
            intakeReceiptID: intake.receiptIDs.first ?? "",
            selectedPathReceiptID: latticeRecord.selectionReceipt?.id ?? "missing-path-receipt",
            scheduleReceiptID: scheduleRecord.installReceipt?.id ?? "missing-schedule-receipt",
            completionReceiptID: completionProof.receiptIDs.first ?? "",
            reflowTraceID: reflowTraceID,
            safetyReceiptID: safetyRecord.receipt.id,
            sourceRecordIDs: sourceRecordIDs,
            receiptIDs: receiptIDs,
            replayTraceIDs: replayTraceIDs,
            whatAmbitionsKnowsRoute: "you://what-ambitions-knows/replay/\(prefix)"
        )
    }

    func primaryCandidateID(_ prefix: String) -> String {
        "candidate.\(prefix).primary"
    }

    func backupCandidateID(_ prefix: String) -> String {
        "candidate.\(prefix).backup"
    }
}
