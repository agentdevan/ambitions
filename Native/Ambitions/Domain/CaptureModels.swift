import Foundation

enum CaptureSourceType: String, Codable, Sendable, Equatable, CaseIterable {
    case todayQuickCapture = "today_quick_capture"
    case notification = "notification"
    case shareExtensionText = "share_extension_text"
    case shareExtensionURL = "share_extension_url"
    case appIntent = "app_intent"

    var title: String {
        switch self {
        case .todayQuickCapture:
            return "Today quick capture"
        case .notification:
            return "Notification"
        case .shareExtensionText:
            return "Share extension text"
        case .shareExtensionURL:
            return "Share extension URL"
        case .appIntent:
            return "App Intent"
        }
    }
}

enum CaptureStatus: String, Codable, Sendable, Equatable, CaseIterable {
    case needsTriage = "needs_triage"
    case seed
    case actionable
    case goalBound = "goal_bound"
    case scheduled
    case delegated
    case waiting
    case optionalSomeday = "optional_someday"
    case archived

    var title: String {
        switch self {
        case .needsTriage:
            return "Needs triage"
        case .seed:
            return "Seed"
        case .actionable:
            return "Actionable"
        case .goalBound:
            return "Goal-bound"
        case .scheduled:
            return "Scheduled"
        case .delegated:
            return "Delegated"
        case .waiting:
            return "Waiting"
        case .optionalSomeday:
            return "Optional / Someday"
        case .archived:
            return "Archived"
        }
    }

    func canTransition(to next: CaptureStatus) -> Bool {
        guard self != next else { return true }

        switch self {
        case .needsTriage:
            return next == .seed || next == .actionable || next == .goalBound || next == .scheduled || next == .delegated || next == .waiting || next == .optionalSomeday || next == .archived
        case .seed:
            return next == .actionable || next == .goalBound || next == .scheduled || next == .waiting || next == .optionalSomeday || next == .archived
        case .actionable:
            return next == .needsTriage || next == .seed || next == .goalBound || next == .scheduled || next == .delegated || next == .waiting || next == .optionalSomeday || next == .archived
        case .goalBound, .scheduled, .delegated, .waiting, .optionalSomeday:
            return next == .needsTriage || next == .seed || next == .actionable || next == .goalBound || next == .scheduled || next == .delegated || next == .waiting || next == .optionalSomeday || next == .archived
        case .archived:
            return false
        }
    }
}

enum CaptureTriageDestination: String, Codable, Sendable, Equatable, CaseIterable {
    case needsTriage = "needs_triage"
    case timeSeed = "time_seed"
    case doSoon = "do_soon"
    case turnIntoGoal = "turn_into_goal"
    case attachToGoal = "attach_to_goal"
    case saveAsSeed = "save_as_seed"
    case waiting
    case optionalSomeday = "optional_someday"
    case deliverableSeed = "deliverable_seed"
    case archive

    var title: String {
        switch self {
        case .needsTriage:
            return "Needs triage"
        case .timeSeed:
            return "Time idea"
        case .doSoon:
            return "Do soon"
        case .turnIntoGoal:
            return "Turn into goal"
        case .attachToGoal:
            return "Attach to goal"
        case .saveAsSeed:
            return "Save as seed"
        case .waiting:
            return "Waiting"
        case .optionalSomeday:
            return "Optional / Someday"
        case .deliverableSeed:
            return "Deliverable seed"
        case .archive:
            return "Archive"
        }
    }
}

enum CaptureBackgroundFactRoute: String, Codable, Sendable, Equatable, CaseIterable {
    case needsPlace = "needs_place"
    case needsReview = "needs_review"

    var title: String {
        switch self {
        case .needsPlace:
            return "Needs a Place"
        case .needsReview:
            return "Needs Review"
        }
    }

    var explanation: String {
        switch self {
        case .needsPlace:
            return "Context that still needs a calm owning surface."
        case .needsReview:
            return "Context that should be checked before runtime use."
        }
    }
}

enum CaptureStagedInputKind: String, Codable, Sendable, Equatable, CaseIterable {
    case text
    case voice
    case image
    case share
    case proof
    case context

