import AmbitionsDesignSystem
import Foundation
import SwiftUI
import UIKit

struct YouTrustReceiptRow: View {
    @Environment(\.ambitionTheme) private var theme

    let receipt: ActionReceiptDisplaySummary

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            HStack(alignment: .top, spacing: theme.spacing.sm) {
                Image(systemName: iconName)
                    .font(.system(size: theme.icon.mediumSize, weight: theme.icon.symbolWeight))
                    .foregroundStyle(theme.colors.accentPrimary)
                    .frame(width: 28)

                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                    Text(receipt.title)
                        .font(theme.typography.bodyEmphasized)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(receipt.summary)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                    if let nextActionTitle = receipt.nextActionTitle {
                        Text(nextActionTitle)
                            .font(theme.typography.caption)
                            .foregroundStyle(theme.colors.textTertiary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                Spacer(minLength: theme.spacing.sm)
            }

            HStack(spacing: theme.spacing.xs) {
                TagPill(resultLabel, state: resultState)
                TagPill(undoLabel, state: undoState)
                TagPill(correctionLabel, state: correctionState)
            }
        }
        .padding(theme.spacing.md)
        .background(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).fill(theme.colors.surfaceOverlay))
        .overlay(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).stroke(theme.colors.strokeSubtle, lineWidth: 1))
        .ambitionPanelAccessibility(
            label: receipt.title,
            value: "\(resultLabel). \(undoLabel). \(correctionLabel).",
            hint: "Receipt summary. Sensitive detail is not expanded here."
        )
    }

    var iconName: String {
        switch receipt.safetyState {
        case .safeFailure, .externalUnavailable, .confirmationRequired:
            return "exclamationmark.shield"
        case .normal, .degraded:
            return "doc.text.magnifyingglass"
        }
    }

    var resultLabel: String {
        switch receipt.resultState {
        case .created: "Created"
        case .changed: "Changed"
        case .scheduled: "Scheduled"
        case .moved: "Rescheduled"
        case .attached: "Attached"
        case .detached: "Detached"
        case .exportedPrepared: "Export prepared"
        case .draftedPrepared: "Draft prepared"
        case .completed: "Completed"
        case .failedSafely: "Safely blocked"
        case .needsConfirmation: "Needs confirmation"
        case .noOp: "No change"
        case .undoAvailable: "Undo available"
        case .undoUnavailable: "Undo unavailable"
        case .correctionAvailable: "Correction available"
        }
    }

    var resultState: AmbitionVisualState {
        switch receipt.safetyState {
        case .safeFailure, .externalUnavailable, .confirmationRequired:
            return .warning
        case .normal, .degraded:
            return .default
        }
    }

    var undoLabel: String {
        receipt.undoAvailability.isAvailable ? "Undo available" : "Undo not available"
    }

    var undoState: AmbitionVisualState {
        receipt.undoAvailability.isAvailable ? .success : .default
    }

    var correctionLabel: String {
        receipt.correctionAvailability.isAvailable ? "Correction available" : "Correction unavailable"
    }

    var correctionState: AmbitionVisualState {
        receipt.correctionAvailability.isAvailable ? .success : .default
    }
}

extension ActionReceiptDisplaySummary {
    var trustReceiptVisualState: TrustReceiptVisualState {
        if safetyState == .safeFailure || safetyState == .externalUnavailable || safetyState == .confirmationRequired {
            return .blocked
        }

        if correctionAvailability.isAvailable {
            return .correction
        }

        if undoAvailability.isAvailable {
            return .undo
        }

        switch resultState {
        case .completed, .created, .changed, .attached, .scheduled:
            return .proofSaved
        case .failedSafely, .needsConfirmation:
            return .blocked
        case .undoAvailable:
            return .undo
        case .correctionAvailable:
            return .correction
        case .undoUnavailable, .noOp, .moved, .detached, .exportedPrepared, .draftedPrepared:
            return .staleSource
        }
    }
}

extension ActionReceiptSourceDomain {
    var trustReceiptSourceLabel: String {
        switch self {
        case .today: "Source: Today"
        case .goals: "Source: Goals"
        case .capture: "Source: Capture"
        case .time: "Source: Time"
        case .you: "Source: You"
        case .reviews: "Source: Reviews"
        case .goalDetail: "Source: Goal Detail"
        case .commandPipeline: "Source: Command"
        case .eventLedger: "Source: Event Ledger"
        case .proof: "Source: Proof"
        case .resource: "Source: Resource"
        case .commitment: "Source: Commitment"
        case .calendar: "Source: Calendar boundary"
        case .exportImport: "Source: Export / import boundary"
        case .externalSurface: "Source: External surface"
        case .system: "Source: System"
        }
    }
}

extension ActionReceiptSafetyState {
    var trustReceiptFreshnessLabel: String {
        switch self {
        case .normal: "Freshness: current local receipt"
        case .degraded: "Freshness: degraded source"
        case .safeFailure: "Freshness: blocked safely"
        case .externalUnavailable: "Freshness: external needs context"
        case .confirmationRequired: "Freshness: waiting for confirmation"
        }
    }
}

