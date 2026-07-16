import copy
import hashlib
import json
import re
import unittest
from pathlib import Path
from unittest.mock import patch


REPO_ROOT = Path(__file__).resolve().parents[2]
VARIANT_FIELDS = {
    "accessibility_focus",
    "allowed_commands",
    "behavior_authority_evidence",
    "behavior_authority_posture",
    "behavior_authority_rationale",
    "behavior_requirement_ids",
    "blueprint_id",
    "displayed_objects",
    "durable_effect",
    "future_gated_commands",
    "generic_kind",
    "implementation_status",
    "machine_command_contracts",
    "offline_behavior",
    "operation_phase",
    "proof_ceiling",
    "recovery_rollback",
    "requirement_ids",
    "specification_gap_ids",
    "state_axis",
    "title",
    "transition_exit",
    "variant_key",
    "visible_content_copy",
    "visible_presentation",
}


class UXBlueprintSemanticRepairTests(unittest.TestCase):
    def _module(self):
        from tools.ambitions_canon import ux_blueprint

        return ux_blueprint

    def _payload(self):
        return json.loads(
            (REPO_ROOT / "docs/canon/migration/ux-blueprint.json").read_text(
                encoding="utf-8"
            )
        )

    def _dispositions(self, payload=None):
        payload = payload or self._payload()
        return {
            item["requirement_id"]: item
            for item in payload["requirement_dispositions"]
        }

    def _state(self, screen_id, variant_key, payload=None):
        payload = payload or self._payload()
        model = next(
            item for item in payload["state_models"] if item["screen_id"] == screen_id
        )
        return next(
            item for item in model["variants"] if item["variant_key"] == variant_key
        )

    def _variants(self, screen_id, payload=None):
        payload = payload or self._payload()
        return next(
            item["variants"]
            for item in payload["state_models"]
            if item["screen_id"] == screen_id
        )

    def _inventory_for(self, payload):
        inventory = json.loads(
            (
                REPO_ROOT
                / "docs/canon/migration/ux-blueprint-state-inventory.json"
            ).read_text(encoding="utf-8")
        )
        inventory["state_variants"] = [
            {
                "blueprint_id": state["blueprint_id"],
                "generic_kind": state["generic_kind"],
                "operation_phase": state["operation_phase"],
                "screen_id": model["screen_id"],
                "state_axis": state["state_axis"],
                "variant_key": state["variant_key"],
            }
            for model in payload["state_models"]
            for state in model["variants"]
        ]
        return inventory

    def test_adversarial_requirement_dispositions_match_conceptual_owners(self):
        by_id = self._dispositions()
        expected = {
            "CONST-IA-ROOT-001": (
                "visual_mapping_required",
                [
                    "UX-SCREEN-APP-SHELL-ROOT",
                    "UX-SCREEN-GOALS-ROOT",
                    "UX-SCREEN-TIME-DAY",
                    "UX-SCREEN-TODAY-ROOT",
                    "UX-SCREEN-YOU-ROOT",
                ],
            ),
            "LAW-IA-NONROOT-001": (
                "visual_mapping_required",
                [
                    "UX-SCREEN-APP-SHELL-DRILLDOWN",
                    "UX-SCREEN-APP-SHELL-SEARCH-CAPTURE",
                    "UX-SCREEN-CAPTURE-COMPOSER",
                    "UX-SCREEN-SEARCH-ROOT",
                    "UX-SCREEN-TRUST-INLINE",
                ],
            ),
            "LAW-RUNTIME-NO-DIRECT-WRITE-001": ("nonvisual_with_rationale", []),
            "PROOF-FIGMA-AUTHORITY-001": ("nonvisual_with_rationale", []),
            "SYSTEM-APPLE-WIDGET-ACTION-001": (
                "visual_mapping_required",
                ["UX-SCREEN-APP-DEEP-LINK-INTAKE", "UX-SCREEN-TRUST-RECEIPT"],
            ),
            "SYSTEM-APPLE-WIDGET-PROJECTION-001": (
                "visual_mapping_required",
                ["UX-SECURITY-CHANNEL-WIDGETS"],
            ),
            "DESIGN-004": ("nonvisual_with_rationale", []),
            "STANDARD-VISUAL-REVIEW-001": ("nonvisual_with_rationale", []),
            "OBJECT-SAVED-FOR-LATER-001": (
                "visual_mapping_required",
                ["UX-OBJECT-SAVED-FOR-LATER-DRAFT", "UX-SCREEN-CAPTURE-SAVED-FOR-LATER"],
            ),
        }
        for requirement_id, (disposition, blueprint_ids) in expected.items():
            self.assertEqual(by_id[requirement_id]["disposition"], disposition)
            self.assertEqual(by_id[requirement_id]["blueprint_ids"], blueprint_ids)

        root_ids = {
            "CONST-IA-ROOT-001",
            "IA-PLAIN-BRANDED-NAMING-001",
            "LAW-IA-PLAIN-LANGUAGE-001",
            "LAW-IA-ROOT-001",
            "LAW-LANGUAGE-ROOT-LABELS-001",
            "LAW-SHELL-STAGE-001",
        }
        for requirement_id in root_ids:
            self.assertEqual(
                by_id[requirement_id]["disposition"], "visual_mapping_required"
            )

        nonvisual_sentinels = {
            "DESIGN-004",
            "LAW-RUNTIME-NO-DIRECT-WRITE-001",
            "OBJ-CANONICAL-OWNER-001",
            "OBJ-COMMON-ENVELOPE-001",
            "PROOF-FIGMA-AUTHORITY-001",
            "STANDARD-VISUAL-REVIEW-001",
            "SYSTEM-PERSISTENCE-COMPACTION-001",
        }
        nonvisual_sentinels.update(
            requirement_id
            for requirement_id in by_id
            if requirement_id.endswith("-VISUAL-AUTHORITY-001")
        )
        for requirement_id in nonvisual_sentinels:
            self.assertEqual(
                by_id[requirement_id]["disposition"], "nonvisual_with_rationale"
            )
            self.assertEqual(by_id[requirement_id]["blueprint_ids"], [])
            self.assertEqual(by_id[requirement_id]["state_blueprint_ids"], [])

        module = self._module()
        inverted = self._payload()
        item = self._dispositions(inverted)["DESIGN-004"]
        item["disposition"] = "visual_mapping_required"
        item["blueprint_ids"] = ["UX-SCREEN-APP-SHELL-DRILLDOWN"]
        screen = next(
            value
            for value in inverted["screens"]
            if value["blueprint_id"] == "UX-SCREEN-APP-SHELL-DRILLDOWN"
        )
        screen["requirement_ids"] = sorted(
            set(screen["requirement_ids"]) | {"DESIGN-004"}
        )
        item["rationale"] = (
            item["rationale"].rstrip(".")
            + " Visual mapping records: UX-SCREEN-APP-SHELL-DRILLDOWN."
        )
        with self.assertRaisesRegex(
            module.UXBlueprintError, "semantic disposition sentinel"
        ):
            module.validate_ux_blueprint(REPO_ROOT, inverted)

    def test_dispositions_are_bound_to_actual_requirement_text_and_specific_rationales(self):
        module = self._module()
        payload = self._payload()
        requirements = {
            item["requirement_id"]: item
            for item in module.load_requirement_source_records(REPO_ROOT)
        }
        rationales = []
        for item in payload["requirement_dispositions"]:
            requirement = requirements[item["requirement_id"]]
            expected_hash = hashlib.sha256(
                requirement["normative_text"].encode("utf-8")
            ).hexdigest()
            self.assertEqual(item["requirement_text_sha256"], expected_hash)
            self.assertIn(requirement["consequence_anchor"], item["rationale"])
            rationales.append(item["rationale"])
        self.assertEqual(len(rationales), len(set(rationales)))
        self.assertFalse(
            any("These records alone present the" in value for value in rationales)
        )

        formulaic = copy.deepcopy(payload)
        formulaic["requirement_dispositions"][0]["rationale"] = (
            "These records alone present the generic requirement consequence to users."
        )
        with self.assertRaisesRegex(module.UXBlueprintError, "formulaic rationale"):
            module.validate_ux_blueprint(REPO_ROOT, formulaic)

        stale = copy.deepcopy(payload)
        stale["requirement_dispositions"][0]["requirement_text_sha256"] = "0" * 64
        with self.assertRaisesRegex(module.UXBlueprintError, "requirement text digest"):
            module.validate_ux_blueprint(REPO_ROOT, stale)

    def test_key_screen_state_contracts_are_scope_specific(self):
        today_empty = self._state("UX-SCREEN-TODAY-ROOT", "empty")
        self.assertIn("Start here", today_empty["visible_content_copy"])
        self.assertEqual(today_empty["allowed_commands"], ["Open step"])
        self.assertEqual(
            today_empty["behavior_authority_posture"],
            "requirement_backed",
        )
        self.assertEqual(today_empty["specification_gap_ids"], [])
        self.assertEqual(
            today_empty["behavior_requirement_ids"],
            ["SPEC-SURFACE-TODAY-COMMAND-CONTRACT-001"],
        )
        self.assertTrue(today_empty["behavior_authority_evidence"])
        self.assertIn("SPEC-SURFACE-TODAY-STATES-001", today_empty["requirement_ids"])

        for model in self._payload()["state_models"]:
            for state in model["variants"]:
                self.assertEqual(
                    len(state["requirement_ids"]),
                    len(set(state["requirement_ids"])),
                )

        you_settings_degraded = self._state(
            "UX-SCREEN-YOU-SETTINGS", "biometric-unavailable"
        )
        self.assertIn("APP-DEGRADED-STATE-001", you_settings_degraded["requirement_ids"])

    def test_state_validator_rejects_mismatched_identity_generic_scope_and_missing_state_law(self):
        module = self._module()
        payload = self._payload()

        identity = copy.deepcopy(payload)
        state = self._state("UX-SCREEN-TODAY-ROOT", "empty", identity)
        state["blueprint_id"] = "UX-STATE-TODAY-ROOT-FAILURE"
        with patch.object(module, "load_state_inventory", return_value=self._inventory_for(identity)):
            with self.assertRaisesRegex(module.UXBlueprintError, "unknown state ID"):
                module.validate_ux_blueprint(REPO_ROOT, identity)

        generic = copy.deepcopy(payload)
        shell = self._state("UX-SCREEN-APP-SHELL-ROOT", "today-selected", generic)
        capture = self._state("UX-SCREEN-CAPTURE-COMPOSER", "composing", generic)
        shell["offline_behavior"] = capture["offline_behavior"]
        with self.assertRaisesRegex(module.UXBlueprintError, "blueprint command contract drift"):
            module.validate_ux_blueprint(REPO_ROOT, generic)

        missing_law = copy.deepcopy(payload)
        degraded = self._state("UX-SCREEN-TODAY-ROOT", "partial-failure", missing_law)
        degraded["requirement_ids"] = [
            item
            for item in degraded["requirement_ids"]
            if item != "APP-DEGRADED-FAILURE-TAXONOMY-001"
        ]
        with self.assertRaisesRegex(module.UXBlueprintError, "state variant omits required law"):
            module.validate_ux_blueprint(REPO_ROOT, missing_law)

        wrong_model = copy.deepcopy(payload)
        wrong_model["state_models"][0]["blueprint_id"] = "UX-STATE-MODEL-INVENTED"
        with self.assertRaisesRegex(module.UXBlueprintError, "state model identity"):
            module.validate_ux_blueprint(REPO_ROOT, wrong_model)

    def test_requirement_edges_are_bidirectionally_coherent_including_states(self):
        module = self._module()
        payload = self._payload()
        module.validate_ux_blueprint(REPO_ROOT, payload)

        invented = copy.deepcopy(payload)
        disposition = next(
            item
            for item in invented["requirement_dispositions"]
            if item["disposition"] == "visual_mapping_required"
        )
        disposition["blueprint_ids"].append("UX-SCREEN-YOU-ROOT")
        disposition["blueprint_ids"] = sorted(set(disposition["blueprint_ids"]))
        disposition["rationale"] = (
            disposition["rationale"].rstrip(".")
            + " Visual mapping records: UX-SCREEN-YOU-ROOT."
        )
        with self.assertRaisesRegex(module.UXBlueprintError, "disposition edge"):
            module.validate_ux_blueprint(REPO_ROOT, invented)

        omitted = copy.deepcopy(payload)
        state = self._state("UX-SCREEN-TODAY-ROOT", "empty", omitted)
        requirement_id = state["requirement_ids"][0]
        disposition = self._dispositions(omitted)[requirement_id]
        disposition["state_blueprint_ids"].remove(state["blueprint_id"])
        disposition["rationale"] = disposition["rationale"].replace(
            state["blueprint_id"] + ", ", ""
        ).replace(", " + state["blueprint_id"], "").replace(
            state["blueprint_id"], ""
        )
        with self.assertRaisesRegex(module.UXBlueprintError, "state disposition edge"):
            module.validate_ux_blueprint(REPO_ROOT, omitted)

    def test_now_capture_vocabulary_accessibility_and_design_foundations_are_exact(self):
        module = self._module()
        payload = self._payload()
        serialized = json.dumps(payload, ensure_ascii=False)
        self.assertNotIn("recommended next movement", serialized.casefold())
        self.assertNotIn("No Now", serialized)
        self.assertNotIn("prior-current Now", serialized)
        self.assertNotIn("Capture history", serialized)

        today_empty = self._state("UX-SCREEN-TODAY-ROOT", "empty", payload)
        self.assertNotIn("Now", today_empty["displayed_objects"])
        self.assertIn("Start here", today_empty["visible_content_copy"])

        cross = {item["facet"]: item for item in payload["cross_cutting"]}
        self.assertIn("DESIGN-002", cross["light-dark"]["requirement_ids"])
        self.assertIn("DESIGN-003", cross["light-dark"]["requirement_ids"])
        self.assertIn("system", cross["light-dark"]["contract"].casefold())
        self.assertIn("contrast", cross["light-dark"]["contract"].casefold())

        accessibility_contracts = {
            tuple(item["accessibility"]) for item in payload["screens"]
        }
        self.assertGreaterEqual(len(accessibility_contracts), 35)

        stale = copy.deepcopy(payload)
        stale["screens"][0]["purpose"] += " recommended next movement"
        with self.assertRaisesRegex(module.UXBlueprintError, "stale vocabulary"):
            module.validate_ux_blueprint(REPO_ROOT, stale)

    def test_canonical_named_state_variant_matrices_are_explicit_and_frameable(self):
        module = self._module()
        payload = self._payload()
        all_variants = [
            item for model in payload["state_models"] for item in model["variants"]
        ]
        self.assertEqual(len(all_variants), 433)
        self.assertEqual(len({item["blueprint_id"] for item in all_variants}), 433)
        eligible_ids = module.authority_eligible_state_variant_ids(payload, REPO_ROOT)
        self.assertEqual(len(eligible_ids), 411)
        for item in all_variants:
            self.assertEqual(set(item), VARIANT_FIELDS)
            if item["behavior_authority_posture"] == "requirement_backed":
                self.assertTrue(
                    item["allowed_commands"]
                    or item["future_gated_commands"]
                    or item["blueprint_id"]
                    == "UX-STATE-VARIANT-TRUST-INLINE-NO-DISCLOSURE"
                )
                self.assertTrue(item["behavior_requirement_ids"])
                self.assertTrue(item["behavior_authority_evidence"])
                self.assertEqual(item["specification_gap_ids"], [])
            else:
                self.assertEqual(item["allowed_commands"], [])
                self.assertEqual(item["behavior_requirement_ids"], [])
                self.assertEqual(item["behavior_authority_evidence"], [])
                self.assertTrue(item["specification_gap_ids"])
                self.assertNotIn(item["blueprint_id"], eligible_ids)
        self.assertEqual(module.validate_ux_blueprint(REPO_ROOT, payload).state_variant_count, 433)

        expected = {
            "UX-SCREEN-CAPTURE-COMPOSER": {
                "blank", "composing", "typed", "confirmation-required", "saved",
                "saved-undo-eligible", "saved-undo-unavailable", "recovered",
                "discard-review", "dictating", "scan-importing", "validating",
                "routing", "saving", "restoring", "offline", "ambiguous-type",
                "invalid-metadata", "partial-routing", "degraded-store",
            },
            "UX-SCREEN-CAPTURE-ATTACHMENT": {
                "attachment-ready", "attachment-processing",
                "attachment-permission-denied", "attachment-failed",
            },
            "UX-SCREEN-CAPTURE-PROPOSAL": {
                "proposal-ready", "classifying", "fit-proposing", "proposal-conflict",
            },
            "UX-SCREEN-CAPTURE-SAVED-FOR-LATER": {"saved-for-later"},
            "UX-SCREEN-SEARCH-ROOT": {
                "empty-query", "recent", "querying", "rebuilding", "restored",
                "privacy-suppressed", "action-validating", "action-mutating",
                "inspection-handoff", "corrupt-index", "stale-index",
                "unavailable-projection", "permission-denied", "partial-results",
                "offline-healthy", "action-rejected",
            },
            "UX-SCREEN-SEARCH-RESULTS": {
                "results", "no-results", "filtered", "selected", "action-preview",
                "action-complete", "action-complete-undo-eligible",
                "action-complete-undo-unavailable",
            },
            "UX-SCREEN-TODAY-ROOT": {
                "empty", "low-density", "populated", "dense",
                "stale-external-context", "offline-healthy", "permission-denied",
                "conflict", "partial-failure", "restored", "loading", "recovery",
                "destructive-confirmation",
            },
            "UX-SCREEN-TODAY-START-HERE": {
                "active-execution", "closure-ready", "recovery-needed",
            },
        }
        permission_keys = {
            "not-determined", "authorized", "limited", "denied", "restricted",
            "unavailable", "eligibility-check", "local-fallback", "reconciling",
            "request-failed", "settings-return-failed", "revoked",
            "partial-external-access",
        }
        for screen_id in (
            "UX-SCREEN-PERMISSIONS-CALENDAR",
            "UX-SCREEN-PERMISSIONS-NOTIFICATIONS",
        ):
            expected[screen_id] = permission_keys
        time_keys = {
            "empty", "populated", "dense", "selected", "editing", "previewing",
            "conflicting", "importing", "restored", "now-anchored",
            "external-hidden-capacity",
        }
        for suffix in ("DAY", "LIST", "MONTH", "WEEK", "YEAR"):
            expected[f"UX-SCREEN-TIME-{suffix}"] = time_keys

        total = 0
        for screen_id, keys in expected.items():
            variants = self._variants(screen_id, payload)
            self.assertEqual({item["variant_key"] for item in variants}, keys)
            total += len(variants)
            for item in variants:
                self.assertEqual(set(item), VARIANT_FIELDS)
                self.assertEqual(item["implementation_status"], "design_input_only")
                self.assertEqual(item["proof_ceiling"], module.RECORD_PROOF_CEILING)
                self.assertTrue(item["requirement_ids"])
                if item["behavior_authority_posture"] == "requirement_backed":
                    self.assertTrue(item["allowed_commands"])
                else:
                    self.assertEqual(item["allowed_commands"], [])
                    self.assertTrue(item["specification_gap_ids"])
                self.assertTrue(item["displayed_objects"])

        all_variants = [
            item for model in payload["state_models"] for item in model["variants"]
        ]
        self.assertEqual(len(all_variants), 433)
        self.assertEqual(len({item["blueprint_id"] for item in all_variants}), 433)
        self.assertEqual(total, sum(len(keys) for keys in expected.values()))
        summary = module.validate_ux_blueprint(REPO_ROOT, payload)
        self.assertEqual(summary.state_variant_count, 433)

    def test_you_trust_security_and_rollback_variants_preserve_exact_consequences(self):
        payload = self._payload()
        by_screen = {
            model["screen_id"]: {
                item["variant_key"]: item for item in model["variants"]
            }
            for model in payload["state_models"]
        }
        self.assertTrue(
            {
                "no-account-healthy", "continuity-conflicted", "action-required",
                "life-capital-empty", "diagnostics-degraded",
            }.issubset(by_screen["UX-SCREEN-YOU-ROOT"])
        )
        self.assertTrue(
            {
                "appearance-system", "appearance-light", "appearance-dark",
                "appearance-oled-dark", "increase-contrast", "privacy-review",
                "app-lock-disabled", "app-lock-enabled", "biometric-unavailable",
            }.issubset(by_screen["UX-SCREEN-YOU-SETTINGS"])
        )
        self.assertTrue(
            {
                "no-disclosure", "marker-present", "proof-required", "proof-satisfied",
            }.issubset(by_screen["UX-SCREEN-TRUST-INLINE"])
        )
        self.assertTrue(
            {
                "source-current", "source-stale", "source-unavailable",
                "privacy-boundary-review", "privacy-redacted", "correction-required",
            }.issubset(by_screen["UX-SCREEN-TRUST-DEEP"])
        )

        irreversible = by_screen["UX-SCREEN-YOU-DATA"][
            "permanent-delete-irreversible"
        ]
        self.assertNotIn("Undo", irreversible["allowed_commands"])
        self.assertNotIn("Restore", irreversible["allowed_commands"])
        self.assertIn("irreversible", irreversible["durable_effect"].casefold())

        import_variants = by_screen["UX-SCREEN-TIME-IMPORT"]
        self.assertIn("native-import-undo", import_variants)
        self.assertIn("external-source-unchanged", import_variants)
        self.assertIn("import-undo-unavailable", import_variants)

        security = self._dispositions(payload)["SECURITY-003"]
        self.assertEqual(security["disposition"], "visual_mapping_required")
        self.assertTrue(
            any("BIOMETRIC-UNAVAILABLE" in item for item in security["state_blueprint_ids"])
        )
        self.assertTrue(
            any("PERMANENT-DELETE" in item for item in security["state_blueprint_ids"])
        )

    def test_variant_validator_rejects_missing_invented_and_mismatched_ids(self):
        module = self._module()
        payload = self._payload()

        missing = copy.deepcopy(payload)
        self._variants("UX-SCREEN-CAPTURE-COMPOSER", missing).pop()
        with patch.object(module, "load_state_inventory", return_value=self._inventory_for(missing)):
            with self.assertRaisesRegex(
                module.UXBlueprintError,
                "state contract references unknown state ID",
            ):
                module.validate_ux_blueprint(REPO_ROOT, missing)

        invented = copy.deepcopy(payload)
        sample = copy.deepcopy(self._variants("UX-SCREEN-CAPTURE-COMPOSER", invented)[0])
        sample["variant_key"] = "invented"
        sample["blueprint_id"] = "UX-STATE-VARIANT-CAPTURE-COMPOSER-INVENTED"
        self._variants("UX-SCREEN-CAPTURE-COMPOSER", invented).append(sample)
        with patch.object(module, "load_state_inventory", return_value=self._inventory_for(invented)):
            with self.assertRaisesRegex(module.UXBlueprintError, "state variant inventory"):
                module.validate_ux_blueprint(REPO_ROOT, invented)

        mismatched = copy.deepcopy(payload)
        self._variants("UX-SCREEN-SEARCH-ROOT", mismatched)[0]["blueprint_id"] = (
            "UX-STATE-VARIANT-SEARCH-ROOT-WRONG"
        )
        with patch.object(module, "load_state_inventory", return_value=self._inventory_for(mismatched)):
            with self.assertRaisesRegex(
                module.UXBlueprintError,
                "state contract references unknown state ID|state variant identity",
            ):
                module.validate_ux_blueprint(REPO_ROOT, mismatched)

    def test_variant_validator_rejects_formulaic_or_repeated_narrative_contracts(self):
        module = self._module()
        payload = self._payload()

        formulaic = copy.deepcopy(payload)
        self._variants("UX-SCREEN-CAPTURE-COMPOSER", formulaic)[0][
            "visible_content_copy"
        ] = "This state shows the exact current state, consequence, and available next action."
        with self.assertRaisesRegex(module.UXBlueprintError, "formulaic state variant"):
            module.validate_ux_blueprint(REPO_ROOT, formulaic)

        repeated = copy.deepcopy(payload)
        variants = self._variants("UX-SCREEN-CAPTURE-COMPOSER", repeated)
        variants[1]["offline_behavior"] = variants[0]["offline_behavior"]
        with self.assertRaisesRegex(
            module.UXBlueprintError, "state variant narrative must be unique"
        ):
            module.validate_ux_blueprint(REPO_ROOT, repeated)

    def test_screen_specific_voiceover_and_language_contracts_are_canon_ordered(self):
        payload = self._payload()
        screens = {item["blueprint_id"]: item for item in payload["screens"]}
        self.assertIn(
            "active primary object before Capture, Search, and root navigation",
            screens["UX-SCREEN-APP-SHELL-ROOT"]["accessibility"][0],
        )
        self.assertIn(
            "context, Start here and fit, primary action, boundaries, next fixed point, then temporal rail",
            screens["UX-SCREEN-TODAY-ROOT"]["accessibility"][0],
        )
        self.assertIn(
            "selected subject, Trust category, status, explanation, evidence, consequence, then actions",
            screens["UX-SCREEN-TRUST-DEEP"]["accessibility"][0],
        )
        serialized = json.dumps(payload, ensure_ascii=False).casefold()
        self.assertNotIn("next movement", serialized)
        self.assertNotIn("passive root view", serialized)
        self.assertNotIn("discard uncommitted today reality window input", serialized)
        self.assertNotIn("discard uncommitted time day input", serialized)

    def test_named_variants_are_authored_contracts_not_generic_templates(self):
        payload = self._payload()
        variants = [
            variant
            for model in payload["state_models"]
            for variant in model["variants"]
        ]
        serialized = json.dumps(
            variants,
            ensure_ascii=False,
        ).casefold()
        for formula in (
            "shows the exact current state, consequence, and available next action",
            "stable frameable",
            "uses verified local facts offline; unavailable external context",
            "returns to the exact owning",
            "current consequence, displayed objects, then actions",
            "remains non-durable until its separately confirmed command succeeds",
            "creates no durable effect",
            "without changing canonical data",
            "uses only its operation-specific recovery law",
        ):
            self.assertNotIn(formula, serialized)
        for field in (
            "visible_content_copy",
            "visible_presentation",
            "durable_effect",
            "transition_exit",
            "recovery_rollback",
            "offline_behavior",
            "accessibility_focus",
        ):
            values = [item[field] for item in variants]
            self.assertEqual(
                len(values),
                len(set(values)),
                f"named variants share formulaic {field}",
            )

    def test_critical_named_states_encode_exact_objects_actions_and_consequences(self):
        payload = self._payload()
        by_screen = {
            model["screen_id"]: {
                item["variant_key"]: item for item in model["variants"]
            }
            for model in payload["state_models"]
        }

        today = by_screen["UX-SCREEN-TODAY-ROOT"]
        self.assertNotIn("permission-conflict", today)
        self.assertIn("permission-denied", today)
        self.assertIn("conflict", today)
        for key in ("permission-denied", "conflict"):
            self.assertTrue(today[key]["allowed_commands"])
            self.assertEqual(today[key]["specification_gap_ids"], [])
        self.assertNotEqual(
            today["permission-denied"]["displayed_objects"],
            today["conflict"]["displayed_objects"],
        )
        self.assertIn(
            "details hidden",
            json.dumps(by_screen["UX-SCREEN-TIME-DAY"]["external-hidden-capacity"]).casefold(),
        )
        self.assertEqual(by_screen["UX-SCREEN-TRUST-INLINE"]["no-disclosure"]["displayed_objects"], [])

        empty_day = by_screen["UX-SCREEN-TIME-DAY"]["empty"]
        self.assertTrue(
            {"Event", "Reminder", "Schedule Placement", "Step"}.isdisjoint(
                empty_day["displayed_objects"]
            )
        )

        hidden_capacity = by_screen["UX-SCREEN-TIME-DAY"][
            "external-hidden-capacity"
        ]
        hidden_text = json.dumps(hidden_capacity).casefold()
        self.assertIn("details hidden", hidden_text)
        self.assertIn("capacity", hidden_text)
        self.assertNotIn("open external event", hidden_text)

        partial = by_screen["UX-SCREEN-TODAY-ROOT"]["partial-failure"]
        permission = by_screen["UX-SCREEN-TODAY-ROOT"]["permission-denied"]
        conflict = by_screen["UX-SCREEN-TODAY-ROOT"]["conflict"]
        self.assertNotEqual(partial["displayed_objects"], permission["displayed_objects"])
        self.assertNotEqual(permission["displayed_objects"], conflict["displayed_objects"])
        for state in (partial, permission, conflict):
            self.assertTrue(state["allowed_commands"])
            self.assertEqual(state["behavior_authority_posture"], "requirement_backed")
            self.assertEqual(state["specification_gap_ids"], [])

        no_disclosure = by_screen["UX-SCREEN-TRUST-INLINE"]["no-disclosure"]
        self.assertEqual(no_disclosure["displayed_objects"], [])
        self.assertEqual(no_disclosure["allowed_commands"], [])
        self.assertNotIn(
            "inspect",
            " ".join(no_disclosure["allowed_commands"]).casefold(),
        )
        self.assertNotIn(
            "inspect",
            (no_disclosure["visible_content_copy"] + no_disclosure["visible_presentation"]).casefold(),
        )

        biometric = by_screen["UX-SCREEN-YOU-SETTINGS"]["biometric-unavailable"]
        biometric_text = json.dumps(biometric).casefold()
        self.assertIn("passcode", biometric_text)
        self.assertIn("not locked out", biometric_text)

        continuity = by_screen["UX-SCREEN-YOU-ROOT"]["continuity-conflicted"]
        continuity_text = json.dumps(continuity).casefold()
        self.assertIn("conflict scope", continuity_text)
        self.assertIn("local", continuity_text)
        self.assertIn("authority", continuity_text)

        irreversible = by_screen["UX-SCREEN-YOU-DATA"][
            "permanent-delete-irreversible"
        ]
        self.assertIn("cannot be undone or restored", irreversible["visible_content_copy"].casefold())

        import_variants = by_screen["UX-SCREEN-TIME-IMPORT"]
        self.assertIn(
            "ambitions-native",
            import_variants["native-import-undo"]["visible_content_copy"].casefold(),
        )
        self.assertIn(
            "external source remains unchanged",
            import_variants["external-source-unchanged"]["visible_content_copy"].casefold(),
        )
        self.assertIn(
            "undo is unavailable",
            import_variants["import-undo-unavailable"]["visible_content_copy"].casefold(),
        )

    def test_screen_focus_order_does_not_contradict_voiceover_order(self):
        screens = {
            item["blueprint_id"]: item for item in self._payload()["screens"]
        }
        shell = " ".join(screens["UX-SCREEN-APP-SHELL-ROOT"]["accessibility"])
        self.assertIn("Keyboard and focus: Root app shell enters at the active primary object", shell)
        self.assertNotIn("enters at Capture action", shell)

        trust = " ".join(screens["UX-SCREEN-TRUST-DEEP"]["accessibility"])
        self.assertIn("enters at selected subject", trust)
        self.assertNotIn("enters at History Event", trust)

        time_day = " ".join(screens["UX-SCREEN-TIME-DAY"]["accessibility"])
        for phrase in (
            "selected range",
            "Now and Today",
            "protected and fixed reality",
            "flexible capacity",
            "conflicts",
            "next object",
        ):
            self.assertIn(phrase, time_day)

    def test_security_mapping_covers_every_user_visible_exposure_channel(self):
        payload = self._payload()
        security = self._dispositions(payload)["SECURITY-003"]
        self.assertTrue(
            {
                "UX-SCREEN-APP-SHELL-ROOT",
                "UX-SCREEN-CAPTURE-ATTACHMENT",
                "UX-SCREEN-CAPTURE-COMPOSER",
                "UX-SCREEN-CAPTURE-PROPOSAL",
                "UX-SCREEN-PERMISSIONS-NOTIFICATIONS",
                "UX-SCREEN-SEARCH-ROOT",
                "UX-SCREEN-TRUST-DEEP",
                "UX-SCREEN-YOU-DATA",
                "UX-SCREEN-YOU-SETTINGS",
            }.issubset(security["blueprint_ids"])
        )
        cross_cutting = {
            item["blueprint_id"]: item for item in payload["cross_cutting"]
        }
        exposure = cross_cutting["UX-CROSS-SENSITIVE-EXPOSURE-CHANNELS"]
        self.assertIn("SECURITY-003", exposure["requirement_ids"])
        exposure_text = json.dumps(exposure).casefold()
        for phrase in (
            "capture",
            "app switcher",
            "widget",
            "spotlight",
            "clipboard",
            "diagnostics",
            "support",
            "visible fields",
            "consent",
            "redaction",
            "retention",
            "protection",
            "denial",
            "proof behavior",
        ):
            self.assertIn(phrase, exposure_text)

    def test_generated_blueprint_copy_has_clean_punctuation_and_locked_casing(self):
        payload_text = (
            REPO_ROOT / "docs/canon/migration/ux-blueprint.json"
        ).read_text(encoding="utf-8")
        self.assertNotIn("..", payload_text)
        self.assertNotIn("Open Step", payload_text)
        self.assertNotIn("Start Now", payload_text)
        self.assertNotIn("Oled", payload_text)
        self.assertNotIn("Move It", payload_text)
        self.assertNotIn("Still Counts", payload_text)
        self.assertNotIn("Not Needed", payload_text)

    def test_named_variants_replace_invented_base_state_authority(self):
        payload = self._payload()
        generic_kinds = {
            "degraded", "empty", "failure", "interruption", "loading",
            "recovery", "resting", "rollback", "transitional",
        }
        for model in payload["state_models"]:
            self.assertNotIn("states", model)
            self.assertTrue(model["variants"], model["screen_id"])
            taxonomy = {item["generic_kind"]: item for item in model["taxonomy"]}
            self.assertEqual(set(taxonomy), generic_kinds)
            by_kind = {}
            for variant in model["variants"]:
                by_kind.setdefault(variant["generic_kind"], []).append(
                    variant["blueprint_id"]
                )
            for kind in generic_kinds:
                item = taxonomy[kind]
                expected = sorted(by_kind.get(kind, []))
                if expected:
                    self.assertEqual(item["applicability"], "applicable")
                    self.assertEqual(item["variant_ids"], expected)
                else:
                    self.assertEqual(item["applicability"], "not_applicable")
                    self.assertEqual(item["variant_ids"], [])

    def test_goals_screens_own_the_exact_fifteen_state_matrix(self):
        payload = self._payload()
        detail = {item["variant_key"]: item for item in self._variants("UX-SCREEN-GOALS-DETAIL", payload)}
        self.assertTrue({"clarifying", "activating", "generation-failed", "preview-rejected"} <= set(detail))
        for state in detail.values():
            self.assertTrue(state["allowed_commands"])
            self.assertEqual(state["specification_gap_ids"], [])
        expected_by_screen = {
            "UX-SCREEN-GOALS-CLOSURE": {
                "completed", "ended", "needs-attention",
            },
            "UX-SCREEN-GOALS-DETAIL": {
                "draft", "ready-to-activate", "active", "paused", "completed",
                "archived", "ended", "needs-attention", "recovering", "waiting",
                "blocked", "dense", "clarifying", "activating",
                "generation-failed", "preview-rejected",
            },
            "UX-SCREEN-GOALS-LIFE-AREA": {
                "empty-direction", "populated", "dense", "needs-attention",
            },
            "UX-SCREEN-GOALS-PATH": {
                "draft", "ready-to-activate", "active", "paused", "completed",
                "needs-attention", "recovering", "waiting", "blocked", "dense",
                "selected-node", "route-generating", "simulating", "path-adjusting",
                "restoring", "missing-reference-context",
                "path-generation-uncertain", "partial-simulation", "rolled-back",
            },
            "UX-SCREEN-GOALS-RECOVERY": {
                "needs-attention", "recovering", "waiting", "blocked",
                "proof-transferring", "schedule-conflict",
                "partial-schedule-failure", "offline-healthy", "local-store-degraded",
            },
            "UX-SCREEN-GOALS-ROOT": {
                "empty-direction", "populated", "dense", "needs-attention",
            },
        }
        for screen_id, expected in expected_by_screen.items():
            self.assertEqual(
                {item["variant_key"] for item in self._variants(screen_id, payload)},
                expected,
            )

    def test_interpolated_state_contract_skeletons_are_forbidden(self):
        module = self._module()
        payload = self._payload()
        variants = [
            variant for model in payload["state_models"] for variant in model["variants"]
        ]
        forbidden = (
            r"follows the declared owner for .+; .+ preserves or restores the invoking object",
            r"no longer supports the declared condition",
            r"any command needing external authority is unavailable with its reason",
            r"Viewing .+ commits nothing; .+ is the explicit primary route",
        )
        for variant in variants:
            for field in (
                "transition_exit", "durable_effect", "offline_behavior",
                "recovery_rollback",
            ):
                for pattern in forbidden:
                    self.assertIsNone(
                        re.search(pattern, variant[field], re.IGNORECASE),
                        f"{variant['blueprint_id']} retains {field} skeleton",
                    )

        interpolated = copy.deepcopy(payload)
        variant = interpolated["state_models"][0]["variants"][0]
        variant["transition_exit"] = (
            "From Invented Screen Invented State, Continue follows the declared "
            "owner for invented object; Close preserves or restores the invoking "
            "object without silently committing another command."
        )
        with self.assertRaisesRegex(
            module.UXBlueprintError, "formulaic state variant narrative"
        ):
            module.validate_ux_blueprint(REPO_ROOT, interpolated)

    def test_time_views_respect_view_specific_temporal_and_editing_law(self):
        payload = self._payload()
        by_screen = {
            model["screen_id"]: {
                item["variant_key"]: item for item in model["variants"]
            }
            for model in payload["state_models"]
        }
        for suffix in ("DAY", "WEEK"):
            state = by_screen[f"UX-SCREEN-TIME-{suffix}"]["now-anchored"]
            self.assertIn("Now marker", state["displayed_objects"])
            self.assertIn("SPEC-SURFACE-TIME-TODAY-CONTROL-001", state["requirement_ids"])
        for suffix in ("LIST", "MONTH", "YEAR"):
            state = by_screen[f"UX-SCREEN-TIME-{suffix}"]["now-anchored"]
            text = json.dumps(state)
            self.assertNotIn("Now marker", state["displayed_objects"])
            self.assertIn("current-period", text.casefold())
            self.assertIn("SPEC-SURFACE-TIME-TODAY-CONTROL-001", state["requirement_ids"])

        year_editing = by_screen["UX-SCREEN-TIME-YEAR"]["editing"]
        self.assertNotIn("Save Change", year_editing["allowed_commands"])
        self.assertIn("drilldown", json.dumps(year_editing).casefold())

        granular_objects = {
            "Event", "Reminder", "Schedule Placement", "Step",
            "next chronological object", "selected item",
        }
        granular_commands = {
            "Create Event", "Create Reminder", "Create Step", "Edit",
            "Open Event", "Open Reminder", "Open Step", "Save Change",
        }
        for state in by_screen["UX-SCREEN-TIME-YEAR"].values():
            self.assertTrue(
                granular_objects.isdisjoint(state["displayed_objects"]),
                state["blueprint_id"],
            )
            self.assertTrue(
                granular_commands.isdisjoint(state["allowed_commands"]),
                state["blueprint_id"],
            )
            self.assertIn("month", json.dumps(state).casefold())

    def test_security_channels_are_explicit_records_not_an_abstract_list(self):
        payload = self._payload()
        channels = payload["sensitive_exposure_channels"]
        self.assertEqual(
            {item["channel"] for item in channels},
            {
                "app-switcher", "notifications", "widgets", "spotlight",
                "clipboard", "capture", "diagnostics", "support", "export",
            },
        )
        required_fields = {
            "blueprint_id", "channel", "visible_fields", "defaults", "consent",
            "redaction", "retention", "protection", "user_control",
            "denial_behavior", "proof_behavior", "requirement_ids",
            "implementation_status", "proof_ceiling",
        }
        for item in channels:
            self.assertEqual(set(item), required_fields)
            for field in required_fields - {"requirement_ids"}:
                self.assertTrue(item[field])
            self.assertIn("SECURITY-003", item["requirement_ids"])

        dispositions = self._dispositions(payload)
        for requirement_id in (
            "SYSTEM-APPLE-PROJECTION-001",
            "SYSTEM-APPLE-WIDGET-PROJECTION-001",
        ):
            self.assertEqual(
                dispositions[requirement_id]["disposition"],
                "visual_mapping_required",
            )
            self.assertTrue(
                any(
                    item.startswith("UX-SECURITY-CHANNEL-")
                    for item in dispositions[requirement_id]["blueprint_ids"]
                )
            )

    def test_undo_availability_is_split_into_authorizing_named_states(self):
        payload = self._payload()
        by_screen = {
            model["screen_id"]: {
                item["variant_key"]: item for item in model["variants"]
            }
            for model in payload["state_models"]
        }
        for screen_id, base in (
            ("UX-SCREEN-CAPTURE-COMPOSER", "saved"),
            ("UX-SCREEN-SEARCH-RESULTS", "action-complete"),
            ("UX-SCREEN-TRUST-RECEIPT", "receipt-committed"),
        ):
            states = by_screen[screen_id]
            for key in (base, f"{base}-undo-eligible", f"{base}-undo-unavailable"):
                self.assertIn(key, states)
                if states[key]["behavior_authority_posture"] == "requirement_backed":
                    self.assertFalse(states[key]["specification_gap_ids"])
                    self.assertTrue(states[key]["behavior_requirement_ids"])
                else:
                    self.assertEqual(states[key]["allowed_commands"], [])
                    self.assertTrue(states[key]["specification_gap_ids"])
        for screen_id, base in (
            ("UX-SCREEN-CAPTURE-COMPOSER", "saved"),
            ("UX-SCREEN-SEARCH-RESULTS", "action-complete"),
            ("UX-SCREEN-TRUST-RECEIPT", "receipt-committed"),
        ):
            states = by_screen[screen_id]
            self.assertNotIn("Undo", states[base]["allowed_commands"])
            eligible = states[f"{base}-undo-eligible"]
            unavailable = states[f"{base}-undo-unavailable"]
            if eligible["behavior_authority_posture"] == "requirement_backed":
                self.assertIn("Undo", eligible["allowed_commands"])
            else:
                self.assertEqual(eligible["allowed_commands"], [])
            self.assertNotIn("Undo", unavailable["allowed_commands"])
            self.assertIn("unavailable", json.dumps(unavailable).casefold())

    def test_permission_eligibility_returns_to_contextual_invoker(self):
        payload = self._payload()
        for screen_id in (
            "UX-SCREEN-PERMISSIONS-CALENDAR",
            "UX-SCREEN-PERMISSIONS-NOTIFICATIONS",
        ):
            state = next(
                item
                for item in self._variants(screen_id, payload)
                if item["variant_key"] == "eligibility-check"
            )
            contract = state["transition_exit"] + " " + state["recovery_rollback"]
            self.assertNotIn("setup", contract.casefold())
            self.assertEqual(state["allowed_commands"], ["Check Again"])
            self.assertEqual(
                state["behavior_requirement_ids"],
                ["APP-PERMISSIONS-COMMAND-CONTRACT-001"],
            )
            self.assertEqual(state["specification_gap_ids"], [])

    def test_requirement_rationales_are_clause_safe_and_complete(self):
        module = self._module()
        payload = self._payload()
        for item in payload["requirement_dispositions"]:
            rationale = item["rationale"]
            self.assertIsNone(re.search(r"[,;:]\.", rationale), item["requirement_id"])
            self.assertRegex(rationale, r"[.!?]$")

        malformed = copy.deepcopy(payload)
        malformed["requirement_dispositions"][0]["rationale"] += " ,."
        with self.assertRaisesRegex(module.UXBlueprintError, "rationale punctuation"):
            module.validate_ux_blueprint(REPO_ROOT, malformed)

        incomplete = copy.deepcopy(payload)
        incomplete["requirement_dispositions"][0]["rationale"] = incomplete[
            "requirement_dispositions"
        ][0]["rationale"].rstrip(".")
        with self.assertRaisesRegex(module.UXBlueprintError, "rationale is incomplete"):
            module.validate_ux_blueprint(REPO_ROOT, incomplete)

    def test_normalized_narratives_preserve_fail_closed_behavior_authority(self):
        module = self._module()
        payload = self._payload()
        eligible_ids = module.authority_eligible_state_variant_ids(payload, REPO_ROOT)
        self.assertEqual(len(eligible_ids), 411)
        for model in payload["state_models"]:
            for variant in model["variants"]:
                if variant["behavior_authority_posture"] == "requirement_backed":
                    self.assertTrue(variant["behavior_requirement_ids"])
                    self.assertTrue(variant["behavior_authority_evidence"])
                    self.assertEqual(variant["specification_gap_ids"], [])
                else:
                    self.assertEqual(variant["allowed_commands"], [])
                    self.assertEqual(variant["behavior_requirement_ids"], [])
                    self.assertEqual(variant["behavior_authority_evidence"], [])
                    self.assertTrue(variant["specification_gap_ids"])
                    self.assertNotIn(variant["blueprint_id"], eligible_ids)

        forbidden = (
            "consequence, consequence", "may produce the consequence declared",
            "canonical owner", "invoking object", "invoking context",
        )
        for model in payload["state_models"]:
            for variant in model["variants"]:
                combined = " ".join(
                    str(variant[field])
                    for field in (
                        "visible_content_copy",
                        "visible_presentation",
                        "transition_exit",
                        "durable_effect",
                        "recovery_rollback",
                        "offline_behavior",
                        "accessibility_focus",
                    )
                ).casefold()
                for phrase in forbidden:
                    self.assertNotIn(phrase, combined, variant["blueprint_id"])

        permitted_invoking_feature = {
            "UX-STATE-VARIANT-PERMISSIONS-CALENDAR-ELIGIBILITY-CHECK",
            "UX-STATE-VARIANT-PERMISSIONS-NOTIFICATIONS-ELIGIBILITY-CHECK",
        }
        for model in payload["state_models"]:
            for variant in model["variants"]:
                text = json.dumps(variant, ensure_ascii=False).casefold()
                self.assertNotIn("invoking object", text, variant["blueprint_id"])
                self.assertNotIn("invoking context", text, variant["blueprint_id"])
                if "invoking feature" in text:
                    self.assertIn(variant["blueprint_id"], permitted_invoking_feature)

    def test_compact_primary_and_every_goals_command_have_one_exact_contract(self):
        payload = self._payload()
        module = self._module()
        eligible_ids = module.authority_eligible_state_variant_ids(payload, REPO_ROOT)
        self.assertEqual(len(eligible_ids), 411)
        for model in payload["state_models"]:
            for variant in model["variants"]:
                if variant["behavior_authority_posture"] == "requirement_backed":
                    self.assertTrue(variant["behavior_requirement_ids"])
                    self.assertTrue(variant["behavior_authority_evidence"])
                    self.assertEqual(variant["specification_gap_ids"], [])
                else:
                    self.assertEqual(variant["allowed_commands"], [])
                    self.assertEqual(variant["behavior_requirement_ids"], [])
                    self.assertEqual(variant["behavior_authority_evidence"], [])
                    self.assertTrue(variant["specification_gap_ids"])
                    self.assertNotIn(variant["blueprint_id"], eligible_ids)
        compact_screens = {
            "UX-SCREEN-ACCOUNT-BOUNDARY", "UX-SCREEN-ACCOUNT-SIGN-IN",
            "UX-SCREEN-ACCOUNT-STATUS", "UX-SCREEN-APP-SHELL-DRILLDOWN",
            "UX-SCREEN-APP-SHELL-ROOT", "UX-SCREEN-APP-SHELL-SEARCH-CAPTURE",
            "UX-SCREEN-OFFLINE-DEGRADED-LOCAL-HEALTH",
            "UX-SCREEN-OFFLINE-DEGRADED-REPAIR", "UX-SCREEN-SETUP-FIRST-USE",
            "UX-SCREEN-SETUP-RESUME", "UX-SCREEN-TIME-DETAIL",
            "UX-SCREEN-TODAY-DETAIL",
        }
        goals_screens = {
            "UX-SCREEN-GOALS-CLOSURE", "UX-SCREEN-GOALS-DETAIL",
            "UX-SCREEN-GOALS-LIFE-AREA", "UX-SCREEN-GOALS-PATH",
            "UX-SCREEN-GOALS-RECOVERY", "UX-SCREEN-GOALS-ROOT",
        }
        for model in payload["state_models"]:
            if model["screen_id"] not in compact_screens | goals_screens:
                continue
            for variant in model["variants"]:
                if variant["behavior_authority_posture"] == "requirement_backed":
                    self.assertTrue(
                        variant["allowed_commands"]
                        or variant["future_gated_commands"]
                    )
                    self.assertEqual(variant["specification_gap_ids"], [])
                else:
                    self.assertEqual(variant["allowed_commands"], [])
                    self.assertTrue(variant["specification_gap_ids"])

        partial = copy.deepcopy(payload)
        variant = next(
            variant
            for model in partial["state_models"]
            for variant in model["variants"]
            if model["screen_id"] == "UX-SCREEN-TODAY-DETAIL"
            and variant["variant_key"] == "active-execution"
        )
        variant["allowed_commands"] = ["Invented Command"]
        with self.assertRaisesRegex(
            self._module().UXBlueprintError,
            "allowed commands drift",
        ):
            self._module().validate_ux_blueprint(REPO_ROOT, partial)

    def test_dense_goals_and_time_detail_use_closed_named_presentations(self):
        module = self._module()
        payload = self._payload()
        eligible_ids = module.authority_eligible_state_variant_ids(payload, REPO_ROOT)
        for screen_id in (
            "UX-SCREEN-GOALS-DETAIL", "UX-SCREEN-GOALS-LIFE-AREA",
            "UX-SCREEN-GOALS-PATH", "UX-SCREEN-GOALS-ROOT",
            "UX-SCREEN-TIME-DETAIL",
        ):
            for state in self._variants(screen_id, payload):
                if state["behavior_authority_posture"] == "requirement_backed":
                    self.assertTrue(state["allowed_commands"])
                    self.assertFalse(state["specification_gap_ids"])
                    self.assertIn(state["blueprint_id"], eligible_ids)
                else:
                    self.assertEqual(state["allowed_commands"], [])
                    self.assertTrue(state["specification_gap_ids"])
                    self.assertIn(
                        "no exact command authorized by current canon",
                        json.dumps(state).casefold(),
                    )
                    self.assertNotIn(state["blueprint_id"], eligible_ids)
        expected_dense = {
            "UX-SCREEN-GOALS-DETAIL": (
                "Goal Detail filter sheet", "selected Goal section row",
            ),
            "UX-SCREEN-GOALS-LIFE-AREA": (
                "Life Area Goal filter sheet", "selected Goal row in that Life Area",
            ),
            "UX-SCREEN-GOALS-PATH": (
                "Goal Path node filter sheet", "selected Path node detail",
            ),
            "UX-SCREEN-GOALS-ROOT": (
                "Goals Root Life Area and Goal filter sheet",
                "typed Goals Root result resolved by stable result kind",
            ),
        }
        for screen_id, destinations in expected_dense.items():
            dense = next(
                item for item in self._variants(screen_id, payload)
                if item["variant_key"] == "dense"
            )
            if dense["behavior_authority_posture"] != "requirement_backed":
                self.assertEqual(dense["allowed_commands"], [])
                self.assertTrue(dense["specification_gap_ids"])
                continue
            for destination in destinations:
                self.assertIn(destination, dense["transition_exit"])
            self.assertNotIn("owner-specific", dense["transition_exit"].casefold())
            self.assertNotIn("selected object", dense["transition_exit"].casefold())

        expected_time_presentations = {
            "conflict-review": "protected-conflict review sheet",
            "editing": "native time-object edit form",
            "saved": "saved-change receipt sheet",
            "undo-eligible": "eligible correction receipt sheet",
            "undo-unavailable": "unavailable-correction explanation sheet",
            "viewing": "native read-only time-object detail",
        }
        for key, presentation in expected_time_presentations.items():
            state = next(
                item for item in self._variants("UX-SCREEN-TIME-DETAIL", payload)
                if item["variant_key"] == key
            )
            self.assertIn(presentation, state["visible_presentation"])
            self.assertNotIn(" or ", state["visible_presentation"].casefold())

        ambiguous = copy.deepcopy(payload)
        state = next(
            item
            for item in self._variants("UX-SCREEN-TIME-DETAIL", ambiguous)
            if item["variant_key"] == "viewing"
        )
        state["visible_presentation"] = (
            "Time Detail uses compact native detail or full destination when depth requires."
        )
        with self.assertRaisesRegex(
            module.UXBlueprintError, "formulaic state variant narrative"
        ):
            module.validate_ux_blueprint(REPO_ROOT, ambiguous)

        vague = copy.deepcopy(payload)
        dense = next(
            item
            for item in self._variants("UX-SCREEN-GOALS-DETAIL", vague)
            if item["variant_key"] == "dense"
        )
        dense["transition_exit"] = (
            "Continue follows the declared owner for selected Goal; Close preserves "
            "or restores the invoking object without silently committing another command."
        )
        with self.assertRaisesRegex(
            module.UXBlueprintError, "formulaic state variant narrative"
        ):
            module.validate_ux_blueprint(REPO_ROOT, vague)

    def test_undo_unavailable_states_preserve_exact_authority_posture(self):
        payload = self._payload()
        module = self._module()
        eligible_ids = module.authority_eligible_state_variant_ids(payload, REPO_ROOT)
        for screen_id, key in (
            ("UX-SCREEN-CAPTURE-COMPOSER", "saved-undo-unavailable"),
            ("UX-SCREEN-SEARCH-RESULTS", "action-complete-undo-unavailable"),
            ("UX-SCREEN-TRUST-RECEIPT", "receipt-committed-undo-unavailable"),
        ):
            variant = next(item for item in self._variants(screen_id, payload) if item["variant_key"] == key)
            self.assertEqual(
                variant["behavior_authority_posture"], "requirement_backed"
            )
            self.assertTrue(variant["allowed_commands"])
            self.assertTrue(variant["behavior_authority_evidence"])
            self.assertEqual(variant["specification_gap_ids"], [])
            self.assertIn(variant["blueprint_id"], eligible_ids)
            if screen_id == "UX-SCREEN-SEARCH-RESULTS":
                self.assertEqual(variant["allowed_commands"], ["Inspect History"])
            self.assertNotIn("invoking context", variant["transition_exit"].casefold())

    def test_requirement_anchors_are_complete_semantic_normative_sentences(self):
        module = self._module()
        records = {
            item["requirement_id"]: item
            for item in module.load_requirement_source_records(REPO_ROOT)
        }
        expected = {
            "SPEC-SURFACE-YOU-SETTINGS-DRILLDOWN-001":
                "Major settings areas MUST open as focused full-screen native drilldowns with low-scroll, scoped content.",
            "SPEC-SURFACE-TIME-VIEWS-001":
                "Time view-family behavior MUST be owned by the separate switching, Day, Week, Month, Year, List, Today-control, and reduced-effects contracts and MUST preserve their independent verification boundaries.",
            "SPEC-SURFACE-TIME-YEAR-001":
                "Year MUST remain a high-level navigational overview of monthly density, protected seasons, Goal movement, recovery, Proof, and conflict pressure, revealing granular objects only after drilldown.",
        }
        for requirement_id, sentence in expected.items():
            self.assertEqual(records[requirement_id]["consequence_anchor"], sentence)

        payload = self._payload()
        fragment = copy.deepcopy(payload)
        disposition = next(
            item for item in fragment["requirement_dispositions"]
            if item["requirement_id"] == "SPEC-SURFACE-TIME-YEAR-001"
        )
        disposition["rationale"] = disposition["rationale"].replace(
            expected["SPEC-SURFACE-TIME-YEAR-001"],
            "Year MUST remain a high-level navigational overview of monthly density, protected seasons",
        )
        with self.assertRaisesRegex(module.UXBlueprintError, "omits its specific consequence"):
            module.validate_ux_blueprint(REPO_ROOT, fragment)


if __name__ == "__main__":
    unittest.main()
