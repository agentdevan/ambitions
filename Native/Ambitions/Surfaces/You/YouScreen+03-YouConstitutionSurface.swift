import AmbitionsDesignSystem
import Foundation
import SwiftUI
import UIKit

struct YouConstitutionSurface: View {
    @Environment(\.ambitionTheme) private var theme

    let constitution: YouConstitutionState

    var body: some View {
        ProductObjectFrame {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(
                    eyebrow: "Constitution",
                    title: constitution.title,
                    subtitle: constitution.subtitle
                )

                HStack(alignment: .top, spacing: theme.spacing.sm) {
                    Image(systemName: "checkmark.shield")
                        .font(.system(size: theme.icon.mediumSize, weight: theme.icon.symbolWeight))
                        .foregroundStyle(theme.colors.accentPrimary)
                    Text(constitution.postureSummary)
                        .font(theme.typography.section)
                        .foregroundStyle(theme.colors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer()
                }
                .padding(theme.spacing.md)
                .background(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).fill(theme.colors.surfaceOverlay))
                .overlay(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).stroke(theme.colors.strokeSubtle, lineWidth: 1))

                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    ForEach(constitution.rules) { rule in
                        YouRuleRow(rule: rule)
                    }
                }

                Text(constitution.footer)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityIdentifier("you.constitution-card")
        .ambitionPanelAccessibility()
    }
}

struct YouMemoryControlsSurface: View {
    @Environment(\.ambitionTheme) private var theme

    let memoryControls: YouMemoryControlState

