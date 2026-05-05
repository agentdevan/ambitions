#if canImport(SwiftUI)
import SwiftUI

private struct InteractionMotionHapticsPreviewGallery: View {
    @Environment(\.ambitionTheme) private var theme

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: theme.spacing.lg) {
                AdaptiveModuleChrome(
                    title: "Interaction Motion Haptics",
                    subtitle: "Motion explains orientation, confirmation, and review states without becoming reward feedback.",
                    context: .trust,
                    state: .calm,
                    evidence: "System-native haptics are optional and only mapped to user-initiated confirmation."
                ) {
                    VStack(alignment: .leading, spacing: theme.spacing.sm) {
                        ForEach(AmbitionInteractionToken.allCases, id: \.rawValue) { token in
                            interactionRow(token)
                        }
                    }
                }

                AdaptiveModuleChrome(
                    title: "FCP09 Object Motion Policies",
                    subtitle: "Flagship objects keep static meaning, bounded haptics, and Reduce Motion equivalents.",
                    context: .today,
                    state: .proof,
                    evidence: "Start Here, Rail, Drawer, Fold, Spine, Closure, LifeShape, and Capture share one object-policy contract."
                ) {
                    VStack(alignment: .leading, spacing: theme.spacing.sm) {
                        ForEach(AmbitionFlagshipMotionObject.allCases, id: \.rawValue) { object in
                            objectPolicyRow(object.motionPolicy)
                        }
                    }
                }
            }
            .padding(theme.spacing.lg)
        }
        .background(LivingSurfaceBackground(context: .trust, state: .calm).ignoresSafeArea())
        .ambitionTheme(.dark)
    }

    private func interactionRow(_ token: AmbitionInteractionToken) -> some View {
        VStack(alignment: .leading, spacing: theme.spacing.xxs) {
            HStack(alignment: .firstTextBaseline, spacing: theme.spacing.xs) {
                EvidenceLabel(token.purpose.title, state: visualState(for: token), context: .trust)

                Text(token.title)
                    .font(theme.typography.bodyEmphasized)
                    .foregroundStyle(theme.colors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer(minLength: theme.spacing.xs)

                if token.allowsAutomaticHaptics {
                    Image(systemName: "hand.tap")
                        .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                        .foregroundStyle(theme.colors.textSecondary)
                        .accessibilityHidden(true)
                }
            }

            Text(token.reduceMotionEquivalent)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(theme.spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                .fill(theme.colors.surfaceSecondary.opacity(0.52))
        )
        .overlay(
            RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                .stroke(theme.colors.strokeSubtle, lineWidth: 1)
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(token.accessibilitySummary)
    }

    private func objectPolicyRow(_ policy: AmbitionObjectMotionPolicy) -> some View {
        VStack(alignment: .leading, spacing: theme.spacing.xxs) {
            HStack(alignment: .firstTextBaseline, spacing: theme.spacing.xs) {
                EvidenceLabel(policy.owner, state: .proof, context: .trust)

                Text(policy.objectTitle)
                    .font(theme.typography.bodyEmphasized)
                    .foregroundStyle(theme.colors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer(minLength: theme.spacing.xs)

                Text(policy.motionPreset.rawValue)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Text(policy.stateMeaning)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            Text(policy.reduceMotionEquivalent)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(theme.spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                .fill(theme.colors.surfaceSecondary.opacity(0.48))
        )
        .overlay(
            RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                .stroke(theme.colors.strokeSubtle, lineWidth: 1)
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(policy.accessibilitySummary)
    }

    private func visualState(for token: AmbitionInteractionToken) -> LivingVisualState {
        switch token.purpose {
        case .orientation:
            return .active
        case .confirmation:
            return .proof
        case .uncertaintyReduction:
            return .stale
        }
    }
}

struct InteractionMotionHapticsPreviews: PreviewProvider {
    static var previews: some View {
        Group {
            InteractionMotionHapticsPreviewGallery()
                .previewDisplayName("SI12 Interaction Motion Haptics")

            InteractionMotionHapticsPreviewGallery()
                .transaction { transaction in
                    transaction.disablesAnimations = true
                }
                .previewDisplayName("SI12 Interaction Motion Haptics Reduce Motion")

            InteractionMotionHapticsPreviewGallery()
                .environment(\.sizeCategory, .accessibilityExtraExtraExtraLarge)
                .previewDisplayName("SI12 Interaction Motion Haptics Dynamic Type")
        }
    }
}
#endif
