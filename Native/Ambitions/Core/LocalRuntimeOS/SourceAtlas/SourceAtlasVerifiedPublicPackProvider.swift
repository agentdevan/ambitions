import Foundation

protocol SourceAtlasVerifiedPublicPackProviding {
    func publicPlanningContext(
        _ input: SourceAtlasVerifiedPublicPackProviderInput
    ) -> SourceAtlasVerifiedPublicPackProviderOutput
}

struct SourceAtlasVerifiedPublicPackProvider: SourceAtlasVerifiedPublicPackProviding {
    private let pipeline: SourceAtlasPublicPackFetchPipeline

    init(pipeline: SourceAtlasPublicPackFetchPipeline = SourceAtlasPublicPackFetchPipeline()) {
        self.pipeline = pipeline
    }

    func publicPlanningContext(
        _ input: SourceAtlasVerifiedPublicPackProviderInput
    ) -> SourceAtlasVerifiedPublicPackProviderOutput {
        let requestIssues = input.request.validationIssues
        let requestFindings = SourceAtlasNoPrivateGraphEgressAudit.validate([input.request.egressRecord])

        guard requestIssues.isEmpty else {
            return SourceAtlasVerifiedPublicPackProviderOutput(
                schemaVersion: sourceAtlasVerifiedPublicPackProviderSchemaVersion,
                requestIssues: requestIssues,
                fetchStatus: requestFindings.isEmpty ? .unavailable : .quarantined,
                fetchIssues: requestFindings.isEmpty ? [] : [.privateEgressFinding],
                manifestRequestIssues: input.request.manifestRequest.validationIssues,
                packRequestIssues: [],
                cacheIssues: [],
                storeQuarantines: [],
                egressFindings: requestFindings,
                context: nil
            )
        }

        let resolution = pipeline.resolve(input.fetchInput)
        let context = makeContext(
            request: input.request,
            resolution: resolution
        )

        return SourceAtlasVerifiedPublicPackProviderOutput(
            schemaVersion: sourceAtlasVerifiedPublicPackProviderSchemaVersion,
            requestIssues: requestIssues,
            fetchStatus: resolution.status,
            fetchIssues: resolution.fetchIssues,
            manifestRequestIssues: resolution.manifestRequestIssues,
            packRequestIssues: resolution.cacheResolution?.requestIssues ?? [],
            cacheIssues: resolution.cacheResolution?.cacheIssues ?? [],
            storeQuarantines: resolution.cacheResolution?.loadResult.quarantines ?? [],
            egressFindings: requestFindings + resolution.egressFindings,
            context: context
        )
    }
}

