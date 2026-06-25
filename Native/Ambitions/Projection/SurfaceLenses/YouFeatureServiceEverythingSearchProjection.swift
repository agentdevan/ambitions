import AmbitionsDesignSystem
import Foundation

extension RepositoryBackedYouService {
    func makeEverythingSearchState(snapshot: Snapshot) -> YouEverythingSearchState {
        let documents = makeEverythingSearchDocuments(snapshot: snapshot)
        let filters = makeEverythingSearchFilters(documents: documents)
        let ordered = documents.sorted { lhs, rhs in
            if lhs.updatedAt != rhs.updatedAt {
                return lhs.updatedAt > rhs.updatedAt
            }
            if lhs.kind.rawValue != rhs.kind.rawValue {
                return lhs.kind.rawValue < rhs.kind.rawValue
            }
            if lhs.title != rhs.title {
                return lhs.title < rhs.title
            }
            return lhs.id < rhs.id
        }

        let maximumResults = 12
        let candidateCount = documents.count
        let matchedCount = ordered.count
        let returnedCount = min(ordered.count, maximumResults)
        let scannedCount = min(candidateCount, 64)
        let hitPerformanceBudget = candidateCount > maximumResults

        return YouEverythingSearchState(
            title: "Everything Search",
            subtitle: "Find anything local across goals, captures, proof, feedback, teaching, event history, and life context.",
            queryPrompt: "Find anything local",
            filters: filters,
            scannedCandidateCount: scannedCount,
            matchedCandidateCount: matchedCount,
            returnedItemCount: returnedCount,
            hitPerformanceBudget: hitPerformanceBudget,
            performanceBudgetSummary: "Scanned \(scannedCount) local candidates; matched \(matchedCount); returned \(returnedCount) within a 64-candidate / \(maximumResults)-result budget.",
            items: ordered.map { document in
                YouEverythingSearchItem(
                    id: document.id,
                    kind: document.kind,
                    title: document.title,
                    summary: document.summary,
                    sourceLabel: document.sourceLabel,
                    freshness: document.freshness,
                    primaryActions: document.actions,
                    matchedTerms: document.searchableText
                        .split(separator: " ")
                        .prefix(8)
                        .map(String.init),
                    accessibilityLabel: "\(document.kind.title) search result",
                    accessibilityValue: "\(document.sourceLabel). \(document.freshness.label).",
                    accessibilityHint: "Search stays local and inspectable."
                )
            },
            footer: "Search stays local, inspectable, and source-tied. No external service is used."
        )
    }

