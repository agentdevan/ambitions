import contextlib
import io
import json
import os
import tempfile
import unittest
from dataclasses import replace
from pathlib import Path
from unittest import mock

from tools.ambitions_canon.cli import main
from tools.ambitions_canon.impact import (
    classify_change,
    impact_report,
    render_amendment_scaffold,
)
from tools.ambitions_canon.model import (
    AuthorityState,
    CanonDocument,
    CanonError,
    CanonManifest,
    CanonRegistry,
    DocumentKind,
    ImpactReferenceIndex,
    Modality,
    Requirement,
    SupersessionEntry,
)
from tools.ambitions_canon.reference_index import parse_reference_index_bytes
from tools.ambitions_canon.supersession import integration_evidence_digest


def supersession_entry(
    *,
    conflict_id: str,
    old_ids: tuple[str, ...],
    resulting_id: str | None,
    decision_date: str,
    owner: str,
    decision_source: str,
    decision_base_commit: str,
    superseded_artifacts: tuple[str, ...],
    resolution: str = "compose",
) -> SupersessionEntry:
    digest = integration_evidence_digest(
        conflict_id=conflict_id,
        old_ids=old_ids,
        resulting_id=resulting_id,
        decision_date=decision_date,
        owner=owner,
        decision_source=decision_source,
        resolution=resolution,
        decision_base_commit=decision_base_commit,
        superseded_artifacts=superseded_artifacts,
    )
    return SupersessionEntry(
        conflict_id=conflict_id,
        old_ids=old_ids,
        resulting_id=resulting_id,
        decision_date=decision_date,
        owner=owner,
        decision_source=decision_source,
        resolution=resolution,
        decision_base_commit=decision_base_commit,
        integration_evidence_sha256=digest,
        superseded_artifacts=superseded_artifacts,
    )


def requirement(
    requirement_id: str,
    concept: str = "surface.today.primary-identity",
    *,
    modality: Modality = Modality.MUST,
    scope: str = "Today primary identity",
    status: str = "normative",
    verification: tuple[str, ...] = (),
    supersedes: tuple[str, ...] = (),
    body: str = "Today presents Start here as its primary identity.",
    path: str = "docs/canon/specifications/surfaces/today.md",
    line: int = 20,
) -> Requirement:
    return Requirement(
        requirement_id=requirement_id,
        title="Today primary identity",
        concept=concept,
        modality=modality,
        scope=scope,
        status=status,
        verification=verification,
        supersedes=supersedes,
        body=body,
        source_path=Path(path),
        line=line,
    )


def document(
    spec_id: str,
    requirements: tuple[Requirement, ...],
    *,
    concepts: tuple[str, ...] = ("surface.today.primary-identity",),
    inherits: tuple[str, ...] = (),
    depends_on: tuple[str, ...] = (),
    source_owners: tuple[str, ...] = (),
    path: str | None = None,
) -> CanonDocument:
    return CanonDocument(
        spec_id=spec_id,
        title=spec_id,
        kind=DocumentKind.SURFACE,
        status="normative",
        owner_domain="product",
        canon_revision=1,
        profile="surface-v1",
        owns_concepts=concepts,
        inherits=inherits,
        depends_on=depends_on,
        source_owners=source_owners,
        sections=frozenset(),
        not_applicable=(),
        requirements=requirements,
        source_path=Path(path or f"docs/canon/{spec_id.lower()}.md"),
    )


