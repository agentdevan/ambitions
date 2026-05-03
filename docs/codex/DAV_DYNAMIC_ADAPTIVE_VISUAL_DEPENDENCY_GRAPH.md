# DAV Dynamic Adaptive Visual Dependency Graph

<!-- markdownlint-disable MD013 -->

Status: Active DAV dependency graph; implementation authority is per-batch only.
Date: 2026-05-03

## Topological Order

DAV01 source truth precedes all DAV work. DAV02 shared primitives precedes every surface batch. DAV03-DAV09 surface implementation precedes DAV10-DAV15 closeout and EB UI-heavy implementation. DAV10 motion/reduce-motion and DAV11 accessibility closeout precede DAV12 previews, DAV13 performance, DAV14 QA, and DAV15 closeout.

## Batch Dependencies

| Batch | Depends on | Blocks | Reason |
| --- | --- | --- | --- |
| DAV01 | EB32, PXEQ, PXOS/SI visual canon | DAV02-DAV15 | Source truth and surface map before implementation. |
| DAV02 | DAV01 | DAV03-DAV15 | Shared primitives, material, labels, motion helpers. |
| DAV03 | DAV02, Today/PXOS/PXEQ | EB Today UI work | Today rail/hero visual object. |
| DAV04 | DAV02, EB02/EB13/EB25/PXEQ | EB capture UI work | Capture composer and routing receipt visual object. |
| DAV05 | DAV02, Plan/PXOS/PXEQ | EB onboarding/plan UI work | Plan LifeShape/capacity visual object. |
| DAV06 | DAV02, Goals/PXOS/PXEQ | EB goal-related UI work | Goals Mission Control lanes. |
| DAV07 | DAV02, Trust/PXEQ/Profile compatibility | EB Trust/You UI work | You personal system center. |
| DAV08 | DAV02, EB07/EB13/EB25/PXEQ | EB memory/search UI work | Memory visuals remain source/control-bound. |
| DAV09 | DAV02, EB13/EB31/PXEQ | EB receipt/trust UI work | Trust receipt stack and evidence labels. |
| DAV10 | DAV03-DAV09 classified | DAV11-DAV15 | Motion meaning and Reduce Motion equivalence. |
| DAV11 | DAV03-DAV10 classified | DAV12-DAV15 | Visual accessibility evidence. |
| DAV12 | DAV02-DAV11 classified | DAV13-DAV15 | Preview fixtures and scenario gallery. |
| DAV13 | DAV02-DAV12 classified | DAV14-DAV15 | Rendering/battery risk review. |
| DAV14 | DAV02-DAV13 classified | DAV15 | PXEQ/product-experience QA. |
| DAV15 | DAV01-DAV14 resolved | EB35/EB38/EB40 closeout | DAV handoff and non-claims. |

## EB Blocking Rules

DAV03-DAV09 must run before EB03, EB14, EB20, EB26, EB33, or any UI-heavy EB implementation can pass product-experience Green. DAV10-DAV15 must run before EB35, EB38, and EB40 closeout claims.

