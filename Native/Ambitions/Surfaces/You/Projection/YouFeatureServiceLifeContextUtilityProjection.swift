import AmbitionsDesignSystem
import Foundation

extension RepositoryBackedYouService {
    func makeLifeContextFactRow(
        id: String,
        title: String,
        detail: String,
        sourceLabel: String,
        freshness: YouMemoryFreshness,
        runtimeUseState: YouLifeContextRuntimeUseState,
        activityLabel: String = "Active",
        lastAffectedLabel: String = "This run",
        runtimePermissionLabel: String = "Allowed",
        whereUsed: String,
        updateTargets: [YouLifeContextUpdateTarget],
        captureRouteContext: CaptureBackgroundFactRoute,
        basePath: String
    ) -> YouLifeContextFactRow {
        let editPath = "\(basePath) > Edit"
        let pausePath = "\(basePath) > Pause"
        let deletePath = "\(basePath) > Delete"
        let reviewPath = "\(basePath) > Review"
        let confirmPath = "\(basePath) > Confirm"
        let editLabel = "Edit"
        let pauseLabel = "Pause"
        let deleteLabel = "Delete"
        let reviewLabel = "Review"
        let confirmLabel = "Confirm"

        return YouLifeContextFactRow(
            id: id,
            title: title,
            detail: detail,
            sourceLabel: sourceLabel,
            freshness: freshness,
            runtimeUseState: runtimeUseState,
            activityLabel: activityLabel,
            lastAffectedLabel: lastAffectedLabel,
            runtimePermissionLabel: runtimePermissionLabel,
            whereUsed: whereUsed,
            editPath: editPath,
            pausePath: pausePath,
            deletePath: deletePath,
            reviewPath: reviewPath,
            confirmPath: confirmPath,
            editLabel: editLabel,
            pauseLabel: pauseLabel,
            deleteLabel: deleteLabel,
            reviewLabel: reviewLabel,
            confirmLabel: confirmLabel,
            updateTargets: updateTargets,
            captureRouteContext: captureRouteContext,
            accessibilityLabel: title,
            accessibilityValue: "\(detail). Source \(sourceLabel). Freshness \(freshness.label). Runtime use \(runtimeUseState.label). Activity \(activityLabel). Last affected \(lastAffectedLabel). Permission \(runtimePermissionLabel). Used for \(whereUsed).",
            accessibilityHint: "Edit, pause, delete, review, and confirm paths stay visible from the owning Life Context surface."
        )
    }

    func ageAnswer(bundle: LifeContextBundle?, projection: LifeContextRuntimeProjection?) -> String {
        if let age = projection?.ageYears ?? bundle?.profile.exactAgeYears {
            return "\(age) years old"
        }
        if let birthdate = bundle?.profile.birthdate {
            return birthdate
        }
        return "Not captured"
    }

    func ageSourceLabel(bundle: LifeContextBundle?) -> String {
        bundle?.profile.ageSource?.label ?? "Profile"
    }

    func ageFreshness(bundle: LifeContextBundle?, projection: LifeContextRuntimeProjection?) -> YouMemoryFreshness {
        guard let bundle else {
            return .basedOnOlderContext
        }
        if bundle.profile.ageSource == nil {
            return .basedOnOlderContext
        }
        if let sourceFreshness = projection?.sourceFreshnessSummary.first(where: { $0.sourceID == bundle.profile.ageSource?.id })?.freshness {
            return memoryFreshness(for: sourceFreshness)
        }
        return .current
    }

    func ageRuntimeUseState(bundle: LifeContextBundle?, projection: LifeContextRuntimeProjection?) -> YouLifeContextRuntimeUseState {
        switch ageFreshness(bundle: bundle, projection: projection) {
        case .current:
            return .used
        case .mayNeedReview:
            return .needsReview
        case .basedOnOlderContext:
            return .needsReview
        }
    }

