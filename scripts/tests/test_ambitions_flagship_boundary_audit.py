import importlib.util
import json
import tempfile
import unittest
from pathlib import Path


SCRIPT = Path(__file__).parents[1] / "ambitions-flagship-boundary-audit.py"
SPEC = importlib.util.spec_from_file_location("ambitions_flagship_boundary_audit", SCRIPT)
MODULE = importlib.util.module_from_spec(SPEC)
assert SPEC.loader is not None
SPEC.loader.exec_module(MODULE)


class FlagshipBoundaryAuditTests(unittest.TestCase):
    def setUp(self) -> None:
        self.temporary = tempfile.TemporaryDirectory()
        self.root = Path(self.temporary.name)
        package = self.root / "Packages/AmbitionsPresentation/Sources"
        self.contracts = package / "AmbitionsPresentationContracts/Contracts.swift"
        self.foundation = package / "AmbitionsFlagshipFoundation/Foundation.swift"
        self.ui = package / "AmbitionsFlagshipUI/UI.swift"
        for path in (self.contracts, self.foundation, self.ui):
            path.parent.mkdir(parents=True, exist_ok=True)
        self.contracts.write_text("import Foundation\npublic struct Contract {}\n")
        self.foundation.write_text("import SwiftUI\npublic struct Token {}\n")
        self.ui.write_text(
            "import SwiftUI\nimport AmbitionsPresentationContracts\n"
            "import AmbitionsFlagshipFoundation\npublic struct Shell {}\n"
        )

    def tearDown(self) -> None:
        self.temporary.cleanup()

    def test_accepts_clean_room_sources(self) -> None:
        self.assertEqual(MODULE.scan_source_boundaries(self.root), [])

    def test_rejects_forbidden_imports_and_symbol_families(self) -> None:
        self.contracts.write_text("import SwiftData\npublic struct Contract {}\n")
        self.ui.write_text("import SwiftUI\nlet container: AppContainer\n")
        findings = MODULE.scan_source_boundaries(self.root)
        self.assertIn(
            "AmbitionsPresentationContracts forbidden import SwiftData in "
            "Packages/AmbitionsPresentation/Sources/AmbitionsPresentationContracts/Contracts.swift",
            findings,
        )
        self.assertIn(
            "AmbitionsFlagshipUI forbidden symbol AppContainer in "
            "Packages/AmbitionsPresentation/Sources/AmbitionsFlagshipUI/UI.swift",
            findings,
        )

    def test_rejects_package_dependency_drift(self) -> None:
        descriptor = {
            "targets": [
                {
                    "name": "AmbitionsPresentationContracts",
                    "type": "library",
                    "target_dependencies": ["AmbitionsDesignSystem"],
                },
                {
                    "name": "AmbitionsFlagshipFoundation",
                    "type": "library",
                },
                {
                    "name": "AmbitionsFlagshipUI",
                    "type": "library",
                    "target_dependencies": ["AmbitionsPresentationContracts"],
                },
            ]
        }
        findings = MODULE.validate_package_descriptor(descriptor)
        self.assertIn(
            "AmbitionsPresentationContracts target dependencies must be []: "
            "['AmbitionsDesignSystem']",
            findings,
        )
        self.assertIn(
            "AmbitionsFlagshipUI target dependencies must be "
            "['AmbitionsFlagshipFoundation', 'AmbitionsPresentationContracts']: "
            "['AmbitionsPresentationContracts']",
            findings,
        )

    def test_resolved_xcode_graph_requires_products_and_excludes_test_support(self) -> None:
        objects = {
            "APP": {
                "isa": "PBXNativeTarget",
                "name": "Ambitions",
                "packageProductDependencies": ["UI", "CORE", "TEST"],
            },
            "UI": {
                "isa": "XCSwiftPackageProductDependency",
                "productName": "AmbitionsFlagshipUI",
            },
            "CORE": {
                "isa": "XCSwiftPackageProductDependency",
                "productName": "AmbitionsRuntimeCore",
            },
            "TEST": {
                "isa": "XCSwiftPackageProductDependency",
                "productName": "AmbitionsRuntimeTestSupport",
            },
        }
        findings = MODULE.validate_resolved_xcode_graph({"objects": objects})
        self.assertIn(
            "Ambitions production target is missing package products: "
            "AmbitionsFlagshipFoundation, AmbitionsPresentationContracts, "
            "AmbitionsRuntimeSQLite",
            findings,
        )
        self.assertIn(
            "Ambitions production target links forbidden AmbitionsRuntimeTestSupport",
            findings,
        )


if __name__ == "__main__":
    unittest.main()
