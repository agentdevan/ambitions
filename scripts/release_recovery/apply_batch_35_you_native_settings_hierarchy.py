#!/usr/bin/env python3
from __future__ import annotations

from report_reconstruction_support import read, require_markers, write, write_proof

YOU = "Native/Ambitions/Features/You/YouScreen.swift"


def main() -> int:
    text = read(YOU)
    text = text.replace('title: "trust-automation", .automationTrust', 'title: "privacy-automation", .automationTrust')
    text = text.replace('"trust-automation": .automationTrust', '"privacy-automation": .automationTrust')
    text = text.replace('"personal-runtime": .personalRuntime', '"personal-system": .personalRuntime')
    text = text.replace('subtitle: "Control"', 'subtitle: "Profile and settings"')
    text = text.replace('PersonalSystemCenterRootView(', 'PersonalSystemCenterRootView(')
    write(YOU, text)

    require_markers(YOU, ["Profile and settings", "privacy-automation", "personal-system", "receipts-history"])

    write_proof(
        "REPORT_BATCH_35_YOU_NATIVE_SETTINGS_HIERARCHY.md",
        """
# Batch 35 — You Native Settings Hierarchy

Status: applied.

Scope:
- Reframed You routing around profile/settings language.
- Moved screenshot detail identifiers away from runtime/manual language.
- Preserved existing sheets and native grouped controls.

Native interaction law:
- Settings becomes You.
- You must feel like profile, command center, privacy, appearance, defaults, permissions, and history.

Validation:
- Source markers prove profile/settings detail route language exists.
- Xcode build remains the blocking gate.
""",
    )
    print("Applied Batch 35 You Native Settings Hierarchy.")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
