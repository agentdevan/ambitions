import Foundation

enum GoalRelevanceConfidenceBand: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case high
    case medium
    case weak
    case rejected
}

struct GoalRelevanceCorrectionSignal: Codable, Sendable, Equatable, Hashable {
    let preferredGoalIDs: [String]
    let rejectedGoalIDs: [String]
    let note: String?

    init(preferredGoalIDs: [String] = [], rejectedGoalIDs: [String] = [], note: String? = nil) {
        self.preferredGoalIDs = Array(Set(preferredGoalIDs.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }).filter { $0.isEmpty == false }).sorted()
        self.rejectedGoalIDs = Array(Set(rejectedGoalIDs.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }).filter { $0.isEmpty == false }).sorted()
        self.note = note?.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

struct GoalRelevanceScanMatch: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let goalID: String
    let goalLabel: String
    let confidenceBand: GoalRelevanceConfidenceBand
    let score: Int
    let evidenceLabels: [String]
    let reason: String
    let requiresUserApproval: Bool
    let localOnly: Bool

    init(
        id: String,
        goalID: String,
        goalLabel: String,
        confidenceBand: GoalRelevanceConfidenceBand,
        score: Int,
        evidenceLabels: [String],
        reason: String,
        requiresUserApproval: Bool,
        localOnly: Bool
    ) {
        self.id = Self.normalized(id)
        self.goalID = Self.normalized(goalID)
        self.goalLabel = Self.normalized(goalLabel)
        self.confidenceBand = confidenceBand
        self.score = max(0, score)
        self.evidenceLabels = Array(Set(evidenceLabels.map(Self.normalized).filter { $0.isEmpty == false })).sorted()
        self.reason = Self.normalized(reason)
        self.requiresUserApproval = requiresUserApproval
        self.localOnly = localOnly
    }

    private static func normalized(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

struct GoalRelevanceScan: Codable, Sendable, Equatable, Hashable, Identifiable {
    let captureID: String
    let scannedGoalIDs: [String]
    let highConfidenceMatches: [GoalRelevanceScanMatch]
    let mediumConfidenceMatches: [GoalRelevanceScanMatch]
    let weakMatches: [GoalRelevanceScanMatch]
    let rejectedMatches: [GoalRelevanceScanMatch]
    let relevanceReasons: [String: [String]]
    let noMatchReason: String?
    let forcedAttachmentBlocked: Bool

    init(
        captureID: String,
        scannedGoalIDs: [String],
        highConfidenceMatches: [GoalRelevanceScanMatch],
        mediumConfidenceMatches: [GoalRelevanceScanMatch],
        weakMatches: [GoalRelevanceScanMatch],
        rejectedMatches: [GoalRelevanceScanMatch],
        relevanceReasons: [String: [String]],
        noMatchReason: String?,
        forcedAttachmentBlocked: Bool
    ) {
        self.captureID = captureID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.scannedGoalIDs = Array(Set(scannedGoalIDs.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }).filter { $0.isEmpty == false }).sorted()
        self.highConfidenceMatches = highConfidenceMatches
        self.mediumConfidenceMatches = mediumConfidenceMatches
        self.weakMatches = weakMatches
        self.rejectedMatches = rejectedMatches
        self.relevanceReasons = relevanceReasons.mapValues { Array(Set($0.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }).filter { $0.isEmpty == false }).sorted() }
        self.noMatchReason = noMatchReason?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.forcedAttachmentBlocked = forcedAttachmentBlocked
    }

    var id: String { captureID }

    var hasAnyRelevantMatch: Bool {
        highConfidenceMatches.isEmpty == false || mediumConfidenceMatches.isEmpty == false || weakMatches.isEmpty == false
    }

    var suggestedMatch: GoalRelevanceScanMatch? {
        highConfidenceMatches.first ?? mediumConfidenceMatches.first ?? weakMatches.first
    }

    var explanation: String {
        if let suggestedMatch {
            return suggestedMatch.reason
        }
        return noMatchReason ?? "No local goal match was strong enough to attach."
    }
}

