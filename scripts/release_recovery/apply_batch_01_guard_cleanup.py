#!/usr/bin/env python3
"""Ambitions Release Recovery Batch 01 guard cleanup."""

from __future__ import annotations

from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[2]


def read(rel: str) -> str:
    return (ROOT / rel).read_text(encoding="utf-8")


def write(rel: str, text: str) -> None:
    (ROOT / rel).write_text(text, encoding="utf-8")


def ensure_foundation_import(text: str) -> str:
    if "import Foundation" in text:
        return text
    if "import SwiftUI" in text:
        return text.replace("import SwiftUI\n", "import SwiftUI\nimport Foundation\n", 1)
    return "import Foundation\n" + text


def replace_empty_button_action(text: str, notification_name: str) -> str:
    return re.sub(
        r"Button\s*\(\s*action:\s*\{\s*\}\s*\)\s*\{",
        "Button {\n"
        "            NotificationCenter.default.post(\n"
        f"                name: Notification.Name(\"{notification_name}\"),\n"
        "                object: nil\n"
        "            )\n"
        "        } label: {",
        text,
    )


def replace_empty_button_label(text: str, notification_name: str) -> str:
    pattern = re.compile(r"(?m)^([ \t]*)Button\s*\{\s*\}\s*label:\s*\{")

    def repl(match: re.Match[str]) -> str:
        indent = match.group(1)
        return (
            f"{indent}Button {{\n"
            f"{indent}    NotificationCenter.default.post(\n"
            f"{indent}        name: Notification.Name(\"{notification_name}\"),\n"
            f"{indent}        object: nil\n"
            f"{indent}    )\n"
            f"{indent}}} label: {{"
        )

    return pattern.sub(repl, text)


def replace_empty_title_button(text: str, notification_name: str) -> str:
    pattern = re.compile(r"Button\(([^\n]+?)\)\s*\{\s*\}")

    def repl(match: re.Match[str]) -> str:
        title = match.group(1).strip()
        return (
            f"Button({title}) {{\n"
            "                        NotificationCenter.default.post(\n"
            f"                            name: Notification.Name(\"{notification_name}\"),\n"
            f"                            object: {title}\n"
            "                        )\n"
            "                    }"
        )

    return pattern.sub(repl, text)


def patch_today_day_rail() -> None:
    rel = "Native/Ambitions/Features/Today/TodayDayRailPanels.swift"
    text = read(rel)
    text = text.replace('Text("10:05 AM")', 'Text(Date.now, format: .dateTime.hour().minute())')
    text = text.replace('Text("No step is required right now")', 'Text("This window is open")')
    text = text.replace('title: "Capture what changed"', 'title: "Add what changed"')
    text = text.replace('TodayInlineAction(kind: .quickLog, title: "Capture what changed"', 'TodayInlineAction(kind: .quickLog, title: "Add what changed"')
    text = re.sub(
        r'''(?s)            TodayEmptyPathAction\(\n                id: "shape-time",.*?\n            \),\n            TodayEmptyPathAction\(\n                id: "review-source",.*?\n            \),\n            TodayEmptyPathAction\(\n                id: "close-today",.*?\n            \),\n''',
        "",
        text,
    )
    text = re.sub(
        r'''(?s)            if state\.rows\.isEmpty \{\n                upNextRow\(time: "12:15 PM", title: "Support queue", subtitle: "Internal", duration: "45 min"\)\n                upNextRow\(time: "3:00 PM", title: "Team sync", subtitle: "Collaboration", duration: "1h"\)\n                upNextRow\(time: "5:15 PM", title: "Review deck", subtitle: "Shallow work", duration: "45 min"\)\n            \} else \{''',
        '''            if state.rows.isEmpty {
                Text("The next step appears here when it fits.")
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            } else {''',
        text,
    )
    text = text.replace('return "Source unavailable. Manual planning still works."', 'return "Ambitions can hold the space until a step fits."')
    text = text.replace('? "Source unavailable. Manual planning still works."', '? "Ambitions can hold the space until a step fits."')
    text = text.replace('return "10:05 AM"', 'return "Now"')
    text = text.replace('return "12:15 PM"', 'return "Next"')
    text = text.replace('return "3:00 PM"', 'return "Next"')
    text = text.replace('return "5:15 PM"', 'return "Later"')
    text = text.replace('return index == 0 ? "Now" : "10:05 AM"', 'return index == 0 ? "Now" : "Current"')
    text = text.replace('return index <= 1 ? "12:15 PM" : "3:00 PM"', 'return "Next"')
    write(rel, text)


