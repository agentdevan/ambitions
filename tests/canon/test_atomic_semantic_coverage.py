from __future__ import annotations

import json
import unittest
from pathlib import Path

from tools.ambitions_canon import migration


ROOT = Path(__file__).resolve().parents[2]
LEDGER = ROOT / "docs/canon/migration/semantic-equivalence-sets.json"


DECISION_OWNER_SETS = {
    17: ("SPEC-SURFACE-TIME-STEP-MEMBERSHIP-001",),
    18: ("SPEC-COMPLETED-CONTEXTUAL-PLACEMENT-001",),
    26: ("SPEC-GLOBAL-SEARCH-PLACEMENT-001", "SPEC-GLOBAL-SEARCH-PRIVATE-COMMAND-LAYER-001"),
    35: ("SPEC-GLOBAL-CAPTURE-CLOSE-BEHAVIOR-001",),
    62: ("SPEC-SURFACE-YOU-SETTINGS-DRILLDOWN-001",),
    75: ("OBJ-GOAL-PATH-ADAPTATION-TRIGGERS-001",),
    101: ("SPEC-SURFACE-TODAY-PURPOSE-001", "SPEC-SURFACE-TODAY-TEMPORAL-RAIL-001", "SPEC-SURFACE-TIME-PURPOSE-001"),
    116: ("SPEC-SURFACE-GOALS-EXECUTION-STACK-001",),
    122: ("OBJECT-GOAL-LIFECYCLE-001", "CONTROL-MATERIAL-CONFIRMATION-001"),
    137: ("SPEC-SURFACE-TIME-CREATION-ROUTES-001",),
    153: ("OBJ-EVENT-RECURRENCE-EDIT-001",),
    155: ("JOURNEY-CALENDAR-INVITE-DIFF-001",),
    160: ("OBJ-EVENT-MULTI-DAY-001",),
    165: ("SPEC-SURFACE-YOU-TIME-PREFERENCES-001", "SPEC-SURFACE-TIME-PURPOSE-001"),
    175: ("SYSTEM-NOTIFICATIONS-POLICY-001", "OBJ-GOAL-AUTOMATION-LADDER-001"),
    187: ("SYSTEM-NOTIFICATIONS-POLICY-001", "SYSTEM-NOTIFICATIONS-EFFECT-001"),
    188: ("SYSTEM-APPLE-WIDGET-PROJECTION-001", "SYSTEM-APPLE-WIDGET-ACTION-001"),
    189: ("SYSTEM-APPLE-INTENTS-001",),
    190: ("SYSTEM-APPLE-SHARE-HANDOFF-001", "APP-DEEP-LINK-EXTERNAL-ENTRY-001", "APP-DEEP-LINK-PRIVACY-001", "SYSTEM-EXPORT-001", "SYSTEM-APPLE-HANDOFF-001"),
    191: ("LAW-OFFLINE-NO-ACCOUNT-001", "APP-DEGRADED-FAILURE-TAXONOMY-001", "SPEC-GLOBAL-CAPTURE-DRAFT-RECOVERY-001", "APP-DEGRADED-RECOVERY-001"),
}

RUNTIME_OWNER_SETS = {
    "CLAIM-MOM-0012": ("SYSTEM-RUNTIME-MUTATION-001",),
    "CLAIM-RPPS-0004": ("SYSTEM-RUNTIME-MUTATION-001", "SYSTEM-RUNTIME-COMMAND-VALIDATION-001"),
    "CLAIM-RPPS-0006": (),
    "CLAIM-RPPS-0007": ("SYSTEM-SCHEDULING-REFLOW-001",),
    "CLAIM-RPPS-0008": ("SYSTEM-RUNTIME-MUTATION-001", "LAW-RUNTIME-DURABLE-SUCCESS-001", "DETERMINISM-003"),
    "CLAIM-RPPS-0009": ("SYSTEM-PERSISTENCE-COMPACTION-001", "SYSTEM-PERSISTENCE-MIGRATION-001"),
    "CLAIM-RPPS-0071": ("SYSTEM-RUNTIME-MUTATION-001",),
}


