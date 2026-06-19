import AmbitionsDesignSystem
import Foundation

extension RepositoryBackedYouService {
    func makeLifeContextState(snapshot: Snapshot) -> YouLifeContextState {
        let bundle = latestLifeContextBundle(from: snapshot.lifeContextBundles)
        let projection = bundle?.projection(asOf: .now)
        let ledger = PersonalizationFactorLedgerBuilder().build(
            PersonalizationFactorLedgerInput(
                goalID: bundle?.id,
                goalText: bundle?.profile.userNotes ?? bundle?.profile.schoolOrWorkContext,
                projection: projection
            )
        )
        let basePath = "You > What Ambitions Knows > Life Context"
        let futureProofContextCandidates = makeFutureProofContextCandidates(snapshot: snapshot, bundle: bundle)
        let summaryItems = makeLifeContextSummaryItems(
            bundle: bundle,
            projection: projection,
            ledger: ledger,
            futureProofContextCandidates: futureProofContextCandidates
        )
        let sections = makeLifeContextSections(bundle: bundle, projection: projection, ledger: ledger, basePath: basePath)
        let futureProofSection = makeFutureProofContextSection(candidates: futureProofContextCandidates, basePath: basePath)
        let allSections = sections + (futureProofSection.map { [$0] } ?? [])

        return YouLifeContextState(
            title: "Life Context",
            subtitle: "Help Ambitions plan from your real life.",
            intro: "Age, schedule, travel, access, history, and constraints help Ambitions make plans that actually fit.",
            summaryItems: summaryItems,
            sections: allSections,
            footer: "Catch Me Up stays under What Ambitions Knows, stays local-first, and keeps edit, pause, delete, review, and confirm paths visible where facts are shown."
        )
    }

    func latestLifeContextBundle(from bundles: [LifeContextBundle]) -> LifeContextBundle? {
        bundles.sorted {
            if $0.updatedAt != $1.updatedAt {
                return $0.updatedAt > $1.updatedAt
            }
            return $0.id > $1.id
        }.first
    }

    func makeLifeContextSummaryItems(
        bundle: LifeContextBundle?,
        projection: LifeContextRuntimeProjection?,
        ledger: PersonalizationFactorLedger,
        futureProofContextCandidates: [FutureProofContextCandidate]
    ) -> [SettingsItem] {
        let ageValue: String
        if let ageYears = projection?.ageYears ?? bundle?.profile.exactAgeYears {
            ageValue = "\(ageYears)"
        } else if let birthdate = bundle?.profile.birthdate {
            ageValue = birthdate
        } else {
            ageValue = "Not captured"
        }

        let locationValue = bundle.map { profileLocationSummary(for: $0.profile) } ?? "Not captured"
        let scheduleValue = bundle?.profile.scheduleAnchors.isEmpty == false ? "\(bundle?.profile.scheduleAnchors.count ?? 0) anchors" : "Not captured"
        let opportunityCount = bundle?.opportunityContexts.count ?? 0
        let pathwayCount = projection?.eligibilityModel.count ?? bundle?.eligibilityPathways.count ?? 0
        let historyCount = projection?.historySummary.count ?? bundle?.historicalFacts.filter { $0.isDeletedOrPaused == false }.count ?? 0
        let constraintCount = (projection?.hardConstraints.count ?? 0) + (projection?.softConstraints.count ?? 0)
        let sourceReviewCount = projection?.sourceFreshnessSummary.filter { $0.freshness != .current }.count ?? 0
        let excludedReviewCount = projection?.excludedHistorySummary.count ?? 0
        let sensitiveReviewCount = projection?.sensitiveUseWarnings.count ?? 0
        let questionReviewCount = projection?.missingContextQuestions.count ?? 0
        let ledgerReviewCount = ledger.factors.filter { $0.allowedForRuntimeUse == false || $0.freshness.needsReview }.count
        let futureProofReviewCount = futureProofContextCandidates.filter { $0.reviewNeeded || $0.runtimeUseAllowed == false }.count
        let reviewCount = sourceReviewCount + excludedReviewCount + sensitiveReviewCount + questionReviewCount + ledgerReviewCount + futureProofReviewCount

        var items = [
            SettingsItem(
                id: "life-context-basics",
                title: "Basics",
                subtitle: "Age, stage, timezone, location, and school/work context.",
                icon: "calendar",
                valueLabel: ageValue
            ),
            SettingsItem(
                id: "life-context-schedule-availability",
                title: "Schedule & Availability",
                subtitle: "Anchors, protected time, and recovery defaults.",
                icon: "calendar.badge.clock",
                valueLabel: scheduleValue
            ),
            SettingsItem(
                id: "life-context-travel-access",
                title: "Travel & Access",
                subtitle: "Radius, transport, and access assumptions.",
                icon: "car",
                valueLabel: locationValue
            ),
            SettingsItem(
                id: "life-context-facilities-equipment",
                title: "Facilities & Equipment",
                subtitle: "Places, gear, and access limits.",
                icon: "building.2",
                valueLabel: "\(opportunityCount)"
            ),
            SettingsItem(
                id: "life-context-eligibility-pathways",
                title: "Eligibility & Pathways",
                subtitle: "Sport, school, career, and creative rules.",
                icon: "checkmark.seal",
                valueLabel: "\(pathwayCount)"
            ),
            SettingsItem(
                id: "life-context-history",
                title: "History",
                subtitle: "Prior attempts, past achievements, and old progress.",
                icon: "clock.arrow.circlepath",
                valueLabel: "\(historyCount)"
            ),
            SettingsItem(
                id: "life-context-constraints",
                title: "Constraints",
                subtitle: "Budget, energy, care, accessibility, and recovery.",
                icon: "slider.horizontal.3",
                valueLabel: "\(constraintCount)"
            ),
            SettingsItem(
                id: "life-context-runtime-factors",
                title: "Runtime Factors",
                subtitle: "What actually shapes recommendations right now.",
                icon: "waveform.path.ecg",
                valueLabel: "\(ledger.factors.count)"
            ),
            SettingsItem(
                id: "life-context-review-needed",
                title: "Needs Review",
                subtitle: "Stale, imported, inferred, and sensitive context.",
                icon: "exclamationmark.triangle",
                valueLabel: reviewCount == 0 ? "Clear" : "\(reviewCount)"
            )
        ]
        if let futureProofContextSummaryItem = futureProofContextSummaryItem(candidates: futureProofContextCandidates) {
            items.insert(futureProofContextSummaryItem, at: 6)
        }
        return items
    }

