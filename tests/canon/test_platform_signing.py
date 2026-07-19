from __future__ import annotations

import hashlib
import json
from pathlib import Path
import subprocess
import tempfile
import unittest

from tools.ambitions_canon.authorization import (
    AuthorizationError,
    _verify_signed_attestation,
    load_base_policy,
    load_trusted_bindings,
    task_finalize,
)
from tools.ambitions_canon.platform_attestations import (
    create_start_attestations,
    create_validation_attestations,
)
from tools.ambitions_canon.platform_signing import (
    PlatformSigningError,
    private_key_modulus_hex,
    sign_attestation,
)
from tests.canon.test_authorization import intake, run, write_json, write_trusted_state


def generate_key() -> str:
    completed = subprocess.run(
        [
            "openssl",
            "genpkey",
            "-algorithm",
            "RSA",
            "-pkeyopt",
            "rsa_keygen_bits:2048",
        ],
        check=True,
        capture_output=True,
        text=True,
    )
    return completed.stdout


def anchor(private_key: str, *, purposes: list[str]) -> dict[str, object]:
    return {
        "anchor_id": "platform-test-v1",
        "algorithm": "rsa-pkcs1v15-sha256",
        "purposes": purposes,
        "modulus_hex": private_key_modulus_hex(private_key),
        "public_exponent": 65537,
    }


class PlatformSigningTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.private_key = generate_key()
        cls.other_private_key = generate_key()

    def test_signer_emits_verifier_compatible_signature(self) -> None:
        trust_anchor = anchor(
            self.private_key, purposes=["approval", "event", "validation"]
        )
        signed = sign_attestation(
            {"schema_version": 1, "payload": "exact"},
            anchor=trust_anchor,
            purpose="event",
            private_key_pem=self.private_key,
        )
        _verify_signed_attestation(
            signed,
            {"anchors": [trust_anchor]},
            purpose="event",
            error_code="TEST_SIGNATURE",
        )

    def test_signer_rejects_wrong_key_and_unowned_purpose(self) -> None:
        trust_anchor = anchor(self.private_key, purposes=["approval"])
        with self.assertRaisesRegex(PlatformSigningError, "does not match"):
            sign_attestation(
                {"schema_version": 1},
                anchor=trust_anchor,
                purpose="approval",
                private_key_pem=self.other_private_key,
            )
        with self.assertRaisesRegex(PlatformSigningError, "does not authorize"):
            sign_attestation(
                {"schema_version": 1},
                anchor=trust_anchor,
                purpose="event",
                private_key_pem=self.private_key,
            )

    def test_signature_fails_after_payload_mutation(self) -> None:
        trust_anchor = anchor(self.private_key, purposes=["validation"])
        signed = sign_attestation(
            {"schema_version": 1, "payload": "exact"},
            anchor=trust_anchor,
            purpose="validation",
            private_key_pem=self.private_key,
        )
        signed["payload"] = "drifted"
        with self.assertRaisesRegex(AuthorizationError, "verification failed"):
            _verify_signed_attestation(
                signed,
                {"anchors": [trust_anchor]},
                purpose="validation",
                error_code="TEST_SIGNATURE",
            )

    def test_real_keys_authorize_and_finalize_exact_ci_range(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            run(root, "init", "-q", "-b", "candidate")
            run(root, "config", "user.name", "Platform Signer Test")
            run(root, "config", "user.email", "platform@example.invalid")
            (root / "keep.txt").write_text("base\n", encoding="utf-8")
            write_trusted_state(root, ["keep.txt"], approval_required=True)
            policy_path = root / "docs/canon/references/task-authorization-policy.json"
            policy = json.loads(policy_path.read_text(encoding="utf-8"))
            approval_anchor = anchor(self.private_key, purposes=["approval"])
            approval_anchor["anchor_id"] = "platform-approval-test-v1"
            event_anchor = anchor(
                self.other_private_key, purposes=["event", "validation"]
            )
            event_anchor["anchor_id"] = "platform-attestation-test-v1"
            policy["trust_anchors"]["anchors"] = [
                approval_anchor,
                event_anchor,
            ]
            policy["approval_trust_anchor_id"] = approval_anchor["anchor_id"]
            policy["event_trust_anchor_id"] = event_anchor["anchor_id"]
            policy["validation_trust_anchor_id"] = event_anchor["anchor_id"]
            write_json(
                root,
                "docs/canon/references/task-authorization-policy.json",
                policy,
            )
            run(root, "add", "-A")
            run(root, "commit", "-qm", "trusted base")
            base = run(root, "rev-parse", "HEAD")
            run(root, "branch", "main", base)
            (root / "keep.txt").write_text("candidate\n", encoding="utf-8")
            run(root, "add", "keep.txt")
            run(root, "commit", "-qm", "candidate")
            head = run(root, "rev-parse", "HEAD")
            intake_data = intake("keep.txt")

            event, approval, authorization = create_start_attestations(
                repo_root=root,
                intake_data=intake_data,
                base_ref="refs/heads/main",
                trusted_base_sha=base,
                trusted_head_sha=head,
                pull_request_number=24,
                verification_epoch=1_900_000_000,
                workflow_run_id=24001,
                workflow_run_attempt=1,
                authenticated_principal="owner:devan",
                event_private_key_pem=self.other_private_key,
                approval_private_key_pem=self.private_key,
            )
            validations = create_validation_attestations(
                repo_root=root,
                authorization=authorization,
                evidence={
                    "canon-unit": {
                        "status": "green",
                        "exit_status": 0,
                        "artifact_digest": hashlib.sha256(b"canon-unit").hexdigest(),
                    },
                    "independent-review-evidence": {
                        "status": "green",
                        "exit_status": 0,
                        "artifact_digest": hashlib.sha256(
                            b"independent-review"
                        ).hexdigest(),
                    },
                },
                validation_private_key_pem=self.other_private_key,
            )
            policy = load_base_policy(root, base)
            bindings = load_trusted_bindings(root, base, intake_data, policy)
            receipt = task_finalize(
                repo_root=root,
                authorization=authorization,
                intake_data=intake_data,
                trusted_event_data=event,
                trusted_bindings=bindings,
                policy_data=policy,
                approval_attestations=(approval,),
                validation_attestations=validations,
                verification_epoch=1_900_000_000,
            )
            self.assertTrue(receipt["exact_diff_authorized"])
            self.assertTrue(receipt["merge_authorized"])

    def test_platform_start_rejects_head_that_does_not_contain_base(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            run(root, "init", "-q", "-b", "main")
            run(root, "config", "user.name", "Platform Signer Test")
            run(root, "config", "user.email", "platform@example.invalid")
            (root / "keep.txt").write_text("common\n", encoding="utf-8")
            write_trusted_state(root, ["keep.txt"], approval_required=True)
            policy_path = root / "docs/canon/references/task-authorization-policy.json"
            policy = json.loads(policy_path.read_text(encoding="utf-8"))
            approval_anchor = anchor(self.private_key, purposes=["approval"])
            approval_anchor["anchor_id"] = "platform-approval-test-v1"
            event_anchor = anchor(
                self.other_private_key, purposes=["event", "validation"]
            )
            event_anchor["anchor_id"] = "platform-attestation-test-v1"
            policy["trust_anchors"]["anchors"] = [
                approval_anchor,
                event_anchor,
            ]
            policy["approval_trust_anchor_id"] = approval_anchor["anchor_id"]
            policy["event_trust_anchor_id"] = event_anchor["anchor_id"]
            policy["validation_trust_anchor_id"] = event_anchor["anchor_id"]
            write_json(
                root,
                "docs/canon/references/task-authorization-policy.json",
                policy,
            )
            run(root, "add", "-A")
            run(root, "commit", "-qm", "common ancestor")
            run(root, "switch", "-qc", "candidate")
            (root / "keep.txt").write_text("candidate\n", encoding="utf-8")
            run(root, "add", "keep.txt")
            run(root, "commit", "-qm", "candidate")
            head = run(root, "rev-parse", "HEAD")
            run(root, "switch", "-q", "main")
            (root / "base-only.txt").write_text("base advanced\n", encoding="utf-8")
            run(root, "add", "base-only.txt")
            run(root, "commit", "-qm", "advance base")
            base = run(root, "rev-parse", "HEAD")

            with self.assertRaisesRegex(
                AuthorizationError, "must contain the exact trusted base"
            ):
                create_start_attestations(
                    repo_root=root,
                    intake_data=intake("keep.txt"),
                    base_ref="refs/heads/main",
                    trusted_base_sha=base,
                    trusted_head_sha=head,
                    pull_request_number=24,
                    verification_epoch=1_900_000_000,
                    workflow_run_id=24001,
                    workflow_run_attempt=1,
                    authenticated_principal="owner:devan",
                    event_private_key_pem=self.other_private_key,
                    approval_private_key_pem=self.private_key,
                )


if __name__ == "__main__":
    unittest.main()
