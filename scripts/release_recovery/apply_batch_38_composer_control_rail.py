#!/usr/bin/env python3
from __future__ import annotations

from report_reconstruction_support import read, require_markers, write, write_proof

SHELL = "Native/Ambitions/App/AppShellView.swift"
STAGE = "Native/Ambitions/Features/Capture/CaptureAtmosphereComposerFlagshipAdapter.swift"


def replace_once(text: str, before: str, after: str, label: str) -> str:
    if before not in text:
        raise RuntimeError(f"Missing marker for {label}")
    return text.replace(before, after, 1)


def ensure_base_composer(text: str) -> str:
    text = text.replace(
        'TextField("Capture one thing…", text: $captureText, axis: .vertical)',
        'TextField("Capture what changed…", text: $captureText, axis: .vertical)',
    )
    text = text.replace(
        'TextField("Record what changed…", text: $captureText, axis: .vertical)',
        'TextField("Capture what changed…", text: $captureText, axis: .vertical)',
    )
    text = text.replace('.lineLimit(3...6)', '.lineLimit(2...8)')
    text = text.replace(
        'Label(saveButtonTitle, systemImage: "tray.and.arrow.down.fill")',
        'Label(saveButtonTitle, systemImage: "arrow.up.circle.fill")',
    )
    return text


def ensure_quick_control_rail(text: str) -> str:
    if "private var quickCaptureControlRail: some View" in text:
        return text
    text = replace_once(
        text,
        '.accessibilityIdentifier("shell.overlay.quick-capture-field")',
        '.accessibilityIdentifier("shell.overlay.quick-capture-field")\n\n            quickCaptureControlRail\n                .accessibilityIdentifier("shell.overlay.quick-capture.control-rail")',
        "quick control rail call",
    )
    return replace_once(
        text,
        "    @ViewBuilder\n    private var statusMessage: some View {\n",
        "    private var quickCaptureControlRail: some View {\n        ScrollView(.horizontal, showsIndicators: false) {\n            HStack(spacing: theme.spacing.xs) {\n                quickCaptureControlChip(\"Camera\", systemImage: \"camera\")\n                quickCaptureControlChip(\"Photos\", systemImage: \"photo.on.rectangle\")\n                quickCaptureControlChip(\"Files\", systemImage: \"folder\")\n                quickCaptureControlChip(\"Scan\", systemImage: \"doc.viewfinder\")\n                quickCaptureControlChip(\"Date\", systemImage: \"calendar\")\n                quickCaptureControlChip(\"Reminder\", systemImage: \"bell\")\n                quickCaptureControlChip(\"Repeat\", systemImage: \"repeat\")\n                quickCaptureControlChip(\"Location\", systemImage: \"location\")\n                quickCaptureControlChip(\"Goal\", systemImage: \"target\")\n                quickCaptureControlChip(\"Flag\", systemImage: \"flag\")\n            }\n            .padding(.vertical, theme.spacing.xxxs)\n        }\n        .accessibilityLabel(\"Composer controls for camera, photos, files, scan, date, reminder, repeat, location, goal, and flag.\")\n    }\n\n    private func quickCaptureControlChip(_ title: String, systemImage: String) -> some View {\n        Label(title, systemImage: systemImage)\n            .font(theme.typography.micro.weight(.semibold))\n            .foregroundStyle(theme.colors.textSecondary)\n            .padding(.horizontal, theme.spacing.xs)\n            .padding(.vertical, theme.spacing.xxs)\n            .background(Capsule(style: .continuous).fill(theme.colors.surfaceOverlay.opacity(0.82)))\n            .overlay(Capsule(style: .continuous).stroke(theme.colors.strokeSubtle.opacity(0.70), lineWidth: 1))\n            .accessibilityElement(children: .combine)\n    }\n\n    @ViewBuilder\n    private var statusMessage: some View {\n",
        "quick control rail helpers",
    )


