import Foundation

public enum TimeNativeCalibrationDayID: String, CaseIterable, Hashable, Identifiable, Sendable {
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday

    public var id: String { rawValue }
}

public struct TimeNativeCalibrationDay: Identifiable, Equatable, Sendable {
    public let id: TimeNativeCalibrationDayID
    public let shortName: String
    public let longName: String
    public let dayNumber: Int

    public init(
        id: TimeNativeCalibrationDayID,
        shortName: String,
        longName: String,
        dayNumber: Int
    ) {
        self.id = id
        self.shortName = shortName
        self.longName = longName
        self.dayNumber = dayNumber
    }
}

public enum TimeNativeCalibrationTruth: String, Equatable, Sendable {
    case acceptedFixed
    case acceptedProtected
    case externalObservation
    case proposedPlacement
    case openCapacity

    public var stateLabel: String {
        switch self {
        case .acceptedFixed:
            "Accepted · Fixed"
        case .acceptedProtected:
            "Accepted · Protected"
        case .externalObservation:
            "External observation"
        case .proposedPlacement:
            "Proposed · Not scheduled"
        case .openCapacity:
            "Open"
        }
    }
}

public struct TimeNativeCalibrationObject: Identifiable, Equatable, Sendable {
    public let id: String
    public let title: String
    public let dayID: TimeNativeCalibrationDayID
    public let startMinute: Int
    public let endMinute: Int?
    public let timeLabel: String
    public let truth: TimeNativeCalibrationTruth
    public let meaning: String?
    public let source: String?
    public let goalTitle: String?
    public let stepTitle: String?
    public let conflictParticipantIDs: [String]

    public init(
        id: String,
        title: String,
        dayID: TimeNativeCalibrationDayID,
        startMinute: Int,
        endMinute: Int?,
        timeLabel: String,
        truth: TimeNativeCalibrationTruth,
        meaning: String? = nil,
        source: String? = nil,
        goalTitle: String? = nil,
        stepTitle: String? = nil,
        conflictParticipantIDs: [String] = []
    ) {
        self.id = id
        self.title = title
        self.dayID = dayID
        self.startMinute = startMinute
        self.endMinute = endMinute
        self.timeLabel = timeLabel
        self.truth = truth
        self.meaning = meaning
        self.source = source
        self.goalTitle = goalTitle
        self.stepTitle = stepTitle
        self.conflictParticipantIDs = conflictParticipantIDs
    }

    public var accessibilityLabel: String {
        [
            title,
            timeLabel,
            truth.stateLabel,
            meaning,
            source
        ]
        .compactMap { $0 }
        .joined(separator: ", ")
    }
}

