#if canImport(SwiftUI)
import SwiftUI

private struct DAVScenario: Identifiable, Sendable {
    let id: String
    let title: String
    let subtitle: String
    let context: LivingTabContext
    let state: LivingVisualState
    let evidence: String
    let pressure: Double?
    let labels: [String]

    static let all: [DAVScenario] = [
        DAVScenario(
            id: "calm-normal-day",
            title: "Calm normal day",
            subtitle: "One next step is ready, pressure is visible, and recovery stays nearby.",
            context: .today,
            state: .active,
            evidence: "Photo target 01 / Today",
            pressure: 0.42,
            labels: ["Next step ready", "Now", "No hidden urgency"]
        ),
        DAVScenario(
            id: "overloaded-day",
            title: "Overloaded day",
            subtitle: "Pressure is legible without shame, and the primary affordance is to lighten the plan.",
            context: .today,
            state: .pressured,
            evidence: "Overloaded day preview",
            pressure: 0.86,
            labels: ["Adjust plan", "Pressure visible", "Recovery path"]
        ),
        DAVScenario(
            id: "recovery-day",
            title: "Recovery day",
            subtitle: "The surface narrows to one believable next move instead of making the miss louder.",
            context: .today,
            state: .recovery,
            evidence: "Recovery day preview",
            pressure: 0.28,
            labels: ["Still Counts", "Smaller version", "No shame"]
        ),
        DAVScenario(
            id: "empty-capture",
            title: "Empty capture",
            subtitle: "The composer stays quiet and useful before the user gives it anything.",
            context: .capture,
            state: .empty,
            evidence: "Photo target 02 / Capture",
            pressure: nil,
            labels: ["Capture Anything", "Needs a Place", "No fake routing"]
        ),
        DAVScenario(
            id: "routed-capture",
            title: "Routed capture",
            subtitle: "A placed thought shows where it went and keeps correction visible.",
            context: .capture,
            state: .proof,
            evidence: "routed capture preview",
            pressure: nil,
            labels: ["Saved to Goal", "Change place", "Receipt visible"]
        ),
        DAVScenario(
            id: "blocked-step",
            title: "Blocked step",
            subtitle: "A blocker is red only when it truly blocks action, and the next safe move remains visible.",
            context: .goals,
            state: .pressured,
            evidence: "Blocked step preview",
            pressure: 0.74,
            labels: ["Blocked", "Ask for help", "Source visible"]
        ),
        DAVScenario(
            id: "still-counts",
            title: "Still Counts",
            subtitle: "Closure gives proof to the minimum honest version without turning into celebration noise.",
            context: .trust,
            state: .proof,
            evidence: "Still Counts preview",
            pressure: nil,
            labels: ["Proof saved", "Minimum version", "Undo available"]
        ),
        DAVScenario(
            id: "goal-with-proof",
            title: "Goal with proof",
            subtitle: "Constellation Atlas makes proof, next step, and momentum feel calm and source-bound.",
            context: .goals,
            state: .proof,
            evidence: "goal with proof preview",
            pressure: 0.36,
            labels: ["Proof", "Next Step", "Momentum"]
        ),
        DAVScenario(
            id: "goal-with-blocker",
            title: "Goal with blocker",
            subtitle: "The lane language separates a true blocker from normal pressure.",
            context: .goals,
            state: .stale,
            evidence: "goal with blocker preview",
            pressure: 0.66,
            labels: ["Blocker", "Needs decision", "No KPI drift"]
        ),
        DAVScenario(
            id: "stale-memory",
            title: "Stale memory",
            subtitle: "Old context is visibly useful only after review.",
            context: .memory,
            state: .stale,
            evidence: "stale memory preview",
            pressure: nil,
            labels: ["May need review", "Source age visible", "Review controls"]
        ),
        DAVScenario(
            id: "rejected-memory",
            title: "Rejected memory",
            subtitle: "The user correction is the truth, and the rejected context stays inspectable.",
            context: .memory,
            state: .recovery,
            evidence: "rejected memory preview",
            pressure: nil,
            labels: ["Rejected", "Correction saved", "Do not reuse"]
        ),
        DAVScenario(
            id: "private-memory",
            title: "Private memory",
            subtitle: "Sensitive context is not dressed up as magic; it shows control before intelligence.",
            context: .memory,
            state: .sensitive,
            evidence: "Private memory preview",
            pressure: nil,
            labels: ["Sensitive", "User controlled", "Hidden until opened"]
        ),
        DAVScenario(
            id: "high-dynamic-type",
            title: "High Dynamic Type",
            subtitle: "The gallery keeps state, evidence, and controls readable at accessibility text sizes.",
            context: .you,
            state: .calm,
            evidence: "Dynamic Type preview",
            pressure: nil,
            labels: ["Large text", "Rows wrap", "No clipped proof"]
        ),
        DAVScenario(
            id: "reduce-motion",
            title: "Reduce Motion",
            subtitle: "Motion meaning survives as labels, hierarchy, and opacity-only/static state.",
            context: .trust,
            state: .calm,
            evidence: "Reduce Motion preview",
            pressure: nil,
            labels: ["Static state", "No looping motion", "Same meaning"]
        )
    ]
}

private struct DynamicAdaptiveVisualGallery: View {
    @Environment(\.ambitionTheme) private var theme
    let scenarios: [DAVScenario]