    func makeLifeContextSections(
        bundle: LifeContextBundle?,
        projection: LifeContextRuntimeProjection?,
        ledger: PersonalizationFactorLedger,
        basePath: String
    ) -> [YouLifeContextSection] {
        return [
            YouLifeContextSection(
                id: "life-context-basics",
                title: "Basics",
                subtitle: "Start with the stable facts that give Ambitions a safe default.",
                factRows: makeBasicsRows(bundle: bundle, projection: projection, basePath: basePath)
            ),
            YouLifeContextSection(
                id: "life-context-schedule-availability",
                title: "Schedule & Availability",
                subtitle: "Keep protected time and cadence visible before any suggestion.",
                factRows: makeScheduleAvailabilityRows(bundle: bundle, projection: projection, basePath: basePath)
            ),
            YouLifeContextSection(
                id: "life-context-travel-access",
                title: "Travel & Access",
                subtitle: "Travel radius and access shape what is realistic.",
                factRows: makeTravelAccessRows(bundle: bundle, projection: projection, basePath: basePath)
            ),
            YouLifeContextSection(
                id: "life-context-facilities-equipment",
                title: "Facilities & Equipment",
                subtitle: "Place and equipment should match the actual opportunity.",
                factRows: makeFacilitiesEquipmentRows(bundle: bundle, projection: projection, basePath: basePath)
            ),
            YouLifeContextSection(
                id: "life-context-eligibility-pathways",
                title: "Eligibility & Pathways",
                subtitle: "Each pathway stays tied to the reason it exists.",
                factRows: makeEligibilityPathwayRows(bundle: bundle, projection: projection, basePath: basePath)
            ),
            YouLifeContextSection(
                id: "life-context-history",
                title: "History",
                subtitle: "Past context stays visible so Ambitions can ask before it assumes too much.",
                factRows: makeHistoryRows(bundle: bundle, projection: projection, basePath: basePath)
            ),
            YouLifeContextSection(
                id: "life-context-constraints",
                title: "Constraints",
                subtitle: "Keep budget, energy, care, accessibility, and recovery visible.",
                factRows: makeConstraintsRows(bundle: bundle, projection: projection, basePath: basePath)
            ),
            YouLifeContextSection(
                id: "life-context-runtime-factors",
                title: "Runtime Factors",
                subtitle: "These are the current factors shaping recommendation behavior.",
                factRows: makeRuntimeFactorRows(ledger: ledger, basePath: basePath)
            ),
            YouLifeContextSection(
                id: "life-context-recommendation-inputs",
                title: "Recommendation Inputs",
                subtitle: "Selected and rejected candidate inputs stay inspectable.",
                factRows: makeRecommendationInputRows(ledger: ledger, basePath: basePath)
            ),
            YouLifeContextSection(
                id: "life-context-why-this-changes-plans",
                title: "Why This Changes Plans",
                subtitle: "The concrete reasons that are allowed to move a recommendation.",
                factRows: makeWhyThisChangesPlanRows(ledger: ledger, basePath: basePath)
            ),
            YouLifeContextSection(
                id: "life-context-rejected-factors",
                title: "Rejected Factors",
                subtitle: "Factors that are blocked or intentionally excluded.",
                factRows: makeRejectedFactorRows(ledger: ledger, basePath: basePath)
            ),
            YouLifeContextSection(
                id: "life-context-sensitive-context-usage",
                title: "Sensitive Context Usage",
                subtitle: "Sensitive inputs stay visible without leaking raw detail.",
                factRows: makeSensitiveContextUsageRows(ledger: ledger, basePath: basePath)
            ),
            YouLifeContextSection(
                id: "life-context-context-confidence",
                title: "Context Confidence",
                subtitle: "Freshness and review posture together shape confidence.",
                factRows: makeContextConfidenceRows(ledger: ledger, basePath: basePath)
            ),
            YouLifeContextSection(
                id: "life-context-review-needed",
                title: "Needs Review",
                subtitle: "These rows need a fresh check before runtime use.",
                factRows: makeReviewNeededRows(bundle: bundle, projection: projection, basePath: basePath)
            ),
            YouLifeContextSection(
                id: "life-context-disabled-factors",
                title: "Disabled Factors",
                subtitle: "These factors are explicitly removed from runtime use.",
                factRows: makeDisabledFactorRows(ledger: ledger, basePath: basePath)
            ),
            YouLifeContextSection(
                id: "life-context-replay-receipts",
                title: "Replay & Receipts",
                subtitle: "The replay fingerprint and review history stay visible.",
                factRows: makeReplayAndReceiptRows(ledger: ledger, basePath: basePath)
            )
        ]
    }

