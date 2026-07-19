from __future__ import annotations

import json
import re
import unittest
from collections import Counter
from pathlib import Path

from tools.ambitions_canon.manifest import load_documents, load_manifest
from tools.ambitions_canon.registry import build_registry


ROOT = Path(__file__).resolve().parents[2]
LEDGER = ROOT / "docs/canon/migration/semantic-equivalence-sets.json"
WRAPPER_MARKERS = (
    "<!-- migration-source",
    "<!-- decision-source",
    "This requirement MUST preserve the following source-bound semantic constraint",
    "This requirement MUST preserve the source clause at its original",
    "This requirement MUST encode the owner-reviewed source decision",
)


class SemanticNormalizationTests(unittest.TestCase):
    def registry(self):
        manifest = load_manifest(ROOT)
        return build_registry(manifest, load_documents(ROOT, manifest))

    def requirements(self):
        manifest = load_manifest(ROOT)
        return [
            requirement
            for document in load_documents(ROOT, manifest)
            for requirement in document.requirements
        ]

    def atomic_sources(self):
        return json.loads(LEDGER.read_text())["source_claims"]

    @staticmethod
    def source_batch(source):
        batches = {clause["review_batch"] for clause in source["clauses"]}
        if len(batches) != 1:
            raise AssertionError((source["claim_id"], batches))
        return next(iter(batches))

    def test_constitution_remains_compact_and_high_order(self):
        constitution = (ROOT / "docs/canon/CONSTITUTION.md").read_text()
        requirements = re.findall(r"(?m)^## [A-Z0-9-]+ — ", constitution)
        self.assertLessEqual(len(constitution.split()), 15_000)
        self.assertLessEqual(len(requirements), 80)
        self.assertFalse(any(marker in constitution for marker in WRAPPER_MARKERS))
        self.assertFalse(
            any(
                concept.startswith("product.") or concept.startswith("codex.")
                for concept in re.findall(r"(?m)^- \*\*Concept:\*\* `([^`]+)`", constitution)
            )
        )

    def test_no_generated_source_wrapper_or_hash_requirement_exists(self):
        for path in (ROOT / "docs/canon").rglob("*.md"):
            text = path.read_text()
            for marker in WRAPPER_MARKERS:
                self.assertNotIn(marker, text, f"{path}: {marker}")
            for requirement_id in re.findall(
                r"(?m)^## ([A-Z0-9-]+) — ", text
            ):
                self.assertNotRegex(requirement_id, r"-[0-9A-F]{8}$")

    def test_every_active_concept_has_one_requirement_owner(self):
        manifest = load_manifest(ROOT)
        documents = load_documents(ROOT, manifest)
        owners: dict[str, list[str]] = {}
        for document in documents:
            for requirement in document.requirements:
                owners.setdefault(requirement.concept, []).append(
                    requirement.requirement_id
                )
        self.assertEqual(
            {concept: ids for concept, ids in owners.items() if len(ids) != 1},
            {},
        )

    def test_equivalence_sets_have_one_owner_and_collapse_exact_text(self):
        ledger = json.loads(LEDGER.read_text())
        requirement_ids = {
            requirement.requirement_id for requirement in self.requirements()
        }
        seen_claims: set[str] = set()
        exact_hash_owners: dict[str, str | None] = {}
        for source in ledger["source_claims"]:
            claim_id = source["claim_id"]
            self.assertNotIn(claim_id, seen_claims)
            seen_claims.add(claim_id)
            for clause in source["clauses"]:
                owner = clause["requirement_id"]
                if owner is not None:
                    self.assertIn(owner, requirement_ids)
                digest = clause["clause_sha256"]
                previous = exact_hash_owners.setdefault(digest, owner)
                self.assertEqual(previous, owner, digest)
        self.assertEqual(ledger["source_claim_count"], len(seen_claims))
        self.assertEqual(ledger["source_claim_count"], 1_542)
        self.assertEqual(ledger["review_status"], "independently_reviewed")

    def test_account_launch_commitment_is_not_weakened(self):
        candidates = [
            requirement
            for requirement in self.requirements()
            if requirement.concept == "account.launch-commitment"
        ]
        self.assertEqual(len(candidates), 1)
        requirement = candidates[0]
        self.assertEqual(requirement.modality.value, "MUST")
        self.assertRegex(requirement.body, r"Ambitions Account.*MUST.*launch")

    def test_native_platform_baseline_is_an_exact_modular_law(self):
        candidates = [
            requirement
            for requirement in self.requirements()
            if requirement.concept == "system.apple.platform-baseline"
        ]
        self.assertEqual(len(candidates), 1)
        self.assertEqual(candidates[0].modality.value, "MUST")
        self.assertIn("iOS 26", candidates[0].body)

    def test_atomic_nondecision_single_a_maps_every_reviewed_claim(self):
        sources = [item for item in self.atomic_sources() if self.source_batch(item) == "nondecision_single_a"]
        standards_claims = {item["claim_id"] for item in sources if any(clause["requirement_id"] for clause in item["clauses"])}
        standards_provenance = {item["claim_id"] for item in sources if not any(clause["requirement_id"] for clause in item["clauses"])}
        self.assertEqual(len(standards_claims | standards_provenance), 388)
        self.assertFalse(standards_claims & standards_provenance)
        for source in sources:
            for clause in source["clauses"]:
                self.assertEqual(clause["source_modality"], clause["adopted_modality"])

    def test_atomic_nondecision_single_b_maps_every_reviewed_claim(self):
        sources = [item for item in self.atomic_sources() if self.source_batch(item) == "nondecision_single_b"]
        mapped = {item["claim_id"] for item in sources if any(clause["requirement_id"] for clause in item["clauses"])}
        provenance = {item["claim_id"] for item in sources if not any(clause["requirement_id"] for clause in item["clauses"])}
        self.assertEqual(len(mapped | provenance), 387)
        self.assertFalse(mapped & provenance)
        for source in sources:
            for clause in source["clauses"]:
                self.assertEqual(clause["source_modality"], clause["adopted_modality"])

    def test_atomic_nondecision_single_c_maps_every_reviewed_claim(self):
        sources = [item for item in self.atomic_sources() if self.source_batch(item) == "nondecision_single_c"]
        mapped = {item["claim_id"] for item in sources if any(clause["requirement_id"] for clause in item["clauses"])}
        provenance = {item["claim_id"] for item in sources if not any(clause["requirement_id"] for clause in item["clauses"])}
        self.assertEqual(len(mapped | provenance), 387)
        self.assertFalse(mapped & provenance)
        for source in sources:
            for clause in source["clauses"]:
                self.assertEqual(clause["source_modality"], clause["adopted_modality"])

    def test_reviewed_claims_and_exact_source_groups_have_one_owner(self):
        sources = self.atomic_sources()
        hash_owners: dict[str, str | None] = {}
        for source in sources:
            for clause in source["clauses"]:
                owner = clause["requirement_id"]
                previous = hash_owners.setdefault(clause["clause_sha256"], owner)
                self.assertEqual(previous, owner)
        false_fragments = {
            "CLAIM-STB-0091",
            "CLAIM-STB-0111",
            "CLAIM-STB-0194",
            "CLAIM-STB-0231",
            "CLAIM-STB-0442",
            "CLAIM-STB-0573",
        }
        self.assertTrue(false_fragments <= {
            item["claim_id"]
            for item in sources
            if all(clause["relationship"] == "provenance" for clause in item["clauses"])
        })

    def test_missing_owner_decisions_are_concise_modular_laws(self):
        expected = {
            "object.step.urgency-metadata": "MAY",
            "object.life-area.suggested-defaults": "MAY",
            "surface.time.today-control": "MUST",
            "surface.time.creation-routes": "SHOULD",
            "object.event.source-selection": "MUST",
            "surface.time.step-membership": "MUST",
            "surface.you.no-knowledge-model": "MUST NOT",
            "global.trust.proportional-receipts": "MUST",
            "object.goal-path.emotional-posture": "MUST",
            "surface.today.missed-placement-continuity": "MUST",
            "object.goal.automation-ladder": "MUST",
            "journey.calendar-diff.grouping": "MUST",
            "journey.calendar-diff.conflict-choice": "MUST",
            "journey.calendar-diff.notification-handoff": "MUST NOT",
            "object.event.all-day-capacity": "MUST",
            "object.event.time-zone": "MUST",
            "system.scheduling.transition-buffer": "MUST",
        }
        actual = {
            requirement.concept: requirement.modality.value
            for requirement in self.requirements()
            if requirement.concept in expected
        }
        self.assertEqual(actual, expected)

    def test_all_decisions_bind_exact_owners_without_owner_wrappers(self):
        sources = [
            item
            for item in self.atomic_sources()
            if self.source_batch(item).startswith("decisions_")
        ]
        decisions = {item["decision_number"]: item for item in sources if any(clause["requirement_id"] for clause in item["clauses"])}
        provenance = {item["decision_number"]: item for item in sources if not any(clause["requirement_id"] for clause in item["clauses"])}
        self.assertEqual(set(decisions) | set(provenance), set(range(1, 202)))
        self.assertEqual(set(provenance), {69})
        self.assertEqual(
            Counter(claim["decision_mapping_status"] for claim in decisions.values())
            + Counter({provenance[69]["decision_mapping_status"]: 1}),
            Counter({"independently_reviewed": 156, "unreviewed": 45}),
        )
        for claim in decisions.values():
            for clause in claim["clauses"]:
                owner = clause["requirement_id"]
                if owner is None:
                    continue
                self.assertFalse(owner.startswith("OWNER-"))
                self.assertFalse(re.search(r"DECISION-?\d", owner))
                self.assertEqual(len(clause["owner_clause_sha256"]), 64)
        for number in {35, 120, 148, 149, 150, 153, 157, 159, 161, 165, 175, 187, 188, 189, 190, 191}:
            self.assertIn(number, decisions)
        self.assertTrue(all(clause["source_modality"] == clause["adopted_modality"] for clause in decisions[75]["clauses"]))

    def test_atomic_nondecision_compound_batches_map_every_reviewed_claim(self):
        sources = [
            item
            for item in self.atomic_sources()
            if self.source_batch(item).startswith("nondecision_compound_")
        ]
        mapped = {item["claim_id"] for item in sources if any(clause["requirement_id"] for clause in item["clauses"])}
        provenance = {item["claim_id"] for item in sources if not any(clause["requirement_id"] for clause in item["clauses"])}
        self.assertEqual(len(mapped | provenance), 179)
        self.assertFalse(mapped & provenance)
        for source in sources:
            for clause in source["clauses"]:
                self.assertEqual(clause["source_modality"], clause["adopted_modality"])

    def test_source_modality_is_not_promoted_by_mapping(self):
        for source in self.atomic_sources():
            for entry in source["clauses"]:
                self.assertIn(
                    entry["source_modality"],
                    {"INFORMATIONAL", "MAY", "MUST", "MUST NOT", "SHOULD", "SHOULD NOT"},
                )
                self.assertEqual(entry["adopted_modality"], entry["source_modality"])


if __name__ == "__main__":
    unittest.main()