def registry(
    documents: tuple[CanonDocument, ...],
    *,
    retired: frozenset[str] = frozenset(),
    ledger_complete: bool = True,
    reference_index: ImpactReferenceIndex | None = None,
    ledger_entries: tuple[SupersessionEntry, ...] | None = None,
) -> CanonRegistry:
    manifest = CanonManifest(
        schema_version=1,
        canon_revision=1,
        authority_state=AuthorityState.SHADOW,
        compiler_version="0.1.0",
        normative_files=(),
        generated_files=(),
        source_path=Path("docs/canon/MANIFEST.toml"),
    )
    requirements = tuple(
        item for specification in documents for item in specification.requirements
    )
    superseded = frozenset(
        identifier
        for item in requirements
        for identifier in item.supersedes
    ) | retired
    entries = (
        ledger_entries
        if ledger_entries is not None
        else tuple(
            supersession_entry(
                conflict_id=f"CONFLICT-{identifier}",
                old_ids=(identifier,),
                resulting_id=None,
                decision_date="2026-07-11",
                owner="Test owner",
                decision_source="Owner approval",
                decision_base_commit="0123456789abcdef0123456789abcdef01234567",
                superseded_artifacts=(),
            )
            for identifier in sorted(retired)
        )
    )
    durable_ids = frozenset(
        identifier for entry in entries for identifier in entry.old_ids
    )
    if reference_index is None:
        requirement_ids = tuple(
            sorted(item.requirement_id for item in requirements)
        )
        payload = {
            "schema_version": 1,
            "canon_revision": 1,
            "indexed_requirement_ids": list(requirement_ids),
            "authority_references": [],
            "task_packs": [],
            "specification_gaps": [],
        }
        source_bytes = (
            json.dumps(payload, sort_keys=True, indent=2) + "\n"
        ).encode("utf-8")
        reference_index = parse_reference_index_bytes(
            source_bytes,
            Path("docs/canon/migration/impact-reference-index.json"),
            canon_revision=1,
            requirement_ids=requirement_ids,
        )
    return CanonRegistry(
        manifest=manifest,
        documents=documents,
        requirements=requirements,
        concept_owners=tuple(
            (concept, specification.spec_id)
            for specification in documents
            for concept in specification.owns_concepts
        ),
        superseded_ids=superseded | durable_ids,
        supersession_entries=entries,
        supersession_ledger_complete=ledger_complete,
        reference_index=reference_index,
    )


