import Foundation

extension GoalCompiledPathCompilerCore {

    func stageUncertaintyReasons(
        understanding: GoalUnderstanding,
        posture: GoalPathCompilePosture
    ) -> [GoalCompiledPathUncertaintyReason] {
        var reasons: [GoalCompiledPathUncertaintyReason] = []
        if understanding.clarification.alternateInterpretationsActive || understanding.timeline.unresolvedAmbiguity {
            reasons.append(.activeAmbiguity)
        }
        if understanding.clarification.missingContext.isEmpty == false {
            reasons.append(.missingContext)
        }
        if understanding.assumptions.isEmpty == false {
            reasons.append(.carriedAssumption)
        }
        if understanding.risks.isEmpty == false {
            reasons.append(.carriedRisk)
        }
        if posture == .blocked {
            reasons.append(.blockedReadiness)
        }
        return reasons
    }


    func makeDependencies(
        understanding: GoalUnderstanding,
        stages: [GoalCompiledPathStage]
    ) -> [GoalCompiledPathDependency] {
        var dependencies = understanding.dependencies.map {
            GoalCompiledPathDependency(
                id: $0.id,
                summary: $0.summary,
                kind: compiledDependencyKind(for: $0.kind),
                sourceClaimIDs: $0.sourceClaimIDs,
                sourceRecordIDs: $0.sourceRecordIDs,
                blocking: understanding.readiness.safeToCompile == false && $0.kind == .readiness,
                relatedStageID: stages.first(where: { $0.kind == .readiness })?.id
            )
        }

        for pair in zip(stages, stages.dropFirst()) {
            dependencies.append(
                GoalCompiledPathDependency(
                    id: stageOrderingDependencyID(previousStageID: pair.0.id, nextStageID: pair.1.id),
                    summary: "\(pair.0.title) should precede \(pair.1.title).",
                    kind: .stageOrdering,
                    sourceClaimIDs: [],
                    sourceRecordIDs: [],
                    blocking: false,
                    relatedStageID: pair.1.id
                )
            )
        }

        return dependencies
    }


    func compiledDependencyKind(for kind: GoalUnderstandingDependencyKind) -> GoalCompiledPathDependencyKind {
        switch kind {
        case .readiness:
            return .readiness
        case .support:
            return .support
        case .timeline:
            return .timeline
        case .knowledge:
            return .knowledge
        }
    }


    func makeBranches(
        understanding: GoalUnderstanding,
        interpretation: GoalUnderstandingInterpretation,
        isPrimary: Bool,
        posture: GoalPathCompilePosture,
        candidateID currentCandidateID: String
    ) -> [GoalCompiledPathBranch] {
        var branches: [GoalCompiledPathBranch] = []

        if isPrimary {
            branches.append(contentsOf: understanding.alternateInterpretations.map {
                GoalCompiledPathBranch(
                    id: "branch-\(currentCandidateID)-\($0.id)",
                    branchType: .alternateInterpretation,
                    summary: "Keep the alternate interpretation available instead of collapsing to one final path.",
                    condition: "Switch here if the alternate reading becomes the better fit.",
                    targetCandidateID: candidateID(for: $0, isPrimary: false),
                    targetStageID: nil,
                    posture: .provisional
                )
            })
        }

        if posture == .blocked {
            branches.append(
                GoalCompiledPathBranch(
                    id: "branch-\(currentCandidateID)-blocked",
                    branchType: .blocked,
                    summary: "The path remains blocked until clarification is sufficient.",
                    condition: "Clarify the blocking fields before treating this as starter-safe.",
                    targetCandidateID: nil,
                    targetStageID: "stage-\(interpretation.id)-setup",
                    posture: .blocked
                )
            )
        } else if understanding.assumptions.isEmpty == false || understanding.risks.isEmpty == false {
            branches.append(
                GoalCompiledPathBranch(
                    id: "branch-\(currentCandidateID)-fallback",
                    branchType: .fallback,
                    summary: "Keep a starter-safe fallback branch while uncertainty remains material.",
                    condition: "Use this branch when assumptions still shape the next step.",
                    targetCandidateID: nil,
                    targetStageID: "stage-\(interpretation.id)-setup",
                    posture: .provisional
                )
            )
        }

        return branches
    }


