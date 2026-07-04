import Foundation

struct TimeObjectStagePrimitiveContract: Equatable, Sendable {
    let primitiveID: String
    let ownerSurface: String
    let productObject: String
    let stageName: String
    let firstViewportStructure: String
    let replacesFirstViewportStructures: [String]
    let sourceTrustLineOrder: [String]
    let accessibilityFallbacks: [String]
    let screenshotIdentifier: String
    let firstViewportAvoidsCalendarCardStackGeometry: Bool

    static let current = TimeObjectStagePrimitiveContract(
        primitiveID: "time-object-stage",
        ownerSurface: "Time",
        productObject: "LifeShape Field",
        stageName: "LifeShape Field",
        firstViewportStructure: "Full-bleed LifeShape Field object stage with live now, current date, fixed points, capacity contours, pressure texture, protected windows, day/week/month/year horizons, confirmation-first shaping actions, global Capture support, and source/receipt inspection.",
        replacesFirstViewportStructures: [
            "calendar-like horizon chip strip",
            "rounded LifeShape canvas panel",
            "capacity statement panel",
            "metric-row stack",
            "calendar clone",
            "agenda clone",
            "free/busy grid",
            "source and receipt pills",
            "change preview panel"
        ],
        sourceTrustLineOrder: [
            "current date",
            "now marker",
            "fixed points",
            "capacity",
            "protected windows",
            "pressure",
            "horizon",
            "Capture"
        ],
        accessibilityFallbacks: [
            "VoiceOver names LifeShape Field before current date, now marker, fixed points, open capacity, protected windows, pressure seams, horizon, and Capture support",
            "Dynamic Type stacks horizon, source, receipt, and capacity lines without changing object order",
            "Reduce Motion keeps pressure texture static and preserves state with text",
            "Reduce Transparency uses opaque field bands with text labels",
            "Increase Contrast strengthens capacity, protected-window, and pressure rules",
            "Differentiate Without Color exposes fixed points, open capacity, protected windows, pressure seams, source, receipt, privacy, and horizon state as text"
        ],
        screenshotIdentifier: "TimeObjectStage",
        firstViewportAvoidsCalendarCardStackGeometry: true
    )
}

enum TimeLens: SurfaceLens {
    static let contract = SurfaceLensContract(
        surface: .time,
        surfaceTitle: "Time",
        primaryObjectTitle: "LifeShape Field",
        primaryActionTitle: "Move it",
        runtimeInputs: [
            "current date",
            "live now",
            "fixed points",
            "capacity",
            "protected windows",
            "pressure",
            "horizon"
        ],
        firstViewportContract: "LifeShape Field owns current time shape, capacity, protected windows, pressure, and horizon changes as one native time field.",
        accessibilityContract: objectStageContract.accessibilityFallbacks,
        trustInspectionRequirements: ["source", "proof", "receipt", "privacy"],
        failureStateRequirements: ["offline calendar", "permission denied", "broken source", "recovery reflow"]
    )

    static let objectStageContract = TimeObjectStagePrimitiveContract.current

    static func project(_ timeState: TimeSurfaceState) -> TimeStageScene {
        makeStageScene(for: timeState, clock: SystemClock())
    }

    static func project(_ timeState: TimeSurfaceState, clock: any AmbitionsClock) -> TimeStageScene {
        makeStageScene(for: timeState, clock: clock)
    }

    static func project(
        _ runtimeSnapshot: RuntimeSnapshot,
        engine: LifeShapeEngine = LifeShapeEngine()
    ) throws -> LifeShapeProjection {
        try engine.project(makeLifeShapeInput(from: runtimeSnapshot))
    }

