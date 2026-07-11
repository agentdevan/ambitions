#!/usr/bin/env python3
"""Atomic, non-destructive ownership for Ambitions Xcode work."""

import argparse
import fcntl
import json
import os
import re
import shutil
import socket
import subprocess
import sys
import time
import uuid
from datetime import datetime, timezone
from contextlib import contextmanager
from pathlib import Path


class LaneBusy(RuntimeError):
    pass


def system_processes():
    output = subprocess.run(
        ["ps", "-axo", "pid=,ppid=,lstart=,command="],
        check=True, capture_output=True, text=True,
    ).stdout
    result = []
    for line in output.splitlines():
        parts = line.strip().split(None, 7)
        if len(parts) != 8:
            continue
        try:
            pid, ppid = int(parts[0]), int(parts[1])
        except ValueError:
            continue
        result.append({"pid": pid, "ppid": ppid, "start": " ".join(parts[2:7]), "command": parts[7]})
    return result


def current_process_start(pid):
    for process in system_processes():
        if process["pid"] == pid:
            return process["start"]
    return "unknown"


class LaneLock:
    def __init__(self, repo_root, process_provider=system_processes, pid=None, ppid=None,
                 pid_start=None, commit_provider=None, host=None):
        self.root = Path(repo_root)
        self.path = self.root / ".codex" / "xcode-lane.lock"
        self.guard_path = self.root / ".codex" / "xcode-lane.guard"
        self.process_provider = process_provider
        self.pid = os.getpid() if pid is None else pid
        self.ppid = os.getppid() if ppid is None else ppid
        self.pid_start = current_process_start(self.pid) if pid_start is None else pid_start
        self.commit_provider = commit_provider or self._commit
        self.host = host or socket.gethostname()

    def _commit(self):
        result = subprocess.run(["git", "rev-parse", "HEAD"], cwd=self.root,
                                capture_output=True, text=True)
        return result.stdout.strip() if result.returncode == 0 else "unknown"

    def _owner(self):
        try:
            return json.loads((self.path / "owner.json").read_text(encoding="utf-8"))
        except (OSError, ValueError):
            return {}

    @staticmethod
    def _live(owner, processes):
        return any(p["pid"] == owner.get("pid") and p.get("start") == owner.get("pid_start") for p in processes)

    def _foreign_xcode(self, processes):
        by_pid = {p["pid"]: p for p in processes}
        ancestors = {self.ppid}
        cursor = self.ppid
        while cursor in by_pid:
            cursor = by_pid[cursor]["ppid"]
            if cursor in ancestors:
                break
            ancestors.add(cursor)
        descendants = {self.pid}
        changed = True
        while changed:
            changed = False
            for p in processes:
                if p["ppid"] in descendants and p["pid"] not in descendants:
                    descendants.add(p["pid"])
                    changed = True
        own = ancestors | descendants
        def is_xcode_work(process):
            command = process.get("command", "").lower()
            return bool(re.search(r"(^|[\s/])xcodebuild(?=\s|$)", command)) or any(
                marker in command
                for marker in (".xctest", "ambitionsuitests-runner", "ambitionstests-runner")
            )
        return [p for p in processes if p["pid"] not in own and is_xcode_work(p)]

    def _reclaim(self, processes):
        owner = self._owner()
        if not owner and time.time() - self.path.stat().st_mtime < 5:
            raise LaneBusy("Xcode lane acquisition is in progress")
        if self._live(owner, processes):
            raise LaneBusy(f"Xcode lane owned by live process {owner.get('pid')}: {owner.get('command', '')}")
        marker = self.path / (".reclaim-" + str(uuid.uuid4()))
        try:
            marker.mkdir()
        except FileNotFoundError:
            return
        except FileExistsError:
            return
        try:
            other_markers = sorted(self.path.glob(".reclaim-*"))
            if other_markers and other_markers[0] == marker:
                shutil.rmtree(self.path)
        except FileNotFoundError:
            pass

    @contextmanager
    def _guard(self):
        self.guard_path.parent.mkdir(parents=True, exist_ok=True)
        with self.guard_path.open("a+", encoding="utf-8") as guard:
            fcntl.flock(guard.fileno(), fcntl.LOCK_EX)
            try:
                yield
            finally:
                fcntl.flock(guard.fileno(), fcntl.LOCK_UN)

    def acquire(self, command):
        with self._guard():
            processes = self.process_provider()
            if self.path.exists():
                self._reclaim(processes)
            self.path.mkdir()
            token = str(uuid.uuid4())
            try:
                foreign = self._foreign_xcode(processes)
                if foreign:
                    details = ", ".join(f"{p['pid']}:{p.get('command', '')}" for p in foreign)
                    raise LaneBusy(f"foreign Xcode process active: {details}")
                owner = {
                    "pid": self.pid, "parent_pid": self.ppid, "pid_start": self.pid_start,
                    "command": command, "commit": self.commit_provider(), "host": self.host,
                    "started_utc": datetime.now(timezone.utc).isoformat(), "token": token,
                }
                (self.path / "owner.json").write_text(json.dumps(owner, indent=2, sort_keys=True) + "\n", encoding="utf-8")
                return token
            except Exception:
                shutil.rmtree(self.path, ignore_errors=True)
                raise

    def release(self, token):
        with self._guard():
            owner = self._owner()
            if not owner or owner.get("token") != token:
                return False
            shutil.rmtree(self.path)
            return True

    def status(self):
        if not self.path.exists():
            return {"status": "idle", "lock_path": str(self.path)}
        owner = self._owner()
        return {"status": "locked" if self._live(owner, self.process_provider()) else "stale",
                "lock_path": str(self.path), "owner": owner}


def main():
    parser = argparse.ArgumentParser()
    sub = parser.add_subparsers(dest="action", required=True)
    acquire = sub.add_parser("acquire")
    acquire.add_argument("--command", required=True)
    acquire.add_argument("--owner-pid", type=int)
    acquire.add_argument("--owner-parent-pid", type=int)
    release = sub.add_parser("release")
    release.add_argument("--token", required=True)
    status = sub.add_parser("status")
    status.add_argument("--json", action="store_true")
    args = parser.parse_args()
    root = os.environ.get("AMBITIONS_XCODE_LANE_ROOT") or subprocess.run(
        ["git", "rev-parse", "--show-toplevel"], capture_output=True, text=True
    ).stdout.strip() or os.getcwd()
    owner_pid = args.owner_pid if args.action == "acquire" and args.owner_pid else None
    owner_ppid = args.owner_parent_pid if args.action == "acquire" and args.owner_parent_pid else None
    if args.action == "acquire" and owner_pid is None:
        owner_pid = os.getppid()
        caller = next((p for p in system_processes() if p["pid"] == owner_pid), {})
        owner_ppid = caller.get("ppid", 1)
    manager = LaneLock(root, pid=owner_pid, ppid=owner_ppid)
    try:
        if args.action == "acquire":
            print(manager.acquire(args.command))
        elif args.action == "release":
            if not manager.release(args.token):
                print("token does not own Xcode lane", file=sys.stderr)
                return 3
        else:
            payload = manager.status()
            print(json.dumps(payload, sort_keys=True) if args.json else payload["status"])
    except LaneBusy as error:
        print(str(error), file=sys.stderr)
        return 2
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