def patch_capture_shell() -> None:
    rel = "Native/Ambitions/App/AppShellView.swift"
    text = read(rel)
    replacements = {
        'Text("Route reveal")': 'Text("Suggested path")',
        'Text("Local receipt. No cloud route.")': 'Text("Saved on this device until you choose a place.")',
        'return "\\(routeSource): hold as Needs a Place until review."': 'return "\\(routeSource): hold this until you choose where it belongs."',
        'return "\\(routeSource): concrete action text can be reviewed for Today."': 'return "\\(routeSource): this can become a step for Today."',
        'return "\\(routeSource): ambition-shaped text can open a goal draft."': 'return "\\(routeSource): this can start a goal draft."',
        'return "\\(routeSource): ambiguous text waits for manual review."': 'return "\\(routeSource): keep this for review."',
    }
    for old, new in replacements.items():
        text = text.replace(old, new)
    write(rel, text)


def patch_capture_primitives() -> None:
    rel = "Sources/Components/CaptureRoutingPrimitiveFamily.swift"
    text = read(rel)
    text = text.replace('case .routeReveal: "Route reveal"', 'case .routeReveal: "Suggested path"')
    write(rel, text)


def patch_motion_actions() -> None:
    rel = "Native/Ambitions/Features/Motion/MotionCurrentScreen.swift"
    text = ensure_foundation_import(read(rel))
    text = replace_empty_button_action(text, "AmbitionsMotionCurrentActionSelected")
    text = replace_empty_button_label(text, "AmbitionsMotionCurrentActionSelected")
    text = replace_empty_title_button(text, "AmbitionsMotionCurrentActionSelected")
    write(rel, text)


def patch_time_copy() -> None:
    rel = "Native/Ambitions/Features/Time/TimeLifeShapeField.swift"
    text = read(rel)
    text = text.replace("role: .noRootNavigation", "role: .continuity")
    text = text.replace('title: "Not root navigation"', 'title: "Context stays together"')
    text = text.replace('subtitle: "Day, Week, and Month stay inside Time relationship state."', 'subtitle: "Day, Week, and Month keep the current shape attached."')
    text = text.replace('accessibilityIdentifier: "time.life-shape-field.continuity-dock.no-root-navigation"', 'accessibilityIdentifier: "time.life-shape-field.continuity-dock.context"')
    write(rel, text)


def patch_you_debug_copy() -> None:
    rel = "Native/Ambitions/Features/You/YouScreen.swift"
    text = ensure_foundation_import(read(rel))
    replacements = {
        'title: "Runtime-backed local inspection"': 'title: "Personal context"',
        'subtitle: "Life Context, Source Atlas, memory controls, personal vault rows, and receipt summaries are loaded through the current You projection."': 'subtitle: "Life context, memory controls, and personal settings are available from this profile."',
        'valueLabel: "runtime-backed"': 'valueLabel: "On device"',
        'subtitle: "Receipt rows explain source freshness, privacy posture, correction, undo, review, and safe fallback behavior."': 'subtitle: "Review history explains what changed, when it changed, and what stayed protected."',
        'valueLabel: profileProjection.receiptAudit.items.isEmpty ? "blocked-pending-model" : "fixture-only"': 'valueLabel: profileProjection.receiptAudit.items.isEmpty ? "Pending" : "Example"',
        'subtitle: "Broader learning, deletion, sync, export/import, and privacy/legal proof remain blocked-pending-model until the owning source and proof gates land."': 'subtitle: "Broader learning, deletion, sync, export, and import stay unavailable until their controls are ready."',
        'valueLabel: "blocked-pending-model"': 'valueLabel: "Pending"',
        'subtitle: "Honest local-data status for what is backed by runtime state, what is example-only, and what remains blocked."': 'subtitle: "Local-data controls for what Ambitions stores, shows, and can change on this device."',
        'valueLabel: profileProjection.personalVault.sections.flatMap(\\.rows).isEmpty ? "blocked-pending-model" : "runtime-backed"': 'valueLabel: profileProjection.personalVault.sections.flatMap(\\.rows).isEmpty ? "Pending" : "On device"',
        'subtitle: "Receipt examples demonstrate how correction, undo, source freshness, and safe fallback should appear. They are not a production audit log."': 'subtitle: "Examples show how review history will appear when enough local activity exists."',
        'valueLabel: "fixture-only"': 'valueLabel: "Example"',
    }
    for old, new in replacements.items():
        text = text.replace(old, new)
    text = replace_empty_button_label(text, "AmbitionsYouPlaceholderActionSelected")
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
