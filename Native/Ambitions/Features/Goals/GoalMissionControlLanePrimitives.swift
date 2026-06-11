import AmbitionsDesignSystem
import SwiftUI

enum MissionControlLaneDensity: String, Sendable, CaseIterable {
    case compact
    case standard
    case expanded

    var minimumWidth: CGFloat {
        switch self {
        case .compact:
            142
        case .standard:
            154
        case .expanded:
            184
        }
    }

    var minimumHeight: CGFloat {
        switch self {
        case .compact:
            132
        case .standard:
            152
        case .expanded:
            176
        }
    }

    var detailLineLimit: Int {
        switch self {
        case .compact:
            2
        case .standard:
            3
        case .expanded:
            4
        }
    }
}

struct MissionControlLaneItem: Identifiable, Sendable, Hashable {
    let id: String
    let title: String
    let value: String
    let detail: String
    let symbolName: String
    let visualState: AmbitionVisualState
    let badgeTitle: String?
    let accessibilityIdentifier: String
    let drillDownHint: String?
    let sparkLevel: Double?
    let pulseLabel: String?

    init(
        id: String,
        title: String,
        value: String,
        detail: String,
        symbolName: String,
        visualState: AmbitionVisualState,
        badgeTitle: String? = nil,
        accessibilityIdentifier: String,
        drillDownHint: String? = nil,
        sparkLevel: Double? = nil,
        pulseLabel: String? = nil
    ) {
        self.id = id
        self.title = title
        self.value = value
        self.detail = detail
        self.symbolName = symbolName
        self.visualState = visualState
        self.badgeTitle = badgeTitle
        self.accessibilityIdentifier = accessibilityIdentifier
        self.drillDownHint = drillDownHint
        self.sparkLevel = sparkLevel
        self.pulseLabel = pulseLabel
    }

    var accessibilityLabel: String {
        [title, value, detail]
            .filter { $0.isEmpty == false }
            .joined(separator: ". ")
    }

    var accessibilityHint: String {
        drillDownHint ?? "Keeps this mission lane visible without opening a separate destination."
    }
}

struct MissionControlLaneHeader: View {
    @Environment(\.ambitionTheme) private var theme

    let eyebrow: String
    let title: String
    let subtitle: String
    let badges: [MissionControlLaneHeaderBadge]

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            Text(eyebrow)
                .font(theme.typography.micro)
                .foregroundStyle(theme.colors.accentWarm)

            if badges.isEmpty == false {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: theme.spacing.xs) {
                        ForEach(badges) { badge in
                            TagPill(badge.title, icon: badge.symbolName, state: badge.state)
                        }
                    }
                    .padding(.vertical, 1)
                }
                .accessibilityHidden(true)
            }

            Text(title)
                .font(theme.typography.section)
                .foregroundStyle(theme.colors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            Text(subtitle)
                .font(theme.typography.body)
                .foregroundStyle(theme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(([eyebrow, title, subtitle] + badges.map(\.title)).joined(separator: ". "))
    }
}

struct MissionControlLaneHeaderBadge: Identifiable, Sendable, Hashable {
    let id: String
    let title: String
    let symbolName: String?
    let state: AmbitionVisualState

    init(id: String, title: String, symbolName: String? = nil, state: AmbitionVisualState) {
        self.id = id
        self.title = title
        self.symbolName = symbolName
        self.state = state
    }
}

struct MissionControlTimeSpine: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var selectedItemID: MissionControlLaneItem.ID?

    let items: [MissionControlLaneItem]
    let defaultSelectedID: MissionControlLaneItem.ID?

    init(
        items: [MissionControlLaneItem],
        defaultSelectedID: MissionControlLaneItem.ID? = nil
    ) {
        self.items = items
        self.defaultSelectedID = defaultSelectedID
    }

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                let isSelected = selectedID == item.id
                MissionControlSpineLane(
                    item: item,
                    positionLabel: positionLabel(for: index),
                    isSelected: isSelected,
                    isFirst: index == 0,
                    isLast: index == items.count - 1,
                    onSelect: {
                        withAnimation(reduceMotion ? nil : .easeOut(duration: 0.18)) {
                            selectedItemID = item.id
                        }
                    }
                )
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("mission-control-time-spine")
    }

    private var selectedID: MissionControlLaneItem.ID? {
        selectedItemID ?? defaultSelectedID ?? items.first?.id
    }

    private func positionLabel(for index: Int) -> String {
        "\(index + 1) of \(items.count)"
    }
}

private struct MissionControlSpineLane: View {
    @Environment(\.ambitionTheme) private var theme

    let item: MissionControlLaneItem
    let positionLabel: String
    let isSelected: Bool
    let isFirst: Bool
    let isLast: Bool
    let onSelect: () -> Void

