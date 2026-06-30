import Foundation

enum SourceAtlasLocalCompositionMode: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case publicReferenceAvailable = "public_reference_available"
    case localFallbackWithCaveat = "local_fallback_with_caveat"
    case localStarterOnly = "local_starter_only"
}

struct SourceAtlasLocalCompositionFallbackResult: Codable, Sendable, Equatable, Hashable {
    let mode: SourceAtlasLocalCompositionMode
    let publicReferencePackIDs: [String]
    let caveats: [String]
    let runtimeOwnsFitTimingPriorityProof: Bool
    let sourceAtlasOwnsFinalUserSteps: Bool
    let createsFinalSchedule: Bool
    let blocksCoreLocalPlanning: Bool
}

struct SourceAtlasLocalCompositionFallback: Sendable, Equatable, Hashable {
    func evaluate(
        cacheResolution: SourceAtlasLocalPackCacheResolution,
        accessDecision: SourceAtlasAccessDecision? = nil
    ) -> SourceAtlasLocalCompositionFallbackResult {
        let selectedPackIDs = cacheResolution.updateRecord.selectedPackIDs.sorted()
        let fallbackMode: SourceAtlasLocalCompositionMode
        var caveats: [String] = []

        if cacheResolution.canSupportCurrentUse {
            fallbackMode = .publicReferenceAvailable
        } else if cacheResolution.selectedPack != nil {
            fallbackMode = .localFallbackWithCaveat
        } else {
            fallbackMode = .localStarterOnly
        }

        if cacheResolution.cacheIssues.contains(.staleManifest) ||
            cacheResolution.cacheIssues.contains(.staleCriticalByManifest) ||
            cacheResolution.fallback.conditions.contains(.staleCache) {
            caveats.append("Source freshness needs review.")
        }
        if cacheResolution.cacheIssues.contains(.revokedByManifest) {
            caveats.append("Revoked Source Atlas artifacts were blocked.")
        }
        if cacheResolution.cacheIssues.contains(.contradictedByManifest) {
            caveats.append("Contradicted Source Atlas artifacts were blocked.")
        }
        if cacheResolution.cacheIssues.contains(.accessBoundaryUnavailable) ||
            accessDecision?.route == .unavailable {
            caveats.append("Live reference update is unavailable.")
        }
        if cacheResolution.fallback.conditions.contains(.missingPack) {
            caveats.append("No eligible public reference pack is loaded.")
        }
        if accessDecision?.coreLocalPlanningBlocked == false {
            caveats.append("Local planning remains available.")
        }

        return SourceAtlasLocalCompositionFallbackResult(
            mode: fallbackMode,
            publicReferencePackIDs: selectedPackIDs,
            caveats: Array(Set(caveats)).sorted(),
            runtimeOwnsFitTimingPriorityProof: true,
            sourceAtlasOwnsFinalUserSteps: false,
            createsFinalSchedule: false,
            blocksCoreLocalPlanning: false
        )
    }
}
