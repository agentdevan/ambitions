import Foundation

extension CaptureSemanticExtraction {
    static func normalizedText(from rawText: String) -> String {
        rawText
            .lowercased()
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }


    static func activityClassification(
        for normalizedText: String,
        routeType: SmartAttachmentRouteType?,
        selectedCandidate: SmartAttachmentCandidate?
    ) -> CaptureActivityClassification {
        if containsAny(normalizedText, ["finished", "completed", "logged", "proof"]) {
            return .proof
        }
        if containsAny(normalizedText, ["closed", "blocked", "waiting", "stuck", "late"]) {
            return .blocker
        }
        if containsAny(normalizedText, ["hurt", "sore", "recover", "recovery", "rest", "practice"]) {
            return .recovery
        }
        if containsAny(normalizedText, ["lesson", "study", "learn", "guitar", "music"]) {
            return .learning
        }
        if containsAny(normalizedText, ["call", "email", "text", "meet", "met", "coach"]) {
            return .communication
        }
        if containsAny(normalizedText, ["ymca", "open court", "court"]) {
            return .outing
        }
        if containsAny(normalizedText, ["run", "ran", "walk", "bike", "pickleball", "workout", "practice", "court", "trail"]) {
            return .exercise
        }
        if containsAny(normalizedText, ["worked", "work", "send", "draft", "write"]) {
            return .work
        }
        if containsAny(normalizedText, ["trip", "travel", "visit", "ymca"]) {
            return .outing
        }
        if routeType == .goal || selectedCandidate?.target.routeType == .goal {
            return .work
        }
        return .unknown
    }


    static func actionVerb(in normalizedText: String) -> String? {
        let verbs = [
            "finished", "completed", "logged", "call", "email", "meet", "met", "play",
            "ran", "run", "worked", "work", "hurt", "study", "learn", "practice"
        ]
        return firstMatchingWord(in: normalizedText, words: verbs)
    }


    static func dateTimeExpression(in rawText: String) -> String? {
        let patterns = [
            #"(?i)\bat\s+\d{1,2}(?:\s?(?:am|pm))?(?:\s+(?:next\s+)?(?:monday|tuesday|wednesday|thursday|friday|saturday|sunday))?"#,
            #"(?i)\bnext\s+(?:monday|tuesday|wednesday|thursday|friday|saturday|sunday)\b"#,
            #"(?i)\bevery\s+(?:monday|tuesday|wednesday|thursday|friday|saturday|sunday)\b"#,
            #"(?i)\b(?:today|tomorrow|tonight|friday|monday|tuesday|wednesday|thursday|saturday|sunday)\b"#
        ]
        return firstMatchingSubstring(in: rawText, patterns: patterns)
    }


    static func timeInterpretation(for rawText: String, dateTimeExpression: String?) -> CaptureTimeInterpretation? {
        guard let dateTimeExpression else { return nil }
        let lowercased = dateTimeExpression.lowercased()
        let timezone = TimeZone.current.identifier

        if lowercased.contains("every ") {
            return CaptureTimeInterpretation(
                originalExpression: dateTimeExpression,
                interpretedStart: nil,
                interpretedEnd: nil,
                timezone: timezone,
                ambiguity: .recurrence,
                requiresUserConfirmation: false,
                confidenceBand: .medium,
                explanation: "The capture names a recurrence without a specific clock time."
            )
        }

        if let hour = parsedHour(from: lowercased) {
            let explicitMeridiem = lowercased.contains("am") || lowercased.contains("pm")
            let clarifiedHour = normalizedHour(hour, isPM: lowercased.contains("pm"))
            var components = DateComponents()
            components.hour = clarifiedHour
            components.minute = 0
            return CaptureTimeInterpretation(
                originalExpression: dateTimeExpression,
                interpretedStart: components,
                interpretedEnd: nil,
                timezone: timezone,
                ambiguity: explicitMeridiem ? .none : .amPm,
                requiresUserConfirmation: explicitMeridiem == false,
                confidenceBand: explicitMeridiem ? .high : .needsClarification,
                explanation: explicitMeridiem
                    ? "The capture includes an explicit clock time."
                    : "The capture includes a clock time without AM or PM."
            )
        }

        if containsAny(lowercased, ["today", "tomorrow", "tonight", "friday", "monday", "tuesday", "wednesday", "thursday", "saturday", "sunday"]) {
            return CaptureTimeInterpretation(
                originalExpression: dateTimeExpression,
                interpretedStart: nil,
                interpretedEnd: nil,
                timezone: timezone,
                ambiguity: .date,
                requiresUserConfirmation: false,
                confidenceBand: .medium,
                explanation: "The capture names a relative day without a clock time."
            )
        }

        return CaptureTimeInterpretation(
            originalExpression: dateTimeExpression,
            interpretedStart: nil,
            interpretedEnd: nil,
            timezone: timezone,
            ambiguity: .other,
            requiresUserConfirmation: false,
            confidenceBand: .low,
            explanation: "The capture mentions time language that stays local until the user confirms it."
        )
    }


