import AmbitionsDesignSystem
import SwiftUI

struct LifeShapeWhyThisInspection: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @State private var showsReasons = false
    @State private var showsProof = false

    let layer: LifeShapeLayer
    let mark: LifeShapeSemanticMark?
    let todayAnchor: String

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            Button {
                withAnimation(reduceMotion ? nil : .easeOut(duration: 0.16)) {
                    showsReasons.toggle()
                    if showsReasons == false {
                        showsProof = false
                    }
                }
            } label: {
                Label("Why this?", systemImage: "questionmark.circle")
                    .font(theme.typography.caption.weight(.semibold))
                    .foregroundStyle(theme.colors.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(minHeight: 44)
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("time.life-shape-field.why-this.button")

            if showsReasons {
                VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                    ForEach(Array(humanReasons.enumerated()), id: \.offset) { _, reason in
                        Label(reason, systemImage: "checkmark.circle")
                            .font(theme.typography.caption)
                            .foregroundStyle(theme.colors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    if showsProof {
                        VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                            ForEach(Array(proofLines.enumerated()), id: \.offset) { _, line in
                                Text(line)
                                    .font(theme.typography.caption)
                                    .foregroundStyle(theme.colors.textTertiary)
                                    .lineLimit(dynamicTypeSize.isAccessibilitySize ? nil : 2)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        .padding(.top, theme.spacing.xxs)
                        .accessibilityElement(children: .combine)
                        .accessibilityIdentifier("time.life-shape-field.proof-inspection")
                    }

                    Button {
                        withAnimation(reduceMotion ? nil : .easeOut(duration: 0.16)) {
                            showsProof.toggle()
                        }
                    } label: {
                        Label("Inspect proof", systemImage: "doc.text.magnifyingglass")
                            .font(theme.typography.caption.weight(.semibold))
                            .foregroundStyle(theme.colors.accentSecondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .frame(minHeight: 44)
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("time.life-shape-field.inspect-proof.button")
                }
                .padding(theme.spacing.sm)
                .background(theme.colors.surfaceSecondary.opacity(0.72), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                .accessibilityElement(children: .contain)
                .accessibilityIdentifier("time.life-shape-field.why-this.reasons")
            }
        }
    }

    private var humanReasons: [String] {
        switch layer {
        case .open:
            [
                "This window is open because it still has room before the next fixed point.",
                "You prefer short transition buffers.",
                "This block is not protected."
            ]
        case .protected:
            [
                "This window is protected because it is marked as a boundary.",
                "Today avoids this block before recommending a Step.",
                "This block is protected."
            ]
        case .pressure, .buffer:
            [
                mark?.accessibilitySummary ?? "This Time shape needs review before it becomes a Step.",
                todayAnchor
            ]
        }
    }

    private var proofLines: [String] {
        [
            "Proof is attached to this Time window.",
            "Receipt is saved with this Time shape.",
            "History stays available after you ask."
        ]
    }
}
