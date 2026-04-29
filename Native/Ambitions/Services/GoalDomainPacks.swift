import Foundation

enum GoalDomainPackDefaults {
    static let all: [any GoalDomainPack] = [
        CareerGoalDomainPack(),
        EducationGoalDomainPack(),
        BroadGoalDomainPack.creativeProject,
        BroadGoalDomainPack.health,
        BroadGoalDomainPack.finance,
        BroadGoalDomainPack.relationship,
        BroadGoalDomainPack.homeAndLifeAdmin
    ]
}

struct CareerGoalDomainPack: GoalDomainPack {
    let descriptor = GoalDomainPackDescriptor(
        id: "career",
        displayName: "Career Pack",
        coveredDomains: [.career],
        supportedModes: [.achievement, .project, .learning, .exploration]
    )

    func match(understanding: GoalUnderstanding) -> GoalDomainPackMatch? {
        guard understanding.domains.all.contains(where: { $0.domain == .career }) else { return nil }

        var reasons = ["Career domain present in goal understanding."]
        if understanding.mode.goalMode == .learning {
            reasons.append("Learning mode still fits career preparation work.")
        }

        return GoalDomainPackMatch(
            packID: descriptor.id,
            confidenceScore: understanding.domains.primary == .career ? 0.9 : 0.7,
            matchedDomains: understanding.domains.all.map(\.domain).filter { $0 == .career },
            reasons: reasons,
            provisional: understanding.mode.remainsProvisional || understanding.clarification.alternateInterpretationsActive
        )
    }

    func contribute(understanding: GoalUnderstanding, candidate: GoalCompiledPathCandidate) -> GoalDomainPackContribution {
        let readinessStageID = candidate.stages.first(where: { $0.kind == .readiness })?.id
        let target = GoalDomainPackTarget(candidateID: candidate.id, stageID: readinessStageID)

        let requirement = GoalCompiledPathRequirementHint(
            id: target.makeArtifactID(packID: descriptor.id, kind: "requirement_hint", semanticKey: "path_requirements_confirmation"),
            summary: "Path requirements should be confirmed before treating the goal as execution-ready.",
            kind: .externalRequirement,
            relatedField: .goalShape,
            relatedStageID: readinessStageID,
            blocking: false
        )
        let readinessCriterion = GoalCompiledPathReadinessCriterion(
            id: target.makeArtifactID(packID: descriptor.id, kind: "readiness_criterion", semanticKey: "requirements_confirmed"),
            summary: "Requirements confirmed",
            kind: .confirmation,
            targetStageID: readinessStageID,
            token: "career_requirements_confirmed",
            blocking: false
        )
        let resourceHook = GoalCompiledPathResourceHook(
            id: target.makeArtifactID(packID: descriptor.id, kind: "resource_hook", semanticKey: "requirements_reference"),
            summary: "Reference material is still needed to confirm path requirements.",
            kind: .requirementReference,
            targetStageID: readinessStageID,
            relatedDomains: [.career],
            sourceClaimIDs: [],
            sourceRecordIDs: [],
            optionality: .required,
            placeholderState: .resourceNeeded
        )

        return GoalDomainPackContribution(
            requirementHints: [requirement],
            readinessCriteria: [readinessCriterion],
            resourceHooks: [resourceHook],
            auditEntries: [
                GoalCompiledPathPackAuditEntry(
                    id: target.makeArtifactID(packID: descriptor.id, kind: "audit", semanticKey: "requirements_reference"),
                    packID: descriptor.id,
                    contributionKind: .resourceHook,
                    artifactID: resourceHook.id,
                    targetCandidateID: candidate.id,
                    targetStageID: readinessStageID,
                    summary: "Career pack added a placeholder requirements reference hook."
                )
            ]
        )
    }
}

struct BroadGoalDomainPack: GoalDomainPack {
    let descriptor: GoalDomainPackDescriptor
    let timelineLabel: String
    let domainLimit: String

    static let creativeProject = BroadGoalDomainPack(
        id: "creative_project",
        displayName: "Creative Project Pack",
        domain: .creativity,
        supportedModes: [.achievement, .project, .exploration],
        timelineLabel: "short-to-medium project arc",
        domainLimit: "Creative guidance stays project-shaped and does not prescribe taste, audience response, or market outcomes."
    )

    static let health = BroadGoalDomainPack(
        id: "health",
        displayName: "Health Pack",
        domain: .health,
        supportedModes: [.achievement, .project, .maintenance, .recovery],
        timelineLabel: "review-based health arc",
        domainLimit: "Health guidance stays organizational and does not replace medical or clinical advice."
    )

    static let finance = BroadGoalDomainPack(
        id: "finance",
        displayName: "Finance Pack",
        domain: .finance,
        supportedModes: [.achievement, .project, .maintenance],
        timelineLabel: "medium-to-long finance arc",
        domainLimit: "Finance guidance stays organizational and does not replace professional financial advice."
    )