    init(scenarios: [DAVScenario] = DAVScenario.all) {
        self.scenarios = scenarios
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: theme.spacing.lg) {
                AdaptiveModuleChrome(
                    title: "Dynamic Adaptive Visual gallery",
                    subtitle: "Photo-matched preview inventory for DAV12: dark studio material, readable state, and no generic dashboard drift.",
                    context: .you,
                    state: .active,
                    evidence: "Targets 01-04 inspected"
                ) {
                    GroupedNavigationSystem(
                        sections: [
                            GroupedNavigationSystemSection(
                                id: "dav12-coverage",
                                title: "Scenario coverage",
                                subtitle: "Preview fixtures stay visual-only and make accessibility states explicit.",
                                items: [
                                    GroupedNavigationSystemItem(
                                        id: "dynamic-type",
                                        title: "Dynamic Type",
                                        subtitle: "Large text has a named preview and wrapping evidence.",
                                        symbolName: "textformat.size",
                                        state: .calm,
                                        statusLabel: "Named"
                                    ),
                                    GroupedNavigationSystemItem(
                                        id: "reduce-motion",
                                        title: "Reduce Motion",
                                        subtitle: "Motion examples use static or opacity-only equivalents.",
                                        symbolName: "figure.walk.motion",
                                        state: .proof,
                                        statusLabel: "Named"
                                    )
                                ]
                            )
                        ],
                        context: .you
                    )
                }

                ForEach(scenarios) { scenario in
                    DAVScenarioCard(scenario: scenario)
                }

                MemoryConstellation(
                    title: "Memory state coverage",
                    subtitle: "Current, stale, rejected, sensitive, corrected, and no-result states are visible without hidden inference.",
                    nodes: [
                        MemoryConstellationNode(id: "current", title: "Current", detail: "Usable", state: .current),
                        MemoryConstellationNode(id: "stale", title: "Stale", detail: "Review", state: .stale),
                        MemoryConstellationNode(id: "rejected", title: "Rejected", detail: "Do not reuse", state: .rejected),
                        MemoryConstellationNode(id: "private", title: "Private", detail: "Controlled", state: .sensitive)
                    ]
                )

                TrustReceiptStack(
                    title: "Receipt state coverage",
                    subtitle: "Proof, correction, undo, stale source, blocked, and empty receipt states stay source-bound.",
                    items: [
                        TrustReceiptStackItem(
                            id: "proof",
                            title: "Proof saved after Still Counts",
                            summary: "A minimum honest version was saved with correction available.",
                            sourceLabel: "Today closure",
                            freshnessLabel: "Just now",
                            undoLabel: "Undo remains visible",
                            correctionLabel: "Correction available",
                            nextActionLabel: "Next: return to Today",
                            state: .proofSaved
                        ),
                        TrustReceiptStackItem(
                            id: "stale-source",
                            title: "Source may need review",
                            summary: "A memory-backed suggestion is present, but freshness is explicit.",
                            sourceLabel: "Saved memory",
                            freshnessLabel: "Older context",
                            undoLabel: "Ignore this source",
                            correctionLabel: "Review source",
                            nextActionLabel: "Next: inspect before reuse",
                            state: .staleSource
                        )
                    ]
                )
            }
            .padding(theme.spacing.lg)
        }
        .background(LivingSurfaceBackground(context: .today, state: .calm).ignoresSafeArea())
        .ambitionTheme(.dark)
    }
}

private struct DAVScenarioCard: View {
    @Environment(\.ambitionTheme) private var theme
    let scenario: DAVScenario

    var body: some View {
        AdaptiveModuleChrome(
            title: scenario.title,
            subtitle: scenario.subtitle,
            context: scenario.context,
            state: scenario.state,
            evidence: scenario.evidence
        ) {
            if let pressure = scenario.pressure {
                PressureGlow(level: pressure, context: scenario.context, label: "\(scenario.title) pressure")
            }

            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                ForEach(scenario.labels, id: \.self) { label in
                    EvidenceLabel(label, state: scenario.state, context: scenario.context)
                }
            }

            if scenario.state == .proof {
                ProofPulse(isActive: true, label: "\(scenario.title) proof state")
            }
        }
        .accessibilityIdentifier("dav12.preview.\(scenario.id)")
    }
}

struct DynamicAdaptiveVisualGallery_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DynamicAdaptiveVisualGallery()
                .previewDisplayName("DAV12 Scenario Gallery")

            DynamicAdaptiveVisualGallery(scenarios: DAVScenario.all.filter { $0.id == "calm-normal-day" })
                .previewDisplayName("DAV Calm Normal Day")

            DynamicAdaptiveVisualGallery(scenarios: DAVScenario.all.filter { $0.id == "overloaded-day" })
                .previewDisplayName("DAV Overloaded Day")

            DynamicAdaptiveVisualGallery(scenarios: DAVScenario.all.filter { $0.id == "recovery-day" })
                .previewDisplayName("DAV Recovery Day")

            DynamicAdaptiveVisualGallery(scenarios: DAVScenario.all.filter { $0.id == "empty-capture" || $0.id == "routed-capture" })
                .previewDisplayName("DAV Capture Empty And Routed")

            DynamicAdaptiveVisualGallery(scenarios: DAVScenario.all.filter { $0.id == "goal-with-proof" || $0.id == "goal-with-blocker" })
                .previewDisplayName("DAV Goal Proof And Blocker")

            DynamicAdaptiveVisualGallery(scenarios: DAVScenario.all.filter { $0.id == "stale-memory" || $0.id == "rejected-memory" || $0.id == "private-memory" })
                .previewDisplayName("DAV Memory Trust States")

            DynamicAdaptiveVisualGallery()
                .transaction { transaction in
                    transaction.disablesAnimations = true
                }
                .previewDisplayName("DAV Reduce Motion")

            DynamicAdaptiveVisualGallery()
                .environment(\.sizeCategory, .accessibilityExtraExtraExtraLarge)
                .previewDisplayName("DAV High Dynamic Type")
        }
    }
}
#endif
