import AmbitionsDesignSystem
import Foundation

extension RepositoryBackedYouService {
    func makeBasicsRows(
        bundle: LifeContextBundle?,
        projection: LifeContextRuntimeProjection?,
        basePath: String
    ) -> [YouLifeContextFactRow] {
        [
            makeLifeContextFactRow(
                id: "life-context-age",
                title: "Birthday or exact age",
                detail: ageAnswer(bundle: bundle, projection: projection),
                sourceLabel: ageSourceLabel(bundle: bundle),
                freshness: ageFreshness(bundle: bundle, projection: projection),
                runtimeUseState: ageRuntimeUseState(bundle: bundle, projection: projection),
                whereUsed: "Eligibility, fit, and pacing",
                updateTargets: [.profile, .historicalFact, .eligibilityPathway],
                captureRouteContext: .needsReview,
                basePath: basePath
            ),
            makeLifeContextFactRow(
                id: "life-context-stage",
                title: "Life stage",
                detail: bundle.map { displayLabel(for: $0.profile.lifeStage) } ?? "Not captured",
                sourceLabel: "Personal context",
                freshness: bundle == nil || bundle?.profile.lifeStage == .unknown ? .basedOnOlderContext : .current,
                runtimeUseState: bundle == nil || bundle?.profile.lifeStage == .unknown ? .needsReview : .used,
                whereUsed: "Safer defaults and pace",
                updateTargets: [.profile, .historicalFact],
                captureRouteContext: .needsReview,
                basePath: basePath
            ),
            makeLifeContextFactRow(
                id: "life-context-timezone",
                title: "Timezone",
                detail: bundle?.profile.timezone ?? "Not captured",
                sourceLabel: "Personal context",
                freshness: bundle?.profile.timezone == nil ? .basedOnOlderContext : .current,
                runtimeUseState: bundle?.profile.timezone == nil ? .needsReview : .used,
                whereUsed: "Time, scheduling, and travel grounding",
                updateTargets: [.profile, .opportunityContext],
                captureRouteContext: .needsPlace,
                basePath: basePath
            ),
            makeLifeContextFactRow(
                id: "life-context-location",
                title: "General location",
                detail: bundle?.profile.generalLocationLabel ?? "Not captured",
                sourceLabel: "Personal context",
                freshness: bundle?.profile.generalLocationLabel == nil ? .basedOnOlderContext : .current,
                runtimeUseState: bundle?.profile.generalLocationLabel == nil ? .needsReview : .used,
                whereUsed: "Time, travel, and opportunity paths",
                updateTargets: [.profile, .opportunityContext],
                captureRouteContext: .needsPlace,
                basePath: basePath
            ),
            makeLifeContextFactRow(
                id: "life-context-school-work",
                title: "School / work context",
                detail: bundle?.profile.schoolOrWorkContext ?? "Not captured",
                sourceLabel: "Personal context",
                freshness: bundle?.profile.schoolOrWorkContext == nil ? .basedOnOlderContext : .current,
                runtimeUseState: bundle?.profile.schoolOrWorkContext == nil ? .needsReview : .used,
                whereUsed: "Avoid impossible steps",
                updateTargets: [.profile, .historicalFact],
                captureRouteContext: .needsReview,
                basePath: basePath
            )
        ]
    }