    static let relationship = BroadGoalDomainPack(
        id: "relationship",
        displayName: "Relationship Pack",
        domain: .relationships,
        supportedModes: [.achievement, .project, .maintenance, .delegatedSupport, .recovery],
        timelineLabel: "review-based relationship arc",
        domainLimit: "Relationship guidance stays reflection-based and does not infer private motives or obligations."
    )

    static let homeAndLifeAdmin = BroadGoalDomainPack(
        id: "home_life_admin",
        displayName: "Home / Life Admin Pack",
        domain: .home,
        supportedModes: [.achievement, .project, .maintenance],
        timelineLabel: "short-to-medium admin arc",
        domainLimit: "Home and life admin guidance stays practical and does not assume outside authority."
    )

    init(
        id: String,
        displayName: String,
        domain: LifeDomainKey,
        supportedModes: [GoalMode],
        timelineLabel: String,
        domainLimit: String
    ) {
        descriptor = GoalDomainPackDescriptor(
            id: id,
            displayName: displayName,
            coveredDomains: [domain],
            supportedModes: supportedModes
        )
        self.timelineLabel = timelineLabel
        self.domainLimit = domainLimit
    }

    func match(understanding: GoalUnderstanding) -> GoalDomainPackMatch? {
        let domains = understanding.domains.all.map(\.domain)
        let matchedDomains = domains.filter { descriptor.coveredDomains.contains($0) }
        guard matchedDomains.isEmpty == false else { return nil }

        let modeSupported = descriptor.supportedModes.contains(understanding.mode.goalMode)
        return GoalDomainPackMatch(
            packID: descriptor.id,
            confidenceScore: understanding.domains.primary == descriptor.coveredDomains.first ? 0.82 : 0.66,
            matchedDomains: matchedDomains,
            reasons: [
                "\(descriptor.displayName) matched the current broad life domain.",
                modeSupported ? "Current goal mode fits this pack." : "Current goal mode needs review for this pack."
            ],
            provisional: understanding.mode.remainsProvisional
                || understanding.clarification.alternateInterpretationsActive
                || modeSupported == false
        )
    }

    func contribute(understanding: GoalUnderstanding, candidate: GoalCompiledPathCandidate) -> GoalDomainPackContribution {
        let readinessStageID = candidate.stages.first(where: { $0.kind == .readiness })?.id
        let setupStageID = candidate.stages.first(where: { $0.kind == .setup })?.id
        let reviewStageID = candidate.stages.first(where: { $0.kind == .reviewFinish })?.id
        let target = GoalDomainPackTarget(candidateID: candidate.id, stageID: readinessStageID)
        let domain = descriptor.coveredDomains.first ?? understanding.domains.primary ?? .personalGrowth

        let requirement = GoalCompiledPathRequirementHint(
            id: target.makeArtifactID(packID: descriptor.id, kind: "requirement_hint", semanticKey: "broad_domain_assumption"),
            summary: "Confirm the broad path assumptions before treating this pack as settled.",
            kind: .domainReadiness,
            relatedField: .goalShape,
            relatedStageID: readinessStageID,
            blocking: false
        )
        let dependency = GoalCompiledPathDependency(
            id: target.makeArtifactID(packID: descriptor.id, kind: "dependency_hint", semanticKey: "review_before_commitment"),
            summary: "Review the broad domain limits before making the next commitment.",
            kind: .readiness,
            sourceClaimIDs: [],
            sourceRecordIDs: [],
            blocking: false,
            relatedStageID: readinessStageID
        )
        let risk = GoalCompiledPathRisk(
            id: target.makeArtifactID(packID: descriptor.id, kind: "risk_hint", semanticKey: "domain_limit"),
            summary: domainLimit,
            kind: .readiness,
            severity: .important
        )
        let readinessCriterion = GoalCompiledPathReadinessCriterion(
            id: target.makeArtifactID(packID: descriptor.id, kind: "readiness_criterion", semanticKey: "assumptions_reviewed"),
            summary: "Broad path assumptions reviewed",
            kind: .confirmation,
            targetStageID: readinessStageID,
            token: "\(descriptor.id)_assumptions_reviewed",
            blocking: false
        )
        let resourceHook = GoalCompiledPathResourceHook(
            id: target.makeArtifactID(packID: descriptor.id, kind: "resource_hook", semanticKey: "source_boundary"),
            summary: "Source or local proof is still needed before this broad pack becomes stronger.",
            kind: .preparationMaterial,
            targetStageID: readinessStageID,
            relatedDomains: [domain],
            sourceClaimIDs: understanding.dependencies.flatMap(\.sourceClaimIDs),
            sourceRecordIDs: understanding.dependencies.flatMap(\.sourceRecordIDs),
            optionality: .optional,
            placeholderState: .resourceNeeded
        )
        let branch = GoalCompiledPathBranch(
            id: target.makeArtifactID(packID: descriptor.id, kind: "branch_addition", semanticKey: "smaller_or_pause_fork"),
            branchType: .fallback,
            summary: "Compare this path with a smaller or paused version before committing deeper.",
            condition: "Use this fork if the \(timelineLabel) feels too large, stale, or unsupported by proof.",
            targetCandidateID: nil,
            targetStageID: setupStageID ?? reviewStageID,
            posture: .provisional
        )

        return GoalDomainPackContribution(
            requirementHints: [requirement],
            dependencyHints: [dependency],
            readinessCriteria: [readinessCriterion],
            riskHints: [risk],
            resourceHooks: [resourceHook],
            branchAdditions: [branch],
            auditEntries: [
                GoalCompiledPathPackAuditEntry(
                    id: target.makeArtifactID(packID: descriptor.id, kind: "audit", semanticKey: "broad_pack_boundary"),
                    packID: descriptor.id,
                    contributionKind: .branchAddition,
                    artifactID: branch.id,
                    targetCandidateID: candidate.id,
                    targetStageID: branch.targetStageID,
                    summary: "\(descriptor.displayName) added a broad, reviewable path fork and source boundary."
                )
            ]
        )
    }
}

