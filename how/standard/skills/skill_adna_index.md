---
type: skill
skill_type: agent
status: active
created: 2026-05-03
updated: 2026-05-03
last_edited_by: agent_init
category: indexing
trigger: "Operator wants context graph rebuilt; or skill_self_improve needs the graph fresh; or after any large set of vault edits."
phase_introduced: 4
tags: [skill, index, graph, lattice, daedalus]
requirements:
  tools: [python3, "PyYAML (pip install pyyaml)"]
  context:
    - what/standard/index/build_graph.py
  permissions:
    - "read all of vault"
    - "write what/standard/index/graph.json"
---

# skill_adna_index — rebuild the vault's context graph

## Purpose

Walk the triad, parse every markdown/org/yaml file's frontmatter and links, emit a JSON graph at `what/standard/index/graph.json`. Two callers use this:

- **From inside Emacs** — `M-x adna-index-project` (in `funcs.el`) shells out to `python3 build_graph.py`
- **From outside Emacs** — direct invocation: `python3 what/standard/index/build_graph.py --vault . --output what/standard/index/graph.json`

Both produce identical output. The Python CLI is the canonical implementation; the elisp is a thin wrapper.

## Why a Python script and not pure elisp?

Three reasons:
1. PyYAML is more battle-tested than emacs-yaml at parsing the frontmatter we see in this workspace
2. Same script can be invoked by CI, agents, or batch jobs that don't have Emacs
3. `build_graph.py` is testable in isolation (run it from any shell, diff outputs)

The Emacs side simply shells out and re-reads the produced JSON.

## Steps

### Run the script

```bash
cd <vault-root>
python3 what/standard/index/build_graph.py --vault . --output what/standard/index/graph.json
```

Output line: `wrote .../graph.json — N nodes, M edges`.

### Validate the output

```bash
python3 what/standard/index/build_graph.py --vault . --validate
```

This is the same walk but doesn't write a file. Exits non-zero if zero nodes (vault is broken). Used by `skill_health_check` check F.

### Inspect the graph

```bash
python3 -c "import json; g=json.load(open('what/standard/index/graph.json')); print(json.dumps(g,indent=2)[:500])"
```

Or open in Spacemacs: `SPC a g` (calls `adna/render-lattice-graph`).

## Output schema

```json
{
  "version": "1.0",
  "vault": "SpaceLattice.aDNA",
  "generated": "2026-05-03T22:30:00Z",
  "node_count": 305,
  "edge_count": 412,
  "nodes": [
    {
      "id": "what/decisions/adr/adr_000_vault_identity.md",
      "type": "decision",
      "tags": ["decision", "adr", "identity", ...],
      "created": "2026-05-03",
      "updated": "2026-05-03",
      "status": "accepted",
      "title": "Vault identity, persona, layered architecture, and publish target"
    },
    ...
  ],
  "edges": [
    {"from": "...", "to": "...", "kind": "wikilink"},
    {"from": "...", "to": "...", "kind": "references"},
    {"from": "...", "to": "...", "kind": "frontmatter_supersedes"},
    ...
  ]
}
```

## Edge kinds

| Kind | Source | Notes |
|------|--------|-------|
| `wikilink` | `[[Target]]` in markdown body | May not resolve to a path; left as-is for downstream tools |
| `references` | `[text](path)` in markdown body | Skips http/https/mailto/obsidian://# |
| `frontmatter_supersedes` | YAML field | ADR supersession |
| `frontmatter_superseded_by` | YAML field | Reverse of above |
| `frontmatter_pattern_spec` | YAML field | Pattern spec citation |
| `frontmatter_ratifies` | YAML field | ADR-ratified items |
| `frontmatter_implementation_path` | YAML field | Spec → implementation pointer |
| `frontmatter_target_files` | YAML field (list) | ADR's target file set |

## What's skipped

- Hidden directories (`.git/`, `.obsidian/`, `__pycache__/`, etc.)
- Non-content files (binaries, images, lock files)
- Inherited template files in `.adna/` if it exists at vault root (not the case here)

## Failure modes

| Failure | Cause | Recovery |
|---------|-------|----------|
| `PyYAML required` | python3 has no yaml package | `pip install pyyaml` (or use system pkg) |
| `not an aDNA vault root` | Wrong cwd | `cd` to a dir with MANIFEST.md |
| Validate exits 60 | Zero nodes | Vault is broken; structure check first via `skill_health_check` A |
| Frontmatter parse error | Malformed YAML in some file | Script silently skips; `skill_health_check` B will flag |

## Self-improvement signal

If `skill_self_improve` notices the graph hasn't been rebuilt in N sessions but the vault has changed substantially, it nudges via SITREP. No auto-rebuild — operator decides.
