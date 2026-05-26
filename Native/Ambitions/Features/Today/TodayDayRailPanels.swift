import AmbitionsDesignSystem
import SwiftUI

/// The Reality Meridian surface for Today - the primary object presenting the daily execution rail.
struct RealityMeridianView: View {
    let state: AmbitionsDayRailViewState
    let onAction: (TodayInlineAction) -> Void
    let onOpenStepDetail: (DayRailStepDetailState) -> Void
    let onShowAnother: (DayRailHeroStepState) -> Void
    let onNotThis: (DayRailHeroStepState) -> Void

    init(
        state: AmbitionsDayRailViewState,
        onAction: @escaping (TodayInlineAction) -> Void,
        onOpenStepDetail: @escaping (DayRailStepDetailState) -> Void = { _ in },
        onShowAnother: @escaping (DayRailHeroStepState) -> Void = { _ in },
        onNotThis: @escaping (DayRailHeroStepState) -> Void = { _ in }
    ) {
        self.state = state
        self.onAction = onAction
        self.onOpenStepDetail = onOpenStepDetail
        self.onShowAnother = onShowAnother
        self.onNotThis = onNotThis
    }

    var body: some View {
        AmbitionsDayRailView(
            state: state,
            onAction: onAction,
            onOpenStepDetail: onOpenStepDetail,
            onShowAnother: onShowAnother,
            onNotThis: onNotThis
        )
    }
}