    func makeScheduleAvailabilityRows(
        bundle: LifeContextBundle?,
        projection: LifeContextRuntimeProjection?,
        basePath: String
    ) -> [YouLifeContextFactRow] {
        [
            makeLifeContextFactRow(
                id: "life-context-work-school-anchors",
                title: "Work / school anchors",
                detail: bundle?.profile.schoolOrWorkContext ?? "Not captured",
                sourceLabel: "Personal context",
                freshness: bundle?.profile.schoolOrWorkContext == nil ? .basedOnOlderContext : .current,
                runtimeUseState: bundle?.profile.schoolOrWorkContext == nil ? .needsReview : .used,
                whereUsed: "Protect the day shape before suggestions shift it",
                updateTargets: [.profile, .historicalFact],
                captureRouteContext: .needsReview,
                basePath: basePath
            ),
            makeLifeContextFactRow(
                id: "life-context-recurring-commitments",
                title: "Recurring commitments",
                detail: bundle?.profile.scheduleAnchors.isEmpty == false ? bundle!.profile.scheduleAnchors.joined(separator: ", ") : "Not captured",
                sourceLabel: "Personal context",
                freshness: bundle == nil || bundle?.profile.scheduleAnchors.isEmpty == true ? .basedOnOlderContext : .current,
                runtimeUseState: bundle == nil || bundle?.profile.scheduleAnchors.isEmpty == true ? .needsReview : .used,
                whereUsed: "Avoid impossible scheduling",
                updateTargets: [.profile, .historicalFact],
                captureRouteContext: .needsReview,
                basePath: basePath
            ),
            makeLifeContextFactRow(
                id: "life-context-protected-time",
                title: "Protected time",
                detail: constraintDetail(
                    from: projection?.hardConstraints ?? [],
                    matching: ["Dependency constraint"],
                    fallback: bundle?.profile.dependencyConstraints.joined(separator: ", ") ?? "Not captured"
                ),
                sourceLabel: "Personal context",
                freshness: (projection?.hardConstraints.contains(where: { $0.title == "Dependency constraint" }) ?? false) ? .current : .basedOnOlderContext,
                runtimeUseState: (projection?.hardConstraints.contains(where: { $0.title == "Dependency constraint" }) ?? false) ? .used : .needsReview,
                whereUsed: "Keep recovery-aware pacing visible",
                updateTargets: [.profile, .historicalFact],
                captureRouteContext: .needsReview,
                basePath: basePath
            ),
            makeLifeContextFactRow(
                id: "life-context-flexible-windows",
                title: "Flexible windows",
                detail: constraintDetail(
                    from: projection?.softConstraints ?? [],
                    matching: ["Energy pattern", "Budget"],
                    fallback: bundle.map { displayLabel(for: $0.profile.energyPattern) } ?? "Not captured"
                ),
                sourceLabel: "Personal context",
                freshness: bundle == nil ? .basedOnOlderContext : .current,
                runtimeUseState: bundle == nil ? .needsReview : .used,
                whereUsed: "Keep capacity honest",
                updateTargets: [.profile],
                captureRouteContext: .needsReview,
                basePath: basePath
            ),
            makeLifeContextFactRow(
                id: "life-context-recovery-defaults",
                title: "Recovery defaults",
                detail: bundle?.profile.recoveryConstraints.isEmpty == false ? bundle!.profile.recoveryConstraints.joined(separator: ", ") : "Not captured",
                sourceLabel: "Personal context",
                freshness: bundle?.profile.recoveryConstraints.isEmpty == true ? .basedOnOlderContext : .current,
                runtimeUseState: bundle?.profile.recoveryConstraints.isEmpty == true ? .needsReview : .used,
                whereUsed: "Keep recovery-aware pacing visible",
                updateTargets: [.profile, .historicalFact],
                captureRouteContext: .needsReview,
                basePath: basePath
            )
        ]
    }

