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
}
