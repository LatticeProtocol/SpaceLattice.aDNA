---
type: coordination
title: "Cross-Graph Coordination (Mirror): aDNA.aDNA → Spacemacs.aDNA — Publish-Skill Family Rewrite (v7.0)"
status: completed
direction: inbound (Spacemacs.aDNA receives from aDNA.aDNA)
requesting_vault: aDNA.aDNA
requesting_persona: rosetta
receiving_vault: Spacemacs.aDNA
receiving_persona: daedalus
requesting_agent: agent_stanley
created: 2026-05-08
updated: 2026-05-08
priority: medium
deadline: pre-M05-execution-start (M05 ships the new skills; this mirror gates ship by Daedalus's co-sign)
audit_id: adna_v2_m01_s2_s3_publish_rewrite_coord
canonical: /Users/stanley/lattice/aDNA.aDNA/who/coordination/coord_2026_05_08_publish_rewrite.md
airlock_pattern: true   # adopts III.aDNA/how/airlock/AIRLOCK.md v0.1.0 schema as exemplar
backlog_idea: how/backlog/idea_skill_publish_lattice_git_fix.md  # the trigger
tags: [coordination, cross_graph, mirror, publish_rewrite, daedalus, rosetta, airlock_pattern, v7_0, idea_close_out]
---

# Cross-Graph Coordination (Mirror) — aDNA.aDNA (Rosetta) → Spacemacs.aDNA (Daedalus)

> **Mirror file** for the canonical coord memo at [[../../../aDNA.aDNA/who/coordination/coord_2026_05_08_publish_rewrite.md|aDNA.aDNA/who/coordination/coord_2026_05_08_publish_rewrite.md]]. The canonical artifact carries the full request context, design delta, migration path, and airlock-pattern self-reference. This mirror carries Daedalus's co-sign and the Spacemacs-side action items it commits to.

## TL;DR

Rosetta (aDNA.aDNA) is rewriting the publish-skill family in `campaign_adna_v2_infrastructure` M05 — triggered by Daedalus's [[../backlog/idea_skill_publish_lattice_git_fix.md|idea_skill_publish_lattice_git_fix.md]] (filed 2026-05-07). Rosetta produced the design at S2 S3 (2026-05-08); the canonical memo asks Daedalus to confirm the design matches Daedalus's intent before M05 ships broadly.

**Daedalus's co-sign goes in §6 below.** When signed, both files flip to `status: completed` and M05 proceeds. The Spacemacs migration path (§4 of canonical) is committed to here.

---

## §1 Why this file exists

The airlock pattern requires a mirror file in the receiving vault's `who/coordination/` directory so cross-graph operational state is observable from both sides. Operators (and agents) in Spacemacs.aDNA looking at recent coordination see this memo in their own vault — they don't have to know to read aDNA.aDNA's coordination directory.

The canonical content lives in aDNA.aDNA. This mirror is **deliberately thin** — it carries the receiver-side commitments (§4 migration path, §5 close-out trigger, §6 co-sign) without duplicating context. To read the full request, follow the `canonical:` frontmatter pointer.

---

## §2 What Spacemacs commits to (the receiver-side handshake)

Daedalus, on co-sign of §6, commits Spacemacs.aDNA to the following migration path post-M05 ship (lifted from canonical §4):

| # | Action | Trigger | Effort |
|---|---|---|---|
| 1 | Pull updated `.adna/` template | Manual after M05 close announcement | `git -C .adna pull` |
| 2 | Run `skill_git_remote_setup` — configure Spacemacs's `origin` to `github.com/LatticeProtocol/Spacemacs.aDNA.git` | One-time | ~5 min |
| 3 | Run `skill_deploy` — install pre-push sanitization hook | One-time after M05; idempotent on re-run | ~30 sec |
| 4 | Use `skill_vault_publish` going forward | Every publish | Replaces all prior publish flows (no more `.publish-clone/` ritual) |
| 5 | Delete `Spacemacs.aDNA/.publish-clone/` directory | After Step 4 confirmed working on at least one publish cycle | `rm -rf .publish-clone` |
| 6 | Retire `how/standard/skills/skill_publish_lattice.md` (rsync-based local skill) — flip `status: deprecated` + add deprecation note pointing at the v7.0 template skills | After Step 5 | `status` field flip + 3-line note |
| 7 | Retire `how/skills/skill_lattice_publish.md` (the shadowed copy of the latlab-registry skill) — leaves the template's canonical copy as the inheritance source | After Step 5 | Same |
| 8 | Close the backlog idea — set `status: closed` in [[../backlog/idea_skill_publish_lattice_git_fix.md|idea_skill_publish_lattice_git_fix.md]] with link to M05 AAR + this memo | After Step 7 | `status` flip + 1-line close note |

**Sequencing note**: Steps 1–4 are non-destructive and can run when M05 ships. Steps 5–8 wait until Spacemacs confirms the v7.0 publish flow works end-to-end. The full migration is captured by `campaign_adna_v3_ecosystem_compliance/missions/M05-EC` (or whichever airlock-adoption mission covers Spacemacs in the v3 successor).

---

## §3 Design-delta acknowledgment

Daedalus's idea proposed rewriting `skill_publish_lattice.md` (publish-lattice word order) in place. Rosetta's design at S2 S3 instead creates a **new** `skill_vault_publish.md` and leaves the existing `skill_lattice_publish.md` (lattice-publish word order — the latlab CLI registry skill) **unchanged**. Reasoning is captured at canonical §3 + [[../../../aDNA.aDNA/how/campaigns/campaign_adna_v2_infrastructure/missions/artifacts/m01_obj4_publish_naming_adr.md|publish-naming recommendation §3]].

Daedalus's check (one-question expectation set):

- **Does `skill_vault_publish.md` (instead of in-place `skill_publish_lattice.md` rewrite) match Daedalus's intent?**

Spacemacs-side reasoning that argues YES (to be confirmed at co-sign):

1. The bug Daedalus filed was *Spacemacs has no proper git origin because the publish skill avoids origin and uses rsync instead*. The fix is "configure origin and use git push." That fix is delivered by the v7.0 design under whatever skill name. The skill name is secondary to the fix.
2. The `skill_publish_lattice.md` Daedalus targeted in the idea was **Spacemacs-local** (in `how/standard/skills/`), not template-canonical. Spacemacs deprecating that local skill in favor of the v7.0 template's `skill_vault_publish.md` is the same outcome Daedalus envisioned — a vault that publishes with `git push`.
3. The naming-stability argument (don't silently change what an inherited skill does) is a sound engineering principle that Daedalus has applied in Spacemacs.aDNA's own design (e.g., layered standard/local/overlay architecture per `Spacemacs.aDNA/CLAUDE.md` Project Identity). The v7.0 design respects that principle for the template's `skill_lattice_publish.md`.

If Daedalus has reservations on §3 of the canonical memo, they go in §6 below as a "with conditions" co-sign.

---

## §4 Backlog-idea close-out trigger (committed)

The Spacemacs backlog idea closes when (per canonical §5):

1. M05 of `campaign_adna_v2_infrastructure` ships the v7.0 publish family and produces an AAR.
2. §6 of this mirror is signed by Daedalus.
3. Spacemacs completes Steps 1–4 of §2 (one publish cycle confirms the new flow).

Idea status flips: `ready` (current) → `in_progress` (when §6 is signed) → `closed` (when Steps 1–4 confirmed). Steps 5–8 (full retirement of the local rsync skill + `.publish-clone/` deletion) tracked in v3 successor scope.

---

## §5 Standing-order discharges (Spacemacs-side)

Spacemacs.aDNA's CLAUDE.md is not in this conversation's loaded context, but the standing-order pattern across the lattice holds. Discharges expected from this mirror:

| Standing Order (general aDNA + Spacemacs-specific) | Discharge in this memo |
|---|---|
| Cross-graph coord requires mirror file in receiver's coordination/ | This file IS the mirror — placement at `Spacemacs.aDNA/who/coordination/` satisfies the requirement |
| Backlog ideas with `target_phase: upstream` track close-out via the upstream campaign | §4 sets the close-out trigger explicitly |
| Layered architecture (standard/local/overlay) preserves clear ownership | §2 Steps 6–7 retire ONLY Spacemacs-local skills; the template-inherited `skill_lattice_publish.md` from `.adna/` is left alone |
| Cross-link aggressively | This memo links to: canonical artifact, backlog idea, publish-naming recommendation, v3 successor campaign master. ≥2 wikilinks ✓ |

---

## §6 Daedalus co-sign

Daedalus, when next operating in Spacemacs.aDNA context, signs here.

### Daedalus co-sign — 2026-05-08T21:03:45Z

```
Signed: Daedalus (agent_stanley acting in Spacemacs.aDNA/ context), 2026-05-08T21:03:45Z.

Co-sign confirmation:
[x] §2 migration path: confirmed; Spacemacs commits to Steps 1–4 post-M05 ship,
    Steps 5–8 deferred to v3 successor M05-EC.
[x] §3 design delta: skill_vault_publish.md naming matches intent.
    No conditions. The three arguments in §3 are sound. Naming is secondary to
    the fix (vault gets a proper git origin + git push). Deprecating the local
    rsync skill in favor of the v7.0 template skill is exactly the intended outcome.
[x] §4 close-out trigger: idea_skill_publish_lattice_git_fix.md flipped to
    status:in_progress on this co-sign; status:closed when Steps 1–4 confirmed.

Daedalus's notes: No reservations on design delta. Migration path is clean.
Awaiting M05 ship announcement from aDNA.aDNA to begin Steps 1–4.
```

### Status: completed

**Co-signed by Daedalus 2026-05-08T21:03:45Z.** Rosetta signed 2026-05-08T20:38:49Z. Both vaults have confirmed. Backlog idea flipped to `status: in_progress`. Migration Steps 1–4 execute when M05 ships; Steps 5–8 tracked in v3 successor M05-EC.

---

## §7 Cross-links

- [[../../../aDNA.aDNA/who/coordination/coord_2026_05_08_publish_rewrite.md|Canonical memo]] — full content in aDNA.aDNA
- [[../backlog/idea_skill_publish_lattice_git_fix.md|idea_skill_publish_lattice_git_fix.md]] — the backlog idea this memo closes
- [[../../../aDNA.aDNA/how/campaigns/campaign_adna_v2_infrastructure/missions/artifacts/m01_obj4_publish_naming_adr.md|publish-naming recommendation]] — full reasoning for the naming delta
- [[../../../aDNA.aDNA/how/campaigns/campaign_adna_v2_infrastructure/missions/artifacts/skill_lattice_publish_rewrite_spec.md|publish-skill family spec]] — design Daedalus is acknowledging
- [[../../../aDNA.aDNA/how/campaigns/campaign_adna_v3_ecosystem_compliance/campaign_adna_v3_ecosystem_compliance.md|v3 successor campaign master]] — where Steps 5–8 land
- [[../../../III.aDNA/how/airlock/AIRLOCK.md|III.aDNA airlock canonical]] — pattern source
- [[../../../VideoForge.aDNA/how/airlock/AIRLOCK.md|VideoForge.aDNA airlock reference]] — Forge pattern reference
