import Foundation

enum TimeMutationError: Error, Equatable {
    case unsupportedCommand
    case unsupportedCorrectionKind(String)
    case missingTimeTarget
    case noMutableBucket
}

enum TimeMutationActionKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case placeStep = "place_step"
    case protectWindow = "protect_window"
    case notUsable = "not_usable"
    case needsMoreTime = "needs_more_time"
    case keepClear = "keep_clear"

    static let correctionKinds: Set<TimeMutationActionKind> = [.notUsable, .needsMoreTime, .keepClear]

    var visibleChange: String {
        switch self {
        case .placeStep:
            "Step placed"
        case .protectWindow:
            "Window protected"
        case .notUsable:
            "Open mark removed"
        case .needsMoreTime:
            "Fit updated"
        case .keepClear:
            "Window kept clear"
        }
    }

    var todaySummary: String {
        switch self {
        case .placeStep:
            "Today recomputed Start here and Later Today after the Step was placed."
        case .protectWindow:
            "Today recomputed recommendations to avoid the protected window."
        case .notUsable:
            "Today recomputed recommendations to avoid the unavailable window."
        case .needsMoreTime:
            "Today recomputed the recommended Step after fit changed."
        case .keepClear:
            "Today recomputed recommendations to respect the clear window."
        }
    }
}

struct TodayTimeCouplingRecompute: Sendable, Equatable {
    let causeMutationID: String
    let actionKind: TimeMutationActionKind
    let beforeStartHereBucketID: String?
    let afterStartHereBucketID: String?
    let beforeStartHereStepID: String?
    let afterStartHereStepID: String?
    let beforeAvoidedBucketIDs: [String]
    let afterAvoidedBucketIDs: [String]
    let affectedBucketIDs: [String]
    let proofLabel: String
    let summary: String

    var recomputedToday: Bool {
        causeMutationID.isEmpty == false &&
            proofLabel.isEmpty == false &&
            summary.isEmpty == false &&
            affectedBucketIDs.isEmpty == false
    }

    var hasTimeCauseProof: Bool {
        proofLabel.contains(causeMutationID)
    }

    var todayRecommendationAvoidsAffectedWindow: Bool {
        guard let afterStartHereBucketID else { return true }
        return affectedBucketIDs.contains(afterStartHereBucketID) == false
    }
}

struct TimeMutation: Identifiable, Sendable, Equatable {
    let id: String
    let actionKind: TimeMutationActionKind
    let commandID: String
    let beforeProjection: LifeShapeProjection
    let afterProjection: LifeShapeProjection
    let affectedBucketIDs: [String]
    let todayRecompute: TodayTimeCouplingRecompute

    static func make(
        command: AmbitionsCommand,
        beforeProjection: LifeShapeProjection
    ) throws -> TimeMutation {
        let actionKind = try actionKind(from: command)
        let targetBucket = try targetBucket(in: beforeProjection, command: command)
        let afterProjection = try projection(after: actionKind, command: command, beforeProjection: beforeProjection, targetBucket: targetBucket)
        let mutationID = "time.mutation.\(command.id).\(actionKind.rawValue)"
        let affectedBucketIDs = affectedBuckets(before: beforeProjection, after: afterProjection, targetBucketID: targetBucket.id)
        let todayRecompute = TodayLens.recomputeAfterTimeMutation(
            mutationID: mutationID,
            actionKind: actionKind,
            before: beforeProjection,
            after: afterProjection,
            affectedBucketIDs: affectedBucketIDs
        )

        return TimeMutation(
            id: mutationID,
            actionKind: actionKind,
            commandID: command.id,
            beforeProjection: beforeProjection,
            afterProjection: afterProjection,
            affectedBucketIDs: affectedBucketIDs,
            todayRecompute: todayRecompute
        )
    }

    private static func actionKind(from command: AmbitionsCommand) throws -> TimeMutationActionKind {
        switch command.kind {
        case .placeStepInTime:
            return .placeStep
        case .protectTimeWindow:
            return .protectWindow
        case .correctTimeWindow:
            guard let rawKind = command.payload.metadata["correctionKind"] else {
                throw TimeMutationError.unsupportedCommand
            }
            guard let kind = TimeMutationActionKind(rawValue: rawKind), TimeMutationActionKind.correctionKinds.contains(kind) else {
                throw TimeMutationError.unsupportedCorrectionKind(rawKind)
            }
            return kind
        default:
            throw TimeMutationError.unsupportedCommand
        }
    }

    private static func targetBucket(
        in projection: LifeShapeProjection,
        command: AmbitionsCommand
    ) throws -> LifeShapeBucket {
        guard let timeID = command.target.timeID else { throw TimeMutationError.missingTimeTarget }
        guard let bucket = projection.todayBuckets.first(where: { bucket in
            bucket.id == timeID || bucket.id == "bucket.\(timeID)" || bucket.id.hasSuffix(".\(timeID)")
        }) else {
            throw TimeMutationError.noMutableBucket
        }
        return bucket
    }

