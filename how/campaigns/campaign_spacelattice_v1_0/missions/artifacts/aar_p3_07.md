---
type: aar
mission_id: mission_sl_p3_07_wild_workarounds_org
session_id: session_sl_p3_07_2026_05_08
created: 2026-05-08
last_edited_by: agent_stanley
---

# AAR — P3-07: Wild customizations + canonical workarounds + org-mode power-user

**Worked**: All three §3.1/§3.2/§3.3 walks completed in one session. Operator decided on all 11 workaround questions; full §3.3 org-mode config specified. Template updates (layers, user-init, §P3-07 user-config section) all land cleanly with balanced parens. Vault-local `org/` directory created with seed files (inbox.org, work.org, .gitignore for .roam.db).

**Didn't**: Ivy stale-prompts workaround was asked about despite the operator having confirmed helm (not ivy) in P3-05. The question framing was incorrect. Caught and corrected as a finding; helm-specific stability knobs added instead.

**Finding**: §3.1 layer adoption was broad (5 stacks: Python/DS, Notes/roam, DevOps, Web, Email). Several of these (kubernetes, ansible, ipython-notebook, html, mu4e) add real install dependencies. The mu4e layer specifically requires `brew install mu` + isync — this should be documented in `how/standard/runbooks/macos_setup.md` (P3-12 scope).

**Change**: Added a "pre-assess from prior mission decisions before building the §3.2 question list" step to the 7-step customization protocol — avoids asking about stack-incompatible workarounds.

**Follow-up**: (1) P3-12 macOS platform context runbook should include mu4e + mu setup instructions. (2) Org-journal style deferred — revisit after 2-3 weeks of inbox.org/work.org usage. (3) §3.3 org-roam protocol requires a browser extension install; document in macos_setup.md runbook.
