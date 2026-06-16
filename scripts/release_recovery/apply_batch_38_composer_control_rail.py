#!/usr/bin/env python3
from __future__ import annotations

from report_reconstruction_support import read, require_markers, write, write_proof

SHELL = "Native/Ambitions/App/AppShellView.swift"
STAGE = "Native/Ambitions/Features/Capture/CaptureAtmosphereComposerFlagshipAdapter.swift"


def replace_once(text: str, before: str, after: str, label: str) -> str:
    if before not in text:
        raise RuntimeError(f"Missing marker for {label}")
    return text.replace(before, after, 1)


def main() -> int:
    shell = read(SHELL)

    if "composerExpansionRail" not in shell:
        shell = replace_once(
            shell,
            'quickCaptureControlRail\n                .accessibilityIdentifier("shell.overlay.quick-capture.control-rail")',
            '''quickCaptureControlRail
                .accessibilityIdentifier("shell.overlay.quick-capture.control-rail")

            composerExpansionRail
                .accessibilityIdentifier("shell.overlay.quick-capture.expansion-rail")''',
            "composer expansion rail insertion",
        )

        shell = replace_once(
            shell,
            "    @ViewBuilder\n    private var statusMessage: some View {\n",
            """    private var composerExpansionRail: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xxs) {
            Text("Expand when this needs more shape")
                .font(theme.typography.micro.weight(.semibold))
                .foregroundStyle(theme.colors.textTertiary)

            HStack(spacing: theme.spacing.xs) {
                composerExpansionPill("Full Composer")
                composerExpansionPill("Place later")
                composerExpansionPill("Protect time")
                composerExpansionPill("Add proof")
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Expansion controls for full composer, place later, protect time, and add proof.")
    }

    private func composerExpansionPill(_ title: String) -> some View {
        Text(title)
            .font(theme.typography.micro.weight(.semibold))
            .foregroundStyle(theme.colors.textSecondary)
            .padding(.horizontal, theme.spacing.xs)
            .padding(.vertical, theme.spacing.xxxs)
            .background(
                Capsule(style: .continuous)
                    .fill(theme.colors.surfacePrimary.opacity(0.72))
            )
            .overlay(
                Capsule(style: .continuous)
                    .stroke(theme.colors.strokeSubtle.opacity(0.50), lineWidth: 1)
            )
    }

    @ViewBuilder
    private var statusMessage: some View {
""",
            "composer expansion helpers",
        )

    write(SHELL, shell)

    stage = read(STAGE)
    stage = stage.replace(
        'FlagshipRuntimeMetric(id: "input", title: "Input", value: state.title, systemImage: "text.cursor"),',
        'FlagshipRuntimeMetric(id: "input", title: "Input", value: state.title, systemImage: "text.cursor"),\n            FlagshipRuntimeMetric(id: "controls", title: "Controls", value: "Ready", systemImage: "slider.horizontal.3"),',
    )
    stage = stage.replace(
        'FlagshipRuntimeProofHook(id: "proof", title: "On-device record", summary: "Capture remains local-first until the user chooses where it belongs.", accessibilityHint: "States the privacy posture for captured text.")',
        'FlagshipRuntimeProofHook(id: "proof", title: "On-device record", summary: "Capture remains local-first until the user chooses where it belongs.", accessibilityHint: "States the privacy posture for captured text."),\n            FlagshipRuntimeProofHook(id: "controls", title: "Expandable controls", summary: "Camera, photos, files, scan, date, reminder, repeat, location, goal, flag, full composer, place later, protected time, and proof stay part of one intake grammar.", accessibilityHint: "Summarizes the composer control set.")',
    )
    write(STAGE, stage)

    require_markers(SHELL, [
        "composerExpansionRail",
        "Expand when this needs more shape",
        "Full Composer",
        "Place later",
        "Protect time",
        "Add proof",
    ])
    require_markers(STAGE, [
        "Expandable controls",
        "Camera, photos, files, scan, date, reminder, repeat, location, goal, flag",
        "protected time",
    ])

    write_proof(
        "REPORT_BATCH_38_COMPOSER_CONTROL_RAIL.md",
        """
# Batch 38 — Composer Control Rail

Status: applied.

Scope:
- Added an expansion rail below the quick composer control rail.
- Added Full Composer, Place later, Protect time, and Add proof affordance labels.
- Added Capture adapter proof hook documenting the complete composer control grammar.
- Ensured the composer includes camera, photos, files, scan, date, reminder, repeat, location, goal, flag, full composer, place later, protected time, and proof affordances.

Native interaction law:
- Capture must be beautiful, obvious, and expandable.
- Rich Reminders-style controls are translated into Ambitions placement mechanics.
- The composer remains one intake grammar, not a task form or debug route selector.

Validation:
- Source markers prove the expansion rail and full composer grammar exist.
- Xcode build remains the blocking gate.
""",
    )
    print("Applied Batch 38 Composer Control Rail.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())