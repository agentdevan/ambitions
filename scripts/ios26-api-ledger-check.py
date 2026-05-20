#!/usr/bin/env python3
"""Create or validate the IOS26 API verification ledger from the local SDK."""

from __future__ import annotations

import argparse
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
LEDGER = ROOT / "docs/audits/ios26-api-verification-ledger.md"
SYMBOLS = [
    "GlassEffectContainer",
    "tabBarMinimizeBehavior",
    "tabViewBottomAccessory",
    "WidgetKit",
    "ActivityKit",
    "AppIntents",
    "BackgroundTasks",
    "SwiftData",
]


def run(command: list[str]) -> tuple[int, str]:
    result = subprocess.run(command, cwd=ROOT, text=True, capture_output=True, check=False)
    return result.returncode, (result.stdout + result.stderr).strip()


def sdk_summary() -> tuple[str, str, str]:
    xcode_code, xcode_out = run(["xcodebuild", "-version"])
    sdk_code, sdk_out = run(["xcodebuild", "-showsdks"])
    swift_code, swift_out = run(["swift", "--version"])
    return (
        xcode_out if xcode_code == 0 else f"unavailable: {xcode_out}",
        sdk_out if sdk_code == 0 else f"unavailable: {sdk_out}",
        swift_out if swift_code == 0 else f"unavailable: {swift_out}",
    )


def symbol_status(symbol: str, sdk_text: str) -> str:
    framework_names = {"WidgetKit", "ActivityKit", "AppIntents", "BackgroundTasks", "SwiftData"}
    if symbol in framework_names:
        return "candidate: framework availability must be verified in source/import tests"
    if "iOS 26" in sdk_text or "iphoneos26" in sdk_text.lower() or "iphonesimulator26" in sdk_text.lower():
        return "candidate: iOS 26 SDK present; verify symbol in focused source batch"
    return "unverified: local iOS 26 SDK not detected"


def render_ledger() -> str:
    xcode, sdks, swift = sdk_summary()
    now = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    rows = []
    for symbol in SYMBOLS:
        rows.append(f"| `{symbol}` | {symbol_status(symbol, sdks)} | Future IOS26 batch must cite local SDK/source proof before adoption. |")
    return f"""# IOS26 API Verification Ledger

Status: generated local SDK ledger; not API adoption proof
Generated: {now}

## Toolchain

```text
{xcode}

{swift}
```

## SDKs

```text
{sdks}
```

## Candidate APIs

| API / Framework | Status | Requirement |
| --- | --- | --- |
{chr(10).join(rows)}

## Claim Boundary

This ledger does not prove implementation, app build success, visual behavior, accessibility, performance, device behavior, TestFlight readiness, or App Store readiness.
"""


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--write", action="store_true", help="Write docs/audits/ios26-api-verification-ledger.md.")
    args = parser.parse_args()
    text = render_ledger()
    if args.write:
        LEDGER.parent.mkdir(parents=True, exist_ok=True)
        LEDGER.write_text(text, encoding="utf-8")
        print(f"GREEN: wrote {LEDGER.relative_to(ROOT)}")
    else:
        print(text)
    return 0


if __name__ == "__main__":
    sys.exit(main())
