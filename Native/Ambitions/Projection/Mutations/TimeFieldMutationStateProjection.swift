import Foundation

extension TimeLifeSuiteState {
    func applying(timeMutation: TimeMutation, runtimeMutation: RuntimeMutation) -> TimeLifeSuiteState {
        let field = field.applying(timeMutation: timeMutation, runtimeMutation: runtimeMutation)
        return TimeLifeSuiteState(
            title: title,
            subtitle: subtitle,
            shapes: shapes,
            field: field,
            drillDown: drillDown,
            calendarBoundaryLabel: calendarBoundaryLabel,
            manualFallbackLabel: manualFallbackLabel,
            trustLabel: trustLabel
        )
    }
}

extension LifeShapeFieldState {
    func applying(timeMutation: TimeMutation, runtimeMutation: RuntimeMutation) -> LifeShapeFieldState {
        let after = timeMutation.afterProjection
        let openBuckets = after.todayBuckets.filter { $0.layer == .open }
        let protectedBuckets = after.todayBuckets.filter { $0.layer == .protected }
        let bufferBuckets = after.todayBuckets.filter { $0.layer == .buffer }
        let fit: LifeShapeCapacityFit = [.makeTodayLighter, .addBuffer].contains(timeMutation.actionKind) ? .steady : (openBuckets.isEmpty ? .tight : .steady)
        let pressureLabel = timeMutation.actionKind == .makeTodayLighter ? "Light" : (fit == .tight ? "Tight" : "Crowded")
        let pressureDetail = timeMutation.actionKind == .makeTodayLighter
            ? "Today is lighter after one ask was narrowed."
            : timeMutation.todayRecompute.summary
        let bufferLabel = timeMutation.actionKind == .addBuffer ? "Add room" : (bufferBuckets.isEmpty ? "Room available" : "Keep light")
        let bufferDetail = timeMutation.actionKind == .addBuffer
            ? "Room was added around this fixed point."
            : (bufferBuckets.isEmpty ? "Room available around the next block." : "\(bufferBuckets.count) buffer mark\(bufferBuckets.count == 1 ? "" : "s") shape schedule room.")
        let weekReading = LifeShapeReading(
            horizon: after.selectedHorizon,
            title: timeMutation.actionKind.visibleChange,
            summary: after.semanticSummary,
            capacityStatement: after.primaryCaption,
            sourceDetail: runtimeMutation.stageMutation.proofArtifact.label,
            accessibilitySummary: runtimeMutation.stageMutation.accessibilityAnnouncement.message
        )
        let semanticMarks = Self.semanticMarks(from: after, runtimeMutation: runtimeMutation)
        return LifeShapeFieldState(
            defaultHorizon: after.selectedHorizon,
            capacityFit: fit,
            segments: [
                LifeShapeSegment(
                    kind: .openTime,
                    detail: openBuckets.isEmpty ? "No open bucket remains after this Time change." : "\(openBuckets.count) open bucket\(openBuckets.count == 1 ? "" : "s") remain after this Time change.",
                    valueLabel: "\(openBuckets.count) open",
                    weight: Double(openBuckets.count) / Double(max(after.todayBuckets.count, 1)),
                    visualState: openBuckets.isEmpty ? .warning : .selected
                ),
                LifeShapeSegment(
                    kind: .protectedTime,
                    detail: protectedBuckets.isEmpty ? "No protected boundary is active." : "\(protectedBuckets.count) protected boundary/bucket\(protectedBuckets.count == 1 ? "" : "s") now shape Time.",
                    valueLabel: "\(protectedBuckets.count) protected",
                    weight: Double(protectedBuckets.count) / Double(max(after.todayBuckets.count, 1)),
                    visualState: protectedBuckets.isEmpty ? .default : .selected
                ),
                LifeShapeSegment(
                    kind: .pressure,
                    detail: pressureDetail,
                    valueLabel: pressureLabel,
                    weight: timeMutation.actionKind == .makeTodayLighter ? 0.24 : (fit == .tight ? 0.72 : 0.48),
                    visualState: fit.visualState
                ),
                LifeShapeSegment(
                    kind: .buffer,
                    detail: bufferDetail,
                    valueLabel: bufferLabel,
                    weight: timeMutation.actionKind == .addBuffer ? 0.38 : 0.22,
                    visualState: .selected
                ),
                LifeShapeSegment(
                    kind: .source,
                    detail: runtimeMutation.stageMutation.receipt.inspectionLabel,
                    valueLabel: "Proof",
                    weight: 0.44,
                    visualState: .selected
                )
            ],
            semanticMarks: semanticMarks,
            renderState: .receiptAttached,
            readings: [
                .day: weekReading,
                .week: weekReading,
                .month: reading(for: .month),
                .year: reading(for: .year)
            ],
            placementCandidate: timeMutation.actionKind == .placeStep ? nil : placementCandidate,
            placementUnavailableReason: timeMutation.actionKind == .placeStep
                ? "Step was placed in this local Time window."
                : placementUnavailableReason,
            calendarRows: Self.calendarRows(
                after: after,
                actionKind: timeMutation.actionKind,
                fit: fit,
                placementCandidate: timeMutation.actionKind == .placeStep ? nil : placementCandidate
            ),
            sourceState: sourceState,
            reflowProposal: LifeShapeReflowProposal(
                title: runtimeMutation.stageMutation.visibleUserFacingChange,
                detail: timeMutation.todayRecompute.summary,
                actionTitle: runtimeMutation.stageMutation.undoAvailability.label,
                visualState: .selected
            ),
            receipt: LifeShapeReceipt(
                title: runtimeMutation.stageMutation.proofArtifact.label,
                detail: runtimeMutation.stageMutation.receipt.inspectionLabel,
                ageLabel: runtimeMutation.stageMutation.proofArtifact.artifactID,
                visualState: .selected
            ),
            continuityDockItems: [
                runtimeMutation.stageMutation.visibleUserFacingChange,
                "Today recomputed",
                timeMutation.actionKind == .makeTodayLighter ? "Later Today updated" : nil,
                timeMutation.actionKind == .addBuffer ? "Current window updated" : nil,
                runtimeMutation.stageMutation.undoAvailability.label
            ].compactMap { $0 }
        )
    }

