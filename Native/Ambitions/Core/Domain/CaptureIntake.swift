import Foundation

struct CaptureIntake: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let text: String?
    let voiceTranscript: String?
    let photoReference: String?
    let fileReference: String?
    let scanText: String?
    let scanDocumentReference: String?
    let locationLabel: String?
    let dateIntent: String?
    let reminderIntent: String?
    let repeatIntent: String?
    let goalIntent: String?
    let stepIntent: String?
    let proofIntent: String?
    let routingConfidence: Double
    let needsReview: Bool
    let privacyClassification: EventLedgerPrivacyClassification

    init(
        id: String,
        text: String? = nil,
        voiceTranscript: String? = nil,
        photoReference: String? = nil,
        fileReference: String? = nil,
        scanText: String? = nil,
        scanDocumentReference: String? = nil,
        locationLabel: String? = nil,
        dateIntent: String? = nil,
        reminderIntent: String? = nil,
        repeatIntent: String? = nil,
        goalIntent: String? = nil,
        stepIntent: String? = nil,
        proofIntent: String? = nil,
        routingConfidence: Double = 0,
        needsReview: Bool = true,
        privacyClassification: EventLedgerPrivacyClassification = .privateUserText
    ) {
        self.id = Self.normalizedRequired(id, fallback: "capture-intake")
        self.text = Self.normalizedOptional(text)
        self.voiceTranscript = Self.normalizedOptional(voiceTranscript)
        self.photoReference = Self.normalizedOptional(photoReference)
        self.fileReference = Self.normalizedOptional(fileReference)
        self.scanText = Self.normalizedOptional(scanText)
        self.scanDocumentReference = Self.normalizedOptional(scanDocumentReference)
        self.locationLabel = Self.normalizedOptional(locationLabel)
        self.dateIntent = Self.normalizedOptional(dateIntent)
        self.reminderIntent = Self.normalizedOptional(reminderIntent)
        self.repeatIntent = Self.normalizedOptional(repeatIntent)
        self.goalIntent = Self.normalizedOptional(goalIntent)
        self.stepIntent = Self.normalizedOptional(stepIntent)
        self.proofIntent = Self.normalizedOptional(proofIntent)
        self.routingConfidence = min(1, max(0, routingConfidence))
        self.needsReview = needsReview
        self.privacyClassification = privacyClassification
    }

    var hasAnyIntent: Bool {
        [
            dateIntent,
            reminderIntent,
            repeatIntent,
            goalIntent,
            stepIntent,
            proofIntent
        ].contains { $0?.isEmpty == false }
    }

    var reviewReason: String {
        if needsReview { return "Needs review before routing" }
        if routingConfidence < 0.75 { return "Routing confidence is low" }
        return "Ready for user-confirmed routing"
    }

    static func from(capture: Capture) -> CaptureIntake {
        CaptureIntake(
            id: capture.id,
            text: capture.rawText,
            voiceTranscript: capture.sourceType == .appIntent ? capture.rawText : nil,
            dateIntent: capture.deadlineText,
            reminderIntent: capture.revisitAfter,
            goalIntent: capture.linkedGoalID ?? capture.goalRelationship?.goalID,
            stepIntent: capture.scopeItemHint,
            proofIntent: capture.route == .proofItem || capture.route == .goalAttachment ? capture.rawText : nil,
            routingConfidence: capture.triageStatus.routingConfidence,
            needsReview: capture.triageStatus.needsReview,
            privacyClassification: capture.privacy
        )
    }

    private static func normalizedOptional(_ value: String?) -> String? {
        guard let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines), trimmed.isEmpty == false else {
            return nil
        }
        return trimmed
    }

    private static func normalizedRequired(_ value: String, fallback: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? fallback : trimmed
    }
}

extension Capture {
    var intake: CaptureIntake {
        CaptureIntake.from(capture: self)
    }
}

extension CaptureTriageStatus {
    var needsReview: Bool {
        switch self {
        case .needsTriage, .assumedRoute:
            true
        case .userCorrected, .routed, .waiting, .archived:
            false
        }
    }

    var routingConfidence: Double {
        switch self {
        case .needsTriage:
            0.15
        case .assumedRoute:
            0.55
        case .userCorrected:
            0.9
        case .routed, .waiting, .archived:
            1
        }
    }
}