    static func makeLifeShapeInput(from runtimeSnapshot: RuntimeSnapshot) -> LifeShapeEngineInput {
        let currentDate = runtimeDate(from: runtimeSnapshot.generatedAt)
        let capacity = runtimeSnapshot.capacityShape
        let protectedBoundary = protectedBoundary(from: capacity, currentDate: currentDate)
        let blockedPoint = blockedFixedPoint(from: capacity, currentDate: currentDate, protectedBoundary: protectedBoundary)
        let rawTotalMinutes = capacity.openMinutes + capacity.protectedMinutes + capacity.blockedMinutes + capacity.flexibleMinutes
        let totalMinutes = max(60, rawTotalMinutes)
        let dayEnd = currentDate.addingTimeInterval(Double(totalMinutes * 60))
        let permission: CalendarPermissionState = rawTotalMinutes > 0 ? .readWrite : .unavailable

        return LifeShapeEngineInput(
            generatedAt: currentDate,
            currentDate: currentDate,
            horizon: .day,
            open: OpenCapacityInput(
                now: currentDate,
                dayStart: currentDate,
                dayEnd: dayEnd,
                fixedPoints: blockedPoint.map { [$0] } ?? [],
                protectedBoundaries: protectedBoundary.map { [$0] } ?? [],
                planningDefaults: LifeShapePlanningDefaults(transitionBufferMinutes: 0),
                stepDurationEstimates: runtimeSnapshot.recommendedStep == nil ? [] : [15, 30],
                calendarPermissionState: permission
            ),
            protected: ProtectionEngineInput(
                explicitProtectedBoundaries: protectedBoundary.map { [$0] } ?? [],
                fixedCommitments: blockedPoint.map { [$0] } ?? []
            )
        )
    }

    static func makeStageScene(for timeState: TimeSurfaceState, clock: any AmbitionsClock) -> TimeStageScene {
        let currentDateSummary = RuntimeTickPolicy(calendar: clock.calendar).shortMonthDayLabel(for: clock.now)

        return TimeStageScene(
            surface: .time,
            productObject: objectStageContract.productObject,
            stageName: objectStageContract.stageName,
            firstViewportStructure: objectStageContract.firstViewportStructure,
            sourceTrustLineOrder: objectStageContract.sourceTrustLineOrder,
            currentDateSummary: currentDateSummary,
            capacitySummary: timeState.capacityEnvelope.availableCapacity,
            protectedWindowSummary: timeState.capacityEnvelope.protectedFocus,
            pressureSummary: timeState.capacityEnvelope.pressure,
            horizonSummary: "Day, week, month, and year stay inside Time.",
            captureSupportSummary: "Capture routes through the global composer, not a Time destination.",
            accessibilityFallbacks: objectStageContract.accessibilityFallbacks
        )
    }

    private static func runtimeDate(from value: String) -> Date {
        if let date = ISO8601DateFormatter().date(from: value) {
            return date
        }
        return Date(timeIntervalSince1970: 0)
    }

    private static func protectedBoundary(from capacity: CapacityShape, currentDate: Date) -> ProtectedBoundary? {
        guard capacity.protectedMinutes > 0 else { return nil }
        let start = currentDate.addingTimeInterval(Double(max(0, capacity.openMinutes) * 60))
        let end = start.addingTimeInterval(Double(capacity.protectedMinutes * 60))
        return ProtectedBoundary(
            id: "runtime.capacity.protected",
            title: "Protected window",
            start: start,
            end: end,
            reason: "Capacity shape marked protected time.",
            kind: .explicit,
            inputRef: LifeShapeInputRef(id: "runtime.capacity.protected", kind: .protectedBoundary, label: "Protected capacity")
        )
    }

    private static func blockedFixedPoint(
        from capacity: CapacityShape,
        currentDate: Date,
        protectedBoundary: ProtectedBoundary?
    ) -> FixedPoint? {
        guard capacity.blockedMinutes > 0 else { return nil }
        let protectedMinutes = protectedBoundary.map { Int($0.end.timeIntervalSince($0.start) / 60) } ?? 0
        let start = currentDate.addingTimeInterval(Double((max(0, capacity.openMinutes) + protectedMinutes) * 60))
        let end = start.addingTimeInterval(Double(capacity.blockedMinutes * 60))
        return FixedPoint(
            id: "runtime.capacity.blocked",
            title: "Blocked time",
            start: start,
            end: end,
            kind: .manualUnavailable,
            isNonNegotiable: false,
            inputRef: LifeShapeInputRef(id: "runtime.capacity.blocked", kind: .fixedPoint, label: "Blocked capacity")
        )
    }
}
