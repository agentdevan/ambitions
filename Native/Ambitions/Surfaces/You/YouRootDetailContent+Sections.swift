import AmbitionsDesignSystem
import Foundation
import SwiftUI

extension YouRootDetailContent {
    var captureSettingsSection: YouSectionGroup {
        YouSectionGroup(
            title: "Capture",
            subtitle: "Capture settings reflect the current global composer path.",
            items: [
                SettingsItem(id: "capture-input", title: "Input behavior", subtitle: "Capture opens as a full-screen Stage composer.", icon: "keyboard", valueLabel: "Global"),
                SettingsItem(id: "capture-keyboard-tools", title: "Keyboard tools", subtitle: "Use standard iOS keyboard tools in the Capture field.", icon: "keyboard.chevron.compact.down", valueLabel: "System"),
                SettingsItem(id: "capture-attachments", title: "Attachments", subtitle: "Local attachments stay in the Capture flow and are not uploaded from this setting.", icon: "paperclip", valueLabel: "Local"),
                SettingsItem(id: "capture-teaching-reset", title: "Gesture teaching reset", subtitle: "Reset is not exposed in You yet.", icon: "hand.tap", valueLabel: "Unavailable"),
                SettingsItem(id: "capture-permissions", title: "Permission state", subtitle: "No Capture-only cloud or analytics permission is connected.", icon: "lock", valueLabel: "Local"),
            ],
            footer: "This detail does not rebuild Capture or add a half-sheet path."
        )
    }

    var lifeAreasSection: YouSectionGroup {
        YouSectionGroup(
            title: "Life Areas",
            subtitle: "Life Area ownership remains with Goals.",
            items: [
                SettingsItem(id: "life-areas-defaults", title: "Default areas", subtitle: "Work, Body, Home, People, Self, and Future are supplied by the Goals Life Area Atlas.", icon: "square.grid.2x2", valueLabel: "Available"),
                SettingsItem(id: "life-areas-customization", title: "Customization", subtitle: "Rename, reorder, hide, and add controls are not exposed from You yet.", icon: "slider.horizontal.3", valueLabel: "Unavailable"),
                SettingsItem(id: "life-areas-route-owner", title: "Where to manage", subtitle: "Open Goals to work with Life Area detail and contextual Capture creation.", icon: "target", valueLabel: "Goals"),
            ],
            footer: "You shows the ownership boundary instead of duplicating Goals controls."
        )
    }

    var localDataStatusSection: YouSectionGroup {
        YouSectionGroup(
            title: "Local Data",
            subtitle: "Personal life data remains local unless a future approved sync architecture changes that.",
            items: [
                SettingsItem(id: "local-data-store", title: "Local store", subtitle: "Goals, captures, proof, receipts, preferences, and local context use on-device storage.", icon: "internaldrive", valueLabel: "On device"),
                SettingsItem(id: "local-data-export", title: "Export", subtitle: "Export is status-only here unless an owning export path proves the action.", icon: "square.and.arrow.up", valueLabel: "Bounded"),
                SettingsItem(id: "local-data-erase", title: "Erase", subtitle: "Broad destructive erase is not exposed from this detail.", icon: "trash.slash", valueLabel: "Unavailable"),
            ],
            footer: "Any destructive local-data action must require confirmation before it becomes available."
        )
    }

    var sourcesSection: YouSectionGroup {
        YouSectionGroup(
            title: "Sources",
            subtitle: "Sources are local or permission-backed unless explicitly shown otherwise.",
            items: [
                SettingsItem(id: "sources-permissions", title: "Permissions", subtitle: "Calendar and notification boundaries are shown where the current app can inspect them.", icon: "checkmark.shield", valueLabel: "Review"),
                SettingsItem(id: "sources-freshness", title: "Freshness", subtitle: "Freshness belongs in source detail and receipts, not on the You root.", icon: "clock.arrow.circlepath", valueLabel: "Detail"),
                SettingsItem(id: "sources-add-remove", title: "Add or remove", subtitle: "No connected external source is faked from this setting.", icon: "minus.plus.batteryblock", valueLabel: "Unavailable"),
            ] + profileProjection.assumptionCorrections.items,
            footer: profileProjection.assumptionCorrections.footer
        )
    }

