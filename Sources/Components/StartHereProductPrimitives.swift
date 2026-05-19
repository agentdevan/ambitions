#if canImport(SwiftUI)
import Foundation
import SwiftUI

public struct StartHereProductFact: Equatable, Identifiable, Sendable {
    public let id: String
    public let title: String
    public let summary: String
    public let detail: String

    public init(id: String, title: String, summary: String, detail: String) {
        self.id = id
        self.title = title
        self.summary = summary
        self.detail = detail
    }

    public var isComplete: Bool {
        [id, title, summary, detail].allSatisfy { $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false }
    }
}

public struct StartHereProductKernel: Equatable, Sendable {
    public let label: String
    public let title: String
    public let subtitle: String
    public let becauseLine: String
    public let durationLabel: String
    public let fitLabel: String
    public let sourceQualityLabel: String
    public let contextEdge: StartHereProductFact
    public let timeFitProof: StartHereProductFact
    public let goalThread: StartHereProductFact
    public let receiptSummary: String
    public let primaryActionTitle: String
    public let secondaryActionTitle: String?

    public init(
        label: String = "Start here",
        title: String,
        subtitle: String,
        becauseLine: String,
        durationLabel: String,
        fitLabel: String,
        sourceQualityLabel: String,
        contextEdge: StartHereProductFact,
        timeFitProof: StartHereProductFact,
        goalThread: StartHereProductFact,
        receiptSummary: String,
        primaryActionTitle: String = "Start now",
        secondaryActionTitle: String? = nil
    ) {
        self.label = label
        self.title = title
        self.subtitle = subtitle
        self.becauseLine = becauseLine
        self.durationLabel = durationLabel
        self.fitLabel = fitLabel
        self.sourceQualityLabel = sourceQualityLabel
        self.contextEdge = contextEdge
        self.timeFitProof = timeFitProof
        self.goalThread = goalThread
        self.receiptSummary = receiptSummary
        self.primaryActionTitle = primaryActionTitle
        self.secondaryActionTitle = secondaryActionTitle
    }

    public var proofFacts: [StartHereProductFact] {
        [contextEdge, timeFitProof, goalThread]
    }

    public var hasRequiredProof: Bool {
        label == "Start here" &&
        [title, subtitle, becauseLine, durationLabel, fitLabel, sourceQualityLabel, receiptSummary, primaryActionTitle]
            .allSatisfy { $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false } &&
        proofFacts.allSatisfy { $0.isComplete }
    }

    public var accessibilitySummary: String {
        ([label, title, subtitle, becauseLine, durationLabel, fitLabel, sourceQualityLabel, receiptSummary] + proofFacts.flatMap { [$0.title, $0.summary, $0.detail] })
            .filter { $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false }
            .joined(separator: ". ")
    }
}

public enum StartHereProductKernelAudit {
    public static let bannedPhrases: [String] = [
        "best next move",
        "next best move",
        "recommended next step",
        "ai recommendation card",
        "recommendation card",
        "dashboard card",
        "task card",
        "productivity score",
        "streak broken"
    ]

    public static func failures(for kernel: StartHereProductKernel) -> [String] {
        var failures: [String] = []
        if kernel.hasRequiredProof == false {
            failures.append("missing required Start Here proof structure")
        }

        let searchable = ([kernel.label, kernel.title, kernel.subtitle, kernel.becauseLine, kernel.durationLabel, kernel.fitLabel, kernel.sourceQualityLabel, kernel.receiptSummary, kernel.primaryActionTitle] + kernel.proofFacts.flatMap { [$0.title, $0.summary, $0.detail] })
            .joined(separator: " ")
            .lowercased()

        for phrase in bannedPhrases where searchable.contains(phrase) {
            failures.append("banned phrase: \(phrase)")
        }
        if kernel.primaryActionTitle != "Start now" && kernel.primaryActionTitle != "Open step" {
            failures.append("primary action must be Start now or Open step")
        }
        return failures
    }
}

