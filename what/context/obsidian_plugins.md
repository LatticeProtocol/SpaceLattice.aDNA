---
type: context
status: active
created: 2026-05-08
updated: 2026-05-08
last_edited_by: agent_stanley
tags: [context, obsidian, plugins, configuration, p3_09]
---

# Obsidian Plugins — Spacemacs.aDNA

Audit completed P3-09 (2026-05-08). Trimmed from 15 → 2 tracked plugins.

## Tracked (installed on all machines)

| Plugin | ID | Why |
|--------|----|-----|
| Advanced Canvas | `obsidian-advanced-canvas` | Canvas round-trip required for CanvasForge consumer federation |
| Templater | `templater-obsidian` | Template system for mission/session/context file scaffolding |

Install: present in `.obsidian/community-plugins.json`; Obsidian installs automatically on vault open.

## Optional — install if needed

These were in the tracked set but removed as non-essential for core vault function. Install manually via Obsidian's community plugin browser.

| Plugin | ID | Use case |
|--------|----|---------|
| Dataview | `dataview` | SQL-like queries across vault (useful for cross-linking missions/ADRs) |
| Tasks | `obsidian-tasks-plugin` | Task tracking in markdown (we use org-mode for tasks; redundant for most workflows) |
| Fold Properties | `fold-properties-by-default` | Auto-fold YAML frontmatter on open |
| Settings Search | `settings-search` | Search within Obsidian settings panel |
| Homepage | `homepage` | Configure a vault landing page |
| Style Settings | `obsidian-style-settings` | CSS variable controls for theme customization |
| Pretty Properties | `pretty-properties` | Enhanced property display in reading view |
| Notebook Navigator | `notebook-navigator` | Alternative notebook-style navigation pane |
| Icon Folder | `obsidian-icon-folder` | Custom folder icons |
| Table Editor | `table-editor-obsidian` | Advanced table editing |

## Removed entirely

These were removed as redundant or development-only tools.

| Plugin | ID | Reason |
|--------|----|--------|
| BRAT | `obsidian42-brat` | Beta plugin installer — dev use only; not needed in production vault |
| Termy | `termy` | Terminal in Obsidian — vterm in Spacemacs covers all terminal needs |
| Meta Bind | `obsidian-meta-bind-plugin` | Complex UI/metadata binding — not in active use |
