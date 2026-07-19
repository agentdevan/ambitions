"""Base-owned RSA signing helpers for trusted GitHub authorization jobs.

This module is intentionally not imported by the ordinary local authorization
path.  A protected platform job supplies the private key, while the verifier
continues to trust only the public anchor frozen in the base commit.
"""

from __future__ import annotations

import base64
import hashlib
import json
import os
from pathlib import Path
import subprocess
import tempfile
from typing import Mapping

from .authorization import (
    AuthorizationError,
    canonical_json_bytes,
    write_json_atomic,
)


SIGNATURE_ALGORITHM = "rsa-pkcs1v15-sha256"
SIGNATURE_FIELDS = frozenset(
    {
        "trust_anchor_id",
        "trust_anchor_sha256",
        "signature_algorithm",
        "signature_base64url",
    }
)


class PlatformSigningError(ValueError):
    """Fail-closed platform signing error."""


def anchor_digest(anchor: Mapping[str, object]) -> str:
    """Return the verifier-compatible digest for one public trust anchor."""

    return hashlib.sha256(canonical_json_bytes(dict(anchor))).hexdigest()


def load_private_key_from_environment(variable_name: str) -> str:
    """Load a PEM private key without accepting an empty or malformed value."""

    value = os.environ.get(variable_name)
    if not value or "BEGIN PRIVATE KEY" not in value:
        raise PlatformSigningError(
            f"platform signing key is unavailable in {variable_name}"
        )
    return value


def embedded_anchor(
    policy: Mapping[str, object], *, anchor_id: str, purpose: str
) -> dict[str, object]:
    """Resolve exactly one purpose-authorized anchor from base-owned policy."""

    registry = policy.get("trust_anchors")
    if not isinstance(registry, Mapping):
        raise PlatformSigningError("base policy has no trust-anchor registry")
    anchors = registry.get("anchors")
    if not isinstance(anchors, list):
        raise PlatformSigningError("base policy trust-anchor registry is malformed")
    matches = [
        item
        for item in anchors
        if isinstance(item, Mapping) and item.get("anchor_id") == anchor_id
    ]
    if len(matches) != 1:
        raise PlatformSigningError("requested trust anchor is not unique")
    anchor = dict(matches[0])
    if anchor.get("algorithm") != SIGNATURE_ALGORITHM:
        raise PlatformSigningError("requested trust anchor algorithm is unsupported")
    purposes = anchor.get("purposes")
    if not isinstance(purposes, list) or purpose not in purposes:
        raise PlatformSigningError("requested trust anchor purpose is unauthorized")
    return anchor


def private_key_modulus_hex(private_key_pem: str) -> str:
    """Extract the RSA modulus from a PEM key using the platform OpenSSL."""

    with tempfile.TemporaryDirectory(prefix="ambitions-canon-key-") as directory:
        key_path = Path(directory) / "private.pem"
        key_path.write_text(private_key_pem, encoding="utf-8")
        key_path.chmod(0o600)
        completed = subprocess.run(
            ["openssl", "rsa", "-in", str(key_path), "-noout", "-modulus"],
            check=False,
            capture_output=True,
            text=True,
        )
    if completed.returncode != 0:
        raise PlatformSigningError("OpenSSL rejected the platform private key")
    prefix = "Modulus="
    modulus = completed.stdout.strip()
    if not modulus.startswith(prefix):
        raise PlatformSigningError("OpenSSL did not return an RSA modulus")
    return modulus[len(prefix) :].lower().lstrip("0")


def sign_attestation(
    payload: Mapping[str, object],
    *,
    anchor: Mapping[str, object],
    purpose: str,
    private_key_pem: str,
) -> dict[str, object]:
    """Sign one closed attestation with the exact base-owned anchor contract."""

    if SIGNATURE_FIELDS & set(payload):
        raise PlatformSigningError("unsigned payload already contains signature fields")
    if anchor.get("algorithm") != SIGNATURE_ALGORITHM:
        raise PlatformSigningError("trust anchor algorithm is unsupported")
    purposes = anchor.get("purposes")
    if not isinstance(purposes, list) or purpose not in purposes:
        raise PlatformSigningError("trust anchor does not authorize this purpose")
    modulus = anchor.get("modulus_hex")
    if not isinstance(modulus, str) or private_key_modulus_hex(private_key_pem) != (
        modulus.lower().lstrip("0")
    ):
        raise PlatformSigningError("private key does not match the base-owned anchor")

    candidate = dict(payload)
    candidate.update(
        {
            "trust_anchor_id": anchor.get("anchor_id"),
            "trust_anchor_sha256": anchor_digest(anchor),
            "signature_algorithm": SIGNATURE_ALGORITHM,
        }
    )
    signed_bytes = canonical_json_bytes(candidate)
    with tempfile.TemporaryDirectory(prefix="ambitions-canon-sign-") as directory:
        key_path = Path(directory) / "private.pem"
        key_path.write_text(private_key_pem, encoding="utf-8")
        key_path.chmod(0o600)
        completed = subprocess.run(
            ["openssl", "dgst", "-sha256", "-sign", str(key_path)],
            input=signed_bytes,
            check=False,
            capture_output=True,
        )
    if completed.returncode != 0 or not completed.stdout:
        raise PlatformSigningError("OpenSSL could not sign the attestation")
    candidate["signature_base64url"] = base64.urlsafe_b64encode(
        completed.stdout
    ).rstrip(b"=").decode("ascii")
    return candidate


def sign_json_file(
    *,
    input_path: Path,
    output_path: Path,
    policy_path: Path,
    anchor_id: str,
    purpose: str,
    private_key_environment: str,
) -> None:
    """Load, sign, and atomically persist one JSON attestation."""

    try:
        payload = json.loads(input_path.read_text(encoding="utf-8"))
        policy = json.loads(policy_path.read_text(encoding="utf-8"))
    except (OSError, UnicodeError, json.JSONDecodeError) as exc:
        raise PlatformSigningError("unable to read signing input") from exc
    if not isinstance(payload, dict) or not isinstance(policy, dict):
        raise PlatformSigningError("signing input must contain JSON objects")
    anchor = embedded_anchor(policy, anchor_id=anchor_id, purpose=purpose)
    signed = sign_attestation(
        payload,
        anchor=anchor,
        purpose=purpose,
        private_key_pem=load_private_key_from_environment(
            private_key_environment
        ),
    )
    try:
        write_json_atomic(output_path, signed)
    except AuthorizationError as exc:
        raise PlatformSigningError("unable to persist signed attestation") from exc
