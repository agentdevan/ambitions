import Foundation

struct ProtectionEngineInput: Sendable, Hashable {
    let explicitProtectedBoundaries: [ProtectedBoundary]
    let sleepAwayVacationDefaults: [ProtectedBoundary]
    let fixedCommitments: [FixedPoint]
    let keepClearCorrections: [ProtectedBoundary]

    init(
        explicitProtectedBoundaries: [ProtectedBoundary] = [],
        sleepAwayVacationDefaults: [ProtectedBoundary] = [],
        fixedCommitments: [FixedPoint] = [],
        keepClearCorrections: [ProtectedBoundary] = []
    ) {
        self.explicitProtectedBoundaries = explicitProtectedBoundaries
        self.sleepAwayVacationDefaults = sleepAwayVacationDefaults
        self.fixedCommitments = fixedCommitments
        self.keepClearCorrections = keepClearCorrections
    }
}

struct ProtectionProjection: Sendable, Hashable {
    let protectedBoundaries: [ProtectedBoundary]
    let derivation: LifeShapeDerivation
    let semanticSummary: String
    let accessibilitySummary: String
}

struct ProtectionEngine: Sendable {
    func project(_ input: ProtectionEngineInput) -> ProtectionProjection {
        let fixedCommitmentBoundaries = input.fixedCommitments
            .filter(\.isNonNegotiable)
            .map { fixedPoint in
                ProtectedBoundary(
                    id: "protected.fixed.\(fixedPoint.id)",
                    title: fixedPoint.title,
                    start: fixedPoint.start,
                    end: fixedPoint.end,
                    reason: "Fixed commitment marked non-negotiable.",
                    kind: .fixedCommitment,
                    inputRef: fixedPoint.inputRef
                )
            }
        let boundaries = deduplicated(
            input.explicitProtectedBoundaries +
                input.sleepAwayVacationDefaults +
                fixedCommitmentBoundaries +
                input.keepClearCorrections
        )
        let derivation = LifeShapeDerivation(
            inputRefs: inputRefs(from: boundaries),
            ruleIDs: [
                "lifeshape.protected.explicit-only",
                "lifeshape.protected.keep-clear-corrections",
                "lifeshape.protected.non-negotiable-fixed-points"
            ],
            clockDerivation: "Protection does not infer from vibe; it uses explicit protected inputs only."
        )
        let summary = boundaries.isEmpty
            ? "No protected boundary is marked yet."
            : "\(boundaries.count) protected boundary\(boundaries.count == 1 ? "" : "ies") kept clear from explicit local inputs."
        return ProtectionProjection(
            protectedBoundaries: boundaries,
            derivation: derivation,
            semanticSummary: summary,
            accessibilitySummary: summary
        )
    }

    private func deduplicated(_ boundaries: [ProtectedBoundary]) -> [ProtectedBoundary] {
        var seen: Set<String> = []
        return boundaries
            .sorted {
                if $0.start != $1.start { return $0.start < $1.start }
                return $0.id < $1.id
            }
            .filter { boundary in
                let inserted = seen.insert(boundary.id)
                return inserted.inserted
            }
    }

    private func inputRefs(from boundaries: [ProtectedBoundary]) -> [LifeShapeInputRef] {
        let refs = boundaries.map(\.inputRef)
        if refs.isEmpty {
            return [LifeShapeInputRef(id: "lifeshape.protection.none", kind: .localDefault, label: "No protected boundaries marked")]
        }
        return Array(Set(refs)).sorted { $0.id < $1.id }
    }
}
