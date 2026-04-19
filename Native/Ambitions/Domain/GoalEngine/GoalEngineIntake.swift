import Foundation

private struct IntakeSignals {
    let normalizedLower: String
    let learning: Bool
    let exploration: Bool
    let support: Bool
    let delegationOnly: Bool
    let noDeadlines: Bool
    let recurring: Bool
    let maintenance: Bool
    let recovery: Bool
    let launchProject: Bool
    let childActor: Bool
    let observedOnly: Bool
    let explicitISODate: String?
    let explicitDate: Bool
    let hardDeadline: Bool
    let targetWindow: Bool
    let metaPreferenceOnly: Bool
    let ambiguousSubject: Bool
}

struct GoalEngineIntakeService {
    func buildGoalDraft(from rawInput: String, referenceNow: String? = nil) -> GoalDraftBuildResult {
        let classification = classify(rawInput: rawInput, referenceNow: referenceNow)
        let clarification = GoalClarificationQuestionGenerator().generate(from: classification)
        return GoalDraftBuildResult(classification: classification, clarification: clarification, draft: classification.draft)
    }

    func classify(rawInput: String, referenceNow: String? = nil) -> ClassificationResult {
        let normalizedInput = normalizeInput(rawInput)
        let signals = analyzeSignals(normalizedInput)
        let ownership = inferOwnership(from: signals)
        let mode = inferMode(from: signals, ownership: ownership.value)
        let tempo = inferTempo(from: signals, mode: mode.value)
        let relationshipKind = inferRelationship(mode: mode.value, ownership: ownership.value)
        let userRole = inferUserRole(ownership: ownership.value, relationshipKind: relationshipKind.value)
        let strictDeadlinesAppropriate = inferStrictDeadlinesAppropriate(tempo: tempo.value, mode: mode.value, signals: signals)
        let planningStrategyID = inferPlanningStrategy(mode: mode.value, tempo: tempo.value, userRole: userRole.value)
        let progressStrategyID = inferProgressStrategy(mode: mode.value, userRole: userRole.value, tempo: tempo.value)
        let missingFields = inferMissingFields(normalizedInput: normalizedInput, signals: signals, mode: mode.value, userRole: userRole.value)
        let readiness = inferReadiness(missingFields)
        let actor = createActor(ownership: ownership, userRole: userRole.value, relationshipKind: relationshipKind.value)
        let timing = createTiming(
            tempo: tempo,
            planningStrategyID: planningStrategyID.value,
            isoDate: signals.explicitISODate,
            normalizedLower: signals.normalizedLower,
            referenceNow: referenceNow
        )
        let lifeGraph = inferLifeGraph(
            normalizedLower: signals.normalizedLower,
            mode: mode.value,
            ownership: ownership.value,
            roleLabel: actor.roleLabel
        )

        let draft = GoalDraft(
            schemaVersion: goalEngineSchemaVersion,
            source: .aiSuggested,
            title: normalizeTitle(normalizedInput),
            summary: normalizedInput.count > 24 ? normalizedInput : nil,
            mode: mode.value,
            relationshipKind: relationshipKind.value,
            actor: actor,
            parentGoalID: nil,
            tags: [mode.value.rawValue, planningStrategyID.value.rawValue, progressStrategyID.value.rawValue, readiness.rawValue],
            timing: timing,
            planningStrategy: createPlanningStrategy(id: planningStrategyID.value),
            progressStrategy: createProgressStrategy(id: progressStrategyID.value),
            lifeGraph: lifeGraph
        )

        return ClassificationResult(
            rawInput: rawInput,
            normalizedInput: normalizedInput,
            title: draft.title,
            summary: draft.summary,
            mode: mode,
            tempo: tempo,
            relationshipKind: relationshipKind,
            executionOwnership: ownership,
            userRole: userRole,
            strictDeadlinesAppropriate: strictDeadlinesAppropriate,
            planningStrategyID: planningStrategyID,
            progressStrategyID: progressStrategyID,
            readiness: readiness,
            clarificationNeeded: readiness != .readyForPlanning,
            starterPlanSafe: readiness != .needsClarification,
            missingFields: missingFields,
            tags: draft.tags,
            draft: draft
        )
    }

    private func normalizeInput(_ rawInput: String) -> String {
        rawInput
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .split(whereSeparator: \.isWhitespace)
            .joined(separator: " ")
    }