struct EducationGoalDomainPack: GoalDomainPack {
    let descriptor = GoalDomainPackDescriptor(
        id: "education",
        displayName: "Education Pack",
        coveredDomains: [.education],
        supportedModes: [.achievement, .project, .learning]
    )

    func match(understanding: GoalUnderstanding) -> GoalDomainPackMatch? {
        guard understanding.domains.all.contains(where: { $0.domain == .education }) else { return nil }

        return GoalDomainPackMatch(
            packID: descriptor.id,
            confidenceScore: understanding.domains.primary == .education ? 0.88 : 0.72,
            matchedDomains: understanding.domains.all.map(\.domain).filter { $0 == .education },
            reasons: ["Education domain present in goal understanding."],
            provisional: understanding.mode.remainsProvisional || understanding.clarification.alternateInterpretationsActive
        )
    }

    func contribute(understanding: GoalUnderstanding, candidate: GoalCompiledPathCandidate) -> GoalDomainPackContribution {
        let readinessStageID = candidate.stages.first(where: { $0.kind == .readiness })?.id
        let target = GoalDomainPackTarget(candidateID: candidate.id, stageID: readinessStageID)

        let requirement = GoalCompiledPathRequirementHint(
            id: target.makeArtifactID(packID: descriptor.id, kind: "requirement_hint", semanticKey: "entry_requirements"),
            summary: "Entry requirements may need confirmation before deeper commitment.",
            kind: .domainReadiness,
            relatedField: .goalShape,
            relatedStageID: readinessStageID,
            blocking: false
        )
        let dependency = GoalCompiledPathDependency(
            id: target.makeArtifactID(packID: descriptor.id, kind: "dependency_hint", semanticKey: "requirements_before_commitment"),
            summary: "Confirm entry requirements before treating the path as commitment-ready.",
            kind: .readiness,
            sourceClaimIDs: [],
            sourceRecordIDs: [],
            blocking: false,
            relatedStageID: readinessStageID
        )
        let readinessCriterion = GoalCompiledPathReadinessCriterion(
            id: target.makeArtifactID(packID: descriptor.id, kind: "readiness_criterion", semanticKey: "entry_requirements_confirmed"),
            summary: "Entry requirements confirmed",
            kind: .eligibility,
            targetStageID: readinessStageID,
            token: "education_entry_requirements_confirmed",
            blocking: true
        )
        let resourceHook = GoalCompiledPathResourceHook(
            id: target.makeArtifactID(packID: descriptor.id, kind: "resource_hook", semanticKey: "entry_requirement_reference"),
            summary: "Reference material is still needed to confirm entry requirements.",
            kind: .requirementReference,
            targetStageID: readinessStageID,
            relatedDomains: [.education],
            sourceClaimIDs: understanding.dependencies.flatMap(\.sourceClaimIDs),
            sourceRecordIDs: understanding.dependencies.flatMap(\.sourceRecordIDs),
            optionality: .required,
            placeholderState: .resourceNeeded
        )
        let branch = GoalCompiledPathBranch(
            id: target.makeArtifactID(packID: descriptor.id, kind: "branch_addition", semanticKey: "requirements_fallback"),
            branchType: .fallback,
            summary: "Keep a fallback branch that returns to readiness until entry requirements are confirmed.",
            condition: "Use this branch if the path still needs requirement confirmation.",
            targetCandidateID: nil,
            targetStageID: candidate.stages.first(where: { $0.kind == .setup })?.id,
            posture: .provisional
        )

        return GoalDomainPackContribution(
            requirementHints: [requirement],
            dependencyHints: [dependency],
            readinessCriteria: [readinessCriterion],
            resourceHooks: [resourceHook],
            branchAdditions: [branch],
            auditEntries: [
                GoalCompiledPathPackAuditEntry(
                    id: target.makeArtifactID(packID: descriptor.id, kind: "audit", semanticKey: "entry_requirement_reference"),
                    packID: descriptor.id,
                    contributionKind: .resourceHook,
                    artifactID: resourceHook.id,
                    targetCandidateID: candidate.id,
                    targetStageID: readinessStageID,
                    summary: "Education pack added a placeholder entry-requirements hook."
                )
            ]
        )
    }
}
