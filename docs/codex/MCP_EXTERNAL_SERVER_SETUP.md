# MCP External Server Setup

Status: Local setup guidance.  
Scope: Codex MCP entries and external developer MCPs for the Ambitions Mac VM.

## Installed / Verified In This Run

Codex CLI exists at `/usr/local/bin/codex`.

Registered Codex MCP entries previously verified by `codex mcp list`:

- `ambitionsRepo` using `python3 /Users/devan/Documents/GitHub/ambitions/tools/mcp/ambitions_repo_mcp/server.py`
- `openaiDeveloperDocs` using `https://developers.openai.com/mcp`
- existing `xcodebuildmcp` using `npx -y xcodebuildmcp@latest mcp`

## Ambitions Repo MCP

```toml
[mcp_servers.ambitionsRepo]
command = "python3"
args = ["/Users/devan/Documents/GitHub/ambitions/tools/mcp/ambitions_repo_mcp/server.py"]
```

## Ambitions Proof MCP

```toml
[mcp_servers.ambitionsProof]
command = "python3"
args = ["/Users/devan/Documents/GitHub/ambitions/tools/mcp/ambitions_proof_mcp/server.py"]
```

Use this for wrapper-native Xcode validation when an external XcodeBuildMCP tool call has a hard host timeout.

## OpenAI Developer Docs MCP

Preferred CLI:

```bash
codex mcp add openaiDeveloperDocs --url https://developers.openai.com/mcp
```

## GitHub Official MCP, Read-Only First

Do not create a broad token automatically. Do not store GitHub tokens in the repo.

Human setup for a future read-only token:

1. Create a fine-grained GitHub personal access token scoped only to the Ambitions repo or required org repos.
2. Grant read-only repository metadata and contents.
3. Add read-only actions/code-scanning/security-events permissions only if a specific proof task requires them.
4. Store the token outside the repo, such as a local shell environment variable for the Codex process.
5. Never commit the token, echo it into docs, or put it in `.env` tracked by git.

Docker was not available in this run, so the GitHub MCP was not installed.

Future read-only config example when Docker and a token are available:

```toml
[mcp_servers.githubReadOnly]
command = "docker"
args = [
  "run", "-i", "--rm",
  "-e", "GITHUB_PERSONAL_ACCESS_TOKEN",
  "-e", "GITHUB_READ_ONLY=1",
  "-e", "GITHUB_DYNAMIC_TOOLSETS=1",
  "ghcr.io/github/github-mcp-server"
]
```

GitHub MCP write tools remain forbidden until a separate approval batch.

## XcodeBuildMCP

`codex mcp list` previously showed an existing `xcodebuildmcp` entry via `npx`. The standalone `xcodebuildmcp` binary was not present in PATH.

The repo now tracks the baseline config at:

```text
.xcodebuildmcp/config.yaml
```

Tracked baseline config:

```yaml
schemaVersion: 1
enabledWorkflows:
  - simulator
sessionDefaults:
  default:
    scheme: Ambitions
    simulatorName: iPhone 17
```

### Timeout-safe registration

Use the repo helper from the Mac VM:

```bash
make xcodebuildmcp-register
```

This executes:

```bash
bash scripts/ambitions-xcodebuildmcp-register.sh
```

The helper refreshes the `xcodebuildmcp` Codex MCP entry and records the local timeout policy at:

```text
.xcodebuildmcp/codex-timeout-policy.json
```

Default policy:

```text
startup timeout: 60 seconds
tool timeout: 1800 seconds
```

Override when needed:

```bash
XCODEBUILDMCP_TOOL_TIMEOUT_SECONDS=2400 make xcodebuildmcp-register
```

### Focused XCTest proof rule

A focused XcodeBuildMCP attempt that times out is not verified XCTest proof.

Preferred recovery path:

```text
ambitionsProof.run_named_validation
name: xcode_validate_focused_test
args: ["--batch", "<BATCH>", "--test", "<TEST_ID>"]
```

Then check:

```text
ambitionsProof.xcode_latest_summary
ambitionsProof.xcode_failure_classification
ambitionsRepo.continuation_oracle
```

Only a passing Xcode Build Lab `validate-summary.json` verifies XCTest proof.

Do not enable debugging, UI automation, Xcode IDE, or experimental workflow discovery until the baseline simulator workflow validates.

## Non-Claims

External MCP setup does not prove build success, test success, simulator run proof, device proof, public accessibility proof, App Store readiness, TestFlight readiness, legal/privacy signoff, hosted CI, or release readiness.