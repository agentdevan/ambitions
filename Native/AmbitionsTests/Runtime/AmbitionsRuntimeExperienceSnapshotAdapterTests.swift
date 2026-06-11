import XCTest
@testable import Ambitions

final class AmbitionsRuntimeExperienceSnapshotAdapterTests: XCTestCase {
    private let adapter = AmbitionsRuntimeExperienceSnapshotAdapter()

    func testAdapterMapsRuntimeFactsIntoDeterministicExperienceInput() {
        let input = AmbitionsRuntimeExperienceSnapshotInput(
            runtimeContext: runtimeContext(knowledgeAvailability: .available),
            priorityReality: NowPriorityRealitySummary(
                overallPressure: .high,
                capacity: .critical,
                recoveryState: .needsRecovery,
                summary: "Capacity is protected and recovery is required."
            ),
            sourceRecordIDs: ["source-1"],
            receiptIDs: ["receipt-1"],
            replayTraceIDs: ["trace-1"]
        )

        let first = adapter.makeSnapshot(from: input)
        let second = adapter.makeSnapshot(from: input)

        XCTAssertEqual(first, second)
        XCTAssertEqual(first.semanticInput.capacity, .depleted)
        XCTAssertEqual(first.semanticInput.protectedPressure, .conflict)
        XCTAssertEqual(first.semanticInput.closureResidue, .recovery)
        XCTAssertEqual(first.semanticInput.sourceFreshness, .current)
        XCTAssertEqual(first.semanticInput.proofStrength, .decisive)
        XCTAssertEqual(first.semanticInput.recoveryNeed, .required)
        XCTAssertEqual(first.semanticInput.privacyMode, .localOnly)
        XCTAssertEqual(first.compiledVisualState.livingState, .sensitive)
        XCTAssertTrue(first.noNetworkProof)
        XCTAssertTrue(first.isInspectableInYou)
    }

    func testUnavailableSourceRecordPostureCannotMasqueradeAsFreshIntelligence() {
        let snapshot = adapter.makeSnapshot(
            from: AmbitionsRuntimeExperienceSnapshotInput(
                runtimeContext: runtimeContext(knowledgeAvailability: .providerUnavailable),
                priorityReality: NowPriorityRealitySummary(
                    overallPressure: .moderate,
                    capacity: .moderate,
                    recoveryState: .stable,
                    summary: "Moderate pressure with unavailable knowledge provider."
                ),
                sourceRecordIDs: ["source-stale"]
            )
        )

        XCTAssertEqual(snapshot.semanticInput.sourceFreshness, .stale)
        XCTAssertEqual(snapshot.compiledVisualState.livingState, .sensitive)
        XCTAssertTrue(snapshot.compiledVisualState.semanticCauseIDs.contains("source_freshness.stale"))
        XCTAssertTrue(snapshot.inspectionSummary.contains("Source IDs: source-stale"))
    }

    func testAdapterPreservesLocalFirstNetworkBoundary() {
        let snapshot = adapter.makeSnapshot(
            from: AmbitionsRuntimeExperienceSnapshotInput(
                runtimeContext: runtimeContext(knowledgeAvailability: .localOnlyMode),
                sourceRecordIDs: ["source-local"],
                receiptIDs: ["receipt-local"],
                replayTraceIDs: ["trace-local"],
                privacyMode: .sensitive
            )
        )

        XCTAssertTrue(snapshot.noNetworkProof)
        XCTAssertEqual(snapshot.semanticInput.privacyMode, .sensitive)
        XCTAssertTrue(snapshot.inspectionSummary.contains("Receipt IDs: receipt-local"))
        XCTAssertTrue(snapshot.inspectionSummary.contains("Reason IDs: trace-local"))
    }
}

private extension AmbitionsRuntimeExperienceSnapshotAdapterTests {
    func runtimeContext(
        knowledgeAvailability: KnowledgeProviderAvailability,
        goals: [Goal] = [],
        drafts: [PersistedGoalDraft] = [],
        evidence: [ProgressEvidence] = [],
        feedback: [GoalFeedbackEvent] = [],
        captures: [Capture] = []
    ) -> RuntimeContextSnapshot {
        RuntimeContextSnapshot(
            clientContext: .iphoneApp,
            capabilities: .currentLocalRuntime,
            syncStatus: SyncCapabilityStatus(
                backendKind: .localOnly,
                trustPosture: .localOnly,
                availability: .unavailable,
                detail: "Local-only test sync status."
            ),
            knowledgeProviderStatuses: [
                KnowledgeProviderStatus(
                    provider: KnowledgeProviderDescriptor(
                        id: "local-provider",
                        type: .systemFallback,
                        displayName: "Local Provider"
                    ),
                    availability: knowledgeAvailability,
                    detail: "Local provider status.",
                    runtimeTrustPosture: .localOnly
                )
            ],
            memorySummary: RuntimeMemorySummary(
                memory: RuntimeMemorySnapshot(
                    goals: goals,
                    drafts: drafts,
                    evidence: evidence,
                    feedback: feedback,
                    captures: captures,
                    appState: .default
                )
            ),
            externalSurfaceSnapshot: nil
        )
    }
}
