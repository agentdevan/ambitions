import Foundation

enum PrivateLifeRuntimeSignalKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case missingContext
    case reviewNeeded
    case earlyTimeline
    case compressedTimeline
    case explicitEligibilityPathway
    case makerSpaceAccess
    case homePracticeAccess
    case localAccess
    case equipmentContext
    case recoveryContext
    case excludedContext
    case staleSourceContext
    case staleHistoryContext
    case sensitiveReviewContext
}

struct PrivateLifeRuntimeSignal: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let kind: PrivateLifeRuntimeSignalKind
    let label: String
    let sourceIDs: [String]
    let strength: Int

    init(
        id: String,
        kind: PrivateLifeRuntimeSignalKind,
        label: String,
        sourceIDs: [String] = [],
        strength: Int = 1
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.kind = kind
        self.label = label.trimmingCharacters(in: .whitespacesAndNewlines)
        self.sourceIDs = Array(Set(sourceIDs.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
        self.strength = strength
    }
}

struct PrivateLifeRuntimeSignalSet: Codable, Sendable, Equatable, Hashable {
    let signals: [PrivateLifeRuntimeSignal]

    init(_ signals: [PrivateLifeRuntimeSignal]) {
        self.signals = signals.sorted { lhs, rhs in
            if lhs.kind.rawValue != rhs.kind.rawValue {
                return lhs.kind.rawValue < rhs.kind.rawValue
            }
            return lhs.id < rhs.id
        }
    }

    func contains(_ kind: PrivateLifeRuntimeSignalKind) -> Bool {
        signals.contains { $0.kind == kind }
    }

    func firstLabel(for kind: PrivateLifeRuntimeSignalKind) -> String? {
        signals.first { $0.kind == kind }?.label
    }

    func ids(for kind: PrivateLifeRuntimeSignalKind) -> [String] {
        signals.filter { $0.kind == kind }.map(\.id).sorted()
    }

    var supportingSignalIDs: [String] {
        signals.map(\.id).sorted()
    }
}

struct AdaptationKernel: Sendable, Equatable {
    func signals(
        for projection: LifeContextRuntimeProjection?,
        readiness: PrivateLifeRuntimeLifeContextReadiness
    ) -> PrivateLifeRuntimeSignalSet {
        guard let projection else {
            return PrivateLifeRuntimeSignalSet([
                PrivateLifeRuntimeSignal(
                    id: "life_context.missing_projection",
                    kind: .missingContext,
                    label: "Life context is missing.",
                    strength: 3
                )
            ])
        }

        var signals: [PrivateLifeRuntimeSignal] = []

        if readiness == .clarification || projection.missingContextQuestions.isEmpty == false {
            signals.append(
                PrivateLifeRuntimeSignal(
                    id: "life_context.missing_questions",
                    kind: .missingContext,
                    label: "Life context questions are unresolved.",
                    sourceIDs: projection.missingContextQuestions.map(\.id),
                    strength: 3
                )
            )
        }

        if readiness == .review {
            signals.append(
                PrivateLifeRuntimeSignal(
                    id: "life_context.review_required",
                    kind: .reviewNeeded,
                    label: "Active context needs review before faster recommendation.",
                    strength: 2
                )
            )
        }

        if projection.lifeStage == .highSchool {
            if (projection.ageYears ?? 0) < 16 {
                signals.append(
                    PrivateLifeRuntimeSignal(
                        id: "life_stage.high_school.early",
                        kind: .earlyTimeline,
                        label: "the timeline is still early",
                        strength: 2
                    )
                )
            } else {
                signals.append(
                    PrivateLifeRuntimeSignal(
                        id: "life_stage.high_school.compressed",
                        kind: .compressedTimeline,
                        label: "the timeline is compressed",
                        strength: 2
                    )
                )
            }
        }

        for pathway in projection.eligibilityModel {
            if let label = normalized(pathway.sexLeaguePathway) {
                signals.append(
                    PrivateLifeRuntimeSignal(
                        id: "eligibility.explicit_pathway.\(pathway.id)",
                        kind: .explicitEligibilityPathway,
                        label: label,
                        sourceIDs: [pathway.id, pathway.source.id],
                        strength: pathway.userConfirmed ? 3 : 2
                    )
                )
            }
        }

        for anchor in projection.availableOpportunityAnchors {
            let semanticText = searchableText(anchor.id, anchor.title, anchor.detail)
            if semanticText.contains("maker") {
                signals.append(
                    PrivateLifeRuntimeSignal(
                        id: "opportunity.maker_space.\(anchor.id)",
                        kind: .makerSpaceAccess,
                        label: "maker-space access",
                        sourceIDs: [anchor.id],
                        strength: anchor.verificationStatus == .verified ? 3 : 2
                    )
                )
            }
            if semanticText.contains("home") {
                signals.append(
                    PrivateLifeRuntimeSignal(
                        id: "opportunity.home_practice.\(anchor.id)",
                        kind: .homePracticeAccess,
                        label: "home practice access",
                        sourceIDs: [anchor.id],
                        strength: 2
                    )
                )
            }
        }

        if projection.travelModel.radiusMinutes.map({ $0 <= 20 }) == true {
            signals.append(
                PrivateLifeRuntimeSignal(
                    id: "travel.local_radius.\(projection.travelModel.radiusMinutes ?? 0)",
                    kind: .localAccess,
                    label: "local access",
                    strength: 2
                )
            )
        }

        for history in projection.historySummary {
            let semanticText = searchableText(history.id, history.title, history.detail)
            if history.usedFor.contains(.recovery) || history.usedFor.contains(.safety) {
                signals.append(
                    PrivateLifeRuntimeSignal(
                        id: "history.recovery.\(history.id)",
                        kind: .recoveryContext,
                        label: "older injury or blocked-attempt context",
                        sourceIDs: [history.id],
                        strength: 3
                    )
                )
            }
            if history.usedFor.contains(.opportunity) || history.usedFor.contains(.sequencing) || history.usedFor.contains(.feasibility) {
                if semanticText.contains("tool") || semanticText.contains("equipment") || semanticText.contains("kit") {
                    signals.append(
                        PrivateLifeRuntimeSignal(
                            id: "history.equipment.\(history.id)",
                            kind: .equipmentContext,
                            label: "equipment and local practice",
                            sourceIDs: [history.id],
                            strength: 2
                        )
                    )
                }
            }
            if history.freshness != .current {
                signals.append(
                    PrivateLifeRuntimeSignal(
                        id: "history.freshness.\(history.id)",
                        kind: .staleHistoryContext,
                        label: "history needs review",
                        sourceIDs: [history.id],
                        strength: history.freshness == .stale ? 3 : 2
                    )
                )
            }
        }

        if projection.excludedHistorySummary.isEmpty == false {
            signals.append(
                PrivateLifeRuntimeSignal(
                    id: "history.excluded",
                    kind: .excludedContext,
                    label: "paused or deleted context stays out of the runtime path",
                    sourceIDs: projection.excludedHistorySummary.map(\.factID),
                    strength: 3
                )
            )
        }

        if projection.sourceFreshnessSummary.contains(where: { $0.freshness != .current }) {
            signals.append(
                PrivateLifeRuntimeSignal(
                    id: "source.freshness.review",
                    kind: .staleSourceContext,
                    label: "source freshness needs review",
                    sourceIDs: projection.sourceFreshnessSummary.filter { $0.freshness != .current }.map(\.sourceID),
                    strength: 2
                )
            )
        }

        if projection.sensitiveUseWarnings.isEmpty == false {
            signals.append(
                PrivateLifeRuntimeSignal(
                    id: "privacy.sensitive_review",
                    kind: .sensitiveReviewContext,
                    label: "sensitive context needs review",
                    sourceIDs: projection.sensitiveUseWarnings.map(\.factID),
                    strength: 3
                )
            )
        }

        return PrivateLifeRuntimeSignalSet(signals)
    }

    private func normalized(_ value: String?) -> String? {
        let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed?.isEmpty == true ? nil : trimmed
    }

    private func searchableText(_ values: String...) -> String {
        values
            .map { $0.lowercased() }
            .joined(separator: " ")
            .replacingOccurrences(of: "_", with: " ")
            .replacingOccurrences(of: "-", with: " ")
    }
}
