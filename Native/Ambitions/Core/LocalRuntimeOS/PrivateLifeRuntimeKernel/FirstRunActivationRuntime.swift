import Foundation

enum FirstRunActivationState: String, Sendable, Equatable, Hashable {
    case ready
    case blocked
}

enum FirstRunActivationIssue: String, Sendable, Equatable, Hashable, CaseIterable {
    case goldenProgramNotReady = "golden_program_not_ready"
    case goldenSliceMissing = "golden_slice_missing"
    case firstGoalFlowMissing = "first_goal_flow_missing"
    case firstGoalMissing = "first_goal_missing"
    case firstGoalNotFromGoldenSlice = "first_goal_not_from_golden_slice"
    case recommendedStepMissing = "recommended_step_missing"
    case recommendedStepNotVisible = "recommended_step_not_visible"
    case recommendedStepNotFromGoldenSlice = "recommended_step_not_from_golden_slice"
    case recoveryOptionMissing = "recovery_option_missing"
    case recoveryOptionNotTiedToGoldenSlice = "recovery_option_not_tied_to_golden_slice"
    case recoveryOptionNotSafe = "recovery_option_not_safe"
    case activationReceiptMissing = "activation_receipt_missing"
    case activationReplayMissing = "activation_replay_missing"
    case activationInspectionRouteMissing = "activation_inspection_route_missing"
    case calmContinuityMissing = "calm_continuity_missing"
    case genericOnboardingTheater = "generic_onboarding_theater"
    case nonLocalRuntimeBoundary = "non_local_runtime_boundary"
}

struct FirstRunActivationInput: Sendable, Equatable {
    let goldenProgram: GoldenVerticalSliceProgramRecord
    let selectedSliceID: String?
    let onboardingChoice: OnboardingEntryChoice
    let activatedAt: String
    let continuitySummaryOverride: String?
    let localOnly: Bool

    init(
        goldenProgram: GoldenVerticalSliceProgramRecord,
        selectedSliceID: String? = nil,
        onboardingChoice: OnboardingEntryChoice = .createFirstGoal,
        activatedAt: String,
        continuitySummaryOverride: String? = nil,
        localOnly: Bool = true
    ) {
        self.goldenProgram = goldenProgram
        self.selectedSliceID = Self.normalizedOptional(selectedSliceID)
        self.onboardingChoice = onboardingChoice
        self.activatedAt = activatedAt.trimmingCharacters(in: .whitespacesAndNewlines)
        self.continuitySummaryOverride = Self.normalizedOptional(continuitySummaryOverride)
        self.localOnly = localOnly
    }

    private static func normalizedOptional(_ value: String?) -> String? {
        guard let normalized = value?.trimmingCharacters(in: .whitespacesAndNewlines), normalized.isEmpty == false else {
            return nil
        }
        return normalized
    }
}

struct FirstRunActivationGoal: Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let title: String
    let sourceRecordIDs: [String]
    let receiptIDs: [String]
    let replayTraceIDs: [String]
    let whatAmbitionsKnowsRoute: String?

    var isInspectable: Bool {
        id.isEmpty == false &&
            title.isEmpty == false &&
            sourceRecordIDs.isEmpty == false &&
            receiptIDs.isEmpty == false &&
            replayTraceIDs.isEmpty == false &&
            whatAmbitionsKnowsRoute != nil
    }
}

struct FirstRunActivationRecommendedStep: Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let title: String
    let sourceRecordIDs: [String]
    let receiptIDs: [String]
    let replayTraceID: String?
    let whatAmbitionsKnowsRoute: String?
    let canShow: Bool

    var isInspectable: Bool {
        id.isEmpty == false &&
            title.isEmpty == false &&
            sourceRecordIDs.isEmpty == false &&
            receiptIDs.isEmpty == false &&
            replayTraceID != nil &&
            whatAmbitionsKnowsRoute != nil &&
            canShow
    }
}

