import XCTest
import AmbitionsDesignSystem
@testable import Ambitions

final class StorageInvariantCheckerTests: XCTestCase {
    func testCleanRepositoryStateProducesGreenReadOnlyReport() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let repositories = Self.makeRepositories(store: store)
        let fixture = try XCTUnwrap(GoalEngineFixtures.fixture(id: "clear-timed-self-goal"))
        let goal = try XCTUnwrap(Self.goalFromFixture(fixture))

        try await repositories.goals.saveGoals([goal])

        let report = try await StorageInvariantChecker().check(store: store)

        XCTAssertEqual(report.schemaVersion, storageInvariantCheckerSchemaVersion)
        XCTAssertEqual(report.ledgerSchemaVersion, StorageSchemaVersionLedger.current.schemaVersion)
        XCTAssertEqual(report.issues, [])
        XCTAssertEqual(report.issueCount, 0)
        XCTAssertEqual(report.blockerCount, 0)
        XCTAssertFalse(report.migrationExecutionAllowed)
        XCTAssertTrue(report.isGreen)
    }

    func testCheckerFindsBrokenReferencesBeforeBackupOrRestore() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)

        try await store.write { context in
            context.insert(Self.orphanStepRecord())
            context.insert(Self.orphanEvidenceRecord())
            context.insert(Self.orphanCaptureRecord())
            context.insert(Self.orphanAppStateRecord())
        }

        let report = try await StorageInvariantChecker().check(store: store)
        let issueFields = Set(report.issues.map { "\($0.storedTypeName).\($0.fieldName)" })

        XCTAssertTrue(issueFields.contains("StepRecord.goalID"))
        XCTAssertTrue(issueFields.contains("StepRecord.planID"))
        XCTAssertTrue(issueFields.contains("StepRecord.sectionID"))
        XCTAssertTrue(issueFields.contains("ProgressEvidenceRecord.goalID"))
        XCTAssertTrue(issueFields.contains("ProgressEvidenceRecord.stepID"))
        XCTAssertTrue(issueFields.contains("CaptureRecord.linkedGoalID"))
        XCTAssertTrue(issueFields.contains("AppStateRecord.lastOpenedGoalID"))
        XCTAssertTrue(report.blockerCount >= 7)
        XCTAssertFalse(report.migrationExecutionAllowed)
        XCTAssertFalse(report.isGreen)
    }

    func testCheckerFlagsUnknownRawValuesAsReviewBlockingDegradation() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)

        try await store.write { context in
            context.insert(
                CaptureRecord(
                    id: "capture-unknown-raw",
                    createdAt: "2026-05-08T12:00:00Z",
                    updatedAt: "2026-05-08T12:00:00Z",
                    rawText: "save this",
                    sourceTypeRaw: "future-source",
                    statusRaw: "future-status",
                    linkedGoalID: nil,
                    snapshotData: Data("{}".utf8)
                )
            )
        }

        let report = try await StorageInvariantChecker().check(store: store)
        let rawIssues = report.issues.filter { $0.kind == .unknownRawValue }

        XCTAssertEqual(Set(rawIssues.map(\.fieldName)), ["sourceTypeRaw", "statusRaw"])
        XCTAssertTrue(rawIssues.allSatisfy { $0.severity == .blocker })
        XCTAssertTrue(rawIssues.allSatisfy { $0.degradation?.blocksMigrationClaim == true })
        XCTAssertFalse(report.migrationExecutionAllowed)
    }

    func testCheckerFlagsMalformedEncodedPayloadsAndSnapshots() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)

        try await store.write { context in
            context.insert(Self.malformedGoalRecord())
        }

        let report = try await StorageInvariantChecker().check(store: store)

        XCTAssertTrue(report.issues.contains {
            $0.storedTypeName == "GoalRecord"
                && $0.fieldName == "childGoalIDsData"
                && $0.kind == .malformedEncodedPayload
        })
        XCTAssertTrue(report.issues.contains {
            $0.storedTypeName == "GoalRecord"
                && $0.fieldName == "snapshotData"
                && $0.kind == .malformedSnapshotPayload
        })
        XCTAssertFalse(report.migrationExecutionAllowed)
    }
}

private extension StorageInvariantCheckerTests {
    static func makeRepositories(store: AmbitionsPersistenceStore) -> AppRepositories {
        AppRepositories(
            goals: SwiftDataGoalRepository(store: store),
            drafts: SwiftDataGoalDraftRepository(store: store),
            evidence: SwiftDataProgressEvidenceRepository(store: store),
            feedback: SwiftDataFeedbackEventRepository(store: store),
            captures: SwiftDataCaptureRepository(store: store),
            teaching: SwiftDataGoalTeachingSignalRepository(store: store),
            appState: SwiftDataAppStateRepository(store: store)
        )
    }

