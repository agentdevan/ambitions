from __future__ import annotations

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

import foundry.r2_hygiene_cleanup as cleanup_module
from foundry.model import read_json
from foundry.r2_hygiene_cleanup import R2HygieneCleanupOptions, run_r2_hygiene_cleanup


def test_cleanup_backs_up_and_deletes_red_hygiene_objects_only(tmp_path: Path, monkeypatch):
    inventory_path = _inventory(tmp_path)
    env_file = _remote_env_file(tmp_path)
    fake_client = _FakeR2Client()
    monkeypatch.setattr(cleanup_module, "R2S3Client", lambda **_: fake_client)

    result = run_r2_hygiene_cleanup(
        R2HygieneCleanupOptions(
            inventory_path=inventory_path,
            output_root=tmp_path / "cleanup",
            bucket="fixture-bucket",
            account_id="fixture-account-id",
            env_file_paths=(env_file,),
            execute=True,
        )
    )

    assert result["valid"], result["issues"]
    assert result["status"] == "Source Green for R2 production bucket hygiene cleanup"
    assert result["recordCounts"]["redTargets"] == 1
    assert result["recordCounts"]["backupReadbacks"] == 1
    assert result["recordCounts"]["deletedObjects"] == 1
    assert result["recordCounts"]["stillPresentAfterDelete"] == 0
    assert "source-atlas/v1/staging/candidate/example_domain/orphan.json" not in fake_client.objects
    assert "source-atlas/v1/production/stable/example_domain/current.json" in fake_client.objects
    backup_manifest = read_json(Path(result["outputPaths"]["backupManifest"]))
    assert backup_manifest["backups"][0]["objectKey"] == "source-atlas/v1/staging/candidate/example_domain/orphan.json"
    assert Path(backup_manifest["backups"][0]["backupPath"]).exists()

    encoded = json.dumps(result, sort_keys=True)
    assert "fixture-access-key" not in encoded
    assert "fixture-secret-key" not in encoded
    assert "fixture-token" not in encoded


def test_cleanup_refuses_current_expected_objects_even_if_marked_red(tmp_path: Path, monkeypatch):
    inventory_path = _inventory(tmp_path, red_current=True)
    env_file = _remote_env_file(tmp_path)
    fake_client = _FakeR2Client()
    monkeypatch.setattr(cleanup_module, "R2S3Client", lambda **_: fake_client)

    result = run_r2_hygiene_cleanup(
        R2HygieneCleanupOptions(
            inventory_path=inventory_path,
            output_root=tmp_path / "cleanup",
            bucket="fixture-bucket",
            account_id="fixture-account-id",
            env_file_paths=(env_file,),
            execute=True,
        )
    )

    assert not result["valid"]
    assert result["recordCounts"]["deletedObjects"] == 0
    assert any("current expected production object" in issue for issue in result["issues"])
    assert "source-atlas/v1/production/stable/example_domain/current.json" in fake_client.objects


def _inventory(tmp_path: Path, *, red_current: bool = False) -> Path:
    expected_key = "source-atlas/v1/production/stable/example_domain/current.json"
    red_key = expected_key if red_current else "source-atlas/v1/staging/candidate/example_domain/orphan.json"
    inventory = {
        "bucket": "fixture-bucket",
        "prefix": "source-atlas/",
        "expectedObjects": [
            {
                "domainID": "example_domain",
                "objectRole": "current_pointer",
                "objectKey": expected_key,
            }
        ],
        "hygiene": {
            "classifiedUnexpectedObjects": [
                {
                    "objectKey": red_key,
                    "classification": "staging_candidate_in_production_bucket",
                    "severity": "Red",
                    "size": 3,
                }
            ]
        },
    }
    path = tmp_path / "inventory.json"
    path.write_text(json.dumps(inventory), encoding="utf-8")
    return path


def _remote_env_file(tmp_path: Path) -> Path:
    env_file = tmp_path / "r2.env"
    env_file.write_text(
        "\n".join(
            [
                "CLOUDFLARE_R2_ACCESS_KEY_ID=fixture-access-key",
                "CLOUDFLARE_R2_SECRET_ACCESS_KEY=fixture-secret-key",
                "CLOUDFLARE_API_TOKEN=fixture-token",
            ]
        ),
        encoding="utf-8",
    )
    return env_file


class _FakeR2Client:
    def __init__(self) -> None:
        self.objects = {
            "source-atlas/v1/production/stable/example_domain/current.json": b'{"current":true}\n',
            "source-atlas/v1/staging/candidate/example_domain/orphan.json": b"{}\n",
        }

    def list_objects(self, *, prefix: str) -> list[dict]:
        return [
            {"objectKey": key, "size": len(value), "lastModified": "2026-06-29T00:00:00Z", "etag": "fixture"}
            for key, value in sorted(self.objects.items())
            if key.startswith(prefix)
        ]

    def get_object_bytes(self, object_key: str) -> bytes:
        return self.objects[object_key]

    def delete_object(self, object_key: str) -> None:
        del self.objects[object_key]