class ChangeClassificationTests(unittest.TestCase):
    def test_explicit_body_only_clarification_retains_id(self):
        before = requirement("TODAY-001")
        after = replace(
            before,
            status="clarification",
            body="  TODAY presents Start here as its primary identity;  ",
        )

        self.assertEqual(classify_change(before, after), "clarification")

    def test_clarification_declaration_cannot_override_destructive_semantics(self):
        before = requirement("TODAY-001")
        changed_bodies = (
            "Today deletes Start here as its primary identity.",
            "Today discloses the private life graph to a hosted service.",
            "Today MUST NOT present Start here as its primary identity.",
            "Start here presents Today as its primary identity.",
        )

        for body in changed_bodies:
            with self.subTest(body=body):
                after = replace(before, status="clarification", body=body)
                self.assertEqual(
                    classify_change(before, after),
                    "semantic_amendment",
                )

    def test_clarification_preserves_operators_sentence_force_numbers_units_and_order(self):
        cases = (
            ("Score MUST be > 0.", "Score MUST be < 0."),
            ("The step is ready.", "The step is ready?"),
            ("Count MUST equal 2.", "Count MUST equal 3."),
            ("Delay MUST be 5 minutes.", "Delay MUST be 5 seconds."),
            ("A MUST precede B.", "B MUST precede A."),
            ("Value MUST be = 1.", "Value MUST be != 1."),
            ("Value MUST be <= 1.", "Value MUST be >= 1."),
        )
        for before_body, after_body in cases:
            with self.subTest(before=before_body, after=after_body):
                before = requirement("TODAY-001", body=before_body)
                after = replace(
                    before,
                    status="clarification",
                    body=after_body,
                )
                self.assertEqual(
                    classify_change(before, after),
                    "semantic_amendment",
                )

    def test_clarification_preserves_all_semantic_symbols_and_grouping(self):
        cases = (
            ("Value MUST be +1.", "Value MUST be -1."),
            ("A MUST require B && C.", "A MUST require B || C."),
            ("Value MUST be A / B.", "Value MUST be A * B."),
            ("Rule MUST preserve /* A */.", "Rule MUST preserve // A."),
            ("Value MUST be -A.", "Value MUST be +A."),
            ("Value MUST be (A + B) * C.", "Value MUST be A + (B * C)."),
            ("Value MUST contain [A].", "Value MUST contain {A}."),
            ("Value MUST contain [A + B].", "Value MUST contain [A] + B."),
            ("Value MUST contain {A + B}.", "Value MUST contain {A} + B."),
            ("A MUST use B & C.", "A MUST use B | C."),
            ("A MUST map B -> C.", "A MUST map B <- C."),
            ("Progress MUST be 50%.", "Progress MUST be 50‰."),
            ("Cost MUST be $5.", "Cost MUST be €5."),
            ("Value MUST be A × B.", "Value MUST be A ÷ B."),
            ("Value MUST be A − B.", "Value MUST be A + B."),
            ("Value MUST be A ≤ B.", "Value MUST be A ≥ B."),
            ("Value MUST be x².", "Value MUST be x2."),
            ("Value MUST use ＋A.", "Value MUST use +A."),
        )
        for before_body, after_body in cases:
            with self.subTest(before=before_body, after=after_body):
                before = requirement("TODAY-001", body=before_body)
                after = replace(
                    before,
                    status="clarification",
                    body=after_body,
                )
                self.assertEqual(
                    classify_change(before, after),
                    "semantic_amendment",
                )

    def test_clarification_may_ignore_safe_nonsemantic_grammar_punctuation(self):
        before = requirement("TODAY-001", body="Today presents Start here: calmly.")
        after = replace(
            before,
            status="clarification",
            body="  TODAY presents Start here, calmly;  ",
        )

        self.assertEqual(classify_change(before, after), "clarification")

    def test_modality_scope_concept_or_body_contract_change_is_semantic(self):
        before = requirement("TODAY-001")
        changes = (
            replace(before, modality=Modality.SHOULD),
            replace(before, scope="Every Today state"),
            replace(before, concept="surface.today.temporal-rail"),
            replace(before, body="Today uses the temporal rail as primary identity."),
            replace(before, verification=("SCENARIO-TODAY-002",)),
        )
        for after in changes:
            with self.subTest(after=after):
                self.assertEqual(
                    classify_change(before, after),
                    "semantic_amendment",
                )

    def test_source_file_move_with_identical_fields_is_structural(self):
        before = requirement("TODAY-001")
        after = replace(
            before,
            source_path=Path("docs/canon/specifications/surfaces/today-v2.md"),
            line=45,
        )

        self.assertEqual(classify_change(before, after), "structural_refactor")

    def test_changed_id_is_semantic_even_when_other_fields_match(self):
        before = requirement("TODAY-001")
        after = replace(
            before,
            requirement_id="TODAY-002",
            supersedes=("TODAY-001",),
        )

        self.assertEqual(classify_change(before, after), "semantic_amendment")


