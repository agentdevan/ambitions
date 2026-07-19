import Foundation

extension GoalEngineIntakeService {
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


    func normalizeInput(_ rawInput: String) -> String {
        rawInput
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .split(whereSeparator: \.isWhitespace)
            .joined(separator: " ")
    }


    func normalizeTitle(_ rawInput: String) -> String {
        let stripped = rawInput
            .replacingOccurrences(of: #"(?i)^i want to\s+"#, with: "", options: .regularExpression)
            .replacingOccurrences(of: #"(?i)^help me\s+"#, with: "", options: .regularExpression)
            .replacingOccurrences(of: #"(?i)^my goal is to\s+"#, with: "", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !stripped.isEmpty else { return "New goal" }
        let normalized = stripped.hasSuffix(".") ? String(stripped.dropLast()) : stripped
        return normalized.prefix(1).uppercased() + normalized.dropFirst()
    }


    func analyzeSignals(_ normalizedInput: String) -> IntakeSignals {
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


    func inferOwnership(from signals: IntakeSignals) -> ClassifiedValue<ExecutionOwnership> {
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


    func inferMode(from signals: IntakeSignals, ownership: ExecutionOwnership) -> ClassifiedValue<GoalMode> {
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


    func inferTempo(from signals: IntakeSignals, mode: GoalMode) -> ClassifiedValue<GoalTempo> {
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


    func inferRelationship(mode: GoalMode, ownership: ExecutionOwnership) -> ClassifiedValue<GoalRelationshipKind> {
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


    func inferUserRole(ownership: ExecutionOwnership, relationshipKind: GoalRelationshipKind) -> ClassifiedValue<UserExecutionRole> {
        let role: UserExecutionRole = (ownership == .self && relationshipKind == .independent) ? .executor : .plannerSupporter
        return classified(role, confidence: role == .executor ? 0.88 : 0.93, reason: role == .executor ? "The user appears to be doing the work directly." : "The user appears to be supporting or coordinating someone else's execution.")
    }


    func inferStrictDeadlinesAppropriate(tempo: GoalTempo, mode: GoalMode, signals: IntakeSignals) -> ClassifiedValue<Bool> {
        let inappropriate = signals.noDeadlines || tempo == .ongoing || tempo == .untimed || [.learning, .exploration, .maintenance, .recovery, .delegatedSupport].contains(mode)
        return classified(!inappropriate && tempo != .targetWindow, confidence: inappropriate ? 0.9 : 0.8, reason: inappropriate ? "The goal should stay flexible rather than manufactured into deadline pressure." : "This goal can tolerate a more date-anchored plan.")
    }


    func inferPlanningStrategy(mode: GoalMode, tempo: GoalTempo, userRole: UserExecutionRole) -> ClassifiedValue<IntakePlanningStrategyID> {
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


    func inferProgressStrategy(mode: GoalMode, userRole: UserExecutionRole, tempo: GoalTempo) -> ClassifiedValue<IntakeProgressStrategyID> {
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
}
