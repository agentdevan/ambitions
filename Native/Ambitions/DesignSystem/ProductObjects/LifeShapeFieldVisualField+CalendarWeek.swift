import AmbitionsDesignSystem
import SwiftUI

extension LifeShapeFieldVisualField {
    var calendarField: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            calendarWeekFrame
            calendarSignalRail
            selectedBucket
        }
        .padding(.vertical, theme.spacing.xxs)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Life Calendar week")
        .accessibilityValue(accessibilityValue)
        .accessibilityIdentifier("time.life-shape-field.calendar-stage")
    }

    var calendarWeekFrame: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                HStack(alignment: .firstTextBaseline, spacing: theme.spacing.sm) {
                    Text("Week")
                        .font(theme.typography.caption.weight(.semibold))
                        .foregroundStyle(theme.colors.textPrimary)
                    Spacer(minLength: theme.spacing.sm)
                    Text(field.sourceState.privacyLabel)
                        .font(theme.typography.micro.weight(.semibold))
                        .foregroundStyle(theme.colors.textSecondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.70)
                }
                Text(reading.capacityStatement)
                    .font(theme.typography.micro)
                    .foregroundStyle(theme.colors.textSecondary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.74)
            }

            calendarWeekRowIfPresent(.now)
            calendarWeekRowIfPresent(.fixedPoint)
            calendarWeekRowIfPresent(.openWindow)
            calendarWeekRowIfPresent(.scheduledStep)
            calendarWeekRowIfPresent(.protectedWindow)
            calendarWeekRowIfPresent(.pressure)
        }
        .padding(.horizontal, theme.spacing.xs)
        .padding(.vertical, theme.spacing.xs)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Week structure")
        .accessibilityValue(calendarWeekAccessibilityValue)
        .accessibilityIdentifier("time.life-shape-field.calendar-week-frame")
    }

    var calendarRowsForFirstViewport: [TimeCalendarRow] {
        let preferred: [TimeCalendarRowKind] = [
            .now,
            .fixedPoint,
            .openWindow,
            .scheduledStep,
            .protectedWindow,
            .pressure
        ]
        var rowsByKind: [TimeCalendarRowKind: TimeCalendarRow] = [:]
        for row in field.calendarRows where rowsByKind[row.kind] == nil {
            rowsByKind[row.kind] = row
        }
        return preferred.compactMap { rowsByKind[$0] }
    }

    var calendarWeekAccessibilityValue: String {
        calendarRowsForFirstViewport
            .map(\.accessibilitySummary)
            .joined(separator: ". ")
    }

    @ViewBuilder
    func calendarWeekRowIfPresent(_ kind: TimeCalendarRowKind) -> some View {
        if let row = calendarRowsForFirstViewport.first(where: { $0.kind == kind }) {
            calendarWeekRow(row)
        }
    }

    func calendarWeekRow(_ row: TimeCalendarRow) -> some View {
        let style = theme.stateStyle(for: row.visualState)
        return HStack(alignment: .center, spacing: theme.spacing.sm) {
            ZStack {
                Circle()
                    .fill(style.fill.opacity(reduceTransparency ? 0.34 : 0.20))
                Image(systemName: row.kind.systemImage)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(style.accent)
            }
            .frame(width: 26, height: 26)
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                HStack(alignment: .firstTextBaseline, spacing: theme.spacing.xs) {
                    Text(row.title)
                        .font(theme.typography.caption.weight(.semibold))
                        .foregroundStyle(theme.colors.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.76)
                    Spacer(minLength: theme.spacing.xs)
                    Text(row.value)
                        .font(theme.typography.micro.weight(.semibold))
                        .foregroundStyle(style.foreground)
                        .lineLimit(1)
                        .minimumScaleFactor(0.68)
                }
                Text(row.detail)
                    .font(theme.typography.micro)
                    .foregroundStyle(theme.colors.textSecondary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.74)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if row.isOperational {
                Circle()
                    .fill(style.accent.opacity(0.72))
                    .frame(width: 7, height: 7)
                    .accessibilityHidden(true)
            }
        }
        .padding(.vertical, theme.spacing.xxs)
        .padding(.horizontal, theme.spacing.xs)
        .background {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(row.isOperational ? style.fill.opacity(reduceTransparency ? 0.16 : 0.08) : theme.colors.strokeSubtle.opacity(0.05))
        }
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(theme.colors.strokeSubtle.opacity(colorSchemeContrast == .increased ? 0.52 : 0.22))
                .frame(height: 1)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(row.accessibilitySummary)
        .accessibilityIdentifier("time.life-shape-field.calendar-row.\(row.kind.rawValue)")
    }

    var calendarSignalRail: some View {
        let marks = Array(selectedMarks.prefix(3))
        return HStack(spacing: theme.spacing.xs) {
            if marks.indices.contains(0) {
                calendarSignalButton(marks[0])
            }
            if marks.indices.contains(1) {
                calendarSignalButton(marks[1])
            }
            if marks.indices.contains(2) {
                calendarSignalButton(marks[2])
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Time signals")
        .accessibilityIdentifier("time.life-shape-field.calendar-signals")
    }

    func calendarSignalButton(_ mark: LifeShapeSemanticMark) -> some View {
        let style = theme.stateStyle(for: mark.visualState)
        return Button {
            onSelectMark(mark)
        } label: {
            Label(mark.kind.pointTitle, systemImage: mark.kind.systemImage)
                .font(theme.typography.micro.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.62)
                .labelStyle(.titleAndIcon)
                .frame(maxWidth: .infinity, minHeight: 36)
                .padding(.horizontal, theme.spacing.xs)
                .foregroundStyle(style.foreground)
                .background {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(style.fill.opacity(reduceTransparency ? 0.24 : 0.14))
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(style.stroke.opacity(colorSchemeContrast == .increased ? 0.74 : 0.34), lineWidth: 1)
                }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(mark.accessibilitySummary)
        .accessibilityIdentifier("time.life-shape-field.mark.\(mark.id)")
    }
}
