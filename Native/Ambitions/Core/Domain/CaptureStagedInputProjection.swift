import Foundation

struct CaptureStagedInputProjection: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let kind: CaptureStagedInputKind
    let provenanceLabel: String
    let policyLabel: String
    let routeCandidates: [CaptureStagedRouteCandidate]
    let privacyLabel: String
    let exportLabel: String
    let redactionLabel: String
    let retentionLabel: String
    let accessibilityReviewSummary: String

    init(
        kind: CaptureStagedInputKind,
        provenanceLabel: String,
        policyLabel: String,
        routeCandidates: [CaptureStagedRouteCandidate],
        privacyLabel: String,
        exportLabel: String,
        redactionLabel: String,
        retentionLabel: String,
        accessibilityReviewSummary: String
    ) {
        self.id = "capture-staged-input.\(kind.rawValue)"
        self.kind = kind
        self.provenanceLabel = Self.normalizedRequired(provenanceLabel)
        self.policyLabel = Self.normalizedRequired(policyLabel)
        self.routeCandidates = routeCandidates
        self.privacyLabel = Self.normalizedRequired(privacyLabel)
        self.exportLabel = Self.normalizedRequired(exportLabel)
        self.redactionLabel = Self.normalizedRequired(redactionLabel)
        self.retentionLabel = Self.normalizedRequired(retentionLabel)
        self.accessibilityReviewSummary = Self.normalizedRequired(accessibilityReviewSummary)
    }

    var routeCandidateSummary: String {
        routeCandidates.map(\.title).joined(separator: " / ")
    }

    var visibleCopy: String {
        [
            kind.title,
            provenanceLabel,
            policyLabel,
            routeCandidateSummary,
            privacyLabel,
            exportLabel,
            redactionLabel,
            retentionLabel,
            accessibilityReviewSummary
        ].joined(separator: " ")
    }

    static func supported(sourceSurface: String? = nil) -> [CaptureStagedInputProjection] {
        CaptureStagedInputKind.allCases.map { projection(for: $0, sourceSurface: sourceSurface) }
    }

    static func projection(for kind: CaptureStagedInputKind, sourceSurface: String? = nil) -> CaptureStagedInputProjection {
        let surface = sourceSurface?.trimmingCharacters(in: .whitespacesAndNewlines)
        let surfaceLabel = surface?.isEmpty == false ? surface! : "Capture"

        switch kind {
        case .text:
            return CaptureStagedInputProjection(
                kind: kind,
                provenanceLabel: "Typed in \(surfaceLabel)",
                policyLabel: "Local-first text stays inspectable before save.",
                routeCandidates: [
                    .init(
                        id: "capture-staged-input.text.task",
                        route: .timeSeed,
                        title: "Step",
                        privacyLabel: "Stored on this device",
                        exportLabel: "Export can summarize the text",
                        redactionLabel: "Redact raw text when needed",
                        retentionLabel: "Retained until you archive or delete"
                    ),
                    .init(
                        id: "capture-staged-input.text.goal",
                        route: .goalSeed,
                        title: "Goal",
                        privacyLabel: "Stored on this device",
                        exportLabel: "Export can summarize the text",
                        redactionLabel: "Redact raw text when needed",
                        retentionLabel: "Retained until you archive or delete"
                    ),
                    .init(
                        id: "capture-staged-input.text.needs-place",
                        route: .captureInbox,
                        title: "Needs a Place",
                        privacyLabel: "Stored on this device",
                        exportLabel: "Export keeps the text summary only",
                        redactionLabel: "Redact raw text when needed",
                        retentionLabel: "Retained while it stays unresolved"
                    )
                ],
                privacyLabel: "Stored on this device",
                exportLabel: "Export can summarize the text",
                redactionLabel: "Redact raw text when needed",
                retentionLabel: "Retained until you archive or delete",
                accessibilityReviewSummary: "Text stays local-first and reviewable before anything becomes a step."
            )
        case .voice:
            return CaptureStagedInputProjection(
                kind: kind,
                provenanceLabel: "Voice captured as local text in \(surfaceLabel)",
                policyLabel: "Voice stays transcript-only and local before save.",
                routeCandidates: [
                    .init(
                        id: "capture-staged-input.voice.task",
                        route: .timeSeed,
                        title: "Step",
                        privacyLabel: "Stored on this device",
                        exportLabel: "Export keeps transcript summary only",
                        redactionLabel: "Redact transcript detail",
                        retentionLabel: "Retained as local transcript until deleted"
                    ),
                    .init(
                        id: "capture-staged-input.voice.goal",
                        route: .goalSeed,
                        title: "Goal",
                        privacyLabel: "Stored on this device",
                        exportLabel: "Export keeps transcript summary only",
                        redactionLabel: "Redact transcript detail",
                        retentionLabel: "Retained as local transcript until deleted"
                    ),
                    .init(
                        id: "capture-staged-input.voice.needs-place",
                        route: .captureInbox,
                        title: "Needs a Place",
                        privacyLabel: "Stored on this device",
                        exportLabel: "Export keeps the transcript summary only",
                        redactionLabel: "Redact transcript detail",
                        retentionLabel: "Retained while it stays unresolved"
                    )
                ],
                privacyLabel: "Stored on this device",
                exportLabel: "Export keeps transcript summary only",
                redactionLabel: "Redact transcript detail",
                retentionLabel: "Retained as local transcript until deleted",
                accessibilityReviewSummary: "Voice input stays transcript-only and reviewable before it becomes a step."
            )
        case .image:
            return CaptureStagedInputProjection(
                kind: kind,
                provenanceLabel: "Image or screenshot staged in \(surfaceLabel)",
                policyLabel: "Image stays local and summary-first before save.",
                routeCandidates: [
                    .init(
                        id: "capture-staged-input.image.proof",
                        route: .proofItem,
                        title: "Proof",
                        privacyLabel: "Stored on this device",
                        exportLabel: "Export keeps a redacted summary",
                        redactionLabel: "Redact pixels and metadata",
                        retentionLabel: "Retained for proof and replay"
                    ),
                    .init(
                        id: "capture-staged-input.image.goal-proof",
                        route: .goalAttachment,
                        title: "Goal proof",
                        privacyLabel: "Stored on this device",
                        exportLabel: "Export keeps a redacted summary",
                        redactionLabel: "Redact pixels and metadata",
                        retentionLabel: "Retained for proof and replay"
                    ),
                    .init(
                        id: "capture-staged-input.image.needs-place",
                        route: .captureInbox,
                        title: "Needs a Place",
                        privacyLabel: "Stored on this device",
                        exportLabel: "Export keeps the image summary only",
                        redactionLabel: "Redact pixels and metadata",
                        retentionLabel: "Retained while it stays unresolved"
                    )
                ],
                privacyLabel: "Stored on this device",
                exportLabel: "Export keeps a redacted summary",
                redactionLabel: "Redact pixels and metadata",
                retentionLabel: "Retained for proof and replay",
                accessibilityReviewSummary: "Image staging stays local-first and redaction-aware before it becomes proof."
            )
        case .share:
            return CaptureStagedInputProjection(
                kind: kind,
                provenanceLabel: "Shared text or URL staged in \(surfaceLabel)",
                policyLabel: "Shared content stays local and inspectable first.",
                routeCandidates: [
                    .init(
                        id: "capture-staged-input.share.task",
                        route: .timeSeed,
                        title: "Step",
                        privacyLabel: "Stored on this device",
                        exportLabel: "Export keeps shared references redacted",
                        redactionLabel: "Redact shared text and URLs",
                        retentionLabel: "Retained until you archive or delete"
                    ),
                    .init(
                        id: "capture-staged-input.share.goal",
                        route: .goalSeed,
                        title: "Goal",
                        privacyLabel: "Stored on this device",
                        exportLabel: "Export keeps shared references redacted",
                        redactionLabel: "Redact shared text and URLs",
                        retentionLabel: "Retained until you archive or delete"
                    ),
                    .init(
                        id: "capture-staged-input.share.needs-place",
                        route: .captureInbox,
                        title: "Needs a Place",
                        privacyLabel: "Stored on this device",
                        exportLabel: "Export keeps the shared summary only",
                        redactionLabel: "Redact shared text and URLs",
                        retentionLabel: "Retained while it stays unresolved"
                    )
                ],
                privacyLabel: "Stored on this device",
                exportLabel: "Export keeps shared references redacted",
                redactionLabel: "Redact shared text and URLs",
                retentionLabel: "Retained until you archive or delete",
                accessibilityReviewSummary: "Shared content stays local-first and redaction-aware before it becomes work."
            )
        case .proof:
            return CaptureStagedInputProjection(
                kind: kind,
                provenanceLabel: "Proof or evidence staged in \(surfaceLabel)",
                policyLabel: "Proof stays local and receipt-bound before save.",
                routeCandidates: [
                    .init(
                        id: "capture-staged-input.proof.proof",
                        route: .proofItem,
                        title: "Proof",
                        privacyLabel: "Stored on this device",
                        exportLabel: "Export keeps proof summary only",
                        redactionLabel: "Redact proof detail by default",
                        retentionLabel: "Retained for receipts and replay"
                    ),
                    .init(
                        id: "capture-staged-input.proof.goal-proof",
                        route: .goalAttachment,
                        title: "Goal proof",
                        privacyLabel: "Stored on this device",
                        exportLabel: "Export keeps proof summary only",
                        redactionLabel: "Redact proof detail by default",
                        retentionLabel: "Retained for receipts and replay"
                    ),
                    .init(
                        id: "capture-staged-input.proof.needs-place",
                        route: .captureInbox,
                        title: "Needs a Place",
                        privacyLabel: "Stored on this device",
                        exportLabel: "Export keeps the proof summary only",
                        redactionLabel: "Redact proof detail by default",
                        retentionLabel: "Retained while it stays unresolved"
                    )
                ],
                privacyLabel: "Stored on this device",
                exportLabel: "Export keeps proof summary only",
                redactionLabel: "Redact proof detail by default",
                retentionLabel: "Retained for receipts and replay",
                accessibilityReviewSummary: "Proof staging stays receipt-bound and redaction-aware before it becomes proof."
            )
        case .context:
            return CaptureStagedInputProjection(
                kind: kind,
                provenanceLabel: "Context staged in \(surfaceLabel)",
                policyLabel: "Context stays local and future-use aware.",
                routeCandidates: [
                    .init(
                        id: "capture-staged-input.context.needs-place",
                        route: .captureInbox,
                        title: "Needs a Place",
                        privacyLabel: "Stored on this device",
                        exportLabel: "Export keeps the context summary only",
                        redactionLabel: "Redact sensitive context text",
                        retentionLabel: "Retained while future use stays local"
                    ),
                    .init(
                        id: "capture-staged-input.context.waiting",
                        route: .waiting,
                        title: "Waiting",
                        privacyLabel: "Stored on this device",
                        exportLabel: "Export keeps the context summary only",
                        redactionLabel: "Redact sensitive context text",
                        retentionLabel: "Retained while future use stays local"
                    ),
                    .init(
                        id: "capture-staged-input.context.someday",
                        route: .optionalSomeday,
                        title: "Review later",
                        privacyLabel: "Stored on this device",
                        exportLabel: "Export keeps the context summary only",
                        redactionLabel: "Redact sensitive context text",
                        retentionLabel: "Retained while future use stays local"
                    )
                ],
                privacyLabel: "Stored on this device",
                exportLabel: "Export keeps the context summary only",
                redactionLabel: "Redact sensitive context text",
                retentionLabel: "Retained while future use stays local",
                accessibilityReviewSummary: "Context staging stays local-first and future-use aware before it becomes a step."
            )
        }
    }

    static func normalizedRequired(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

enum CaptureKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case raw
    case oneTimeCommitment = "one_time_commitment"
    case deadlineTask = "deadline_task"
    case goalSeed = "goal_seed"
    case goalSupportingTask = "goal_supporting_task"
    case deliverableSeed = "deliverable_seed"
    case waitingItem = "waiting_item"
    case optionalSomeday = "optional_someday"
    case archiveItem = "archive_item"

    var title: String {
        switch self {
        case .raw: "Raw capture"
        case .oneTimeCommitment: "One-time commitment"
        case .deadlineTask: "Deadline step"
        case .goalSeed: "Goal seed"
        case .goalSupportingTask: "Goal-supporting step"
        case .deliverableSeed: "Deliverable seed"
        case .waitingItem: "Waiting item"
        case .optionalSomeday: "Optional / Someday"
        case .archiveItem: "Archive item"
        }
    }
}

enum CaptureTriageStatus: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case needsTriage = "needs_triage"
    case assumedRoute = "assumed_route"
    case userCorrected = "user_corrected"
    case routed
    case waiting
    case archived

    var title: String {
        switch self {
        case .needsTriage: "Needs triage"
        case .assumedRoute: "Assumed route"
        case .userCorrected: "User corrected"
        case .routed: "Routed"
        case .waiting: "Waiting"
        case .archived: "Archived"
        }
    }
}
