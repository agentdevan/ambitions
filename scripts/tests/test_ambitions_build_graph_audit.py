import importlib.util
from pathlib import Path
import unittest


SCRIPT_PATH = Path(__file__).parents[1] / "ambitions-build-graph-audit.py"
SPEC = importlib.util.spec_from_file_location("ambitions_build_graph_audit", SCRIPT_PATH)
audit_module = importlib.util.module_from_spec(SPEC)
assert SPEC.loader is not None
SPEC.loader.exec_module(audit_module)


class BuildGraphAuditTests(unittest.TestCase):
    def test_rejects_repo_root_local_package(self):
        objects = {
            "PACKAGE": {
                "isa": "XCLocalSwiftPackageReference",
                "relativePath": ".",
            }
        }

        self.assertEqual(
            audit_module.audit(objects),
            ["repo-root local package reference: ."],
        )

    def test_accepts_nested_design_system_package(self):
        objects = {
            "APP": {
                "isa": "PBXNativeTarget",
                "name": "Ambitions",
                "dependencies": [],
                "packageProductDependencies": ["PRODUCT"],
            },
            "PACKAGE": {
                "isa": "XCLocalSwiftPackageReference",
                "relativePath": "Packages/AmbitionsDesignSystem",
            },
            "PRODUCT": {
                "isa": "XCSwiftPackageProductDependency",
                "package": "PACKAGE",
                "productName": "AmbitionsDesignSystem",
            },
        }

        self.assertEqual(
            audit_module.audit(
                objects,
                expected_package_path="Packages/AmbitionsDesignSystem",
            ),
            [],
        )
        self.assertEqual(
            audit_module.package_product_edges(objects),
            {("Ambitions", "AmbitionsDesignSystem")},
        )

    def test_reports_malformed_package_product_dependency(self):
        objects = {
            "APP": {
                "isa": "PBXNativeTarget",
                "name": "Ambitions",
                "dependencies": [],
                "packageProductDependencies": ["MISSING", "MALFORMED"],
            },
            "MALFORMED": {
                "isa": "XCSwiftPackageProductDependency",
            },
        }

        self.assertEqual(
            audit_module.audit(objects),
            [
                "invalid package product dependency: Ambitions -> MALFORMED",
                "invalid package product dependency: Ambitions -> MISSING",
            ],
        )

    def test_reports_missing_expected_target_edge(self):
        objects = {
            "APP": {
                "isa": "PBXNativeTarget",
                "name": "Ambitions",
                "dependencies": [],
            },
            "TIME": {
                "isa": "PBXNativeTarget",
                "name": "AmbitionsTimeFoundation",
                "dependencies": [],
            },
        }

        self.assertEqual(
            audit_module.audit(
                objects,
                required_edges=[("Ambitions", "AmbitionsTimeFoundation")],
            ),
            ["missing required target edge: Ambitions -> AmbitionsTimeFoundation"],
        )

    def test_reports_dependency_cycle(self):
        objects = {
            "APP": {
                "isa": "PBXNativeTarget",
                "name": "Ambitions",
                "dependencies": ["APP_TO_TIME"],
            },
            "TIME": {
                "isa": "PBXNativeTarget",
                "name": "AmbitionsTimeFoundation",
                "dependencies": ["TIME_TO_APP"],
            },
            "APP_TO_TIME": {
                "isa": "PBXTargetDependency",
                "target": "TIME",
            },
            "TIME_TO_APP": {
                "isa": "PBXTargetDependency",
                "targetProxy": "APP_PROXY",
            },
            "APP_PROXY": {
                "isa": "PBXContainerItemProxy",
                "remoteGlobalIDString": "APP",
            },
        }

        self.assertEqual(
            audit_module.audit(objects),
            [
                "target dependency cycle: "
                "Ambitions -> AmbitionsTimeFoundation -> Ambitions"
            ],
        )

    def test_accepts_acyclic_time_foundation_graph(self):
        objects = {
            "APP": {
                "isa": "PBXNativeTarget",
                "name": "Ambitions",
                "dependencies": ["APP_TO_TIME"],
            },
            "TESTS": {
                "isa": "PBXNativeTarget",
                "name": "AmbitionsTests",
                "dependencies": ["TESTS_TO_APP", "TESTS_TO_TIME"],
            },
            "MODULE_TESTS": {
                "isa": "PBXNativeTarget",
                "name": "AmbitionsModuleTests",
                "dependencies": ["MODULE_TESTS_TO_TIME"],
            },
            "TIME": {
                "isa": "PBXNativeTarget",
                "name": "AmbitionsTimeFoundation",
                "dependencies": [],
            },
            "APP_TO_TIME": {"isa": "PBXTargetDependency", "target": "TIME"},
            "TESTS_TO_APP": {"isa": "PBXTargetDependency", "target": "APP"},
            "TESTS_TO_TIME": {"isa": "PBXTargetDependency", "target": "TIME"},
            "MODULE_TESTS_TO_TIME": {
                "isa": "PBXTargetDependency",
                "target": "TIME",
            },
        }

        self.assertEqual(
            audit_module.audit(
                objects,
                required_targets=[
                    "Ambitions",
                    "AmbitionsTests",
                    "AmbitionsModuleTests",
                    "AmbitionsTimeFoundation",
                ],
                required_edges=[
                    ("Ambitions", "AmbitionsTimeFoundation"),
                    ("AmbitionsTests", "Ambitions"),
                    ("AmbitionsTests", "AmbitionsTimeFoundation"),
                    ("AmbitionsModuleTests", "AmbitionsTimeFoundation"),
                ],
            ),
            [],
        )


if __name__ == "__main__":
    unittest.main()