    static func semanticMarks(from projection: LifeShapeProjection, runtimeMutation: RuntimeMutation) -> [LifeShapeSemanticMark] {
        var marks = projection.todayBuckets.map { bucket in
            LifeShapeSemanticMark(
                kind: bucket.layer.semanticMarkKind,
                valueLabel: bucket.reading.capacityStatement,
                detail: bucket.reading.summary,
                intensity: bucket.layer == .protected ? 0.72 : (bucket.layer == .pressure ? 0.30 : (bucket.layer == .buffer ? 0.38 : 0.52)),
                visualState: bucket.layer == .protected ? .selected : .selected,
                inputRefs: bucket.derivation.inputRefs,
                ruleIDs: bucket.derivation.ruleIDs,
                accessibilitySummary: bucket.accessibilitySummary
            )
        }
        marks.append(
            LifeShapeSemanticMark(
                kind: .receiptReflow,
                valueLabel: "Proof",
                detail: runtimeMutation.stageMutation.proofArtifact.artifactID,
                intensity: 0.82,
                visualState: .selected,
                inputRefs: [LifeShapeInputRef(id: runtimeMutation.command.id, kind: .userCorrection, label: runtimeMutation.command.payload.title ?? runtimeMutation.command.kind.rawValue)],
                ruleIDs: ["lifeshape.mutation.proof-visible"],
                accessibilitySummary: runtimeMutation.stageMutation.accessibilityAnnouncement.message
            )
        )
        return marks
    }

    static func calendarRows(
        after projection: LifeShapeProjection,
        actionKind: TimeMutationActionKind,
        fit: LifeShapeCapacityFit,
        placementCandidate: TimePlacementCandidate?
    ) -> [TimeCalendarRow] {
        let openCount = projection.todayBuckets.filter { $0.layer == .open }.count
        let protectedCount = projection.todayBuckets.filter { $0.layer == .protected || $0.protectedBoundary != nil }.count
        let placedStep = projection.todayBuckets.first { $0.recommendedStepID != nil }?.recommendedStepID
        return [
            TimeCalendarRow(
                id: "time.calendar.now",
                kind: .now,
                title: "Now",
                value: actionKind.visibleChange,
                detail: projection.primaryCaption,
                visualState: .selected,
                isOperational: true
            ),
            TimeCalendarRow(
                id: "time.calendar.open-window",
                kind: .openWindow,
                title: "Open windows",
                value: "\(openCount)",
                detail: placedStep.map { "Placed Step \($0)." } ?? (placementCandidate.map { "Placement candidate: \($0.title)." } ?? "Placement waits for a real Step."),
                visualState: openCount == 0 ? .warning : .selected,
                isOperational: openCount > 0 && placementCandidate != nil
            ),
            TimeCalendarRow(
                id: "time.calendar.protected-window",
                kind: .protectedWindow,
                title: "Protected windows",
                value: "\(protectedCount)",
                detail: protectedCount == 0 ? "No protected window is active." : "Protected windows are part of the local Time state.",
                visualState: protectedCount == 0 ? .default : .selected,
                isOperational: true
            ),
            TimeCalendarRow(
                id: "time.calendar.pressure",
                kind: .pressure,
                title: "Pressure",
                value: fit.title,
                detail: projection.semanticSummary,
                visualState: fit.visualState,
                isOperational: true
            ),
            TimeCalendarRow(
                id: "time.calendar.list",
                kind: .list,
                title: "List",
                value: "Equivalent",
                detail: "Rows expose the current Time state for VoiceOver and large text.",
                visualState: .selected,
                isOperational: true
            )
        ]
    }
}

