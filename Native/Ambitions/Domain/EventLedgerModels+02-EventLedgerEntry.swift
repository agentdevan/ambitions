import Foundation

extension EventLedgerEntry {
    static func fromFeedbackEvent(
        _ event: GoalFeedbackEvent,
        goalID: String,
        source: EventLedgerSource = .goalEngine
    ) -> EventLedgerEntry {
        let kind: EventLedgerKind
        let title: String
        let tone: EventLedgerTone
        switch event {
        case .completed:
            kind = .actionCompleted
            title = "Action completed"
            tone = .positive
        case .skipped:
            kind = .actionSkipped
            title = "Action skipped"
            tone = .recovering
        case .delayed:
            kind = .actionDelayed
            title = "Action delayed"
            tone = .recovering
        case .edited:
            kind = .planUpdated
            title = "Schedule wording updated"
            tone = .neutral
        case .confused:
            kind = .userCorrectionAdded
            title = "Clarification signal recorded"
            tone = .correction
        case .tooBig, .askedForSmallerVersion:
            kind = .actionSplit
            title = "Smaller action requested"
            tone = .recovering
        case .tooEasy, .notRelevant, .askedWhyThisMatters:
            kind = .userCorrectionAdded
            title = "User correction recorded"
            tone = .correction
        }

        return EventLedgerEntry(
            id: "ledger.feedback.\(event.base.id)",
            kind: kind,
            occurredAt: event.base.occurredAt,
            source: source,
            goalID: goalID,
            title: title,
            summary: event.base.note,
            semanticState: event.kind.rawValue,
            tone: tone,
            trust: EventLedgerTrustMetadata(isUserConfirmed: true),
            evidenceReferences: [
                EventLedgerEvidenceReference(
                    id: event.base.id,
                    kind: .feedbackEvent,
                    occurredAt: event.base.occurredAt,
                    summary: event.kind.rawValue
                )
            ],
            metadata: [
                "legacyKind": event.kind.rawValue,
                "stepID": event.base.stepID
            ],
            privacy: event.base.note == nil ? .standard : .privateUserText
        )
    }

    static func fromProgressEvidence(
        _ evidence: ProgressEvidence,
        source: EventLedgerSource = .goalEngine
    ) -> EventLedgerEntry {
        EventLedgerEntry(
            id: "ledger.evidence.\(evidence.id)",
            kind: evidence.evidenceKind == .stepCompleted ? .actionCompleted : .goalUpdated,
            occurredAt: evidence.capturedAt,
            source: source,
            goalID: evidence.goalID,
            title: "Progress evidence recorded",
            summary: evidence.note,
            semanticState: evidence.evidenceKind.rawValue,
            tone: .positive,
            trust: EventLedgerTrustMetadata(confidence: evidence.confidenceDelta.map { 0.5 + $0 }),
            evidenceReferences: [
                EventLedgerEvidenceReference(
                    id: evidence.id,
                    kind: .progressEvidence,
                    occurredAt: evidence.capturedAt,
                    summary: evidence.evidenceKind.rawValue
                )
            ],
            metadata: [
                "evidenceKind": evidence.evidenceKind.rawValue,
                "evidenceSource": evidence.source.rawValue,
                "stepID": evidence.stepID ?? ""
            ].filter { $0.value.isEmpty == false },
            privacy: evidence.note == nil ? .standard : .privateUserText
        )
    }

