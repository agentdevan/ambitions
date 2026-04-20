import AmbitionsDesignSystem
import Foundation
import SwiftUI

enum GoalShellSummaryIndicatorKind: String, Sendable, Equatable, Hashable {
    case freshness
    case energy
    case contradiction
    case correction
}

struct GoalShellSummaryIndicatorState: Identifiable, Sendable, Equatable, Hashable {
    let kind: GoalShellSummaryIndicatorKind
    let title: String
    let systemImage: String
    let state: AmbitionVisualState

    var id: String { "\(kind.rawValue)-\(title)" }
}

struct GoalShellSummaryState: Sendable, Equatable {
    let explanationSummary: String
    let pathSummary: String
    let indicators: [GoalShellSummaryIndicatorState]
}

struct GoalShellSummaryProjector {
    func makeState(from context: RuntimeGoalIntelligenceContext) -> GoalShellSummaryState {
        let explainability = context.explainability
        let primaryCandidate = context.metadata.compiledPath.candidates.first(where: \.isPrimary)
            ?? context.metadata.compiledPath.candidates.sorted { $0.id < $1.id }.first

        var indicators: [GoalShellSummaryIndicatorState] = [
            GoalShellSummaryIndicatorState(
                kind: .freshness,
                title: "Freshness: \(humanized(explainability.freshness.posture.rawValue))",
                systemImage: "clock.arrow.circlepath",
                state: freshnessState(for: explainability.freshness.posture)
            )
        ]

        if context.metadata.energyModel.overallBand != .unknown {
            indicators.append(
                GoalShellSummaryIndicatorState(
                    kind: .energy,
                    title: "Energy: \(humanized(context.metadata.energyModel.overallBand.rawValue))",
                    systemImage: "bolt.heart",
                    state: energyState(for: context.metadata.energyModel.overallBand)
                )
            )
        }

        if explainability.contradictions.isEmpty == false {
            indicators.append(
                GoalShellSummaryIndicatorState(
                    kind: .contradiction,
                    title: "\(explainability.contradictions.count) contradiction\(explainability.contradictions.count == 1 ? "" : "s")",
                    systemImage: "exclamationmark.triangle",
                    state: .warning
                )
            )
        }

        if explainability.appliedTeachingBadges.isEmpty == false {
            indicators.append(
                GoalShellSummaryIndicatorState(
                    kind: .correction,
                    title: "\(explainability.appliedTeachingBadges.count) teaching signal\(explainability.appliedTeachingBadges.count == 1 ? "" : "s")",
                    systemImage: "checkmark.seal",
                    state: .success
                )
            )
        } else if explainability.correctionControls.isEmpty == false {
            indicators.append(
                GoalShellSummaryIndicatorState(
                    kind: .correction,
                    title: "\(explainability.correctionControls.count) correction option\(explainability.correctionControls.count == 1 ? "" : "s")",
                    systemImage: "pencil.and.outline",
                    state: .selected
                )
            )
        }

        return GoalShellSummaryState(
            explanationSummary: explainability.whyThis.compactSummary,
            pathSummary: primaryCandidate?.summary ?? humanized(context.metadata.compiledPath.overallPosture.rawValue),
            indicators: indicators
        )
    }
}

struct GoalShellSummaryCompactView: View {
    @Environment(\.ambitionTheme) private var theme

    let summary: GoalShellSummaryState

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
            Text(summary.explanationSummary)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            if summary.pathSummary != summary.explanationSummary {
                Text(summary.pathSummary)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: theme.spacing.xs) {
                    ForEach(summary.indicators) { indicator in
                        TagPill(indicator.title, icon: indicator.systemImage, state: indicator.state)
                    }
                }
            }
        }
    }
}

private extension GoalShellSummaryProjector {
    func freshnessState(for posture: GoalFreshnessPosture) -> AmbitionVisualState {
        switch posture {
        case .currentEnough:
            return .success
        case .aging, .unknownFreshness:
            return .default
        case .stale, .expired, .blockedMissingEvidence, .providerUnavailable:
            return .warning
        }
    }

    func energyState(for band: EnergyFitBand) -> AmbitionVisualState {
        switch band {
        case .supportive:
            return .success
        case .sustainable:
            return .selected
        case .constrained, .strained:
            return .warning
        case .unknown:
            return .default
        }
    }

    func humanized(_ rawValue: String) -> String {
        rawValue
            .replacingOccurrences(of: "_", with: " ")
            .split(separator: " ")
            .map { $0.capitalized }
            .joined(separator: " ")
    }
}
