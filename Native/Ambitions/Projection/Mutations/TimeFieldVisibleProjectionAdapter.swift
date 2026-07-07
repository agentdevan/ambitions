import Foundation

extension LifeShapeProjection {
    static func fromVisibleTimeField(
        _ field: LifeShapeFieldState,
        selectedMark: LifeShapeSemanticMark?,
        preferredLayer: LifeShapeLayer,
        placementCandidate: TimePlacementCandidate? = nil,
        now: Date
    ) throws -> LifeShapeProjection {
        let marks = orderedMarks(field.semanticMarks, selectedMark: selectedMark, preferredLayer: preferredLayer)
        let buckets = try marks.enumerated().map { index, mark in
            try bucket(from: mark, field: field, placementCandidate: placementCandidate, now: now, index: index)
        }
        let nowBucketID = buckets.first?.id
        let row = LifeShapeHorizonRow(
            id: "lifeshape.\(field.defaultHorizon.rawValue).visible-time-field-row",
            horizon: field.defaultHorizon,
            summary: field.reading(for: field.defaultHorizon).accessibilitySummary,
            bucketIDs: buckets.map(\.id)
        )
        let anchor = LifeShapeTodayAnchor(
            date: now,
            bucketID: nowBucketID,
            accessibilitySummary: nowBucketID == nil
                ? "Today has no visible Time bucket selected."
                : "Today is anchored to the selected Time field bucket."
        )
        return try LifeShapeBucketBuilder.makeProjection(
            generatedAt: now,
            currentDate: now,
            selectedLayer: preferredLayer,
            selectedHorizon: field.defaultHorizon,
            nowBucketID: nowBucketID,
            todayBuckets: buckets,
            horizonRows: [row],
            primaryCaption: field.reading(for: field.defaultHorizon).capacityStatement,
            primaryAction: buckets.first(where: { $0.layer == .open })?.primaryAction,
            todayAnchor: anchor,
            semanticSummary: [
                "Visible Time field mutation projection.",
                field.reading(for: field.defaultHorizon).accessibilitySummary
            ].joined(separator: " ")
        )
    }

    func targetBucket(for selectedMark: LifeShapeSemanticMark?, preferredLayer: LifeShapeLayer) -> LifeShapeBucket? {
        if let selectedMark,
           let bucket = todayBuckets.first(where: { $0.id.hasSuffix(Self.idSuffix(for: selectedMark)) }) {
            return bucket
        }
        return todayBuckets.first { $0.layer == preferredLayer } ?? todayBuckets.first
    }

    private static func orderedMarks(
        _ marks: [LifeShapeSemanticMark],
        selectedMark: LifeShapeSemanticMark?,
        preferredLayer: LifeShapeLayer
    ) -> [LifeShapeSemanticMark] {
        let preferred = marks.filter { $0.kind.layer == preferredLayer }
        let fallback = preferred.isEmpty ? marks.filter { [.open, .protected].contains($0.kind.layer) } : preferred
        guard fallback.isEmpty == false else {
            return [
                LifeShapeSemanticMark(
                    kind: preferredLayer == .protected ? .protectedTime : .freeTimeQuality,
                    valueLabel: preferredLayer.title,
                    detail: "Visible Time field bucket.",
                    intensity: 0.5,
                    visualState: .selected,
                    inputRefs: [LifeShapeInputRef(id: "time.visible-field", kind: .localDefault, label: "Visible Time field")],
                    ruleIDs: ["lifeshape.visible-field.mutation-target"],
                    accessibilitySummary: "Visible Time field bucket."
                )
            ]
        }
        guard let selectedMark else { return fallback }
        return fallback.sorted { left, _ in left.id == selectedMark.id }
    }

    private static func bucket(
        from mark: LifeShapeSemanticMark,
        field: LifeShapeFieldState,
        placementCandidate: TimePlacementCandidate?,
        now: Date,
        index: Int
    ) throws -> LifeShapeBucket {
        let start = now.addingTimeInterval(Double(index * 3600))
        let end = start.addingTimeInterval(Double(max(20, Int(mark.intensity * 90)) * 60))
        let inputRefs = mark.inputRefs.isEmpty
            ? [LifeShapeInputRef(id: "time.visible.\(mark.id)", kind: .localDefault, label: mark.kind.title)]
            : mark.inputRefs
        let ruleIDs = mark.ruleIDs.isEmpty ? [LifeShapeRuleID(rawValue: "lifeshape.visible.\(mark.kind.rawValue)")] : mark.ruleIDs
        let derivation = LifeShapeDerivation(
            inputRefs: inputRefs,
            ruleIDs: ruleIDs,
            clockDerivation: "Visible Time field mark \(mark.id) was converted into a runtime-validated mutation bucket."
        )
        let layer = mark.kind.layer
        let protectedBoundary = layer == .protected
            ? ProtectedBoundary(
                id: "visible.\(mark.id)",
                title: mark.kind.title,
                start: start,
                end: end,
                reason: mark.detail,
                inputRef: inputRefs[0]
            )
            : nil
        return try LifeShapeBucketBuilder.makeBucket(
            id: "bucket.visible.\(idSuffix(for: mark))",
            start: start,
            end: end,
            horizon: field.defaultHorizon,
            layer: layer,
            reading: LifeShapeReading(
                horizon: field.defaultHorizon,
                kind: mark.kind.readingKind,
                title: mark.kind.title,
                summary: mark.detail,
                capacityStatement: mark.valueLabel,
                sourceDetail: "Derived from the visible Time field mark.",
                accessibilitySummary: mark.accessibilitySummary
            ),
            protectedBoundary: protectedBoundary,
            recommendedStepID: layer == .open ? placementCandidate?.stepID : nil,
            primaryAction: layer == .open && placementCandidate?.isRealStep == true
                ? LifeShapePrimaryAction(id: "lifeshape.action.place-step.\(mark.id)", title: "Place Step", actionKind: TimeMutationActionKind.placeStep.rawValue)
                : nil,
            correctionOptions: [
                LifeShapeCorrection(id: "correction.not-usable.\(mark.id)", kind: .review, title: "Not usable", accessibilitySummary: "Mark this Time window as not usable."),
                LifeShapeCorrection(id: "correction.keep-clear.\(mark.id)", kind: .protect, title: "Keep this clear", accessibilitySummary: "Protect this Time window.")
            ],
            derivation: derivation,
            confidence: LifeShapeConfidence(level: .grounded, explanation: "Mutation target came from a visible Life Calendar mark."),
            accessibilitySummary: layer == .open && placementCandidate == nil
                ? "\(mark.accessibilitySummary) Placement waits for a real Step."
                : mark.accessibilitySummary
        )
    }

    private static func idSuffix(for mark: LifeShapeSemanticMark) -> String {
        "\(mark.kind.rawValue).\(mark.id)"
    }
}

extension LifeShapeSemanticMarkKind {
    var layer: LifeShapeLayer {
        switch self {
        case .protectedTime, .recoveryNeed:
            .protected
        case .pressure, .cognitiveLoad:
            .pressure
        case .transitionFriction:
            .buffer
        default:
            .open
        }
    }

    var readingKind: LifeShapeReadingKind {
        switch layer {
        case .protected:
            .protected
        case .pressure:
            .pressure
        case .buffer:
            .buffer
        case .open:
            .open
        }
    }
}
