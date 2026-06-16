#!/usr/bin/env python3
from __future__ import annotations
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
ROOT_VIEW = ROOT / "Native/Ambitions/App/AmbitionsRootView.swift"
SHELL = ROOT / "Native/Ambitions/App/AppShellView.swift"


def main() -> int:
    root = ROOT_VIEW.read_text(encoding="utf-8")
    root = root.replace("theme.colors.canvas.opacity(theme.mode == .dark ? 0.98 : 0.94)", "theme.colors.canvas.opacity(theme.mode == .dark ? 0.42 : 0.34)")
    root = root.replace("theme.colors.canvas.opacity(1.0)", "theme.colors.canvas.opacity(theme.mode == .dark ? 0.70 : 0.58)")
    root = root.replace("dynamicTypeSize.isAccessibilitySize ? 112 : 124", "dynamicTypeSize.isAccessibilitySize ? 156 : 152")
    ROOT_VIEW.write_text(root, encoding="utf-8")

    shell = SHELL.read_text(encoding="utf-8")
    shell = shell.replace(".fill(theme.shell.divider)\n            .frame(height: 1)", ".fill(Color.clear)\n            .frame(height: 0)")
    shell = shell.replace("theme.colors.canvas.opacity(theme.mode == .dark ? 0.96 : 0.92)", "theme.colors.canvas.opacity(theme.mode == .dark ? 0.28 : 0.22)")
    shell = shell.replace("dynamicTypeSize.isAccessibilitySize ? 128 : 124", "dynamicTypeSize.isAccessibilitySize ? 180 : 164")
    SHELL.write_text(shell, encoding="utf-8")

    root = ROOT_VIEW.read_text(encoding="utf-8")
    shell = SHELL.read_text(encoding="utf-8")
    for marker in ["? 156 : 152", "? 0.70 : 0.58"]:
        if marker not in root:
            raise RuntimeError(f"root shell marker missing: {marker}")
    for marker in [".frame(height: 0)", "? 180 : 164", "? 0.28 : 0.22"]:
        if marker not in shell:
            raise RuntimeError(f"shell marker missing: {marker}")
    print("Applied Batch 14 report shell nav repair.")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
