#!/usr/bin/env python3
from __future__ import annotations

from report_reconstruction_support import read, require_markers, write, write_proof

ROOT = "Native/Ambitions/App/AmbitionsRootView.swift"
YOU = "Native/Ambitions/Features/You/YouScreen.swift"


def main() -> int:
    root = read(ROOT)
    root = root.replace('subtitle: "Control",', 'subtitle: "Profile and settings",')
    write(ROOT, root)

    you = read(YOU)
    you = you.replace('"trust-automation": .automationTrust', '"privacy-automation": .automationTrust')
    you = you.replace('"personal-runtime": .personalRuntime', '"personal-system": .personalRuntime')
    write(YOU, you)

    require_markers(ROOT, ["Profile and settings"])
    require_markers(YOU, ["privacy-automation", "personal-system", "receipts-history"])

    write_proof(
        "REPORT_BATCH_35_YOU_NATIVE_SETTINGS_HIERARCHY.md",
        """
# Batch 35 — You Native Settings Hierarchy

Status: applied.

Scope:
- Reframed the root shell subtitle for You around profile/settings language.
- Moved screenshot detail identifiers away from runtime/manual language.
- Preserved existing sheets and native grouped controls.

Native interaction law:
- Settings becomes You.
- You must feel like profile, command center, privacy, appearance, defaults, permissions, and history.

Validation:
- Root source marker proves the profile/settings shell subtitle exists.
- You source markers prove updated detail-route language exists.
- Xcode build remains the blocking gate.
""",
    )
    print("Applied Batch 35 You Native Settings Hierarchy.")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
