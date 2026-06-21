import Foundation

enum LifeShapeStressScenarios {
    static let frozenNow = Date(timeIntervalSince1970: 1_800_000_000)

    static var emptyManualInput: LifeShapeEngineInput {
        let start = frozenNow
        let end = start.addingTimeInterval(8 * 60 * 60)
        return LifeShapeEngineInput(
            generatedAt: frozenNow,
            currentDate: frozenNow,
            open: OpenCapacityInput(
                now: frozenNow,
                dayStart: start,
                dayEnd: end,
                calendarPermissionState: .unavailable
            ),
            protected: ProtectionEngineInput()
        )
    }

    static var calendarDeniedManualInput: LifeShapeEngineInput {
        let start = frozenNow
        let end = start.addingTimeInterval(8 * 60 * 60)
        let manualBoundary = ProtectedBoundary(
            id: "manual-protected-morning",
            title: "School drop-off",
            start: start.addingTimeInterval(60 * 60),
            end: start.addingTimeInterval(2 * 60 * 60),
            reason: "User marked this clear manually.",
            kind: .explicit,
            inputRef: LifeShapeInputRef(id: "manual-protected-morning", kind: .protectedBoundary, label: "Manual protected morning")
        )
        return LifeShapeEngineInput(
            generatedAt: frozenNow,
            currentDate: frozenNow.addingTimeInterval(30 * 60),
            open: OpenCapacityInput(
                now: frozenNow,
                dayStart: start,
                dayEnd: end,
                protectedBoundaries: [manualBoundary],
                calendarPermissionState: .denied
            ),
            protected: ProtectionEngineInput(explicitProtectedBoundaries: [manualBoundary])
        )
    }

    static var denseDayInput: LifeShapeEngineInput {
        let start = frozenNow
        let end = start.addingTimeInterval(12 * 60 * 60)
        let fixedPoints = (0..<6).map { index in
            let blockStart = start.addingTimeInterval(Double(45 + index * 105) * 60)
            return FixedPoint(
                id: "dense-fixed-\(index)",
                title: "Fixed commitment \(index + 1)",
                start: blockStart,
                end: blockStart.addingTimeInterval(35 * 60),
                kind: .commitment,
                isNonNegotiable: index == 2,
                inputRef: LifeShapeInputRef(id: "dense-fixed-\(index)", kind: .fixedPoint, label: "Dense fixed commitment \(index + 1)")
            )
        }
        return LifeShapeEngineInput(
            generatedAt: frozenNow,
            currentDate: frozenNow,
            open: OpenCapacityInput(
                now: frozenNow,
                dayStart: start,
                dayEnd: end,
                fixedPoints: fixedPoints,
                planningDefaults: LifeShapePlanningDefaults(transitionBufferMinutes: 5),
                stepDurationEstimates: [15, 45],
                calendarPermissionState: .readWrite
            ),
            protected: ProtectionEngineInput(fixedCommitments: fixedPoints)
        )
    }
}
