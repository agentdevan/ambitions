#!/usr/bin/env python3
"""Sign an Ambitions canon attestation inside a protected platform job."""

from __future__ import annotations

import argparse
from pathlib import Path
import sys

from tools.ambitions_canon.platform_signing import (
    PlatformSigningError,
    sign_json_file,
)


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--policy", type=Path, required=True)
    parser.add_argument("--anchor-id", required=True)
    parser.add_argument(
        "--purpose", choices=("approval", "event", "validation"), required=True
    )
    parser.add_argument("--private-key-environment", required=True)
    arguments = parser.parse_args(argv)
    try:
        sign_json_file(
            input_path=arguments.input,
            output_path=arguments.output,
            policy_path=arguments.policy,
            anchor_id=arguments.anchor_id,
            purpose=arguments.purpose,
            private_key_environment=arguments.private_key_environment,
        )
    except PlatformSigningError as error:
        print(f"P0_BLOCKER PLATFORM_SIGNING_FAILED {error}")
        return 1
    print(
        "GREEN platform attestation signed "
        f"purpose={arguments.purpose} anchor={arguments.anchor_id}"
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
