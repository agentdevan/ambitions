import Foundation

/// Local-only deterministic proof-mode router for harness validation.
///
/// This type is intentionally pure: it has no persistence writes, no network access,
/// no clock dependency, and no production user-data mutation. It exists to prove
/// the shape of Ambitions' same-intent / different-context recommendation moat.
struct AppDrivingProofModeRouter: Sendable {
    enum EnergyLevel: String, Codable, Sendable, Equatable {
        case low
        case medium
        case high
    }

    struct LocalContext: Codable, Sendable, Equatable {
        let id: String
        let protectedTimeMinutes: Int
        let openWindowMinutes: Int
        let energy: EnergyLevel
        let closureResidueCount: Int
        let sourceFreshnessMinutes: Int

        init(
            id: String,
            protectedTimeMinutes: Int,
            openWindowMinutes: Int,
            energy: EnergyLevel,
            closureResidueCount: Int,
            sourceFreshnessMinutes: Int
        ) {
            self.id = id
            self.protectedTimeMinutes = protectedTimeMinutes
            self.openWindowMinutes = openWindowMinutes
            self.energy = energy
            self.closureResidueCount = closureResidueCount
            self.sourceFreshnessMinutes = sourceFreshnessMinutes
        }
    }

    struct ProofOutput: Codable, Sendable, Equatable {
        let intent: String
        let contextID: String
        let recommendedStep: String
        let whyNow: String
        let timeFit: String
        let plannedMinutes: Int
        let receiptID: String
        let replayID: String
        let sourceFreshness: String
        let claimsNotMade: [String]
    }

    func route(intent: String, context: LocalContext) -> ProofOutput {
        let normalizedIntent = intent.trimmingCharacters(in: .whitespacesAndNewlines)
        let recommendation = recommendationShape(for: context)
        let plannedMinutes = plannedMinutes(for: context)
        let receiptSeed = stableSeed(intent: normalizedIntent, context: context, suffix: "receipt")
        let replaySeed = stableSeed(intent: normalizedIntent, context: context, suffix: "replay")

        return ProofOutput(
            intent: normalizedIntent,
            contextID: context.id,
            recommendedStep: recommendation.step,
            whyNow: recommendation.whyNow,
            timeFit: "Fits \(plannedMinutes)m inside \(context.openWindowMinutes)m open window with \(context.protectedTimeMinutes)m protected.",
            plannedMinutes: plannedMinutes,
            receiptID: "proof-receipt-\(receiptSeed)",
            replayID: "proof-replay-\(replaySeed)",
            sourceFreshness: context.sourceFreshnessMinutes <= 30 ? "fresh" : "stale-review-needed",
            claimsNotMade: Self.claimsNotMade
        )
    }

    func routePair(intent: String, first: LocalContext, second: LocalContext) -> [ProofOutput] {
        [route(intent: intent, context: first), route(intent: intent, context: second)]
    }

    static let certificationExamIntent = "Prepare for a certification exam without burning out."

    static let protectedTimeHeavyContext = LocalContext(
        id: "protected_time_heavy_low_energy",
        protectedTimeMinutes: 420,
        openWindowMinutes: 25,
        energy: .low,
        closureResidueCount: 3,
        sourceFreshnessMinutes: 12
    )

    static let openDeepWorkContext = LocalContext(
        id: "open_deep_work_medium_energy",
        protectedTimeMinutes: 60,
        openWindowMinutes: 95,
        energy: .medium,
        closureResidueCount: 0,
        sourceFreshnessMinutes: 8
    )

    static let claimsNotMade: [String] = [
        "No production user data was mutated.",
        "No cloud AI or hosted inference was used.",
        "No build success claim is made by this router alone.",
        "No UI test success claim is made by this router alone.",
        "No release readiness claim is made.",
        "No TestFlight readiness claim is made.",
        "No App Store readiness claim is made.",
        "No device validation claim is made.",
        "No accessibility validation claim is made.",
        "No privacy/legal approval claim is made."
    ]

    private func recommendationShape(for context: LocalContext) -> (step: String, whyNow: String) {
        if context.energy == .low || context.openWindowMinutes < 35 || context.closureResidueCount > 0 {
            return (
                "Review one exam topic for 15 minutes and close the loop with a Still Counts note.",
                "Protected time and recovery pressure make a short, closure-aware step safer than deep work."
            )
        }

        return (
            "Start a 60-minute focused exam practice block with proof notes after completion.",
            "A longer open window and steadier energy can support focused progress without forcing the day."
        )
    }

    private func plannedMinutes(for context: LocalContext) -> Int {
        if context.energy == .low || context.openWindowMinutes < 35 || context.closureResidueCount > 0 {
            return min(15, max(10, context.openWindowMinutes))
        }
        return min(60, max(30, context.openWindowMinutes - 15))
    }

    private func stableSeed(intent: String, context: LocalContext, suffix: String) -> String {
        let raw = "\(intent)|\(context.id)|\(context.protectedTimeMinutes)|\(context.openWindowMinutes)|\(context.energy.rawValue)|\(context.closureResidueCount)|\(context.sourceFreshnessMinutes)|\(suffix)"
        let hash = raw.unicodeScalars.reduce(UInt64(1469598103934665603)) { partial, scalar in
            (partial ^ UInt64(scalar.value)) &* 1099511628211
        }
        return String(hash, radix: 16)
    }
}
