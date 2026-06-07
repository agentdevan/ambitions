import AmbitionsDesignSystem
import SwiftUI

struct MotionCurrentScreen: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let projection: MotionCurrentProjection

    init(projection: MotionCurrentProjection = .fixture) {
        self.projection = projection
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: theme.spacing.lg) {
                MotionContextCrown(state: projection.crown)
                MotionCurrentField(state: projection.field, reduceMotion: reduceMotion)
                MotionLaneCluster(lanes: projection.lanes)
                MotionSourceReceiptAffordance(state: projection.affordance)
                MotionContinuityDock(actions: projection.dockActions)
            }
            .padding(.horizontal, theme.spacing.lg)
            .padding(.vertical, theme.spacing.md)
        }
        .scrollIndicators(.hidden)
        .accessibilityIdentifier("motion.current.screen")
    }
}

private struct MotionContextCrown: View {
    @Environment(\.ambitionTheme) private var theme

    let state: MotionContextCrownState

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            HStack(alignment: .firstTextBaseline, spacing: theme.spacing.sm) {
                Text(state.eyebrow)
                    .font(theme.typography.micro)
                    .foregroundStyle(theme.colors.textTertiary)
                    .textCase(.uppercase)

                Rectangle()
                    .fill(theme.colors.strokeSubtle)
                    .frame(width: 22, height: 1)
                    .accessibilityHidden(true)
            }

            Text(state.title)
                .font(theme.typography.hero)
                .foregroundStyle(theme.colors.textPrimary)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
                .accessibilityIdentifier("motion.current.title")

            Text(state.summary)
                .font(theme.typography.body)
                .foregroundStyle(theme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityIdentifier("motion.current.context-summary")

            FlowLayout(spacing: theme.spacing.xs) {
                ForEach(state.chips) { chip in
                    AmbitionChip(chip.title, icon: chip.icon, role: .state, semanticState: chip.semanticState)
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(state.title). \(state.summary)")
    }
}

private struct MotionCurrentField: View {
    @Environment(\.ambitionTheme) private var theme

    let state: MotionCurrentFieldState
    let reduceMotion: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            HStack(alignment: .top, spacing: theme.spacing.md) {
                MotionFieldGlyph(reduceMotion: reduceMotion)
                    .frame(width: 86, height: 132)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    Text(state.title)
                        .font(theme.typography.section)
                        .foregroundStyle(theme.colors.textPrimary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.82)

                    Text(state.summary)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)

                    MotionFieldFactRow(label: "Source", value: state.source)
                    MotionFieldFactRow(label: "Proof", value: state.proof)
                    MotionFieldFactRow(label: "Receipt", value: state.receipt)
                }
            }

            Text(state.control)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textTertiary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, theme.spacing.xs)
        }
        .padding(theme.spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                .fill(theme.colors.surfacePrimary.opacity(0.72))
        )
        .overlay(
            RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                .stroke(theme.colors.accentSecondary.opacity(0.38), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("motion.current.field")
        .accessibilityLabel("\(state.title). \(state.summary)")
        .accessibilityValue("\(state.source). \(state.proof). \(state.receipt). \(state.control)")
    }
}

private struct MotionFieldGlyph: View {
    @Environment(\.ambitionTheme) private var theme

    let reduceMotion: Bool

    var body: some View {
        ZStack {
            Capsule()
                .fill(theme.colors.surfaceSecondary.opacity(0.32))
                .frame(width: 16)

            VStack(spacing: reduceMotion ? 14 : 10) {
                MotionFieldNode(color: theme.colors.accentSecondary, size: 18)
                MotionFieldNode(color: theme.colors.accentPrimary, size: 26)
                MotionFieldNode(color: theme.colors.success, size: 18)
            }

            Path { path in
                path.move(to: CGPoint(x: 42, y: 18))
                path.addCurve(
                    to: CGPoint(x: 42, y: 114),
                    control1: CGPoint(x: reduceMotion ? 42 : 72, y: 42),
                    control2: CGPoint(x: reduceMotion ? 42 : 12, y: 86)
                )
            }
            .stroke(
                LinearGradient(
                    colors: [
                        theme.colors.accentSecondary.opacity(0.78),
                        theme.colors.accentPrimary.opacity(0.5),
                        theme.colors.success.opacity(0.68)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                ),
                style: StrokeStyle(lineWidth: 2, lineCap: .round)
            )
        }
    }
}

private struct MotionFieldNode: View {
    @Environment(\.ambitionTheme) private var theme

