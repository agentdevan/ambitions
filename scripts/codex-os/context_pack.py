#!/usr/bin/env python3
from pathlib import Path
from datetime import datetime, timezone

out = Path('build/codex-os/ambitions-context-pack.md')
out.parent.mkdir(parents=True, exist_ok=True)
parts = ['# Ambitions Context Pack', '', f'Generated: {datetime.now(timezone.utc).isoformat()}', '']
for name in ['docs/governance/GOVERNANCE_DASHBOARD.md', 'docs/governance/generated/repo_doctor_summary.md']:
    p = Path(name)
    parts.append('## ' + name)
    parts.append('')
    parts.append(p.read_text(encoding='utf-8', errors='replace')[:12000] if p.exists() else 'MISSING')
    parts.append('')
out.write_text('\n'.join(parts), encoding='utf-8')
print(out)
