import AmbitionsDesignSystem
import SwiftUI

extension LifeShapeFieldView {
    var continuityDock: some View {
        HorizonCapacityPrimitiveStage(
            role: .continuity,
            title: "Continuity",
            subtitle: "Horizon changes keep source, protected pocket, and receipt review attached.",
            statusLabel: selectedHorizon.title,
            accessibilityIdentifier: "time.life-shape-field.continuity-dock"
        ) {
            ForEach(Array(suite.field.continuityDockItems.enumerated()), id: \.offset) { index, item in
                HorizonCapacityPrimitiveLine(
                    role: .continuity,
                    title: item,
                    subtitle: continuitySubtitle(at: index),
                    systemImage: continuityIcon(at: index),
                    visualState: index == 0 ? .selected : .default,
                    accessibilityIdentifier: "time.life-shape-field.continuity-dock.\(index)"
                )
            }

            HorizonCapacityPrimitiveLine(
                role: .continuity,
	                title: "Context stays together",
	                subtitle: "Day, week, month, and year keep the current shape attached.",
                systemImage: "lock.shield",
                visualState: .default,
                accessibilityIdentifier: "time.life-shape-field.continuity-dock.context"
            )
        }
    }

    func inlineObjectLabel(_ title: String, icon: String, state: AmbitionVisualState) -> some View {
        Label(title, systemImage: icon)
            .font(theme.typography.micro.weight(.semibold))
            .foregroundStyle(theme.stateStyle(for: state).accent)
            .lineLimit(1)
            .minimumScaleFactor(0.72)
    }

    func nonEmpty(_ value: String?, fallback: String) -> String {
        guard let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines),
              trimmed.isEmpty == false else {
            return fallback
        }
        return trimmed
    }

    func continuityIcon(at index: Int) -> String {
        switch index {
        case 0: "waveform.path"
        case 1: "lock"
        default: "doc.text"
        }
    }

    func continuitySubtitle(at index: Int) -> String {
        switch index {
        case 0: "Current horizon relationship remains inspectable."
        case 1: "Protected time stays attached to capacity review."
        default: "Receipt history stays with the horizon change."
        }
    }

    var accessibilityValue: String {
        [
            reading.title,
            reading.summary,
            reading.capacityStatement,
            displayedSourceDetail,
            suite.field.receipt.detail
        ].joined(separator: ". ")
    }
}

