from __future__ import annotations

import importlib.util
import pathlib
import unittest


TRACKER_PATH = pathlib.Path(__file__).parents[1] / "scripts" / "program_tracker.py"
SKILL_PATH = pathlib.Path(__file__).parents[1] / "SKILL.md"
SPEC = importlib.util.spec_from_file_location("unified_program_tracker", TRACKER_PATH)
assert SPEC and SPEC.loader
tracker = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(tracker)


def stage(status: str = "pending") -> dict:
    return {"status": status, "evidence": []}


def component() -> dict:
    return {
        "id": "time",
        "label": "Time",
        "order": 1,
        "design_status": "next",
        "acceptance": {"status": "pending"},
        "cycle": {
            "research": stage(),
            "audit": stage(),
            "exploration": stage(),
            "passes": [
                {
                    "number": number,
                    "status": "pending",
                    "swot": "",
                    "review": "",
                    "repair": "",
                    "gap": "",
                    "polish": "",
                    "evidence": [],
                }
                for number in range(1, 6)
            ],
        },
        "polish_gates": {f"P{number:02d}": "pending" for number in range(1, 16)},
        "native_proof": {"status": "not_started", "evidence": []},
        "device_proof": {"status": "not_started", "open": []},
        "proof_ceiling": "Fixture-only design work.",
    }


def ledger() -> dict:
    return {
        "schema_version": 2,
        "program": "Ambitions Unified Maximum Polish Frontend Program",
        "program_kind": "unified_frontend",
        "single_authoritative_program": True,
        "updated_at": "2026-08-12T12:00:00-04:00",
        "foundry": {
            "role": "fixture_rendering_and_proof_harness",
            "authority": "subordinate",
            "renders_canonical_ui": True,
            "owns_canonical_ui": False,
        },
        "approvals": {
            "frontend_design": False,
            "runtime_integration": False,
            "production_cutover": False,
            "legacy_deletion": False,
            "release": False,
        },
        "authorization": {
            "approved_for_swiftui": False,
            "production_integration_authorized": False,
        },
        "legacy_frontend": {
            "disposition": "delete_all",
            "reuse_boundary": "nonvisual_runtime_behavior_only",
            "zero_legacy_required": True,
            "verification": {"status": "not_started", "evidence": []},
        },
        "milestones": [
            {
                "id": f"UFP-{number}",
                "label": f"Milestone {number}",
                "status": "COMPLETE" if number == 0 else "ACTIVE" if number == 1 else "QUEUED",
                "depends_on": [] if number == 0 else [f"UFP-{number - 1}"],
                "owner": "Codex",
                "entry_conditions": ["entry condition"],
                "exit_conditions": ["exit condition"],
                "proof_required": ["proof condition"],
                "evidence": ["completed evidence"] if number == 0 else [],
            }
            for number in range(9)
        ],
        "components": [component()],
        "next_component_id": "time",
        "repository": {
            "last_verified": {
                "at": "2026-08-12T12:00:00-04:00",
                "branch": "main",
                "head": "abc123",
                "status_short": [],
            }
        },
    }


