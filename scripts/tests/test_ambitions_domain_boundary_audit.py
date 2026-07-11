import importlib.util
import json
import tempfile
import unittest
from pathlib import Path


SCRIPT_PATH = Path(__file__).parents[1] / "ambitions-domain-boundary-audit.py"
SPEC = importlib.util.spec_from_file_location("ambitions_domain_boundary_audit", SCRIPT_PATH)
MODULE = importlib.util.module_from_spec(SPEC)
assert SPEC.loader is not None
SPEC.loader.exec_module(MODULE)

collect_boundary = MODULE.collect_boundary
validate_boundary = MODULE.validate_boundary
reviewed_content_hash = MODULE.reviewed_content_hash


class DomainBoundaryAuditTests(unittest.TestCase):
    def setUp(self) -> None:
        self.temporary = tempfile.TemporaryDirectory()
        self.root = Path(self.temporary.name)
        self.project = self.root / "Ambitions.xcodeproj"
        self.project.mkdir()
        self.disposition = self.root / ".codex/architecture/source-disposition.json"
        self.disposition.parent.mkdir(parents=True)
        self.write_domain("Step.swift", "import Foundation\nstruct Step { let id: String }\n")
        self.write_domain("GoalEngine/Planner.swift", "import Foundation\nstruct Planner {}\n")
        outside = self.root / "Native/Ambitions/Surfaces/Goals/GoalView.swift"
        outside.parent.mkdir(parents=True)
        outside.write_text("struct GoalView { let step: Step }\n", encoding="utf-8")
        paths = [
            "Native/Ambitions/Core/Domain/Step.swift",
            "Native/Ambitions/Core/Domain/GoalEngine/Planner.swift",
            "Native/Ambitions/Surfaces/Goals/GoalView.swift",
        ]
        self._write_project(paths)
        self.disposition.write_text(
            json.dumps({"files": [{"path": path, "disposition": "unknown_pending_stronger_evidence"} for path in paths]}),
            encoding="utf-8",
        )

    def tearDown(self) -> None:
        self.temporary.cleanup()

    def _write_project(self, paths: list[str]) -> None:
        objects = {}
        build_files = []
        for index, path in enumerate(paths):
            file_id = f"FILE{index}"
            build_id = f"BUILD{index}"
            objects[file_id] = {"isa": "PBXFileReference", "path": path, "sourceTree": "SOURCE_ROOT"}
            objects[build_id] = {"isa": "PBXBuildFile", "fileRef": file_id}
            build_files.append(build_id)
        objects["SOURCES"] = {"isa": "PBXSourcesBuildPhase", "files": build_files}
        objects["TARGET"] = {"isa": "PBXNativeTarget", "name": "Ambitions", "buildPhases": ["SOURCES"]}
        (self.project / "project.pbxproj").write_text(json.dumps({"objects": objects}), encoding="utf-8")

    def write_domain(self, relative: str, content: str) -> None:
        path = self.root / "Native/Ambitions/Core/Domain" / relative
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(content, encoding="utf-8")

    def collect(self):
        return collect_boundary(self.root, self.project, self.disposition)

    @staticmethod
    def approved_contract(signature: str) -> dict:
        return {
            "symbol": signature,
            "status": "approved",
            "declarationPaths": ["Native/Ambitions/Core/Domain/Step.swift"],
            "consumerPaths": ["Native/Ambitions/Surfaces/Goals/GoalView.swift"],
            "coverage": ["scripts/tests/test_ambitions_domain_boundary_audit.py"],
            "decision": "required by current consumer",
        }

    def complete_reviewed_payload(self) -> dict:
        payload = self.collect()
        payload["compilerPublicInterface"] = ["public struct Step"]
        payload["publicContracts"] = [self.approved_contract("public struct Step")]
        payload["consolidationReview"] = {
            "status": "approved",
            "dynamicPersistenceMigrationReplayChecked": True,
            "appIntentsWidgetsShareChecked": True,
            "reflectionFixturesRegistriesChecked": True,
            "localRuntimeConstructionChecked": True,
            "provenCandidatePaths": [],
        }
        payload["review"] = {"status": "approved", "findings": []}
        payload["review"]["reviewedContentHash"] = reviewed_content_hash(self.root, payload)
        return payload

    def test_collects_recursive_domain_files_and_outside_consumers(self) -> None:
        payload = collect_boundary(self.root, self.project, self.disposition)
        self.assertEqual(
            [row["path"] for row in payload["files"]],
            [
                "Native/Ambitions/Core/Domain/GoalEngine/Planner.swift",
                "Native/Ambitions/Core/Domain/Step.swift",
            ],
        )
        self.assertEqual(
            payload["outsideConsumers"],
            [{
                "path": "Native/Ambitions/Surfaces/Goals/GoalView.swift",
                "target": "Ambitions",
                "candidateSymbols": ["Step"],
            }],
        )

    def test_rejects_forbidden_domain_import(self) -> None:
        self.write_domain("Bad.swift", "import SwiftUI\nstruct Bad {}\n")
        findings = validate_boundary(self.collect(), require_review=False)
        self.assertIn("forbidden Domain import: SwiftUI in Native/Ambitions/Core/Domain/Bad.swift", findings)

    def test_rejects_duplicate_production_membership(self) -> None:
        payload = self.collect()
        payload["files"][0]["xcodeTargets"] = ["Ambitions", "AmbitionsDomain"]
        findings = validate_boundary(payload, require_review=False)
        self.assertIn("Domain source has multiple production targets: Native/Ambitions/Core/Domain/GoalEngine/Planner.swift", findings)

    def test_review_gate_rejects_unreviewed_or_candidate_contracts(self) -> None:
        payload = self.collect()
        payload["publicContracts"] = [{"symbol": "Step", "status": "candidate"}]
        findings = validate_boundary(payload, require_review=True)
        self.assertIn("boundary review is not approved", findings)
        self.assertIn("public contract lacks approved decision: Step", findings)

    def test_review_gate_accepts_only_complete_approved_contracts(self) -> None:
        payload = self.complete_reviewed_payload()
        self.assertEqual(validate_boundary(payload, require_review=True), [])

    def test_public_interface_and_approved_manifest_must_be_bijective(self) -> None:
        payload = self.complete_reviewed_payload()
        payload["compilerPublicInterface"] = ["public struct Step", "public init(id: Swift.String)"]
        payload["publicContracts"] = [self.approved_contract("public struct Step")]
        findings = validate_boundary(payload, require_review=True)
        self.assertIn("unapproved compiler public declaration: public init(id: Swift.String)", findings)

    def test_rejects_approved_contract_absent_from_compiler_interface(self) -> None:
        payload = self.complete_reviewed_payload()
        payload["publicContracts"].append(self.approved_contract("public var phantom: Swift.String"))
        findings = validate_boundary(payload, require_review=True)
        self.assertIn("approved public contract absent from compiler interface: public var phantom: Swift.String", findings)

    def test_rejects_incomplete_contract_evidence_and_review_findings(self) -> None:
        payload = self.complete_reviewed_payload()
        payload["publicContracts"][0]["coverage"] = []
        payload["review"]["findings"] = ["Important: initializer is broader than its consumer"]
        findings = validate_boundary(payload, require_review=True)
        self.assertIn("public contract has incomplete evidence: public struct Step", findings)
        self.assertIn("boundary review retains Critical or Important findings", findings)

    def test_content_hash_invalidates_review_after_source_or_manifest_change(self) -> None:
        payload = self.complete_reviewed_payload()
        payload["review"]["reviewedContentHash"] = "sha256:stale"
        findings = validate_boundary(payload, require_review=True)
        self.assertIn("reviewed content hash does not match current boundary content", findings)

    def test_consolidation_review_requires_all_dynamic_safety_checks(self) -> None:
        payload = self.complete_reviewed_payload()
        payload["consolidationReview"]["appIntentsWidgetsShareChecked"] = False
        findings = validate_boundary(payload, require_review=True)
        self.assertIn("consolidation review is incomplete: appIntentsWidgetsShareChecked", findings)

    def test_declarations_do_not_cross_lines_or_promote_nested_private_types(self) -> None:
        self.write_domain(
            "Noise.swift",
            "func choose() -> String {\n  return\n  actor.value\n}\n"
            "struct Outer { private enum CodingKeys: String { case value } }\n",
        )
        payload = self.collect()
        noise = next(row for row in payload["files"] if row["path"].endswith("Noise.swift"))
        self.assertEqual(noise["declarations"], [{"kind": "struct", "name": "Outer"}])
        symbols = {symbol for row in payload["outsideConsumers"] for symbol in row["candidateSymbols"]}
        self.assertNotIn("return", symbols)
        self.assertNotIn("self", symbols)
        self.assertNotIn("CodingKeys", symbols)

    def test_source_change_invalidates_an_existing_approval(self) -> None:
        payload = self.complete_reviewed_payload()
        self.write_domain("Step.swift", "import Foundation\nstruct Step { let changed: String }\n")
        findings = validate_boundary(payload, require_review=True)
        self.assertIn("reviewed content hash does not match current boundary content", findings)

    def test_collects_nonprivate_nested_contracts_and_file_level_app_intent_signal(self) -> None:
        self.write_domain(
            "LifeCompatibility.swift",
            "struct LifeCompatibility { enum Store {} }\n",
        )
        outside = self.root / "Native/Ambitions/Surfaces/Goals/GoalView.swift"
        outside.write_text(
            "import AppIntents\n\n\n\n\nstruct GoalView { let store: Store }\n",
            encoding="utf-8",
        )
        paths = [
            "Native/Ambitions/Core/Domain/Step.swift",
            "Native/Ambitions/Core/Domain/GoalEngine/Planner.swift",
            "Native/Ambitions/Core/Domain/LifeCompatibility.swift",
            "Native/Ambitions/Surfaces/Goals/GoalView.swift",
        ]
        self._write_project(paths)
        payload = self.collect()
        row = next(item for item in payload["files"] if item["path"].endswith("LifeCompatibility.swift"))
        self.assertIn({"kind": "enum", "name": "Store"}, row["declarations"])
        candidate = next(item for item in payload["consolidationCandidates"] if item["path"] == row["path"])
        self.assertEqual(
            candidate["safetySignals"]["appIntents"],
            ["Native/Ambitions/Surfaces/Goals/GoalView.swift"],
        )


if __name__ == "__main__":
    unittest.main()
