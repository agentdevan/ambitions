import ActivityKit
import SwiftUI
import WidgetKit

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
                    Text(context.state.privacyLabel)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                        .lineLimit(1)
                    Text(context.state.proofLabel)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                        .lineLimit(1)
                }
                Spacer(minLength: 0)
                Link(destination: deepLinkURL(state: context.state)) {
                    Label("Return", systemImage: "arrow.up.right.square")
                        .labelStyle(.iconOnly)
                }
            }
            .padding()
            .activityBackgroundTint(Color(red: 0.08, green: 0.10, blue: 0.12))
            .activitySystemActionForegroundColor(Color(red: 0.96, green: 0.72, blue: 0.42))
            .accessibilityLabel(accessibilityLabel(state: context.state))
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.center) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(context.state.stateLabel)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(context.state.title)
                            .font(.headline)
                            .lineLimit(1)
                        Text(context.state.detail)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                        Text(context.state.privacyLabel)
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                            .lineLimit(1)
                        Text(context.state.proofLabel)
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                            .lineLimit(1)
                        Link("Return to Ambitions", destination: deepLinkURL(state: context.state))
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
            .widgetURL(deepLinkURL(state: context.state))
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

    private func deepLinkURL(state: NextStepActivityAttributes.ContentState) -> URL {
        URL(string: state.deepLinkURLString)
            ?? ExternalSurfaceActionPayload.safeDeepLinkURL(surface: .goalDetail, goalID: state.goalID, origin: .liveActivity, fallbackTab: "time")!
    }

    private func accessibilityLabel(state: NextStepActivityAttributes.ContentState) -> String {
        state.accessibilitySummary
    }
}
