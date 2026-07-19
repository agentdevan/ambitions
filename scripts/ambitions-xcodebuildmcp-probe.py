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
CONFIG_PATH = f"{REPO_ROOT}/.xcodebuildmcp/config.yaml"
DEFAULT_EXPECTED_PROFILE = "ambitions-ios"
DEFAULT_EXPECTED_SCHEME = "Ambitions"
DEFAULT_EXPECTED_SIMULATOR_NAME = "iPhone 17 Pro Max"


def parse_args():
    parser = argparse.ArgumentParser(
        description="Probe the Ambitions XcodeBuildMCP stdio transport."
    )
    parser.add_argument("--timeout", type=float, default=45.0)
    parser.add_argument("--json", action="store_true")
    return parser.parse_args()


def load_expected_defaults():
    expected = {
        "profile": DEFAULT_EXPECTED_PROFILE,
        "scheme": DEFAULT_EXPECTED_SCHEME,
        "simulatorName": DEFAULT_EXPECTED_SIMULATOR_NAME,
        "simulatorId": "",
    }
    try:
        with open(CONFIG_PATH, encoding="utf-8") as handle:
            lines = handle.read().splitlines()
    except OSError:
        return expected

    active_profile = None
    for line in lines:
        if line.startswith("activeSessionDefaultsProfile:"):
            active_profile = line.split(":", 1)[1].strip().strip("'\"")
            break
    if active_profile:
        expected["profile"] = active_profile

    in_profile = False
    for line in lines:
        if line == f"  {expected['profile']}:":
            in_profile = True
            continue
        if in_profile and line.startswith("  ") and not line.startswith("    "):
            break
        if not in_profile or not line.startswith("    "):
            continue

        key, separator, value = line.strip().partition(":")
        if not separator:
            continue
        value = value.strip().strip("'\"")
        if key in ("scheme", "simulatorName", "simulatorId"):
            expected[key] = value

    return expected


def encode_message(payload):
    return (json.dumps(payload, separators=(",", ":")) + "\n").encode("utf-8")


def send(stdin, payload):
    stdin.write(encode_message(payload))
    stdin.flush()


def header_separator(buffer):
    crlf = buffer.find(b"\r\n\r\n")
    lf = buffer.find(b"\n\n")
    candidates = [(index, length) for index, length in ((crlf, 4), (lf, 2)) if index >= 0]
    if not candidates:
        return None
    return min(candidates, key=lambda candidate: candidate[0])


def content_length(header_bytes):
    header = header_bytes.decode("ascii", errors="replace")
    for line in header.replace("\r\n", "\n").split("\n"):
        name, separator, value = line.partition(":")
        if separator and name.strip().lower() == "content-length":
            try:
                return int(value.strip())
            except ValueError:
                return None
    return None


def append_stderr(events, stderr_buffer, data):
    stderr_buffer.extend(data)
    while True:
        newline = stderr_buffer.find(b"\n")
        if newline < 0:
            break
        line = bytes(stderr_buffer[:newline]).decode("utf-8", errors="replace")
        del stderr_buffer[: newline + 1]
        events.append({"stream": "stderr", "line": line.rstrip("\r")})


def drain_stderr(events, stderr_buffer):
    if stderr_buffer:
        line = bytes(stderr_buffer).decode("utf-8", errors="replace")
        events.append({"stream": "stderr", "line": line.rstrip("\r\n")})
        stderr_buffer.clear()


def parse_stdout_messages(events, stdout_buffer):
    messages = []
    while True:
        stripped = stdout_buffer.lstrip()
        if stripped.startswith(b"{") or stripped.startswith(b"["):
            newline = stdout_buffer.find(b"\n")
            if newline < 0:
                return messages
            line = bytes(stdout_buffer[:newline]).decode("utf-8", errors="replace").rstrip("\r")
            del stdout_buffer[: newline + 1]
            if not line:
                continue
            events.append({"stream": "stdout", "line": line})
            try:
                messages.append(json.loads(line))
            except json.JSONDecodeError:
                events.append({"stream": "stdout", "line": "malformed MCP JSON line"})
            continue

        separator = header_separator(stdout_buffer)
        if separator is None:
            return messages

        header_end, separator_length = separator
        length = content_length(bytes(stdout_buffer[:header_end]))
        if length is None:
            bad_header = bytes(stdout_buffer[:header_end]).decode("utf-8", errors="replace")
            events.append({"stream": "stdout", "line": f"malformed MCP header: {bad_header}"})
            del stdout_buffer[: header_end + separator_length]
            continue

        body_start = header_end + separator_length
        body_end = body_start + length
        if len(stdout_buffer) < body_end:
            return messages

        body = bytes(stdout_buffer[body_start:body_end])
        del stdout_buffer[:body_end]
        line = body.decode("utf-8", errors="replace")
        events.append({"stream": "stdout", "line": line})
        try:
            messages.append(json.loads(line))
        except json.JSONDecodeError:
            events.append({"stream": "stdout", "line": "malformed MCP JSON body"})
    return messages


def wait_for_id(proc, selector, state, expected_id, deadline, events):
    while time.time() < deadline:
        if proc.poll() is not None:
            drain_stderr(events, state["stderr_buffer"])
            return None
        for key, _ in selector.select(timeout=0.2):
            try:
                chunk = os.read(key.fileobj.fileno(), 4096)
            except BlockingIOError:
                continue
            stream = key.data
            if not chunk:
                continue
            if stream == "stderr":
                append_stderr(events, state["stderr_buffer"], chunk)
                continue
            state["stdout_buffer"].extend(chunk)
            for payload in parse_stdout_messages(events, state["stdout_buffer"]):
                if payload.get("id") == expected_id:
                    drain_stderr(events, state["stderr_buffer"])
                    return payload
    drain_stderr(events, state["stderr_buffer"])
    return None


def summarize(result, events, expected, ok, error=None):
    payload = {
        "ok": ok,
        "wrapper": WRAPPER,
        "expected": expected,
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
    expected = load_expected_defaults()
    env = os.environ.copy()
    env.setdefault("AMBITIONS_XCODEBUILDMCP_CLEAN_PEERS", "0")
    proc = subprocess.Popen(
        [WRAPPER],
        cwd=REPO_ROOT,
        env=env,
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        bufsize=0,
    )
    selector = selectors.DefaultSelector()
    selector.register(proc.stdout, selectors.EVENT_READ, "stdout")
    selector.register(proc.stderr, selectors.EVENT_READ, "stderr")
    events = []
    state = {"stdout_buffer": bytearray(), "stderr_buffer": bytearray()}
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
        initialized = wait_for_id(proc, selector, state, 1, deadline, events)
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
            result = wait_for_id(proc, selector, state, 2, deadline, events)
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
    expected_values = [
        expected["profile"],
        expected["scheme"],
        expected["simulatorName"],
        expected["simulatorId"],
    ]
    ok = (
        error is None
        and all(value and value in text for value in expected_values)
    )
    if error is None and not ok:
        error = "session defaults response did not contain expected Ambitions profile/defaults"

    payload = summarize(result, events, expected, ok, error)
    if args.json:
        print(json.dumps(payload, indent=2, sort_keys=True))
    else:
        print("XcodeBuildMCP transport:", "ok" if ok else "failed")
        if error:
            print("error:", error)
        if ok:
            print(
                "profile:",
                expected["profile"],
                expected["scheme"],
                expected["simulatorName"],
                expected["simulatorId"],
            )
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