struct GoalRelevanceScanner: Sendable, Equatable, Hashable {
    func scan(
        captureID: String,
        extraction: CaptureSemanticExtraction,
        candidates: [SmartAttachmentDestinationCandidate],
        sourceAtlasMatch: SourceAtlasIntentMatch? = nil,
        lifeContext: LifeContextRuntimeProjection? = nil,
        personalizationLedger: PersonalizationFactorLedger? = nil,
        correctionSignal: GoalRelevanceCorrectionSignal? = nil
    ) -> GoalRelevanceScan {
        let usableCandidates = candidates.filter(\.isUsable)
        let scannedGoalIDs = usableCandidates.map(\.id)
        let inputTokens = tokens(from: [extraction.rawText, extraction.normalizedText, extraction.object ?? "", extraction.activity.userFacingLabel.lowercased()])
        let domainHints = Set(extraction.goalDomainHints)
        let sourceAtlasTokens = Set((sourceAtlasMatch?.normalizedGoalIntent ?? "").split(separator: "-").map(String.init).filter { $0.isEmpty == false })
        let lifeContextTokens = lifeContextTokens(from: lifeContext)
        let ledgerTokens = ledgerTokens(from: personalizationLedger)
        var reasonsByGoalID: [String: [String]] = [:]
        var high: [GoalRelevanceScanMatch] = []
        var medium: [GoalRelevanceScanMatch] = []
        var weak: [GoalRelevanceScanMatch] = []
        var rejected: [GoalRelevanceScanMatch] = []

        for candidate in usableCandidates {
            let evaluation = evaluate(
                candidate: candidate,
                inputTokens: inputTokens,
                domainHints: domainHints,
                sourceAtlasTokens: sourceAtlasTokens,
                lifeContextTokens: lifeContextTokens,
                ledgerTokens: ledgerTokens,
                extraction: extraction,
                correctionSignal: correctionSignal
            )
            reasonsByGoalID[candidate.id] = evaluation.reasons

            let match = GoalRelevanceScanMatch(
                id: "goal-relevance.\(captureID).\(candidate.id)",
                goalID: candidate.id,
                goalLabel: candidate.label,
                confidenceBand: evaluation.band,
                score: evaluation.score,
                evidenceLabels: evaluation.evidenceLabels,
                reason: evaluation.reason,
                requiresUserApproval: evaluation.requiresUserApproval,
                localOnly: candidate.localOnly
            )

            switch evaluation.band {
            case .high:
                high.append(match)
            case .medium:
                medium.append(match)
            case .weak:
                weak.append(match)
            case .rejected:
                rejected.append(match)
            }
        }

        let forcedAttachmentBlocked = high.isEmpty == false
        let noMatchReason: String?
        if high.isEmpty, medium.isEmpty, weak.isEmpty {
            if scannedGoalIDs.isEmpty {
                noMatchReason = "No local goals were available to scan."
            } else {
                noMatchReason = "No local goal matched the capture text and goal hints."
            }
        } else {
            noMatchReason = nil
        }

        return GoalRelevanceScan(
            captureID: captureID,
            scannedGoalIDs: scannedGoalIDs,
            highConfidenceMatches: sorted(high),
            mediumConfidenceMatches: sorted(medium),
            weakMatches: sorted(weak),
            rejectedMatches: sorted(rejected),
            relevanceReasons: reasonsByGoalID,
            noMatchReason: noMatchReason,
            forcedAttachmentBlocked: forcedAttachmentBlocked
        )
    }