class ImpactReportTests(unittest.TestCase):
    def test_removal_reports_all_transitive_dependents_and_reference_kinds(self):
        removed = requirement(
            "TODAY-001",
            verification=(
                "SCENARIO-TODAY-001",
                "TEST:tests/canon/test_today.py::test_primary",
                "PROOF:docs/qa/today-primary.md",
                "FIGMA:ambitions-v3#today-primary",
                "LINEAR:AMB-1901",
                "TASK_PACK:.codex/canon-packs/AMB-1901.md",
            ),
        )
        dependent = requirement(
            "TODAY-JOURNEY-001",
            "journey.today.start-here",
            verification=("SCENARIO:SCENARIO-JOURNEY-001",),
            path="docs/canon/journeys/today-start.md",
        )
        downstream = requirement(
            "TODAY-PROOF-001",
            "standard.today.proof",
            verification=("PROOF-TODAY-PRIMARY",),
            path="docs/canon/standards/today-proof.md",
        )
        owner = document(
            "SURFACE-TODAY",
            (removed,),
            source_owners=("Native/Ambitions/Surfaces/Today/",),
        )
        journey = document(
            "JOURNEY-TODAY-START",
            (dependent,),
            concepts=("journey.today.start-here",),
            inherits=("TODAY-001",),
            source_owners=("Native/Ambitions/Scenarios/Today/",),
        )
        standard = document(
            "STANDARD-TODAY-PROOF",
            (downstream,),
            concepts=("standard.today.proof",),
            depends_on=("JOURNEY-TODAY-START",),
            source_owners=("Native/Ambitions/Quality/Today/",),
        )
        before = registry((standard, journey, owner))
        after = registry(
            (
                replace(owner, requirements=()),
                replace(journey, inherits=()),
                standard,
            ),
            retired=frozenset({"TODAY-001"}),
        )

        report = impact_report(before, after)

        self.assertEqual(
            report.affected_specifications,
            ("JOURNEY-TODAY-START", "STANDARD-TODAY-PROOF", "SURFACE-TODAY"),
        )
        self.assertEqual(
            report.dependent_requirements,
            ("TODAY-JOURNEY-001", "TODAY-PROOF-001"),
        )
        self.assertEqual(
            report.source_owners,
            (
                "Native/Ambitions/Quality/Today/",
                "Native/Ambitions/Scenarios/Today/",
                "Native/Ambitions/Surfaces/Today/",
            ),
        )
        self.assertEqual(
            report.scenarios,
            (),
        )
        self.assertEqual(report.tests, ())
        self.assertEqual(report.proof_obligations, ())
        self.assertEqual(report.figma_authority, ())
        self.assertEqual(report.linear_work, ())
        self.assertEqual(report.generated_task_packs, ())
        self.assertEqual(report.removed_ids, ("TODAY-001",))
        self.assertEqual(report.unresolved_p0_dependents, ())

    def test_semantic_change_retaining_id_fails_closed(self):
        before_item = requirement("TODAY-001")
        after_item = replace(before_item, modality=Modality.SHOULD)

        with self.assertRaises(CanonError) as raised:
            impact_report(
                registry((document("SURFACE-TODAY", (before_item,)),)),
                registry((document("SURFACE-TODAY", (after_item,)),)),
            )

        self.assertEqual(raised.exception.code, "CANON_AMENDMENT_ID_REUSE")

    def test_semantic_change_with_new_superseding_id_is_reported(self):
        before_item = requirement("TODAY-001")
        after_item = replace(
            before_item,
            requirement_id="TODAY-002",
            modality=Modality.SHOULD,
            supersedes=("TODAY-001",),
        )

        report = impact_report(
            registry((document("SURFACE-TODAY", (before_item,)),)),
            registry(
                (document("SURFACE-TODAY", (after_item,)),),
                ledger_entries=(
                    supersession_entry(
                        conflict_id="CONFLICT-TODAY-001",
                        old_ids=("TODAY-001",),
                        resulting_id="TODAY-002",
                        decision_date="2026-07-11",
                        owner="Owner",
                        decision_source="Owner approval",
                        decision_base_commit="0123456789abcdef0123456789abcdef01234567",
                        superseded_artifacts=("docs/canon/old.md",),
                    ),
                ),
            ),
        )

        self.assertEqual(
            tuple(
                (change.before_id, change.after_id, change.classification)
                for change in report.changes
            ),
            (("TODAY-001", "TODAY-002", "semantic_amendment"),),
        )
        self.assertEqual(report.retired_ids, ("TODAY-001",))
        self.assertEqual(report.unresolved_p0_dependents, ())

    def test_retired_id_reactivation_fails_closed(self):
        active = requirement("TODAY-001")
        before = registry((), retired=frozenset({"TODAY-001"}))
        after = registry((document("SURFACE-TODAY", (active,)),))

        with self.assertRaises(CanonError) as raised:
            impact_report(before, after)

        self.assertEqual(raised.exception.code, "CANON_RETIRED_ID_REACTIVATED")

    def test_retired_id_cannot_reactivate_as_a_specification(self):
        before = registry((), retired=frozenset({"SURFACE-TODAY"}))
        after = registry((document("SURFACE-TODAY", ()),))

        with self.assertRaises(CanonError) as raised:
            impact_report(before, after)

        self.assertEqual(raised.exception.code, "CANON_RETIRED_ID_REACTIVATED")

    def test_removal_requires_complete_synchronized_after_ledger(self):
        before_item = requirement("TODAY-001")
        before = registry((document("SURFACE-TODAY", (before_item,)),))
        removed_document = document("SURFACE-TODAY", ())

        invalid_after_states = (
            registry((removed_document,), ledger_complete=False),
            registry((removed_document,), ledger_complete=True),
        )
        expected_codes = (
            "CANON_SUPERSESSION_LEDGER_REQUIRED",
            "CANON_SUPERSESSION_LEDGER_UNSYNCED",
        )
        for after, code in zip(invalid_after_states, expected_codes):
            with self.subTest(code=code):
                with self.assertRaises(CanonError) as raised:
                    impact_report(before, after)
                self.assertEqual(raised.exception.code, code)

    def test_durable_ledger_cannot_regress_across_fresh_snapshots(self):
        before = registry((), retired=frozenset({"TODAY-001"}))
        after = registry((), retired=frozenset())

        with self.assertRaises(CanonError) as raised:
            impact_report(before, after)

        self.assertEqual(
            raised.exception.code,
            "CANON_SUPERSESSION_LEDGER_REGRESSION",
        )

    def test_existing_ledger_entries_are_append_only_and_byte_semantic(self):
        original = supersession_entry(
            conflict_id="CONFLICT-001",
            old_ids=("OLD-001",),
            resulting_id=None,
            decision_date="2026-07-11",
            owner="Owner A",
            decision_source="Owner approval",
            decision_base_commit="0123456789abcdef0123456789abcdef01234567",
            superseded_artifacts=("docs/truth/old.md",),
        )
        rewritten = replace(original, owner="Owner B")
        before = registry((), ledger_entries=(original,))
        after = registry((), ledger_entries=(rewritten,))

        with self.assertRaises(CanonError) as raised:
            impact_report(before, after)

        self.assertEqual(
            raised.exception.code,
            "CANON_SUPERSESSION_LEDGER_REWRITE",
        )

    def test_semantic_replacement_requires_exact_ledger_resulting_id(self):
        before_item = requirement("TODAY-001")
        after_item = replace(
            before_item,
            requirement_id="TODAY-002",
            modality=Modality.SHOULD,
            supersedes=("TODAY-001",),
        )
        invalid_results = (None, "TODAY-999")
        for resulting_id in invalid_results:
            entry = supersession_entry(
                conflict_id="CONFLICT-TODAY-001",
                old_ids=("TODAY-001",),
                resulting_id=resulting_id,
                decision_date="2026-07-11",
                owner="Owner",
                decision_source="Owner approval",
                decision_base_commit="0123456789abcdef0123456789abcdef01234567",
                superseded_artifacts=("docs/canon/old.md",),
            )
            with self.subTest(resulting_id=resulting_id):
                with self.assertRaises(CanonError) as raised:
                    impact_report(
                        registry((document("SURFACE-TODAY", (before_item,)),)),
                        registry(
                            (document("SURFACE-TODAY", (after_item,)),),
                            ledger_entries=(entry,),
                        ),
                    )
                self.assertEqual(
                    raised.exception.code,
                    "CANON_SUPERSESSION_LEDGER_RESULT",
                )

    def test_pure_removal_requires_null_ledger_result(self):
        before_item = requirement("TODAY-001")
        entry = supersession_entry(
            conflict_id="CONFLICT-TODAY-001",
            old_ids=("TODAY-001",),
            resulting_id="TODAY-002",
            decision_date="2026-07-11",
            owner="Owner",
            decision_source="Owner approval",
            decision_base_commit="0123456789abcdef0123456789abcdef01234567",
            superseded_artifacts=("docs/canon/old.md",),
        )

        with self.assertRaises(CanonError) as raised:
            impact_report(
                registry((document("SURFACE-TODAY", (before_item,)),)),
                registry(
                    (document("SURFACE-TODAY", ()),),
                    ledger_entries=(entry,),
                ),
            )

        self.assertEqual(
            raised.exception.code,
            "CANON_SUPERSESSION_LEDGER_RESULT",
        )

    def test_output_is_deterministic_for_reversed_closed_inputs(self):
        first = requirement("TODAY-001")
        second = requirement(
            "TODAY-002",
            "surface.today.secondary",
            path="docs/canon/today-secondary.md",
        )
        doc = document(
            "SURFACE-TODAY",
            (first, second),
            concepts=(
                "surface.today.primary-identity",
                "surface.today.secondary",
            ),
        )
        removed = replace(doc, requirements=())

        left = impact_report(
            registry((doc,)),
            registry(
                (removed,),
                retired=frozenset({"TODAY-001", "TODAY-002"}),
            ),
        )
        right = impact_report(
            registry((replace(doc, requirements=(second, first)),)),
            registry(
                (removed,),
                retired=frozenset({"TODAY-001", "TODAY-002"}),
            ),
        )

        self.assertEqual(left, right)

    def test_duplicate_requirement_input_fails_with_stable_code(self):
        duplicate = requirement("TODAY-001")
        valid_index = registry(
            (document("SURFACE-BASE", (duplicate,)),)
        ).reference_index
        invalid = registry(
            (
                document("SURFACE-TODAY", (duplicate,)),
                document("SURFACE-TIME", (duplicate,)),
            ),
            reference_index=valid_index,
        )

        with self.assertRaises(CanonError) as raised:
            impact_report(invalid, registry(()))

        self.assertEqual(raised.exception.code, "CANON_IMPACT_INPUT_INVALID")

    def test_cross_kind_id_collision_fails_closed(self):
        item = requirement("SURFACE-TODAY")
        invalid = registry((document("SURFACE-TODAY", (item,)),))

        with self.assertRaises(CanonError) as raised:
            impact_report(invalid, invalid)

        self.assertEqual(raised.exception.code, "CANON_IMPACT_INPUT_INVALID")

    def test_active_spec_or_requirement_cannot_intersect_superseded_ids(self):
        active_requirement = requirement("TODAY-001")
        invalid_values = (
            registry(
                (document("SURFACE-TODAY", (active_requirement,)),),
                retired=frozenset({"TODAY-001"}),
            ),
            registry(
                (document("SURFACE-TODAY", (active_requirement,)),),
                retired=frozenset({"SURFACE-TODAY"}),
            ),
        )
        for invalid in invalid_values:
            with self.subTest(retired=invalid.superseded_ids):
                with self.assertRaises(CanonError) as raised:
                    impact_report(invalid, invalid)
                self.assertEqual(
                    raised.exception.code,
                    "CANON_IMPACT_INPUT_INVALID",
                )

    def test_duplicate_concept_owner_declaration_fails_closed(self):
        invalid = registry(
            (
                document("SURFACE-TODAY", ()),
                document("SURFACE-TIME", ()),
            )
        )

        with self.assertRaises(CanonError) as raised:
            impact_report(invalid, invalid)

        self.assertEqual(raised.exception.code, "CANON_IMPACT_INPUT_INVALID")


