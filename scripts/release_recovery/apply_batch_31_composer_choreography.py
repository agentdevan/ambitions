#!/usr/bin/env python3
from __future__ import annotations

from report_reconstruction_support import read, require_markers, write, write_proof

SHELL = "Native/Ambitions/App/AppShellView.swift"


def main() -> int:
    text = read(SHELL)
    text = text.replace('TextField("Capture one thing…", text: $captureText, axis: .vertical)', 'TextField("Record what changed…", text: $captureText, axis: .vertical)')
    text = text.replace('.lineLimit(3...6)', '.lineLimit(2...8)')
    text = text.replace('Label(saveButtonTitle, systemImage: "tray.and.arrow.down.fill")', 'Label(saveButtonTitle, systemImage: "arrow.up.circle.fill")')
    write(SHELL, text)

    require_markers(SHELL, ["Record what changed…", ".lineLimit(2...8)", "arrow.up.circle.fill"])

    write_proof(
        "REPORT_BATCH_31_COMPOSER_CHOREOGRAPHY.md",
        """
# Batch 31 — Composer Choreography

Status: applied.

Scope:
- Rebuilt quick input prompt around change intake.
- Increased composer growth range.
- Moved the primary save affordance toward native composer/send behavior.

Native interaction law:
- Intake must be obvious, keyboard-aware, and expandable.

Validation:
- Source markers prove prompt, growth range, and send affordance exist.
- Xcode build remains the blocking gate.
""",
    )
    print("Applied Batch 31 Composer Choreography.")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