    func factRuntimeUseState(
        for bundle: LifeContextBundle?,
        matching categories: [HistoricalContextFactCategory]
    ) -> YouLifeContextRuntimeUseState {
        let facts = bundle?.historicalFacts.filter { $0.isDeletedOrPaused == false && categories.contains($0.category) } ?? []
        if facts.isEmpty {
            return .needsReview
        }
        if facts.contains(where: { $0.freshness == .current && $0.runtimeUseAllowed }) {
            return .used
        }
        if facts.contains(where: { $0.runtimeUseAllowed == false }) {
            return .needsReview
        }
        return .needsReview
    }

    func deadlineRuntimeUseState(
        for bundle: LifeContextBundle?,
        projection: LifeContextRuntimeProjection?
    ) -> YouLifeContextRuntimeUseState {
        switch deadlineFreshness(for: bundle, projection: projection) {
        case .current:
            return .used
        case .mayNeedReview, .basedOnOlderContext:
            return .needsReview
        }
    }

    func olderContextRuntimeUseState(
        for bundle: LifeContextBundle?,
        projection: LifeContextRuntimeProjection?
    ) -> YouLifeContextRuntimeUseState {
        switch olderContextFreshness(for: bundle, projection: projection) {
        case .current:
            return .used
        case .mayNeedReview, .basedOnOlderContext:
            return .needsReview
        }
    }

    func receiptRuntimeUseState(for freshness: LifeContextFreshness) -> YouLifeContextRuntimeUseState {
        switch freshness {
        case .current:
            return .used
        case .mayNeedReview:
            return .needsReview
        case .basedOnOlderContext, .stale:
            return .notUsed
        }
    }

    func memoryFreshness(for freshness: PersonalizationFactorLedgerFreshnessState) -> YouMemoryFreshness {
        switch freshness {
        case .current:
            return .current
        case .mayNeedReview:
            return .mayNeedReview
        case .basedOnOlderContext, .stale:
            return .basedOnOlderContext
        }
    }

    func displayLabel(for budgetConstraintBand: LifeContextBudgetConstraintBand) -> String {
        switch budgetConstraintBand {
        case .tight:
            return "Tight"
        case .moderate:
            return "Moderate"
        case .flexible:
            return "Flexible"
        case .custom:
            return "Custom"
        case .unknown:
            return "Not captured"
        }
    }

    func displayLabel(for energyPattern: LifeContextEnergyPattern) -> String {
        switch energyPattern {
        case .morning:
            return "Morning"
        case .midday:
            return "Midday"
        case .evening:
            return "Evening"
        case .variable:
            return "Variable"
        case .unknown:
            return "Not captured"
        }
    }

    func displayLabel(for locationPrecision: LifeContextLocationPrecision) -> String {
        switch locationPrecision {
        case .none:
            return "Not captured"
        case .timezone:
            return "Timezone only"
        case .cityRegion:
            return "City or region"
        case .userEnteredPlace:
            return "User-entered place"
        case .precisePermissioned:
            return "Precise with permission"
        }
    }

    func displayLabel(for sourceKind: LifeContextSourceKind) -> String {
        switch sourceKind {
        case .userConfirmed:
            return "Confirmed"
        case .imported:
            return "Imported"
        case .inferred:
            return "Inferred"
        case .corrected:
            return "Corrected"
        }
    }

    func displayLabel(for pathwayType: LifeContextEligibilityPathwayType) -> String {
        switch pathwayType {
        case .sport:
            return "Sport"
        case .academic:
            return "School"
        case .career:
            return "Career"
        case .creative:
            return "Creative"
        case .health:
            return "Health"
        case .finance:
            return "Finance"
        case .custom:
            return "Custom"
        }
    }

