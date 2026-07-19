import copy
import json
import subprocess
import sys
import unittest
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[2]
MATRIX_SHA256 = "f319153d552ab557798f289d7e838e94364a2e21b43903343c672af207dbdbbe"

STATE_REPAIRS = {
    "UX-SCREEN-TODAY-ROOT": ({"loading", "populated", "stale-external-context", "offline-healthy", "permission-denied", "conflict", "recovery", "destructive-confirmation"}, {"normal", "stale", "offline", "permission-conflict"}),
    "UX-SCREEN-TODAY-DETAIL": ({"stale-external-context"}, {"stale"}),
    "UX-SCREEN-TODAY-START-HERE": (set(), set()),
    "UX-SCREEN-APP-LAUNCH-GATE": ({"checking-local-readiness", "ready", "retryable-delay", "repair-required", "quarantined", "stop-ship-data-risk"}, set()),
    "UX-SCREEN-SETUP-FIRST-USE": ({"not-started", "in-progress", "skipped", "sufficient-for-local-use", "revisitable"}, {"local-ready", "complete"}),
    "UX-SCREEN-SETUP-RESUME": (set(), set()),
    "UX-SCREEN-APP-SHELL-DRILLDOWN": ({"drilldown", "full-screen-overlay", "compact-modal", "deep-inspection", "restoration", "unavailable-route"}, {"pushed", "full-screen", "sheet", "restored", "dismissed"}),
    "UX-SCREEN-APP-SHELL-ROOT": ({"unavailable-route-unknown-owner", "unavailable-route-duplicate-presentation-owner", "unavailable-route-orphan-depth", "unavailable-route-unauthorized-target", "unavailable-route-stale-object-reference"}, set()),
    "UX-SCREEN-APP-SHELL-SEARCH-CAPTURE": (set(), set()),
    "UX-SCREEN-APP-DEEP-LINK-INTAKE": ({"queued", "resolving", "presented", "rejected", "consumed", "recoverable"}, set()),
    "UX-SCREEN-YOU-CONTINUITY-CONTROL": ({"disabled", "ineligible", "eligible-not-enabled", "enabled-idle", "local-pending", "uploading", "remote-pending", "merging", "conflicted-quarantined", "retrying", "paused", "unavailable", "signed-out", "migrating", "restoring", "blocked"}, set()),
    "UX-SCREEN-ACCOUNT-BOUNDARY": (set(), {"continuity-enabled"}),
    "UX-SCREEN-ACCOUNT-STATUS": (set(), {"continuity-pending", "continuity-conflicted", "entitlement-stale"}),
    "UX-SCREEN-YOU-ENTITLEMENT": ({"active", "trial", "grace", "retry", "expired", "revoked", "restored", "supported-sharing", "offline-cached", "mismatch", "unknown"}, set()),
    "UX-SCREEN-OFFLINE-DEGRADED-LOCAL-HEALTH": ({"offline-healthy", "continuity-pending", "continuity-conflict", "import-failure", "external-write-failure", "partial-operation", "unavailable-permission", "local-store-degradation"}, {"local-healthy", "degraded-local-store"}),
    "UX-SCREEN-OFFLINE-DEGRADED-REPAIR": ({"quarantine-inspection"}, set()),
    "UX-SCREEN-PERMISSIONS-CALENDAR": ({"request-failed", "settings-return-failed", "revoked", "partial-external-access"}, set()),
    "UX-SCREEN-PERMISSIONS-NOTIFICATIONS": ({"request-failed", "settings-return-failed", "revoked", "partial-external-access"}, set()),
    "UX-SCREEN-CAPTURE-COMPOSER": ({"dictating", "scan-importing", "validating", "routing", "saving", "restoring", "offline", "ambiguous-type", "invalid-metadata", "partial-routing", "degraded-store"}, set()),
    "UX-SCREEN-CAPTURE-ATTACHMENT": ({"attachment-processing", "attachment-permission-denied", "attachment-failed"}, set()),
    "UX-SCREEN-CAPTURE-PROPOSAL": ({"classifying", "fit-proposing", "proposal-conflict"}, set()),
    "UX-SCREEN-SEARCH-ROOT": ({"action-validating", "action-mutating", "inspection-handoff", "corrupt-index", "stale-index", "unavailable-projection", "permission-denied", "partial-results", "offline-healthy", "action-rejected"}, set()),
    "UX-SCREEN-GOALS-DETAIL": ({"clarifying", "activating", "generation-failed", "preview-rejected"}, set()),
    "UX-SCREEN-GOALS-PATH": ({"route-generating", "simulating", "path-adjusting", "restoring", "missing-reference-context", "path-generation-uncertain", "partial-simulation", "rolled-back"}, set()),
    "UX-SCREEN-GOALS-RECOVERY": ({"proof-transferring", "schedule-conflict", "partial-schedule-failure", "offline-healthy", "local-store-degraded"}, set()),
    "UX-SCREEN-TIME-DEGRADED": ({"permission-denied", "stale-source", "pending-external-diff", "partial-import", "external-write-failure", "sync-pending", "sync-conflict", "offline-healthy", "local-store-degradation"}, set()),
    "UX-SCREEN-TIME-IMPORT": ({"partial-import", "external-write-failure", "reconciling", "import-failed", "restored"}, set()),
    "UX-SCREEN-TRUST-DEEP": ({"proof-loading", "history-paginating", "source-checking", "privacy-preview", "correcting", "restoring", "missing-proof", "partial-history", "offline-healthy", "permission-denied", "local-store-degraded"}, set()),
    "UX-SCREEN-TRUST-RECEIPT": ({"receipt-resolving", "undoing", "restoring", "absent-receipt-detail", "offline-healthy", "local-store-degraded"}, set()),
    "UX-SCREEN-YOU-DIAGNOSTICS": ({"healthy", "degraded", "recoverable", "quarantined", "blocked", "unknown", "diagnosis-ready", "repair-preview", "export-preview", "export-failed"}, set()),
    "UX-SCREEN-YOU-NOTIFICATIONS": ({"disabled", "permission-not-requested", "permission-denied", "permission-allowed", "scheduled", "superseded", "removed", "delivered", "acted", "externally-failed", "reconciled"}, set()),
}