    func makeFutureProofContextSection(
        candidates: [FutureProofContextCandidate],
        basePath: String
    ) -> YouLifeContextSection? {
        let rows = makeFutureProofContextRows(candidates: candidates, basePath: basePath)
        guard rows.isEmpty == false else {
            return nil
        }

        return YouLifeContextSection(
            id: "life-context-future-proof-context",
            title: "Future-proof context",
            subtitle: "Captured context that can stay visible and reviewable for later planning.",
            factRows: rows
        )
    }

    func makeFutureProofContextRows(
        candidates: [FutureProofContextCandidate],
        basePath: String
    ) -> [YouLifeContextFactRow] {
        candidates.sorted { $0.id < $1.id }.map { candidate in
            let runtimeUseState = candidate.runtimeUseAllowed && candidate.reviewNeeded == false ? YouLifeContextRuntimeUseState.used : .needsReview
            let displayTitle = candidate.contextCategory == .skillContext
                ? FutureProofContextCategory.recurringCommitment.displayTitle
                : candidate.contextCategory.displayTitle
            return makeLifeContextFactRow(
                id: "future-proof-context-\(candidate.id)",
                title: displayTitle,
                detail: futureProofContextDetail(for: candidate),
                sourceLabel: candidate.sourceLabel,
                freshness: memoryFreshness(for: candidate.freshness),
                runtimeUseState: runtimeUseState,
                activityLabel: displayTitle,
                lastAffectedLabel: candidate.visibleInYou ? "Visible in You" : "Hidden from You",
                runtimePermissionLabel: candidate.runtimeUseAllowed ? "Allowed" : "Approval required",
                whereUsed: candidate.potentialFutureUses.joined(separator: " · "),
                updateTargets: [.historicalFact],
                captureRouteContext: candidate.reviewNeeded || candidate.runtimeUseAllowed == false ? .needsReview : .needsPlace,
                basePath: "\(basePath) > Future-proof context"
            )
        }
    }

    func futureProofContextSummaryItem(candidates: [FutureProofContextCandidate]) -> SettingsItem? {
        guard candidates.isEmpty == false else {
            return nil
        }

        return SettingsItem(
            id: "life-context-future-proof-context",
            title: "Future-proof context",
            subtitle: "Standalone captures and stored context you can reuse later without forcing goal attachment.",
            icon: "sparkles",
            valueLabel: "\(candidates.count) items"
        )
    }

    func makeFutureProofContextCandidates(snapshot: Snapshot, bundle: LifeContextBundle?) -> [FutureProofContextCandidate] {
        let storedCandidates = bundle?.futureProofContextCandidates ?? []
        let derivedCandidates = snapshot.captures
            .filter { $0.status != .archived }
            .compactMap { capture -> FutureProofContextCandidate? in
                let result = DefaultSmartAttachmentService().route(
                    SmartAttachmentInput(
                        rawText: capture.rawText,
                        sourceContext: SmartAttachmentSourceContext(
                            sourceType: capture.sourceType,
                            sourceSurface: "Capture"
                        )
                    ),
                    candidates: []
                )
                return result.futureProofContextCandidate
            }

        var ordered = [String: FutureProofContextCandidate]()
        for candidate in storedCandidates + derivedCandidates {
            ordered[candidate.id] = candidate
        }
        return ordered.values.sorted { $0.id < $1.id }
    }

    func futureProofContextDetail(for candidate: FutureProofContextCandidate) -> String {
        let uses = candidate.potentialFutureUses.joined(separator: ", ")
        let runtimeLine = candidate.runtimeUseAllowed ? "Runtime use allowed." : "Runtime use blocked until approval."
        let reviewLine = candidate.reviewNeeded ? "Review needed." : "Review not required."
        return "\(candidate.contextCategory.displayTitle) from \(candidate.sourceLabel). \(uses). \(runtimeLine) \(reviewLine) Deletion supported: \(candidate.deletionSupported ? "yes" : "no")."
    }

}
