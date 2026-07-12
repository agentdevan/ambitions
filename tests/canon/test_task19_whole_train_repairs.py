from __future__ import annotations

import hashlib
import json
import os
import re
import tempfile
import unittest
from copy import deepcopy
from pathlib import Path

from tools.ambitions_canon import migration
from tools.ambitions_canon.manifest import load_documents, load_manifest
from tools.ambitions_canon.model import CanonError
from tools.ambitions_canon.registry import build_registry
from tools.ambitions_canon.render import stable_json


ROOT = Path(__file__).resolve().parents[2]
LEDGER = ROOT / "docs/canon/migration/semantic-equivalence-sets.json"
HOMOGENEITY = ROOT / "docs/canon/migration/requirement-homogeneity.json"
TASK19_MARKER = "<!-- task19-reviewed-law:"
MUTABLE_POSTURE = re.compile(
    r"(?i)(?:"
    r"current (?:implementation|source|compliance|conformance|proof|device|bridge|inspectors|scripts|checks|performance|lane green)"
    r"|(?:current|existing) .*?(?:architecture debt|implementation debt|coverage debt)"
    r"|existing source does not prove|source presence does not prove|source-present only"
    r"|this shadow (?:target|journey|specification).*?(?:current|implementation completion|parity|readiness)"
    r"|(?:unclaimed|not claimed|remains? absent|remains narrower)"
    r"|(?:structured P1 gap|P1 mapping gap|remains unmapped)"
    r"|(?:Yellow approval|approval is Yellow|Yellow design authority)"
    r")"
)


def _protected_corpus_available(root: Path) -> bool:
    return all(
        (root / relative).is_dir()
        for relative in (
            ".codex/canon-migration/claims",
            ".codex/canon-migration/sources",
        )
    )


