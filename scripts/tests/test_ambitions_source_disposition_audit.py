import importlib.util
import json
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
SCRIPT = ROOT / "scripts" / "ambitions-source-disposition-audit.py"


def load_audit():
    spec = importlib.util.spec_from_file_location("source_disposition_audit", SCRIPT)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


class SourceDispositionAuditTests(unittest.TestCase):
    def setUp(self):
        self.audit = load_audit()

    def _workspace(self, files):
        temporary = tempfile.TemporaryDirectory()
        root = Path(temporary.name)
        for relative_path, contents in files.items():
            path = root / relative_path
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text(contents, encoding="utf-8")
        self.addCleanup(temporary.cleanup)
        return root

    def test_zero_references_with_dynamic_discovery_stays_unknown(self):
        marker_cases = {
            "AppIntent.swift": "import AppIntents\nstruct StartIntent: AppIntent {}",
            "Model.swift": "import SwiftData\n@Model final class StoredGoal {}",
            "Reflection.swift": "let kind = String(reflecting: Goal.self)",
            "Extension.swift": "extension Goal { func repair() {} }",
            "Preview.swift": "#Preview { GoalView() }",
            "Registry.swift": "Registry.register(Goal.self)",
            "Migration.swift": "struct GoalMigrationPlan: SchemaMigrationPlan {}",
            "Persistence.swift": "let container: ModelContainer",
            "Replay.swift": "func replay(_ events: [Event]) {}",
        }
        root = self._workspace(
            {f"Native/Ambitions/Core/{name}": contents for name, contents in marker_cases.items()}
        )

        rows = self.audit.collect_inventory(root, xcode_target_membership={})["files"]

        self.assertEqual(len(marker_cases), len(rows))
        self.assertTrue(all(row["disposition"] == self.audit.UNKNOWN for row in rows))
        self.assertTrue(all(row["discovery_markers"] or row["migration_replay_markers"] for row in rows))

    def test_collects_all_production_roots_and_canonical_nested_package_paths(self):
        root = self._workspace(
            {
                "Native/Ambitions/App/AppRoot.swift": "import SwiftUI\nstruct AppRoot: View {}",
                "Native/AmbitionsWidgetExtension/Widget.swift": "import WidgetKit\nstruct Widget: Widget {}",
                "Native/AmbitionsShareExtension/Share.swift": "import AppIntents\nstruct ShareIntent: AppIntent {}",
                "Packages/AmbitionsDesignSystem/Sources/Tokens/ColorToken.swift": "public enum ColorToken {}",
                "Packages/AmbitionsDesignSystem/AppUI/Sources/Widget/Card.swift": "public struct Card {}",
                "Native/AmbitionsTests/NotProduction.swift": "struct NotProduction {}",
            }
        )

        paths = [row["path"] for row in self.audit.collect_inventory(root, {})["files"]]

        self.assertEqual(
            paths,
            sorted(
                [
                    "Native/Ambitions/App/AppRoot.swift",
                    "Native/AmbitionsShareExtension/Share.swift",
                    "Native/AmbitionsWidgetExtension/Widget.swift",
                    "Packages/AmbitionsDesignSystem/AppUI/Sources/Widget/Card.swift",
                    "Packages/AmbitionsDesignSystem/Sources/Tokens/ColorToken.swift",
                ]
            ),
        )

    def test_reference_counts_exclude_declaration_file_and_registry_refs_are_separate(self):
        root = self._workspace(
            {
                "Native/Ambitions/Core/Goal.swift": "struct Goal {}",
                "Native/Ambitions/App/Use.swift": "let current: Goal\nRegistry.register(Goal.self)",
            }
        )

        rows = {row["path"]: row for row in self.audit.collect_inventory(root, {})["files"]}
        goal = rows["Native/Ambitions/Core/Goal.swift"]

        self.assertIn({"kind": "struct", "name": "Goal"}, goal["declarations"])
        self.assertEqual(goal["reference_count"], 2)
        self.assertEqual(goal["registry_reference_count"], 1)

    def test_extension_only_file_collects_target_and_exact_external_references(self):
        root = self._workspace(
            {
                "Native/Ambitions/Core/Goal+Repair.swift": "extension Goal { func repair() {} }",
                "Native/Ambitions/App/Use.swift": "let goal: Goal\ngoal.repair()\ngoal.repair()",
            }
        )

        rows = {row["path"]: row for row in self.audit.collect_inventory(root, {})["files"]}
        row = rows["Native/Ambitions/Core/Goal+Repair.swift"]

        self.assertEqual(
            row["declarations"],
            [{"kind": "extension", "name": "Goal"}, {"kind": "func", "name": "repair"}],
        )
        self.assertEqual(row["reference_count"], 3)

    def test_function_property_subscript_and_operator_declarations_have_exact_counts(self):
        root = self._workspace(
            {
                "Native/Ambitions/Core/Utilities.swift": (
                    "precedencegroup GoalPrecedence {}\n"
                    "infix operator <~>: GoalPrecedence\n"
                    "func <~> (lhs: Int, rhs: Int) -> Int { lhs + rhs }\n"
                    "func scheduleGoal() {}\n"
                    "let defaultGoal = 1\n"
                    "struct GoalShelf { subscript(index: Int) -> Int { index } }"
                ),
                "Native/Ambitions/App/Use.swift": (
                    "scheduleGoal()\nscheduleGoal()\nlet x = defaultGoal\nlet y = 1 <~> 2\n"
                    "let p: GoalPrecedence.Type? = nil"
                ),
            }
        )

        rows = {row["path"]: row for row in self.audit.collect_inventory(root, {})["files"]}
        row = rows["Native/Ambitions/Core/Utilities.swift"]
        declarations = {(item["kind"], item["name"]) for item in row["declarations"]}

        self.assertTrue(
            {
                ("precedencegroup", "GoalPrecedence"),
                ("operator", "<~>"),
                ("func", "<~>"),
                ("func", "scheduleGoal"),
                ("let", "defaultGoal"),
                ("subscript", "subscript"),
            }.issubset(declarations)
        )
        self.assertEqual(row["reference_count"], 6)

    def test_parses_target_membership_from_pbx_json(self):
        pbx = {
            "objects": {
                "FILE": {"isa": "PBXFileReference", "path": "Goal.swift", "sourceTree": "<group>"},
                "GROUP": {"isa": "PBXGroup", "path": "Core", "sourceTree": "<group>", "children": ["FILE"]},
                "ROOT_GROUP": {"isa": "PBXGroup", "path": "Native/Ambitions", "sourceTree": "<group>", "children": ["GROUP"]},
                "BUILD_FILE": {"isa": "PBXBuildFile", "fileRef": "FILE"},
                "PHASE": {"isa": "PBXSourcesBuildPhase", "files": ["BUILD_FILE"]},
                "TARGET": {"isa": "PBXNativeTarget", "name": "Ambitions", "buildPhases": ["PHASE"]},
                "PROJECT": {"isa": "PBXProject", "mainGroup": "ROOT_GROUP", "targets": ["TARGET"]},
            },
            "rootObject": "PROJECT",
        }

        membership = self.audit.target_membership_from_pbx_json(pbx)

        self.assertEqual(membership, {"Native/Ambitions/Core/Goal.swift": ["Ambitions"]})

    def test_swiftpm_membership_maps_nested_target_source_paths(self):
        description = {
            "path": "/repo/Packages/AmbitionsDesignSystem",
            "targets": [
                {"name": "AmbitionsDesignSystem", "path": "Sources", "sources": ["Tokens/Color.swift"]},
                {"name": "AmbitionsWidgetUI", "path": "AppUI/Sources", "sources": ["Widget/Card.swift"]},
            ],
        }

        membership = self.audit.swiftpm_membership_from_description(
            description, Path("Packages/AmbitionsDesignSystem")
        )

        self.assertEqual(
            membership,
            {
                "Packages/AmbitionsDesignSystem/AppUI/Sources/Widget/Card.swift": ["AmbitionsWidgetUI"],
                "Packages/AmbitionsDesignSystem/Sources/Tokens/Color.swift": ["AmbitionsDesignSystem"],
            },
        )

    def test_inventory_distinguishes_and_unions_membership_sources(self):
        root = self._workspace(
            {"Packages/AmbitionsDesignSystem/Sources/Tokens/Color.swift": "public enum Color {}"}
        )
        path = "Packages/AmbitionsDesignSystem/Sources/Tokens/Color.swift"

        row = self.audit.collect_inventory(
            root,
            xcode_target_membership={path: ["Ambitions"]},
            swiftpm_target_membership={path: ["AmbitionsDesignSystem"]},
        )["files"][0]

        self.assertEqual(row["xcode_target_membership"], ["Ambitions"])
        self.assertEqual(row["swiftpm_target_membership"], ["AmbitionsDesignSystem"])
        self.assertEqual(row["target_membership"], ["Ambitions", "AmbitionsDesignSystem"])

    def test_generated_and_preview_files_are_non_destructively_classified(self):
        root = self._workspace(
            {
                "Native/Ambitions/Core/Generated.swift": "// Generated by SwiftGen. Do not edit.\nstruct Asset {}",
                "Native/Ambitions/PreviewSupport/Example.swift": "#Preview { ExampleView() }",
            }
        )

        rows = {row["path"]: row for row in self.audit.collect_inventory(root, {})["files"]}

        self.assertEqual(rows["Native/Ambitions/Core/Generated.swift"]["disposition"], self.audit.GENERATED)
        self.assertEqual(rows["Native/Ambitions/PreviewSupport/Example.swift"]["disposition"], self.audit.TEST_PREVIEW_ONLY)

    def test_dynamic_uncertainty_outranks_generated_and_preview_classification(self):
        root = self._workspace(
            {
                "Native/Ambitions/Core/GeneratedModel.swift": "// Generated by Tool. Do not edit.\n@Model final class Goal {}",
                "Native/Ambitions/PreviewSupport/Intent.swift": "#Preview { View() }\nstruct OpenIntent: AppIntent {}",
                "Native/Ambitions/Core/GeneratedMigration.swift": "// @generated\nstruct MigrationPlan: SchemaMigrationPlan {}",
            }
        )

        rows = self.audit.collect_inventory(root, {})["files"]

        self.assertTrue(all(row["disposition"] == self.audit.UNKNOWN for row in rows))
        self.assertTrue(all(any("outranks" in item for item in row["evidence"]) for row in rows))

    def test_schema_and_evidence_are_stable_and_complete(self):
        root = self._workspace({"Native/Ambitions/App/B.swift": "import SwiftUI\nstruct B {}"})

        first = self.audit.collect_inventory(root, {"Native/Ambitions/App/B.swift": ["Z", "A"]})
        second = self.audit.collect_inventory(root, {"Native/Ambitions/App/B.swift": ["A", "Z"]})

        self.assertEqual(first, second)
        self.assertEqual(first["schema_version"], 1)
        self.assertEqual(first["files"][0]["target_membership"], ["A", "Z"])
        self.assertTrue(first["files"][0]["evidence"])
        json.dumps(first, sort_keys=True)

    def test_fact_collector_does_not_modify_swift_sources(self):
        root = self._workspace({"Native/Ambitions/App/AppRoot.swift": "struct AppRoot {}\n"})
        source = root / "Native/Ambitions/App/AppRoot.swift"
        before = source.read_bytes()

        self.audit.collect_inventory(root, {})

        self.assertEqual(source.read_bytes(), before)


if __name__ == "__main__":
    unittest.main()