private extension SourceAtlasVerifiedPublicPackProvider {
    func makeContext(
        request: SourceAtlasPublicPlanningContextRequest,
        resolution: SourceAtlasPublicPackFetchResolution
    ) -> SourceAtlasPublicPlanningContext? {
        guard let cacheResolution = resolution.cacheResolution,
              let pack = resolution.selectedPack
        else {
            return nil
        }

        let selectedResult = cacheResolution.queryResponse.selectedResult
        let requirements = requirementContexts(
            from: pack,
            request: request
        )
        let proofNeeds = proofNeedContexts(
            from: pack,
            requirementIDs: Set(requirements.map(\.id))
        )
        let sourceIDs = orderedUnique(
            requirements.flatMap(\.sourceIDs) +
                proofNeeds.flatMap(\.sourceRecordIDs) +
                pack.sources.map(\.id) +
                selectedResult.provenanceSourceIDs
        )
        let claimIDs = orderedUnique(
            requirements.map(\.claimID) +
                proofNeeds.flatMap(\.sourceClaimIDs) +
                pack.claims.map(\.id)
        )
        let availability = SourceAtlasPublicPlanningContextAvailability(
            fetchStatus: resolution.status,
            selectedStoreSource: cacheResolution.loadResult.selectedSource,
            storeSourceState: cacheResolution.loadResult.sourceState,
            fallbackConditions: cacheResolution.fallback.conditions,
            canSupportCurrentPublicReferenceUse: cacheResolution.canSupportCurrentUse && resolution.status == .accepted,
            localPlanningBlocked: resolution.coreLocalPlanningBlocked,
            isLastKnownGood: cacheResolution.loadResult.selectedSource == .lastKnownGood,
            isLocalFallback: resolution.status == .usingLocalFallback
        )
        let useMode = useMode(
            availability: availability,
            selectedPack: pack
        )

        return SourceAtlasPublicPlanningContext(
            schemaVersion: sourceAtlasVerifiedPublicPackProviderSchemaVersion,
            id: CandidateSource.stableIdentifier(
                prefix: "source-atlas.public-planning-context",
                components: [
                    request.domainID,
                    pack.id,
                    cacheResolution.updateRecord.manifestVersionID,
                    useMode.rawValue,
                    requirements.map(\.id).joined(separator: ",")
                ]
            ),
            requestDomainID: request.domainID,
            selectedPackID: pack.id,
            selectedPackDomainID: pack.manifest.domainID,
            manifestVersionID: cacheResolution.updateRecord.manifestVersionID,
            useMode: useMode,
            availability: availability,
            requirements: requirements,
            proofNeeds: proofNeeds,
            starterActions: starterActionContexts(from: pack),
            sourceIDs: sourceIDs,
            claimIDs: claimIDs,
            caveats: caveats(
                pack: pack,
                resolution: resolution,
                cacheResolution: cacheResolution
            ),
            riskMetadata: riskMetadataContexts(
                pack: pack,
                requirements: requirements
            ),
            ownership: .publicReferenceOnly
        )
    }

    func useMode(
        availability: SourceAtlasPublicPlanningContextAvailability,
        selectedPack: SourceAtlasPack
    ) -> SourceAtlasPublicPlanningContextUseMode {
        guard selectedPack.isValidForRuntimeUse else {
            return .reviewOnlyReference
        }
        return availability.canSupportCurrentPublicReferenceUse ? .currentReference : .reviewOnlyReference
    }

    func requirementContexts(
        from pack: SourceAtlasPack,
        request: SourceAtlasPublicPlanningContextRequest
    ) -> [SourceAtlasPublicRequirementContext] {
        let claimsByID = Dictionary(uniqueKeysWithValues: pack.claims.map { ($0.id, $0) })
        return pack.requirements
            .filter { requirement in
                if let requirementID = request.requirementID, requirement.id != requirementID {
                    return false
                }
                if let claimID = request.claimID, requirement.claimID != claimID {
                    return false
                }
                if let sourceState = request.sourceState, requirement.sourceState != sourceState {
                    return false
                }
                if let freshnessState = request.freshnessState, requirement.freshnessState != freshnessState {
                    return false
                }
                if let riskClass = request.riskClass, claimsByID[requirement.claimID]?.riskClass != riskClass {
                    return false
                }
                if let sourceID = request.sourceID, claimsByID[requirement.claimID]?.sourceIDs.contains(sourceID) != true {
                    return false
                }
                return true
            }
            .map { requirement in
                let proofEntries = pack.proofMap.filter { $0.requirementID == requirement.id }
                return SourceAtlasPublicRequirementContext(
                    id: requirement.id,
                    claimID: requirement.claimID,
                    title: requirement.title,
                    kind: requirement.kind,
                    required: requirement.required,
                    sourceState: requirement.sourceState,
                    freshnessState: requirement.freshnessState,
                    riskState: requirement.riskState,
                    reviewState: requirement.reviewState,
                    sourceIDs: orderedUnique(claimsByID[requirement.claimID]?.sourceIDs ?? []),
                    proofEntryIDs: orderedUnique(proofEntries.map(\.id))
                )
            }
            .sorted { $0.id < $1.id }
    }

