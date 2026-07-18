from __future__ import annotations

import json
import tomllib
import unittest
from pathlib import Path

from tools.ambitions_canon.migration import (
    validate_legacy_semantic_migration,
    verify_catalog,
)


ROOT = Path(__file__).resolve().parents[2]
LEDGER_PATH = ROOT / "docs/canon/migration/legacy-semantic-migration.json"
PURGE_PLAN_PATH = ROOT / "docs/canon/migration/task-29-legacy-purge-plan.toml"


class LegacySemanticMigrationTests(unittest.TestCase):
    def test_every_registered_legacy_source_has_a_digest_bound_migration_record(self) -> None:
        ledger = json.loads(LEDGER_PATH.read_text(encoding="utf-8"))
        catalog = json.loads(
            (ROOT / "docs/canon/migration/source-catalog.json").read_text(
                encoding="utf-8"
            )
        )
        recorded_paths = {record["source_path"] for record in ledger["sources"]}
        expected_paths = sorted(
            item["repo_path"]
            for item in catalog["sources"]
            if item.get("kind") == "repo"
            and str(item.get("repo_path", "")).startswith(
                ("docs/truth/", "docs/constitution/")
            )
            and item["repo_path"] in recorded_paths
        )
        records = ledger["sources"]
        self.assertEqual(
            [record["source_path"] for record in records], expected_paths
        )
        self.assertTrue(all(record["content_sha256"] for record in records))
        self.assertTrue(all(record["canonical_owner_id"] for record in records))
        self.assertTrue(all(record["source_text"] for record in records))

    def test_recorded_source_bytes_remain_valid_after_legacy_purge(self) -> None:
        ledger = validate_legacy_semantic_migration(ROOT, LEDGER_PATH)
        self.assertEqual(len(ledger["sources"]), 52)

    def test_catalog_verifies_purged_legacy_sources_from_validated_ledger(self) -> None:
        findings = verify_catalog(
            ROOT / "docs/canon/migration/source-catalog.json",
            ROOT,
        )
        self.assertEqual(findings, ())

    def test_historical_deleted_provenance_is_never_active_authority(self) -> None:
        catalog = json.loads(
            (ROOT / "docs/canon/migration/source-catalog.json").read_text(
                encoding="utf-8"
            )
        )
        historical = [
            record
            for record in catalog["sources"]
            if record.get("authority_claim")
            == "historical deleted repo provenance retained solely for migration traceability; not active authority or implementation proof"
        ]
        self.assertTrue(historical)
        self.assertTrue(
            all(
                str(record.get("repo_path", "")).startswith("docs/constitution/")
                for record in historical
            )
        )

    def test_ledger_labels_only_current_canon_ids_as_active_requirements(self) -> None:
        active_ids = set(
            json.loads(
                (ROOT / "docs/canon/generated/requirement-graph.json").read_text(
                    encoding="utf-8"
                )
            )["requirement_ids"]
        )
        ledger = json.loads(LEDGER_PATH.read_text(encoding="utf-8"))
        invalid = {
            requirement_id
            for record in ledger["sources"]
            for requirement_id in record["active_requirement_ids"]
            if requirement_id not in active_ids
        }
        self.assertEqual(invalid, set())

    def test_purge_plan_claim_replacements_match_disposition_evidence(self) -> None:
        with PURGE_PLAN_PATH.open("rb") as handle:
            plan = tomllib.load(handle)
        dispositions = json.loads(
            (ROOT / "docs/canon/migration/claim-dispositions.json").read_text(
                encoding="utf-8"
            )
        )["claims"]
        active_ids = set(
            json.loads(
                (ROOT / "docs/canon/generated/requirement-graph.json").read_text(
                    encoding="utf-8"
                )
            )["requirement_ids"]
        )
        by_path = {artifact["locator"]: artifact for artifact in plan["artifact"]}
        for record in json.loads(LEDGER_PATH.read_text(encoding="utf-8"))["sources"]:
            with self.subTest(source_path=record["source_path"]):
                artifact = by_path[record["source_path"]]
                expected = {
                    claim["claim_id"]: (
                        claim["target_id"]
                        if claim.get("disposition") in {"keep", "rewrite", "compose"}
                        and isinstance(claim.get("target_id"), str)
                        and claim["target_id"] in active_ids
                        else "CONST-HISTORY-SUPERSESSION-001"
                    )
                    for claim in dispositions
                    if claim.get("source_id") == record["source_id"]
                    and isinstance(claim.get("claim_id"), str)
                }
                actual = {
                    item["claim_id"]: item["replacement_id"]
                    for item in artifact.get("claim_disposition", [])
                }
                if not expected:
                    expected = {
                        record["semantic_record_id"]: "CONST-HISTORY-SUPERSESSION-001"
                    }
                self.assertEqual(actual, expected)

    def test_task29_plan_proves_nonapproval_gate_inputs_without_self_approval(self) -> None:
        with PURGE_PLAN_PATH.open("rb") as handle:
            plan = tomllib.load(handle)
        artifacts = plan["artifact"]
        self.assertEqual(len(artifacts), 52)
        self.assertTrue(all(item["incoming_links_rewritten"] for item in artifacts))
        self.assertTrue(
            all(item["external_references_reconciled"] for item in artifacts)
        )
        self.assertTrue(all(item["unique_content_extracted"] for item in artifacts))
        self.assertTrue(all(not item["owner_approved"] for item in artifacts))
        self.assertTrue(all(not item["independent_review"] for item in artifacts))
        self.assertTrue(
            all(not item["owner_approval_attestation_sha256"] for item in artifacts)
        )
        self.assertTrue(
            all(
                not item["independent_review_attestation_sha256"]
                for item in artifacts
            )
        )


if __name__ == "__main__":
    unittest.main()
