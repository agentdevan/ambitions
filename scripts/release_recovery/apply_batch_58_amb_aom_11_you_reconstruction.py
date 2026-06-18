#!/usr/bin/env python3
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
YOU = ROOT / "Native" / "Ambitions" / "Features" / "You" / "YouRootSurface.swift"
TEST = ROOT / "Native" / "AmbitionsTests" / "You" / "YouUserSystemProfileReconstructionTests.swift"
OUT = ROOT / "artifacts" / "object-stage-mega-train"
RECON = OUT / "reconciliation"
RECON.mkdir(parents=True, exist_ok=True)

text = YOU.read_text(encoding="utf-8")
replacements = {
    'productObject: "Personal system / User System Profile"': 'productObject: "User System Profile"',
    'stageName: "You Object Stage Control"': 'stageName: "User System Profile"',
    '            "planning setup",\n            "runtime preferences",\n            "history and trust",\n            "support system"': '            "account and profile",\n            "privacy and automation",\n            "appearance",\n            "notifications",\n            "learning",\n            "receipts and history",\n            "export",\n            "support"',
    '            "operator-style root overview",\n            "rounded per-row card stack"': '            "operator-style root overview",\n            "rounded per-row card stack",\n            "social profile",\n            "admin panel",\n            "AI settings wall",\n            "verbose documentation UI",\n            "internal runtime console"',
    '                Text("Local-first personal system")': '                Text("Account, privacy, learning, and controls stay local")',
    '        .accessibilityValue("Ambitions runs on this iPhone.")': '        .accessibilityValue("Account, privacy, appearance, notifications, learning, receipts, export, and support controls are organized locally.")',
    '                title: "Planning defaults",\n                subtitle: "Time, availability, and planning defaults stay user-owned."': '                title: "Account & profile",\n                subtitle: "Profile, availability, and planning defaults stay user-owned."',
    '                title: "Privacy & security",\n                subtitle: "Receipts and controls remain connected to local evidence."': '                title: "Privacy, learning & receipts",\n                subtitle: "Learning controls, receipts, history, and local data stay inspectable."',
    '                title: "Help & about",\n                subtitle: "Assistance and app-system context in a single system band."': '                title: "Export & support",\n                subtitle: "Export, support, and app-system context in one native settings group."',
    '                    RootSectionRow(id: "help", sourceItemID: "help-support", title: "Help", detail: .support),\n                    RootSectionRow(id: "about", sourceItemID: "about", title: "About", detail: .about)': '                    RootSectionRow(id: "export-import", sourceItemID: "export-import", title: "Export / Import", detail: .exportImport),\n                    RootSectionRow(id: "help", sourceItemID: "help-support", title: "Help", detail: .support),\n                    RootSectionRow(id: "about", sourceItemID: "about", title: "About", detail: .about)',
    '        case "help": .support\n        case "about": .about': '        case "export-import": .exportImport\n        case "help": .support\n        case "about": .about',
}
for old, new in replacements.items():
    if old not in text:
        raise SystemExit(f"Expected You marker not found: {old}")
    text = text.replace(old, new)

required_markers = [
    "User System Profile",
    "account and profile",
    "privacy and automation",
    "appearance",
    "notifications",
    "learning",
    "receipts and history",
    "export",
    "support",
    "social profile",
    "admin panel",
    "AI settings wall",
    "Account & profile",
    "Privacy, learning & receipts",
    "Export & support",
    "Export / Import",
]
for marker in required_markers:
    if marker not in text:
        raise SystemExit(f"Missing AMB-AOM-11 marker: {marker}")
YOU.write_text(text, encoding="utf-8")

TEST.write_text(
    """import XCTest
@testable import Ambitions

final class YouUserSystemProfileReconstructionTests: XCTestCase {
    func testYouObjectStageContractOwnsUserSystemProfile() {
        let contract = YouObjectStageControlPrimitiveContract.current
        XCTAssertEqual(contract.ownerSurface, "You")
        XCTAssertEqual(contract.productObject, "User System Profile")
        XCTAssertEqual(contract.stageName, "User System Profile")
        XCTAssertTrue(contract.avoidsGenericProfileSettingsWall)
    }

    func testYouObjectStageContractCoversNativeSettingsMap() {
        let order = Set(YouObjectStageControlPrimitiveContract.current.sourceControlOrder)
        XCTAssertTrue(order.contains("account and profile"))
        XCTAssertTrue(order.contains("privacy and automation"))
        XCTAssertTrue(order.contains("appearance"))
        XCTAssertTrue(order.contains("notifications"))
        XCTAssertTrue(order.contains("learning"))
        XCTAssertTrue(order.contains("receipts and history"))
        XCTAssertTrue(order.contains("export"))
        XCTAssertTrue(order.contains("support"))
    }

    func testYouObjectStageContractRejectsBadProfileShapes() {
        let replaced = Set(YouObjectStageControlPrimitiveContract.current.replacesFirstViewportStructures)
        XCTAssertTrue(replaced.contains("social profile"))
        XCTAssertTrue(replaced.contains("admin panel"))
        XCTAssertTrue(replaced.contains("AI settings wall"))
        XCTAssertTrue(replaced.contains("verbose documentation UI"))
        XCTAssertTrue(replaced.contains("internal runtime console"))
        XCTAssertTrue(replaced.contains("generic settings wall"))
    }
}
""",
    encoding="utf-8",
)

report = """# AMB-AOM-11 You Reconstruction

Status: `GREEN_SOURCE_DELTA`

This deterministic Autopilot batch starts AMB-AOM-11 by hardening You as User System Profile with native settings-quality organization instead of a social profile, admin panel, AI settings wall, verbose documentation UI, or internal runtime console.

## Source changes

- `Native/Ambitions/Features/You/YouRootSurface.swift`
- `Native/AmbitionsTests/You/YouUserSystemProfileReconstructionTests.swift`

## Scope result

- You owns User System Profile.
- Root settings groups are reframed as Account & profile, Appearance & notifications, Privacy, learning & receipts, and Export & support.
- Account, privacy, appearance, notifications, learning, receipts/history, export/import, and support are explicitly represented in the contract.
- The root object rejects social profile, admin panel, AI settings wall, verbose documentation UI, internal runtime console, and generic settings wall shapes.
- Existing detail sheets, local-first controls, haptic route changes, accessibility identifiers, and Dynamic Type behavior remain intact.

## Next gate

Run AMB-AOM-11 validation for no profile/settings-wall regression and native settings-quality proof before AMB-AOM-12.
"""
(OUT / "AMB-AOM-11-report.md").write_text(report, encoding="utf-8")
(RECON / "AMB-AOM-11-you-reconstruction.md").write_text(report, encoding="utf-8")
print("AMB-AOM-11 You reconstruction source delta written.")
