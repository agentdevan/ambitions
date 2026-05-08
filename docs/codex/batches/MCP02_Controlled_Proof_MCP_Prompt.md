# MCP02 Controlled Proof MCP Prompt

Create or maintain the Ambitions Controlled Proof MCP.

Rules:

- Keep it stdlib-only.
- Keep it repo-root bounded.
- Expose named validation tools only.
- Do not add arbitrary shell, network, write, secrets, signing, release, hosted CI, or git mutation tools.
- Save proof logs under `.codex/logs/proof/` or `output/logs/`.
- Record EFC applicability and non-claims in closeout.

Required validation:

```bash
python3 tools/mcp/ambitions_proof_mcp/server.py --self-test
python3 -m pytest tools/mcp/ambitions_proof_mcp/tests
```

If pytest is unavailable, record Yellow and continue with self-test plus manual JSON-RPC.