    func makeEverythingSearchDocuments(snapshot: Snapshot) -> [EverythingSearchDocument] {
        var documents: [EverythingSearchDocument] = []

        documents.append(contentsOf: snapshot.goals.map { goal in
            EverythingSearchDocument(
                id: "goal-\(goal.id)",
                kind: .goal,
                title: goal.title,
                summary: goal.summary ?? goal.mode.displayTitle,
                sourceLabel: "Goals",
                freshness: goal.searchFreshness,
                actions: searchActions(
                    baseID: goal.id,
                    titles: ["Open goal", "Open step", "Review history"],
                    statusLabel: goal.state.rawValue.capitalized,
                    detail: "Open the canonical Goal Detail surface.",
                    state: goal.state == .active ? .success : .default
                ),
                createdAt: goal.createdAt,
                updatedAt: goal.updatedAt,
                searchableText: normalizedSearchText([
                    goal.title,
                    goal.summary ?? "",
                    goal.mode.displayTitle,
                    goal.state.rawValue,
                    goal.tags.joined(separator: " ")
                ])
            )
        })

        documents.append(contentsOf: snapshot.captures.map { capture in
            EverythingSearchDocument(
                id: "capture-\(capture.id)",
                kind: .capture,
                title: capture.rawText,
                summary: capture.assumptionSummary ?? capture.route.title,
                sourceLabel: capture.searchSourceLabel,
                freshness: capture.searchFreshness,
                actions: searchActions(
                    baseID: capture.id,
                    titles: capture.searchPrimaryActionTitles,
                    statusLabel: capture.status.title,
                    detail: capture.searchObjectTypeLabel,
                    state: capture.status == .archived ? .default : .success
                ),
                createdAt: capture.createdAt,
                updatedAt: capture.updatedAt,
                searchableText: normalizedSearchText([
                    capture.rawText,
                    capture.assumptionSummary ?? "",
                    capture.searchObjectTypeLabel,
                    capture.searchSourceLabel,
                    capture.status.title,
                    capture.route.title,
                    capture.kind.title,
                    capture.linkedGoalID ?? "",
                    capture.recommendationExplanationIDs.joined(separator: " ")
                ])
            )
        })

        documents.append(contentsOf: snapshot.evidence.map { evidence in
            EverythingSearchDocument(
                id: "evidence-\(evidence.id)",
                kind: .proof,
                title: evidence.note ?? "Progress evidence",
                summary: evidence.evidenceKind.rawValue.replacingOccurrences(of: "_", with: " ").capitalized,
                sourceLabel: "Proof",
                freshness: .current,
                actions: searchActions(
                    baseID: evidence.id,
                    titles: ["Review history", "Open goal", "Open detail"],
                    statusLabel: evidence.source.rawValue.replacingOccurrences(of: "_", with: " ").capitalized,
                    detail: "Proof remains local and inspectable.",
                    state: .success
                ),
                createdAt: evidence.capturedAt,
                updatedAt: evidence.capturedAt,
                searchableText: normalizedSearchText([
                    evidence.note ?? "",
                    evidence.evidenceKind.rawValue,
                    evidence.source.rawValue,
                    evidence.goalID,
                    evidence.stepID ?? ""
                ])
            )
        })

        documents.append(contentsOf: snapshot.feedback.map { event in
            EverythingSearchDocument(
                id: "feedback-\(event.base.id)",
                kind: .feedback,
                title: event.searchTitle,
                summary: event.searchSummary,
                sourceLabel: "Feedback",
                freshness: event.searchFreshness,
                actions: searchActions(
                    baseID: event.base.id,
                    titles: ["Open review", "Correct assumption", "Open history"],
                    statusLabel: event.kind.rawValue.replacingOccurrences(of: "_", with: " ").capitalized,
                    detail: "Feedback stays tied to the owning goal surface.",
                    state: .success
                ),
                createdAt: event.base.occurredAt,
                updatedAt: event.base.occurredAt,
                searchableText: normalizedSearchText([
                    event.searchTitle,
                    event.searchSummary,
                    event.kind.rawValue,
                    event.base.note ?? "",
                    event.stepID,
                    event.base.id
                ])
            )
        })

        documents.append(contentsOf: snapshot.teachingSignals.map { signal in
            EverythingSearchDocument(
                id: "teaching-\(signal.id)",
                kind: .teaching,
                title: signal.userNote ?? signal.kind.rawValue.replacingOccurrences(of: "_", with: " ").capitalized,
                summary: signal.source.rawValue.replacingOccurrences(of: "_", with: " ").capitalized,
                sourceLabel: "Teaching",
                freshness: signal.disposition == .active ? .mayNeedReview : .basedOnOlderContext,
                actions: searchActions(
                    baseID: signal.id,
                    titles: ["Inspect correction", "Use owning surface", "Reject reuse"],
                    statusLabel: signal.disposition.rawValue.replacingOccurrences(of: "_", with: " ").capitalized,
                    detail: "Teaching stays source-tied and reviewable.",
                    state: signal.disposition == .active ? .warning : .default
                ),
                createdAt: signal.createdAt,
                updatedAt: signal.updatedAt,
                searchableText: normalizedSearchText([
                    signal.userNote ?? "",
                    signal.kind.rawValue,
                    signal.source.rawValue,
                    signal.goalID,
                    signal.applicationKey,
                    signal.anchor.normalizedIdentity
                ])
            )
        })

        documents.append(contentsOf: snapshot.eventLedger.map { event in
            EverythingSearchDocument(
                id: "event-\(event.id)",
                kind: .eventLedger,
                title: event.title,
                summary: event.summary ?? event.kind.rawValue.replacingOccurrences(of: "_", with: " "),
                sourceLabel: "Event Ledger",
                freshness: event.localOnly ? .current : .mayNeedReview,
                actions: searchActions(
                    baseID: event.id,
                    titles: ["Open event", "Open context", "Open history"],
                    statusLabel: event.source.rawValue.replacingOccurrences(of: "_", with: " ").capitalized,
                    detail: "Recent local actions and changes stay inspectable.",
                    state: event.localOnly ? .success : .warning
                ),
                createdAt: event.occurredAt,
                updatedAt: event.updatedAt,
                searchableText: normalizedSearchText([
                    event.title,
                    event.summary ?? "",
                    event.kind.rawValue,
                    event.source.rawValue,
                    event.goalID ?? "",
                    event.captureID ?? "",
                    event.planID ?? "",
                    event.reviewID ?? ""
                ])
            )
        })

        documents.append(contentsOf: snapshot.lifeContextBundles.filter { $0.isDeleted == false }.map { bundle in
            EverythingSearchDocument(
                id: "life-context-\(bundle.id)",
                kind: .lifeContext,
                title: lifeContextDisplayTitle(for: bundle.profile),
                summary: lifeContextDisplaySummary(for: bundle.profile),
                sourceLabel: "Life Context",
                freshness: bundle.historicalFacts.contains(where: { $0.isDeletedOrPaused }) ? .mayNeedReview : .current,
                actions: searchActions(
                    baseID: bundle.id,
                    titles: ["Open fact", "Edit", "Pause use"],
                    statusLabel: bundle.historicalFacts.count == 0 ? "Empty" : "\(bundle.historicalFacts.count) facts",
                    detail: "Life context stays local and editable through You.",
                    state: bundle.historicalFacts.isEmpty ? .default : .success
                ),
                createdAt: bundle.createdAt,
                updatedAt: bundle.updatedAt,
                searchableText: normalizedSearchText([
                    lifeContextDisplayTitle(for: bundle.profile),
                    lifeContextDisplaySummary(for: bundle.profile),
                    bundle.historicalFacts.map(\.title).joined(separator: " "),
                    bundle.historicalFacts.compactMap(\.detail).joined(separator: " "),
                    bundle.sources.map(\.label).joined(separator: " "),
                    bundle.eligibilityPathways.map(\.eligibilityRulesSummary).joined(separator: " ")
                ])
            )
        })

        return documents
    }

