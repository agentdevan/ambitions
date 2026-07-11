#if canImport(SwiftUI)
import SwiftUI

public struct TrustSeamExplainer: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    let title: String
    let reason: String
    let confidence: Double // 0.0 to 1.0
    let source: String
    let onOverride: () -> Void
    let onAccept: () -> Void
    
    @State private var isDetailsExpanded: Bool = false
    
    public init(
        title: String,
        reason: String,
        confidence: Double,
        source: String,
        onOverride: @escaping () -> Void,
        onAccept: @escaping () -> Void
    ) {
        self.title = title
        self.reason = reason
        self.confidence = confidence
        self.source = source
        self.onOverride = onOverride
        self.onAccept = onAccept
    }
    
    public var body: some View {
        QuietGlass(cornerRadius: theme.radius.lg) {
            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                // Section Header
                HStack(alignment: .center) {
                    HStack(spacing: theme.spacing.xxs) {
                        Image(systemName: "lock.shield")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(theme.semanticColors.trust)
                        
                        Text("TRUST SEAM")
                            .font(theme.typography.micro.weight(.bold))
                            .foregroundStyle(theme.semanticColors.trust)
                            .tracking(1.5)
                    }
                    
                    Spacer()
                    
                    // Source Stamp
                    Text(source.uppercased())
                        .font(theme.typography.micro.weight(.semibold))
                        .foregroundStyle(theme.colors.textSecondary)
                        .padding(.horizontal, theme.spacing.xxs)
                        .padding(.vertical, theme.spacing.xxxs)
                        .background {
                            Capsule().fill(theme.colors.strokeSubtle.opacity(0.12))
                        }
                }
                
                // Explanatory Core
                VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                    Text(title)
                        .font(theme.typography.section)
                        .foregroundStyle(theme.colors.textPrimary)
                    
                    Text(reason)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                // Transparency Dial (Confidence Metric)
                HStack(spacing: theme.spacing.md) {
                    // Mini Gauge indicator
                    ZStack {
                        Circle()
                            .stroke(theme.colors.strokeSubtle.opacity(0.2), lineWidth: 4)
                            .frame(width: 38, height: 38)
                        
                        Circle()
                            .trim(from: 0.0, to: CGFloat(confidence))
                            .stroke(
                                confidenceColor,
                                style: StrokeStyle(lineWidth: 4, lineCap: .round)
                            )
                            .frame(width: 38, height: 38)
                            .rotationEffect(.degrees(-90))
                        
                        Text(String(format: "%.0f%%", confidence * 100))
                            .font(theme.typography.micro.weight(.bold))
                            .foregroundStyle(theme.colors.textPrimary)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Local Alignment Fit")
                            .font(theme.typography.caption.weight(.semibold))
                            .foregroundStyle(theme.colors.textPrimary)
                        
                        Text("Determined entirely from local on-device habits.")
                            .font(theme.typography.micro)
                            .foregroundStyle(theme.colors.textTertiary)
                    }
                }
                .padding(theme.spacing.sm)
                .background {
                    RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                        .fill(theme.colors.canvasElevated.opacity(colorSchemeContrast == .increased ? 1.0 : 0.65))
                }
                
                // Expandable explanation fold-out
                VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                    Button(action: {
                        withAnimation(theme.motion.animation(reduceMotion: reduceMotion, emphasis: true)) {
                            isDetailsExpanded.toggle()
                        }
                    }) {
                        HStack {
                            Text("WHY THIS RECOMMENDATION?")
                                .font(theme.typography.micro.weight(.bold))
                                .foregroundStyle(theme.colors.accentSecondary)
                            
                            Spacer()
                            
                            Image(systemName: isDetailsExpanded ? "chevron.up" : "chevron.down")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(theme.colors.accentSecondary)
                        }
                    }
                    .buttonStyle(.plain)
                    
                    if isDetailsExpanded {
                        VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                            Text("1. Historical patterns: You typically close health commitments in the morning.")
                                .font(theme.typography.micro)
                                .foregroundStyle(theme.colors.textSecondary)
                            
                            Text("2. Capacity check: Active time blocks show 35 minutes of free headroom.")
                                .font(theme.typography.micro)
                                .foregroundStyle(theme.colors.textSecondary)
                            
                            Text("3. Non-shaming reflow: Designed to preserve momentum without forcing strict clock deadlines.")
                                .font(theme.typography.micro)
                                .foregroundStyle(theme.colors.textSecondary)
                        }
                        .padding(.top, 4)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
                .padding(.horizontal, 4)
                
                Divider()
                    .background(theme.colors.strokeSubtle)
                
                // Command Override Actions
                HStack(spacing: theme.spacing.sm) {
                    Button(action: onOverride) {
                        Text("ADJUST PROFILE")
                            .font(theme.typography.micro.weight(.bold))
                            .foregroundStyle(theme.colors.textSecondary)
                            .padding(.vertical, theme.spacing.xs)
                            .frame(maxWidth: .infinity)
                            .background {
                                RoundedRectangle(cornerRadius: theme.radius.sm, style: .continuous)
                                    .stroke(theme.colors.strokeStrong, lineWidth: 1.0)
                            }
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: onAccept) {
                        Text("TRUST DECISION")
                            .font(theme.typography.micro.weight(.bold))
                            .foregroundStyle(theme.colors.textInverse)
                            .padding(.vertical, theme.spacing.xs)
                            .frame(maxWidth: .infinity)
                            .background {
                                RoundedRectangle(cornerRadius: theme.radius.sm, style: .continuous)
                                    .fill(theme.semanticColors.trust)
                            }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(theme.spacing.lg)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Trust Seam explanation card")
        .accessibilityValue("Why this recommended action exists: \(reason). Local alignment fit is \(Int(confidence * 100)) percent.")
    }
    
    var confidenceColor: Color {
        if confidence >= 0.8 {
            return theme.semanticColors.confidenceHigh
        } else if confidence >= 0.5 {
            return theme.semanticColors.confidenceMedium
        } else {
            return theme.semanticColors.confidenceLow
        }
    }
}
#endif
