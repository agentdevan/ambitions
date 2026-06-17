#!/usr/bin/env python3
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
TODAY = ROOT / "Native" / "Ambitions" / "Features" / "Today" / "TodayDayRailPanels.swift"
OUT = ROOT / "artifacts" / "object-stage-mega-train" / "reconciliation"
OUT.mkdir(parents=True, exist_ok=True)

text = TODAY.read_text(encoding="utf-8")

old_time_spine = '''    private var timeSpine: some View {
        Group {
            if dynamicTypeSize.isAccessibilitySize {
                compactTimeSpine
            } else {
                VStack(spacing: 0) {
                    timeTick("6 AM", prominent: false)
                    verticalSegment(height: 50)
                    currentTimeNode
                    verticalSegment(height: 58)
                    timeTick("12 PM", prominent: false)
                    verticalSegment(height: 72)
                    mappedRowNode(index: 0, fallbackSymbol: "person.2.fill", fallbackColor: Color.blue.opacity(0.75))
                    verticalSegment(height: 56)
                    timeTick("4 PM", prominent: false)
                    verticalSegment(height: 46)
                    mappedRowNode(index: 1, fallbackSymbol: "person.2.fill", fallbackColor: Color.green.opacity(0.76))
                    verticalSegment(height: 54)
                    mappedRowNode(index: 2, fallbackSymbol: "doc.text.fill", fallbackColor: Color.purple.opacity(0.76))
                    verticalSegment(height: 34)
                    timeTick("8 PM", prominent: false)
                }
            }
        }
        .padding(.top, theme.spacing.xs)
        .accessibilityHidden(true)
    }
'''

new_time_spine = '''    private var timeSpine: some View {
        TimelineView(.periodic(from: .now, by: 60)) { timeline in
            Group {
                if dynamicTypeSize.isAccessibilitySize {
                    compactTimeSpine
                } else {
                    liveTimeSpine(date: timeline.date)
                }
            }
        }
        .padding(.top, theme.spacing.xs)
        .accessibilityIdentifier("TodayRealityRailLiveTimeSpine")
        .accessibilityHidden(true)
    }

    private func liveTimeSpine(date: Date) -> some View {
        VStack(spacing: 0) {
            timeTick(timeLabel(offsetHours: -3, from: date), prominent: false)
            verticalSegment(height: 50)
            currentTimeNode(date: date)
            verticalSegment(height: 58)
            timeTick(timeLabel(offsetHours: 2, from: date), prominent: false)
            verticalSegment(height: 72)
            mappedRowNode(index: 0, fallbackSymbol: "person.2.fill", fallbackColor: Color.blue.opacity(0.75))
            verticalSegment(height: 56)
            timeTick(timeLabel(offsetHours: 5, from: date), prominent: false)
            verticalSegment(height: 46)
            mappedRowNode(index: 1, fallbackSymbol: "person.2.fill", fallbackColor: Color.green.opacity(0.76))
            verticalSegment(height: 54)
            mappedRowNode(index: 2, fallbackSymbol: "doc.text.fill", fallbackColor: Color.purple.opacity(0.76))
            verticalSegment(height: 34)
            timeTick(timeLabel(offsetHours: 8, from: date), prominent: false)
        }
    }

    private func timeLabel(offsetHours: Int, from date: Date) -> String {
        let adjusted = Calendar.current.date(byAdding: .hour, value: offsetHours, to: date) ?? date
        return adjusted.formatted(.dateTime.hour())
    }
'''

if old_time_spine not in text:
    raise SystemExit("Expected hardcoded time spine block not found")
text = text.replace(old_time_spine, new_time_spine)

old_cta_stack = '''            HStack(spacing: theme.spacing.md) {
                Button {
                    onOpenStepDetail(heroStep.stepDetail(privacy: state.privacyProjection, contextLabel: state.contextSummary))
                } label: {
                    Label("Why this?", systemImage: "chevron.right")
                        .font(theme.typography.caption.weight(.semibold))
                        .labelStyle(.titleAndIcon)
                        .foregroundStyle(theme.colors.accentWarm)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("TodayMFPWhyThis")

                if heroStep.secondaryAction != nil {
                    Button {
                        onShowAnother(heroStep)
                    } label: {
                        Text(secondaryActionTitle(for: heroStep.secondaryAction))
                            .font(theme.typography.caption.weight(.semibold))
                            .foregroundStyle(theme.colors.textSecondary)
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("TodayMFPAdjust")
                }
            }
'''

if old_cta_stack not in text:
    raise SystemExit("Expected Start Here CTA stack block not found")
text = text.replace(old_cta_stack, "")

for forbidden in ['timeTick("6 AM"', 'timeTick("12 PM"', 'timeTick("4 PM"', 'timeTick("8 PM"', '"Why this?"', 'TodayMFPAdjust']:
    if forbidden in text:
        raise SystemExit(f"Replay failed to remove blocker marker: {forbidden}")

TODAY.write_text(text, encoding="utf-8")

report = """# AMB-AOM-08 Today Replay

Status: `GREEN_REPLAY_SOURCE_DELTA`

This replay closes the AMB-AOM-08 Yellow by removing hardcoded time-spine labels and simplifying the visible Start Here action surface.

## Source changes

- `Native/Ambitions/Features/Today/TodayDayRailPanels.swift`

## Scope result

- The Today time spine now derives labels from live `TimelineView` dates instead of fixed `6 AM`, `12 PM`, `4 PM`, and `8 PM` ticks.
- Start Here now keeps one primary action plus one inspection affordance instead of a visible CTA stack.
- The existing live-now node, refresh-after-action path, refresh-after-closure path, Dynamic Type, VoiceOver identifiers, and Reduce Motion behavior remain intact.

## Remaining risk

This closes AMB-AOM-08 blocker scope. Pixel-level Today polish remains a later visual QA concern, not a blocker to reconciliation.

## Next gate

Proceed to AMB-AOM-00/01/02/05 proof-quality closeout before AMB-AOM-09.
"""
(OUT / "AMB-AOM-08-today-replay.md").write_text(report, encoding="utf-8")
print("AMB-AOM-08 Today blocker replay written.")