    var title: String {
        switch self {
        case .text:
            return "Text"
        case .voice:
            return "Voice"
        case .image:
            return "Image"
        case .share:
            return "Share"
        case .proof:
            return "Proof"
        case .context:
            return "Context"
        }
    }
}

struct CaptureStagedRouteCandidate: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let route: CaptureRoute
    let title: String
    let privacyLabel: String
    let exportLabel: String
    let redactionLabel: String
    let retentionLabel: String

    init(
        id: String,
        route: CaptureRoute,
        title: String,
        privacyLabel: String,
        exportLabel: String,
        redactionLabel: String,
        retentionLabel: String
    ) {
        self.id = Self.normalizedRequired(id)
        self.route = route
        self.title = Self.normalizedRequired(title)
        self.privacyLabel = Self.normalizedRequired(privacyLabel)
        self.exportLabel = Self.normalizedRequired(exportLabel)
        self.redactionLabel = Self.normalizedRequired(redactionLabel)
        self.retentionLabel = Self.normalizedRequired(retentionLabel)
    }

    private static func normalizedRequired(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

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
                        title: "Task",
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
                        title: "Task",
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
                        title: "Task",
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

    private static func normalizedRequired(_ value: String) -> String {
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
        case .deadlineTask: "Deadline task"
        case .goalSeed: "Goal seed"
        case .goalSupportingTask: "Goal-supporting task"
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

enum CaptureRoute: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case captureInbox = "capture_inbox"
    case timeSeed = "time_seed"
    case goalSeed = "goal_seed"
    case goalAttachment = "goal_attachment"
    case deliverableSeed = "deliverable_seed"
    case proofItem = "proof_item"
    case constraintItem = "constraint_item"
    case waiting
    case optionalSomeday = "optional_someday"
    case archive

    var title: String {
        switch self {
        case .captureInbox: "Capture"
        case .timeSeed: "Time idea"
        case .goalSeed: "Goal seed"
        case .goalAttachment: "Attach to goal"
        case .deliverableSeed: "Deliverable seed"
        case .proofItem: "Proof"
        case .constraintItem: "Constraint"
        case .waiting: "Waiting"
        case .optionalSomeday: "Optional / Someday"
        case .archive: "Archive"
        }
    }

    var triageDestination: CaptureTriageDestination {
        switch self {
        case .captureInbox: .needsTriage
        case .timeSeed: .timeSeed
        case .goalSeed: .turnIntoGoal
        case .goalAttachment: .attachToGoal
        case .deliverableSeed: .deliverableSeed
        case .proofItem, .constraintItem: .deliverableSeed
        case .waiting: .waiting
        case .optionalSomeday: .optionalSomeday
        case .archive: .archive
        }
    }
}

enum CaptureDeadlineKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case none
    case soft
    case hard
    case flexible
}

enum CaptureCorrectionAction: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case changeRoute = "change_route"
    case changeDeadline = "change_deadline"
    case attachToGoal = "attach_to_goal"
    case markWaiting = "mark_waiting"
    case markOptionalSomeday = "mark_optional_someday"
    case archive
}

struct CapturePriorityHints: Codable, Sendable, Equatable, Hashable {
    let importance: NowPressureLevel?
    let urgency: NowPressureLevel?
    let consequence: NowPressureLevel?
    let deadline: NowPressureLevel?
    let effort: NowPressureLevel?
    let contextFit: NowPressureLevel?
    let optionalSomeday: Bool
    let passive: Bool
    let goalSupporting: Bool

    init(
        importance: NowPressureLevel? = nil,
        urgency: NowPressureLevel? = nil,
        consequence: NowPressureLevel? = nil,
        deadline: NowPressureLevel? = nil,
        effort: NowPressureLevel? = nil,
        contextFit: NowPressureLevel? = nil,
        optionalSomeday: Bool = false,
        passive: Bool = false,
        goalSupporting: Bool = false
    ) {
        self.importance = importance
        self.urgency = urgency
        self.consequence = consequence
        self.deadline = deadline
        self.effort = effort
        self.contextFit = contextFit
        self.optionalSomeday = optionalSomeday
        self.passive = passive
        self.goalSupporting = goalSupporting
    }
}

