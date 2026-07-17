from __future__ import annotations

import copy
import hashlib
import json
import unittest
from dataclasses import replace
from pathlib import Path
from unittest import mock

from tools.ambitions_canon import migration, ux_blueprint, visual_authority
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

ASK_VISUAL_STATE_IDS = {
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
    for state_id in ASK_VISUAL_STATE_IDS
}
SEARCH_VISUAL_NODE_SNAPSHOT = (
    ROOT / "docs/canon/migration/visual-authority-r1-node-snapshot.json"
)
SEARCH_VISUAL_FREEZE_ID = "SEARCH-AUTHORITY-R2-2026-07-17T110150Z"
SEARCH_VISUAL_BINDINGS = {
    "UX-STATE-VARIANT-SEARCH-RESULTS-ASK-FAILED": (
        "375:3063",
        "search-failed-375-3063-r2.png",
        "21c120eb0f8de6ebe88ff2693f962655ea16a740b96e1f0fe56325e0abebfe27",
    ),
    "UX-STATE-VARIANT-SEARCH-RESULTS-ASK-INTERRUPTED": (
        "375:3159",
        "search-interrupted-375-3159-r2.png",
        "315798e0bbeb093fad695efae14a284f0380e46f5c77b98e7a91af430e4c0ade",
    ),
    "UX-STATE-VARIANT-SEARCH-RESULTS-ASK-RECOVERED": (
        "375:3326",
        "search-recovered-375-3326-r2.png",
        "472e13f495c1d46f592a3c2f9283296d1c8f39721b89f338ed05beaddcdb87cf",
    ),
    "UX-STATE-VARIANT-SEARCH-RESULTS-ASK-RESUMED": (
        "375:3245",
        "search-resumed-375-3245-r2.png",
        "ab9788a0828f20aa13e95d13ce01aec7d9632c4a383eaa5cde14a8e7d969ed2c",
    ),
    "UX-STATE-VARIANT-SEARCH-RESULTS-ASK-UNAVAILABLE-OFFLINE-FALLBACK": (
        "375:2972",
        "search-offline-375-2972-r2.png",
        "0133d0914a6ee6fd6c5ab11ff8e5b1ad5ced384788b2019dbbedb1ca45d1c549",
    ),
    "UX-STATE-VARIANT-SEARCH-RESULTS-CAPTURE-HANDOFF": (
        "375:3402",
        "search-capture-375-3402-r2.png",
        "642068d82d43c392fed92a04a4b29902425996beebd88f93c60061950fb23b48",
    ),
    "UX-STATE-VARIANT-SEARCH-RESULTS-GROUNDED-ANSWER": (
        "375:2806",
        "search-grounded-375-2806-r2.png",
        "2c30f3974896a685ce5d1c06fcbeaa42268af4b27575c8e1200f2ee67971ed24",
    ),
    "UX-STATE-VARIANT-SEARCH-RESULTS-SYNTHESIS-IN-PROGRESS": (
        "375:2880",
        "search-progress-375-2880-r2.png",
        "c38a95f1c1aa75aeaea0464e0466b6e65faf3cfad64bac5b22bcb455e66430a2",
    ),
}
SEARCH_VISUAL_CONTROLS = {
    "UX-STATE-VARIANT-SEARCH-RESULTS-ASK-FAILED": "Retry Ask",
    "UX-STATE-VARIANT-SEARCH-RESULTS-ASK-INTERRUPTED": "Resume Ask",
    "UX-STATE-VARIANT-SEARCH-RESULTS-ASK-RECOVERED": "Inspect Source",
    "UX-STATE-VARIANT-SEARCH-RESULTS-ASK-RESUMED": "Cancel Ask",
    "UX-STATE-VARIANT-SEARCH-RESULTS-ASK-UNAVAILABLE-OFFLINE-FALLBACK": (
        "Inspect Privacy"
    ),
    "UX-STATE-VARIANT-SEARCH-RESULTS-CAPTURE-HANDOFF": "Open Capture",
    "UX-STATE-VARIANT-SEARCH-RESULTS-GROUNDED-ANSWER": "Inspect Source",
    "UX-STATE-VARIANT-SEARCH-RESULTS-SYNTHESIS-IN-PROGRESS": "Cancel Ask",
}
SEARCH_SHARED_COMPONENT_NAMES = {
    "Search R2 / Shared / Header",
    "Search R2 / Shared / State Banner",
    "Search R2 / Shared / Deterministic Results",
    "Search R2 / Shared / Evidence Stack",
    "Search R2 / Shared / Owner Action",
    "Search R2 / Shared / Contextual Inspector",
}
SEARCH_APPROVED_FRAME_IDS = (
    "375:2806",
    "375:2880",
    "375:2972",
    "375:3063",
    "375:3159",
    "375:3245",
    "375:3326",
    "375:3402",
)
SEARCH_OWNER_APPROVAL_STATEMENT = (
    "I approve SEARCH-AUTHORITY-R2-2026-07-17T110150Z and frames "
    "375:2806, 375:2880, 375:2972, 375:3063, 375:3159, 375:3245, "
    "375:3326, and 375:3402 as the final Search visual authority."
)
SEARCH_OWNER_APPROVED_AT_UTC = "2026-07-17T11:46:05Z"
SEARCH_TERMINAL_REVIEW_RECEIPT = {
    "critical_count": 0,
    "entry_count": 24,
    "important_count": 0,
    "minor_count": 0,
    "package_path": (
        ".superpowers/sdd/"
        "review-search-visual-authority-r2-295889c9-working-tree.diff"
    ),
    "package_sha256": (
        "8786427a72b6a3cf3d874261ce5c920ef25bfb52bc4ff7c0a76f07adcf9bb80a"
    ),
    "package_size_bytes": 995426,
    "status": "complete_clean",
    "synthetic_tree": "ff43e51eb389865f0aa42fcd8788490f113fccc8",
}
SEARCH_APPROVAL_RECORD_REVIEW_RECEIPT = {
    "authenticated_base_commit": "295889c9f76528d398fce8d54b155d3285705f29",
    "critical_count": 0,
    "entry_count": 24,
    "important_count": 0,
    "live_figma_metadata_verification": (
        "complete_read_only_exact_section_and_eight_frames"
    ),
    "minor_count": 0,
    "package_base_authentication": (
        "complete_exact_sha256_size_tree_entry_count_and_base_apply_check"
    ),
    "package_path": (
        ".superpowers/sdd/"
        "review-search-visual-authority-r2-295889c9-working-tree.diff"
    ),
    "package_sha256": (
        "0771b42183a8e57df60dac3ae28047b5d5708eb211fa02f1eead397ea379f926"
    ),
    "package_size_bytes": 1034935,
    "status": "complete_clean",
    "synthetic_tree": "b1a3445ba4d6f30682d69d2514e6d06acdc34e2e",
}
SEARCH_RENDER_BYTE_LENGTHS = {
    "375:2806": 56362,
    "375:2880": 52894,
    "375:2972": 52496,
    "375:3063": 50924,
    "375:3159": 51983,
    "375:3245": 52916,
    "375:3326": 55954,
    "375:3402": 55773,
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
                    ASK_VISUAL_STATE_IDS.intersection(record["state_blueprint_ids"])
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
        self.assertTrue(ASK_VISUAL_STATE_IDS.issubset(states))
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
        for state_id in ASK_VISUAL_STATE_IDS:
            with self.subTest(state_id=state_id):
                self.assertEqual(states[state_id]["specification_gap_ids"], [])
                self.assertEqual(
                    states[state_id]["behavior_authority_posture"],
                    "requirement_backed",
                )

    def test_new_ask_states_are_future_gated_and_bound_to_exact_figma_frames(self):
        visual = json.loads(VISUAL_REBASELINE.read_text(encoding="utf-8"))
        posture = visual["state_posture"]
        self.assertEqual(posture["gap_blocked_state_ids"], [])
        self.assertFalse(
            ASK_VISUAL_STATE_IDS.intersection(posture["eligible_state_ids"])
        )
        self.assertTrue(
            ASK_VISUAL_STATE_IDS.issubset(posture["future_state_ids"])
        )
        mapped_states = {
            state_id
            for node in visual["figma"]["authority_nodes"]
            for mapping in node.get("screen_mappings", [])
            for state_id in mapping["state_variant_ids"]
        }
        self.assertTrue(ASK_VISUAL_STATE_IDS.issubset(mapped_states))
        mapped_requirements = {
            requirement_id
            for node in visual["figma"]["authority_nodes"]
            for requirement_id in node["requirement_ids"]
        }
        self.assertTrue(
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
            }.issubset(mapped_requirements)
        )
        snapshot = json.loads(
            SEARCH_VISUAL_NODE_SNAPSHOT.read_text(encoding="utf-8")
        )
        addendum = snapshot["search_authority_addendum"]
        self.assertEqual(addendum["freeze_id"], SEARCH_VISUAL_FREEZE_ID)
        self.assertEqual(addendum["section_node_id"], "375:2805")
        self.assertEqual(addendum["owner_approval_state"], "approved")
        self.assertEqual(addendum["independent_review_state"], "terminal_clean")
        self.assertEqual(
            addendum["authority_status"],
            "owner_approved_final_search_visual_authority_shadow_pending_gate_b",
        )
        self.assertEqual(
            addendum["owner_approval"],
            {
                "approval_scope": "final_search_visual_authority_only",
                "approved_at_utc": SEARCH_OWNER_APPROVED_AT_UTC,
                "approved_frame_ids": list(SEARCH_APPROVED_FRAME_IDS),
                "approved_freeze_id": SEARCH_VISUAL_FREEZE_ID,
                "gate_b_state": "red_pending",
                "owner_statement": SEARCH_OWNER_APPROVAL_STATEMENT,
                "post_approval_authority_state": "shadow_non_authoritative",
                "source_authorization": "blocked_until_gate_b_green",
                "task_pack_selection": "blocked_until_gate_b_green",
            },
        )
        self.assertEqual(
            addendum["terminal_independent_review"],
            SEARCH_TERMINAL_REVIEW_RECEIPT,
        )
        self.assertNotIn("next_required_action", addendum["owner_approval"])
        self.assertEqual(
            addendum["approval_record_independent_review"],
            SEARCH_APPROVAL_RECORD_REVIEW_RECEIPT,
        )
        self.assertEqual(
            {
                item["state_id"]: (
                    item["node_id"],
                    Path(item["screenshot_path"]).name,
                    item["screenshot_sha256"],
                )
                for item in addendum["state_frame_bindings"]
            },
            SEARCH_VISUAL_BINDINGS,
        )
        self.assertEqual(
            {
                item["proof_posture"]
                for item in addendum["state_frame_bindings"]
            },
            {"owner_approved_product_only_shadow_pending_gate_b"},
        )
        visual_authority.validate_r1_node_snapshot_payload(
            ROOT,
            visual,
            snapshot,
        )

    def test_search_visual_snapshot_rejects_pending_or_missing_owner_approval(self):
        visual = json.loads(VISUAL_REBASELINE.read_text(encoding="utf-8"))
        snapshot = json.loads(
            SEARCH_VISUAL_NODE_SNAPSHOT.read_text(encoding="utf-8")
        )
        broken = copy.deepcopy(snapshot)
        addendum = broken["search_authority_addendum"]
        addendum["authority_status"] = (
            "candidate_pending_independent_review_and_owner_approval"
        )
        addendum["independent_review_state"] = "pending"
        addendum["owner_approval_state"] = "pending"
        addendum.pop("owner_approval", None)
        addendum.pop("approval_record_independent_review", None)
        addendum.pop("terminal_independent_review", None)
        with self.assertRaisesRegex(
            visual_authority.CanonError,
            "Search authority addendum",
        ):
            visual_authority.validate_r1_node_snapshot_payload(
                ROOT,
                visual,
                broken,
            )

    def test_search_visual_snapshot_rejects_substituted_final_approval(self):
        visual = json.loads(VISUAL_REBASELINE.read_text(encoding="utf-8"))
        snapshot = json.loads(
            SEARCH_VISUAL_NODE_SNAPSHOT.read_text(encoding="utf-8")
        )
        mutations = {
            "substituted_freeze": (
                lambda approval, review, approval_review: approval.__setitem__(
                    "approved_freeze_id", "SEARCH-AUTHORITY-R2-ARBITRARY"
                )
            ),
            "duplicate_and_omitted_frame": (
                lambda approval, review, approval_review: approval[
                    "approved_frame_ids"
                ].__setitem__(-1, approval["approved_frame_ids"][0])
            ),
            "missing_frame": (
                lambda approval, review, approval_review: approval[
                    "approved_frame_ids"
                ].pop()
            ),
            "pending_review": (
                lambda approval, review, approval_review: review.__setitem__(
                    "status", "pending"
                )
            ),
            "transient_next_action": (
                lambda approval, review, approval_review: approval.__setitem__(
                    "next_required_action",
                    "independent_exact_rereview_of_owner_approval_record",
                )
            ),
            "substituted_approval_record_sha": (
                lambda approval, review, approval_review: approval_review.__setitem__(
                    "package_sha256", "0" * 64
                )
            ),
            "pending_approval_record_review": (
                lambda approval, review, approval_review: approval_review.__setitem__(
                    "status", "pending"
                )
            ),
        }
        for label, mutate in mutations.items():
            with self.subTest(label=label):
                broken = copy.deepcopy(snapshot)
                addendum = broken["search_authority_addendum"]
                mutate(
                    addendum["owner_approval"],
                    addendum["terminal_independent_review"],
                    addendum["approval_record_independent_review"],
                )
                with self.assertRaisesRegex(
                    visual_authority.CanonError,
                    "Search authority addendum",
                ):
                    visual_authority.validate_r1_node_snapshot_payload(
                        ROOT,
                        visual,
                        broken,
                    )

    def test_search_visual_snapshot_binds_figma_metadata_readback_receipt(self):
        snapshot = json.loads(
            SEARCH_VISUAL_NODE_SNAPSHOT.read_text(encoding="utf-8")
        )
        receipt = snapshot["search_authority_addendum"]["figma_metadata_receipt"]
        self.assertEqual(receipt["namespace"], "ambitions.canon")
        self.assertEqual(receipt["page_id"], "215:2")
        self.assertEqual(receipt["section_node_id"], "375:2805")
        self.assertEqual(
            receipt["mutated_node_ids"],
            ["375:2805", *SEARCH_APPROVED_FRAME_IDS],
        )
        self.assertTrue(receipt["metadata_only"])
        self.assertTrue(receipt["readback_verified"])
        self.assertFalse(receipt["visible_properties_mutated"])
        self.assertFalse(receipt["shared_components_mutated"])
        self.assertFalse(receipt["legacy_nodes_mutated"])
        self.assertEqual(receipt["created_node_ids"], [])
        self.assertEqual(receipt["deleted_node_ids"], [])
        self.assertEqual(receipt["renamed_node_ids"], [])
        self.assertEqual(
            receipt["render_hash_algorithm"],
            "sha256_pure_js_over_figma_export_async_png_contents_only_scale_1",
        )
        renders = {item["node_id"]: item for item in receipt["render_bindings"]}
        self.assertEqual(set(renders), set(SEARCH_APPROVED_FRAME_IDS))
        expected_sha_by_node = {
            node_id: digest
            for node_id, _, digest in SEARCH_VISUAL_BINDINGS.values()
        }
        for node_id in SEARCH_APPROVED_FRAME_IDS:
            with self.subTest(node_id=node_id):
                render = renders[node_id]
                self.assertEqual(render["before_sha256"], expected_sha_by_node[node_id])
                self.assertEqual(render["after_sha256"], expected_sha_by_node[node_id])
                self.assertEqual(
                    render["snapshot_sha256"], expected_sha_by_node[node_id]
                )
                self.assertEqual(
                    render["byte_length"], SEARCH_RENDER_BYTE_LENGTHS[node_id]
                )
                self.assertTrue(render["byte_identical"])
        self.assertEqual(
            {item["node_id"] for item in receipt["readback_records"]},
            {"375:2805", *SEARCH_APPROVED_FRAME_IDS},
        )
        self.assertTrue(
            all(
                len(item["readback_sha256"]) == 64
                and item["key_count"] > 0
                for item in receipt["readback_records"]
            )
        )

    def test_search_visual_snapshot_rejects_arbitrary_or_unbound_frame_ids(self):
        visual = json.loads(VISUAL_REBASELINE.read_text(encoding="utf-8"))
        snapshot = json.loads(
            SEARCH_VISUAL_NODE_SNAPSHOT.read_text(encoding="utf-8")
        )
        broken = copy.deepcopy(snapshot)
        broken["search_authority_addendum"]["state_frame_bindings"][0][
            "node_id"
        ] = "999:999"
        with self.assertRaisesRegex(
            visual_authority.CanonError,
            "Search authority addendum",
        ):
            visual_authority.validate_r1_node_snapshot_payload(
                ROOT,
                visual,
                broken,
            )

    def test_search_visual_snapshot_rejects_replaced_bound_screenshot_bytes(self):
        visual = json.loads(VISUAL_REBASELINE.read_text(encoding="utf-8"))
        snapshot = json.loads(
            SEARCH_VISUAL_NODE_SNAPSHOT.read_text(encoding="utf-8")
        )
        broken = copy.deepcopy(snapshot)
        binding = broken["search_authority_addendum"]["state_frame_bindings"][0]
        target_path = Path(binding["screenshot_path"])
        replacement_bytes = b"replacement Search R2 screenshot bytes"
        binding["screenshot_sha256"] = hashlib.sha256(
            replacement_bytes
        ).hexdigest()
        original_reader = visual_authority._read_regular_nofollow

        def replaced_reader(root: Path, path: Path) -> bytes:
            if path == target_path:
                return replacement_bytes
            return original_reader(root, path)

        with mock.patch.object(
            visual_authority,
            "_read_regular_nofollow",
            side_effect=replaced_reader,
        ):
            with self.assertRaisesRegex(
                visual_authority.CanonError,
                "Search authority addendum",
            ):
                visual_authority.validate_r1_node_snapshot_payload(
                    ROOT,
                    visual,
                    broken,
                )

    def test_search_visual_snapshot_rejects_duplicate_and_omitted_legacy_nodes(self):
        visual = json.loads(VISUAL_REBASELINE.read_text(encoding="utf-8"))
        snapshot = json.loads(
            SEARCH_VISUAL_NODE_SNAPSHOT.read_text(encoding="utf-8")
        )
        broken = copy.deepcopy(snapshot)
        legacy_nodes = broken["search_authority_addendum"][
            "legacy_integrity_evidence"
        ]["nodes"]
        legacy_nodes[2] = copy.deepcopy(legacy_nodes[0])
        with self.assertRaisesRegex(
            visual_authority.CanonError,
            "Search legacy integrity evidence",
        ):
            visual_authority.validate_r1_node_snapshot_payload(
                ROOT,
                visual,
                broken,
            )

    def test_search_visual_snapshot_binds_componentized_auto_layout_contract(self):
        visual = json.loads(VISUAL_REBASELINE.read_text(encoding="utf-8"))
        snapshot = json.loads(
            SEARCH_VISUAL_NODE_SNAPSHOT.read_text(encoding="utf-8")
        )
        addendum = snapshot["search_authority_addendum"]
        components = addendum["shared_anatomy_components"]
        self.assertEqual(
            {item["name"] for item in components},
            SEARCH_SHARED_COMPONENT_NAMES,
        )
        self.assertEqual(
            len({item["node_id"] for item in components}),
            len(SEARCH_SHARED_COMPONENT_NAMES),
        )
        self.assertTrue(all(item["type"] == "COMPONENT" for item in components))

        bindings = {
            item["state_id"]: item for item in addendum["state_frame_bindings"]
        }
        self.assertEqual(set(bindings), ASK_VISUAL_STATE_IDS)
        for state_id, control in SEARCH_VISUAL_CONTROLS.items():
            with self.subTest(state_id=state_id):
                binding = bindings[state_id]
                self.assertEqual(binding["visible_control"], control)
                self.assertEqual(binding["layout_mode"], "VERTICAL")
                self.assertEqual(binding["frame_width"], 393)
                self.assertEqual(binding["frame_height"], 852)
                self.assertGreaterEqual(binding["component_instance_count"], 4)
                self.assertEqual(binding["minimum_semantic_label_font_size"], 10)
                self.assertTrue(binding["deterministic_results_preserved"])
                self.assertNotEqual(binding["visible_control"], "Cancel")

        visual_authority.validate_r1_node_snapshot_payload(
            ROOT,
            visual,
            snapshot,
        )

    def test_search_visual_snapshot_rejects_generic_or_uncomponentized_controls(self):
        visual = json.loads(VISUAL_REBASELINE.read_text(encoding="utf-8"))
        snapshot = json.loads(
            SEARCH_VISUAL_NODE_SNAPSHOT.read_text(encoding="utf-8")
        )
        broken = copy.deepcopy(snapshot)
        binding = broken["search_authority_addendum"]["state_frame_bindings"][0]
        binding["visible_control"] = "Cancel"
        binding["component_instance_count"] = 0
        with self.assertRaisesRegex(
            visual_authority.CanonError,
            "Search authority addendum",
        ):
            visual_authority.validate_r1_node_snapshot_payload(
                ROOT,
                visual,
                broken,
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
            if state["blueprint_id"] in ASK_VISUAL_STATE_IDS:
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
            item for item in contracts if item.state_id in ASK_VISUAL_STATE_IDS
        )
        self.assertEqual(len(ask_contracts), len(ASK_VISUAL_STATE_IDS))
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
            if item.state_id in ASK_VISUAL_STATE_IDS
        }
        sample_state_id = sorted(ASK_VISUAL_STATE_IDS)[0]
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
            unexpected_states = ASK_VISUAL_STATE_IDS - state_ids
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
