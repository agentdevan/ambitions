import Foundation

extension GoalEngineIntakeService {

    func inferMissingFields(normalizedInput: String, signals: IntakeSignals, mode: GoalMode, userRole: UserExecutionRole) -> [MissingField] {
        var missing: [MissingField] = []

        if normalizedInput.isEmpty || signals.metaPreferenceOnly || signals.ambiguousSubject || normalizedInput.lowercased().contains("i don't know where to start") {
            missing.append(MissingField(field: .goalSubject, reason: "The input does not give a concrete goal subject the engine can safely decompose.", blocksPlanning: true))
        }

        if missing.contains(where: { $0.field == .goalSubject }) {
            if userRole == .plannerSupporter && signals.delegationOnly {
                missing.append(MissingField(field: .executorIdentity, reason: "A delegated plan needs to know who is actually doing the work.", blocksPlanning: true))
            }
            return missing
        }

        if userRole == .plannerSupporter && signals.delegationOnly {
            missing.append(MissingField(field: .executorIdentity, reason: "A delegated plan needs the executor identity before decomposition starts.", blocksPlanning: true))
        }

        if userRole == .plannerSupporter && !signals.delegationOnly && !signals.childActor {
            missing.append(MissingField(field: .supportScope, reason: "Clarifying whether the user is supporting, coaching, or observing improves language and step framing.", blocksPlanning: false))
        }

        if [.project, .achievement, .recovery].contains(mode) && !signals.explicitDate {
            missing.append(MissingField(field: .successDefinition, reason: "A first success signal would sharpen planning without forcing a deadline.", blocksPlanning: false))
        }

        if mode == .recovery {
            missing.append(MissingField(field: .goalShape, reason: "Recovery goals benefit from knowing whether the user wants stabilization or a concrete result.", blocksPlanning: false))
        }

        if [.project, .achievement].contains(mode) && !signals.explicitDate && !signals.noDeadlines {
            missing.append(MissingField(field: .timeHorizon, reason: "A rough horizon helps sequencing, but only if the user wants one.", blocksPlanning: false))
        }

        return missing
    }


    func inferReadiness(_ missingFields: [MissingField]) -> PlanningReadiness {
        if missingFields.contains(where: \.blocksPlanning) {
            return .needsClarification
        }
        return missingFields.isEmpty ? .readyForPlanning : .canPlanWithDefaults
    }


    func createActor(ownership: ClassifiedValue<ExecutionOwnership>, userRole: UserExecutionRole, relationshipKind: GoalRelationshipKind) -> GoalActor {
        let displayName: String
        switch ownership.value {
        case .self:
            displayName = "You"
        case .delegated:
            displayName = "Delegated owner"
        case .child:
            displayName = "Child"
        case .support:
            displayName = "Supported person"
        case .observedOnly:
            displayName = "Observed owner"
        }

        let roleLabel: String?
        if userRole == .plannerSupporter {
            switch relationshipKind {
            case .child:
                roleLabel = "Supported child"
            case .support:
                roleLabel = "Supported person"
            case .delegated:
                roleLabel = "Delegated executor"
            case .independent:
                roleLabel = "Primary owner"
            }
        } else {
            roleLabel = "Primary owner"
        }

        return GoalActor(actorID: ownership.value.rawValue, displayName: displayName, ownership: ownership.value, roleLabel: roleLabel, isPrimary: true)
    }


    func createTiming(tempo: ClassifiedValue<GoalTempo>, planningStrategyID: IntakePlanningStrategyID, isoDate: String?, normalizedLower: String, referenceNow: String?) -> GoalTiming {
        let reviewCadence = planningStrategyID == .discoveryMap ? 5 : (planningStrategyID == .stabilizationPath ? 4 : 7)
        switch tempo.value {
        case .deadlineBased:
            return GoalTiming(tempo: .deadlineBased, timingType: .dueAt, startsOn: nil, dueAt: isoDate.map { "\($0)T17:00:00Z" }, targetBy: nil, windowStart: nil, windowEnd: nil, suggestedNextAt: nil, repeatEveryDays: nil, progressReviewCadenceDays: reviewCadence)
        case .targetWindow:
            let window = deriveWindow(from: normalizedLower, referenceNow: referenceNow)
            return GoalTiming(tempo: .targetWindow, timingType: .targetBy, startsOn: nil, dueAt: nil, targetBy: isoDate ?? window?.end, windowStart: window?.start, windowEnd: window?.end, suggestedNextAt: nil, repeatEveryDays: nil, progressReviewCadenceDays: reviewCadence)
        case .ongoing:
            return GoalTiming(tempo: .ongoing, timingType: .repeatWithinWindow, startsOn: nil, dueAt: nil, targetBy: nil, windowStart: nil, windowEnd: nil, suggestedNextAt: nil, repeatEveryDays: 7, progressReviewCadenceDays: reviewCadence)
        case .untimed:
            return GoalTiming(tempo: .untimed, timingType: .logWhenDone, startsOn: nil, dueAt: nil, targetBy: nil, windowStart: nil, windowEnd: nil, suggestedNextAt: nil, repeatEveryDays: nil, progressReviewCadenceDays: reviewCadence)
        }
    }


