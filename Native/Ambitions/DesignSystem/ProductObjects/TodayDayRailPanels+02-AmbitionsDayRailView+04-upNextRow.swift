import AmbitionsDesignSystem
import SwiftUI

extension AmbitionsDayRailView {

    func upNextRow(time: String, title: String, subtitle: String, duration: String) -> some View {
        HStack(alignment: .top, spacing: theme.spacing.sm) {
            VStack(spacing: 0) {
                Circle()
                    .fill(theme.colors.textSecondary.opacity(0.54))
                    .frame(width: 5, height: 5)
                Rectangle()
                    .fill(theme.colors.strokeSubtle.opacity(0.18))
                    .frame(width: 1, height: 28)
            }
            .padding(.top, 7)
            .accessibilityHidden(true)

            Text(time)
                .font(theme.typography.caption.weight(.semibold))
                .foregroundStyle(theme.colors.textSecondary)
                .frame(width: 74, alignment: .leading)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
                .padding(.top, 1)

            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                Text(title)
                    .font(theme.typography.caption.weight(.semibold))
                    .foregroundStyle(theme.colors.textPrimary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                Text([duration, subtitle].filter { $0.isEmpty == false }.joined(separator: " · "))
                    .font(theme.typography.micro)
                    .foregroundStyle(theme.colors.textSecondary)
                    .lineLimit(2)
            }
        }
    }


    var continuityDock: some View {
        HStack(spacing: theme.spacing.sm) {
            Circle()
                .fill(theme.colors.accentWarm.opacity(0.82))
                .frame(width: 9, height: 9)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                Text(state.proofSlot.title.isEmpty ? "Proof nearby" : state.proofSlot.title)
                    .font(theme.typography.caption.weight(.semibold))
                    .foregroundStyle(theme.colors.textPrimary)
                    .lineLimit(1)
                Text(proofSummary)
                    .font(theme.typography.micro)
                    .foregroundStyle(theme.colors.textSecondary)
                    .lineLimit(2)
            }

            Spacer(minLength: theme.spacing.sm)

            Image(systemName: "chevron.up")
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(theme.colors.textSecondary)
        }
        .padding(.top, theme.spacing.md)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(theme.colors.strokeSubtle.opacity(0.18))
                .frame(height: 1)
        }
        .accessibilityIdentifier("TodayRealityRailContinuityDock")
    }


    func nonEmpty(_ value: String?, fallback: String) -> String {
        guard let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines),
              trimmed.isEmpty == false else {
            return fallback
        }
        return trimmed
    }


    func rowColor(for slot: DayRailRowSlot?) -> Color? {
        switch slot {
        case .now:
            return theme.colors.accentWarm
        case .next:
            return theme.colors.accentPrimary.opacity(0.78)
        case .later:
            return theme.colors.textSecondary.opacity(0.76)
        case nil:
            return nil
        }
    }


    func metaLine(for heroStep: DayRailHeroStepState) -> String {
        let duration = heroStep.duration.label.isEmpty ? heroStep.fitLabel : heroStep.duration.label
        return ["Recommended step", duration, state.contextSummary]
            .filter { $0.isEmpty == false }
            .joined(separator: " · ")
    }


    func heroCopy(for heroStep: DayRailHeroStepState) -> String {
        if heroStep.receiptItem.freshness == .unavailable {
            return "Needs context. Manual shaping still works."
        }
        if heroStep.becauseLine.isEmpty == false {
            return heroStep.becauseLine
        }
        if heroStep.subtitle.isEmpty == false {
            return heroStep.subtitle
        }
        return heroStep.whySummary
    }


    func receiptLabel(for heroStep: DayRailHeroStepState) -> String {
        if let reviewLabel = heroStep.receiptItem.reviewLabel,
           reviewLabel.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false {
            return reviewLabel
        }

        if heroStep.receiptItem.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false {
            return "Review trail"
        }

        return "Review trail ready"
    }


    func primaryActionTitle(for action: TodayInlineAction) -> String {
        switch action.kind {
        case .openDetail:
            return "Open step"
        case .closeActionClosure:
            return "Still counts"
        default:
            return "Start now"
        }
    }


    func secondaryActionTitle(for action: TodayInlineAction?) -> String {
        guard let kind = action?.kind else {
            return "Move this"
        }

        switch kind {
        case .split:
            return "Shorten"
        case .defer:
            return "Waiting"
        case .askForHelp:
            return "Blocked"
        case .markNotRelevant:
            return "Not needed"
        default:
            return "Move this"
        }
    }


    var dateContextLine: String {
        [state.dateTitle, modeLabel].filter { $0.isEmpty == false }.joined(separator: " · ")
    }


    var proofSummary: String {
        if state.proofSlot.noSilentChanges {
            return "Review trail is local."
        }
        return state.proofSlot.subtitle
    }


    var modeLabel: String {
        switch state.mode {
        case .normal:
            return "Morning"
        case .recovery:
            return "Recovery"
        case .protected:
            return "Protected"
        case .overloaded:
            return "Lighten first"
        case .empty:
            return "Open"
        case .noSchedule:
            return "Schedule not set"
        }
    }


    var accessibilityLabel: String {
        var parts = ["Today. Reality Meridian", state.dateTitle, modeLabel, state.contextSummary]
        if let heroStep = state.heroStep {
            parts.append("Start here")
            parts.append("Attached to the current Now node")
            parts.append(heroStep.title)
            parts.append(heroStep.duration.label)
            parts.append("Trust context remains local")
            parts.append("Review state \(heroStep.receiptItem.freshness.label)")
            parts.append("Review label \(receiptLabel(for: heroStep))")
            parts.append(primaryActionTitle(for: heroStep.primaryAction))
        } else {
            parts.append("Start here is attached to the current Now node.")
            parts.append("Nothing needs you right now.")
        }
        return parts.joined(separator: ". ")
    }
}
