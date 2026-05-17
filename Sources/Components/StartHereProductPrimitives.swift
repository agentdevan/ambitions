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

    private let kernel: StartHereProductKernel

    public init(kernel: StartHereProductKernel) {
        self.kernel = kernel
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            Text(kernel.label)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textTertiary)
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
                .foregroundStyle(theme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
            HStack(spacing: theme.spacing.xs) {
                Text(kernel.durationLabel)
                Text(kernel.fitLabel)
                Text(kernel.sourceQualityLabel)
            }
            .font(theme.typography.micro.weight(.semibold))
            .foregroundStyle(theme.colors.textSecondary)
            .lineLimit(1)
            .minimumScaleFactor(0.82)

            ForEach(kernel.proofFacts) { fact in
                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                    Text(fact.title)
                        .font(theme.typography.micro)
                        .foregroundStyle(theme.colors.textTertiary)
                    Text(fact.summary)
                        .font(theme.typography.bodySecondary)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(fact.detail)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textSecondary)
                }
                .fixedSize(horizontal: false, vertical: true)
            }

            Text(kernel.receiptSummary)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(kernel.accessibilitySummary)
        .accessibilityIdentifier("StartHereProductProofStack")
    }
}
#endif
