import Foundation

let ambitionsOSVerticalSliceProofSchemaVersion = "ambitionsos_vertical_slice_proof.native.v1"

enum AmbitionsOSVerticalSliceProofIssue: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case captureMutationMismatch = "capture_mutation_mismatch"
    case eventLedgerMismatch = "event_ledger_mismatch"
    case commandReceiptMismatch = "command_receipt_mismatch"
    case closureReceiptMismatch = "closure_receipt_mismatch"
    case sourceClaimNotInspectable = "source_claim_not_inspectable"
    case proofTrustReceiptNotClosable = "proof_trust_receipt_not_closable"
    case startHereRecommendationInvalid = "start_here_recommendation_invalid"
    case startHereTraceIncomplete = "start_here_trace_incomplete"
    case replayNotIdempotent = "replay_not_idempotent"
    case calendarWriteClaimed = "calendar_write_claimed"
    case externalCloudDependencyClaimed = "external_cloud_dependency_claimed"
    case silentMutationClaimed = "silent_mutation_claimed"
    case releaseAccessibilityDeviceClaimed = "release_accessibility_device_claimed"
}

struct AmbitionsOSVerticalSliceProofConstraints: Codable, Sendable, Equatable, Hashable {
    let noCalendarWrite: Bool
    let noExternalCloudDependency: Bool
    let noSilentMutation: Bool
    let noReleaseAccessibilityDeviceClaim: Bool

    init(
        noCalendarWrite: Bool = true,
        noExternalCloudDependency: Bool = true,
        noSilentMutation: Bool = true,
        noReleaseAccessibilityDeviceClaim: Bool = true
    ) {
        self.noCalendarWrite = noCalendarWrite
        self.noExternalCloudDependency = noExternalCloudDependency
        self.noSilentMutation = noSilentMutation
        self.noReleaseAccessibilityDeviceClaim = noReleaseAccessibilityDeviceClaim
    }

    var isWellFormed: Bool {
        noCalendarWrite &&
            noExternalCloudDependency &&
            noSilentMutation &&
            noReleaseAccessibilityDeviceClaim
    }
}

struct AmbitionsOSVerticalSliceProofValidation: Codable, Sendable, Equatable, Hashable {
    let issues: [AmbitionsOSVerticalSliceProofIssue]

    init(issues: [AmbitionsOSVerticalSliceProofIssue]) {
        self.issues = Array(Set(issues)).sorted { $0.rawValue < $1.rawValue }
    }

    var isGreen: Bool {
        issues.isEmpty
    }
}

struct AmbitionsOSVerticalSliceProofReport: Codable, Sendable, Equatable, Identifiable {
    let id: String
    let command: AmbitionsCommand
    let capture: Capture
    let captureEvent: EventLedgerEntry
    let commandResult: AmbitionsCommandExecutionResult
    let commandReceipt: ActionReceipt
    let closureReceipt: ActionReceipt
    let sourceClaim: AmbitionsOSSourceTruthClaim
    let proofTrustReceipt: AmbitionsOSProofTrustReceipt
    let startHereRecommendation: AmbitionsOSStartHereRecommendation
    let startHereTrace: RecommendationTrace
    let replayResult: AmbitionsCommandExecutionResult
    let constraints: AmbitionsOSVerticalSliceProofConstraints
    let schemaVersion: String

    init(
        command: AmbitionsCommand,
        capture: Capture,
        captureEvent: EventLedgerEntry,
        commandResult: AmbitionsCommandExecutionResult,
        commandReceipt: ActionReceipt,
        closureReceipt: ActionReceipt,
        sourceClaim: AmbitionsOSSourceTruthClaim,
        proofTrustReceipt: AmbitionsOSProofTrustReceipt,
        startHereRecommendation: AmbitionsOSStartHereRecommendation,
        startHereTrace: RecommendationTrace,
        replayResult: AmbitionsCommandExecutionResult,
        constraints: AmbitionsOSVerticalSliceProofConstraints = AmbitionsOSVerticalSliceProofConstraints(),
        schemaVersion: String = ambitionsOSVerticalSliceProofSchemaVersion
    ) {
        self.id = command.id
        self.command = command
        self.capture = capture
        self.captureEvent = captureEvent
        self.commandResult = commandResult
        self.commandReceipt = commandReceipt
        self.closureReceipt = closureReceipt
        self.sourceClaim = sourceClaim
        self.proofTrustReceipt = proofTrustReceipt
        self.startHereRecommendation = startHereRecommendation
        self.startHereTrace = startHereTrace
        self.replayResult = replayResult
        self.constraints = constraints
        self.schemaVersion = schemaVersion
    }

