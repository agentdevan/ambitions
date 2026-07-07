import Foundation

extension LifeContextBundle {
    var isDeleted: Bool {
        deletedAt != nil
    }


    func updated(
        profile: LifeContextProfile? = nil,
        eligibilityPathways: [LifeContextEligibilityPathway]? = nil,
        opportunityContexts: [OpportunityContext]? = nil,
        historicalFacts: [HistoricalContextFact]? = nil,
        sources: [LifeContextSource]? = nil,
        futureProofContextCandidates: [FutureProofContextCandidate]? = nil,
        updatedAt: String
    ) -> LifeContextBundle {
        LifeContextBundle(
            id: id,
            profile: profile ?? self.profile,
            eligibilityPathways: eligibilityPathways ?? self.eligibilityPathways,
            opportunityContexts: opportunityContexts ?? self.opportunityContexts,
            historicalFacts: historicalFacts ?? self.historicalFacts,
            sources: sources ?? self.sources,
            futureProofContextCandidates: futureProofContextCandidates ?? self.futureProofContextCandidates,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt
        )
    }


    func markedDeleted(at timestamp: String) -> LifeContextBundle {
        LifeContextBundle(
            id: id,
            profile: profile,
            eligibilityPathways: eligibilityPathways,
            opportunityContexts: opportunityContexts,
            historicalFacts: historicalFacts,
            sources: sources,
            futureProofContextCandidates: futureProofContextCandidates,
            createdAt: createdAt,
            updatedAt: timestamp,
            deletedAt: timestamp
        )
    }


    func replacingHistoricalFact(_ fact: HistoricalContextFact, updatedAt: String) -> LifeContextBundle {
        var facts = historicalFacts
        if let index = facts.firstIndex(where: { $0.id == fact.id }) {
            facts[index] = fact
        } else {
            facts.append(fact)
        }
        return updated(historicalFacts: facts, updatedAt: updatedAt)
    }


    func markHistoricalFactDeleted(id: String, at timestamp: String) -> LifeContextBundle {
        updated(
            historicalFacts: historicalFacts.map { $0.id == id ? $0.markedDeleted(at: timestamp) : $0 },
            updatedAt: timestamp
        )
    }


    func markHistoricalFactPaused(id: String, at timestamp: String) -> LifeContextBundle {
        updated(
            historicalFacts: historicalFacts.map { $0.id == id ? $0.markedPaused(at: timestamp) : $0 },
            updatedAt: timestamp
        )
    }


