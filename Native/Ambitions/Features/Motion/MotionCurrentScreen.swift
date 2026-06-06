import AmbitionsDesignSystem
import SwiftUI

struct MotionCurrentScreen: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let projection: MotionCurrentProjection
    @State private var selectedStrand: MotionCurrentStrand = .proof

    init(projection: MotionCurrentProjection = .fixture) {
        self.projection = projection
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: theme.spacing.lg) {
                Text("Motion Current")
                    .font(theme.typography.section)
                    .foregroundStyle(theme.colors.textPrimary)
                    .accessibilityIdentifier("motion.current.title")

                Picker("Motion strand", selection: $selectedStrand) {
                    ForEach(MotionCurrentStrand.allCases) { strand in
                        Text(strand.title).tag(strand)
                    }
                }
                .pickerStyle(.segmented)
                .accessibilityIdentifier("motion.current.strand-picker")

                Text(projection.groupedSummary(for: selectedStrand, reduceMotionEnabled: reduceMotion))
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                    .accessibilityIdentifier("motion.current.summary")

                ForEach(projection.nodes(for: selectedStrand)) { node in
                    MotionCurrentNodeCard(
                        node: node,
                        showsPrimaryAction: node.id == projection.primaryNodeID(for: selectedStrand)
                    )
                        .accessibilityElement(children: .contain)
                        .accessibilityIdentifier("motion.current.node.\(node.kind.rawValue)")
                }
            }
            .padding(.horizontal, theme.spacing.lg)
            .padding(.vertical, theme.spacing.md)
        }
        .accessibilityIdentifier("motion.current.screen")
    }
}

private struct MotionCurrentNodeCard: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let node: MotionCurrentNode
    let showsPrimaryAction: Bool

    private var groupedActions: MotionCurrentActionGroup {
        node.actions.isEmpty ? .init(primary: nil, secondary: []) : node.actions.divideByPrimary(allowPrimary: showsPrimaryAction)
    }

    var body: some View {
        QuietGlass(cornerRadius: theme.radius.lg) {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                    Text(node.title)
                        .font(theme.typography.title)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(node.description)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                }

                if reduceMotion {
                    Text(node.compactReductionLabel)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textTertiary)
                        .padding(.vertical, theme.spacing.xs)
                        .padding(.horizontal, theme.spacing.sm)
                        .background(theme.colors.surfaceSecondary.opacity(0.2))
                        .clipShape(.capsule)
                        .accessibilityIdentifier("motion.current.reduce-motion-summary.\(node.kind.rawValue)")
                }

                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    SourceProofReceiptRow(label: "Origin", value: node.originLabel)
                    SourceProofReceiptRow(label: "Route", value: node.routeStateLabel)
                    SourceProofReceiptRow(label: "Source", value: node.sourceLabel)
                    SourceProofReceiptRow(label: "Proof", value: node.proofLabel)
                    SourceProofReceiptRow(label: "Receipt", value: node.receiptLabel)
                    SourceProofReceiptRow(label: "Control", value: node.controlLabel)

                    if let primary = groupedActions.primary {
                        Button(primary.label) {
                            // motion-only presentation anchor; no side effects in this scope
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.small)
                        .accessibilityIdentifier("motion.current.primary-\(node.kind.rawValue)")
                    }

                    if groupedActions.secondary.isEmpty == false {
                        VStack(alignment: .leading, spacing: theme.spacing.xs) {
                            ForEach(groupedActions.secondary) { action in
                                Button(action.label) {}
                                    .buttonStyle(.bordered)
                                    .controlSize(.small)
                                    .accessibilityIdentifier("motion.current.secondary-\(node.kind.rawValue).\(action.label.slug)")
                            }
                        }
                    }
                }
            }
            .padding(.vertical, theme.spacing.md)
            .padding(.horizontal, theme.spacing.md)
        }
        .luminousTrace(
            isShimmering: false,
            accentColor: theme.colors.accentSecondary,
            role: .proof,
            intensity: .quiet,
            showsStaticOrigin: true,
            relationshipSummary: node.nonvisualContinuitySummary
        )
        .padding(.horizontal, 0.5)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(node.title). \(node.kind.canonicalLabel)")
        .accessibilityValue(node.nonvisualContinuitySummary)
        .accessibilityHint("Review the owning source, receipt, route state, and user control before following this Motion thread.")
    }
}

private struct SourceProofReceiptRow: View {
    @Environment(\.ambitionTheme) private var theme

    let label: String
    let value: String

    var body: some View {
        HStack(spacing: theme.spacing.sm) {
            Text(label)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textTertiary)
                .frame(width: 60, alignment: .leading)
            Text(value)
                .font(theme.typography.body)
                .foregroundStyle(theme.colors.textPrimary)
        }
        .accessibilityIdentifier("motion.current.\(label.lowercased())-\(value.slug)")
    }
}

