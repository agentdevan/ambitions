import Foundation

enum GoldenVerticalSliceState: String, Sendable, Equatable, Hashable {
    case ready
    case blocked
}

enum GoldenVerticalSliceIssue: String, Sendable, Equatable, Hashable, CaseIterable {
    case requiresExactlyTwoSlices = "requires_exactly_two_slices"
    case duplicateEndUserBackground = "duplicate_end_user_background"
    case duplicateGoalReference = "duplicate_goal_reference"
    case intakeMissing = "intake_missing"
    case backgroundMissing = "background_missing"
    case notMusicReleaseGoal = "not_music_release_goal"
    case anyGoalBlocked = "any_goal_blocked"
    case stepQualityBlocked = "step_quality_blocked"
    case pathSelectionBlocked = "path_selection_blocked"
    case graphCompilerBlocked = "graph_compiler_blocked"
    case elasticityBlocked = "elasticity_blocked"
    case scheduleInstallBlocked = "schedule_install_blocked"
    case consequenceReflowBlocked = "consequence_reflow_blocked"
    case highRiskSafetyBlocked = "high_risk_safety_blocked"
    case runtimeCoreBlocked = "runtime_core_blocked"
    case completionProofMissing = "completion_proof_missing"
    case completionDoesNotMatchRecommendedStep = "completion_does_not_match_recommended_step"
    case replayOutputMissing = "replay_output_missing"
    case replayOutputDoesNotMatchRuntime = "replay_output_does_not_match_runtime"
    case optionalShareProofBlocked = "optional_share_proof_blocked"
    case backgroundNotCarriedIntoReplay = "background_not_carried_into_replay"
    case personalizationNotDistinct = "personalization_not_distinct"
    case nonLocalRuntimeBoundary = "non_local_runtime_boundary"
}

struct GoldenSliceEndUserBackground: Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let displayName: String
    let lifeContextSummary: String
    let capacityProfile: String
    let creativeConstraint: String
    let supportPreference: String
    let sourceRecordIDs: [String]
    let receiptIDs: [String]
    let replayTraceID: String?
    let whatAmbitionsKnowsRoute: String?

    init(
        id: String,
        displayName: String,
        lifeContextSummary: String,
        capacityProfile: String,
        creativeConstraint: String,
        supportPreference: String,
        sourceRecordIDs: [String],
        receiptIDs: [String],
        replayTraceID: String?,
        whatAmbitionsKnowsRoute: String?
    ) {
        self.id = Self.normalizedID(id)
        self.displayName = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        self.lifeContextSummary = lifeContextSummary.trimmingCharacters(in: .whitespacesAndNewlines)
        self.capacityProfile = capacityProfile.trimmingCharacters(in: .whitespacesAndNewlines)
        self.creativeConstraint = creativeConstraint.trimmingCharacters(in: .whitespacesAndNewlines)
        self.supportPreference = supportPreference.trimmingCharacters(in: .whitespacesAndNewlines)
        self.sourceRecordIDs = Self.normalizedIDs(sourceRecordIDs)
        self.receiptIDs = Self.normalizedIDs(receiptIDs)
        self.replayTraceID = Self.normalizedOptional(replayTraceID)
        self.whatAmbitionsKnowsRoute = Self.normalizedOptional(whatAmbitionsKnowsRoute)
    }

    var isInspectable: Bool {
        id.isEmpty == false &&
            displayName.isEmpty == false &&
            lifeContextSummary.isEmpty == false &&
            capacityProfile.isEmpty == false &&
            creativeConstraint.isEmpty == false &&
            supportPreference.isEmpty == false &&
            sourceRecordIDs.isEmpty == false &&
            receiptIDs.isEmpty == false &&
            replayTraceID != nil &&
            whatAmbitionsKnowsRoute != nil
    }

    var personalizationFingerprint: String {
        Self.stableIdentifier(
            prefix: "golden-slice.background",
            components: [id, lifeContextSummary, capacityProfile, creativeConstraint, supportPreference]
        )
    }

    static func normalizedID(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static func normalizedIDs(_ values: [String]) -> [String] {
        Array(Set(values.map(normalizedID).filter { $0.isEmpty == false })).sorted()
    }

    static func normalizedOptional(_ value: String?) -> String? {
        guard let normalized = value?.trimmingCharacters(in: .whitespacesAndNewlines), normalized.isEmpty == false else {
            return nil
        }
        return normalized
    }

    static func stableIdentifier(prefix: String, components: [String]) -> String {
        let payload = components
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
            .filter { $0.isEmpty == false }
            .joined(separator: "|")
        let normalized = payload
            .replacingOccurrences(of: "://", with: "-")
            .replacingOccurrences(of: "/", with: "-")
            .replacingOccurrences(of: " ", with: "-")
            .replacingOccurrences(of: "_", with: "-")
            .components(separatedBy: CharacterSet.alphanumerics.union(CharacterSet(charactersIn: ".-")).inverted)
            .filter { $0.isEmpty == false }
            .joined(separator: "-")
        return "\(prefix).\(normalized)"
    }
}