    func displayLabel(for factorType: PersonalizationFactorLedgerFactorType) -> String {
        switch factorType {
        case .goalRequirement:
            return "Goal requirement"
        case .deadlinePressure:
            return "Deadline pressure"
        case .availabilityWindow:
            return "Availability window"
        case .travelFit:
            return "Travel fit"
        case .transportationConstraint:
            return "Transportation constraint"
        case .facilityAccess:
            return "Facility access"
        case .equipmentAccess:
            return "Equipment access"
        case .historicalContext:
            return "Historical context"
        case .pastFailure:
            return "Past failure"
        case .pastSuccess:
            return "Past success"
        case .recoveryConstraint:
            return "Recovery constraint"
        case .executionBehavior:
            return "Execution behavior"
        case .timeOfDayFit:
            return "Time of day fit"
        case .energyPattern:
            return "Energy pattern"
        case .eligibilityPathway:
            return "Eligibility pathway"
        case .seasonality:
            return "Seasonality"
        case .dependencyConstraint:
            return "Dependency constraint"
        case .budgetConstraint:
            return "Budget constraint"
        case .preference:
            return "Preference"
        case .trustAllowance:
            return "Trust allowance"
        case .recentProof:
            return "Recent proof"
        case .recentDrift:
            return "Recent drift"
        case .safetyConstraint:
            return "Safety constraint"
        }
    }

    func runtimeUseState(for factor: PersonalizationFactorLedgerFactor) -> YouLifeContextRuntimeUseState {
        if factor.allowedForRuntimeUse == false || factor.active == false {
            return .notUsed
        }
        return factor.freshness.state == .current ? .used : .needsReview
    }

    func factorUpdateTargets(for factor: PersonalizationFactorLedgerFactor) -> [YouLifeContextUpdateTarget] {
        switch factor.factorCategory {
        case .eligibility:
            return [.profile, .eligibilityPathway]
        case .access:
            return [.profile, .opportunityContext]
        case .history:
            return [.historicalFact]
        case .recovery, .safety:
            return [.profile, .historicalFact]
        case .timing, .preference, .trust, .proof, .freshness, .sensitivity, .replay, .goal:
            return [.historicalFact]
        }
    }

    func constraintDetail(
        from constraints: [LifeContextConstraintSummary],
        matching titles: [String],
        fallback: String
    ) -> String {
        let matches = constraints.filter { titles.contains($0.title) }.map(\.detail)
        return matches.isEmpty ? fallback : Array(Set(matches)).sorted().joined(separator: ", ")
    }

    func equipmentNeedSummary(for bundle: LifeContextBundle?) -> String {
        guard let bundle else { return "Not captured" }
        let needs = bundle.opportunityContexts.flatMap { opportunity -> [String] in
            var items: [String] = []
            if let travelRequirement = opportunity.travelRequirement {
                items.append(travelRequirement)
            }
            if let costRequirement = opportunity.costRequirement {
                items.append(costRequirement)
            }
            return items
        }
        return needs.isEmpty ? "Not captured" : Array(Set(needs)).sorted().joined(separator: ", ")
    }

    func seasonalAccessSummary(for bundle: LifeContextBundle?) -> String {
        guard let bundle else { return "Not captured" }
        let access = bundle.opportunityContexts.flatMap { opportunity -> [String] in
            var items: [String] = []
            if let seasonalAvailability = opportunity.seasonalAvailability {
                items.append(seasonalAvailability)
            }
            if let travelRequirement = opportunity.travelRequirement {
                items.append(travelRequirement)
            }
            if let costRequirement = opportunity.costRequirement {
                items.append(costRequirement)
            }
            return items
        }
        return access.isEmpty ? "Not captured" : Array(Set(access)).sorted().joined(separator: ", ")
    }

    func eligibilityConstraintSummary(for pathways: [LifeContextEligibilityPathway]) -> String {
        guard pathways.isEmpty == false else { return "Not captured" }
        let pieces = pathways.flatMap { pathway -> [String] in
            var items: [String] = []
            if let ageWindow = pathway.ageWindow {
                switch (ageWindow.lowerBoundYears, ageWindow.upperBoundYears) {
                case let (lower?, upper?):
                    items.append("\(lower) to \(upper) years")
                case let (lower?, nil):
                    items.append("\(lower)+ years")
                case let (nil, upper?):
                    items.append("Up to \(upper) years")
                case (nil, nil):
                    break
                }
            }
            if let gradeWindow = pathway.gradeWindow {
                items.append(gradeWindow)
            }
            if let sexLeaguePathway = pathway.sexLeaguePathway {
                items.append(sexLeaguePathway)
            }
            return items
        }
        return pieces.isEmpty ? "Not captured" : Array(Set(pieces)).sorted().joined(separator: ", ")
    }

}
