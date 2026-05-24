import Foundation

protocol SmartAttachmentRouting: Sendable {
    func route(_ input: SmartAttachmentInput, candidates: [SmartAttachmentDestinationCandidate], maxCandidateCount: Int) -> SmartAttachmentResult
}

extension SmartAttachmentRouting {
    func route(_ input: SmartAttachmentInput, candidates: [SmartAttachmentDestinationCandidate] = []) -> SmartAttachmentResult {
        route(input, candidates: candidates, maxCandidateCount: 5)
    }
}

struct DefaultSmartAttachmentService: SmartAttachmentRouting {
    func route(
        _ input: SmartAttachmentInput,
        candidates: [SmartAttachmentDestinationCandidate] = [],
        maxCandidateCount: Int = 5
    ) -> SmartAttachmentResult {
        let text = input.rawText.trimmingCharacters(in: .whitespacesAndNewlines)
        let resultID = stableResultID(for: text)
        guard text.isEmpty == false else {
            let emptyExtraction = CaptureSemanticExtraction.extract(
                from: input,
                routeType: nil,
                selectedCandidate: nil,
                clarification: nil
            )
            let emptyScan = GoalRelevanceScanner().scan(
                captureID: resultID,
                extraction: emptyExtraction,
                candidates: []
            )
            return SmartAttachmentResult(
                id: resultID,
                input: input,
                resultState: .failedSafely,
                confidence: .unavailableFailed,
                selectedCandidate: needsPlaceCandidate(id: "candidate.needs-place.empty", input: input),
                semanticExtraction: emptyExtraction,
                goalRelevanceScan: emptyScan,
                receiptLine: "Saved to Needs a Place",
                explanation: "The capture text was preserved, but no route could be inferred from an empty input.",
                actions: [.change, .retry, .copy],
                privacyLevel: .unavailable,
                failureReason: "Empty capture text"
            )
        }

        let routeType = inferRouteType(from: text)
        let semanticExtraction = CaptureSemanticExtraction.extract(
            from: input,
            routeType: routeType,
            selectedCandidate: nil,
            clarification: nil
        )
        let goalRelevanceScan = GoalRelevanceScanner().scan(
            captureID: resultID,
            extraction: semanticExtraction,
            candidates: candidates
        )
        let rankedCandidates = rankCandidates(
            candidates: candidates,
            routeType: routeType,
            text: text,
            limit: maxCandidateCount
        )
        let tokenCount = tokens(in: text).count
        let routeIsWeak = routeType == .idea && tokenCount <= 2
        let ambiguity = ambiguityClarification(for: input, routeType: routeType, text: text)

        if routeIsWeak {
            return SmartAttachmentResult(
                id: resultID,
                input: input,
                resultState: .needsClarification,
                confidence: .needsClarification,
                selectedCandidate: needsPlaceCandidate(id: "candidate.needs-place.clarification", input: input),
                semanticExtraction: semanticExtraction,
                goalRelevanceScan: goalRelevanceScan,
                clarification: clarification(for: input),
                receiptLine: "Saved to Needs a Place",
                explanation: "Saved to Needs a Place because this needs one compact route choice.",
                actions: [.change, .task, .goal, .idea],
                privacyLevel: .privateItem
            )
        }

        if let ambiguity {
            return SmartAttachmentResult(
                id: resultID,
                input: input,
                resultState: .needsClarification,
                confidence: .needsClarification,
                selectedCandidate: needsPlaceCandidate(id: "candidate.needs-place.ambiguous", input: input),
                semanticExtraction: semanticExtraction,
                goalRelevanceScan: goalRelevanceScan,
                clarification: ambiguity,
                receiptLine: "Saved to Needs a Place",
                explanation: "Saved to Needs a Place because this could become more than one useful thing.",
                actions: ambiguity.choices.map(\.actionLabel),
                privacyLevel: .privateItem
            )
        }

        if let best = rankedCandidates.first, routeType == .proofItem {
            return SmartAttachmentResult(
                id: resultID,
                input: input,
                resultState: .savedStandalone,
                confidence: .high,
                selectedCandidate: best,
                suggestedCandidate: SmartAttachmentCandidate(
                    id: "candidate.suggested.\(best.id)",
                    target: best.target,
                    score: best.score,
                    evidenceLabels: best.evidenceLabels,
                    isSuggestedAttachment: true
                ),
                semanticExtraction: semanticExtraction,
                goalRelevanceScan: goalRelevanceScan,
                receiptLine: receiptLine(for: best.target, state: .savedStandalone),
                explanation: goalRelevanceScan.explanation,
                actions: [.change, .keepStandalone, .attach],
                privacyLevel: .privateItem
            )
        }

        if routeType == .waitingItem {
            let standalone = standaloneCandidate(routeType: .waitingItem, id: "candidate.waiting.standalone", input: input)
            return SmartAttachmentResult(
                id: resultID,
                input: input,
                resultState: .savedStandalone,
                confidence: .high,
                selectedCandidate: standalone,
                semanticExtraction: semanticExtraction,
                goalRelevanceScan: goalRelevanceScan,
                receiptLine: "Saved as Waiting",
                explanation: "Saved as Waiting because the capture names something blocked or pending.",
                actions: [.change],
                privacyLevel: .privateItem
            )
        }

        if routeType == .plan {
            let standalone = standaloneCandidate(routeType: .plan, id: "candidate.plan.standalone", input: input, placementLabel: "This Week")
            return SmartAttachmentResult(
                id: resultID,
                input: input,
                resultState: .savedStandalone,
                confidence: .high,
                selectedCandidate: standalone,
                suggestedCandidate: rankedCandidates.first,
                semanticExtraction: semanticExtraction,
                goalRelevanceScan: goalRelevanceScan,
                receiptLine: "Saved as Plan · This Week",
                explanation: "Saved as a Plan item without scheduling or calendar changes.",
                actions: [.change],
                privacyLevel: .privateItem
            )
        }

        if routeType == .task {
            let standalone = standaloneCandidate(routeType: .task, id: "candidate.task.standalone", input: input, placementLabel: "Today")
            return SmartAttachmentResult(
                id: resultID,
                input: input,
                resultState: .savedStandalone,
                confidence: rankedCandidates.isEmpty ? .medium : .medium,
                selectedCandidate: standalone,
                suggestedCandidate: rankedCandidates.first.map { SmartAttachmentCandidate(id: $0.id, target: $0.target, score: $0.score, evidenceLabels: $0.evidenceLabels, isSuggestedAttachment: true) },
                semanticExtraction: semanticExtraction,
                goalRelevanceScan: goalRelevanceScan,
                receiptLine: "Saved as Task · Today",
                explanation: rankedCandidates.first == nil
                    ? "Saved as a standalone Task because no existing local destination was reliable enough."
                    : "Saved as a standalone Task with a suggested attachment available.",
                actions: rankedCandidates.first == nil ? [.change] : [.change, .keepStandalone, .attach],
                privacyLevel: .privateItem
            )
        }

        if routeType == .goal {
            let standalone = standaloneCandidate(routeType: .goal, id: "candidate.goal.standalone", input: input, placementLabel: "Creative")
            return SmartAttachmentResult(
                id: resultID,
                input: input,
                resultState: .savedStandalone,
                confidence: .medium,
                selectedCandidate: standalone,
                semanticExtraction: semanticExtraction,
                goalRelevanceScan: goalRelevanceScan,
                receiptLine: "Saved as Goal · Creative",
                explanation: "Saved as a Goal seed; full Goal creation remains explicit and user-confirmed.",
                actions: [.change],
                privacyLevel: .privateItem
            )
        }

        if routeType == .idea {
            let standalone = standaloneCandidate(routeType: .idea, id: "candidate.idea.standalone", input: input)
            return SmartAttachmentResult(
                id: resultID,
                input: input,
                resultState: .savedStandalone,
                confidence: .medium,
                selectedCandidate: standalone,
                semanticExtraction: semanticExtraction,
                goalRelevanceScan: goalRelevanceScan,
                receiptLine: "Saved as Idea",
                explanation: "Saved as an Idea so it stays findable without becoming scheduled work.",
                actions: [.change],
                privacyLevel: .privateItem
            )
        }

        return SmartAttachmentResult(
            id: resultID,
            input: input,
            resultState: .savedToNeedsPlace,
            confidence: .low,
            selectedCandidate: needsPlaceCandidate(id: "candidate.needs-place.low", input: input),
            semanticExtraction: semanticExtraction,
            goalRelevanceScan: goalRelevanceScan,
            clarification: clarification(for: input),
            receiptLine: "Saved to Needs a Place",
            explanation: "Saved to Needs a Place because the route was not safe to infer.",
            actions: [.change, .task, .goal, .idea],
            privacyLevel: .privateItem
        )
    }
}

