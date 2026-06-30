import Foundation

let findActInspectContractSchemaVersion = "search_recall_find_act_inspect.native.v1"

struct SearchRecallQuery: Codable, Sendable, Equatable, Hashable {
    let rawText: String
    let origin: AmbitionsSurface?
    let allowedPrivacy: Set<EventLedgerPrivacyClassification>
    let allowedFamilies: Set<LocalSearchObjectFamily>?
    let limit: Int
    let requiresLocalOnly: Bool

    init(
        rawText: String,
        origin: AmbitionsSurface? = nil,
        allowedPrivacy: Set<EventLedgerPrivacyClassification> = SearchStoreFTSQuery.allPrivacyClasses,
        allowedFamilies: Set<LocalSearchObjectFamily>? = nil,
        limit: Int = 32,
        requiresLocalOnly: Bool = true
    ) {
        self.rawText = rawText.trimmingCharacters(in: .whitespacesAndNewlines)
        self.origin = origin
        self.allowedPrivacy = allowedPrivacy
        self.allowedFamilies = allowedFamilies
        self.limit = max(0, limit)
        self.requiresLocalOnly = requiresLocalOnly
    }

    var normalizedText: String {
        LocalSearchIndex.normalized([rawText])
    }

    var isEmpty: Bool {
        normalizedText.isEmpty
    }
}

struct SearchRecallProvenance: Codable, Sendable, Equatable, Hashable {
    let eventID: String
    let objectIDs: [String]
    let sourceSummary: String
    let sourceOwner: String
    let schemaVersion: String

    init(
        eventID: String,
        objectIDs: [String],
        sourceSummary: String,
        sourceOwner: String = "Core/LocalRuntimeOS/SearchRecall",
        schemaVersion: String = findActInspectContractSchemaVersion
    ) {
        self.eventID = eventID
        self.objectIDs = Self.orderedUnique(objectIDs)
        self.sourceSummary = sourceSummary.trimmingCharacters(in: .whitespacesAndNewlines)
        self.sourceOwner = sourceOwner
        self.schemaVersion = schemaVersion
    }

    private static func orderedUnique(_ values: [String]) -> [String] {
        Array(Set(values.filter { $0.isEmpty == false })).sorted()
    }
}

struct SearchRecallExplanation: Codable, Sendable, Equatable, Hashable {
    let matchedTerms: [String]
    let rankingSignals: [String]
    let privacySummary: String
    let actionSummary: String
    let localOnly: Bool

    init(
        matchedTerms: [String],
        rankingSignals: [String],
        privacySummary: String,
        actionSummary: String,
        localOnly: Bool
    ) {
        self.matchedTerms = Self.orderedUnique(matchedTerms)
        self.rankingSignals = Self.orderedUnique(rankingSignals)
        self.privacySummary = privacySummary.trimmingCharacters(in: .whitespacesAndNewlines)
        self.actionSummary = actionSummary.trimmingCharacters(in: .whitespacesAndNewlines)
        self.localOnly = localOnly
    }

    func addingRankingSignals(_ signals: [String]) -> SearchRecallExplanation {
        SearchRecallExplanation(
            matchedTerms: matchedTerms,
            rankingSignals: rankingSignals + signals,
            privacySummary: privacySummary,
            actionSummary: actionSummary,
            localOnly: localOnly
        )
    }

    private static func orderedUnique(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }
}

enum SearchRecallActionKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case open
    case inspect
}

struct SearchRecallAction: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let kind: SearchRecallActionKind
    let title: String
    let commandKind: AmbitionsCommandKind
    let target: AmbitionsCommandTarget
    let validationState: AmbitionsCommandValidationState
    let requiresConfirmation: Bool
    let localOnly: Bool

    init(
        id: String,
        kind: SearchRecallActionKind,
        title: String,
        commandKind: AmbitionsCommandKind,
        target: AmbitionsCommandTarget,
        validationState: AmbitionsCommandValidationState,
        requiresConfirmation: Bool = false,
        localOnly: Bool = true
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.kind = kind
        self.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        self.commandKind = commandKind
        self.target = target
        self.validationState = validationState
        self.requiresConfirmation = requiresConfirmation
        self.localOnly = localOnly
    }
}

