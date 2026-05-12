---
type: runbook
status: active
created: 2026-05-12
updated: 2026-05-12
last_edited_by: agent_stanley
tags: [runbook, publish, release, v1_0, operator_gated]
---

# v1.0.0 Publish Checklist

Operator-gated steps to publish the local v1.0.0 tag to GitHub and create the release. The vault currently has no configured git remote. Run these steps in order when ready to publish.

---

## Step 1 — Configure the remote (if not already done)

```bash
git remote add origin https://github.com/LatticeProtocol/Spacemacs.aDNA.git
git remote -v   # verify
```

---

## Step 2 — Push the branch

```bash
git push -u origin master
```

Verify the push succeeds before proceeding.

---

## Step 3 — Push the v1.0.0 tag

```bash
git push origin v1.0.0
```

Tag was created locally on commit `57d289c` (P5-05 doc pass, 2026-05-11).

---

## Step 4 — Create the GitHub release

```bash
gh release create v1.0.0 \
  --title "Spacemacs.aDNA v1.0.0" \
  --notes "$(awk '/^\#\# \[1\.0\.0\]/,/^\#\# \[/' CHANGELOG.md | head -n -1)" \
  --latest
```

Or manually via GitHub UI: Releases → Draft a new release → tag `v1.0.0` → paste CHANGELOG.md `[1.0.0]` section as release notes.

Explicitly note in release body:
- Audit finding #7 (peer federation) deferred to post-v1.0
- P5-06 (second-machine install receipt) deferred to post-v1.0

---

## Step 5 — Fork tag (LatticeProtocol/spacelattice)

The sibling Spacemacs fork at `LatticeProtocol/spacelattice` has no LP-specific commits yet (vault-only model per ADR-024). The `lp-stable` branch update and `latticeprotocol-1.0.0` tag are deferred until the fork accumulates LP-specific work.

When ready:
```bash
# Requires a local clone of the fork
cd ~/lattice/spacelattice    # or wherever the fork is cloned
git tag -a latticeprotocol-1.0.0 -m "SpaceLattice distribution v1.0.0"
git push origin latticeprotocol-1.0.0
git push origin develop:lp-stable
```

---

## Post-publish verification

- [ ] `https://github.com/LatticeProtocol/Spacemacs.aDNA/releases/tag/v1.0.0` resolves
- [ ] Release notes show [1.0.0] content from CHANGELOG.md
- [ ] `git clone https://github.com/LatticeProtocol/Spacemacs.aDNA.git` + `skill_install` succeeds on a clean host (Campaign B — P5-06 rerun)