extension ActionReceiptUndoAvailability {
    var trustReceiptUndoLabel: String {
        switch self {
        case .availableLocal: "Undo available locally"
        case .requiresConfirmation: "Undo requires confirmation"
        case .unavailable: "Undo unavailable"
        case .unsafe: "Undo blocked as unsafe"
        case .notSupportedYet: "Undo not supported yet"
        }
    }
}

extension ActionReceiptCorrectionAvailability {
    var trustReceiptCorrectionLabel: String {
        switch self {
        case .available: "Correction available"
        case .availableWithReason: "Correction available with reason"
        case .unavailable: "Correction unavailable"
        case .notSupportedYet: "Correction not supported yet"
        }
    }
}

extension ActionReceiptDisplaySummary {
    var trustReceiptLayerItem: TrustReceiptLayerItem {
        TrustReceiptLayerItem(
            id: id,
            kind: trustReceiptKind,
            title: title,
            summary: summary,
            sourceLabel: sourceDomain.trustReceiptSourceLabel,
            freshness: safetyState.trustReceiptFreshnessState,
            privacyLabel: safetyState.trustReceiptPrivacyLabel,
            whyLabel: trustReceiptWhyLabel,
            changeLabel: trustReceiptChangeLabel,
            undoLabel: undoAvailability.trustReceiptUndoLabel,
            correctionLabel: correctionAvailability.trustReceiptCorrectionLabel,
            reviewLabel: trustReceiptReviewLabel
        )
    }

    var proofTrailBead: ProofBead {
        ProofBead(
            id: id,
            title: title,
            summary: summary,
            sourceLabel: sourceDomain.trustReceiptSourceLabel,
            freshness: safetyState.trustReceiptFreshnessState,
            privacyLabel: safetyState.trustReceiptPrivacyLabel,
            timestampLabel: occurredAt,
            correctionLabel: correctionAvailability.trustReceiptCorrectionLabel,
            staleReviewLabel: trustReceiptStaleReviewLabel
        )
    }

    var trustReceiptKind: TrustReceiptLayerKind {
        switch (safetyState, resultState) {
        case (.safeFailure, _), (.externalUnavailable, _):
            return .blockedSafely
        case (.confirmationRequired, _):
            return .needsReview
        case (_, .undoAvailable):
            return .undone
        case (_, .correctionAvailable):
            return .sourceChange
        case (_, .moved):
            return .moved
        case (_, .changed), (_, .created), (_, .scheduled), (_, .attached), (_, .completed):
            return .proofSaved
        case (_, .failedSafely), (_, .needsConfirmation):
            return .blockedSafely
        case (_, .noOp), (_, .undoUnavailable), (_, .detached), (_, .exportedPrepared), (_, .draftedPrepared):
            return .staleSource
        }
    }

    var trustReceiptWhyLabel: String {
        nextActionTitle ?? "User review keeps the next change visible and inspectable."
    }

    var trustReceiptChangeLabel: String {
        switch resultState {
        case .created: "A new local receipt was recorded."
        case .changed: "The local record changed with a receipt."
        case .scheduled: "A scheduled change was recorded locally."
        case .moved: "The item moved with a receipt."
        case .attached: "The item was attached with a receipt."
        case .detached: "The item was detached with a receipt."
        case .exportedPrepared: "Export was prepared locally."
        case .draftedPrepared: "Draft preparation was recorded."
        case .completed: "The completed step remains visible as proof."
        case .failedSafely: "The change stayed blocked safely."
        case .needsConfirmation: "The change waits for confirmation."
        case .noOp: "No hidden change happened."
        case .undoAvailable: "Undo remains available locally."
        case .undoUnavailable: "Undo is not available for this receipt."
        case .correctionAvailable: "Correction remains available locally."
        }
    }

    var trustReceiptReviewLabel: String {
        switch safetyState {
        case .normal: "Review receipt"
        case .degraded: "Review context"
        case .safeFailure: "Review blocked change"
        case .externalUnavailable: "Review local-only receipt"
        case .confirmationRequired: "Review before confirming"
        }
    }

    var trustReceiptStaleReviewLabel: String? {
        switch safetyState {
        case .normal:
            return nil
        case .degraded:
            return "Review before broader use."
        case .safeFailure:
            return "Blocked safely until the source is reviewed."
        case .externalUnavailable:
            return "Source is unavailable, so the receipt stays local."
        case .confirmationRequired:
            return "Wait for confirmation before broader use."
        }
    }
}

extension ActionReceiptSafetyState {
    var trustReceiptFreshnessState: SourceFreshnessState {
        switch self {
        case .normal: .fresh
        case .degraded: .partial
        case .safeFailure: .blocked
        case .externalUnavailable: .offline
        case .confirmationRequired: .stale
        }
    }

    var trustReceiptPrivacyLabel: String {
        switch self {
        case .normal: "Private by default"
        case .degraded: "Private summary"
        case .safeFailure: "Protected receipt"
        case .externalUnavailable: "Local only"
        case .confirmationRequired: "Private until confirmed"
        }
    }
}
