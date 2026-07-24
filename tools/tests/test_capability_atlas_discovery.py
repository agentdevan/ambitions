from __future__ import annotations

import json
import tempfile
import unittest
from pathlib import Path

from tools.capability_atlas.cli import SUPPORTED_COMMANDS, main
from tools.capability_atlas.discover import (
    OUTPUT_PATHS,
    compile_discovery,
    output_drift,
    render_outputs,
    write_outputs,
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
                    "status": "pending",
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
                    "status": "pending",
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
        (self.root / "docs/canon/specifications/global/search.md").write_text(
            """# Search\n\n## Semantic Search and Command\n\nAmbitions must help the person find goals, steps, attachments, and actions through private local search.\n""",
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
        self.assertGreaterEqual(len(repository_candidates), 3)
        for candidate in repository_candidates:
            self.assertRegex(candidate.candidate_id, r"^CAND-[0-9A-F]{16}$")
            self.assertEqual(len(candidate.evidence), 1)
            self.assertRegex(
                candidate.evidence[0].evidence_fingerprint,
                r"^[0-9a-f]{64}$",
            )
            self.assertGreater(candidate.evidence[0].start_line, 0)

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

    def test_build_writes_outputs_and_check_detects_drift(self) -> None:
        compilation = compile_discovery(self.root)
        outputs = render_outputs(compilation)
        self.assertEqual(set(outputs), set(OUTPUT_PATHS))
        self.assertEqual(output_drift(self.root, outputs), OUTPUT_PATHS)

        write_outputs(self.root, outputs)
        self.assertEqual(output_drift(self.root, outputs), ())

        candidate_path = self.root / "docs/capabilities/candidate-capabilities.json"
        candidate_path.write_text("{}\n", encoding="utf-8")
        self.assertEqual(
            output_drift(self.root, outputs),
            (Path("docs/capabilities/candidate-capabilities.json"),),
        )

    def test_cli_build_then_check(self) -> None:
        self.assertEqual(main(["build"], root=self.root), 0)
        self.assertEqual(main(["check"], root=self.root), 0)


if __name__ == "__main__":
    unittest.main()
