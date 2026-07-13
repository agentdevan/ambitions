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
