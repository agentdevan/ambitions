#!/usr/bin/env python3
from __future__ import annotations

from report_reconstruction_support import read, require_markers, write, write_proof

SHELL = "Native/Ambitions/App/AppShellView.swift"
ROOT = "Native/Ambitions/App/AmbitionsRootView.swift"


def main() -> int:
    shell = read(SHELL)
    shell = shell.replace(
        '.background(Circle().fill(theme.colors.surfaceOverlay))\n                    .overlay(Circle().stroke(theme.colors.strokeSubtle, lineWidth: 1))',
        '.contentShape(Circle())',
    )
    shell = shell.replace(
        'Label("Actions", systemImage: "ellipsis.circle")',
        'Label("Actions", systemImage: "ellipsis")',
    )
    shell = shell.replace(
        'onBack == nil ? .clear : theme.depth.resting.color',
        '.clear',
    )
    shell = shell.replace(
        'onBack == nil ? 0 : (theme.mode == .dark ? 14 : 10)',
        '0',
    )
    shell = shell.replace(
        'return AnyShapeStyle(theme.shell.headerMaterial)',
        'return AnyShapeStyle(theme.colors.canvas.opacity(theme.mode == .dark ? 0.46 : 0.34))',
    )
    shell = shell.replace(
        'return theme.spacing.lg + theme.spacing.lg + theme.spacing.lg',
        'return dynamicTypeSize.isAccessibilitySize ? theme.spacing.xl : theme.spacing.lg',
    )
    write(SHELL, shell)

    root = read(ROOT)
    root = root.replace('subtitle: "Control",', 'subtitle: "Profile and settings",')
    root = root.replace('subtitle: "Open Field",', 'subtitle: "Composer",')
    write(ROOT, root)

    require_markers(SHELL, ["contentShape(Circle())", "Label(\"Actions\", systemImage: \"ellipsis\")", "return AnyShapeStyle(theme.colors.canvas.opacity"])
    require_markers(ROOT, ["Profile and settings", "Composer"])

    write_proof(
        "REPORT_BATCH_37_SHELL_NATIVE_CHROME_REBUILD.md",
        """
# Batch 37 — Shell Native Chrome Rebuild

Status: applied.

Scope:
- Removed hard circular border/background treatment from drilldown back control.
- Converted action cluster symbol to a quieter native ellipsis.
- Removed header shadow for focused drilldowns.
- Reworked drilldown header material to a quieter canvas-integrated surface.
- Tightened drilldown top clearance.
- Renamed You shell subtitle to Profile and settings and Capture drilldown subtitle to Composer.

Native interaction law:
- Root shell chrome should support the object, not frame the whole app like a dashboard.
- Drilldowns should feel native, focused, and free of root chrome clutter.

Validation:
- Source markers prove borderless back control, quiet action symbol, and shell copy updates exist.
- Xcode build remains the blocking gate.
""",
    )
    print("Applied Batch 37 Shell Native Chrome Rebuild.")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
