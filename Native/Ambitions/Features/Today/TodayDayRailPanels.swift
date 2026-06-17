import AmbitionsDesignSystem
import SwiftUI

private struct TodayEmptyPathAction: Identifiable {
    let id: String
    let title: String
    let systemImage: String
    let action: TodayInlineAction
}

private enum TodayMeridianZoom: String, CaseIterable {
    case window
    case day

    var title: String {
        switch self {
        case .window: "Start Here"
        case .day: "Meridian"
        }
    }
}

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
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var meridianZoom: TodayMeridianZoom = .window

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
        let objectStageContract = TodayObjectStagePrimitiveContract.current

        ZStack(alignment: .bottom) {
            meridianAtmosphere

            GeometryReader { proxy in
                let horizontalInset = dynamicTypeSize.isAccessibilitySize
                    ? theme.spacing.md
                    : max(theme.spacing.md, proxy.size.width * 0.055)
                let railWidth = dynamicTypeSize.isAccessibilitySize ? 34.0 : max(68.0, proxy.size.width * 0.19)

                VStack(alignment: .leading, spacing: 0) {
                    if dynamicTypeSize.isAccessibilitySize {
                        accessibilityContextCrown
                    } else {
                        todayModeSelector
                            .padding(.bottom, theme.spacing.md)
                    }

                    HStack(alignment: .top, spacing: theme.spacing.lg) {
                        timeSpine
                            .frame(width: railWidth)

                        VStack(alignment: .leading, spacing: dynamicTypeSize.isAccessibilitySize ? theme.spacing.lg : theme.spacing.xl) {
                            if let heroStep = state.heroStep {
                                currentMoment(heroStep)
                                    .padding(.top, dynamicTypeSize.isAccessibilitySize ? theme.spacing.xs : theme.spacing.sm)
                            } else {
                                emptyMoment
                                    .padding(.top, dynamicTypeSize.isAccessibilitySize ? theme.spacing.xs : theme.spacing.sm)
                            }

                            if dynamicTypeSize.isAccessibilitySize == false {
                                upNextList
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.top, dynamicTypeSize.isAccessibilitySize ? theme.spacing.lg : theme.spacing.xl)

                    Spacer(minLength: theme.spacing.lg)
                }
                .padding(.horizontal, horizontalInset)
                .padding(.top, topChromeClearance)
                .padding(.bottom, theme.spacing.lg)
            }
        }
        .frame(maxWidth: .infinity, minHeight: dynamicTypeSize.isAccessibilitySize ? 700 : 760, alignment: .top)
        .padding(.horizontal, -theme.spacing.lg)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityValue(objectStageContract.firstViewportStructure)
        .accessibilityIdentifier("TodayRealityRail")
    }

    private var meridianAtmosphere: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.006, green: 0.014, blue: 0.027),
                    Color(red: 0.010, green: 0.035, blue: 0.064),
                    Color(red: 0.006, green: 0.010, blue: 0.018)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            RadialGradient(
                colors: [theme.colors.accentWarm.opacity(0.32), .clear],
                center: .bottomTrailing,
                startRadius: 10,
                endRadius: 380
            )
            .blendMode(.screen)

            RadialGradient(
                colors: [theme.colors.accentPrimary.opacity(0.10), .clear],
                center: .center,
                startRadius: 48,
                endRadius: 330
            )
            .blendMode(.screen)

            meridianOrientationField
            horizonField
        }
        .ignoresSafeArea()
    }

    private var topChromeClearance: CGFloat {
        dynamicTypeSize.isAccessibilitySize ? 180 : 116
    }

    private var meridianOrientationField: some View {
        Canvas { context, size in
            let sweeps: [(CGFloat, CGFloat, CGFloat)] = [
                (0.16, 0.34, 0.10),
                (0.31, 0.55, 0.08),
                (0.52, 0.76, 0.06)
            ]

            for sweep in sweeps {
                var path = Path()
                path.move(to: CGPoint(x: -size.width * 0.10, y: size.height * sweep.0))
                path.addCurve(
                    to: CGPoint(x: size.width * 1.08, y: size.height * sweep.1),
                    control1: CGPoint(x: size.width * 0.24, y: size.height * (sweep.0 - 0.05)),
                    control2: CGPoint(x: size.width * 0.70, y: size.height * (sweep.1 + 0.07))
                )
                context.stroke(
                    path,
                    with: .color(theme.colors.strokeSubtle.opacity(sweep.2)),
                    style: StrokeStyle(lineWidth: 1, lineCap: .round, dash: [6, 18])
                )
            }
        }
        .opacity(reduceMotion ? 0.42 : 0.74)
        .allowsHitTesting(false)
    }

    private var horizonField: some View {
        ZStack(alignment: .bottom) {
            VStack {
                Spacer()
                LinearGradient(
                    colors: [.clear, theme.colors.accentWarm.opacity(0.12), .black.opacity(0.44)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 230)
            }

            Canvas { context, size in
                var farRidge = Path()
                farRidge.move(to: CGPoint(x: 0, y: size.height))
                farRidge.addLine(to: CGPoint(x: 0, y: size.height * 0.82))
                farRidge.addLine(to: CGPoint(x: size.width * 0.20, y: size.height * 0.77))
                farRidge.addLine(to: CGPoint(x: size.width * 0.40, y: size.height * 0.84))
                farRidge.addLine(to: CGPoint(x: size.width * 0.62, y: size.height * 0.75))
                farRidge.addLine(to: CGPoint(x: size.width * 0.82, y: size.height * 0.80))
                farRidge.addLine(to: CGPoint(x: size.width, y: size.height * 0.72))
                farRidge.addLine(to: CGPoint(x: size.width, y: size.height))
                farRidge.closeSubpath()
                context.fill(farRidge, with: .color(.black.opacity(0.26)))

                var nearRidge = Path()
                nearRidge.move(to: CGPoint(x: 0, y: size.height))
                nearRidge.addLine(to: CGPoint(x: 0, y: size.height * 0.90))
                nearRidge.addLine(to: CGPoint(x: size.width * 0.22, y: size.height * 0.84))
                nearRidge.addLine(to: CGPoint(x: size.width * 0.47, y: size.height * 0.92))
                nearRidge.addLine(to: CGPoint(x: size.width * 0.74, y: size.height * 0.82))
                nearRidge.addLine(to: CGPoint(x: size.width, y: size.height * 0.88))
                nearRidge.addLine(to: CGPoint(x: size.width, y: size.height))
                nearRidge.closeSubpath()
                context.fill(nearRidge, with: .color(.black.opacity(0.48)))
            }
            .frame(height: 260)
            .allowsHitTesting(false)
        }
        .allowsHitTesting(false)
    }

    private var compactContextCrown: some View {
        HStack(alignment: .center, spacing: theme.spacing.sm) {
            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                Text("Today")
                    .font(theme.typography.caption.weight(.semibold))
                    .foregroundStyle(theme.colors.textTertiary)
                    .textCase(.uppercase)
                    .tracking(0.8)

                Text(dateContextLine)
                    .font(theme.typography.section.weight(.semibold))
                    .foregroundStyle(theme.colors.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
            }

            Spacer(minLength: theme.spacing.md)

            onDeviceSignal(font: theme.typography.caption.weight(.semibold), dotSize: 8)
        }
        .accessibilityIdentifier("TodayRealityRailContextCrown")
    }

    private var accessibilityContextCrown: some View {
        HStack(alignment: .center, spacing: theme.spacing.sm) {
            Text(dateContextLine)
                .font(theme.typography.caption.weight(.semibold))
                .foregroundStyle(theme.colors.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.78)

            Spacer(minLength: theme.spacing.sm)

            onDeviceSignal(font: theme.typography.micro.weight(.semibold), dotSize: 7)
        }
        .dynamicTypeSize(...DynamicTypeSize.accessibility1)
        .accessibilityIdentifier("TodayRealityRailAccessibilityContextCrown")
    }

    private func onDeviceSignal(font: Font, dotSize: CGFloat) -> some View {
        HStack(spacing: theme.spacing.xs) {
            Circle()
                .fill(Color.green.opacity(0.90))
                .frame(width: dotSize, height: dotSize)
                .accessibilityHidden(true)
            Text("On-device")
                .font(font)
                .foregroundStyle(theme.colors.textSecondary)
                .lineLimit(1)
        }
        .accessibilityLabel("On-device")
    }

    private var todayModeSelector: some View {
        Picker("Today mode", selection: $meridianZoom) {
            ForEach(TodayMeridianZoom.allCases, id: \.self) { zoom in
                Text(zoom.title).tag(zoom)
            }
        }
        .pickerStyle(.segmented)
        .accessibilityIdentifier("TodayRealityMeridianModeSelector")
        .accessibilityLabel("Today mode")
        .accessibilityHint("Switches between the recommended step and the day meridian.")
    }

    private var timeSpine: some View {
        Group {
            if dynamicTypeSize.isAccessibilitySize {
                compactTimeSpine
            } else {
                VStack(spacing: 0) {
                    timeTick("6 AM", prominent: false)
                    verticalSegment(height: 50)
                    currentTimeNode
                    verticalSegment(height: 58)
                    timeTick("12 PM", prominent: false)
                    verticalSegment(height: 72)
                    mappedRowNode(index: 0, fallbackSymbol: "person.2.fill", fallbackColor: Color.blue.opacity(0.75))
                    verticalSegment(height: 56)
                    timeTick("4 PM", prominent: false)
                    verticalSegment(height: 46)
                    mappedRowNode(index: 1, fallbackSymbol: "person.2.fill", fallbackColor: Color.green.opacity(0.76))
                    verticalSegment(height: 54)
                    mappedRowNode(index: 2, fallbackSymbol: "doc.text.fill", fallbackColor: Color.purple.opacity(0.76))
                    verticalSegment(height: 34)
                    timeTick("8 PM", prominent: false)
                }
            }
        }
        .padding(.top, theme.spacing.xs)
        .accessibilityHidden(true)
    }

    private var compactTimeSpine: some View {
        VStack(spacing: 0) {
            compactRailNode(color: theme.colors.textSecondary.opacity(0.62), size: 5)
            verticalSegment(height: 38)
            compactRailNode(color: theme.colors.accentWarm, size: 18, halo: true)
            verticalSegment(height: 52)
            compactRailNode(color: Color.blue.opacity(0.78), size: 14)
            verticalSegment(height: 44)
            compactRailNode(color: Color.green.opacity(0.76), size: 13)
            verticalSegment(height: 42)
            compactRailNode(color: Color.purple.opacity(0.76), size: 13)
        }
        .frame(width: 28, alignment: .center)
    }

    private func compactRailNode(color: Color, size: CGFloat, halo: Bool = false) -> some View {
        ZStack {
            if halo {
                Circle()
                    .fill(color.opacity(0.24))
                    .frame(width: size + 18, height: size + 18)
            }
            Circle()
                .fill(color)
                .frame(width: size, height: size)
        }
        .frame(width: 28, height: max(28, size + 18))
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
                .fill(prominent ? theme.colors.accentWarm : theme.colors.textSecondary.opacity(0.60))
                .frame(width: prominent ? 8 : 5, height: prominent ? 8 : 5)
        }
    }

    private func verticalSegment(height: CGFloat) -> some View {
        Rectangle()
            .fill(theme.colors.textSecondary.opacity(0.34))
            .frame(width: 1.25, height: height)
            .offset(x: 25)
    }

    private var currentTimeNode: some View {
        TimelineView(.periodic(from: .now, by: 60)) { timeline in
            currentTimeNode(date: timeline.date)
        }
        .accessibilityIdentifier("TodayRealityRailLiveNow")
    }

    private func currentTimeNode(date: Date) -> some View {
        HStack(spacing: theme.spacing.xs) {
            VStack(alignment: .trailing, spacing: 1) {
                Text(date, format: .dateTime.hour().minute())
                    .font(theme.typography.micro.weight(.semibold))
                    .foregroundStyle(theme.colors.accentWarm)
                    .lineLimit(1)
                    .minimumScaleFactor(0.62)
                Text("Live now")
                    .font(theme.typography.caption.weight(.semibold))
                    .foregroundStyle(theme.colors.accentWarm)
            }
            .frame(width: 42, alignment: .trailing)

            ZStack {
                Circle()
                    .fill(theme.colors.accentWarm.opacity(reduceMotion ? 0.18 : 0.22))
                    .frame(width: 42, height: 42)
                    .blur(radius: reduceMotion ? 0 : 2)
                Circle()
                    .fill(theme.colors.accentWarm)
                    .frame(width: 16, height: 16)
                Circle()
                    .stroke(theme.colors.accentWarm.opacity(0.78), lineWidth: 2)
                    .frame(width: 30, height: 30)
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
                    .fill(color.opacity(0.30))
                    .frame(width: 32, height: 32)
                Image(systemName: row?.slot.mvpSymbol ?? fallbackSymbol)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.90))
            }
        }
    }

    private func currentMoment(_ heroStep: DayRailHeroStepState) -> some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            HStack(spacing: theme.spacing.sm) {
                startHereOriginMarker

                Text("Start here")
                    .font(theme.typography.caption.weight(.semibold))
                    .foregroundStyle(theme.colors.accentWarm)
                    .lineLimit(1)
            }
            .accessibilityIdentifier("TodayRealityRailStartHereTitle")

            HStack(alignment: .firstTextBaseline, spacing: theme.spacing.xs) {
                Text(state.privacyProjection.detailTitle(heroStep.title))
                    .font((dynamicTypeSize.isAccessibilitySize ? theme.typography.section : theme.typography.title).weight(.semibold))
                    .foregroundStyle(theme.colors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(dynamicTypeSize.isAccessibilitySize ? nil : 3)
                    .accessibilityIdentifier("TodayRealityRailStepTitle")
            }

            Text(dynamicTypeSize.isAccessibilitySize ? "Recommended step" : liveMeridianMetaLine(for: heroStep))
                .font(dynamicTypeSize.isAccessibilitySize ? theme.typography.caption : theme.typography.body)
                .foregroundStyle(theme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(3)

            if dynamicTypeSize.isAccessibilitySize {
                primaryActionButton(for: heroStep)
                    .padding(.top, theme.spacing.xs)
            } else {
                Text(heroCopy(for: heroStep))
                    .font(theme.typography.body)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(3)

                Button {
                    onOpenStepDetail(heroStep.stepDetail(privacy: state.privacyProjection, contextLabel: state.contextSummary))
                } label: {
                    Text("Trust details")
                        .font(theme.typography.caption.weight(.semibold))
                        .foregroundStyle(theme.colors.textTertiary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, theme.spacing.xxs)
                        .overlay(
                            Rectangle()
                                .fill(theme.colors.strokeSubtle)
                                .frame(height: 1),
                            alignment: .bottom
                        )
                }
                .buttonStyle(.plain)
                .padding(.top, theme.spacing.xs)
                .accessibilityIdentifier("TodayStartHereSourceFreshness")

                primaryActionButton(for: heroStep)
                    .padding(.top, theme.spacing.sm)
            }

            HStack(spacing: theme.spacing.md) {
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

                if heroStep.secondaryAction != nil {
                    Button {
                        onShowAnother(heroStep)
                    } label: {
                        Text(secondaryActionTitle(for: heroStep.secondaryAction))
                            .font(theme.typography.caption.weight(.semibold))
                            .foregroundStyle(theme.colors.textSecondary)
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("TodayMFPAdjust")
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func liveMeridianMetaLine(for heroStep: DayRailHeroStepState) -> String {
        "Now-aware fit · \(metaLine(for: heroStep))"
    }

    private func primaryActionButton(for heroStep: DayRailHeroStepState) -> some View {
        Button {
            onAction(heroStep.primaryAction)
        } label: {
            HStack(spacing: theme.spacing.sm) {
                Text(primaryActionTitle(for: heroStep.primaryAction))
                    .font((dynamicTypeSize.isAccessibilitySize ? theme.typography.body : theme.typography.section).weight(.semibold))
                Spacer(minLength: theme.spacing.sm)
                Image(systemName: "arrow.right")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
            }
            .foregroundStyle(.black.opacity(0.92))
            .padding(.horizontal, dynamicTypeSize.isAccessibilitySize ? theme.spacing.md : theme.spacing.lg)
            .padding(.vertical, dynamicTypeSize.isAccessibilitySize ? theme.spacing.sm : theme.spacing.md)
            .frame(maxWidth: .infinity)
            .background(
                Capsule(style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                theme.colors.accentWarm.opacity(0.98),
                                Color(red: 1.0, green: 0.72, blue: 0.24)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: theme.colors.accentWarm.opacity(dynamicTypeSize.isAccessibilitySize ? 0.16 : 0.34), radius: 16, x: 0, y: 9)
            )
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("TodayRealityRailPrimaryAction")
    }

    private var emptyMoment: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            HStack(spacing: theme.spacing.sm) {
                startHereOriginMarker

                Text("Available now")
                    .font(theme.typography.caption.weight(.semibold))
                    .foregroundStyle(theme.colors.accentWarm)
            }
            Text(emptySourceLine)
                .font(theme.typography.caption.weight(.semibold))
                .foregroundStyle(theme.colors.textTertiary)
            Text("This window can hold a step")
                .font(theme.typography.title.weight(.semibold))
                .foregroundStyle(theme.colors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(dynamicTypeSize.isAccessibilitySize ? 4 : 2)
            Text(state.contextSummary)
                .font(theme.typography.body)
                .foregroundStyle(theme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(dynamicTypeSize.isAccessibilitySize ? 5 : 3)

            emptyPathActions
                .padding(.top, theme.spacing.xs)
        }
    }

    private var emptyPathActions: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            ForEach(emptyPathActionItems) { item in
                Button {
                    onAction(item.action)
                } label: {
                    HStack(spacing: theme.spacing.sm) {
                        Image(systemName: item.systemImage)
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .frame(width: 16)
                            .accessibilityHidden(true)
                        Text(item.title)
                            .font(theme.typography.caption.weight(.semibold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.78)
                    }
                    .foregroundStyle(theme.colors.textPrimary)
                    .padding(.horizontal, theme.spacing.sm)
                    .padding(.vertical, theme.spacing.xs)
                    .frame(maxWidth: dynamicTypeSize.isAccessibilitySize ? .infinity : nil, alignment: .leading)
                    .background(
                        Capsule(style: .continuous)
                            .fill(theme.colors.surfaceOverlay.opacity(0.34))
                    )
                    .overlay(
                        Capsule(style: .continuous)
                            .stroke(theme.colors.strokeSubtle.opacity(0.72), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("TodayEmptyPath.\(item.id)")
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Today available actions")
    }

    private var emptyPathActionItems: [TodayEmptyPathAction] {
        [
            TodayEmptyPathAction(
                id: "capture",
                title: "Add what changed",
                systemImage: "plus.bubble",
                action: TodayInlineAction(kind: .quickLog, title: "Add what changed", systemImage: "plus.bubble", state: .selected, target: TodayActionTarget())
            ),
            TodayEmptyPathAction(
                id: "protect-window",
                title: "Protect this window",
                systemImage: "shield",
                action: TodayInlineAction(kind: .protectLater, title: "Protect this window", systemImage: "shield", state: .default, target: TodayActionTarget())
            )
        ]
    }

    private var startHereOriginMarker: some View {
        HStack(spacing: 0) {
            Rectangle()
                .fill(theme.colors.accentWarm.opacity(reduceMotion ? 0.72 : 0.46))
                .frame(width: dynamicTypeSize.isAccessibilitySize ? 24 : 42, height: 2)

            Circle()
                .strokeBorder(theme.colors.accentWarm.opacity(0.86), lineWidth: 2)
                .background(
                    Circle()
                        .fill(theme.colors.accentWarm.opacity(reduceMotion ? 0.20 : 0.32))
                )
                .frame(width: 12, height: 12)

            Rectangle()
                .fill(theme.colors.accentWarm.opacity(reduceMotion ? 0.72 : 0.30))
                .frame(width: dynamicTypeSize.isAccessibilitySize ? 10 : 16, height: 2)
        }
        .shadow(color: reduceMotion ? .clear : theme.colors.accentWarm.opacity(0.22), radius: 8, x: 0, y: 0)
        .accessibilityHidden(true)
    }

    private var upNextList: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            HStack(spacing: theme.spacing.xs) {
                Rectangle()
                    .fill(theme.colors.strokeSubtle.opacity(0.28))
                    .frame(width: 24, height: 1)
                    .accessibilityHidden(true)

                Text("Up next")
                    .font(theme.typography.caption.weight(.semibold))
                    .foregroundStyle(theme.colors.textTertiary)
                    .textCase(.uppercase)
                    .tracking(0.7)
            }

            if state.rows.isEmpty {
                Text("Start here appears when this window can hold it.")
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
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
        .padding(.top, theme.spacing.xs)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var accessibilityContinuitySummary: some View {
        HStack(alignment: .top, spacing: theme.spacing.sm) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.green.opacity(0.86))
                .accessibilityHidden(true)

            Text(proofSummary)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(2)
        }
        .padding(.top, theme.spacing.xs)
        .accessibilityIdentifier("TodayRealityRailAccessibilityContinuity")
    }

    private func upNextRow(time: String, title: String, subtitle: String, duration: String) -> some View {
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

    private var continuityDock: some View {
        HStack(spacing: theme.spacing.sm) {
            Circle()
                .fill(Color.green.opacity(0.82))
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

    private func nonEmpty(_ value: String?, fallback: String) -> String {
        guard let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines),
              trimmed.isEmpty == false else {
            return fallback
        }
        return trimmed
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
        return ["Recommended step", duration, state.contextSummary]
            .filter { $0.isEmpty == false }
            .joined(separator: " · ")
    }

    private func heroCopy(for heroStep: DayRailHeroStepState) -> String {
        if heroStep.receiptItem.freshness == .unavailable {
            return "Ambitions can hold the space until a step fits."
        }
        if heroStep.becauseLine.isEmpty == false {
            return heroStep.becauseLine
        }
        if heroStep.subtitle.isEmpty == false {
            return heroStep.subtitle
        }
        return heroStep.whySummary
    }

    private var emptySourceLine: String {
        state.mode == .empty
            ? "Ambitions can hold the space until a step fits."
            : "Choice stays open."
    }

    private func receiptLabel(for heroStep: DayRailHeroStepState) -> String {
        if let reviewLabel = heroStep.receiptItem.reviewLabel,
           reviewLabel.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false {
            return reviewLabel
        }

        if heroStep.receiptItem.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false {
            return "Receipt"
        }

        return "Receipt ready"
    }

    private func primaryActionTitle(for action: TodayInlineAction) -> String {
        switch action.kind {
        case .openDetail:
            return "Open step"
        case .closeActionClosure:
            return "Still counts"
        default:
            return "Start now"
        }
    }

    private func secondaryActionTitle(for action: TodayInlineAction?) -> String {
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
            parts.append("Attached to the current Now node")
            parts.append(heroStep.title)
            parts.append(heroStep.duration.label)
            parts.append("Source \(state.privacyProjection.sourceLabel)")
            parts.append("Freshness \(heroStep.receiptItem.freshness.label)")
            parts.append("Receipt \(receiptLabel(for: heroStep))")
            parts.append(primaryActionTitle(for: heroStep.primaryAction))
        } else {
            parts.append("Start here is attached to the current Now node.")
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
            return "Now"
        case .next:
            return "Next"
        case .later:
            return "Later"
        }
    }

    func mvpTimeLabel(for index: Int) -> String {
        switch self {
        case .now:
            return index == 0 ? "Now" : "Current"
        case .next:
            return "Next"
        case .later:
            return "Later"
        }
    }
}
