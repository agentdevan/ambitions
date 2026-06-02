import Foundation

enum PlanInsertionTimeConfidence: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case high
    case medium
    case low
    case needsClarification = "needs_clarification"

    var userFacingLabel: String {
        switch self {
        case .high: "High"
        case .medium: "Medium"
        case .low: "Low"
        case .needsClarification: "Needs clarification"
        }
    }
}

enum PlanInsertionScheduleImpact: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case timeItemProposed = "time_item_proposed"
    case timeChangeRecommended = "time_change_recommended"
    case contextOnly = "context_only"
    case protectedTimeReview = "protected_time_review"
    case calendarPermissionGate = "calendar_permission_gate"

    var userFacingLabel: String {
        switch self {
        case .timeItemProposed: "Add to Time after approval"
        case .timeChangeRecommended: "Change time before approval"
        case .contextOnly: "Save as context only"
        case .protectedTimeReview: "Protected time needs review"
        case .calendarPermissionGate: "Calendar write stays gated"
        }
    }
}

enum PlanInsertionConflictStatus: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case none
    case ambiguity
    case possibleConflict = "possible_conflict"
    case protectedTime = "protected_time"
    case calendarPermissionRequired = "calendar_permission_required"

    var userFacingLabel: String {
        switch self {
        case .none: "No known conflict"
        case .ambiguity: "Time ambiguity"
        case .possibleConflict: "Possible schedule conflict"
        case .protectedTime: "Protected time conflict"
        case .calendarPermissionRequired: "Calendar permission required"
        }
    }
}

enum PlanInsertionApprovalOptionKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case decideLater = "decide_later"
    case saveAsContext = "save_as_context"
    case attachToGoal = "attach_to_goal"
    case addToTime = "add_to_time"
    case changeTime = "change_time"
    case doNotUseForPlanning = "do_not_use_for_planning"

    var title: String {
        switch self {
        case .decideLater: "Decide later"
        case .saveAsContext: "Save as context"
        case .attachToGoal: "Attach to goal"
        case .addToTime: "Add to Time"
        case .changeTime: "Change time"
        case .doNotUseForPlanning: "Do not use for planning"
        }
    }

    var detail: String {
        switch self {
        case .decideLater: "Keep the capture parked without choosing a time."
        case .saveAsContext: "Store the note as context without turning it into work."
        case .attachToGoal: "Link the capture to a goal without changing Time."
        case .addToTime: "Create a proposed Time item after you confirm."
        case .changeTime: "Adjust the proposed time before anything is saved."
        case .doNotUseForPlanning: "Keep this out of planning surfaces."
        }
    }
}

struct PlanInsertionApprovalOption: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let kind: PlanInsertionApprovalOptionKind
    let title: String
    let detail: String

    init(kind: PlanInsertionApprovalOptionKind) {
        self.id = kind.rawValue
        self.kind = kind
        self.title = kind.title
        self.detail = kind.detail
    }
}

struct PlanInsertionDecisionReceipt: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let captureID: String
    let candidateID: String
    let title: String
    let summary: String
    let timeConfidence: PlanInsertionTimeConfidence
    let scheduleImpact: PlanInsertionScheduleImpact
    let conflictStatus: PlanInsertionConflictStatus
    let requiresUserApproval: Bool
    let requiresCalendarPermission: Bool
    let approvalOptionTitles: [String]

    init(
        captureID: String,
        candidateID: String,
        title: String,
        summary: String,
        timeConfidence: PlanInsertionTimeConfidence,
        scheduleImpact: PlanInsertionScheduleImpact,
        conflictStatus: PlanInsertionConflictStatus,
        requiresUserApproval: Bool,
        requiresCalendarPermission: Bool,
        approvalOptionTitles: [String]
    ) {
        self.id = "plan-insertion.\(captureID)"
        self.captureID = captureID
        self.candidateID = candidateID
        self.title = title
        self.summary = summary
        self.timeConfidence = timeConfidence
        self.scheduleImpact = scheduleImpact
        self.conflictStatus = conflictStatus
        self.requiresUserApproval = requiresUserApproval
        self.requiresCalendarPermission = requiresCalendarPermission
        self.approvalOptionTitles = approvalOptionTitles
    }

    var projection: PlanInsertionDecisionReceiptProjection {
        PlanInsertionDecisionReceiptProjection(
            title: title,
            summary: summary,
            accessibilityLabel: "Time insertion decision",
            accessibilityValue: [
                title,
                summary,
                "Time confidence: \(timeConfidence.userFacingLabel)",
                "Schedule impact: \(scheduleImpact.userFacingLabel)",
                "Conflict status: \(conflictStatus.userFacingLabel)",
                requiresCalendarPermission ? "Calendar permission required before any write." : "Calendar permission not required for the local proposal.",
                requiresUserApproval ? "Approval required." : "Approval not required."
            ].joined(separator: ". "),
            accessibilityHint: approvalOptionTitles.isEmpty
                ? nil
                : "Choose among \(approvalOptionTitles.joined(separator: ", ")).",
            actionTitles: approvalOptionTitles
        )
    }
}

