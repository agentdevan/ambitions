import Foundation

enum ReminderCaptureSemanticKind: String, Codable, Sendable, Equatable, Hashable {
    case concreteReminder = "concrete_reminder"
    case recurringReminder = "recurring_reminder"
    case waitingReminder = "waiting_reminder"
    case reviewNeeded = "review_needed"
}

struct ReminderNaturalLanguageCaptureParseResult: Codable, Sendable, Equatable, Hashable {
    let rawText: String
    let normalizedText: String
    let title: String
    let semanticKind: ReminderCaptureSemanticKind
    let triggerKind: ReminderTriggerKind
    let state: ReminderState
    let deliveryPolicy: ReminderDeliveryPolicy
    let timingPhrase: String?
    let recurrencePhrase: String?
    let waitingOn: String?
    let followUpText: String?
    let needsReview: Bool
    let reviewReason: String?
    let source: ReminderSource
    let inspectionBoundary: ReminderYouInspectionBoundary

    var sourceRecordID: String {
        source.sourceRecordID
    }

    var receiptID: String? {
        source.receiptID
    }

    var replayTraceID: String? {
        source.replayTraceID
    }

    var localReminderYouInspectionSummary: String {
        source.localReminderYouInspectionSummary
    }
}

private struct ReminderWaitingPhrase: Sendable, Equatable, Hashable {
    let value: String
    let state: ReminderState
    let noteLabel: String
}

struct ReminderNaturalLanguageCaptureParser: Sendable {
    func parse(
        _ rawText: String,
        sourceRecord: ReminderSourceRecord,
        sourceObject: LifeGraphObjectReference,
        receipt: Receipt? = nil,
        replayTrace: ReplayTrace? = nil,
        surfaceTitle: String = "What Ambitions knows"
    ) -> ReminderNaturalLanguageCaptureParseResult? {
        let normalizedText = Self.normalizedText(rawText)
        guard normalizedText.isEmpty == false else { return nil }

        let lowercased = normalizedText.lowercased()
        let waitingPhrase = Self.waitingOnPhrase(in: lowercased, original: normalizedText)
        let waitingOn = waitingPhrase?.value
        let recurrencePhrase = Self.recurrencePhrase(in: lowercased, original: normalizedText)
        let followUpText = Self.followUpPhrase(in: lowercased, original: normalizedText)
        let rawTimingPhrase = Self.timingPhrase(in: lowercased, original: normalizedText)
        let hasExplicitClockTime = Self.hasExplicitClockTime(in: lowercased)
        let timingPhrase = recurrencePhrase != nil && hasExplicitClockTime == false ? nil : rawTimingPhrase
        let hasAmbiguousLanguage = Self.hasAmbiguousLanguage(in: lowercased)
        let needsReview = Self.needsReview(
            waitingOn: waitingOn,
            recurrencePhrase: recurrencePhrase,
            timingPhrase: timingPhrase,
            hasExplicitClockTime: hasExplicitClockTime,
            hasAmbiguousLanguage: hasAmbiguousLanguage
        )

        let semanticKind: ReminderCaptureSemanticKind
        let triggerKind: ReminderTriggerKind
        let state: ReminderState

        if let waitingPhrase {
            semanticKind = .waitingReminder
            triggerKind = .manual
            state = waitingPhrase.state
        } else if recurrencePhrase != nil {
            semanticKind = .recurringReminder
            triggerKind = .recurring
            state = needsReview ? .draft : .scheduled
        } else if timingPhrase != nil {
            semanticKind = .concreteReminder
            triggerKind = .manual
            state = needsReview ? .draft : .scheduled
        } else {
            semanticKind = .reviewNeeded
            triggerKind = .manual
            state = .draft
        }

        let reviewReason = Self.reviewReason(
            semanticKind: semanticKind,
            hasExplicitClockTime: hasExplicitClockTime,
            waitingOn: waitingOn,
            recurrencePhrase: recurrencePhrase,
            timingPhrase: timingPhrase,
            hasAmbiguousLanguage: hasAmbiguousLanguage
        )

        let sourceNotes = [
            timingPhrase.map { "timing: \($0)" },
            recurrencePhrase.map { "recurrence: \($0)" },
            waitingPhrase.map { "\($0.noteLabel): \($0.value)" },
            followUpText.map { "follow up: \($0)" },
            reviewReason.map { "review: \($0)" }
        ].compactMap { $0 }

        let source = ReminderSource(
            record: sourceRecord,
            sourceObject: sourceObject,
            surfaceTitle: surfaceTitle,
            inspectionSummary: "You / What Ambitions knows can inspect this SourceRecord, Receipt, and ReplayTrace.",
            receipt: receipt,
            replayTrace: replayTrace,
            notes: sourceNotes
        )

        return ReminderNaturalLanguageCaptureParseResult(
            rawText: rawText,
            normalizedText: normalizedText,
            title: normalizedText,
            semanticKind: semanticKind,
            triggerKind: triggerKind,
            state: state,
            deliveryPolicy: .localNotification,
            timingPhrase: timingPhrase,
            recurrencePhrase: recurrencePhrase,
            waitingOn: waitingOn,
            followUpText: followUpText,
            needsReview: needsReview,
            reviewReason: reviewReason,
            source: source,
            inspectionBoundary: ReminderYouInspectionBoundary(
                surfaceTitle: surfaceTitle,
                sourceKnowledgeLabel: source.sourceRecordLabel,
                allowsRawActivityLog: false
            )
        )
    }

