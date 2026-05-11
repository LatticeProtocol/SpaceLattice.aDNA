---
type: backlog_idea
status: deferred
priority: high
created: 2026-04-04
updated: 2026-05-11
last_edited_by: agent_stanley
plan_id: post_v1_0
deferred_reason: post-v1.0 per p5_gap_register GAP-10
tags: [backlog, visual, readme, onboarding]
---

# Idea: Demo GIF for README

## Problem
README describes the adna layer and `SPC a` menu but provides no visual proof. Top GitHub repos show the tool working — a GIF cuts through skepticism faster than prose.

## Proposed Solution (Spacemacs-scoped)
Record a 30-45 second terminal GIF showing the Spacemacs flow: `M-x adna-index-project` → graph.json emitted → `SPC a i` opens the adna index → wikilink navigation. Embed in README after the Install section. Tool: `asciinema` + `agg` for GIF conversion, or `vhs`.

## Routing
Phase 5 doc pass (mission_sl_p5_01_doc_pass). Add as P5-01 sub-task when that mission opens.

## Origin
Inherited from campaign_adna_polish V-05. Scoped to Spacemacs at P1-01 backlog audit 2026-05-06.
