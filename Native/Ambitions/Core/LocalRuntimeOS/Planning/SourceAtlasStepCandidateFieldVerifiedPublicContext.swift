import Foundation

extension SourceAtlasStepCandidateFieldBridge {
    func expandVerifiedPublicPlanningContext(
        providerOutput: SourceAtlasVerifiedPublicPackProviderOutput,
        composition: PersonalPathComposition,
        pack: SourceAtlasPack,
        generatedAt: String,
        goalID: String? = nil,
        deadlineTargetDate: String? = nil,
        factorLedger: PersonalizationFactorLedger? = nil,
        lifeContextProjection: LifeContextRuntimeProjection? = nil,
        candidateLimit: Int = 24,
        localOnly: Bool = true
    ) -> SourceAtlasVerifiedPublicPlanningBridgeOutput {
        let issues = verifiedPublicPlanningIssues(
            providerOutput: providerOutput,
            pack: pack
        )

        guard issues.isEmpty,
              let publicPlanningContext = providerOutput.context
        else {
            let fallbackField = makeVerifiedPublicPlanningFallbackField(
                goalID: goalID ?? composition.goalID,
                deadlineTargetDate: deadlineTargetDate,
                generatedAt: generatedAt,
                factorLedger: factorLedger,
                lifeContextProjection: lifeContextProjection,
                localOnly: localOnly
            )
            let receipts = makePublicPlanningRejectedReceipts(
                providerOutput: providerOutput,
                issues: issues,
                generatedAt: generatedAt,
                localOnly: localOnly
            )
            return SourceAtlasVerifiedPublicPlanningBridgeOutput(
                field: fallbackField,
                receipts: receipts,
                shardInfluence: nil,
                sourceInfluenceReceipt: nil,
                issues: issues,
                localOnly: localOnly
            )
        }

        let field = expand(
            goalID: goalID ?? composition.goalID,
            composition: composition,
            pack: pack,
            generatedAt: generatedAt,
            deadlineTargetDate: deadlineTargetDate,
            factorLedger: factorLedger,
            lifeContextProjection: lifeContextProjection,
            publicPlanningContext: publicPlanningContext,
            candidateLimit: candidateLimit,
            localOnly: localOnly
        )
        let shardInfluence = SourceAtlasVerifiedPublicShardInfluence(context: publicPlanningContext)
        let sourceInfluenceReceipt = SourceInfluenceReceipt(
            recordedAt: generatedAt,
            field: field,
            shardInfluence: shardInfluence,
            reviewRequired: publicPlanningContext.sourceInfluenceReceiptReviewRequired,
            localOnly: localOnly
        )
        let receipts = makePublicPlanningAppliedReceipts(
            context: publicPlanningContext,
            field: field,
            shardInfluence: shardInfluence,
            sourceInfluenceReceipt: sourceInfluenceReceipt,
            generatedAt: generatedAt,
            localOnly: localOnly
        )

        return SourceAtlasVerifiedPublicPlanningBridgeOutput(
            field: field,
            receipts: receipts,
            shardInfluence: shardInfluence,
            sourceInfluenceReceipt: sourceInfluenceReceipt,
            issues: [],
            localOnly: localOnly
        )
    }


    func verifiedPublicPlanningIssues(
        providerOutput: SourceAtlasVerifiedPublicPackProviderOutput,
        pack: SourceAtlasPack
    ) -> [SourceAtlasVerifiedPublicPlanningBridgeIssue] {
        var issues: Set<SourceAtlasVerifiedPublicPlanningBridgeIssue> = []

        if providerOutput.requestIssues.isEmpty == false {
            issues.insert(.publicContextRequestInvalid)
        }
        if providerOutput.egressFindings.isEmpty == false {
            issues.insert(.publicContextEgressBlocked)
        }
        guard let context = providerOutput.context else {
            issues.insert(.missingVerifiedPublicContext)
            return SourceAtlasVerifiedPublicPlanningBridgeIssue.allCases.filter { issues.contains($0) }
        }
        if context.canInformLocalPlanning == false || context.useMode == .unavailable {
            issues.insert(.publicContextUnavailable)
        }
        if context.availability.localPlanningBlocked {
            issues.insert(.localPlanningBlocked)
        }
        if context.selectedPackID != pack.id {
            issues.insert(.selectedPackMismatch)
        }
        if context.selectedPackDomainID != pack.manifest.domainID {
            issues.insert(.selectedDomainMismatch)
        }
        if context.ownership.sourceAtlasOwnsPublicReferenceContext == false ||
            context.ownership.privateRuntimeOwnsPersonalization == false ||
            context.ownership.privateRuntimeOwnsPathing == false ||
            context.ownership.privateRuntimeOwnsScheduling == false ||
            context.ownership.privateRuntimeOwnsReceipts == false ||
            context.ownership.sourceAtlasCreatesFinalSteps ||
            context.ownership.sourceAtlasCreatesUserSchedule ||
            context.ownership.sourceAtlasStoresRuntimeState {
            issues.insert(.ownershipBoundaryViolation)
        }

        return SourceAtlasVerifiedPublicPlanningBridgeIssue.allCases.filter { issues.contains($0) }
    }