    var replayOutcome: LedgerReplayOutcome {
        LedgerReplayOutcome(
            idempotencyKey: LedgerIdempotencyKey(command.id),
            decision: LedgerReplayDecision(rawValue: replayResult.metadata["replayDecision"] ?? "") ?? .lookupUnavailable,
            doubleApplyDisposition: LedgerDoubleApplyDisposition(rawValue: replayResult.metadata["doubleApplyDisposition"] ?? "") ?? .skipUnverifiedMutation,
            receiptSummary: replayResult.summary
        )
    }

    var validation: AmbitionsOSVerticalSliceProofValidation {
        var issues: [AmbitionsOSVerticalSliceProofIssue] = []

        if command.kind != .quickCapture {
            issues.append(.captureMutationMismatch)
        }
        if commandResult.status != .succeeded {
            issues.append(.captureMutationMismatch)
        }
        if captureEvent.kind != .captureCreated || captureEvent.captureID != capture.id {
            issues.append(.eventLedgerMismatch)
        }
        if commandReceipt.affectedObjects.contains(where: { $0.kind == .capture && $0.id == capture.id }) == false {
            issues.append(.commandReceiptMismatch)
        }
        if commandReceipt.why?.eventLedgerEntryIDs.contains(captureEvent.id) != true {
            issues.append(.commandReceiptMismatch)
        }
        if closureReceipt.isWellFormed == false {
            issues.append(.closureReceiptMismatch)
        }
        if sourceClaim.canDriveSourceSensitiveRecommendation == false {
            issues.append(.sourceClaimNotInspectable)
        }
        if proofTrustReceipt.canCloseProofTrustGate == false {
            issues.append(.proofTrustReceiptNotClosable)
        }
        if AmbitionsOSStartHereRecommendationValidator().validate(startHereRecommendation).isEmpty == false {
            issues.append(.startHereRecommendationInvalid)
        }
        if startHereTrace.isComplete == false || startHereTrace.canDriveRecommendationBehavior == false {
            issues.append(.startHereTraceIncomplete)
        }
        if replayOutcome.isReplay == false ||
            replayOutcome.doubleApplyDisposition != .skipDuplicateMutation ||
            replayResult.metadata["replayDecision"] != LedgerReplayDecision.replayExistingReceipt.rawValue ||
            replayResult.metadata["doubleApplyDisposition"] != LedgerDoubleApplyDisposition.skipDuplicateMutation.rawValue {
            issues.append(.replayNotIdempotent)
        }
        if constraints.noCalendarWrite == false {
            issues.append(.calendarWriteClaimed)
        }
        if constraints.noExternalCloudDependency == false {
            issues.append(.externalCloudDependencyClaimed)
        }
        if constraints.noSilentMutation == false {
            issues.append(.silentMutationClaimed)
        }
        if constraints.noReleaseAccessibilityDeviceClaim == false {
            issues.append(.releaseAccessibilityDeviceClaimed)
        }

        return AmbitionsOSVerticalSliceProofValidation(issues: issues)
    }

    var summaryLines: [String] {
        [
            "Intent -> \(command.kind.rawValue) saved \(capture.id) at \(capture.route.rawValue)",
            "Capture event -> \(captureEvent.kind.rawValue) / \(captureEvent.id)",
            "Command receipt -> \(commandReceipt.title)",
            "Closure receipt -> \(closureReceipt.title)",
            "Start Here -> \(startHereRecommendation.title)",
            "Trace -> \(startHereTrace.isComplete ? "complete" : "incomplete")",
            "Replay -> \(replayOutcome.decision.rawValue) / \(replayOutcome.doubleApplyDisposition.rawValue)",
            "Boundary -> no calendar write, no external/cloud dependency, no silent mutation, no release/accessibility/device claim"
        ]
    }

    var isValidated: Bool {
        validation.isGreen
    }
}
