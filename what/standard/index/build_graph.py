#!/usr/bin/env python3
"""build_graph.py — emit aDNA context graph as JSON.

Walks the triad of an aDNA vault, parses YAML frontmatter, identifies
wikilinks and markdown links, and emits a JSON graph at the specified path.

Used by:
- M-x adna-index-project (the elisp wraps this script)
- skill_adna_index.md (CLI invocation)
- skill_health_check.md check F (with --validate flag)

Usage:
    python3 build_graph.py --vault /path/to/vault.aDNA \\
                           --output what/standard/index/graph.json
    python3 build_graph.py --vault . --validate
"""

import argparse
import datetime
import json
import pathlib
import re
import sys

try:
    import yaml
except ImportError:
    print("ERROR: PyYAML required. Install with: pip install pyyaml", file=sys.stderr)
    sys.exit(1)


WIKILINK_RE = re.compile(r"\[\[([^\]\n]+)\]\]")
MD_LINK_RE = re.compile(r"\[[^\]\n]*\]\(([^)\s]+)\)")
FRONTMATTER_RE = re.compile(r"\A---\n(.*?)\n---\s*\n", re.DOTALL)
SKIP_DIRS = frozenset({".git", "node_modules", "__pycache__", ".venv", "venv",
                       ".obsidian", "_archive"})


def _json_default(obj):
    """JSON serializer for datetime.date/datetime, common in YAML frontmatter."""
    if isinstance(obj, (datetime.date, datetime.datetime)):
        return obj.isoformat()
    raise TypeError(
        f"Object of type {type(obj).__name__} is not JSON serializable")


def parse_frontmatter(text: str):
    """Return parsed frontmatter as dict (or {}) and the remainder of the text."""
    m = FRONTMATTER_RE.match(text)
    if not m:
        return {}, text
    try:
        meta = yaml.safe_load(m.group(1)) or {}
        if not isinstance(meta, dict):
            meta = {}
    except yaml.YAMLError:
        meta = {}
    return meta, text[m.end():]


def parse_links(text: str, current_rel: str):
    """Yield edge dicts for wikilinks and markdown-relative-links in TEXT."""
    for m in WIKILINK_RE.finditer(text):
        yield {"from": current_rel, "to": m.group(1).strip(), "kind": "wikilink"}
    for m in MD_LINK_RE.finditer(text):
        target = m.group(1).strip()
        if target.startswith(("http", "mailto:", "obsidian://", "#")):
            continue
        yield {"from": current_rel, "to": target, "kind": "references"}


def parse_frontmatter_refs(meta: dict, current_rel: str):
    """Yield edge dicts for path-like fields in frontmatter."""
    fields = ("supersedes", "superseded_by", "pattern_spec", "ratifies",
              "implementation_path", "ratified_by", "target_files",
              "charter_adr", "parity_reference")
    for field in fields:
        v = meta.get(field)
        if isinstance(v, str) and v:
            yield {"from": current_rel, "to": v, "kind": f"frontmatter_{field}"}
        elif isinstance(v, list):
            for item in v:
                if isinstance(item, str) and item:
                    yield {"from": current_rel, "to": item,
                           "kind": f"frontmatter_{field}"}


def should_skip(path: pathlib.Path, vault_root: pathlib.Path) -> bool:
    """True if PATH is in a skip directory or hidden by .gitignore-ish rules."""
    rel_parts = path.relative_to(vault_root).parts
    return any(p in SKIP_DIRS for p in rel_parts)


def walk_files(vault_root: pathlib.Path):
    """Yield content files (.md, .org, .yaml) under VAULT_ROOT."""
    for path in vault_root.rglob("*"):
        if not path.is_file():
            continue
        if should_skip(path, vault_root):
            continue
        if path.suffix.lower() not in (".md", ".org", ".yaml", ".yml"):
            continue
        yield path


def build_graph(vault_root: pathlib.Path) -> dict:
    nodes, edges = [], []
    for path in walk_files(vault_root):
        try:
            text = path.read_text(encoding="utf-8")
        except (OSError, UnicodeDecodeError):
            continue
        meta, body = parse_frontmatter(text)
        rel = str(path.relative_to(vault_root))
        nodes.append({
            "id": rel,
            "type": meta.get("type"),
            "tags": meta.get("tags") if isinstance(meta.get("tags"), list) else [],
            "created": meta.get("created"),
            "updated": meta.get("updated"),
            "status": meta.get("status"),
            "title": meta.get("title"),
        })
        if path.suffix.lower() in (".md", ".org"):
            edges.extend(parse_links(body, rel))
        edges.extend(parse_frontmatter_refs(meta, rel))
    return {
        "version": "1.0",
        "vault": vault_root.name,
        "generated": datetime.datetime.now(datetime.timezone.utc)
                                .strftime("%Y-%m-%dT%H:%M:%SZ"),
        "node_count": len(nodes),
        "edge_count": len(edges),
        "nodes": nodes,
        "edges": edges,
    }


def main():
    ap = argparse.ArgumentParser(
        description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--vault", default=".", help="Vault root (default: cwd)")
    ap.add_argument("--output", default="what/standard/index/graph.json",
                    help="Output path (relative to vault root or absolute)")
    ap.add_argument("--validate", action="store_true",
                    help="Self-validate: build graph, exit 60 if zero nodes")
    args = ap.parse_args()

    vault = pathlib.Path(args.vault).resolve()
    manifest = vault / "MANIFEST.md"
    if not manifest.exists():
        print(f"ERROR: {vault} does not look like an aDNA vault root "
              f"(no MANIFEST.md)", file=sys.stderr)
        sys.exit(2)

    graph = build_graph(vault)

    if args.validate:
        if graph["node_count"] == 0:
            print("FAIL: graph has zero nodes", file=sys.stderr)
            sys.exit(60)
        # Quick sanity: edges should reference existing nodes (where the edge
        # target is a path within the vault — wikilinks may not be paths)
        node_ids = {n["id"] for n in graph["nodes"]}
        path_edges = [e for e in graph["edges"]
                      if e["kind"] != "wikilink" and "/" in e["to"]]
        unresolved = [e for e in path_edges if e["to"] not in node_ids]
        print(f"validate OK: {graph['node_count']} nodes, "
              f"{graph['edge_count']} edges, "
              f"{len(unresolved)} edges with non-vault path targets "
              f"(expected for external/relative links)")
        return

    output = pathlib.Path(args.output)
    if not output.is_absolute():
        output = vault / output
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(
        json.dumps(graph, indent=2, ensure_ascii=False, default=_json_default))
    print(f"wrote {output} — {graph['node_count']} nodes, "
          f"{graph['edge_count']} edges")


if __name__ == "__main__":
    main()
