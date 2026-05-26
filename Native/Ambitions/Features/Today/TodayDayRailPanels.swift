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
        ZStack(alignment: .bottom) {
            meridianAtmosphere

            VStack(alignment: .leading, spacing: 0) {
                header

                HStack(alignment: .top, spacing: theme.spacing.lg) {
                    timeSpine
                        .frame(width: dynamicTypeSize.isAccessibilitySize ? 54 : 66)

                    VStack(alignment: .leading, spacing: theme.spacing.xl) {
                        if let heroStep = state.heroStep {
                            currentMoment(heroStep)
                        } else {
                            emptyMoment
                        }

                        upNextList
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.top, theme.spacing.xl)

                Spacer(minLength: theme.spacing.lg)

                proofStrip
            }
            .padding(.horizontal, theme.spacing.xl)
            .padding(.top, theme.spacing.xl)
            .padding(.bottom, theme.spacing.lg)
        }
        .frame(maxWidth: .infinity, minHeight: dynamicTypeSize.isAccessibilitySize ? 760 : 690, alignment: .top)
        .clipShape(RoundedRectangle(cornerRadius: 38, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 38, style: .continuous)
                .stroke(theme.colors.strokeSubtle.opacity(0.34), lineWidth: 1)
        )
        .shadow(color: .black.opacity(theme.mode == .dark ? 0.46 : 0.18), radius: 28, x: 0, y: 18)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityIdentifier("TodayRealityRail")
    }

    private var meridianAtmosphere: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.015, green: 0.026, blue: 0.046),
                    Color(red: 0.018, green: 0.052, blue: 0.086),
                    Color(red: 0.010, green: 0.014, blue: 0.024)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            RadialGradient(
                colors: [theme.colors.accentWarm.opacity(0.26), .clear],
                center: .bottomTrailing,
                startRadius: 20,
                endRadius: 340
            )
            .blendMode(.screen)

            RadialGradient(
                colors: [Color.purple.opacity(0.20), .clear],
                center: .center,
                startRadius: 10,
                endRadius: 260
            )
            .blendMode(.screen)

            Canvas { context, size in
                let stars: [(Double, Double, Double)] = [
                    (0.16, 0.11, 1.0), (0.28, 0.18, 0.55), (0.43, 0.10, 0.70),
                    (0.62, 0.16, 0.45), (0.76, 0.12, 0.80), (0.89, 0.22, 0.55),
                    (0.19, 0.34, 0.42), (0.36, 0.29, 0.62), (0.55, 0.36, 0.50),
                    (0.81, 0.41, 0.72), (0.20, 0.58, 0.52), (0.50, 0.61, 0.40),
                    (0.70, 0.56, 0.64), (0.88, 0.67, 0.44)
                ]
                for star in stars {
                    let rect = CGRect(
                        x: size.width * star.0,
                        y: size.height * star.1,
                        width: 1.2 + star.2,
                        height: 1.2 + star.2
                    )
                    context.fill(Path(ellipseIn: rect), with: .color(.white.opacity(0.26 + star.2 * 0.18)))
                }
            }
            .allowsHitTesting(false)

            VStack {
                Spacer()
                LinearGradient(
                    colors: [.clear, theme.colors.accentWarm.opacity(0.10), .black.opacity(0.28)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 180)
            }
            .allowsHitTesting(false)
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                Text("Today")
                    .font(theme.typography.hero)
                    .foregroundStyle(theme.colors.textPrimary)
                    .minimumScaleFactor(0.84)
                    .lineLimit(1)

                Text(dateContextLine)
                    .font(theme.typography.body)
                    .foregroundStyle(theme.colors.textSecondary)
                    .lineLimit(1)
            }

            Spacer(minLength: theme.spacing.md)

            HStack(spacing: theme.spacing.xs) {
                Circle()
                    .fill(Color.green.opacity(0.88))
                    .frame(width: 8, height: 8)
                Text("On-device")
                    .font(theme.typography.caption.weight(.semibold))
                    .foregroundStyle(theme.colors.textSecondary)
                    .lineLimit(1)
            }
            .padding(.horizontal, theme.spacing.sm)
            .padding(.vertical, theme.spacing.xxs)
            .background(Capsule().fill(theme.colors.canvasElevated.opacity(0.50)))
            .overlay(Capsule().stroke(theme.colors.strokeSubtle.opacity(0.34), lineWidth: 1))
            .accessibilityLabel("On-device")
        }
    }

    private var timeSpine: some View {
        VStack(spacing: 0) {
            timeTick("6 AM", prominent: false)
            verticalSegment(height: 48)
            currentTimeNode
            verticalSegment(height: 58)
            timeTick("12 PM", prominent: false)
            verticalSegment(height: 70)
            mappedRowNode(index: 0, fallbackSymbol: "person.2.fill", fallbackColor: Color.blue.opacity(0.75))
            verticalSegment(height: 54)
            timeTick("4 PM", prominent: false)
            verticalSegment(height: 44)
            mappedRowNode(index: 1, fallbackSymbol: "rectangle.stack.fill", fallbackColor: Color.green.opacity(0.76))
            verticalSegment(height: 54)
            timeTick("8 PM", prominent: false)
        }
        .padding(.top, theme.spacing.xs)
        .accessibilityHidden(true)
    }

    private func timeTick(_ label: String, prominent: Bool) -> some View {
        HStack(spacing: theme.spacing.xs) {
            Text(label)
                .font(theme.typography.caption)
                .foregroundStyle(prominent ? theme.colors.accentWarm : theme.colors.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
                .frame(width: 42, alignment: .trailing)

            Circle()
                .fill(prominent ? theme.colors.accentWarm : theme.colors.textSecondary.opacity(0.58))
                .frame(width: prominent ? 8 : 5, height: prominent ? 8 : 5)
        }
    }

    private func verticalSegment(height: CGFloat) -> some View {
        Rectangle()
            .fill(theme.colors.textSecondary.opacity(0.36))
            .frame(width: 1.4, height: height)
            .offset(x: 25)
    }

    private var currentTimeNode: some View {
        HStack(spacing: theme.spacing.xs) {
            Text("Now")
                .font(theme.typography.caption.weight(.semibold))
                .foregroundStyle(theme.colors.accentWarm)
                .frame(width: 42, alignment: .trailing)

            ZStack {
                Circle()
                    .fill(theme.colors.accentWarm.opacity(0.20))
                    .frame(width: 32, height: 32)
                    .blur(radius: 2)
                Circle()
                    .fill(theme.colors.accentWarm)
                    .frame(width: 14, height: 14)
                Circle()
                    .stroke(theme.colors.accentWarm.opacity(0.78), lineWidth: 2)
                    .frame(width: 26, height: 26)
            }
        }
    }

    private func mappedRowNode(index: Int, fallbackSymbol: String, fallbackColor: Color) -> some View {
        let row = state.rows.indices.contains(index) ? state.rows[index] : nil
        let color = rowColor(for: row?.slot) ?? fallbackColor
        return HStack(spacing: theme.spacing.xs) {
            Text(row?.slot.mvpTimeLabel ?? "")
                .font(theme.typography.caption)
                .foregroundStyle(.clear)
                .frame(width: 42, alignment: .trailing)
            ZStack {
                Circle()
                    .fill(color.opacity(0.28))
                    .frame(width: 30, height: 30)
                Image(systemName: row?.slot.mvpSymbol ?? fallbackSymbol)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.88))
            }
        }
    }

    private func currentMoment(_ heroStep: DayRailHeroStepState) -> some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            Text("Start here")
                .font(theme.typography.caption.weight(.semibold))
                .foregroundStyle(theme.colors.accentWarm)
                .lineLimit(1)

            HStack(alignment: .firstTextBaseline, spacing: theme.spacing.xs) {
                Text(state.privacyProjection.detailTitle(heroStep.title))
                    .font(theme.typography.title.weight(.semibold))
                    .foregroundStyle(theme.colors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(dynamicTypeSize.isAccessibilitySize ? 5 : 3)
                    .accessibilityIdentifier("TodayRealityRailStepTitle")

                Image(systemName: "sparkle")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.purple.opacity(0.9))
                    .accessibilityHidden(true)
            }

            Text(metaLine(for: heroStep))
                .font(theme.typography.body)
                .foregroundStyle(theme.colors.textSecondary)
                .lineLimit(2)

            Text(heroCopy(for: heroStep))
                .font(theme.typography.body)
                .foregroundStyle(theme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(dynamicTypeSize.isAccessibilitySize ? 6 : 3)

            HStack(spacing: theme.spacing.xs) {
                meridianChip(heroStep.fitLabel.isEmpty ? "Open block" : heroStep.fitLabel)
                meridianChip(heroStep.duration.label.isEmpty ? "Suggested" : heroStep.duration.label)
                meridianChip(state.privacyProjection.sourceLabel)
            }
            .padding(.top, theme.spacing.xs)

            Button {
                onAction(heroStep.primaryAction)
            } label: {
                HStack(spacing: theme.spacing.sm) {
                    Text(primaryActionTitle(for: heroStep.primaryAction))
                        .font(theme.typography.section.weight(.semibold))
                    Spacer(minLength: theme.spacing.sm)
                    Image(systemName: "arrow.right")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                }
                .foregroundStyle(.black.opacity(0.92))
                .padding(.horizontal, theme.spacing.lg)
                .padding(.vertical, theme.spacing.md)
                .frame(maxWidth: .infinity)
                .background(
                    Capsule(style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    theme.colors.accentWarm.opacity(0.96),
                                    Color(red: 1.0, green: 0.73, blue: 0.25)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: theme.colors.accentWarm.opacity(0.34), radius: 16, x: 0, y: 9)
                )
            }
            .buttonStyle(.plain)
            .padding(.top, theme.spacing.sm)
            .accessibilityIdentifier("TodayRealityRailPrimaryAction")

            Button {
                onOpenStepDetail(heroStep.stepDetail(privacy: state.privacyProjection, contextLabel: state.contextSummary))
            } label: {
                Label("Why this?", systemImage: "chevron.right")
                    .font(theme.typography.caption.weight(.semibold))
                    .labelStyle(.titleAndIcon)
                    .foregroundStyle(theme.colors.accentWarm)
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("TodayMFPWhyThis")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var emptyMoment: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            Text("Start here")
                .font(theme.typography.caption.weight(.semibold))
                .foregroundStyle(theme.colors.accentWarm)
            Text("Choose one clear step")
                .font(theme.typography.title.weight(.semibold))
                .foregroundStyle(theme.colors.textPrimary)
            Text(state.contextSummary)
                .font(theme.typography.body)
                .foregroundStyle(theme.colors.textSecondary)
        }
    }

    private var upNextList: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            Text("Up next")
                .font(theme.typography.caption.weight(.semibold))
                .foregroundStyle(theme.colors.textTertiary)
                .textCase(.uppercase)
                .tracking(0.7)

            if state.rows.isEmpty {
                upNextRow(time: "12:15 PM", title: "Support queue", subtitle: "Internal", duration: "45 min")
                upNextRow(time: "3:00 PM", title: "Team sync", subtitle: "Collaboration", duration: "1h")
                upNextRow(time: "5:15 PM", title: "Review deck", subtitle: "Shallow work", duration: "45 min")
            } else {
                ForEach(Array(state.rows.enumerated()), id: \.element.id) { index, row in
                    upNextRow(
                        time: row.slot.mvpTimeLabel(for: index),
                        title: state.privacyProjection.detailTitle(row.title),
                        subtitle: row.subtitle,
                        duration: row.duration.label
                    )
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func upNextRow(time: String, title: String, subtitle: String, duration: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: theme.spacing.md) {
            Text(time)
                .font(theme.typography.body.weight(.semibold))
                .foregroundStyle(theme.colors.textPrimary.opacity(0.86))
                .frame(width: 82, alignment: .leading)
                .lineLimit(1)
                .minimumScaleFactor(0.75)

            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                Text(title)
                    .font(theme.typography.body.weight(.semibold))
                    .foregroundStyle(theme.colors.textPrimary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                Text([duration, subtitle].filter { $0.isEmpty == false }.joined(separator: " · "))
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                    .lineLimit(2)
            }
        }
    }

    private var proofStrip: some View {
        HStack(spacing: theme.spacing.sm) {
            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                Text(state.proofSlot.title)
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
                .frame(width: 30, height: 30)
                .background(Circle().fill(theme.colors.canvasElevated.opacity(0.58)))
        }
        .padding(theme.spacing.md)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(theme.colors.canvasElevated.opacity(0.42))
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(theme.colors.strokeSubtle.opacity(0.30), lineWidth: 1)
                )
        )
        .accessibilityIdentifier("TodayMFPProofStrip")
    }

    private func meridianChip(_ label: String) -> some View {
        Text(label.isEmpty ? "Local" : label)
            .font(theme.typography.caption.weight(.semibold))
            .foregroundStyle(theme.colors.textSecondary)
            .lineLimit(1)
            .minimumScaleFactor(0.75)
            .padding(.horizontal, theme.spacing.sm)
            .padding(.vertical, theme.spacing.xxxs)
            .background(Capsule().fill(theme.colors.canvasElevated.opacity(0.48)))
            .overlay(Capsule().stroke(theme.colors.strokeSubtle.opacity(0.28), lineWidth: 1))
    }

    private func rowColor(for slot: DayRailRowSlot?) -> Color? {
        switch slot {
        case .now:
            return theme.colors.accentWarm
        case .next:
            return Color.blue.opacity(0.78)
        case .later:
            return Color.purple.opacity(0.76)
        case nil:
            return nil
        }
    }

    private func metaLine(for heroStep: DayRailHeroStepState) -> String {
        let duration = heroStep.duration.label.isEmpty ? heroStep.fitLabel : heroStep.duration.label
        return [duration, state.contextSummary].filter { $0.isEmpty == false }.joined(separator: " · ")
    }

    private func heroCopy(for heroStep: DayRailHeroStepState) -> String {
        if heroStep.becauseLine.isEmpty == false {
            return heroStep.becauseLine
        }
        if heroStep.subtitle.isEmpty == false {
            return heroStep.subtitle
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

    private var dateContextLine: String {
        [state.dateTitle, modeLabel].filter { $0.isEmpty == false }.joined(separator: " · ")
    }

    private var proofSummary: String {
        if state.proofSlot.noSilentChanges {
            return "Receipts, closure, and proof stay local."
        }
        return state.proofSlot.subtitle
    }

    private var modeLabel: String {
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

    private var accessibilityLabel: String {
        var parts = ["Today. Reality Meridian", state.dateTitle, modeLabel, state.contextSummary]
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
    var mvpSymbol: String {
        switch self {
        case .now:
            return "target"
        case .next:
            return "person.2.fill"
        case .later:
            return "doc.text.fill"
        }
    }

    var mvpTimeLabel: String {
        switch self {
        case .now:
            return "10:05 AM"
        case .next:
            return "12:15 PM"
        case .later:
            return "5:15 PM"
        }
    }

    func mvpTimeLabel(for index: Int) -> String {
        switch self {
        case .now:
            return index == 0 ? "Now" : "10:05 AM"
        case .next:
            return index <= 1 ? "12:15 PM" : "3:00 PM"
        case .later:
            return "5:15 PM"
        }
    }
}
