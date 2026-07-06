import AmbitionsDesignSystem
import Foundation
import SwiftUI

extension AmbitionsDayRailView {

    func mappedRowNode(index: Int) -> some View {
        let row = state.rows.indices.contains(index) ? state.rows[index] : nil
        let color = rowColor(for: row?.slot) ?? theme.colors.textSecondary.opacity(0.58)
        return HStack(spacing: theme.spacing.xs) {
            Text(row?.slot.mvpTimeLabel ?? "")
                .font(theme.typography.caption)
                .foregroundStyle(.clear)
                .frame(width: 42, alignment: .trailing)
            ZStack {
                Circle()
                    .fill(color.opacity(row == nil ? 0.18 : 0.30))
                    .frame(width: 32, height: 32)
                Circle()
                    .fill(color.opacity(row == nil ? 0.46 : 0.86))
                    .frame(width: row == nil ? 8 : 12, height: row == nil ? 8 : 12)
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

            Button {
                openStepDetail(for: heroStep)
            } label: {
                HStack(alignment: .firstTextBaseline, spacing: theme.spacing.xs) {
                    Text(state.privacyProjection.detailTitle(heroStep.title))
                        .font((usesExpandedViewport ? theme.typography.section : theme.typography.title).weight(.semibold))
                        .foregroundStyle(theme.colors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(usesExpandedViewport ? nil : 3)
                        .accessibilityIdentifier("TodayRealityRailStepTitle")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)
            .contentShape(Rectangle())
            .accessibilityLabel("Open step")
            .accessibilityValue(state.privacyProjection.detailTitle(heroStep.title))
            .accessibilityHint("Opens Step detail with completion, move, and recovery controls.")
            .accessibilityIdentifier("TodayStartHereOpenStep")

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
                    openStepDetail(for: heroStep)
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

                currentMomentActionRow(for: heroStep)
            }

        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityAction(named: "Begin") {
            onAction(heroStep.primaryAction)
        }
        .accessibilityAction(named: "Open step") {
            openStepDetail(for: heroStep)
        }
    }


    func openStepDetail(for heroStep: DayRailHeroStepState) {
        onOpenStepDetail(heroStep.stepDetail(privacy: state.privacyProjection, contextLabel: state.contextSummary))
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
            .foregroundStyle(theme.colors.canvas)
            .padding(.horizontal, usesExpandedViewport ? theme.spacing.md : theme.spacing.lg)
            .padding(.vertical, usesExpandedViewport ? theme.spacing.sm : theme.spacing.md)
            .frame(maxWidth: .infinity)
            .background(
                Capsule(style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                theme.colors.accentWarm.opacity(0.98),
                                theme.colors.accentWarm.opacity(0.72)
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
            Text("No step is required right now")
                .font(theme.typography.title.weight(.semibold))
                .foregroundStyle(theme.colors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(usesExpandedViewport ? 4 : 2)
            Text(noStepSummary)
                .font(theme.typography.body)
                .foregroundStyle(theme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(usesExpandedViewport ? 5 : 3)
        }
    }


    var noStepSummary: String {
        let trimmed = state.contextSummary.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else {
            return "Open Field stays available from global Capture when something new needs a place."
        }
        return "\(trimmed) Open Field stays available from global Capture."
    }


    func currentMomentActionRow(for heroStep: DayRailHeroStepState) -> some View {
        let availability = TodayRootActionGate.actions(for: heroStep)
        let actions = [availability.shapeTime, availability.protectWindow, availability.recordOutcome].compactMap { $0 }

        return Group {
            if actions.isEmpty == false {
                HStack(spacing: theme.spacing.sm) {
                    ForEach(actions) { action in
                        rootActionButton(action)
                    }
                }
                .padding(.top, theme.spacing.sm)
                .accessibilityElement(children: .contain)
                .accessibilityLabel("Start here actions")
            }
        }
    }


    func rootActionButton(_ action: TodayInlineAction) -> some View {
        Button {
            onAction(action)
        } label: {
            Image(systemName: action.systemImage)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(theme.colors.textPrimary)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(theme.colors.surfaceOverlay.opacity(0.52))
                )
                .overlay(
                    Circle()
                        .stroke(theme.colors.strokeSubtle, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(action.title)
        .accessibilityIdentifier("TodayAction.\(action.kind.rawValue)")
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
                        row: row,
                        time: row.slot.mvpTimeLabel(for: index)
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
                .foregroundStyle(theme.colors.accentWarm.opacity(0.86))
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
