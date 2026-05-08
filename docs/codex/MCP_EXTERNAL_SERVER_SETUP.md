# MCP External Server Setup

Status: Local setup guidance.
Scope: Codex MCP entries and external developer MCPs for the Ambitions Mac VM.

## Installed / Verified In This Run

Codex CLI exists at `/usr/local/bin/codex`.

Registered Codex MCP entries verified by `codex mcp list`:

- `ambitionsRepo` using `python3 /Users/devan/Documents/GitHub/ambitions/tools/mcp/ambitions_repo_mcp/server.py`
- `openaiDeveloperDocs` using `https://developers.openai.com/mcp`
- existing `xcodebuildmcp` using `npx -y xcodebuildmcp@latest mcp`

## Ambitions Repo MCP

```toml
[mcp_servers.ambitionsRepo]
command = "python3"
args = ["/Users/devan/Documents/GitHub/ambitions/tools/mcp/ambitions_repo_mcp/server.py"]
```

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

`codex mcp list` shows an existing `xcodebuildmcp` entry via `npx`. The standalone `xcodebuildmcp` binary was not present in PATH.

Repo-local baseline config:

```yaml
schemaVersion: 1
enabledWorkflows:
  - simulator
sessionDefaults:
  default:
    scheme: Ambitions
    simulatorName: iPhone 17
```

Do not enable debugging, UI automation, Xcode IDE, or experimental workflow discovery until the baseline simulator workflow validates.

## Non-Claims

External MCP setup does not prove build success, test success, simulator behavior, device proof, public accessibility proof, App Store readiness, TestFlight readiness, legal/privacy signoff, hosted CI, or release readiness.