    private static func projection(
        after actionKind: TimeMutationActionKind,
        command: AmbitionsCommand,
        beforeProjection: LifeShapeProjection,
        targetBucket: LifeShapeBucket
    ) throws -> LifeShapeProjection {
        let updatedBuckets: [LifeShapeBucket]
        switch actionKind {
        case .placeStep:
            updatedBuckets = try beforeProjection.todayBuckets.replacing(
                targetBucket.id,
                with: placedStepBucket(from: targetBucket, command: command)
            )
        case .protectWindow:
            updatedBuckets = try beforeProjection.todayBuckets.replacing(
                targetBucket.id,
                with: protectedBucket(from: targetBucket, command: command, kind: .explicit)
            )
        case .notUsable:
            updatedBuckets = beforeProjection.todayBuckets.filter { $0.id != targetBucket.id }
        case .needsMoreTime:
            updatedBuckets = try beforeProjection.todayBuckets.replacing(
                targetBucket.id,
                with: needsMoreTimeBucket(from: targetBucket, command: command)
            )
        case .keepClear:
            updatedBuckets = try beforeProjection.todayBuckets.replacing(
                targetBucket.id,
                with: protectedBucket(from: targetBucket, command: command, kind: .keepClearCorrection)
            )
        }

        return try makeProjection(
            from: beforeProjection,
            buckets: updatedBuckets,
            actionKind: actionKind,
            targetBucketID: targetBucket.id
        )
    }

    private static func placedStepBucket(
        from bucket: LifeShapeBucket,
        command: AmbitionsCommand
    ) throws -> LifeShapeBucket {
        let stepMinutes = max(1, Int(command.payload.metadata["durationMinutes"] ?? "") ?? 15)
        let shortenedEnd = max(bucket.start, bucket.end.addingTimeInterval(Double(-stepMinutes * 60)))
        let remainingMinutes = max(0, Int(shortenedEnd.timeIntervalSince(bucket.start) / 60))
        let stepTitle = command.payload.title ?? "Step"
        let stepID = command.target.stepID ?? "step.\(command.id)"
        return try LifeShapeBucketBuilder.makeBucket(
            id: bucket.id,
            start: bucket.start,
            end: shortenedEnd,
            horizon: bucket.horizon,
            layer: .open,
            reading: LifeShapeReading(
                horizon: bucket.horizon,
                kind: .open,
                title: "Step placed",
                summary: "\(stepTitle) is placed in this window.",
                capacityStatement: "\(remainingMinutes) minutes remain after this Step.",
                sourceDetail: "Changed from a local Time action.",
                fallbackState: bucket.reading.fallbackState,
                accessibilitySummary: "Step placed. \(remainingMinutes) minutes remain."
            ),
            fixedPoints: bucket.fixedPoints,
            protectedBoundary: bucket.protectedBoundary,
            recommendedStepID: stepID,
            primaryAction: LifeShapePrimaryAction(
                id: "lifeshape.action.open-step.\(stepID)",
                title: "Open step",
                actionKind: "open_step"
            ),
            correctionOptions: bucket.correctionOptions,
            derivation: derivation(from: bucket, command: command, rule: "lifeshape.time-mutation.place-step"),
            confidence: LifeShapeConfidence(level: .grounded, explanation: "Step placement came from an explicit local Time action."),
            accessibilitySummary: "Step placed. \(remainingMinutes) minutes remain."
        )
    }

    private static func protectedBucket(
        from bucket: LifeShapeBucket,
        command: AmbitionsCommand,
        kind: ProtectedBoundaryKind
    ) throws -> LifeShapeBucket {
        let title = command.payload.title ?? (kind == .keepClearCorrection ? "Keep this clear" : "Protected window")
        let boundary = ProtectedBoundary(
            id: "time.boundary.\(command.id).\(kind.rawValue)",
            title: title,
            start: bucket.start,
            end: bucket.end,
            reason: kind == .keepClearCorrection ? "User asked Time to keep this clear." : "User protected this Time window.",
            kind: kind,
            inputRef: LifeShapeInputRef(id: "time.command.\(command.id)", kind: .userCorrection, label: title)
        )
        let accessibilitySummary = "Protected. \(title). This window is kept clear."
        return try LifeShapeBucketBuilder.makeBucket(
            id: bucket.id,
            start: bucket.start,
            end: bucket.end,
            horizon: bucket.horizon,
            layer: .protected,
            reading: LifeShapeReading(
                horizon: bucket.horizon,
                kind: .protected,
                title: "Protected",
                summary: title,
                capacityStatement: "This window is kept clear.",
                sourceDetail: boundary.reason,
                accessibilitySummary: accessibilitySummary
            ),
            fixedPoints: bucket.fixedPoints,
            protectedBoundary: boundary,
            recommendedStepID: nil,
            primaryAction: nil,
            correctionOptions: [],
            derivation: derivation(from: bucket, command: command, rule: "lifeshape.time-mutation.protect-window"),
            confidence: LifeShapeConfidence(level: .grounded, explanation: "Protected boundary came from an explicit local Time action."),
            accessibilitySummary: accessibilitySummary
        )
    }

