#!/usr/bin/env python3
from __future__ import annotations

from report_reconstruction_support import read, require_markers, write, write_proof

YOU = "Native/Ambitions/Features/You/YouRootSurface.swift"


def main() -> int:
    text = read(YOU)
    text = text.replace('Text("Ambitions runs on this iPhone")', 'Text("Local-first personal system")')
    text = text.replace('title: "Planning Setup"', 'title: "Planning defaults"')
    text = text.replace('title: "Preferences"', 'title: "Appearance & notifications"')
    text = text.replace('title: "Privacy & Trust"', 'title: "Privacy & security"')
    text = text.replace('title: "App"', 'title: "Help & about"')
    text = text.replace('title: "Capture Preferences"', 'title: "Capture"')
    text = text.replace('title: "Source Settings"', 'title: "Sources & permissions"')
    text = text.replace('title: "Local Data Controls"', 'title: "Local data"')
    text = text.replace('title: "About Ambitions"', 'title: "About"')
    write(YOU, text)

    require_markers(YOU, ["Local-first personal system", "Planning defaults", "Appearance & notifications", "Privacy & security", "Sources & permissions", "Help & about"])

    write_proof(
        "REPORT_BATCH_40_YOU_SETTINGS_STUDIO_REBUILD.md",
        """
# Batch 40 — You Settings Studio Rebuild

Status: applied.

Scope:
- Rebuilt top-level You section language toward native profile/settings hierarchy.
- Added clearer Planning defaults, Appearance & notifications, Privacy & security, Sources & permissions, Local data, Help & about group names.
- Reduced runtime-manual posture by reframing the header as a local-first personal system.

Native interaction law:
- Settings becomes You.
- You is profile, command center, privacy, appearance, defaults, permissions, and history.

Validation:
- Source markers prove the settings hierarchy language exists.
- Xcode build remains the blocking gate.
""",
    )
    print("Applied Batch 40 You Settings Studio Rebuild.")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