public struct TimeNativeCalibrationFixture: Equatable, Sendable {
    public static let flagship = TimeNativeCalibrationFixture(
        id: "time-flagship/week/protected-family-and-launch/v1",
        weekLabel: "This week",
        rangeLabel: "Jul 27–Aug 2",
        selectedDayID: .wednesday,
        nowMinute: 15 * 60 + 12,
        days: [
            .init(id: .monday, shortName: "Mon", longName: "Monday", dayNumber: 27),
            .init(id: .tuesday, shortName: "Tue", longName: "Tuesday", dayNumber: 28),
            .init(id: .wednesday, shortName: "Wed", longName: "Wednesday", dayNumber: 29),
            .init(id: .thursday, shortName: "Thu", longName: "Thursday", dayNumber: 30),
            .init(id: .friday, shortName: "Fri", longName: "Friday", dayNumber: 31),
            .init(id: .saturday, shortName: "Sat", longName: "Saturday", dayNumber: 1),
            .init(id: .sunday, shortName: "Sun", longName: "Sunday", dayNumber: 2)
        ],
        objects: [
            .init(
                id: "placement.send-launch-brief.wed-1400",
                title: "Send the launch brief",
                dayID: .wednesday,
                startMinute: 14 * 60,
                endMinute: 14 * 60 + 30,
                timeLabel: "2:00–2:30 PM",
                truth: .acceptedFixed,
                goalTitle: "Ship the launch well"
            ),
            .init(
                id: "placement.family-time.wed-1730",
                title: "Family time",
                dayID: .wednesday,
                startMinute: 17 * 60 + 30,
                endMinute: 18 * 60 + 30,
                timeLabel: "5:30–6:30 PM",
                truth: .acceptedProtected,
                meaning: "No work"
            ),
            .init(
                id: "proposal.launch-review.wed-1745",
                title: "Launch review",
                dayID: .wednesday,
                startMinute: 17 * 60 + 45,
                endMinute: 18 * 60 + 15,
                timeLabel: "5:45–6:15 PM",
                truth: .proposedPlacement,
                meaning: "Conflicts with Family time",
                conflictParticipantIDs: [
                    "proposal.launch-review.wed-1745",
                    "placement.family-time.wed-1730"
                ]
            ),
            .init(
                id: "opening.wed-after-1830",
                title: "Open calendar space",
                dayID: .wednesday,
                startMinute: 18 * 60 + 30,
                endMinute: nil,
                timeLabel: "After 6:30 PM",
                truth: .openCapacity,
                meaning: "Personal usability unknown"
            ),
            .init(
                id: "external.prenatal-appointment.thu-0900",
                title: "Prenatal appointment",
                dayID: .thursday,
                startMinute: 9 * 60,
                endMinute: 10 * 60,
                timeLabel: "9:00–10:00 AM",
                truth: .externalObservation,
                source: "Apple Calendar observation"
            ),
            .init(
                id: "proposal.paint-nursery-wall.thu-1030",
                title: "Paint the nursery wall",
                dayID: .thursday,
                startMinute: 10 * 60 + 30,
                endMinute: 11 * 60 + 30,
                timeLabel: "10:30–11:30 AM",
                truth: .proposedPlacement,
                meaning: "Fits after the appointment; Family time is unchanged",
                goalTitle: "Welcome our baby home",
                stepTitle: "Paint the nursery wall"
            )
        ]
    )

    public let id: String
    public let weekLabel: String
    public let rangeLabel: String
    public let selectedDayID: TimeNativeCalibrationDayID
    public let nowMinute: Int
    public let days: [TimeNativeCalibrationDay]
    public let objects: [TimeNativeCalibrationObject]

    public init(
        id: String,
        weekLabel: String,
        rangeLabel: String,
        selectedDayID: TimeNativeCalibrationDayID,
        nowMinute: Int,
        days: [TimeNativeCalibrationDay],
        objects: [TimeNativeCalibrationObject]
    ) {
        self.id = id
        self.weekLabel = weekLabel
        self.rangeLabel = rangeLabel
        self.selectedDayID = selectedDayID
        self.nowMinute = nowMinute
        self.days = days
        self.objects = objects
    }

    public func day(_ id: TimeNativeCalibrationDayID) -> TimeNativeCalibrationDay? {
        days.first { $0.id == id }
    }

    public func objects(on dayID: TimeNativeCalibrationDayID) -> [TimeNativeCalibrationObject] {
        objects
            .filter { $0.dayID == dayID }
            .sorted { lhs, rhs in
                lhs.startMinute == rhs.startMinute
                    ? lhs.id < rhs.id
                    : lhs.startMinute < rhs.startMinute
            }
    }

    public func object(id: String) -> TimeNativeCalibrationObject? {
        objects.first { $0.id == id }
    }
}

public struct TimeNativeCalibrationScale: Equatable, Sendable {
    public let startMinute: Int
    public let endMinute: Int
    public let pointsPerHour: Double

    public init(startMinute: Int, endMinute: Int, pointsPerHour: Double) {
        precondition(endMinute > startMinute)
        precondition(pointsPerHour > 0)
        self.startMinute = startMinute
        self.endMinute = endMinute
        self.pointsPerHour = pointsPerHour
    }

    public var height: Double {
        Double(endMinute - startMinute) / 60 * pointsPerHour
    }

    public func yOffset(for minute: Int) -> Double {
        Double(minute - startMinute) / 60 * pointsPerHour
    }

    public func durationHeight(startMinute: Int, endMinute: Int) -> Double {
        Double(endMinute - startMinute) / 60 * pointsPerHour
    }
}