private struct MotionCurrentActionGroup {
    let primary: MotionCurrentAction?
    let secondary: [MotionCurrentAction]
}

enum MotionCurrentStrand: String, CaseIterable, Identifiable {
    case proof
    case recovery
    case reentry

    var id: String { rawValue }

    var title: String {
        switch self {
        case .proof:
            "Proof"
        case .recovery:
            "Recovery"
        case .reentry:
            "Re-entry"
        }
    }
}

enum MotionCurrentNodeKind: String, CaseIterable {
    case noMotionYet
    case sourceUnavailable
    case lowConfidenceSourceProof
    case captureObjectPlaced
    case goalThreadRecommended
    case timeReflowReview
    case recovered
    case stalledReentry
    case changed
    case lifeAreaDeveloping
    case receiptHistoryControl

    var canonicalLabel: String {
        switch self {
        case .noMotionYet:
            "No Motion Yet"
        case .sourceUnavailable:
            "Source Unavailable"
        case .lowConfidenceSourceProof:
            "Low-confidence Source/Proof Relation"
        case .captureObjectPlaced:
            "Capture-to-object Placement"
        case .goalThreadRecommended:
            "Goal Thread to Recommended Step"
        case .timeReflowReview:
            "Time-to-Today Reflow Review"
        case .recovered:
            "Recovered"
        case .stalledReentry:
            "Stalled / Re-enter Ready"
        case .changed:
            "Context Changed"
        case .lifeAreaDeveloping:
            "Life-area Developing"
        case .receiptHistoryControl:
            "You Receipt History Control"
        }
    }
}

struct MotionCurrentAction: Identifiable {
    let id: String
    let label: String
    let isPrimary: Bool

    init(_ label: String, isPrimary: Bool = false) {
        self.label = label
        self.isPrimary = isPrimary
        self.id = label.slug
    }
}

struct MotionCurrentNode: Identifiable {
    let id: String
    let strand: MotionCurrentStrand
    let kind: MotionCurrentNodeKind
    let title: String
    let description: String
    let originLabel: String
    let routeStateLabel: String
    let sourceLabel: String
    let proofLabel: String
    let receiptLabel: String
    let controlLabel: String
    let compactReductionLabel: String
    let actions: [MotionCurrentAction]

    var nonvisualContinuitySummary: String {
        [
            originLabel,
            routeStateLabel,
            sourceLabel,
            proofLabel,
            receiptLabel,
            controlLabel,
            compactReductionLabel
        ].joined(separator: ". ")
    }

    init(
        kind: MotionCurrentNodeKind,
        strand: MotionCurrentStrand,
        title: String,
        description: String,
        originLabel: String,
        routeStateLabel: String,
        sourceLabel: String,
        proofLabel: String,
        receiptLabel: String,
        controlLabel: String,
        compactReductionLabel: String,
        actions: [MotionCurrentAction]
    ) {
        self.id = "\(strand.rawValue).\(kind.rawValue)"
        self.kind = kind
        self.strand = strand
        self.title = title
        self.description = description
        self.originLabel = originLabel
        self.routeStateLabel = routeStateLabel
        self.sourceLabel = sourceLabel
        self.proofLabel = proofLabel
        self.receiptLabel = receiptLabel
        self.controlLabel = controlLabel
        self.compactReductionLabel = compactReductionLabel
        self.actions = actions
    }
}

struct MotionCurrentProjection {
    let nodes: [MotionCurrentNode]

    func nodes(for strand: MotionCurrentStrand) -> [MotionCurrentNode] {
        nodes.filter { $0.strand == strand }
    }

    func primaryNodeID(for strand: MotionCurrentStrand) -> MotionCurrentNode.ID? {
        nodes(for: strand).first { node in
            node.actions.contains { $0.isPrimary }
        }?.id
    }

    func visiblePrimaryActionCount(for strand: MotionCurrentStrand) -> Int {
        guard let primaryNodeID = primaryNodeID(for: strand) else { return 0 }
        return nodes(for: strand)
            .filter { $0.id == primaryNodeID }
            .flatMap(\.actions)
            .filter(\.isPrimary)
            .count
    }

    func groupedSummary(for strand: MotionCurrentStrand, reduceMotionEnabled: Bool) -> String {
        if reduceMotionEnabled {
            "Reduce Motion is on: Motion Current keeps one strand selected and summarizes Proof, Recovery, and Re-entry in a calm static grouping."
        } else {
            "Motion Current focuses one strand at a time: \(strand.title), with Proof, Recovery, and Re-entry braided across a single execution thread."
        }
    }

