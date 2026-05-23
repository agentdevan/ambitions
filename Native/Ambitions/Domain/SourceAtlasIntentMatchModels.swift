import Foundation

enum SourceAtlasIntentMatchConfidenceBand: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case unknown
    case low
    case medium
    case high
}

struct SourceAtlasIntentMatch: Codable, Sendable, Equatable, Hashable {
    let rawGoalText: String
    let normalizedGoalIntent: String
    let matchedDomainIDs: [String]
    let matchedSpecificDomainIDs: [String]
    let matchedSkillSliceIDs: [String]
    let matchedRoleIDs: [String]
    let confidenceBand: SourceAtlasIntentMatchConfidenceBand
    let missingClarifications: [String]
    let sourceAtlasPackIDs: [String]
    let rejectedPackIDs: [String]
    let matchTrace: [String]
}

struct SourceAtlasPackSelection: Codable, Sendable, Equatable, Hashable {
    let selectedPackIDs: [String]
    let rejectedPackIDs: [String]
    let rejectionReasons: [String: [String]]
    let sourceState: SourceAtlasRequirementSourceState
    let freshnessState: SourceAtlasRequirementFreshnessState
    let riskState: SourceAtlasRequirementRiskState
    let reviewState: SourceAtlasRequirementReviewState
    let canDriveRuntime: Bool
    let requiredUserReview: Bool
}

struct SourceAtlasIntentMatcher: Sendable, Equatable, Hashable {
    let packs: [SourceAtlasPack]

    init(packs: [SourceAtlasPack]) {
        self.packs = packs
    }

    func match(rawGoalText: String) -> SourceAtlasIntentMatch {
        let evaluation = evaluate(rawGoalText: rawGoalText)
        return evaluation.match
    }

    func select(rawGoalText: String) -> SourceAtlasPackSelection {
        evaluate(rawGoalText: rawGoalText).selection
    }

    func evaluate(rawGoalText: String) -> (match: SourceAtlasIntentMatch, selection: SourceAtlasPackSelection) {
        let normalizedInput = Self.normalizedGoalText(rawGoalText)
        let rule = Self.intentRule(for: normalizedInput)
        let queryEngine = SourceAtlasQueryEngine(packs: packs)
        let candidatePacks = Self.candidatePacks(
            in: packs,
            normalizedGoalIntent: rule.normalizedGoalIntent,
            rule: rule
        )

        let queryResponses = rule.matchedDomainIDs.isEmpty
            ? [queryEngine.query(SourceAtlasQuery(goalIntent: rule.normalizedGoalIntent))]
            : rule.matchedDomainIDs.map {
                queryEngine.query(
                    SourceAtlasQuery(
                        goalIntent: rule.normalizedGoalIntent,
                        domainID: $0
                    )
                )
            }

        let selectionEvaluation = Self.selectionEvaluation(
            match: rule,
            candidatePacks: candidatePacks,
            queryResponses: queryResponses
        )
        let selection = SourceAtlasPackSelection(
            selectedPackIDs: selectionEvaluation.selectedPackIDs,
            rejectedPackIDs: selectionEvaluation.rejectedPackIDs,
            rejectionReasons: selectionEvaluation.rejectionReasons,
            sourceState: selectionEvaluation.sourceState,
            freshnessState: selectionEvaluation.freshnessState,
            riskState: selectionEvaluation.riskState,
            reviewState: selectionEvaluation.reviewState,
            canDriveRuntime: selectionEvaluation.canDriveRuntime,
            requiredUserReview: selectionEvaluation.requiredUserReview
        )

        let matchTrace = Self.matchTrace(
            rawGoalText: rawGoalText,
            normalizedInput: normalizedInput,
            rule: rule,
            candidatePackIDs: candidatePacks.map(\.id),
            selection: selection
        )

        let match = SourceAtlasIntentMatch(
            rawGoalText: rawGoalText.trimmingCharacters(in: .whitespacesAndNewlines),
            normalizedGoalIntent: rule.normalizedGoalIntent,
            matchedDomainIDs: rule.matchedDomainIDs,
            matchedSpecificDomainIDs: rule.matchedSpecificDomainIDs,
            matchedSkillSliceIDs: rule.matchedSkillSliceIDs,
            matchedRoleIDs: rule.matchedRoleIDs,
            confidenceBand: rule.confidenceBand,
            missingClarifications: rule.missingClarifications,
            sourceAtlasPackIDs: candidatePacks.map(\.id),
            rejectedPackIDs: selection.rejectedPackIDs,
            matchTrace: matchTrace
        )

        return (match: match, selection: selection)
    }
}

private extension SourceAtlasIntentMatcher {
    struct IntentRule {
        let normalizedGoalIntent: String
        let matchedDomainIDs: [String]
        let matchedSpecificDomainIDs: [String]
        let matchedSkillSliceIDs: [String]
        let matchedRoleIDs: [String]
        let confidenceBand: SourceAtlasIntentMatchConfidenceBand
        let missingClarifications: [String]
        let traceSignals: [String]
    }