    var sourceSettingsInspectionPresentation: SourceInspectionPresentation {
        guard let row = profileProjection.sourceAtlasKnowledge.sections.flatMap(\.rows).first else {
            return SourceInspectionPresentation.make(
                id: "you-sources-unavailable",
                state: .unavailable,
                publicDetail: SourceInspectionPublicDetail(
                    sourceName: "Public reference detail",
                    sourceKind: "Public reference",
                    referenceTitle: "No source detail loaded",
                    retrievedLabel: "Not available right now",
                    freshnessLabel: "No current source detail available",
                    useLabel: "Blocked from current use"
                ),
                useContext: "Local planning remains available without this reference detail.",
                reviewAction: "Open this detail again after a reference pack is available."
            )
        }

        let state = sourceInspectionState(for: row)
        return SourceInspectionPresentation.make(
            id: "you-sources-\(row.id)",
            state: state,
            publicDetail: SourceInspectionPublicDetail(
                sourceName: sourceInspectionPublicSourceName(for: row),
                sourceKind: "Public reference",
                referenceTitle: sourceInspectionPublicReferenceTitle(for: row),
                retrievedLabel: row.sourceStateLabel,
                freshnessLabel: row.freshnessStateLabel,
                useLabel: row.runtimeUseState.label
            ),
            useContext: sourceInspectionUseContext(for: state),
            reviewAction: sourceInspectionReviewAction(for: state)
        )
    }

    func sourceInspectionPublicSourceName(for row: YouSourceAtlasKnowledgeRow) -> String {
        if row.sourceName.localizedCaseInsensitiveContains("local") {
            return "Local reference pack"
        }

        return "Public reference pack"
    }

    func sourceInspectionPublicReferenceTitle(for row: YouSourceAtlasKnowledgeRow) -> String {
        if row.title.localizedCaseInsensitiveContains("goal") {
            return "Goals reference"
        }

        return row.title
    }

    func sourceInspectionUseContext(for state: SourceInspectionState) -> String {
        switch state {
        case .current:
            return "Can explain public source context for this detail without changing local planning on its own."
        case .stale:
            return "Can be shown as older context, but should not silently change what you do next."
        case .staleCritical:
            return "Too old to guide current recommendations."
        case .unavailable:
            return "Local planning remains available without this reference detail."
        case .conflicted:
            return "Needs a conflict check before it guides behavior."
        case .revoked:
            return "No longer usable for current recommendations."
        case .unsupported:
            return "Not supported by this inspection detail."
        case .reviewRequired:
            return "Needs review before it changes a recommendation."
        }
    }

    func sourceInspectionReviewAction(for state: SourceInspectionState) -> String {
        switch state {
        case .current, .stale:
            return "No review needed right now."
        case .staleCritical:
            return "Use a newer reference before relying on this detail."
        case .unavailable:
            return "Open this detail again after a reference pack is available."
        case .conflicted:
            return "Review the conflict before using this source."
        case .revoked:
            return "Do not use this withdrawn reference."
        case .unsupported:
            return "Use a supported reference type for this detail."
        case .reviewRequired:
            return "Review this reference before it changes a recommendation."
        }
    }