    func makeTravelAccessRows(
        bundle: LifeContextBundle?,
        projection: LifeContextRuntimeProjection?,
        basePath: String
    ) -> [YouLifeContextFactRow] {
        [
            makeLifeContextFactRow(
                id: "life-context-transport",
                title: "Transportation access",
                detail: bundle.map { displayLabel(for: $0.profile.transportationAccess) } ?? "Not captured",
                sourceLabel: "Personal context",
                freshness: (bundle?.profile.transportationAccess ?? .unknown) == .unknown ? .basedOnOlderContext : .current,
                runtimeUseState: (bundle?.profile.transportationAccess ?? .unknown) == .unknown ? .needsReview : .used,
                whereUsed: "Fit travel and access assumptions",
                updateTargets: [.profile, .opportunityContext],
                captureRouteContext: .needsPlace,
                basePath: basePath
            ),
            makeLifeContextFactRow(
                id: "life-context-travel-radius",
                title: "Travel radius",
                detail: travelRadiusSummary(for: bundle?.profile),
                sourceLabel: "Personal context",
                freshness: bundle?.profile.travelRadiusMinutes == nil && bundle?.profile.travelRadiusMiles == nil ? .basedOnOlderContext : .current,
                runtimeUseState: bundle?.profile.travelRadiusMinutes == nil && bundle?.profile.travelRadiusMiles == nil ? .needsReview : .used,
                whereUsed: "Route fit and nearby opportunity paths",
                updateTargets: [.profile, .opportunityContext],
                captureRouteContext: .needsPlace,
                basePath: basePath
            ),
            makeLifeContextFactRow(
                id: "life-context-location-precision",
                title: "Location precision",
                detail: bundle.map { displayLabel(for: $0.profile.locationPrecision) } ?? "Not captured",
                sourceLabel: "Personal context",
                freshness: ((bundle?.profile.locationPrecision).map { $0 != LifeContextLocationPrecision.none } ?? false) ? .current : .basedOnOlderContext,
                runtimeUseState: ((bundle?.profile.locationPrecision).map { $0 != LifeContextLocationPrecision.none } ?? false) ? .used : .needsReview,
                whereUsed: "Keep location assumptions narrow",
                updateTargets: [.profile, .opportunityContext],
                captureRouteContext: .needsPlace,
                basePath: basePath
            ),
            makeLifeContextFactRow(
                id: "life-context-commute-tolerance",
                title: "Commute tolerance",
                detail: bundle?.profile.travelRadiusMinutes.map { "\($0) minutes" } ?? "Not captured",
                sourceLabel: "Personal context",
                freshness: bundle?.profile.travelRadiusMinutes == nil ? .basedOnOlderContext : .current,
                runtimeUseState: bundle?.profile.travelRadiusMinutes == nil ? .needsReview : .used,
                whereUsed: "Keep route suggestions within comfort",
                updateTargets: [.profile, .opportunityContext],
                captureRouteContext: .needsPlace,
                basePath: basePath
            ),
            makeLifeContextFactRow(
                id: "life-context-parent-guardian",
                title: "Parent / guardian dependency",
                detail: bundle?.profile.transportationAccess == .parentGuardian ? "Parent or guardian transport is part of the plan." : "Not captured",
                sourceLabel: "Personal context",
                freshness: bundle?.profile.transportationAccess == .parentGuardian ? .current : .basedOnOlderContext,
                runtimeUseState: bundle?.profile.transportationAccess == .parentGuardian ? .used : .needsReview,
                whereUsed: "Respect dependency-driven access",
                updateTargets: [.profile, .opportunityContext],
                captureRouteContext: .needsPlace,
                basePath: basePath
            ),
            makeLifeContextFactRow(
                id: "life-context-mobility-constraints",
                title: "Mobility constraints",
                detail: bundle?.profile.accessibilityNeeds.isEmpty == false ? bundle!.profile.accessibilityNeeds.joined(separator: ", ") : "Not captured",
                sourceLabel: "Personal context",
                freshness: bundle?.profile.accessibilityNeeds.isEmpty == true ? .basedOnOlderContext : .current,
                runtimeUseState: bundle?.profile.accessibilityNeeds.isEmpty == true ? .needsReview : .used,
                whereUsed: "Keep mobility assumptions honest",
                updateTargets: [.profile, .opportunityContext],
                captureRouteContext: .needsPlace,
                basePath: basePath
            )
        ]
    }

    func makeFacilitiesEquipmentRows(
        bundle: LifeContextBundle?,
        projection: LifeContextRuntimeProjection?,
        basePath: String
    ) -> [YouLifeContextFactRow] {
        let hasOpportunityContexts = bundle?.opportunityContexts.isEmpty == false

        return [
            makeLifeContextFactRow(
                id: "life-context-facilities",
                title: "Facilities access",
                detail: facilitiesSummary(for: bundle),
                sourceLabel: "Opportunity context",
                freshness: hasOpportunityContexts ? .current : .basedOnOlderContext,
                runtimeUseState: hasOpportunityContexts ? .used : .needsReview,
                whereUsed: "Avoid suggesting unavailable places",
                updateTargets: [.opportunityContext],
                captureRouteContext: .needsPlace,
                basePath: basePath
            ),
            makeLifeContextFactRow(
                id: "life-context-equipment",
                title: "Equipment owned",
                detail: equipmentSummary(for: bundle),
                sourceLabel: "Opportunity context",
                freshness: hasOpportunityContexts ? .current : .basedOnOlderContext,
                runtimeUseState: hasOpportunityContexts ? .used : .needsReview,
                whereUsed: "Fit steps to real access",
                updateTargets: [.opportunityContext],
                captureRouteContext: .needsPlace,
                basePath: basePath
            ),
            makeLifeContextFactRow(
                id: "life-context-equipment-needed",
                title: "Equipment needed",
                detail: equipmentNeedSummary(for: bundle),
                sourceLabel: "Opportunity context",
                freshness: hasOpportunityContexts ? .current : .basedOnOlderContext,
                runtimeUseState: hasOpportunityContexts ? .needsReview : .needsReview,
                whereUsed: "Fit steps to real access",
                updateTargets: [.opportunityContext],
                captureRouteContext: .needsPlace,
                basePath: basePath
            ),
            makeLifeContextFactRow(
                id: "life-context-organizations",
                title: "Local organizations",
                detail: localOrganizationsSummary(for: bundle),
                sourceLabel: "Opportunity context",
                freshness: hasOpportunityContexts ? .current : .basedOnOlderContext,
                runtimeUseState: hasOpportunityContexts ? .used : .needsReview,
                whereUsed: "Point toward realistic access",
                updateTargets: [.opportunityContext],
                captureRouteContext: .needsPlace,
                basePath: basePath
            ),
            makeLifeContextFactRow(
                id: "life-context-seasonal-limits",
                title: "Seasonal / access limits",
                detail: seasonalAccessSummary(for: bundle),
                sourceLabel: "Opportunity context",
                freshness: hasOpportunityContexts ? .current : .basedOnOlderContext,
                runtimeUseState: hasOpportunityContexts ? .needsReview : .needsReview,
                whereUsed: "Keep seasonal and access constraints visible",
                updateTargets: [.opportunityContext],
                captureRouteContext: .needsPlace,
                basePath: basePath
            )
        ]
    }