struct FindActInspectResult: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let family: LocalSearchObjectFamily
    let title: String
    let body: String
    let privacy: EventLedgerPrivacyClassification
    let provenance: SearchRecallProvenance
    let primaryAction: SearchRecallAction
    let inspectAction: SearchRecallAction
    let explanation: SearchRecallExplanation
    let updatedAt: String
    let baseScore: Int
    let rankScore: Int
    let localOnly: Bool
    let schemaVersion: String

    init(
        id: String,
        family: LocalSearchObjectFamily,
        title: String,
        body: String,
        privacy: EventLedgerPrivacyClassification,
        provenance: SearchRecallProvenance,
        primaryAction: SearchRecallAction,
        inspectAction: SearchRecallAction,
        explanation: SearchRecallExplanation,
        updatedAt: String,
        baseScore: Int,
        rankScore: Int? = nil,
        localOnly: Bool = true,
        schemaVersion: String = findActInspectContractSchemaVersion
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.family = family
        self.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        self.body = body.trimmingCharacters(in: .whitespacesAndNewlines)
        self.privacy = privacy
        self.provenance = provenance
        self.primaryAction = primaryAction
        self.inspectAction = inspectAction
        self.explanation = explanation
        self.updatedAt = updatedAt.trimmingCharacters(in: .whitespacesAndNewlines)
        self.baseScore = max(0, baseScore)
        self.rankScore = max(0, rankScore ?? baseScore)
        self.localOnly = localOnly
        self.schemaVersion = schemaVersion
    }

    init(record: SearchStoreFTSRecord) {
        let family = LocalSearchObjectFamily.inferred(
            objectFamily: record.objectFamily,
            objectIDs: record.objectIDs
        )
        let target = AmbitionsCommandTarget.destination(for: family, objectIDs: record.objectIDs)
        let actionState = record.actionValidation
        let provenance = SearchRecallProvenance(
            eventID: record.eventID,
            objectIDs: record.objectIDs,
            sourceSummary: record.provenance
        )
        let primaryAction = SearchRecallAction(
            id: "\(record.id).open",
            kind: .open,
            title: "Open \(family.title.lowercased())",
            commandKind: .openDestination,
            target: target,
            validationState: actionState,
            requiresConfirmation: false,
            localOnly: true
        )
        let inspectAction = SearchRecallAction(
            id: "\(record.id).inspect",
            kind: .inspect,
            title: "Inspect source",
            commandKind: .askWhy,
            target: AmbitionsCommandTarget(explanationID: record.eventID, destination: .memoryLens),
            validationState: actionState == .valid ? .valid : actionState,
            requiresConfirmation: false,
            localOnly: true
        )
        self.init(
            id: record.id,
            family: family,
            title: record.title,
            body: record.body,
            privacy: record.privacy,
            provenance: provenance,
            primaryAction: primaryAction,
            inspectAction: inspectAction,
            explanation: SearchRecallExplanation(
                matchedTerms: [],
                rankingSignals: ["fts-store-score-\(record.score)"],
                privacySummary: "Privacy class \(record.privacy.rawValue) stayed inside local search recall.",
                actionSummary: "Open and inspect actions require valid local targets.",
                localOnly: true
            ),
            updatedAt: record.updatedAt,
            baseScore: record.score,
            localOnly: true
        )
    }

    func ranked(score: Int, signals: [String], matchedTerms: [String]) -> FindActInspectResult {
        FindActInspectResult(
            id: id,
            family: family,
            title: title,
            body: body,
            privacy: privacy,
            provenance: provenance,
            primaryAction: primaryAction,
            inspectAction: inspectAction,
            explanation: SearchRecallExplanation(
                matchedTerms: explanation.matchedTerms + matchedTerms,
                rankingSignals: explanation.rankingSignals + signals,
                privacySummary: explanation.privacySummary,
                actionSummary: explanation.actionSummary,
                localOnly: explanation.localOnly
            ),
            updatedAt: updatedAt,
            baseScore: baseScore,
            rankScore: score,
            localOnly: localOnly,
            schemaVersion: schemaVersion
        )
    }
}

private extension AmbitionsCommandTarget {
    static func destination(for family: LocalSearchObjectFamily, objectIDs: [String]) -> AmbitionsCommandTarget {
        let firstObjectID = objectIDs.first
        switch family {
        case .step:
            return AmbitionsCommandTarget(stepID: firstObjectID, destination: .today)
        case .goal:
            return AmbitionsCommandTarget(goalID: firstObjectID, destination: .goals)
        case .capture, .thought:
            return AmbitionsCommandTarget(captureID: firstObjectID, destination: .captureInbox)
        case .proof, .receipt:
            return AmbitionsCommandTarget(explanationID: firstObjectID, destination: .you)
        case .timeWindow:
            return AmbitionsCommandTarget(timeID: firstObjectID, destination: .time)
        case .setting:
            return AmbitionsCommandTarget(destination: .you)
        }
    }
}
