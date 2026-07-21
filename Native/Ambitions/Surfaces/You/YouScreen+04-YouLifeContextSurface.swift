import AmbitionsDesignSystem
import Foundation
import SwiftUI

struct YouLifeContextAction: Hashable, Sendable {
    enum Kind: String, CaseIterable, Hashable, Sendable {
        case edit
        case pause
        case delete
        case review
        case confirm
    }

    let factID: String
    let kind: Kind

    var isSupported: Bool { false }

    var unavailableReason: String {
        "Unavailable until a canonical Life Context mutation owner is implemented."
    }
}

// Life Context mutations remain unavailable until a canonical User System Profile command owner exists.
struct YouLifeContextSurface: View {
    @Environment(\.ambitionTheme) private var theme
    @State private var expandedSectionIDs: Set<String> = ["life-context-basics", "life-context-schedule-availability"]

    let lifeContext: YouLifeContextState
    let onAction: (YouLifeContextAction) -> Void

    init(
        lifeContext: YouLifeContextState,
        onAction: @escaping (YouLifeContextAction) -> Void = { _ in }
    ) {
        self.lifeContext = lifeContext
        self.onAction = onAction
    }

    var body: some View {
        ProductObjectFrame {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(
                    eyebrow: "Life Context",
                    title: lifeContext.title,
                    subtitle: lifeContext.subtitle
                )
                .accessibilityIdentifier("you.life-context-card")

                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    Text(lifeContext.intro)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)

                    VStack(alignment: .leading, spacing: theme.spacing.xs) {
                        Button {
                            expandAllSections()
                        } label: {
                            Label("Catch me up", systemImage: "arrow.down.right.and.arrow.up.left")
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .buttonStyle(AmbitionButtonStyle(tier: .hero, state: .selected))
                        .accessibilityIdentifier("you.life-context.catch-up-button")

                        Button {
                            focusReviewNeededSection()
                        } label: {
                            Label("Review what Ambitions knows", systemImage: "checkmark.shield")
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .buttonStyle(AmbitionButtonStyle(tier: .secondary, state: .default))
                        .accessibilityIdentifier("you.life-context.review-button")
                    }
                }

                VStack(alignment: .leading, spacing: theme.spacing.md) {
                    ForEach(lifeContext.sections) { section in
                        YouLifeContextSectionDisclosure(
                            section: section,
                            isExpanded: expansionBinding(for: section.id),
                            onAction: onAction
                        )
                    }
                }

                Text(lifeContext.footer)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .ambitionPanelAccessibility(
            label: lifeContext.title,
            value: lifeContextAccessibilityValue,
            hint: "Review local life context before Ambitions uses it to fit steps to real life."
        )
    }

    var lifeContextAccessibilityValue: String {
        let facts = lifeContext.sections.flatMap(\.factRows)
        let reviewCount = facts.filter { $0.runtimeUseState == .needsReview }.count
        return "\(lifeContext.sections.count) sections, \(facts.count) facts, \(reviewCount) need review."
    }

    func expansionBinding(for sectionID: String) -> Binding<Bool> {
        Binding(
            get: { expandedSectionIDs.contains(sectionID) },
            set: { isExpanded in
                if isExpanded {
                    expandedSectionIDs.insert(sectionID)
                } else {
                    expandedSectionIDs.remove(sectionID)
                }
            }
        )
    }

    func expandAllSections() {
        expandedSectionIDs = Set(lifeContext.sections.map(\.id))
    }

    func focusReviewNeededSection() {
        expandedSectionIDs = ["life-context-review-needed"]
    }
}

struct YouLifeContextSectionDisclosure: View {
    @Environment(\.ambitionTheme) private var theme

    let section: YouLifeContextSection
    @Binding var isExpanded: Bool
    let onAction: (YouLifeContextAction) -> Void

