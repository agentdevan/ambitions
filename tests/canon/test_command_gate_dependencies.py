import hashlib
import json
import unittest
from dataclasses import replace
from pathlib import Path
from unittest.mock import patch

from tools.ambitions_canon import task_pack as task_pack_module
from tools.ambitions_canon.manifest import load_documents, load_manifest
from tools.ambitions_canon.model import (
    CanonError,
    StateCommandActivationPosture,
)
from tools.ambitions_canon.registry import build_registry
from tools.ambitions_canon.task_pack import TaskIntake, build_task_pack
from tools.ambitions_canon.ux_blueprint import load_state_command_contracts


ROOT = Path(__file__).resolve().parents[2]


class CommandGateDependencyTests(unittest.TestCase):
    def dependency_api(self):
        try:
            from tools.ambitions_canon import command_gate_dependencies
        except ImportError as error:
            self.fail(f"command-gate dependency API is missing: {error}")
        return command_gate_dependencies

    def loaded(self):
        api = self.dependency_api()
        return api, api.load_command_gate_dependency_registry(
            ROOT,
            expected_canon_revision=1,
        )

    def purchase_contracts(self):
        contracts = load_state_command_contracts(ROOT)
        contract = next(
            item
            for item in contracts
            if item.state_id == "UX-STATE-VARIANT-YOU-ENTITLEMENT-EXPIRED"
        )
        purchase = next(
            item
            for item in contract.commands
            if item.command_id == "CMD-YOU-ENTITLEMENT-EXPIRED-002"
        )
        return contracts, contract, purchase

    def active_purchase_contracts(self):
        contracts, contract, purchase = self.purchase_contracts()
        active_purchase = replace(
            purchase,
            activation_posture=StateCommandActivationPosture.ACTIVE,
            gate_requirement_ids=(),
        )
        active_contract = replace(
            contract,
            commands=tuple(
                active_purchase if item.command_id == purchase.command_id else item
                for item in contract.commands
            ),
        )
        return tuple(
            active_contract if item.state_id == contract.state_id else item
            for item in contracts
        )

    def rehash(self, api, row, **changes):
        candidate = replace(row, dependency_sha256="", **changes)
        return replace(
            candidate,
            dependency_sha256=api.command_gate_dependency_sha256(candidate),
        )

    def authorized_registry(self, api, registry):
        row = self.rehash(
            api,
            registry.dependencies[0],
            owner_approval_state="approved",
            owner_approval_evidence="OWNER-APPROVAL-TEST-001",
            exact_product_mappings=("com.example.registered-product",),
            mapping_sha256=api.command_gate_mapping_sha256(
                ("com.example.registered-product",)
            ),
            freshness="current",
            dependency_posture="ready",
            activation_authorization=True,
        )
        return replace(registry, dependencies=(row,))

    def broken_registries(self, api, registry):
        authorized = self.authorized_registry(api, registry)
        approved_row = authorized.dependencies[0]
        return authorized, {
            "missing": replace(authorized, dependencies=()),
            "stale": replace(
                authorized,
                dependencies=(
                    self.rehash(
                        api,
                        approved_row,
                        freshness="stale",
                        dependency_posture="blocked",
                        activation_authorization=False,
                    ),
                ),
            ),
            "unapproved": replace(
                authorized,
                dependencies=(
                    self.rehash(
                        api,
                        approved_row,
                        owner_approval_state="withheld",
                        owner_approval_evidence=None,
                        dependency_posture="blocked",
                        activation_authorization=False,
                    ),
                ),
            ),
            "empty mapping": replace(
                authorized,
                dependencies=(
                    self.rehash(
                        api,
                        approved_row,
                        exact_product_mappings=(),
                        mapping_sha256=None,
                    ),
                ),
            ),
            "mismatch": replace(
                authorized,
                dependencies=(
                    self.rehash(
                        api,
                        approved_row,
                        command_id="CMD-YOU-ENTITLEMENT-EXPIRED-999",
                    ),
                ),
            ),
            "bad hash": replace(
                authorized,
                dependencies=(
                    replace(approved_row, dependency_sha256="0" * 64),
                ),
            ),
        }

    def test_registry_is_closed_hashed_machine_control_not_product_law(self):
        api, registry = self.loaded()
        path = ROOT / "docs/canon/registries/command-gate-dependencies.json"
        self.assertEqual(registry.registry_id, "COMMAND-GATE-DEPENDENCY-REGISTRY-001")
        self.assertEqual(registry.registry_revision, 1)
        self.assertEqual(registry.canon_revision, 1)
        self.assertEqual(
            registry.source_sha256,
            hashlib.sha256(path.read_bytes()).hexdigest(),
        )
        self.assertEqual(len(registry.dependencies), 1)
        dependency = registry.dependencies[0]
        self.assertEqual(dependency.dependency_id, "GATE-STOREKIT-PRODUCT-REGISTRY-001")
        self.assertEqual(dependency.dependency_revision, 1)
        self.assertEqual(dependency.dependency_kind, "storekit_product_registry")
        self.assertEqual(
            dependency.dependency_sha256,
            api.command_gate_dependency_sha256(dependency),
        )
        self.assertEqual(dependency.owner_approval_state, "withheld")
        self.assertIsNone(dependency.owner_approval_evidence)
        self.assertEqual(dependency.exact_product_mappings, ())
        self.assertIsNone(dependency.mapping_sha256)
        self.assertEqual(dependency.freshness, "absent")
        self.assertEqual(dependency.dependency_posture, "blocked")
        self.assertFalse(dependency.activation_authorization)

        payload = json.loads(path.read_text(encoding="utf-8"))
        self.assertEqual(
            set(payload),
            {
                "canon_revision",
                "dependencies",
                "registry_id",
                "registry_revision",
                "schema_version",
            },
        )
        manifest_text = (ROOT / "docs/canon/MANIFEST.toml").read_text(
            encoding="utf-8"
        )
        self.assertNotIn("registries/command-gate-dependencies.json", manifest_text)
        self.assertFalse(
            any(
                dependency.dependency_id in document.owns_concepts
                for document in load_documents(ROOT, load_manifest(ROOT))
            )
        )

    def test_purchase_has_exact_symmetric_dependency_and_remains_future_only(self):
        api, registry = self.loaded()
        contracts, contract, purchase = self.purchase_contracts()
        self.assertEqual(
            purchase.gate_dependency_ids,
            ("GATE-STOREKIT-PRODUCT-REGISTRY-001",),
        )
        self.assertEqual(purchase.activation_posture.value, "future_gated")
        self.assertFalse(registry.dependencies[0].activation_authorization)
        api.validate_command_gate_dependency_bindings(
            registry,
            contracts,
            canon_revision=1,
        )
        dependency = registry.dependencies[0]
        self.assertEqual(dependency.owner_concept, purchase.canonical_owner)
        self.assertEqual(dependency.requirement_id, contract.requirement_id)
        self.assertEqual(dependency.state_id, contract.state_id)
        self.assertEqual(dependency.command_id, purchase.command_id)

    def test_active_purchase_fails_closed_for_every_dependency_break(self):
        api, registry = self.loaded()
        active_contracts = self.active_purchase_contracts()
        authorized, broken = self.broken_registries(api, registry)
        api.validate_command_gate_dependency_bindings(
            authorized,
            active_contracts,
            canon_revision=1,
        )
        for label, candidate in broken.items():
            with self.subTest(label=label):
                with self.assertRaises(CanonError):
                    api.validate_command_gate_dependency_bindings(
                        candidate,
                        active_contracts,
                        canon_revision=1,
                    )

    def test_purchase_task_pack_projects_dependency_and_closes_requirement_gates(self):
        manifest = load_manifest(ROOT)
        registry = build_registry(manifest, load_documents(ROOT, manifest))
        intake = TaskIntake.from_json(
            {
                "schema_version": 1,
                "issue_id": "VISUAL-R1-PURCHASE-GATE",
                "task_type": "release",
                "scope": ["surface.you.entitlement-command-contract"],
                "changed_files": ["docs/canon/specifications/surfaces/you.md"],
                "claim_type": "governance",
                "known_issue_ids": [],
            }
        )
        pack = build_task_pack(registry, intake, "repo-sha", ())
        purchase = next(
            item
            for item in pack.command_authorizations
            if item["command_id"] == "CMD-YOU-ENTITLEMENT-EXPIRED-002"
        )
        self.assertEqual(purchase["activation_posture"], "future_gated")
        self.assertFalse(purchase["activation_authorized"])
        self.assertEqual(
            purchase["gate_dependencies"],
            [
                {
                    "activation_authorization": False,
                    "dependency_id": "GATE-STOREKIT-PRODUCT-REGISTRY-001",
                    "dependency_kind": "storekit_product_registry",
                    "dependency_posture": "blocked",
                    "dependency_revision": 1,
                    "dependency_sha256": purchase["gate_dependencies"][0][
                        "dependency_sha256"
                    ],
                    "exact_product_mapping_count": 0,
                    "freshness": "absent",
                    "mapping_sha256": None,
                    "owner_approval_evidence": None,
                    "owner_approval_state": "withheld",
                    "registry_id": "COMMAND-GATE-DEPENDENCY-REGISTRY-001",
                    "registry_revision": 1,
                    "source_sha256": purchase["gate_dependencies"][0][
                        "source_sha256"
                    ],
                }
            ],
        )
        self.assertEqual(len(purchase["gate_dependencies"][0]["source_sha256"]), 64)
        self.assertEqual(len(purchase["gate_dependencies"][0]["dependency_sha256"]), 64)
        self.assertIn("ENTITLEMENT-003", pack.applicable_requirement_ids)
        self.assertIn("**ENTITLEMENT-003**", pack.to_markdown())

    def test_active_purchase_pack_rejects_every_dependency_break(self):
        manifest = load_manifest(ROOT)
        registry = build_registry(manifest, load_documents(ROOT, manifest))
        contracts, contract, purchase = self.purchase_contracts()
        active_purchase = replace(
            purchase,
            activation_posture=StateCommandActivationPosture.ACTIVE,
            gate_requirement_ids=(),
        )
        active_contract = replace(
            contract,
            commands=tuple(
                active_purchase if item.command_id == purchase.command_id else item
                for item in contract.commands
            ),
        )
        surface_you = next(
            document for document in registry.documents if document.spec_id == "SURFACE-YOU"
        )
        mutated_you = replace(
            surface_you,
            state_command_contracts=tuple(
                active_contract if item.state_id == contract.state_id else item
                for item in surface_you.state_command_contracts
            ),
        )
        mutated_registry = replace(
            registry,
            documents=tuple(
                mutated_you if item.spec_id == surface_you.spec_id else item
                for item in registry.documents
            ),
        )
        intake = TaskIntake.from_json(
            {
                "schema_version": 1,
                "issue_id": "VISUAL-R1-PURCHASE-GATE-ACTIVE",
                "task_type": "release",
                "scope": ["surface.you.entitlement-command-contract"],
                "changed_files": ["docs/canon/specifications/surfaces/you.md"],
                "claim_type": "governance",
                "known_issue_ids": [],
            }
        )
        api, dependency_registry = self.loaded()
        _, broken = self.broken_registries(api, dependency_registry)
        for label, candidate in broken.items():
            with self.subTest(label=label):
                with patch.object(
                    task_pack_module,
                    "load_command_gate_dependency_registry",
                    return_value=candidate,
                ):
                    with self.assertRaises(CanonError):
                        build_task_pack(mutated_registry, intake, "repo-sha", ())


if __name__ == "__main__":
    unittest.main()