    static func recurrenceHint(in rawText: String) -> String? {
        firstMatchingSubstring(
            in: rawText,
            patterns: [
                #"(?i)\bevery\s+(?:monday|tuesday|wednesday|thursday|friday|saturday|sunday)\b"#,
                #"(?i)\bevery\s+(?:week|day|month|year)\b"#
            ]
        )
    }


    static func locationHint(in rawText: String) -> String? {
        if let facility = facilityHint(in: rawText) {
            return facility
        }
        if let match = firstMatchingSubstring(
            in: rawText,
            patterns: [
                #"(?i)\b(?:at|in|on|near)\s+[A-Z][A-Za-z0-9&'\- ]+"#,
                #"(?i)\b(?:court|trail|studio|gym|park|office|home)\b"#
            ]
        ) {
            return match.replacingOccurrences(of: #"(?i)^(?:at|in|on|near)\s+"#, with: "", options: .regularExpression)
        }
        return nil
    }


    static func equipmentHint(in rawText: String) -> String? {
        firstMatchingSubstring(
            in: rawText,
            patterns: [
                #"(?i)\b(guitar|bike|bicycle|ball|paddle|weights|dumbbells|mat)\b"#
            ]
        )
    }


    static func facilityHint(in rawText: String) -> String? {
        firstMatchingSubstring(
            in: rawText,
            patterns: [
                #"(?i)\bymca\b"#,
                #"(?i)\b(?:court|trail|gym|studio|clinic|field|pool)\b"#
            ]
        )
    }


    static func peopleHint(in rawText: String) -> [String] {
        var hints = [String]()
        if let directRole = firstMatchingSubstring(in: rawText, patterns: [#"(?i)\bcall\s+coach\b"#]) {
            hints.append(directRole.replacingOccurrences(of: #"(?i)^call\s+"#, with: "", options: .regularExpression))
        }
        let names = matches(in: rawText, pattern: #"\b[A-Z][a-z]+\b"#)
            .filter { !commonTimeWords.contains($0.lowercased()) }
            .filter { $0 != "YMCA" }
        hints.append(contentsOf: names)
        return Array(NSOrderedSet(array: hints)).compactMap { $0 as? String }
    }


    static func objectPhrase(
        in rawText: String,
        actionVerb: String?,
        dateTimeExpression: String?
    ) -> String? {
        let lowercased = rawText.lowercased()
        if lowercased.contains("met ") && lowercased.contains(" for ") {
            if let forRange = rawText.range(of: #"(?i)\bfor\s+(.+)$"#, options: .regularExpression) {
                let value = String(rawText[forRange]).replacingOccurrences(of: #"(?i)^for\s+"#, with: "", options: .regularExpression)
                return cleaned(value)
            }
        }
        guard let actionVerb else {
            if let blockerObject = firstMatchingSubstring(
                in: rawText,
                patterns: [
                    #"(?i)^(.*?)(?:\s+closed\b|\s+open\b|\s+hurt\b)$"#
                ]
            ) {
                return cleaned(blockerObject.replacingOccurrences(of: #"(?i)\s+(?:closed|open|hurt)$"#, with: "", options: .regularExpression))
            }
            if let dateTimeExpression,
               let range = rawText.range(of: dateTimeExpression, options: [.caseInsensitive]) {
                let withoutDate = rawText.replacingCharacters(in: range, with: "")
                return cleaned(withoutDate)
            }
            return cleaned(rawText)
        }

        guard let verbRange = lowercased.range(of: actionVerb.lowercased()) else {
            return cleaned(rawText)
        }

        let before = String(rawText[..<verbRange.lowerBound]).trimmingCharacters(in: .whitespacesAndNewlines)
        let after = String(rawText[verbRange.upperBound...]).trimmingCharacters(in: .whitespacesAndNewlines)
        if actionVerb == "hurt", before.isEmpty == false {
            return cleaned(before)
        }
        if actionVerb == "call", after.isEmpty == false {
            return cleaned(after.replacingOccurrences(of: #"(?i)\b(?:today|tomorrow|tonight|friday|monday|tuesday|wednesday|thursday|saturday|sunday|next\s+\w+)\b.*$"#, with: "", options: .regularExpression))
        }
        if after.isEmpty == false {
            let clipped = after.replacingOccurrences(
                of: #"(?i)\s+(?:at|on|in|near|by|today|tomorrow|tonight|every|next\s+\w+)\b.*$"#,
                with: "",
                options: .regularExpression
            )
            if let cleanedAfter = cleaned(clipped) {
                return cleanedAfter
            }
        }
        if before.isEmpty == false {
            return cleaned(before)
        }
        return cleaned(after)
    }


    static func durationEstimate(in rawText: String) -> String? {
        firstMatchingSubstring(
            in: rawText,
            patterns: [
                #"(?i)\b\d+\s*(?:miles?|minutes?|mins?|hours?|hrs?)\b"#
            ]
        )
    }
}
