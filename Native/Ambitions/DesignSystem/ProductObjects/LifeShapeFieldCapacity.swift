import AmbitionsDesignSystem
import SwiftUI

extension LifeShapeFieldView {
    @ViewBuilder
    var capacityStatement: some View {
        if dynamicTypeSize.isAccessibilitySize {
            accessibilityCapacityStatement
        } else {
            standardCapacityStatement
        }
    }

    var standardCapacityStatement: some View {
        HorizonCapacityPrimitiveStage(
            role: .capacity,
            title: reading.capacityStatement,
            subtitle: suite.field.reflowProposal.title,
            statusLabel: suite.field.capacityFit.title,
            visualState: suite.field.capacityFit.visualState,
            accessibilityIdentifier: "time.life-shape-field.capacity-statement"
        ) {
            shapingActionStrip

            HorizonCapacityPrimitiveLine(
                role: .continuity,
                title: "Preview changes",
                subtitle: suite.field.reflowProposal.detail,
                systemImage: "lock.shield",
                visualState: .default
            )
        }
        .accessibilityElement(children: .combine)
    }

    var accessibilityCapacityStatement: some View {
        let style = theme.stateStyle(for: suite.field.capacityFit.visualState)
        return VStack(alignment: .leading, spacing: theme.spacing.sm) {
            HStack(alignment: .top, spacing: theme.spacing.sm) {
                Image(systemName: "gauge.with.dots.needle.bottom.50percent")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(style.accent)
                    .frame(width: 28, alignment: .leading)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                    Text("Capacity")
                        .font(theme.typography.caption.weight(.semibold))
                        .foregroundStyle(style.accent)
                    Text(reading.capacityStatement)
                        .font(theme.typography.micro.weight(.semibold))
                        .foregroundStyle(theme.colors.textPrimary)
                        .lineLimit(7)
                        .minimumScaleFactor(0.64)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: theme.spacing.sm)

                Text(suite.field.capacityFit.title)
                    .font(theme.typography.micro.weight(.semibold))
                    .foregroundStyle(theme.colors.textSecondary)
                    .multilineTextAlignment(.trailing)
                    .fixedSize(horizontal: false, vertical: true)
            }

            shapingActionStrip
        }
        .padding(.leading, theme.spacing.md)
        .padding(.trailing, theme.spacing.sm)
        .padding(.vertical, theme.spacing.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(style.fill.opacity(0.18))
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(style.accent)
                .frame(width: 3)
                .accessibilityHidden(true)
        }
        .overlay(alignment: .top) {
            Rectangle()
                .fill(style.stroke.opacity(0.66))
                .frame(height: colorSchemeContrast == .increased ? 2 : 1)
                .accessibilityHidden(true)
        }
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(style.stroke.opacity(0.66))
                .frame(height: colorSchemeContrast == .increased ? 2 : 1)
                .accessibilityHidden(true)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("capacity, \(reading.capacityStatement)")
        .accessibilityValue([suite.field.reflowProposal.title, suite.field.capacityFit.title].joined(separator: ". "))
        .accessibilityIdentifier("time.life-shape-field.capacity-statement")
    }

    @ViewBuilder
    var shapingActionStrip: some View {
        if dynamicTypeSize.isAccessibilitySize {
            verticalShapingActionStrip
        } else {
            compactShapingActionGrid
        }
    }

    var verticalShapingActionStrip: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            shapingActionButton(
                title: "Shape week",
                icon: "calendar.badge.clock",
                identifier: "time.life-shape-field.action.shape-week"
            ) {
                selectedHorizon = .week
                selectedZoomLevel = .week
                revealsPressure = false
            }
            shapingActionButton(
                title: "Review pressure",
                icon: "waveform.path.ecg.rectangle",
                identifier: "time.life-shape-field.action.review-pressure"
            ) {
                revealsPressure = true
            }
            shapingActionButton(
                title: "Protect this block",
                icon: "clock.badge.checkmark",
                identifier: "time.life-shape-field.action.protect-block"
            ) {
                selectedHorizon = .week
                selectedZoomLevel = .week
                confirmedReflowAction = .decline
            }
            shapingActionButton(
                title: "Adjust shape",
                icon: "slider.horizontal.3",
                identifier: "time.life-shape-field.action.adjust-shape"
            ) {
                confirmedReflowAction = .edit
            }
        }
        .accessibilityElement(children: .contain)
    }

    var compactShapingActionGrid: some View {
        let columns = [
            GridItem(.flexible(), spacing: theme.spacing.sm, alignment: .leading),
            GridItem(.flexible(), spacing: theme.spacing.sm, alignment: .leading)
        ]

        return LazyVGrid(columns: columns, alignment: .leading, spacing: theme.spacing.sm) {
            shapingActionButton(
                title: "Shape week",
                icon: "calendar.badge.clock",
                identifier: "time.life-shape-field.action.shape-week"
            ) {
                selectedHorizon = .week
                selectedZoomLevel = .week
                revealsPressure = false
            }
            shapingActionButton(
                title: "Review pressure",
                icon: "waveform.path.ecg.rectangle",
                identifier: "time.life-shape-field.action.review-pressure"
            ) {
                revealsPressure = true
            }
            shapingActionButton(
                title: "Protect this block",
                icon: "clock.badge.checkmark",
                identifier: "time.life-shape-field.action.protect-block"
            ) {
                selectedHorizon = .week
                selectedZoomLevel = .week
                confirmedReflowAction = .decline
            }
            shapingActionButton(
                title: "Adjust shape",
                icon: "slider.horizontal.3",
                identifier: "time.life-shape-field.action.adjust-shape"
            ) {
                confirmedReflowAction = .edit
            }
        }
        .accessibilityElement(children: .contain)
    }

    func shapingActionButton(
        title: String,
        icon: String,
        identifier: String,
        action: @escaping () -> Void
    ) -> some View {
        let accessibilityReduceMotion = reduceMotion
        return Button {
            withAnimation(accessibilityReduceMotion ? nil : .easeOut(duration: 0.18)) {
                action()
            }
        } label: {
            Label(title, systemImage: icon)
                .font(theme.typography.caption.weight(.semibold))
                .foregroundStyle(theme.colors.textPrimary)
                .lineLimit(2)
                .minimumScaleFactor(0.78)
                .frame(maxWidth: .infinity, minHeight: 38, alignment: .leading)
                .padding(.vertical, theme.spacing.xxs)
                .overlay(alignment: .bottom) {
                    Rectangle()
                        .fill(theme.colors.strokeSubtle)
                        .frame(height: 1)
                }
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityIdentifier(identifier)
    }

}
