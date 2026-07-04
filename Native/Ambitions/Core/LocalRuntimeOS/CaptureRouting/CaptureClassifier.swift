import Foundation

struct CaptureClassification: Codable, Sendable, Equatable, Hashable {
    let kind: CaptureKind
    let route: CaptureRoute
    let triageStatus: CaptureTriageStatus
    let commitmentKind: NowCommitmentKind?
    let deadlineText: String?
    let deadlineKind: CaptureDeadlineKind
    let contextLensHint: NowContextLens?
    let priorityHints: CapturePriorityHints
    let assumptionSummary: String
}

enum CaptureClassifier {
    static func classify(
        text: String,
        requestedKind: CaptureKind?,
        requestedRoute: CaptureRoute?,
        deadlineText: String?,
        contextLensHint: NowContextLens?,
        priorityHints: CapturePriorityHints
    ) -> CaptureClassification {
        let lowercased = text.lowercased()
        let inferredDeadline = deadlineText ?? deadlinePhrase(in: lowercased, original: text)
        let hasDeadline = inferredDeadline != nil || lowercased.contains(" by ") || lowercased.contains("before ")
        let looksWaiting = lowercased.contains("waiting on") || lowercased.contains("blocked by") || lowercased.contains("follow up")
        let looksOptional = lowercased.contains("someday") || lowercased.contains("maybe") || lowercased.contains("optional")
        let looksDeliverable = lowercased.contains("add another") || lowercased.contains("deliverable") || lowercased.contains("song")
        let looksCommitment = lowercased.contains("send") || lowercased.contains("create") || lowercased.contains("finish") || lowercased.contains("call") || lowercased.contains("email")
        let inferredKind: CaptureKind
        let inferredRoute: CaptureRoute

        if let requestedKind {
            inferredKind = requestedKind
            inferredRoute = requestedRoute ?? route(for: requestedKind)
        } else if looksWaiting {
            inferredKind = .waitingItem
            inferredRoute = .waiting
        } else if looksOptional {
            inferredKind = .optionalSomeday
            inferredRoute = .optionalSomeday
        } else if looksDeliverable {
            inferredKind = .deliverableSeed
            inferredRoute = .deliverableSeed
        } else if hasDeadline, looksCommitment {
            inferredKind = .oneTimeCommitment
            inferredRoute = .timeSeed
        } else if hasDeadline {
            inferredKind = .deadlineTask
            inferredRoute = .timeSeed
        } else if looksCommitment {
            inferredKind = .oneTimeCommitment
            inferredRoute = .timeSeed
        } else {
            inferredKind = .raw
            inferredRoute = .captureInbox
        }

        let route = requestedRoute ?? inferredRoute
        let context = contextLensHint ?? (lowercased.contains("spreadsheet") || lowercased.contains("kaylee") || lowercased.contains("client") ? .work : nil)
        let deadlineLevel: NowPressureLevel? = hasDeadline ? .high : priorityHints.deadline
        let mergedHints = CapturePriorityHints(
            importance: priorityHints.importance,
            urgency: priorityHints.urgency ?? (hasDeadline ? .elevated : nil),
            consequence: priorityHints.consequence,
            deadline: deadlineLevel,
            effort: priorityHints.effort,
            contextFit: priorityHints.contextFit,
            optionalSomeday: inferredKind == .optionalSomeday || priorityHints.optionalSomeday,
            passive: inferredKind == .optionalSomeday || priorityHints.passive,
            goalSupporting: inferredKind == .goalSupportingTask || priorityHints.goalSupporting
        )

        return CaptureClassification(
            kind: inferredKind,
            route: route,
            triageStatus: inferredKind == .raw ? .needsTriage : .assumedRoute,
            commitmentKind: commitmentKind(for: inferredKind),
            deadlineText: inferredDeadline,
            deadlineKind: hasDeadline ? .hard : .none,
            contextLensHint: context,
            priorityHints: mergedHints,
            assumptionSummary: assumption(for: inferredKind)
        )
    }

    static func route(for kind: CaptureKind) -> CaptureRoute {
        switch kind {
        case .raw: .captureInbox
        case .oneTimeCommitment, .deadlineTask: .timeSeed
        case .goalSeed: .goalSeed
        case .goalSupportingTask: .goalAttachment
        case .deliverableSeed: .deliverableSeed
        case .waitingItem: .waiting
        case .optionalSomeday: .optionalSomeday
        case .archiveItem: .archive
        }
    }

    static func commitmentKind(for kind: CaptureKind) -> NowCommitmentKind? {
        switch kind {
        case .oneTimeCommitment, .deadlineTask: .oneTime
        case .goalSupportingTask: .goalSupporting
        case .waitingItem: .waiting
        case .optionalSomeday: .optionalSomeday
        case .raw, .goalSeed, .deliverableSeed, .archiveItem: nil
        }
    }

    static func assumption(for kind: CaptureKind) -> String {
        switch kind {
        case .raw: "I left this as a raw capture because the route was not obvious."
        case .oneTimeCommitment: "I treated this as a one-time commitment."
        case .deadlineTask: "I treated this as deadline-bound work."
        case .goalSeed: "I kept this as a possible goal seed."
        case .goalSupportingTask: "I treated this as supporting a goal."
        case .deliverableSeed: "I kept this as a deliverable seed."
        case .waitingItem: "I treated this as waiting on someone or something."
        case .optionalSomeday: "I parked this as optional or someday."
        case .archiveItem: "I archived this capture."
        }
    }

    static func deadlinePhrase(in lowercased: String, original: String) -> String? {
        let markers = [" by ", " before ", " due "]
        guard let marker = markers.first(where: { lowercased.contains($0) }),
              let range = lowercased.range(of: marker) else {
            return nil
        }
        let originalIndex = original.index(original.startIndex, offsetBy: lowercased.distance(from: lowercased.startIndex, to: range.upperBound))
        let phrase = original[originalIndex...].trimmingCharacters(in: .whitespacesAndNewlines)
        return phrase.isEmpty ? nil : phrase
    }
}
