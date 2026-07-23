public enum TodayBootstrapFixture {
    /// Synthetic evaluation content. This is not canon or runtime proof.
    public static let preparingForBaby = TodayBootstrapContent(
        fixtureID: "today-bootstrap/preparing-for-baby/typical/v1",
        isSynthetic: true,
        crownTitle: "Today",
        dateRelationship: "Thursday · Home before dinner",
        fixtureLabel: "Synthetic preview fixture",
        startHereEyebrow: "Start Here",
        startHereTitle: "Make the baby’s room ready for the crib",
        currentTruth: "The home corner is clear and the paint sample is ready.",
        materialConsequence: (
            "Finish this pass by 4:30 to protect family dinner and the "
            + "evening health walk."
        ),
        primaryActionTitle: "Continue nursery setup",
        timelineTitle: "Today’s Timeline",
        timelineEntries: [
            TodayBootstrapTimelineEntry(
                id: "nursery-paint-sample",
                timeLabel: "10:30 AM",
                title: "Paint the nursery sample",
                relationship: "Baby preparation · Home"
            ),
            TodayBootstrapTimelineEntry(
                id: "work-brief",
                timeLabel: "2:00 PM",
                title: "Send the launch brief",
                relationship: "One meaningful work commitment"
            ),
            TodayBootstrapTimelineEntry(
                id: "family-health-walk",
                timeLabel: "5:30 PM",
                title: "Take the prenatal walk together",
                relationship: "Family time · Health"
            )
        ]
    )
}
