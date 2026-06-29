from __future__ import annotations

import hashlib
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

import foundry.r2_live_inventory as inventory_module
from foundry.model import read_json
from foundry.r2_live_inventory import (
    R2LiveInventoryOptions,
    compare_live_to_expected,
    expected_objects_from_ledger,
    run_r2_live_inventory,
)


def test_expected_objects_from_production_target_ledger_includes_payloads_and_current_pointer(tmp_path: Path):
    ledger = _fixture_ledger(tmp_path)

    expected = expected_objects_from_ledger(ledger)

    assert [item["objectRole"] for item in expected] == ["payload", "payload", "current_pointer"]
    assert {item["objectKey"] for item in expected} == {
        "source-atlas/v1/production/stable/example_domain/20260629T000000Z/claims.json",
        "source-atlas/v1/production/stable/example_domain/20260629T000000Z/manifest.json",
        "source-atlas/v1/production/stable/example_domain/current.json",
    }


def test_compare_live_to_expected_reports_missing_unexpected_and_size_mismatch(tmp_path: Path):
    ledger = _fixture_ledger(tmp_path)
    expected = expected_objects_from_ledger(ledger)
    live = [
        {
            "objectKey": "source-atlas/v1/production/stable/example_domain/20260629T000000Z/claims.json",
            "size": 999,
            "lastModified": "2026-06-29T00:00:00Z",
        },
        {
            "objectKey": "source-atlas/v1/production/stable/example_domain/orphan.json",
            "size": 4,
            "lastModified": "2026-06-29T00:00:00Z",
        },
    ]

    comparison = compare_live_to_expected(live, expected)

    assert len(comparison["presentExpectedObjects"]) == 1
    assert len(comparison["missingExpectedObjects"]) == 2
    assert len(comparison["unexpectedLiveObjects"]) == 1
    assert len(comparison["sizeMismatches"]) == 1


def test_run_live_inventory_does_not_persist_secret_values(tmp_path: Path, monkeypatch):
    ledger = _fixture_ledger(tmp_path)
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
    monkeypatch.setattr(inventory_module, "R2S3Client", _FakeR2Client)

    result = run_r2_live_inventory(
        R2LiveInventoryOptions(
            production_target_ledger_path=ledger,
            output_root=tmp_path / "inventory",
            bucket="fixture-bucket",
            account_id="fixture-account-id",
            env_file_paths=(env_file,),
            verify_known_checksums=True,
        )
    )

    encoded = json.dumps(result, sort_keys=True)
    assert result["valid"], result["issues"]
    assert result["recordCounts"]["liveObjects"] == 3
    assert result["recordCounts"]["expectedPresent"] == 3
    assert result["recordCounts"]["checksumMismatches"] == 0
    assert "fixture-access-key" not in encoded
    assert "fixture-secret-key" not in encoded
    assert "fixture-token" not in encoded
    assert read_json(Path(result["outputPaths"]["report"]))["environment"]["secretValuesPrinted"] is False


def _fixture_ledger(tmp_path: Path) -> Path:
    pack_root = tmp_path / "pack"
    pack_root.mkdir()
    claims = b'{"claims":[]}\n'
    manifest = b'{"manifest":true}\n'
    (pack_root / "claims.json").write_bytes(claims)
    (pack_root / "manifest.json").write_bytes(manifest)
    pack_report = {
        "dryRunPlan": {
            "objects": [
                {
                    "label": "claims",
                    "objectKey": "source-atlas/v1/production/stable/example_domain/20260629T000000Z/claims.json",
                    "bytes": len(claims),
                    "sha256": hashlib.sha256(claims).hexdigest(),
                },
                {
                    "label": "manifest",
                    "objectKey": "source-atlas/v1/production/stable/example_domain/20260629T000000Z/manifest.json",
                    "bytes": len(manifest),
                    "sha256": hashlib.sha256(manifest).hexdigest(),
                },
            ]
        }
    }
    pack_path = tmp_path / "pack-report.json"
    pack_path.write_text(json.dumps(pack_report), encoding="utf-8")
    pointer_payload = b'{"current":true}\n'
    publisher_report = {
        "operation": {
            "currentPointer": {
                "key": "source-atlas/v1/production/stable/example_domain/current.json",
                "expectedSHA256": hashlib.sha256(pointer_payload).hexdigest(),
            }
        }
    }
    publisher_path = tmp_path / "publisher-report.json"
    publisher_path.write_text(json.dumps(publisher_report), encoding="utf-8")
    ledger = {
        "domains": [
            {
                "domainID": "example_domain",
                "packProductionPath": str(pack_path),
                "r2PublisherPath": str(publisher_path),
            }
        ]
    }
    ledger_path = tmp_path / "production-target-ledger.json"
    ledger_path.write_text(json.dumps(ledger), encoding="utf-8")
    return ledger_path


class _FakeR2Client:
    def __init__(self, **_: str) -> None:
        self.objects = {
            "source-atlas/v1/production/stable/example_domain/20260629T000000Z/claims.json": b'{"claims":[]}\n',
            "source-atlas/v1/production/stable/example_domain/20260629T000000Z/manifest.json": b'{"manifest":true}\n',
            "source-atlas/v1/production/stable/example_domain/current.json": b'{"current":true}\n',
        }

    def list_objects(self, *, prefix: str) -> list[dict]:
        return [
            {"objectKey": key, "size": len(value), "lastModified": "2026-06-29T00:00:00Z", "etag": "fixture"}
            for key, value in sorted(self.objects.items())
            if key.startswith(prefix)
        ]

    def get_object_bytes(self, object_key: str) -> bytes:
        return self.objects[object_key]
