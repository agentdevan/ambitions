public struct TodayBootstrapTimelineEntry: Equatable, Identifiable, Sendable {
    public let id: String
    public let timeLabel: String
    public let title: String
    public let relationship: String

    public init(
        id: String,
        timeLabel: String,
        title: String,
        relationship: String
    ) {
        self.id = id
        self.timeLabel = timeLabel
        self.title = title
        self.relationship = relationship
    }
}

public struct TodayBootstrapContent: Equatable, Identifiable, Sendable {
    public var id: String { fixtureID }

    public let fixtureID: String
    public let isSynthetic: Bool
    public let crownTitle: String
    public let dateRelationship: String
    public let fixtureLabel: String
    public let startHereEyebrow: String
    public let startHereTitle: String
    public let currentTruth: String
    public let materialConsequence: String
    public let primaryActionTitle: String
    public let timelineTitle: String
    public let timelineEntries: [TodayBootstrapTimelineEntry]

    public init(
        fixtureID: String,
        isSynthetic: Bool,
        crownTitle: String,
        dateRelationship: String,
        fixtureLabel: String,
        startHereEyebrow: String,
        startHereTitle: String,
        currentTruth: String,
        materialConsequence: String,
        primaryActionTitle: String,
        timelineTitle: String,
        timelineEntries: [TodayBootstrapTimelineEntry]
    ) {
        self.fixtureID = fixtureID
        self.isSynthetic = isSynthetic
        self.crownTitle = crownTitle
        self.dateRelationship = dateRelationship
        self.fixtureLabel = fixtureLabel
        self.startHereEyebrow = startHereEyebrow
        self.startHereTitle = startHereTitle
        self.currentTruth = currentTruth
        self.materialConsequence = materialConsequence
        self.primaryActionTitle = primaryActionTitle
        self.timelineTitle = timelineTitle
        self.timelineEntries = timelineEntries
    }
}