    static func goalFromFixture(_ fixture: GoalEngineFixture) -> Goal? {
        switch fixture.result {
        case let .planned(result):
            return Goal(
                schemaVersion: goalEngineSchemaVersion,
                id: result.plan.goalID,
                revision: 1,
                createdAt: GoalEngineFixtures.fixedNow,
                updatedAt: GoalEngineFixtures.fixedNow,
                state: .active,
                title: result.draft.title,
                summary: result.draft.summary,
                mode: result.draft.mode,
                relationshipKind: result.draft.relationshipKind,
                actor: result.draft.actor,
                parentGoalID: result.draft.parentGoalID,
                childGoalIDs: [],
                supportGoalIDs: [],
                tags: result.draft.tags,
                timing: result.draft.timing,
                planningStrategy: result.draft.planningStrategy,
                progressStrategy: result.draft.progressStrategy,
                plan: result.plan
            )
        case let .starterPlanned(result):
            return Goal(
                schemaVersion: goalEngineSchemaVersion,
                id: result.plan.goalID,
                revision: 1,
                createdAt: GoalEngineFixtures.fixedNow,
                updatedAt: GoalEngineFixtures.fixedNow,
                state: .active,
                title: result.draft.title,
                summary: result.draft.summary,
                mode: result.draft.mode,
                relationshipKind: result.draft.relationshipKind,
                actor: result.draft.actor,
                parentGoalID: result.draft.parentGoalID,
                childGoalIDs: [],
                supportGoalIDs: [],
                tags: result.draft.tags,
                timing: result.draft.timing,
                planningStrategy: result.draft.planningStrategy,
                progressStrategy: result.draft.progressStrategy,
                plan: result.plan
            )
        case .clarificationRequired, .blocked:
            return nil
        }
    }

    static func orphanStepRecord() -> StepRecord {
        StepRecord(
            id: "step-orphan",
            goalID: "missing-goal",
            planID: "missing-plan",
            sectionID: "missing-section",
            orderIndex: 0,
            title: "Orphan step",
            summaryText: nil,
            typeRaw: StepType.actionUnit.rawValue,
            stateRaw: StepLifecycleState.planned.rawValue,
            ownerDisplayName: "Taylor",
            ownerOwnershipRaw: "self",
            tempoRaw: GoalTempo.untimed.rawValue,
            timingTypeRaw: TimingType.logWhenDone.rawValue,
            startsOn: nil,
            dueAt: nil,
            targetBy: nil,
            windowStart: nil,
            windowEnd: nil,
            suggestedNextAt: nil,
            repeatEveryDays: nil,
            progressReviewCadenceDays: nil,
            dependencyStepIDsData: Data("[]".utf8),
            successSignalsData: Data("[]".utf8),
            actionabilityData: Data("{}".utf8),
            isOptional: false,
            isRepeatable: false,
            evidenceRequired: false,
            snapshotData: Data("{}".utf8)
        )
    }

    static func orphanEvidenceRecord() -> ProgressEvidenceRecord {
        ProgressEvidenceRecord(
            id: "evidence-orphan",
            goalID: "missing-goal",
            stepID: "missing-step",
            capturedAt: "2026-05-08T12:00:00Z",
            evidenceKindRaw: ProgressEvidenceKind.stepCompleted.rawValue,
            sourceRaw: EvidenceSource.manual.rawValue,
            progressDelta: nil,
            confidenceDelta: nil,
            minutesInvested: nil,
            note: nil,
            snapshotData: Data("{}".utf8)
        )
    }

    static func orphanCaptureRecord() -> CaptureRecord {
        CaptureRecord(
            id: "capture-orphan",
            createdAt: "2026-05-08T12:00:00Z",
            updatedAt: "2026-05-08T12:00:00Z",
            rawText: "connect later",
            sourceTypeRaw: nil,
            statusRaw: CaptureStatus.goalBound.rawValue,
            linkedGoalID: "missing-goal",
            snapshotData: Data("{}".utf8)
        )
    }

    static func orphanAppStateRecord() -> AppStateRecord {
        AppStateRecord(
            id: "default",
            preferredTabRaw: AmbitionsSurface.today.rawValue,
            userDisplayName: "Taylor",
            appearancePreferenceRaw: AppAppearancePreference.system.rawValue,
            accentFamilyRaw: AmbitionAccentFamily.sage.rawValue,
            hasCompletedBootstrap: true,
            lastBootstrapSourceRaw: nil,
            lastBootstrapAt: nil,
            lastSeedVersion: nil,
            lastSeededAt: nil,
            lastOpenedGoalID: "missing-goal",
            snapshotData: Data("{}".utf8)
        )
    }

    static func malformedGoalRecord() -> GoalRecord {
        GoalRecord(
            id: "goal-malformed",
            schemaVersion: goalEngineSchemaVersion,
            revision: 1,
            createdAt: "2026-05-08T12:00:00Z",
            updatedAt: "2026-05-08T12:00:00Z",
            stateRaw: GoalLifecycleState.active.rawValue,
            title: "Malformed",
            summaryText: nil,
            modeRaw: GoalMode.project.rawValue,
            relationshipKindRaw: GoalRelationshipKind.independent.rawValue,
            actorDisplayName: "Taylor",
            actorOwnershipRaw: "self",
            parentGoalID: nil,
            childGoalIDsData: Data("not-json".utf8),
            supportGoalIDsData: Data("[]".utf8),
            tagsData: Data("[]".utf8),
            tempoRaw: GoalTempo.untimed.rawValue,
            timingTypeRaw: TimingType.logWhenDone.rawValue,
            startsOn: nil,
            dueAt: nil,
            targetBy: nil,
            windowStart: nil,
            windowEnd: nil,
            suggestedNextAt: nil,
            repeatEveryDays: nil,
            progressReviewCadenceDays: nil,
            planningStrategyData: Data("{}".utf8),
            progressStrategyData: Data("{}".utf8),
            snapshotData: Data("not-json".utf8)
        )
    }
}
