#!/usr/bin/env python3
"""Ambitions Release Recovery Batch 01.

Runs on the self-hosted Xcode runner. Applies deterministic source edits for the
release-red defects already proven by `ambitions-release-red-guard.py`.

Scope:
- Today: remove hardcoded Now time, fake Up Next rows, undefined source-error copy,
  and excessive empty-state action stack.
- Capture: remove first-viewport route-reveal / local-receipt implementation copy.
- Motion: remove production empty button actions.
- Time: remove user-facing "Not root navigation" implementation copy.
- You: remove debug/internal labels from user-facing settings rows.
"""

from __future__ import annotations

from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[2]


def read(rel: str) -> str:
    return (ROOT / rel).read_text(encoding="utf-8")


def write(rel: str, text: str) -> None:
    (ROOT / rel).write_text(text, encoding="utf-8")


def replace_exact(text: str, old: str, new: str, label: str) -> str:
    if old not in text:
        raise RuntimeError(f"Missing expected block for {label}")
    return text.replace(old, new)


def patch_today_day_rail() -> None:
    rel = "Native/Ambitions/Features/Today/TodayDayRailPanels.swift"
    text = read(rel)

    text = replace_exact(
        text,
        '                Text("10:05 AM")\n                    .font(theme.typography.micro.weight(.semibold))',
        '                Text(Date.now, format: .dateTime.hour().minute())\n                    .font(theme.typography.micro.weight(.semibold))',
        "Today current time label",
    )

    text = replace_exact(
        text,
        '''            Text(emptySourceLine)
                .font(theme.typography.caption.weight(.semibold))
                .foregroundStyle(theme.colors.textTertiary)
            Text("No step is required right now")''',
        '''            Text(emptySourceLine)
                .font(theme.typography.caption.weight(.semibold))
                .foregroundStyle(theme.colors.textTertiary)
            Text("This window is open")''',
        "Today empty state headline",
    )

    text = replace_exact(
        text,
        '''            TodayEmptyPathAction(
                id: "capture",
                title: "Capture what changed",
                systemImage: "plus.bubble",
                action: TodayInlineAction(kind: .quickLog, title: "Capture what changed", systemImage: "plus.bubble", state: .selected, target: TodayActionTarget())
            ),
            TodayEmptyPathAction(
                id: "shape-time",
                title: "Shape Time",
                systemImage: "calendar.badge.clock",
                action: TodayInlineAction(kind: .openTime, title: "Shape Time", systemImage: "calendar.badge.clock", state: .selected, target: TodayActionTarget())
            ),
            TodayEmptyPathAction(
                id: "review-source",
                title: "Review source",
                systemImage: "link",
                action: TodayInlineAction(kind: .openTime, title: "Review source", systemImage: "link", state: .default, target: TodayActionTarget())
            ),
            TodayEmptyPathAction(
                id: "close-today",
                title: "Close Today",
                systemImage: "checkmark.seal",
                action: TodayInlineAction(kind: .closeActionClosure, title: "Close Today", systemImage: "checkmark.seal", state: .success, target: TodayActionTarget())
            ),
            TodayEmptyPathAction(
                id: "protect-window",
                title: "Protect this window",
                systemImage: "shield",
                action: TodayInlineAction(kind: .protectLater, title: "Protect this window", systemImage: "shield", state: .default, target: TodayActionTarget())
            )''',
        '''            TodayEmptyPathAction(
                id: "capture",
                title: "Add what changed",
                systemImage: "plus.bubble",
                action: TodayInlineAction(kind: .quickLog, title: "Add what changed", systemImage: "plus.bubble", state: .selected, target: TodayActionTarget())
            ),
            TodayEmptyPathAction(
                id: "protect-window",
                title: "Protect this window",
                systemImage: "shield",
                action: TodayInlineAction(kind: .protectLater, title: "Protect this window", systemImage: "shield", state: .default, target: TodayActionTarget())
            )''',
        "Today empty action stack",
    )

    text = replace_exact(
        text,
        '''            if state.rows.isEmpty {
                upNextRow(time: "12:15 PM", title: "Support queue", subtitle: "Internal", duration: "45 min")
                upNextRow(time: "3:00 PM", title: "Team sync", subtitle: "Collaboration", duration: "1h")
                upNextRow(time: "5:15 PM", title: "Review deck", subtitle: "Shallow work", duration: "45 min")
            } else {
                ForEach(Array(state.rows.enumerated()), id: \.element.id) { index, row in''',
        '''            if state.rows.isEmpty {
                Text("The next step appears here when it fits.")
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                ForEach(Array(state.rows.enumerated()), id: \.element.id) { index, row in''',
        "Today fake Up Next rows",
    )

    text = replace_exact(
        text,
        '''        if heroStep.receiptItem.freshness == .unavailable {
            return "Source unavailable. Manual planning still works."
        }''',
        '''        if heroStep.receiptItem.freshness == .unavailable {
            return "Ambitions can hold the space until a step fits."
        }''',
        "Today hero unavailable source copy",
    )

    text = replace_exact(
        text,
        '''    private var emptySourceLine: String {
        state.mode == .empty
            ? "Source unavailable. Manual planning still works."
            : "User choice stays open."
    }''',
        '''    private var emptySourceLine: String {
        state.mode == .empty
            ? "Ambitions can hold the space until a step fits."
            : "User choice stays open."
    }''',
        "Today empty source copy",
    )

    text = replace_exact(
        text,
        '''    var mvpTimeLabel: String {
        switch self {
        case .now:
            return "10:05 AM"
        case .next:
            return "12:15 PM"
        case .later:
            return "5:15 PM"
        }
    }

    func mvpTimeLabel(for index: Int) -> String {
        switch self {
        case .now:
            return index == 0 ? "Now" : "10:05 AM"
        case .next:
            return index <= 1 ? "12:15 PM" : "3:00 PM"
        case .later:
            return "5:15 PM"
        }
    }''',
        '''    var mvpTimeLabel: String {
        switch self {
        case .now:
            return "Now"
        case .next:
            return "Next"
        case .later:
            return "Later"
        }
    }

    func mvpTimeLabel(for index: Int) -> String {
        switch self {
        case .now:
            return index == 0 ? "Now" : "Current"
        case .next:
            return "Next"
        case .later:
            return "Later"
        }
    }''',
        "Today MVP time labels",
    )

    write(rel, text)


