import Foundation

enum FreshnessEngineStatus: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case current
    case stale
    case staleCritical = "stale_critical"
    case contradicted
    case revoked
    case missing
}

struct FreshnessEngineVerdict: Codable, Sendable, Equatable, Hashable {
    let packID: String
    let status: FreshnessEngineStatus
    let manifestAgeDays: Int
    let changedClaimIDs: [String]
    let rollbackPointers: [String: String]

    var blocksCurrentUse: Bool {
        switch status {
        case .current, .stale:
            return false
        case .staleCritical, .contradicted, .revoked, .missing:
            return true
        }
    }
}

struct FreshnessEngine: Sendable, Equatable, Hashable {
    func evaluate(
        manifest: SourceAtlasFreshnessManifest,
        packID: String,
        checkedAt: Date,
        staleAfterDays: Int = 30,
        staleCriticalAfterDays: Int = 90
    ) -> FreshnessEngineVerdict {
        let trimmedPackID = packID.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let entry = manifest.packIndex.first(where: { $0.packID == trimmedPackID }) else {
            return FreshnessEngineVerdict(
                packID: trimmedPackID,
                status: .missing,
                manifestAgeDays: ageDays(from: manifest.publishedAt, to: checkedAt),
                changedClaimIDs: [],
                rollbackPointers: [:]
            )
        }

        let age = ageDays(from: manifest.publishedAt, to: checkedAt)
        let blockingStates = Set(entry.claimStateBuckets.flatMap { bucket in
            bucket.claimIDs.isEmpty ? [bucket.state] : [bucket.state]
        } + manifest.globalClaimStateBuckets.map(\.state))

        let status: FreshnessEngineStatus
        if blockingStates.contains(.revoked) {
            status = .revoked
        } else if blockingStates.contains(.contradicted) {
            status = .contradicted
        } else if age >= staleCriticalAfterDays {
            status = .staleCritical
        } else if age >= staleAfterDays || blockingStates.contains(.stale) {
            status = .stale
        } else {
            status = .current
        }

        return FreshnessEngineVerdict(
            packID: trimmedPackID,
            status: status,
            manifestAgeDays: age,
            changedClaimIDs: entry.changedClaimIDs,
            rollbackPointers: entry.rollbackPointers
        )
    }

    private func ageDays(from publishedAt: Date, to checkedAt: Date) -> Int {
        max(0, Int(checkedAt.timeIntervalSince(publishedAt) / 86_400))
    }
}
