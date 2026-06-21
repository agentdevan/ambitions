import Foundation

struct LifeShapeBucketizerInput: Sendable, Hashable {
    let generatedAt: Date
    let currentDate: Date
    let selectedHorizon: LifeShapeHorizon
    let openProjection: OpenCapacityProjection
    let protectionProjection: ProtectionProjection
}

struct LifeShapeBucketizer: Sendable {
    func todayBuckets(from input: LifeShapeBucketizerInput) throws -> [LifeShapeBucket] {
        let protectedBuckets = try input.protectionProjection.protectedBoundaries.map { boundary in
            try protectedBucket(boundary: boundary, horizon: input.selectedHorizon)
        }
        let openBuckets = try input.openProjection.visibleWindows.map { window in
            try openBucket(window: window, fallback: input.openProjection.calendarFallback, horizon: input.selectedHorizon)
        }
        return (protectedBuckets + openBuckets).sorted {
            if $0.start != $1.start { return $0.start < $1.start }
            return $0.id < $1.id
        }
    }

    func projection(from input: LifeShapeBucketizerInput) throws -> LifeShapeProjection {
        let buckets = try todayBuckets(from: input)
        let nowBucketID = buckets.first {
            $0.start <= input.currentDate && input.currentDate <= $0.end
        }?.id
        let row = LifeShapeHorizonRow(
            id: "lifeshape.\(input.selectedHorizon.rawValue).runtime-row",
            horizon: input.selectedHorizon,
            summary: semanticSummary(open: input.openProjection, protected: input.protectionProjection),
            bucketIDs: buckets.map(\.id)
        )
        let anchor = LifeShapeTodayAnchor(
            date: input.currentDate,
            bucketID: nowBucketID,
            accessibilitySummary: nowBucketID == nil
                ? "Current time is outside a visible LifeShape bucket."
                : "Current time is inside the selected LifeShape bucket."
        )
        return try LifeShapeBucketBuilder.makeProjection(
            generatedAt: input.generatedAt,
            currentDate: input.currentDate,
            selectedLayer: .open,
            selectedHorizon: input.selectedHorizon,
            nowBucketID: nowBucketID,
            todayBuckets: buckets,
            horizonRows: [row],
            primaryCaption: input.openProjection.semanticSummary,
            primaryAction: nil,
            todayAnchor: anchor,
            semanticSummary: semanticSummary(open: input.openProjection, protected: input.protectionProjection)
        )
    }

    private func openBucket(
        window: OpenCapacityWindow,
        fallback: LifeShapeFallback?,
        horizon: LifeShapeHorizon
    ) throws -> LifeShapeBucket {
        let derivation = LifeShapeDerivation(
            inputRefs: window.derivation.inputRefs,
            ruleIDs: window.derivation.ruleIDs,
            clockDerivation: window.derivation.clockDerivation,
            fallbackState: fallback ?? window.derivation.fallbackState
        )
        return try LifeShapeBucketBuilder.makeBucket(
            id: "bucket.\(window.id)",
            start: window.start,
            end: window.end,
            horizon: horizon,
            layer: .open,
            reading: LifeShapeReading(
                horizon: horizon,
                kind: .open,
                title: window.band.bucketTitle,
                summary: window.canFitEstimatedStep
                    ? "This open window can hold a Step estimate."
                    : "This open window is transition room only.",
                capacityStatement: "\(window.usableMinutes) usable minutes after transition buffer.",
                sourceDetail: "Derived from local fixed points, protected boundaries, and manual availability.",
                fallbackState: fallback,
                accessibilitySummary: window.accessibilitySummary
            ),
            derivation: derivation,
            confidence: LifeShapeConfidence(
                level: fallback == nil ? .grounded : .partial,
                explanation: fallback == nil
                    ? "Open capacity was derived from local schedule inputs."
                    : fallback?.userVisibleSummary ?? "Open capacity used a local fallback."
            ),
            accessibilitySummary: window.accessibilitySummary
        )
    }

    private func protectedBucket(boundary: ProtectedBoundary, horizon: LifeShapeHorizon) throws -> LifeShapeBucket {
        let derivation = LifeShapeDerivation(
            inputRefs: [boundary.inputRef],
            ruleIDs: [
                "lifeshape.protected.visible-boundary",
                LifeShapeRuleID(rawValue: "lifeshape.protected.kind.\(boundary.kind.rawValue)")
            ],
            clockDerivation: "Protected boundary \(boundary.id) carries explicit start/end times."
        )
        let accessibilitySummary = "Protected. \(boundary.title). \(boundary.reason)"
        return try LifeShapeBucketBuilder.makeBucket(
            id: "bucket.protected.\(boundary.id)",
            start: boundary.start,
            end: boundary.end,
            horizon: horizon,
            layer: .protected,
            reading: LifeShapeReading(
                horizon: horizon,
                kind: .protected,
                title: "Protected",
                summary: boundary.title,
                capacityStatement: "This window is kept clear.",
                sourceDetail: boundary.reason,
                accessibilitySummary: accessibilitySummary
            ),
            protectedBoundary: boundary,
            derivation: derivation,
            confidence: LifeShapeConfidence(level: .grounded, explanation: "Protected boundary came from explicit local input."),
            accessibilitySummary: accessibilitySummary
        )
    }

    private func semanticSummary(open: OpenCapacityProjection, protected: ProtectionProjection) -> String {
        [
            open.semanticSummary,
            protected.semanticSummary
        ].joined(separator: " ")
    }
}

private extension OpenCapacityBand {
    var bucketTitle: String {
        switch self {
        case .transitionOnly: "Transition room"
        case .lightWindow: "Light window"
        case .focusedBlock: "Focused block"
        case .deepBlock: "Deep block"
        }
    }
}