    static func fromTeachingSignal(
        _ signal: GoalTeachingSignal,
        source: EventLedgerSource = .goalEngine
    ) -> EventLedgerEntry {
        EventLedgerEntry(
            id: "ledger.teaching.\(signal.id)",
            kind: .userCorrectionAdded,
            occurredAt: signal.updatedAt,
            source: source,
            goalID: signal.goalID,
            title: "Correction added",
            summary: signal.userNote,
            semanticState: signal.kind.rawValue,
            tone: .correction,
            trust: EventLedgerTrustMetadata(isUserConfirmed: true),
            evidenceReferences: [
                EventLedgerEvidenceReference(
                    id: signal.id,
                    kind: .teachingSignal,
                    occurredAt: signal.updatedAt,
                    summary: signal.kind.rawValue
                )
            ],
            metadata: [
                "teachingKind": signal.kind.rawValue,
                "teachingSource": signal.source.rawValue,
                "applicationKey": signal.applicationKey
            ],
            privacy: signal.userNote == nil ? .standard : .privateUserText
        )
    }
}

let diagnosticLedgerSchemaVersion = "diagnostic_ledger.native.v1"

enum DiagnosticLedgerSignal: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case eventLedger = "event_ledger"
    case sideEffectLedger = "side_effect_ledger"
    case privacySafety = "privacy_safety"
}

enum DiagnosticLedgerSeverity: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case info
    case caution
    case warning
    case blocked
    case critical

    var requiresAttention: Bool {
        switch self {
        case .info:
            false
        case .caution, .warning, .blocked, .critical:
            true
        }
    }
}

struct DiagnosticLedgerEntry: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let signal: DiagnosticLedgerSignal
    let sourceRecordID: String
    let occurredAt: String
    let title: String
    let summary: String
    let severity: DiagnosticLedgerSeverity
    let localOnly: Bool
    let requiresReview: Bool
    let privacy: EventLedgerPrivacyClassification
    let sideEffectBoundary: SideEffectLedgerBoundary?
    let schemaVersion: String
    let metadata: [String: String]
    let payload: [String: String]
    let createdAt: String
    let issueFingerprint: String

    init(
        signal: DiagnosticLedgerSignal,
        sourceRecordID: String,
        occurredAt: String,
        title: String,
        summary: String,
        severity: DiagnosticLedgerSeverity,
        localOnly: Bool = true,
        requiresReview: Bool = false,
        privacy: EventLedgerPrivacyClassification = .standard,
        sideEffectBoundary: SideEffectLedgerBoundary? = nil,
        schemaVersion: String = diagnosticLedgerSchemaVersion,
        metadata: [String: String] = [:],
        payload: [String: String] = [:],
        createdAt: String? = nil
    ) {
        self.id = "diag.\(signal.rawValue).\(sourceRecordID)"
        self.signal = signal
        self.sourceRecordID = sourceRecordID
        self.occurredAt = occurredAt.trimmingCharacters(in: .whitespacesAndNewlines)
        self.title = title
        self.summary = summary.trimmingCharacters(in: .whitespacesAndNewlines)
        self.severity = severity
        self.localOnly = localOnly
        self.requiresReview = requiresReview
        self.privacy = privacy
        self.sideEffectBoundary = sideEffectBoundary
        self.schemaVersion = schemaVersion
        self.metadata = metadata
        self.payload = payload
        self.createdAt = createdAt?.trimmingCharacters(in: .whitespacesAndNewlines) ?? occurredAt
        self.issueFingerprint = "\(signal.rawValue)|\(sourceRecordID)|\(severity.rawValue)|\(privacy.rawValue)|\(summary)"
    }

    var isAttentionRequired: Bool {
        requiresReview || severity.requiresAttention
    }
}

extension EventLedgerEntry {
    func toDiagnosticLedgerEntry() -> DiagnosticLedgerEntry {
        let isSensitive = privacy == .sensitive || privacy == .privateUserText
        let severity: DiagnosticLedgerSeverity = {
            switch tone {
            case .positive, .neutral:
                return isSensitive ? .caution : .info
            case .recovering, .caution:
                return .warning
            case .correction:
                return .caution
            }
        }()

        return DiagnosticLedgerEntry(
            signal: .eventLedger,
            sourceRecordID: id,
            occurredAt: occurredAt,
            title: "EventLedger \(kind.rawValue)",
            summary: title,
            severity: severity,
            localOnly: localOnly,
            requiresReview: trust.requiresReview || isSensitive,
            privacy: privacy,
            metadata: [
                "goalID": goalID ?? "",
                "captureID": captureID ?? "",
                "planID": planID ?? "",
                "planScope": planScope ?? "",
                "reviewID": reviewID ?? "",
                "source": source.rawValue,
                "kind": kind.rawValue,
                "tone": tone.rawValue,
                "sourceConfirmed": String(trust.isUserConfirmed)
            ].filter { $0.value.isEmpty == false },
            payload: payload
        )
    }
}