struct FirstRunActivationRecoveryOption: Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let kind: StepElasticityActionKind
    let title: String
    let summary: String
    let reason: String
    let sourceRecordIDs: [String]
    let receiptIDs: [String]
    let replayTraceID: String?
    let whatAmbitionsKnowsRoute: String?
    let sourceNodeID: String
    let recoverySafe: Bool
    let preservesProof: Bool
    let localOnly: Bool
    let silentlyMutatesPlan: Bool

    var isInspectable: Bool {
        id.isEmpty == false &&
            title.isEmpty == false &&
            summary.isEmpty == false &&
            reason.isEmpty == false &&
            sourceNodeID.isEmpty == false &&
            sourceRecordIDs.isEmpty == false &&
            receiptIDs.isEmpty == false &&
            replayTraceID != nil &&
            whatAmbitionsKnowsRoute != nil &&
            recoverySafe &&
            preservesProof &&
            localOnly &&
            silentlyMutatesPlan == false
    }
}

struct FirstRunActivationReceipt: Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let activatedAt: String
    let firstGoalID: String
    let recommendedStepID: String
    let recoveryOptionID: String
    let continuitySummary: String
    let topLevelTabs: [String]
    let captureRole: String
    let sourceRecordIDs: [String]
    let receiptIDs: [String]
    let replayTraceIDs: [String]
    let whatAmbitionsKnowsRoute: String?
    let localOnly: Bool

    var isInspectable: Bool {
        id.isEmpty == false &&
            activatedAt.isEmpty == false &&
            firstGoalID.isEmpty == false &&
            recommendedStepID.isEmpty == false &&
            recoveryOptionID.isEmpty == false &&
            continuitySummary.isEmpty == false &&
            topLevelTabs == ["Today", "Goals", "Time", "You"] &&
            captureRole == "global action" &&
            sourceRecordIDs.isEmpty == false &&
            receiptIDs.isEmpty == false &&
            replayTraceIDs.isEmpty == false &&
            whatAmbitionsKnowsRoute != nil &&
            localOnly
    }
}

struct FirstRunActivationRecord: Sendable, Equatable, Identifiable {
    let id: String
    let state: FirstRunActivationState
    let selectedSliceID: String?
    let firstGoal: FirstRunActivationGoal?
    let recommendedStep: FirstRunActivationRecommendedStep?
    let recoveryOption: FirstRunActivationRecoveryOption?
    let receipt: FirstRunActivationReceipt?
    let issues: [FirstRunActivationIssue]

    var canActivateFirstRun: Bool {
        state == .ready &&
            issues.isEmpty &&
            firstGoal?.isInspectable == true &&
            recommendedStep?.isInspectable == true &&
            recoveryOption?.isInspectable == true &&
            receipt?.isInspectable == true
    }
}

struct FirstRunActivationRuntime: Sendable, Equatable {
    func evaluate(_ input: FirstRunActivationInput) -> FirstRunActivationRecord {
        let selectedSlice = selectSlice(from: input)
        let firstGoal = selectedSlice.map(firstGoal(from:))
        let recommendedStep = selectedSlice.map(recommendedStep(from:))
        let recoveryOption = selectedSlice.flatMap(recoveryOption(from:))
        let receipt = makeReceipt(
            input: input,
            slice: selectedSlice,
            firstGoal: firstGoal,
            recommendedStep: recommendedStep,
            recoveryOption: recoveryOption
        )
        let issues = sortedIssues(
            issues(
                input: input,
                slice: selectedSlice,
                firstGoal: firstGoal,
                recommendedStep: recommendedStep,
                recoveryOption: recoveryOption,
                receipt: receipt
            )
        )
        return FirstRunActivationRecord(
            id: stableIdentifier(
                prefix: "first-run-activation.record",
                components: [
                    input.activatedAt,
                    selectedSlice?.id ?? "missing-slice",
                    issues.map(\.rawValue).joined(separator: ",")
                ]
            ),
            state: issues.isEmpty ? .ready : .blocked,
            selectedSliceID: selectedSlice?.id,
            firstGoal: firstGoal,
            recommendedStep: recommendedStep,
            recoveryOption: recoveryOption,
            receipt: receipt,
            issues: issues
        )
    }
}