    func sourceInspectionState(for row: YouSourceAtlasKnowledgeRow) -> SourceInspectionState {
        let searchable = [
            row.sourceStateLabel,
            row.freshnessStateLabel,
            row.reviewNeedLabel,
            row.runtimeUseState.label,
        ].joined(separator: " ").lowercased()

        if searchable.contains("revoked") || searchable.contains("withdrawn") {
            return .revoked
        }
        if searchable.contains("conflict") || searchable.contains("contradict") {
            return .conflicted
        }
        if searchable.contains("unsupported") {
            return .unsupported
        }
        if searchable.contains("too old") || searchable.contains("critical") {
            return .staleCritical
        }
        if row.reviewNeedLabel == "Needs Review" || searchable.contains("review") {
            return .reviewRequired
        }
        if searchable.contains("stale") || searchable.contains("older") {
            return .stale
        }
        return .current
    }

    var accessibilitySettingsSection: YouSectionGroup {
        YouSectionGroup(
            title: "Accessibility",
            subtitle: "System accessibility settings are respected; release claims remain proof-gated.",
            items: [
                SettingsItem(id: "accessibility-dynamic-type", title: "Dynamic Type", subtitle: "Rows support larger text through native wrapping.", icon: "textformat.size", valueLabel: "System"),
                SettingsItem(id: "accessibility-reduce-motion", title: "Reduce Motion", subtitle: "Stage animation uses the iOS Reduce Motion environment.", icon: "figure.walk.motion", valueLabel: "System"),
                SettingsItem(id: "accessibility-increase-contrast", title: "Increase Contrast", subtitle: "Semantic tokens provide contrast-aware foreground and stroke states.", icon: "circle.lefthalf.filled", valueLabel: "System"),
                SettingsItem(id: "accessibility-haptics", title: "Haptics", subtitle: "Route haptics use the design-system haptic policy.", icon: "iphone.radiowaves.left.and.right", valueLabel: "Policy"),
                SettingsItem(id: "accessibility-icon-labels", title: "Icon labels", subtitle: "Root navigation labels remain VoiceOver-accessible and not visibly persistent.", icon: "character.cursor.ibeam", valueLabel: "VoiceOver"),
                SettingsItem(id: "accessibility-proof-preview", title: "Proof preview", subtitle: "Manual accessibility proof is still pending.", icon: "checkmark.seal", valueLabel: "Pending"),
            ],
            footer: "This is app support status, not public accessibility certification."
        )
    }

    var aboutSection: YouSectionGroup {
        let info = Bundle.main.infoDictionary
        let version = info?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = info?["CFBundleVersion"] as? String ?? "1"

        return YouSectionGroup(
            title: "About",
            subtitle: "App and local-first status.",
            items: [
                SettingsItem(id: "about-version", title: "Version", subtitle: nil, icon: "number", valueLabel: version),
                SettingsItem(id: "about-build", title: "Build", subtitle: nil, icon: "hammer", valueLabel: build),
                SettingsItem(id: "about-local-first", title: "Local-first core", subtitle: "Core personal life data stays on device by default.", icon: "lock.iphone", valueLabel: "On device"),
                SettingsItem(id: "about-privacy-legal", title: "Privacy & legal", subtitle: "Release privacy and legal approval are not claimed here.", icon: "doc.text", valueLabel: "Pending"),
                SettingsItem(id: "about-diagnostics", title: "Diagnostics export", subtitle: "Diagnostics export is available only where an owning support path proves the action.", icon: "waveform.path.ecg", valueLabel: "Unavailable"),
            ],
            footer: nil
        )
    }

    func durationTitle(for source: DurationSource) -> String {
        switch source {
        case .userSet: "User-set"
        case .userAccepted: "Accepted suggestion"
        case .suggested: "Suggested"
        case .historical: "Historical range"
        case .unset: "Unset"
        case .actual: "Actual"
        }
    }

    func durationSubtitle(for source: DurationSource) -> String {
        switch source {
        case .userSet: "Shown as planned because you set it."
        case .userAccepted: "Shown as planned after you accept it."
        case .suggested: "Always labeled as suggested."
        case .historical: "Always labeled as usually."
        case .unset: "Shown as Duration not set."
        case .actual: "Shown only after completion evidence exists."
        }
    }
}
