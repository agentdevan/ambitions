import hashlib
import json
import shutil
import subprocess
import tempfile
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

    def git_trusted_base(
        self,
        api,
        dependency_bytes,
        receipt_bytes,
        owner_bytes,
    ):
        root = Path(tempfile.mkdtemp(prefix="ambitions-command-gate-legacy-"))
        self.addCleanup(shutil.rmtree, root, ignore_errors=True)
        subprocess.run(
            ["git", "init", "-q", "-b", "candidate"],
            cwd=root,
            check=True,
        )
        subprocess.run(
            ["git", "config", "user.email", "canon-test@ambitions.local"],
            cwd=root,
            check=True,
        )
        subprocess.run(
            ["git", "config", "user.name", "Canon Test"],
            cwd=root,
            check=True,
        )
        registry_root = root / "docs/canon/registries"
        registry_root.mkdir(parents=True)
        (registry_root / "command-gate-dependencies.json").write_bytes(
            dependency_bytes
        )
        (registry_root / "command-gate-approval-receipts.json").write_bytes(
            receipt_bytes
        )
        (registry_root / "command-gate-owner-approvals.json").write_bytes(
            owner_bytes
        )
        subprocess.run(["git", "add", "."], cwd=root, check=True)
        subprocess.run(
            ["git", "commit", "-q", "-m", "trusted approval base"],
            cwd=root,
            check=True,
        )
        base = subprocess.run(
            ["git", "rev-parse", "HEAD"],
            cwd=root,
            check=True,
            capture_output=True,
            text=True,
        ).stdout.strip()
        subprocess.run(["git", "branch", "trusted", base], cwd=root, check=True)
        subprocess.run(
            ["git", "update-ref", api.PROTECTED_COMMAND_GATE_REF, base],
            cwd=root,
            check=True,
        )
        (root / "candidate-marker.txt").write_text(
            "candidate\n",
            encoding="utf-8",
        )
        subprocess.run(["git", "add", "."], cwd=root, check=True)
        subprocess.run(
            ["git", "commit", "-q", "-m", "candidate"],
            cwd=root,
            check=True,
        )
        head = subprocess.run(
            ["git", "rev-parse", "HEAD"],
            cwd=root,
            check=True,
            capture_output=True,
            text=True,
        ).stdout.strip()
        context = api.AuthenticatedCommandGateCIContext(
            protected_ref=api.PROTECTED_COMMAND_GATE_REF,
            protected_sha=base,
            candidate_head_sha=head,
            provenance=api.PROTECTED_COMMAND_GATE_CI_PROVENANCE,
            context_sha256="",
        )
        context = replace(
            context,
            context_sha256=api.command_gate_ci_context_sha256(context),
        )
        return api.load_trusted_approval_base_from_git(
            root,
            authenticated_ci_context=context,
        )

    def authorized_registry(
        self,
        api,
        registry,
        *,
        mapping=("com.example.registered-product",),
        dependency_revision=2,
    ):
        dependency_bytes = api.render_command_gate_dependency_registry(registry)
        receipt_bytes = api.render_command_gate_approval_receipt_registry(registry)
        mapping_record_id = (
            "MAPPING-GATE-STOREKIT-PRODUCT-REGISTRY-001-"
            f"R{dependency_revision:04d}"
        )
        receipt_id = (
            "APPROVAL-RECEIPT-GATE-STOREKIT-PRODUCT-REGISTRY-001-"
            f"R{dependency_revision:04d}"
        )
        row = self.rehash(
            api,
            registry.dependencies[0],
            dependency_revision=dependency_revision,
            owner_approval_state="approved",
            approval_receipt_id=receipt_id,
            mapping_record_id=mapping_record_id,
            exact_product_mappings=mapping,
            mapping_sha256=api.command_gate_mapping_sha256(mapping),
            freshness="current",
            dependency_posture="ready",
            activation_authorization=True,
        )
        scope = api.CommandGateApprovalScope(
            owner_concept=row.owner_concept,
            requirement_id=row.requirement_id,
            state_id=row.state_id,
            command_id=row.command_id,
        )
        approval_identity = (
            "OWNER-APPROVAL-GATE-STOREKIT-PRODUCT-REGISTRY-001-"
            f"R{dependency_revision:04d}"
        )
        attestation = api.CommandGateOwnerApprovalAttestation(
            approval_identity=approval_identity,
            approval_revision=dependency_revision,
            approval_state="pending",
            dependency_id=row.dependency_id,
            dependency_revision=row.dependency_revision,
            dependency_sha256=row.dependency_sha256,
            mapping_record_id=mapping_record_id,
            exact_product_mappings=mapping,
            mapping_sha256=row.mapping_sha256,
            canon_content_sha256=registry.canon_content_sha256,
            approved_scope=scope,
            approved_scope_sha256=api.command_gate_approval_scope_sha256(scope),
            trusted_dependency_registry_sha256=hashlib.sha256(
                dependency_bytes
            ).hexdigest(),
            trusted_receipt_registry_sha256=hashlib.sha256(
                receipt_bytes
            ).hexdigest(),
            trusted_prior_receipt_sha256=(
                registry.approval_receipts[-1].receipt_sha256
                if registry.approval_receipts
                else None
            ),
            attestation_sha256="",
        )
        attestation = replace(
            attestation,
            attestation_sha256=(
                api.command_gate_owner_approval_attestation_sha256(attestation)
            ),
        )
        owner_approvals = (*registry.owner_approvals, attestation)
        owner_revision = registry.owner_approval_registry_revision + 1
        owner_bytes = api.render_command_gate_owner_approval_registry(
            owner_approvals,
            registry_revision=owner_revision,
        )
        receipt = api.CommandGateApprovalReceipt(
            receipt_id=receipt_id,
            receipt_revision=dependency_revision,
            dependency_id=row.dependency_id,
            dependency_revision=row.dependency_revision,
            mapping_record_id=mapping_record_id,
            exact_product_mappings=mapping,
            mapping_sha256=row.mapping_sha256,
            dependency_sha256=row.dependency_sha256,
            canon_content_sha256=registry.canon_content_sha256,
            approval_identity=approval_identity,
            approval_attestation_sha256=attestation.attestation_sha256,
            approval_state="approved",
            approved_scope=scope,
            approved_scope_sha256=api.command_gate_approval_scope_sha256(scope),
            previous_receipt_sha256=(
                registry.approval_receipts[-1].receipt_sha256
                if registry.approval_receipts
                else None
            ),
            receipt_sha256="",
        )
        receipt = replace(
            receipt,
            receipt_sha256=api.command_gate_approval_receipt_sha256(receipt),
        )
        candidate = replace(
            registry,
            dependencies=(row,),
            approval_receipts=(*registry.approval_receipts, receipt),
            owner_approval_registry_revision=owner_revision,
            owner_approvals=owner_approvals,
            owner_approval_source_sha256=hashlib.sha256(owner_bytes).hexdigest(),
        )
        candidate = replace(
            candidate,
            source_sha256=hashlib.sha256(
                api.render_command_gate_dependency_registry(candidate)
            ).hexdigest(),
            approval_receipt_source_sha256=hashlib.sha256(
                api.render_command_gate_approval_receipt_registry(candidate)
            ).hexdigest(),
        )
        trusted = self.git_trusted_base(
            api,
            dependency_bytes,
            receipt_bytes,
            owner_bytes,
        )
        return candidate, trusted

    def validate(
        self,
        api,
        candidate,
        contracts,
        *,
        trusted=None,
        current_canon_sha=None,
    ):
        if trusted is None or trusted.repository_root is None:
            api.validate_command_gate_dependency_bindings(
                candidate,
                contracts,
                canon_revision=1,
                trusted_approval_base=trusted,
            )
            return
        candidate = replace(
            candidate,
            repository_root=trusted.repository_root,
        )
        with patch.object(
            api,
            "_current_canon_content_sha256",
            return_value=(
                current_canon_sha
                if current_canon_sha is not None
                else candidate.canon_content_sha256
            ),
        ):
            api.validate_command_gate_dependency_bindings(
                candidate,
                contracts,
                canon_revision=1,
                trusted_approval_base=trusted,
            )

    def broken_registries(self, api, registry):
        authorized, trusted = self.authorized_registry(api, registry)
        approved_row = authorized.dependencies[0]
        return authorized, trusted, {
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
                        approval_receipt_id=None,
                        mapping_record_id=None,
                        exact_product_mappings=(),
                        mapping_sha256=None,
                        freshness="absent",
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
        self.assertRegex(registry.canon_content_sha256, r"^[0-9a-f]{64}$")
        self.assertEqual(registry.approval_receipts, ())
        self.assertEqual(registry.owner_approvals, ())
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
        self.assertIsNone(dependency.approval_receipt_id)
        self.assertIsNone(dependency.mapping_record_id)
        self.assertEqual(
            dependency.canon_content_sha256,
            registry.canon_content_sha256,
        )
        self.assertEqual(dependency.exact_product_mappings, ())
        self.assertIsNone(dependency.mapping_sha256)
        self.assertEqual(dependency.freshness, "absent")
        self.assertEqual(dependency.dependency_posture, "blocked")
        self.assertFalse(dependency.activation_authorization)

        payload = json.loads(path.read_text(encoding="utf-8"))
        self.assertEqual(
            set(payload),
            {
                "canon_content_sha256",
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

    def test_arbitrary_or_unresolvable_approval_receipt_cannot_authorize_mapping(self):
        api, registry = self.loaded()
        authorized, trusted = self.authorized_registry(api, registry)
        arbitrary_row = self.rehash(
            api,
            authorized.dependencies[0],
            approval_receipt_id="APPROVAL-RECEIPT-UNRESOLVABLE-R0002",
        )
        cases = (
            ("arbitrary", replace(authorized, dependencies=(arbitrary_row,))),
            ("unresolvable", replace(authorized, approval_receipts=())),
        )
        for label, candidate in cases:
            with self.subTest(label=label):
                with self.assertRaises(CanonError):
                    self.validate(
                        api,
                        candidate,
                        self.active_purchase_contracts(),
                        trusted=trusted,
                    )

    def test_mapping_change_invalidates_receipt_until_new_revision_and_receipt(self):
        api, registry = self.loaded()
        authorized, trusted = self.authorized_registry(api, registry)
        changed_mapping = ("com.example.changed-product",)
        substituted = self.rehash(
            api,
            authorized.dependencies[0],
            exact_product_mappings=changed_mapping,
            mapping_sha256=api.command_gate_mapping_sha256(changed_mapping),
        )
        with self.assertRaisesRegex(
            CanonError,
            "approval receipt does not bind exact dependency content",
        ):
            self.validate(
                api,
                replace(authorized, dependencies=(substituted,)),
                self.active_purchase_contracts(),
                trusted=trusted,
            )

        same_revision, same_trusted = self.authorized_registry(
            api,
            registry,
            mapping=changed_mapping,
            dependency_revision=2,
        )
        with self.assertRaises(CanonError):
            self.validate(
                api,
                replace(
                    same_revision,
                    approval_receipts=(
                        *authorized.approval_receipts,
                        *same_revision.approval_receipts,
                    ),
                ),
                self.active_purchase_contracts(),
                trusted=same_trusted,
            )

        revised, revised_trusted = self.authorized_registry(
            api,
            authorized,
            mapping=changed_mapping,
            dependency_revision=3,
        )
        self.validate(
            api,
            revised,
            self.active_purchase_contracts(),
            trusted=revised_trusted,
        )

    def test_stale_canon_content_cannot_be_laundered_through_new_self_hashes(self):
        api, registry = self.loaded()
        authorized, trusted = self.authorized_registry(api, registry)
        stale_sha = "f" * 64
        row = self.rehash(
            api,
            authorized.dependencies[0],
            canon_content_sha256=stale_sha,
        )
        receipt = replace(
            authorized.approval_receipts[0],
            dependency_sha256=row.dependency_sha256,
            canon_content_sha256=stale_sha,
            receipt_sha256="",
        )
        receipt = replace(
            receipt,
            receipt_sha256=api.command_gate_approval_receipt_sha256(receipt),
        )
        stale = replace(
            authorized,
            canon_content_sha256=stale_sha,
            dependencies=(row,),
            approval_receipts=(receipt,),
        )
        with self.assertRaisesRegex(CanonError, "canon content"):
            self.validate(
                api,
                stale,
                self.active_purchase_contracts(),
                trusted=trusted,
                current_canon_sha=authorized.canon_content_sha256,
            )

    def test_approval_hash_mismatch_fails_closed(self):
        api, registry = self.loaded()
        authorized, trusted = self.authorized_registry(api, registry)
        receipt = replace(
            authorized.approval_receipts[0],
            receipt_sha256="0" * 64,
        )
        with self.assertRaisesRegex(CanonError, "approval receipt hash"):
            self.validate(
                api,
                replace(authorized, approval_receipts=(receipt,)),
                self.active_purchase_contracts(),
                trusted=trusted,
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
        authorized, trusted, broken = self.broken_registries(api, registry)
        self.validate(
            api,
            authorized,
            active_contracts,
            trusted=trusted,
        )
        for label, candidate in broken.items():
            with self.subTest(label=label):
                with self.assertRaises(CanonError):
                    self.validate(
                        api,
                        candidate,
                        active_contracts,
                        trusted=trusted,
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
                    "approval_receipt": None,
                    "approval_receipt_id": None,
                    "approval_receipt_registry_id": (
                        "COMMAND-GATE-APPROVAL-RECEIPT-REGISTRY-001"
                    ),
                    "approval_receipt_registry_revision": 1,
                    "approval_receipt_source_sha256": purchase[
                        "gate_dependencies"
                    ][0]["approval_receipt_source_sha256"],
                    "canon_content_sha256": purchase["gate_dependencies"][0][
                        "canon_content_sha256"
                    ],
                    "dependency_id": "GATE-STOREKIT-PRODUCT-REGISTRY-001",
                    "dependency_kind": "storekit_product_registry",
                    "dependency_posture": "blocked",
                    "dependency_revision": 1,
                    "dependency_sha256": purchase["gate_dependencies"][0][
                        "dependency_sha256"
                    ],
                    "exact_product_mappings": [],
                    "freshness": "absent",
                    "mapping_sha256": None,
                    "mapping_record_id": None,
                    "owner_approval_state": "withheld",
                    "owner_approval_registry_id": (
                        "COMMAND-GATE-OWNER-APPROVAL-REGISTRY-001"
                    ),
                    "owner_approval_registry_revision": 1,
                    "owner_approval_source_sha256": purchase[
                        "gate_dependencies"
                    ][0]["owner_approval_source_sha256"],
                    "registry_id": "COMMAND-GATE-DEPENDENCY-REGISTRY-001",
                    "registry_revision": 1,
                    "source_sha256": purchase["gate_dependencies"][0][
                        "source_sha256"
                    ],
                }
            ],
        )
        self.assertEqual(len(purchase["gate_dependencies"][0]["source_sha256"]), 64)
        self.assertEqual(
            len(
                purchase["gate_dependencies"][0][
                    "approval_receipt_source_sha256"
                ]
            ),
            64,
        )
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
        authorized, trusted, broken = self.broken_registries(
            api,
            dependency_registry,
        )
        trusted_authorized = replace(
            authorized,
            repository_root=trusted.repository_root,
        )
        with patch.object(
            task_pack_module,
            "load_command_gate_dependency_registry",
            return_value=trusted_authorized,
        ), patch.object(
            api,
            "_current_canon_content_sha256",
            return_value=authorized.canon_content_sha256,
        ):
            with self.assertRaisesRegex(CanonError, "resolution behavior/source"):
                build_task_pack(
                    mutated_registry,
                    intake,
                    "repo-sha",
                    (),
                    trusted_command_gate_approval_base=trusted,
                )
        for label, candidate in broken.items():
            with self.subTest(label=label):
                trusted_candidate = replace(
                    candidate,
                    repository_root=trusted.repository_root,
                )
                with patch.object(
                    task_pack_module,
                    "load_command_gate_dependency_registry",
                    return_value=trusted_candidate,
                ), patch.object(
                    api,
                    "_current_canon_content_sha256",
                    return_value=candidate.canon_content_sha256,
                ):
                    with self.assertRaises(CanonError):
                        build_task_pack(
                            mutated_registry,
                            intake,
                            "repo-sha",
                            (),
                            trusted_command_gate_approval_base=trusted,
                        )


if __name__ == "__main__":
    unittest.main()
