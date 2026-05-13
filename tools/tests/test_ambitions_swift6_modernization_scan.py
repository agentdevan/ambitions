#!/usr/bin/env python3
"""Tests for scripts/ambitions-swift6-modernization-scan.py.

Run from repo root:
    python3 tools/tests/test_ambitions_swift6_modernization_scan.py
"""
from __future__ import annotations

import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
SCANNER = REPO_ROOT / "scripts" / "ambitions-swift6-modernization-scan.py"


def write_base_fixture(root: Path, swift_version: str = "6.0", strict: str = "complete", package_tools: str = "6.0") -> None:
    (root / "Native/Ambitions/Features/Today").mkdir(parents=True)
    (root / "Native/Ambitions/Domain").mkdir(parents=True)
    (root / "Sources").mkdir(parents=True)
    (root / "AppUI/Sources").mkdir(parents=True)
    (root / "project.yml").write_text(
        f"settings:\n  base:\n    SWIFT_VERSION: {swift_version}\n    SWIFT_STRICT_CONCURRENCY: {strict}\n",
        encoding="utf-8",
    )
    (root / "Package.swift").write_text(f"// swift-tools-version: {package_tools}\n", encoding="utf-8")
    (root / "Native/Ambitions/Features/Today/TodayViewModel.swift").write_text(
        "import Observation\n\n@MainActor @Observable final class TodayViewModel {}\n",
        encoding="utf-8",
    )
    (root / "Native/Ambitions/Domain/PureDomainModel.swift").write_text(
        "import Foundation\n\nstruct PureDomainModel: Sendable {}\n",
        encoding="utf-8",
    )


def run_scanner(root: Path) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        [sys.executable, str(SCANNER), str(root), "--strict"],
        text=True,
        capture_output=True,
        check=False,
    )


class Swift6ModernizationScanTests(unittest.TestCase):
    def test_clean_swift6_fixture_passes(self) -> None:
        with tempfile.TemporaryDirectory() as raw:
            root = Path(raw)
            write_base_fixture(root)
            result = run_scanner(root)
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            self.assertIn("Status: GREEN", result.stdout)

    def test_swift_5_10_settings_fail(self) -> None:
        with tempfile.TemporaryDirectory() as raw:
            root = Path(raw)
            write_base_fixture(root, swift_version="5.10", strict="minimal", package_tools="5.10")
            result = run_scanner(root)
            self.assertNotEqual(result.returncode, 0, result.stdout + result.stderr)
            self.assertIn("swift-version-not-6", result.stdout)
            self.assertIn("strict-concurrency-not-complete", result.stdout)
            self.assertIn("package-tools-not-6", result.stdout)

    def test_combine_owned_observable_object_fails(self) -> None:
        with tempfile.TemporaryDirectory() as raw:
            root = Path(raw)
            write_base_fixture(root)
            legacy = root / "Native/Ambitions/Features/Today/LegacyViewModel.swift"
            legacy.write_text(
                "import Combine\n\n"
                "final class LegacyViewModel: ObservableObject {\n"
                "    @Published var title = \"\"\n"
                "    var cancellables: Set<AnyCancellable> = []\n"
                "}\n",
                encoding="utf-8",
            )
            result = run_scanner(root)
            self.assertNotEqual(result.returncode, 0, result.stdout + result.stderr)
            self.assertIn("combine-import", result.stdout)
            self.assertIn("observable-object", result.stdout)
            self.assertIn("published-wrapper", result.stdout)
            self.assertIn("any-cancellable", result.stdout)

    def test_module_boundary_leaks_fail(self) -> None:
        with tempfile.TemporaryDirectory() as raw:
            root = Path(raw)
            write_base_fixture(root)
            (root / "Native/Ambitions/Domain/LeakyDomainModel.swift").write_text(
                "import SwiftUI\nimport SwiftData\n",
                encoding="utf-8",
            )
            (root / "Native/Ambitions/Features/Today/LeakyFeature.swift").write_text(
                "import SwiftData\n",
                encoding="utf-8",
            )
            (root / "Sources/LeakyDesignSystemPrimitive.swift").write_text(
                "import SwiftData\n",
                encoding="utf-8",
            )
            (root / "AppUI/Sources/LeakyWidgetUI.swift").write_text(
                "import SwiftData\n",
                encoding="utf-8",
            )

            result = run_scanner(root)

            self.assertNotEqual(result.returncode, 0, result.stdout + result.stderr)
            self.assertIn("domain-imports-swiftui", result.stdout)
            self.assertIn("domain-imports-swiftdata", result.stdout)
            self.assertIn("features-own-swiftdata", result.stdout)
            self.assertIn("design-system-imports-swiftdata", result.stdout)
            self.assertIn("widget-ui-imports-swiftdata", result.stdout)

    def test_allow_marker_keeps_adapter_escape_hatch_reviewable(self) -> None:
        with tempfile.TemporaryDirectory() as raw:
            root = Path(raw)
            write_base_fixture(root)
            adapter = root / "Native/Ambitions/Features/Today/CombineEdgeAdapter.swift"
            adapter.write_text(
                "import Combine // AMB_SWIFT6_ALLOW: legacy Apple publisher adapter only\n",
                encoding="utf-8",
            )
            result = run_scanner(root)
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            self.assertIn("Allowed: 1", result.stdout)

    def test_explicit_sendable_allowlist_is_narrow_and_reviewable(self) -> None:
        with tempfile.TemporaryDirectory() as raw:
            root = Path(raw)
            write_base_fixture(root)
            projector = root / "Native/Ambitions/Features/Today/TodayReadModelProjector.swift"
            projector.write_text(
                "import Foundation\n\n"
                "final class TodayDerivedReadModelCache: @unchecked Sendable {}\n",
                encoding="utf-8",
            )

            result = run_scanner(root)

            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            self.assertIn("unchecked-sendable", result.stdout)
            self.assertIn("Allowed: 1", result.stdout)


if __name__ == "__main__":
    unittest.main()
