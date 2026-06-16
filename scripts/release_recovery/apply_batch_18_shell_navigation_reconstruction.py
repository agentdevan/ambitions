#!/usr/bin/env python3
from __future__ import annotations

from report_reconstruction_support import read, replace_all, require_markers, write, write_proof

SHELL = "Native/Ambitions/App/AppMeridianShell.swift"
ROOT = "Native/Ambitions/App/AmbitionsRootView.swift"


def main() -> int:
    shell = read(SHELL)
    shell = replace_all(shell, {
        "theme.colors.surfacePrimary.opacity(theme.mode == .dark ? 0.96 : 0.94)": "AmbitionsIOS26SemanticTokens.LiquidGlass.darkDockCore.opacity(theme.mode == .dark ? 0.72 : 0.58)",
        "theme.shell.bottomBarMaterial.opacity(theme.mode == .dark ? 0.26 : 0.18)": "AmbitionsIOS26SemanticTokens.LiquidGlass.darkDockBase.opacity(theme.mode == .dark ? 0.38 : 0.24)",
        "theme.shell.divider.opacity(0.56)": "AmbitionsIOS26SemanticTokens.Separator.darkNonOpaque.opacity(0.42)",
        "theme.colors.textPrimary.opacity(theme.mode == .dark ? 0.08 : 0.10)": "theme.colors.textPrimary.opacity(theme.mode == .dark ? 0.035 : 0.06)",
        "theme.depth.resting.color.opacity(theme.mode == .dark ? 0.82 : 0.36)": "theme.depth.resting.color.opacity(theme.mode == .dark ? 0.28 : 0.18)",
        "let iconSize: CGFloat = accessibilityCompact ? (isSelected ? 15 : 14) : (isSelected ? 20 : 19)": "let iconSize: CGFloat = accessibilityCompact ? (isSelected ? 14 : 13) : (isSelected ? 18 : 17)",
        "width: accessibilityCompact ? 24 : 32,\n            height: accessibilityCompact ? 22 : 28": "width: accessibilityCompact ? 24 : 30,\n            height: accessibilityCompact ? 22 : 26",
        "theme.colors.accentWarm.opacity(theme.mode == .dark ? 0.24 : 0.15)": "theme.colors.accentWarm.opacity(theme.mode == .dark ? 0.070 : 0.055)",
        "theme.colors.accentPrimary.opacity(theme.mode == .dark ? 0.12 : 0.08)": "theme.colors.accentPrimary.opacity(theme.mode == .dark ? 0.045 : 0.035)",
        "theme.colors.canvasElevated.opacity(0.10)": "theme.colors.canvasElevated.opacity(0.025)",
        "theme.colors.accentWarm.opacity(theme.mode == .dark ? 0.36 : 0.22)": "theme.colors.accentWarm.opacity(theme.mode == .dark ? 0.14 : 0.10)",
    })
    old_circle = '''if isSelected {
                        Circle()
                            .fill(theme.colors.accentWarm.opacity(theme.mode == .dark ? 0.20 : 0.14))
                            .overlay(
                                Circle()
                                    .stroke(theme.colors.accentWarm.opacity(theme.mode == .dark ? 0.34 : 0.24), lineWidth: 1)
                            )
                    }'''
    new_mark = '''if isSelected {
                        Capsule(style: .continuous)
                            .fill(theme.shell.activeTabForeground.opacity(theme.mode == .dark ? 0.78 : 0.64))
                            .frame(width: accessibilityCompact ? 14 : 18, height: 2)
                            .offset(y: accessibilityCompact ? 15 : 18)
                            .accessibilityHidden(true)
                    }'''
    shell = shell.replace(old_circle, new_mark)
    if "import AmbitionsDesignSystem\nimport SwiftUI" in shell and "AmbitionsIOS26SemanticTokens" not in shell:
        raise RuntimeError("shell token markers missing after patch")
    write(SHELL, shell)

    root = read(ROOT)
    root = replace_all(root, {
        ".opacity(theme.mode == .dark ? 0.42 : 0.34)": ".opacity(theme.mode == .dark ? 0.24 : 0.18)",
        ".opacity(theme.mode == .dark ? 0.70 : 0.58)": ".opacity(theme.mode == .dark ? 0.44 : 0.36)",
        "private var shellDockClearance: CGFloat {\n        dynamicTypeSize.isAccessibilitySize ? 156 : 152\n    }": "private var shellDockClearance: CGFloat {\n        dynamicTypeSize.isAccessibilitySize ? 184 : 164\n    }",
        "private func shellDockClearance(theme: AmbitionTheme) -> CGFloat {\n        dynamicTypeSize.isAccessibilitySize ? 156 : 152\n    }": "private func shellDockClearance(theme: AmbitionTheme) -> CGFloat {\n        dynamicTypeSize.isAccessibilitySize ? 184 : 164\n    }",
    })
    write(ROOT, root)

    require_markers(SHELL, ["AmbitionsIOS26SemanticTokens.LiquidGlass.darkDockCore", "Capsule(style: .continuous)", "accessibilityIdentifier(destination.accessibilityIdentifier)"])
    root_text = read(ROOT)
    if "dynamicTypeSize.isAccessibilitySize ? 184 : 164" not in root_text:
        raise RuntimeError("shell dock clearance marker missing after root patch")
    write_proof(
        "REPORT_BATCH_18_SHELL_NAVIGATION.md",
        """
# Batch 18 — Shell/navigation reconstruction

Status: applied.

Scope:
- Rebased floating destination rail material on the Ambitions iOS 26 semantic bridge.
- Reduced visible rail opacity, strokes, shadow, and selected-tab chrome.
- Replaced the selected icon glow circle with a restrained under-glyph mark.
- Increased shared bottom shell clearance for root content.

Atlas gates:
- Native TabView remains semantic routing spine.
- Capture remains global and not a tab.
- Floating rail is the only visible root navigation affordance.
- Active tab treatment is restrained and iOS-native.
""",
    )
    print("Applied Batch 18 Shell/navigation reconstruction.")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