FORMER_GAP_IDS = {
    "GAP-UX-COMMAND-CONTRACT-ACCOUNT-001",
    "GAP-UX-COMMAND-CONTRACT-DEGRADED-001", "GAP-UX-COMMAND-CONTRACT-PERMISSIONS-001",
    "GAP-UX-COMMAND-CONTRACT-SEARCH-001", "GAP-UX-COMMAND-CONTRACT-LAUNCH-SETUP-001",
    "GAP-UX-COMMAND-CONTRACT-TIME-DETAIL-001",
    "GAP-UX-COMMAND-CONTRACT-TIME-IMPORT-001",
    "GAP-UX-COMMAND-CONTRACT-DEEP-LINK-001", "GAP-UX-COMMAND-CONTRACT-ENTITLEMENT-001",
    "GAP-UX-COMMAND-CONTRACT-CONTINUITY-001", "GAP-UX-COMMAND-CONTRACT-DIAGNOSTICS-001",
    "GAP-UX-COMMAND-CONTRACT-NOTIFICATIONS-001",
}

FALSE_NONVISUAL_IDS = {
    "MISSION-FOUNDATION-RUNTIME-001", "MISSION-LAUNCH-BAR-001", "MISSION-MOAT-001", "MISSION-MOAT-CONTINUITY-001",
    "OBJECT-CANONICAL-GRAPH-001", "PLATFORM-CALENDAR-REPLACEMENT-001", "PRIVACY-CLOUDKIT-CONTINUITY-001", "LAW-LOCAL-AUTHORITY-001",
    "LAW-RUNTIME-DURABLE-SUCCESS-001", "RUNTIME-MUTATION-SEQUENCE-001", "APP-DEEP-LINK-RESOLVE-001", "APP-DEEP-LINK-STATE-001",
    "APP-LAUNCH-READINESS-001", "SPEC-GLOBAL-SEARCH-INDEX-001", "SPEC-GLOBAL-SEARCH-INDEX-ACTIONS-001", "OBJ-MEMORY-RETENTION-001",
    "OBJ-REMINDER-REPLACEMENT-TARGET-001", "OBJ-SCHEDULE-PLACEMENT-ATOMICITY-001", "SYS-CANONICAL-GRAPH-001", "SYS-PROJECTION-OWNERSHIP-001",
    "SYSTEM-APPLE-HANDOFF-001", "SYSTEM-APPLE-INTENTS-001", "SYSTEM-APPLE-SHARE-HANDOFF-001", "SYSTEM-APPLE-WIDGET-ACTION-001",
    "SYSTEM-DIAGNOSTICS-AUTHORITY-001", "SYSTEM-DIAGNOSTICS-HEALTH-001", "SYSTEM-LEARNING-CAPABILITY-RETENTION-001", "SYSTEM-LEARNING-LOCAL-001",
    "SYSTEM-NOTIFICATIONS-EFFECT-001", "SYSTEM-PERSISTENCE-ATOMIC-001", "SYSTEM-PERSISTENCE-CORRUPTION-001", "SYSTEM-PERSISTENCE-MIGRATION-001",
    "SYSTEM-PERSISTENCE-REPLAY-001", "SYSTEM-EXTERNAL-ASSISTANCE-BOUNDARY-001", "SYSTEM-PRIVACY-CLASSIFICATION-001", "SYSTEM-PRIVACY-EGRESS-001",
    "SYSTEM-RUNTIME-CLOUD-INDEPENDENCE-001", "SYSTEM-RUNTIME-COMMAND-VALIDATION-001", "SYSTEM-RUNTIME-MUTATION-001", "SYSTEM-RUNTIME-ORCHESTRATION-001",
    "SYSTEM-RUNTIME-SIMULATION-001", "SYSTEM-SCHEDULING-FIT-001", "SYSTEM-CONTINUITY-DISABLED-001", "SYSTEM-CONTINUITY-FAILURE-001",
    "SYSTEM-CONTINUITY-SEPARATION-001", "ENTITLEMENT-001", "ENTITLEMENT-002", "ENTITLEMENT-003", "ENTITLEMENT-004", "SECURITY-002",
    "FRONTEND-003", "FRONTEND-004", "FRONTEND-005", "FRONTEND-006", "FRONTEND-009", "FRONTEND-010",
    "STANDARD-ACCEPTANCE-IA-001", "STANDARD-ACCEPTANCE-INTERACTION-001", "STANDARD-ACCEPTANCE-OBJECTS-001",
    "STANDARD-ACCEPTANCE-SCENARIOS-001", "STANDARD-ACCEPTANCE-VIEWPORTS-001",
}


