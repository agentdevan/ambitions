# Post-PK Batch Bundles

Status: active bundle map after PK41  
Authority: execution accelerator only; canonical queue still controls order

## Purpose

Bundles preserve serial batch IDs while reducing repeated planning overhead. They do not merge batches or weaken proof boundaries.

## Bundles

| Bundle | Batch IDs | Intent |
| --- | --- | --- |
| `pk-tail` | PK34-PK41 | Finish remaining Platform Kernel if explicitly allowed |
| `source-atlas-core` | SA07-SA10C | Claim/requirement/proof/freshness/capability core |
| `source-atlas-runtime` | SA11-SA16 | Store/query/source-needed/offline/container runtime |
| `source-atlas-importers` | SA17-SA24 | URL/text/PDF/OCR/image/classifier/extractor import lane |
| `source-atlas-review-pack` | SA25-SA32 | Review sheet, packs, diff/hash/freshness/adapters/UI handoff |
| `ldi-tail` | LDI17-LDI22 | Living Dream tail, dependency gated |
| `aos-tail` | AOS24-AOS30 | AmbitionsOS tail, dependency gated |
| `fcp-closeout` | FCP27-FCP30 | Flagship completion closeout |
| `pfc-closeout` | PFC31-PFC40 | Platform/framework/compliance closeout |
| `repo-hygiene` | RHC01-RHC06 | Repo hygiene closeout |

## Command

```bash
python3 scripts/ambitions-bundle-next-batches.py --next
python3 scripts/ambitions-bundle-next-batches.py --bundle source-atlas-core
```

## Rule

Bundles are planning context. The train still installs, reviews, commits, advances, and pushes each batch ID independently.