    var body: some View {
        ProductObjectFrame {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(
                    eyebrow: "Memory",
                    title: memoryControls.title,
                    subtitle: memoryControls.subtitle
                )

                if memoryControls.memoryLensItems.isEmpty == false {
                    VStack(alignment: .leading, spacing: theme.spacing.sm) {
                        SectionHeader(
                            eyebrow: "Search",
                            title: "Source-grounded recall",
                            subtitle: "Each visible memory names source age, why it is remembered, privacy posture, and review controls."
                        )

                        ForEach(memoryControls.memoryLensItems) { item in
                            YouMemoryLensItemRow(item: item)
                        }
                    }
                    .accessibilityIdentifier("you.memory-lens-visual-layer")
                }

                ContextRecallSurface(
                    title: "What Ambitions remembers",
                    summary: memoryControls.recoverySummary,
                    sourceLabel: "Source: local receipts, corrections, reviews, and explicit profile context",
                    confidenceLabel: primaryRecallState == .current ? "Review state: current" : "Review state: needs review",
                    state: primaryRecallState,
                    context: .memory,
                    controls: memoryControls.items.prefix(3).map(\.title)
                )
                .accessibilityIdentifier("you.context-recall-surface")

                if memoryControls.runtimeInspectionItems.isEmpty == false {
                    VStack(alignment: .leading, spacing: theme.spacing.sm) {
                        SectionHeader(
                            eyebrow: "Runtime inspection",
                            title: "Learned, used, ignored, changed",
                            subtitle: "A local readout of what shaped memory, what stayed held back, and what changed."
                        )

                        ForEach(memoryControls.runtimeInspectionItems) { item in
                            YouRuntimeInspectionItemRow(item: item)
                        }
                    }
                    .accessibilityIdentifier("you.runtime-inspection-section")
                }

                if memoryControls.localLearningControls.isEmpty == false {
                    VStack(alignment: .leading, spacing: theme.spacing.sm) {
                        SectionHeader(
                            eyebrow: "Local learning controls",
                            title: "Reset, disable, delete, export",
                            subtitle: "Controls stay source-tied, local-only, confirmation-aware, and receipt-aware."
                        )

                        ForEach(memoryControls.localLearningControls) { control in
                            YouLocalLearningControlRow(control: control)
                        }
                    }
                    .accessibilityIdentifier("you.local-learning-controls-section")
                }

                MemoryConstellation(
                    title: "Visible memory states",
                    subtitle: "A bounded map of current, stale, sensitive, corrected, and empty states. It is not a hidden inference graph.",
                    nodes: constellationNodes
                )
                .accessibilityIdentifier("you.memory-constellation")

                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    ForEach(memoryControls.items) { item in
                        YouSettingRow(item: item)
                    }
                }

                YouPersonalizationConsentPanel(consent: memoryControls.consent)

                if memoryControls.privateModeControls.isEmpty == false {
                    VStack(alignment: .leading, spacing: theme.spacing.sm) {
                        SectionHeader(
                            eyebrow: "Private mode",
                            title: "Sensitive areas",
                            subtitle: "Private context stays summarized, approval-gated, or blocked until a safe owner proves more."
                        )

                        ForEach(memoryControls.privateModeControls) { control in
                            YouPrivateModeControlRow(control: control)
                        }
                    }
                    .accessibilityIdentifier("you.private-mode-controls")
                }

                ForEach(memoryControls.groups) { group in
                    VStack(alignment: .leading, spacing: theme.spacing.sm) {
                        SectionHeader(
                            eyebrow: "What this uses",
                            title: group.title,
                            subtitle: group.subtitle
                        )

                        ForEach(group.items) { item in
                            YouMemoryItemRow(item: item)
                        }

                        if let footer = group.footer {
                            Text(footer)
                                .font(theme.typography.caption)
                                .foregroundStyle(theme.colors.textTertiary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }

                if memoryControls.narrativeMemories.isEmpty == false {
                    VStack(alignment: .leading, spacing: theme.spacing.sm) {
                        SectionHeader(
                            eyebrow: "Narrative memory",
                            title: "Reviewable stories",
                            subtitle: "Only explicit local evidence, receipts, corrections, reviews, or confirmations can shape these."
                        )

                        ForEach(memoryControls.narrativeMemories) { memory in
                            YouNarrativeMemoryRow(memory: memory)
                        }
                    }
                    .accessibilityIdentifier("you.narrative-memory-section")
                }

                if memoryControls.conservativePatterns.isEmpty == false {
                    VStack(alignment: .leading, spacing: theme.spacing.sm) {
                        SectionHeader(
                            eyebrow: "Pattern review",
                            title: "Conservative signals",
                            subtitle: "Patterns stay reviewable and never become automatic certainty."
                        )

                        ForEach(memoryControls.conservativePatterns) { pattern in
                            YouMemoryPatternRow(pattern: pattern)
                        }
                    }
                    .accessibilityIdentifier("you.memory-pattern-section")
                }

                Text(memoryControls.recoverySummary)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                Text(memoryControls.footer)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityIdentifier("you.memory-controls-card")
        .ambitionPanelAccessibility(
            label: memoryControls.title,
            value: "Local memory groups, freshness labels, and safe correction controls.",
            hint: "Review what Ambitions stores and how it can be corrected."
        )
    }

    var primaryRecallState: ContextRecallState {
        let freshness = memoryControls.groups.flatMap(\.items).map(\.freshness)

        if freshness.contains(.mayNeedReview) {
            return .stale
        }

        if memoryControls.narrativeMemories.contains(where: { $0.sensitiveStatusLabel.localizedCaseInsensitiveContains("sensitive") }) {
            return .sensitive
        }

        if memoryControls.conservativePatterns.contains(where: { $0.reviewLabel.localizedCaseInsensitiveContains("correct") }) {
            return .corrected
        }

        return freshness.isEmpty ? .noResult : .current
    }

    var constellationNodes: [MemoryConstellationNode] {
        let memoryNodes = memoryControls.groups
            .flatMap(\.items)
            .prefix(3)
            .map { item in
                MemoryConstellationNode(
                    id: item.id,
                    title: item.title,
                    detail: item.sourceLabel,
                    state: item.freshness.contextRecallState
                )
            }

        let narrativeNodes = memoryControls.narrativeMemories
            .prefix(1)
            .map { memory in
                MemoryConstellationNode(
                    id: memory.id,
                    title: memory.title,
                    detail: memory.sensitiveStatusLabel,
                    state: memory.sensitiveStatusLabel.localizedCaseInsensitiveContains("sensitive") ? .sensitive : memory.freshness.contextRecallState
                )
            }

        let nodes = Array(memoryNodes + narrativeNodes)

        if nodes.isEmpty {
            return [
                MemoryConstellationNode(
                    id: "memory-no-result",
                    title: "No hidden memory",
                    detail: "Nothing inferred",
                    state: .noResult
                )
            ]
        }

        return nodes
    }
}