struct CaptureGoalRelationship: Codable, Sendable, Equatable, Hashable {
    let goalID: String?
    let relationshipKind: NowGoalPressureKind?
    let note: String?

    init(goalID: String? = nil, relationshipKind: NowGoalPressureKind? = nil, note: String? = nil) {
        self.goalID = goalID
        self.relationshipKind = relationshipKind
        self.note = note
    }
}

struct CaptureWaitingMetadata: Codable, Sendable, Equatable, Hashable {
    let blockedBy: String?
    let waitingOn: String?
    let followUpText: String?

    init(blockedBy: String? = nil, waitingOn: String? = nil, followUpText: String? = nil) {
        self.blockedBy = blockedBy
        self.waitingOn = waitingOn
        self.followUpText = followUpText
    }
}

struct CaptureTriageMetadata: Codable, Sendable, Equatable {
    let destination: CaptureTriageDestination?
    let hint: String?

    init(destination: CaptureTriageDestination? = nil, hint: String? = nil) {
        self.destination = destination
        self.hint = hint
    }
}

struct Capture: Identifiable, Codable, Sendable, Equatable {
    let id: String
    let createdAt: String
    let updatedAt: String
    let rawText: String
    let sourceType: CaptureSourceType?
    let status: CaptureStatus
    let linkedGoalID: String?
    let triage: CaptureTriageMetadata?
    let revisitAfter: String?
    let kind: CaptureKind
    let route: CaptureRoute
    let triageStatus: CaptureTriageStatus
    let commitmentKind: NowCommitmentKind?
    let deadlineText: String?
    let deadlineKind: CaptureDeadlineKind
    let contextLensHint: NowContextLens?
    let priorityHints: CapturePriorityHints
    let goalRelationship: CaptureGoalRelationship?
    let deliverableHint: String?
    let scopeItemHint: String?
    let waitingMetadata: CaptureWaitingMetadata?
    let assumptionSummary: String?
    let correctionActions: [CaptureCorrectionAction]
    let recommendationExplanationIDs: [String]
    let localOnly: Bool
    let privacy: EventLedgerPrivacyClassification

    init(
        id: String,
        createdAt: String,
        updatedAt: String,
        rawText: String,
        sourceType: CaptureSourceType?,
        status: CaptureStatus,
        linkedGoalID: String?,
        triage: CaptureTriageMetadata? = nil,
        revisitAfter: String? = nil,
        kind: CaptureKind = .raw,
        route: CaptureRoute = .captureInbox,
        triageStatus: CaptureTriageStatus = .needsTriage,
        commitmentKind: NowCommitmentKind? = nil,
        deadlineText: String? = nil,
        deadlineKind: CaptureDeadlineKind = .none,
        contextLensHint: NowContextLens? = nil,
        priorityHints: CapturePriorityHints = CapturePriorityHints(),
        goalRelationship: CaptureGoalRelationship? = nil,
        deliverableHint: String? = nil,
        scopeItemHint: String? = nil,
        waitingMetadata: CaptureWaitingMetadata? = nil,
        assumptionSummary: String? = nil,
        correctionActions: [CaptureCorrectionAction] = [.changeRoute, .changeDeadline, .attachToGoal, .markWaiting, .markOptionalSomeday, .archive],
        recommendationExplanationIDs: [String] = [],
        localOnly: Bool = true,
        privacy: EventLedgerPrivacyClassification = .privateUserText
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.rawText = rawText
        self.sourceType = sourceType
        self.status = status
        self.linkedGoalID = linkedGoalID
        self.triage = triage
        self.revisitAfter = revisitAfter
        self.kind = kind
        self.route = route
        self.triageStatus = triageStatus
        self.commitmentKind = commitmentKind
        self.deadlineText = deadlineText
        self.deadlineKind = deadlineKind
        self.contextLensHint = contextLensHint
        self.priorityHints = priorityHints
        self.goalRelationship = goalRelationship
        self.deliverableHint = deliverableHint
        self.scopeItemHint = scopeItemHint
        self.waitingMetadata = waitingMetadata
        self.assumptionSummary = assumptionSummary
        self.correctionActions = Array(Set(correctionActions)).sorted { $0.rawValue < $1.rawValue }
        self.recommendationExplanationIDs = Array(Set(recommendationExplanationIDs.filter { $0.isEmpty == false })).sorted()
        self.localOnly = localOnly
        self.privacy = privacy
    }
}

