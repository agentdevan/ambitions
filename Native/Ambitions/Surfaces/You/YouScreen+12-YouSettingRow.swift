import AmbitionsDesignSystem
import Foundation
import SwiftUI
import UIKit

struct YouSettingRow: View {
    @Environment(\.ambitionTheme) private var theme

    let item: SettingsItem

    var body: some View {
        HStack(alignment: .top, spacing: theme.spacing.sm) {
            Image(systemName: item.icon)
                .font(.system(size: theme.icon.mediumSize, weight: theme.icon.symbolWeight))
                .foregroundStyle(theme.colors.accentPrimary)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                Text(item.title)
                    .font(theme.typography.section)
                    .foregroundStyle(theme.colors.textPrimary)
                if let valueLabel = item.valueLabel {
                    TagPill(valueLabel, state: .default)
                }
                if let subtitle = item.subtitle {
                    Text(subtitle)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(theme.spacing.md)
        .background(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).fill(theme.colors.surfaceOverlay))
        .overlay(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).stroke(theme.colors.strokeSubtle, lineWidth: 1))
        .ambitionPanelAccessibility()
    }
}

#if DEBUG
#Preview("You Minimal State") {
    NavigationStack {
        YouScreen(viewModel: YouViewModel(state: .loaded(PreviewFixtures.default.youDashboard)))
    }
    .appContainer(PreviewAppContainerFactory.preview)
    .ambitionTheme(.dark)
    .preferredColorScheme(.dark)
}

#Preview("You Memory Stale") {
    ScrollView {
        ContextRecallSurface(
            title: "Availability pattern may need review",
            summary: "This recall is old enough that Ambitions should ask before using it to shape planning.",
            sourceLabel: "Source: older local review",
            confidenceLabel: "Review state: needs review",
            state: .stale,
            controls: ["Review", "Correct", "Ignore"]
        )
        .padding()
    }
    .background(LivingSurfaceBackground(context: .memory, state: .stale).stageOwnedIgnoresSafeArea())
    .ambitionTheme(.dark)
    .preferredColorScheme(.dark)
}

#Preview("You Memory Rejected") {
    ScrollView {
        ContextRecallSurface(
            title: "Rejected assumption",
            summary: "The user rejected this signal, so it remains visible only as correction history.",
            sourceLabel: "Source: correction receipt",
            confidenceLabel: "Review state: not active",
            state: .rejected,
            controls: ["View receipt"]
        )
        .padding()
    }
    .background(LivingSurfaceBackground(context: .memory, state: .recovery).stageOwnedIgnoresSafeArea())
    .ambitionTheme(.dark)
    .preferredColorScheme(.dark)
}

#Preview("You Memory Private") {
    ScrollView {
        ContextRecallSurface(
            title: "Sensitive context is protected",
            summary: "This context requires explicit review before it appears in planning guidance.",
            sourceLabel: "Source: private profile context",
            confidenceLabel: "Review state: protected",
            state: .sensitive,
            controls: ["Review privacy", "Keep hidden"]
        )
        .padding()
    }
    .background(LivingSurfaceBackground(context: .memory, state: .sensitive).stageOwnedIgnoresSafeArea())
    .ambitionTheme(.dark)
    .preferredColorScheme(.dark)
}

#Preview("You Memory Corrected") {
    ScrollView {
        ContextRecallSurface(
            title: "Planning default corrected",
            summary: "The corrected version is the only active version used for future recall surfaces.",
            sourceLabel: "Source: explicit correction",
            confidenceLabel: "Review state: user-confirmed",
            state: .corrected,
            controls: ["View correction"]
        )
        .padding()
    }
    .background(LivingSurfaceBackground(context: .memory, state: .proof).stageOwnedIgnoresSafeArea())
    .ambitionTheme(.dark)
    .preferredColorScheme(.dark)
}

#Preview("You Memory No Result") {
    ScrollView {
        ContextRecallSurface(
            title: "No hidden memory",
            summary: "Ambitions has no recall result for this context and should say so plainly.",
            sourceLabel: "Source: none",
            confidenceLabel: "Review state: no result",
            state: .noResult,
            controls: []
        )
        .padding()
    }
    .background(LivingSurfaceBackground(context: .memory, state: .empty).stageOwnedIgnoresSafeArea())
    .ambitionTheme(.dark)
    .preferredColorScheme(.dark)
}

#Preview("You Trust Receipts Empty") {
    ScrollView {
        TrustReceiptStack(items: [])
            .padding()
    }
    .background(LivingSurfaceBackground(context: .trust, state: .empty).stageOwnedIgnoresSafeArea())
    .ambitionTheme(.dark)
    .preferredColorScheme(.dark)
}

#Preview("You Trust Proof Saved") {
    ScrollView {
        TrustReceiptStack(items: [
            TrustReceiptStackItem(
                id: "preview-proof-saved",
                title: "Proof saved",
                summary: "A completed step produced local proof and a visible receipt.",
                sourceLabel: "Source: Today",
                freshnessLabel: "Freshness: current local receipt",
                undoLabel: "Undo available locally",
                correctionLabel: "Correction available",
                nextActionLabel: "Review proof",
                state: .proofSaved
            )
        ])
        .padding()
    }
    .background(LivingSurfaceBackground(context: .trust, state: .proof).stageOwnedIgnoresSafeArea())
    .ambitionTheme(.dark)
    .preferredColorScheme(.dark)
}

#Preview("You Trust Correction") {
    ScrollView {
        TrustReceiptStack(items: [
            TrustReceiptStackItem(
                id: "preview-correction",
                title: "Correction recorded",
                summary: "A user correction is visible as the active trust signal.",
                sourceLabel: "Source: You",
                freshnessLabel: "Freshness: current local receipt",
                undoLabel: "Undo unavailable",
                correctionLabel: "Correction available with reason",
                nextActionLabel: "View correction",
                state: .correction
            )
        ])
        .padding()
    }
    .background(LivingSurfaceBackground(context: .trust, state: .proof).stageOwnedIgnoresSafeArea())
    .ambitionTheme(.dark)
    .preferredColorScheme(.dark)
}

#Preview("You Trust Undo") {
    ScrollView {
        TrustReceiptStack(items: [
            TrustReceiptStackItem(
                id: "preview-undo",
                title: "Time change can be undone",
                summary: "A local reversible change exposes undo without implying silent automation.",
                sourceLabel: "Source: Time",
                freshnessLabel: "Freshness: current local receipt",
                undoLabel: "Undo requires confirmation",
                correctionLabel: "Correction unavailable",
                nextActionLabel: "Review in Time",
                state: .undo
            )
        ])
        .padding()
    }
    .background(LivingSurfaceBackground(context: .trust, state: .active).stageOwnedIgnoresSafeArea())
    .ambitionTheme(.dark)
    .preferredColorScheme(.dark)
}

#Preview("You Trust Stale Source") {
    ScrollView {
        TrustReceiptStack(items: [
            TrustReceiptStackItem(
                id: "preview-stale-source",
                title: "Source may need review",
                summary: "This receipt stays visible, but its source should not be treated as fresh proof.",
                sourceLabel: "Source: older review",
                freshnessLabel: "Freshness: degraded source",
                undoLabel: "Undo not supported yet",
                correctionLabel: "Correction not supported yet",
                nextActionLabel: nil,
                state: .staleSource
            )
        ])
        .padding()
    }
    .background(LivingSurfaceBackground(context: .trust, state: .stale).stageOwnedIgnoresSafeArea())
    .ambitionTheme(.dark)
    .preferredColorScheme(.dark)
}
#endif