struct PlanInsertionDecisionReceiptProjection: Sendable, Equatable, Hashable {
    let title: String
    let summary: String
    let accessibilityLabel: String
    let accessibilityValue: String
    let accessibilityHint: String?
    let actionTitles: [String]
}

struct PlanInsertionCandidate: Codable, Sendable, Equatable, Hashable, Identifiable {
    let captureID: String
    let title: String
    let proposedStart: DateComponents?
    let proposedEnd: DateComponents?
    let timeConfidence: PlanInsertionTimeConfidence
    let scheduleImpact: PlanInsertionScheduleImpact
    let conflictStatus: PlanInsertionConflictStatus
    let affectsProtectedTime: Bool
    let requiresCalendarPermission: Bool
    let requiresUserApproval: Bool
    let approvalOptions: [PlanInsertionApprovalOption]

    var id: String { captureID }

    var receipt: PlanInsertionDecisionReceipt {
        PlanInsertionDecisionReceipt(
            captureID: captureID,
            candidateID: "plan-insertion.\(captureID)",
            title: receiptTitle,
            summary: receiptSummary,
            timeConfidence: timeConfidence,
            scheduleImpact: scheduleImpact,
            conflictStatus: conflictStatus,
            requiresUserApproval: requiresUserApproval,
            requiresCalendarPermission: requiresCalendarPermission,
            approvalOptionTitles: approvalOptions.map(\.title)
        )
    }

    var receiptProjection: PlanInsertionDecisionReceiptProjection {
        receipt.projection
    }

    var proposedStartLabel: String {
        Self.label(for: proposedStart) ?? "Unresolved start"
    }

    var proposedEndLabel: String {
        Self.label(for: proposedEnd) ?? "No end yet"
    }

    var statusLabel: String {
        [
            "Time confidence: \(timeConfidence.userFacingLabel)",
            "Schedule impact: \(scheduleImpact.userFacingLabel)",
            "Conflict status: \(conflictStatus.userFacingLabel)",
            affectsProtectedTime ? "Protected time may be affected." : "Protected time not checked yet.",
            requiresCalendarPermission ? "Calendar permission required before any write." : "Calendar permission not required for the local proposal.",
            requiresUserApproval ? "User approval required." : "User approval not required."
        ].joined(separator: " ")
    }

    var approvalOptionTitles: [String] {
        approvalOptions.map(\.title)
    }

    private var receiptTitle: String {
        "Add to Time"
    }

    private var receiptSummary: String {
        [
            title,
            proposedStartLabel,
            proposedEndLabel,
            timeConfidence.userFacingLabel,
            scheduleImpact.userFacingLabel,
            conflictStatus.userFacingLabel
        ].joined(separator: " · ")
    }

    static func make(
        from decision: SmartAttachmentCaptureDecision
    ) -> PlanInsertionCandidate? {
        let extraction = decision.semanticExtraction
        guard extraction.dateTimeExpression != nil || extraction.interpretedDateTime != nil || decision.routeType == .plan else {
            return nil
        }

        let parsedTimeConfidence = PlanInsertionTimeConfidence(from: extraction.interpretedDateTime?.confidenceBand ?? .medium)
        let timeConfidence: PlanInsertionTimeConfidence = extraction.uncertaintyFlags.contains(.recurrenceDetected) && parsedTimeConfidence == .high
            ? .medium
            : parsedTimeConfidence
        let proposedStart = extraction.interpretedDateTime?.interpretedStart
        let proposedEnd = Self.proposedEnd(from: extraction)
        let title = Self.title(for: extraction)
        let affectsProtectedTime = Self.affectsProtectedTime(for: extraction)
        let requiresCalendarPermission = Self.requiresCalendarPermission(for: extraction, routeType: decision.routeType)
        let conflictStatus = Self.conflictStatus(
            extraction: extraction,
            affectsProtectedTime: affectsProtectedTime,
            requiresCalendarPermission: requiresCalendarPermission
        )
        let scheduleImpact = Self.scheduleImpact(
            extraction: extraction,
            timeConfidence: timeConfidence,
            conflictStatus: conflictStatus,
            routeType: decision.routeType
        )

        return PlanInsertionCandidate(
            captureID: decision.result.id,
            title: title,
            proposedStart: proposedStart,
            proposedEnd: proposedEnd,
            timeConfidence: timeConfidence,
            scheduleImpact: scheduleImpact,
            conflictStatus: conflictStatus,
            affectsProtectedTime: affectsProtectedTime,
            requiresCalendarPermission: requiresCalendarPermission,
            requiresUserApproval: true,
            approvalOptions: [
                .init(kind: .decideLater),
                .init(kind: .saveAsContext),
                .init(kind: .attachToGoal),
                .init(kind: .addToTime),
                .init(kind: .changeTime),
                .init(kind: .doNotUseForPlanning)
            ]
        )
    }