    func proofNeedContexts(
        from pack: SourceAtlasPack,
        requirementIDs: Set<String>
    ) -> [SourceAtlasPublicProofNeedContext] {
        pack.proofMap
            .filter { requirementIDs.contains($0.requirementID) }
            .map {
                SourceAtlasPublicProofNeedContext(
                    id: $0.id,
                    requirementID: $0.requirementID,
                    proofCandidate: $0.proofCandidate,
                    proofStrength: $0.proofStrength,
                    privacyClass: $0.privacyClass,
                    sourceRecordIDs: orderedUnique($0.sourceRecordIDs),
                    sourceClaimIDs: orderedUnique($0.sourceClaimIDs)
                )
            }
            .sorted { $0.id < $1.id }
    }

    func starterActionContexts(from pack: SourceAtlasPack) -> [SourceAtlasPublicStarterActionContext] {
        pack.starterItems
            .map {
                SourceAtlasPublicStarterActionContext(
                    id: $0.id,
                    title: $0.title,
                    stepCandidateSeed: $0.stepCandidateSeed,
                    storesFinalSchedule: $0.storesFinalSchedule
                )
            }
            .sorted { $0.id < $1.id }
    }

    func riskMetadataContexts(
        pack: SourceAtlasPack,
        requirements: [SourceAtlasPublicRequirementContext]
    ) -> [SourceAtlasPublicRiskMetadataContext] {
        let claimsByID = Dictionary(uniqueKeysWithValues: pack.claims.map { ($0.id, $0) })
        return requirements.compactMap { requirement in
            guard let claim = claimsByID[requirement.claimID] else {
                return nil
            }
            return SourceAtlasPublicRiskMetadataContext(
                id: "risk.\(requirement.id)",
                riskClass: claim.riskClass,
                riskState: requirement.riskState,
                reviewState: requirement.reviewState,
                strictReviewRequired: claim.riskClass.requiresStrictReview,
                sourceBacked: claim.sourceIDs.isEmpty == false
            )
        }
        .sorted { $0.id < $1.id }
    }

    func caveats(
        pack: SourceAtlasPack,
        resolution: SourceAtlasPublicPackFetchResolution,
        cacheResolution: SourceAtlasLocalPackCacheResolution
    ) -> [SourceAtlasPublicCaveatContext] {
        var caveats: [SourceAtlasPublicCaveatContext] = [
            SourceAtlasPublicCaveatContext(
                id: "caveat.not-professional-advice",
                message: pack.disclosureCopy.notProfessionalAdvice,
                relatedIDs: [pack.id]
            )
        ]

        if cacheResolution.fallback.blocksCurrentUse {
            caveats.append(
                SourceAtlasPublicCaveatContext(
                    id: "caveat.review-only-reference",
                    message: pack.disclosureCopy.reviewRequired,
                    relatedIDs: [pack.id]
                )
            )
        }
        if cacheResolution.loadResult.selectedSource == .lastKnownGood {
            caveats.append(
                SourceAtlasPublicCaveatContext(
                    id: "caveat.last-known-good",
                    message: "Last-known-good public reference is available for local review only.",
                    relatedIDs: [pack.id]
                )
            )
        }
        if resolution.status == .usingLocalFallback {
            caveats.append(
                SourceAtlasPublicCaveatContext(
                    id: "caveat.local-fallback",
                    message: "Remote public reference refresh did not replace the local reference pack.",
                    relatedIDs: [pack.id]
                )
            )
        }

        return caveats.removingDuplicateIDs().sorted { $0.id < $1.id }
    }

    func orderedUnique(_ values: [String]) -> [String] {
        Array(
            Set(
                values
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { $0.isEmpty == false }
            )
        ).sorted()
    }
}

private extension Array where Element == SourceAtlasPublicCaveatContext {
    func removingDuplicateIDs() -> [SourceAtlasPublicCaveatContext] {
        var seen: Set<String> = []
        return filter { seen.insert($0.id).inserted }
    }
}
