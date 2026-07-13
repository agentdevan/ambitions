import tempfile
import unittest
from dataclasses import replace
from pathlib import Path

from tests.canon.test_impact import document, registry, requirement
from tools.ambitions_canon.external_authority import (
    external_reference_findings,
    load_external_references,
    render_external_reference_impact,
    render_visual_authority_manifest,
)
from tools.ambitions_canon.model import (
    AuthorityClass,
    AuthorityReference,
    AuthorityReferenceKind,
    FigmaAuthorityRole,
)


def external_reference(
    reference_id: str,
    kind: AuthorityReferenceKind,
    requirement_ids: tuple[str, ...],
    *,
    source: str,
    approval_state: str = "approved",
    approved_by: str | None = "Devan Warner",
) -> AuthorityReference:
    authority_class = {
        AuthorityReferenceKind.FIGMA: AuthorityClass.FIGMA,
        AuthorityReferenceKind.LINEAR: AuthorityClass.LINEAR,
    }.get(kind, AuthorityClass.SOURCE_AND_TESTS)
    return AuthorityReference(
        schema_version=1,
        reference_id=reference_id,
        authority_class=authority_class,
        reference_kind=kind,
        source=source,
        revision="fixture-v1",
        requirement_ids=requirement_ids,
        approval_state=approval_state,
        approved_by=approved_by,
        implementation_status="Yellow evidence ceiling; not implementation proof",
        authority_role=(
            FigmaAuthorityRole.APPROVED_TARGET
            if kind is AuthorityReferenceKind.FIGMA
            else None
        ),
    )


