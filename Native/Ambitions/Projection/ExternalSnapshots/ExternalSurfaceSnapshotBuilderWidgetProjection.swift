import Foundation

extension ExternalSurfaceSnapshotBuilder {
    func makeSnapshot(widget: WidgetProjection, privacy: PrivacyProjection, now: Date) -> ExternalSurfaceSnapshot {
        let generatedAt = Self.iso.string(from: now)
        let safeRowCount = widget.rows.count
        let redactedCount = privacy.redactionRequiredEventIDs.count
        let captureCount = widget.rows.filter { $0.source == .capture }.count
        let state = projectionNowState(
            safeRowCount: safeRowCount,
            redactedCount: redactedCount,
            captureCount: captureCount
        )

        return ExternalSurfaceSnapshot(
            generatedAt: generatedAt,
            nextAction: nil,
            nowState: state,
            ambientState: projectionAmbientState(
                nowState: state,
                safeRowCount: safeRowCount,
                redactedCount: redactedCount,
                captureCount: captureCount
            ),
            continuity: ExternalSurfaceContinuityState.localFirst(generatedAt: generatedAt)
        )
    }

    private func projectionNowState(
        safeRowCount: Int,
        redactedCount: Int,
        captureCount: Int
    ) -> ExternalSurfaceNowState {
        ExternalSurfaceNowState(
            todayPosture: projectionPosture(safeRowCount: safeRowCount, redactedCount: redactedCount),
            pressureLevel: projectionPressureLevel(safeRowCount: safeRowCount, redactedCount: redactedCount),
            bestNextStep: nil,
            activeFocus: nil,
            openCaptureUrgency: projectionCaptureUrgency(captureCount: captureCount),
            blockerSummary: ExternalSurfaceBlockerSummary(waitingCount: redactedCount, blockedCount: 0),
            ritualCue: nil,
            supportedCommands: supportedCommands(hasNextAction: false)
        )
    }

    private func projectionPosture(safeRowCount: Int, redactedCount: Int) -> ExternalSurfaceTodayPosture {
        if safeRowCount == 0 && redactedCount == 0 {
            return .empty
        }
        if safeRowCount == 0 && redactedCount > 0 {
            return .waiting
        }
        return .active
    }

    private func projectionPressureLevel(safeRowCount: Int, redactedCount: Int) -> ExternalSurfacePressureLevel {
        let visibleLoad = safeRowCount + redactedCount
        if visibleLoad == 0 { return .open }
        if redactedCount >= 5 || visibleLoad >= 8 { return .overloaded }
        if redactedCount > 0 || visibleLoad >= 5 { return .elevated }
        return .steady
    }

    private func projectionCaptureUrgency(captureCount: Int) -> ExternalSurfaceCaptureUrgency {
        if captureCount == 0 { return .none }
        if captureCount >= 5 { return .elevated }
        return .low
    }

    private func projectionAmbientState(
        nowState: ExternalSurfaceNowState,
        safeRowCount: Int,
        redactedCount: Int,
        captureCount: Int
    ) -> ExternalSurfaceAmbientState {
        let pressure = nowState.pressureLevel
        let hasSafeRows = safeRowCount > 0
        let hasRedactions = redactedCount > 0

        return ExternalSurfaceAmbientState(
            today: ExternalSurfaceVariantState(
                kind: .today,
                title: hasSafeRows ? "Today has local updates" : "Today needs context",
                detail: hasRedactions ? "Open Ambitions to review private context safely." : "Open Ambitions to continue from the latest local state.",
                privacySummary: "Glance-safe updates only",
                action: ExternalSurfaceVariantAction(title: "Open Today", surface: .tab, tab: "today"),
                reference: nil,
                prominence: pressure == .elevated || pressure == .overloaded ? .elevated : .standard
            ),
            focus: ExternalSurfaceVariantState(
                kind: .focus,
                title: hasSafeRows ? "Focus is available" : "Focus when ready",
                detail: "Step details stay inside Ambitions.",
                privacySummary: "Step details stay inside Ambitions",
                action: ExternalSurfaceVariantAction(title: "Open Focus", surface: .tab, tab: "today"),
                reference: nil,
                prominence: hasSafeRows ? .standard : .quiet
            ),
            goal: ExternalSurfaceVariantState(
                kind: .goal,
                title: safeRowCount == 0 ? "Goals stay private here" : "\(safeRowCount) safe local updates",
                detail: "Goal names and graph details open in Ambitions.",
                privacySummary: "Goal names stay private here",
                action: ExternalSurfaceVariantAction(title: "Open Goals", surface: .tab, tab: "goals"),
                reference: nil,
                prominence: hasRedactions ? .elevated : .standard
            ),
            timeShape: ExternalSurfaceVariantState(
                kind: .timeShape,
                title: timeShapeVariantTitle(pressure: pressure),
                detail: "Open Time to inspect the latest private state.",
                privacySummary: "Time detail opens in app",
                action: ExternalSurfaceVariantAction(title: "Open Time", surface: .tab, tab: "time"),
                reference: nil,
                prominence: pressure == .overloaded ? .elevated : .standard
            ),
            currentStep: ExternalSurfaceVariantState(
                kind: .currentStep,
                title: "Open step in Ambitions",
                detail: "Recommended step details require the app.",
                privacySummary: "Step details stay inside Ambitions",
                action: ExternalSurfaceVariantAction(title: "Open step", surface: .tab, tab: "today"),
                reference: nil,
                prominence: hasSafeRows ? .standard : .quiet
            ),
            todayPressure: ExternalSurfaceVariantState(
                kind: .todayPressure,
                title: todayPressureTitle(pressure),
                detail: todayPressureDetail(pressure, blockedCount: redactedCount),
                privacySummary: "Pressure uses local counts only",
                action: ExternalSurfaceVariantAction(title: "Open Today", surface: .tab, tab: "today"),
                reference: nil,
                prominence: pressure == .elevated || pressure == .overloaded ? .elevated : .standard
            ),
            protectedTime: ExternalSurfaceVariantState(
                kind: .protectedTime,
                title: protectedTimeTitle(pressure),
                detail: "Open Time before changing protected blocks.",
                privacySummary: "Protected-time detail stays in app",
                action: ExternalSurfaceVariantAction(title: "Open Time", surface: .tab, tab: "time"),
                reference: nil,
                prominence: pressure == .overloaded ? .elevated : .standard
            ),
            captureEntry: ExternalSurfaceVariantState(
                kind: .captureEntry,
                title: captureCount == 0 ? "Capture is available" : "\(captureCount) safe capture updates",
                detail: "Review new shares inside Ambitions.",
                privacySummary: "Capture text never appears here",
                action: ExternalSurfaceVariantAction(title: "Open Capture", surface: .captureComposer, tab: nil),
                reference: nil,
                prominence: captureCount > 0 ? .standard : .quiet
            ),
            recovery: ExternalSurfaceVariantState(
                kind: .recovery,
                title: hasRedactions ? "Review private context" : "Recovery stays available",
                detail: "Open Ambitions to inspect the full local proof.",
                privacySummary: "Private recovery context stays local",
                action: ExternalSurfaceVariantAction(title: "Open Today", surface: .tab, tab: "today"),
                reference: nil,
                prominence: hasRedactions ? .elevated : .quiet
            )
        )
    }
}