private extension DefaultSmartAttachmentService {
    func inferRouteType(from text: String) -> SmartAttachmentRouteType {
        let lowercased = text.lowercased()
        if lowercased.contains("waiting on") || lowercased.contains("blocked by") || lowercased.contains("follow up") {
            return .waitingItem
        }
        if lowercased.contains("proof") || lowercased.contains("finished") || lowercased.contains("completed") || lowercased.contains("screenshot") || lowercased.contains("receipt") {
            return .proofItem
        }
        if lowercased.contains("plan ") || lowercased.contains("this week") || lowercased.contains("schedule") || lowercased.contains("tomorrow") {
            return .plan
        }
        if lowercased.contains("goal") || lowercased.contains("launch") || lowercased.contains("build ") || lowercased.contains("learn ") {
            return .goal
        }
        if lowercased.contains("idea") || lowercased.contains("maybe") || lowercased.contains("someday") {
            return .idea
        }
        if containsTaskVerb(lowercased) {
            return .task
        }
        return .idea
    }

    func containsTaskVerb(_ text: String) -> Bool {
        [
            "buy", "call", "email", "send", "draft", "write", "find", "fix", "create",
            "make", "book", "pay", "pick up", "review", "submit", "finish"
        ].contains { text.contains($0) }
    }

    func ambiguityClarification(
        for input: SmartAttachmentInput,
        routeType: SmartAttachmentRouteType,
        text: String
    ) -> SmartAttachmentClarification? {
        guard routeType != .proofItem else { return nil }
        let lowercased = text.lowercased()
        var choices = [SmartAttachmentClarificationChoice]()
        if containsTaskVerb(lowercased) || lowercased.contains("tomorrow") || lowercased.contains("schedule") {
            choices.append(SmartAttachmentClarificationChoice(id: "clarify.task", actionLabel: .task, routeType: .task))
        }
        if lowercased.contains("goal") || lowercased.contains("launch") || lowercased.contains("build ") || lowercased.contains("learn ") {
            choices.append(SmartAttachmentClarificationChoice(id: "clarify.goal", actionLabel: .goal, routeType: .goal))
        }
        if lowercased.contains("idea") || lowercased.contains("maybe") || lowercased.contains("someday") {
            choices.append(SmartAttachmentClarificationChoice(id: "clarify.idea", actionLabel: .idea, routeType: .idea))
        }
        let uniqueChoices = Array(Dictionary(grouping: choices, by: \.routeType).compactMap { $0.value.first })
            .sorted { $0.routeType.rawValue < $1.routeType.rawValue }
        guard uniqueChoices.count > 1 else { return nil }
        return SmartAttachmentClarification(
            question: "What should this become first?",
            choices: Array(uniqueChoices.prefix(3))
        )
    }