    func makeEverythingSearchFilters(documents: [EverythingSearchDocument]) -> [SettingsItem] {
        let countsByKind = Dictionary(grouping: documents, by: \.kind).mapValues(\.count)

        return [
            SettingsItem(
                id: "search-filter-goals",
                title: "Goals",
                subtitle: "Goal threads and canonical steps",
                icon: "target",
                valueLabel: "\(countsByKind[.goal, default: 0])"
            ),
            SettingsItem(
                id: "search-filter-captures",
                title: "Captures",
                subtitle: "Open captures and route previews",
                icon: "tray.full",
                valueLabel: "\(countsByKind[.capture, default: 0])"
            ),
            SettingsItem(
                id: "search-filter-proof",
                title: "Proof",
                subtitle: "Evidence and receipts",
                icon: "checkmark.seal",
                valueLabel: "\(countsByKind[.proof, default: 0])"
            ),
            SettingsItem(
                id: "search-filter-feedback",
                title: "Feedback",
                subtitle: "Corrections and review signals",
                icon: "bubble.left.and.bubble.right",
                valueLabel: "\(countsByKind[.feedback, default: 0])"
            ),
            SettingsItem(
                id: "search-filter-teaching",
                title: "Teaching",
                subtitle: "Local learning signals",
                icon: "slider.horizontal.3",
                valueLabel: "\(countsByKind[.teaching, default: 0])"
            ),
            SettingsItem(
                id: "search-filter-event-ledger",
                title: "Event Ledger",
                subtitle: "Recent local actions",
                icon: "list.bullet.rectangle",
                valueLabel: "\(countsByKind[.eventLedger, default: 0])"
            ),
            SettingsItem(
                id: "search-filter-life-context",
                title: "Life Context",
                subtitle: "Facts and eligibility context",
                icon: "map",
                valueLabel: "\(countsByKind[.lifeContext, default: 0])"
            )
        ]
    }

    func searchActions(
        baseID: String,
        titles: [String],
        statusLabel: String,
        detail: String,
        state: AmbitionVisualState
    ) -> [YouEverythingSearchAction] {
        titles.enumerated().map { index, title in
            YouEverythingSearchAction(
                id: "\(baseID).\(index)",
                title: title,
                statusLabel: statusLabel,
                detail: detail,
                state: state
            )
        }
    }

    func normalizedSearchText(_ values: [String]) -> String {
        values
            .joined(separator: " ")
            .lowercased()
            .replacingOccurrences(of: #"[^a-z0-9]+"#, with: " ", options: .regularExpression)
    }

}