struct GoldenSliceGoalIntake: Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let rawGoalText: String
    let normalizedGoal: String
    let intakeSurface: String
    let capturedAt: String
    let sourceRecordIDs: [String]
    let receiptIDs: [String]
    let replayTraceID: String?
    let whatAmbitionsKnowsRoute: String?

    init(
        id: String,
        rawGoalText: String,
        normalizedGoal: String,
        intakeSurface: String,
        capturedAt: String,
        sourceRecordIDs: [String],
        receiptIDs: [String],
        replayTraceID: String?,
        whatAmbitionsKnowsRoute: String?
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.rawGoalText = rawGoalText.trimmingCharacters(in: .whitespacesAndNewlines)
        self.normalizedGoal = normalizedGoal.trimmingCharacters(in: .whitespacesAndNewlines)
        self.intakeSurface = intakeSurface.trimmingCharacters(in: .whitespacesAndNewlines)
        self.capturedAt = capturedAt.trimmingCharacters(in: .whitespacesAndNewlines)
        self.sourceRecordIDs = GoldenSliceEndUserBackground.normalizedIDs(sourceRecordIDs)
        self.receiptIDs = GoldenSliceEndUserBackground.normalizedIDs(receiptIDs)
        self.replayTraceID = GoldenSliceEndUserBackground.normalizedOptional(replayTraceID)
        self.whatAmbitionsKnowsRoute = GoldenSliceEndUserBackground.normalizedOptional(whatAmbitionsKnowsRoute)
    }

    var isInspectable: Bool {
        id.isEmpty == false &&
            rawGoalText.isEmpty == false &&
            normalizedGoal.isEmpty == false &&
            intakeSurface.isEmpty == false &&
            capturedAt.isEmpty == false &&
            sourceRecordIDs.isEmpty == false &&
            receiptIDs.isEmpty == false &&
            replayTraceID != nil &&
            whatAmbitionsKnowsRoute != nil
    }

    var isMusicReleaseGoal: Bool {
        let normalized = "\(rawGoalText) \(normalizedGoal)"
            .lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { $0.isEmpty == false }
        let terms = Set(normalized)
        return terms.contains("release") &&
            (terms.contains("music") || terms.contains("song") || terms.contains("single") || terms.contains("album") || terms.contains("track"))
    }
}

struct GoldenSliceCompletionProof: Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let completedStepID: String
    let completedAt: String
    let proofSummary: String
    let sourceRecordIDs: [String]
    let receiptIDs: [String]
    let replayTraceID: String?
    let whatAmbitionsKnowsRoute: String?
    let localOnly: Bool

    init(
        id: String,
        completedStepID: String,
        completedAt: String,
        proofSummary: String,
        sourceRecordIDs: [String],
        receiptIDs: [String],
        replayTraceID: String?,
        whatAmbitionsKnowsRoute: String?,
        localOnly: Bool = true
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.completedStepID = completedStepID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.completedAt = completedAt.trimmingCharacters(in: .whitespacesAndNewlines)
        self.proofSummary = proofSummary.trimmingCharacters(in: .whitespacesAndNewlines)
        self.sourceRecordIDs = GoldenSliceEndUserBackground.normalizedIDs(sourceRecordIDs)
        self.receiptIDs = GoldenSliceEndUserBackground.normalizedIDs(receiptIDs)
        self.replayTraceID = GoldenSliceEndUserBackground.normalizedOptional(replayTraceID)
        self.whatAmbitionsKnowsRoute = GoldenSliceEndUserBackground.normalizedOptional(whatAmbitionsKnowsRoute)
        self.localOnly = localOnly
    }

    var isInspectable: Bool {
        id.isEmpty == false &&
            completedStepID.isEmpty == false &&
            completedAt.isEmpty == false &&
            proofSummary.isEmpty == false &&
            sourceRecordIDs.isEmpty == false &&
            receiptIDs.isEmpty == false &&
            replayTraceID != nil &&
            whatAmbitionsKnowsRoute != nil &&
            localOnly
    }
}

