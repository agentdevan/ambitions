import ActivityKit
import SwiftUI
import WidgetKit

@available(iOS 16.1, *)
struct NextStepLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: NextStepActivityAttributes.self) { context in
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Ambitions")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("Next step active")
                        .font(.headline)
                    Text(urgencyLabel(context.state.urgency))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Link(destination: deepLinkURL(goalID: context.state.goalID)) {
                    Image(systemName: "arrow.up.right.square")
                }
            }
            .padding()
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.center) {
                    VStack(alignment: .leading) {
                        Text("Next step")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(urgencyLabel(context.state.urgency))
                            .font(.headline)
                        Link("Open in Ambitions", destination: deepLinkURL(goalID: context.state.goalID))
                            .font(.subheadline)
                    }
                }
            } compactLeading: {
                Image(systemName: "scope")
            } compactTrailing: {
                Text(shortUrgency(context.state.urgency))
            } minimal: {
                Image(systemName: "scope")
            }
            .widgetURL(deepLinkURL(goalID: context.state.goalID))
        }
    }

    private func urgencyLabel(_ urgency: ExternalSurfaceUrgency) -> String {
        switch urgency {
        case .overdue:
            return "Needs attention"
        case .soon:
            return "Coming up soon"
        case .normal:
            return "In progress"
        case .anytime:
            return "Flexible timing"
        }
    }

    private func shortUrgency(_ urgency: ExternalSurfaceUrgency) -> String {
        switch urgency {
        case .overdue:
            return "Now"
        case .soon:
            return "Soon"
        case .normal:
            return "Next"
        case .anytime:
            return "Any"
        }
    }

    private func deepLinkURL(goalID: String) -> URL {
        URL(string: "ambitions://goal/\(goalID)") ?? URL(string: "ambitions://tab/today")!
    }
}