    var body: some View {
        let style = theme.stateStyle(for: isSelected ? .pressed : item.visualState)
        HStack(alignment: .top, spacing: theme.spacing.sm) {
            spineRail(style: style)

            Button(action: onSelect) {
                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                    HStack(alignment: .firstTextBaseline, spacing: theme.spacing.xs) {
                        Text(item.title)
                            .font(theme.typography.bodyEmphasized)
                            .foregroundStyle(theme.colors.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                        TagPill(positionLabel, state: item.visualState)
                    }

                    Text(item.value)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)

                    if isSelected {
                        MissionControlLaneInspector(item: item)
                            .padding(.top, theme.spacing.xxxs)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(theme.spacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                        .fill(theme.colors.surfaceOverlay)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                        .stroke(style.stroke, lineWidth: isSelected ? 1.4 : 1)
                )
            }
            .buttonStyle(.plain)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(item.accessibilityLabel)
            .accessibilityValue(isSelected ? "Selected lane. \(item.detail)" : "Lane")
            .accessibilityHint("Inspects this lane inside the MissionControlTimeSpine without opening another destination.")
            .accessibilityIdentifier("mission-control-time-spine.\(item.id)")
        }
    }

    @ViewBuilder
    private func spineRail(style: AmbitionStateStyle) -> some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(isFirst ? Color.clear : style.stroke.opacity(0.7))
                .frame(width: 2, height: 12)
            Circle()
                .fill(style.accent)
                .frame(width: 12, height: 12)
                .overlay(Circle().stroke(style.stroke, lineWidth: 2))
            Rectangle()
                .fill(isLast ? Color.clear : style.stroke.opacity(0.7))
                .frame(width: 2)
        }
        .frame(width: 16)
        .accessibilityHidden(true)
    }
}

private struct MissionControlLaneInspector: View {
    @Environment(\.ambitionTheme) private var theme

    let item: MissionControlLaneItem

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            Text("Lane inspector")
                .font(theme.typography.micro)
                .foregroundStyle(theme.colors.textTertiary)
            Text(item.detail)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
            if let hint = item.drillDownHint {
                Text(hint)
                    .font(theme.typography.micro)
                    .foregroundStyle(theme.colors.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

struct MissionControlLaneGrid: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var focusedItemID: MissionControlLaneItem.ID?

    let items: [MissionControlLaneItem]
    let density: MissionControlLaneDensity
    let showsDrillDownAffordance: Bool
    let animatedReveal: Bool
    let hasAppeared: Bool

    init(
        items: [MissionControlLaneItem],
        density: MissionControlLaneDensity = .standard,
        showsDrillDownAffordance: Bool = true,
        animatedReveal: Bool = false,
        hasAppeared: Bool = true
    ) {
        self.items = items
        self.density = density
        self.showsDrillDownAffordance = showsDrillDownAffordance
        self.animatedReveal = animatedReveal
        self.hasAppeared = hasAppeared
    }

    var body: some View {
        LazyVGrid(
            columns: [GridItem(.adaptive(minimum: density.minimumWidth), spacing: theme.spacing.sm)],
            alignment: .leading,
            spacing: theme.spacing.sm
        ) {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                MissionControlLaneSurface(
                    item: item,
                    density: density,
                    showsDrillDownAffordance: showsDrillDownAffordance,
                    revealDelay: revealDelay(for: index),
                    hasAppeared: hasAppeared,
                    isFocused: focusedItemID == item.id,
                    onFocus: {
                        withAnimation(reduceMotion ? nil : .easeOut(duration: 0.2)) {
                            focusedItemID = focusedItemID == item.id ? nil : item.id
                        }
                    }
                )
            }
        }
    }

    private func revealDelay(for index: Int) -> Double {
        guard animatedReveal, reduceMotion == false else { return 0 }
        return Double(index) * 0.04
    }
}

private struct MissionControlLaneSurface: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let item: MissionControlLaneItem
    let density: MissionControlLaneDensity
    let showsDrillDownAffordance: Bool
    let revealDelay: Double
    let hasAppeared: Bool
    let isFocused: Bool
    let onFocus: () -> Void

    var body: some View {
        let style = theme.stateStyle(for: isFocused ? .pressed : item.visualState)
        let shape = RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)

