import Foundation

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
            kind: .requirementReference,
            targetStageID: readinessStageID,
            relatedDomains: [.career],
            sourceClaimIDs: [],
            sourceRecordIDs: [],
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
            kind: .requirementReference,
            targetStageID: readinessStageID,
            relatedDomains: [.education],
            sourceClaimIDs: understanding.dependencies.flatMap(\.sourceClaimIDs),
            sourceRecordIDs: understanding.dependencies.flatMap(\.sourceRecordIDs),
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
