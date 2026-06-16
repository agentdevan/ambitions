#!/usr/bin/env python3
from __future__ import annotations

from report_reconstruction_support import read, require_markers, write, write_proof

MOTION = "Native/Ambitions/Features/Motion/MotionCurrentScreen.swift"


def replace_once(text: str, before: str, after: str, label: str) -> str:
    if before not in text:
        raise RuntimeError(f"Missing marker for {label}")
    return text.replace(before, after, 1)


def main() -> int:
    text = read(MOTION)
    text = replace_once(
        text,
        "                MotionCurrentField(state: projection.field, lanes: projection.lanes, reduceMotion: reduceMotion)\n                MotionContextCrown(state: projection.crown)\n                Color.clear\n                    .frame(height: theme.spacing.xxl)\n                    .allowsHitTesting(false)\n                    .accessibilityHidden(true)\n                MotionLaneCluster(lanes: projection.lanes)\n                MotionSourceReceiptAffordance(state: projection.affordance)\n                MotionContinuityDock(actions: projection.dockActions)\n",
        "                MotionContextCrown(state: projection.crown)\n                MotionCurrentField(state: projection.field, lanes: projection.lanes, reduceMotion: reduceMotion)\n                MotionReentryPrompt()\n                MotionLaneCluster(lanes: projection.lanes)\n                MotionSourceReceiptAffordance(state: projection.affordance)\n                MotionContinuityDock(actions: projection.dockActions)\n",
        "Motion first viewport order",
    )
    if "private struct MotionReentryPrompt" not in text:
        text = replace_once(
            text,
            "private struct MotionContextCrown: View {\n",
            "private struct MotionReentryPrompt: View {\n    @Environment(\\.ambitionTheme) private var theme\n\n    var body: some View {\n        HStack(alignment: .center, spacing: theme.spacing.sm) {\n            Image(systemName: \"arrow.uturn.forward.circle\")\n                .font(.system(size: theme.icon.mediumSize, weight: .semibold))\n                .foregroundStyle(theme.colors.accentWarm)\n            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {\n                Text(\"Re-enter from here\")\n                    .font(theme.typography.caption.weight(.semibold))\n                    .foregroundStyle(theme.colors.textPrimary)\n                Text(\"Motion shows what changed, where to return, and what needs recovery.\")\n                    .font(theme.typography.caption)\n                    .foregroundStyle(theme.colors.textSecondary)\n                    .fixedSize(horizontal: false, vertical: true)\n            }\n        }\n        .padding(.vertical, theme.spacing.xs)\n        .accessibilityElement(children: .combine)\n        .accessibilityIdentifier(\"motion.reentry.prompt\")\n    }\n}\n\nprivate struct MotionContextCrown: View {\n",
            "Motion reentry prompt helper",
        )
    text = text.replace(
        "Full-bleed Motion Current object stage with inline proof, recovery, re-entry, source, proof, receipt relationships, and a visible re-entry action.",
        "Full-bleed Motion Current object stage with what changed, where to re-enter, what needs recovery, and inspectable proof relationships.",
    )
    write(MOTION, text)

    require_markers(MOTION, ["MotionReentryPrompt", "Re-enter from here", "motion.reentry.prompt", "what changed", "where to re-enter"])

    write_proof(
        "REPORT_BATCH_41_MOTION_REENTRY_VISUAL_REBUILD.md",
        """
# Batch 41 — Motion Re-entry Visual Rebuild

Status: applied.

Scope:
- Reordered Motion so context comes before proof-field texture.
- Added a visible re-entry prompt that states what Motion does.
- Reframed Motion contract around what changed, where to re-enter, and what needs recovery.

Native interaction law:
- Motion Current is a re-entry/recovery/proof object, not analytics or a static ledger.

Validation:
- Source markers prove the re-entry prompt exists.
- Xcode build remains the blocking gate.
""",
    )
    print("Applied Batch 41 Motion Re-entry Visual Rebuild.")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