extension SideEffectLedgerRecord {
    func toDiagnosticLedgerEntry() -> DiagnosticLedgerEntry {
        let severity: DiagnosticLedgerSeverity = {
            switch boundary {
            case .destructive:
                return .critical
            case .privacySensitive, .externalEffect, .confirmationGate:
                return .warning
            case .unsupported:
                return .blocked
            case .localOnly:
                return .info
            }
        }()
        let summary = "SideEffect \(effectKind.rawValue) from \(actionKind.rawValue)"

        return DiagnosticLedgerEntry(
            signal: .sideEffectLedger,
            sourceRecordID: id,
            occurredAt: occurredAt,
            title: "SideEffect \(effectKind.rawValue)",
            summary: summary,
            severity: severity,
            localOnly: localOnly,
            requiresReview: boundary != .localOnly || requiresConfirmation || status != .recordedLocalOnly,
            privacy: boundary == .localOnly ? .standard : .privateUserText,
            sideEffectBoundary: boundary,
            metadata: [
                "actionKind": actionKind.rawValue,
                "status": status.rawValue,
                "boundary": boundary.rawValue,
                "sourceDomain": sourceDomain.rawValue,
                "requiresConfirmation": String(requiresConfirmation),
                "externalEffect": String(externalEffect)
            ],
            payload: [
                "blockedFacts": blockedFacts.joined(separator: "|"),
                "degradedFacts": degradedFacts.joined(separator: "|"),
                "receiptID": receiptID ?? ""
            ].filter { $0.value.isEmpty == false }
        )
    }
}

extension AmbitionsOSPrivacySafetyClassification {
    func toDiagnosticLedgerEntry(occurredAt: String) -> DiagnosticLedgerEntry {
        let severity: DiagnosticLedgerSeverity = {
            switch classification {
            case .local:
                return .info
            case .localRedacted:
                return .caution
            case .externalRedacted:
                return .warning
            case .blocked:
                return .warning
            case .unsafe:
                return .critical
            }
        }()

        return DiagnosticLedgerEntry(
            signal: .privacySafety,
            sourceRecordID: id,
            occurredAt: occurredAt,
            title: "PrivacySafety \(classification.rawValue)",
            summary: "Policy \(policyID) -> \(humanProgressPrivacyClass.rawValue)",
            severity: severity,
            localOnly: true,
            requiresReview: requiresUserReview || classification != .local,
            privacy: eventLedgerPrivacyClassification,
            sideEffectBoundary: sideEffectLedgerBoundary,
            metadata: [
                "policyID": policyID,
                "humanProgressPrivacyClass": humanProgressPrivacyClass.rawValue,
                "projectionPolicy": projectionPolicy.rawValue,
                "localProjectionOnly": String(localProjectionOnly),
                "externallyProjectable": String(externallyProjectable),
                "requiresRedaction": String(requiresRedaction),
                "receiptCompatible": String(receiptCompatible),
                "classification": classification.rawValue
            ],
            payload: [
                "issues": issues.map(\.rawValue).joined(separator: "|"),
                "actionReceiptPrivacyLevel": actionReceiptPrivacyLevel.rawValue,
                "issueFingerprint": issueFingerprint
            ].filter { $0.value.isEmpty == false },
            createdAt: occurredAt
        )
    }
}
