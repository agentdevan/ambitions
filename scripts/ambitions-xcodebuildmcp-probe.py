#!/usr/bin/env python3
import argparse
import json
import os
import selectors
import subprocess
import sys
import time


REPO_ROOT = "/Users/devan/Documents/GitHub/ambitions"
WRAPPER = f"{REPO_ROOT}/scripts/ambitions-xcodebuildmcp-stdio.sh"
EXPECTED_PROFILE = "ambitions-ios"
EXPECTED_SCHEME = "Ambitions"
EXPECTED_SIMULATOR_NAME = "iPhone 17 Pro Max"
EXPECTED_SIMULATOR_ID = "0F5F5AC4-4303-47C8-9BDC-EB5F57A0F79E"


def parse_args():
    parser = argparse.ArgumentParser(
        description="Probe the Ambitions XcodeBuildMCP stdio transport."
    )
    parser.add_argument("--timeout", type=float, default=45.0)
    parser.add_argument("--json", action="store_true")
    return parser.parse_args()


def send(stdin, payload):
    stdin.write(json.dumps(payload, separators=(",", ":")) + "\n")
    stdin.flush()


def wait_for_id(proc, selector, expected_id, deadline, events):
    while time.time() < deadline:
        if proc.poll() is not None:
            return None
        for key, _ in selector.select(timeout=0.2):
            line = key.fileobj.readline()
            if not line:
                continue
            stream = key.data
            line = line.rstrip("\n")
            events.append({"stream": stream, "line": line})
            if stream != "stdout":
                continue
            try:
                payload = json.loads(line)
            except json.JSONDecodeError:
                continue
            if payload.get("id") == expected_id:
                return payload
    return None


def summarize(result, events, ok, error=None):
    payload = {
        "ok": ok,
        "wrapper": WRAPPER,
        "expected": {
            "profile": EXPECTED_PROFILE,
            "scheme": EXPECTED_SCHEME,
            "simulatorName": EXPECTED_SIMULATOR_NAME,
            "simulatorId": EXPECTED_SIMULATOR_ID,
        },
        "error": error,
        "stderr_tail": [
            event["line"] for event in events if event["stream"] == "stderr"
        ][-12:],
    }
    if result is not None:
        payload["session_show_defaults"] = result
    return payload


def main():
    args = parse_args()
    env = os.environ.copy()
    env.setdefault("AMBITIONS_XCODEBUILDMCP_CLEAN_PEERS", "0")
    proc = subprocess.Popen(
        [WRAPPER],
        cwd=REPO_ROOT,
        env=env,
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
        bufsize=1,
    )
    selector = selectors.DefaultSelector()
    selector.register(proc.stdout, selectors.EVENT_READ, "stdout")
    selector.register(proc.stderr, selectors.EVENT_READ, "stderr")
    events = []
    deadline = time.time() + args.timeout
    result = None
    error = None

    try:
        send(
            proc.stdin,
            {
                "jsonrpc": "2.0",
                "id": 1,
                "method": "initialize",
                "params": {
                    "protocolVersion": "2025-06-18",
                    "capabilities": {},
                    "clientInfo": {
                        "name": "ambitions-xcodebuildmcp-probe",
                        "version": "1",
                    },
                },
            },
        )
        initialized = wait_for_id(proc, selector, 1, deadline, events)
        if initialized is None:
            error = "initialize timed out or transport closed"
        elif "error" in initialized:
            error = f"initialize failed: {initialized['error']}"
        else:
            send(
                proc.stdin,
                {
                    "jsonrpc": "2.0",
                    "method": "notifications/initialized",
                    "params": {},
                },
            )
            send(
                proc.stdin,
                {
                    "jsonrpc": "2.0",
                    "id": 2,
                    "method": "tools/call",
                    "params": {
                        "name": "session_show_defaults",
                        "arguments": {},
                    },
                },
            )
            result = wait_for_id(proc, selector, 2, deadline, events)
            if result is None:
                error = "session_show_defaults timed out or transport closed"
            elif "error" in result:
                error = f"session_show_defaults failed: {result['error']}"
    finally:
        proc.terminate()
        try:
            proc.wait(timeout=5)
        except subprocess.TimeoutExpired:
            proc.kill()
            proc.wait()

    text = json.dumps(result or {})
    ok = (
        error is None
        and EXPECTED_PROFILE in text
        and EXPECTED_SCHEME in text
        and EXPECTED_SIMULATOR_NAME in text
        and EXPECTED_SIMULATOR_ID in text
    )
    if error is None and not ok:
        error = "session defaults response did not contain expected Ambitions profile"

    payload = summarize(result, events, ok, error)
    if args.json:
        print(json.dumps(payload, indent=2, sort_keys=True))
    else:
        print("XcodeBuildMCP transport:", "ok" if ok else "failed")
        if error:
            print("error:", error)
        if ok:
            print(
                "profile:",
                EXPECTED_PROFILE,
                EXPECTED_SCHEME,
                EXPECTED_SIMULATOR_NAME,
                EXPECTED_SIMULATOR_ID,
            )
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