    struct PackSelectionEvaluation {
        let selectedPackIDs: [String]
        let rejectedPackIDs: [String]
        let rejectionReasons: [String: [String]]
        let sourceState: SourceAtlasRequirementSourceState
        let freshnessState: SourceAtlasRequirementFreshnessState
        let riskState: SourceAtlasRequirementRiskState
        let reviewState: SourceAtlasRequirementReviewState
        let canDriveRuntime: Bool
        let requiredUserReview: Bool
        let selectedResult: SourceAtlasQueryResult?
    }

    static func normalizedGoalText(_ text: String) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else {
            return ""
        }

        let lowercased = trimmed
            .lowercased()
            .replacingOccurrences(of: ",", with: "")
            .replacingOccurrences(of: "$", with: "")

        let scalarParts = lowercased.unicodeScalars.map { scalar -> String in
            if CharacterSet.alphanumerics.contains(scalar) {
                return String(scalar)
            }
            return " "
        }

        return scalarParts
            .joined()
            .split(whereSeparator: \.isWhitespace)
            .joined(separator: "-")
    }

    static func intentRule(for normalizedGoalText: String) -> IntentRule {
        let tokens = Set(normalizedGoalText.split(separator: "-").map(String.init))

        if tokens.contains("football") {
            return IntentRule(
                normalizedGoalIntent: normalizedGoalText,
                matchedDomainIDs: ["sports"],
                matchedSpecificDomainIDs: ["sports.football.high-school"],
                matchedSkillSliceIDs: ["sports.football.varsity"],
                matchedRoleIDs: ["role.athlete"],
                confidenceBand: .high,
                missingClarifications: [],
                traceSignals: ["football", "varsity", "high-school"]
            )
        }

        if tokens.contains("song") || tokens.contains("songs") || (tokens.contains("music") && tokens.contains("release")) {
            return IntentRule(
                normalizedGoalIntent: normalizedGoalText,
                matchedDomainIDs: ["creative"],
                matchedSpecificDomainIDs: ["creative.music.release"],
                matchedSkillSliceIDs: ["creative.music.release.songs"],
                matchedRoleIDs: ["role.creator"],
                confidenceBand: .medium,
                missingClarifications: [],
                traceSignals: ["music", "release", "songs"]
            )
        }

        if tokens.contains("debt") || tokens.contains("pay") || tokens.contains("repayment") {
            return IntentRule(
                normalizedGoalIntent: normalizedGoalText,
                matchedDomainIDs: ["financial"],
                matchedSpecificDomainIDs: ["financial.debt.repayment"],
                matchedSkillSliceIDs: ["financial.debt.repayment.plan"],
                matchedRoleIDs: ["role.financial-steward"],
                confidenceBand: .medium,
                missingClarifications: [],
                traceSignals: ["financial", "debt", "repayment"]
            )
        }

        return IntentRule(
            normalizedGoalIntent: "goal-scaffold",
            matchedDomainIDs: [],
            matchedSpecificDomainIDs: [],
            matchedSkillSliceIDs: [],
            matchedRoleIDs: [],
            confidenceBand: .unknown,
            missingClarifications: ["Need one concrete goal domain or outcome."],
            traceSignals: ["clarify", "missing-source"]
        )
    }

    static func candidatePacks(
        in packs: [SourceAtlasPack],
        normalizedGoalIntent: String,
        rule: IntentRule
    ) -> [SourceAtlasPack] {
        let matchedDomainIDs = Set(rule.matchedDomainIDs)
        let matchedSpecificIDs = Set(rule.matchedSpecificDomainIDs)
        let matchedSkillSliceIDs = Set(rule.matchedSkillSliceIDs)
        let matchedRoleIDs = Set(rule.matchedRoleIDs)

        return packs.filter { pack in
            let projectionMatch = pack.projections.contains(where: { $0.goalIntent == normalizedGoalIntent })
            let domainMatch = matchedDomainIDs.contains(pack.manifest.domainID)
            let nestedDomainMatch = pack.domainPacks.contains(where: { matchedSpecificIDs.contains($0.id) || matchedDomainIDs.contains($0.domainID) })
            let specificMatch = pack.specificDomainPacks.contains(where: { specific in
                matchedSpecificIDs.contains(specific.id) ||
                    specific.skillSliceIDs.contains(where: matchedSkillSliceIDs.contains) ||
                    specific.roleOverlayIDs.contains(where: matchedRoleIDs.contains)
            })
            let capabilityMatch = pack.capabilityGraphs.contains(where: { graph in
                graph.roleOverlayIDs.contains(where: matchedRoleIDs.contains)
            })

            return projectionMatch && (domainMatch || nestedDomainMatch || specificMatch || capabilityMatch)
        }
        .sorted { $0.id < $1.id }
    }

    static func selectionEvaluation(
        match rule: IntentRule,
        candidatePacks: [SourceAtlasPack],
        queryResponses: [SourceAtlasQueryResponse]
    ) -> PackSelectionEvaluation {
        let allResults = queryResponses.flatMap(\.results)
        let resultsByPackID = Dictionary(grouping: allResults, by: \.packID)

        var selectedPackIDs: [String] = []
        var rejectedPackIDs: [String] = []
        var rejectionReasonsByPackID: [String: [String]] = [:]
        var selectedResult: SourceAtlasQueryResult?

        for pack in candidatePacks {
            let packResults = resultsByPackID[pack.id] ?? []
            let bestResult = packResults.first(where: \.canSupportCurrentUse) ?? packResults.first
            let reasons = self.rejectionReasons(for: pack, result: bestResult)

            if reasons.isEmpty, let bestResult {
                selectedPackIDs.append(pack.id)
                if selectedResult == nil || bestResult.canSupportCurrentUse {
                    selectedResult = bestResult
                }
            } else {
                rejectedPackIDs.append(pack.id)
                rejectionReasonsByPackID[pack.id] = reasons
            }
        }

        let orderedSelectedPackIDs = Self.orderedUnique(selectedPackIDs)
        let orderedRejectedPackIDs = Self.orderedUnique(rejectedPackIDs)
        let selectedStates = selectedResult

        let sourceState = selectedStates?.sourceState
            ?? allResults.first?.sourceState
            ?? .sourceNeeded
        let freshnessState = selectedStates?.freshnessState
            ?? allResults.first?.freshnessState
            ?? .unknown
        let riskState = selectedStates?.riskState
            ?? allResults.first?.riskState
            ?? .unknown
        let reviewState = selectedStates?.reviewState
            ?? allResults.first?.reviewState
            ?? .required

        let canDriveRuntime = orderedSelectedPackIDs.isEmpty == false

        let requiredUserReview = orderedSelectedPackIDs.isEmpty && (rule.missingClarifications.isEmpty == false || orderedRejectedPackIDs.isEmpty == false)

        return PackSelectionEvaluation(
            selectedPackIDs: orderedSelectedPackIDs,
            rejectedPackIDs: orderedRejectedPackIDs,
            rejectionReasons: rejectionReasonsByPackID,
            sourceState: sourceState,
            freshnessState: freshnessState,
            riskState: riskState,
            reviewState: reviewState,
            canDriveRuntime: canDriveRuntime,
            requiredUserReview: requiredUserReview,
            selectedResult: selectedResult
        )
    }

    static func rejectionReasons(
        for pack: SourceAtlasPack,
        result: SourceAtlasQueryResult?
    ) -> [String] {
        var reasons: [String] = []

        if pack.isValidForRuntimeUse == false {
            reasons.append("unsupported")
            reasons.append("runtime-blocked")
        }

        guard let result else {
            reasons.append("no-query-match")
            return orderedUnique(reasons)
        }

        switch result.sourceState {
        case .sourceNeeded:
            reasons.append("source-needed")
        case .stale:
            reasons.append("stale")
        case .contradicted:
            reasons.append("contradicted")
        case .revoked:
            reasons.append("revoked")
        case .unknown:
            reasons.append("source-needed")
        case .official, .officialCurrent, .current, .locallyProven:
            break
        }

        if result.freshnessState == .stale {
            reasons.append("stale")
        }
        if result.riskState == .high {
            reasons.append("high-risk")
        }
        if result.reviewState.blocksCurrentProjection {
            reasons.append("review-required")
        }
        if result.canSupportCurrentUse == false {
            reasons.append("runtime-blocked")
        }

        return orderedUnique(reasons)
    }

    static func matchTrace(
        rawGoalText: String,
        normalizedInput: String,
        rule: IntentRule,
        candidatePackIDs: [String],
        selection: SourceAtlasPackSelection
    ) -> [String] {
        var trace: [String] = [
            "raw=\(rawGoalText.trimmingCharacters(in: .whitespacesAndNewlines))",
            "normalized=\(rule.normalizedGoalIntent)",
            "input=\(normalizedInput)",
            "signals=\(rule.traceSignals.joined(separator: ","))"
        ]

        if rule.missingClarifications.isEmpty == false {
            trace.append("clarify=\(rule.missingClarifications.joined(separator: " | "))")
        }

        if candidatePackIDs.isEmpty {
            trace.append("candidate-packs=none")
        } else {
            trace.append("candidate-packs=\(candidatePackIDs.joined(separator: ","))")
        }

        if selection.selectedPackIDs.isEmpty == false {
            trace.append("selected=\(selection.selectedPackIDs.joined(separator: ","))")
        }

        for packID in selection.rejectedPackIDs {
            let reasons = selection.rejectionReasons[packID]?.joined(separator: ",") ?? "unknown"
            trace.append("reject \(packID): \(reasons)")
        }

        trace.append(selection.canDriveRuntime ? "runtime=enabled" : "runtime=blocked")
        if selection.requiredUserReview {
            trace.append("review=user-required")
        }

        return trace
    }

    static func orderedUnique(_ values: [String]) -> [String] {
        var seen: Set<String> = []
        return values.filter { seen.insert($0).inserted }
    }
}
