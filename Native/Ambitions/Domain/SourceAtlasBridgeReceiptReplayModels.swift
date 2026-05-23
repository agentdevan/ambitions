import Foundation

let sourceAtlasBridgeReplaySchemaVersion = "source_atlas_bridge_replay.native.v1"

enum SourceAtlasBridgeReceiptKind: String, Codable, Sendable, Equatable, Hashable {
    case sourceAtlasIntentMatched
    case sourceAtlasPackSelected
    case sourceAtlasPackRejected
    case sourceAtlasPathComposed
    case sourceAtlasPathRejected
    case sourceAtlasStepCandidatesExpanded
    case sourceAtlasUnsupportedGoalFallback
    case sourceAtlasFreshnessBlocked
    case sourceAtlasUserCorrectionApplied
    case sourceAtlasReplayGenerated
}

struct SourceAtlasBridgeIntentMatchSummary: Codable, Sendable, Equatable, Hashable {
    let rawGoalText: String
    let rawGoalTextWasRedacted: Bool
    let normalizedGoalIntent: String
    let matchedDomainIDs: [String]
    let matchedSpecificDomainIDs: [String]
    let matchedSkillSliceIDs: [String]
    let matchedRoleIDs: [String]
    let confidenceBand: SourceAtlasIntentMatchConfidenceBand
    let missingClarifications: [String]
    let selectedPackIDs: [String]
    let rejectedPackIDs: [String]
    let matchTrace: [String]

    init(match: SourceAtlasIntentMatch, selection: SourceAtlasPackSelection) {
        let trimmedRawGoalText = match.rawGoalText.trimmingCharacters(in: .whitespacesAndNewlines)
        let redactedRawGoalText = sourceAtlasBridgeRedactedText(trimmedRawGoalText)
        rawGoalText = redactedRawGoalText ?? trimmedRawGoalText
        rawGoalTextWasRedacted = redactedRawGoalText != nil
        normalizedGoalIntent = match.normalizedGoalIntent
        matchedDomainIDs = match.matchedDomainIDs
        matchedSpecificDomainIDs = match.matchedSpecificDomainIDs
        matchedSkillSliceIDs = match.matchedSkillSliceIDs
        matchedRoleIDs = match.matchedRoleIDs
        confidenceBand = match.confidenceBand
        missingClarifications = match.missingClarifications
        selectedPackIDs = selection.selectedPackIDs
        rejectedPackIDs = selection.rejectedPackIDs
        matchTrace = Self.redactedMatchTrace(
            match.matchTrace,
            rawGoalText: trimmedRawGoalText,
            redactedRawGoalText: rawGoalText
        )
    }

    private static func redactedMatchTrace(
        _ trace: [String],
        rawGoalText: String,
        redactedRawGoalText: String
    ) -> [String] {
        trace.map { entry in
            let trimmed = entry.trimmingCharacters(in: .whitespacesAndNewlines)
            guard trimmed.isEmpty == false else {
                return trimmed
            }
            return trimmed.replacingOccurrences(of: "raw=\(rawGoalText)", with: "raw=\(redactedRawGoalText)")
        }
    }
}

struct SourceAtlasBridgeReceipt: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let kind: SourceAtlasBridgeReceiptKind
    let recordedAt: String
    let summary: String
    let details: [String]
    let relatedIDs: [String]
    let isRedacted: Bool

    init(
        kind: SourceAtlasBridgeReceiptKind,
        recordedAt: String,
        summary: String,
        details: [String] = [],
        relatedIDs: [String] = [],
        isRedacted: Bool = false
    ) {
        self.kind = kind
        self.recordedAt = recordedAt.trimmingCharacters(in: .whitespacesAndNewlines)
        self.summary = summary.trimmingCharacters(in: .whitespacesAndNewlines)
        self.details = Self.normalized(details)
        self.relatedIDs = Self.normalized(relatedIDs)
        self.isRedacted = isRedacted
        self.id = CandidateSource.stableIdentifier(
            prefix: "source-atlas.bridge-receipt",
            components: [
                self.kind.rawValue,
                self.recordedAt,
                self.summary,
                self.details.joined(separator: "|"),
                self.relatedIDs.joined(separator: "|"),
                self.isRedacted ? "redacted" : "clear"
            ]
        )
    }

    private static func normalized(_ values: [String]) -> [String] {
        Array(
            Set(
                values
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { $0.isEmpty == false }
            )
        ).sorted()
    }
}

struct SourceAtlasBridgeRecommendationSummary: Codable, Sendable, Equatable, Hashable {
    let candidateID: String
    let sourceStepID: String
    let sourceCandidateID: String?
    let kind: String
    let title: String
    let summary: String
    let accessibilitySummary: String
    let impactSimulation: StepImpactSimulation

    init(_ candidate: StepCandidate) {
        candidateID = candidate.id
        sourceStepID = candidate.sourceStepID
        sourceCandidateID = candidate.sourceCandidateID
        kind = candidate.kind.rawValue
        title = sourceAtlasBridgeRedactedText(candidate.title) ?? candidate.title
        summary = sourceAtlasBridgeRedactedText(candidate.summary) ?? candidate.summary
        accessibilitySummary = sourceAtlasBridgeRedactedText(candidate.accessibilitySummary) ?? candidate.accessibilitySummary
        impactSimulation = candidate.impactSimulation
    }
}

struct SourceAtlasBridgeCorrectionInput: Codable, Sendable, Equatable, Hashable {
    let rejectedPathIDs: [String]
    let rejectedCandidateHistory: [StepCandidateRejectionRecord]

    init(
        rejectedPathIDs: [String] = [],
        rejectedCandidateHistory: [StepCandidateRejectionRecord] = []
    ) {
        self.rejectedPathIDs = Self.normalized(rejectedPathIDs)
        self.rejectedCandidateHistory = rejectedCandidateHistory
    }

    private static func normalized(_ values: [String]) -> [String] {
        Array(
            Set(
                values
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { $0.isEmpty == false }
            )
        ).sorted()
    }
}

func sourceAtlasBridgeRedactedText(_ value: String) -> String? {
    let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
    guard trimmed.isEmpty == false else { return nil }
    if trimmed.localizedCaseInsensitiveContains("private") || trimmed.localizedCaseInsensitiveContains("secret") {
        return "[redacted]"
    }
    return nil
}
