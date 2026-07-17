from __future__ import annotations

import copy
import hashlib
import json
import unittest
from dataclasses import replace
from pathlib import Path

from tools.ambitions_canon import migration, ux_blueprint
from tools.ambitions_canon.manifest import load_documents, load_manifest
from tools.ambitions_canon.registry import build_registry
from tools.ambitions_canon.supersession import load_supersession_ledger
from tools.ambitions_canon.ux_blueprint import (
    UXBlueprintError,
    _validate_unlinked_gate_requirement_ids,
    _validate_search_find_ask_act_inspect_mapping,
    load_state_command_contracts,
)


ROOT = Path(__file__).resolve().parents[2]
SEMANTIC_LEDGER = ROOT / "docs/canon/migration/semantic-equivalence-sets.json"
SUPERSESSION_LEDGER = ROOT / "docs/canon/decisions/SUPERSESSION_LEDGER.toml"
UX_BLUEPRINT = ROOT / "docs/canon/migration/ux-blueprint.json"
UX_DISPOSITIONS = (
    ROOT / "docs/canon/migration/ux-blueprint-requirement-dispositions.json"
)
VISUAL_REBASELINE = (
    ROOT / "docs/canon/migration/visual-authority-rebaseline.json"
)
CLAIM_DISPOSITIONS = ROOT / "docs/canon/migration/claim-dispositions.json"
GENERATED_JSON_ROOT = ROOT / "docs/canon/generated"
SEARCH_JOURNEY = (
    ROOT / "docs/canon/specifications/journeys/search-find-ask-act-inspect.md"
)

