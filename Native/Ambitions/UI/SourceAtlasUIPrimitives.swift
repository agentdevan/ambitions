import SwiftUI
import AmbitionsDesignSystem

// MARK: - Source Atlas UI Primitives

/// Explicit badge for requirement source state.
public struct SourceBadge: View {
    let state: SourceAtlasRequirementSourceState
    @Environment(\.ambitionTheme) var theme
    
    public init(state: SourceAtlasRequirementSourceState) {
        self.state = state
    }
    
    public var body: some View {
        HStack(spacing: theme.spacing.xxxs) {
            Image(systemName: iconName)
            Text(label)
        }
        .font(theme.typography.micro)
        .padding(.horizontal, theme.spacing.xxs)
        .padding(.vertical, theme.spacing.xxxs)
        .background(theme.canonSurfaces.graphiteRecess)
        .foregroundColor(color)
        .cornerRadius(theme.radius.chip)
        .overlay(
            Capsule()
                .strokeBorder(color.opacity(0.3), lineWidth: 1)
        )
    }
    
    private var label: String {
        switch state {
        case .official, .officialCurrent: return "Official"
        case .locallyProven: return "Locally Proven"
        case .sourceNeeded: return "Source Needed"
        case .stale: return "Stale"
        case .contradicted: return "Contradicted"
        case .revoked: return "Revoked"
        case .current: return "Current"
        case .unknown: return "Unknown"
        }
    }
    
    private var iconName: String {
        switch state {
        case .official, .officialCurrent: return "checkmark.seal.fill"
        case .locallyProven: return "person.badge.shield.checkmark.fill"
        case .sourceNeeded: return "exclamationmark.triangle.fill"
        case .stale: return "clock.arrow.circlepath"
        case .contradicted: return "xmark.shield.fill"
        case .revoked: return "prohibit"
        default: return "questionmark.circle"
        }
    }
    
    private var color: Color {
        switch state {
        case .official, .officialCurrent, .current: return theme.semanticColors.trust
        case .locallyProven: return theme.semanticColors.confidenceHigh
        case .sourceNeeded: return theme.semanticColors.warning
        case .stale: return theme.semanticColors.confidenceMedium
        case .contradicted, .revoked: return theme.semanticColors.risk
        default: return theme.colors.textSecondary
        }
    }
}

/// Explicit badge for requirement freshness.
public struct FreshnessBadge: View {
    let state: SourceAtlasRequirementFreshnessState
    @Environment(\.ambitionTheme) var theme
    
    public init(state: SourceAtlasRequirementFreshnessState) {
        self.state = state
    }
    
    public var body: some View {
        HStack(spacing: theme.spacing.xxxs) {
            Image(systemName: state == .current ? "leaf.fill" : "clock.fill")
            Text(state.rawValue.capitalized)
        }
        .font(theme.typography.micro)
        .padding(.horizontal, theme.spacing.xxs)
        .padding(.vertical, theme.spacing.xxxs)
        .background(theme.canonSurfaces.graphiteRecess)
        .foregroundColor(color)
        .cornerRadius(theme.radius.chip)
    }
    
    private var color: Color {
        switch state {
        case .current: return theme.semanticColors.confidenceHigh
        case .stale: return theme.semanticColors.confidenceMedium
        default: return theme.colors.textSecondary
        }
    }
}

/// A fold indicating a missing source for a requirement.
public struct SourceNeededFold: View {
    @Environment(\.ambitionTheme) var theme
    
    public init() {}
    
    public var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xxs) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                Text("Source Needed")
                    .font(theme.typography.sectionTitle)
            }
            .foregroundColor(theme.semanticColors.warning)
            
            Text("This requirement is missing an official source basis. Verification is required before it can drive recommendations.")
                .font(theme.typography.bodySecondary)
                .foregroundColor(theme.colors.textSecondary)
        }
        .padding(theme.spacing.standard)
        .background(theme.canonSurfaces.graphiteRecess)
        .cornerRadius(theme.radius.md)
    }
}

/// A fold displaying source information for a requirement.
public struct RequirementSourceFold: View {
    let sourceState: SourceAtlasRequirementSourceState
    @Environment(\.ambitionTheme) var theme
    
    public init(sourceState: SourceAtlasRequirementSourceState) {
        self.sourceState = sourceState
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xxs) {
            Text("Requirement Source")
                .font(theme.typography.sectionTitle)
            
            SourceBadge(state: sourceState)
        }
        .padding(theme.spacing.standard)
        .background(theme.canonSurfaces.graphiteRecess)
        .cornerRadius(theme.radius.md)
    }
}

/// Drawer for reviewing claims.
public struct ClaimReviewDrawer: View {
    @Environment(\.ambitionTheme) var theme
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: theme.spacing.standard) {
            Capsule()
                .frame(width: 40, height: 4)
                .foregroundColor(theme.colors.strokeSubtle)
            
            Text("Claim Review")
                .font(theme.typography.titleCompact)
            
            Text("Please verify the accuracy of this claim based on the provided source.")
                .font(theme.typography.bodySecondary)
                .multilineTextAlignment(.center)
            
            Button("Verify Claim") {
                // Action
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .background(theme.canonSurfaces.quietGlass)
    }
}

