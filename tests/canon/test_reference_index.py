import unittest
import json
import tempfile
import hashlib
import os
from contextlib import redirect_stdout
from io import StringIO
from pathlib import Path
from dataclasses import replace

from tests.canon.test_impact import document, registry, requirement
from tools.ambitions_canon.impact import impact_report
from tools.ambitions_canon.build import _registry_content_sha
from tools.ambitions_canon.build import build_canon
from tools.ambitions_canon.cli import main
from tools.ambitions_canon.registry import build_registry
from tools.ambitions_canon.reference_index import parse_reference_index_bytes
from tests.canon.test_supersession import manifest, write_ledger
from tools.ambitions_canon.model import (
    AuthorityClass,
    AuthorityReference,
    AuthorityReferenceKind,
    CanonError,
    GapSeverity,
    ImpactReferenceIndex,
    SpecificationGapRecord,
    TaskPackReference,
)
from tests.canon.canon_test_support import write_required_governance_artifacts
from tests.canon.test_build import document_text, manifest_text


def complete_index(
    *,
    references: tuple[AuthorityReference, ...] = (),
    task_packs: tuple[TaskPackReference, ...] = (),
    gaps: tuple[SpecificationGapRecord, ...] = (),
    indexed_ids: tuple[str, ...] | None = None,
    specification_ids: tuple[str, ...] = (),
) -> ImpactReferenceIndex:
    requirement_ids = (
        tuple(sorted(indexed_ids))
        if indexed_ids is not None
        else tuple(
            sorted(
                {
                    identifier
                    for item in (*references, *task_packs)
                    for identifier in item.requirement_ids
                }
            )
        )
    )
    payload = {
        "schema_version": 1,
        "canon_revision": 1,
        "indexed_requirement_ids": list(requirement_ids),
        "authority_references": [
            {
                "schema_version": item.schema_version,
                "reference_id": item.reference_id,
                "authority_class": item.authority_class.value,
                "reference_kind": item.reference_kind.value,
                "source": item.source,
                "revision": item.revision,
                "requirement_ids": list(item.requirement_ids),
                "approval_state": item.approval_state,
                **(
                    {"approved_by": item.approved_by}
                    if item.approved_by is not None
                    else {}
                ),
                **(
                    {"implementation_status": item.implementation_status}
                    if item.implementation_status is not None
                    else {}
                ),
            }
            for item in sorted(references, key=lambda item: item.reference_id)
        ],
        "task_packs": [
            {
                "schema_version": item.schema_version,
                "pack_id": item.pack_id,
                "source": item.source,
                "canon_revision": item.canon_revision,
                "canon_sha": item.canon_sha,
                "requirement_ids": list(item.requirement_ids),
            }
            for item in sorted(task_packs, key=lambda item: item.pack_id)
        ],
        "specification_gaps": [
            {
                "gap_id": item.gap_id,
                "severity": item.severity.value,
                "affected_ids": list(item.affected_ids),
                "message": item.message,
            }
            for item in sorted(gaps, key=lambda item: item.gap_id)
        ],
    }
    source_bytes = (
        json.dumps(payload, ensure_ascii=False, sort_keys=True, indent=2) + "\n"
    ).encode("utf-8")
    return parse_reference_index_bytes(
        source_bytes,
        Path("docs/canon/migration/impact-reference-index.json"),
        canon_revision=1,
        requirement_ids=requirement_ids,
        specification_ids=specification_ids,
    )


def write_index(
    root: Path,
    *,
    canon_revision: int = 1,
    indexed_ids: tuple[str, ...] = (),
    authority_references: list[dict[str, object]] | None = None,
    task_packs: list[dict[str, object]] | None = None,
    gaps: list[dict[str, object]] | None = None,
) -> Path:
    payload = {
        "schema_version": 1,
        "canon_revision": canon_revision,
        "indexed_requirement_ids": list(indexed_ids),
        "authority_references": authority_references or [],
        "task_packs": task_packs or [],
        "specification_gaps": gaps or [],
    }
    path = root / "docs/canon/migration/impact-reference-index.json"
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(
        json.dumps(payload, ensure_ascii=False, sort_keys=True, indent=2) + "\n",
        encoding="utf-8",
    )
    return path