    func makeVerifiedPublicPlanningFallbackField(
        goalID: String?,
        deadlineTargetDate: String?,
        generatedAt: String,
        factorLedger: PersonalizationFactorLedger?,
        lifeContextProjection: LifeContextRuntimeProjection?,
        localOnly: Bool
    ) -> StepCandidateField {
        StepCandidateFieldGenerator().generate(
            CandidateGenerationContext(
                goalID: goalID,
                deadlineTargetDate: deadlineTargetDate,
                compilerOutput: nil,
                factorLedger: factorLedger,
                lifeContextProjection: lifeContextProjection,
                generatedAt: generatedAt,
                candidateLimit: 1,
                localOnly: localOnly
            )
        )
    }


    func makePublicPlanningAppliedReceipts(
        context: SourceAtlasPublicPlanningContext,
        field: StepCandidateField,
        shardInfluence: SourceAtlasVerifiedPublicShardInfluence,
        sourceInfluenceReceipt: SourceInfluenceReceipt,
        generatedAt: String,
        localOnly: Bool
    ) -> [SourceAtlasBridgeReceipt] {
        [
            SourceAtlasBridgeReceipt(
                kind: .sourceAtlasPublicContextVerified,
                recordedAt: generatedAt,
                summary: "Verified public Source Atlas context was accepted for local planning.",
                details: [
                    "context=\(context.id)",
                    "pack=\(context.selectedPackID)",
                    "domain=\(context.selectedPackDomainID)",
                    "manifest=\(context.manifestVersionID ?? "none")",
                    "use-mode=\(context.useMode.rawValue)",
                    "fetch-status=\(context.availability.fetchStatus.rawValue)",
                    "store-source=\(context.availability.selectedStoreSource?.rawValue ?? "none")",
                    "last-known-good=\(context.availability.isLastKnownGood)",
                    "local-fallback=\(context.availability.isLocalFallback)",
                    "source-count=\(shardInfluence.sourceIDs.count)",
                    "claim-count=\(shardInfluence.claimIDs.count)",
                    "requirement-count=\(shardInfluence.requirementIDs.count)",
                    "proof-need-count=\(shardInfluence.proofNeedIDs.count)",
                    "starter-action-count=\(shardInfluence.starterActionIDs.count)",
                    "receipt-scope=local-only",
                    "r2-artifact=false"
                ],
                relatedIDs: [context.id, context.selectedPackID] +
                    shardInfluence.sourceIDs +
                    shardInfluence.claimIDs +
                    shardInfluence.requirementIDs +
                    shardInfluence.proofNeedIDs +
                    shardInfluence.starterActionIDs
            ),
            SourceAtlasBridgeReceipt(
                kind: .sourceAtlasPublicContextApplied,
                recordedAt: generatedAt,
                summary: "Private Runtime applied public shard context before local candidate ranking.",
                details: [
                    "candidate-field=\(field.id)",
                    "selected-candidate=\(field.selectedCandidateID)",
                    "candidate-count=\(field.candidates.count)",
                    "seed-count=\(field.sourceAtlasExpansionTrace?.sourceStepCandidateSeeds.count ?? 0)",
                    "expanded-count=\(field.sourceAtlasExpansionTrace?.expandedCandidates.count ?? 0)",
                    "source-atlas-final-step-owner=false",
                    "source-atlas-final-schedule-owner=false",
                    "source-atlas-stores-runtime-state=false",
                    "private-runtime-owns-personalization=\(shardInfluence.privateRuntimeOwnsPersonalization)",
                    "private-runtime-owns-pathing=\(shardInfluence.privateRuntimeOwnsPathing)",
                    "private-runtime-owns-scheduling=\(shardInfluence.privateRuntimeOwnsScheduling)",
                    "private-runtime-owns-receipts=\(shardInfluence.privateRuntimeOwnsReceipts)",
                    "local-only=\(localOnly)"
                ],
                relatedIDs: [field.id, field.selectedCandidateID, shardInfluence.id] + field.candidateIDs
            ),
            sourceInfluenceReceipt.bridgeReceipt
        ]
    }


    func makePublicPlanningRejectedReceipts(
        providerOutput: SourceAtlasVerifiedPublicPackProviderOutput,
        issues: [SourceAtlasVerifiedPublicPlanningBridgeIssue],
        generatedAt: String,
        localOnly: Bool
    ) -> [SourceAtlasBridgeReceipt] {
        let contextIDs = providerOutput.context.map { [$0.id, $0.selectedPackID] } ?? []
        return [
            SourceAtlasBridgeReceipt(
                kind: .sourceAtlasPublicContextRejected,
                recordedAt: generatedAt,
                summary: "Verified public Source Atlas context was not accepted for candidate expansion.",
                details: [
                    "issues=\(issues.map(\.rawValue).joined(separator: ","))",
                    "request-issues=\(providerOutput.requestIssues.map(\.rawValue).joined(separator: ","))",
                    "fetch-status=\(providerOutput.fetchStatus.rawValue)",
                    "fetch-issues=\(providerOutput.fetchIssues.map(\.rawValue).joined(separator: ","))",
                    "egress-findings=\(providerOutput.egressFindings.count)",
                    "fallback=local-private-runtime",
                    "receipt-scope=local-only",
                    "r2-artifact=false",
                    "local-only=\(localOnly)"
                ],
                relatedIDs: contextIDs,
                isRedacted: providerOutput.egressFindings.isEmpty == false
            )
        ]
    }
}

private extension SourceAtlasPublicPlanningContext {
    var sourceInfluenceReceiptReviewRequired: Bool {
        useMode == .reviewOnlyReference ||
            requirements.contains { $0.reviewState != .approved } ||
            riskMetadata.contains { $0.strictReviewRequired }
    }
}
