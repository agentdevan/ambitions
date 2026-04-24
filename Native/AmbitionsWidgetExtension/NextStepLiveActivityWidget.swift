import ActivityKit
import SwiftUI
import WidgetKit

@available(iOS 16.1, *)
struct NextStepLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: NextStepActivityAttributes.self) { context in
            HStack(spacing: 14) {
                Image(systemName: "scope")
                    .font(.title3.weight(.semibold))
                    .frame(width: 34, height: 34)
                    .background(.thinMaterial, in: Circle())
                VStack(alignment: .leading, spacing: 4) {
                    Text(context.state.title)
                        .font(.headline)
                        .lineLimit(1)
                    Text(context.state.detail)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                    Text("\(context.state.syncLabel) · \(context.state.leaseLabel)")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                        .lineLimit(1)
                }
                Spacer(minLength: 0)
                Link(destination: deepLinkURL(goalID: context.state.goalID)) {
                    Label("Return", systemImage: "arrow.up.right.square")
                        .labelStyle(.iconOnly)
                }
            }
            .padding()
            .activityBackgroundTint(Color(red: 0.08, green: 0.10, blue: 0.12))
            .activitySystemActionForegroundColor(Color(red: 0.96, green: 0.72, blue: 0.42))
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.center) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Ambitions Focus")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(context.state.title)
                            .font(.headline)
                            .lineLimit(1)
                        Text(context.state.detail)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                        Link("Return to Ambitions", destination: deepLinkURL(goalID: context.state.goalID))
                            .font(.caption.weight(.semibold))
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
        ExternalSurfaceActionPayload.deepLinkURL(surface: .goalDetail, goalID: goalID, origin: .liveActivity)
            ?? ExternalSurfaceActionPayload.deepLinkURL(surface: .tab, tab: "today", origin: .liveActivity)!
    }

    private func pressureLabel(_ pressure: ExternalSurfacePressureLevel) -> String {
        switch pressure {
        case .open:
            return "Open"
        case .steady:
            return "Steady"
        case .elevated:
            return "Elevated pressure"
        case .overloaded:
            return "Needs triage"
        }
    }
}
