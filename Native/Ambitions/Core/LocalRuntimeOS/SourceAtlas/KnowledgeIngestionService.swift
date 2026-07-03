import Foundation

protocol KnowledgeIngesting: Sendable {
    func ingest(
        response: KnowledgeProviderResponse,
        fallbackStatuses: [KnowledgeProviderStatus]
    ) -> KnowledgeIngestionResult
}

struct DefaultKnowledgeIngestionService: KnowledgeIngesting {
    func ingest(
        response: KnowledgeProviderResponse,
        fallbackStatuses: [KnowledgeProviderStatus] = []
    ) -> KnowledgeIngestionResult {
        let statuses = response.providerStatuses.isEmpty ? fallbackStatuses : response.providerStatuses
        if response.providerInputs.isEmpty {
            return legacyFallbackResult(from: response.claimSet, providerStatuses: statuses)
        }

        return normalizedResult(from: response.providerInputs, providerStatuses: statuses)
    }

    private func normalizedResult(
        from inputs: [KnowledgeProviderClaimInput],
        providerStatuses: [KnowledgeProviderStatus]
    ) -> KnowledgeIngestionResult {
        var sources: [KnowledgeSourceRecord] = []
        var sourceByID: [String: KnowledgeSourceRecord] = [:]
        var claims: [KnowledgeClaim] = []

        for input in inputs {
            let source = normalizedSource(for: input)
            if sourceByID[source.id] == nil {
                sourceByID[source.id] = source
                sources.append(source)
            }

            claims.append(
                KnowledgeClaim(
                    id: makeClaimID(for: input, sourceID: source.id),
                    providerID: input.providerID,
                    subject: input.subject,
                    payload: KnowledgeClaimPayload(summary: input.summary, detail: input.detail),
                    source: source,
                    freshness: input.freshness,
                    trustLevel: input.trustLevel,
                    confidence: input.confidence,
                    uncertaintyFlags: baseUncertaintyFlags(for: input),
                    explanation: KnowledgeExplanationMetadata(
                        summary: "",
                        supportingSourceIDs: [source.id],
                        notes: []
                    )
                )
            )
        }

        let conflictGroups = buildConflictGroups(claims: claims)
        let conflictingClaimIDs = Set(conflictGroups.flatMap(\.claimIDs))
        let normalizedClaims = claims.map { claim in
            guard conflictingClaimIDs.contains(claim.id) else { return claim }
            return KnowledgeClaim(
                id: claim.id,
                providerID: claim.providerID,
                subject: claim.subject,
                payload: claim.payload,
                source: claim.source,
                freshness: claim.freshness,
                trustLevel: claim.trustLevel,
                confidence: claim.confidence,
                uncertaintyFlags: claim.uncertaintyFlags.union([.conflicting]),
                explanation: claim.explanation
            )
        }

        let degradationStates = degradationStates(
            providerStatuses: providerStatuses,
            claims: normalizedClaims,
            hasConflicts: conflictGroups.isEmpty == false
        )
        let conflictState: KnowledgeConflictState = conflictGroups.isEmpty ? .none : .conflictingUnresolved

        return KnowledgeIngestionResult(
            claimSet: KnowledgeClaimSet(
                claims: normalizedClaims,
                conflictState: conflictState,
                degradationSummary: derivedSummary(from: degradationStates)
            ),
            sources: sources,
            conflictGroups: conflictGroups,
            degradationStates: degradationStates,
            providerStatuses: providerStatuses
        )
    }

    private func legacyFallbackResult(
        from claimSet: KnowledgeClaimSet,
        providerStatuses: [KnowledgeProviderStatus]
    ) -> KnowledgeIngestionResult {
        var sources: [KnowledgeSourceRecord] = []
        var seenSourceIDs: Set<String> = []
        for claim in claimSet.claims where seenSourceIDs.contains(claim.source.id) == false {
            seenSourceIDs.insert(claim.source.id)
            sources.append(claim.source)
        }

        let conflictGroups = buildConflictGroups(claims: claimSet.claims, forcedConflict: claimSet.conflictState == .conflictingUnresolved)
        let degradationStates = degradationStates(
            providerStatuses: providerStatuses,
            claims: claimSet.claims,
            hasConflicts: conflictGroups.isEmpty == false || claimSet.conflictState == .conflictingUnresolved
        )

        return KnowledgeIngestionResult(
            claimSet: KnowledgeClaimSet(
                claims: claimSet.claims,
                conflictState: conflictGroups.isEmpty ? claimSet.conflictState : .conflictingUnresolved,
                degradationSummary: derivedSummary(from: degradationStates) ?? claimSet.degradationSummary
            ),
            sources: sources,
            conflictGroups: conflictGroups,
            degradationStates: degradationStates,
            providerStatuses: providerStatuses
        )
    }

    private func normalizedSource(for input: KnowledgeProviderClaimInput) -> KnowledgeSourceRecord {
        KnowledgeSourceRecord(
            id: makeSourceID(providerID: input.providerID, source: input.source),
            providerID: input.providerID,
            entityTitle: input.source.entityTitle,
            publisher: input.source.publisher,
            locator: input.source.locator,
            provenanceKind: input.source.provenanceKind,
            isOfficial: input.source.isOfficial
        )
    }

