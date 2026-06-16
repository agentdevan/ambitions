#!/usr/bin/env python3
from __future__ import annotations

from report_reconstruction_support import read, require_markers, write, write_proof

ROOT = "Native/Ambitions/App/AmbitionsRootView.swift"
NAV = "Native/Ambitions/App/AppNavigation.swift"
SHELL = "Native/Ambitions/App/AppShellView.swift"


def replace_once(text: str, before: str, after: str, label: str) -> str:
    if before not in text:
        raise RuntimeError(f"Missing marker for {label}")
    return text.replace(before, after, 1)


def main() -> int:
    nav = read(NAV)
    if "var hasRootNavigationChrome: Bool" not in nav:
        nav = replace_once(
            nav,
            "    var isActivatedCaptureComposerVisible: Bool {\n        activeOverlay?.isActivatedCaptureComposer == true\n    }\n",
            "    var isActivatedCaptureComposerVisible: Bool {\n        activeOverlay?.isActivatedCaptureComposer == true\n    }\n\n    var isInFocusedDrilldown: Bool {\n        goalsPath.isEmpty == false || timePath.isEmpty == false || youPath.isEmpty == false\n    }\n\n    var hasRootNavigationChrome: Bool {\n        isInFocusedDrilldown == false && isActivatedCaptureComposerVisible == false\n    }\n",
            "navigation root/detail chrome state",
        )
        write(NAV, nav)

    root = read(ROOT)
    root = replace_once(
        root,
        "            shellTabView(theme: resolvedTheme)\n            shellDockBackdrop(theme: resolvedTheme)\n                .zIndex(2)\n            shellVisibleDock(theme: resolvedTheme)\n                .zIndex(3)\n            shellActivatedCaptureComposerSeam(theme: resolvedTheme)\n            shellContinuityReceipt(theme: resolvedTheme)\n",
        "            shellTabView(theme: resolvedTheme)\n            if navigation.hasRootNavigationChrome {\n                shellDockBackdrop(theme: resolvedTheme)\n                    .zIndex(2)\n                shellVisibleDock(theme: resolvedTheme)\n                    .zIndex(3)\n            }\n            shellActivatedCaptureComposerSeam(theme: resolvedTheme)\n            shellContinuityReceipt(theme: resolvedTheme)\n",
        "root shell dock visibility",
    )
    root = root.replace(
        ".offset(y: -shellDockClearance(theme: theme))",
        ".offset(y: -shellCaptureComposerClearance(theme: theme))",
    )
    root = root.replace(
        "backButtonAccessibilityIdentifier: \"shell.time.back-button\",\n                        onBack: { navigation.resetTimePath() },\n                        trailingButtons: shellUtilityButtons(for: .time)",
        "backButtonAccessibilityIdentifier: \"shell.time.back-button\",\n                        onBack: { navigation.resetTimePath() },\n                        trailingButtons: []",
    )
    root = root.replace(
        "backButtonAccessibilityIdentifier: \"shell.you.back-button\",\n                        onBack: { navigation.resetYouPath() },\n                        trailingButtons: shellUtilityButtons(for: .you)",
        "backButtonAccessibilityIdentifier: \"shell.you.back-button\",\n                        onBack: { navigation.resetYouPath() },\n                        trailingButtons: []",
    )
    if "private func shellCaptureComposerClearance(theme: AmbitionTheme) -> CGFloat" not in root:
        root = replace_once(
            root,
            "    private func shellDockClearance(theme: AmbitionTheme) -> CGFloat {\n        dynamicTypeSize.isAccessibilitySize ? 184 : 164\n    }\n",
            "    private func shellDockClearance(theme: AmbitionTheme) -> CGFloat {\n        dynamicTypeSize.isAccessibilitySize ? 184 : 164\n    }\n\n    private func shellCaptureComposerClearance(theme: AmbitionTheme) -> CGFloat {\n        navigation.hasRootNavigationChrome ? shellDockClearance(theme: theme) : (dynamicTypeSize.isAccessibilitySize ? 36 : 18)\n    }\n",
            "capture composer clearance",
        )
    write(ROOT, root)

    shell = read(SHELL)
    shell = replace_once(
        shell,
        "    private var bottomChromeClearance: CGFloat {\n        dynamicTypeSize.isAccessibilitySize ? 180 : 164\n    }\n",
        "    private var bottomChromeClearance: CGFloat {\n        if onBack != nil {\n            return dynamicTypeSize.isAccessibilitySize ? 64 : 34\n        }\n        return dynamicTypeSize.isAccessibilitySize ? 180 : 164\n    }\n",
        "drilldown bottom clearance",
    )
    shell = shell.replace(
        "Return to Today and center the next step.",
        "Return to Today and center the recommended step.",
    )
    write(SHELL, shell)

    require_markers(NAV, ["hasRootNavigationChrome", "isInFocusedDrilldown"])
    require_markers(ROOT, ["navigation.hasRootNavigationChrome", "shellCaptureComposerClearance", "trailingButtons: []"])
    require_markers(SHELL, ["if onBack != nil", "return dynamicTypeSize.isAccessibilitySize ? 64 : 34"])

    write_proof(
        "REPORT_BATCH_30_SHELL_DRILLDOWN_VISUAL_RECONSTRUCTION.md",
        """
# Batch 30 — Shell Drilldown Visual Reconstruction

Status: applied.

Scope:
- Added root-vs-drilldown shell chrome state to AppNavigationModel.
- Hid the floating root dock/backdrop whenever the user is in a focused drilldown or activated Capture composer.
- Reduced bottom safe-area clearance for drilldowns so detail screens no longer reserve root-nav space.
- Removed contextual root trailing controls from Time and You drilldown scaffolds.
- Kept root surfaces on the floating dock law: Today / Goals / Time / Motion / You only.

Native interaction law:
- Root navigation and drilldown navigation are different systems.
- Drilldowns use top-left back / gesture behavior and focused full-screen objects.
- Capture composer is allowed to own keyboard space without the root dock fighting it.

Validation:
- Source markers prove shell root chrome visibility is state-driven.
- Xcode build remains the blocking gate.
""",
    )
    print("Applied Batch 30 Shell Drilldown Visual Reconstruction.")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
