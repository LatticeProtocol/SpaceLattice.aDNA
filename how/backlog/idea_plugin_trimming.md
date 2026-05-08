---
type: backlog_idea
status: planned
priority: high
created: 2026-04-04
updated: 2026-05-06
last_edited_by: agent_stanley
plan_id: p3_09
tags: [backlog, obsidian, performance, clone-size]
---

# Idea: Obsidian Plugin Trimming

## Problem
Spacemacs.aDNA ships an `.obsidian/` config with 15 plugins (13MB, ~87% of the `.obsidian/` directory). Most are cosmetic. New operators clone 13MB of plugins they may never enable. Clone time and disk space impacted.

## Proposed Solution (Spacemacs-scoped)
Audit `.obsidian/plugins/` within this vault. Ship only the essentials needed for aDNA wikilink navigation and context-graph work:
- **Keep**: `obsidian-advanced-canvas` (canvas round-trip), `templater-obsidian` (template system)
- **Optional**: `obsidian-tasks-plugin` (mission tracking, if operator uses it)
- **Document remaining 12 as optional** in `what/local/README.md` or a new `what/local/obsidian_optional_plugins.md`
- Operator must test Obsidian UX (especially wikilink resolution) after trimming before committing

Target: ~1.5MB shipped, ~11.5MB moved to optional docs.

## Routing
New mission P3-09 (Obsidian plugin audit) — added to Phase 3 at P1-01 backlog audit 2026-05-06. Opens after P3-08.

## Origin
Inherited from campaign_adna_polish pre-merge efficiency audit. Scoped to Spacemacs at P1-01 backlog audit 2026-05-06.