class AtomicSemanticCoverageTests(unittest.TestCase):
    def setUp(self) -> None:
        self.value = json.loads(LEDGER.read_text(encoding="utf-8"))

    def test_compound_decisions_have_ordered_atomic_owner_sets(self):
        self.assertEqual(self.value["schema_version"], 3)
        by_decision = {
            item["decision_number"]: item
            for item in self.value["source_claims"]
            if item["decision_number"] is not None
        }
        for number, expected in DECISION_OWNER_SETS.items():
            with self.subTest(decision=number):
                atomic_owners = tuple(
                    clause["requirement_id"]
                    for clause in by_decision[number]["clauses"]
                    if clause["requirement_id"] is not None
                )
                # Multiple contiguous atomic spans may compose into the same
                # reviewed owner. Preserve first source order while asserting
                # the exact stable owner sequence rather than occurrence count.
                actual = tuple(dict.fromkeys(atomic_owners))
                self.assertEqual(actual, expected)

    def test_runtime_claims_bind_exact_runtime_owners(self):
        by_claim = {item["claim_id"]: item for item in self.value["source_claims"]}
        for claim_id, expected in RUNTIME_OWNER_SETS.items():
            with self.subTest(claim_id=claim_id):
                atomic_owners = tuple(
                    clause["requirement_id"]
                    for clause in by_claim[claim_id]["clauses"]
                    if clause["requirement_id"] is not None
                )
                actual = tuple(dict.fromkeys(atomic_owners))
                self.assertEqual(actual, expected)

    def test_owner_body_clause_evidence_rejects_positive_polarity_for_prohibition(self):
        validate = getattr(migration, "owner_body_span_is_exact_clause", None)
        self.assertIsNotNone(validate, "owner body span validation must exist")
        body = "Actions MUST validate before commit. Direct writes MUST NOT occur."
        positive_end = body.index(".") + 1
        self.assertTrue(validate(body, 0, positive_end, "MUST"))
        self.assertFalse(validate(body, 0, positive_end, "MUST NOT"))
        negative_start = positive_end + 1
        self.assertTrue(validate(body, negative_start, len(body), "MUST NOT"))
        self.assertFalse(validate(body, 8, 12, "MUST"), "partial token spans are forbidden")
        lower = "Automation must not override user authority."
        self.assertTrue(validate(lower, 0, len(lower), "MUST NOT"))

    def test_owner_body_clause_evidence_allows_nonnormative_review_marker(self):
        validate = migration.owner_body_span_is_exact_clause
        marker = "<!-- reviewed provenance marker -->\n"
        law = "Capture MUST NOT be a tab."
        body = marker + law
        self.assertTrue(validate(body, len(marker), len(body), "MUST NOT"))

    def test_clause_modality_compatibility_is_same_polarity_and_equal_or_stronger(self):
        compatible = migration.clause_modalities_are_compatible
        self.assertTrue(compatible("SHOULD", "MUST"))
        self.assertTrue(compatible("SHOULD NOT", "MUST NOT"))
        self.assertFalse(compatible("MUST", "SHOULD"))
        self.assertFalse(compatible("MUST NOT", "MUST"))

    def test_approved_owner_supersession_records_polarity_change_explicitly(self):
        validate = getattr(migration, "relationship_modalities_are_valid", None)
        self.assertIsNotNone(validate, "relationship-aware modality validation must exist")
        approval = "Owner-approved polarity supersession preserves the rejected source as migration evidence."
        self.assertTrue(validate("MUST NOT", "MUST", "owner_supersession", approval))
        self.assertTrue(validate("MUST", "MUST NOT", "rejected_by_owner", approval))
        self.assertFalse(validate("MUST NOT", "MUST", "composition", approval))
        self.assertFalse(validate("MUST NOT", "MUST", "owner_supersession", None))


if __name__ == "__main__":
    unittest.main()
