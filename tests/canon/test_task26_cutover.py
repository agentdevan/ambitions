from __future__ import annotations

import copy
import hashlib
import json
import os
import subprocess
import tempfile
import tomllib
import unittest
from pathlib import Path

from tools.ambitions_canon.authorization import (
    canonical_json_bytes,
    canonical_tree_delta,
)
from tools.ambitions_canon.build import build_canon
from tools.ambitions_canon.model import CanonError
from tools.ambitions_canon.render import _validate_task26_transition_record
from tools.ambitions_canon.ux_blueprint import (
    UXBlueprintError,
    load_ux_blueprint,
    validate_ux_blueprint,
)


ROOT = Path(__file__).resolve().parents[2]


class Task26CutoverTests(unittest.TestCase):
    def _mark_review_pending(
        self, record: dict[str, object]
    ) -> dict[str, object]:
        pending = copy.deepcopy(record)
        review = {
            "critical_findings": "pending",
            "important_findings": "pending",
            "review_package_sha256": None,
            "review_receipt_sha256": None,
            "reviewed_candidate_bundle_sha256": None,
            "reviewed_candidate_tree_sha": None,
            "reviewed_scope_manifest_sha256": None,
            "status": "pending",
        }
        pending["exact_review"] = review
        finalization_payload = {
            "task_id": "TASK-26",
            "start_record_id": pending["task_start"]["record_id"],
            "scope_manifest_sha256": pending["scope"]["manifest_sha256"],
            "candidate": pending["candidate"],
            "exact_review": review,
            "controls": pending["controls"],
            "rollback": pending["rollback"],
            "reusable": False,
        }
        digest = hashlib.sha256(
            canonical_json_bytes(finalization_payload)
        ).hexdigest()
        pending["task_finalize"] = {
            "candidate_bundle_sha256": pending["candidate"][
                "candidate_bundle_sha256"
            ],
            "exact_review_status": "pending",
            "payload_sha256": digest,
            "record_id": f"OWNER-DIRECT-TASK26-FINALIZE-{digest}",
            "reusable": False,
            "scope_manifest_sha256": pending["scope"]["manifest_sha256"],
            "start_record_id": pending["task_start"]["record_id"],
            "status": "pending_exact_review",
            "use_state": "reserved_pending_exact_review",
        }
        return pending

    def _close_review_cleanly(
        self,
        record: dict[str, object],
        *,
        package_sha256: str,
        review_receipt_sha256: str,
    ) -> dict[str, object]:
        closed = copy.deepcopy(record)
        review = {
            "critical_findings": 0,
            "important_findings": 0,
            "review_package_sha256": package_sha256,
            "review_receipt_sha256": review_receipt_sha256,
            "reviewed_candidate_bundle_sha256": closed["candidate"][
                "candidate_bundle_sha256"
            ],
            "reviewed_candidate_tree_sha": closed["candidate"][
                "candidate_tree_sha"
            ],
            "reviewed_scope_manifest_sha256": closed["scope"][
                "manifest_sha256"
            ],
            "status": "complete_clean",
        }
        closed["exact_review"] = review
        finalization_payload = {
            "task_id": "TASK-26",
            "start_record_id": closed["task_start"]["record_id"],
            "scope_manifest_sha256": closed["scope"]["manifest_sha256"],
            "candidate": closed["candidate"],
            "exact_review": review,
            "controls": closed["controls"],
            "rollback": closed["rollback"],
            "reusable": False,
        }
        digest = hashlib.sha256(
            canonical_json_bytes(finalization_payload)
        ).hexdigest()
        closed["task_finalize"] = {
            "candidate_bundle_sha256": closed["candidate"][
                "candidate_bundle_sha256"
            ],
            "exact_review_status": "complete_clean",
            "payload_sha256": digest,
            "record_id": f"OWNER-DIRECT-TASK26-FINALIZE-CLEAN-{digest}",
            "reusable": False,
            "scope_manifest_sha256": closed["scope"]["manifest_sha256"],
            "start_record_id": closed["task_start"]["record_id"],
            "status": "complete_clean",
            "use_state": "consumed_complete_clean",
        }
        return closed

    def _candidate_binding(self, review_only: set[str]) -> dict[str, object]:
        base = subprocess.check_output(
            ["git", "rev-parse", "HEAD"], cwd=ROOT, text=True
        ).strip()
        base_tree = subprocess.check_output(
            ["git", "rev-parse", f"{base}^{{tree}}"], cwd=ROOT, text=True
        ).strip()
        with tempfile.TemporaryDirectory(prefix="task26-binding-") as directory:
            environment = dict(os.environ)
            environment["GIT_INDEX_FILE"] = str(Path(directory) / "index")
            subprocess.run(
                ["git", "read-tree", "HEAD"], cwd=ROOT, env=environment, check=True
            )
            subprocess.run(
                ["git", "add", "-u", "--", "."],
                cwd=ROOT,
                env=environment,
                check=True,
            )
            untracked = subprocess.check_output(
                ["git", "ls-files", "--others", "--exclude-standard"],
                cwd=ROOT,
                text=True,
            ).splitlines()
            included = sorted(set(untracked) - review_only)
            if included:
                subprocess.run(
                    ["git", "add", "--", *included],
                    cwd=ROOT,
                    env=environment,
                    check=True,
                )
            candidate_tree = subprocess.check_output(
                ["git", "write-tree"], cwd=ROOT, env=environment, text=True
            ).strip()

        commit_environment = dict(os.environ)
        commit_environment.update(
            {
                "GIT_AUTHOR_NAME": "Task26 Binder",
                "GIT_AUTHOR_EMAIL": "task26@local.invalid",
                "GIT_AUTHOR_DATE": "2000-01-01T00:00:00Z",
                "GIT_COMMITTER_NAME": "Task26 Binder",
                "GIT_COMMITTER_EMAIL": "task26@local.invalid",
                "GIT_COMMITTER_DATE": "2000-01-01T00:00:00Z",
            }
        )
        candidate_commit = subprocess.check_output(
            ["git", "commit-tree", candidate_tree, "-p", base],
            cwd=ROOT,
            env=commit_environment,
            input=b"Task 26 candidate binding\n",
        ).decode("utf-8").strip()
        delta = canonical_tree_delta(ROOT, base, candidate_commit)
        tree_delta_sha256 = hashlib.sha256(canonical_json_bytes(delta)).hexdigest()
        files = []
        for item in delta["records"]:
            path = item["path_display_utf8"]
            content = (ROOT / path).read_bytes()
            files.append(
                {
                    "byte_size": item["new_blob_size"],
                    "git_blob_oid": item["new_object_id"],
                    "mode": item["new_mode"],
                    "path": path,
                    "sha256": hashlib.sha256(content).hexdigest(),
                }
            )
        bundle_payload = {
            "schema_version": 1,
            "task_id": "TASK-26",
            "base_commit_sha": base,
            "base_tree_sha": base_tree,
            "candidate_tree_sha": candidate_tree,
            "tree_delta_sha256": tree_delta_sha256,
            "files": files,
        }
        return {
            "base_commit_sha": base,
            "base_tree_sha": base_tree,
            "bound_files": files,
            "candidate_bundle_sha256": hashlib.sha256(
                canonical_json_bytes(bundle_payload)
            ).hexdigest(),
            "candidate_tree_sha": candidate_tree,
            "review_only_files": sorted(review_only),
            "tree_delta_sha256": tree_delta_sha256,
        }

    def test_active_cutover_projections_are_deterministic_and_bound(self) -> None:
        manifest = tomllib.loads(
            (ROOT / "docs/canon/MANIFEST.toml").read_text(encoding="utf-8")
        )
        self.assertEqual(manifest["authority_state"], "active")
        self.assertEqual(manifest["canon_revision"], 1)
        self.assertIn(
            "generated/CHATGPT_CODEX_HANDOFF.md",
            manifest["generated_files"],
        )
        self.assertIn(
            "generated/AUTHORIZATION_GATE_TRANSITION.md",
            manifest["generated_files"],
        )

        transition_record = json.loads(
            (ROOT / "docs/canon/references/task-26-owner-direct-transition.json")
            .read_text(encoding="utf-8")
        )
        scope = transition_record["scope"]
        self.assertEqual(scope["path_count"], 42)
        self.assertEqual(
            scope["manifest_sha256"],
            "ade805bb6d0059e66a0d54358c07da23daa1b70baaabe70d78a8896f6b2a636c",
        )
        self.assertEqual(
            hashlib.sha256(("\n".join(scope["paths"]) + "\n").encode()).hexdigest(),
            scope["manifest_sha256"],
        )
        self.assertFalse(transition_record["task_start"]["reusable"])
        self.assertFalse(transition_record["task_finalize"]["reusable"])
        self.assertEqual(
            transition_record["task_finalize"]["start_record_id"],
            transition_record["task_start"]["record_id"],
        )
        candidate = transition_record["candidate"]
        for field in (
            "candidate_bundle_sha256",
            "candidate_tree_sha",
            "tree_delta_sha256",
        ):
            self.assertNotEqual(set(candidate[field]), {"0"})
        review_only = {
            "docs/canon/generated/AUTHORIZATION_GATE_TRANSITION.md",
            "docs/canon/references/task-26-owner-direct-transition.json",
        }
        self.assertEqual(candidate, self._candidate_binding(review_only))
        self.assertEqual(
            scope["paths"],
            sorted(
                [item["path"] for item in candidate["bound_files"]]
                + candidate["review_only_files"]
            ),
        )
        self.assertNotIn(
            "docs/canon/references/task-authorization-policy.json",
            scope["paths"],
        )

        extra_scope = copy.deepcopy(transition_record)
        extra_scope["scope"]["paths"].append("UNAUTHORIZED-EXTRA")
        with self.assertRaisesRegex(CanonError, "worktree scope differs"):
            _validate_task26_transition_record(
                {"authority_state": "active"}, ROOT, extra_scope
            )
        reusable = copy.deepcopy(transition_record)
        reusable["task_start"]["reusable"] = True
        with self.assertRaisesRegex(CanonError, "start receipt"):
            _validate_task26_transition_record(
                {"authority_state": "active"}, ROOT, reusable
            )
        mutated = copy.deepcopy(transition_record)
        mutated["candidate"]["bound_files"][0]["sha256"] = "0" * 64
        with self.assertRaisesRegex(CanonError, "candidate binding"):
            _validate_task26_transition_record(
                {"authority_state": "active"}, ROOT, mutated
            )

        placeholder_review = self._close_review_cleanly(
            transition_record,
            package_sha256="0" * 64,
            review_receipt_sha256="0" * 64,
        )
        with self.assertRaisesRegex(CanonError, "review closure"):
            _validate_task26_transition_record(
                {"authority_state": "active"}, ROOT, placeholder_review
            )
        dirty_review = self._close_review_cleanly(
            transition_record,
            package_sha256="b" * 64,
            review_receipt_sha256="a" * 64,
        )
        dirty_review["exact_review"]["important_findings"] = 1
        with self.assertRaisesRegex(CanonError, "review closure"):
            _validate_task26_transition_record(
                {"authority_state": "active"}, ROOT, dirty_review
            )
        stale_review = self._close_review_cleanly(
            transition_record,
            package_sha256="b" * 64,
            review_receipt_sha256="a" * 64,
        )
        stale_review["exact_review"]["reviewed_candidate_tree_sha"] = "c" * 40
        with self.assertRaisesRegex(CanonError, "review closure"):
            _validate_task26_transition_record(
                {"authority_state": "active"}, ROOT, stale_review
            )
        clean_review = self._close_review_cleanly(
            transition_record,
            package_sha256="b" * 64,
            review_receipt_sha256="a" * 64,
        )
        validated_clean = _validate_task26_transition_record(
            {"authority_state": "active"}, ROOT, clean_review
        )
        for immutable_field in (
            "base",
            "scope",
            "verifier",
            "task25_evidence",
            "candidate",
            "task_start",
            "rollback",
            "controls",
        ):
            self.assertEqual(
                validated_clean[immutable_field],
                transition_record[immutable_field],
            )
        pending_review = self._mark_review_pending(transition_record)
        validated_pending = _validate_task26_transition_record(
            {"authority_state": "active"}, ROOT, pending_review
        )
        self.assertEqual(validated_pending["exact_review"]["status"], "pending")
        self.assertEqual(
            validated_pending["task_finalize"]["status"],
            "pending_exact_review",
        )

        live_status = transition_record["exact_review"]["status"]
        self.assertIn(live_status, {"pending", "complete_clean"})
        if live_status == "complete_clean":
            live_review = transition_record["exact_review"]
            self.assertEqual(live_review["critical_findings"], 0)
            self.assertEqual(live_review["important_findings"], 0)
            for digest_field in (
                "review_package_sha256",
                "review_receipt_sha256",
            ):
                self.assertRegex(live_review[digest_field], r"^[0-9a-f]{64}$")
                self.assertNotEqual(set(live_review[digest_field]), {"0"})
            self.assertEqual(
                live_review["reviewed_candidate_tree_sha"],
                candidate["candidate_tree_sha"],
            )
            self.assertEqual(
                live_review["reviewed_candidate_bundle_sha256"],
                candidate["candidate_bundle_sha256"],
            )
            self.assertEqual(
                live_review["reviewed_scope_manifest_sha256"],
                scope["manifest_sha256"],
            )
            self.assertEqual(
                transition_record["task_finalize"]["status"],
                "complete_clean",
            )
            self.assertEqual(
                transition_record["task_finalize"]["use_state"],
                "consumed_complete_clean",
            )
        else:
            self.assertEqual(transition_record, pending_review)

        blueprint = load_ux_blueprint(ROOT)
        validate_ux_blueprint(ROOT, blueprint)
        stale_blueprint = copy.deepcopy(blueprint)
        stale_blueprint["canon_content_sha"] = "0" * 64
        with self.assertRaisesRegex(UXBlueprintError, "canon content SHA is stale"):
            validate_ux_blueprint(ROOT, stale_blueprint)

        self.assertEqual(build_canon(ROOT, check=True), ())

        instructions = (
            ROOT / "docs/canon/references/chatgpt-project-instructions.md"
        ).read_bytes()
        handoff = (
            ROOT / "docs/canon/generated/CHATGPT_CODEX_HANDOFF.md"
        ).read_text(encoding="utf-8")
        self.assertIn(hashlib.sha256(instructions).hexdigest(), handoff)
        self.assertIn("request-only", handoff)
        self.assertIn("cannot authorize", handoff)

        transition = (
            ROOT / "docs/canon/generated/AUTHORIZATION_GATE_TRANSITION.md"
        ).read_text(encoding="utf-8")
        for expected in (
            "OWNER-TRAIN5-TASK26-SCOPE-2026-07-17T234045Z",
            "scope_manifest_sha256 = `ade805bb6d0059e66a0d54358c07da23daa1b70baaabe70d78a8896f6b2a636c`",
            "protected_ci_installed = `false`",
            "required_check_installed = `false`",
            "ruleset_inspected = `false`",
            "live_enforcement_proven = `false`",
            "post_merge_receipt_required = `false`",
            f"exact_review_status = `{live_status}`",
        ):
            self.assertIn(expected, transition)


if __name__ == "__main__":
    unittest.main()