    let color: Color
    let size: CGFloat

    var body: some View {
        Circle()
            .fill(color.opacity(0.82))
            .frame(width: size, height: size)
            .overlay(Circle().stroke(theme.colors.textPrimary.opacity(0.18), lineWidth: 1))
            .shadow(color: color.opacity(0.22), radius: 10, x: 0, y: 3)
    }
}

private struct MotionFieldFactRow: View {
    @Environment(\.ambitionTheme) private var theme

    let label: String
    let value: String

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: theme.spacing.sm) {
            Text(label)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textTertiary)
                .frame(width: 58, alignment: .leading)

            Text(value)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("motion.current.fact.\(label.slug)")
    }
}

private struct MotionLaneCluster: View {
    @Environment(\.ambitionTheme) private var theme

    let lanes: [MotionLaneState]

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            ForEach(lanes) { lane in
                MotionLaneBand(lane: lane)
            }
        }
        .accessibilityIdentifier("motion.current.lanes")
    }
}

private struct MotionLaneBand: View {
    @Environment(\.ambitionTheme) private var theme

    let lane: MotionLaneState

    var body: some View {
        HStack(alignment: .top, spacing: theme.spacing.md) {
            ZStack {
                Circle()
                    .fill(lane.color(theme).opacity(0.2))
                    .frame(width: 38, height: 38)
                Image(systemName: lane.icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(lane.color(theme))
            }
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                HStack(alignment: .firstTextBaseline, spacing: theme.spacing.sm) {
                    Text(lane.title)
                        .font(theme.typography.title)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(lane.status)
                        .font(theme.typography.micro)
                        .foregroundStyle(theme.colors.textTertiary)
                        .textCase(.uppercase)
                }

                Text(lane.summary)
                    .font(theme.typography.body)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                FlowLayout(spacing: theme.spacing.xs) {
                    ForEach(lane.markers) { marker in
                        AmbitionChip(marker.title, icon: marker.icon, role: .state, semanticState: marker.semanticState)
                    }
                }

                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                    ForEach(lane.items) { item in
                        MotionLaneStateRow(item: item, tint: lane.color(theme))
                    }
                }
                .padding(.top, theme.spacing.xs)
            }
        }
        .padding(.vertical, theme.spacing.md)
        .padding(.horizontal, theme.spacing.md)
        .background(
            RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                .fill(theme.colors.surfaceSecondary.opacity(0.24))
        )
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(lane.color(theme))
                .frame(width: 3)
                .clipShape(Capsule())
                .padding(.vertical, theme.spacing.sm)
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("motion.current.lane.\(lane.id)")
        .accessibilityLabel("\(lane.title). \(lane.status). \(lane.summary)")
        .accessibilityValue(lane.items.map(\.accessibilitySummary).joined(separator: ". "))
    }
}

private struct MotionLaneStateRow: View {
    @Environment(\.ambitionTheme) private var theme

    let item: MotionLaneItemState
    let tint: Color

