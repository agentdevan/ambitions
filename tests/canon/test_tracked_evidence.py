from __future__ import annotations

import hashlib
import io
import json
import shutil
import subprocess
import tempfile
import unittest
from contextlib import redirect_stdout
from dataclasses import replace
from pathlib import Path
from unittest import mock

from tools.ambitions_canon import build as canon_build
from tools.ambitions_canon import cli as canon_cli
from tools.ambitions_canon.build import build_canon
from tools.ambitions_canon.cli import _audit, _pack
from tools.ambitions_canon.conflicts import (
    load_conflict_dockets,
    render_conflict_baseline,
    report_conflicts,
    validate_conflict_repository,
)
from tools.ambitions_canon.migration import (
    tracked_decision_evidence_fingerprint_sha256,
    validate_tracked_canon_evidence,
)
from tools.ambitions_canon.model import CanonError


ROOT = Path(__file__).resolve().parents[2]
ISSUE_FIXTURE = Path(__file__).with_name("fixtures") / "issue-intake.json"
EVIDENCE_PATHS = (
    Path("docs/canon/migration/source-catalog.json"),
    Path("docs/canon/migration/claim-dispositions.json"),
    Path("docs/canon/migration/conflict-docket-baseline.json"),
)


def copy_evidence(root: Path) -> None:
    for relative in EVIDENCE_PATHS:
        target = root / relative
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(ROOT / relative, target)


def write_json(path: Path, value: object) -> None:
    path.write_text(
        json.dumps(value, indent=2, sort_keys=True) + "\n",
        encoding="utf-8",
    )


def rebind_dispositions(root: Path, mutate) -> None:
    dispositions_path = root / EVIDENCE_PATHS[1]
    dispositions = json.loads(dispositions_path.read_text(encoding="utf-8"))
    decision = next(
        item
        for item in dispositions["claims"]
        if item["source_id"] == "LINEAR-CANON-V3"
        and item["source_location"] == "decision:1"
    )
    mutate(decision)
    write_json(dispositions_path, dispositions)
    baseline_path = root / EVIDENCE_PATHS[2]
    baseline = json.loads(baseline_path.read_text(encoding="utf-8"))
    baseline["claim_dispositions_sha256"] = hashlib.sha256(
        dispositions_path.read_bytes()
    ).hexdigest()
    write_json(baseline_path, baseline)


def rebind_decision_snapshot_sha(root: Path, value: object) -> None:
    dispositions_path = root / EVIDENCE_PATHS[1]
    dispositions = json.loads(dispositions_path.read_text(encoding="utf-8"))
    dispositions["decision_evidence_sha256"] = value
    write_json(dispositions_path, dispositions)
    baseline_path = root / EVIDENCE_PATHS[2]
    baseline = json.loads(baseline_path.read_text(encoding="utf-8"))
    baseline["claim_dispositions_sha256"] = hashlib.sha256(
        dispositions_path.read_bytes()
    ).hexdigest()
    write_json(baseline_path, baseline)