class UXBlueprintMatrixRepairTests(unittest.TestCase):
    def _payload(self):
        return json.loads((REPO_ROOT / "docs/canon/migration/ux-blueprint.json").read_text())

    def _module(self):
        from tools.ambitions_canon import ux_blueprint
        return ux_blueprint

    def test_exact_repaired_screen_and_state_inventories(self):
        payload = self._payload()
        variants = {m["screen_id"]: {v["variant_key"] for v in m["variants"]} for m in payload["state_models"]}
        self.assertEqual(len(payload["screens"]), 47)
        self.assertEqual(len(payload["state_models"]), 47)
        self.assertEqual(sum(map(len, variants.values())), 433)
        self.assertEqual(set(STATE_REPAIRS), set(STATE_REPAIRS) & set(variants))
        for screen_id, (required, forbidden) in STATE_REPAIRS.items():
            self.assertTrue(required <= variants[screen_id], screen_id)
            self.assertTrue(forbidden.isdisjoint(variants[screen_id]), screen_id)
        launch = variants["UX-SCREEN-APP-LAUNCH-GATE"]
        self.assertIn("stop-ship-data-risk", launch)
        today = variants["UX-SCREEN-TODAY-ROOT"]
        self.assertTrue({"loading", "populated", "permission-denied", "conflict", "destructive-confirmation"} <= today)

    def test_all_61_false_nonvisual_dispositions_are_visual_and_concrete(self):
        payload = self._payload()
        by_id = {item["requirement_id"]: item for item in payload["requirement_dispositions"]}
        self.assertEqual(len(FALSE_NONVISUAL_IDS), 61)
        all_top = {item["blueprint_id"] for group in ("screens", "state_models", "object_boundaries", "journeys", "cross_cutting", "sensitive_exposure_channels") for item in payload[group]}
        all_states = {v["blueprint_id"] for model in payload["state_models"] for v in model["variants"]}
        for requirement_id in FALSE_NONVISUAL_IDS:
            item = by_id[requirement_id]
            self.assertEqual(item["disposition"], "visual_mapping_required", requirement_id)
            self.assertTrue(item["blueprint_ids"] or item["state_blueprint_ids"], requirement_id)
            self.assertFalse(set(item["blueprint_ids"]) - all_top, requirement_id)
            self.assertFalse(set(item["state_blueprint_ids"]) - all_states, requirement_id)
            self.assertFalse(any(value.startswith("UX-STATE-FAMILY-") or value in {"UX-OBJECT-BOUNDARIES", "UX-STATE-MODELS-ALL", "UX-SCREENS-ALL", "UX-JOURNEYS-ALL", "UX-COMPONENT-STATE-CONTRACTS"} for value in item["blueprint_ids"] + item["state_blueprint_ids"]), requirement_id)

    def test_exact_specification_gap_ledger_is_fully_resolved(self):
        payload = self._payload()
        gaps = payload["specification_gaps"]
        self.assertEqual(len(FORMER_GAP_IDS), 12)
        self.assertEqual(gaps, [])
        self.assertFalse(
            any(
                set(state["specification_gap_ids"]) & FORMER_GAP_IDS
                for model in payload["state_models"]
                for state in model["variants"]
            )
        )

    def test_state_behavior_authority_is_fail_closed(self):
        module = self._module()
        payload = self._payload()
        gap_ids = {item["gap_id"] for item in payload["specification_gaps"]}
        for model in payload["state_models"]:
            for state in model["variants"]:
                self.assertEqual(set(state), module.STATE_VARIANT_FIELDS)
                posture = state["behavior_authority_posture"]
                self.assertIn(posture, {"requirement_backed", "exploratory_blocked_by_specification_gap"})
                if posture == "exploratory_blocked_by_specification_gap":
                    self.assertEqual(state["behavior_authority_evidence"], [])
                    self.assertEqual(state["allowed_commands"], [])
                    self.assertTrue(set(state["specification_gap_ids"]) <= gap_ids)
                    self.assertIn("no exact command authorized by current canon", json.dumps(state).casefold())
                    self.assertFalse(state["behavior_requirement_ids"])
                else:
                    self.assertTrue(state["behavior_authority_evidence"])
                    self.assertFalse(state["specification_gap_ids"])
                    self.assertTrue(state["behavior_requirement_ids"])
                    self.assertTrue(set(state["behavior_requirement_ids"]) <= set(state["requirement_ids"]))

        unsupported = copy.deepcopy(payload)
        state = unsupported["state_models"][0]["variants"][0]
        state["behavior_authority_posture"] = "requirement_backed"
        state["behavior_requirement_ids"] = []
        state["specification_gap_ids"] = []
        with self.assertRaisesRegex(
            module.UXBlueprintError,
            "independent structured canon field ownership|unsupported behavior authority",
        ):
            module.validate_ux_blueprint(REPO_ROOT, unsupported)

    def test_future_gated_state_cannot_be_selected_as_visual_authority(self):
        module = self._module()
        payload = self._payload()
        eligible_ids = module.authority_eligible_state_variant_ids(payload, REPO_ROOT)
        all_ids = {
            variant["blueprint_id"]
            for model in payload["state_models"]
            for variant in model["variants"]
        }
        future_gated = all_ids - set(eligible_ids)
        self.assertEqual(len(eligible_ids), 411)
        self.assertEqual(len(future_gated), 22)
        for variant_id in future_gated:
            self.assertNotIn(variant_id, eligible_ids)

    def test_render_and_check_are_deterministic_with_gap_counts(self):
        module = self._module()
        payload = self._payload()
        first = module.render_ux_blueprint_markdown(payload, REPO_ROOT)
        second = module.render_ux_blueprint_markdown(payload, REPO_ROOT)
        self.assertEqual(first, second)
        self.assertIn(b"0 specification gaps", first)
        self.assertEqual(payload["specification_gaps"], [])
        self.assertFalse(
            any(
                state["behavior_authority_posture"]
                == "exploratory_blocked_by_specification_gap"
                for model in payload["state_models"]
                for state in model["variants"]
            )
        )
        result = subprocess.run(
            [
                sys.executable,
                "scripts/ambitions-canon.py",
                "ux-blueprint",
                "--check",
            ],
            cwd=REPO_ROOT,
            text=True,
            capture_output=True,
        )
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)


if __name__ == "__main__":
    unittest.main()