struct AmbitionsDayRailView: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let state: AmbitionsDayRailViewState
    let onAction: (TodayInlineAction) -> Void
    let onOpenStepDetail: (DayRailStepDetailState) -> Void
    let onShowAnother: (DayRailHeroStepState) -> Void
    let onNotThis: (DayRailHeroStepState) -> Void

    init(
        state: AmbitionsDayRailViewState,
        onAction: @escaping (TodayInlineAction) -> Void,
        onOpenStepDetail: @escaping (DayRailStepDetailState) -> Void = { _ in },
        onShowAnother: @escaping (DayRailHeroStepState) -> Void = { _ in },
        onNotThis: @escaping (DayRailHeroStepState) -> Void = { _ in }
    ) {
        self.state = state
        self.onAction = onAction
        self.onOpenStepDetail = onOpenStepDetail
        self.onShowAnother = onShowAnother
        self.onNotThis = onNotThis
    }

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.lg) {
            if let heroStep = state.heroStep {
                startHerePanel(heroStep)
            } else {
                DayRailEmptyCard(state: state)
            }

            meridianPanel
            closureAndProofPanel
        }
        .padding(theme.spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .fill(theme.colors.canvasElevated.opacity(theme.mode == .dark ? 0.78 : 0.96))
                .overlay(
                    RoundedRectangle(cornerRadius: 34, style: .continuous)
                        .stroke(theme.colors.strokeSubtle.opacity(0.68), lineWidth: 1)
                )
        )
        .shadow(color: theme.depth.resting.color.opacity(theme.mode == .dark ? 0.46 : 0.22), radius: 22, x: 0, y: 12)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityIdentifier("TodayRealityRail")
    }

    private func startHerePanel(_ heroStep: DayRailHeroStepState) -> some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            HStack(alignment: .center, spacing: theme.spacing.sm) {
                Image(systemName: "sparkle.magnifyingglass")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(theme.colors.accentWarm)
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(theme.colors.accentWarm.opacity(0.15)))
                    .overlay(Circle().stroke(theme.colors.accentWarm.opacity(0.28), lineWidth: 1))
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                    Text("Start here")
                        .font(theme.typography.caption.weight(.semibold))
                        .foregroundStyle(theme.colors.accentWarm)
                        .textCase(.uppercase)
                        .tracking(0.8)

                    Text(state.privacyProjection.detailTitle(heroStep.title))
                        .font(theme.typography.titleCompact.weight(.semibold))
                        .foregroundStyle(theme.colors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(dynamicTypeSize.isAccessibilitySize ? 5 : 3)
                        .accessibilityIdentifier("TodayRealityRailStepTitle")
                }
            }

            Text(heroCopy(for: heroStep))
                .font(theme.typography.body)
                .foregroundStyle(theme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(dynamicTypeSize.isAccessibilitySize ? 6 : 3)

            HStack(spacing: theme.spacing.xs) {
                mvpChip(heroStep.duration.label.isEmpty ? heroStep.fitLabel : heroStep.duration.label)
                mvpChip(state.privacyProjection.sourceLabel)
            }

            HStack(spacing: theme.spacing.sm) {
                Button {
                    onAction(heroStep.primaryAction)
                } label: {
                    Label(primaryActionTitle(for: heroStep.primaryAction), systemImage: "arrow.right")
                        .font(theme.typography.body.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, theme.spacing.xs)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .accessibilityIdentifier("TodayRealityRailPrimaryAction")

                Button {
                    onOpenStepDetail(heroStep.stepDetail(privacy: state.privacyProjection, contextLabel: state.contextSummary))
                } label: {
                    Label("Open step", systemImage: "doc.text.magnifyingglass")
                        .labelStyle(.iconOnly)
                        .frame(width: 46, height: 46)
                }
                .buttonStyle(.bordered)
                .accessibilityIdentifier("TodayMVPReadStep")
            }
        }
        .padding(theme.spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(theme.colors.surfaceOverlay.opacity(theme.mode == .dark ? 0.70 : 0.92))
                .overlay(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3, style: .continuous)
                        .fill(theme.colors.accentWarm.opacity(0.88))
                        .frame(width: 4)
                        .padding(.vertical, theme.spacing.md)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(theme.colors.strokeSubtle.opacity(0.62), lineWidth: 1)
                )
        )
        .accessibilityIdentifier("TodayStartHereSurface")
    }

    private var meridianPanel: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                    Text("Reality Meridian")
                        .font(theme.typography.section.weight(.semibold))
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(state.contextSummary)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(3)
                }
                Spacer(minLength: theme.spacing.sm)
                Text(modeLabel)
                    .font(theme.typography.caption.weight(.semibold))
                    .foregroundStyle(theme.colors.accentWarm)
                    .padding(.horizontal, theme.spacing.sm)
                    .padding(.vertical, theme.spacing.xxxs)
                    .background(Capsule().fill(theme.colors.accentWarm.opacity(0.14)))
            }

            VStack(alignment: .leading, spacing: theme.spacing.md) {
                if let heroStep = state.heroStep {
                    meridianRow(
                        title: "Start here",
                        subtitle: state.privacyProjection.detailTitle(heroStep.title),
                        detail: heroCopy(for: heroStep),
                        active: true
                    )
                }

                if state.rows.isEmpty {
                    meridianRow(title: "Now", subtitle: "Current focus window", detail: "Stay with the recommended step.", active: state.heroStep == nil)
                    meridianRow(title: "Next", subtitle: "Prepare the next step", detail: "Ambitions keeps the sequence visible without reshuffling silently.", active: false)
                    meridianRow(title: "Later", subtitle: "Hold without shame", detail: "Closure and proof remain inspectable.", active: false)
                } else {
                    ForEach(state.rows) { row in
                        meridianRow(
                            title: row.slot.mvpTitle,
                            subtitle: state.privacyProjection.detailTitle(row.title),
                            detail: row.subtitle,
                            active: row.slot == .now
                        )
                    }
                }
            }
        }
        .padding(theme.spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(theme.colors.surfaceOverlay.opacity(theme.mode == .dark ? 0.52 : 0.82))
                .overlay(
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .stroke(theme.colors.strokeSubtle.opacity(0.56), lineWidth: 1)
                )
        )
        .accessibilityIdentifier("TodayMVPMeridianList")
    }

    private var closureAndProofPanel: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            HStack(alignment: .top, spacing: theme.spacing.sm) {
                Image(systemName: state.closureSlot.reservedForActionClosureSheet ? "checkmark.seal" : "lock.doc")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundStyle(theme.colors.textSecondary)
                    .frame(width: 26, height: 26)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                    Text(state.closureSlot.title)
                        .font(theme.typography.body.weight(.semibold))
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(state.closureSlot.subtitle)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            Divider().overlay(theme.colors.strokeSubtle.opacity(0.56))

            Text(state.proofSlot.noSilentChanges ? "Proof is local and no silent changes are made." : state.proofSlot.subtitle)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(theme.spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(theme.colors.canvasElevated.opacity(theme.mode == .dark ? 0.46 : 0.78))
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(theme.colors.strokeSubtle.opacity(0.46), lineWidth: 1)
                )
        )
        .accessibilityIdentifier("TodayMVPClosureProofPanel")
    }

    private func meridianRow(title: String, subtitle: String, detail: String, active: Bool) -> some View {
        HStack(alignment: .top, spacing: theme.spacing.sm) {
            VStack(spacing: 0) {
                Circle()
                    .fill(active ? theme.colors.accentWarm : theme.colors.textSecondary.opacity(0.40))
                    .frame(width: active ? 12 : 9, height: active ? 12 : 9)
                    .padding(.top, 5)
                Rectangle()
                    .fill(theme.colors.strokeSubtle.opacity(0.42))
                    .frame(width: 1, height: 44)
            }
            .frame(width: 18)
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                Text(title)
                    .font(theme.typography.caption.weight(.semibold))
                    .foregroundStyle(active ? theme.colors.accentWarm : theme.colors.textSecondary)
                    .textCase(.uppercase)
                    .tracking(0.5)
                    .lineLimit(1)
                Text(subtitle)
                    .font(theme.typography.body.weight(.semibold))
                    .foregroundStyle(theme.colors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(dynamicTypeSize.isAccessibilitySize ? 4 : 2)
                Text(detail)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(dynamicTypeSize.isAccessibilitySize ? 4 : 2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityElement(children: .combine)
    }

    private func mvpChip(_ label: String) -> some View {
        Text(label.isEmpty ? "Local" : label)
            .font(theme.typography.caption.weight(.semibold))
            .foregroundStyle(theme.colors.textSecondary)
            .lineLimit(1)
            .minimumScaleFactor(0.82)
            .padding(.horizontal, theme.spacing.sm)
            .padding(.vertical, theme.spacing.xxxs)
            .background(Capsule().fill(theme.colors.canvasElevated.opacity(0.72)))
            .overlay(Capsule().stroke(theme.colors.strokeSubtle.opacity(0.44), lineWidth: 1))
    }

    private func heroCopy(for heroStep: DayRailHeroStepState) -> String {
        if heroStep.subtitle.isEmpty == false {
            return heroStep.subtitle
        }
        if heroStep.becauseLine.isEmpty == false {
            return heroStep.becauseLine
        }
        return heroStep.whySummary
    }

    private func primaryActionTitle(for action: TodayInlineAction) -> String {
        switch action.kind {
        case .openDetail:
            return "Open step"
        case .closeActionClosure:
            return "Close step"
        default:
            return "Start now"
        }
    }

    private var modeLabel: String {
        switch state.mode {
        case .normal:
            return "Ready"
        case .recovery:
            return "Needs review"
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

    private var accessibilityLabel: String {
        var parts = ["Reality Meridian", state.dateTitle, modeLabel, state.contextSummary]
        if let heroStep = state.heroStep {
            parts.append("Start here")
            parts.append(heroStep.title)
            parts.append(heroStep.duration.label)
            parts.append(heroStep.primaryAction.title)
        } else {
            parts.append("Nothing needs you right now.")
        }
        return parts.joined(separator: ". ")
    }
}

private extension DayRailRowSlot {
    var mvpTitle: String {
        switch self {
        case .now:
            return "Now"
        case .next:
            return "Next"
        case .later:
            return "Later"
        }
    }
}