    private static func normalizedText(_ text: String) -> String {
        text
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .split { $0.isWhitespace || $0.isNewline }
            .joined(separator: " ")
    }

    private static func waitingOnPhrase(in lowercased: String, original: String) -> ReminderWaitingPhrase? {
        for marker in [
            ("waiting on", ReminderState.waiting, "waiting on"),
            ("waiting for", ReminderState.waiting, "waiting for"),
            ("blocked by", ReminderState.blocked, "blocked by")
        ] {
            if let phrase = tail(after: marker.0, in: lowercased, original: original) {
                return ReminderWaitingPhrase(value: phrase, state: marker.1, noteLabel: marker.2)
            }
        }
        return nil
    }

    private static func recurrencePhrase(in lowercased: String, original: String) -> String? {
        for marker in [
            "every monday",
            "every tuesday",
            "every wednesday",
            "every thursday",
            "every friday",
            "every saturday",
            "every sunday",
            "every week",
            "every month",
            "each week",
            "each month",
            "weekly",
            "monthly",
            "daily"
        ] {
            if let phrase = phrase(after: marker, in: lowercased, original: original) {
                return phrase
            }
        }
        return nil
    }

    private static func followUpPhrase(in lowercased: String, original: String) -> String? {
        for marker in ["follow up", "follow-up"] {
            if let phrase = phrase(after: marker, in: lowercased, original: original) {
                return phrase
            }
        }
        return nil
    }

    private static func timingPhrase(in lowercased: String, original: String) -> String? {
        let markers = [
            "tomorrow at",
            "tomorrow",
            "tonight",
            "today",
            "next week",
            "next monday",
            "next tuesday",
            "next wednesday",
            "next thursday",
            "next friday",
            "next saturday",
            "next sunday",
            "monday",
            "tuesday",
            "wednesday",
            "thursday",
            "friday",
            "saturday",
            "sunday",
            "at "
        ]
        for marker in markers {
            if let phrase = phrase(after: marker, in: lowercased, original: original) {
                return phrase
            }
        }
        return nil
    }

    private static func hasExplicitClockTime(in lowercased: String) -> Bool {
        lowercased.range(of: #"\b\d{1,2}(?::\d{2})?\s*(?:a\.m\.|p\.m\.|am|pm)\b"#, options: .regularExpression) != nil ||
            lowercased.range(of: #"\bat\s+\d{1,2}(?::\d{2})?\b"#, options: .regularExpression) != nil
    }

    private static func needsReview(
        waitingOn: String?,
        recurrencePhrase: String?,
        timingPhrase: String?,
        hasExplicitClockTime: Bool,
        hasAmbiguousLanguage: Bool
    ) -> Bool {
        if waitingOn != nil {
            if hasAmbiguousLanguage {
                return true
            }
            if timingPhrase != nil && hasExplicitClockTime == false {
                return true
            }
            return false
        }
        guard recurrencePhrase != nil || timingPhrase != nil else { return true }

        if hasAmbiguousLanguage {
            return true
        }

        let timingRequiresReview = hasExplicitClockTime == false
        if recurrencePhrase != nil {
            return timingRequiresReview
        }
        if let timingPhrase {
            if timingPhrase.lowercased().contains("next week") {
                return true
            }
            return timingRequiresReview
        }
        return true
    }

    private static func reviewReason(
        semanticKind: ReminderCaptureSemanticKind,
        hasExplicitClockTime: Bool,
        waitingOn: String?,
        recurrencePhrase: String?,
        timingPhrase: String?,
        hasAmbiguousLanguage: Bool
    ) -> String? {
        if waitingOn != nil {
            if timingPhrase != nil && hasExplicitClockTime == false {
                return "A follow-up was found, but no time of day was supplied."
            }
            return nil
        }
        if hasAmbiguousLanguage {
            return "Reminder language is ambiguous enough to review before saving."
        }
        if semanticKind == .reviewNeeded {
            return "Reminder language is ambiguous enough to review before saving."
        }
        if recurrencePhrase != nil && hasExplicitClockTime == false {
            return "A recurrence was found, but no time of day was supplied."
        }
        if let timingPhrase {
            if timingPhrase.lowercased().contains("next week") {
                return "A follow-up was found, but no time of day was supplied."
            }
            if hasExplicitClockTime == false {
                return "A date was found, but no time of day was supplied."
            }
        }
        return nil
    }

    private static func hasAmbiguousLanguage(in lowercased: String) -> Bool {
        lowercased.contains("maybe") || lowercased.contains("ambiguous") || lowercased.contains("??")
    }

    private static func phrase(after marker: String, in lowercased: String, original: String) -> String? {
        guard let range = lowercased.range(of: marker) else { return nil }
        let lowerDistance = lowercased.distance(from: lowercased.startIndex, to: range.lowerBound)
        let startIndex = original.index(original.startIndex, offsetBy: lowerDistance)
        // Preserve the matched reminder phrase so the user can review the original intent.
        let slice = original[startIndex...]
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: CharacterSet(charactersIn: ".,;:"))
        return slice.isEmpty ? nil : slice
    }

    private static func tail(after marker: String, in lowercased: String, original: String) -> String? {
        guard let range = lowercased.range(of: marker) else { return nil }
        let lowerDistance = lowercased.distance(from: lowercased.startIndex, to: range.upperBound)
        let startIndex = original.index(original.startIndex, offsetBy: lowerDistance)
        let slice = original[startIndex...]
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: CharacterSet(charactersIn: ".,;:"))
        return slice.isEmpty ? nil : slice
    }
}
