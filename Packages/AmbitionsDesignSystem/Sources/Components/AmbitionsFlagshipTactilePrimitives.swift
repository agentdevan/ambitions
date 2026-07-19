#if canImport(SwiftUI)
import SwiftUI

// MARK: - 1. ContextCrownHeader

/// An ultra-thin, highly polished persistent navigation crown representing
/// the current focus path, active lens state, and local on-device sync pulse.
/// Adheres strictly to the "one-primary-object" layout guidelines in `PRODUCT_DESIGN_TRUTH.md`.
public struct ContextCrownHeader: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    let title: String
    let contextPhrase: String
    let syncState: AmbitionTrustBadgeState
    
    @State private var isSyncAnimating: Bool = false
    @State private var ambientGlowPhase: Double = 0.0
    
    public init(
        title: String,
        contextPhrase: String,
        syncState: AmbitionTrustBadgeState = .localOnly
    ) {
        self.title = title
        self.contextPhrase = contextPhrase
        self.syncState = syncState
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center) {
                // Focus Scope Indicator
                HStack(spacing: theme.spacing.xxs) {
                    Circle()
                        .fill(theme.colors.accentSecondary)
                        .frame(width: 6, height: 6)
                        .shadow(color: theme.colors.accentSecondary.opacity(0.4), radius: 2)
                    
                    Text(title.uppercased())
                        .font(theme.typography.micro.weight(.semibold))
                        .foregroundStyle(theme.colors.textPrimary)
                        .tracking(2.0)
                }
                
                // Micro Compass Divider Ticks mimicking physical instrument markings
                HStack(spacing: 3) {
                    ForEach(0..<5) { index in
                        Rectangle()
                            .fill(theme.colors.strokeSubtle.opacity(index == 2 ? 0.70 : 0.28))
                            .frame(width: 1, height: index == 2 ? 10 : 5)
                    }
                }
                .padding(.horizontal, theme.spacing.xs)
                
                // Context Sub-phrase
                Text(contextPhrase)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                    .lineLimit(1)
                
                Spacer()
                
                // On-Device Integrity Badge with elegant resting breathe pulse
                HStack(spacing: theme.spacing.xxs) {
                    Circle()
                        .fill(theme.colors.accentPrimary)
                        .frame(width: 5, height: 5)
                        .opacity(colorSchemeContrast == .increased ? 1.0 : (0.45 + 0.55 * sin(ambientGlowPhase)))
                        .shadow(color: theme.colors.accentPrimary.opacity(0.6), radius: 2)
                    
                    Image(systemName: syncState.systemImage)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(theme.colors.accentPrimary)
                        .rotationEffect(.degrees(isSyncAnimating ? 360 : 0))
                    
                    Text("LOCAL SYSTEM")
                        .font(theme.typography.micro.weight(.bold))
                        .foregroundStyle(theme.colors.accentPrimary)
                        .tracking(1.0)
                }
                .padding(.horizontal, theme.spacing.xs)
                .padding(.vertical, theme.spacing.xxxs)
                .background {
                    Capsule()
                        .fill(theme.colors.accentPrimary.opacity(0.10))
                }
                .overlay {
                    Capsule()
                        .strokeBorder(theme.colors.accentPrimary.opacity(0.24), lineWidth: 0.5)
                }
            }
            .padding(.horizontal, theme.spacing.lg)
            .padding(.vertical, theme.spacing.xs)
            .background {
                if colorSchemeContrast == .increased {
                    theme.colors.canvas
                } else {
                    theme.shell.headerMaterial
                        .opacity(0.92)
                }
            }
            
            // Subtly shimmering bottom hairline stroke
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            theme.colors.strokeSubtle.opacity(0.02),
                            theme.colors.accentSecondary.opacity(0.35),
                            theme.colors.strokeSubtle.opacity(0.02)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 0.5)
        }
        .onAppear {
            if !reduceMotion {
                withAnimation(Animation.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
                    ambientGlowPhase = .pi
                }
                if syncState == .synced {
                    withAnimation(Animation.linear(duration: 3.5).repeatForever(autoreverses: false)) {
                        isSyncAnimating = true
                    }
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Context Crown: \(title)")
        .accessibilityValue("\(contextPhrase). On-device status is active.")
    }
}

// MARK: - 2. AtmosphereComposerCanvas

/// A majestic, tactile thought capture canvas that converts typed text inputs
/// into floating, connected coordinate particles, simulating an organic "thought cloud"
/// which moves gracefully inside a refractive glass capsule.
#endif