    private func normalizeTitle(_ rawInput: String) -> String {
        let stripped = rawInput
            .replacingOccurrences(of: #"(?i)^i want to\s+"#, with: "", options: .regularExpression)
            .replacingOccurrences(of: #"(?i)^help me\s+"#, with: "", options: .regularExpression)
            .replacingOccurrences(of: #"(?i)^my goal is to\s+"#, with: "", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !stripped.isEmpty else { return "New goal" }
        let normalized = stripped.hasSuffix(".") ? String(stripped.dropLast()) : stripped
        return normalized.prefix(1).uppercased() + normalized.dropFirst()
    }

    private func analyzeSignals(_ normalizedInput: String) -> IntakeSignals {
        let lower = normalizedInput.lowercased()

        func matches(_ pattern: String) -> Bool {
            lower.range(of: pattern, options: .regularExpression) != nil
        }

        let learning = matches(#"\blearn\b|\bpractice\b|\bstudy\b|\bhow to\b|\bunderstand\b"#)
        let exploration = matches(#"\bfigure out if\b|\bdecide whether\b|\bexplore\b|\bsee if\b"#)
        let support = matches(#"\bhelp\b|\bsupport\b|\bfor someone else\b|\bfor my\b"#)
        let delegationOnly = matches(#"\bsomeone else\b|\bplan this for someone else\b|\bbreak this down for someone else\b"#)
        let noDeadlines = matches(#"\bno deadlines\b|\bdon'?t want deadlines\b|\bwithout deadlines\b"#)
        let recurring = matches(#"\bdaily\b|\bweekly\b|\bongoing\b|\bevery\b"#)
        let maintenance = matches(#"\bmaintain\b|\bkeep\b|\bstay on top of\b"#)
        let recovery = matches(#"\brecover\b|\bstabilize\b|\bfeel better\b|\breset\b|\bget healthier\b|\bhealthier\b"#)
        let launchProject = matches(#"\blaunch\b|\bbuild\b|\bship\b|\bpublish\b|\bstart\b"#)
        let childActor = matches(#"\bdaughter\b|\bson\b|\bchild\b|\bkid\b"#)
        let observedOnly = matches(#"\btrack\b|\bobserve\b|\bkeep tabs\b"#)
        let explicitISODate = firstMatch(in: lower, pattern: #"\b\d{4}-\d{2}-\d{2}\b"#)
        let explicitDate = explicitISODate != nil || matches(#"\bthis week\b|\bthis month\b|\bthis quarter\b|\bthis year\b|\bnext month\b|\bthis summer\b|\bthis fall\b|\bbefore\b|\bby [a-z]+\b"#)
        let hardDeadline = explicitISODate != nil || matches(#"\bdeadline\b|\bdue\b|\bmust\b|\bno later than\b"#)
        let targetWindow = explicitDate && !hardDeadline
        let goalSignalsPresent = learning || exploration || support || recurring || maintenance || recovery || launchProject
        let metaPreferenceOnly = (noDeadlines || recurring) && !goalSignalsPresent
        let ambiguousSubject = matches(#"\b(do this|this|it)\b"#) && !launchProject && !learning && !exploration && !recovery

        return IntakeSignals(
            normalizedLower: lower,
            learning: learning,
            exploration: exploration,
            support: support,
            delegationOnly: delegationOnly,
            noDeadlines: noDeadlines,
            recurring: recurring,
            maintenance: maintenance,
            recovery: recovery,
            launchProject: launchProject,
            childActor: childActor,
            observedOnly: observedOnly,
            explicitISODate: explicitISODate,
            explicitDate: explicitDate,
            hardDeadline: hardDeadline,
            targetWindow: targetWindow,
            metaPreferenceOnly: metaPreferenceOnly,
            ambiguousSubject: ambiguousSubject
        )
    }

    private func inferOwnership(from signals: IntakeSignals) -> ClassifiedValue<ExecutionOwnership> {
        if signals.childActor {
            return classified(.child, confidence: 0.95, reason: "Family-language points to a child as the active owner.")
        }
        if signals.delegationOnly {
            return classified(.delegated, confidence: 0.92, reason: "The input explicitly describes planning for someone else.")
        }
        if signals.support {
            return classified(.support, confidence: 0.84, reason: "Support language suggests the user is enabling work rather than directly owning it.")
        }
        if signals.observedOnly {
            return classified(.observedOnly, confidence: 0.78, reason: "Observation language suggests tracking without direct execution.")
        }
        return classified(.self, confidence: 0.88, reason: "No external owner was mentioned, so self execution is the safest default.")
    }

    private func inferMode(from signals: IntakeSignals, ownership: ExecutionOwnership) -> ClassifiedValue<GoalMode> {
        if ownership != .self && (signals.support || signals.delegationOnly || signals.childActor) {
            return classified(.delegatedSupport, confidence: 0.95, reason: "Helping or planning for another person is support-oriented work.")
        }
        if signals.exploration {
            return classified(.exploration, confidence: 0.92, reason: "The language emphasizes discovery and fit rather than committed execution.")
        }
        if signals.learning {
            return classified(.learning, confidence: 0.92, reason: "The goal centers on skill-building or understanding.")
        }
        if signals.maintenance || signals.recurring {
            return classified(.maintenance, confidence: 0.86, reason: "Recurring or upkeep language fits a maintenance cadence.")
        }
        if signals.recovery {
            return classified(.recovery, confidence: 0.82, reason: "Broad health or stabilization language is safer as recovery than as a hard outcome.")
        }
        if signals.launchProject {
            return classified(.project, confidence: 0.9, reason: "Launch/build language usually implies multi-step project coordination.")
        }
        return classified(.achievement, confidence: 0.68, reason: "The input points at an outcome but not a stronger specialized mode.")
    }

    private func inferTempo(from signals: IntakeSignals, mode: GoalMode) -> ClassifiedValue<GoalTempo> {
        if signals.noDeadlines {
            return classified(signals.recurring ? .ongoing : .untimed, confidence: 0.97, reason: "The user explicitly asked to avoid deadline pressure.")
        }
        if signals.recurring || mode == .maintenance || mode == .delegatedSupport {
            return classified(.ongoing, confidence: 0.86, reason: "Recurring, maintenance, and support flows are safer as ongoing work.")
        }
        if signals.hardDeadline {
            return classified(.deadlineBased, confidence: 0.9, reason: "A concrete due signal should anchor planning.")
        }
        if signals.targetWindow {
            return classified(.targetWindow, confidence: 0.8, reason: "Relative timing language suggests a target window rather than a strict deadline.")
        }
        if mode == .learning || mode == .exploration || mode == .recovery {
            return classified(.untimed, confidence: 0.84, reason: "Learning, exploration, and recovery should stay flexible unless the user asks otherwise.")
        }
        return classified(.untimed, confidence: 0.66, reason: "No reliable timing constraint was supplied.")
    }

    private func inferRelationship(mode: GoalMode, ownership: ExecutionOwnership) -> ClassifiedValue<GoalRelationshipKind> {
        if mode == .delegatedSupport {
            switch ownership {
            case .delegated, .observedOnly:
                return classified(.delegated, confidence: 0.92, reason: "The user is planning around another person's execution.")
            case .child:
                return classified(.child, confidence: 0.94, reason: "The support relationship is explicitly about a child.")
            case .support:
                return classified(.support, confidence: 0.9, reason: "This reads as a support relationship rather than an independent goal.")
            case .self:
                return classified(.independent, confidence: 0.6, reason: "Support mode without a non-self owner falls back to independent.")
            }
        }
        return classified(.independent, confidence: 0.9, reason: "No relationship signal requires a parent/support linkage.")
    }

    private func inferUserRole(ownership: ExecutionOwnership, relationshipKind: GoalRelationshipKind) -> ClassifiedValue<UserExecutionRole> {
        let role: UserExecutionRole = (ownership == .self && relationshipKind == .independent) ? .executor : .plannerSupporter
        return classified(role, confidence: role == .executor ? 0.88 : 0.93, reason: role == .executor ? "The user appears to be doing the work directly." : "The user appears to be supporting or coordinating someone else's execution.")
    }

    private func inferStrictDeadlinesAppropriate(tempo: GoalTempo, mode: GoalMode, signals: IntakeSignals) -> ClassifiedValue<Bool> {
        let inappropriate = signals.noDeadlines || tempo == .ongoing || tempo == .untimed || [.learning, .exploration, .maintenance, .recovery, .delegatedSupport].contains(mode)
        return classified(!inappropriate && tempo != .targetWindow, confidence: inappropriate ? 0.9 : 0.8, reason: inappropriate ? "The goal should stay flexible rather than manufactured into deadline pressure." : "This goal can tolerate a more date-anchored plan.")
    }

    private func inferPlanningStrategy(mode: GoalMode, tempo: GoalTempo, userRole: UserExecutionRole) -> ClassifiedValue<IntakePlanningStrategyID> {
        if userRole == .plannerSupporter || mode == .delegatedSupport {
            return classified(.guidedSupport, confidence: 0.95, reason: "Support work should guide without taking ownership away from the executor.")
        }
        switch mode {
        case .learning:
            return classified(.learningPath, confidence: 0.94, reason: "Learning goals need checkpoints, resources, and reflection.")
        case .exploration:
            return classified(.discoveryMap, confidence: 0.94, reason: "Exploration benefits from experiments instead of straight-line execution.")
        case .maintenance, .habit:
            return classified(.routineBuilder, confidence: 0.9, reason: "Maintenance work needs a repeatable cadence.")
        case .recovery:
            return classified(.stabilizationPath, confidence: 0.84, reason: "Recovery work should stabilize first and expand later.")
        case .project, .achievement:
            return classified(tempo == .untimed ? .lightweightTracking : .milestonePlan, confidence: 0.82, reason: tempo == .untimed ? "Untimed delivery goals should start with a safer, lighter plan." : "Milestones fit delivery-oriented work with timing pressure.")
        case .delegatedSupport:
            return classified(.guidedSupport, confidence: 0.95, reason: "Delegated/supportive goals need support framing.")
        }
    }

    private func inferProgressStrategy(mode: GoalMode, userRole: UserExecutionRole, tempo: GoalTempo) -> ClassifiedValue<IntakeProgressStrategyID> {
        if userRole == .plannerSupporter || mode == .delegatedSupport {
            return classified(.delegatedSupport, confidence: 0.95, reason: "Support scenarios should track support actions and updates, not pretend direct execution.")
        }
        switch mode {
        case .learning:
            return classified(.learning, confidence: 0.92, reason: "Learning progress is better measured by evidence and checkpoints.")
        case .exploration:
            return classified(.exploration, confidence: 0.92, reason: "Exploration should reward observations and experiments.")
        case .maintenance, .habit:
            return classified(.maintenance, confidence: 0.9, reason: "Maintenance progress is consistency-oriented.")
        case .recovery:
            return classified(.observationalProgress, confidence: 0.86, reason: "Recovery progress should stay observational and non-punitive.")
        case .project, .achievement:
            return classified(tempo == .deadlineBased || tempo == .targetWindow ? .timedExecution : .untimedGrowth, confidence: 0.84, reason: tempo == .deadlineBased || tempo == .targetWindow ? "Timed delivery work can be tracked against visible steps." : "Untimed growth work should show progress without fake urgency.")
        case .delegatedSupport:
            return classified(.delegatedSupport, confidence: 0.95, reason: "Support flows need support-oriented progress tracking.")
        }
    }

    private func inferMissingFields(normalizedInput: String, signals: IntakeSignals, mode: GoalMode, userRole: UserExecutionRole) -> [MissingField] {
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

    private func inferReadiness(_ missingFields: [MissingField]) -> PlanningReadiness {
        if missingFields.contains(where: \.blocksPlanning) {
            return .needsClarification
        }
        return missingFields.isEmpty ? .readyForPlanning : .canPlanWithDefaults
    }

    private func createActor(ownership: ClassifiedValue<ExecutionOwnership>, userRole: UserExecutionRole, relationshipKind: GoalRelationshipKind) -> GoalActor {
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

    private func createTiming(tempo: ClassifiedValue<GoalTempo>, planningStrategyID: IntakePlanningStrategyID, isoDate: String?, normalizedLower: String, referenceNow: String?) -> GoalTiming {
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

    private func inferLifeGraph(
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

        if ownership != .self, let roleLabel {
            roles.append(LifeRole(kind: .supporting, title: roleLabel))
        }

        guard domains.isEmpty == false || roles.isEmpty == false || path != nil else {
            return nil
        }

        return LifeGraphContext(
            domains: domains,
            roles: roles,
            path: path,
            stages: stages,
            prerequisites: prerequisites,
            milestones: milestones
        )
    }

    private func matches(_ text: String, pattern: String) -> Bool {
        text.range(of: pattern, options: .regularExpression) != nil
    }

    private func createPlanningStrategy(id: IntakePlanningStrategyID) -> PlanningStrategy {
        switch id {
        case .routineBuilder:
            return PlanningStrategy(strategyKind: .cadence, allowParallelSteps: true, maxActiveSteps: 3, preferredSectionOrder: [.overview, .activeSteps, .review], defaultStepType: .recurringRoutine, autoGenerateReviewSection: true, preferShortSteps: true, revisitCadenceDays: 7)
        case .learningPath:
            return PlanningStrategy(strategyKind: .adaptive, allowParallelSteps: true, maxActiveSteps: 4, preferredSectionOrder: [.overview, .activeSteps, .resources, .review], defaultStepType: .learningCheckpoint, autoGenerateReviewSection: true, preferShortSteps: true, revisitCadenceDays: 7)
        case .discoveryMap:
            return PlanningStrategy(strategyKind: .exploratory, allowParallelSteps: true, maxActiveSteps: 4, preferredSectionOrder: [.overview, .activeSteps, .supportingWork, .review], defaultStepType: .explorationExperiment, autoGenerateReviewSection: true, preferShortSteps: true, revisitCadenceDays: 5)
        case .stabilizationPath:
            return PlanningStrategy(strategyKind: .adaptive, allowParallelSteps: false, maxActiveSteps: 2, preferredSectionOrder: [.overview, .activeSteps, .review], defaultStepType: .observationPrompt, autoGenerateReviewSection: true, preferShortSteps: true, revisitCadenceDays: 4)
        case .guidedSupport:
            return PlanningStrategy(strategyKind: .supportive, allowParallelSteps: true, maxActiveSteps: 3, preferredSectionOrder: [.supportingWork, .activeSteps, .review], defaultStepType: .supportAction, autoGenerateReviewSection: true, preferShortSteps: true, revisitCadenceDays: 7)
        case .lightweightTracking:
            return PlanningStrategy(strategyKind: .adaptive, allowParallelSteps: true, maxActiveSteps: 2, preferredSectionOrder: [.overview, .activeSteps, .review], defaultStepType: .reflectionPrompt, autoGenerateReviewSection: true, preferShortSteps: true, revisitCadenceDays: 7)
        case .milestonePlan:
            return PlanningStrategy(strategyKind: .sequential, allowParallelSteps: true, maxActiveSteps: 4, preferredSectionOrder: [.overview, .activeSteps, .upcoming, .review], defaultStepType: .actionUnit, autoGenerateReviewSection: true, preferShortSteps: false, revisitCadenceDays: 7)
        }
    }

    private func createProgressStrategy(id: IntakeProgressStrategyID) -> ProgressStrategy {
        switch id {
        case .learning:
            return ProgressStrategy(metricKind: .evidenceCount, rollupMethod: .weightedRatio, targetStepCount: 4, targetEvidenceCount: 8, targetMinutes: 240, supportsUntimedProgress: true, countsChildGoals: false, countsSupportGoals: false)
        case .exploration:
            return ProgressStrategy(metricKind: .observationLog, rollupMethod: .sum, targetStepCount: 4, targetEvidenceCount: 5, targetMinutes: nil, supportsUntimedProgress: true, countsChildGoals: false, countsSupportGoals: false)
        case .maintenance:
            return ProgressStrategy(metricKind: .streak, rollupMethod: .streakLength, targetStepCount: nil, targetEvidenceCount: 5, targetMinutes: nil, supportsUntimedProgress: true, countsChildGoals: false, countsSupportGoals: false)
        case .delegatedSupport:
            return ProgressStrategy(metricKind: .evidenceCount, rollupMethod: .latest, targetStepCount: 3, targetEvidenceCount: 4, targetMinutes: nil, supportsUntimedProgress: true, countsChildGoals: true, countsSupportGoals: true)
        case .observationalProgress:
            return ProgressStrategy(metricKind: .confidenceGain, rollupMethod: .latest, targetStepCount: 3, targetEvidenceCount: 6, targetMinutes: nil, supportsUntimedProgress: true, countsChildGoals: false, countsSupportGoals: true)
        case .timedExecution:
            return ProgressStrategy(metricKind: .stepCompletion, rollupMethod: .ratio, targetStepCount: 5, targetEvidenceCount: nil, targetMinutes: 300, supportsUntimedProgress: false, countsChildGoals: true, countsSupportGoals: true)
        case .untimedGrowth:
            return ProgressStrategy(metricKind: .timeInvested, rollupMethod: .ratio, targetStepCount: 4, targetEvidenceCount: nil, targetMinutes: 240, supportsUntimedProgress: true, countsChildGoals: false, countsSupportGoals: false)
        }
    }

    private func classified<Value: Codable & Sendable & Equatable>(_ value: Value, confidence: Double, reason: String) -> ClassifiedValue<Value> {
        let bounded = max(0, min(1, confidence))
        let label: ClassificationConfidence = bounded >= 0.8 ? .high : (bounded >= 0.55 ? .medium : .low)
        return ClassifiedValue(value: value, metadata: InferenceMetadata(source: .derivedContract, inferred: true, confidence: bounded, label: label, reason: reason))
    }

    private func firstMatch(in text: String, pattern: String) -> String? {
        guard let range = text.range(of: pattern, options: .regularExpression) else { return nil }
        return String(text[range])
    }

    private func deriveWindow(from text: String, referenceNow: String?) -> (start: String, end: String)? {
        let year = referenceYear(from: referenceNow)
        if text.contains("this summer") { return ("\(year)-06-01", "\(year)-08-31") }
        if text.contains("this fall") { return ("\(year)-09-01", "\(year)-11-30") }
        if text.contains("this quarter") { return ("\(year)-04-01", "\(year)-06-30") }
        if text.contains("this month") { return ("\(year)-04-01", "\(year)-04-30") }
        if text.contains("this week") { return ("\(year)-04-14", "\(year)-04-20") }
        return nil
    }

    private func referenceYear(from referenceNow: String?) -> Int {
        guard let referenceNow, let date = ISO8601DateFormatter().date(from: referenceNow) else {
            return Calendar(identifier: .gregorian).component(.year, from: Date())
        }
        return Calendar(identifier: .gregorian).component(.year, from: date)
    }
}

struct GoalClarificationQuestionGenerator {
    func generate(from result: ClassificationResult) -> ClarificationSet {
        var questions: [ClarificationQuestion] = []

        for missing in result.missingFields where questions.count < 3 {
            switch missing.field {
            case .goalSubject:
                questions.append(ClarificationQuestion(id: "goal-subject", field: .goalSubject, prompt: "What is the actual goal you want planned?", rationale: "The engine cannot safely decompose a preference-only or placeholder input.", skipSafeDefault: "No starter plan is created until the subject is explicit."))
            case .executorIdentity:
                questions.append(ClarificationQuestion(id: "executor-identity", field: .executorIdentity, prompt: "Who is actually doing the work this plan is for?", rationale: "Delegated plans should not use self-execution language for someone else's work.", skipSafeDefault: "The app waits rather than inventing an executor."))
            case .supportScope:
                questions.append(ClarificationQuestion(id: "support-scope", field: .supportScope, prompt: "Are you supporting them, coaching them, or mostly tracking progress?", rationale: "That choice changes step tone and what counts as progress.", skipSafeDefault: "The starter plan assumes light, non-punitive support."))
            case .successDefinition:
                questions.append(ClarificationQuestion(id: "success-definition", field: .successDefinition, prompt: "What would count as a good first version of this goal?", rationale: "A first success signal sharpens planning without forcing urgency.", skipSafeDefault: "The starter plan stays intentionally broad."))
            case .goalShape:
                questions.append(ClarificationQuestion(id: "goal-shape", field: .goalShape, prompt: "Should this behave more like stabilization or a concrete result?", rationale: "Recovery-style goals can get over-structured too early without that choice.", skipSafeDefault: "The starter plan stays stabilization-oriented."))
            case .timeHorizon:
                questions.append(ClarificationQuestion(id: "time-horizon", field: .timeHorizon, prompt: "Do you want a rough horizon for this, or should the first plan stay untimed?", rationale: "A horizon helps sequencing only if the user actually wants one.", skipSafeDefault: "The starter plan stays untimed."))
            }
        }

        return ClarificationSet(readiness: result.readiness, questions: questions, missingFields: result.missingFields)
    }
}
