import importlib.util
import json
import os
import subprocess
import tempfile
import threading
import time
import unittest
from pathlib import Path


SCRIPT = Path(__file__).parents[1] / "ambitions-xcode-lane-lock.py"
REPO_ROOT = SCRIPT.parents[1]


def load_module():
    spec = importlib.util.spec_from_file_location("lane_lock", SCRIPT)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


class LaneLockTests(unittest.TestCase):
    def setUp(self):
        self.module = load_module()
        self.temp = tempfile.TemporaryDirectory()
        self.root = Path(self.temp.name)

    def tearDown(self):
        self.temp.cleanup()

    def manager(self, processes, pid=100, start="self-start"):
        return self.module.LaneLock(
            repo_root=self.root,
            process_provider=lambda: processes,
            pid=pid,
            ppid=10,
            pid_start=start,
            commit_provider=lambda: "abc123",
            host="test-host",
        )

    def test_first_owner_acquires_atomically_and_writes_metadata(self):
        manager = self.manager([{"pid": 100, "ppid": 10, "command": "python lock", "start": "self-start"}])
        token = manager.acquire("focused test")
        owner = json.loads((self.root / ".codex/xcode-lane.lock/owner.json").read_text())
        self.assertEqual(owner["token"], token)
        self.assertEqual(owner["command"], "focused test")
        self.assertEqual(owner["commit"], "abc123")
        self.assertEqual(owner["host"], "test-host")
        self.assertIn("started_utc", owner)

    def test_live_foreign_owner_is_rejected(self):
        first = self.manager([{"pid": 100, "ppid": 10, "command": "python", "start": "one"}], start="one")
        first.acquire("one")
        second = self.manager([{"pid": 100, "ppid": 10, "command": "python", "start": "one"}], pid=200, start="two")
        with self.assertRaisesRegex(self.module.LaneBusy, "owned by live process"):
            second.acquire("two")

    def test_unlocked_foreign_xcode_process_is_rejected_without_signalling(self):
        processes = [
            {"pid": 100, "ppid": 10, "command": "python lock", "start": "self"},
            {"pid": 777, "ppid": 1, "command": "/usr/bin/xcodebuild test", "start": "foreign"},
        ]
        with self.assertRaisesRegex(self.module.LaneBusy, "foreign Xcode process.*777"):
            self.manager(processes, start="self").acquire("mine")
        self.assertFalse((self.root / ".codex/xcode-lane.lock").exists())

    def test_xcode_sibling_under_same_parent_is_foreign(self):
        processes = [
            {"pid": 10, "ppid": 1, "command": "shell", "start": "shell"},
            {"pid": 100, "ppid": 10, "command": "python lock", "start": "self"},
            {"pid": 888, "ppid": 10, "command": "xcodebuild build", "start": "sibling"},
        ]
        with self.assertRaisesRegex(self.module.LaneBusy, "888"):
            self.manager(processes, start="self").acquire("mine")

    def test_foreign_xctest_and_ambitions_runner_are_rejected(self):
        for command in ("/tmp/MyTests.xctest", "AmbitionsUITests-Runner"):
            with self.subTest(command=command):
                processes = [{"pid": 444, "ppid": 1, "command": command, "start": "x"}]
                with self.assertRaises(self.module.LaneBusy):
                    self.manager(processes).acquire("mine")

    def test_dead_or_pid_reused_owner_is_reclaimed(self):
        lock = self.root / ".codex/xcode-lane.lock"
        lock.mkdir(parents=True)
        (lock / "owner.json").write_text(json.dumps({"pid": 777, "pid_start": "old", "token": "old"}))
        manager = self.manager([{"pid": 777, "ppid": 1, "command": "unrelated", "start": "new"}])
        token = manager.acquire("replacement")
        self.assertNotEqual(token, "old")

    def test_release_requires_matching_token(self):
        manager = self.manager([])
        token = manager.acquire("mine")
        self.assertFalse(manager.release("wrong"))
        self.assertTrue((self.root / ".codex/xcode-lane.lock").exists())
        self.assertTrue(manager.release(token))
        self.assertFalse((self.root / ".codex/xcode-lane.lock").exists())

    def test_acquisition_race_has_exactly_one_owner(self):
        barrier = threading.Barrier(2)
        results = []
        processes = [
            {"pid": 501, "ppid": 10, "command": "python", "start": "501"},
            {"pid": 502, "ppid": 10, "command": "python", "start": "502"},
        ]

        def acquire(pid):
            manager = self.module.LaneLock(
                repo_root=self.root, process_provider=lambda: processes, pid=pid, ppid=10,
                pid_start=str(pid), commit_provider=lambda: "abc123", host="test-host",
            )
            barrier.wait()
            try:
                results.append(("owned", manager.acquire(str(pid))))
            except self.module.LaneBusy:
                results.append(("busy", None))

        threads = [threading.Thread(target=acquire, args=(pid,)) for pid in (501, 502)]
        for thread in threads:
            thread.start()
        for thread in threads:
            thread.join()
        self.assertEqual(sorted(state for state, _ in results), ["busy", "owned"])

    def test_two_releasers_racing_successor_never_delete_successor(self):
        processes = [
            {"pid": 100, "ppid": 10, "command": "python", "start": "old"},
            {"pid": 200, "ppid": 10, "command": "python", "start": "new"},
        ]
        old = self.manager(processes, pid=100, start="old")
        token = old.acquire("old")
        successor = self.manager(processes, pid=200, start="new")
        barrier = threading.Barrier(3)
        release_results = []
        successor_token = []

        def release_old():
            barrier.wait()
            release_results.append(old.release(token))

        def acquire_successor():
            barrier.wait()
            for _ in range(1000):
                try:
                    successor_token.append(successor.acquire("successor"))
                    return
                except self.module.LaneBusy:
                    time.sleep(0.0005)

        threads = [threading.Thread(target=release_old), threading.Thread(target=release_old), threading.Thread(target=acquire_successor)]
        for thread in threads:
            thread.start()
        for thread in threads:
            thread.join()
        self.assertEqual(release_results.count(True), 1)
        self.assertEqual(len(successor_token), 1)
        owner = json.loads((self.root / ".codex/xcode-lane.lock/owner.json").read_text())
        self.assertEqual(owner["token"], successor_token[0])

    def test_cross_process_release_race_is_serialized_with_successor(self):
        env = os.environ.copy()
        env["AMBITIONS_XCODE_LANE_ROOT"] = str(self.root)
        acquire = [
            "python3", str(SCRIPT), "acquire", "--command", "old",
            "--owner-pid", str(os.getpid()), "--owner-parent-pid", str(os.getppid()),
        ]
        token = subprocess.run(acquire, env=env, check=True, capture_output=True, text=True).stdout.strip()
        release = ["python3", str(SCRIPT), "release", "--token", token]
        releasers = [subprocess.Popen(release, env=env, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True) for _ in range(2)]
        successor_token = ""
        for _ in range(100):
            result = subprocess.run(
                [
                    "python3", str(SCRIPT), "acquire", "--command", "successor",
                    "--owner-pid", str(os.getpid()), "--owner-parent-pid", str(os.getppid()),
                ],
                env=env, capture_output=True, text=True,
            )
            if result.returncode == 0:
                successor_token = result.stdout.strip()
                break
            time.sleep(0.005)
        exit_codes = []
        for process in releasers:
            process.communicate()
            exit_codes.append(process.returncode)
        self.assertEqual(sorted(exit_codes), [0, 3])
        self.assertTrue(successor_token)
        owner = json.loads((self.root / ".codex/xcode-lane.lock/owner.json").read_text())
        self.assertEqual(owner["token"], successor_token)
        self.assertTrue((self.root / ".codex/xcode-lane.guard").exists())


class BoundedWrapperIntegrationTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.root = Path(self.temp.name)
        self.bin = self.root / "bin"
        self.bin.mkdir()
        (self.bin / "xcodebuild").write_text("#!/bin/sh\nexit 0\n")
        os.chmod(self.bin / "xcodebuild", 0o755)

    def tearDown(self):
        self.temp.cleanup()

    def run_wrapper(self, timeout_body, result_path):
        for name in ("timeout", "gtimeout"):
            (self.bin / name).write_text("#!/bin/sh\n" + timeout_body)
            os.chmod(self.bin / name, 0o755)
        env = os.environ.copy()
        env["PATH"] = str(self.bin) + os.pathsep + env["PATH"]
        return subprocess.run(
            ["bash", "scripts/ambitions-bounded-xcodebuild.sh", "--", "-resultBundlePath", str(result_path), "test"],
            cwd=REPO_ROOT, env=env, capture_output=True, text=True,
        )

    def test_wrapper_preserves_non_timeout_exit_code(self):
        result = self.run_wrapper("exit 42\n", self.root / "result.xcresult")
        self.assertEqual(result.returncode, 42, result.stdout + result.stderr)

    def test_timeout_never_signals_unrelated_same_path_process(self):
        pid_file = self.root / "pid"
        match = self.root / "shared.xcresult"
        body = (
            f"python3 -c 'import time; time.sleep(30)' xcodebuild '{match}' >/dev/null 2>&1 &\n"
            f"echo $! > '{pid_file}'\n"
            "sleep 0.1\nexit 124\n"
        )
        result = self.run_wrapper(body, match)
        self.assertEqual(result.returncode, 124, result.stdout + result.stderr)
        pid = int(pid_file.read_text())
        try:
            os.kill(pid, 0)
        finally:
            try:
                os.kill(pid, 9)
            except ProcessLookupError:
                pass


if __name__ == "__main__":
    unittest.main()
