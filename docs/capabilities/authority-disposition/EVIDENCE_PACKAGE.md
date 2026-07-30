# Capability Authority Disposition Evidence Package

Status: **non-normative portable audit evidence**

The complete 112-record machine-readable disposition, concise human matrix, current-authority map, derived projection, validator, and synthetic test fixtures are preserved in:

```text
docs/capabilities/authority-disposition/evidence/capability-authority-disposition-package.zip
```

SHA-256:

```text
624b3b272497a13af9c28e8954353ed0aa4ebc7fac934b2679f984e80cd7567b
```

Extract from the repository root with:

```bash
unzip docs/capabilities/authority-disposition/evidence/capability-authority-disposition-package.zip
```

The package is an audit artifact, not canon. It must not be added to `docs/canon/MANIFEST.toml` or treated as a product-authority source. The readable reports beside it are review projections of the same audit results.

Local synthetic validation passed all positive and negative fixture cases after repair. Full-repository canon and drift checks require execution in a complete checkout and remain separate from this evidence package.