    private func evaluate(
        candidate: SmartAttachmentDestinationCandidate,
        inputTokens: Set<String>,
        domainHints: Set<CaptureGoalDomainHint>,
        sourceAtlasTokens: Set<String>,
        lifeContextTokens: Set<String>,
        ledgerTokens: Set<String>,
        extraction: CaptureSemanticExtraction,
        correctionSignal: GoalRelevanceCorrectionSignal?
    ) -> (band: GoalRelevanceConfidenceBand, score: Int, evidenceLabels: [String], reasons: [String], reason: String, requiresUserApproval: Bool) {
        var reasons = [String]()
        var evidence = [String]()
        var score = 0

        let labelTokens = tokens(from: [candidate.id, candidate.label, candidate.placementLabel ?? ""])
        let overlap = inputTokens.intersection(labelTokens)
        if overlap.isEmpty == false {
            let overlapList = overlap.sorted()
            evidence.append(contentsOf: overlapList)
            score += overlapList.count * 3
            reasons.append("matched local goal label terms: \(overlapList.joined(separator: ", "))")
        }

        if extraction.object?.isEmpty == false, let object = extraction.object, candidate.label.localizedCaseInsensitiveContains(object) {
            score += 3
            evidence.append(object.lowercased())
            reasons.append("object text matched goal label")
        }

        if extraction.proofSignal, candidate.destinationKind == .existingGoal {
            score += 4
            reasons.append("proof signal supports a local goal attachment")
        }

        if extraction.blockerSignal || extraction.recoverySignal {
            if containsAny(in: candidate.label, terms: ["health", "recovery", "rest", "support"]) {
                score += 2
                reasons.append("blocker or recovery signal matches the goal label")
            }
        }

        if domainHints.contains(where: { hintMatches(candidate: candidate, hint: $0) }) {
            score += 2
            reasons.append("capture goal domain hints align with the goal label")
        }

        if sourceAtlasTokens.isEmpty == false, sourceAtlasTokens.intersection(labelTokens).isEmpty == false {
            let matched = sourceAtlasTokens.intersection(labelTokens).sorted()
            score += 2
            evidence.append(contentsOf: matched)
            reasons.append("Source Atlas vocabulary echoes the same local goal terms")
        }

        if lifeContextTokens.isEmpty == false, lifeContextTokens.intersection(labelTokens).isEmpty == false {
            let matched = lifeContextTokens.intersection(labelTokens).sorted()
            score += 1
            evidence.append(contentsOf: matched)
            reasons.append("Life Context corroborates the same goal terms")
        }

        if ledgerTokens.isEmpty == false, ledgerTokens.intersection(labelTokens).isEmpty == false {
            let matched = ledgerTokens.intersection(labelTokens).sorted()
            score += 1
            evidence.append(contentsOf: matched)
            reasons.append("Personalization factors support the same goal terms")
        }

        if let correctionSignal {
            if correctionSignal.preferredGoalIDs.contains(candidate.id) {
                score += 4
                reasons.append("manual correction prefers this goal")
            }
            if correctionSignal.rejectedGoalIDs.contains(candidate.id) {
                return (
                    .rejected,
                    0,
                    evidence,
                    reasons + [correctionSignal.note ?? "manual correction rejected this goal"],
                    correctionSignal.note ?? "manual correction rejected this goal",
                    false
                )
            }
        }

        if candidate.localOnly == false {
            return (
                .rejected,
                score,
                evidence,
                reasons + ["goal is not local-only"],
                "Goal attachment stays local-only, so this match was rejected.",
                false
            )
        }

        let band: GoalRelevanceConfidenceBand
        let requiresUserApproval: Bool
        if score >= 10 {
            band = .high
            requiresUserApproval = true
        } else if score >= 5 {
            band = .medium
            requiresUserApproval = true
        } else if score > 0 {
            band = .weak
            requiresUserApproval = false
        } else {
            band = .rejected
            requiresUserApproval = false
            reasons.append("no local goal terms matched")
        }

        if let note = correctionSignal?.note, correctionSignal?.preferredGoalIDs.contains(candidate.id) == true {
            reasons.append(note)
        }

        let reason = reason(
            for: band,
            score: score,
            candidate: candidate,
            reasons: reasons,
            extraction: extraction
        )

        return (band, score, evidence, reasons, reason, requiresUserApproval)
    }

