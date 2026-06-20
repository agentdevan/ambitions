import Foundation

struct AmbitionsRuntimeExperienceSnapshotInput: Sendable, Equatable {
    let runtimeContext: RuntimeContextSnapshot
    let kernelOutput: PrivateLifeRuntimeKernelDecisionOutput?
    let priorityReality: NowPriorityRealitySummary?
    let sourceRecordIDs: [String]
    let receiptIDs: [String]
    let replayTraceIDs: [String]
    let privacyMode: AmbitionsOSExperiencePrivacyMode?

    init(
        runtimeContext: RuntimeContextSnapshot,
        kernelOutput: PrivateLifeRuntimeKernelDecisionOutput? = nil,
        priorityReality: NowPriorityRealitySummary? = nil,
        sourceRecordIDs: [String] = [],
        receiptIDs: [String] = [],
        replayTraceIDs: [String] = [],
        privacyMode: AmbitionsOSExperiencePrivacyMode? = nil
    ) {
        self.runtimeContext = runtimeContext
        self.kernelOutput = kernelOutput
        self.priorityReality = priorityReality
        self.sourceRecordIDs = Self.normalized(sourceRecordIDs)
        self.receiptIDs = Self.normalized(receiptIDs)
        self.replayTraceIDs = Self.normalized(replayTraceIDs)
        self.privacyMode = privacyMode
    }

    private static func normalized(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }
}

struct AmbitionsRuntimeExperienceSnapshot: Sendable, Equatable {
    let semanticInput: AmbitionsOSExperienceSemanticVisualInput
    let compiledVisualState: AmbitionsOSExperienceCompiledVisualState
    let sourceRecordIDs: [String]
    let receiptIDs: [String]
    let replayTraceIDs: [String]
    let inspectionSummary: String
    let noNetworkProof: Bool

    var isInspectableInYou: Bool {
        inspectionSummary.localizedCaseInsensitiveContains("Search Ambitions")
    }
}

struct AmbitionsRuntimeExperienceSnapshotAdapter: Sendable, Equatable {
    private let compiler: AmbitionsOSExperienceCompiler

    init(compiler: AmbitionsOSExperienceCompiler = AmbitionsOSExperienceCompiler()) {
        self.compiler = compiler
    }

    func makeSnapshot(from input: AmbitionsRuntimeExperienceSnapshotInput) -> AmbitionsRuntimeExperienceSnapshot {
        let semanticInput = AmbitionsOSExperienceSemanticVisualInput(
            surface: .today,
            capacity: capacityState(from: input.priorityReality?.capacity),
            protectedPressure: protectedPressure(from: input.priorityReality?.overallPressure),
            closureResidue: closureResidue(from: input),
            sourceFreshness: sourceFreshness(from: input),
            proofStrength: proofStrength(from: input),
            goalPull: goalPull(from: input),
            recoveryNeed: recoveryNeed(from: input.priorityReality?.recoveryState),
            privacyMode: privacyMode(from: input)
        )
        return AmbitionsRuntimeExperienceSnapshot(
            semanticInput: semanticInput,
            compiledVisualState: compiler.compile(semanticInput),
            sourceRecordIDs: input.sourceRecordIDs,
            receiptIDs: input.receiptIDs,
            replayTraceIDs: input.replayTraceIDs,
            inspectionSummary: inspectionSummary(for: input),
            noNetworkProof: noNetworkProof(for: input.runtimeContext)
        )
    }

    private func capacityState(from pressure: NowPressureLevel?) -> AmbitionsOSExperienceCapacityState {
        switch pressure {
        case .some(.none), .some(.low):
            return .spacious
        case .some(.moderate):
            return .balanced
        case .some(.elevated):
            return .tight
        case .some(.high), .some(.critical):
            return .depleted
        case nil:
            return .balanced
        }
    }

