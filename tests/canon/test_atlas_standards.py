from __future__ import annotations

import json
import io
import shutil
import tempfile
import unittest
from dataclasses import replace
from contextlib import redirect_stdout
from pathlib import Path
from unittest import mock

from tools.ambitions_canon import cli
from tools.ambitions_canon.coverage import coverage_findings, load_profiles
from tools.ambitions_canon.manifest import load_documents, load_manifest
from tools.ambitions_canon import migration
from tools.ambitions_canon.migration import validate_compact_semantic_loss_review
from tools.ambitions_canon.model import CanonError
from tools.ambitions_canon.render import stable_json
from tools.ambitions_canon.registry import build_registry


ROOT = Path(__file__).resolve().parents[2]

EXPECTED_STANDARDS = {
    "STANDARD-ACCESSIBILITY": "standards/accessibility.md",
    "STANDARD-COPY-STATE-LANGUAGE": "standards/copy-and-state-language.md",
    "STANDARD-NATIVE-IOS-ENGINEERING": "standards/native-ios-engineering.md",
    "STANDARD-PERFORMANCE-ENERGY": "standards/performance-and-energy.md",
    "STANDARD-SECURITY-PRIVACY": "standards/security-and-privacy.md",
    "STANDARD-SWIFTUI-DESIGN-SYSTEM": "standards/swiftui-and-design-system.md",
    "STANDARD-TESTING-FIXTURES": "standards/testing-and-fixtures.md",
    "STANDARD-VALIDATION-RELEASE": "standards/validation-and-release.md",
}


def _protected_corpus_available(root: Path) -> bool:
    return all(
        (root / relative).is_dir()
        for relative in (
            ".codex/canon-migration/claims",
            ".codex/canon-migration/sources",
        )
    )


def copy_semantic_fixture(root: Path) -> None:
    """Copy exact protected inputs while retaining the live Git provenance."""

    shutil.copytree(ROOT / "docs/canon", root / "docs/canon")
    git_metadata = ROOT / ".git"
    if git_metadata.is_file():
        shutil.copy2(git_metadata, root / ".git")
    else:
        (root / ".git").write_text(
            f"gitdir: {git_metadata.resolve()}\n",
            encoding="utf-8",
        )
    shutil.copy2(ROOT / ".gitignore", root / ".gitignore")
    for relative in (
        ".codex/canon-migration/claims",
        ".codex/canon-migration/sources",
    ):
        shutil.copytree(ROOT / relative, root / relative)
    catalog = json.loads(
        (ROOT / "docs/canon/migration/source-catalog.json").read_text()
    )
    for record in catalog["sources"]:
        relative = record.get("repo_path")
        if relative is None:
            continue
        source = ROOT / relative
        if not source.is_file():
            continue
        target = root / relative
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(source, target)