private extension LifeShapeLayer {
    var semanticMarkKind: LifeShapeSemanticMarkKind {
        switch self {
        case .open:
            .executionLanes
        case .protected:
            .protectedTime
        case .pressure:
            .pressure
        case .buffer:
            .transitionFriction
        }
    }
}

extension TimeSurfaceState {
    func replacing(lifeSuite: TimeLifeSuiteState) -> TimeSurfaceState {
        TimeSurfaceState(
            mode: mode,
            timeframeLabel: timeframeLabel,
            hero: hero,
            lifeSuite: lifeSuite,
            primaryAction: primaryAction,
            treaty: treaty,
            capacityEnvelope: capacityEnvelope,
            pressureRecoveryReview: pressureRecoveryReview,
            lifecycleRail: lifecycleRail,
            timelineStrip: timelineStrip,
            opportunityWindows: opportunityWindows,
            decisionDebt: decisionDebt,
            conflictCourt: conflictCourt,
            calendarBoundary: calendarBoundary,
            recoveryEntry: recoveryEntry,
            realityReflow: realityReflow,
            reflowDecision: reflowDecision,
            recoveryGradient: recoveryGradient,
            saveTheDay: saveTheDay,
            reflowReceiptPreview: reflowReceiptPreview,
            recoveryMaturity: recoveryMaturity,
            pressureScrubber: pressureScrubber,
            weekDays: weekDays,
            believability: believability,
            calendarAwareness: calendarAwareness,
            resilience: resilience,
            goalShapingItems: goalShapingItems,
            shapingActions: shapingActions,
            secondaryDestinations: secondaryDestinations,
            emptyTitle: emptyTitle,
            emptyMessage: emptyMessage
        )
    }
}

extension RuntimeMutation {
    static func undoVisibleMutation(
        original: RuntimeMutation,
        restoredSnapshot: String,
        now: Date
    ) -> UserVisibleMutation {
        let commandID = "undo.\(original.command.id)"
        let affectedObjectIDs = original.stageMutation.affectedObjectIDs
        let action = MutationActionReference(
            commandID: commandID,
            commandKind: original.command.kind,
            source: original.command.source,
            targetObjectIDs: affectedObjectIDs
        )
        let beforeReference = MutationSnapshotReference(
            id: "snapshot.undo.before.\(original.command.id)",
            surface: .time,
            summary: original.stageMutation.afterSnapshot.summary
        )
        let afterReference = MutationSnapshotReference(
            id: "snapshot.undo.after.\(original.command.id)",
            surface: .time,
            summary: restoredSnapshot
        )
        let proof = MutationProof(
            artifactID: "runtime.proof.undo.\(original.command.id)",
            label: "Undo proof artifact",
            localOnly: original.validation.privacyBoundary.localOnly,
            beforeSnapshot: beforeReference,
            action: action,
            afterSnapshot: afterReference
        )
        let receiptID = "runtime.receipt.undo.\(original.command.id)"
        let receipt = MutationReceipt(
            receiptID: receiptID,
            saved: true,
            inspectionLabel: "Undo receipt",
            proofArtifactID: proof.artifactID,
            action: action
        )
        let runtimeMutationID = "runtime.mutation.undo.\(original.command.id).\(ISO8601DateFormatter().string(from: now))"
        let stageMutation = StageMutation(
            runtimeMutationID: runtimeMutationID,
            beforeSnapshot: beforeReference,
            afterSnapshot: afterReference,
            targetSurface: .time,
            affectedObjectIDs: affectedObjectIDs,
            visibleUserFacingChange: "Undo applied",
            typedMotionEvent: MutationMotionEvent(
                id: "stage.motion.time.mutation_undone",
                kind: .undo,
                sourceMutationID: runtimeMutationID,
                affectedObjectIDs: affectedObjectIDs
            ),
            accessibilityAnnouncement: MutationAccessibilityAnnouncement(
                message: "Undo applied. Time and Today returned to the prior shape.",
                reasonIfSilent: nil
            ),
            hapticIntent: "selection",
            undoAvailability: .unavailable(
                label: "Undo used",
                reason: "This mutation already restored the prior Time shape."
            ),
            proofArtifact: proof,
            receipt: receipt,
            safeFallback: "Keep the restored Time shape and receipt visible."
        )
        return UserVisibleMutation(
            stageMutation: stageMutation,
            headline: "Undo applied",
            detail: "Time and Today returned to the prior shape."
        )
    }
}
