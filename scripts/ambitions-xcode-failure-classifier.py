import argparse
import json
import re
import time
from pathlib import Path


PATTERNS = {
    "compile_error": [
        r"\b(error|failed) to build module\b",
        r"\bcommand Swift-Driver",
        r"\bCompileSwift\b",
        r"\berror:.*no such module\b",
        r"\bFailed to produce objective-c header\b",
        r"\bfatal error:\s+[A-Za-z]",
    ],
    "launch_wait_timeout": [
        r"Timed out waiting for .* to launch",
        r"Failed to launch .* within",
        r"Launch .* timed out",
    ],
    "idle_wait_timeout": [
        r"Timed out waiting for .* to idle",
        r"Wait for .* to idle.*Timed out",
    ],
    "assertion_failure": [
        r"\bAssertion Failure\b",
        r"\bXCTAssert\w*\b.*failed",
    ],
    "test_failure": [
        r"\b\d+\s+tests?\s+failed\b",
        r"\*\*\s+TEST\s+FAILED\b",
        r"\*\*\s+TEST\s+EXECUTE\s+FAILED\b",
        r"\bTest Case .* failed\b",
        r"\btest failed\b",
    ],
    "automation_event_timeout": [
        r"(?s)Setting up automation session.*\*\*\s+BUILD\s+INTERRUPTED\s+\*\*",
        r"(?s)Wait for .* to idle.*\*\*\s+BUILD\s+INTERRUPTED\s+\*\*",
        r"(?s)Checking existence of .* retry \d+.*\*\*\s+BUILD\s+INTERRUPTED\s+\*\*",
        r"Timed out.*(?:synthesiz|automation|accessibility hierarchy|idle)",
        r"Failed to synthesize event",
    ],
    "test_timeout": [
        r"Test run did not complete",
        r"Testing timed out",
        r"Test operation timed out",
        r"\bTimed out\b",
    ],
    "simulator_boot_failure": [
        r"Unable to boot simulated device",
        r"Simulator with identifier .* couldn't be found",
        r"Unable to find a simulator",
        r"Booting the simulator failed",
        r"An error was encountered while attempting to boot",
    ],
    "simulator_launcher_failure": [
        r"XCODEBUILD_TEST_LAUNCH_TIMEOUT=1",
        r"XCODEBUILD_SIMULATOR_LAUNCH_FAILURE=1",
        r"IDELaunchiPhoneSimulatorLauncher",
        r"NSMachErrorDomain\s+Code:\s*-308",
        r"Mach error -308",
        r"\(ipc/mig\) server died",
    ],
    "test_discovery_failure": [
        r"No such test class",
        r"no tests found",
        r"Could not find any tests",
        r"Unable to discover tests",
        r"test list could not be obtained",
    ],
    "stale_derived_data": [
        r"stale dependency",
        r"module .* was created by an \w+ newer compiler",
        r"Could not use module.*because module was built with a different version",
        r"Build input file cannot be found",
        r"No such file or directory: .*Build/Products/Debug-iphonesimulator/Ambitions\.app",
    ],
    "xcodegen_project_drift": [
        r"xcodegen generate",
        r"Could not find a valid .xcscheme file",
        r"No such file or directory.*Ambitions.xcodeproj",
        r"Could not read values in project file",
        r"Build phase \"Copy Files\" in target 'Ambitions' references missing file",
    ],
    "missing_destination": [
        r"Unable to find a destination",
        r"no matching destinations",
        r"Any iOS Simulator device not available",
        r"Destination .* unavailable",
    ],
    "signing_error": [
        r"code signing error",
        r"A valid signing identity",
        r"provisioning profile",
        r"code 65",
    ],
    "package_resolution_error": [
        r"swift package could not be resolved",
        r"package resolution failed",
        r"checksum.*mismatch",
        r"unable to resolve package",
    ],
    "result_bundle_error": [
        r"unable to open result bundle",
        r"result bundle \"?[^\" ]+\"? does not exist",
        r"Failed to generate result bundle",
        r"could not write result bundle",
    ],
    "result_extraction_failure": [
        r"result extraction failed",
        r"xcresulttool.*failed",
        r"xcparse.*failed",
    ],
    "corrupt_xcresult": [
        r"corrupt_xcresult",
        r"Result bundle .* is corrupt",
        r"result bundle .* is not valid",
        r"Info\.plist.*missing",
        r"missing Info\.plist.*xcresult",
    ],
    "mcp_timeout_no_test_log": [
        r"mcp_timeout_no_test_log",
        r"XCODEBUILD_TIMEOUT_NO_TEST_LOG=1",
    ],
    "simctl_unresponsive": [
        r"simctl_unresponsive",
        r"simctl list devices .* exceeded",
    ],
    "tool_missing": [
        r"\bcommand not found\b",
        r"xcodebuild:\s+error:\s+unknown option",
        r"No such file or directory.*xcodegen",
        r"No such file or directory.*xcbeautify",
        r"No such file or directory.*xcparse",
    ],
}


def classify(text: str) -> str:
    for key, pats in PATTERNS.items():
        for pat in pats:
            if re.search(pat, text, re.IGNORECASE | re.MULTILINE):
                return key
    return "unknown"


def read_input(path: str) -> str:
    p = Path(path)
    if not p.exists():
        return ""
    try:
        return p.read_text(encoding="utf-8", errors="ignore")
    except Exception:
        return ""


def watch_test_launch(log_path: str, completion_path: str, timeout_seconds: float) -> str:
    deadline = time.monotonic() + timeout_seconds
    completion = Path(completion_path)
    test_started = False
    while True:
        text = read_input(log_path)
        if re.search(r"Testing started|Test Suite|Test Case", text, re.IGNORECASE | re.MULTILINE):
            test_started = True
        classification = classify(text)
        if classification == "simulator_launcher_failure":
            return classification
        if completion.exists() and completion.stat().st_size > 0:
            if classification != "unknown":
                return classification
            return "test_completed" if test_started else "process_exited"
        if not test_started and time.monotonic() >= deadline:
            return "test_launch_timeout"
        time.sleep(0.1)


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--log")
    ap.add_argument("--result")
    ap.add_argument("--watch-test-launch", action="store_true")
    ap.add_argument("--completion-file")
    ap.add_argument("--timeout-seconds", type=float)
    ap.add_argument("--json", action="store_true")
    args = ap.parse_args()

    text = ""
    if args.log:
        text += read_input(args.log)
    elif args.result:
        text = args.result

    if args.watch_test_launch:
        if not args.log or not args.completion_file or not args.timeout_seconds or args.timeout_seconds <= 0:
            ap.error("--watch-test-launch requires --log, --completion-file, and positive --timeout-seconds")
        classification = watch_test_launch(args.log, args.completion_file, args.timeout_seconds)
    else:
        classification = classify(text)
    payload = {
        "classification": classification,
        "input": {
            "log": args.log,
            "result": args.result,
        },
    }

    if args.json:
        print(json.dumps(payload, indent=2))
    else:
        print(classification)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