class ValidationTests(unittest.TestCase):
    def test_valid_unified_ledger(self) -> None:
        errors, _ = tracker.validate(ledger())
        self.assertEqual([], errors)

    def test_requires_exact_unified_program_identity_and_foundry_role(self) -> None:
        data = ledger()
        data["single_authoritative_program"] = False
        data["foundry"]["owns_canonical_ui"] = True
        errors, _ = tracker.validate(data)
        self.assertTrue(any("single_authoritative_program" in error for error in errors))
        self.assertTrue(any("foundry" in error for error in errors))

    def test_requires_separate_boolean_approvals(self) -> None:
        data = ledger()
        del data["approvals"]["legacy_deletion"]
        data["approvals"]["release"] = "pending"
        errors, _ = tracker.validate(data)
        self.assertTrue(any("legacy_deletion" in error for error in errors))
        self.assertTrue(any("release" in error for error in errors))

    def test_legacy_authorization_cannot_contradict_approvals(self) -> None:
        data = ledger()
        data["authorization"]["production_integration_authorized"] = True
        errors, _ = tracker.validate(data)
        self.assertTrue(any("production_integration_authorized" in error for error in errors))

        data = ledger()
        data["authorization"]["approved_for_swiftui"] = True
        errors, _ = tracker.validate(data)
        self.assertTrue(any("approved_for_swiftui" in error for error in errors))

    def test_unified_approvals_can_advance_while_legacy_aliases_fail_closed(self) -> None:
        data = ledger()
        data["approvals"]["frontend_design"] = True
        data["approvals"]["runtime_integration"] = True
        errors, _ = tracker.validate(data)
        self.assertFalse(any("approved_for_swiftui" in error for error in errors))
        self.assertFalse(
            any("production_integration_authorized" in error for error in errors)
        )

    def test_swiftui_legacy_alias_requires_full_release_ceiling(self) -> None:
        data = ledger()
        for field in tracker.APPROVAL_FIELDS:
            data["approvals"][field] = True
        data["authorization"]["approved_for_swiftui"] = True
        data["authorization"]["production_integration_authorized"] = True
        for milestone in data["milestones"]:
            milestone["status"] = "COMPLETE"
            milestone["evidence"] = ["milestone evidence"]
        data["legacy_frontend"]["verification"] = {
            "status": "complete",
            "evidence": ["zero-legacy-report.json"],
        }
        data["components"][0]["native_proof"] = {
            "status": "complete",
            "evidence": ["native-proof.xcresult"],
        }
        data["components"][0]["device_proof"] = {
            "status": "complete",
            "evidence": ["device-proof.md"],
        }
        errors, _ = tracker.validate(data)
        self.assertEqual([], errors)

    def test_requires_legacy_authorization_compatibility_fields(self) -> None:
        data = ledger()
        del data["authorization"]["approved_for_swiftui"]
        errors, _ = tracker.validate(data)
        self.assertTrue(any("approved_for_swiftui" in error for error in errors))

    def test_requires_exact_ordered_ufp_milestones_and_valid_dependencies(self) -> None:
        data = ledger()
        data["milestones"][4]["id"] = "MP-4"
        data["milestones"][5]["depends_on"] = ["UFP-8"]
        errors, _ = tracker.validate(data)
        self.assertTrue(any("UFP-0 through UFP-8" in error for error in errors))
        self.assertTrue(any("dependency" in error for error in errors))

    def test_milestones_require_owner_entry_exit_proof_and_completed_evidence(self) -> None:
        data = ledger()
        del data["milestones"][0]["owner"]
        data["milestones"][0]["entry_conditions"] = []
        data["milestones"][0]["evidence"] = []
        errors, _ = tracker.validate(data)
        self.assertTrue(any("owner" in error for error in errors))
        self.assertTrue(any("entry_conditions" in error for error in errors))
        self.assertTrue(any("completed milestone needs evidence" in error for error in errors))

    def test_preserves_component_cycle_validation(self) -> None:
        data = ledger()
        item = data["components"][0]
        item["design_status"] = "owner_approved_direction"
        item["cycle"]["passes"] = list(reversed(item["cycle"]["passes"]))
        errors, _ = tracker.validate(data)
        self.assertTrue(any("passes must be numbered 1 through 5" in error for error in errors))
        self.assertTrue(
            any("approved design lacks completed research" in error for error in errors)
        )

    def test_next_component_must_exist(self) -> None:
        data = ledger()
        data["next_component_id"] = "missing"
        errors, _ = tracker.validate(data)
        self.assertIn("next_component_id must name an existing component", errors)

    def test_next_component_must_be_marked_next_or_active(self) -> None:
        data = ledger()
        data["components"][0]["design_status"] = "queued"
        errors, _ = tracker.validate(data)
        self.assertIn("next_component_id must have design_status next or active", errors)


class GateTests(unittest.TestCase):
    def assert_blocked(self, data: dict, kind: str, *expected: str) -> None:
        missing = tracker.missing_gate(data, kind, component_id="time")
        for value in expected:
            self.assertIn(value, missing)

    def test_owner_review_retains_component_requirements(self) -> None:
        self.assert_blocked(ledger(), "owner-review", "research", "pass-1", "P01")

    def test_frontend_complete_requires_ufp5_and_design_approval(self) -> None:
        data = ledger()
        self.assert_blocked(data, "frontend-complete", "UFP-5", "frontend_design_approval")
        for milestone in data["milestones"][:6]:
            milestone["status"] = "COMPLETE"
        data["milestones"][6]["status"] = "ACTIVE"
        data["approvals"]["frontend_design"] = True
        self.assertEqual([], tracker.missing_gate(data, "frontend-complete"))

    def test_runtime_integration_requires_frontend_complete_and_approval(self) -> None:
        data = ledger()
        self.assert_blocked(
            data,
            "runtime-integration",
            "UFP-5",
            "frontend_design_approval",
            "runtime_integration_approval",
        )

    def test_cutover_requires_ufp6_and_both_cutover_approvals(self) -> None:
        data = ledger()
        self.assert_blocked(
            data,
            "cutover",
            "UFP-6",
            "production_cutover_approval",
            "legacy_deletion_approval",
        )

    def test_release_requires_ufp7_ufp8_zero_legacy_and_release_approval(self) -> None:
        data = ledger()
        self.assert_blocked(
            data,
            "release",
            "UFP-7",
            "UFP-8",
            "zero_legacy_verification",
            "release_approval",
        )


class RenderTests(unittest.TestCase):
    def test_render_shows_one_program_next_component_milestones_and_approvals(self) -> None:
        output = tracker.render(ledger())
        self.assertIn("# Ambitions Unified Frontend Program Status", output)
        self.assertIn("Single authoritative program: `true`", output)
        self.assertIn("Native Foundry: `fixture_rendering_and_proof_harness`", output)
        self.assertIn("Next component: **Time** (`time`)", output)
        self.assertIn("| Frontend design | false |", output)
        self.assertIn("**UFP-0**", output)
        self.assertIn("depends on: none", output)


class SkillStructureTests(unittest.TestCase):
    def test_skill_description_is_trigger_only(self) -> None:
        frontmatter = SKILL_PATH.read_text(encoding="utf-8").split("---", 2)[1]
        description = next(
            line.removeprefix("description: ")
            for line in frontmatter.splitlines()
            if line.startswith("description: ")
        )
        self.assertTrue(description.startswith("Use when "))
        self.assertNotIn("Run and govern", description)


if __name__ == "__main__":
    unittest.main()