    private static func title(for extraction: CaptureSemanticExtraction) -> String {
        switch (extraction.actionVerb, extraction.object) {
        case let (verb?, object?):
            return [verb, object].joined(separator: " ").capitalized
        case let (verb?, nil):
            return verb.capitalized
        case let (nil, object?):
            return object.capitalized
        default:
            return extraction.rawText
        }
    }

    private static func proposedEnd(from extraction: CaptureSemanticExtraction) -> DateComponents? {
        guard let start = extraction.interpretedDateTime?.interpretedStart else { return nil }
        let durationMinutes = defaultDurationMinutes(for: extraction.activity)
        guard durationMinutes > 0 else { return nil }

        var end = start
        let startMinute = start.minute ?? 0
        let totalMinutes = startMinute + durationMinutes
        end.minute = totalMinutes % 60
        let hourCarry = totalMinutes / 60
        end.hour = ((start.hour ?? 0) + hourCarry) % 24
        return end
    }

    private static func defaultDurationMinutes(for activity: CaptureActivityClassification) -> Int {
        switch activity {
        case .exercise: 60
        case .communication: 30
        case .learning: 45
        case .work: 45
        case .proof: 15
        case .blocker: 30
        case .recovery: 30
        case .outing: 90
        case .unknown: 30
        }
    }

    private static func affectsProtectedTime(for extraction: CaptureSemanticExtraction) -> Bool {
        extraction.recoverySignal || extraction.blockerSignal
    }

    private static func requiresCalendarPermission(for extraction: CaptureSemanticExtraction, routeType: SmartAttachmentRouteType) -> Bool {
        routeType == .plan || extraction.interpretedDateTime != nil
    }

    private static func conflictStatus(
        extraction: CaptureSemanticExtraction,
        affectsProtectedTime: Bool,
        requiresCalendarPermission: Bool
    ) -> PlanInsertionConflictStatus {
        if let interpretation = extraction.interpretedDateTime, interpretation.requiresUserConfirmation {
            return .ambiguity
        }
        if affectsProtectedTime {
            return .protectedTime
        }
        if extraction.uncertaintyFlags.contains(.recurrenceDetected) {
            return .possibleConflict
        }
        if requiresCalendarPermission {
            return .calendarPermissionRequired
        }
        return .none
    }

    private static func scheduleImpact(
        extraction: CaptureSemanticExtraction,
        timeConfidence: PlanInsertionTimeConfidence,
        conflictStatus: PlanInsertionConflictStatus,
        routeType: SmartAttachmentRouteType
    ) -> PlanInsertionScheduleImpact {
        if routeType != .plan, extraction.dateTimeExpression == nil {
            return .contextOnly
        }
        if conflictStatus == .protectedTime {
            return .protectedTimeReview
        }
        if conflictStatus == .ambiguity || timeConfidence == .needsClarification {
            return .timeChangeRecommended
        }
        if conflictStatus == .calendarPermissionRequired {
            return .calendarPermissionGate
        }
        return .timeItemProposed
    }

    private static func label(for components: DateComponents?) -> String? {
        guard let components else { return nil }
        let weekday = components.weekday.flatMap(Self.weekdayName)
        let hour = components.hour.map { Self.hourLabel($0, minute: components.minute ?? 0) }
        let pieces = [weekday, hour].compactMap { $0 }
        return pieces.isEmpty ? nil : pieces.joined(separator: ", ")
    }

    private static func weekdayName(_ weekday: Int) -> String {
        let names = [
            1: "Sunday",
            2: "Monday",
            3: "Tuesday",
            4: "Wednesday",
            5: "Thursday",
            6: "Friday",
            7: "Saturday"
        ]
        return names[weekday] ?? "Day \(weekday)"
    }

    private static func hourLabel(_ hour: Int, minute: Int) -> String {
        let normalizedHour = ((hour % 24) + 24) % 24
        let displayHour = normalizedHour % 12 == 0 ? 12 : normalizedHour % 12
        let meridiem = normalizedHour >= 12 ? "PM" : "AM"
        let minuteText = minute == 0 ? "" : String(format: ":%02d", minute)
        return "\(displayHour)\(minuteText) \(meridiem)"
    }
}

private extension PlanInsertionTimeConfidence {
    init(from band: CaptureTimeConfidenceBand) {
        switch band {
        case .high:
            self = .high
        case .medium:
            self = .medium
        case .low:
            self = .low
        case .needsClarification:
            self = .needsClarification
        }
    }
}