    var body: some View {
        HStack(alignment: .top, spacing: theme.spacing.sm) {
            Circle()
                .fill(item.semanticState == .success ? theme.colors.success : tint)
                .frame(width: 8, height: 8)
                .padding(.top, 7)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                HStack(alignment: .firstTextBaseline, spacing: theme.spacing.xs) {
                    Text(item.title)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(item.stateLabel)
                        .font(theme.typography.micro)
                        .foregroundStyle(theme.colors.textTertiary)
                        .textCase(.uppercase)
                }

                HStack(alignment: .top, spacing: theme.spacing.xs) {
                    MotionTracePill(label: "Source", value: item.source)
                    MotionTracePill(label: "Proof", value: item.proof)
                    MotionTracePill(label: "Receipt", value: item.receipt)
                }
            }
        }
        .padding(.vertical, theme.spacing.xs)
        .padding(.horizontal, theme.spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: theme.radius.sm, style: .continuous)
                .fill(theme.colors.canvasElevated.opacity(0.22))
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(item.title)
        .accessibilityValue(item.accessibilitySummary)
    }
}

private struct MotionTracePill: View {
    @Environment(\.ambitionTheme) private var theme

    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(label)
                .font(theme.typography.micro)
                .foregroundStyle(theme.colors.textTertiary)
            Text(value)
                .font(theme.typography.micro)
                .foregroundStyle(theme.colors.textSecondary)
                .lineLimit(2)
                .minimumScaleFactor(0.78)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct MotionSourceReceiptAffordance: View {
    @Environment(\.ambitionTheme) private var theme

    let state: MotionSourceReceiptAffordanceState

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            Text(state.title)
                .font(theme.typography.title)
                .foregroundStyle(theme.colors.textPrimary)

            HStack(alignment: .top, spacing: theme.spacing.sm) {
                ForEach(state.items) { item in
                    VStack(alignment: .leading, spacing: theme.spacing.xs) {
                        Image(systemName: item.icon)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(item.semanticState == .success ? theme.colors.success : theme.colors.accentSecondary)
                        Text(item.label)
                            .font(theme.typography.caption)
                            .foregroundStyle(theme.colors.textTertiary)
                        Text(item.value)
                            .font(theme.typography.micro)
                            .foregroundStyle(theme.colors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .padding(theme.spacing.md)
        .background(
            RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                .fill(theme.colors.surfaceOverlay.opacity(0.18))
        )
        .overlay(
            RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                .stroke(theme.colors.strokeSubtle.opacity(0.72), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("motion.current.source-proof-receipt")
    }
}

private struct MotionContinuityDock: View {
    @Environment(\.ambitionTheme) private var theme

    let actions: [MotionDockAction]

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            Text("Continuity Dock")
                .font(theme.typography.title)
                .foregroundStyle(theme.colors.textPrimary)

            FlowLayout(spacing: theme.spacing.sm) {
                ForEach(actions) { action in
                    Button(action.title) {}
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                        .accessibilityIdentifier("motion.current.dock.\(action.id)")
                }
            }
        }
        .padding(.bottom, theme.spacing.md)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("motion.current.continuity-dock")
    }
}

struct MotionCurrentProjection {
    let crown: MotionContextCrownState
    let field: MotionCurrentFieldState
    let lanes: [MotionLaneState]
    let affordance: MotionSourceReceiptAffordanceState
    let dockActions: [MotionDockAction]

    static let fixture = MotionCurrentProjection(
        crown: MotionContextCrownState(
            eyebrow: "Motion",
            title: "Motion Current",
            summary: "A living field for proof, recovery, and re-entry threads moving between Today, Goals, Time, and You.",
            chips: [
                MotionChipState(title: "Local", icon: "iphone", semanticState: .protected),
                MotionChipState(title: "Source-led", icon: "link", semanticState: .trust),
                MotionChipState(title: "Receipt-aware", icon: "checkmark.seal", semanticState: .success)
            ]
        ),
        field: MotionCurrentFieldState(
            title: "Current thread is forming",
            summary: "Motion keeps the first visible shift structured even before a saved thread exists.",
            source: "SourceRecord attaches at the handoff",
            proof: "Proof stays visible after closure",
            receipt: "Receipt path appears before change",
            control: "User control remains visible before any continuity change is applied."
        ),
        lanes: [
            MotionLaneState(
                id: "proof",
                title: "Proof lane",
                status: "Origin visible",
                summary: "Source, proof, and owning surface stay braided before the thread enters Today.",
                icon: "checkmark.seal",
                colorRole: .proof,
                markers: [
                    MotionChipState(title: "Origin", icon: "point.topleft.down.curvedto.point.bottomright.up", semanticState: .focus),
                    MotionChipState(title: "Proof seam", icon: "seal", semanticState: .success),
                    MotionChipState(title: "Receipt path", icon: "doc.text", semanticState: .trust)
                ],
                items: [
                    MotionLaneItemState(
                        id: "no-proof-yet",
                        title: "No proof yet",
                        stateLabel: "Seed",
                        source: "Today or Capture",
                        proof: "Open seam",
                        receipt: "Created on close",
                        semanticState: .neutral
                    ),
                    MotionLaneItemState(
                        id: "proof-available",
                        title: "Proof available",
                        stateLabel: "Attached",
                        source: "Closure",
                        proof: "Visible",
                        receipt: "Linked",
                        semanticState: .success
                    ),
                    MotionLaneItemState(
                        id: "proof-transferred",
                        title: "Proof transferred",
                        stateLabel: "Carried",
                        source: "Goals",
                        proof: "Preserved",
                        receipt: "Transfer note",
                        semanticState: .trust
                    ),
                    MotionLaneItemState(
                        id: "source-unavailable",
                        title: "Source unavailable",
                        stateLabel: "Held",
                        source: "Needs local source",
                        proof: "Not widened",
                        receipt: "No change",
                        semanticState: .caution
                    )
                ]
            ),
            MotionLaneState(
                id: "recovery",
                title: "Recovery lane",
                status: "Calm route",
                summary: "A lighter route can rejoin Today with source, reason, and consent visible.",
                icon: "arrow.uturn.backward.circle",
                colorRole: .recovery,
                markers: [
                    MotionChipState(title: "Still counts", icon: "checkmark.circle", semanticState: .recovery),
                    MotionChipState(title: "Lighter path", icon: "leaf", semanticState: .focus),
                    MotionChipState(title: "Consent", icon: "hand.raised", semanticState: .trust)
                ],
                items: [
                    MotionLaneItemState(
                        id: "recovery-active",
                        title: "Recovery active",
                        stateLabel: "In motion",
                        source: "Today closure",
                        proof: "Minimum kept",
                        receipt: "Calm route",
                        semanticState: .recovery
                    ),
                    MotionLaneItemState(
                        id: "recovery-complete",
                        title: "Recovery complete",
                        stateLabel: "Stable",
                        source: "Today",
                        proof: "Still counts",
                        receipt: "Saved",
                        semanticState: .success
                    ),
                    MotionLaneItemState(
                        id: "stalled-returnable",
                        title: "Stalled but returnable",
                        stateLabel: "Returnable",
                        source: "Motion",
                        proof: "Held",
                        receipt: "Return point",
                        semanticState: .focus
                    ),
                    MotionLaneItemState(
                        id: "receipt-linked",
                        title: "Receipt linked",
                        stateLabel: "Traceable",
                        source: "Receipt",
                        proof: "Related",
                        receipt: "Open",
                        semanticState: .trust
                    )
                ]
            ),
            MotionLaneState(
                id: "reentry",
                title: "Re-entry lane",
                status: "Return point",
                summary: "A paused thread keeps one calm return point and a clear owner.",
                icon: "arrowshape.turn.up.forward",
                colorRole: .reentry,
                markers: [
                    MotionChipState(title: "Owner", icon: "person.crop.circle", semanticState: .protected),
                    MotionChipState(title: "Return point", icon: "arrow.forward.circle", semanticState: .focus),
                    MotionChipState(title: "Next seam", icon: "line.3.horizontal.decrease", semanticState: .trust)
                ],
                items: [
                    MotionLaneItemState(
                        id: "reentry-available",
                        title: "Re-entry available",
                        stateLabel: "Ready",
                        source: "Today",
                        proof: "Last honest point",
                        receipt: "Open path",
                        semanticState: .focus
                    ),
                    MotionLaneItemState(
                        id: "life-area-development",
                        title: "Life-area development",
                        stateLabel: "Developing",
                        source: "Capture or Goals",
                        proof: "Provisional",
                        receipt: "Reviewable",
                        semanticState: .protected
                    ),
                    MotionLaneItemState(
                        id: "changed-object",
                        title: "Changed object",
                        stateLabel: "Rerouted",
                        source: "Goals",
                        proof: "Reattached",
                        receipt: "Change note",
                        semanticState: .trust
                    )
                ]
            )
        ],
        affordance: MotionSourceReceiptAffordanceState(
            title: "Source, proof, receipt",
            items: [
                MotionAffordanceItem(label: "Source", value: "Local record", icon: "link", semanticState: .trust),
                MotionAffordanceItem(label: "Proof", value: "Attached after closure", icon: "seal", semanticState: .success),
                MotionAffordanceItem(label: "Receipt", value: "Visible before change", icon: "doc.text", semanticState: .trust)
            ]
        ),
        dockActions: [
            MotionDockAction(id: "today", title: "Open Today"),
            MotionDockAction(id: "goals", title: "Open Goals"),
            MotionDockAction(id: "time", title: "Open Time"),
            MotionDockAction(id: "trust", title: "Open Trust")
        ]
    )
}

struct MotionContextCrownState {
    let eyebrow: String
    let title: String
    let summary: String
    let chips: [MotionChipState]
}

struct MotionCurrentFieldState {
    let title: String
    let summary: String
    let source: String
    let proof: String
    let receipt: String
    let control: String
}

struct MotionLaneState: Identifiable {
    enum ColorRole {
        case proof
        case recovery
        case reentry
    }

    let id: String
    let title: String
    let status: String
    let summary: String
    let icon: String
    let colorRole: ColorRole
    let markers: [MotionChipState]
    let items: [MotionLaneItemState]

    func color(_ theme: AmbitionTheme) -> Color {
        switch colorRole {
        case .proof:
            theme.colors.accentSecondary
        case .recovery:
            theme.colors.accentWarm
        case .reentry:
            theme.colors.success
        }
    }
}

struct MotionLaneItemState: Identifiable {
    let id: String
    let title: String
    let stateLabel: String
    let source: String
    let proof: String
    let receipt: String
    let semanticState: AmbitionSemanticState

    var accessibilitySummary: String {
        "\(stateLabel). Source: \(source). Proof: \(proof). Receipt: \(receipt)"
    }
}

struct MotionChipState: Identifiable {
    let title: String
    let icon: String
    let semanticState: AmbitionSemanticState

    var id: String { "\(title)-\(icon)" }
}

struct MotionSourceReceiptAffordanceState {
    let title: String
    let items: [MotionAffordanceItem]
}

struct MotionAffordanceItem: Identifiable {
    let label: String
    let value: String
    let icon: String
    let semanticState: AmbitionSemanticState

    var id: String { label.slug }
}

struct MotionDockAction: Identifiable {
    let id: String
    let title: String
}

private struct FlowLayout<Content: View>: View {
    let spacing: CGFloat
    @ViewBuilder let content: Content

    init(spacing: CGFloat, @ViewBuilder content: () -> Content) {
        self.spacing = spacing
        self.content = content()
    }

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: spacing) {
                content
            }

            VStack(alignment: .leading, spacing: spacing) {
                content
            }
        }
    }
}

private extension String {
    var slug: String {
        lowercased()
            .replacingOccurrences(of: " / ", with: "-")
            .replacingOccurrences(of: " ", with: "-")
            .replacingOccurrences(of: "?", with: "")
            .replacingOccurrences(of: "/", with: "-")
    }
}