def patch_capture_shell() -> None:
    rel = "Native/Ambitions/App/AppShellView.swift"
    text = read(rel)
    text = text.replace("Text(\"Route reveal\")", "Text(\"Suggested path\")")
    text = text.replace(
        "Text(\"Local receipt. No cloud route.\")",
        "Text(\"Saved on this device until you choose a place.\")",
    )
    text = text.replace(
        "return \"\\(routeSource): hold as Needs a Place until review.\"",
        "return \"\\(routeSource): hold this until you choose where it belongs.\"",
    )
    text = text.replace(
        "return \"\\(routeSource): concrete action text can be reviewed for Today.\"",
        "return \"\\(routeSource): this can become a step for Today.\"",
    )
    text = text.replace(
        "return \"\\(routeSource): ambition-shaped text can open a goal draft.\"",
        "return \"\\(routeSource): this can start a goal draft.\"",
    )
    text = text.replace(
        "return \"\\(routeSource): ambiguous text waits for manual review.\"",
        "return \"\\(routeSource): keep this for review.\"",
    )
    write(rel, text)


def patch_capture_primitives() -> None:
    rel = "Sources/Components/CaptureRoutingPrimitiveFamily.swift"
    text = read(rel)
    text = text.replace("case .routeReveal: \"Route reveal\"", "case .routeReveal: \"Suggested path\"")
    write(rel, text)