class AtlasStandardsTests(unittest.TestCase):
    def setUp(self) -> None:
        self.manifest = load_manifest(ROOT)
        self.registry = build_registry(
            self.manifest,
            load_documents(ROOT, self.manifest),
        )

    def test_exact_eight_cross_cutting_standards_are_complete(self):
        standards = {
            document.spec_id: document
            for document in self.registry.documents
            if document.kind.value == "standard"
        }
        self.assertEqual(set(standards), set(EXPECTED_STANDARDS))
        for spec_id, relative in EXPECTED_STANDARDS.items():
            document = standards[spec_id]
            self.assertEqual(document.profile, "standard-v1")
            self.assertEqual(
                document.source_path,
                Path("docs/canon") / relative,
            )

        findings = coverage_findings(
            self.registry,
            load_profiles(ROOT / "docs/canon/schemas/completeness-profiles.toml"),
        )
        self.assertFalse(
            [
                finding
                for finding in findings
                if finding.path is not None
                and finding.path.as_posix().startswith("docs/canon/standards/")
            ]
        )

    def test_semantic_loss_review_closes_every_claim_and_decision(self):
        review = validate_compact_semantic_loss_review(ROOT, self.registry)
        dispositions = json.loads(
            (ROOT / "docs/canon/migration/claim-dispositions.json").read_text(
                encoding="utf-8"
            )
        )
        self.assertEqual(review.claim_count, len(dispositions["claims"]))
        self.assertEqual(review.decision_count, 201)
        self.assertEqual(
            set(review.classification_counts),
            {
                "duplicated",
                "missing",
                "provenance_only",
                "rejected_by_owner",
                "represented",
                "represented_with_composition",
                "weakened",
            },
        )
        self.assertEqual(review.classification_counts["missing"], 0)
        self.assertEqual(review.classification_counts["weakened"], 0)
        self.assertEqual(review.classification_counts["duplicated"], 0)
        self.assertEqual(review.review_status, "independently_reviewed")

        raw = json.loads(
            (ROOT / "docs/canon/migration/semantic-loss-review.json").read_text(
                encoding="utf-8"
            )
        )
        required_binding_fields = {
            "canonical_ids",
            "claim_id",
            "classification",
            "clause_count",
            "decision_mapping_status",
            "decision_number",
            "priority",
            "priority_basis",
            "source_text_sha256",
        }
        for entry in raw["entries"]:
            self.assertEqual(set(entry), required_binding_fields, entry["claim_id"])

    def test_primary_audit_runs_compact_semantic_loss_validation(self):
        with mock.patch.object(
            cli,
            "validate_compact_semantic_loss_review",
            wraps=migration.validate_compact_semantic_loss_review,
        ) as validate:
            self.assertEqual(cli._audit(ROOT), 0)
        validate.assert_called_once()

    def test_protected_semantic_verify_fails_closed_without_ignored_corpus(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            shutil.copytree(ROOT / "docs/canon", root / "docs/canon")
            output = io.StringIO()
            with mock.patch.object(Path, "cwd", return_value=root):
                with redirect_stdout(output):
                    self.assertEqual(
                        cli.main(["migration", "claims", "semantic-verify"]),
                        1,
                    )
            self.assertIn("CANON_PROTECTED_SOURCE_MISSING", output.getvalue())

    def test_live_protected_corpus_requires_claims_and_sources(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            claims = root / ".codex/canon-migration/claims"
            sources = root / ".codex/canon-migration/sources"
            self.assertFalse(_protected_corpus_available(root))
            claims.mkdir(parents=True)
            self.assertFalse(_protected_corpus_available(root))
            sources.mkdir(parents=True)
            self.assertTrue(_protected_corpus_available(root))

    def test_live_protected_semantic_verify_passes_and_rejects_stale_or_divergent_claims(self):
        if not _protected_corpus_available(ROOT):
            self.skipTest(
                "ignored protected corpus is absent; clean-checkout fail-closed coverage ran separately"
            )
        with mock.patch.object(Path, "cwd", return_value=ROOT):
            self.assertEqual(
                cli.main(["migration", "claims", "semantic-verify"]),
                0,
            )

        for case in ("stale", "divergent"):
            with self.subTest(case=case), tempfile.TemporaryDirectory() as temporary:
                root = Path(temporary)
                copy_semantic_fixture(root)
                batch_path = sorted(
                    (root / ".codex/canon-migration/claims").glob("*.json")
                )[0]
                batch = json.loads(batch_path.read_text())
                claim = batch["claims"][0]
                if case == "stale":
                    claim["source_location"] = "line:999999"
                else:
                    claim["original_text"] += " divergent"
                batch_path.write_bytes(stable_json(batch))
                output = io.StringIO()
                with mock.patch.object(Path, "cwd", return_value=root):
                    with redirect_stdout(output):
                        self.assertEqual(
                            cli.main(
                                ["migration", "claims", "semantic-verify"]
                            ),
                            1,
                        )
                self.assertIn(
                    (
                        "CANON_PROTECTED_SOURCE_STALE"
                        if case == "stale"
                        else "CANON_PROTECTED_SOURCE_HASH"
                    ),
                    output.getvalue(),
                )

    def test_semantic_loss_owners_are_explicit_not_inferred_from_wording(self):
        self.assertFalse(
            hasattr(migration, "_semantic_composition_owner"),
            "semantic composition must come from explicit tracked mappings",
        )
        opaque_prefixes = ("migration.", "requirement.")
        for requirement in self.registry.requirements:
            self.assertFalse(
                requirement.concept.startswith(opaque_prefixes),
                requirement.requirement_id,
            )
            direct_mirrors = {
                requirement.requirement_id.lower(),
                requirement.requirement_id.lower().replace("-", "."),
            }
            self.assertNotIn(
                requirement.concept,
                direct_mirrors,
                requirement.requirement_id,
            )

    def test_runtime_claim_cannot_be_represented_by_time_surface_document(self):
        review = json.loads(
            (ROOT / "docs/canon/migration/semantic-loss-review.json").read_text(
                encoding="utf-8"
            )
        )
        entries = {item["claim_id"]: item for item in review["entries"]}
        runtime = entries["CLAIM-MOM-0012"]
        self.assertNotIn("SURFACE-TIME", runtime["canonical_ids"])
        requirement_ids = {
            requirement.requirement_id for requirement in self.registry.requirements
        }
        for entry in review["entries"]:
            if entry["classification"] in {
                "represented",
                "represented_with_composition",
            }:
                self.assertTrue(entry["canonical_ids"], entry["claim_id"])
                self.assertTrue(
                    set(entry["canonical_ids"]) <= requirement_ids,
                    entry["claim_id"],
                )

    def test_both_build_modes_fail_when_semantic_review_is_missing(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            shutil.copytree(ROOT / "docs/canon", root / "docs/canon")
            (root / "docs/canon/migration/semantic-loss-review.json").unlink()
            for check in (False, True):
                with self.subTest(check=check):
                    self.assertEqual(cli._build(root, check=check), 1)

    def test_semantic_review_regeneration_is_idempotent_for_all_claim_shapes(self):
        expected = (
            ROOT / "docs/canon/migration/semantic-loss-review.json"
        ).read_bytes()
        first = migration.render_compact_semantic_loss_review(ROOT, self.registry)
        second = migration.render_compact_semantic_loss_review(ROOT, self.registry)
        self.assertEqual(first, expected)
        self.assertEqual(second, expected)
        value = json.loads(first)
        self.assertTrue(any(item["decision_number"] for item in value["entries"]))
        self.assertTrue(any(item["decision_number"] is None for item in value["entries"]))

    def test_representative_decisions_bind_exact_owner_evidence(self):
        dispositions = json.loads(
            (ROOT / "docs/canon/migration/claim-dispositions.json").read_text()
        )["claims"]
        review = {
            item["claim_id"]: item
            for item in json.loads(
                (ROOT / "docs/canon/migration/semantic-loss-review.json").read_text()
            )["entries"]
        }
        ledger = json.loads(
            (ROOT / "docs/canon/migration/semantic-equivalence-sets.json").read_text()
        )
        clauses_by_decision = {
            item["decision_number"]: item["clauses"]
            for item in ledger["source_claims"]
            if item["decision_number"] is not None
        }
        by_number = {
            int(item["source_location"].split(":", 1)[1]): item
            for item in dispositions
            if item["source_id"] == "LINEAR-CANON-V3"
            and item["source_location"].startswith("decision:")
        }
        representative = {35, 120, 148, 149, 150, 153, 157, 159, 161, 165, 175, 187, 188, 189, 190, 191}
        requirement_ids = {
            requirement.requirement_id for requirement in self.registry.requirements
        }
        for number in representative:
            claim = by_number[number]
            entry = review[claim["claim_id"]]
            with self.subTest(decision=number):
                self.assertEqual(entry["decision_mapping_status"], claim["decision_mapping_status"])
                self.assertEqual(entry["source_text_sha256"], claim["owner_evidence_text_sha256"])
                self.assertEqual(entry["classification"], "represented_with_composition")
                expected = [
                    clause["requirement_id"]
                    for clause in clauses_by_decision[number]
                    if clause["requirement_id"] is not None
                ]
                self.assertEqual(entry["canonical_ids"], expected)
                self.assertTrue(set(expected) <= requirement_ids)

        # The atomic schema removes the old whole-claim polarity anomaly by
        # extracting each Decision 75 clause at its literal modality.
        self.assertTrue(
            all(
                clause["source_modality"] == clause["adopted_modality"]
                for clause in clauses_by_decision[75]
            )
        )

    def test_semantic_ledger_negative_mutations_fail_closed(self):
        def check(mutate, expected_code: str) -> None:
            with tempfile.TemporaryDirectory() as temporary:
                root = Path(temporary)
                shutil.copytree(ROOT / "docs/canon", root / "docs/canon")
                path = root / "docs/canon/migration/semantic-equivalence-sets.json"
                value = json.loads(path.read_text())
                mutate(value)
                raw = stable_json(value)
                path.write_bytes(raw)
                manifest = load_manifest(root)
                registry = build_registry(manifest, load_documents(root, manifest))
                with self.assertRaises(CanonError) as raised:
                    migration._atomic_semantic_review_projection(
                        root,
                        registry,
                        value,
                        raw,
                        path,
                        verify_protected_sources=False,
                    )
                self.assertEqual(raised.exception.code, expected_code)

        check(
            lambda value: value["source_claims"][0]["clauses"][0].__setitem__(
                "clause_sha256", "0" * 64
            ),
            # Compact validation has no ignored source bytes from which to
            # recompute this hash, but the independently reviewed semantic
            # content binding still rejects the mutation deterministically.
            "CANON_SEMANTIC_REVIEW_BINDING",
        )
        check(
            lambda value: value["source_claims"][0]["clauses"][0].__setitem__(
                "relationship", "plausible_but_unrecognized"
            ),
            "CANON_SEMANTIC_CLAUSE_INVALID",
        )
        def replace_owner(value):
            clause = next(
                clause
                for source in value["source_claims"]
                for clause in source["clauses"]
                if clause["requirement_id"] is not None
            )
            clause["requirement_id"] = "MISSING-OWNER-001"

        check(replace_owner, "CANON_SEMANTIC_CLAUSE_OWNER")

        def weaken(value):
            clause = next(
                clause
                for source in value["source_claims"]
                for clause in source["clauses"]
                if clause["source_modality"] == "INFORMATIONAL"
            )
            clause["adopted_modality"] = "MUST"

        check(weaken, "CANON_SEMANTIC_CLAUSE_MODALITY")

        def drop_decision(value):
            for index, source in enumerate(value["source_claims"]):
                if source.get("decision_number") == 35:
                    value["source_claims"].pop(index)
                    return
            raise AssertionError("Decision 35 fixture missing")

        # Compact clean-checkout validation reaches tracked completeness
        # without depending on the intentionally ignored protected corpus.
        check(drop_decision, "CANON_SEMANTIC_CLAUSE_INCOMPLETE")

        def strip_exact_owner(value):
            clause = next(
                clause
                for source in value["source_claims"]
                for clause in source["clauses"]
                if clause["requirement_id"] is not None
            )
            requirement_id = clause["requirement_id"]
            clause.update(
                {
                    "owner_body_span_end": None,
                    "owner_body_span_start": None,
                    "owner_clause_modality": None,
                    "owner_clause_sha256": None,
                    "owner_requirement_sha256": None,
                    "relationship": "provenance",
                    "requirement_id": None,
                    "semantic_rationale": (
                        f"Exact owner clause for {requirement_id} entails source."
                    ),
                }
            )
            clause["semantic_rationale_sha256"] = __import__("hashlib").sha256(
                clause["semantic_rationale"].encode()
            ).hexdigest()

        check(strip_exact_owner, "CANON_SEMANTIC_CLAUSE_OWNER")

        def mismatch_exact_span(value):
            clause = next(
                clause
                for source in value["source_claims"]
                for clause in source["clauses"]
                if clause["requirement_id"] is not None
            )
            clause["semantic_rationale"] = (
                "Exact owner clause “support outside the recorded span” "
                "entails source."
            )
            clause["semantic_rationale_sha256"] = __import__("hashlib").sha256(
                clause["semantic_rationale"].encode()
            ).hexdigest()

        check(mismatch_exact_span, "CANON_SEMANTIC_CLAUSE_OWNER")

        def split_exact_group(value):
            by_hash = {}
            duplicate = None
            for source in value["source_claims"]:
                for clause in source["clauses"]:
                    digest = clause["clause_sha256"]
                    if digest in by_hash and clause["requirement_id"] is not None:
                        duplicate = clause
                        break
                    by_hash[digest] = clause
                if duplicate is not None:
                    break
            self.assertIsNotNone(duplicate)
            donor = next(
                clause
                for source in value["source_claims"]
                for clause in source["clauses"]
                if clause["requirement_id"] is not None
                and clause["requirement_id"] != duplicate["requirement_id"]
                and migration.relationship_modalities_are_valid(
                    duplicate["adopted_modality"],
                    clause["owner_clause_modality"],
                    clause["relationship"],
                    clause["modality_rationale"],
                )
            )
            for field in (
                "modality_rationale",
                "owner_body_span_end",
                "owner_body_span_start",
                "owner_clause_modality",
                "owner_clause_sha256",
                "owner_requirement_sha256",
                "relationship",
                "requirement_id",
            ):
                duplicate[field] = donor[field]

        check(split_exact_group, "CANON_SEMANTIC_DUPLICATE_SOURCE")

    def test_duplicate_requirement_concept_fails_semantic_validation(self):
        first, second, *rest = self.registry.requirements
        duplicate = replace(second, concept=first.concept)
        registry = replace(
            self.registry,
            requirements=(first, duplicate, *rest),
        )
        with self.assertRaises(CanonError) as raised:
            validate_compact_semantic_loss_review(ROOT, registry)
        self.assertEqual(raised.exception.code, "CANON_SEMANTIC_DUPLICATE_CONCEPT")

    def test_build_and_buildcheck_reject_stale_equivalence_source_hash(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            shutil.copytree(ROOT / "docs/canon", root / "docs/canon")
            path = root / "docs/canon/migration/semantic-equivalence-sets.json"
            value = json.loads(path.read_text())
            value["source_claims"][0]["clauses"][0]["clause_sha256"] = "0" * 64
            path.write_bytes(stable_json(value))
            self.assertEqual(cli._build(root, check=False), 1)
            self.assertEqual(cli._build(root, check=True), 1)


if __name__ == "__main__":
    unittest.main()
