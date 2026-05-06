---
type: adr
adr_number: 006
title: "Sanitization WARNs in skill_l1_upgrade.md — upstream-PR disposition"
status: accepted
target: upstream
created: 2026-05-06
updated: 2026-05-06
last_edited_by: agent_stanley
supersedes:
superseded_by:
upstream_pr:
  repo: LatticeProtocol/Agentic-DNA
  url: https://github.com/LatticeProtocol/Agentic-DNA/pull/3
  status: open
tags: [adr, decision, sanitization, layer_contract, upstream_pr, p1_02]
---

# ADR-006: Sanitization WARNs in skill_l1_upgrade.md — upstream-PR disposition

## Status

Accepted (2026-05-06, Mission P1-02)

## Context

`skill_publish_lattice` (Step 3) runs the sanitization scan from `LAYER_CONTRACT.md § 4` against the full publish tree, which includes `how/skills/` (inherited `.adna/` template skills). Two WARNs fire on every dry-run, both originating in `how/skills/skill_l1_upgrade.md`:

| WARN | Location | Pattern | Match |
|------|----------|---------|-------|
| Private IPv4 | L230 (Phase 2 Step 3) | RFC 1918 `10.x.x.x` | `10.42.0.1` — Nebula lighthouse ping verification |
| Email address | L99 (Phase 1 Step 2) | `[user]@[domain].[tld]` | `git@github.com` — git SSH clone URL (false positive) |

**WARN #1 (private IPv4)**: `ping -c 2 10.42.0.1` is a Nebula overlay connectivity check. The IP `10.42.0.1` is used as a pedagogical example but is actually deployment-specific — the real lighthouse IP comes from the operator's `config.yml` provided by the Lattice admin. A placeholder is more accurate and removes the WARN.

**WARN #2 (git SSH URL)**: `git clone git@github.com:LatticeProtocol/latlab.git` uses the standard Git SSH remote format. The sanitization scanner's email regex (`[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}`) matches the `git@github.com` portion — a false positive. Git SSH URLs are not email addresses and carry no privacy risk.

Both patterns originate in the inherited `.adna/` base template (`adna/how/skills/skill_l1_upgrade.md`). Fixing them benefits all future aDNA forks.

## Decision

**Upstream-PR path** for both WARNs.

**WARN #1 — Fix**: Replace `10.42.0.1` with a `<lighthouse-ip>` placeholder in `skill_l1_upgrade.md`. The ping step context already explains that the IP comes from `config.yml`, so a placeholder is more accurate than a concrete RFC 1918 example.

**WARN #2 — Document**: The git SSH URL false positive is a known limitation of the current email regex. No content change to the skill — the SSH URL is pedagogically correct and necessary. `LAYER_CONTRACT.md` gains a `§ Known False Positives` subsection documenting this pattern, so future operators understand the WARN is expected and acknowledged.

Vault-local fix for WARN #1 applied immediately (vault owns its copy of `how/skills/`). Upstream PR opens the same fix in the `adna` template repo for all future forks.

## Consequences

### Positive
- `skill_publish_lattice` dry-run no longer emits the private IPv4 WARN
- Audit finding #5 closed; P1 phase gate unblocked
- Upstream PR improves all future aDNA forks
- LAYER_CONTRACT.md gains a known-false-positives reference for git SSH URLs

### Negative
- Upstream PR requires maintainer review cycle (non-blocking; vault fix applies immediately)
- `git@github.com` WARN still fires until upstream regex is tightened (acknowledged in LAYER_CONTRACT.md § Known False Positives)

### Neutral
- ADR lifecycle: this ADR stays `accepted` regardless of upstream PR merge timeline; the vault fix is the primary deliverable
- WARN #2 continues to appear in dry-runs on the SSH URL line; operators are expected to acknowledge it per the Known False Positives note