extension Capture {
    enum CodingKeys: String, CodingKey {
        case id
        case createdAt
        case updatedAt
        case rawText
        case sourceType
        case status
        case linkedGoalID
        case triage
        case revisitAfter
        case kind
        case route
        case triageStatus
        case commitmentKind
        case deadlineText
        case deadlineKind
        case contextLensHint
        case priorityHints
        case goalRelationship
        case deliverableHint
        case scopeItemHint
        case waitingMetadata
        case assumptionSummary
        case correctionActions
        case recommendationExplanationIDs
        case localOnly
        case privacy
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        createdAt = try container.decode(String.self, forKey: .createdAt)
        updatedAt = try container.decode(String.self, forKey: .updatedAt)
        rawText = try container.decode(String.self, forKey: .rawText)
        sourceType = try container.decodeIfPresent(CaptureSourceType.self, forKey: .sourceType)
        status = try container.decode(CaptureStatus.self, forKey: .status)
        linkedGoalID = try container.decodeIfPresent(String.self, forKey: .linkedGoalID)
        triage = try container.decodeIfPresent(CaptureTriageMetadata.self, forKey: .triage)
        revisitAfter = try container.decodeIfPresent(String.self, forKey: .revisitAfter)
        kind = try container.decodeIfPresent(CaptureKind.self, forKey: .kind) ?? Self.defaultKind(for: status)
        route = try container.decodeIfPresent(CaptureRoute.self, forKey: .route) ?? Self.defaultRoute(for: status, triage: triage)
        triageStatus = try container.decodeIfPresent(CaptureTriageStatus.self, forKey: .triageStatus) ?? Self.defaultTriageStatus(for: status)
        commitmentKind = try container.decodeIfPresent(NowCommitmentKind.self, forKey: .commitmentKind)
        deadlineText = try container.decodeIfPresent(String.self, forKey: .deadlineText)
        deadlineKind = try container.decodeIfPresent(CaptureDeadlineKind.self, forKey: .deadlineKind) ?? .none
        contextLensHint = try container.decodeIfPresent(NowContextLens.self, forKey: .contextLensHint)
        priorityHints = try container.decodeIfPresent(CapturePriorityHints.self, forKey: .priorityHints) ?? CapturePriorityHints()
        goalRelationship = try container.decodeIfPresent(CaptureGoalRelationship.self, forKey: .goalRelationship)
        deliverableHint = try container.decodeIfPresent(String.self, forKey: .deliverableHint)
        scopeItemHint = try container.decodeIfPresent(String.self, forKey: .scopeItemHint)
        waitingMetadata = try container.decodeIfPresent(CaptureWaitingMetadata.self, forKey: .waitingMetadata)
        assumptionSummary = try container.decodeIfPresent(String.self, forKey: .assumptionSummary)
        correctionActions = try container.decodeIfPresent([CaptureCorrectionAction].self, forKey: .correctionActions) ?? [.changeRoute, .changeDeadline, .attachToGoal, .markWaiting, .markOptionalSomeday, .archive]
        recommendationExplanationIDs = try container.decodeIfPresent([String].self, forKey: .recommendationExplanationIDs) ?? []
        localOnly = try container.decodeIfPresent(Bool.self, forKey: .localOnly) ?? true
        privacy = try container.decodeIfPresent(EventLedgerPrivacyClassification.self, forKey: .privacy) ?? .privateUserText
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
        try container.encode(rawText, forKey: .rawText)
        try container.encodeIfPresent(sourceType, forKey: .sourceType)
        try container.encode(status, forKey: .status)
        try container.encodeIfPresent(linkedGoalID, forKey: .linkedGoalID)
        try container.encodeIfPresent(triage, forKey: .triage)
        try container.encodeIfPresent(revisitAfter, forKey: .revisitAfter)
        try container.encode(kind, forKey: .kind)
        try container.encode(route, forKey: .route)
        try container.encode(triageStatus, forKey: .triageStatus)
        try container.encodeIfPresent(commitmentKind, forKey: .commitmentKind)
        try container.encodeIfPresent(deadlineText, forKey: .deadlineText)
        try container.encode(deadlineKind, forKey: .deadlineKind)
        try container.encodeIfPresent(contextLensHint, forKey: .contextLensHint)
        try container.encode(priorityHints, forKey: .priorityHints)
        try container.encodeIfPresent(goalRelationship, forKey: .goalRelationship)
        try container.encodeIfPresent(deliverableHint, forKey: .deliverableHint)
        try container.encodeIfPresent(scopeItemHint, forKey: .scopeItemHint)
        try container.encodeIfPresent(waitingMetadata, forKey: .waitingMetadata)
        try container.encodeIfPresent(assumptionSummary, forKey: .assumptionSummary)
        try container.encode(correctionActions, forKey: .correctionActions)
        try container.encode(recommendationExplanationIDs, forKey: .recommendationExplanationIDs)
        try container.encode(localOnly, forKey: .localOnly)
        try container.encode(privacy, forKey: .privacy)
    }

