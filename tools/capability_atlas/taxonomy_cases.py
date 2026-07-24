from __future__ import annotations

import json
import sys
import tempfile
import unittest
from pathlib import Path

REPOSITORY_ROOT = Path(__file__).resolve().parents[2]
if str(REPOSITORY_ROOT) not in sys.path:
    sys.path.insert(0, str(REPOSITORY_ROOT))

from tools.capability_atlas.discover import DiscoveryCompilation
from tools.capability_atlas.model import CandidateRecord, EvidenceExcerpt
from tools.capability_atlas.taxonomy import TAXONOMY_PATH, validate_taxonomy


class CapabilityAtlasTaxonomyTests(unittest.TestCase):
    def setUp(self) -> None:
        self.temporary_directory = tempfile.TemporaryDirectory()
        self.root = Path(self.temporary_directory.name)
        (self.root / TAXONOMY_PATH.parent).mkdir(parents=True)
        evidence = EvidenceExcerpt.create(
            family_id="SRC-OWNER-SEEDS",
            authority_class="owner_seed_non_normative",
            source_path="docs/capabilities/seed-capabilities.json",
            start_line=1,
            end_line=1,
            exact_text="Skill transference",
            extraction_kind="owner_seed",
            extraction_rationale="fixture",
        )
        candidate = CandidateRecord(
            candidate_id="CAND-SEED-001",
            authority_status="owner_seed",
            exact_terminology="Skill transference",
            normalized_name_hint="Skill Transference",
            classification="capability_candidate",
            specification_maturity="unframed",
            implementation_status="not_assessed",
            verification_status="not_assessed",
            disposition="preserve_for_repository_reconciliation",
            evidence=(evidence,),
            owner_seed_id="SEED-001",
        )
        self.compilation = DiscoveryCompilation(
            repository="agentdevan/ambitions",
            baseline_ref="fixture-main",
            candidates=(candidate,),
            source_files=(),
            coverage=(),
        )

    def tearDown(self) -> None:
        self.temporary_directory.cleanup()

    def taxonomy_payload(self) -> dict[str, object]:
        return {
            "schema_version": 1,
            "authority": "non_normative_phase_c_taxonomy",
            "governing_rules": {
                "maximum_secondary_domains": 3,
            },
            "domains": [
                {
                    "domain_id": "DOM-CONTEXT",
                    "name": "Personal Context, Learning, and Transfer",
                    "purpose": "Understand and reuse learned personal patterns.",
                    "owns": ["skill transfer"],
                    "does_not_own": ["goal path construction"],
                    "anti_overlap_rule": "Learning informs paths without owning them.",
                },
                {
                    "domain_id": "DOM-PATH",
                    "name": "Goals, Paths, and Progression",
                    "purpose": "Own pursuits and coherent progression.",
                    "owns": ["goal path formation"],
                    "does_not_own": ["skill learning"],
                    "anti_overlap_rule": "Paths consume context without owning learning.",
                },
            ],
            "assignments": [
                {
                    "candidate_id": "CAND-SEED-001",
                    "candidate_name": "Skill Transference",
                    "primary_domain_id": "DOM-CONTEXT",
                    "secondary_domain_ids": ["DOM-PATH"],
                    "assignment_rationale": "The promise is learned transfer.",
                }
            ],
            "validation_expectations": {
                "qualified_candidate_count": 1,
                "assignment_count": 1,
            },
        }

    def write_taxonomy(self, payload: dict[str, object]) -> None:
        (self.root / TAXONOMY_PATH).write_text(
            json.dumps(payload),
            encoding="utf-8",
        )

    def test_valid_taxonomy_covers_every_qualified_candidate_once(self) -> None:
        self.write_taxonomy(self.taxonomy_payload())
        validation = validate_taxonomy(self.root, self.compilation)
        self.assertTrue(validation.is_valid)
        self.assertEqual(validation.errors, ())
        self.assertEqual(
            validation.payload["coverage"]["unassigned_candidate_ids"],
            [],
        )
        self.assertEqual(
            validation.payload["primary_domain_counts"],
            {"DOM-CONTEXT": 1},
        )

    def test_missing_assignment_is_reported(self) -> None:
        payload = self.taxonomy_payload()
        payload["assignments"] = []
        payload["validation_expectations"]["assignment_count"] = 0
        self.write_taxonomy(payload)
        validation = validate_taxonomy(self.root, self.compilation)
        self.assertFalse(validation.is_valid)
        self.assertIn(
            "unassigned qualified candidates: CAND-SEED-001",
            validation.errors,
        )

    def test_unknown_and_over_broad_domains_are_reported(self) -> None:
        payload = self.taxonomy_payload()
        payload["governing_rules"]["maximum_secondary_domains"] = 1
        assignment = payload["assignments"][0]
        assignment["primary_domain_id"] = "DOM-UNKNOWN"
        assignment["secondary_domain_ids"] = ["DOM-CONTEXT", "DOM-PATH"]
        self.write_taxonomy(payload)
        validation = validate_taxonomy(self.root, self.compilation)
        self.assertFalse(validation.is_valid)
        self.assertEqual(
            validation.payload["coverage"]["unknown_domain_ids"],
            ["DOM-UNKNOWN"],
        )
        self.assertEqual(
            validation.payload["coverage"]["over_broad_candidate_ids"],
            ["CAND-SEED-001"],
        )

    def test_duplicate_primary_assignment_is_reported(self) -> None:
        payload = self.taxonomy_payload()
        payload["assignments"].append(dict(payload["assignments"][0]))
        payload["validation_expectations"]["assignment_count"] = 2
        self.write_taxonomy(payload)
        validation = validate_taxonomy(self.root, self.compilation)
        self.assertFalse(validation.is_valid)
        self.assertEqual(
            validation.payload["coverage"]["duplicate_primary_assignments"],
            ["CAND-SEED-001"],
        )


if __name__ == "__main__":
    unittest.main()
