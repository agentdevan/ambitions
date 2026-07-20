from __future__ import annotations

import json
import hashlib
import os
import shutil
import subprocess
import tempfile
import unittest
from pathlib import Path

from tools.ambitions_canon.task_pack import (
    PACK_BUDGETS,
    TASK_TYPE_BUDGET_CLASS,
    TaskIntake,
)


ROOT = Path(__file__).resolve().parents[2]
PYTHON = os.environ.get(
    "PYTHON312",
    "/Users/devan/.local/share/uv/python/cpython-3.12-macos-x86_64-none/bin/python3.12",
)


def cli(*arguments: str, cwd: Path = ROOT) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        [PYTHON, "scripts/ambitions-canon.py", *arguments],
        cwd=cwd,
        check=False,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
    )


class Task24CliIntegrationTests(unittest.TestCase):
    def test_task24_topology_allocation_and_document_bindings_are_exact(self) -> None:
        amendment = json.loads(
            (
                ROOT
                / "docs/superpowers/amendments/2026-07-17-train-5-trust-topology-amendment.json"
            ).read_text(encoding="utf-8")
        )
        allocation = amendment["task_24_allocation"]
        self.assertEqual(
            allocation["generated_projection_paths"],
            [
                "docs/canon/generated/CODEX_START_HERE.md",
                "docs/canon/generated/INDEX.md",
                "docs/canon/generated/canon-index.json",
                "docs/canon/generated/codex-consumption-benchmark.md",
                "docs/canon/generated/concept-ownership.json",
                "docs/canon/generated/external-reference-impact.md",
                "docs/canon/generated/law-proof-map.json",
                "docs/canon/generated/law-source-map.json",
                "docs/canon/generated/law-test-map.json",
                "docs/canon/generated/object-boundary-matrix.md",
                "docs/canon/generated/requirement-graph.json",
                "docs/canon/generated/specification-coverage.md",
                "docs/canon/generated/supersession-manifest.json",
                "docs/canon/generated/unresolved-conflicts.md",
                "docs/canon/generated/visual-authority-manifest.json",
            ],
        )
        self.assertEqual(
            allocation["canon_evidence_input_paths"],
            [
                "docs/canon/specifications/global/search.md",
                "docs/canon/specifications/journeys/search-find-ask-act-inspect.md",
            ],
        )
        self.assertEqual(
            allocation["freshness_rebind_paths"],
            [
                "docs/canon/migration/UX_BLUEPRINT.md",
                "docs/canon/migration/VISUAL_AUTHORITY_REBASELINE.md",
                "docs/canon/migration/ux-blueprint-requirement-dispositions.json",
                "docs/canon/migration/ux-blueprint.json",
                "docs/canon/migration/visual-authority-r1-node-snapshot.json",
                "docs/canon/migration/visual-authority-rebaseline.json",
                "docs/canon/registries/command-gate-approval-receipts.json",
                "docs/canon/registries/command-gate-dependencies.json",
            ],
        )
        self.assertEqual(
            (
                allocation["task_pack_task_type"],
                allocation["task_pack_budget_class"],
                allocation["task_pack_token_budget"],
            ),
            ("release", "complex", 30_000),
        )
        for binding in amendment["document_bindings"]:
            raw = (ROOT / binding["path"]).read_bytes()
            self.assertEqual(
                hashlib.sha256(raw).hexdigest(),
                binding["post_amendment_sha256"],
                binding["path"],
            )

    def test_request_only_intake_maps_to_existing_task_pack_contract(self) -> None:
        data = json.loads(
            (ROOT / "tests/canon/fixtures/task-intake-valid.json").read_text(
                encoding="utf-8"
            )
        )
        self.assertTrue(hasattr(TaskIntake, "from_authorization_intake"))
        intake = TaskIntake.from_authorization_intake(data)
        self.assertEqual(intake.issue_id, "TASK-24")
        self.assertEqual(intake.task_type, "release")
        self.assertEqual(
            TaskIntake.from_authorization_intake(data).task_type,
            "release",
        )
        self.assertEqual(intake.scope, ("authorization",))
        self.assertEqual(
            intake.changed_files,
            ("tools/ambitions_canon/authorization.py",),
        )
        policy = json.loads(
            (
                ROOT
                / "docs/canon/references/task-authorization-policy.json"
            ).read_text(encoding="utf-8")
        )
        rules = {
            rule["task_id"]: rule for rule in policy["task_rules"]
        }
        expected_task_types = {
            "CEBR-01-CANON-INTEGRATION": ["release"],
            "CODEX-AUTONOMOUS-REPAIR-DELEGATION": [
                "docs",
                "mechanical",
                "runtime",
                "swiftui",
                "release",
            ],
            **{f"TASK-{number}": ["release"] for number in range(24, 30)},
        }
        self.assertEqual(
            {
                task_id: rules[task_id]["task_types"]
                for task_id in rules
            },
            expected_task_types,
        )
        self.assertEqual(TASK_TYPE_BUDGET_CLASS["release"], "complex")
        self.assertEqual(PACK_BUDGETS["complex"], 30_000)
        self.assertNotIn("governance", TASK_TYPE_BUDGET_CLASS)

    def test_skill_conformance_and_authority_sprawl_cli_checks_are_green(self) -> None:
        for arguments, marker in (
            (("skill-conformance", "--check"), "GREEN skill conformance"),
            (("authority-sprawl", "--check"), "GREEN authority sprawl"),
        ):
            completed = cli(*arguments)
            self.assertEqual(completed.returncode, 0, completed.stdout)
            self.assertIn(marker, completed.stdout)

    def test_purge_plan_and_verify_are_read_only_and_deterministic(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            output = Path(directory) / "purge.toml"
            planned = cli("purge", "plan", "--output", str(output))
            self.assertEqual(planned.returncode, 0, planned.stdout)
            first = output.read_bytes()
            planned_again = cli("purge", "plan", "--output", str(output))
            self.assertEqual(planned_again.returncode, 0, planned_again.stdout)
            self.assertEqual(output.read_bytes(), first)
            before = subprocess.run(
                ["git", "status", "--porcelain=v1"],
                cwd=ROOT,
                check=True,
                stdout=subprocess.PIPE,
            ).stdout
            verified = cli("purge", "verify", "--plan", str(output), "--dry-run")
            self.assertEqual(verified.returncode, 1, verified.stdout)
            self.assertEqual(
                verified.stdout.strip(),
                "P0_BLOCKER PURGE_TREE_BINDING_INVALID <plan>:0 "
                "purge attestations require immutable pre-delete and candidate commits",
            )
            after = subprocess.run(
                ["git", "status", "--porcelain=v1"],
                cwd=ROOT,
                check=True,
                stdout=subprocess.PIPE,
            ).stdout
            self.assertEqual(after, before)

    def test_task_cli_has_local_start_and_finalize_contracts(self) -> None:
        for subcommand in ("start", "finalize"):
            completed = cli("task", subcommand, "--help")
            self.assertEqual(completed.returncode, 0, completed.stdout)
        start_help = cli("task", "start", "--help").stdout
        self.assertIn("--intake-json", start_help)
        self.assertIn("--output", start_help)
        finalize_help = cli("task", "finalize", "--help").stdout
        self.assertIn("--authorization", finalize_help)
        self.assertIn("--delegation-authorization", finalize_help)
        self.assertIn("--delegation-event", finalize_help)
        self.assertIn("--delegation-approval", finalize_help)
        self.assertIn("--output", finalize_help)

    def test_exact_live_task24_policy_builds_release_pack_and_start_fails_without_platform_approval(
        self,
    ) -> None:
        with tempfile.TemporaryDirectory() as directory:
            source = Path(directory) / "source"
            subprocess.run(
                ["git", "clone", "-q", "--no-hardlinks", str(ROOT), str(source)],
                check=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
            )
            for relative in (
                "docs/canon",
                "tools/ambitions_canon",
            ):
                shutil.copytree(
                    ROOT / relative,
                    source / relative,
                    dirs_exist_ok=True,
                )
            shutil.copy2(
                ROOT / "scripts/ambitions-canon.py",
                source / "scripts/ambitions-canon.py",
            )
            shutil.copy2(
                ROOT / ".github/workflows/ambitions-canon-authorization.yml",
                source / ".github/workflows/ambitions-canon-authorization.yml",
            )
            subprocess.run(["git", "add", "-A"], cwd=source, check=True)
            staged = subprocess.run(
                ["git", "diff", "--cached", "--quiet"], cwd=source
            )
            if staged.returncode:
                subprocess.run(
                    ["git", "commit", "-qm", "exact live Task24 policy base"],
                    cwd=source,
                    check=True,
                )
            subprocess.run(
                ["git", "checkout", "-qb", "task24-proof"],
                cwd=source,
                check=True,
            )
            report = source / "docs/canon/migration/TASK_24_IMPLEMENTATION_REPORT.md"
            report.write_text(
                report.read_text(encoding="utf-8") + "\nLive-policy integration probe.\n",
                encoding="utf-8",
            )
            subprocess.run(
                ["git", "add", report.relative_to(source).as_posix()],
                cwd=source,
                check=True,
            )
            subprocess.run(
                ["git", "commit", "-qm", "Task24 proof candidate"],
                cwd=source,
                check=True,
            )
            intake = json.loads(
                (ROOT / "tests/canon/fixtures/task-intake-valid.json").read_text(
                    encoding="utf-8"
                )
            )
            authorization_scope = list(intake["requested_scope"])
            intake["requested_scope"] = ["AUTHORITY-AMENDMENT-001"]
            intake["requested_changed_files"] = [
                "docs/canon/migration/TASK_24_IMPLEMENTATION_REPORT.md"
            ]
            intake_path = source / "task24-intake.json"
            intake_path.write_text(
                json.dumps(intake, sort_keys=True, separators=(",", ":")) + "\n",
                encoding="utf-8",
            )
            self.assertEqual(
                (
                    source
                    / "docs/canon/references/task-authorization-policy.json"
                ).read_bytes(),
                (
                    ROOT
                    / "docs/canon/references/task-authorization-policy.json"
                ).read_bytes(),
            )

            packed = cli("pack", "--issue-json", str(intake_path), cwd=source)
            self.assertEqual(packed.returncode, 0, packed.stdout)
            pack_files = sorted((source / ".codex/canon-packs").rglob("*.json"))
            self.assertEqual(len(pack_files), 1, packed.stdout)
            pack = json.loads(pack_files[0].read_text(encoding="utf-8"))
            self.assertEqual(
                (pack["task_type"], pack["budget_class"], pack["token_budget"]),
                ("release", "complex", 30_000),
            )

            intake["requested_scope"] = authorization_scope
            intake_path.write_text(
                json.dumps(intake, sort_keys=True, separators=(",", ":")) + "\n",
                encoding="utf-8",
            )
            envelope = source / "authorization.json"
            started = cli(
                "task",
                "start",
                "--mode",
                "local-advisory",
                "--intake-json",
                str(intake_path),
                "--output",
                str(envelope),
                cwd=source,
            )
            self.assertNotEqual(started.returncode, 0, started.stdout)
            self.assertIn("AUTH_APPROVAL_MISSING", started.stdout)
            self.assertFalse(envelope.exists())


if __name__ == "__main__":
    unittest.main()