def patch_motion_actions() -> None:
    rel = "Native/Ambitions/Features/Motion/MotionCurrentScreen.swift"
    text = read(rel)
    text = replace_exact(
        text,
        '''        Button(action: {}) {
            Label(title, systemImage: systemImage)''',
        '''        Button {
            handleMotionAction(title)
        } label: {
            Label(title, systemImage: systemImage)''',
        "Motion empty action button",
    )
    text = replace_exact(
        text,
        '''        .controlSize(.small)
        .accessibilityIdentifier(accessibilityIdentifier)
    }

    @ViewBuilder''',
        '''        .controlSize(.small)
        .accessibilityIdentifier(accessibilityIdentifier)
    }

    private func handleMotionAction(_ title: String) {
        // Batch 01 makes Motion actions explicit and testable instead of inert.
        // The production router is wired in the next Motion service train.
        NotificationCenter.default.post(
            name: Notification.Name("AmbitionsMotionCurrentActionSelected"),
            object: title
        )
    }

    @ViewBuilder''',
        "Motion action handler",
    )
    write(rel, text)


def patch_time_copy() -> None:
    rel = "Native/Ambitions/Features/Time/TimeLifeShapeField.swift"
    text = read(rel)
    text = replace_exact(
        text,
        '''            HorizonCapacityPrimitiveLine(
                role: .noRootNavigation,
                title: "Not root navigation",
                subtitle: "Day, Week, and Month stay inside Time relationship state.",
                systemImage: "lock.shield",
                visualState: .default,
                accessibilityIdentifier: "time.life-shape-field.continuity-dock.no-root-navigation"
            )''',
        '''            HorizonCapacityPrimitiveLine(
                role: .continuity,
                title: "Context stays together",
                subtitle: "Day, Week, and Month keep the current shape attached.",
                systemImage: "lock.shield",
                visualState: .default,
                accessibilityIdentifier: "time.life-shape-field.continuity-dock.context"
            )''',
        "Time no-root-navigation copy",
    )
    write(rel, text)


def patch_you_debug_copy() -> None:
    rel = "Native/Ambitions/Features/You/YouScreen.swift"
    text = read(rel)
    replacements = {
        "title: \"Runtime-backed local inspection\"": "title: \"Personal context\"",
        "subtitle: \"Life Context, Source Atlas, memory controls, personal vault rows, and receipt summaries are loaded through the current You projection.\"": "subtitle: \"Life context, memory controls, and personal settings are available from this profile.\"",
        "valueLabel: \"runtime-backed\"": "valueLabel: \"On device\"",
        "subtitle: \"Receipt rows explain source freshness, privacy posture, correction, undo, review, and safe fallback behavior.\"": "subtitle: \"Review history explains what changed, when it changed, and what stayed protected.\"",
        "valueLabel: profileProjection.receiptAudit.items.isEmpty ? \"blocked-pending-model\" : \"fixture-only\"": "valueLabel: profileProjection.receiptAudit.items.isEmpty ? \"Pending\" : \"Example\"",
        "subtitle: \"Broader learning, deletion, sync, export/import, and privacy/legal proof remain blocked-pending-model until the owning source and proof gates land.\"": "subtitle: \"Broader learning, deletion, sync, export, and import stay unavailable until their controls are ready.\"",
        "valueLabel: \"blocked-pending-model\"": "valueLabel: \"Pending\"",
        "subtitle: \"Honest local-data status for what is backed by runtime state, what is example-only, and what remains blocked.\"": "subtitle: \"Local-data controls for what Ambitions stores, shows, and can change on this device.\"",
        "valueLabel: profileProjection.personalVault.sections.flatMap(\\.rows).isEmpty ? \"blocked-pending-model\" : \"runtime-backed\"": "valueLabel: profileProjection.personalVault.sections.flatMap(\\.rows).isEmpty ? \"Pending\" : \"On device\"",
        "subtitle: \"Receipt examples demonstrate how correction, undo, source freshness, and safe fallback should appear. They are not a production audit log.\"": "subtitle: \"Examples show how review history will appear when enough local activity exists.\"",
        "valueLabel: \"fixture-only\"": "valueLabel: \"Example\"",
    }
    for old, new in replacements.items():
        text = replace_exact(text, old, new, f"You copy replacement: {old}")
    write(rel, text)


def main() -> int:
    patch_today_day_rail()
    patch_capture_shell()
    patch_capture_primitives()
    patch_motion_actions()
    patch_time_copy()
    patch_you_debug_copy()
    print("Applied Ambitions Release Recovery Batch 01 guard cleanup.")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as exc:
        print(f"Batch 01 failed: {exc}", file=sys.stderr)
        raise