    func inferLifeGraph(
        normalizedLower: String,
        mode: GoalMode,
        ownership: ExecutionOwnership,
        roleLabel: String?
    ) -> LifeGraphContext? {
        var domains: [LifeDomainAssignment] = []
        var roles: [LifeRole] = []
        var path: LifePathDescriptor?
        var stages: [LifePathStage] = []
        var prerequisites: [LifePathPrerequisite] = []
        var milestones: [LifeGraphMilestone] = []
        var sharedParticipants: [SharedLifeParticipant] = []
        var sharedResponsibilities: [SharedResponsibility] = []
        var careSummary: String?

        if normalizedLower.contains("astronaut") {
            domains = [LifeDomainAssignment(domain: .career)]
            path = LifePathDescriptor(kind: .careerTrack, title: "Astronaut path")
            roles = [LifeRole(kind: .aspirational, title: "Astronaut candidate")]
            stages = [
                LifePathStage(id: "foundation", title: "Foundation", summary: "Build the academic and physical baseline first.", orderIndex: 0, readinessSignals: [
                    LifePathSignal(id: "foundation-evidence", title: "Core STEM baseline", summary: "A visible academic baseline helps keep the path believable.", kind: .evidence),
                    LifePathSignal(id: "foundation-gap", title: "Training rhythm still forming", summary: "A sustainable study and training cadence is still missing.", kind: .readiness, isGap: true)
                ]),
                LifePathStage(id: "qualification", title: "Qualification", summary: "Accumulate qualifying experience and decision-ready evidence.", orderIndex: 1, readinessSignals: [
                    LifePathSignal(id: "qualification-experience", title: "Relevant experience", summary: "The path needs visible experience signals, not just intent.", kind: .experience, isGap: true)
                ]),
                LifePathStage(id: "application", title: "Application readiness", summary: "Treat the application as a final stage, not the starting point.", orderIndex: 2, readinessSignals: [
                    LifePathSignal(id: "application-window", title: "Application window awareness", summary: "The application stage needs a real window and materials ready.", kind: .applicationWindow)
                ])
            ]
            milestones = [
                LifeGraphMilestone(id: "degree", title: "Complete a qualifying degree", summary: "Finish the academic foundation required for the path.", stageID: "foundation"),
                LifeGraphMilestone(id: "flight-or-equivalent", title: "Build qualifying experience", summary: "Accumulate relevant operational or research experience.", stageID: "qualification", dependencyIDs: ["degree"]),
                LifeGraphMilestone(id: "application-ready", title: "Prepare the application package", summary: "Turn the path into a real application-ready package.", stageID: "application", dependencyIDs: ["flight-or-equivalent"])
            ]
            prerequisites = [
                LifePathPrerequisite(id: "qualification-needs-foundation", title: "Qualification depends on the foundation stage", summary: "Do not treat late-stage qualification work like the first move.", kind: .stage, stageID: "qualification", requiredStageID: "foundation"),
                LifePathPrerequisite(id: "application-needs-experience", title: "Application readiness depends on qualifying experience", summary: "The application stage should stay blocked until the qualifying milestone is real.", kind: .milestone, stageID: "application", requiredMilestoneID: "flight-or-equivalent")
            ]
        } else if matches(normalizedLower, pattern: #"\bcareer\b|\bjob\b|\bpromotion\b|\bbusiness\b|\bcompany\b|\bfreelance\b"#) {
            domains = [LifeDomainAssignment(domain: .career)]
            if mode == .project || mode == .achievement {
                path = LifePathDescriptor(kind: .careerTrack, title: "Career path")
            }
        } else if matches(normalizedLower, pattern: #"\bdegree\b|\bschool\b|\bcourse\b|\bcertification\b"#) {
            domains = [LifeDomainAssignment(domain: .education)]
            path = LifePathDescriptor(kind: .educationTrack, title: "Education path")
            if matches(normalizedLower, pattern: #"\bdegree\b|\bcertification\b"#) {
                stages = [
                    LifePathStage(id: "preparation", title: "Preparation", summary: "Clarify the program and entry constraints first.", orderIndex: 0, readinessSignals: [
                        LifePathSignal(id: "prep-readiness", title: "Entry requirements clarified", summary: "The program requirements should be explicit before committing the full path.", kind: .readiness, isGap: true)
                    ]),
                    LifePathStage(id: "coursework", title: "Coursework", summary: "Move through the core learning and requirement load.", orderIndex: 1),
                    LifePathStage(id: "completion", title: "Completion", summary: "Finish assessments and close the path cleanly.", orderIndex: 2, readinessSignals: [
                        LifePathSignal(id: "completion-evidence", title: "Completion evidence", summary: "The final stage needs visible completion evidence.", kind: .evidence)
                    ])
                ]
                milestones = [
                    LifeGraphMilestone(id: "entry-requirements", title: "Clarify entry requirements", summary: "Make the entry constraints explicit.", stageID: "preparation"),
                    LifeGraphMilestone(id: "core-coursework", title: "Finish the core coursework", summary: "Complete the main program requirements.", stageID: "coursework", dependencyIDs: ["entry-requirements"]),
                    LifeGraphMilestone(id: "final-assessment", title: "Complete the final assessment", summary: "Close the program with the final assessment or review.", stageID: "completion", dependencyIDs: ["core-coursework"])
                ]
                prerequisites = [
                    LifePathPrerequisite(id: "coursework-needs-prep", title: "Coursework depends on clarified entry requirements", kind: .milestone, stageID: "coursework", requiredMilestoneID: "entry-requirements"),
                    LifePathPrerequisite(id: "completion-needs-coursework", title: "Completion depends on core coursework", kind: .milestone, stageID: "completion", requiredMilestoneID: "core-coursework")
                ]
            }
        } else if matches(normalizedLower, pattern: #"\bhealth\b|\bfitness\b|\bexercise\b|\bsleep\b|\brecovery\b"#) {
            domains = [LifeDomainAssignment(domain: .health)]
        } else if matches(normalizedLower, pattern: #"\bdebt\b|\bbudget\b|\bsave money\b|\bfinance\b"#) {
            domains = [LifeDomainAssignment(domain: .finance)]
        }

        if matches(normalizedLower, pattern: #"\bpartner\b|\bspouse\b|\bwife\b|\bhusband\b"#) {
            if domains.isEmpty {
                domains = [LifeDomainAssignment(domain: .relationships)]
            }
            sharedParticipants.append(
                SharedLifeParticipant(
                    id: "partner",
                    displayName: "Partner",
                    relationshipKind: .partner,
                    roleLabel: "Partner"
                )
            )
        }
        if matches(normalizedLower, pattern: #"\bdaughter\b|\bson\b|\bchild\b|\bkid\b"#) {
            sharedParticipants.append(
                SharedLifeParticipant(
                    id: "child",
                    displayName: "Child",
                    relationshipKind: .child,
                    roleLabel: "Child"
                )
            )
            sharedResponsibilities.append(
                SharedResponsibility(
                    id: "care-support",
                    title: "Care support",
                    summary: "Keep the support path calm and visible.",
                    kind: .care,
                    participantID: "child"
                )
            )
            careSummary = "Child-related care support is part of the goal context."
        }
        if matches(normalizedLower, pattern: #"\bhousehold\b|\bhome\b|\bgrocery\b|\bchores\b|\bpickup\b|\bdrop off\b"#) {
            if domains.contains(where: { $0.domain == .home }) == false {
                domains.append(LifeDomainAssignment(domain: .home, priority: 0.9))
            }
            sharedResponsibilities.append(
                SharedResponsibility(
                    id: "household-logistics",
                    title: "Household logistics",
                    summary: "Keep the coordination load visible without turning it into admin.",
                    kind: .household
                )
            )
        }
        if matches(normalizedLower, pattern: #"\bappointment\b|\bdoctor\b|\bdentist\b|\bmeeting\b|\bpickup\b|\bdropoff\b|\bschedule\b"#) {
            sharedResponsibilities.append(
                SharedResponsibility(
                    id: "shared-appointment",
                    title: "Shared timing",
                    summary: "A shared timing commitment needs calm coordination.",
                    kind: .appointment,
                    coordination: SharedCoordinationContext(
                        kind: .appointment,
                        title: "Shared timing",
                        summary: "Use the current goal timing to keep coordination visible."
                    )
                )
            )
        }

        if ownership != .self, let roleLabel {
            roles.append(LifeRole(kind: .supporting, title: roleLabel))
        }

        let sharedLife: SharedLifeContext? = (sharedParticipants.isEmpty == false || sharedResponsibilities.isEmpty == false || careSummary != nil)
            ? SharedLifeContext(
                participants: sharedParticipants,
                responsibilities: sharedResponsibilities,
                householdName: domains.contains(where: { $0.domain == .home }) ? "Household" : nil,
                careSummary: careSummary
            )
            : nil

        guard domains.isEmpty == false || roles.isEmpty == false || path != nil || sharedLife != nil else {
            return nil
        }

        return LifeGraphContext(
            domains: domains,
            roles: roles,
            path: path,
            stages: stages,
            prerequisites: prerequisites,
            milestones: milestones,
            sharedLife: sharedLife
        )
    }


    func matches(_ text: String, pattern: String) -> Bool {
        text.range(of: pattern, options: .regularExpression) != nil
    }
}
