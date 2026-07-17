import hashlib
import shutil
import subprocess
import tempfile
import unittest
from contextlib import contextmanager
from dataclasses import replace
from pathlib import Path
from unittest.mock import patch

from tools.ambitions_canon.model import CanonError, StateCommandActivationPosture
from tools.ambitions_canon.ux_blueprint import load_state_command_contracts


ROOT = Path(__file__).resolve().parents[2]


class CommandGateTrustedHistoryTests(unittest.TestCase):
    def api(self):
        from tools.ambitions_canon import command_gate_dependencies as api

        required = (
            "AuthenticatedCommandGateCIContext",
            "CommandGateOwnerApprovalAttestation",
            "PROTECTED_COMMAND_GATE_REF",
            "PROTECTED_COMMAND_GATE_CI_PROVENANCE",
            "command_gate_ci_context_sha256",
            "command_gate_owner_approval_attestation_sha256",
            "load_trusted_approval_base_from_git",
            "render_command_gate_dependency_registry",
            "render_command_gate_approval_receipt_registry",
            "render_command_gate_owner_approval_registry",
        )
        missing = [name for name in required if not hasattr(api, name)]
        if missing:
            self.fail(f"trusted approval-history API is missing: {missing[0]}")
        return api

    def loaded(self, api):
        return api.load_command_gate_dependency_registry(
            ROOT,
            expected_canon_revision=1,
        )

    def active_purchase_contracts(self):
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

    def rehash_dependency(self, api, row, **changes):
        candidate = replace(row, dependency_sha256="", **changes)
        return replace(
            candidate,
            dependency_sha256=api.command_gate_dependency_sha256(candidate),
        )

    def rehash_receipt(self, api, receipt, **changes):
        candidate = replace(receipt, receipt_sha256="", **changes)
        return replace(
            candidate,
            receipt_sha256=api.command_gate_approval_receipt_sha256(candidate),
        )

    def finalize_sources(self, api, registry):
        dependency_bytes = api.render_command_gate_dependency_registry(registry)
        receipt_bytes = api.render_command_gate_approval_receipt_registry(registry)
        owner_bytes = api.render_command_gate_owner_approval_registry(
            registry.owner_approvals,
            registry_revision=registry.owner_approval_registry_revision,
        )
        return replace(
            registry,
            source_sha256=hashlib.sha256(dependency_bytes).hexdigest(),
            approval_receipt_source_sha256=hashlib.sha256(receipt_bytes).hexdigest(),
            owner_approval_source_sha256=hashlib.sha256(owner_bytes).hexdigest(),
        )

    def stage_pending_transition(
        self,
        api,
        base_registry,
        *,
        mapping,
        dependency_revision,
        canon_content_sha256=None,
    ):
        canon_sha = canon_content_sha256 or base_registry.canon_content_sha256
        base_dependency_bytes = api.render_command_gate_dependency_registry(base_registry)
        base_receipt_bytes = api.render_command_gate_approval_receipt_registry(base_registry)
        base_owner_bytes = api.render_command_gate_owner_approval_registry(
            base_registry.owner_approvals,
            registry_revision=base_registry.owner_approval_registry_revision,
        )
        mapping_record_id = (
            "MAPPING-GATE-STOREKIT-PRODUCT-REGISTRY-001-"
            f"R{dependency_revision:04d}"
        )
        receipt_id = (
            "APPROVAL-RECEIPT-GATE-STOREKIT-PRODUCT-REGISTRY-001-"
            f"R{dependency_revision:04d}"
        )
        approval_identity = (
            "OWNER-APPROVAL-GATE-STOREKIT-PRODUCT-REGISTRY-001-"
            f"R{dependency_revision:04d}"
        )
        row = self.rehash_dependency(
            api,
            base_registry.dependencies[0],
            dependency_revision=dependency_revision,
            owner_approval_state="approved",
            approval_receipt_id=receipt_id,
            mapping_record_id=mapping_record_id,
            canon_content_sha256=canon_sha,
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
        attestation = api.CommandGateOwnerApprovalAttestation(
            approval_identity=approval_identity,
            approval_revision=dependency_revision,
            approval_state="pending",
            dependency_id=row.dependency_id,
            dependency_revision=row.dependency_revision,
            dependency_sha256=row.dependency_sha256,
            mapping_record_id=row.mapping_record_id,
            exact_product_mappings=row.exact_product_mappings,
            mapping_sha256=row.mapping_sha256,
            canon_content_sha256=canon_sha,
            approved_scope=scope,
            approved_scope_sha256=api.command_gate_approval_scope_sha256(scope),
            trusted_dependency_registry_sha256=hashlib.sha256(
                base_dependency_bytes
            ).hexdigest(),
            trusted_receipt_registry_sha256=hashlib.sha256(
                base_receipt_bytes
            ).hexdigest(),
            trusted_prior_receipt_sha256=(
                base_registry.approval_receipts[-1].receipt_sha256
                if base_registry.approval_receipts
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
        approvals = (*base_registry.owner_approvals, attestation)
        staged = self.finalize_sources(
            api,
            replace(
                base_registry,
                owner_approval_registry_revision=(
                    base_registry.owner_approval_registry_revision + 1
                ),
                owner_approvals=approvals,
            ),
        )
        return (
            staged,
            row,
            attestation,
            (base_dependency_bytes, base_receipt_bytes, base_owner_bytes),
        )

    def consume_pending_transition(self, api, staged, row, attestation):
        base_bytes = (
            api.render_command_gate_dependency_registry(staged),
            api.render_command_gate_approval_receipt_registry(staged),
            api.render_command_gate_owner_approval_registry(
                staged.owner_approvals,
                registry_revision=staged.owner_approval_registry_revision,
            ),
        )
        receipt_id = (
            "APPROVAL-RECEIPT-GATE-STOREKIT-PRODUCT-REGISTRY-001-"
            f"R{row.dependency_revision:04d}"
        )
        receipt = api.CommandGateApprovalReceipt(
            receipt_id=receipt_id,
            receipt_revision=row.dependency_revision,
            dependency_id=row.dependency_id,
            dependency_revision=row.dependency_revision,
            mapping_record_id=row.mapping_record_id,
            exact_product_mappings=row.exact_product_mappings,
            mapping_sha256=row.mapping_sha256,
            dependency_sha256=row.dependency_sha256,
            canon_content_sha256=row.canon_content_sha256,
            approval_identity=attestation.approval_identity,
            approval_attestation_sha256=attestation.attestation_sha256,
            approval_state="approved",
            approved_scope=attestation.approved_scope,
            approved_scope_sha256=attestation.approved_scope_sha256,
            previous_receipt_sha256=(
                staged.approval_receipts[-1].receipt_sha256
                if staged.approval_receipts
                else None
            ),
            receipt_sha256="",
        )
        receipt = self.rehash_receipt(api, receipt)
        candidate = replace(
            staged,
            canon_content_sha256=row.canon_content_sha256,
            dependencies=(row,),
            approval_receipts=(*staged.approval_receipts, receipt),
        )
        return self.finalize_sources(api, candidate), base_bytes

    def approved_transition(
        self,
        api,
        base_registry,
        *,
        mapping,
        dependency_revision,
        canon_content_sha256=None,
    ):
        staged, row, attestation, _ = self.stage_pending_transition(
            api,
            base_registry,
            mapping=mapping,
            dependency_revision=dependency_revision,
            canon_content_sha256=canon_content_sha256,
        )
        return self.consume_pending_transition(api, staged, row, attestation)

    @contextmanager
    def git_base(self, dependency_bytes, receipt_bytes, owner_bytes):
        root = Path(tempfile.mkdtemp(prefix="ambitions-command-gate-history-"))
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
        (root / "history-marker.txt").write_text("ancestor\n", encoding="utf-8")
        subprocess.run(["git", "add", "."], cwd=root, check=True)
        subprocess.run(
            ["git", "commit", "-q", "-m", "ancestor"],
            cwd=root,
            check=True,
        )
        ancestor = subprocess.run(
            ["git", "rev-parse", "HEAD"],
            cwd=root,
            check=True,
            capture_output=True,
            text=True,
        ).stdout.strip()
        (root / "history-marker.txt").write_text("approval base\n", encoding="utf-8")
        subprocess.run(["git", "add", "."], cwd=root, check=True)
        subprocess.run(
            ["git", "commit", "-q", "-m", "approval base"],
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
        subprocess.run(
            ["git", "branch", "trusted", base],
            cwd=root,
            check=True,
        )
        subprocess.run(
            ["git", "update-ref", "refs/remotes/origin/main", base],
            cwd=root,
            check=True,
        )
        (root / "candidate-marker.txt").write_text("candidate\n", encoding="utf-8")
        subprocess.run(["git", "add", "."], cwd=root, check=True)
        subprocess.run(
            ["git", "commit", "-q", "-m", "candidate"],
            cwd=root,
            check=True,
        )
        yield root, ancestor, base

    def authenticated_context(
        self,
        api,
        *,
        protected_sha,
        candidate_head_sha,
        protected_ref=None,
        provenance=None,
    ):
        context = api.AuthenticatedCommandGateCIContext(
            protected_ref=protected_ref or api.PROTECTED_COMMAND_GATE_REF,
            protected_sha=protected_sha,
            candidate_head_sha=candidate_head_sha,
            provenance=provenance or api.PROTECTED_COMMAND_GATE_CI_PROVENANCE,
            context_sha256="",
        )
        return replace(
            context,
            context_sha256=api.command_gate_ci_context_sha256(context),
        )

    def trusted_context(self, api, base_bytes):
        with self.git_base(*base_bytes) as (root, _, base):
            head = subprocess.run(
                ["git", "rev-parse", "HEAD"],
                cwd=root,
                check=True,
                capture_output=True,
                text=True,
            ).stdout.strip()
            return api.load_trusted_approval_base_from_git(
                root,
                authenticated_ci_context=self.authenticated_context(
                    api,
                    protected_sha=base,
                    candidate_head_sha=head,
                ),
            )

    def validate(self, api, candidate, trusted_base):
        contracts = self.active_purchase_contracts()
        repository_root = (
            trusted_base.repository_root
            if trusted_base is not None
            and trusted_base.repository_root is not None
            else None
        )
        original_bytes = None
        if repository_root is not None:
            original_bytes = {
                relative_path: (repository_root / relative_path).read_bytes()
                for relative_path in (
                    api.REGISTRY_PATH,
                    api.APPROVAL_RECEIPT_REGISTRY_PATH,
                    api.OWNER_APPROVAL_REGISTRY_PATH,
                )
            }
        candidate = self.materialize_candidate_registry(
            api,
            candidate,
            repository_root,
        )
        try:
            with patch.object(
                api,
                "_current_canon_content_sha256",
                return_value=candidate.canon_content_sha256,
            ):
                api.validate_command_gate_dependency_bindings(
                    candidate,
                    contracts,
                    canon_revision=1,
                    trusted_approval_base=trusted_base,
                )
        finally:
            if original_bytes is not None:
                for relative_path, content in original_bytes.items():
                    (repository_root / relative_path).write_bytes(content)

    def materialize_candidate_registry(
        self,
        api,
        candidate,
        repository_root=None,
    ):
        if repository_root is None:
            repository_root = Path(
                tempfile.mkdtemp(
                    prefix="ambitions-command-gate-live-candidate-"
                )
            )
            self.addCleanup(shutil.rmtree, repository_root, ignore_errors=True)
        candidate = replace(candidate, repository_root=repository_root)
        rendered = (
            (
                api.REGISTRY_PATH,
                api.render_command_gate_dependency_registry(candidate),
            ),
            (
                api.APPROVAL_RECEIPT_REGISTRY_PATH,
                api.render_command_gate_approval_receipt_registry(candidate),
            ),
            (
                api.OWNER_APPROVAL_REGISTRY_PATH,
                api.render_command_gate_owner_approval_registry(
                    candidate.owner_approvals,
                    registry_revision=(
                        candidate.owner_approval_registry_revision
                    ),
                ),
            ),
        )
        for relative_path, content in rendered:
            destination = repository_root / relative_path
            destination.parent.mkdir(parents=True, exist_ok=True)
            destination.write_bytes(content)
        return candidate

    def test_current_withheld_purchase_builds_without_trusted_approval_context(self):
        api = self.api()
        current = self.loaded(api)
        api.validate_command_gate_dependency_bindings(
            current,
            self.active_purchase_contracts(),
            canon_revision=1,
        )
        self.assertFalse(current.dependencies[0].activation_authorization)
        self.assertEqual(current.owner_approvals, ())

    def test_active_approval_without_trusted_context_fails_closed(self):
        api = self.api()
        candidate, _ = self.approved_transition(
            api,
            self.loaded(api),
            mapping=("com.example.approved-A",),
            dependency_revision=2,
        )
        with self.assertRaisesRegex(CanonError, "trusted approval base"):
            self.validate(api, candidate, None)

    def test_candidate_bytes_cannot_self_select_approval_history(self):
        api = self.api()
        candidate, _ = self.approved_transition(
            api,
            self.loaded(api),
            mapping=("com.example.approved-A",),
            dependency_revision=2,
        )
        self_selected = api.load_trusted_approval_base_from_bytes(
            api.render_command_gate_dependency_registry(candidate),
            api.render_command_gate_approval_receipt_registry(candidate),
            api.render_command_gate_owner_approval_registry(
                candidate.owner_approvals,
                registry_revision=candidate.owner_approval_registry_revision,
            ),
        )
        forged_markers = replace(
            self_selected,
            authenticated_ci_context=self.authenticated_context(
                api,
                protected_sha="0" * 40,
                candidate_head_sha="0" * 40,
            ),
            repository_root=ROOT,
        )

        with self.assertRaisesRegex(CanonError, "authenticated CI context"):
            self.validate(api, candidate, forged_markers)

    def test_git_context_does_not_trust_caller_replaced_parsed_state(self):
        api = self.api()
        current = self.loaded(api)
        approved_a, base_bytes_a = self.approved_transition(
            api,
            current,
            mapping=("com.example.approved-A",),
            dependency_revision=2,
        )
        approved_b, _ = self.approved_transition(
            api,
            current,
            mapping=("com.example.replacement-B",),
            dependency_revision=2,
        )
        trusted_a = self.trusted_context(api, base_bytes_a)
        forged = replace(
            trusted_a,
            dependencies=approved_b.dependencies,
            approval_receipts=approved_b.approval_receipts,
            owner_approvals=approved_b.owner_approvals,
            owner_approval_registry_revision=(
                approved_b.owner_approval_registry_revision
            ),
            owner_approval_registry_sha256=(
                approved_b.owner_approval_source_sha256
            ),
        )

        with self.assertRaisesRegex(CanonError, "immutable owner approval history"):
            self.validate(api, approved_b, forged)
        self.validate(api, approved_a, trusted_a)

    def test_first_approval_resolves_attestation_from_exact_git_merge_base(self):
        api = self.api()
        candidate, base_bytes = self.approved_transition(
            api,
            self.loaded(api),
            mapping=("com.example.approved-A",),
            dependency_revision=2,
        )
        context = self.trusted_context(api, base_bytes)
        self.validate(api, candidate, context)
        self.assertEqual(candidate.dependencies[0].dependency_revision, 2)
        self.assertEqual(len(candidate.approval_receipts), 1)
        self.assertEqual(len(candidate.owner_approvals), 1)

    def test_appended_receipt_must_bind_exact_changed_dependency(self):
        api = self.api()
        candidate, base_bytes = self.approved_transition(
            api,
            self.loaded(api),
            mapping=("com.example.approved-A",),
            dependency_revision=2,
        )
        receipt = candidate.approval_receipts[0]
        lied_scope = replace(
            receipt.approved_scope,
            command_id="CMD-RECEIPT-LIE",
        )
        cases = (
            {
                "exact_product_mappings": ("com.example.receipt-lie",),
                "mapping_sha256": api.command_gate_mapping_sha256(
                    ("com.example.receipt-lie",)
                ),
            },
            {"dependency_sha256": "f" * 64},
            {"canon_content_sha256": "e" * 64},
            {
                "approved_scope": lied_scope,
                "approved_scope_sha256": (
                    api.command_gate_approval_scope_sha256(lied_scope)
                ),
            },
        )
        trusted = self.trusted_context(api, base_bytes)
        for changes in cases:
            with self.subTest(fields=tuple(changes)):
                lied_receipt = self.rehash_receipt(api, receipt, **changes)
                lied_candidate = self.finalize_sources(
                    api,
                    replace(candidate, approval_receipts=(lied_receipt,)),
                )
                with self.assertRaisesRegex(
                    CanonError,
                    "approval receipt does not bind exact dependency content",
                ):
                    self.validate(api, lied_candidate, trusted)

    def test_valid_append_preserves_old_receipt_canon_and_adds_new_binding(self):
        api = self.api()
        first, _ = self.approved_transition(
            api,
            self.loaded(api),
            mapping=("com.example.approved-A",),
            dependency_revision=2,
        )
        old_receipt = first.approval_receipts[0]
        new_canon_sha = "f" * 64
        second, base_bytes = self.approved_transition(
            api,
            first,
            mapping=("com.example.approved-B",),
            dependency_revision=3,
            canon_content_sha256=new_canon_sha,
        )
        context = self.trusted_context(api, base_bytes)
        self.validate(api, second, context)
        self.assertEqual(second.approval_receipts[0], old_receipt)
        self.assertNotEqual(old_receipt.canon_content_sha256, new_canon_sha)
        self.assertEqual(second.approval_receipts[1].canon_content_sha256, new_canon_sha)
        self.assertEqual(
            second.approval_receipts[1].previous_receipt_sha256,
            old_receipt.receipt_sha256,
        )

    def test_withheld_changed_dependency_cannot_launder_appended_approval_history(self):
        api = self.api()
        first, _ = self.approved_transition(
            api,
            self.loaded(api),
            mapping=("com.example.approved-A",),
            dependency_revision=2,
        )
        candidate, base_bytes = self.approved_transition(
            api,
            first,
            mapping=("com.example.approved-B",),
            dependency_revision=3,
        )
        withheld = self.rehash_dependency(
            api,
            candidate.dependencies[0],
            owner_approval_state="withheld",
            approval_receipt_id=None,
            mapping_record_id=None,
            exact_product_mappings=(),
            mapping_sha256=None,
            freshness="absent",
            dependency_posture="blocked",
            activation_authorization=False,
        )
        laundered = self.finalize_sources(
            api,
            replace(candidate, dependencies=(withheld,)),
        )

        with self.assertRaisesRegex(
            CanonError,
            "approval history does not bind exact changed dependency",
        ):
            self.validate(
                api,
                laundered,
                self.trusted_context(api, base_bytes),
            )

    def test_unconsumed_approved_attestation_is_rejected(self):
        api = self.api()
        candidate, base_bytes = self.approved_transition(
            api,
            self.loaded(api),
            mapping=("com.example.approved-A",),
            dependency_revision=2,
        )
        original = candidate.owner_approvals[0]
        extra = replace(
            original,
            approval_state="approved",
            attestation_sha256="",
        )
        extra = replace(
            extra,
            attestation_sha256=(
                api.command_gate_owner_approval_attestation_sha256(extra)
            ),
        )
        approvals = (extra,)
        owner_bytes = api.render_command_gate_owner_approval_registry(
            approvals,
            registry_revision=candidate.owner_approval_registry_revision,
        )
        unreferenced = self.finalize_sources(
            api,
            replace(
                candidate,
                owner_approvals=approvals,
                owner_approval_source_sha256=hashlib.sha256(owner_bytes).hexdigest(),
            ),
        )
        with self.assertRaisesRegex(
            CanonError,
            "state must be pending",
        ):
            api._validate_registry_approval_bindings(unreferenced)

    def test_mixed_transition_checks_unchanged_approved_rows(self):
        api = self.api()
        first, _ = self.approved_transition(
            api,
            self.loaded(api),
            mapping=("com.example.approved-A",),
            dependency_revision=2,
        )
        second, base_bytes = self.approved_transition(
            api,
            first,
            mapping=("com.example.approved-A3",),
            dependency_revision=3,
        )
        trusted = api.load_trusted_approval_base_from_bytes(*base_bytes)

        dependency_b_id = "GATE-ZSECOND-PRODUCT-REGISTRY-001"
        dependency_b_mapping = ("com.example.approved-B",)
        dependency_b = self.rehash_dependency(
            api,
            first.dependencies[0],
            dependency_id=dependency_b_id,
            approval_receipt_id=(
                "APPROVAL-RECEIPT-GATE-ZSECOND-PRODUCT-REGISTRY-001-R0002"
            ),
            mapping_record_id=(
                "MAPPING-GATE-ZSECOND-PRODUCT-REGISTRY-001-R0002"
            ),
            exact_product_mappings=dependency_b_mapping,
            mapping_sha256=api.command_gate_mapping_sha256(
                dependency_b_mapping
            ),
        )
        attestation_b = replace(
            first.owner_approvals[0],
            approval_identity=(
                "OWNER-APPROVAL-GATE-ZSECOND-PRODUCT-REGISTRY-001-R0002"
            ),
            dependency_id=dependency_b_id,
            dependency_sha256=dependency_b.dependency_sha256,
            mapping_record_id=dependency_b.mapping_record_id,
            exact_product_mappings=dependency_b.exact_product_mappings,
            mapping_sha256=dependency_b.mapping_sha256,
            attestation_sha256="",
        )
        attestation_b = replace(
            attestation_b,
            attestation_sha256=(
                api.command_gate_owner_approval_attestation_sha256(
                    attestation_b
                )
            ),
        )
        receipt_lie = ("com.example.receipt-lie-B",)
        receipt_b = self.rehash_receipt(
            api,
            first.approval_receipts[0],
            receipt_id=(
                "APPROVAL-RECEIPT-GATE-ZSECOND-PRODUCT-REGISTRY-001-R0002"
            ),
            dependency_id=dependency_b_id,
            mapping_record_id=dependency_b.mapping_record_id,
            exact_product_mappings=receipt_lie,
            mapping_sha256=api.command_gate_mapping_sha256(receipt_lie),
            dependency_sha256=dependency_b.dependency_sha256,
            approval_identity=attestation_b.approval_identity,
            approval_attestation_sha256=attestation_b.attestation_sha256,
        )
        approvals = tuple(
            sorted(
                (*second.owner_approvals, attestation_b),
                key=lambda item: item.approval_identity,
            )
        )
        owner_bytes = api.render_command_gate_owner_approval_registry(
            approvals,
            registry_revision=second.owner_approval_registry_revision,
        )
        candidate = self.finalize_sources(
            api,
            replace(
                second,
                dependencies=(second.dependencies[0], dependency_b),
                approval_receipts=(
                    first.approval_receipts[0],
                    receipt_b,
                    second.approval_receipts[-1],
                ),
                owner_approvals=approvals,
                owner_approval_source_sha256=hashlib.sha256(
                    owner_bytes
                ).hexdigest(),
            ),
        )
        forged_trusted = replace(
            trusted,
            dependencies=(first.dependencies[0], dependency_b),
            approval_receipts=(first.approval_receipts[0], receipt_b),
            owner_approval_registry_revision=(
                candidate.owner_approval_registry_revision
            ),
            owner_approvals=approvals,
            owner_approval_registry_sha256=(
                candidate.owner_approval_source_sha256
            ),
        )

        with self.assertRaisesRegex(
            CanonError,
            "approval receipt does not bind exact dependency content",
        ):
            api._validate_trusted_approval_transition(
                candidate,
                forged_trusted,
            )

    def test_unchanged_approved_history_revalidates_exact_latest_receipt(self):
        api = self.api()
        approved, _ = self.approved_transition(
            api,
            self.loaded(api),
            mapping=("com.example.approved-A",),
            dependency_revision=2,
        )
        base_bytes = (
            api.render_command_gate_dependency_registry(approved),
            api.render_command_gate_approval_receipt_registry(approved),
            api.render_command_gate_owner_approval_registry(
                approved.owner_approvals,
                registry_revision=approved.owner_approval_registry_revision,
            ),
        )

        self.validate(api, approved, self.trusted_context(api, base_bytes))

    def test_whole_history_mapping_replacement_is_rejected(self):
        api = self.api()
        current = self.loaded(api)
        approved_a, _ = self.approved_transition(
            api,
            current,
            mapping=("com.example.approved-A",),
            dependency_revision=2,
        )
        approved_b, _ = self.approved_transition(
            api,
            current,
            mapping=("com.example.replacement-B",),
            dependency_revision=2,
        )
        base_owner_bytes = api.render_command_gate_owner_approval_registry(
            approved_a.owner_approvals,
            registry_revision=approved_a.owner_approval_registry_revision,
        )
        approved_b = self.finalize_sources(
            api,
            replace(
                approved_b,
                owner_approval_registry_revision=(
                    approved_a.owner_approval_registry_revision
                ),
                owner_approvals=approved_a.owner_approvals,
                owner_approval_source_sha256=hashlib.sha256(
                    base_owner_bytes
                ).hexdigest(),
            ),
        )
        base_bytes = (
            api.render_command_gate_dependency_registry(approved_a),
            api.render_command_gate_approval_receipt_registry(approved_a),
            base_owner_bytes,
        )
        with self.assertRaisesRegex(CanonError, "immutable receipt history"):
            self.validate(api, approved_b, self.trusted_context(api, base_bytes))

    def test_prior_receipt_deletion_is_rejected(self):
        api = self.api()
        approved, _ = self.approved_transition(
            api,
            self.loaded(api),
            mapping=("com.example.approved-A",),
            dependency_revision=2,
        )
        base_bytes = (
            api.render_command_gate_dependency_registry(approved),
            api.render_command_gate_approval_receipt_registry(approved),
            api.render_command_gate_owner_approval_registry(
                approved.owner_approvals,
                registry_revision=approved.owner_approval_registry_revision,
            ),
        )
        deleted = self.finalize_sources(
            api,
            replace(approved, approval_receipts=()),
        )
        with self.assertRaisesRegex(CanonError, "immutable receipt history"):
            self.validate(api, deleted, self.trusted_context(api, base_bytes))

    def test_dependency_revision_cannot_be_reused_for_changed_mapping(self):
        api = self.api()
        approved, _ = self.approved_transition(
            api,
            self.loaded(api),
            mapping=("com.example.approved-A",),
            dependency_revision=2,
        )
        base_bytes = (
            api.render_command_gate_dependency_registry(approved),
            api.render_command_gate_approval_receipt_registry(approved),
            api.render_command_gate_owner_approval_registry(
                approved.owner_approvals,
                registry_revision=approved.owner_approval_registry_revision,
            ),
        )
        changed_mapping = ("com.example.revision-reuse-B",)
        reused_row = self.rehash_dependency(
            api,
            approved.dependencies[0],
            exact_product_mappings=changed_mapping,
            mapping_sha256=api.command_gate_mapping_sha256(changed_mapping),
        )
        reused = self.finalize_sources(
            api,
            replace(approved, dependencies=(reused_row,)),
        )
        with self.assertRaisesRegex(CanonError, "dependency revision reuse"):
            self.validate(api, reused, self.trusted_context(api, base_bytes))

    def test_approval_identity_must_resolve_to_trusted_base_attestation(self):
        api = self.api()
        first, _ = self.approved_transition(
            api,
            self.loaded(api),
            mapping=("com.example.approved-A",),
            dependency_revision=2,
        )
        second, base_bytes = self.approved_transition(
            api,
            first,
            mapping=("com.example.approved-B",),
            dependency_revision=3,
        )
        receipt = self.rehash_receipt(
            api,
            second.approval_receipts[-1],
            approval_identity="OWNER-APPROVAL-UNRESOLVABLE-R0003",
        )
        mismatched = self.finalize_sources(
            api,
            replace(
                second,
                approval_receipts=(*second.approval_receipts[:-1], receipt),
            ),
        )
        with self.assertRaisesRegex(CanonError, "owner approval attestation"):
            self.validate(
                api,
                mismatched,
                self.trusted_context(api, base_bytes),
            )

    def test_authenticated_context_rejects_same_head_self_selected_protected_base(self):
        api = self.api()
        base = self.loaded(api)
        base_bytes = (
            api.render_command_gate_dependency_registry(base),
            api.render_command_gate_approval_receipt_registry(base),
            api.render_command_gate_owner_approval_registry(
                base.owner_approvals,
                registry_revision=base.owner_approval_registry_revision,
            ),
        )
        with self.git_base(*base_bytes) as (root, _, _):
            head = subprocess.run(
                ["git", "rev-parse", "HEAD"],
                cwd=root,
                check=True,
                capture_output=True,
                text=True,
            ).stdout.strip()
            subprocess.run(
                ["git", "update-ref", api.PROTECTED_COMMAND_GATE_REF, head],
                cwd=root,
                check=True,
            )
            context = self.authenticated_context(
                api,
                protected_sha=head,
                candidate_head_sha=head,
            )
            with self.assertRaisesRegex(CanonError, "strict ancestor"):
                api.load_trusted_approval_base_from_git(
                    root,
                    authenticated_ci_context=context,
                )

    def test_authenticated_context_rejects_local_candidate_heads_ref(self):
        api = self.api()
        base = self.loaded(api)
        base_bytes = (
            api.render_command_gate_dependency_registry(base),
            api.render_command_gate_approval_receipt_registry(base),
            api.render_command_gate_owner_approval_registry(
                base.owner_approvals,
                registry_revision=base.owner_approval_registry_revision,
            ),
        )
        with self.git_base(*base_bytes) as (root, _, protected):
            head = subprocess.run(
                ["git", "rev-parse", "HEAD"],
                cwd=root,
                check=True,
                capture_output=True,
                text=True,
            ).stdout.strip()
            context = self.authenticated_context(
                api,
                protected_ref="refs/heads/candidate",
                protected_sha=protected,
                candidate_head_sha=head,
            )
            with self.assertRaisesRegex(CanonError, "fixed protected ref"):
                api.load_trusted_approval_base_from_git(
                    root,
                    authenticated_ci_context=context,
                )

    def test_authenticated_context_rechecks_protected_ref_sha_and_candidate_head(self):
        api = self.api()
        candidate, base_bytes = self.approved_transition(
            api,
            self.loaded(api),
            mapping=("com.example.approved-A",),
            dependency_revision=2,
        )

        with self.subTest(case="protected-sha"):
            with self.git_base(*base_bytes) as (root, ancestor, protected):
                head = subprocess.run(
                    ["git", "rev-parse", "HEAD"],
                    cwd=root,
                    check=True,
                    capture_output=True,
                    text=True,
                ).stdout.strip()
                context = self.authenticated_context(
                    api,
                    protected_sha=ancestor,
                    candidate_head_sha=head,
                )
                with self.assertRaisesRegex(CanonError, "resolve exactly"):
                    api.load_trusted_approval_base_from_git(
                        root,
                        authenticated_ci_context=context,
                    )

        with self.subTest(case="context-provenance-and-digest"):
            with self.git_base(*base_bytes) as (root, _, protected):
                head = subprocess.run(
                    ["git", "rev-parse", "HEAD"],
                    cwd=root,
                    check=True,
                    capture_output=True,
                    text=True,
                ).stdout.strip()
                context = self.authenticated_context(
                    api,
                    protected_sha=protected,
                    candidate_head_sha=head,
                )
                local = replace(context, provenance="local-self-assertion")
                local = replace(
                    local,
                    context_sha256=api.command_gate_ci_context_sha256(local),
                )
                with self.assertRaisesRegex(CanonError, "provenance"):
                    api.load_trusted_approval_base_from_git(
                        root,
                        authenticated_ci_context=local,
                    )
                with self.assertRaisesRegex(CanonError, "digest"):
                    api.load_trusted_approval_base_from_git(
                        root,
                        authenticated_ci_context=replace(
                            context,
                            context_sha256="0" * 64,
                        ),
                    )

        with self.subTest(case="moved-protected-ref"):
            with self.git_base(*base_bytes) as (root, ancestor, protected):
                head = subprocess.run(
                    ["git", "rev-parse", "HEAD"],
                    cwd=root,
                    check=True,
                    capture_output=True,
                    text=True,
                ).stdout.strip()
                trusted = api.load_trusted_approval_base_from_git(
                    root,
                    authenticated_ci_context=self.authenticated_context(
                        api,
                        protected_sha=protected,
                        candidate_head_sha=head,
                    ),
                )
                subprocess.run(
                    ["git", "update-ref", api.PROTECTED_COMMAND_GATE_REF, ancestor],
                    cwd=root,
                    check=True,
                )
                with self.assertRaisesRegex(CanonError, "authenticated CI context"):
                    self.validate(api, candidate, trusted)

        with self.subTest(case="moved-candidate-head"):
            with self.git_base(*base_bytes) as (root, _, protected):
                head = subprocess.run(
                    ["git", "rev-parse", "HEAD"],
                    cwd=root,
                    check=True,
                    capture_output=True,
                    text=True,
                ).stdout.strip()
                trusted = api.load_trusted_approval_base_from_git(
                    root,
                    authenticated_ci_context=self.authenticated_context(
                        api,
                        protected_sha=protected,
                        candidate_head_sha=head,
                    ),
                )
                (root / "post-authentication-change.txt").write_text(
                    "moved head\n",
                    encoding="utf-8",
                )
                subprocess.run(["git", "add", "."], cwd=root, check=True)
                subprocess.run(
                    ["git", "commit", "-q", "-m", "move candidate head"],
                    cwd=root,
                    check=True,
                )
                with self.assertRaisesRegex(CanonError, "authenticated CI context"):
                    self.validate(api, candidate, trusted)

    def test_positive_protected_base_flow_stages_pending_then_consumes_once(self):
        api = self.api()
        base = self.loaded(api)
        staged, row, pending, base_bytes = self.stage_pending_transition(
            api,
            base,
            mapping=("com.example.approved-A",),
            dependency_revision=2,
        )
        self.validate(api, staged, self.trusted_context(api, base_bytes))
        self.assertEqual(staged.dependencies, base.dependencies)
        self.assertEqual(staged.approval_receipts, base.approval_receipts)
        self.assertEqual(pending.approval_state, "pending")
        self.assertFalse(staged.dependencies[0].activation_authorization)

        consumed, staged_bytes = self.consume_pending_transition(
            api,
            staged,
            row,
            pending,
        )
        self.validate(api, consumed, self.trusted_context(api, staged_bytes))
        self.assertEqual(consumed.owner_approvals, staged.owner_approvals)
        self.assertEqual(
            consumed.owner_approval_registry_revision,
            staged.owner_approval_registry_revision,
        )
        self.assertEqual(len(consumed.approval_receipts), 1)
        self.assertTrue(consumed.dependencies[0].activation_authorization)

    def test_stale_expected_git_base_is_rejected(self):
        api = self.api()
        _, base_bytes = self.approved_transition(
            api,
            self.loaded(api),
            mapping=("com.example.approved-A",),
            dependency_revision=2,
        )
        with self.git_base(*base_bytes) as (root, ancestor, _):
            head = subprocess.run(
                ["git", "rev-parse", "HEAD"],
                cwd=root,
                check=True,
                capture_output=True,
                text=True,
            ).stdout.strip()
            with self.assertRaisesRegex(CanonError, "resolve exactly"):
                api.load_trusted_approval_base_from_git(
                    root,
                    authenticated_ci_context=self.authenticated_context(
                        api,
                        protected_sha=ancestor,
                        candidate_head_sha=head,
                    ),
                )

    def test_self_selected_ancestor_expression_is_not_a_trusted_ref(self):
        api = self.api()
        _, base_bytes = self.approved_transition(
            api,
            self.loaded(api),
            mapping=("com.example.approved-A",),
            dependency_revision=2,
        )
        with self.git_base(*base_bytes) as (root, _, base):
            head = subprocess.run(
                ["git", "rev-parse", "HEAD"],
                cwd=root,
                check=True,
                capture_output=True,
                text=True,
            ).stdout.strip()
            with self.assertRaisesRegex(CanonError, "fixed protected ref"):
                api.load_trusted_approval_base_from_git(
                    root,
                    authenticated_ci_context=self.authenticated_context(
                        api,
                        protected_ref="refs/heads/trusted",
                        protected_sha=base,
                        candidate_head_sha=head,
                    ),
                )


if __name__ == "__main__":
    unittest.main()
