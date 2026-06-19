import Foundation

extension CaptureSemanticExtraction {

    static func goalDomainHints(
        activity: CaptureActivityClassification,
        proofSignal: Bool,
        blockerSignal: Bool,
        recoverySignal: Bool,
        rawText: String
    ) -> [CaptureGoalDomainHint] {
        var hints = [CaptureGoalDomainHint]()
        switch activity {
        case .exercise:
            hints.append(contentsOf: [.fitness, .health])
        case .communication:
            hints.append(.relationships)
        case .learning:
            hints.append(contentsOf: [.learning, .music])
        case .work:
            hints.append(.work)
        case .proof:
            hints.append(.proof)
        case .blocker:
            hints.append(contentsOf: [.health, .recovery])
        case .recovery:
            hints.append(contentsOf: [.health, .recovery])
        case .outing:
            hints.append(contentsOf: [.outdoors, .fitness])
        case .unknown:
            break
        }
        if proofSignal {
            hints.append(.proof)
        }
        if blockerSignal || recoverySignal {
            hints.append(contentsOf: [.health, .recovery])
        }
        if rawText.contains("met ") || rawText.contains("call ") || rawText.contains("study") || rawText.contains("coach") {
            hints.append(.relationships)
        }
        if rawText.contains("study") {
            hints.append(.learning)
        }
        return Array(NSOrderedSet(array: hints)).compactMap { $0 as? CaptureGoalDomainHint }
    }


    static func uncertaintyFlags(
        timeInterpretation: CaptureTimeInterpretation?,
        recurrenceHint: String?,
        locationHint: String?,
        peopleHint: [String],
        object: String?
    ) -> [CaptureSemanticUncertaintyFlag] {
        var flags = [CaptureSemanticUncertaintyFlag]()
        if timeInterpretation?.ambiguity == .amPm {
            flags.append(.timeRequiresAMPM)
        }
        if timeInterpretation?.ambiguity == .date {
            flags.append(.relativeDateOnly)
        }
        if recurrenceHint != nil {
            flags.append(.recurrenceDetected)
        }
        if locationHint != nil {
            flags.append(.locationAmbiguous)
        }
        if peopleHint.isEmpty == false {
            flags.append(.personUnconfirmed)
        }
        if object == nil || object?.isEmpty == true {
            flags.append(.objectPartial)
        }
        if flags.isEmpty {
            flags.append(.contextualOnly)
        }
        return Array(NSOrderedSet(array: flags)).compactMap { $0 as? CaptureSemanticUncertaintyFlag }
    }


    static func containsAny(_ text: String, _ terms: [String]) -> Bool {
        terms.contains { containsWord(text, $0) }
    }


    static func containsWord(_ text: String, _ word: String) -> Bool {
        text.range(of: #"(?<![a-z0-9])"# + NSRegularExpression.escapedPattern(for: word.lowercased()) + #"(?=[^a-z0-9]|$)"#, options: .regularExpression) != nil
    }


    static func firstMatchingWord(in text: String, words: [String]) -> String? {
        words.first { containsWord(text, $0) }
    }


    static func firstMatchingSubstring(in text: String, patterns: [String]) -> String? {
        for pattern in patterns {
            if let match = firstMatch(in: text, pattern: pattern) {
                return match
            }
        }
        return nil
    }


    static func firstMatch(in text: String, pattern: String) -> String? {
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }
        let range = NSRange(text.startIndex..., in: text)
        guard let match = regex.firstMatch(in: text, options: [], range: range),
              let matchRange = Range(match.range, in: text) else {
            return nil
        }
        return String(text[matchRange]).trimmingCharacters(in: .whitespacesAndNewlines)
    }


    static func matches(in text: String, pattern: String) -> [String] {
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }
        let range = NSRange(text.startIndex..., in: text)
        return regex.matches(in: text, options: [], range: range).compactMap { match in
            guard let matchRange = Range(match.range, in: text) else { return nil }
            return String(text[matchRange])
        }
    }


    static func parsedHour(from text: String) -> Int? {
        guard let regex = try? NSRegularExpression(pattern: #"(?i)\bat\s+(\d{1,2})(?:\s?(?:am|pm))?"#) else {
            return nil
        }
        let range = NSRange(text.startIndex..., in: text)
        guard let match = regex.firstMatch(in: text, options: [], range: range),
              match.numberOfRanges > 1,
              let captureRange = Range(match.range(at: 1), in: text) else {
            return nil
        }
        return Int(String(text[captureRange]))
    }


    static func normalizedHour(_ hour: Int, isPM: Bool) -> Int {
        let boundedHour = max(0, min(hour, 23))
        guard boundedHour <= 12 else { return boundedHour }
        if isPM, boundedHour < 12 {
            return boundedHour + 12
        }
        if isPM == false, boundedHour == 12 {
            return 0
        }
        return boundedHour
    }


    static func cleaned(_ value: String) -> String? {
        let trimmed = value
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }


    static var commonTimeWords: Set<String> {
        ["am", "pm", "today", "tomorrow", "tonight", "friday", "monday", "tuesday", "wednesday", "thursday", "saturday", "sunday", "next", "every"]
    }
}
