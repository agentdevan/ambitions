import json
import tempfile
import unittest
from contextlib import redirect_stdout
from io import StringIO
from pathlib import Path
from unittest import mock

from tests.canon.test_impact import document, registry, requirement
from tools.ambitions_canon.cli import main
from tools.ambitions_canon.build import build_canon
from tools.ambitions_canon.model import (
    AuthorityClass,
    AuthorityReference,
    AuthorityReferenceKind,
    FigmaAuthorityRole,
)
from tools.ambitions_canon.traceability import (
    TraceabilityRecord,
    build_traceability,
    render_traceability_maps,
)
from tests.canon.canon_test_support import write_required_governance_artifacts
from tests.canon.test_build import document_text, manifest_text


ROOT = Path(__file__).resolve().parents[2]


def reference(
    reference_id: str,
    kind: AuthorityReferenceKind,
    source: str,
    requirement_ids: tuple[str, ...],
) -> AuthorityReference:
    return AuthorityReference(
        schema_version=1,
        reference_id=reference_id,
        authority_class=AuthorityClass.SOURCE_AND_TESTS,
        reference_kind=kind,
        source=source,
        revision="fixture-v1",
        requirement_ids=requirement_ids,
        approval_state="approved",
        approved_by="Fixture owner" if kind is AuthorityReferenceKind.PROOF else None,
        implementation_status="fixture evidence; not implementation proof",
    )


