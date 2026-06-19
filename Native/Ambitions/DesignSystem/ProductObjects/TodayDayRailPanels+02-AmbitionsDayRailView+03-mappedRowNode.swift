import AmbitionsDesignSystem
import SwiftUI

extension AmbitionsDayRailView {

    func mappedRowNode(index: Int, fallbackSymbol: String, fallbackColor: Color) -> some View {
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


    func currentMoment(_ heroStep: DayRailHeroStepState) -> some View {
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
                    .font((usesExpandedViewport ? theme.typography.section : theme.typography.title).weight(.semibold))
                    .foregroundStyle(theme.colors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(usesExpandedViewport ? nil : 3)
                    .accessibilityIdentifier("TodayRealityRailStepTitle")
            }

            Text(usesExpandedViewport ? "Recommended step" : liveMeridianMetaLine(for: heroStep))
                .font(usesExpandedViewport ? theme.typography.caption : theme.typography.body)
                .foregroundStyle(theme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(3)

            if usesExpandedViewport {
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
                    Text("Why this?")
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

        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }


    func liveMeridianMetaLine(for heroStep: DayRailHeroStepState) -> String {
        "Now-aware fit · \(metaLine(for: heroStep))"
    }


    func primaryActionButton(for heroStep: DayRailHeroStepState) -> some View {
        Button {
            onAction(heroStep.primaryAction)
        } label: {
            HStack(spacing: theme.spacing.sm) {
                Text(primaryActionTitle(for: heroStep.primaryAction))
                    .font((usesExpandedViewport ? theme.typography.body : theme.typography.section).weight(.semibold))
                Spacer(minLength: theme.spacing.sm)
                Image(systemName: "arrow.right")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
            }
            .foregroundStyle(.black.opacity(0.92))
            .padding(.horizontal, usesExpandedViewport ? theme.spacing.md : theme.spacing.lg)
            .padding(.vertical, usesExpandedViewport ? theme.spacing.sm : theme.spacing.md)
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
                    .shadow(color: theme.colors.accentWarm.opacity(usesExpandedViewport ? 0.16 : 0.34), radius: 16, x: 0, y: 9)
            )
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("TodayRealityRailPrimaryAction")
    }


    var emptyMoment: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            HStack(spacing: theme.spacing.sm) {
                startHereOriginMarker

                Text("Start here")
                    .font(theme.typography.caption.weight(.semibold))
                    .foregroundStyle(theme.colors.accentWarm)
                    .accessibilityIdentifier("TodayRealityRailStartHereTitle")
            }
            Text(emptySourceLine)
                .font(theme.typography.caption.weight(.semibold))
                .foregroundStyle(theme.colors.textTertiary)
            Text("No step is required right now")
                .font(theme.typography.title.weight(.semibold))
                .foregroundStyle(theme.colors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(usesExpandedViewport ? 4 : 2)
            Text(state.contextSummary)
                .font(theme.typography.body)
                .foregroundStyle(theme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(usesExpandedViewport ? 5 : 3)

            emptyPathActions
                .padding(.top, theme.spacing.xs)
        }
    }


    var emptyPathActions: some View {
        Group {
            if usesExpandedViewport {
                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    ForEach(emptyPathActionItems) { item in
                        emptyPathActionButton(item, expands: true)
                    }
                }
            } else {
                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: 210), spacing: theme.spacing.sm, alignment: .leading)],
                    alignment: .leading,
                    spacing: theme.spacing.sm
                ) {
                    ForEach(emptyPathActionItems) { item in
                        emptyPathActionButton(item, expands: true)
                    }
                }
            }
        }
        .padding(.bottom, viewportSafety.emptyActionBottomClearance)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Today available actions")
    }


    func emptyPathActionButton(_ item: TodayEmptyPathAction, expands: Bool) -> some View {
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
            .frame(maxWidth: expands ? .infinity : nil, alignment: .leading)
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


    var emptyPathActionItems: [TodayEmptyPathAction] {
        [
            TodayEmptyPathAction(
                id: "capture",
                title: "Capture what changed",
                systemImage: "plus.bubble",
                action: TodayInlineAction(kind: .quickLog, title: "Capture what changed", systemImage: "plus.bubble", state: .selected, target: TodayActionTarget())
            ),
            TodayEmptyPathAction(
                id: "shape-time",
                title: "Shape Time",
                systemImage: "calendar.badge.clock",
                action: TodayInlineAction(kind: .openTime, title: "Shape Time", systemImage: "calendar.badge.clock", state: .default, target: TodayActionTarget())
            ),
            TodayEmptyPathAction(
                id: "review-context",
                title: "Review context",
                systemImage: "text.magnifyingglass",
                action: TodayInlineAction(kind: .askWhyThisMatters, title: "Review context", systemImage: "text.magnifyingglass", state: .default, target: TodayActionTarget())
            ),
            TodayEmptyPathAction(
                id: "record-outcome",
                title: "Close the loop",
                systemImage: "checkmark.seal",
                action: TodayInlineAction(kind: .closeActionClosure, title: "Close the loop", systemImage: "checkmark.seal", state: .default, target: TodayActionTarget())
            ),
            TodayEmptyPathAction(
                id: "protect-window",
                title: "Protect this window",
                systemImage: "shield",
                action: TodayInlineAction(kind: .protectLater, title: "Protect this window", systemImage: "shield", state: .default, target: TodayActionTarget())
            )
        ]
    }


    var startHereOriginMarker: some View {
        HStack(spacing: 0) {
            Rectangle()
                .fill(theme.colors.accentWarm.opacity(reduceMotion ? 0.72 : 0.46))
                .frame(width: usesExpandedViewport ? 24 : 42, height: 2)

            Circle()
                .strokeBorder(theme.colors.accentWarm.opacity(0.86), lineWidth: 2)
                .background(
                    Circle()
                        .fill(theme.colors.accentWarm.opacity(reduceMotion ? 0.20 : 0.32))
                )
                .frame(width: 12, height: 12)

            Rectangle()
                .fill(theme.colors.accentWarm.opacity(reduceMotion ? 0.72 : 0.30))
                .frame(width: usesExpandedViewport ? 10 : 16, height: 2)
        }
        .shadow(color: reduceMotion ? .clear : theme.colors.accentWarm.opacity(0.22), radius: 8, x: 0, y: 0)
        .accessibilityHidden(true)
    }


    var upNextList: some View {
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


    var accessibilityContinuitySummary: some View {
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
}