class StructuredImpactReferenceTests(unittest.TestCase):
    def test_build_registry_rejects_unknown_nested_ids_and_stale_pack_revision(self):
        item = requirement("TODAY-001")
        docs = (document("SURFACE-TODAY", (item,)),)
        authority = {
            "schema_version": 1,
            "reference_id": "REF-TODAY-SOURCE",
            "authority_class": "source_and_tests",
            "reference_kind": "source",
            "source": "Native/Ambitions/Surfaces/Today/",
            "revision": "git:abc1234",
            "requirement_ids": ["UNKNOWN-1"],
            "approval_state": "approved",
        }
        pack = {
            "schema_version": 1,
            "pack_id": "PACK-AMB-1901",
            "source": ".codex/canon-packs/amb-1901.md",
            "canon_revision": 1,
            "canon_sha": "a" * 64,
            "requirement_ids": ["UNKNOWN-1"],
        }
        gap = {
            "gap_id": "GAP-TODAY-001",
            "severity": "P1_REQUIRED",
            "affected_ids": ["UNKNOWN-1"],
            "message": "Unknown affected identity.",
        }
        cases = (
            ("authority", [authority], [], [], "CANON_REFERENCE_INDEX_UNKNOWN_ID"),
            (
                "authority_cross_kind",
                [{**authority, "requirement_ids": ["SURFACE-TODAY"]}],
                [],
                [],
                "CANON_REFERENCE_INDEX_UNKNOWN_ID",
            ),
            ("task_pack", [], [pack], [], "CANON_REFERENCE_INDEX_UNKNOWN_ID"),
            ("gap", [], [], [gap], "CANON_REFERENCE_INDEX_UNKNOWN_ID"),
            (
                "pack_revision",
                [],
                [{**pack, "requirement_ids": ["TODAY-001"], "canon_revision": 999}],
                [],
                "CANON_REFERENCE_INDEX_STALE",
            ),
        )
        for label, references, packs, gaps, code in cases:
            with self.subTest(label=label), tempfile.TemporaryDirectory() as directory:
                root = Path(directory)
                write_ledger(
                    root,
                    "schema_version = 1\nentries = []\n",
                    indexed_requirement_ids=("TODAY-001",),
                )
                write_index(
                    root,
                    indexed_ids=("TODAY-001",),
                    authority_references=references,
                    task_packs=packs,
                    gaps=gaps,
                )

                with self.assertRaises(CanonError) as raised:
                    build_registry(manifest(root), docs)

                self.assertEqual(raised.exception.code, code)

    def test_valid_mixed_specification_and_requirement_references_ingest(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            write_ledger(
                root,
                "schema_version = 1\nentries = []\n",
                indexed_requirement_ids=("TODAY-001",),
            )
            write_index(
                root,
                indexed_ids=("TODAY-001",),
                authority_references=[
                    {
                        "schema_version": 1,
                        "reference_id": "REF-TODAY-SOURCE",
                        "authority_class": "source_and_tests",
                        "reference_kind": "source",
                        "source": "Native/Ambitions/Surfaces/Today/",
                        "revision": "git:abc1234",
                        "requirement_ids": ["TODAY-001"],
                        "approval_state": "approved",
                    }
                ],
                task_packs=[
                    {
                        "schema_version": 1,
                        "pack_id": "PACK-AMB-1901",
                        "source": ".codex/canon-packs/amb-1901.md",
                        "canon_revision": 1,
                        "canon_sha": "a" * 64,
                        "requirement_ids": ["SURFACE-TODAY", "TODAY-001"],
                    }
                ],
                gaps=[
                    {
                        "gap_id": "GAP-TODAY-001",
                        "severity": "P1_REQUIRED",
                        "affected_ids": ["SURFACE-TODAY", "TODAY-001"],
                        "message": "Mixed active identities are valid.",
                    }
                ],
            )
            item = requirement("TODAY-001")
            built = build_registry(
                manifest(root),
                (document("SURFACE-TODAY", (item,)),),
            )

            self.assertEqual(impact_report(built, built).changes, ())

    def test_public_audit_and_build_reject_unknown_nested_ids_before_use(self):
        authority = {
            "schema_version": 1,
            "reference_id": "REF-TODAY-SOURCE",
            "authority_class": "source_and_tests",
            "reference_kind": "source",
            "source": "Native/Ambitions/Surfaces/Today/",
            "revision": "git:abc1234",
            "requirement_ids": ["UNKNOWN-1"],
            "approval_state": "approved",
        }
        pack = {
            "schema_version": 1,
            "pack_id": "PACK-AMB-1901",
            "source": ".codex/canon-packs/amb-1901.md",
            "canon_revision": 0,
            "canon_sha": "a" * 64,
            "requirement_ids": ["UNKNOWN-1"],
        }
        gap = {
            "gap_id": "GAP-TODAY-001",
            "severity": "P1_REQUIRED",
            "affected_ids": ["UNKNOWN-1"],
            "message": "Unknown affected identity.",
        }
        cases = (
            ("authority", [authority], [], [], "CANON_REFERENCE_INDEX_UNKNOWN_ID"),
            ("task_pack", [], [pack], [], "CANON_REFERENCE_INDEX_UNKNOWN_ID"),
            ("gap", [], [], [gap], "CANON_REFERENCE_INDEX_UNKNOWN_ID"),
            (
                "pack_revision",
                [],
                [{**pack, "requirement_ids": ["TODAY-001"], "canon_revision": 999}],
                [],
                "CANON_REFERENCE_INDEX_STALE",
            ),
        )
        for label, references, packs, gaps, code in cases:
            with self.subTest(label=label), tempfile.TemporaryDirectory() as directory:
                root = Path(directory)
                canon_root = root / "docs/canon"
                specification = canon_root / "specifications/today.md"
                specification.parent.mkdir(parents=True)
                (canon_root / "MANIFEST.toml").write_text(
                    manifest_text(("specifications/today.md",)),
                    encoding="utf-8",
                )
                specification.write_text(
                    document_text(
                        "SURFACE-TODAY",
                        "surface.today",
                        "TODAY-001",
                    ),
                    encoding="utf-8",
                )
                write_required_governance_artifacts(
                    canon_root,
                    canon_revision=0,
                    requirement_ids=("TODAY-001",),
                )
                write_index(
                    root,
                    canon_revision=0,
                    indexed_ids=("TODAY-001",),
                    authority_references=references,
                    task_packs=packs,
                    gaps=gaps,
                )
                output = StringIO()
                previous = Path.cwd()
                try:
                    os.chdir(root)
                    with redirect_stdout(output):
                        result = main(["audit"])
                finally:
                    os.chdir(previous)

                self.assertEqual(result, 1)
                self.assertIn(code, output.getvalue())
                with self.assertRaises(CanonError) as raised:
                    build_canon(root)
                self.assertEqual(raised.exception.code, code)

    def test_caller_asserted_complete_empty_index_cannot_cover_nonempty_canon(self):
        item = requirement("TODAY-001")
        candidate = registry(
            (document("SURFACE-TODAY", (item,)),),
            reference_index=ImpactReferenceIndex(
                schema_version=1,
                complete=True,
                authority_references=(),
                task_packs=(),
                specification_gaps=(),
            ),
        )

        with self.assertRaises(CanonError) as raised:
            impact_report(candidate, candidate)

        self.assertEqual(
            raised.exception.code,
            "CANON_IMPACT_REFERENCE_INDEX_REQUIRED",
        )

    def test_build_registry_loads_provenance_bound_reference_index(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            write_ledger(root, "schema_version = 1\nentries = []\n")
            (
                root / "docs/canon/migration/impact-reference-index.json"
            ).unlink()
            index_path = write_index(
                root,
                indexed_ids=("TODAY-001",),
                authority_references=[
                    {
                        "schema_version": 1,
                        "reference_id": "REF-TODAY-SOURCE",
                        "authority_class": "source_and_tests",
                        "reference_kind": "source",
                        "source": "Native/Ambitions/Surfaces/Today/",
                        "revision": "git:abc1234",
                        "requirement_ids": ["TODAY-001"],
                        "approval_state": "approved",
                    }
                ],
            )
            item = requirement("TODAY-001")

            built = build_registry(
                manifest(root),
                (document("SURFACE-TODAY", (item,)),),
            )

            self.assertIsNotNone(built.reference_index)
            self.assertEqual(
                built.reference_index.source_bytes,
                index_path.read_bytes(),
            )
            self.assertEqual(
                built.reference_index.source_sha,
                hashlib.sha256(index_path.read_bytes()).hexdigest(),
            )
            self.assertEqual(
                built.reference_index.indexed_requirement_ids,
                ("TODAY-001",),
            )

    def test_repository_index_missing_or_stale_fails_registry_build(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            write_ledger(root, "schema_version = 1\nentries = []\n")
            (
                root / "docs/canon/migration/impact-reference-index.json"
            ).unlink()
            item = requirement("TODAY-001")
            docs = (document("SURFACE-TODAY", (item,)),)

            with self.assertRaises(CanonError) as missing:
                build_registry(manifest(root), docs)
            self.assertEqual(missing.exception.code, "CANON_REFERENCE_INDEX_MISSING")

            write_index(root, canon_revision=2, indexed_ids=("TODAY-001",))
            with self.assertRaises(CanonError) as revision:
                build_registry(manifest(root), docs)
            self.assertEqual(revision.exception.code, "CANON_REFERENCE_INDEX_STALE")

            write_index(root, canon_revision=1, indexed_ids=())
            with self.assertRaises(CanonError) as identities:
                build_registry(manifest(root), docs)
            self.assertEqual(identities.exception.code, "CANON_REFERENCE_INDEX_STALE")

    def test_reference_index_mutation_changes_registry_content_sha(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            write_ledger(root, "schema_version = 1\nentries = []\n")
            path = write_index(root)
            loaded_manifest = replace(
                manifest(root),
                source_bytes=b"manifest\n",
            )
            first = build_registry(loaded_manifest, ())
            first_sha = _registry_content_sha(first)

            payload = json.loads(path.read_text(encoding="utf-8"))
            payload["specification_gaps"] = []
            path.write_text(
                json.dumps(payload, sort_keys=True, separators=(",", ":")) + "\n",
                encoding="utf-8",
            )
            second = build_registry(loaded_manifest, ())

            self.assertNotEqual(first_sha, _registry_content_sha(second))

    def test_removal_uses_explicit_reference_kinds_and_task_pack_records(self):
        removed = requirement("TODAY-001", verification=("ARBITRARY:ignored",))
        before_document = document("SURFACE-TODAY", (removed,))
        references = tuple(
            AuthorityReference(
                schema_version=1,
                reference_id=f"REF-{kind.value}",
                authority_class=(
                    AuthorityClass.FIGMA
                    if kind is AuthorityReferenceKind.FIGMA
                    else AuthorityClass.LINEAR
                    if kind is AuthorityReferenceKind.LINEAR
                    else AuthorityClass.SOURCE_AND_TESTS
                ),
                reference_kind=kind,
                source=f"source/{kind.value}",
                revision="revision-1",
                requirement_ids=("TODAY-001",),
                approval_state="approved",
            )
            for kind in (
                AuthorityReferenceKind.SOURCE,
                AuthorityReferenceKind.TEST,
                AuthorityReferenceKind.PROOF,
                AuthorityReferenceKind.SCENARIO,
                AuthorityReferenceKind.FIGMA,
                AuthorityReferenceKind.LINEAR,
            )
        )
        pack = TaskPackReference(
            schema_version=1,
            pack_id="PACK-AMB-1901",
            source=".codex/canon-packs/amb-1901.md",
            canon_revision=1,
            canon_sha="a" * 64,
            requirement_ids=("TODAY-001",),
        )
        before = registry(
            (before_document,),
            reference_index=complete_index(
                references=references,
                task_packs=(pack,),
            ),
        )
        after = registry(
            (document("SURFACE-TODAY", ()),),
            retired=frozenset({"TODAY-001"}),
            reference_index=complete_index(),
        )

        report = impact_report(before, after)

        self.assertEqual(report.source_references, ("source/source",))
        self.assertEqual(report.tests, ("source/test",))
        self.assertEqual(report.proof_obligations, ("source/proof",))
        self.assertEqual(report.scenarios, ("source/scenario",))
        self.assertEqual(report.figma_authority, ("source/figma",))
        self.assertEqual(report.linear_work, ("source/linear",))
        self.assertEqual(
            report.generated_task_packs,
            (".codex/canon-packs/amb-1901.md",),
        )
        self.assertEqual(report.unclassified_verification, ())

    def test_missing_or_incomplete_reference_index_fails_closed(self):
        removed = requirement("TODAY-001")
        before_document = document("SURFACE-TODAY", (removed,))
        complete_after = registry(
            (document("SURFACE-TODAY", ()),),
            retired=frozenset({"TODAY-001"}),
            reference_index=complete_index(),
        )
        invalid_before = (
            replace(registry((before_document,)), reference_index=None),
            registry(
                (before_document,),
                reference_index=ImpactReferenceIndex(
                    schema_version=1,
                    complete=False,
                    authority_references=(),
                    task_packs=(),
                    specification_gaps=(),
                ),
            ),
        )
        for candidate in invalid_before:
            with self.subTest(index=candidate.reference_index):
                with self.assertRaises(CanonError) as raised:
                    impact_report(candidate, complete_after)
                self.assertEqual(
                    raised.exception.code,
                    "CANON_IMPACT_REFERENCE_INDEX_REQUIRED",
                )

    def test_new_specification_gaps_are_derived_from_structured_records(self):
        item = requirement("TODAY-001")
        before = registry(
            (document("SURFACE-TODAY", (item,)),),
            reference_index=complete_index(indexed_ids=("TODAY-001",)),
        )
        gap = SpecificationGapRecord(
            gap_id="GAP-TODAY-FAILURE",
            severity=GapSeverity.P0_BLOCKER,
            affected_ids=("SURFACE-TODAY", "TODAY-001"),
            message="Failure and rollback state is incomplete.",
        )
        after = registry(
            (document("SURFACE-TODAY", (item,)),),
            reference_index=complete_index(
                gaps=(gap,),
                indexed_ids=("TODAY-001",),
                specification_ids=("SURFACE-TODAY",),
            ),
        )

        report = impact_report(before, after)

        self.assertEqual(
            report.new_specification_gaps,
            (
                "P0_BLOCKER GAP-TODAY-FAILURE "
                "affected_ids=SURFACE-TODAY,TODAY-001 "
                "Failure and rollback state is incomplete.",
            ),
        )

    def test_reference_index_rejects_mismatched_authority_and_invalid_pack_sha(self):
        invalid_reference = AuthorityReference(
            schema_version=1,
            reference_id="REF-FIGMA",
            authority_class=AuthorityClass.LINEAR,
            reference_kind=AuthorityReferenceKind.FIGMA,
            source="figma-file#node",
            revision="revision-1",
            requirement_ids=("TODAY-001",),
            approval_state="approved",
        )
        invalid_pack = TaskPackReference(
            schema_version=1,
            pack_id="PACK-1",
            source=".codex/canon-packs/pack.md",
            canon_revision=1,
            canon_sha="not-a-sha",
            requirement_ids=("TODAY-001",),
        )
        with self.assertRaises(CanonError) as raised:
            complete_index(
                references=(invalid_reference,),
                task_packs=(invalid_pack,),
            )

        self.assertEqual(
            raised.exception.code,
            "CANON_REFERENCE_INDEX_SCHEMA",
        )

    def test_same_id_gap_escalation_or_affected_id_change_is_new_impact(self):
        item = requirement("TODAY-001")
        base_gap = SpecificationGapRecord(
            gap_id="GAP-TODAY-001",
            severity=GapSeverity.P1_REQUIRED,
            affected_ids=("TODAY-001",),
            message="Today evidence needs review.",
        )
        escalated = SpecificationGapRecord(
            gap_id="GAP-TODAY-001",
            severity=GapSeverity.P0_BLOCKER,
            affected_ids=("SURFACE-TODAY", "TODAY-001"),
            message="Today evidence blocks the amendment.",
        )
        before = registry(
            (document("SURFACE-TODAY", (item,)),),
            reference_index=complete_index(
                gaps=(base_gap,),
                indexed_ids=("TODAY-001",),
            ),
        )
        after = registry(
            (document("SURFACE-TODAY", (item,)),),
            reference_index=complete_index(
                gaps=(escalated,),
                indexed_ids=("TODAY-001",),
                specification_ids=("SURFACE-TODAY",),
            ),
        )

        report = impact_report(before, after)

        self.assertEqual(
            report.new_specification_gaps,
            (
                "P0_BLOCKER GAP-TODAY-001 "
                "affected_ids=SURFACE-TODAY,TODAY-001 "
                "Today evidence blocks the amendment.",
            ),
        )

    def test_gap_parser_rejects_invalid_severity_and_duplicate_ids_stably(self):
        invalid_payloads = (
            [
                {
                    "gap_id": "GAP-1",
                    "severity": "critical",
                    "affected_ids": ["TODAY-001"],
                    "message": "Invalid severity.",
                }
            ],
            [
                {
                    "gap_id": "GAP-1",
                    "severity": "P1_REQUIRED",
                    "affected_ids": ["TODAY-001"],
                    "message": "First.",
                },
                {
                    "gap_id": "GAP-1",
                    "severity": "P0_BLOCKER",
                    "affected_ids": ["TODAY-001"],
                    "message": "Duplicate.",
                },
            ],
        )
        for gaps in invalid_payloads:
            with self.subTest(gaps=gaps):
                payload = {
                    "schema_version": 1,
                    "canon_revision": 1,
                    "indexed_requirement_ids": ["TODAY-001"],
                    "authority_references": [],
                    "task_packs": [],
                    "specification_gaps": gaps,
                }
                source = (
                    json.dumps(payload, sort_keys=True, indent=2) + "\n"
                ).encode("utf-8")
                with self.assertRaises(CanonError) as raised:
                    parse_reference_index_bytes(
                        source,
                        Path("docs/canon/migration/impact-reference-index.json"),
                        canon_revision=1,
                        requirement_ids=("TODAY-001",),
                    )
                self.assertEqual(
                    raised.exception.code,
                    "CANON_REFERENCE_INDEX_SCHEMA",
                )


if __name__ == "__main__":
    unittest.main()