    func projection(asOf now: Date = .now) -> LifeContextRuntimeProjection {
        let activeFacts = historicalFacts.filter(\.isRuntimeEligible)
        let ageYears = resolvedAgeYears(asOf: now)
        let anchors = opportunityContexts.flatMap { opportunity in
            opportunity.facilities.map { facility in
                LifeContextOpportunityAnchor(
                    id: "\(opportunity.id).\(facility.rawValue)",
                    title: facility.rawValue.replacingOccurrences(of: "_", with: " ").capitalized,
                    detail: opportunityDetail(for: opportunity),
                    verificationStatus: opportunity.verificationStatus
                )
            }
        }
        .sorted { $0.id < $1.id }

        let hardConstraints = deriveConstraints(from: activeFacts, isHard: true)
        let softConstraints = deriveConstraints(from: activeFacts, isHard: false)
        let historySummary = activeFacts.map {
            LifeContextHistorySummary(
                id: $0.id,
                title: $0.title,
                detail: $0.detail ?? $0.category.rawValue.replacingOccurrences(of: "_", with: " "),
                freshness: $0.freshness,
                usedFor: $0.usedFor
            )
        }
        .sorted { $0.id < $1.id }
        let excludedHistorySummary = historicalFacts.compactMap { fact -> LifeContextHistoryExclusionSummary? in
            guard fact.isDeletedOrPaused else {
                return nil
            }

            let reason: LifeContextHistoryExclusionReason = fact.deletedAt != nil || fact.sourceType == .deleted ? .deleted : .paused
            return LifeContextHistoryExclusionSummary(
                id: fact.id,
                factID: fact.id,
                reason: reason
            )
        }
        .sorted { $0.id < $1.id }
        let sourceFreshnessSummary = sources.map { source in
            LifeContextSourceFreshnessSummary(
                id: source.id,
                sourceID: source.id,
                label: source.label,
                freshness: freshness(for: source, asOf: now),
                detail: source.visibleExplanation
            )
        }
        .sorted { $0.id < $1.id }
        let sensitiveUseWarnings: [LifeContextSensitiveUseWarning] = historicalFacts.compactMap { fact -> LifeContextSensitiveUseWarning? in
            guard fact.isDeletedOrPaused == false, fact.sensitivity != .normal, fact.runtimeUseAllowed == false else {
                return nil
            }
            return LifeContextSensitiveUseWarning(
                id: fact.id,
                factID: fact.id,
                title: fact.title,
                detail: "Runtime use is blocked until the user explicitly allows it."
            )
        }
        .sorted { $0.id < $1.id }
        let missingContextQuestions = missingContextQuestions(ageYears: ageYears)

        return LifeContextRuntimeProjection(
            ageYears: ageYears,
            lifeStage: profile.lifeStage,
            availableOpportunityAnchors: anchors,
            hardConstraints: hardConstraints,
            softConstraints: softConstraints,
            travelModel: LifeContextTravelModel(
                radiusMinutes: profile.travelRadiusMinutes,
                radiusMiles: profile.travelRadiusMiles,
                transportationAccess: profile.transportationAccess,
                locationLabel: profile.generalLocationLabel,
                locationPrecision: profile.locationPrecision
            ),
            eligibilityModel: eligibilityPathways.sorted { $0.id < $1.id },
            historySummary: historySummary,
            excludedHistorySummary: excludedHistorySummary,
            sourceFreshnessSummary: sourceFreshnessSummary,
            sensitiveUseWarnings: sensitiveUseWarnings,
            missingContextQuestions: missingContextQuestions
        )
    }


    func inspectableRecords() -> [LifeContextInspectableRecord] {
        historicalFacts
            .map { fact in
                let privacyBoundary: LifeContextPrivacyIndexingBoundary
                let visibleDetail: String
                if fact.isDeletedOrPaused {
                    privacyBoundary = .excludedFromRuntime
                    visibleDetail = "Excluded from runtime use."
                } else if fact.sensitivity == .normal {
                    privacyBoundary = .summaryOnly
                    visibleDetail = fact.detail ?? fact.category.rawValue.replacingOccurrences(of: "_", with: " ")
                } else {
                    privacyBoundary = .privateDetailHidden
                    visibleDetail = "Private detail hidden; review in Search Ambitions."
                }

                return LifeContextInspectableRecord(
                    id: fact.id,
                    title: fact.title,
                    visibleDetail: visibleDetail,
                    sourceLabel: displayLabel(for: fact.sourceType),
                    sourceRecordID: "SourceRecord.life-context.\(fact.id)",
                    receiptID: "Receipt.life-context.\(fact.id)",
                    replayTraceID: "ReplayTrace.life-context.\(fact.id)",
                    confidence: fact.confidence,
                    freshness: fact.freshness,
                    privacyIndexingBoundary: privacyBoundary,
                    controlActionIDs: ["edit", "review", "pause", "delete", "reset"],
                    inspectionSurfaceTitle: "Search Ambitions",
                    inspectionSummary: "You / Search Ambitions can inspect this life context source, receipt, reason, confidence, provenance, and reset boundary."
                )
            }
            .sorted { $0.id < $1.id }
    }


    func resolvedAgeYears(asOf now: Date) -> Int? {
        if let exactAgeYears = profile.exactAgeYears {
            return exactAgeYears
        }

        guard let birthdate = profile.birthdate,
              let birthdateDate = DomainTimestamp.date(from: birthdate) else {
            return nil
        }

        let calendar = Calendar(identifier: .gregorian)
        let years = calendar.dateComponents([.year], from: birthdateDate, to: now).year ?? 0
        return max(0, years)
    }
}