def ensure_expansion_rail(text: str) -> str:
    if "private var composerExpansionRail: some View" in text:
        return text
    text = replace_once(
        text,
        'quickCaptureControlRail\n                .accessibilityIdentifier("shell.overlay.quick-capture.control-rail")',
        'quickCaptureControlRail\n                .accessibilityIdentifier("shell.overlay.quick-capture.control-rail")\n\n            composerExpansionRail\n                .accessibilityIdentifier("shell.overlay.quick-capture.expansion-rail")',
        "composer expansion rail call",
    )
    return replace_once(
        text,
        "    @ViewBuilder\n    private var statusMessage: some View {\n",
        "    private var composerExpansionRail: some View {\n        VStack(alignment: .leading, spacing: theme.spacing.xxs) {\n            Text(\"Expand when this needs more shape\")\n                .font(theme.typography.micro.weight(.semibold))\n                .foregroundStyle(theme.colors.textTertiary)\n\n            HStack(spacing: theme.spacing.xs) {\n                composerExpansionPill(\"Full Composer\")\n                composerExpansionPill(\"Place later\")\n                composerExpansionPill(\"Protect time\")\n                composerExpansionPill(\"Add proof\")\n            }\n        }\n        .accessibilityElement(children: .combine)\n        .accessibilityLabel(\"Expansion controls for full composer, place later, protect time, and add proof.\")\n    }\n\n    private func composerExpansionPill(_ title: String) -> some View {\n        Text(title)\n            .font(theme.typography.micro.weight(.semibold))\n            .foregroundStyle(theme.colors.textSecondary)\n            .padding(.horizontal, theme.spacing.xs)\n            .padding(.vertical, theme.spacing.xxxs)\n            .background(Capsule(style: .continuous).fill(theme.colors.surfacePrimary.opacity(0.72)))\n            .overlay(Capsule(style: .continuous).stroke(theme.colors.strokeSubtle.opacity(0.50), lineWidth: 1))\n    }\n\n    @ViewBuilder\n    private var statusMessage: some View {\n",
        "composer expansion helpers",
    )


def ensure_stage_control_hook(text: str) -> str:
    if 'FlagshipRuntimeMetric(id: "controls"' not in text:
        text = text.replace(
            'FlagshipRuntimeMetric(id: "input", title: "Input", value: state.title, systemImage: "text.cursor"),',
            'FlagshipRuntimeMetric(id: "input", title: "Input", value: state.title, systemImage: "text.cursor"),\n            FlagshipRuntimeMetric(id: "controls", title: "Controls", value: "Ready", systemImage: "slider.horizontal.3"),',
        )
    if 'FlagshipRuntimeProofHook(id: "controls"' not in text:
        text = text.replace(
            'FlagshipRuntimeProofHook(id: "proof", title: "On-device record", summary: "Capture remains local-first until the user chooses where it belongs.", accessibilityHint: "States the privacy posture for captured text.")',
            'FlagshipRuntimeProofHook(id: "proof", title: "On-device record", summary: "Capture remains local-first until the user chooses where it belongs.", accessibilityHint: "States the privacy posture for captured text."),\n            FlagshipRuntimeProofHook(id: "controls", title: "Expandable controls", summary: "Camera, photos, files, scan, date, reminder, repeat, location, goal, flag, full composer, place later, protected time, and proof stay part of one intake grammar.", accessibilityHint: "Summarizes the composer control set.")',
        )
    return text


def main() -> int:
    shell = read(SHELL)
    shell = ensure_base_composer(shell)
    shell = ensure_quick_control_rail(shell)
    shell = ensure_expansion_rail(shell)
    write(SHELL, shell)

    stage = ensure_stage_control_hook(read(STAGE))
    write(STAGE, stage)

    require_markers(SHELL, [
        "Capture what changed…",
        "quickCaptureControlRail",
        "quickCaptureControlChip",
        "composerExpansionRail",
        "Camera",
        "Photos",
        "Files",
        "Scan",
        "Date",
        "Reminder",
        "Repeat",
        "Location",
        "Goal",
        "Flag",
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
- Self-installed the base quick composer rail when prior Batch 31 output is absent.
- Added Camera, Photos, Files, Scan, Date, Reminder, Repeat, Location, Goal, and Flag affordances.
- Added expansion rail for Full Composer, Place later, Protect time, and Add proof.
- Added adapter proof hook documenting the complete composer control grammar.

Native interaction law:
- Capture must be beautiful, obvious, and expandable.
- Rich quick-add controls are translated into Ambitions placement mechanics.
- The composer remains one intake grammar, not a task form or debug route selector.

Validation:
- Source markers prove both composer rails and the full control grammar exist.
- Xcode build remains the blocking gate.
""",
    )
    print("Applied Batch 38 Composer Control Rail.")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