    private func protectedPressure(from pressure: NowPressureLevel?) -> AmbitionsOSExperienceProtectedPressure {
        switch pressure {
        case .some(.high), .some(.critical):
            return .conflict
        case .some(.elevated):
            return .reserved
        case .some(.none), .some(.low), .some(.moderate), nil:
            return .clear
        }
    }

    private func closureResidue(from input: AmbitionsRuntimeExperienceSnapshotInput) -> AmbitionsOSExperienceClosureResidue {
        if input.priorityReality?.recoveryState == .needsRecovery || input.priorityReality?.recoveryState == .recovering || input.priorityReality?.recoveryState == .blocked {
            return .recovery
        }
        if input.receiptIDs.isEmpty == false || input.replayTraceIDs.isEmpty == false {
            return .light
        }
        return .none
    }

    private func sourceFreshness(from input: AmbitionsRuntimeExperienceSnapshotInput) -> AmbitionsOSExperienceSourceFreshness {
        if input.runtimeContext.knowledgeProviderStatuses.contains(where: { $0.availability == .unsupported }) {
            return .disputed
        }
        if input.runtimeContext.knowledgeProviderStatuses.contains(where: { $0.availability == .providerUnavailable }) {
            return .stale
        }
        if input.sourceRecordIDs.isEmpty && input.runtimeContext.memorySummary.evidenceCount == 0 {
            return .aging
        }
        return .current
    }

    private func proofStrength(from input: AmbitionsRuntimeExperienceSnapshotInput) -> AmbitionsOSExperienceProofStrength {
        if input.replayTraceIDs.isEmpty == false {
            return .decisive
        }
        if input.receiptIDs.isEmpty == false || input.sourceRecordIDs.isEmpty == false {
            return .strong
        }
        if input.kernelOutput?.hasRecommendationTrace == true {
            return .supporting
        }
        return .absent
    }

    private func goalPull(from input: AmbitionsRuntimeExperienceSnapshotInput) -> AmbitionsOSExperienceGoalPull {
        if input.kernelOutput?.canDriveRecommendation == true || input.priorityReality?.overallPressure == .critical {
            return .urgent
        }
        if input.runtimeContext.memorySummary.goalCount > 0 || input.runtimeContext.memorySummary.draftCount > 0 {
            return .present
        }
        return .neutral
    }

    private func recoveryNeed(from state: NowRecoveryState?) -> AmbitionsOSExperienceRecoveryNeed {
        switch state {
        case .needsRecovery, .blocked:
            return .required
        case .watch, .recovering:
            return .gentle
        case .stable, nil:
            return .none
        }
    }

    private func privacyMode(from input: AmbitionsRuntimeExperienceSnapshotInput) -> AmbitionsOSExperiencePrivacyMode {
        if let privacyMode = input.privacyMode {
            return privacyMode
        }
        return input.runtimeContext.capabilities.privateLifeRuntimeBoundary.isLocalOnly ? .localOnly : .standard
    }

    private func noNetworkProof(for context: RuntimeContextSnapshot) -> Bool {
        context.capabilities.privateLifeRuntimeBoundary.isLocalOnly &&
            context.capabilities.hasRemoteIntelligenceBackend == false &&
            context.syncStatus.backendKind == .localOnly &&
            context.knowledgeProviderStatuses.allSatisfy { $0.runtimeTrustPosture == .localOnly }
    }

    private func inspectionSummary(for input: AmbitionsRuntimeExperienceSnapshotInput) -> String {
        [
            "You / Search Ambitions can inspect this runtime snapshot.",
            "Source IDs: \(input.sourceRecordIDs.joined(separator: ",").ifEmpty("none")).",
            "Receipt IDs: \(input.receiptIDs.joined(separator: ",").ifEmpty("none")).",
            "Reason IDs: \(input.replayTraceIDs.joined(separator: ",").ifEmpty("none"))."
        ]
        .joined(separator: " ")
    }
}

private extension String {
    func ifEmpty(_ fallback: String) -> String {
        isEmpty ? fallback : self
    }
}