    private func reason(
        for band: GoalRelevanceConfidenceBand,
        score: Int,
        candidate: SmartAttachmentDestinationCandidate,
        reasons: [String],
        extraction: CaptureSemanticExtraction
    ) -> String {
        switch band {
        case .high:
            return "High confidence match for \(candidate.label); explicit approval is still required before attachment."
        case .medium:
            return "Medium confidence match for \(candidate.label); save standalone and suggest attachment."
        case .weak:
            return "Weak local context for \(candidate.label); keep it standalone as future context."
        case .rejected:
            if reasons.isEmpty == false {
                return reasons.joined(separator: " ")
            }
            if extraction.goalDomainHints.isEmpty {
                return "No local goal matched the capture text or goal hints."
            }
            return "No local goal matched the capture text."
        }
    }

    private func sorted(_ matches: [GoalRelevanceScanMatch]) -> [GoalRelevanceScanMatch] {
        matches.sorted { lhs, rhs in
            if lhs.score != rhs.score { return lhs.score > rhs.score }
            if lhs.goalLabel.lowercased() != rhs.goalLabel.lowercased() { return lhs.goalLabel.lowercased() < rhs.goalLabel.lowercased() }
            return lhs.goalID < rhs.goalID
        }
    }

    private func hintMatches(candidate: SmartAttachmentDestinationCandidate, hint: CaptureGoalDomainHint) -> Bool {
        let label = candidate.label.lowercased()
        switch hint {
        case .fitness:
            return containsAny(in: label, terms: ["fitness", "workout", "sport", "training", "exercise", "run", "bike", "court", "trail"])
        case .health:
            return containsAny(in: label, terms: ["health", "wellness", "clinic", "recovery", "therapy", "medical"])
        case .work:
            return containsAny(in: label, terms: ["work", "project", "launch", "build", "ship", "business"])
        case .learning:
            return containsAny(in: label, terms: ["learn", "study", "class", "lesson", "music", "practice"])
        case .music:
            return containsAny(in: label, terms: ["music", "song", "guitar", "album", "practice"])
        case .relationships:
            return containsAny(in: label, terms: ["friend", "family", "coach", "relationship", "partner", "people"])
        case .outdoors:
            return containsAny(in: label, terms: ["outdoor", "trail", "park", "field", "court", "bike"])
        case .logistics:
            return containsAny(in: label, terms: ["logistics", "travel", "schedule", "plan", "errand"])
        case .recovery:
            return containsAny(in: label, terms: ["recovery", "rest", "health", "therapy"])
        case .proof:
            return containsAny(in: label, terms: ["proof", "evidence", "receipt", "done", "finished"])
        case .general:
            return false
        }
    }

    private func containsAny(in text: String, terms: [String]) -> Bool {
        terms.contains { text.localizedCaseInsensitiveContains($0) }
    }

    private func tokens(from values: [String]) -> Set<String> {
        Set(values
            .joined(separator: " ")
            .lowercased()
            .split(whereSeparator: { !$0.isLetter && !$0.isNumber })
            .map(String.init)
            .filter { $0.isEmpty == false })
    }

    private func lifeContextTokens(from lifeContext: LifeContextRuntimeProjection?) -> Set<String> {
        guard let lifeContext else { return [] }
        var values = [String]()
        values.append(lifeContext.lifeStage.rawValue.replacingOccurrences(of: "_", with: " "))
        values.append(contentsOf: lifeContext.availableOpportunityAnchors.map(\.title))
        values.append(contentsOf: lifeContext.hardConstraints.map(\.title))
        values.append(contentsOf: lifeContext.softConstraints.map(\.title))
        return tokens(from: values)
    }

    private func ledgerTokens(from ledger: PersonalizationFactorLedger?) -> Set<String> {
        guard let ledger else { return [] }
        var values = [String]()
        values.append(contentsOf: ledger.factors.map(\.affectedRecommendationArea))
        values.append(contentsOf: ledger.factors.map(\.humanReadableReason))
        values.append(contentsOf: ledger.factors.map(\.lastAffectedLabel))
        return tokens(from: values)
    }
}