    var body: some View {
        ProductObjectFrame {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                Button {
                    isExpanded.toggle()
                } label: {
                    HStack(alignment: .top, spacing: theme.spacing.sm) {
                        VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                            Text(section.title)
                                .font(theme.typography.section)
                                .foregroundStyle(theme.colors.textPrimary)
                            Text(section.subtitle)
                                .font(theme.typography.body)
                                .foregroundStyle(theme.colors.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        Spacer(minLength: theme.spacing.sm)

                        TagPill("\(section.factRows.count)", icon: "list.bullet", state: section.factRows.isEmpty ? .default : .selected)

                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                            .foregroundStyle(theme.colors.textSecondary)
                            .accessibilityHidden(true)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("you.life-context.section.\(section.id)")
                .accessibilityLabel(section.title)
                .accessibilityValue("\(section.factRows.count) facts. \(isExpanded ? "Expanded" : "Collapsed")")
                .accessibilityHint(section.subtitle)

                if isExpanded {
                    VStack(alignment: .leading, spacing: theme.spacing.sm) {
                        ForEach(section.factRows) { factRow in
                            YouLifeContextFactRowView(factRow: factRow, onAction: onAction)
                        }
                    }
                }
            }
        }
        .ambitionPanelAccessibility()
    }
}

struct YouLifeContextFactRowView: View {
    @Environment(\.ambitionTheme) private var theme

    let factRow: YouLifeContextFactRow
    let onAction: (YouLifeContextAction) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            HStack(alignment: .top, spacing: theme.spacing.sm) {
                Image(systemName: iconName)
                    .font(.system(size: theme.icon.mediumSize, weight: theme.icon.symbolWeight))
                    .foregroundStyle(theme.colors.accentWarm)
                    .frame(width: 28)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                    Text(factRow.title)
                        .font(theme.typography.bodyEmphasized)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(factRow.detail)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: theme.spacing.sm)
                TagPill(factRow.freshness.label, state: factRow.freshness.visualState)
            }

            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: theme.spacing.xs) {
                        TagPill(factRow.sourceLabel, icon: "doc.text.magnifyingglass", state: .default)
                        TagPill(factRow.activityLabel, icon: "play.circle", state: factRow.activityLabel.localizedCaseInsensitiveContains("active") ? .success : .warning)
                        TagPill(factRow.lastAffectedLabel, icon: "clock", state: factRow.freshness.visualState)
                        TagPill("Runtime use \(factRow.runtimeUseState.label)", icon: "hand.raised", state: factRow.runtimeUseState.visualState)
                        TagPill(factRow.runtimePermissionLabel, icon: "lock.shield", state: factRow.runtimeUseState == .used ? .success : .warning)
                        TagPill(factRow.whereUsed, icon: "tray.full", state: factRow.runtimeUseState.visualState)
                    }
                }

                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                    YouLifeContextFactActionButton(
                        action: YouLifeContextAction(factID: factRow.id, kind: .edit),
                        title: factRow.editLabel,
                        systemImage: "pencil",
                        state: .default,
                        identifier: "you.life-context.fact.\(factRow.id).edit",
                        onAction: onAction
                    )
                    YouLifeContextFactActionButton(
                        action: YouLifeContextAction(factID: factRow.id, kind: .pause),
                        title: factRow.pauseLabel,
                        systemImage: "pause.circle",
                        state: .warning,
                        identifier: "you.life-context.fact.\(factRow.id).pause",
                        onAction: onAction
                    )
                    YouLifeContextFactActionButton(
                        action: YouLifeContextAction(factID: factRow.id, kind: .delete),
                        title: factRow.deleteLabel,
                        systemImage: "trash.slash",
                        state: .warning,
                        identifier: "you.life-context.fact.\(factRow.id).delete",
                        onAction: onAction
                    )
                    YouLifeContextFactActionButton(
                        action: YouLifeContextAction(factID: factRow.id, kind: .review),
                        title: factRow.reviewLabel,
                        systemImage: "checkmark.shield",
                        state: .selected,
                        identifier: "you.life-context.fact.\(factRow.id).review",
                        onAction: onAction
                    )
                    YouLifeContextFactActionButton(
                        action: YouLifeContextAction(factID: factRow.id, kind: .confirm),
                        title: factRow.confirmLabel,
                        systemImage: "checkmark.circle",
                        state: .success,
                        identifier: "you.life-context.fact.\(factRow.id).confirm",
                        onAction: onAction
                    )
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(theme.spacing.md)
        .background(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).fill(theme.colors.surfaceOverlay))
        .overlay(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).stroke(theme.colors.strokeSubtle, lineWidth: 1))
        .ambitionPanelAccessibility()
    }

    var iconName: String {
        switch factRow.captureRouteContext {
        case .needsPlace:
            return "location"
        case .needsReview:
            return "checkmark.shield"
        }
    }
}

struct YouLifeContextFactActionButton: View {
    @Environment(\.ambitionTheme) private var theme

    let action: YouLifeContextAction
    let title: String
    let systemImage: String
    let state: AmbitionVisualState
    let identifier: String
    let onAction: (YouLifeContextAction) -> Void

    var body: some View {
        Button {
            onAction(action)
        } label: {
            Label("\(title) — Unavailable", systemImage: systemImage)
                .font(theme.typography.caption.weight(.semibold))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(AmbitionButtonStyle(tier: .tertiary, state: state))
        .disabled(action.isSupported == false)
        .accessibilityIdentifier(identifier)
        .accessibilityHint(action.unavailableReason)
    }
}

struct YouRuntimeInspectionItemRow: View {
    @Environment(\.ambitionTheme) private var theme

    let item: YouRuntimeInspectionItem

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            HStack(alignment: .top, spacing: theme.spacing.sm) {
                Image(systemName: iconName)
                    .font(.system(size: theme.icon.mediumSize, weight: theme.icon.symbolWeight))
                    .foregroundStyle(theme.colors.accentPrimary)
                    .frame(width: 28)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                    Text(item.title)
                        .font(theme.typography.bodyEmphasized)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(item.summary)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: theme.spacing.sm)

                TagPill(item.kind.label, state: item.state)
            }

            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 220), spacing: theme.spacing.xs, alignment: .leading)],
                alignment: .leading,
                spacing: theme.spacing.xs
            ) {
                TagPill(item.sourceLabel, icon: "doc.text.magnifyingglass", state: .default)
                TagPill(item.controlLabel, icon: "hand.tap", state: item.state)
                TagPill(item.privacyLabel, icon: "lock.shield", state: .default)
            }
        }
        .padding(theme.spacing.md)
        .background(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).fill(theme.colors.surfaceOverlay))
        .overlay(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).stroke(theme.colors.strokeSubtle, lineWidth: 1))
        .ambitionPanelAccessibility(
            label: item.accessibilityLabel,
            value: item.accessibilityValue,
            hint: item.accessibilityHint
        )
    }

    var iconName: String {
        switch item.kind {
        case .learned:
            return "checkmark.seal"
        case .used:
            return "doc.text.magnifyingglass"
        case .ignored:
            return "xmark.seal"
        case .changed:
            return "arrow.triangle.2.circlepath"
        }
    }
}
