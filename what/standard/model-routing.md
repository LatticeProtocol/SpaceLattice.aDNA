---
type: policy
status: active
created: 2026-05-03
updated: 2026-05-03
last_edited_by: agent_init
tags: [policy, models, routing, claude, llama, ollama, standard]
---

# Model routing policy

Decides which model Spacemacs invokes for a given operation. Two routes coexist:

1. **Claude Code (`SPC c c`)** — Spacemacs spawns the `claude` CLI in a vterm at the nearest aDNA root. Routing happens inside Claude Code itself per the user's `~/.claude/settings.json`. Spacemacs is just the launcher.
2. **In-Emacs LLM calls** — when Emacs functions need an LLM directly (e.g., a future `adna/explain-frontmatter` command), use the precedence below.

## Precedence (in-Emacs route)

| Tier | Provider | Use when |
|------|----------|----------|
| 1 | Claude API (anthropic-sdk via http) | Default. Models specified in `who/operators/<operator>.md` `primary_models`. |
| 2 | Local llama.cpp | When operator sets `(setq adna-prefer-local t)` in `what/local/operator.private.el`, OR when offline |
| 3 | Ollama | Same as Tier 2 — operator picks one or the other |
| 4 | Other (OpenAI, Gemini, etc.) | Off by default. Operator opts in via `what/local/operator.private.el` |

## Model selection by task

| Task class | Default model | Why |
|-----------|---------------|-----|
| Heavy reasoning (planning, ADR drafting via skill_self_improve) | `claude-opus-4-7` | Maximum capability |
| Routine refactor / small edits | `claude-sonnet-4-6` | Cheaper, fast enough |
| Trivia / completion | `claude-haiku-4-5` | Cheap, very fast |
| Offline / privacy-sensitive | `llama-3.3-70b-instruct` (or operator's local pin) | No network |

## Secrets

API keys live in `what/local/secrets.env` (gitignored). `what/local/secrets.env.example` is the committed template.

Loading order in `dotspacemacs/user-init`:

1. If `what/local/secrets.env` exists, source it into Emacs `process-environment`
2. If not, log to `*Messages*` that no secrets are loaded — in-Emacs LLM calls will fail until operator creates secrets.env

## Rate-limit + cost discipline

The vault doesn't track LLM costs directly. Operators wanting cost telemetry should:

1. Add a layer like `(setq adna-log-llm-calls t)` in `what/local/operator.private.el`
2. Inspect `~/.claude/logs/` for Claude Code call logs

`skill_self_improve` (Phase 5) is the most expensive recurring caller. When it runs, it batches its session-note read into one prompt rather than streaming.

## Cross-graph operations

When Spacemacs is editing a file in another aDNA vault (e.g., `RareHarness.aDNA`), the `adna-vault-root` becomes that other vault. Model routing still uses *this* vault's policy unless the other vault has its own `model-routing.md` — in which case `adna/find-vault-root` honors the nearest one. Cross-vault calls don't share secrets.

## Promotion

Changes to this policy go through ADR (per `LAYER_CONTRACT.md`). The most likely friction signal `skill_self_improve` will catch is repeated rate-limit errors → propose route adjustment.