    func makeEligibilityPathwayRows(
        bundle: LifeContextBundle?,
        projection: LifeContextRuntimeProjection?,
        basePath: String
    ) -> [YouLifeContextFactRow] {
        let pathways = bundle?.eligibilityPathways ?? []
        var rows: [YouLifeContextFactRow] = []

        if let sexContext = bundle?.profile.sexOrEligibilityContext, sexContext.isEmpty == false {
            rows.append(
                makeLifeContextFactRow(
                    id: "life-context-eligibility-sex-context",
                    title: "Sex / eligibility context",
                    detail: sexContext,
                    sourceLabel: "Personal context",
                    freshness: .current,
                    runtimeUseState: .needsReview,
                    whereUsed: "Only used where a pathway materially needs it",
                    updateTargets: [.profile, .eligibilityPathway],
                    captureRouteContext: .needsReview,
                    basePath: basePath
                )
            )
        }

        if pathways.isEmpty {
            rows.append(
                makeLifeContextFactRow(
                    id: "life-context-eligibility-placeholder",
                    title: "Sport / school / career / creative pathways",
                    detail: "Not captured",
                    sourceLabel: "Eligibility pathway",
                    freshness: .basedOnOlderContext,
                    runtimeUseState: .needsReview,
                    whereUsed: "Add a pathway when a rule materially matters",
                    updateTargets: [.eligibilityPathway],
                    captureRouteContext: .needsReview,
                    basePath: basePath
                )
            )
        } else {
            let grouped = Dictionary(grouping: pathways, by: { $0.pathwayType })
            let orderedTypes: [LifeContextEligibilityPathwayType] = [.sport, .academic, .career, .creative]

            for type in orderedTypes {
                if let pathway = grouped[type]?.first {
                    rows.append(
                        makeLifeContextFactRow(
                            id: "life-context-eligibility-\(type.rawValue)",
                            title: "\(displayLabel(for: type)) pathway",
                            detail: pathway.eligibilityRulesSummary,
                            sourceLabel: pathway.source.label,
                            freshness: memoryFreshness(for: pathway.freshness),
                            runtimeUseState: pathway.userConfirmed ? .used : .needsReview,
                            whereUsed: pathway.locationDependent ? "Used for route-aware eligibility" : "Used for eligibility checks",
                            updateTargets: [.eligibilityPathway],
                            captureRouteContext: .needsReview,
                            basePath: basePath
                        )
                    )
                } else {
                    rows.append(
                        makeLifeContextFactRow(
                            id: "life-context-eligibility-\(type.rawValue)-missing",
                            title: "\(displayLabel(for: type)) pathway",
                            detail: "Not captured",
                            sourceLabel: "Eligibility pathway",
                            freshness: .basedOnOlderContext,
                            runtimeUseState: .needsReview,
                            whereUsed: "Add when materially relevant",
                            updateTargets: [.eligibilityPathway],
                            captureRouteContext: .needsReview,
                            basePath: basePath
                        )
                    )
                }
            }
        }

        rows.append(
            makeLifeContextFactRow(
                id: "life-context-eligibility-constraints",
                title: "Age / grade / league constraints",
                detail: eligibilityConstraintSummary(for: pathways),
                sourceLabel: "Eligibility pathway",
                freshness: pathways.contains(where: { $0.freshness != .current }) ? .mayNeedReview : (pathways.isEmpty ? .basedOnOlderContext : .current),
                runtimeUseState: pathways.isEmpty ? .needsReview : (pathways.contains(where: { $0.userConfirmed == false }) ? .needsReview : .used),
                whereUsed: "Used before Ambitions assumes a pathway fits",
                updateTargets: [.eligibilityPathway],
                captureRouteContext: .needsReview,
                basePath: basePath
            )
        )

        return rows
    }

}