class TraceabilityTests(unittest.TestCase):
    def setUp(self):
        self.temporary_directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary_directory.cleanup)
        self.root = Path(self.temporary_directory.name)

    def test_mapped_source_exists_without_turning_existence_into_normative_status(self):
        source = self.root / "Native/Ambitions/Surfaces/Today/TodayView.swift"
        source.parent.mkdir(parents=True)
        source.write_text("struct TodayView {}\n", encoding="utf-8")
        item = requirement("TODAY-002")
        current = registry(
            (
                document(
                    "SURFACE-TODAY",
                    (item,),
                    source_owners=("Native/Ambitions/Surfaces/Today/",),
                ),
            )
        )

        report = build_traceability(current, self.root, ())

        self.assertEqual(len(report.records), 1)
        record = report.records[0]
        self.assertIsInstance(record, TraceabilityRecord)
        self.assertEqual(record.requirement_id, "TODAY-002")
        self.assertEqual(record.source_owners, ("Native/Ambitions/Surfaces/Today/",))
        self.assertTrue(record.source_mappings[0].exists)
        self.assertEqual(record.source_mappings[0].implementation_files, (source.relative_to(self.root).as_posix(),))
        self.assertNotIn("implemented", record.source_mappings[0].status)

    def test_existing_owner_directory_without_implementation_file_is_explicit_canon_to_code_gap(self):
        owner = self.root / "Native/Ambitions/Surfaces/Today"
        owner.mkdir(parents=True)
        (owner / "AGENTS.md").write_text("routing only\n", encoding="utf-8")
        item = requirement("TODAY-001")
        current = registry(
            (
                document(
                    "SURFACE-TODAY",
                    (item,),
                    source_owners=("Native/Ambitions/Surfaces/Today/",),
                ),
            )
        )

        report = build_traceability(current, self.root, ())

        self.assertIn("CANON_TRACE_CANON_TO_CODE", {finding.code for finding in report.findings})
        self.assertTrue(
            any("gap_class=canon_to_code" in finding.message for finding in report.findings)
        )
        self.assertFalse(report.records[0].source_mappings[0].has_implementation)

    def test_symlinked_source_owner_is_rejected_instead_of_followed(self):
        outside = self.root.parent / f"{self.root.name}-outside-source"
        outside.mkdir()
        self.addCleanup(lambda: __import__("shutil").rmtree(outside, ignore_errors=True))
        (outside / "TodayView.swift").write_text(
            "struct TodayView {}\n", encoding="utf-8"
        )
        owner_parent = self.root / "Native/Ambitions/Surfaces"
        owner_parent.mkdir(parents=True)
        (owner_parent / "Today").symlink_to(outside, target_is_directory=True)
        item = requirement("TODAY-001")
        current = registry(
            (
                document(
                    "SURFACE-TODAY",
                    (item,),
                    source_owners=("Native/Ambitions/Surfaces/Today/",),
                ),
            )
        )

        report = build_traceability(current, self.root, ())
        mapping = report.records[0].source_mappings[0]

        self.assertEqual(mapping.status, "invalid_owner_path")
        self.assertFalse(mapping.exists)
        self.assertEqual(mapping.implementation_files, ())

    def test_unowned_implementation_file_is_code_to_canon_gap(self):
        source = self.root / "Native/Ambitions/Unowned/Loose.swift"
        source.parent.mkdir(parents=True)
        source.write_text("struct Loose {}\n", encoding="utf-8")
        item = requirement("TODAY-001")
        current = registry(
            (
                document(
                    "SURFACE-TODAY",
                    (item,),
                    source_owners=("Native/Ambitions/Surfaces/Today/",),
                ),
            )
        )

        report = build_traceability(current, self.root, ())

        self.assertTrue(
            any(
                finding.code == "CANON_TRACE_CODE_TO_CANON"
                and "gap_class=code_to_canon" in finding.message
                and "Loose.swift" in finding.message
                for finding in report.findings
            )
        )

    def test_requirement_verification_and_stable_references_feed_separate_maps(self):
        proof = self.root / "docs/proof/today.json"
        proof.parent.mkdir(parents=True)
        proof.write_text("{}\n", encoding="utf-8")
        item = requirement(
            "TODAY-001",
            verification=("SCENARIO-TODAY-001", "PROOF-TODAY-001"),
        )
        current = registry((document("SURFACE-TODAY", (item,)),))
        references = (
            reference(
                "TEST-TODAY",
                AuthorityReferenceKind.TEST,
                "tests/canon/test_traceability.py",
                ("TODAY-001",),
            ),
            reference(
                "PROOF-TODAY",
                AuthorityReferenceKind.PROOF,
                "docs/proof/today.json",
                ("TODAY-001",),
            ),
        )

        report = build_traceability(current, self.root, references)
        record = report.records[0]

        self.assertEqual(record.verification_ids, ("PROOF-TODAY-001", "SCENARIO-TODAY-001"))
        self.assertEqual(tuple(item.reference_id for item in record.test_references), ("TEST-TODAY",))
        self.assertEqual(tuple(item.reference_id for item in record.proof_references), ("PROOF-TODAY",))

    def test_declared_verification_is_required_future_work_not_current_mapping(self):
        item = requirement(
            "TODAY-001",
            verification=("SCENARIO-TODAY-001", "PROOF-TODAY-001"),
        )
        current = registry((document("SURFACE-TODAY", (item,)),))

        outputs = render_traceability_maps(
            build_traceability(current, self.root, ())
        )
        test_row = json.loads(outputs[Path("law-test-map.json")])["mappings"][0]
        proof_row = json.loads(outputs[Path("law-proof-map.json")])["mappings"][0]

        self.assertEqual(test_row["required_verification_ids"], ["SCENARIO-TODAY-001"])
        self.assertEqual(proof_row["required_verification_ids"], ["PROOF-TODAY-001"])
        self.assertEqual(test_row["references"], [])
        self.assertEqual(proof_row["references"], [])
        self.assertEqual(test_row["mapping_status"], "gap")
        self.assertEqual(proof_row["mapping_status"], "gap")
        self.assertEqual(test_row["current_claim_posture"], "required_but_unverified")
        self.assertEqual(proof_row["current_claim_posture"], "required_but_unverified")
        self.assertNotIn("verification_ids", test_row)
        self.assertNotIn("verification_ids", proof_row)

    def test_current_reference_mapping_and_source_posture_are_explicit(self):
        source = self.root / "Native/Ambitions/Surfaces/Today/TodayView.swift"
        source.parent.mkdir(parents=True)
        source.write_text("struct TodayView {}\n", encoding="utf-8")
        item = requirement("TODAY-001", verification=("SCENARIO-TODAY-001",))
        current = registry(
            (
                document(
                    "SURFACE-TODAY",
                    (item,),
                    source_owners=("Native/Ambitions/Surfaces/Today/",),
                ),
            )
        )
        references = (
            reference(
                "TEST-TODAY",
                AuthorityReferenceKind.TEST,
                "tests/canon/test_traceability.py",
                ("TODAY-001",),
            ),
        )

        outputs = render_traceability_maps(
            build_traceability(current, self.root, references)
        )
        source_row = json.loads(outputs[Path("law-source-map.json")])["mappings"][0]
        test_row = json.loads(outputs[Path("law-test-map.json")])["mappings"][0]

        self.assertEqual(source_row["current_claim_posture"], "source_present_unverified")
        self.assertEqual(test_row["mapping_status"], "mapped")
        self.assertEqual(test_row["current_claim_posture"], "current_evidence_mapped")

    def test_generated_maps_are_sorted_by_requirement_id_and_newline_terminated(self):
        second = requirement("ZZZ-002", concept="surface.today.second", line=30)
        first = requirement("AAA-001", concept="surface.today.first", line=20)
        current = registry(
            (
                document(
                    "SURFACE-TODAY",
                    (second, first),
                    concepts=("surface.today.first", "surface.today.second"),
                ),
            )
        )
        report = build_traceability(current, self.root, ())

        outputs = render_traceability_maps(report)

        for name in ("law-source-map.json", "law-test-map.json", "law-proof-map.json"):
            payload = json.loads(outputs[Path(name)])
            self.assertEqual(
                [item["requirement_id"] for item in payload["mappings"]],
                ["AAA-001", "ZZZ-002"],
            )
            self.assertTrue(outputs[Path(name)].endswith(b"\n"))

    def test_generated_finding_inventory_preserves_all_four_directional_classes(self):
        item = requirement("TODAY-001")
        current = registry(
            (
                document(
                    "SURFACE-TODAY",
                    (item,),
                    source_owners=("Native/Ambitions/Surfaces/Today/",),
                ),
            )
        )
        (self.root / "Native/Ambitions/Surfaces/Today").mkdir(parents=True)
        loose = self.root / "Native/Ambitions/Unowned/Loose.swift"
        loose.parent.mkdir(parents=True)
        loose.write_text("struct Loose {}\n", encoding="utf-8")
        references = (
            AuthorityReference(
                schema_version=1,
                reference_id="FIGMA:FILE:1:2",
                authority_class=AuthorityClass.FIGMA,
                reference_kind=AuthorityReferenceKind.FIGMA,
                source="figma:FILE:1:2",
                revision="1:2",
                requirement_ids=("UNKNOWN-FIGMA-001",),
                approval_state="approved",
                approved_by="Fixture owner",
                implementation_status="fixture; not implementation proof",
                authority_role=FigmaAuthorityRole.APPROVED_TARGET,
            ),
            AuthorityReference(
                schema_version=1,
                reference_id="LINEAR:DOC",
                authority_class=AuthorityClass.LINEAR,
                reference_kind=AuthorityReferenceKind.LINEAR,
                source="linear:doc",
                revision="v1",
                requirement_ids=("UNKNOWN-LINEAR-001",),
                approval_state="approved",
                approved_by="Fixture owner",
                implementation_status="fixture; not implementation proof",
            ),
        )

        report = build_traceability(current, self.root, references)
        outputs = render_traceability_maps(report)
        source = json.loads(outputs[Path("law-source-map.json")])

        classes = {item["gap_class"] for item in source["finding_inventory"]}
        self.assertEqual(
            classes,
            {"canon_to_code", "code_to_canon", "figma_to_canon", "linear_to_canon"},
        )
        for finding in source["finding_inventory"]:
            self.assertEqual(
                set(finding),
                {"affected_ids", "code", "gap_class", "message", "path", "severity"},
            )

    def test_traceability_input_snapshot_detects_live_inventory_change(self):
        from tools.ambitions_canon.external_authority import ExternalReferenceSnapshot
        from tools.ambitions_canon.traceability import (
            capture_traceability_input_snapshot,
            validate_traceability_input_snapshot,
        )

        item = requirement("TODAY-001")
        current = registry(
            (
                document(
                    "SURFACE-TODAY",
                    (item,),
                    source_owners=("Native/Ambitions/Surfaces/Today/",),
                ),
            )
        )
        reference_snapshot = ExternalReferenceSnapshot((), (), "a" * 64)
        before = capture_traceability_input_snapshot(
            current, self.root, reference_snapshot
        )
        source = self.root / "Native/Ambitions/Surfaces/Today/TodayView.swift"
        source.parent.mkdir(parents=True)
        source.write_text("struct TodayView {}\n", encoding="utf-8")
        after = capture_traceability_input_snapshot(
            current, self.root, reference_snapshot
        )

        self.assertNotEqual(before.input_sha, after.input_sha)
        with self.assertRaises(Exception) as raised:
            validate_traceability_input_snapshot(current, self.root, before)
        self.assertEqual(raised.exception.code, "CANON_TRACEABILITY_INPUT_CHANGED")

    def write_build_fixture(self, *, figma_requirement: str = "TODAY-001") -> None:
        canon_root = self.root / "docs/canon"
        canon_root.mkdir(parents=True)
        (canon_root / "MANIFEST.toml").write_text(
            manifest_text(("specifications/today.md",)), encoding="utf-8"
        )
        specification = document_text(
            "SURFACE-TODAY", "surface.today", "TODAY-001"
        )
        path = canon_root / "specifications/today.md"
        path.parent.mkdir(parents=True)
        path.write_text(specification, encoding="utf-8")
        write_required_governance_artifacts(
            canon_root,
            canon_revision=0,
            requirement_ids=("TODAY-001",),
        )
        references = canon_root / "references"
        references.mkdir(exist_ok=True)
        (references / "linear.toml").write_text(
            'schema_version = 1\nkind = "linear"\nreferences = []\n',
            encoding="utf-8",
        )
        (references / "proof-sources.toml").write_text(
            'schema_version = 1\nkind = "proof"\nreferences = []\n',
            encoding="utf-8",
        )
        (references / "figma.toml").write_text(
            f'''schema_version = 1
kind = "figma"

[[references]]
reference_id = "FIGMA:FILE:1:2"
source = "figma:FILE:1:2"
revision = "1:2"
requirement_ids = ["{figma_requirement}"]
authority_role = "approved_target"
approval_state = "approved"
approved_by = "Fixture owner"
implementation_status = "fixture; not implementation proof"
''',
            encoding="utf-8",
        )

    def write_linear_external_authority_fixture(
        self,
        *,
        reconciliation_requirement: str = "TODAY-001",
        reconciliation_revision: str = "fixture-v1",
        external_mutations_applied: bool = False,
    ) -> None:
        self.write_build_fixture()
        references = self.root / "docs/canon/references"
        (references / "linear.toml").write_text(
            '''schema_version = 1
kind = "linear"

[[references]]
reference_id = "LINEAR:fixture-document"
source = "linear:fixture-document"
revision = "fixture-v1"
requirement_ids = ["TODAY-001"]
approval_state = "approved"
approved_by = "Fixture owner"
implementation_status = "migration corpus; not implementation proof"
''',
            encoding="utf-8",
        )
        reconciliation = {
            "schema_version": 1,
            "canon_revision": 0,
            "authority_state": "shadow",
            "disposition_state": "proposed_not_applied_owner_gate",
            "external_mutations_applied": external_mutations_applied,
            "generated_from": {
                "inventory_date": "2026-07-13",
                "method": "live_linear_oauth_reads",
            },
            "content_checksum_contract": {
                "algorithm": "sha256",
                "encoding": "utf-8",
                "json_ensure_ascii": False,
                "json_key_order": ["title", "content", "summary"],
                "json_separators": [",", ":"],
                "null_or_absent_text": "",
                "terminal_newline": False,
                "extractors": {
                    "comment": ["derived_parent_title", "body", ""],
                    "document": ["title", "content", ""],
                    "initiative": ["name", "description", "summary"],
                    "issue": ["title", "description", ""],
                    "milestone": ["name", "description", ""],
                    "project": ["name", "description", "summary"],
                    "status_update": ["derived_parent_title", "body", ""],
                },
                "offline_validation": "format_and_internal_bindings_only",
                "write_time_guard": "fresh_connector_read_and_exact_recomputation_required",
            },
            "inventory_scope": {
                "pilot_named_entity": "fixture-document",
                "pilot_live_entity_type": "document",
                "pilot_plan_label_type": "document",
                "linked_pilot_projects": [],
                "active_related_initiatives": [],
                "issue_filter": "fixture",
                "raw_exports_tracked": False,
                "limitations": ["fixture inventory"],
            },
            "allowed_actions": [
                "keep_execution_reference",
                "rewrite_to_requirement_references",
                "delete_after_extraction",
                "retain_provenance_only",
                "owner_review",
                "archive_after_extraction",
            ],
            "action_rules": {
                "all_external_actions": "owner approval and fresh hash verification required",
                "archive_after_extraction": "temporary Yellow only when deletion is unavailable; manual deletion remains required",
                "destructive_actions": "deferred to Gate C and not authorized by this manifest",
            },
            "pilot_decision_required": {
                "mismatch": "fixture type check",
                "options": [
                    {"option_id": "fixture", "entity_ids": ["fixture-document"]}
                ],
                "recommended_option": "fixture",
                "rationale": "fixture owner review",
            },
            "inventory_counts": {"document": 1},
            "batches": [
                {
                    "batch_id": "fixture-owner-gate",
                    "action": "owner_review",
                    "entity_ids": ["fixture-document"],
                    "status": "not_applied",
                }
            ],
            "entities": [
                {
                    "entity_id": "fixture-document",
                    "entity_type": "document",
                    "title": "Fixture Linear document",
                    "parent_id": None,
                    "claimed_authority": "fixture_migration_provenance",
                    "represented_requirement_ids": [reconciliation_requirement],
                    "unique_accepted_content_summary": "redacted_fixture_summary",
                    "current_execution_value": "migration_provenance",
                    "recommended_action": "retain_provenance_only",
                    "action_status": "proposed_not_applied",
                    "replacement_ids": [],
                    "owner_approval_required": True,
                    "live_metadata": {
                        "created_at": "fixture-created",
                        "updated_at": reconciliation_revision,
                        "status": "active",
                    },
                    "content_sha256": "0" * 64,
                }
            ],
        }
        migration = self.root / "docs/canon/migration"
        migration.mkdir(exist_ok=True)
        (migration / "linear-reconciliation.json").write_text(
            json.dumps(reconciliation, sort_keys=True) + "\n",
            encoding="utf-8",
        )

    def run_cli(self, arguments: list[str]) -> tuple[int, str]:
        previous = Path.cwd()
        output = StringIO()
        try:
            import os

            os.chdir(self.root)
            with redirect_stdout(output):
                code = main(arguments)
        finally:
            os.chdir(previous)
        return code, output.getvalue()

    def write_applied_pilot_fixture(self) -> None:
        self.write_linear_external_authority_fixture()
        path = self.root / "docs/canon/migration/linear-reconciliation.json"
        data = json.loads(path.read_text(encoding="utf-8"))
        document = data["entities"][0]
        project = json.loads(json.dumps(document))
        project.update(
            {
                "entity_id": "fixture-project",
                "entity_type": "project",
                "title": "Fixture project",
                "parent_id": None,
                "claimed_authority": "fixture_execution_container",
                "content_sha256": "1" * 64,
            }
        )
        comment = json.loads(json.dumps(document))
        comment.update(
            {
                "entity_id": "fixture-comment",
                "entity_type": "comment",
                "title": "Fixture comment",
                "parent_id": "fixture-document",
                "claimed_authority": "fixture_provenance",
                "content_sha256": "2" * 64,
            }
        )
        for entity in (document, project):
            entity["recommended_action"] = "rewrite_to_requirement_references"
            entity["action_status"] = "applied_verified"
        data["entities"] = [comment, document, project]
        data["inventory_counts"] = {"comment": 1, "document": 1, "project": 1}
        data["disposition_state"] = "pilot_applied_verified_broader_withheld"
        data["external_mutations_applied"] = True
        data["pilot_decision_required"]["options"] = [
            {
                "option_id": "bounded-pair",
                "entity_ids": ["fixture-document", "fixture-project"],
            }
        ]
        data["pilot_decision_required"]["recommended_option"] = "bounded-pair"
        data["batches"] = [
            {
                "batch_id": "fixture-owner-gate",
                "action": "rewrite_to_requirement_references",
                "entity_ids": ["fixture-document", "fixture-project"],
                "status": "applied_verified",
            },
            {
                "batch_id": "fixture-broader-withheld",
                "action": "retain_provenance_only",
                "entity_ids": ["fixture-comment"],
                "status": "withheld_not_authorized",
            },
        ]
        data["pilot_execution"] = {
            "approved_option": "bounded-pair",
            "approval_scope": "exact_reviewed_bytes_only",
            "broader_actions": "withheld_not_authorized",
            "destructive_actions": "withheld_gate_c",
            "entity_ids": ["fixture-document", "fixture-project"],
            "status": "applied_verified",
        }
        path.write_text(json.dumps(data, sort_keys=True) + "\n", encoding="utf-8")

    def write_applied_initiative_fixture(self) -> None:
        self.write_linear_external_authority_fixture()
        path = self.root / "docs/canon/migration/linear-reconciliation.json"
        data = json.loads(path.read_text(encoding="utf-8"))
        initiative = data["entities"][0]
        initiative.update(
            {
                "entity_id": "fixture-document",
                "entity_type": "initiative",
                "title": "Fixture initiative",
                "recommended_action": "rewrite_to_requirement_references",
                "action_status": "applied_verified",
                "content_sha256": "3" * 64,
            }
        )
        project = json.loads(json.dumps(initiative))
        project.update(
            {
                "entity_id": "fixture-project",
                "entity_type": "project",
                "title": "Fixture project",
                "parent_id": "fixture-document",
                "action_status": "proposed_not_applied",
                "content_sha256": "4" * 64,
            }
        )
        comment = json.loads(json.dumps(initiative))
        comment.update(
            {
                "entity_id": "fixture-comment",
                "entity_type": "comment",
                "title": "Fixture comment",
                "parent_id": "fixture-document",
                "recommended_action": "retain_provenance_only",
                "action_status": "proposed_not_applied",
                "content_sha256": "5" * 64,
            }
        )
        data["entities"] = [comment, initiative, project]
        data["inventory_counts"] = {"comment": 1, "initiative": 1, "project": 1}
        data["disposition_state"] = "initiative_applied_verified_broader_withheld"
        data["external_mutations_applied"] = True
        data["pilot_decision_required"]["options"] = [
            {
                "option_id": "bounded-pair",
                "entity_ids": ["fixture-document", "fixture-project"],
            },
            {
                "option_id": "initiative-only",
                "entity_ids": ["fixture-document"],
            },
        ]
        data["pilot_decision_required"]["recommended_option"] = "bounded-pair"
        data["batches"] = [
            {
                "batch_id": "fixture-bounded-pair-owner-gate",
                "action": "owner_review",
                "entity_ids": ["fixture-document", "fixture-project"],
                "status": "withheld_not_authorized",
            },
            {
                "batch_id": "fixture-initiative-owner-gate",
                "action": "rewrite_to_requirement_references",
                "entity_ids": ["fixture-document"],
                "status": "applied_verified",
            },
            {
                "batch_id": "fixture-broader-withheld",
                "action": "retain_provenance_only",
                "entity_ids": ["fixture-comment"],
                "status": "withheld_not_authorized",
            },
        ]
        data["initiative_execution"] = {
            "approved_option": "initiative-only",
            "approval_authority": "controller_on_owner_behalf_under_tasks_22_29_delegation",
            "approval_review": "INITIATIVE_GATE_CLEAN",
            "broader_actions": "withheld_not_authorized",
            "destructive_actions": "withheld_gate_c",
            "entity_id": "fixture-document",
            "status": "applied_verified",
            "validation": "dedicated_full_read_exact",
            "before_bytes": 428,
            "before_raw_sha256": "6" * 64,
            "before_canonical_sha256": "7" * 64,
            "before_updated_at": "fixture-before",
            "after_bytes": 2431,
            "after_raw_sha256": "8" * 64,
            "after_canonical_sha256": "3" * 64,
            "after_updated_at": "fixture-v1",
            "after_terminal_lf": False,
        }
        path.write_text(json.dumps(data, sort_keys=True) + "\n", encoding="utf-8")

    def test_external_authority_linear_check_is_offline_deterministic_and_green(self):
        self.write_linear_external_authority_fixture()

        first = self.run_cli(["external-authority", "--kind", "linear", "--check"])
        second = self.run_cli(["external-authority", "--kind", "linear", "--check"])

        self.assertEqual(first, second)
        self.assertEqual(first[0], 0)
        self.assertEqual(
            first[1],
            "GREEN ambitions canon external-authority kind=linear references=1 "
            "reconciliation_entities=1 authority_state=shadow\n",
        )

    def test_external_authority_allows_absent_update_metadata_for_unreferenced_entity(self):
        self.write_linear_external_authority_fixture()
        path = self.root / "docs/canon/migration/linear-reconciliation.json"
        reconciliation = json.loads(path.read_text(encoding="utf-8"))
        milestone = dict(reconciliation["entities"][0])
        milestone.update(
            {
                "entity_id": "fixture-milestone",
                "entity_type": "milestone",
                "title": "Fixture milestone",
                "live_metadata": {
                    "created_at": "fixture-created",
                    "updated_at": None,
                    "status": "progress:0%",
                },
            }
        )
        reconciliation["entities"].append(milestone)
        reconciliation["inventory_counts"] = {"document": 1, "milestone": 1}
        path.write_text(
            json.dumps(reconciliation, sort_keys=True) + "\n", encoding="utf-8"
        )

        code, output = self.run_cli(
            ["external-authority", "--kind", "linear", "--check"]
        )

        self.assertEqual(code, 0)
        self.assertIn("reconciliation_entities=2", output)

    def test_external_authority_figma_kind_uses_shared_offline_check_contract(self):
        self.write_build_fixture()

        code, output = self.run_cli(
            ["external-authority", "--kind", "figma", "--check"]
        )

        self.assertEqual(code, 0)
        self.assertEqual(
            output,
            "GREEN ambitions canon external-authority kind=figma references=1 "
            "reconciliation_entities=0 authority_state=shadow\n",
        )

    def test_external_authority_linear_check_rejects_invalid_reconciliation_state(self):
        self.write_linear_external_authority_fixture(external_mutations_applied=True)

        code, output = self.run_cli(
            ["external-authority", "--kind", "linear", "--check"]
        )

        self.assertEqual(code, 1)
        self.assertIn("CANON_LINEAR_RECONCILIATION_STATE", output)

    def test_external_authority_linear_check_rejects_stale_reference_revision(self):
        self.write_linear_external_authority_fixture(
            reconciliation_revision="fixture-v2"
        )

        code, output = self.run_cli(
            ["external-authority", "--kind", "linear", "--check"]
        )

        self.assertEqual(code, 1)
        self.assertIn("CANON_LINEAR_RECONCILIATION_STALE", output)

    def test_external_authority_linear_check_rejects_unknown_requirement(self):
        self.write_linear_external_authority_fixture(
            reconciliation_requirement="UNKNOWN-001"
        )

        code, output = self.run_cli(
            ["external-authority", "--kind", "linear", "--check"]
        )

        self.assertEqual(code, 1)
        self.assertIn("CANON_LINEAR_RECONCILIATION_REQUIREMENT_UNKNOWN", output)

    def test_external_authority_linear_schema_is_closed_at_every_layer(self):
        mutations = {
            "root extra": lambda data: data.__setitem__("raw_export", "forbidden"),
            "root missing": lambda data: data.pop("generated_from"),
            "batch extra": lambda data: data["batches"][0].__setitem__(
                "approval", "implicit"
            ),
            "batch missing": lambda data: data["batches"][0].pop("status"),
            "entity extra": lambda data: data["entities"][0].__setitem__(
                "content", "raw content"
            ),
            "entity missing": lambda data: data["entities"][0].pop(
                "claimed_authority"
            ),
            "metadata extra": lambda data: data["entities"][0][
                "live_metadata"
            ].__setitem__("priority", "High"),
            "metadata missing": lambda data: data["entities"][0][
                "live_metadata"
            ].pop("created_at"),
            "checksum extra": lambda data: data["content_checksum_contract"].__setitem__(
                "serializer", "ambiguous"
            ),
        }
        self.write_linear_external_authority_fixture()
        path = self.root / "docs/canon/migration/linear-reconciliation.json"
        baseline = json.loads(path.read_text(encoding="utf-8"))
        for label, mutate in mutations.items():
            with self.subTest(label=label):
                data = json.loads(json.dumps(baseline))
                mutate(data)
                path.write_text(json.dumps(data, sort_keys=True) + "\n", encoding="utf-8")

                code, output = self.run_cli(
                    ["external-authority", "--kind", "linear", "--check"]
                )

                self.assertEqual(code, 1)
                self.assertIn("CANON_LINEAR_RECONCILIATION_STATE", output)

    def test_external_authority_linear_rejects_invalid_enums_duplicates_and_counts(self):
        mutations = {
            "entity type": lambda data: data["entities"][0].__setitem__(
                "entity_type", "workspace"
            ),
            "action": lambda data: data["entities"][0].__setitem__(
                "recommended_action", "publish"
            ),
            "duplicate entity": lambda data: data["entities"].append(
                dict(data["entities"][0])
            ),
            "count drift": lambda data: data.__setitem__(
                "inventory_counts", {"document": 2}
            ),
            "approval": lambda data: data["entities"][0].__setitem__(
                "owner_approval_required", False
            ),
        }
        self.write_linear_external_authority_fixture()
        path = self.root / "docs/canon/migration/linear-reconciliation.json"
        baseline = json.loads(path.read_text(encoding="utf-8"))
        for label, mutate in mutations.items():
            with self.subTest(label=label):
                data = json.loads(json.dumps(baseline))
                mutate(data)
                path.write_text(json.dumps(data, sort_keys=True) + "\n", encoding="utf-8")

                code, output = self.run_cli(
                    ["external-authority", "--kind", "linear", "--check"]
                )

                self.assertEqual(code, 1)
                self.assertIn("CANON_LINEAR_RECONCILIATION_STATE", output)

    def test_external_authority_linear_rejects_destructive_action_before_gate_c(self):
        self.write_linear_external_authority_fixture()
        path = self.root / "docs/canon/migration/linear-reconciliation.json"
        data = json.loads(path.read_text(encoding="utf-8"))
        data["entities"][0]["recommended_action"] = "delete_after_extraction"
        data["entities"][0]["replacement_ids"] = ["replacement"]
        data["batches"][0]["action"] = "delete_after_extraction"
        path.write_text(json.dumps(data, sort_keys=True) + "\n", encoding="utf-8")

        code, output = self.run_cli(
            ["external-authority", "--kind", "linear", "--check"]
        )

        self.assertEqual(code, 1)
        self.assertIn("CANON_LINEAR_RECONCILIATION_STATE", output)

    def test_external_authority_linear_accepts_exact_two_applied_pilot_records(self):
        self.write_applied_pilot_fixture()

        code, output = self.run_cli(
            ["external-authority", "--kind", "linear", "--check"]
        )

        self.assertEqual(code, 0)
        self.assertIn("reconciliation_entities=3", output)

    def test_external_authority_linear_accepts_exact_one_applied_initiative_record(self):
        self.write_applied_initiative_fixture()

        code, output = self.run_cli(
            ["external-authority", "--kind", "linear", "--check"]
        )

        self.assertEqual(code, 0)
        self.assertIn("reconciliation_entities=3", output)

    def test_external_authority_linear_rejects_initiative_receipt_after_hash_mismatch(self):
        self.write_applied_initiative_fixture()
        path = self.root / "docs/canon/migration/linear-reconciliation.json"
        data = json.loads(path.read_text(encoding="utf-8"))
        data["initiative_execution"]["after_canonical_sha256"] = "9" * 64
        path.write_text(json.dumps(data, sort_keys=True) + "\n", encoding="utf-8")

        code, output = self.run_cli(
            ["external-authority", "--kind", "linear", "--check"]
        )

        self.assertEqual(code, 1)
        self.assertIn("CANON_LINEAR_RECONCILIATION_STATE", output)

    def test_external_authority_linear_rejects_initiative_receipt_after_revision_mismatch(self):
        self.write_applied_initiative_fixture()
        path = self.root / "docs/canon/migration/linear-reconciliation.json"
        data = json.loads(path.read_text(encoding="utf-8"))
        data["initiative_execution"]["after_updated_at"] = "fixture-after"
        path.write_text(json.dumps(data, sort_keys=True) + "\n", encoding="utf-8")

        code, output = self.run_cli(
            ["external-authority", "--kind", "linear", "--check"]
        )

        self.assertEqual(code, 1)
        self.assertIn("CANON_LINEAR_RECONCILIATION_STATE", output)

    def test_external_authority_linear_rejects_non_initiative_execution_entity(self):
        self.write_applied_initiative_fixture()
        path = self.root / "docs/canon/migration/linear-reconciliation.json"
        data = json.loads(path.read_text(encoding="utf-8"))
        data["entities"][1]["entity_type"] = "document"
        data["inventory_counts"] = {"comment": 1, "document": 1, "project": 1}
        path.write_text(json.dumps(data, sort_keys=True) + "\n", encoding="utf-8")

        code, output = self.run_cli(
            ["external-authority", "--kind", "linear", "--check"]
        )

        self.assertEqual(code, 1)
        self.assertIn("CANON_LINEAR_RECONCILIATION_STATE", output)

    def test_external_authority_linear_initiative_only_state_fails_closed(self):
        mutations = {
            "initiative proposed": lambda data: data["entities"][1].__setitem__(
                "action_status", "proposed_not_applied"
            ),
            "project applied": lambda data: data["entities"][2].__setitem__(
                "action_status", "applied_verified"
            ),
            "bounded pair falsely complete": lambda data: data["batches"][0].__setitem__(
                "status", "applied_verified"
            ),
            "initiative batch not applied": lambda data: data["batches"][1].__setitem__(
                "status", "withheld_not_authorized"
            ),
            "execution points to project": lambda data: data[
                "initiative_execution"
            ].__setitem__("entity_id", "fixture-project"),
            "wrong approval option": lambda data: data[
                "initiative_execution"
            ].__setitem__("approved_option", "bounded-pair"),
            "missing delegated approval": lambda data: data[
                "initiative_execution"
            ].pop("approval_review"),
            "terminal LF accepted": lambda data: data[
                "initiative_execution"
            ].__setitem__("after_terminal_lf", True),
        }
        self.write_applied_initiative_fixture()
        path = self.root / "docs/canon/migration/linear-reconciliation.json"
        baseline = json.loads(path.read_text(encoding="utf-8"))
        for label, mutate in mutations.items():
            with self.subTest(label=label):
                data = json.loads(json.dumps(baseline))
                mutate(data)
                path.write_text(
                    json.dumps(data, sort_keys=True) + "\n", encoding="utf-8"
                )

                code, output = self.run_cli(
                    ["external-authority", "--kind", "linear", "--check"]
                )

                self.assertEqual(code, 1)
                self.assertIn("CANON_LINEAR_RECONCILIATION_STATE", output)

    def test_external_authority_linear_mixed_state_fails_closed(self):
        mutations = {
            "one applied": lambda data: data["entities"][1].__setitem__(
                "action_status", "proposed_not_applied"
            ),
            "three applied": lambda data: data["entities"][0].__setitem__(
                "action_status", "applied_verified"
            ),
            "mutation flag false": lambda data: data.__setitem__(
                "external_mutations_applied", False
            ),
            "pilot batch not applied": lambda data: data["batches"][0].__setitem__(
                "status", "not_applied"
            ),
            "broader batch applied": lambda data: data["batches"][1].__setitem__(
                "status", "applied_verified"
            ),
        }
        self.write_applied_pilot_fixture()
        path = self.root / "docs/canon/migration/linear-reconciliation.json"
        baseline = json.loads(path.read_text(encoding="utf-8"))
        for label, mutate in mutations.items():
            with self.subTest(label=label):
                data = json.loads(json.dumps(baseline))
                mutate(data)
                path.write_text(
                    json.dumps(data, sort_keys=True) + "\n", encoding="utf-8"
                )

                code, output = self.run_cli(
                    ["external-authority", "--kind", "linear", "--check"]
                )

                self.assertEqual(code, 1)
                self.assertIn("CANON_LINEAR_RECONCILIATION_STATE", output)

    def test_build_rejects_invalid_external_requirement_reference(self):
        self.write_build_fixture(figma_requirement="UNKNOWN-001")

        with self.assertRaises(Exception) as raised:
            build_canon(self.root)

        self.assertEqual(raised.exception.code, "CANON_FIGMA_REQUIREMENT_UNKNOWN")

    def test_build_keeps_current_posture_gaps_nonfatal(self):
        self.write_build_fixture()

        self.assertEqual(build_canon(self.root), ())

    def test_build_revalidates_pinned_external_and_inventory_snapshots(self):
        from tools.ambitions_canon.external_authority import (
            validate_external_reference_snapshot,
        )
        from tools.ambitions_canon.traceability import (
            validate_traceability_input_snapshot,
        )

        self.write_build_fixture()
        with mock.patch(
            "tools.ambitions_canon.external_authority.validate_external_reference_snapshot",
            wraps=validate_external_reference_snapshot,
        ) as external_validate, mock.patch(
            "tools.ambitions_canon.traceability.validate_traceability_input_snapshot",
            wraps=validate_traceability_input_snapshot,
        ) as inventory_validate:
            self.assertEqual(build_canon(self.root), ())

        self.assertGreaterEqual(external_validate.call_count, 2)
        self.assertGreaterEqual(inventory_validate.call_count, 2)

    def test_build_revalidates_pinned_linear_reconciliation_snapshot(self):
        from tools.ambitions_canon.external_authority import (
            validate_linear_reconciliation_snapshot,
        )

        self.write_linear_external_authority_fixture()
        with mock.patch(
            "tools.ambitions_canon.external_authority.validate_linear_reconciliation_snapshot",
            wraps=validate_linear_reconciliation_snapshot,
        ) as linear_validate:
            self.assertEqual(build_canon(self.root), ())

        self.assertGreaterEqual(linear_validate.call_count, 2)

    def test_gap_families_remain_distinct(self):
        item = requirement("TODAY-001")
        current = registry(
            (
                document(
                    "SURFACE-TODAY",
                    (item,),
                    source_owners=("Native/Ambitions/Surfaces/Today/",),
                ),
            )
        )
        (self.root / "Native/Ambitions/Surfaces/Today").mkdir(parents=True)
        (self.root / "Native/Ambitions/Unowned").mkdir(parents=True)
        (self.root / "Native/Ambitions/Unowned/Loose.swift").write_text(
            "struct Loose {}\n", encoding="utf-8"
        )

        report = build_traceability(current, self.root, ())
        classes = {
            finding.message.split("gap_class=", 1)[1].split()[0]
            for finding in report.findings
            if "gap_class=" in finding.message
        }

        self.assertIn("canon_to_code", classes)
        self.assertIn("code_to_canon", classes)
        self.assertNotIn("missing", classes)

    def test_traceability_check_accepts_generated_posture_gaps_without_upgrading_them(self):
        previous = Path.cwd()
        output = StringIO()
        try:
            import os

            os.chdir(ROOT)
            with redirect_stdout(output):
                code = main(["traceability", "--check"])
        finally:
            os.chdir(previous)

        self.assertEqual(code, 0)
        self.assertIn("GREEN ambitions canon traceability", output.getvalue())
        self.assertIn("posture_gaps=", output.getvalue())


if __name__ == "__main__":
    unittest.main()
