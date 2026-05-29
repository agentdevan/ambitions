# MCP Codex Setup

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite
> Dispositions: rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

<!-- markdownlint-disable MD013 -->

Status: Setup guide for local Ambitions MCP servers.  
Date: 2026-05-08  
Scope: dedicated Ambitions Mac VM / Codex setup.

## What This Installs

Ambitions local MCP setup now has one verified repo-truth server and one controlled proof server scaffold:

```text
tools/mcp/ambitions_repo_mcp/
tools/mcp/ambitions_proof_mcp/
```

`ambitions_repo_mcp` is read-only and local-only. It exposes repo-truth tools for Codex:

- active batch detection
- EFC overlay status
- source-truth stack
- changed-file impact routing
- EFC applicability
- forbidden claim scanning
- closeout shape validation
- current repo posture summary

`ambitions_proof_mcp` exposes named local validation tools only. It is not a generic shell and does not add write, network, secrets, signing, App Store, hosted CI, or git mutation tools. It is registered as `ambitionsProof` in the local Codex config on this Mac when `codex mcp list` shows the server.

Scaffold-only MCP plans also exist for visual proof, accessibility shadow proof, Ambitions Twin fixtures, Source Atlas packs, and release truth:

- `tools/mcp/ambitions_visual_mcp/`
- `tools/mcp/ambitions_accessibility_mcp/`
- `tools/mcp/ambitions_fixture_mcp/`
- `tools/mcp/ambitions_source_atlas_mcp/`
- `tools/mcp/ambitions_release_truth_mcp/`

None of these servers are part of the Ambitions app runtime.

## Install On The Mac VM

From the Ambitions repo root:

```bash
cd /Users/devan/Documents/GitHub/ambitions
python3 tools/mcp/ambitions_repo_mcp/server.py --self-test
python3 tools/mcp/ambitions_proof_mcp/server.py --self-test
```

If the self-test passes, the server can be configured for Codex.

## Codex Config Option

Open your Codex config file:

```bash
mkdir -p ~/.codex
nano ~/.codex/config.toml
```

Add:

```toml
[mcp_servers.ambitionsRepo]
command = "python3"
args = ["/Users/devan/Documents/GitHub/ambitions/tools/mcp/ambitions_repo_mcp/server.py"]
```

Then verify through Codex CLI if your installed Codex version supports it:

```bash
codex mcp list
```

Some Codex versions also support adding MCPs through a command such as:

```bash
codex mcp add ambitionsRepo -- python3 /Users/devan/Documents/GitHub/ambitions/tools/mcp/ambitions_repo_mcp/server.py
codex mcp add openaiDeveloperDocs --url https://developers.openai.com/mcp
```

If the command is unavailable, use the `config.toml` method.

MCP02 config:

```toml
[mcp_servers.ambitionsProof]
command = "python3"
args = ["/Users/devan/Documents/GitHub/ambitions/tools/mcp/ambitions_proof_mcp/server.py"]
```

Do not add the GitHub MCP until a fine-grained read-only token exists outside the repo. Do not add GitHub write tools until a separate approval batch.

See:

- [MCP External Server Setup](MCP_EXTERNAL_SERVER_SETUP.md)
- [GitHub Native Tooling Policy](GITHUB_NATIVE_TOOLING_POLICY.md)

## Recommended Codex Prompt After Setup

```text
Use the ambitionsRepo MCP before touching the repo. First call get_active_batch, summarize_repo_posture, and check_efc_applicability for the target files. Preserve the current active batch and do not claim release/device/accessibility/legal/privacy proof unless the MCP and repo evidence support it.
```

## Safety Notes

- This server is read-only.
- It only reads inside the repo root.
- It does not expose a shell tool.
- It does not use external network.
- It does not access Keychain, environment secrets, or files outside the repo.
- It does not add runtime dependencies to the Ambitions app.
- MCP02 exposes only named validations and keeps proof logs local.
- MCP03-MCP07 are scaffolds/plans only until a later batch implements their tools.

## Troubleshooting

Run self-test:

```bash
python3 tools/mcp/ambitions_repo_mcp/server.py --self-test
python3 tools/mcp/ambitions_proof_mcp/server.py --self-test
```

Expected output includes:

```text
ambitions_repo_mcp self-test passed
```

If Codex cannot see the server:

1. Confirm the path in `~/.codex/config.toml` is absolute.
2. Confirm `python3` exists on the Mac VM.
3. Run the self-test from repo root.
4. Restart the Codex session.

## Non-Claims

Installing this MCP server does not mean any app behavior, build, test, visual QA, accessibility, physical-device, App Store, TestFlight, legal/privacy, sync, hosted AI, hosted CI, telemetry, or release claim is proven.

## Source-of-truth references

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: BEGIN -->

This file must not be treated as standalone active canon. Current authority must be resolved through:

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`
- `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`
- `docs/ops/change-protocol/change-request-template.md`
- `docs/ops/change-protocol/change-impact-check.md`
- `docs/ops/change-protocol/implementation-prompt-template.md`
- `docs/ops/change-protocol/post-implementation-proof-reconciliation.md`

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: END -->

## Non-claims

<!-- AMB-291-NON-CLAIMS: BEGIN -->

- This file does not prove implementation.
- This file does not prove build success.
- This file does not prove test success.
- This file does not prove accessibility validation.
- This file does not prove performance validation.
- This file does not prove device validation.
- This file does not prove privacy/legal approval.
- This file does not prove TestFlight readiness.
- This file does not prove App Store readiness.
- This file does not prove release readiness.
- Linear status is not repo truth.

<!-- AMB-291-NON-CLAIMS: END -->