    private static func defaultKind(for status: CaptureStatus) -> CaptureKind {
        switch status {
        case .needsTriage, .actionable: .raw
        case .seed: .goalSeed
        case .goalBound: .goalSupportingTask
        case .scheduled: .oneTimeCommitment
        case .delegated, .waiting: .waitingItem
        case .optionalSomeday: .optionalSomeday
        case .archived: .archiveItem
        }
    }

    private static func defaultRoute(for status: CaptureStatus, triage: CaptureTriageMetadata?) -> CaptureRoute {
        if let destination = triage?.destination {
            switch destination {
            case .needsTriage: return .captureInbox
            case .doSoon, .timeSeed: return .timeSeed
            case .turnIntoGoal: return .goalSeed
            case .attachToGoal: return .goalAttachment
            case .saveAsSeed: return .captureInbox
            case .waiting: return .waiting
            case .optionalSomeday: return .optionalSomeday
            case .deliverableSeed: return .deliverableSeed
            case .archive: return .archive
            }
        }

        switch status {
        case .needsTriage, .actionable, .seed:
            return .captureInbox
        case .goalBound:
            return .goalAttachment
        case .scheduled:
            return .timeSeed
        case .delegated, .waiting:
            return .waiting
        case .optionalSomeday:
            return .optionalSomeday
        case .archived:
            return .archive
        }
    }

    private static func defaultTriageStatus(for status: CaptureStatus) -> CaptureTriageStatus {
        switch status {
        case .needsTriage, .actionable, .seed: .needsTriage
        case .waiting: .waiting
        case .archived: .archived
        case .goalBound, .scheduled, .delegated, .optionalSomeday: .routed
        }
    }
}

extension Capture {
    var searchFreshness: YouMemoryFreshness {
        switch status {
        case .archived:
            return .basedOnOlderContext
        case .needsTriage, .seed:
            return .mayNeedReview
        case .actionable, .goalBound, .scheduled, .delegated, .waiting, .optionalSomeday:
            return .current
        }
    }

    var searchObjectTypeLabel: String {
        kind.title
    }

    var searchSourceLabel: String {
        sourceType?.title ?? "Typed in Capture"
    }

    var searchPrimaryActionTitles: [String] {
        switch status {
        case .archived:
            return ["Open capture", "Inspect receipt"]
        case .needsTriage, .actionable, .seed:
            return ["Open capture", "Change route", "Attach to goal"]
        case .goalBound:
            return ["Open capture", "Open goal", "Inspect proof"]
        case .scheduled:
            return ["Open capture", "Move to Time", "Inspect receipt"]
        case .delegated:
            return ["Open capture", "Review delegation", "Inspect receipt"]
        case .waiting:
            return ["Open capture", "Mark waiting", "Inspect receipt"]
        case .optionalSomeday:
            return ["Open capture", "Review later", "Inspect receipt"]
        }
    }
}