public struct StartHereProductProofStack: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let kernel: StartHereProductKernel

    public init(kernel: StartHereProductKernel) {
        self.kernel = kernel
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.lg) {
            // Header Area
            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                HStack {
                    Text(kernel.label.uppercased())
                        .font(theme.typography.micro.weight(.semibold))
                        .foregroundStyle(theme.colors.accentSecondary)
                        .padding(.horizontal, theme.spacing.xs)
                        .padding(.vertical, theme.spacing.xxs)
                        .background {
                            Capsule(style: .continuous)
                                .fill(theme.colors.accentSecondary.opacity(0.12))
                        }
                    
                    Spacer()
                    
                    Circle()
                        .fill(theme.colors.accentSecondary)
                        .frame(width: 6, height: 6)
                        .opacity(0.8)
                }
                
                Text(kernel.title)
                    .font(theme.typography.titleCompact)
                    .foregroundStyle(theme.colors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text(kernel.subtitle)
                    .font(theme.typography.body)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text(kernel.becauseLine)
                    .font(theme.typography.bodySecondary)
                    .foregroundStyle(theme.colors.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            // Metadata Badges Row
            HStack(spacing: theme.spacing.xs) {
                badgeView(text: kernel.durationLabel, icon: "hourglass")
                badgeView(text: kernel.fitLabel, icon: "clock")
                badgeView(text: kernel.sourceQualityLabel, icon: "checkmark.shield")
            }
            .lineLimit(1)
            .minimumScaleFactor(0.82)
            
            // Sub-modules: Proof Facts
            VStack(spacing: theme.spacing.sm) {
                ForEach(Array(kernel.proofFacts.enumerated()), id: \.element.id) { index, fact in
                    QuietGlass(cornerRadius: theme.radius.md) {
                        HStack(alignment: .top, spacing: theme.spacing.sm) {
                            Image(systemName: factIcon(for: index))
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(theme.colors.accentSecondary)
                                .frame(width: 22, height: 22)
                                .background {
                                    Circle()
                                        .fill(theme.colors.accentSecondary.opacity(0.10))
                                }
                                .padding(.top, 2)
                            
                            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                                Text(fact.title)
                                    .font(theme.typography.micro.weight(.semibold))
                                    .foregroundStyle(theme.colors.textTertiary)
                                Text(fact.summary)
                                    .font(theme.typography.bodySecondary.weight(.medium))
                                    .foregroundStyle(theme.colors.textPrimary)
                                Text(fact.detail)
                                    .font(theme.typography.caption)
                                    .foregroundStyle(theme.colors.textSecondary)
                            }
                        }
                        .padding(theme.spacing.md)
                    }
                }
            }
            
            // Bottom Trust Receipt Area
            GraphiteRecess(cornerRadius: theme.radius.md) {
                HStack(spacing: theme.spacing.xs) {
                    Image(systemName: "lock.shield")
                        .font(.system(size: 12))
                        .foregroundStyle(theme.colors.accentWarm)
                    Text(kernel.receiptSummary)
                        .font(theme.typography.micro)
                        .foregroundStyle(theme.colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(theme.spacing.sm)
            }
        }
        .padding(theme.spacing.lg)
        .background {
            QuietGlass(cornerRadius: theme.radius.lg) {
                CelestialField()
            }
        }
        .luminousTrace(isShimmering: true)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(kernel.accessibilitySummary)
        .accessibilityIdentifier("StartHereProductProofStack")
    }
    
    private func badgeView(text: String, icon: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10))
            Text(text)
                .font(theme.typography.micro.weight(.semibold))
        }
        .foregroundStyle(theme.colors.textSecondary)
        .padding(.horizontal, theme.spacing.sm)
        .padding(.vertical, theme.spacing.xs)
        .background {
            Capsule(style: .continuous)
                .fill(theme.colors.surfaceOverlay.opacity(0.24))
        }
        .overlay {
            Capsule(style: .continuous)
                .strokeBorder(theme.colors.strokeSubtle.opacity(0.15), lineWidth: 0.5)
        }
    }
    
    private func factIcon(for index: Int) -> String {
        switch index {
        case 0: "doc.text.magnifyingglass"
        case 1: "clock.badge.checkmark"
        case 2: "sparkles"
        default: "circle.badge.checkmark"
        }
    }
}

public extension StartHereProductKernel {
    public var fe04Role: FE04PrimitiveRole {
        .startHere
    }
}

public extension StartHereProductProofStack {
    public var fe04Role: FE04PrimitiveRole {
        .startHere
    }
}
#endif