    func rankCandidates(
        candidates: [SmartAttachmentDestinationCandidate],
        routeType: SmartAttachmentRouteType,
        text: String,
        limit: Int
    ) -> [SmartAttachmentCandidate] {
        let boundedLimit = max(0, min(limit, 10))
        guard boundedLimit > 0 else { return [] }
        let inputTokens = tokens(in: text)
        let ranked = candidates
            .filter(\.isUsable)
            .filter { $0.supportedRouteTypes.contains(routeType) || routeType == .proofItem && $0.supportedRouteTypes.contains(.goal) }
            .compactMap { candidate -> SmartAttachmentCandidate? in
                let labelTokens = tokens(in: candidate.label)
                let overlap = inputTokens.intersection(labelTokens)
                let phraseBonus = text.localizedCaseInsensitiveContains(candidate.label) ? 6 : 0
                let kindBonus = candidate.destinationKind == .existingGoal && [SmartAttachmentRouteType.proofItem, .task, .goal].contains(routeType) ? 2 : 0
                let score = overlap.count * 3 + phraseBonus + kindBonus
                guard score > 0 else { return nil }
                let target = SmartAttachmentRouteTarget(
                    id: "target.\(candidate.id).\(routeType.rawValue)",
                    routeType: routeType,
                    destinationKind: candidate.destinationKind,
                    destinationID: candidate.id,
                    destinationLabel: candidate.label,
                    placementLabel: candidate.placementLabel
                )
                return SmartAttachmentCandidate(
                    id: "candidate.\(candidate.id).\(routeType.rawValue)",
                    target: target,
                    score: score,
                    evidenceLabels: overlap.sorted()
                )
            }
            .sorted { lhs, rhs in
                lhs.orderingKey < rhs.orderingKey
            }
        return Array(ranked.prefix(boundedLimit))
    }

