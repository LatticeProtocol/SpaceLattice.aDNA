---
type: backlog_idea
status: deferred
priority: low
created: 2026-04-04
updated: 2026-05-11
last_edited_by: agent_stanley
plan_id: post_v1_0
deferred_reason: post-v1.0 per p5_gap_register GAP-12
tags: [backlog, performance, agent-efficiency]
---

# Idea: Startup Sequence Optimization

## Problem
Spacemacs.aDNA agent cold-start loads CLAUDE.md + MANIFEST.md + STATE.md with significant overlap: the base ontology table, triad description, and project identity are partially duplicated. Reducing this overlap reduces time-to-first-useful-output for agents.

## Proposed Solution (Spacemacs-scoped)
Audit CLAUDE.md vs. MANIFEST.md for duplicated content specific to this vault. Consolidate without reducing information density. Candidates:
- Move ontology table reference to MANIFEST.md only (CLAUDE.md points to it)
- Merge first-run detection signal into CLAUDE.md frontmatter field (avoid separate read)
- Target: ~400-900 token reduction in cold-start context

Do NOT apply to the base template (`.adna/`) — this optimization is vault-specific.

## Routing
Phase 5 doc pass (mission_sl_p5_01_doc_pass). Add as P5-01 sub-task alongside the demo-gif sub-task.

## Origin
Inherited from campaign_adna_polish pre-merge efficiency audit. Scoped to Spacemacs at P1-01 backlog audit 2026-05-06.
