import Foundation

extension LifeContextBundle {

    func deriveConstraints(from facts: [HistoricalContextFact], isHard: Bool) -> [LifeContextConstraintSummary] {
        var summaries: [LifeContextConstraintSummary] = []

        if isHard {
            if let schoolOrWorkContext = profile.schoolOrWorkContext {
                summaries.append(LifeContextConstraintSummary(
                    id: "profile.school_or_work",
                    title: "School or work context",
                    detail: schoolOrWorkContext,
                    isHardConstraint: true
                ))
            }
            if let travelRadiusMinutes = profile.travelRadiusMinutes {
                summaries.append(LifeContextConstraintSummary(
                    id: "profile.travel_radius_minutes",
                    title: "Travel radius",
                    detail: "\(travelRadiusMinutes) minutes",
                    isHardConstraint: true
                ))
            }
            if profile.dependencyConstraints.isEmpty == false {
                summaries.append(contentsOf: profile.dependencyConstraints.enumerated().map { index, constraint in
                    LifeContextConstraintSummary(
                        id: "profile.dependency.\(index)",
                        title: "Dependency constraint",
                        detail: constraint,
                        isHardConstraint: true
                    )
                })
            }
            if profile.recoveryConstraints.isEmpty == false {
                summaries.append(contentsOf: profile.recoveryConstraints.enumerated().map { index, constraint in
                    LifeContextConstraintSummary(
                        id: "profile.recovery.\(index)",
                        title: "Recovery constraint",
                        detail: constraint,
                        isHardConstraint: true
                    )
                })
            }
            if profile.accessibilityNeeds.isEmpty == false {
                summaries.append(contentsOf: profile.accessibilityNeeds.enumerated().map { index, need in
                    LifeContextConstraintSummary(
                        id: "profile.accessibility.\(index)",
                        title: "Accessibility need",
                        detail: need,
                        isHardConstraint: true
                    )
                })
            }
            summaries.append(contentsOf: facts.flatMap { fact in
                fact.usedFor.contains(.safety) || fact.usedFor.contains(.eligibility) || fact.usedFor.contains(.travel)
                    ? [LifeContextConstraintSummary(
                        id: "fact.\(fact.id)",
                        title: fact.title,
                        detail: fact.detail ?? fact.category.rawValue,
                        isHardConstraint: true
                    )]
                    : []
            })
        } else {
            if let budgetConstraintBand = profile.budgetConstraintBand.displayLabelIfMeaningful {
                summaries.append(LifeContextConstraintSummary(
                    id: "profile.budget",
                    title: "Budget",
                    detail: budgetConstraintBand,
                    isHardConstraint: false
                ))
            }
            if let generalLocationLabel = profile.generalLocationLabel {
                summaries.append(LifeContextConstraintSummary(
                    id: "profile.location",
                    title: "Location",
                    detail: generalLocationLabel,
                    isHardConstraint: false
                ))
            }
            if profile.scheduleAnchors.isEmpty == false {
                summaries.append(contentsOf: profile.scheduleAnchors.enumerated().map { index, anchor in
                    LifeContextConstraintSummary(
                        id: "profile.anchor.\(index)",
                        title: "Schedule anchor",
                        detail: anchor,
                        isHardConstraint: false
                    )
                })
            }
            if let energyPattern = profile.energyPattern.displayLabelIfMeaningful {
                summaries.append(LifeContextConstraintSummary(
                    id: "profile.energy",
                    title: "Energy pattern",
                    detail: energyPattern,
                    isHardConstraint: false
                ))
            }
            summaries.append(contentsOf: facts.flatMap { fact in
                fact.usedFor.contains(.sequencing) || fact.usedFor.contains(.duration) || fact.usedFor.contains(.explanation) || fact.usedFor.contains(.opportunity)
                    ? [LifeContextConstraintSummary(
                        id: "fact.soft.\(fact.id)",
                        title: fact.title,
                        detail: fact.detail ?? fact.category.rawValue,
                        isHardConstraint: false
                    )]
                    : []
            })
        }

        return summaries.sorted { $0.id < $1.id }
    }


    func opportunityDetail(for opportunity: OpportunityContext) -> String {
        var components: [String] = []
        if opportunity.equipmentAccess.isEmpty == false {
            components.append(opportunity.equipmentAccess.joined(separator: ", "))
        }
        if let coachingMentorAccess = opportunity.coachingMentorAccess {
            components.append(coachingMentorAccess)
        }
        if opportunity.localOrganizations.isEmpty == false {
            components.append(opportunity.localOrganizations.joined(separator: ", "))
        }
        if let travelRequirement = opportunity.travelRequirement {
            components.append(travelRequirement)
        }
        if let costRequirement = opportunity.costRequirement {
            components.append(costRequirement)
        }
        if let seasonalAvailability = opportunity.seasonalAvailability {
            components.append(seasonalAvailability)
        }
        if opportunity.eventExposureAccess {
            components.append("event exposure available")
        }
        if opportunity.remoteAccess {
            components.append("remote access available")
        }
        return components.isEmpty ? "Local opportunity anchor" : components.joined(separator: ", ")
    }


    func freshness(for source: LifeContextSource, asOf now: Date) -> LifeContextFreshness {
        guard let sourceDate = DomainTimestamp.date(from: source.timestamp) else {
            return .current
        }

        let days = now.timeIntervalSince(sourceDate) / 86_400
        switch days {
        case ..<90:
            return .current
        case ..<365:
            return .mayNeedReview
        case ..<730:
            return .basedOnOlderContext
        default:
            return .stale
        }
    }


    func missingContextQuestions(ageYears: Int?) -> [LifeContextQuestion] {
        var questions: [LifeContextQuestion] = []

        if ageYears == nil {
            questions.append(LifeContextQuestion(
                id: "missing.age",
                prompt: "What age context should the runtime use?",
                reason: "Age unlocks eligibility and safe-fit reasoning.",
                priority: 0
            ))
        }
        if profile.timezone == nil {
            questions.append(LifeContextQuestion(
                id: "missing.timezone",
                prompt: "Which timezone should the runtime assume?",
                reason: "Timezone keeps time, travel, and scheduling grounded.",
                priority: 1
            ))
        }
        if profile.locale == nil {
            questions.append(LifeContextQuestion(
                id: "missing.locale",
                prompt: "Which locale should the runtime use?",
                reason: "Locale keeps dates and labels readable.",
                priority: 2
            ))
        }
        if profile.lifeStage == .unknown {
            questions.append(LifeContextQuestion(
                id: "missing.life_stage",
                prompt: "Which life stage best describes this context?",
                reason: "Life stage shapes safe opportunity and recovery choices.",
                priority: 3
            ))
        }
        return questions.sorted { $0.priority < $1.priority }
    }


    func displayLabel(for sourceType: HistoricalContextFactSourceType) -> String {
        switch sourceType {
        case .userToldAmbitions:
            return "User confirmed"
        case .imported:
            return "Imported"
        case .inferredFromLocalAction:
            return "Inferred from local action"
        case .correctedByUser:
            return "Corrected by user"
        case .deleted:
            return "Deleted"
        case .paused:
            return "Paused"
        }
    }
}
