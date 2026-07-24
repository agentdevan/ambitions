from __future__ import annotations

import json
import tempfile
import unittest
from pathlib import Path

from tools.capability_atlas.classification_pipeline import (
    AMBIGUOUS_DIRECTORY,
    CLASSIFICATION_CORE_PATHS,
    EXCLUSION_DIRECTORY,
    QUALIFIED_DIRECTORY,
    output_drift,
    render_outputs,
    write_outputs,
)
from tools.capability_atlas.classification_refinement import (
    apply_refined_classification,
)
from tools.capability_atlas.cli import SUPPORTED_COMMANDS, main
from tools.capability_atlas.discover import compile_discovery
from tools.capability_atlas.model import CandidateRecord, EvidenceExcerpt
from tools.capability_atlas.outputs import (
    CANDIDATE_SHARD_DIRECTORY,
    CORE_OUTPUT_PATHS,
    SOURCE_SHARD_DIRECTORY,
)


class CapabilityAtlasDiscoveryTests(unittest.TestCase):
    def setUp(self) -> None:
        self.temporary_directory = tempfile.TemporaryDirectory()
        self.root = Path(self.temporary_directory.name)
        (self.root / "docs/capabilities").mkdir(parents=True)
        (self.root / "docs/canon/specifications/global").mkdir(parents=True)
        (self.root / "Native/Ambitions").mkdir(parents=True)
        (self.root / "Native/node_modules").mkdir(parents=True)

        source_register = {
            "schema_version": 1,
            "authority": "non_normative_discovery_control",
            "repository": "agentdevan/ambitions",
            "baseline_ref": "fixture-main",
            "source_families": [
                {
                    "id": "SRC-NORMATIVE-SPECS",
                    "name": "Normative specifications",
                    "path_patterns": ["docs/canon/specifications/**/*.md"],
                    "authority_class": "normative",
                    "status": "covered",
                },
                {
                    "id": "SRC-OWNER-SEEDS",
                    "name": "Owner seeds",
                    "path_patterns": ["docs/capabilities/seed-capabilities.json"],
                    "authority_class": "owner_seed_non_normative",
                    "status": "covered",
                },
                {
                    "id": "SRC-PRODUCTION",
                    "name": "Production source",
                    "path_patterns": ["Native/**/*.swift"],
                    "authority_class": "implementation_evidence_only",
                    "status": "covered",
                },
            ],
        }
        seed_payload = {
            "schema_version": 1,
            "authority": "non_normative_discovery_input",
            "seeds": [
                {
                    "seed_id": "SEED-001",
                    "owner_wording": "Skill transference",
                    "proposed_name": "Skill Transference",
                    "authority_status": "owner_seed",
                    "specification_maturity": "unframed",
                    "implementation_status": "not_assessed",
                    "verification_status": "not_assessed",
                    "disposition": "preserve_for_repository_reconciliation",
                }
            ],
        }
        (self.root / "docs/capabilities/discovery-source-register.json").write_text(
            json.dumps(source_register),
            encoding="utf-8",
        )
        (self.root / "docs/capabilities/seed-capabilities.json").write_text(
            json.dumps(seed_payload),
            encoding="utf-8",
        )
        repeated_headings = "\n".join(
            f"## Search Capability {index:03d}" for index in range(510)
        )
        (self.root / "docs/canon/specifications/global/search.md").write_text(
            "# Search\n\n"
            + repeated_headings
            + "\n\nAmbitions must help the person find goals, steps, attachments, and actions through private local search.\n",
            encoding="utf-8",
        )
        (self.root / "Native/Ambitions/SearchRuntime.swift").write_text(
            "// Ambitions can provide contextual search commands without making code authoritative.\n",
            encoding="utf-8",
        )
        (self.root / "Native/node_modules/Noise.swift").write_text(
            "// Ambitions can provide fake search capability from dependencies.\n",
            encoding="utf-8",
        )

    def tearDown(self) -> None:
        self.temporary_directory.cleanup()

    def test_supported_commands_are_bounded(self) -> None:
        self.assertEqual(SUPPORTED_COMMANDS, {"version", "build", "check"})

    def test_discovery_is_deterministic_and_preserves_owner_seed_first(self) -> None:
        first = compile_discovery(self.root)
        second = compile_discovery(self.root)
        self.assertEqual(render_outputs(first), render_outputs(second))
        self.assertEqual(first.candidates[0].candidate_id, "CAND-SEED-001")
        self.assertEqual(first.candidates[0].exact_terminology, "Skill transference")
        self.assertEqual(first.candidates[0].authority_status, "owner_seed")

    def test_repository_candidates_have_stable_provenance_and_ids(self) -> None:
        compilation = compile_discovery(self.root)
        repository_candidates = [
            item
            for item in compilation.candidates
            if item.authority_status == "repository_candidate"
        ]
        self.assertGreaterEqual(len(repository_candidates), 512)
        for candidate in repository_candidates:
            self.assertRegex(candidate.candidate_id, r"^CAND-[0-9A-F]{16}$")
            self.assertEqual(len(candidate.evidence), 1)
            self.assertRegex(
                candidate.evidence[0].evidence_fingerprint,
                r"^[0-9a-f]{64}$",
            )
            self.assertGreater(candidate.evidence[0].start_line, 0)

    def test_candidate_identity_does_not_depend_on_mutable_name_hint(self) -> None:
        compilation = compile_discovery(self.root)
        candidate = next(
            item
            for item in compilation.candidates
            if item.authority_status == "repository_candidate"
        )
        renamed = CandidateRecord.from_evidence(
            candidate.evidence[0],
            normalized_name_hint="A Different Reconciliation Hint",
        )
        self.assertEqual(candidate.candidate_id, renamed.candidate_id)

    def test_owner_seed_is_qualified_without_becoming_canonical(self) -> None:
        candidate = apply_refined_classification(compile_discovery(self.root).candidates[0])
        self.assertEqual(candidate.classification, "capability")
        self.assertEqual(candidate.qualification_status, "qualified")
        self.assertEqual(candidate.classification_reason_code, "direct_owner_seed")
        self.assertEqual(candidate.authority_status, "owner_seed")

    def test_implementation_source_is_preserved_as_supporting_implementation(self) -> None:
        evidence = EvidenceExcerpt.create(
            family_id="SRC-PRODUCTION",
            authority_class="implementation_evidence_only",
            source_path="Native/Ambitions/SearchRuntime.swift",
            start_line=1,
            end_line=1,
            exact_text="Ambitions can provide contextual search commands.",
            extraction_kind="person_facing_promise_hint",
            extraction_rationale="fixture",
        )
        candidate = CandidateRecord.from_evidence(
            evidence,
            normalized_name_hint="Contextual Search Commands",
        )
        classified = apply_refined_classification(candidate)
        self.assertEqual(classified.classification, "implementation")
        self.assertEqual(classified.qualification_status, "supporting")
        self.assertEqual(
            classified.disposition,
            "preserve_as_supporting_implementation",
        )

    def test_machine_command_is_excluded_as_evidence_not_deleted(self) -> None:
        evidence = EvidenceExcerpt.create(
            family_id="SRC-AUDITS",
            authority_class="audit_evidence",
            source_path="docs/audits/search.json",
            start_line=10,
            end_line=10,
            exact_text='"command": "python3 scripts/check-search.py"',
            extraction_kind="person_facing_promise_hint",
            extraction_rationale="fixture",
        )
        candidate = CandidateRecord.from_evidence(
            evidence,
            normalized_name_hint="python3 scripts/check-search.py",
        )
        classified = apply_refined_classification(candidate)
        self.assertEqual(classified.classification, "evidence")
        self.assertEqual(classified.qualification_status, "supporting")
        self.assertEqual(
            classified.classification_reason_code,
            "file_or_artifact_reference",
        )

    def test_audit_capability_claim_requires_product_authority(self) -> None:
        evidence = EvidenceExcerpt.create(
            family_id="SRC-AUDITS",
            authority_class="audit_evidence",
            source_path="docs/audits/search.md",
            start_line=20,
            end_line=20,
            exact_text="Ambitions helps a person find and inspect local goals through private search.",
            extraction_kind="person_facing_promise_hint",
            extraction_rationale="fixture",
        )
        candidate = CandidateRecord.from_evidence(
            evidence,
            normalized_name_hint="Private Goal Search",
        )
        classified = apply_refined_classification(candidate)
        self.assertEqual(classified.classification, "ambiguous")
        self.assertEqual(classified.qualification_status, "ambiguous")
        self.assertEqual(
            classified.classification_reason_code,
            "capability_like_evidence_requires_authority_source",
        )

    def test_excluded_dependency_paths_are_not_harvested(self) -> None:
        compilation = compile_discovery(self.root)
        harvested_paths = {item.path for item in compilation.source_files}
        self.assertIn("Native/Ambitions/SearchRuntime.swift", harvested_paths)
        self.assertNotIn("Native/node_modules/Noise.swift", harvested_paths)

    def test_every_configured_family_has_explicit_coverage(self) -> None:
        compilation = compile_discovery(self.root)
        self.assertEqual(
            {item.family_id for item in compilation.coverage},
            {"SRC-NORMATIVE-SPECS", "SRC-OWNER-SEEDS", "SRC-PRODUCTION"},
        )
        self.assertTrue(all(item.status == "covered" for item in compilation.coverage))
        owner_coverage = next(
            item
            for item in compilation.coverage
            if item.family_id == "SRC-OWNER-SEEDS"
        )
        self.assertEqual(owner_coverage.extracted_candidate_count, 1)

    def test_outputs_are_sharded_bounded_and_drift_checked(self) -> None:
        compilation = compile_discovery(self.root)
        outputs = render_outputs(compilation)
        self.assertTrue(set(CORE_OUTPUT_PATHS).issubset(outputs))
        self.assertTrue(set(CLASSIFICATION_CORE_PATHS).issubset(outputs))
        candidate_shards = sorted(
            path for path in outputs if path.parent == CANDIDATE_SHARD_DIRECTORY
        )
        source_shards = sorted(
            path for path in outputs if path.parent == SOURCE_SHARD_DIRECTORY
        )
        qualified_shards = sorted(
            path for path in outputs if path.parent == QUALIFIED_DIRECTORY
        )
        exclusion_shards = sorted(
            path for path in outputs if path.parent == EXCLUSION_DIRECTORY
        )
        ambiguous_shards = sorted(
            path for path in outputs if path.parent == AMBIGUOUS_DIRECTORY
        )
        self.assertGreaterEqual(len(candidate_shards), 2)
        self.assertGreaterEqual(len(source_shards), 1)
        self.assertGreaterEqual(len(qualified_shards), 2)
        self.assertGreaterEqual(len(exclusion_shards), 1)
        self.assertEqual(ambiguous_shards, [])
        self.assertTrue(
            all(len(content.encode("utf-8")) < 1_000_000 for content in outputs.values())
        )
        self.assertEqual(set(output_drift(self.root, outputs)), set(outputs))

        write_outputs(self.root, outputs)
        self.assertEqual(output_drift(self.root, outputs), ())

        stale_path = self.root / EXCLUSION_DIRECTORY / "stale.json"
        stale_path.write_text("{}\n", encoding="utf-8")
        self.assertIn(
            EXCLUSION_DIRECTORY / "stale.json",
            output_drift(self.root, outputs),
        )

    def test_cli_build_then_check(self) -> None:
        self.assertEqual(main(["build"], root=self.root), 0)
        self.assertEqual(main(["check"], root=self.root), 0)


if __name__ == "__main__":
    unittest.main()