struct GoldenSliceOptionalShareProof: Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let audienceSummary: String
    let redactionSummary: String
    let sourceRecordIDs: [String]
    let receiptIDs: [String]
    let replayTraceID: String?
    let whatAmbitionsKnowsRoute: String?
    let userApproved: Bool
    let localOnly: Bool

    init(
        id: String,
        audienceSummary: String,
        redactionSummary: String,
        sourceRecordIDs: [String],
        receiptIDs: [String],
        replayTraceID: String?,
        whatAmbitionsKnowsRoute: String?,
        userApproved: Bool,
        localOnly: Bool = true
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.audienceSummary = audienceSummary.trimmingCharacters(in: .whitespacesAndNewlines)
        self.redactionSummary = redactionSummary.trimmingCharacters(in: .whitespacesAndNewlines)
        self.sourceRecordIDs = GoldenSliceEndUserBackground.normalizedIDs(sourceRecordIDs)
        self.receiptIDs = GoldenSliceEndUserBackground.normalizedIDs(receiptIDs)
        self.replayTraceID = GoldenSliceEndUserBackground.normalizedOptional(replayTraceID)
        self.whatAmbitionsKnowsRoute = GoldenSliceEndUserBackground.normalizedOptional(whatAmbitionsKnowsRoute)
        self.userApproved = userApproved
        self.localOnly = localOnly
    }

    var isInspectable: Bool {
        id.isEmpty == false &&
            audienceSummary.isEmpty == false &&
            redactionSummary.isEmpty == false &&
            sourceRecordIDs.isEmpty == false &&
            receiptIDs.isEmpty == false &&
            replayTraceID != nil &&
            whatAmbitionsKnowsRoute != nil &&
            userApproved &&
            localOnly
    }
}

struct GoldenSliceReplayOutput: Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let replayedAt: String
    let intakeReceiptID: String
    let selectedPathReceiptID: String
    let scheduleReceiptID: String
    let completionReceiptID: String
    let reflowTraceID: String
    let safetyReceiptID: String
    let sourceRecordIDs: [String]
    let receiptIDs: [String]
    let replayTraceIDs: [String]
    let whatAmbitionsKnowsRoute: String?
    let localOnly: Bool

    init(
        id: String,
        replayedAt: String,
        intakeReceiptID: String,
        selectedPathReceiptID: String,
        scheduleReceiptID: String,
        completionReceiptID: String,
        reflowTraceID: String,
        safetyReceiptID: String,
        sourceRecordIDs: [String],
        receiptIDs: [String],
        replayTraceIDs: [String],
        whatAmbitionsKnowsRoute: String?,
        localOnly: Bool = true
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.replayedAt = replayedAt.trimmingCharacters(in: .whitespacesAndNewlines)
        self.intakeReceiptID = intakeReceiptID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.selectedPathReceiptID = selectedPathReceiptID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.scheduleReceiptID = scheduleReceiptID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.completionReceiptID = completionReceiptID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.reflowTraceID = reflowTraceID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.safetyReceiptID = safetyReceiptID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.sourceRecordIDs = GoldenSliceEndUserBackground.normalizedIDs(sourceRecordIDs)
        self.receiptIDs = GoldenSliceEndUserBackground.normalizedIDs(receiptIDs)
        self.replayTraceIDs = GoldenSliceEndUserBackground.normalizedIDs(replayTraceIDs)
        self.whatAmbitionsKnowsRoute = GoldenSliceEndUserBackground.normalizedOptional(whatAmbitionsKnowsRoute)
        self.localOnly = localOnly
    }

    var isInspectable: Bool {
        id.isEmpty == false &&
            replayedAt.isEmpty == false &&
            intakeReceiptID.isEmpty == false &&
            selectedPathReceiptID.isEmpty == false &&
            scheduleReceiptID.isEmpty == false &&
            completionReceiptID.isEmpty == false &&
            reflowTraceID.isEmpty == false &&
            safetyReceiptID.isEmpty == false &&
            sourceRecordIDs.isEmpty == false &&
            receiptIDs.isEmpty == false &&
            replayTraceIDs.isEmpty == false &&
            whatAmbitionsKnowsRoute != nil &&
            localOnly
    }
}