class Task19WholeTrainRepairTests(unittest.TestCase):
    def test_tracked_atomic_ledger_contains_no_raw_source_text(self):
        value = json.loads(LEDGER.read_text())
        for source in value["source_claims"]:
            self.assertNotIn("source_text", source, source["claim_id"])
            self.assertEqual(
                set(source),
                {
                    "claim_id",
                    "clauses",
                    "decision_mapping_status",
                    "decision_number",
                    "source_location",
                    "source_text_length",
                    "source_text_sha256",
                },
            )

    def test_exact_owner_entailment_never_drops_traceability_edge(self):
        value = json.loads(LEDGER.read_text())
        contradictions = []
        by_id = {}
        for source in value["source_claims"]:
            for clause in source["clauses"]:
                edge_id = f"{source['claim_id']}:{clause['ordinal']}"
                by_id[edge_id] = clause
                if (
                    clause["requirement_id"] is None
                    and clause["semantic_rationale"].startswith("Exact owner clause")
                ):
                    contradictions.append(edge_id)
        self.assertEqual(contradictions, [])
        for ordinal in (1, 2):
            clause = by_id[f"CLAIM-STB-0653:{ordinal}"]
            self.assertEqual(clause["requirement_id"], "CONCURRENCY-003")
            self.assertNotEqual(clause["relationship"], "provenance")

    def test_restored_exact_owner_rationale_matches_hashed_supporting_span(self):
        import re

        manifest = load_manifest(ROOT)
        registry = build_registry(manifest, load_documents(ROOT, manifest))
        requirements = {
            item.requirement_id: item for item in registry.requirements
        }
        value = json.loads(LEDGER.read_text())
        by_id = {
            f"{source['claim_id']}:{clause['ordinal']}": clause
            for source in value["source_claims"]
            for clause in source["clauses"]
        }
        exact_edges = {}
        for edge_id, clause in by_id.items():
            match = re.match(
                r"^Exact (?:live |modular )?(?:owner )?clause “(.+?)” "
                r"(?:entails|displaces|supersedes)",
                clause["semantic_rationale"],
            )
            if match is not None:
                exact_edges[edge_id] = (clause, match.group(1))
        self.assertGreaterEqual(len(exact_edges), 59)
        for edge_id, (clause, quoted_support) in exact_edges.items():
            owner = requirements[clause["requirement_id"]]
            span = owner.body[
                clause["owner_body_span_start"] : clause["owner_body_span_end"]
            ]
            self.assertIn(quoted_support, span, edge_id)

        self.assertIn(
            "If current proof is absent",
            requirements[by_id["CLAIM-PRC-003:1"]["requirement_id"]].body[
                by_id["CLAIM-PRC-003:1"]["owner_body_span_start"] :
                by_id["CLAIM-PRC-003:1"]["owner_body_span_end"]
            ],
        )
        self.assertEqual(
            by_id["CLAIM-PRC-049:1"]["requirement_id"],
            "SPEC-GLOBAL-MOTION-RESPONSIBILITY-001",
        )
        capture = by_id["CLAIM-PRC-049:2"]
        self.assertEqual(
            requirements[capture["requirement_id"]].body[
                capture["owner_body_span_start"] : capture["owner_body_span_end"]
            ],
            "Capture MUST NOT be a tab.",
        )
        for edge_id in ("CLAIM-STB-0060:2", "CLAIM-STB-0744:1"):
            clause = by_id[edge_id]
            span = requirements[clause["requirement_id"]].body[
                clause["owner_body_span_start"] : clause["owner_body_span_end"]
            ]
            self.assertIn("integrated movement from intent", span, edge_id)

    def test_owner_rejection_is_preserved_in_claim_projection(self):
        review = json.loads(
            (ROOT / "docs/canon/migration/semantic-loss-review.json").read_text()
        )
        entries = {item["claim_id"]: item for item in review["entries"]}
        self.assertEqual(
            entries["CLAIM-STB-0486"]["classification"],
            "rejected_by_owner",
        )
        self.assertGreater(review["classification_counts"]["rejected_by_owner"], 0)

    def test_protected_source_loader_missing_corpus_is_fail_closed(self):
        loader = getattr(migration, "load_protected_semantic_sources", None)
        self.assertIsNotNone(loader, "protected semantic source loader is required")
        if loader is None:
            return
        ledger = json.loads(LEDGER.read_text())
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            with self.subTest(case="absent"):
                with self.assertRaises(CanonError) as raised:
                    loader(root, ledger)
                self.assertEqual(raised.exception.code, "CANON_PROTECTED_SOURCE_MISSING")

    def test_live_protected_source_loader_detects_divergent_and_stale_inputs(self):
        if not _protected_corpus_available(ROOT):
            self.skipTest(
                "ignored protected corpus is absent; clean-checkout fail-closed coverage ran separately"
            )
        loader = migration.load_protected_semantic_sources
        ledger = json.loads(LEDGER.read_text())
        loaded = loader(ROOT, ledger)
        self.assertEqual(len(loaded), 1_542)

        divergent = deepcopy(ledger)
        divergent["source_claims"][0]["source_text_length"] += 1
        with self.subTest(case="hash-divergent"):
            with self.assertRaises(CanonError) as raised:
                loader(ROOT, divergent)
            self.assertEqual(raised.exception.code, "CANON_PROTECTED_SOURCE_HASH")

        stale = deepcopy(ledger)
        stale["source_claims"][0]["source_location"] = "line:999999"
        with self.subTest(case="stale-metadata"):
            with self.assertRaises(CanonError) as raised:
                loader(ROOT, stale)
            self.assertEqual(raised.exception.code, "CANON_PROTECTED_SOURCE_STALE")

    def test_protected_claim_reader_rejects_symlink_entries(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            source = root / "synthetic-claim-batch.json"
            source.write_text("{}\n", encoding="utf-8")
            directory = root / "claims"
            directory.mkdir()
            os.symlink(source, directory / "batch.json")
            with self.assertRaises(CanonError) as raised:
                migration._read_claim_batches(directory)
            self.assertEqual(raised.exception.code, "CLAIM_INPUT_PATH_UNSAFE")

    def test_normative_markdown_has_no_task19_wrapper_markers(self):
        offenders = []
        for path in (ROOT / "docs/canon").rglob("*.md"):
            if TASK19_MARKER in path.read_text():
                offenders.append(path.relative_to(ROOT).as_posix())
        self.assertEqual(offenders, [])

    def test_declared_concepts_have_exactly_one_requirement_owner(self):
        manifest = load_manifest(ROOT)
        registry = build_registry(manifest, load_documents(ROOT, manifest))
        requirement_concepts = {item.concept for item in registry.requirements}
        declared_concepts = {
            concept
            for document in registry.documents
            for concept in document.owns_concepts
        }
        self.assertEqual(declared_concepts - requirement_concepts, set())
        self.assertNotIn("global.motion-capture-ownership", declared_concepts)

    def test_independent_review_binding_does_not_rewrite_decision_status(self):
        ledger = json.loads(LEDGER.read_text())
        review = json.loads(
            (ROOT / "docs/canon/migration/semantic-loss-review.json").read_text()
        )
        self.assertEqual(ledger["review_status"], "independently_reviewed")
        self.assertEqual(review["review_status"], "independently_reviewed")
        binding = ledger["independent_review"]
        self.assertEqual(
            set(binding),
            {
                "finding_counts",
                "reviewed_candidate_diff_sha256",
                "reviewed_path_count",
                "reviewed_semantic_content_sha256",
                "reviewer_report_sha256",
                "schema_version",
                "verdict",
            },
        )
        self.assertEqual(binding["verdict"], "clean")
        self.assertEqual(
            binding["reviewed_candidate_diff_sha256"],
            "12055e3f7cc5340bd8fdf3c66e44eb9584cbcc2d56289738266766b28933275c",
        )
        self.assertEqual(
            binding["reviewer_report_sha256"],
            "70a45abd9ee12042b7aaef752cfa7af52a2781f000578a932de30a9d67b6ae43",
        )
        self.assertEqual(binding["finding_counts"], {
            "critical": 0,
            "important": 0,
            "minor": 0,
        })
        counts = {"independently_reviewed": 0, "unreviewed": 0}
        for source in ledger["source_claims"]:
            if source["decision_number"] is not None:
                counts[source["decision_mapping_status"]] += 1
        self.assertEqual(counts, {"independently_reviewed": 156, "unreviewed": 45})

    def test_candidate_cannot_self_promote_without_exact_review_binding(self):
        ledger = json.loads(LEDGER.read_text())
        manifest = load_manifest(ROOT)
        registry = build_registry(manifest, load_documents(ROOT, manifest))
        for status, binding in (
            ("independently_reviewed", None),
            ("candidate", ledger.get("independent_review")),
        ):
            with self.subTest(status=status):
                mutated = deepcopy(ledger)
                mutated["review_status"] = status
                mutated["independent_review"] = binding
                raw = stable_json(mutated)
                with self.assertRaises(CanonError) as raised:
                    migration._atomic_semantic_review_projection(
                        ROOT,
                        registry,
                        mutated,
                        raw,
                        LEDGER,
                        verify_protected_sources=False,
                    )
                self.assertEqual(
                    raised.exception.code,
                    "CANON_SEMANTIC_REVIEW_BINDING",
                )

    def test_normative_markdown_excludes_mutable_implementation_posture(self):
        offenders = []
        roots = (
            ROOT / "docs/canon/specifications",
            ROOT / "docs/canon/standards",
        )
        exempt = {ROOT / "docs/canon/standards/validation-and-release.md"}
        for root in roots:
            for path in root.rglob("*.md"):
                if path in exempt:
                    continue
                for line, text in enumerate(path.read_text().splitlines(), start=1):
                    if MUTABLE_POSTURE.search(text):
                        offenders.append(f"{path.relative_to(ROOT)}:{line}")
        self.assertEqual(offenders, [])

    def test_normative_source_owners_use_stable_owner_paths(self):
        offenders = []
        for path in (ROOT / "docs/canon").rglob("*.md"):
            text = path.read_text()
            if not text.startswith("+++\n"):
                continue
            front = text.split("+++", 2)[1]
            match = re.search(r"source_owners\s*=\s*\[(.*?)\]", front, re.DOTALL)
            if match and ".swift" in match.group(1):
                offenders.append(path.relative_to(ROOT).as_posix())
        self.assertEqual(offenders, [])

    def test_mutable_posture_projection_preserves_reviewed_stable_laws(self):
        stable = {
            "docs/canon/specifications/surfaces/today.md": "Today’s temporal rail MUST NOT replace the object-led current-reality viewport as the primary product identity.",
            "docs/canon/standards/performance-and-energy.md": "Performance claims MUST require current measurements tied to commit and environment.",
            "docs/canon/specifications/app/shell.md": "It is not responsible for constitutional root IA, surface content, Capture/Search behavior, object mutation, or privacy policy.",
            "docs/canon/specifications/systems/sync-and-continuity.md": "It does not own Ambitions Account identity, R2, public references, canonical command decisions, local store meaning, or backup as a synonym for sync.",
            "docs/canon/specifications/objects/reminder.md": "it MUST NOT claim parity until complete current evidence satisfies the replacement bar.",
        }
        evidence = json.loads(
            (ROOT / "docs/canon/migration/current-posture-evidence.json").read_text()
        )
        projected = {item["statement_sha256"] for item in evidence["records"]}
        for relative, statement in stable.items():
            self.assertIn(statement, (ROOT / relative).read_text(), relative)
            self.assertNotIn(hashlib.sha256(statement.encode()).hexdigest(), projected)

    def test_aggregate_rewrites_preserve_profile_completeness_sections(self):
        path = ROOT / "docs/canon/standards/swiftui-and-design-system.md"
        text = path.read_text()
        required = {
            "purpose", "scope", "requirements", "exceptions", "verification",
            "source-ownership", "proof", "amendment-impact",
        }
        present = set(re.findall(r"<!-- canon-section: ([a-z-]+) -->", text))
        self.assertTrue(required <= present)
        for section in required:
            marker = f"<!-- canon-section: {section} -->\n"
            body = text.split(marker, 1)[1].split("\n<!-- canon-section:", 1)[0]
            self.assertTrue(body.strip(), section)

    def test_homogeneity_manifest_is_closed_and_covers_every_atomic_owner(self):
        self.assertTrue(HOMOGENEITY.is_file(), "homogeneity manifest is required")
        if not HOMOGENEITY.is_file():
            return
        value = json.loads(HOMOGENEITY.read_text())
        self.assertEqual(set(value), {"schema_version", "policy", "owners"})
        self.assertEqual(value["schema_version"], 1)
        owners = value["owners"]
        self.assertEqual(
            [item["requirement_id"] for item in owners],
            sorted(item["requirement_id"] for item in owners),
        )
        ledger = json.loads(LEDGER.read_text())
        edge_counts: dict[str, int] = {}
        edge_ids: dict[str, list[str]] = {}
        for source in ledger["source_claims"]:
            for clause in source["clauses"]:
                owner = clause["requirement_id"]
                if owner is not None:
                    edge_counts[owner] = edge_counts.get(owner, 0) + 1
                    edge_ids.setdefault(owner, []).append(
                        f"{source['claim_id']}:{clause['ordinal']}"
                    )
        by_id = {item["requirement_id"]: item for item in owners}
        self.assertTrue(set(edge_counts) <= set(by_id))
        for owner, count in edge_counts.items():
            record = by_id[owner]
            self.assertEqual(
                set(record),
                {
                    "aggregate_contract", "allowed_facets", "child_requirement_ids",
                    "clause_edge_ids", "clause_roles", "contract_key",
                    "direct_modal_sentence_count", "incoming_edge_count", "modalities",
                    "owner_file", "rationale", "requirement_id", "reviewer",
                    "triggered_by", "verification_owner",
                },
            )
            self.assertEqual(record["incoming_edge_count"], count)
            self.assertEqual(record["clause_edge_ids"], sorted(edge_ids[owner]))
            self.assertEqual(set(record["clause_roles"]), set(edge_ids[owner]))
            self.assertTrue(record["allowed_facets"], owner)
            if record["direct_modal_sentence_count"] > 12:
                self.assertTrue(record["aggregate_contract"], owner)


if __name__ == "__main__":
    unittest.main()
