import Foundation

struct PrivacySafeCoverageRequestBuilder: Sendable, Equatable, Hashable {
    func build(from need: CoverageNeed, rawPrivateGoalText: String? = nil) -> PrivacySafeCoverageRequest? {
        guard need.canBuildRemoteAbstractRequest else {
            return nil
        }
        let request = PrivacySafeCoverageRequest(
            id: "coverage-request.\(need.dedupeKey)",
            needID: need.id,
            dedupeKey: need.dedupeKey,
            family: need.family,
            domain: need.domain,
            missingSourceTypes: need.missingSourceTypes,
            seedGapCategories: need.seedGapCategories,
            riskJurisdictionClass: need.riskJurisdictionClass,
            redactionBoundary: "abstract family/capability/source gap only; no raw private goal text",
            consentState: need.consentState,
            sourceRecordIDs: need.sourceRecordIDs
        )
        guard let rawPrivateGoalText, rawPrivateGoalText.isEmpty == false else {
            return request
        }
        return request.containsPrivateMaterial(from: rawPrivateGoalText) ? nil : request
    }
}

struct CoverageSourceArrivalDetector: Sendable, Equatable, Hashable {
    func detect(needs: [CoverageNeed], signals: [CoverageSourceArrivalSignal]) -> [CoverageSourceArrivalTrace] {
        let sortedNeeds = needs.sorted { $0.id < $1.id }
        let sortedSignals = signals.sorted { $0.id < $1.id }
        return sortedNeeds.flatMap { need in
            sortedSignals.compactMap { signal in
                traceIfMatched(need: need, signal: signal)
            }
        }
        .sorted { $0.id < $1.id }
    }

    func traceIfMatched(need: CoverageNeed, signal: CoverageSourceArrivalSignal) -> CoverageSourceArrivalTrace? {
        guard need.family == signal.family,
              need.domain == signal.domain,
              signal.sourceFingerprintID.isEmpty == false,
              intersects(need.missingSourceTypes, signal.missingSourceTypes) ||
                intersects(need.seedGapCategories, signal.seedGapCategories) else {
            return nil
        }

        let hasReleaseAndRollback = signal.releaseReceiptIDs.isEmpty == false && signal.rollbackReceiptIDs.isEmpty == false
        let state: CoverageSourceArrivalState = signal.canSupportCurrentUse &&
            signal.authorityIssueCodes.isEmpty &&
            signal.sourceRecordIDs.isEmpty == false &&
            hasReleaseAndRollback
            ? .candidateForRecheck
            : .blockedByAuthority

        return CoverageSourceArrivalTrace(
            id: "coverage-arrival.\(need.id).\(signal.id)",
            needID: need.id,
            signalID: signal.id,
            state: state,
            sourceFingerprintID: signal.sourceFingerprintID,
            sourceRecordIDs: signal.sourceRecordIDs,
            authorityIssueCodes: signal.authorityIssueCodes,
            releaseReceiptIDs: signal.releaseReceiptIDs,
            rollbackReceiptIDs: signal.rollbackReceiptIDs,
            requiresLocalRouteRecheck: state == .candidateForRecheck
        )
    }

    func intersects<T: Hashable>(_ lhs: [T], _ rhs: [T]) -> Bool {
        Set(lhs).isDisjoint(with: Set(rhs)) == false
    }
}