    private static func needsMoreTimeBucket(
        from bucket: LifeShapeBucket,
        command: AmbitionsCommand
    ) throws -> LifeShapeBucket {
        try LifeShapeBucketBuilder.makeBucket(
            id: bucket.id,
            start: bucket.start,
            end: bucket.end,
            horizon: bucket.horizon,
            layer: bucket.layer,
            reading: LifeShapeReading(
                horizon: bucket.horizon,
                kind: bucket.reading.kind,
                title: bucket.reading.title,
                summary: "This Step needs more time than the window can hold.",
                capacityStatement: bucket.reading.capacityStatement,
                sourceDetail: "Changed from a local Time correction.",
                fallbackState: bucket.reading.fallbackState,
                accessibilitySummary: "Fit changed. Recommended Step may change."
            ),
            fixedPoints: bucket.fixedPoints,
            protectedBoundary: bucket.protectedBoundary,
            recommendedStepID: nil,
            primaryAction: nil,
            correctionOptions: bucket.correctionOptions,
            derivation: derivation(from: bucket, command: command, rule: "lifeshape.time-mutation.needs-more-time"),
            confidence: LifeShapeConfidence(level: .grounded, explanation: "Fit changed from an explicit local Time correction."),
            accessibilitySummary: "Fit changed. Recommended Step may change."
        )
    }

    private static func makeProjection(
        from projection: LifeShapeProjection,
        buckets: [LifeShapeBucket],
        actionKind: TimeMutationActionKind,
        targetBucketID: String
    ) throws -> LifeShapeProjection {
        let sortedBuckets = buckets.sorted {
            if $0.start != $1.start { return $0.start < $1.start }
            return $0.id < $1.id
        }
        let nowBucketID = sortedBuckets.first {
            $0.start <= projection.currentDate && projection.currentDate <= $0.end
        }?.id
        let row = LifeShapeHorizonRow(
            id: "lifeshape.\(projection.selectedHorizon.rawValue).time-mutation-row",
            horizon: projection.selectedHorizon,
            summary: actionKind.todaySummary,
            bucketIDs: sortedBuckets.map(\.id)
        )
        let anchor = LifeShapeTodayAnchor(
            date: projection.currentDate,
            bucketID: nowBucketID,
            accessibilitySummary: nowBucketID == nil
                ? "Current time is outside a visible LifeShape bucket after Time changed."
                : "Current time remains inside the selected LifeShape bucket after Time changed."
        )
        return try LifeShapeBucketBuilder.makeProjection(
            generatedAt: projection.generatedAt,
            currentDate: projection.currentDate,
            selectedLayer: projection.selectedLayer,
            selectedHorizon: projection.selectedHorizon,
            nowBucketID: nowBucketID,
            todayBuckets: sortedBuckets,
            horizonRows: [row],
            primaryCaption: actionKind.visibleChange,
            primaryAction: sortedBuckets.first(where: { $0.layer == .open && $0.primaryAction != nil })?.primaryAction,
            todayAnchor: anchor,
            semanticSummary: "\(actionKind.visibleChange). \(actionKind.todaySummary)"
        )
    }

    private static func derivation(
        from bucket: LifeShapeBucket,
        command: AmbitionsCommand,
        rule: LifeShapeRuleID
    ) -> LifeShapeDerivation {
        let commandRef = LifeShapeInputRef(
            id: "time.command.\(command.id)",
            kind: .userCorrection,
            label: command.payload.title ?? command.kind.rawValue
        )
        let inputRefs = Array(Set(bucket.derivation.inputRefs + [commandRef])).sorted { $0.id < $1.id }
        let ruleIDs = Array(Set(bucket.derivation.ruleIDs + [rule])).sorted { $0.rawValue < $1.rawValue }
        return LifeShapeDerivation(
            inputRefs: inputRefs,
            ruleIDs: ruleIDs,
            clockDerivation: bucket.derivation.clockDerivation,
            fallbackState: bucket.derivation.fallbackState
        )
    }

    private static func affectedBuckets(
        before: LifeShapeProjection,
        after: LifeShapeProjection,
        targetBucketID: String
    ) -> [String] {
        let beforeIDs = Set(before.todayBuckets.map(\.id))
        let afterIDs = Set(after.todayBuckets.map(\.id))
        return Array(beforeIDs.symmetricDifference(afterIDs).union([targetBucketID])).sorted()
    }
}

private extension Array where Element == LifeShapeBucket {
    func replacing(_ id: String, with replacement: LifeShapeBucket) -> [LifeShapeBucket] {
        map { $0.id == id ? replacement : $0 }
    }
}