    func tokens(in text: String) -> Set<String> {
        let components = text
            .lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.count >= 3 }
        return Set(components)
    }

    func needsPlaceCandidate(id: String, input: SmartAttachmentInput) -> SmartAttachmentCandidate {
        let target = SmartAttachmentRouteTarget(
            id: "target.needs-place",
            routeType: .idea,
            destinationKind: .needsPlace,
            destinationLabel: "Needs a Place"
        )
        return SmartAttachmentCandidate(id: id, target: target, score: 0, evidenceLabels: ["Needs a Place"])
    }

    func standaloneCandidate(
        routeType: SmartAttachmentRouteType,
        id: String,
        input: SmartAttachmentInput,
        placementLabel: String? = nil
    ) -> SmartAttachmentCandidate {
        let target = SmartAttachmentRouteTarget(
            id: "target.\(routeType.rawValue).standalone",
            routeType: routeType,
            destinationKind: .standalone,
            placementLabel: placementLabel
        )
        return SmartAttachmentCandidate(id: id, target: target, score: 1, evidenceLabels: ["Standalone"])
    }

    func clarification(for input: SmartAttachmentInput) -> SmartAttachmentClarification {
        SmartAttachmentClarification(
            question: "What should this become?",
            choices: [
                SmartAttachmentClarificationChoice(id: "clarify.task", actionLabel: .task, routeType: .task),
                SmartAttachmentClarificationChoice(id: "clarify.goal", actionLabel: .goal, routeType: .goal),
                SmartAttachmentClarificationChoice(id: "clarify.idea", actionLabel: .idea, routeType: .idea)
            ]
        )
    }

    func receiptLine(for target: SmartAttachmentRouteTarget, state: SmartAttachmentResultState) -> String {
        if state == .attached, target.routeType == .proofItem {
            return "Attached as Proof · \(target.destinationLabel ?? "Goal")"
        }
        if target.isNeedsPlace {
            return "Saved to Needs a Place"
        }
        return "Saved as \(target.displaySegments.joined(separator: " · "))"
    }

    func explanation(for routeType: SmartAttachmentRouteType, candidate: SmartAttachmentCandidate) -> String {
        switch routeType {
        case .proofItem:
            return "Attached as Proof because the capture reads like evidence for a matching local goal."
        case .task:
            return "Suggested attachment because the capture shares local wording with \(candidate.target.destinationLabel ?? "an existing item")."
        case .goal:
            return "Matched an existing goal by local title wording."
        case .idea:
            return "Saved as an Idea with a local destination suggestion."
        case .waitingItem:
            return "Matched an existing Waiting item by local wording."
        case .plan:
            return "Matched an existing Plan destination by local wording."
        case .contextualNote, .reminder, .ritual, .archive, .decision:
            return "Represented as a future-compatible Smart Attachment route without building its surface here."
        }
    }

    func stableResultID(for text: String) -> String {
        let normalized = text
            .lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { $0.isEmpty == false }
            .prefix(8)
            .joined(separator: "-")
        return normalized.isEmpty ? "smart-attachment-empty" : "smart-attachment-\(normalized)"
    }
}