        Button(action: onFocus) {
            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                HStack(alignment: .top, spacing: theme.spacing.xs) {
                    Image(systemName: item.symbolName)
                        .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                        .foregroundStyle(style.accent)
                        .frame(width: 28, height: 28)
                        .background(Circle().fill(style.accent.opacity(0.13)))
                        .accessibilityHidden(true)

                    Spacer(minLength: theme.spacing.xs)

                    if let badgeTitle = item.badgeTitle {
                        TagPill(badgeTitle, state: item.visualState)
                    } else if let pulseLabel = item.pulseLabel {
                        ProofPulse(isActive: hasAppeared, label: pulseLabel)
                            .frame(width: 34, height: 34)
                    }
                }

                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                    Text(item.title)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textTertiary)
                    Text(item.value)
                        .font(theme.typography.bodyEmphasized)
                        .foregroundStyle(theme.colors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(item.detail)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textSecondary)
                        .lineLimit(isFocused ? max(density.detailLineLimit, 4) : density.detailLineLimit)
                        .fixedSize(horizontal: false, vertical: true)
                }

                if let sparkLevel = item.sparkLevel {
                    MissionControlLaneSparkLine(level: sparkLevel, accent: style.accent)
                }

                if showsDrillDownAffordance {
                    HStack(spacing: theme.spacing.xxxs) {
                        Text(isFocused ? "Lane expanded" : "Inspect lane")
                            .font(theme.typography.micro)
                        Image(systemName: isFocused ? "chevron.down" : "chevron.right")
                            .font(.system(size: 10, weight: .semibold))
                            .accessibilityHidden(true)
                    }
                    .foregroundStyle(style.accent)
                    .padding(.top, theme.spacing.xxxs)
                }
            }
            .frame(maxWidth: .infinity, minHeight: density.minimumHeight, alignment: .topLeading)
            .padding(theme.spacing.sm)
            .contentShape(shape)
        }
        .buttonStyle(.plain)
        .background {
            shape.fill(theme.surfaces.elevatedGradient)
        }
        .overlay {
            shape.strokeBorder(style.stroke, lineWidth: 1)
        }
        .shadow(color: style.accent.opacity(0.08), radius: 16, x: 0, y: 8)
        .opacity(hasAppeared || reduceMotion ? 1 : 0.84)
        .offset(y: hasAppeared || reduceMotion ? 0 : 6)
        .animation(
            reduceMotion ? nil : .easeOut(duration: 0.34).delay(revealDelay),
            value: hasAppeared
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(item.accessibilityLabel)
        .accessibilityValue(isFocused ? "Expanded" : "Collapsed")
        .accessibilityHint(item.accessibilityHint)
        .accessibilityIdentifier(item.accessibilityIdentifier)
    }
}

private struct MissionControlLaneSparkLine: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let level: Double
    let accent: Color

    private var normalizedLevel: Double {
        min(1, max(0.12, level))
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: 4) {
            ForEach(0..<6, id: \.self) { index in
                Capsule(style: .continuous)
                    .fill(accent.opacity(index == 5 ? 0.62 : 0.26))
                    .frame(width: 5, height: barHeight(index: index))
            }
        }
        .frame(height: 32, alignment: .bottomLeading)
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityHidden(true)
    }

    private func barHeight(index: Int) -> CGFloat {
        let base = CGFloat(normalizedLevel)
        let wave = reduceMotion ? CGFloat(index + 1) / 7 : abs(sin(Double(index) * 0.72 + normalizedLevel))
        return max(8, 10 + (base * 16) + CGFloat(wave * 10))
    }
}

extension MissionControlLaneItem {
    init(detailLane lane: GoalDetailMissionLaneState) {
        self.init(
            id: lane.kind.rawValue,
            title: lane.title,
            value: lane.headline,
            detail: [lane.summary, lane.detail].filter { $0.isEmpty == false }.joined(separator: " "),
            symbolName: lane.systemImage,
            visualState: lane.state,
            badgeTitle: lane.badgeTitle,
            accessibilityIdentifier: lane.kind.accessibilityIdentifier,
            drillDownHint: "Keeps \(lane.title) inspectable inside the MissionControlTimeSpine without adding a new destination."
        )
    }

    init(atlasLane lane: GoalMissionControlLaneState) {
        self.init(
            id: lane.id,
            title: lane.title,
            value: lane.value,
            detail: lane.detail,
            symbolName: lane.symbolName,
            visualState: lane.state.ambitionState,
            accessibilityIdentifier: "goals.mission-control-lane.\(lane.id)",
            drillDownHint: "Keeps \(lane.title) visible as a direction lane inside Goals.",
            sparkLevel: lane.level,
            pulseLabel: lane.showsProofPulse ? "Proof lane has saved proof" : nil
        )
    }

    init(boardLane lane: GoalMissionControlLaneState) {
        self.init(atlasLane: lane)
    }
}

#Preview("SI07 Mission Control Lanes") {
    MissionControlLaneGrid(
        items: [
            MissionControlLaneItem(
                id: "proof",
                title: "Proof",
                value: "2 saved",
                detail: "Latest proof stays inspectable without becoming a dashboard.",
                symbolName: "checkmark.seal",
                visualState: .success,
                accessibilityIdentifier: "preview.mission-control.proof",
                sparkLevel: 0.72,
                pulseLabel: "Proof lane has saved proof"
            ),
            MissionControlLaneItem(
                id: "source",
                title: "Source",
                value: "Needs review",
                detail: "Future source-state hook only; no Living Dream runtime is claimed.",
                symbolName: "scope",
                visualState: .warning,
                badgeTitle: "Review",
                accessibilityIdentifier: "preview.mission-control.source"
            ),
            MissionControlLaneItem(
                id: "privacy",
                title: "Privacy",
                value: "Local",
                detail: "Private goal details stay on device by default.",
                symbolName: "lock.shield",
                visualState: .selected,
                badgeTitle: "Local",
                accessibilityIdentifier: "preview.mission-control.privacy"
            ),
        ],
        density: .expanded
    )
    .padding()
    .background(LivingSurfaceBackground(context: .goals, state: .active, intensity: 0.72))
}