    private func baseUncertaintyFlags(for input: KnowledgeProviderClaimInput) -> Set<KnowledgeUncertaintyFlag> {
        var flags = input.uncertaintyFlags
        if input.source.provenanceKind == .inferred {
            flags.insert(.inferred)
        }
        if input.freshness.state == .stale || input.freshness.state == .expired {
            flags.insert(.stale)
        }
        if input.trustLevel == .low || input.confidence == .low {
            flags.insert(.lowConfidence)
        }
        return flags
    }

    private func degradationStates(
        providerStatuses: [KnowledgeProviderStatus],
        claims: [KnowledgeClaim],
        hasConflicts: Bool
    ) -> [KnowledgeDegradationState] {
        var states: [KnowledgeDegradationState] = []

        if providerStatuses.contains(where: { $0.availability == .localOnlyMode }) {
            states.append(.localOnlyMode)
        }
        if providerStatuses.contains(where: { $0.availability == .providerUnavailable }) {
            states.append(.providerUnavailable)
        }
        if claims.contains(where: { $0.freshness.state == .stale || $0.freshness.state == .expired }) {
            states.append(.staleInformation)
        }
        if claims.contains(where: { $0.trustLevel == .low || $0.confidence == .low }) {
            states.append(.lowTrustInformation)
        }
        if hasConflicts {
            states.append(.conflictingClaims)
        }

        return stableUnique(states)
    }

    private func buildConflictGroups(
        claims: [KnowledgeClaim],
        forcedConflict: Bool = false
    ) -> [KnowledgeConflictGroup] {
        let grouped = Dictionary(grouping: claims, by: \.subject)
        return grouped.keys.sorted().compactMap { subject in
            guard let subjectClaims = grouped[subject] else { return nil }
            let reason = conflictReason(for: subjectClaims, forcedConflict: forcedConflict)
            guard let reason else { return nil }
            return KnowledgeConflictGroup(
                subject: subject,
                claimIDs: subjectClaims.map(\.id).sorted(),
                sourceIDs: Array(Set(subjectClaims.map(\.source.id))).sorted(),
                reason: reason
            )
        }
    }

    private func conflictReason(
        for claims: [KnowledgeClaim],
        forcedConflict: Bool
    ) -> String? {
        if forcedConflict {
            return "legacy_conflict_state"
        }
        if claims.contains(where: { $0.uncertaintyFlags.contains(.conflicting) }) {
            return "provider_marked_conflicting"
        }
        let distinctSummaries = Set(claims.map { normalizedKey($0.payload.summary) })
        return distinctSummaries.count > 1 ? "multiple_distinct_claim_values" : nil
    }

    private func makeSourceID(providerID: String, source: KnowledgeProviderSourceInput) -> String {
        stableID(
            prefix: "source",
            parts: [
                providerID,
                source.providerSourceKey ?? "",
                source.locator ?? "",
                source.entityTitle
            ]
        )
    }

    private func makeClaimID(for input: KnowledgeProviderClaimInput, sourceID: String) -> String {
        stableID(
            prefix: "claim",
            parts: [
                input.providerID,
                input.providerClaimKey ?? "",
                input.subject,
                sourceID,
                input.summary
            ]
        )
    }

    private func stableID(prefix: String, parts: [String]) -> String {
        let body = parts
            .map(normalizedKey)
            .filter { $0.isEmpty == false }
            .joined(separator: "-")
        return body.isEmpty ? prefix : "\(prefix)-\(body)"
    }

    private func normalizedKey(_ value: String) -> String {
        let lowered = value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let scalars = lowered.unicodeScalars.map { scalar -> Character in
            CharacterSet.alphanumerics.contains(scalar) ? Character(scalar) : "-"
        }
        let collapsed = String(scalars).replacingOccurrences(of: "-+", with: "-", options: .regularExpression)
        return collapsed.trimmingCharacters(in: CharacterSet(charactersIn: "-"))
    }

    private func derivedSummary(from states: [KnowledgeDegradationState]) -> String? {
        guard states.isEmpty == false else { return nil }
        return states.map(\.rawValue).joined(separator: ",")
    }

    private func stableUnique<T: Hashable>(_ values: [T]) -> [T] {
        var seen: Set<T> = []
        var result: [T] = []
        for value in values where seen.insert(value).inserted {
            result.append(value)
        }
        return result
    }
}

extension KnowledgeProviderResponse {
    func goalUnderstandingKnowledgeContext(
        using ingestionService: any KnowledgeIngesting = DefaultKnowledgeIngestionService(),
        fallbackStatuses: [KnowledgeProviderStatus] = []
    ) -> GoalUnderstandingKnowledgeContext {
        ingestionService
            .ingest(response: self, fallbackStatuses: fallbackStatuses)
            .goalUnderstandingKnowledgeContext()
    }
}
