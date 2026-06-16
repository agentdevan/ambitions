#!/usr/bin/env python3
from __future__ import annotations
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SHELL = ROOT / "Native/Ambitions/App/AppShellView.swift"
CAPTURE = ROOT / "Native/Ambitions/Features/Capture/CaptureScreen.swift"
ADAPTER = ROOT / "Native/Ambitions/Features/Capture/CaptureAtmosphereComposerFlagshipAdapter.swift"


def replace_once(text: str, old: str, new: str) -> str:
    if new in text:
        return text
    if old not in text:
        raise RuntimeError(f"anchor missing: {old[:80]}")
    return text.replace(old, new, 1)


def main() -> int:
    text = SHELL.read_text(encoding="utf-8")
    text = replace_once(
        text,
        ".presentationDetents(overlay.kind == .memoryLens ? [.height(560), .large] : [.medium, .large])",
        ".presentationDetents(overlay.kind == .memoryLens ? [.height(560), .large] : [.large])",
    )
    text = replace_once(
        text,
        "case .quickCapture: \"Save what needs placement with a local receipt.\"",
        "case .quickCapture: \"Write one thing. Save it here, place it when ready.\"",
    )
    text = text.replace("Button(\"Make Goal\")", "Button(\"Open as Goal\")")
    text = text.replace("saveState = .saved(\"Saved to Capture. Nothing else changed.\")", "saveState = .saved(\"Saved. Place it when ready.\")")
    SHELL.write_text(text, encoding="utf-8")

    shell_text = SHELL.read_text(encoding="utf-8")
    capture_text = CAPTURE.read_text(encoding="utf-8")
    adapter_text = ADAPTER.read_text(encoding="utf-8")
    for marker in [".presentationDetents(overlay.kind == .memoryLens ? [.height(560), .large] : [.large])", "Write one thing. Save it here, place it when ready.", "shell.activated-capture.dictation-button", "Open as Goal"]:
        if marker not in shell_text:
            raise RuntimeError(f"capture repair marker missing: {marker}")
    if "flagshipCaptureComposerStage" not in capture_text:
        raise RuntimeError("capture screen is not wired to the flagship composer stage")
    for marker in ["CaptureAtmosphereComposerFlagshipAdapter", "capture.flagship.atmosphere-composer", "accessibilityReduceMotion", "dynamicTypeSize"]:
        if marker not in adapter_text:
            raise RuntimeError(f"capture adapter marker missing: {marker}")
    print("Applied Batch 12 report Capture repair.")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