ASK_GAP_STATE_IDS = {
    "UX-STATE-VARIANT-SEARCH-RESULTS-ASK-FAILED",
    "UX-STATE-VARIANT-SEARCH-RESULTS-ASK-INTERRUPTED",
    "UX-STATE-VARIANT-SEARCH-RESULTS-ASK-RECOVERED",
    "UX-STATE-VARIANT-SEARCH-RESULTS-ASK-RESUMED",
    "UX-STATE-VARIANT-SEARCH-RESULTS-ASK-UNAVAILABLE-OFFLINE-FALLBACK",
    "UX-STATE-VARIANT-SEARCH-RESULTS-CAPTURE-HANDOFF",
    "UX-STATE-VARIANT-SEARCH-RESULTS-GROUNDED-ANSWER",
    "UX-STATE-VARIANT-SEARCH-RESULTS-SYNTHESIS-IN-PROGRESS",
}
ASK_GAP_COMMAND_IDS = {
    state_id: state_id.replace("UX-STATE-VARIANT-", "CMD-") + "-001"
    for state_id in ASK_GAP_STATE_IDS
}
SEARCH_STATE_REQUIREMENT_MATRIX = {
    "UX-STATE-VARIANT-SEARCH-RESULTS-ASK-FAILED": {
        "LAW-SEARCH-PRIVATE-COMMAND-LAYER-001",
        "SPEC-GLOBAL-SEARCH-ASK-001",
        "SPEC-GLOBAL-SEARCH-ASK-COMMAND-CONTRACT-001",
        "SPEC-GLOBAL-SEARCH-PRESENTATION-001",
        "SPEC-GLOBAL-SEARCH-PRIVATE-COMMAND-LAYER-001",
    },
    "UX-STATE-VARIANT-SEARCH-RESULTS-ASK-INTERRUPTED": {
        "JOURNEY-SEARCH-FIND-ASK-ACT-INSPECT-001",
        "SPEC-GLOBAL-SEARCH-ASK-001",
        "SPEC-GLOBAL-SEARCH-ASK-COMMAND-CONTRACT-001",
        "SPEC-GLOBAL-SEARCH-INPUT-001",
    },
    "UX-STATE-VARIANT-SEARCH-RESULTS-ASK-RECOVERED": {
        "SPEC-GLOBAL-SEARCH-ANSWER-EVIDENCE-001",
        "SPEC-GLOBAL-SEARCH-ASK-001",
        "SPEC-GLOBAL-SEARCH-ASK-COMMAND-CONTRACT-001",
        "SPEC-GLOBAL-SEARCH-INSPECT-001",
        "SPEC-GLOBAL-SEARCH-PRESENTATION-001",
    },
    "UX-STATE-VARIANT-SEARCH-RESULTS-ASK-RESUMED": {
        "SPEC-GLOBAL-SEARCH-ASK-001",
        "SPEC-GLOBAL-SEARCH-ASK-COMMAND-CONTRACT-001",
        "SPEC-GLOBAL-SEARCH-INPUT-001",
    },
    "UX-STATE-VARIANT-SEARCH-RESULTS-ASK-UNAVAILABLE-OFFLINE-FALLBACK": {
        "JOURNEY-SEARCH-FIND-ASK-ACT-INSPECT-001",
        "LAW-SEARCH-PRIVATE-COMMAND-LAYER-001",
        "SPEC-GLOBAL-SEARCH-ASK-001",
        "SPEC-GLOBAL-SEARCH-ASK-COMMAND-CONTRACT-001",
        "SPEC-GLOBAL-SEARCH-FIND-001",
        "SPEC-GLOBAL-SEARCH-PRIVATE-COMMAND-LAYER-001",
    },
    "UX-STATE-VARIANT-SEARCH-RESULTS-CAPTURE-HANDOFF": {
        "JOURNEY-SEARCH-FIND-ASK-ACT-INSPECT-001",
        "SPEC-GLOBAL-SEARCH-ASK-COMMAND-CONTRACT-001",
        "SPEC-GLOBAL-SEARCH-CAPTURE-HANDOFF-001",
        "SPEC-GLOBAL-SEARCH-INPUT-001",
    },
    "UX-STATE-VARIANT-SEARCH-RESULTS-GROUNDED-ANSWER": {
        "JOURNEY-SEARCH-FIND-ASK-ACT-INSPECT-001",
        "LAW-SEARCH-PRIVATE-COMMAND-LAYER-001",
        "SPEC-GLOBAL-SEARCH-ANSWER-EVIDENCE-001",
        "SPEC-GLOBAL-SEARCH-ASK-001",
        "SPEC-GLOBAL-SEARCH-ASK-COMMAND-CONTRACT-001",
        "SPEC-GLOBAL-SEARCH-INPUT-001",
        "SPEC-GLOBAL-SEARCH-INSPECT-001",
        "SPEC-GLOBAL-SEARCH-PRESENTATION-001",
        "SPEC-GLOBAL-SEARCH-PRIVATE-COMMAND-LAYER-001",
    },
    "UX-STATE-VARIANT-SEARCH-RESULTS-SYNTHESIS-IN-PROGRESS": {
        "SPEC-GLOBAL-SEARCH-ASK-001",
        "SPEC-GLOBAL-SEARCH-ASK-COMMAND-CONTRACT-001",
        "SPEC-GLOBAL-SEARCH-FIND-001",
        "SPEC-GLOBAL-SEARCH-INPUT-001",
        "SPEC-GLOBAL-SEARCH-PRESENTATION-001",
    },
}
SEARCH_REQUIREMENT_STATE_SETS = {
    requirement_id: {
        state_id
        for state_id, requirement_ids in SEARCH_STATE_REQUIREMENT_MATRIX.items()
        if requirement_id in requirement_ids
    }
    for requirement_id in {
        requirement_id
        for requirement_ids in SEARCH_STATE_REQUIREMENT_MATRIX.values()
        for requirement_id in requirement_ids
    }
}
MATERIALIZED_SEARCH_CLAIM_TARGETS = {
    "CLAIM-IA-SHELL-SURFACES-0015": (
        "SPEC-GLOBAL-SEARCH-PRIVATE-COMMAND-LAYER-001",
        "Owner-approved Search amendment retargets the composed Search identity "
        "claim to SPEC-GLOBAL-SEARCH-PRIVATE-COMMAND-LAYER-001 and retires "
        "SPEC-GLOBAL-SEARCH-IDENTITY-001.",
    ),
    "CLAIM-IA-SHELL-SURFACES-0059": (
        "SPEC-GLOBAL-SEARCH-PRIVATE-COMMAND-LAYER-001",
        "Owner-approved Search amendment retargets the local-first Search identity "
        "claim to SPEC-GLOBAL-SEARCH-PRIVATE-COMMAND-LAYER-001 and retires "
        "SPEC-GLOBAL-SEARCH-IDENTITY-001.",
    ),
    "CLAIM-IA-SHELL-SURFACES-0064": (
        "SPEC-GLOBAL-SEARCH-PRESENTATION-001",
        "Owner-approved Search amendment retargets the anti-chatbot Search claim "
        "to SPEC-GLOBAL-SEARCH-PRESENTATION-001 and retires "
        "SPEC-GLOBAL-SEARCH-IDENTITY-001.",
    ),
}


class SearchFindAskActInspectAmendmentTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        manifest = load_manifest(ROOT)
        cls.registry = build_registry(manifest, load_documents(ROOT, manifest))
        cls.requirements = {
            requirement.requirement_id: requirement
            for requirement in cls.registry.requirements
        }

    def requirement(self, requirement_id: str):
        self.assertIn(requirement_id, self.requirements)
        return self.requirements[requirement_id]

    def test_constitution_and_nonroot_law_own_unified_private_command_layer(self):
        law = self.requirement("LAW-SEARCH-PRIVATE-COMMAND-LAYER-001")
        self.assertEqual(law.modality.value, "MUST")
        for phrase in (
            "one unified, local-first Find / Ask / Act / Inspect surface",
            "fully useful without Ask",
            "MUST NOT become a generic AI destination",
            "MUST NOT transfer the private life graph",
        ):
            self.assertIn(phrase, law.body)
        self.assertIn(
            "Find / Ask / Act / Inspect",
            self.requirement("LAW-IA-NONROOT-001").body,
        )

    def test_find_is_immediate_deterministic_offline_and_privacy_authorized(self):
        find = self.requirement("SPEC-GLOBAL-SEARCH-FIND-001")
        self.assertEqual(find.modality.value, "MUST")
        for phrase in (
            "immediate",
            "deterministic",
            "offline",
            "privacy-authorized local objects and projections",
            "while the user types",
        ):
            self.assertIn(phrase, find.body)

    def test_ask_is_on_device_grounded_inspectable_and_optional(self):
        ask = self.requirement("SPEC-GLOBAL-SEARCH-ASK-001")
        self.assertEqual(ask.modality.value, "MAY")
        for phrase in (
            "on-device synthesis",
            "privacy-authorized Ambitions data",
            "approved reference sources",
            "supporting objects",
            "sources",
            "assumptions",
            "uncertainty",
            "conversational intelligence is unavailable",
        ):
            self.assertIn(phrase, ask.body)

    def test_act_only_proposes_and_material_actions_remain_owner_commands(self):
        act = self.requirement("SPEC-GLOBAL-SEARCH-ACTIONS-001")
        for phrase in (
            "MUST only propose actions",
            "MUST NOT silently mutate canonical state",
            "MUST NOT own a generic mutation path",
            "current-state validation",
            "visible consequence preview",
            "explicit confirmation",
            "History, Receipt, and Undo",
        ):
            self.assertIn(phrase, act.body)

    def test_inspect_preserves_relevant_context_and_trust_distinctions(self):
        inspect = self.requirement("SPEC-GLOBAL-SEARCH-INSPECT-001")
        for phrase in (
            "Source",
            "Privacy",
            "History",
            "Proof",
            "Receipts",
            "without leaving the relevant context unnecessarily",
        ):
            self.assertIn(phrase, inspect.body)

    def test_creation_intent_hands_off_to_capture_without_parallel_composition(self):
        handoff = self.requirement("SPEC-GLOBAL-SEARCH-CAPTURE-HANDOFF-001")
        for phrase in (
            "Creation intent MUST hand off seamlessly to Capture",
            "MUST NOT duplicate Capture's creation policy",
            "MUST NOT become a parallel composer",
        ):
            self.assertIn(phrase, handoff.body)
        capture = self.requirement("SPEC-GLOBAL-CAPTURE-IDENTITY-001")
        self.assertIn("Search creation-intent handoff", capture.body)
        self.assertIn("Capture alone MUST own composition", capture.body)

    def test_session_history_is_ephemeral_until_explicit_owner_routing(self):
        session = self.requirement("SPEC-GLOBAL-SEARCH-SESSION-HISTORY-001")
        for phrase in (
            "session-local by default",
            "explicit user action",
            "identified canonical owner",
            "question, answer, proposal, or derived object",
        ):
            self.assertIn(phrase, session.body)

    def test_input_answer_evidence_and_presentation_keep_states_distinguishable(self):
        input_law = self.requirement("SPEC-GLOBAL-SEARCH-INPUT-001")
        for phrase in (
            "same input",
            "exact search",
            "natural-language questions",
            "action intent",
            "progressively enhance",
            "inline Ambitions objects, evidence, and action proposals",
            "MUST NOT become an endless transcript",
        ):
            self.assertIn(phrase, input_law.body)

        evidence = self.requirement("SPEC-GLOBAL-SEARCH-ANSWER-EVIDENCE-001")
        for phrase in (
            "retrieved fact",
            "inferred interpretation",
            "proposed change",
            "non-color",
            "VoiceOver",
        ):
            self.assertIn(phrase, evidence.body)

        presentation = self.requirement("SPEC-GLOBAL-SEARCH-PRESENTATION-001")
        for phrase in (
            "generic AI chatbot",
            "chatbot bubble stream",
            "branded AI destination",
            "object-led",
            "source-linked",
            "calm",
            "concise",
            "native to iPhone",
        ):
            self.assertIn(phrase, presentation.body)

    def test_offline_fallback_and_private_egress_prohibitions_are_explicit(self):
        self.assertNotIn("SPEC-GLOBAL-SEARCH-IDENTITY-001", self.requirements)
        identity = self.requirement("SPEC-GLOBAL-SEARCH-PRIVATE-COMMAND-LAYER-001")
        for phrase in (
            "Find / Ask / Act / Inspect",
            "offline degradation",
            "deterministic Find / Act / Inspect",
            "MUST NOT use hosted AI",
            "MUST NOT perform cloud profiling",
            "MUST NOT transfer the private life graph",
        ):
            self.assertIn(phrase, identity.body)

    def test_incompatible_no_chatbot_claims_are_atomized_and_fail_closed(self):
        ledger = json.loads(SEMANTIC_LEDGER.read_text(encoding="utf-8"))
        by_claim = {item["claim_id"]: item for item in ledger["source_claims"]}

        decision_163 = by_claim["CLAIM-LFT-0163"]["clauses"]
        self.assertEqual(len(decision_163), 7)
        self.assertEqual(
            [
                (item["ordinal"], item["requirement_id"], item["relationship"])
                for item in decision_163[-3:]
            ],
            [
                (5, "SPEC-GLOBAL-SEARCH-PRIVATE-COMMAND-LAYER-001", "owner_supersession"),
                (6, "SPEC-GLOBAL-SEARCH-PRESENTATION-001", "owner_supersession"),
                (7, "SPEC-GLOBAL-SEARCH-CAPTURE-HANDOFF-001", "composition"),
            ],
        )
        self.assertEqual(
            (
                by_claim["CLAIM-LFT-0182"]["clauses"][-1]["requirement_id"],
                by_claim["CLAIM-LFT-0182"]["clauses"][-1]["relationship"],
            ),
            ("SPEC-GLOBAL-SEARCH-PRESENTATION-001", "owner_supersession"),
        )
        self.assertEqual(
            (
                by_claim["CLAIM-STB-0306"]["clauses"][0]["requirement_id"],
                by_claim["CLAIM-STB-0306"]["clauses"][0]["relationship"],
            ),
            ("SPEC-GLOBAL-SEARCH-PRIVATE-COMMAND-LAYER-001", "owner_supersession"),
        )
        self.assertEqual(ledger["review_status"], "candidate")
        self.assertIsNone(ledger["independent_review"])

    def test_owner_decision_is_durable_without_reusing_active_ids(self):
        ledger = load_supersession_ledger(SUPERSESSION_LEDGER)
        entry = next(
            item
            for item in ledger.entries
            if item.conflict_id == "CONFLICT-SEARCH-FIND-ASK-ACT-INSPECT"
        )
        self.assertEqual(entry.resolution, "reject_both")
        self.assertEqual(
            entry.resulting_id,
            "SPEC-GLOBAL-SEARCH-PRIVATE-COMMAND-LAYER-001",
        )
        self.assertEqual(
            entry.old_ids,
            (
                "CLAIM-LFT-0163",
                "CLAIM-LFT-0182",
                "CLAIM-STB-0306",
                "SPEC-GLOBAL-SEARCH-IDENTITY-001",
            ),
        )
        self.assertIn("Owner decision", entry.decision_source)
        self.assertIn("stronger third law", entry.decision_source)
        self.assertNotIn(entry.resulting_id, entry.old_ids)

    def test_new_ask_journey_composes_with_unchanged_deterministic_fallback(self):
        fallback = self.requirement("JOURNEY-SEARCH-FIND-ACT-INSPECT-001")
        self.assertIn("Search MUST resolve local canonical identities", fallback.body)
        self.assertNotIn("optional grounded Ask", fallback.body)

        journey = self.requirement("JOURNEY-SEARCH-FIND-ASK-ACT-INSPECT-001")
        for phrase in (
            "immediate deterministic Find",
            "optional grounded Ask",
            "session-local",
            "Capture",
            "retrieved fact",
            "inferred interpretation",
            "proposed change",
            "deterministic Find / Act / Inspect fallback",
        ):
            self.assertIn(phrase, journey.body)

    def test_visible_ask_obligations_require_exact_visual_state_mappings(self):
        payload = json.loads(UX_DISPOSITIONS.read_text(encoding="utf-8"))
        dispositions = {
            item["requirement_id"]: item for item in payload["dispositions"]
        }
        visible_requirements = {
            "JOURNEY-SEARCH-FIND-ASK-ACT-INSPECT-001",
            "LAW-SEARCH-PRIVATE-COMMAND-LAYER-001",
            "SPEC-GLOBAL-SEARCH-ANSWER-EVIDENCE-001",
            "SPEC-GLOBAL-SEARCH-ASK-001",
            "SPEC-GLOBAL-SEARCH-ASK-COMMAND-CONTRACT-001",
            "SPEC-GLOBAL-SEARCH-CAPTURE-HANDOFF-001",
            "SPEC-GLOBAL-SEARCH-FIND-001",
            "SPEC-GLOBAL-SEARCH-INPUT-001",
            "SPEC-GLOBAL-SEARCH-INSPECT-001",
            "SPEC-GLOBAL-SEARCH-PRESENTATION-001",
            "SPEC-GLOBAL-SEARCH-PRIVATE-COMMAND-LAYER-001",
        }
        for requirement_id in visible_requirements:
            with self.subTest(requirement_id=requirement_id):
                record = dispositions[requirement_id]
                self.assertEqual(record["disposition"], "visual_mapping_required")
                self.assertTrue(
                    ASK_GAP_STATE_IDS.intersection(record["state_blueprint_ids"])
                )

        session = dispositions["SPEC-GLOBAL-SEARCH-SESSION-HISTORY-001"]
        self.assertEqual(session["disposition"], "nonvisual_with_rationale")
        self.assertEqual(session["blueprint_ids"], [])
        self.assertEqual(session["state_blueprint_ids"], [])

    def test_search_results_has_minimum_complete_ask_state_contract(self):
        blueprint = json.loads(UX_BLUEPRINT.read_text(encoding="utf-8"))
        model = next(
            item
            for item in blueprint["state_models"]
            if item["blueprint_id"] == "UX-STATE-MODEL-SEARCH-RESULTS"
        )
        states = {item["blueprint_id"]: item for item in model["variants"]}
        self.assertTrue(ASK_GAP_STATE_IDS.issubset(states))
        expected_kinds = {
            "UX-STATE-VARIANT-SEARCH-RESULTS-ASK-FAILED": "failure",
            "UX-STATE-VARIANT-SEARCH-RESULTS-ASK-INTERRUPTED": "interruption",
            "UX-STATE-VARIANT-SEARCH-RESULTS-ASK-RECOVERED": "recovery",
            "UX-STATE-VARIANT-SEARCH-RESULTS-ASK-RESUMED": "recovery",
            "UX-STATE-VARIANT-SEARCH-RESULTS-ASK-UNAVAILABLE-OFFLINE-FALLBACK": "degraded",
            "UX-STATE-VARIANT-SEARCH-RESULTS-CAPTURE-HANDOFF": "transitional",
            "UX-STATE-VARIANT-SEARCH-RESULTS-GROUNDED-ANSWER": "resting",
            "UX-STATE-VARIANT-SEARCH-RESULTS-SYNTHESIS-IN-PROGRESS": "loading",
        }
        self.assertEqual(
            {state_id: states[state_id]["generic_kind"] for state_id in expected_kinds},
            expected_kinds,
        )
        for state_id in ASK_GAP_STATE_IDS:
            with self.subTest(state_id=state_id):
                self.assertEqual(states[state_id]["specification_gap_ids"], [])
                self.assertEqual(
                    states[state_id]["behavior_authority_posture"],
                    "requirement_backed",
                )

    def test_new_ask_states_are_visual_gap_blocked_without_figma_claims(self):
        visual = json.loads(VISUAL_REBASELINE.read_text(encoding="utf-8"))
        posture = visual["state_posture"]
        self.assertEqual(set(posture["gap_blocked_state_ids"]), ASK_GAP_STATE_IDS)
        self.assertFalse(ASK_GAP_STATE_IDS.intersection(posture["eligible_state_ids"]))
        self.assertFalse(ASK_GAP_STATE_IDS.intersection(posture["future_state_ids"]))
        mapped_states = {
            state_id
            for node in visual["figma"]["authority_nodes"]
            for mapping in node.get("screen_mappings", [])
            for state_id in mapping["state_variant_ids"]
        }
        self.assertFalse(ASK_GAP_STATE_IDS.intersection(mapped_states))
        mapped_requirements = {
            requirement_id
            for node in visual["figma"]["authority_nodes"]
            for requirement_id in node["requirement_ids"]
        }
        self.assertFalse(
            {
                "JOURNEY-SEARCH-FIND-ASK-ACT-INSPECT-001",
                "LAW-SEARCH-PRIVATE-COMMAND-LAYER-001",
                "SPEC-GLOBAL-SEARCH-ANSWER-EVIDENCE-001",
                "SPEC-GLOBAL-SEARCH-ASK-001",
                "SPEC-GLOBAL-SEARCH-ASK-COMMAND-CONTRACT-001",
                "SPEC-GLOBAL-SEARCH-CAPTURE-HANDOFF-001",
                "SPEC-GLOBAL-SEARCH-FIND-001",
                "SPEC-GLOBAL-SEARCH-INPUT-001",
                "SPEC-GLOBAL-SEARCH-INSPECT-001",
                "SPEC-GLOBAL-SEARCH-PRESENTATION-001",
                "SPEC-GLOBAL-SEARCH-PRIVATE-COMMAND-LAYER-001",
            }.intersection(mapped_requirements)
        )

    def test_ask_commands_do_not_expand_the_existing_find_act_inspect_owner(self):
        existing = self.requirement("SPEC-GLOBAL-SEARCH-COMMAND-CONTRACT-001")
        self.assertIn("Find, Act, and Inspect overlay", existing.body)
        for ask_control in ("Retry Ask", "Resume Ask", "Cancel Ask", "Open Capture"):
            self.assertNotIn(ask_control, existing.body)

        ask = self.requirement("SPEC-GLOBAL-SEARCH-ASK-COMMAND-CONTRACT-001")
        self.assertEqual(ask.modality.value, "MUST")
        for ask_control in ("Retry Ask", "Resume Ask", "Cancel Ask", "Open Capture"):
            self.assertIn(ask_control, ask.body)
        for inspect_target in ("Source", "Privacy", "History", "Proof", "Receipts"):
            self.assertIn(inspect_target, ask.body)

    def test_deterministic_blueprint_validator_owns_the_new_search_mapping(self):
        blueprint = json.loads(UX_BLUEPRINT.read_text(encoding="utf-8"))
        _validate_search_find_ask_act_inspect_mapping(blueprint)

        broken = copy.deepcopy(blueprint)
        model = next(
            item
            for item in broken["state_models"]
            if item["blueprint_id"] == "UX-STATE-MODEL-SEARCH-RESULTS"
        )
        for state in model["variants"]:
            if state["blueprint_id"] in ASK_GAP_STATE_IDS:
                state["requirement_ids"] = [
                    item
                    for item in state["requirement_ids"]
                    if item != "SPEC-GLOBAL-SEARCH-ASK-001"
                ]
                state["behavior_requirement_ids"] = [
                    item
                    for item in state["behavior_requirement_ids"]
                    if item != "SPEC-GLOBAL-SEARCH-ASK-001"
                ]
        with self.assertRaisesRegex(
            UXBlueprintError,
            "Search Find / Ask / Act / Inspect visual requirement mapping is stale",
        ):
            _validate_search_find_ask_act_inspect_mapping(broken)

    def test_ask_commands_are_future_gated_without_weakening_deterministic_search(self):
        gate_id = "SPEC-GLOBAL-SEARCH-ASK-ACTIVATION-GATE-001"
        gate = self.requirement(gate_id)
        for phrase in (
            "MUST remain future-gated",
            "closed, base-owned evidence registry and verifier",
            "already merged",
            "nonempty exact command dependency bindings",
            "current source and runtime proof",
            "no-egress and privacy proof",
            "grounding and deterministic-fallback proof",
            "accessibility and visual proof",
            "performance proof",
            "same canon revision and source revision",
            "explicitly approved the exact final Figma frame IDs",
        ):
            self.assertIn(phrase, gate.body)

        contracts = load_state_command_contracts(ROOT)
        ask_contracts = tuple(
            item for item in contracts if item.state_id in ASK_GAP_STATE_IDS
        )
        self.assertEqual(len(ask_contracts), len(ASK_GAP_STATE_IDS))
        for contract in ask_contracts:
            with self.subTest(state_id=contract.state_id):
                self.assertEqual(contract.activation_posture.value, "future_gated")
                self.assertEqual(contract.gate_requirement_ids, (gate_id,))
                for command in contract.commands:
                    self.assertEqual(command.activation_posture.value, "future_gated")
                    self.assertEqual(command.gate_requirement_ids, (gate_id,))

        deterministic = tuple(
            item
            for item in contracts
            if item.requirement_id == "SPEC-GLOBAL-SEARCH-COMMAND-CONTRACT-001"
        )
        self.assertEqual(len(deterministic), 24)
        self.assertTrue(
            all(item.activation_posture.value == "active" for item in deterministic)
        )

        dispositions = {
            item["requirement_id"]: item
            for item in json.loads(UX_DISPOSITIONS.read_text(encoding="utf-8"))[
                "dispositions"
            ]
        }
        self.assertEqual(
            dispositions[gate_id]["disposition"],
            "nonvisual_with_rationale",
        )
        self.assertEqual(dispositions[gate_id]["blueprint_ids"], [])
        self.assertEqual(dispositions[gate_id]["state_blueprint_ids"], [])

    def test_search_ask_contract_validator_rejects_every_fail_open_mutation(self):
        validator = getattr(
            ux_blueprint,
            "_validate_search_ask_command_contracts",
            None,
        )
        self.assertIsNotNone(
            validator,
            "production Search Ask command-contract validator is missing",
        )
        contracts = load_state_command_contracts(ROOT)
        validator(contracts)
        by_state = {
            item.state_id: item
            for item in contracts
            if item.state_id in ASK_GAP_STATE_IDS
        }
        sample_state_id = sorted(ASK_GAP_STATE_IDS)[0]
        sample = by_state[sample_state_id]
        sample_command = sample.commands[0]
        gate_id = "SPEC-GLOBAL-SEARCH-ASK-ACTIVATION-GATE-001"

        mutations = {
            "missing state": tuple(
                item for item in contracts if item.state_id != sample_state_id
            ),
            "changed state posture": tuple(
                replace(
                    item,
                    activation_posture=ux_blueprint.StateCommandActivationPosture.ACTIVE,
                )
                if item.state_id == sample_state_id
                else item
                for item in contracts
            ),
            "removed state gate": tuple(
                replace(item, gate_requirement_ids=())
                if item.state_id == sample_state_id
                else item
                for item in contracts
            ),
            "changed state gate": tuple(
                replace(item, gate_requirement_ids=(gate_id + "-CHANGED",))
                if item.state_id == sample_state_id
                else item
                for item in contracts
            ),
            "missing command": tuple(
                replace(item, commands=())
                if item.state_id == sample_state_id
                else item
                for item in contracts
            ),
            "changed command identity": tuple(
                replace(
                    item,
                    commands=(
                        replace(
                            sample_command,
                            command_id=ASK_GAP_COMMAND_IDS[sample_state_id] + "-CHANGED",
                        ),
                    ),
                )
                if item.state_id == sample_state_id
                else item
                for item in contracts
            ),
            "wrong command owner": tuple(
                replace(
                    item,
                    commands=(replace(sample_command, canonical_owner="global.search"),),
                )
                if item.state_id == sample_state_id
                else item
                for item in contracts
            ),
            "changed command posture": tuple(
                replace(
                    item,
                    commands=(
                        replace(
                            sample_command,
                            activation_posture=ux_blueprint.StateCommandActivationPosture.ACTIVE,
                        ),
                    ),
                )
                if item.state_id == sample_state_id
                else item
                for item in contracts
            ),
            "removed command gate": tuple(
                replace(
                    item,
                    commands=(replace(sample_command, gate_requirement_ids=()),),
                )
                if item.state_id == sample_state_id
                else item
                for item in contracts
            ),
            "changed command gate": tuple(
                replace(
                    item,
                    commands=(
                        replace(
                            sample_command,
                            gate_requirement_ids=(gate_id + "-CHANGED",),
                        ),
                    ),
                )
                if item.state_id == sample_state_id
                else item
                for item in contracts
            ),
        }
        for label, mutated in mutations.items():
            with self.subTest(label=label):
                with self.assertRaisesRegex(
                    UXBlueprintError,
                    "Search Ask command contract is stale or authorizing",
                ):
                    validator(mutated)

    def test_search_visual_matrix_is_closed_per_state_and_per_requirement(self):
        blueprint = json.loads(UX_BLUEPRINT.read_text(encoding="utf-8"))
        _validate_search_find_ask_act_inspect_mapping(blueprint)

        for state_id, requirement_ids in SEARCH_STATE_REQUIREMENT_MATRIX.items():
            for requirement_id in requirement_ids:
                with self.subTest(
                    mutation="remove state-local mapping",
                    state_id=state_id,
                    requirement_id=requirement_id,
                ):
                    broken = copy.deepcopy(blueprint)
                    model = next(
                        item
                        for item in broken["state_models"]
                        if item["blueprint_id"] == "UX-STATE-MODEL-SEARCH-RESULTS"
                    )
                    state = next(
                        item
                        for item in model["variants"]
                        if item["blueprint_id"] == state_id
                    )
                    state["requirement_ids"].remove(requirement_id)
                    with self.assertRaisesRegex(
                        UXBlueprintError,
                        "Search Find / Ask / Act / Inspect state requirement matrix is stale",
                    ):
                        _validate_search_find_ask_act_inspect_mapping(broken)

        swapped = copy.deepcopy(blueprint)
        model = next(
            item
            for item in swapped["state_models"]
            if item["blueprint_id"] == "UX-STATE-MODEL-SEARCH-RESULTS"
        )
        states = {item["blueprint_id"]: item for item in model["variants"]}
        failed = states["UX-STATE-VARIANT-SEARCH-RESULTS-ASK-FAILED"]
        interrupted = states["UX-STATE-VARIANT-SEARCH-RESULTS-ASK-INTERRUPTED"]
        failed["requirement_ids"].remove("SPEC-GLOBAL-SEARCH-PRESENTATION-001")
        failed["requirement_ids"].append("SPEC-GLOBAL-SEARCH-INPUT-001")
        interrupted["requirement_ids"].remove("SPEC-GLOBAL-SEARCH-INPUT-001")
        interrupted["requirement_ids"].append(
            "SPEC-GLOBAL-SEARCH-PRESENTATION-001"
        )
        with self.assertRaisesRegex(
            UXBlueprintError,
            "Search Find / Ask / Act / Inspect state requirement matrix is stale",
        ):
            _validate_search_find_ask_act_inspect_mapping(swapped)

        unexpected = copy.deepcopy(blueprint)
        model = next(
            item
            for item in unexpected["state_models"]
            if item["blueprint_id"] == "UX-STATE-MODEL-SEARCH-RESULTS"
        )
        failed = next(
            item
            for item in model["variants"]
            if item["blueprint_id"]
            == "UX-STATE-VARIANT-SEARCH-RESULTS-ASK-FAILED"
        )
        failed["requirement_ids"].append(
            "SPEC-GLOBAL-SEARCH-CAPTURE-HANDOFF-001"
        )
        with self.assertRaisesRegex(
            UXBlueprintError,
            "Search Find / Ask / Act / Inspect state requirement matrix is stale",
        ):
            _validate_search_find_ask_act_inspect_mapping(unexpected)

        disposition_mutations = []
        for requirement_id, state_ids in SEARCH_REQUIREMENT_STATE_SETS.items():
            removed = copy.deepcopy(blueprint)
            record = next(
                item
                for item in removed["requirement_dispositions"]
                if item["requirement_id"] == requirement_id
            )
            record["state_blueprint_ids"].remove(sorted(state_ids)[0])
            disposition_mutations.append((requirement_id, "removed", removed))
            unexpected_states = ASK_GAP_STATE_IDS - state_ids
            if unexpected_states:
                added = copy.deepcopy(blueprint)
                record = next(
                    item
                    for item in added["requirement_dispositions"]
                    if item["requirement_id"] == requirement_id
                )
                record["state_blueprint_ids"].append(sorted(unexpected_states)[0])
                disposition_mutations.append((requirement_id, "added", added))
        for requirement_id, mutation, broken in disposition_mutations:
            with self.subTest(
                mutation=f"disposition {mutation}",
                requirement_id=requirement_id,
            ):
                with self.assertRaisesRegex(
                    UXBlueprintError,
                    "Search Find / Ask / Act / Inspect disposition state set is stale",
                ):
                    _validate_search_find_ask_act_inspect_mapping(broken)

    def test_checked_in_generated_json_is_one_coherent_canon_snapshot(self):
        snapshots = {}
        for path in sorted(GENERATED_JSON_ROOT.glob("*.json")):
            payload = json.loads(path.read_text(encoding="utf-8"))
            snapshots[path.name] = payload["canon_content_sha"]
        self.assertEqual(
            len(set(snapshots.values())),
            1,
            f"generated JSON mixes canon_content_sha values: {snapshots}",
        )

    def test_materialized_search_claims_target_current_stable_ids(self):
        payload = json.loads(CLAIM_DISPOSITIONS.read_text(encoding="utf-8"))
        claims = {item["claim_id"]: item for item in payload["claims"]}
        for claim_id, (target_id, rationale) in (
            MATERIALIZED_SEARCH_CLAIM_TARGETS.items()
        ):
            with self.subTest(claim_id=claim_id):
                self.assertEqual(claims[claim_id]["target_id"], target_id)
                self.assertEqual(
                    claims[claim_id]["rationale_sha256"],
                    hashlib.sha256(rationale.encode("utf-8")).hexdigest(),
                )

    def test_retired_search_identity_is_rejected_outside_supersession_evidence(self):
        validator = getattr(
            migration,
            "validate_no_retired_search_identity_targets",
            None,
        )
        self.assertIsNotNone(
            validator,
            "production retired Search identity validator is missing",
        )
        payload = json.loads(CLAIM_DISPOSITIONS.read_text(encoding="utf-8"))
        validator(payload["claims"], CLAIM_DISPOSITIONS)
        broken = copy.deepcopy(payload["claims"])
        broken[0]["target_id"] = "SPEC-GLOBAL-SEARCH-IDENTITY-001"
        with self.assertRaisesRegex(
            migration.CanonError,
            "retired Search identity may appear only in explicit supersession evidence",
        ):
            validator(broken, CLAIM_DISPOSITIONS)

    def test_journey_trigger_routes_creation_intent_from_search_to_capture(self):
        journey = SEARCH_JOURNEY.read_text(encoding="utf-8")
        self.assertIn("creation intent detected in Search", journey)
        self.assertNotIn("Capture creation intent", journey)

    def test_unlinked_gate_validation_rejects_unknown_or_visual_requirements(self):
        gate_id = "SPEC-GLOBAL-SEARCH-ASK-ACTIVATION-GATE-001"
        blueprint = json.loads(UX_BLUEPRINT.read_text(encoding="utf-8"))
        known = frozenset(self.requirements)
        _validate_unlinked_gate_requirement_ids(
            blueprint,
            frozenset({gate_id}),
            known,
            "UX-STATE-VARIANT-SEARCH-RESULTS-ASK-FAILED",
        )
        with self.assertRaisesRegex(
            UXBlueprintError,
            "state command contract requirements are not linked",
        ):
            _validate_unlinked_gate_requirement_ids(
                blueprint,
                frozenset({"SPEC-GLOBAL-SEARCH-UNKNOWN-GATE-001"}),
                known,
                "UX-STATE-VARIANT-SEARCH-RESULTS-ASK-FAILED",
            )

        visually_mapped = copy.deepcopy(blueprint)
        disposition = next(
            item
            for item in visually_mapped["requirement_dispositions"]
            if item["requirement_id"] == gate_id
        )
        disposition["disposition"] = "visual_mapping_required"
        disposition["state_blueprint_ids"] = [
            "UX-STATE-VARIANT-SEARCH-RESULTS-ASK-FAILED"
        ]
        with self.assertRaisesRegex(
            UXBlueprintError,
            "state command contract requirements are not linked",
        ):
            _validate_unlinked_gate_requirement_ids(
                visually_mapped,
                frozenset({gate_id}),
                known,
                "UX-STATE-VARIANT-SEARCH-RESULTS-ASK-FAILED",
            )


if __name__ == "__main__":
    unittest.main()
