import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path


SCRIPT = Path(__file__).parents[1] / "verify_unified_frontend_boundaries.py"
PROGRAM = "Ambitions Unified Maximum Polish Frontend Program"
FINAL_DISPOSITIONS = ["promote", "rebuild", "fixture-only", "historical", "delete"]


class UnifiedFrontendBoundaryTests(unittest.TestCase):
    def setUp(self) -> None:
        self.temporary = tempfile.TemporaryDirectory()
        self.root = Path(self.temporary.name)
        self.docs = self.root / "docs/frontend/unified-maximum-polish-frontend"
        self.docs.mkdir(parents=True)
        self._write("Packages/AmbitionsPresentation/Sources/AmbitionsPresentationContracts/Contract.swift", "import Foundation\n")
        self._write("Packages/AmbitionsPresentation/Sources/AmbitionsFlagshipFoundation/Tokens.swift", "import SwiftUI\n")
        self._write(
            "Packages/AmbitionsPresentation/Sources/AmbitionsFlagshipUI/Screen.swift",
            "import SwiftUI\nimport AmbitionsPresentationContracts\n"
            "import AmbitionsFlagshipFoundation\n",
        )
        self._write(
            "Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/Fixture.swift",
            "import SwiftUI\nimport AmbitionsFlagshipUI\n",
        )
        self._write(
            "Packages/AmbitionsPresentation/Package.swift",
            """// swift-tools-version: 6.2
import PackageDescription
let package = Package(products: [
 .library(name: "AmbitionsPresentationContracts", targets: ["AmbitionsPresentationContracts"]),
 .library(name: "AmbitionsFlagshipFoundation", targets: ["AmbitionsFlagshipFoundation"]),
 .library(name: "AmbitionsFlagshipUI", targets: ["AmbitionsFlagshipUI"]),
 .library(name: "AmbitionsNativeVisualFoundry", targets: ["AmbitionsNativeVisualFoundry"])
], targets: [
 .target(name: "AmbitionsPresentationContracts"),
 .target(name: "AmbitionsFlagshipFoundation"),
 .target(name: "AmbitionsFlagshipUI", dependencies: ["AmbitionsPresentationContracts", "AmbitionsFlagshipFoundation"]),
 .target(name: "AmbitionsNativeVisualFoundry", dependencies: ["AmbitionsFlagshipUI"])
])
""",
        )
        self._write(
            "project.yml",
            """packages:
  AmbitionsPresentation:
    path: Packages/AmbitionsPresentation
targets:
  Ambitions:
    dependencies:
      - package: AmbitionsPresentation
        product: AmbitionsPresentationContracts
      - package: AmbitionsPresentation
        product: AmbitionsFlagshipFoundation
      - package: AmbitionsPresentation
        product: AmbitionsFlagshipUI
""",
        )
        self.registry = {
            "schema_version": 1,
            "program": PROGRAM,
            "gate_status": "pending_ufp_4",
            "allowed_final_dispositions": FINAL_DISPOSITIONS,
            "required_final_metadata": [
                "source_owner",
                "replacement",
                "dependency_edges",
                "proof_requirements",
                "removal_condition",
                "production_legacy",
            ],
            "production_frontend_disposition": "legacy_in_full_delete_original_sources",
            "frontend_roots": [
                "Packages/AmbitionsPresentation/Sources/AmbitionsPresentationContracts",
                "Packages/AmbitionsPresentation/Sources/AmbitionsFlagshipFoundation",
                "Packages/AmbitionsPresentation/Sources/AmbitionsFlagshipUI",
                "Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry",
            ],
            "entries": [
                {
                    "id": "presentation-contracts",
                    "path": "Packages/AmbitionsPresentation/Sources/AmbitionsPresentationContracts",
                    "kind": "tree",
                    "disposition": "pending",
                    "decision_gate": "UFP-4",
                    "production_legacy": False,
                },
                {
                    "id": "flagship-foundation",
                    "path": "Packages/AmbitionsPresentation/Sources/AmbitionsFlagshipFoundation",
                    "kind": "tree",
                    "disposition": "pending",
                    "decision_gate": "UFP-4",
                    "production_legacy": False,
                },
                {
                    "id": "flagship-ui",
                    "path": "Packages/AmbitionsPresentation/Sources/AmbitionsFlagshipUI",
                    "kind": "tree",
                    "disposition": "pending",
                    "decision_gate": "UFP-4",
                    "production_legacy": False,
                },
                {
                    "id": "foundry",
                    "path": "Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry",
                    "kind": "tree",
                    "disposition": "pending",
                    "decision_gate": "UFP-4",
                    "production_legacy": False,
                },
            ],
        }
        self.manifest = {
            "schema_version": 1,
            "program": PROGRAM,
            "gate_status": "transition",
            "remove_by": "UFP-7",
            "legacy_paths": [],
            "legacy_package_products": [],
            "legacy_project_targets": [],
            "legacy_project_dependencies": [],
            "legacy_imports": ["AmbitionsDesignSystem"],
            "legacy_renderer_flags": [],
            "legacy_wrappers": [],
            "legacy_assets": [],
        }
        self._save_contracts()

    def tearDown(self) -> None:
        self.temporary.cleanup()

    def _write(self, relative: str, content: str = "") -> None:
        path = self.root / relative
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(content, encoding="utf-8")

    def _save_contracts(self) -> None:
        (self.docs / "COMPONENT_REGISTRY.json").write_text(
            json.dumps(self.registry), encoding="utf-8"
        )
        (self.docs / "LEGACY_DELETION_MANIFEST.json").write_text(
            json.dumps(self.manifest), encoding="utf-8"
        )

    def run_scan(self, mode: str) -> subprocess.CompletedProcess[str]:
        return subprocess.run(
            [sys.executable, str(SCRIPT), "--root", str(self.root), "--mode", mode],
            capture_output=True,
            text=True,
            check=False,
        )

    def finalize_registry(self) -> None:
        self.registry["gate_status"] = "ufp_4_complete"
        dispositions = {
            "presentation-contracts": "promote",
            "flagship-foundation": "promote",
            "flagship-ui": "promote",
            "foundry": "fixture-only",
        }
        for entry in self.registry["entries"]:
            entry["disposition"] = dispositions[entry["id"]]
            entry["decision_gate"] = "UFP-4-complete"
            entry["source_owner"] = entry["id"]
            entry["replacement"] = "self"
            entry["dependency_edges"] = []
            entry["proof_requirements"] = ["focused component proof"]
            entry["removal_condition"] = "retain approved canonical source"
        self.manifest["gate_status"] = "final"
        self._save_contracts()

    def test_transition_accepts_valid_pending_inventory_with_legacy_present(self) -> None:
        self._write("LegacyUI/OldScreen.swift", "import AmbitionsDesignSystem\n")
        self.registry["frontend_roots"].append("LegacyUI")
        self.registry["entries"].append(
            {
                "id": "legacy-ui",
                "path": "LegacyUI",
                "kind": "tree",
                "disposition": "pending",
                "decision_gate": "UFP-4",
                "production_legacy": True,
            }
        )
        self.manifest["legacy_paths"] = ["LegacyUI"]
        self.manifest["legacy_package_products"] = ["AmbitionsDesignSystem"]
        self._save_contracts()

        result = self.run_scan("transition")

        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("PASS: unified frontend boundaries (transition)", result.stdout)

    def test_transition_fails_for_unclassified_frontend_file(self) -> None:
        self._write("UntrackedUI/NewScreen.swift", "import SwiftUI\n")
        self.registry["frontend_roots"].append("UntrackedUI")
        self._save_contracts()

        result = self.run_scan("transition")

        self.assertEqual(result.returncode, 1)
        self.assertIn("unclassified frontend file: UntrackedUI/NewScreen.swift", result.stdout)

    def test_transition_fails_when_existing_extension_and_test_roots_are_omitted(self) -> None:
        self._write("Native/AmbitionsWidgetExtension/Widget.swift", "import SwiftUI\n")
        self._write("Native/AmbitionsTests/App/LegacyUITest.swift", "import SwiftUI\n")

        result = self.run_scan("transition")

        self.assertEqual(result.returncode, 1)
        self.assertIn(
            "missing required frontend inventory root: Native/AmbitionsWidgetExtension",
            result.stdout,
        )
        self.assertIn(
            "missing required frontend inventory root: Native/AmbitionsTests",
            result.stdout,
        )

    def test_transition_rejects_invalid_gate_and_disposition_vocabulary(self) -> None:
        self.registry["gate_status"] = "approved"
        self.registry["entries"][0]["disposition"] = "keep"
        self._save_contracts()

        result = self.run_scan("transition")

        self.assertEqual(result.returncode, 1)
        self.assertIn("registry gate_status must be pending_ufp_4 in transition mode", result.stdout)
        self.assertIn("invalid component disposition keep", result.stdout)

    def test_canonical_sources_reject_reverse_and_runtime_dependencies_in_both_modes(self) -> None:
        self._write(
            "Packages/AmbitionsPresentation/Sources/AmbitionsFlagshipUI/Screen.swift",
            "import AmbitionsNativeVisualFoundry\nimport AmbitionsRuntimeCore\n"
            "import AmbitionsDesignSystem\n",
        )

        result = self.run_scan("transition")

        self.assertEqual(result.returncode, 1)
        self.assertIn("canonical UI forbidden import AmbitionsNativeVisualFoundry", result.stdout)
        self.assertIn("canonical UI forbidden import AmbitionsRuntimeCore", result.stdout)
        self.assertIn("canonical UI forbidden import AmbitionsDesignSystem", result.stdout)

    def test_final_requires_ufp_4_dispositions_and_canonical_package_direction(self) -> None:
        result = self.run_scan("final")

        self.assertEqual(result.returncode, 1)
        self.assertIn("final mode requires registry gate_status ufp_4_complete", result.stdout)
        self.assertIn("final mode forbids pending component disposition", result.stdout)

        self.finalize_registry()
        package = self.root / "Packages/AmbitionsPresentation/Package.swift"
        package.write_text(
            package.read_text(encoding="utf-8").replace(
                '.target(name: "AmbitionsNativeVisualFoundry", dependencies: ["AmbitionsFlagshipUI"])',
                '.target(name: "AmbitionsNativeVisualFoundry")',
            ),
            encoding="utf-8",
        )
        result = self.run_scan("final")

        self.assertEqual(result.returncode, 1)
        self.assertIn(
            "AmbitionsNativeVisualFoundry target must depend on AmbitionsFlagshipUI",
            result.stdout,
        )

    def test_final_rejects_missing_disposition_metadata(self) -> None:
        self.finalize_registry()
        del self.registry["entries"][0]["source_owner"]
        self.registry["entries"][0]["proof_requirements"] = []
        self._save_contracts()

        result = self.run_scan("final")

        self.assertEqual(result.returncode, 1)
        self.assertIn("final component presentation-contracts needs source_owner", result.stdout)
        self.assertIn(
            "final component presentation-contracts needs proof_requirements",
            result.stdout,
        )

    def test_final_rejects_surviving_production_legacy_outside_manifest(self) -> None:
        self.finalize_registry()
        self._write("LegacyOutside/OldView.swift", "import SwiftUI\n")
        self.registry["frontend_roots"].append("LegacyOutside")
        self.registry["entries"].append(
            {
                "id": "legacy-outside",
                "path": "LegacyOutside",
                "kind": "tree",
                "disposition": "promote",
                "decision_gate": "UFP-4-complete",
                "source_owner": "legacy production",
                "replacement": "canonical UI",
                "dependency_edges": [],
                "proof_requirements": ["replacement proof"],
                "removal_condition": "delete original tree",
                "production_legacy": True,
            }
        )
        self._save_contracts()

        result = self.run_scan("final")

        self.assertEqual(result.returncode, 1)
        self.assertIn(
            "production legacy component legacy-outside must be rebuild or delete",
            result.stdout,
        )
        self.assertIn("production legacy source remains: LegacyOutside", result.stdout)

    def test_final_reports_every_configured_legacy_category(self) -> None:
        self.finalize_registry()
        self._write("LegacyUI/OldScreen.swift", "import AmbitionsDesignSystem\n")
        self._write("Native/LegacyWrapper.swift", "struct LegacyWrapper {}\n")
        self._write("Native/RendererChoice.swift", "let useLegacyRenderer = true\n")
        self._write("Native/Assets/old.imageset/Contents.json", "{}\n")
        self._write(
            "Packages/AmbitionsPresentation/Package.swift",
            (self.root / "Packages/AmbitionsPresentation/Package.swift").read_text(encoding="utf-8")
            .replace(
                "products: [",
                'products: [.library(name: "AmbitionsDesignSystem", targets: ["AmbitionsDesignSystem"]),',
            ),
        )
        self._write(
            "project.yml",
            (self.root / "project.yml").read_text(encoding="utf-8")
            + "  LegacyHost:\n    type: application\n    dependencies:\n"
            + "      - package: AmbitionsPackages\n        product: AmbitionsDesignSystem\n",
        )
        self.manifest.update(
            {
                "legacy_paths": ["LegacyUI"],
                "legacy_package_products": ["AmbitionsDesignSystem"],
                "legacy_project_targets": ["LegacyHost"],
                "legacy_project_dependencies": ["AmbitionsPackages", "AmbitionsDesignSystem"],
                "legacy_renderer_flags": [
                    {"path": "Native/RendererChoice.swift", "symbol": "useLegacyRenderer"}
                ],
                "legacy_wrappers": [
                    {"path": "Native/LegacyWrapper.swift", "symbol": "LegacyWrapper"}
                ],
                "legacy_assets": ["Native/Assets/old.imageset"],
            }
        )
        self._save_contracts()

        result = self.run_scan("final")

        self.assertEqual(result.returncode, 1)
        for expected in (
            "legacy path remains: LegacyUI",
            "legacy package product remains: AmbitionsDesignSystem",
            "legacy project target remains: LegacyHost",
            "legacy project dependency remains: AmbitionsPackages",
            "legacy project dependency remains: AmbitionsDesignSystem",
            "legacy import remains: AmbitionsDesignSystem in LegacyUI/OldScreen.swift",
            "legacy renderer flag remains: useLegacyRenderer in Native/RendererChoice.swift",
            "legacy wrapper remains: LegacyWrapper in Native/LegacyWrapper.swift",
            "legacy asset remains: Native/Assets/old.imageset",
        ):
            self.assertIn(expected, result.stdout)

    def test_final_accepts_zero_legacy_cutover(self) -> None:
        self.finalize_registry()

        result = self.run_scan("final")

        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("PASS: unified frontend boundaries (final)", result.stdout)

    def test_final_accepts_absent_tree_classified_for_deletion(self) -> None:
        self.finalize_registry()
        self.registry["frontend_roots"].append("DeletedLegacyUI")
        self.registry["entries"].append(
            {
                "id": "deleted-legacy-ui",
                "path": "DeletedLegacyUI",
                "kind": "tree",
                "disposition": "delete",
                "decision_gate": "UFP-4-complete",
                "source_owner": "legacy production",
                "replacement": "canonical UI",
                "dependency_edges": [],
                "proof_requirements": ["deletion proof"],
                "removal_condition": "original tree absent",
                "production_legacy": True,
            }
        )
        self.manifest["legacy_paths"] = ["DeletedLegacyUI"]
        self._save_contracts()

        result = self.run_scan("final")

        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

    def test_final_rejects_remaining_delete_disposition_even_if_manifest_omits_it(self) -> None:
        self.finalize_registry()
        self._write("UnlistedLegacyUI/OldScreen.swift", "import SwiftUI\n")
        self.registry["frontend_roots"].append("UnlistedLegacyUI")
        self.registry["entries"].append(
            {
                "id": "unlisted-legacy-ui",
                "path": "UnlistedLegacyUI",
                "kind": "tree",
                "disposition": "delete",
                "decision_gate": "UFP-4-complete",
                "source_owner": "legacy production",
                "replacement": "canonical UI",
                "dependency_edges": [],
                "proof_requirements": ["deletion proof"],
                "removal_condition": "original tree absent",
                "production_legacy": True,
            }
        )
        self._save_contracts()

        result = self.run_scan("final")

        self.assertEqual(result.returncode, 1)
        self.assertIn(
            "component classified delete remains: UnlistedLegacyUI",
            result.stdout,
        )


if __name__ == "__main__":
    unittest.main()