    static let fixture: MotionCurrentProjection = {
        let nodes: [MotionCurrentNode] = [
            MotionCurrentNode(
                kind: .noMotionYet,
                strand: .proof,
                title: "No Motion Yet",
                description: "No Motion records exist for this cycle yet. Start here when Reality Meridian receives your first actionable shift.",
                originLabel: "Origin: Today or Capture pending",
                routeStateLabel: "Route: no transformed object yet",
                sourceLabel: "Source: pending SourceRecord",
                proofLabel: "Proof: empty",
                receiptLabel: "Receipt: none",
                controlLabel: "Control: start from Today or Capture",
                compactReductionLabel: "No-motion state ready for first capture.",
                actions: [
                    MotionCurrentAction("Inspect proof", isPrimary: true)
                ]
            ),
            MotionCurrentNode(
                kind: .sourceUnavailable,
                strand: .proof,
                title: "Source Unavailable",
                description: "The Motion source snapshot is not loaded for inspection right now, but the continuity ledger remains intact.",
                originLabel: "Origin: owning surface retained",
                routeStateLabel: "Route: source review required",
                sourceLabel: "Source: SourceRecord unavailable",
                proofLabel: "Proof: deferred",
                receiptLabel: "Receipt: pending",
                controlLabel: "Control: follow source before reuse",
                compactReductionLabel: "Source inspection is delayed but no data is lost.",
                actions: [
                    MotionCurrentAction("Inspect proof", isPrimary: true),
                    MotionCurrentAction("Follow source")
                ]
            ),
            MotionCurrentNode(
                kind: .lowConfidenceSourceProof,
                strand: .proof,
                title: "Low-confidence Source/Proof Relation",
                description: "Source and proof are linked, but confidence is low. Keep manual control before widening the plan.",
                originLabel: "Origin: Capture held object",
                routeStateLabel: "Route: Needs a Place until confirmed",
                sourceLabel: "Source: capture source label",
                proofLabel: "Proof: weak confidence",
                receiptLabel: "Receipt: review needed",
                controlLabel: "Control: correct route or keep held",
                compactReductionLabel: "Shows low-confidence state before scaling execution.",
                actions: [
                    MotionCurrentAction("Review recovery", isPrimary: true),
                    MotionCurrentAction("Follow source"),
                    MotionCurrentAction("Peek receipt")
                ]
            ),
            MotionCurrentNode(
                kind: .captureObjectPlaced,
                strand: .proof,
                title: "Capture Placed With Receipt",
                description: "A Capture item became a held object, goal seed, proof item, or Time seed only after a visible placement decision.",
                originLabel: "Origin: Capture",
                routeStateLabel: "Route: Held Object to owned surface",
                sourceLabel: "Source: capture text and placement label",
                proofLabel: "Proof: placement can attach to Goal or remain held",
                receiptLabel: "Receipt: placement receipt available",
                controlLabel: "Control: correction remains available",
                compactReductionLabel: "Capture placement keeps origin, route, and receipt grouped.",
                actions: [
                    MotionCurrentAction("Follow source", isPrimary: true),
                    MotionCurrentAction("Peek receipt")
                ]
            ),
            MotionCurrentNode(
                kind: .goalThreadRecommended,
                strand: .proof,
                title: "Goal Thread Fed Today",
                description: "A Goal Thread can surface a Recommended step only with the source, reason, and control path still visible.",
                originLabel: "Origin: Goals",
                routeStateLabel: "Route: Goal Thread to Recommended step",
                sourceLabel: "Source: Direction Atlas relationship",
                proofLabel: "Proof: goal evidence remains inspectable",
                receiptLabel: "Receipt: recommendation receipt path",
                controlLabel: "Control: Why this? and Not this stay available",
                compactReductionLabel: "Goal-to-Today handoff preserves why, source, and control.",
                actions: [
                    MotionCurrentAction("Follow to Today", isPrimary: true),
                    MotionCurrentAction("Follow to Goals"),
                    MotionCurrentAction("Peek receipt")
                ]
            ),
            MotionCurrentNode(
                kind: .recovered,
                strand: .recovery,
                title: "Recovered",
                description: "A stalled thread moved forward with a successful continuity recovery and updated recommendation context.",
                originLabel: "Origin: Today closure",
                routeStateLabel: "Route: Closure Event to Recovery Thread",
                sourceLabel: "Source: closure SourceRecord",
                proofLabel: "Proof: stabilized",
                receiptLabel: "Receipt: available",
                controlLabel: "Control: Still counts or recovery review",
                compactReductionLabel: "Recovery completed and continuity restored.",
                actions: [
                    MotionCurrentAction("Review recovery", isPrimary: true),
                    MotionCurrentAction("Peek receipt")
                ]
            ),
            MotionCurrentNode(
                kind: .timeReflowReview,
                strand: .recovery,
                title: "Time Reflow Needs Review",
                description: "Time can suggest a lighter Today path, but the plan remains unchanged until the user accepts a reviewed reflow.",
                originLabel: "Origin: Time",
                routeStateLabel: "Route: Time pressure to Today preview",
                sourceLabel: "Source: LifeShape Field",
                proofLabel: "Proof: affected steps previewed",
                receiptLabel: "Receipt: preview before mutation",
                controlLabel: "Control: accept, edit, or decline",
                compactReductionLabel: "Time-to-Today handoff keeps the before-and-after state static until review.",
                actions: [
                    MotionCurrentAction("Review recovery", isPrimary: true),
                    MotionCurrentAction("Follow to Today"),
                    MotionCurrentAction("Peek receipt")
                ]
            ),
            MotionCurrentNode(
                kind: .stalledReentry,
                strand: .recovery,
                title: "Stalled / Re-enter",
                description: "Work paused. Recovery is available to resume at the latest safe boundary.",
                originLabel: "Origin: Motion",
                routeStateLabel: "Route: back-link to Today re-entry",
                sourceLabel: "Source: retained SourceRecord",
                proofLabel: "Proof: waiting",
                receiptLabel: "Receipt: queued",
                controlLabel: "Control: resume or review first",
                compactReductionLabel: "Shows one safe re-entry point for the next step.",
                actions: [
                    MotionCurrentAction("Re-enter", isPrimary: true),
                    MotionCurrentAction("Review recovery"),
                    MotionCurrentAction("Peek receipt")
                ]
            ),
            MotionCurrentNode(
                kind: .changed,
                strand: .reentry,
                title: "Context Changed",
                description: "Motion meaning changed after user intent shifted. Follow to Goals for the new thread and avoid stale continuation.",
                originLabel: "Origin: Goals",
                routeStateLabel: "Route: Pivot to Proof Transfer",
                sourceLabel: "Source: realigned SourceRecord",
                proofLabel: "Proof: revised",
                receiptLabel: "Receipt: pending update",
                controlLabel: "Control: inspect before continuing",
                compactReductionLabel: "Changed context reroutes inspection to target surfaces.",
                actions: [
                    MotionCurrentAction("Follow to Goals", isPrimary: true),
                    MotionCurrentAction("Follow source"),
                    MotionCurrentAction("Peek receipt")
                ]
            ),
            MotionCurrentNode(
                kind: .lifeAreaDeveloping,
                strand: .reentry,
                title: "Life-area Developing",
                description: "A life area is developing from experimentation and is not yet a completed proof stream.",
                originLabel: "Origin: Capture, Time, or Goals",
                routeStateLabel: "Route: developing object to owning surface",
                sourceLabel: "Source: active SourceRecord",
                proofLabel: "Proof: provisional",
                receiptLabel: "Receipt: developing",
                controlLabel: "Control: keep, park, or review",
                compactReductionLabel: "Development holds low-pressure continuity for review.",
                actions: [
                    MotionCurrentAction("Follow to Today", isPrimary: true),
                    MotionCurrentAction("Inspect proof"),
                    MotionCurrentAction("Peek receipt")
                ]
            ),
            MotionCurrentNode(
                kind: .receiptHistoryControl,
                strand: .reentry,
                title: "Receipt History Owns Control",
                description: "You keeps learning, receipt history, and automation controls visible without turning Motion into a settings surface.",
                originLabel: "Origin: You",
                routeStateLabel: "Route: Receipt to Trust History",
                sourceLabel: "Source: What Ambitions knows",
                proofLabel: "Proof: local summary only",
                receiptLabel: "Receipt: history row available",
                controlLabel: "Control: reset, pause, disable, or review",
                compactReductionLabel: "You ownership preserves local control and receipt history.",
                actions: [
                    MotionCurrentAction("Open Trust History", isPrimary: true),
                    MotionCurrentAction("Peek receipt")
                ]
            )
        ]
        return MotionCurrentProjection(nodes: nodes)
    }()
}

private extension Array where Element == MotionCurrentAction {
    func divideByPrimary(allowPrimary: Bool) -> MotionCurrentActionGroup {
        var primary: MotionCurrentAction?
        var secondary: [MotionCurrentAction] = []

        for action in self {
            if allowPrimary, action.isPrimary, primary == nil {
                primary = action
            } else {
                secondary.append(action)
            }
        }

        return MotionCurrentActionGroup(primary: primary, secondary: secondary)
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