class AmendmentScaffoldTests(unittest.TestCase):
    def test_scaffold_is_complete_non_normative_deterministic_and_newline_terminated(self):
        first = render_amendment_scaffold("surface.today.primary-identity")
        second = render_amendment_scaffold("surface.today.primary-identity")

        self.assertEqual(first, second)
        self.assertTrue(first.endswith(b"\n"))
        text = first.decode("utf-8")
        self.assertIn('status = "temporary_non_normative"', text)
        self.assertIn('owner_approval = "unresolved"', text)
        for heading in (
            "Problem",
            "Affected concept keys",
            "Current requirements",
            "Proposed requirements",
            "Rationale",
            "Alternatives",
            "Superseded requirements",
            "Specification impact",
            "Source and test impact",
            "Figma impact",
            "Linear impact",
            "Privacy, accessibility, and performance impact",
            "Migration",
            "Rollback",
            "Owner approval",
        ):
            self.assertIn(f"## {heading}\n", text)

    def test_cli_writes_atomically_within_ignored_migration_root(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            output = root / ".codex/canon-migration/amendment.md"
            output.parent.mkdir(parents=True)
            previous = Path.cwd()
            try:
                os.chdir(root)
                code = main(
                    (
                        "amend",
                        "scaffold",
                        "--concept",
                        "surface.today.primary-identity",
                        "--output",
                        ".codex/canon-migration/amendment.md",
                    )
                )
            finally:
                os.chdir(previous)

            self.assertEqual(code, 0)
            self.assertTrue(output.read_bytes().endswith(b"\n"))
            self.assertEqual(
                tuple(output.parent.glob(".ambitions-canon-amendment-*")),
                (),
            )

    def test_cli_rejects_escape_and_never_overwrites_existing_output(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            migration = root / ".codex/canon-migration"
            migration.mkdir(parents=True)
            output = migration / "amendment.md"
            output.write_bytes(b"previous\n")
            previous = Path.cwd()
            stderr = io.StringIO()
            try:
                os.chdir(root)
                with contextlib.redirect_stdout(stderr):
                    escape_code = main(
                        (
                            "amend",
                            "scaffold",
                            "--concept",
                            "surface.today.primary-identity",
                            "--output",
                            "outside.md",
                        )
                    )
                with contextlib.redirect_stdout(stderr):
                    failure_code = main(
                        (
                            "amend",
                            "scaffold",
                            "--concept",
                            "surface.today.primary-identity",
                            "--output",
                            ".codex/canon-migration/amendment.md",
                        )
                    )
            finally:
                os.chdir(previous)

            self.assertEqual(escape_code, 1)
            self.assertEqual(failure_code, 1)
            self.assertIn("CANON_AMENDMENT_PATH", stderr.getvalue())
            self.assertIn("CANON_AMENDMENT_EXISTS", stderr.getvalue())
            self.assertEqual(output.read_bytes(), b"previous\n")
            self.assertEqual(
                tuple(migration.glob(".ambitions-canon-amendment-*")),
                (),
            )

    def test_first_install_race_preserves_intruder_and_cleans_staging(self):
        from tools.ambitions_canon.build import _rename_noreplace as real_rename

        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            migration = root / ".codex/canon-migration"
            migration.mkdir(parents=True)
            output = migration / "amendment.md"
            previous = Path.cwd()
            stdout = io.StringIO()

            def race(source, destination, **kwargs):
                output.write_bytes(b"intruder\n")
                return real_rename(source, destination, **kwargs)

            try:
                os.chdir(root)
                with mock.patch(
                    "tools.ambitions_canon.impact._rename_noreplace",
                    side_effect=race,
                ):
                    with contextlib.redirect_stdout(stdout):
                        code = main(
                            (
                                "amend",
                                "scaffold",
                                "--concept",
                                "surface.today.primary-identity",
                                "--output",
                                ".codex/canon-migration/amendment.md",
                            )
                        )
            finally:
                os.chdir(previous)

            self.assertEqual(code, 1)
            self.assertIn("CANON_AMENDMENT_EXISTS", stdout.getvalue())
            self.assertEqual(output.read_bytes(), b"intruder\n")
            self.assertEqual(
                tuple(migration.glob(".ambitions-canon-amendment-*")),
                (),
            )

    def test_cli_rejects_symlinked_output_parent_with_amendment_path_code(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            migration = root / ".codex/canon-migration"
            external = root / "external"
            migration.mkdir(parents=True)
            external.mkdir()
            (migration / "linked").symlink_to(external, target_is_directory=True)
            previous = Path.cwd()
            stdout = io.StringIO()
            try:
                os.chdir(root)
                with contextlib.redirect_stdout(stdout):
                    code = main(
                        (
                            "amend",
                            "scaffold",
                            "--concept",
                            "surface.today.primary-identity",
                            "--output",
                            ".codex/canon-migration/linked/amendment.md",
                        )
                    )
            finally:
                os.chdir(previous)

            self.assertEqual(code, 1)
            self.assertIn("CANON_AMENDMENT_PATH", stdout.getvalue())
            self.assertFalse((external / "amendment.md").exists())


if __name__ == "__main__":
    unittest.main()
