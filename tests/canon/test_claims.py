import contextlib
import hashlib
import io
import json
import os
import re
import socket
import stat
import subprocess
import sys
import tempfile
import unittest
from dataclasses import FrozenInstanceError
from pathlib import Path
from unittest import mock

import tools.ambitions_canon.migration as migration
import tools.ambitions_canon.model as model
from tools.ambitions_canon.cli import main
from tools.ambitions_canon.model import CanonError


FIXTURE = Path(__file__).parent / "fixtures/claims-valid.json"


def source_record(
    source_id: str,
    path: str,
    *,
    kind: str = "repo",
    content: bytes,
) -> dict[str, object]:
    common = {
        "authority_claim": "migration provenance only",
        "kind": kind,
        "locator": f"{kind}:{path}",
        "owner": "owner",
        "source_id": source_id,
        "title": path,
        "updated_at": "2026-07-11",
    }
    if kind in {"linear", "figma"}:
        return {
            **common,
            "raw_byte_length": len(content),
            "raw_path": path,
            "raw_sha256": hashlib.sha256(content).hexdigest(),
        }
    return {
        **common,
        "content_sha256": hashlib.sha256(content).hexdigest(),
        "repo_path": path,
        "repository_revision": "0" * 40,
    }


def claim(**overrides: object) -> dict[str, object]:
    return {
        "authority_claim": True,
        "claim_id": "CLAIM-TEST-001",
        "concept": "surface.today.primary-identity",
        "conditions": [],
        "disposition": "keep",
        "exceptions": [],
        "modality": "MUST",
        "original_text": "Today MUST present Start here.",
        "owner_approval": "owner-approved:test",
        "predicate": "presents",
        "rationale": "Preserves the approved primary decision object.",
        "scope": "surface.today",
        "source_id": "SOURCE-A",
        "source_location": "line:2",
        "subject": "Today",
        "target_class": "specification",
        "target_id": "SURFACE-TODAY-PRIMARY-001",
        "value": "Start here",
        **overrides,
    }


def batch(
    claims: list[dict[str, object]],
    dispositions: list[dict[str, object]] | None = None,
    *,
    batch_id: str = "test-domain",
) -> dict[str, object]:
    return {
        "batch_id": batch_id,
        "claims": claims,
        "schema_version": 1,
        "source_section_dispositions": dispositions or [],
    }


class AtomicClaimModelTests(unittest.TestCase):
    def test_tracked_json_schema_is_closed_and_matches_runtime_claim_fields(self):
        schema_path = Path("docs/canon/schemas/claim.schema.json")
        self.assertTrue(schema_path.is_file(), "claim schema must exist")
        schema = json.loads(schema_path.read_text(encoding="utf-8"))
        claim_schema = schema["$defs"]["claim"]
        self.assertFalse(schema["additionalProperties"])
        self.assertFalse(claim_schema["additionalProperties"])
        self.assertEqual(
            set(claim_schema["properties"]),
            migration.CLAIM_FIELDS | migration.DECISION_CLAIM_FIELDS,
        )
        self.assertEqual(set(claim_schema["required"]), migration.CLAIM_FIELDS)
        decision_rules = [
            rule
            for rule in claim_schema["allOf"]
            if rule.get("if", {})
            .get("properties", {})
            .get("source_location", {})
            .get("const", "")
            .startswith("decision:")
        ]
        self.assertEqual(len(decision_rules), 201)
        disposition_rules = {
            rule.get("if", {}).get("properties", {}).get("disposition", {}).get("const")
            for rule in claim_schema["allOf"]
        }
        self.assertTrue(
            {"keep", "rewrite", "compose", "reject", "provenance_only", "conflict"}
            <= disposition_rules
        )

    def test_tracked_json_schema_rejects_whitespace_only_semantic_strings(self):
        schema = json.loads(
            Path("docs/canon/schemas/claim.schema.json").read_text(encoding="utf-8")
        )
        checked = 0

        def inspect(value: object, path: str = "schema") -> None:
            nonlocal checked
            if isinstance(value, dict):
                if value.get("type") == "string" and value.get("minLength") == 1:
                    checked += 1
                    pattern = value.get("pattern")
                    self.assertIsInstance(pattern, str, path)
                    self.assertIsNone(re.search(pattern, " \t\n"), path)
                for key, item in value.items():
                    inspect(item, f"{path}.{key}")
            elif isinstance(value, list):
                for index, item in enumerate(value):
                    inspect(item, f"{path}[{index}]")

        inspect(schema)
        self.assertGreaterEqual(checked, 418)

    def test_complete_claim_parses_and_is_deeply_immutable(self):
        parse = getattr(migration, "parse_claim_batch", None)
        self.assertIsNotNone(parse, "claim parser must exist")
        parsed = parse(FIXTURE.read_bytes(), FIXTURE)
        parsed_claim = parsed.claims[0]
        self.assertIsInstance(parsed_claim, model.AtomicClaim)
        self.assertEqual(parsed_claim.conditions, ())
        with self.assertRaises(FrozenInstanceError):
            parsed_claim.concept = "changed"
        with self.assertRaises(AttributeError):
            parsed_claim.conditions.append("changed")

    def test_stable_domain_prefixed_claim_id_is_accepted(self):
        parsed = migration.parse_claim_batch(
            json.dumps(batch([claim(claim_id="MIG-MOM-0001")])).encode(),
            Path("batch.json"),
        )
        self.assertEqual(parsed.claims[0].claim_id, "MIG-MOM-0001")

    def test_closed_runtime_shape_rejects_unknown_field_and_enum(self):
        parse = getattr(migration, "parse_claim_batch", None)
        self.assertIsNotNone(parse, "claim parser must exist")
        for changed in (
            claim(surprise=True),
            claim(concept="Surface Today"),
            claim(disposition="later"),
            claim(target_class="screen"),
        ):
            with self.subTest(changed=changed):
                with self.assertRaises(CanonError):
                    parse(json.dumps(batch([changed])).encode(), Path("batch.json"))

    def test_semantically_required_strings_reject_blank_and_invalid_utf8(self):
        parse = getattr(migration, "parse_claim_batch", None)
        self.assertIsNotNone(parse, "claim parser must exist")
        for field in (
            "claim_id",
            "source_id",
            "source_location",
            "concept",
            "subject",
            "predicate",
            "value",
            "modality",
            "scope",
            "original_text",
            "rationale",
        ):
            with self.subTest(field=field):
                with self.assertRaises(CanonError):
                    parse(
                        json.dumps(batch([claim(**{field: "  "})])).encode(),
                        Path("batch.json"),
                    )
        with self.assertRaises(CanonError):
            parse(b'{"bad":"\xff"}', Path("batch.json"))

    def test_disposition_target_and_rationale_laws_fail_closed(self):
        parse = getattr(migration, "parse_claim_batch", None)
        self.assertIsNotNone(parse, "claim parser must exist")
        invalid = (
            claim(
                disposition="provenance_only",
                target_class="provenance",
                target_id=None,
                rationale="",
            ),
            claim(disposition="keep", target_id=None),
            claim(disposition="rewrite", target_id=None),
            claim(disposition="compose", target_id=None),
            claim(
                disposition="conflict",
                target_class="decision_docket",
                target_id="LAW-A-001",
            ),
            claim(
                disposition="reject", target_class="rejection", target_id="LAW-A-001"
            ),
        )
        for changed in invalid:
            with self.subTest(disposition=changed["disposition"]):
                with self.assertRaises(CanonError):
                    parse(json.dumps(batch([changed])).encode(), Path("batch.json"))

    def test_linear_decision_claim_requires_number_matched_owner_evidence(self):
        unsupported = claim(
            authority_claim=False,
            disposition="provenance_only",
            owner_approval=None,
            source_id="LINEAR-CANON-V3",
            source_location="decision:2",
            target_class="provenance",
            target_id=None,
        )
        with self.assertRaises(CanonError) as caught:
            migration.parse_claim_batch(
                json.dumps(batch([unsupported])).encode(), Path("batch.json")
            )
        self.assertEqual(caught.exception.code, "CLAIM_DECISION_PROVENANCE_REQUIRED")

        supported = {
            **unsupported,
            "owner_approval": "linear-comment:11111111-1111-1111-1111-111111111111:decision:2",
            "owner_evidence_text": "Decision 2 owner text",
            "owner_evidence_rationale": "Decision 2 owner rationale",
        }
        parsed = migration.parse_claim_batch(
            json.dumps(batch([supported])).encode(), Path("batch.json")
        )
        self.assertEqual(parsed.claims[0].source_location, "decision:2")

        supported["owner_approval"] = (
            "linear-comment:11111111-1111-1111-1111-111111111111:decision:3"
        )
        with self.assertRaises(CanonError):
            migration.parse_claim_batch(
                json.dumps(batch([supported])).encode(), Path("batch.json")
            )

    def test_duplicate_claim_and_source_section_disposition_fail(self):
        parse = getattr(migration, "parse_claim_batch", None)
        self.assertIsNotNone(parse, "claim parser must exist")
        duplicate_disposition = {
            "disposition": "no_normative_claims",
            "rationale": "No product law in this section.",
            "source_id": "SOURCE-A",
            "source_location": "line:1",
        }
        for payload in (
            batch([claim(), claim()]),
            batch([], [duplicate_disposition, duplicate_disposition]),
        ):
            with self.assertRaises(CanonError):
                parse(json.dumps(payload).encode(), Path("batch.json"))


class ClaimImportTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.root = Path(self.temporary.name)
        (self.root / ".gitignore").write_text(".codex/\n", encoding="utf-8")
        subprocess.run(("git", "init", "-q"), cwd=self.root, check=True)
        subprocess.run(
            ("git", "config", "user.name", "Canon Tests"),
            cwd=self.root,
            check=True,
        )
        subprocess.run(
            ("git", "config", "user.email", "canon@example.invalid"),
            cwd=self.root,
            check=True,
        )
        source = self.root / "source.md"
        source.write_text(
            "# One\nToday MUST present Start here.\n## Two\nMetadata only.\n",
            encoding="utf-8",
        )
        subprocess.run(
            ("git", "add", ".gitignore", "source.md"), cwd=self.root, check=True
        )
        subprocess.run(("git", "commit", "-qm", "baseline"), cwd=self.root, check=True)
        self.claim_dir = self.root / ".codex/canon-migration/claims"
        self.claim_dir.mkdir(parents=True)
        self.catalog = self.root / "docs/canon/migration/source-catalog.json"
        self.catalog.parent.mkdir(parents=True)
        self.catalog.write_text(
            json.dumps(
                {
                    "schema_version": 1,
                    "sources": [
                        source_record(
                            "SOURCE-A", "source.md", content=source.read_bytes()
                        )
                    ],
                },
                indent=2,
                sort_keys=True,
            )
            + "\n",
            encoding="utf-8",
        )
        self.output = self.catalog.with_name("claim-dispositions.json")

    def tearDown(self):
        self.temporary.cleanup()

    def write_batch(self, name: str, value: dict[str, object]) -> None:
        (self.claim_dir / name).write_text(
            json.dumps(value, indent=2, sort_keys=True) + "\n",
            encoding="utf-8",
        )

    def valid_batch(self) -> dict[str, object]:
        return batch(
            [claim()],
            [
                {
                    "disposition": "no_normative_claims",
                    "rationale": "Metadata only; it introduces no product law.",
                    "source_id": "SOURCE-A",
                    "source_location": "line:3",
                }
            ],
        )

    def write_linear_decision_fixture(self) -> dict[str, object]:
        clauses = {
            number: f"Integrated v3 clause for Decision {number}."
            for number in range(1, 202)
        }
        clauses[5] = "Time   — a first-class native Life Calendar"
        clauses[11] = (
            "| Step | Executable unit of work | optional Goal/Path, substeps, "
            "schedule placement, due date, proof |"
        )
        raw = self.root / ".codex/canon-migration/sources/linear.md"
        raw.parent.mkdir(parents=True, exist_ok=True)
        raw.write_text(
            "# Canon\n" + "\n".join(clauses.values()) + "\n",
            encoding="utf-8",
        )
        self.catalog.write_text(
            json.dumps(
                {
                    "schema_version": 1,
                    "sources": [
                        source_record(
                            "LINEAR-CANON-V3",
                            raw.relative_to(self.root).as_posix(),
                            kind="linear",
                            content=raw.read_bytes(),
                        )
                    ],
                },
                indent=2,
                sort_keys=True,
            )
            + "\n",
            encoding="utf-8",
        )
        entries: list[dict[str, object]] = []
        claims: list[dict[str, object]] = []
        for number in range(1, 202):
            entity_id = f"{number:08x}-1111-4111-8111-{number:012x}"
            kind = "ledger" if number == 1 else "comment"
            locator = f"linear-{kind}:{entity_id}:decision:{number}"
            owner_text = f"Decision {number} owner decision text"
            owner_rationale = f"Decision {number} owner rationale"
            entries.append(
                {
                    "author": "Devan Warner",
                    "decision_number": number,
                    "entity_id": entity_id,
                    "evidence_kind": kind,
                    "evidence_locator": locator,
                    "mapping_rationale": "Independent semantic mapping review.",
                    "mapping_reviewed_by": "Task 11 test independent review",
                    "mapping_status": "independently_reviewed",
                    "owner_evidence_rationale": owner_rationale,
                    "owner_evidence_text": owner_text,
                    "v3_clause": clauses[number],
                }
            )
            claims.append(
                claim(
                    authority_claim=False,
                    claim_id=f"CLAIM-DECISION-{number:03d}",
                    concept=f"linear.decision.{number}",
                    disposition="provenance_only",
                    modality="INFORMATIONAL",
                    original_text=clauses[number],
                    owner_approval=locator,
                    owner_evidence_rationale=owner_rationale,
                    owner_evidence_text=owner_text,
                    scope=f"Linear v3 Decision {number}",
                    source_id="LINEAR-CANON-V3",
                    source_location=f"decision:{number}",
                    subject=f"Linear v3 Decision {number}",
                    target_class="provenance",
                    target_id=None,
                    value=clauses[number],
                )
            )
        evidence = {
            "evidence_entries": entries,
            "linear_v3_document_id": "96b93346-271d-46fc-beab-43ff7e286b5d",
            "owner": "Devan Warner",
            "schema_version": 1,
        }
        evidence_path = (
            self.root / ".codex/canon-migration/sources/linear-decision-evidence.json"
        )
        evidence_path.write_text(
            json.dumps(evidence, indent=2, sort_keys=True) + "\n",
            encoding="utf-8",
        )
        payload = batch(
            claims,
            [
                {
                    "disposition": "no_normative_claims",
                    "rationale": "Container heading only.",
                    "source_id": "LINEAR-CANON-V3",
                    "source_location": "line:1",
                }
            ],
            batch_id="linear-decisions",
        )
        self.write_batch("batch.json", payload)
        return payload

    def test_import_rejects_unknown_source_location_and_unsafe_inputs(self):
        import_claims = getattr(migration, "import_claim_batches", None)
        self.assertIsNotNone(import_claims, "claim import must exist")
        cases = (
            batch([claim(source_id="UNKNOWN")]),
            batch([claim(source_location="line:999")]),
            batch([claim(source_location="../secret")]),
        )
        for index, payload in enumerate(cases):
            with self.subTest(index=index):
                for path in self.claim_dir.glob("*"):
                    path.unlink()
                self.write_batch("batch.json", payload)
                with self.assertRaises(CanonError):
                    import_claims(self.root, self.claim_dir, self.catalog, self.output)
        outside = self.root / "outside.json"
        outside.write_text("{}\n", encoding="utf-8")
        (self.claim_dir / "escape.json").symlink_to(outside)
        with self.assertRaises(CanonError):
            import_claims(self.root, self.claim_dir, self.catalog, self.output)

    def test_import_requires_each_markdown_section_and_catalog_source(self):
        import_claims = getattr(migration, "import_claim_batches", None)
        self.assertIsNotNone(import_claims, "claim import must exist")
        self.write_batch("batch.json", batch([claim()]))
        with self.assertRaises(CanonError) as caught:
            import_claims(self.root, self.claim_dir, self.catalog, self.output)
        self.assertEqual(caught.exception.code, "CLAIM_COVERAGE_INCOMPLETE")

        self.write_batch("batch.json", self.valid_batch())
        result = import_claims(self.root, self.claim_dir, self.catalog, self.output)
        self.assertEqual(result.source_count, 1)
        self.assertEqual(result.section_count, 2)
        self.assertTrue(self.output.read_bytes().endswith(b"\n"))

    def test_import_rejects_duplicate_ids_and_dispositions_across_batches(self):
        import_claims = getattr(migration, "import_claim_batches", None)
        self.assertIsNotNone(import_claims, "claim import must exist")
        first = self.valid_batch()
        second = self.valid_batch()
        second["batch_id"] = "other"
        self.write_batch("a.json", first)
        self.write_batch("b.json", second)
        with self.assertRaises(CanonError):
            import_claims(self.root, self.claim_dir, self.catalog, self.output)

    def test_import_rejects_catalog_hash_mismatch_before_output(self):
        catalog = json.loads(self.catalog.read_text(encoding="utf-8"))
        catalog["sources"][0]["content_sha256"] = "0" * 64
        self.catalog.write_text(
            json.dumps(catalog, indent=2, sort_keys=True) + "\n", encoding="utf-8"
        )
        self.write_batch("batch.json", self.valid_batch())
        with self.assertRaises(CanonError) as caught:
            migration.import_claim_batches(
                self.root, self.claim_dir, self.catalog, self.output
            )
        self.assertEqual(caught.exception.code, "CLAIM_SOURCE_VERIFICATION_FAILED")
        self.assertFalse(self.output.exists())

    def test_import_revalidates_source_snapshot_after_extraction(self):
        self.write_batch("batch.json", self.valid_batch())
        original_inventory = migration._source_inventories

        def mutate_after_inventory(*args: object, **kwargs: object):
            result = original_inventory(*args, **kwargs)
            (self.root / "source.md").write_text(
                "# One\nchanged after extraction\n## Two\nMetadata only.\n",
                encoding="utf-8",
            )
            return result

        with (
            mock.patch.object(
                migration,
                "_source_inventories",
                side_effect=mutate_after_inventory,
            ),
            self.assertRaises(CanonError) as caught,
        ):
            migration.import_claim_batches(
                self.root, self.claim_dir, self.catalog, self.output
            )
        self.assertEqual(caught.exception.code, "CLAIM_SOURCE_VERIFICATION_FAILED")
        self.assertFalse(self.output.exists())

    def test_import_binds_inventory_bytes_to_registered_repo_digest(self):
        source = self.root / "source.md"
        expected = source.read_bytes()
        injected = b"# One\nInjected MUST become canon.\n## Two\nMetadata only.\n"
        payload = self.valid_batch()
        payload["claims"][0]["original_text"] = "Injected MUST become canon."
        payload["claims"][0]["value"] = "Injected MUST become canon."
        payload["claims"][0]["concept"] = "injected.authority"
        self.write_batch("batch.json", payload)
        original_read = migration._read_claim_source_snapshot
        swapped = False

        def swap_read_restore(path: Path):
            nonlocal swapped
            if Path(path).resolve() == source.resolve() and not swapped:
                swapped = True
                replacement = source.with_suffix(".swap")
                replacement.write_bytes(injected)
                source.rename(source.with_suffix(".saved"))
                replacement.rename(source)
                try:
                    return original_read(path)
                finally:
                    source.unlink()
                    source.with_suffix(".saved").rename(source)
            return original_read(path)

        with (
            mock.patch.object(
                migration,
                "_read_claim_source_snapshot",
                side_effect=swap_read_restore,
            ),
            self.assertRaises(CanonError) as caught,
        ):
            migration.import_claim_batches(
                self.root, self.claim_dir, self.catalog, self.output
            )
        self.assertEqual(caught.exception.code, "CLAIM_SOURCE_VERIFICATION_FAILED")
        self.assertEqual(source.read_bytes(), expected)
        self.assertFalse(self.output.exists())

    def test_import_binds_same_inode_inventory_read_to_registered_digest(self):
        source = self.root / "source.md"
        expected = source.read_bytes()
        injected = b"# One\nInjected MUST become canon.\n## Two\nMetadata only.\n"
        payload = self.valid_batch()
        payload["claims"][0]["original_text"] = "Injected MUST become canon."
        payload["claims"][0]["value"] = "Injected MUST become canon."
        self.write_batch("batch.json", payload)
        original_read = migration._read_claim_source_snapshot
        swapped = False

        def same_inode_read_restore(path: Path):
            nonlocal swapped
            if Path(path).resolve() == source.resolve() and not swapped:
                swapped = True
                with source.open("r+b") as handle:
                    handle.write(injected)
                    handle.truncate()
                    handle.flush()
                try:
                    return original_read(path)
                finally:
                    with source.open("r+b") as handle:
                        handle.write(expected)
                        handle.truncate()
                        handle.flush()
            return original_read(path)

        with (
            mock.patch.object(
                migration,
                "_read_claim_source_snapshot",
                side_effect=same_inode_read_restore,
            ),
            self.assertRaises(CanonError) as caught,
        ):
            migration.import_claim_batches(
                self.root, self.claim_dir, self.catalog, self.output
            )
        self.assertEqual(caught.exception.code, "CLAIM_SOURCE_VERIFICATION_FAILED")
        self.assertEqual(source.read_bytes(), expected)
        self.assertFalse(self.output.exists())

    def test_import_binds_raw_inventory_read_to_registered_digest(self):
        source = self.root / ".codex/canon-migration/sources/source.md"
        source.parent.mkdir(parents=True, exist_ok=True)
        expected = b"# One\nToday MUST present Start here.\n## Two\nMetadata only.\n"
        injected = b"# One\nInjected MUST become canon.\n## Two\nMetadata only.\n"
        source.write_bytes(expected)
        self.catalog.write_text(
            json.dumps(
                {
                    "schema_version": 1,
                    "sources": [
                        source_record(
                            "SOURCE-A",
                            source.relative_to(self.root).as_posix(),
                            kind="linear",
                            content=expected,
                        )
                    ],
                },
                indent=2,
                sort_keys=True,
            )
            + "\n",
            encoding="utf-8",
        )
        payload = self.valid_batch()
        payload["claims"][0]["original_text"] = "Injected MUST become canon."
        payload["claims"][0]["value"] = "Injected MUST become canon."
        self.write_batch("batch.json", payload)
        original_read = migration._read_claim_source_snapshot
        swapped = False

        def swap_read_restore(path: Path):
            nonlocal swapped
            if Path(path).resolve() == source.resolve() and not swapped:
                swapped = True
                saved = source.with_suffix(".saved")
                replacement = source.with_suffix(".swap")
                replacement.write_bytes(injected)
                source.rename(saved)
                replacement.rename(source)
                try:
                    return original_read(path)
                finally:
                    source.unlink()
                    saved.rename(source)
            return original_read(path)

        with (
            mock.patch.object(
                migration,
                "_read_claim_source_snapshot",
                side_effect=swap_read_restore,
            ),
            self.assertRaises(CanonError) as caught,
        ):
            migration.import_claim_batches(
                self.root, self.claim_dir, self.catalog, self.output
            )
        self.assertEqual(caught.exception.code, "CLAIM_SOURCE_VERIFICATION_FAILED")
        self.assertEqual(source.read_bytes(), expected)
        self.assertFalse(self.output.exists())

    def test_import_inventory_read_remains_nofollow_after_preverification(self):
        source = self.root / "source.md"
        expected = source.read_bytes()
        self.write_batch("batch.json", self.valid_batch())
        original_read = migration._read_claim_source_snapshot
        swapped = False
        before_fds = len(os.listdir("/dev/fd"))

        def symlink_read_restore(path: Path):
            nonlocal swapped
            if Path(path).resolve() == source.resolve() and not swapped:
                swapped = True
                saved = source.with_suffix(".saved")
                source.rename(saved)
                source.symlink_to(saved.name)
                try:
                    return original_read(path)
                finally:
                    source.unlink()
                    saved.rename(source)
            return original_read(path)

        with (
            mock.patch.object(
                migration,
                "_read_claim_source_snapshot",
                side_effect=symlink_read_restore,
            ),
            self.assertRaises(CanonError),
        ):
            migration.import_claim_batches(
                self.root, self.claim_dir, self.catalog, self.output
            )
        self.assertEqual(source.read_bytes(), expected)
        self.assertFalse(self.output.exists())
        self.assertEqual(len(os.listdir("/dev/fd")), before_fds)

    def test_import_inventory_read_rejects_nonregular_after_preverification(self):
        source = self.root / "source.md"
        expected = source.read_bytes()
        self.write_batch("batch.json", self.valid_batch())
        original_read = migration._read_claim_source_snapshot
        swapped = False
        before_fds = len(os.listdir("/dev/fd"))

        def fifo_read_restore(path: Path):
            nonlocal swapped
            if Path(path).resolve() == source.resolve() and not swapped:
                swapped = True
                saved = source.with_suffix(".saved")
                source.rename(saved)
                os.mkfifo(source)
                try:
                    return original_read(path)
                finally:
                    source.unlink()
                    saved.rename(source)
            return original_read(path)

        with (
            mock.patch.object(
                migration,
                "_read_claim_source_snapshot",
                side_effect=fifo_read_restore,
            ),
            self.assertRaises(CanonError) as caught,
        ):
            migration.import_claim_batches(
                self.root, self.claim_dir, self.catalog, self.output
            )
        self.assertEqual(caught.exception.code, "CLAIM_SOURCE_PATH_UNSAFE")
        self.assertEqual(source.read_bytes(), expected)
        self.assertFalse(self.output.exists())
        self.assertEqual(len(os.listdir("/dev/fd")), before_fds)

    def test_source_change_during_output_install_rolls_back_output(self):
        source = self.root / "source.md"
        expected = source.read_bytes()
        changed = b"# One\nchanged during install\n## Two\nMetadata only.\n"
        self.write_batch("batch.json", self.valid_batch())
        original_revalidate = migration._revalidate_inventory_snapshots
        for preexisting in (False, True):
            with self.subTest(preexisting=preexisting):
                if preexisting:
                    self.output.write_bytes(b'{"prior":true}\n')
                else:
                    self.output.unlink(missing_ok=True)
                calls = 0

                def change_on_postinstall(inventories: object):
                    nonlocal calls
                    calls += 1
                    if calls == 3:
                        source.write_bytes(changed)
                        try:
                            return original_revalidate(inventories)
                        finally:
                            source.write_bytes(expected)
                    return original_revalidate(inventories)

                with (
                    mock.patch.object(
                        migration,
                        "_revalidate_inventory_snapshots",
                        side_effect=change_on_postinstall,
                    ),
                    self.assertRaises(CanonError) as caught,
                ):
                    migration.import_claim_batches(
                        self.root, self.claim_dir, self.catalog, self.output
                    )
                self.assertEqual(caught.exception.code, "CLAIM_SOURCE_CHANGED")
                if preexisting:
                    self.assertEqual(self.output.read_bytes(), b'{"prior":true}\n')
                else:
                    self.assertFalse(self.output.exists())
                self.assertFalse(
                    tuple(
                        self.output.parent.glob(f".{self.output.name}.claim-recovery-*")
                    )
                )

    def test_import_rejects_claim_and_no_normative_disposition_for_same_section(self):
        import_claims = getattr(migration, "import_claim_batches", None)
        self.assertIsNotNone(import_claims, "claim import must exist")
        payload = self.valid_batch()
        payload["source_section_dispositions"].append(
            {
                "disposition": "no_normative_claims",
                "rationale": "Contradicts the claim and must fail.",
                "source_id": "SOURCE-A",
                "source_location": "line:1",
            }
        )
        self.write_batch("batch.json", payload)
        with self.assertRaises(CanonError) as caught:
            import_claims(self.root, self.claim_dir, self.catalog, self.output)
        self.assertEqual(caught.exception.code, "CLAIM_SECTION_DISPOSITION_CONFLICT")

    def test_import_rejects_tracked_raw_claim_batch(self):
        import_claims = getattr(migration, "import_claim_batches", None)
        self.assertIsNotNone(import_claims, "claim import must exist")
        self.write_batch("batch.json", self.valid_batch())
        subprocess.run(
            ("git", "add", "-f", ".codex/canon-migration/claims/batch.json"),
            cwd=self.root,
            check=True,
        )
        with self.assertRaises(CanonError) as caught:
            import_claims(self.root, self.claim_dir, self.catalog, self.output)
        self.assertEqual(caught.exception.code, "CLAIM_INPUT_TRACKED")

    def test_import_rejects_same_inode_batch_mutation_during_read(self):
        self.write_batch("batch.json", self.valid_batch())
        batch_path = self.claim_dir / "batch.json"
        original_read = migration._read_descriptor

        def mutate_batch_after_read(descriptor: int) -> bytes:
            descriptor_info = os.fstat(descriptor)
            batch_info = batch_path.stat()
            result = original_read(descriptor)
            if (descriptor_info.st_dev, descriptor_info.st_ino) == (
                batch_info.st_dev,
                batch_info.st_ino,
            ):
                changed = batch_path.read_bytes().replace(
                    b"Metadata only", b"metadata only", 1
                )
                with batch_path.open("r+b") as handle:
                    handle.seek(0)
                    handle.write(changed)
                    handle.truncate()
                    handle.flush()
            return result

        with (
            mock.patch.object(
                migration,
                "_read_descriptor",
                side_effect=mutate_batch_after_read,
            ),
            self.assertRaises(CanonError) as caught,
        ):
            migration.import_claim_batches(
                self.root, self.claim_dir, self.catalog, self.output
            )
        self.assertEqual(caught.exception.code, "CLAIM_INPUT_CHANGED")

    def test_import_is_deterministic_and_deduplicates_semantics_without_losing_provenance(
        self,
    ):
        import_claims = getattr(migration, "import_claim_batches", None)
        self.assertIsNotNone(import_claims, "claim import must exist")
        first = self.valid_batch()
        first["claims"].append(
            claim(
                claim_id="CLAIM-TEST-002",
                disposition="rewrite",
                source_location="line:2",
                target_id="SURFACE-TODAY-PRIMARY-002",
            )
        )
        self.write_batch("z.json", first)
        with self.assertRaises(CanonError) as caught:
            import_claims(self.root, self.claim_dir, self.catalog, self.output)
        self.assertEqual(caught.exception.code, "CLAIM_SEMANTIC_OWNER_CONFLICT")
        first["claims"][1]["target_id"] = "SURFACE-TODAY-PRIMARY-001"
        self.write_batch("z.json", first)
        result = import_claims(self.root, self.claim_dir, self.catalog, self.output)
        before = self.output.read_bytes()
        claims = json.loads(before)["claims"]
        self.assertEqual(len(claims), 2)
        semantic_groups = json.loads(before)["semantic_groups"]
        self.assertEqual(
            semantic_groups[0]["claim_ids"], ["CLAIM-TEST-001", "CLAIM-TEST-002"]
        )
        (self.claim_dir / "z.json").rename(self.claim_dir / "a.json")
        again = import_claims(self.root, self.claim_dir, self.catalog, self.output)
        self.assertEqual(result, again)
        self.assertEqual(before, self.output.read_bytes())

    def test_linear_decisions_must_cover_exactly_1_through_201(self):
        payload = self.write_linear_decision_fixture()
        result = migration.import_claim_batches(
            self.root, self.claim_dir, self.catalog, self.output
        )
        self.assertEqual(result.linear_decision_count, 201)
        coverage_keys = [
            (item["source_id"], item["source_location"])
            for item in json.loads(self.output.read_text(encoding="utf-8"))["coverage"]
        ]
        self.assertEqual(coverage_keys, sorted(coverage_keys))
        payload["claims"].pop()
        self.write_batch("batch.json", payload)
        with self.assertRaises(CanonError) as caught:
            migration.import_claim_batches(
                self.root, self.claim_dir, self.catalog, self.output
            )
        self.assertEqual(caught.exception.code, "CLAIM_DECISION_MAPPING_INCOMPLETE")

    def test_decision_5_and_11_reject_forged_or_unrelated_evidence(self):
        payload = self.write_linear_decision_fixture()

        decision_5 = payload["claims"][4]
        decision_5["owner_approval"] = (
            "linear-comment:ffffffff-ffff-4fff-8fff-ffffffffffff:decision:5"
        )
        self.write_batch("batch.json", payload)
        with self.assertRaises(CanonError) as caught:
            migration.import_claim_batches(
                self.root, self.claim_dir, self.catalog, self.output
            )
        self.assertEqual(caught.exception.code, "CLAIM_DECISION_MAPPING_MISMATCH")

    def test_decision_evidence_snapshot_rejects_forged_entity_author_and_number(self):
        self.write_linear_decision_fixture()
        evidence_path = (
            self.root / ".codex/canon-migration/sources/linear-decision-evidence.json"
        )
        evidence = json.loads(evidence_path.read_text(encoding="utf-8"))
        parsed = migration.parse_decision_evidence_snapshot(
            evidence_path.read_bytes(), evidence_path
        )
        self.assertEqual(len(parsed.evidence_entries), 201)

        evidence["evidence_entries"][4]["entity_id"] = (
            "ffffffff-ffff-4fff-8fff-ffffffffffff"
        )
        with self.assertRaises(CanonError):
            migration.parse_decision_evidence_snapshot(
                json.dumps(evidence).encode(), evidence_path
            )
        evidence = json.loads(evidence_path.read_text(encoding="utf-8"))
        evidence["evidence_entries"][10]["author"] = "Not the owner"
        with self.assertRaises(CanonError):
            migration.parse_decision_evidence_snapshot(
                json.dumps(evidence).encode(), evidence_path
            )
        evidence = json.loads(evidence_path.read_text(encoding="utf-8"))
        evidence["evidence_entries"][10]["decision_number"] = 5
        with self.assertRaises(CanonError):
            migration.parse_decision_evidence_snapshot(
                json.dumps(evidence).encode(), evidence_path
            )

        payload = self.write_linear_decision_fixture()
        decision_5 = payload["claims"][4]
        decision_5["owner_evidence_text"] = "forged owner decision text"
        self.write_batch("batch.json", payload)
        with self.assertRaises(CanonError) as caught:
            migration.import_claim_batches(
                self.root, self.claim_dir, self.catalog, self.output
            )
        self.assertEqual(caught.exception.code, "CLAIM_DECISION_MAPPING_MISMATCH")

        payload = self.write_linear_decision_fixture()
        decision_5 = payload["claims"][4]
        unrelated_clause = payload["claims"][5]["original_text"]
        decision_5["original_text"] = unrelated_clause
        decision_5["value"] = unrelated_clause
        decision_11 = payload["claims"][10]
        decision_11["owner_evidence_rationale"] = "wrong Step rationale"
        self.write_batch("batch.json", payload)
        with self.assertRaises(CanonError) as caught:
            migration.import_claim_batches(
                self.root, self.claim_dir, self.catalog, self.output
            )
        self.assertEqual(caught.exception.code, "CLAIM_DECISION_MAPPING_MISMATCH")

    def test_json_document_original_text_uses_decoded_exact_scalar(self):
        source = self.root / "source.json"
        source.write_text(
            json.dumps({"title": "No unverifiable ‘fast’"}, ensure_ascii=True) + "\n",
            encoding="utf-8",
        )
        subprocess.run(("git", "add", "source.json"), cwd=self.root, check=True)
        subprocess.run(
            ("git", "commit", "-qm", "add json source"), cwd=self.root, check=True
        )
        self.catalog.write_text(
            json.dumps(
                {
                    "schema_version": 1,
                    "sources": [
                        source_record(
                            "SOURCE-A", "source.json", content=source.read_bytes()
                        )
                    ],
                },
                indent=2,
                sort_keys=True,
            )
            + "\n",
            encoding="utf-8",
        )
        payload = claim(
            original_text="No unverifiable ‘fast’",
            source_location="document",
        )
        self.write_batch("batch.json", batch([payload]))
        result = migration.import_claim_batches(
            self.root, self.claim_dir, self.catalog, self.output
        )
        self.assertEqual(result.claim_count, 1)

    def test_tracked_output_redacts_original_connector_text(self):
        import_claims = getattr(migration, "import_claim_batches", None)
        self.assertIsNotNone(import_claims, "claim import must exist")
        secret = "private@example.com exact raw connector body"
        (self.root / "source.md").write_text(
            f"# One\n{secret}\n## Two\nMetadata only.\n",
            encoding="utf-8",
        )
        subprocess.run(("git", "add", "source.md"), cwd=self.root, check=True)
        subprocess.run(
            ("git", "commit", "-qm", "update source"), cwd=self.root, check=True
        )
        catalog = json.loads(self.catalog.read_text(encoding="utf-8"))
        catalog["sources"][0]["content_sha256"] = hashlib.sha256(
            (self.root / "source.md").read_bytes()
        ).hexdigest()
        self.catalog.write_text(
            json.dumps(catalog, indent=2, sort_keys=True) + "\n", encoding="utf-8"
        )
        payload = self.valid_batch()
        payload["claims"][0]["original_text"] = secret
        self.write_batch("batch.json", payload)
        import_claims(self.root, self.claim_dir, self.catalog, self.output)
        tracked = self.output.read_text(encoding="utf-8")
        self.assertNotIn(secret, tracked)
        self.assertNotIn("original_text", tracked)
        tracked_claim = json.loads(tracked)["claims"][0]
        self.assertNotIn("owner_approval", tracked_claim)
        self.assertRegex(tracked_claim["owner_approval_sha256"], r"^[0-9a-f]{64}$")


class ClaimCoverageTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.root = Path(self.temporary.name)
        subprocess.run(("git", "init", "-q"), cwd=self.root, check=True)
        subprocess.run(
            ("git", "config", "user.name", "Canon Tests"),
            cwd=self.root,
            check=True,
        )
        subprocess.run(
            ("git", "config", "user.email", "canon@example.invalid"),
            cwd=self.root,
            check=True,
        )
        (self.root / ".gitignore").write_text(".codex/\n", encoding="utf-8")
        source = self.root / "source.md"
        source.write_text("# Source\n", encoding="utf-8")
        subprocess.run(
            ("git", "add", ".gitignore", "source.md"), cwd=self.root, check=True
        )
        subprocess.run(("git", "commit", "-qm", "baseline"), cwd=self.root, check=True)
        path = self.root / "docs/canon/migration/claim-dispositions.json"
        path.parent.mkdir(parents=True)
        self.path = path
        catalog_path = path.with_name("source-catalog.json")
        catalog_path.write_text(
            json.dumps(
                {
                    "schema_version": 1,
                    "sources": [
                        source_record(
                            "SOURCE-A", "source.md", content=source.read_bytes()
                        )
                    ],
                },
                indent=2,
                sort_keys=True,
            )
            + "\n",
            encoding="utf-8",
        )
        self.payload = {
            "catalog_sha256": hashlib.sha256(catalog_path.read_bytes()).hexdigest(),
            "decision_evidence_sha256": None,
            "decision_mapping_counts": {
                "independently_reviewed": 0,
                "unreviewed": 0,
            },
            "claims": [
                {
                    "authority_claim": True,
                    "claim_id": "CLAIM-A",
                    "concept": "surface.today.primary-identity",
                    "decision_mapping_status": None,
                    "disposition": "keep",
                    "owner_approval_sha256": "3" * 64,
                    "owner_evidence_rationale_sha256": None,
                    "owner_evidence_text_sha256": None,
                    "rationale_sha256": "2" * 64,
                    "source_id": "SOURCE-A",
                    "source_location": "line:1",
                    "target_class": "specification",
                    "target_id": "SURFACE-TODAY-001",
                }
            ],
            "coverage": [
                {
                    "claim_ids": ["CLAIM-A"],
                    "disposition": "claims",
                    "rationale_sha256": None,
                    "source_id": "SOURCE-A",
                    "source_location": "line:1",
                }
            ],
            "linear_decision_count": 0,
            "schema_version": 1,
            "section_count": 1,
            "semantic_groups": [
                {"claim_ids": ["CLAIM-A"], "semantic_sha256": "1" * 64}
            ],
            "source_count": 1,
            "uncovered": [],
        }
        self.path.write_text(
            json.dumps(self.payload, indent=2, sort_keys=True) + "\n", encoding="utf-8"
        )

    def tearDown(self):
        self.temporary.cleanup()

    def test_filters_are_deterministic_but_cannot_hide_uncovered_exit_status(self):
        coverage = getattr(migration, "claim_coverage", None)
        self.assertIsNotNone(coverage, "claim coverage must exist")
        report = coverage(
            self.path, concept_prefix="surface.today", target_class="specification"
        )
        self.assertTrue(report.complete)
        self.assertEqual(
            tuple(item["claim_id"] for item in report.claims), ("CLAIM-A",)
        )
        self.payload["uncovered"] = [
            {"source_id": "SOURCE-B", "source_location": "document"}
        ]
        self.path.write_text(
            json.dumps(self.payload, indent=2, sort_keys=True) + "\n", encoding="utf-8"
        )
        report = coverage(self.path, concept_prefix="does.not.match")
        self.assertFalse(report.complete)
        self.assertEqual(report.claims, ())

    def test_coverage_rejects_vacuous_self_reported_inventory(self):
        self.payload.update(
            {
                "claims": [],
                "coverage": [],
                "linear_decision_count": 0,
                "section_count": 0,
                "semantic_groups": [],
                "source_count": 0,
                "uncovered": [],
            }
        )
        self.path.write_text(
            json.dumps(self.payload, indent=2, sort_keys=True) + "\n",
            encoding="utf-8",
        )
        report = migration.claim_coverage(self.path)
        self.assertFalse(report.complete)

    def test_coverage_rejects_unknown_tracked_fields_and_inconsistent_counts(self):
        coverage = getattr(migration, "claim_coverage", None)
        self.assertIsNotNone(coverage, "claim coverage must exist")
        self.payload["claims"][0]["raw_body"] = "must never be accepted"
        self.path.write_text(
            json.dumps(self.payload, indent=2, sort_keys=True) + "\n",
            encoding="utf-8",
        )
        with self.assertRaises(CanonError):
            coverage(self.path)
        del self.payload["claims"][0]["raw_body"]
        self.payload["section_count"] = 2
        self.path.write_text(
            json.dumps(self.payload, indent=2, sort_keys=True) + "\n",
            encoding="utf-8",
        )
        with self.assertRaises(CanonError):
            coverage(self.path)

    def test_coverage_rejects_claim_ids_reassigned_between_sections(self):
        source = self.root / "source.md"
        source.write_text(
            "# One\nFirst section.\n## Two\nSecond section.\n", encoding="utf-8"
        )
        subprocess.run(("git", "add", "source.md"), cwd=self.root, check=True)
        subprocess.run(
            ("git", "commit", "-qm", "add second section"),
            cwd=self.root,
            check=True,
        )
        catalog_path = self.path.with_name("source-catalog.json")
        catalog = json.loads(catalog_path.read_text(encoding="utf-8"))
        catalog["sources"][0]["content_sha256"] = hashlib.sha256(
            source.read_bytes()
        ).hexdigest()
        catalog_path.write_text(
            json.dumps(catalog, indent=2, sort_keys=True) + "\n", encoding="utf-8"
        )
        self.payload["catalog_sha256"] = hashlib.sha256(
            catalog_path.read_bytes()
        ).hexdigest()
        self.payload["section_count"] = 2

        def coverage_row(location: str, claim_ids: list[str]) -> dict[str, object]:
            return {
                "claim_ids": claim_ids,
                "disposition": "claims" if claim_ids else "no_normative_claims",
                "rationale_sha256": None if claim_ids else "4" * 64,
                "source_id": "SOURCE-A",
                "source_location": location,
            }

        for name, first_ids, second_ids in (
            ("missing", [], []),
            ("extra", ["CLAIM-A"], ["CLAIM-A"]),
            ("wrong-section", [], ["CLAIM-A"]),
        ):
            with self.subTest(name=name):
                self.payload["coverage"] = [
                    coverage_row("line:1", first_ids),
                    coverage_row("line:3", second_ids),
                ]
                self.path.write_text(
                    json.dumps(self.payload, indent=2, sort_keys=True) + "\n",
                    encoding="utf-8",
                )
                with self.assertRaises(CanonError) as caught:
                    migration.claim_coverage(
                        self.path,
                        concept_prefix="does.not.match",
                    )
                self.assertEqual(
                    caught.exception.code,
                    "CLAIM_DISPOSITIONS_INVALID",
                )

    def test_cli_claim_import_and_coverage_output_contract(self):
        output = self.root / "report.json"
        stdout = io.StringIO()
        with contextlib.redirect_stdout(stdout):
            code = main(
                [
                    "migration",
                    "claims",
                    "coverage",
                    "--dispositions",
                    str(self.path),
                    "--concept-prefix",
                    "surface.today",
                    "--target-class",
                    "specification",
                    "--output",
                    str(output),
                ]
            )
        self.assertEqual(code, 0)
        self.assertIn("GREEN", stdout.getvalue())
        self.assertTrue(output.read_bytes().endswith(b"\n"))
        self.payload["uncovered"] = [
            {"source_id": "SOURCE-B", "source_location": "document"}
        ]
        self.path.write_text(
            json.dumps(self.payload, indent=2, sort_keys=True) + "\n", encoding="utf-8"
        )
        with contextlib.redirect_stdout(io.StringIO()):
            code = main(
                ["migration", "claims", "coverage", "--dispositions", str(self.path)]
            )
        self.assertEqual(code, 1)

    def test_atomic_output_preserves_a_concurrent_edit(self):
        output = self.root / "report.json"
        output.write_bytes(b'{"prior":true}\n')
        concurrent = b'{"concurrent":true}\n'
        original_exchange = migration._rename_exchange

        def mutate_then_exchange(*args: object, **kwargs: object) -> None:
            output.write_bytes(concurrent)
            original_exchange(*args, **kwargs)

        with (
            mock.patch.object(
                migration,
                "_rename_exchange",
                side_effect=mutate_then_exchange,
            ),
            self.assertRaises(CanonError) as caught,
        ):
            migration._write_claim_json(output, {"schema_version": 1})
        self.assertEqual(caught.exception.code, "CLAIM_OUTPUT_CHANGED")
        self.assertEqual(output.read_bytes(), concurrent)

    def test_postvalidate_rollback_preserves_concurrent_output_and_recovery(self):
        output = self.root / "report.json"
        prior = b'{"prior":true}\n'
        concurrent = b'{"concurrent":true}\n'
        output.write_bytes(prior)
        validations = 0
        before_fds = len(os.listdir("/dev/fd"))

        def fail_after_concurrent_edit() -> None:
            nonlocal validations
            validations += 1
            if validations == 2:
                output.write_bytes(concurrent)
                raise CanonError("CLAIM_SOURCE_CHANGED", "test source changed")

        with self.assertRaises(CanonError) as caught:
            migration._write_claim_json(
                output,
                {"schema_version": 1},
                validate=fail_after_concurrent_edit,
            )
        self.assertEqual(caught.exception.code, "CLAIM_OUTPUT_RECOVERY_REQUIRED")
        self.assertEqual(output.read_bytes(), concurrent)
        recovery = Path(caught.exception.path)
        self.assertEqual(recovery.read_bytes(), prior)
        transaction_recoveries = tuple(
            output.parent.glob(f".{output.name}.claim-recovery-transaction-*")
        )
        self.assertEqual(len(transaction_recoveries), 1)
        self.assertEqual(
            transaction_recoveries[0].read_bytes(),
            migration.stable_json({"schema_version": 1}),
        )
        self.assertEqual(len(os.listdir("/dev/fd")), before_fds)

    def test_absent_output_postvalidate_preserves_concurrent_output_and_transaction(
        self,
    ):
        output = self.root / "report.json"
        concurrent = b'{"concurrent":true}\n'
        validations = 0
        before_fds = len(os.listdir("/dev/fd"))

        def fail_after_concurrent_edit() -> None:
            nonlocal validations
            validations += 1
            if validations == 2:
                output.write_bytes(concurrent)
                raise CanonError("CLAIM_SOURCE_CHANGED", "test source changed")

        with self.assertRaises(CanonError) as caught:
            migration._write_claim_json(
                output,
                {"schema_version": 1},
                validate=fail_after_concurrent_edit,
            )
        self.assertEqual(caught.exception.code, "CLAIM_OUTPUT_RECOVERY_REQUIRED")
        self.assertEqual(output.read_bytes(), concurrent)
        recovery = Path(caught.exception.path)
        self.assertEqual(
            recovery.read_bytes(),
            migration.stable_json({"schema_version": 1}),
        )
        self.assertEqual(len(os.listdir("/dev/fd")), before_fds)

    def test_postvalidate_preserves_symlink_and_nonregular_concurrent_output(self):
        prior = b'{"prior":true}\n'
        transaction = migration.stable_json({"schema_version": 1})
        external = self.root / "external.json"
        external.write_bytes(b'{"external":true}\n')
        before_fds = len(os.listdir("/dev/fd"))
        sockets: list[socket.socket] = []
        for kind in ("symlink", "fifo", "directory", "socket", "missing"):
            with self.subTest(kind=kind):
                output = self.root / f"report-{kind}.json"
                output.write_bytes(prior)
                displaced = self.root / f"displaced-{kind}.json"
                validations = 0

                def fail_with_unsafe_concurrent_output() -> None:
                    nonlocal validations
                    validations += 1
                    if validations == 2:
                        output.rename(displaced)
                        if kind == "symlink":
                            output.symlink_to(external.name)
                        elif kind == "fifo":
                            os.mkfifo(output)
                        elif kind == "directory":
                            output.mkdir()
                        elif kind == "socket":
                            concurrent_socket = socket.socket(socket.AF_UNIX)
                            try:
                                concurrent_socket.bind(str(output))
                                sockets.append(concurrent_socket)
                            except Exception:
                                concurrent_socket.close()
                                raise
                        raise CanonError(
                            "CLAIM_SOURCE_CHANGED",
                            "test source changed",
                        )

                with self.assertRaises(CanonError) as caught:
                    migration._write_claim_json(
                        output,
                        {"schema_version": 1},
                        validate=fail_with_unsafe_concurrent_output,
                    )
                self.assertEqual(
                    caught.exception.code,
                    "CLAIM_OUTPUT_RECOVERY_REQUIRED",
                )
                self.assertEqual(Path(caught.exception.path).read_bytes(), prior)
                transaction_recoveries = tuple(
                    output.parent.glob(f".{output.name}.claim-recovery-transaction-*")
                )
                self.assertEqual(len(transaction_recoveries), 1)
                self.assertEqual(transaction_recoveries[0].read_bytes(), transaction)
                if kind == "symlink":
                    self.assertTrue(output.is_symlink())
                    self.assertEqual(external.read_bytes(), b'{"external":true}\n')
                elif kind == "fifo":
                    self.assertTrue(stat.S_ISFIFO(output.lstat().st_mode))
                elif kind == "directory":
                    self.assertTrue(output.is_dir())
                elif kind == "socket":
                    self.assertTrue(stat.S_ISSOCK(output.lstat().st_mode))
                else:
                    self.assertFalse(output.exists())
        for concurrent_socket in sockets:
            concurrent_socket.close()
        self.assertEqual(len(os.listdir("/dev/fd")), before_fds)

    def test_absent_postvalidate_preserves_unsafe_concurrent_output(self):
        transaction = migration.stable_json({"schema_version": 1})
        external = self.root / "absent-external.json"
        external.write_bytes(b'{"external":true}\n')
        before_fds = len(os.listdir("/dev/fd"))
        sockets: list[socket.socket] = []
        for kind in ("symlink", "fifo", "directory", "socket", "missing"):
            with self.subTest(kind=kind):
                output = self.root / f"absent-{kind}.json"
                displaced = self.root / f"absent-displaced-{kind}.json"
                validations = 0

                def fail_with_unsafe_concurrent_output() -> None:
                    nonlocal validations
                    validations += 1
                    if validations == 2:
                        output.rename(displaced)
                        if kind == "symlink":
                            output.symlink_to(external.name)
                        elif kind == "fifo":
                            os.mkfifo(output)
                        elif kind == "directory":
                            output.mkdir()
                        elif kind == "socket":
                            concurrent_socket = socket.socket(socket.AF_UNIX)
                            try:
                                concurrent_socket.bind(str(output))
                                sockets.append(concurrent_socket)
                            except Exception:
                                concurrent_socket.close()
                                raise
                        raise CanonError(
                            "CLAIM_SOURCE_CHANGED",
                            "test source changed",
                        )

                with self.assertRaises(CanonError) as caught:
                    migration._write_claim_json(
                        output,
                        {"schema_version": 1},
                        validate=fail_with_unsafe_concurrent_output,
                    )
                self.assertEqual(
                    caught.exception.code,
                    "CLAIM_OUTPUT_RECOVERY_REQUIRED",
                )
                recovery = Path(caught.exception.path)
                self.assertEqual(recovery.read_bytes(), transaction)
                if kind == "symlink":
                    self.assertTrue(output.is_symlink())
                    self.assertEqual(external.read_bytes(), b'{"external":true}\n')
                elif kind == "fifo":
                    self.assertTrue(stat.S_ISFIFO(output.lstat().st_mode))
                elif kind == "directory":
                    self.assertTrue(output.is_dir())
                elif kind == "socket":
                    self.assertTrue(stat.S_ISSOCK(output.lstat().st_mode))
                else:
                    self.assertFalse(output.exists())
        for concurrent_socket in sockets:
            concurrent_socket.close()
        self.assertEqual(len(os.listdir("/dev/fd")), before_fds)

    def test_claim_output_reader_rejects_device_and_replacement_race(self):
        before_fds = len(os.listdir("/dev/fd"))
        device_parent = os.open("/dev", os.O_RDONLY | os.O_DIRECTORY)
        try:
            with self.assertRaises(CanonError):
                migration._read_claim_output_at(
                    device_parent,
                    "null",
                    Path("/dev/null"),
                    allow_missing=False,
                )
        finally:
            os.close(device_parent)

        output = self.root / "raced-output.json"
        output.write_bytes(b'{"original":true}\n')
        replacement = self.root / "raced-replacement.json"
        replacement.write_bytes(b'{"replacement":true}\n')
        displaced = self.root / "raced-displaced.json"
        parent = os.open(self.root, os.O_RDONLY | os.O_DIRECTORY)
        original_read = migration._read_descriptor
        raced = False

        def replace_after_read(descriptor: int) -> bytes:
            nonlocal raced
            result = original_read(descriptor)
            if not raced:
                raced = True
                output.rename(displaced)
                replacement.rename(output)
            return result

        try:
            with (
                mock.patch.object(
                    migration,
                    "_read_descriptor",
                    side_effect=replace_after_read,
                ),
                self.assertRaises(CanonError) as caught,
            ):
                migration._read_claim_output_at(
                    parent,
                    output.name,
                    output,
                    allow_missing=False,
                )
            self.assertEqual(caught.exception.code, "CLAIM_OUTPUT_CHANGED")
            self.assertEqual(output.read_bytes(), b'{"replacement":true}\n')
        finally:
            os.close(parent)
        self.assertEqual(len(os.listdir("/dev/fd")), before_fds)

    def test_postvalidate_rollback_failure_retains_recovery_locator(self):
        output = self.root / "report.json"
        prior = b'{"prior":true}\n'
        output.write_bytes(prior)
        validations = 0
        exchanges = 0
        original_exchange = migration._rename_exchange
        before_fds = len(os.listdir("/dev/fd"))

        def fail_postvalidate() -> None:
            nonlocal validations
            validations += 1
            if validations == 2:
                raise CanonError("CLAIM_SOURCE_CHANGED", "test source changed")

        def fail_rollback_exchange(*args: object, **kwargs: object) -> None:
            nonlocal exchanges
            exchanges += 1
            if exchanges == 2:
                raise OSError("forced rollback failure")
            original_exchange(*args, **kwargs)

        with (
            mock.patch.object(
                migration,
                "_rename_exchange",
                side_effect=fail_rollback_exchange,
            ),
            self.assertRaises(CanonError) as caught,
        ):
            migration._write_claim_json(
                output,
                {"schema_version": 1},
                validate=fail_postvalidate,
            )
        self.assertEqual(caught.exception.code, "CLAIM_OUTPUT_RECOVERY_REQUIRED")
        recovery = Path(caught.exception.path)
        self.assertEqual(recovery.read_bytes(), prior)
        transaction_recoveries = tuple(
            output.parent.glob(f".{output.name}.claim-recovery-transaction-*")
        )
        self.assertEqual(len(transaction_recoveries), 1)
        self.assertEqual(
            transaction_recoveries[0].read_bytes(),
            migration.stable_json({"schema_version": 1}),
        )
        self.assertEqual(len(os.listdir("/dev/fd")), before_fds)

    def test_recovery_writer_reuses_exact_content_and_skips_unsafe_collisions(self):
        output = self.root / "report.json"
        content = b"exact recovery bytes\n"
        before_fds = len(os.listdir("/dev/fd"))
        descriptor = os.open(self.root, os.O_RDONLY | os.O_DIRECTORY)
        try:
            first = migration._retain_claim_recovery(
                descriptor,
                output.name,
                content,
                output,
                "transaction",
            )
            second = migration._retain_claim_recovery(
                descriptor,
                output.name,
                content,
                output,
                "transaction",
            )
            self.assertEqual(first, second)
            self.assertEqual(first.read_bytes(), content)

            digest = hashlib.sha256(content).hexdigest()
            unsafe = output.with_name(f".{output.name}.claim-recovery-prior-{digest}")
            unsafe.symlink_to(first.name)
            collision = migration._retain_claim_recovery(
                descriptor,
                output.name,
                content,
                output,
                "prior",
            )
            self.assertEqual(collision.name, f"{unsafe.name}-01")
            self.assertEqual(collision.read_bytes(), content)

            fifo = output.with_name(f".{output.name}.claim-recovery-ambiguous-{digest}")
            os.mkfifo(fifo)
            nonregular_collision = migration._retain_claim_recovery(
                descriptor,
                output.name,
                content,
                output,
                "ambiguous",
            )
            self.assertEqual(nonregular_collision.name, f"{fifo.name}-01")
            self.assertEqual(nonregular_collision.read_bytes(), content)
        finally:
            os.close(descriptor)
        self.assertEqual(len(os.listdir("/dev/fd")), before_fds)

    def test_recovery_collision_inspection_rejects_nonregular_open_races(self):
        content = b"exact recovery bytes\n"
        digest = hashlib.sha256(content).hexdigest()
        before_fds = len(os.listdir("/dev/fd"))
        external = self.root / "race-external"
        external.write_bytes(b"external\n")
        for kind in (
            "fifo",
            "socket",
            "device",
            "directory",
            "symlink",
            "missing",
        ):
            with self.subTest(kind=kind):
                output = self.root / f"race-{kind}.json"
                base = f".{output.name}.claim-recovery-transaction-{digest}"
                candidate = output.with_name(base)
                candidate.write_bytes(b"occupied\n")
                parent = os.open(self.root, os.O_RDONLY | os.O_DIRECTORY)
                original_stat = migration.os.stat
                original_open = migration.os.open
                swapped = False

                def race_stat(path: object, *args: object, **kwargs: object):
                    nonlocal swapped
                    info = original_stat(path, *args, **kwargs)
                    if (
                        path == base
                        and not swapped
                        and kind
                        in {
                            "fifo",
                            "directory",
                            "symlink",
                            "missing",
                        }
                    ):
                        swapped = True
                        candidate.unlink()
                        if kind == "fifo":
                            os.mkfifo(candidate)
                        elif kind == "directory":
                            candidate.mkdir()
                        elif kind == "symlink":
                            candidate.symlink_to(external.name)
                    return info

                def device_open(
                    path: object, flags: int, *args: object, **kwargs: object
                ):
                    nonlocal swapped
                    if (
                        kind in {"device", "socket"}
                        and path == base
                        and not flags & os.O_CREAT
                        and not swapped
                    ):
                        swapped = True
                        if kind == "device":
                            return original_open(
                                "/dev/null",
                                os.O_RDONLY | os.O_NONBLOCK,
                            )
                        left, right = socket.socketpair()
                        right.close()
                        return left.detach()
                    return original_open(path, flags, *args, **kwargs)

                try:
                    with (
                        mock.patch.object(
                            migration.os,
                            "stat",
                            side_effect=race_stat,
                        ),
                        mock.patch.object(
                            migration.os,
                            "open",
                            side_effect=device_open,
                        ),
                    ):
                        recovery = migration._retain_claim_recovery(
                            parent,
                            output.name,
                            content,
                            output,
                            "transaction",
                        )
                    self.assertEqual(recovery.name, f"{base}-01")
                    self.assertEqual(recovery.read_bytes(), content)
                    if kind == "fifo":
                        self.assertTrue(stat.S_ISFIFO(candidate.lstat().st_mode))
                    elif kind == "socket":
                        self.assertEqual(candidate.read_bytes(), b"occupied\n")
                    elif kind == "directory":
                        self.assertTrue(candidate.is_dir())
                    elif kind == "symlink":
                        self.assertTrue(candidate.is_symlink())
                    elif kind == "missing":
                        self.assertFalse(candidate.exists())
                    else:
                        self.assertEqual(candidate.read_bytes(), b"occupied\n")
                finally:
                    os.close(parent)
        self.assertEqual(len(os.listdir("/dev/fd")), before_fds)

    def test_recovery_fifo_open_race_completes_under_subprocess_timeout(self):
        script = r"""
import hashlib
import os
import tempfile
from pathlib import Path
from unittest import mock
import tools.ambitions_canon.migration as migration

with tempfile.TemporaryDirectory() as temporary:
    root = Path(temporary)
    output = root / "report.json"
    content = b"exact recovery bytes\n"
    digest = hashlib.sha256(content).hexdigest()
    base = f".{output.name}.claim-recovery-transaction-{digest}"
    candidate = root / base
    candidate.write_bytes(b"occupied\n")
    parent = os.open(root, os.O_RDONLY | os.O_DIRECTORY)
    original_stat = migration.os.stat
    swapped = False
    def race_stat(path, *args, **kwargs):
        global swapped
        info = original_stat(path, *args, **kwargs)
        if path == base and not swapped:
            swapped = True
            candidate.unlink()
            os.mkfifo(candidate)
        return info
    try:
        with mock.patch.object(migration.os, "stat", side_effect=race_stat):
            recovery = migration._retain_claim_recovery(
                parent, output.name, content, output, "transaction"
            )
        assert recovery.read_bytes() == content
        assert recovery.name == f"{base}-01"
    finally:
        os.close(parent)
"""
        result = subprocess.run(
            (sys.executable, "-c", script),
            cwd=Path.cwd(),
            text=True,
            capture_output=True,
            timeout=5,
            check=False,
        )
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_recovery_writer_survives_sixty_five_namespace_collisions(self):
        transaction = migration.stable_json({"schema_version": 1})
        prior = b'{"prior":true}\n'
        concurrent = b'{"concurrent":true}\n'
        before_fds = len(os.listdir("/dev/fd"))

        def occupy(output: Path, label: str, content: bytes) -> None:
            digest = hashlib.sha256(content).hexdigest()
            base = f".{output.name}.claim-recovery-{label}-{digest}"
            for collision in range(65):
                name = base if collision == 0 else f"{base}-{collision:02x}"
                output.with_name(name).write_bytes(b"occupied\n")

        for preexisting in (False, True):
            with self.subTest(preexisting=preexisting):
                output = self.root / f"collision-{preexisting}.json"
                if preexisting:
                    output.write_bytes(prior)
                    occupy(output, "prior", prior)
                occupy(output, "transaction", transaction)
                validations = 0

                def fail_after_concurrent_edit() -> None:
                    nonlocal validations
                    validations += 1
                    if validations == 2:
                        output.write_bytes(concurrent)
                        raise CanonError(
                            "CLAIM_SOURCE_CHANGED",
                            "test source changed",
                        )

                with self.assertRaises(CanonError) as caught:
                    migration._write_claim_json(
                        output,
                        {"schema_version": 1},
                        validate=fail_after_concurrent_edit,
                    )
                self.assertEqual(
                    caught.exception.code,
                    "CLAIM_OUTPUT_RECOVERY_REQUIRED",
                )
                self.assertEqual(output.read_bytes(), concurrent)
                recovery = Path(caught.exception.path)
                self.assertTrue(recovery.name.endswith("-41"))
                self.assertEqual(
                    recovery.read_bytes(),
                    prior if preexisting else transaction,
                )
                transaction_digest = hashlib.sha256(transaction).hexdigest()
                transaction_recovery = output.with_name(
                    f".{output.name}.claim-recovery-transaction-{transaction_digest}-41"
                )
                self.assertEqual(transaction_recovery.read_bytes(), transaction)
        self.assertEqual(len(os.listdir("/dev/fd")), before_fds)

    def test_recovery_staging_error_retains_exact_transaction_temp(self):
        transaction = migration.stable_json({"schema_version": 1})
        prior = b'{"prior":true}\n'
        before_fds = len(os.listdir("/dev/fd"))
        for preexisting in (False, True):
            with self.subTest(preexisting=preexisting):
                output = self.root / f"staging-error-{preexisting}.json"
                if preexisting:
                    output.write_bytes(prior)
                with (
                    mock.patch.object(
                        migration,
                        "_retain_claim_recovery",
                        side_effect=CanonError(
                            "CLAIM_OUTPUT_RECOVERY_REQUIRED",
                            "forced recovery write error",
                        ),
                    ),
                    self.assertRaises(CanonError) as caught,
                ):
                    migration._write_claim_json(output, {"schema_version": 1})
                self.assertEqual(
                    caught.exception.code,
                    "CLAIM_OUTPUT_RECOVERY_REQUIRED",
                )
                staging = Path(caught.exception.path)
                self.assertTrue(staging.is_file())
                self.assertEqual(staging.read_bytes(), transaction)
                if preexisting:
                    self.assertEqual(output.read_bytes(), prior)
                else:
                    self.assertFalse(output.exists())
        self.assertEqual(len(os.listdir("/dev/fd")), before_fds)


if __name__ == "__main__":
    unittest.main()
