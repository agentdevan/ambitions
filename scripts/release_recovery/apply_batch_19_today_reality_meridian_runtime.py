#!/usr/bin/env python3
from __future__ import annotations

from report_reconstruction_support import read, replace_required, require_markers, write, write_proof

TODAY = "Native/Ambitions/Features/Today/TodayDayRailPanels.swift"


def main() -> int:
    text = read(TODAY)
    text = replace_required(
        text,
        "private struct TodayEmptyPathAction: Identifiable {\n    let id: String\n    let title: String\n    let systemImage: String\n    let action: TodayInlineAction\n}\n",
        "private struct TodayEmptyPathAction: Identifiable {\n    let id: String\n    let title: String\n    let systemImage: String\n    let action: TodayInlineAction\n}\n\nprivate enum TodayMeridianZoom: String, CaseIterable {\n    case window\n    case day\n}\n",
    )
    text = replace_required(
        text,
        "    @Environment(\\.accessibilityReduceMotion) private var reduceMotion\n\n    let state: AmbitionsDayRailViewState",
        "    @Environment(\\.accessibilityReduceMotion) private var reduceMotion\n    @State private var meridianZoom: TodayMeridianZoom = .window\n\n    let state: AmbitionsDayRailViewState",
    )
    text = replace_required(
        text,
        '''    private var currentTimeNode: some View {
        HStack(spacing: theme.spacing.xs) {
            VStack(alignment: .trailing, spacing: 1) {
                Text(Date.now, format: .dateTime.hour().minute())
                    .font(theme.typography.micro.weight(.semibold))
                    .foregroundStyle(theme.colors.accentWarm)
                    .lineLimit(1)
                    .minimumScaleFactor(0.62)
                Text("Now")
                    .font(theme.typography.caption.weight(.semibold))
                    .foregroundStyle(theme.colors.accentWarm)
            }
            .frame(width: 42, alignment: .trailing)

            ZStack {
                Circle()
                    .fill(theme.colors.accentWarm.opacity(0.22))
                    .frame(width: 42, height: 42)
                    .blur(radius: 2)
                Circle()
                    .fill(theme.colors.accentWarm)
                    .frame(width: 16, height: 16)
                Circle()
                    .stroke(theme.colors.accentWarm.opacity(0.78), lineWidth: 2)
                    .frame(width: 30, height: 30)
            }
        }
    }
''',
        '''    private var currentTimeNode: some View {
        TimelineView(.periodic(from: .now, by: 60)) { timeline in
            currentTimeNode(date: timeline.date)
        }
        .accessibilityIdentifier("TodayRealityRailLiveNow")
    }

    private func currentTimeNode(date: Date) -> some View {
        HStack(spacing: theme.spacing.xs) {
            VStack(alignment: .trailing, spacing: 1) {
                Text(date, format: .dateTime.hour().minute())
                    .font(theme.typography.micro.weight(.semibold))
                    .foregroundStyle(theme.colors.accentWarm)
                    .lineLimit(1)
                    .minimumScaleFactor(0.62)
                Text("Now")
                    .font(theme.typography.caption.weight(.semibold))
                    .foregroundStyle(theme.colors.accentWarm)
            }
            .frame(width: 42, alignment: .trailing)

            ZStack {
                Circle()
                    .fill(theme.colors.accentWarm.opacity(reduceMotion ? 0.18 : 0.22))
                    .frame(width: 42, height: 42)
                    .blur(radius: reduceMotion ? 0 : 2)
                Circle()
                    .fill(theme.colors.accentWarm)
                    .frame(width: 16, height: 16)
                Circle()
                    .stroke(theme.colors.accentWarm.opacity(0.78), lineWidth: 2)
                    .frame(width: 30, height: 30)
            }
        }
    }
''',
    )
    text = replace_required(
        text,
        '''            HStack(spacing: theme.spacing.sm) {
                startHereOriginMarker

                Text("Start here")
                    .font(theme.typography.caption.weight(.semibold))
                    .foregroundStyle(theme.colors.accentWarm)
            }
            Text(emptySourceLine)
''',
        '''            HStack(spacing: theme.spacing.sm) {
                startHereOriginMarker

                Text("Available now")
                    .font(theme.typography.caption.weight(.semibold))
                    .foregroundStyle(theme.colors.accentWarm)
            }
            Text(emptySourceLine)
''',
    )
    text = text.replace('''        .accessibilityLabel("Source, trust, and receipt")''', '''        .accessibilityLabel("Why this fits")''')
    text = text.replace('''        .accessibilityLabel("Today open paths")''', '''        .accessibilityLabel("Today available actions")''')
    write(TODAY, text)
    require_markers(TODAY, ["TimelineView(.periodic", "TodayRealityRailLiveNow", "TodayMeridianZoom", "Available now", "Why this fits"])
    write_proof(
        "REPORT_BATCH_19_TODAY_REALITY_MERIDIAN.md",
        """
# Batch 19 — Today Reality Meridian runtime/live interaction

Status: applied.

Scope:
- Converted the visible Now node to a SwiftUI TimelineView that refreshes every minute.
- Added an explicit TodayMeridianZoom state anchor for the next scroll/zoom pass.
- Split empty-state visible language away from Start here by rendering Available now when no recommended step exists.
- Kept Source / Proof / Receipt canonical concepts inspectable while changing the first-viewport accessibility grouping to Why this fits.

Atlas gates:
- Today remains Reality Meridian + Start Here Surface.
- Start here is reserved for a recommended step state.
- Current time is live and not hardcoded.
- Empty Today does not read as a task-list failure state.
""",
    )
    print("Applied Batch 19 Today Reality Meridian runtime/live interaction.")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
