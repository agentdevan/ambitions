#!/usr/bin/env python3
from __future__ import annotations

from report_reconstruction_support import read, replace_all, replace_required, require_markers, write, write_proof

TIME = "Native/Ambitions/Features/Time/TimeLifeShapeField.swift"


def main() -> int:
    text = read(TIME)
    text = replace_all(text, {
        "Capacity, pressure, protected time, and local source state.": "Capacity, pressure, and protected time.",
        "Source proof.": "Capacity proof.",
        "title: \"Source and receipt\"": "title: \"Why this fits\"",
        "subtitle: displayedSourceDetail": "subtitle: \"Context and proof stay inspectable when needed.\"",
        "title: \"Horizon\",\n            subtitle: \"Day, Week, and Month shape capacity without becoming root navigation.\"": "title: \"Horizon\",\n            subtitle: \"Day, Week, and Month change the field without changing root navigation.\"",
    })
    text = replace_required(
        text,
        '''            if Self.screenshotFocusesQuietReflow() == false {
                reflowTrustSeam
            }
            continuityDock
''',
        '''            if Self.screenshotFocusesQuietReflow() == false,
               revealsPressure || confirmedReflowAction != nil || displayedRenderState == .reflowPreview {
                reflowTrustSeam
            }
            continuityDock
''',
    )
    text = replace_required(
        text,
        '''            Group {
                if dynamicTypeSize.isAccessibilitySize {
                    ForEach(items) { item in
                        horizonCapacitySourceLine(item)
                    }
                } else {
                    HStack(alignment: .top, spacing: theme.spacing.xs) {
                        ForEach(items) { item in
                            horizonCapacitySourceLine(item)
                        }
                    }
                }
            }
''',
        '''            ViewThatFits(in: .horizontal) {
                HStack(alignment: .top, spacing: theme.spacing.sm) {
                    ForEach(items.prefix(2)) { item in
                        horizonCapacitySourceLine(item)
                    }
                }

                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    ForEach(items) { item in
                        horizonCapacitySourceLine(item)
                    }
                }
            }
''',
    )
    text = replace_required(
        text,
        '''            HorizonCapacityPrimitiveLine(
                role: .receipt,
                title: suite.field.sourceState.whyThisLabel,
                subtitle: suite.field.receipt.detail,
                systemImage: "doc.text.magnifyingglass",
                visualState: suite.field.receipt.visualState
            )
''',
        '''            Button {
                confirmedReflowAction = .edit
            } label: {
                HorizonCapacityPrimitiveLine(
                    role: .receipt,
                    title: "Why this?",
                    subtitle: "Open source, receipt, privacy, and reason detail.",
                    systemImage: "doc.text.magnifyingglass",
                    visualState: suite.field.receipt.visualState
                )
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("time.life-shape-field.why-this")
''',
    )
    write(TIME, text)
    require_markers(TIME, ["ViewThatFits(in: .horizontal)", "time.life-shape-field.why-this", "Capacity, pressure, and protected time.", "displayedRenderState == .reflowPreview"])
    write_proof(
        "REPORT_BATCH_22_TIME_LIFESHAPE_FIELD.md",
        """
# Batch 22 — Time LifeShape Field object rewrite

Status: applied.

Scope:
- Reduced top-level Time copy to capacity, pressure, and protected time.
- Prevented the reflow seam from appearing on initial Time unless the user/screenshot state asks for it.
- Replaced fixed source/review horizontal metadata with ViewThatFits horizontal/stacked behavior.
- Moved detailed Source / Receipt / Privacy / Reason language behind Why this.

Atlas gates:
- Time remains LifeShape Field, not a calendar clone.
- Source / Proof / Receipt stay inspectable, not loud first-viewport columns.
- Dynamic Type and compact width avoid unreadable metadata collapse.
""",
    )
    print("Applied Batch 22 Time LifeShape Field object rewrite.")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