class TrackedEvidenceTests(unittest.TestCase):
    def test_valid_tracked_evidence_passes_without_codex_or_network_inputs(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            copy_evidence(root)
            self.assertFalse((root / ".codex").exists())
            snapshot = validate_tracked_canon_evidence(root)
            self.assertIsNotNone(snapshot)
            self.assertEqual(snapshot.source_count, 77)
            self.assertEqual(snapshot.claim_count, 1542)
            self.assertEqual(snapshot.section_count, 1216)
            self.assertEqual(snapshot.linear_decision_count, 201)
            fingerprint = tracked_decision_evidence_fingerprint_sha256(
                snapshot.claim_dispositions_bytes
            )
            self.assertEqual(fingerprint, snapshot.decision_evidence_fingerprint_sha256)
            self.assertEqual(
                fingerprint,
                tracked_decision_evidence_fingerprint_sha256(
                    snapshot.claim_dispositions_bytes
                ),
            )

    def test_valid_clean_archive_entrypoints_pass_tracked_validation(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            shutil.copytree(ROOT / "docs/canon", root / "docs/canon")
            (root / ".gitignore").write_text(".codex/\n", encoding="utf-8")
            self.assertFalse((root / ".codex").exists())
            issue_path = root / "issue.json"
            issue = json.loads(ISSUE_FIXTURE.read_text(encoding="utf-8"))
            issue["scope"] = ["surface.unrelated"]
            write_json(issue_path, issue)
            subprocess.run(("git", "init", "-q"), cwd=root, check=True)
            subprocess.run(("git", "add", "."), cwd=root, check=True)
            subprocess.run(
                (
                    "git",
                    "-c",
                    "user.name=Canon Tests",
                    "-c",
                    "user.email=canon@example.invalid",
                    "commit",
                    "-qm",
                    "archive",
                ),
                cwd=root,
                check=True,
            )

            self.assertEqual(_audit(root), 0)
            self.assertEqual(build_canon(root, check=True), ())
            self.assertEqual(report_conflicts(root, require_resolved=False)[0], 0)
            self.assertEqual(_pack(root, issue_path, check=False), 0)

    def test_decision_snapshot_sha_changes_fingerprint_and_every_removal_hash(self):
        disposition_path = ROOT / EVIDENCE_PATHS[1]
        original_bytes = disposition_path.read_bytes()
        original_payload = json.loads(original_bytes)
        changed_payload = dict(original_payload)
        changed_payload["decision_evidence_sha256"] = hashlib.sha256(
            b"legitimate replacement decision snapshot"
        ).hexdigest()
        changed_bytes = (
            json.dumps(changed_payload, indent=2, sort_keys=True) + "\n"
        ).encode("utf-8")

        original_fingerprint = tracked_decision_evidence_fingerprint_sha256(
            original_bytes
        )
        changed_fingerprint = tracked_decision_evidence_fingerprint_sha256(
            changed_bytes
        )
        self.assertNotEqual(original_fingerprint, changed_fingerprint)

        dockets = load_conflict_dockets(ROOT)
        original_baseline = json.loads(
            render_conflict_baseline(dockets, original_bytes)
        )
        changed_baseline = json.loads(render_conflict_baseline(dockets, changed_bytes))
        self.assertEqual(len(original_baseline["dockets"]), 20)
        self.assertEqual(len(changed_baseline["dockets"]), 20)
        self.assertNotEqual(
            original_baseline["decision_evidence_fingerprint_sha256"],
            changed_baseline["decision_evidence_fingerprint_sha256"],
        )
        original_removals = {
            item["conflict_id"]: item["removal_state_sha256"]
            for item in original_baseline["dockets"]
        }
        changed_removals = {
            item["conflict_id"]: item["removal_state_sha256"]
            for item in changed_baseline["dockets"]
        }
        self.assertEqual(set(original_removals), set(changed_removals))
        self.assertTrue(
            all(
                original_removals[conflict_id] != changed_removals[conflict_id]
                for conflict_id in original_removals
            )
        )

    def test_decision_snapshot_sha_missing_malformed_and_wrong_type_fail_closed(self):
        disposition_path = ROOT / EVIDENCE_PATHS[1]
        original = json.loads(disposition_path.read_text(encoding="utf-8"))
        mutations = {
            "missing": lambda value: value.pop("decision_evidence_sha256"),
            "malformed": lambda value: value.update(
                {"decision_evidence_sha256": "not-a-sha"}
            ),
            "wrong_type": lambda value: value.update(
                {"decision_evidence_sha256": {"sha256": "0" * 64}}
            ),
        }
        for name, mutate in mutations.items():
            with self.subTest(name=name):
                payload = dict(original)
                mutate(payload)
                raw = (json.dumps(payload, sort_keys=True) + "\n").encode("utf-8")
                with self.assertRaises(CanonError) as raised:
                    tracked_decision_evidence_fingerprint_sha256(raw)
                self.assertEqual(raised.exception.code, "CLAIM_DISPOSITIONS_INVALID")

    def test_decision_snapshot_sha_drift_fails_clean_archive_entrypoints(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            shutil.copytree(ROOT / "docs/canon", root / "docs/canon")
            (root / ".gitignore").write_text(".codex/\n", encoding="utf-8")
            self.assertFalse((root / ".codex").exists())
            issue_path = root / "issue.json"
            issue = json.loads(ISSUE_FIXTURE.read_text(encoding="utf-8"))
            issue["scope"] = ["surface.unrelated"]
            write_json(issue_path, issue)
            subprocess.run(("git", "init", "-q"), cwd=root, check=True)
            subprocess.run(("git", "add", "."), cwd=root, check=True)
            subprocess.run(
                (
                    "git",
                    "-c",
                    "user.name=Canon Tests",
                    "-c",
                    "user.email=canon@example.invalid",
                    "commit",
                    "-qm",
                    "archive",
                ),
                cwd=root,
                check=True,
            )
            rebind_decision_snapshot_sha(root, "0" * 64)

            with self.assertRaises(CanonError) as direct:
                validate_tracked_canon_evidence(root)
            self.assertEqual(direct.exception.code, "CONFLICT_DECISION_EVIDENCE_STALE")
            output = io.StringIO()
            with redirect_stdout(output):
                self.assertEqual(_audit(root), 1)
            self.assertIn("CONFLICT_DECISION_EVIDENCE_STALE", output.getvalue())
            with self.assertRaises(CanonError) as build_error:
                build_canon(root, check=True)
            self.assertEqual(
                build_error.exception.code,
                "CONFLICT_DECISION_EVIDENCE_STALE",
            )
            with self.assertRaises(CanonError) as conflict_error:
                report_conflicts(root, require_resolved=False)
            self.assertEqual(
                conflict_error.exception.code,
                "CONFLICT_DECISION_EVIDENCE_STALE",
            )
            output = io.StringIO()
            with redirect_stdout(output):
                self.assertEqual(_pack(root, issue_path, check=False), 1)
            self.assertIn("CONFLICT_DECISION_EVIDENCE_STALE", output.getvalue())

    def test_decision_snapshot_sha_drift_blocks_pack_check_and_pinned_resume(self):
        for phase in ("check", "pinned_resume"):
            with self.subTest(phase=phase), tempfile.TemporaryDirectory() as temporary:
                root = Path(temporary)
                shutil.copytree(ROOT / "docs/canon", root / "docs/canon")
                (root / ".gitignore").write_text(".codex/\n", encoding="utf-8")
                self.assertFalse((root / ".codex").exists())
                issue_path = root / "issue.json"
                issue = json.loads(ISSUE_FIXTURE.read_text(encoding="utf-8"))
                issue["scope"] = ["surface.unrelated"]
                write_json(issue_path, issue)
                subprocess.run(("git", "init", "-q"), cwd=root, check=True)
                subprocess.run(("git", "add", "."), cwd=root, check=True)
                subprocess.run(
                    (
                        "git",
                        "-c",
                        "user.name=Canon Tests",
                        "-c",
                        "user.email=canon@example.invalid",
                        "commit",
                        "-qm",
                        "archive",
                    ),
                    cwd=root,
                    check=True,
                )
                self.assertEqual(_pack(root, issue_path, check=False), 0)

                output = io.StringIO()
                if phase == "check":
                    rebind_decision_snapshot_sha(root, "0" * 64)
                    with redirect_stdout(output):
                        self.assertEqual(_pack(root, issue_path, check=True), 1)
                else:
                    original_require = canon_cli._require_source_snapshot
                    mutated = False

                    def mutate_after_pinned_read(*arguments):
                        nonlocal mutated
                        if not mutated:
                            mutated = True
                            rebind_decision_snapshot_sha(root, "0" * 64)
                        return original_require(*arguments)

                    with mock.patch.object(
                        canon_cli,
                        "_require_source_snapshot",
                        side_effect=mutate_after_pinned_read,
                    ):
                        with redirect_stdout(output):
                            self.assertEqual(_pack(root, issue_path, check=True), 1)
                self.assertIn(
                    "CONFLICT_DECISION_EVIDENCE_STALE",
                    output.getvalue(),
                )

    def test_catalog_change_fails_binding_and_changes_content_identity(self):
        snapshot = validate_tracked_canon_evidence(ROOT)
        self.assertIsNotNone(snapshot)
        registry = canon_build._load_audited_registry(ROOT)
        dockets = load_conflict_dockets(ROOT)
        conflicts = validate_conflict_repository(
            ROOT,
            dockets,
            (item.requirement_id for item in registry.requirements),
            registry.supersession_entries,
        )
        self.assertIsNotNone(conflicts)
        before = canon_build._registry_content_sha(registry, dockets, conflicts)
        changed_catalog = snapshot.source_catalog_bytes.replace(
            b'"owner": "Devan Warner"',
            b'"owner": "Forged Owner"',
            1,
        )
        changed_conflicts = replace(
            conflicts,
            source_catalog_bytes=changed_catalog,
        )
        after = canon_build._registry_content_sha(
            registry,
            dockets,
            changed_conflicts,
        )
        self.assertNotEqual(before, after)

        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            copy_evidence(root)
            catalog_path = root / EVIDENCE_PATHS[0]
            catalog = json.loads(catalog_path.read_text(encoding="utf-8"))
            catalog["sources"][0]["owner"] = "Forged Owner"
            write_json(catalog_path, catalog)
            with self.assertRaises(CanonError) as raised:
                validate_tracked_canon_evidence(root)
            self.assertEqual(raised.exception.code, "CLAIM_DISPOSITIONS_STALE")

    def test_invalid_disposition_stays_blocked_after_baseline_rebind(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            copy_evidence(root)
            dispositions_path = root / EVIDENCE_PATHS[1]
            dispositions = json.loads(dispositions_path.read_text(encoding="utf-8"))
            dispositions["claims"][0]["disposition"] = "banana"
            write_json(dispositions_path, dispositions)
            baseline_path = root / EVIDENCE_PATHS[2]
            baseline = json.loads(baseline_path.read_text(encoding="utf-8"))
            baseline["claim_dispositions_sha256"] = hashlib.sha256(
                dispositions_path.read_bytes()
            ).hexdigest()
            write_json(baseline_path, baseline)
            with self.assertRaises(CanonError) as raised:
                validate_tracked_canon_evidence(root)
            self.assertEqual(raised.exception.code, "CLAIM_DISPOSITIONS_INVALID")

    def test_decision_authority_and_owner_checksum_forgeries_fail_all_entrypoints(self):
        mutations = {
            "keep_with_target": lambda item: item.update(
                {
                    "disposition": "keep",
                    "target_class": "constitution",
                    "target_id": "LAW-FORGED-DECISION-001",
                }
            ),
            "rewrite_with_target": lambda item: item.update(
                {
                    "disposition": "rewrite",
                    "target_class": "constitution",
                    "target_id": "LAW-FORGED-DECISION-002",
                }
            ),
            "compose_with_target": lambda item: item.update(
                {
                    "disposition": "compose",
                    "target_class": "specification",
                    "target_id": "SPEC-FORGED-DECISION-003",
                }
            ),
            "reject_without_target": lambda item: item.update(
                {
                    "disposition": "reject",
                    "target_class": "rejection",
                    "target_id": None,
                }
            ),
            "owner_checksum_null": lambda item: item.update(
                {"owner_approval_sha256": None}
            ),
            "owner_checksum_wrong_value": lambda item: item.update(
                {"owner_approval_sha256": "0" * 64}
            ),
            "owner_checksum_malformed": lambda item: item.update(
                {"owner_approval_sha256": "not-a-sha"}
            ),
            "owner_checksum_wrong_shape": lambda item: item.update(
                {"owner_approval_sha256": {"sha256": "0" * 64}}
            ),
        }
        for name, mutate in mutations.items():
            with self.subTest(name=name), tempfile.TemporaryDirectory() as temporary:
                expected_code = (
                    "CONFLICT_DECISION_EVIDENCE_STALE"
                    if name == "owner_checksum_wrong_value"
                    else "CLAIM_DISPOSITIONS_INVALID"
                )
                root = Path(temporary)
                shutil.copytree(ROOT / "docs/canon", root / "docs/canon")
                issue_path = root / "issue.json"
                issue_path.write_bytes(ISSUE_FIXTURE.read_bytes())
                (root / ".gitignore").write_text(".codex/\n", encoding="utf-8")
                subprocess.run(("git", "init", "-q"), cwd=root, check=True)
                subprocess.run(("git", "add", "."), cwd=root, check=True)
                subprocess.run(
                    (
                        "git",
                        "-c",
                        "user.name=Canon Tests",
                        "-c",
                        "user.email=canon@example.invalid",
                        "commit",
                        "-qm",
                        "archive",
                    ),
                    cwd=root,
                    check=True,
                )
                rebind_dispositions(root, mutate)

                with self.assertRaises(CanonError) as direct:
                    validate_tracked_canon_evidence(root)
                self.assertEqual(direct.exception.code, expected_code)
                output = io.StringIO()
                with redirect_stdout(output):
                    self.assertEqual(_audit(root), 1)
                self.assertIn(expected_code, output.getvalue())
                with self.assertRaises(CanonError) as build_error:
                    build_canon(root, check=True)
                self.assertEqual(build_error.exception.code, expected_code)
                with self.assertRaises(CanonError) as conflict_error:
                    report_conflicts(root, require_resolved=False)
                self.assertEqual(conflict_error.exception.code, expected_code)
                output = io.StringIO()
                with redirect_stdout(output):
                    self.assertEqual(_pack(root, issue_path, check=False), 1)
                self.assertIn(expected_code, output.getvalue())

    def test_wrong_owner_sha_blocks_pack_check_and_pinned_resume(self):
        for phase in ("check", "pinned_resume"):
            with self.subTest(phase=phase), tempfile.TemporaryDirectory() as temporary:
                root = Path(temporary)
                shutil.copytree(ROOT / "docs/canon", root / "docs/canon")
                (root / ".gitignore").write_text(".codex/\n", encoding="utf-8")
                issue_path = root / "issue.json"
                issue = json.loads(ISSUE_FIXTURE.read_text(encoding="utf-8"))
                issue["scope"] = ["surface.unrelated"]
                write_json(issue_path, issue)
                subprocess.run(("git", "init", "-q"), cwd=root, check=True)
                subprocess.run(("git", "add", "."), cwd=root, check=True)
                subprocess.run(
                    (
                        "git",
                        "-c",
                        "user.name=Canon Tests",
                        "-c",
                        "user.email=canon@example.invalid",
                        "commit",
                        "-qm",
                        "archive",
                    ),
                    cwd=root,
                    check=True,
                )
                self.assertEqual(_pack(root, issue_path, check=False), 0)

                def forge_owner_sha() -> None:
                    rebind_dispositions(
                        root,
                        lambda item: item.update(
                            {"owner_approval_sha256": "0" * 64}
                        ),
                    )

                output = io.StringIO()
                if phase == "check":
                    forge_owner_sha()
                    with redirect_stdout(output):
                        self.assertEqual(_pack(root, issue_path, check=True), 1)
                else:
                    original_require = canon_cli._require_source_snapshot
                    mutated = False

                    def mutate_after_pinned_read(*arguments):
                        nonlocal mutated
                        if not mutated:
                            mutated = True
                            forge_owner_sha()
                        return original_require(*arguments)

                    with mock.patch.object(
                        canon_cli,
                        "_require_source_snapshot",
                        side_effect=mutate_after_pinned_read,
                    ):
                        with redirect_stdout(output):
                            self.assertEqual(_pack(root, issue_path, check=True), 1)
                self.assertIn(
                    "CONFLICT_DECISION_EVIDENCE_STALE",
                    output.getvalue(),
                )

    def test_decision_reorder_duplicate_and_missing_drift_fail_closed(self):
        def reorder(value: dict[str, object]) -> None:
            decisions = [
                item
                for item in value["claims"]
                if item["source_id"] == "LINEAR-CANON-V3"
                and item["source_location"] in {"decision:1", "decision:2"}
            ]
            decisions[0]["source_location"], decisions[1]["source_location"] = (
                decisions[1]["source_location"],
                decisions[0]["source_location"],
            )

        def duplicate(value: dict[str, object]) -> None:
            decision_two = next(
                item
                for item in value["claims"]
                if item["source_id"] == "LINEAR-CANON-V3"
                and item["source_location"] == "decision:2"
            )
            decision_two["source_location"] = "decision:1"

        def missing(value: dict[str, object]) -> None:
            value["claims"] = [
                item
                for item in value["claims"]
                if not (
                    item["source_id"] == "LINEAR-CANON-V3"
                    and item["source_location"] == "decision:201"
                )
            ]

        for name, mutate in {
            "reorder": reorder,
            "duplicate": duplicate,
            "missing": missing,
        }.items():
            with self.subTest(name=name), tempfile.TemporaryDirectory() as temporary:
                root = Path(temporary)
                copy_evidence(root)
                dispositions_path = root / EVIDENCE_PATHS[1]
                dispositions = json.loads(
                    dispositions_path.read_text(encoding="utf-8")
                )
                mutate(dispositions)
                write_json(dispositions_path, dispositions)
                baseline_path = root / EVIDENCE_PATHS[2]
                baseline = json.loads(baseline_path.read_text(encoding="utf-8"))
                baseline["claim_dispositions_sha256"] = hashlib.sha256(
                    dispositions_path.read_bytes()
                ).hexdigest()
                write_json(baseline_path, baseline)
                with self.assertRaises(CanonError) as raised:
                    validate_tracked_canon_evidence(root)
                self.assertEqual(raised.exception.code, "CLAIM_DISPOSITIONS_INVALID")

    def test_partial_unknown_count_source_and_sort_drift_fail_closed(self):
        mutations = {
            "partial_top_level": lambda value: value.pop("section_count"),
            "unknown_nested": lambda value: value["claims"][0].update(
                {"unknown": True}
            ),
            "count_drift": lambda value: value.update(
                {"source_count": value["source_count"] + 1}
            ),
            "source_id_drift": lambda value: value["claims"][0].update(
                {"source_id": "UNKNOWN-SOURCE"}
            ),
            "claim_sort_drift": lambda value: value["claims"].reverse(),
            "coverage_sort_drift": lambda value: value["coverage"].reverse(),
            "semantic_sort_drift": lambda value: value["semantic_groups"].reverse(),
        }
        for name, mutate in mutations.items():
            with self.subTest(name=name), tempfile.TemporaryDirectory() as temporary:
                root = Path(temporary)
                copy_evidence(root)
                path = root / EVIDENCE_PATHS[1]
                value = json.loads(path.read_text(encoding="utf-8"))
                mutate(value)
                write_json(path, value)
                baseline_path = root / EVIDENCE_PATHS[2]
                baseline = json.loads(baseline_path.read_text(encoding="utf-8"))
                baseline["claim_dispositions_sha256"] = hashlib.sha256(
                    path.read_bytes()
                ).hexdigest()
                write_json(baseline_path, baseline)
                with self.assertRaises(CanonError):
                    validate_tracked_canon_evidence(root)

    def test_source_catalog_shape_duplicate_and_sort_drift_fail_closed(self):
        mutations = {
            "unknown_shape": lambda value: value["sources"][0].update(
                {"unknown": True}
            ),
            "duplicate_source": lambda value: value["sources"].append(
                dict(value["sources"][0])
            ),
            "source_sort_drift": lambda value: value["sources"].reverse(),
        }
        for name, mutate in mutations.items():
            with self.subTest(name=name), tempfile.TemporaryDirectory() as temporary:
                root = Path(temporary)
                copy_evidence(root)
                catalog_path = root / EVIDENCE_PATHS[0]
                catalog = json.loads(catalog_path.read_text(encoding="utf-8"))
                mutate(catalog)
                write_json(catalog_path, catalog)
                dispositions_path = root / EVIDENCE_PATHS[1]
                dispositions = json.loads(
                    dispositions_path.read_text(encoding="utf-8")
                )
                dispositions["catalog_sha256"] = hashlib.sha256(
                    catalog_path.read_bytes()
                ).hexdigest()
                write_json(dispositions_path, dispositions)
                baseline_path = root / EVIDENCE_PATHS[2]
                baseline = json.loads(baseline_path.read_text(encoding="utf-8"))
                baseline["claim_dispositions_sha256"] = hashlib.sha256(
                    dispositions_path.read_bytes()
                ).hexdigest()
                write_json(baseline_path, baseline)
                with self.assertRaises(CanonError):
                    validate_tracked_canon_evidence(root)

    def test_clean_archive_entrypoints_reject_tracked_catalog_drift(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            shutil.copytree(ROOT / "docs/canon", root / "docs/canon")
            self.assertFalse((root / ".codex").exists())
            issue_path = root / "issue.json"
            issue_path.write_bytes(ISSUE_FIXTURE.read_bytes())
            subprocess.run(("git", "init", "-q"), cwd=root, check=True)
            subprocess.run(("git", "add", "."), cwd=root, check=True)
            subprocess.run(
                (
                    "git",
                    "-c",
                    "user.name=Canon Tests",
                    "-c",
                    "user.email=canon@example.invalid",
                    "commit",
                    "-qm",
                    "archive",
                ),
                cwd=root,
                check=True,
            )
            catalog_path = root / EVIDENCE_PATHS[0]
            catalog = json.loads(catalog_path.read_text(encoding="utf-8"))
            catalog["sources"][0]["owner"] = "Forged Owner"
            write_json(catalog_path, catalog)

            output = io.StringIO()
            with redirect_stdout(output):
                self.assertEqual(_audit(root), 1)
            self.assertIn("CLAIM_DISPOSITIONS_STALE", output.getvalue())
            with self.assertRaises(CanonError) as build_error:
                build_canon(root, check=True)
            self.assertEqual(build_error.exception.code, "CLAIM_DISPOSITIONS_STALE")
            with self.assertRaises(CanonError) as conflicts_error:
                report_conflicts(root, require_resolved=False)
            self.assertEqual(
                conflicts_error.exception.code,
                "CLAIM_DISPOSITIONS_STALE",
            )
            output = io.StringIO()
            with redirect_stdout(output):
                self.assertEqual(_pack(root, issue_path, check=False), 1)
            self.assertIn("CLAIM_DISPOSITIONS_STALE", output.getvalue())


if __name__ == "__main__":
    unittest.main()