/// Sheet for reviewing the source binder.
public struct SourceBinderReviewSheet: View {
    @Environment(\.ambitionTheme) var theme
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            List {
                Section("Official Sources") {
                    Text("O*NET (Current)")
                    Text("BLS (Stale)")
                }
            }
            .navigationTitle("Source Binder Review")
        }
    }
}

/// Receipt for a pack update.
public struct PackUpdateReceipt: View {
    let packID: String
    @Environment(\.ambitionTheme) var theme
    
    public init(packID: String) {
        self.packID = packID
    }
    
    public var body: some View {
        HStack {
            Image(systemName: "arrow.down.doc.fill")
            VStack(alignment: .leading) {
                Text("Pack Updated")
                    .font(theme.typography.bodyEmphasized)
                Text("ID: \(packID)")
                    .font(theme.typography.micro)
            }
        }
        .padding()
        .background(theme.semanticColors.trust.opacity(0.1))
        .cornerRadius(theme.radius.sm)
    }
}

/// Shield for private sources.
public struct PrivateSourceShield: View {
    @Environment(\.ambitionTheme) var theme
    
    public init() {}
    
    public var body: some View {
        HStack {
            Image(systemName: "lock.shield.fill")
            Text("Private Source")
                .font(theme.typography.micro)
        }
        .foregroundColor(theme.colors.textSecondary)
        .padding(.horizontal, theme.spacing.xxs)
        .padding(.vertical, theme.spacing.xxxs)
        .background(theme.colors.surfaceSecondary)
        .cornerRadius(theme.radius.pill)
    }
}

/// Notice for OCR-derived content.
public struct OCRReviewNotice: View {
    @Environment(\.ambitionTheme) var theme
    
    public init() {}
    
    public var body: some View {
        HStack {
            Image(systemName: "text.viewfinder")
            Text("OCR Review Needed")
                .font(theme.typography.micro)
        }
        .foregroundColor(theme.semanticColors.warning)
        .padding(theme.spacing.xxs)
        .background(theme.semanticColors.warning.opacity(0.1))
        .cornerRadius(theme.radius.sm)
    }
}

/// Receipt for source impact.
public struct SourceImpactReceipt: View {
    @Environment(\.ambitionTheme) var theme
    
    public init() {}
    
    public var body: some View {
        Text("Source Impact: Validated")
            .font(theme.typography.bodySecondary)
            .padding(theme.spacing.xxs)
            .background(theme.semanticColors.trust.opacity(0.2))
            .cornerRadius(theme.radius.sm)
    }
}

/// Fold for projection receipts.
public struct ProjectionReceiptFold: View {
    @Environment(\.ambitionTheme) var theme
    
    public init() {}
    
    public var body: some View {
        VStack(alignment: .leading) {
            Text("Projection Receipt")
                .font(theme.typography.sectionTitle)
            Text("A verifiable receipt has been generated for this projection.")
                .font(theme.typography.caption)
        }
        .padding()
        .background(theme.canonSurfaces.graphiteRecess)
    }
}

/// Indicator for skill slices.
public struct SkillSliceIndicator: View {
    let sliceName: String
    @Environment(\.ambitionTheme) var theme
    
    public init(sliceName: String) {
        self.sliceName = sliceName
    }
    
    public var body: some View {
        Text(sliceName)
            .font(theme.typography.micro)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(theme.colors.accentPrimary.opacity(0.2))
            .cornerRadius(4)
    }
}

/// Receipt for an alternative path.
public struct AlternativePathReceipt: View {
    @Environment(\.ambitionTheme) var theme
    
    public init() {}
    
    public var body: some View {
        HStack {
            Image(systemName: "arrow.triangle.branch")
            Text("Alternative Path Available")
                .font(theme.typography.bodySecondary)
        }
        .padding(theme.spacing.xxs)
        .background(theme.colors.accentSecondary.opacity(0.1))
        .cornerRadius(theme.radius.sm)
    }
}

/// Fold for option value reservation.
public struct OptionValueFold: View {
    @Environment(\.ambitionTheme) var theme
    
    public init() {}
    
    public var body: some View {
        VStack(alignment: .leading) {
            Text("Option Value Reserved")
                .font(theme.typography.sectionTitle)
            Text("This path reserves optionality for future adaptations.")
                .font(theme.typography.caption)
        }
        .padding()
        .background(theme.canonSurfaces.quietGlass)
    }
}

// MARK: - Previews

#Preview {
    VStack(spacing: 20) {
        SourceBadge(state: .official)
        FreshnessBadge(state: .current)
        SourceNeededFold()
        RequirementSourceFold(sourceState: .locallyProven)
        PackUpdateReceipt(packID: "onet-v24")
        PrivateSourceShield()
        OCRReviewNotice()
        SkillSliceIndicator(sliceName: "iOS.SwiftUI")
    }
    .padding()
    .background(Color.black)
    .environment(\.ambitionTheme, .dark)
}
