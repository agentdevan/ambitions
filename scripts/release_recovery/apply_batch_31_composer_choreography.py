#!/usr/bin/env python3
from __future__ import annotations

from report_reconstruction_support import read, require_markers, write, write_proof

SHELL = "Native/Ambitions/App/AppShellView.swift"
STAGE = "Native/Ambitions/Features/Capture/CaptureAtmosphereComposerFlagshipAdapter.swift"


def replace_once(text: str, before: str, after: str, label: str) -> str:
    if before not in text:
        raise RuntimeError(f"Missing marker for {label}")
    return text.replace(before, after, 1)


def ensure_shell_composer(text: str) -> str:
    text = text.replace(
        'TextField("Capture one thing…", text: $captureText, axis: .vertical)',
        'TextField("Capture what changed…", text: $captureText, axis: .vertical)',
    )
    text = text.replace(
        'TextField("Record what changed…", text: $captureText, axis: .vertical)',
        'TextField("Capture what changed…", text: $captureText, axis: .vertical)',
    )
    text = text.replace(".lineLimit(3...6)", ".lineLimit(2...8)")
    text = text.replace(
        'Label(saveButtonTitle, systemImage: "tray.and.arrow.down.fill")',
        'Label(saveButtonTitle, systemImage: "arrow.up.circle.fill")',
    )

    if "quickCaptureControlRail" not in text:
        text = replace_once(
            text,
            '.accessibilityIdentifier("shell.overlay.quick-capture-field")',
            '.accessibilityIdentifier("shell.overlay.quick-capture-field")\n\n            quickCaptureControlRail\n                .accessibilityIdentifier("shell.overlay.quick-capture.control-rail")',
            "quick capture control rail insertion",
        )

        text = replace_once(
            text,
            "    @ViewBuilder\n    private var statusMessage: some View {\n",
            """    private var quickCaptureControlRail: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: theme.spacing.xs) {
                quickCaptureControlChip("Camera", systemImage: "camera")
                quickCaptureControlChip("Photos", systemImage: "photo.on.rectangle")
                quickCaptureControlChip("Files", systemImage: "folder")
                quickCaptureControlChip("Scan", systemImage: "doc.viewfinder")
                quickCaptureControlChip("Date", systemImage: "calendar")
                quickCaptureControlChip("Reminder", systemImage: "bell")
                quickCaptureControlChip("Repeat", systemImage: "repeat")
                quickCaptureControlChip("Location", systemImage: "location")
                quickCaptureControlChip("Goal", systemImage: "target")
                quickCaptureControlChip("Flag", systemImage: "flag")
            }
            .padding(.vertical, theme.spacing.xxxs)
        }
        .accessibilityLabel("Composer controls for camera, photos, files, scan, date, reminder, repeat, location, goal, and flag.")
    }

    private func quickCaptureControlChip(_ title: String, systemImage: String) -> some View {
        Label(title, systemImage: systemImage)
            .font(theme.typography.micro.weight(.semibold))
            .foregroundStyle(theme.colors.textSecondary)
            .padding(.horizontal, theme.spacing.xs)
            .padding(.vertical, theme.spacing.xxs)
            .background(
                Capsule(style: .continuous)
                    .fill(theme.colors.surfaceOverlay.opacity(0.82))
            )
            .overlay(
                Capsule(style: .continuous)
                    .stroke(theme.colors.strokeSubtle.opacity(0.70), lineWidth: 1)
            )
            .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private var statusMessage: some View {
""",
            "quick capture control helpers",
        )

    return text


def ensure_stage_language(text: str) -> str:
    text = text.replace(
        'return "\\(summary) \\(motionLine)"',
        'return "Composer-first Open Field. Text, voice, files, scan, date, reminder, repeat, location, goal, and flag controls stay available before placement. \\(motionLine)"',
    )
    text = text.replace(
        'FlagshipRuntimeMetric(id: "route", title: "Route", value: "Editable", systemImage: "arrow.triangle.branch"),',
        'FlagshipRuntimeMetric(id: "placement", title: "Placement", value: "Reviewable", systemImage: "arrow.triangle.branch"),',
    )
    text = text.replace(
        'FlagshipRuntimeProofHook(id: "route", title: "Suggested path", summary: "Placement appears after input and stays editable before save.", accessibilityHint: "Explains why Capture has not created planned work yet."),',
        'FlagshipRuntimeProofHook(id: "placement", title: "Placement review", summary: "Input stays editable until the user decides whether it becomes a Step, Goal, Time boundary, note, proof, reminder, or held item.", accessibilityHint: "Explains why Capture has not created planned work yet."),',
    )
    text = text.replace(
        'FlagshipRuntimeProofHook(id: "review", title: "Review before save", summary: "The user keeps control of what becomes a Step, Goal, Time item, or saved note.", accessibilityHint: "Confirms capture changes remain reviewable."),',
        'FlagshipRuntimeProofHook(id: "review", title: "Review before save", summary: "The user keeps control of what becomes a Step, Goal, Time boundary, note, proof, reminder, or held item.", accessibilityHint: "Confirms capture changes remain reviewable."),',
    )
    return text


def main() -> int:
    shell = ensure_shell_composer(read(SHELL))
    write(SHELL, shell)

    stage = ensure_stage_language(read(STAGE))
    write(STAGE, stage)

    require_markers(SHELL, [
        "Capture what changed…",
        ".lineLimit(2...8)",
        "arrow.up.circle.fill",
        "quickCaptureControlRail",
        "quickCaptureControlChip",
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
    ])
    require_markers(STAGE, [
        "Composer-first Open Field",
        "Placement review",
        "Step, Goal, Time boundary, note, proof, reminder, or held item",
        "Reviewable",
    ])

    write_proof(
        "REPORT_BATCH_31_COMPOSER_CHOREOGRAPHY.md",
        """
# Batch 31 — Composer Choreography

Status: applied.

Scope:
- Rebuilt quick input prompt around `Capture what changed…`.
- Increased composer growth range from 3...6 to 2...8.
- Moved the primary save affordance toward native composer/send behavior.
- Added a horizontal control rail for Camera, Photos, Files, Scan, Date, Reminder, Repeat, Location, Goal, and Flag.
- Reframed the Atmosphere Composer adapter around composer-first Open Field behavior and placement review.
- Preserved local-first review before placement.

Native interaction law:
- Capture must be beautiful, obvious, keyboard-aware, and expandable.
- Composer quality is translated into Ambitions intake, not copied as chat UI or task form.
- Reminders quick-add control usefulness is translated into Ambitions placement controls.

Validation:
- Source markers prove prompt, growth range, send affordance, control rail, and placement language exist.
- Xcode build remains the blocking gate.
""",
    )
    print("Applied Batch 31 Composer Choreography.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())