    func blockingReasons(
        from understanding: GoalUnderstanding,
        posture: GoalPathCompilePosture
    ) -> [GoalCompiledPathBlockingReason] {
        guard posture == .blocked else { return [] }

        var reasons = understanding.clarification.missingContext
            .filter(\.blocksCompilation)
            .map {
                GoalCompiledPathBlockingReason(
                    id: "blocking-\($0.id)",
                    summary: $0.reason,
                    field: $0.field
                )
            }

        reasons.append(
            contentsOf: understanding.clarification.unresolvedQuestions
                .filter(\.blocking)
                .map {
                    GoalCompiledPathBlockingReason(
                        id: "blocking-\($0.id)",
                        summary: $0.prompt,
                        field: $0.targetField
                    )
                }
        )

        return reasons
    }


    func confidenceScore(
        understanding: GoalUnderstanding,
        isPrimary: Bool
    ) -> Double {
        let base = understanding.confidence.score
        if isPrimary {
            return roundToTwoDecimals(base)
        }
        return roundToTwoDecimals(max(0.0, base - 0.12))
    }


    func makeAuditEntries(
        understanding: GoalUnderstanding,
        candidates: [GoalCompiledPathCandidate]
    ) -> [GoalCompiledPathAuditEntry] {
        var entries: [GoalCompiledPathAuditEntry] = []

        entries.append(
            GoalCompiledPathAuditEntry(
                id: "audit-interpretation-\(understanding.primaryInterpretation.id)",
                kind: .interpretationSelection,
                sourceInterpretationID: understanding.primaryInterpretation.id,
                sourceDependencyID: nil,
                sourceRiskID: nil,
                sourceAssumptionID: nil,
                claimID: nil,
                sourceRecordID: nil,
                summary: "Primary interpretation selected as the lead path candidate."
            )
        )

        entries.append(
            contentsOf: understanding.dependencies.map {
                GoalCompiledPathAuditEntry(
                    id: "audit-dependency-\($0.id)",
                    kind: .dependencyCarryForward,
                    sourceInterpretationID: nil,
                    sourceDependencyID: $0.id,
                    sourceRiskID: nil,
                    sourceAssumptionID: nil,
                    claimID: $0.sourceClaimIDs.first,
                    sourceRecordID: $0.sourceRecordIDs.first,
                    summary: $0.summary
                )
            }
        )

        entries.append(
            contentsOf: understanding.assumptions.map {
                GoalCompiledPathAuditEntry(
                    id: "audit-assumption-\($0.id)",
                    kind: .assumptionCarryForward,
                    sourceInterpretationID: nil,
                    sourceDependencyID: nil,
                    sourceRiskID: nil,
                    sourceAssumptionID: $0.id,
                    claimID: nil,
                    sourceRecordID: nil,
                    summary: $0.summary
                )
            }
        )

        entries.append(
            contentsOf: understanding.risks.map {
                GoalCompiledPathAuditEntry(
                    id: "audit-risk-\($0.id)",
                    kind: .riskCarryForward,
                    sourceInterpretationID: nil,
                    sourceDependencyID: nil,
                    sourceRiskID: $0.id,
                    sourceAssumptionID: nil,
                    claimID: nil,
                    sourceRecordID: nil,
                    summary: $0.summary
                )
            }
        )

        entries.append(
            contentsOf: understanding.audit.evidence
                .filter { $0.origin == .knowledgeContext }
                .map {
                    GoalCompiledPathAuditEntry(
                        id: "audit-knowledge-\($0.id)",
                        kind: .knowledgeEvidence,
                        sourceInterpretationID: nil,
                        sourceDependencyID: nil,
                        sourceRiskID: nil,
                        sourceAssumptionID: nil,
                        claimID: $0.claimID,
                        sourceRecordID: $0.sourceRecordID,
                        summary: $0.summary
                    )
                }
        )

        if entries.isEmpty, let candidate = candidates.first {
            entries.append(
                GoalCompiledPathAuditEntry(
                    id: "audit-candidate-\(candidate.id)",
                    kind: .interpretationSelection,
                    sourceInterpretationID: understanding.primaryInterpretation.id,
                    sourceDependencyID: nil,
                    sourceRiskID: nil,
                    sourceAssumptionID: nil,
                    claimID: nil,
                    sourceRecordID: nil,
                    summary: candidate.summary
                )
            )
        }

        return entries
    }


    func roundToTwoDecimals(_ value: Double) -> Double {
        (value * 100).rounded() / 100
    }
}