class ExternalAuthorityTests(unittest.TestCase):
    def setUp(self):
        self.temporary_directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary_directory.cleanup)
        self.root = Path(self.temporary_directory.name)
        self.item = requirement("TODAY-001")
        self.current = registry((document("SURFACE-TODAY", (self.item,)),))

    def rooted_registry(self):
        return replace(
            self.current,
            manifest=replace(self.current.manifest, repository_root=self.root),
        )

    def write_reference_files(self) -> Path:
        references_root = self.root / "docs/canon/references"
        references_root.mkdir(parents=True, exist_ok=True)
        (references_root / "linear.toml").write_text(
            '''schema_version = 1
kind = "linear"

[[references]]
reference_id = "LINEAR:96b93346-271d-46fc-beab-43ff7e286b5d"
source = "linear:96b93346-271d-46fc-beab-43ff7e286b5d"
revision = "2026-07-10T00:44:25.448Z"
requirement_ids = ["TODAY-001"]
approval_state = "approved"
approved_by = "Devan Warner"
implementation_status = "migration corpus; not implementation proof"
''',
            encoding="utf-8",
        )
        (references_root / "figma.toml").write_text(
            'schema_version = 1\nkind = "figma"\nreferences = []\n',
            encoding="utf-8",
        )
        (references_root / "proof-sources.toml").write_text(
            'schema_version = 1\nkind = "proof"\nreferences = []\n',
            encoding="utf-8",
        )
        return references_root

    def test_unknown_figma_and_linear_requirements_have_distinct_gap_classes(self):
        references = (
            external_reference(
                "FIGMA:FILE:1:2",
                AuthorityReferenceKind.FIGMA,
                ("UNKNOWN-FIGMA-001",),
                source="figma:FILE:1:2",
            ),
            external_reference(
                "LINEAR:DOC",
                AuthorityReferenceKind.LINEAR,
                ("UNKNOWN-LINEAR-001",),
                source="linear:96b93346-271d-46fc-beab-43ff7e286b5d",
            ),
        )

        findings = external_reference_findings(self.current, references, self.root)

        self.assertTrue(any("gap_class=figma_to_canon" in item.message for item in findings))
        self.assertTrue(any("gap_class=linear_to_canon" in item.message for item in findings))
        self.assertFalse(any("gap_class=missing" in item.message for item in findings))

    def test_superseded_requirement_reference_fails(self):
        current = replace(self.current, superseded_ids=frozenset({"OLD-TODAY-001"}))
        reference = external_reference(
            "LINEAR:DOC",
            AuthorityReferenceKind.LINEAR,
            ("OLD-TODAY-001",),
            source="linear:96b93346-271d-46fc-beab-43ff7e286b5d",
        )

        findings = external_reference_findings(current, (reference,), self.root)

        self.assertIn(
            "CANON_EXTERNAL_REQUIREMENT_SUPERSEDED",
            {finding.code for finding in findings},
        )

    def test_visual_authority_without_explicit_owner_approval_blocks_ui_readiness(self):
        unapproved = external_reference(
            "FIGMA:FILE:1:2",
            AuthorityReferenceKind.FIGMA,
            ("TODAY-001",),
            source="figma:FILE:1:2",
            approval_state="unreviewed",
            approved_by=None,
        )

        findings = external_reference_findings(self.current, (unapproved,), self.root)
        manifest = render_visual_authority_manifest(self.current, (unapproved,))

        self.assertIn("CANON_FIGMA_OWNER_APPROVAL_REQUIRED", {item.code for item in findings})
        self.assertFalse(manifest["ui_readiness"])
        self.assertEqual(manifest["authorities"][0]["authority_status"], "non_authoritative")

    def test_candidate_figma_reference_never_becomes_authoritative(self):
        candidate = replace(
            external_reference(
                "FIGMA-CANDIDATE:FILE:1:2",
                AuthorityReferenceKind.FIGMA,
                ("TODAY-001",),
                source="figma:FILE:1:2",
                approval_state="unreviewed",
                approved_by=None,
            ),
            authority_role=FigmaAuthorityRole.CANDIDATE,
        )

        manifest = render_visual_authority_manifest(self.current, (candidate,))

        self.assertEqual(manifest["authorities"][0]["authority_status"], "non_authoritative")
        self.assertFalse(manifest["ui_readiness"])

    def test_typed_figma_role_ignores_adversarial_reference_id_spelling(self):
        from tools.ambitions_canon.model import FigmaAuthorityRole

        approved = replace(
            external_reference(
                "FIGMA-CANDIDATE-WORD:FILE:1:2",
                AuthorityReferenceKind.FIGMA,
                ("TODAY-001",),
                source="figma:FILE:1:2",
            ),
            authority_role=FigmaAuthorityRole.APPROVED_TARGET,
        )
        candidate = replace(
            external_reference(
                "FIGMA:ORDINARY-ID:3:4",
                AuthorityReferenceKind.FIGMA,
                ("TODAY-001",),
                source="figma:FILE:3:4",
                approval_state="unreviewed",
                approved_by=None,
            ),
            authority_role=FigmaAuthorityRole.CANDIDATE,
        )

        manifest = render_visual_authority_manifest(
            self.current, (approved, candidate)
        )
        by_id = {item["reference_id"]: item for item in manifest["authorities"]}

        self.assertEqual(
            by_id[approved.reference_id]["authority_status"], "approved"
        )
        self.assertEqual(
            by_id[candidate.reference_id]["authority_status"], "non_authoritative"
        )
        self.assertEqual(
            by_id[candidate.reference_id]["authority_role"], "candidate"
        )

    def test_multiple_approved_figma_targets_for_one_requirement_fail(self):
        from tools.ambitions_canon.model import FigmaAuthorityRole

        first = replace(
            external_reference(
                "FIGMA:FILE:1:2",
                AuthorityReferenceKind.FIGMA,
                ("TODAY-001",),
                source="figma:FILE:1:2",
            ),
            authority_role=FigmaAuthorityRole.APPROVED_TARGET,
        )
        second = replace(
            external_reference(
                "FIGMA:FILE:3:4",
                AuthorityReferenceKind.FIGMA,
                ("TODAY-001",),
                source="figma:FILE:3:4",
            ),
            authority_role=FigmaAuthorityRole.APPROVED_TARGET,
        )

        findings = external_reference_findings(self.rooted_registry(), (first, second))

        self.assertIn(
            "CANON_FIGMA_MULTIPLE_APPROVED_TARGETS",
            {item.code for item in findings},
        )

    def test_figma_role_and_approval_combinations_are_closed(self):
        references_root = self.write_reference_files()
        invalid_rows = (
            (
                "approved_target_without_approval",
                '''authority_role = "approved_target"
approval_state = "unreviewed"''',
            ),
            (
                "candidate_with_approval",
                '''authority_role = "candidate"
approval_state = "approved"
approved_by = "Fixture owner"''',
            ),
        )
        for label, state_lines in invalid_rows:
            with self.subTest(label=label):
                (references_root / "figma.toml").write_text(
                    f'''schema_version = 1
kind = "figma"

[[references]]
reference_id = "FIGMA:FILE:1:2"
source = "figma:FILE:1:2"
revision = "1:2"
requirement_ids = ["TODAY-001"]
{state_lines}
implementation_status = "fixture; not implementation proof"
''',
                    encoding="utf-8",
                )

                with self.assertRaises(Exception) as raised:
                    load_external_references(self.root)
                self.assertEqual(
                    raised.exception.code,
                    "CANON_EXTERNAL_REFERENCE_SCHEMA",
                )

    def test_public_validator_rejects_illegal_typed_figma_state(self):
        invalid_candidate = replace(
            external_reference(
                "FIGMA:FILE:1:2",
                AuthorityReferenceKind.FIGMA,
                ("TODAY-001",),
                source="figma:FILE:1:2",
            ),
            authority_role=FigmaAuthorityRole.CANDIDATE,
        )

        findings = external_reference_findings(
            self.rooted_registry(),
            (invalid_candidate,),
        )

        self.assertIn(
            "CANON_FIGMA_AUTHORITY_STATE_INVALID",
            {item.code for item in findings},
        )

    def test_external_impact_projection_truthfully_summarizes_loaded_references(self):
        figma = replace(
            external_reference(
                "FIGMA:FILE:1:2",
                AuthorityReferenceKind.FIGMA,
                ("TODAY-001",),
                source="figma:FILE:1:2",
            ),
            authority_role=FigmaAuthorityRole.APPROVED_TARGET,
        )
        linear = external_reference(
            "LINEAR:DOC",
            AuthorityReferenceKind.LINEAR,
            ("TODAY-001",),
            source="linear:doc",
        )

        rendered = render_external_reference_impact(
            self.current,
            (linear, figma),
            (),
            {"traceability_input_sha": "a" * 64},
        ).decode("utf-8")

        self.assertIn("**Representation status:** Represented", rendered)
        self.assertIn("- Stable references: `2`", rendered)
        self.assertIn("- Invalid external findings: `0`", rendered)
        self.assertIn("`FIGMA:FILE:1:2`", rendered)
        self.assertIn("`LINEAR:DOC`", rendered)
        self.assertIn("does not prove implementation or readiness", rendered)
        self.assertTrue(rendered.endswith("\n"))

    def test_proof_source_must_be_repo_confined_or_an_allowed_external_locator(self):
        outside = external_reference(
            "PROOF-OUTSIDE",
            AuthorityReferenceKind.PROOF,
            ("TODAY-001",),
            source="../outside.json",
        )
        unsupported = external_reference(
            "PROOF-UNSUPPORTED",
            AuthorityReferenceKind.PROOF,
            ("TODAY-001",),
            source="ftp://example.invalid/proof.json",
        )
        allowed = external_reference(
            "PROOF-LINEAR",
            AuthorityReferenceKind.PROOF,
            ("TODAY-001",),
            source="linear-comment:11111111-1111-1111-1111-111111111111:decision:1",
        )

        findings = external_reference_findings(
            self.current, (outside, unsupported, allowed), self.root
        )

        invalid_ids = {
            finding.message.rsplit("reference_id=", 1)[-1]
            for finding in findings
            if finding.code == "CANON_PROOF_SOURCE_INVALID"
        }
        self.assertEqual(invalid_ids, {"PROOF-OUTSIDE", "PROOF-UNSUPPORTED"})

    def test_two_argument_validator_fails_closed_for_local_proof_without_repository_root(self):
        local = external_reference(
            "PROOF-LOCAL",
            AuthorityReferenceKind.PROOF,
            ("TODAY-001",),
            source="docs/proof/today.json",
        )

        findings = external_reference_findings(self.current, (local,))

        self.assertIn("CANON_PROOF_SOURCE_INVALID", {item.code for item in findings})

    def test_two_argument_validator_allows_stable_external_proof_without_repository_root(self):
        external = external_reference(
            "PROOF-LINEAR",
            AuthorityReferenceKind.PROOF,
            ("TODAY-001",),
            source="linear-comment:11111111-1111-1111-1111-111111111111:decision:1",
        )

        self.assertEqual(external_reference_findings(self.current, (external,)), ())

    def test_local_proof_rejects_leaf_ancestor_and_dangling_symlinks(self):
        outside = self.root.parent / f"{self.root.name}-outside-proof.json"
        outside.write_text("{}\n", encoding="utf-8")
        self.addCleanup(outside.unlink, missing_ok=True)
        proof_root = self.root / "docs/proof"
        proof_root.mkdir(parents=True)
        (proof_root / "leaf.json").symlink_to(outside)
        (self.root / "linked-proof").symlink_to(outside.parent, target_is_directory=True)
        (proof_root / "dangling.json").symlink_to(self.root / "missing.json")
        references = (
            external_reference(
                "PROOF-LEAF",
                AuthorityReferenceKind.PROOF,
                ("TODAY-001",),
                source="docs/proof/leaf.json",
            ),
            external_reference(
                "PROOF-ANCESTOR",
                AuthorityReferenceKind.PROOF,
                ("TODAY-001",),
                source=f"linked-proof/{outside.name}",
            ),
            external_reference(
                "PROOF-DANGLING",
                AuthorityReferenceKind.PROOF,
                ("TODAY-001",),
                source="docs/proof/dangling.json",
            ),
        )

        findings = external_reference_findings(self.rooted_registry(), references)

        invalid_ids = {
            finding.message.rsplit("reference_id=", 1)[-1]
            for finding in findings
            if finding.code == "CANON_PROOF_SOURCE_INVALID"
        }
        self.assertEqual(
            invalid_ids,
            {"PROOF-ANCESTOR", "PROOF-DANGLING", "PROOF-LEAF"},
        )

    def test_local_proof_requires_existing_regular_file(self):
        proof = self.root / "docs/proof/today.json"
        proof.parent.mkdir(parents=True)
        proof.write_text("{}\n", encoding="utf-8")
        valid = external_reference(
            "PROOF-LOCAL",
            AuthorityReferenceKind.PROOF,
            ("TODAY-001",),
            source="docs/proof/today.json",
        )

        self.assertEqual(
            external_reference_findings(self.rooted_registry(), (valid,)),
            (),
        )

    def test_all_three_fixed_reference_inputs_are_required(self):
        references_root = self.write_reference_files()
        (references_root / "figma.toml").unlink()

        with self.assertRaises(Exception) as raised:
            load_external_references(self.root)

        self.assertEqual(raised.exception.code, "CANON_EXTERNAL_REFERENCE_MISSING")

    def test_fixed_reference_input_rejects_leaf_symlink(self):
        references_root = self.write_reference_files()
        real = references_root / "figma-real.toml"
        (references_root / "figma.toml").replace(real)
        (references_root / "figma.toml").symlink_to(real)

        with self.assertRaises(Exception) as raised:
            load_external_references(self.root)

        self.assertEqual(raised.exception.code, "CANON_EXTERNAL_REFERENCE_READ")

    def test_reference_snapshot_hash_changes_and_revalidation_detects_mutation(self):
        from tools.ambitions_canon.external_authority import (
            load_external_reference_snapshot,
            validate_external_reference_snapshot,
        )

        references_root = self.write_reference_files()
        before = load_external_reference_snapshot(self.root)
        (references_root / "linear.toml").write_text(
            (references_root / "linear.toml").read_text(encoding="utf-8")
            .replace("migration corpus", "changed migration corpus"),
            encoding="utf-8",
        )
        after = load_external_reference_snapshot(self.root)

        self.assertNotEqual(before.input_sha, after.input_sha)
        with self.assertRaises(Exception) as raised:
            validate_external_reference_snapshot(self.root, before)
        self.assertEqual(raised.exception.code, "CANON_TRACEABILITY_INPUT_CHANGED")

    def test_reference_toml_loader_is_sorted_and_preserves_stable_ids(self):
        self.write_reference_files()

        references = load_external_references(self.root)

        self.assertEqual(
            tuple(item.reference_id for item in references),
            ("LINEAR:96b93346-271d-46fc-beab-43ff7e286b5d",),
        )
        self.assertEqual(references[0].reference_kind, AuthorityReferenceKind.LINEAR)


if __name__ == "__main__":
    unittest.main()
