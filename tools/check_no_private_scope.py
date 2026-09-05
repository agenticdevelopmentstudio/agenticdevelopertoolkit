#!/usr/bin/env python3
"""No file in this public repo may name a private package or the product it came from.

The eight UI packages arriving here were extracted from a PRIVATE repo, and each
one arrives carrying whatever prose its old home had written about it. A README
whose first line is `# @agentic-toolkit/model` is an install instruction for a
package the reader cannot fetch, published under an Apache-2.0 licence that says
they may.

The per-package arrival checks scan `src/` only, which is where the imports are —
and imports are not where this leaks. It leaks in README.md, in CHANGELOG.md, in
a doc comment at the top of a config file: the files nobody greps because they do
not compile.

The scan runs in two tiers, because the patterns below are not all the same kind
of thing.

The FULL pattern set runs over four directories: `packages/web/packages` (the
library — the packages that arrived from the private repo), `recipes` and `docs`
(the prose that describes them), and `websites` (the demo sites, which ship too),
plus three root-level files a public reader opens first — `README.md`,
`AGENTS.md`, `.claude/CLAUDE.md`. These are the trees that hold shipped prose and
shipped code and nothing else this guard can tell apart from a leak.

The PRIVATE tier — every pattern except the product name — then sweeps whatever
those roots did not reach, which is most of the repo: `packages/apple`,
`packages/android`, `packages/terminal`, `packages/windows`, `cookbook/`,
`tools/`. Those four sibling package trees were scanned by nothing at all before,
so a private repo name could sit in the Swift client indefinitely with this guard
reporting a clean tree.

The product name is what keeps the tiers apart rather than merely widening the
roots. Those same sibling trees ship a client NAMED for the product and call its
PUBLIC API host: `AgenticDeveloperHubClient` and `api.agenticdeveloperhub.com` are
the thing itself, not a coordinate into anything private. Sweeping the product
name over them would condemn the product for existing. Every OTHER pattern names
the private repo, and those are a leak wherever they sit.

The wide sweep skips each guard's own source by filename, and the self-tests that
keep synthetic leak fixtures in theirs. A guard that hunts a string necessarily
contains that string — in its regex, and in the prose explaining what it catches
and why. The allowance is by filename and nothing wider: a leak in any other file
under `tools/` fires like anywhere else.

Passing `--roots` explicitly means "ask about these roots", so it runs the scoped
pass only. The wide sweep rides along with the default invocation, where the
question is "is this repo clean".

Five patterns, for five different failures:

  @agentic-toolkit/   a private package name. Fatal wherever it appears, including
                      in prose about a package that no longer exists — a public
                      repo should not be publishing another repo's history.
  agentictoolkit      the bare, unhyphenated name of the private REPOSITORY these
                      packages came from — the form that appears in prose rather
                      than in an import ("the sibling agentictoolkit repo's ...").
                      The scope pattern above only ever matched the hyphenated
                      package scope, so every prose mention of the repo walked
                      straight past it. Word-bounded on purpose: this repo's own
                      name (`agenticdevelopertoolkit`) and Swift module names that
                      merely start with it (`AgenticToolkitSync`) are not it.
  agenticdeveloperhub the product these packages were built for. The toolkit is
                      meant to be usable by anyone; a reference to the one product
                      it happens to serve is either a leak or a coupling, and both
                      are worth seeing.
  [adh]               a log/error prefix carrying the private product's name into
                      output a public consumer reads. It is a coordinate like any
                      other: it tells a stranger their build failed inside someone
                      else's product. A package prefixes with its OWN name.
  private repo paths  a filesystem path into a tree the reader does not have:
                      `backend/src/adh/src/lib/rdid.ts`,
                      `<adh-tools>/sites/scripts/verify_autofill_copies.py`,
                      `adh-site-config/content/help.en.json`.

The bracketed-prefix pattern is deliberately the bracketed form only. Bare `adh`
stays legal for the same reason the path pattern is about paths (below): naming
adh as a service is correct here. `[adh]` is not a mention of a service, it is
this code labelling its own output with a name that is not its own.

That third pattern is deliberately about PATHS and not about the word "adh". Naming
adh as a service is correct and this repo does it in twenty-one places on purpose —
`chat` exists to talk to adh's API, and "adh's chat endpoint carries a message and
nothing else" is exactly what a consumer needs to read. A CSS class called
`adh-mv-prose` is this toolkit's public API; a theme called `adh-comic` is shipped
branding. None of those are leaks and none of them are matched here.

Widening into `recipes/` turned up one more shape like it: every recipe's frontmatter
carries a `domain: agenticdeveloperhub://recipes/<slug>` field (and the same scheme in
`ingredients:`/`related:` cross-references) — the artifact format's own internal URI
namespace for the recipe corpus, present identically in every recipe this repo already
shipped before this task, resolving nowhere and naming no coordinate. It is not a
leak in the sense this guard exists to catch, any more than `adh-mv-prose` is, so the
product-name pattern below carves out exactly that one scheme shape and nothing wider —
a bare `agenticdeveloperhub` anywhere else, including `agenticdeveloperhub.com` or
`api.agenticdeveloperhub.com`, still fires.

A path is different in kind. It cannot be followed by anyone outside the private
repo, so it is useless to the reader it is addressed to, and it describes a layout
they were not given. Several of the comments carrying such paths do record something
worth keeping — that two copies of a list are pinned against each other by a parity
guard, and that editing one alone will be caught. Keep the invariant, drop the
coordinate: "a parity guard in the consuming application asserts these two copies
stay identical" says the useful half and names nothing unreachable.

Exit 0 clean, 1 on a hit, 2 if there was nothing to scan, or if a named root does
not exist — an empty scan (and a missing root looks exactly like one) is a broken
path, never a pass.
"""
from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_ROOTS = ("packages/web/packages", "recipes", "docs", "websites")
# Root-level files scanned with the FULL pattern set, named individually because
# the rest of the root gets the private tier only (see the docstring). A listed
# file that does not exist is skipped, not an error —
# these three are the ones this repo happens to ship; a fork of this guard might not
# ship all of them.
DEFAULT_FILES = ("README.md", "AGENTS.md", ".claude/CLAUDE.md")

PATTERNS = {
    "private package scope": re.compile(r"@agentic-toolkit/"),
    # The bare repo name, word-bounded (see the docstring): `agenticdevelopertoolkit`
    # is this repo and must not match, and neither must `AgenticToolkitSync`.
    "private repo name": re.compile(r"\bagentictoolkit\b", re.IGNORECASE),
    # (?!://recipes/) carves out the recipe corpus's own `agenticdeveloperhub://recipes/<slug>`
    # domain-URI scheme (see the docstring) — everything else still fires.
    "product name": re.compile(r"agenticdeveloperhub(?!://recipes/)", re.IGNORECASE),
    # A shipped log/error prefix naming the private product rather than the package
    # emitting it. Bracketed form only — bare `adh` is legitimate prose here.
    "private product log prefix": re.compile(r"\[adh\]", re.IGNORECASE),
    # The alternatives are eras, not synonyms: the guards moved out of adh's
    # `frontend/tools/` into adh-tools' `sites/scripts/` in 2026-09, so a leak
    # written today spells the new one and a leak written last month spells the
    # old. Both trees are equally absent from a public consumer's disk, so both
    # keep firing -- deleting the retired spelling would quietly stop catching
    # every comment already in the tree.
    "private repo path": re.compile(
        r"backend/src/(adh|builder|status)"
        r"|frontend/(src|tools)/"
        r"|\badh-tools[>/]"
        r"|\badh/(src|frontend)/"
        r"|adh-site-config",
        re.IGNORECASE,
    ),
}

SKIP_DIRS = {"node_modules", "dist", ".turbo", ".git", "coverage",
             # Git-ignored scratch: plan ledgers and captured review diffs,
             # which quote the very leaks this guard exists to remove and are
             # not part of what the repo publishes.
             ".superpowers"}

# Binary and lockfile noise: a lockfile legitimately names whatever the manifests
# name, and is regenerated rather than edited, so it is not where a leak is fixed.
SKIP_NAMES = {"pnpm-lock.yaml", "package-lock.json", "yarn.lock"}
SKIP_SUFFIXES = {
    ".png", ".jpg", ".jpeg", ".gif", ".webp", ".ico", ".svg",
    ".woff", ".woff2", ".ttf", ".otf", ".eot",
    ".pdf", ".zip", ".gz", ".map",
}


# The product name is legitimate branding outside the web tree: the sibling
# platform packages ship a client NAMED for the product and call its PUBLIC API
# host, so `AgenticDeveloperHubClient` and `api.agenticdeveloperhub.com` are the
# thing itself, not a coordinate into anything private. Every other pattern names
# the PRIVATE repo, and those are a leak wherever they sit — so they sweep
# repo-wide while the product name stays scoped to DEFAULT_ROOTS.
WIDE_PATTERNS = {k: v for k, v in PATTERNS.items() if k != "product name"}

# The wide sweep reaches tools/, where the guards' own self-tests keep synthetic
# leak fixtures in their source. Those strings are proof-of-behaviour, not
# references — skip the files rather than the strings inside them, the same way
# check_doc_links.py skips its own.
WIDE_SKIP_NAMES = {
    "check_no_private_scope_test.py",
    "check_doc_links_test.py",
    "check_recipe_scope_test.py",
    "check_doc_subpaths_test.py",
    # And the guards themselves. A guard that hunts a string necessarily contains
    # that string — in its regex, and in the prose explaining what it catches and
    # why. Those occurrences are the definition of the rule, not a violation of it;
    # scanning them would make every guard permanently unable to describe its own
    # job. This is a narrow allowance by FILENAME, so a leak in any other file
    # under tools/ still fires.
    "check_no_private_scope.py",
    "check_doc_links.py",
    "check_recipe_scope.py",
    "check_doc_subpaths.py",
}


def _scan_lines(text: str, rel: Path, patterns: dict | None = None) -> list[str]:
    hits: list[str] = []
    for lineno, line in enumerate(text.splitlines(), start=1):
        for label, pattern in (patterns or PATTERNS).items():
            if pattern.search(line):
                hits.append(f"{rel}:{lineno}: {label}: {line.strip()}")
    return hits


def scan(root: Path, seen: set[Path] | None = None) -> tuple[list[str], int]:
    """Scan one root with the full pattern set.

    `seen`, when given, collects every file actually read, so the repo-wide sweep
    can skip what this pass already covered.
    """
    hits: list[str] = []
    scanned = 0
    for path in sorted(root.rglob("*")):
        if not path.is_file():
            continue
        if any(part in SKIP_DIRS for part in path.parts):
            continue
        if path.name in SKIP_NAMES or path.suffix.lower() in SKIP_SUFFIXES:
            continue
        try:
            text = path.read_text(encoding="utf-8")
        except (UnicodeDecodeError, OSError):
            continue
        scanned += 1
        if seen is not None:
            seen.add(path)
        hits.extend(_scan_lines(text, path.relative_to(root)))
    return hits, scanned


def scan_file(path: Path, label_root: Path) -> tuple[list[str], int]:
    """Scan one DEFAULT_FILES entry. The caller decides what a missing file means
    (skip, per DEFAULT_FILES' contract) — this only scans what is actually there."""
    if path.name in SKIP_NAMES or path.suffix.lower() in SKIP_SUFFIXES:
        return [], 0
    try:
        text = path.read_text(encoding="utf-8")
    except (UnicodeDecodeError, OSError):
        return [], 0
    return _scan_lines(text, path.relative_to(label_root)), 1


def scan_wide(repo_root: Path, already: set[Path]) -> tuple[list[str], int]:
    """Sweep whatever the scoped roots did not reach, for the private tier only.

    `already` is the set of files the scoped pass read, so each file is checked by
    exactly one pass and a leak inside DEFAULT_ROOTS is never reported twice.
    """
    hits: list[str] = []
    scanned = 0
    for path in sorted(repo_root.rglob("*")):
        if not path.is_file() or path in already:
            continue
        if any(part in SKIP_DIRS for part in path.parts):
            continue
        if path.name in SKIP_NAMES or path.name in WIDE_SKIP_NAMES:
            continue
        if path.suffix.lower() in SKIP_SUFFIXES:
            continue
        try:
            text = path.read_text(encoding="utf-8")
        except (UnicodeDecodeError, OSError):
            continue
        scanned += 1
        hits.extend(_scan_lines(text, path.relative_to(repo_root), WIDE_PATTERNS))
    return hits, scanned


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "roots",
        nargs="*",
        type=Path,
        default=None,
        help=(
            "trees to scan (default: packages/web/packages, recipes, docs, "
            "websites, plus the individually-named README.md, AGENTS.md, and "
            ".claude/CLAUDE.md). A single per-package path — e.g. "
            "packages/web/packages/<pkg> — still works unchanged, but passing "
            "explicit roots replaces the default files too."
        ),
    )
    parser.add_argument(
        "--repo-root",
        default=None,
        help=(
            "base to resolve DEFAULT_ROOTS/DEFAULT_FILES against, instead of this "
            "script's own repo (self-test only — real usage never needs this)."
        ),
    )
    args = parser.parse_args()
    repo_root = Path(args.repo_root).resolve() if args.repo_root else REPO_ROOT

    roots = args.roots if args.roots else [repo_root / r for r in DEFAULT_ROOTS]
    # DEFAULT_FILES rides along only with the default invocation — explicit roots
    # on the command line replace DEFAULT_ROOTS and are not widened further.
    files = [repo_root / f for f in DEFAULT_FILES] if not args.roots else []

    all_hits: list[str] = []
    total_scanned = 0
    seen: set[Path] = set()
    for root in roots:
        if not root.exists():
            print(f"check_no_private_scope: no such path: {root}", file=sys.stderr)
            return 2

        hits, scanned = scan(root, seen)
        all_hits.extend(hits)
        total_scanned += scanned

    for file_path in files:
        if not file_path.exists():
            continue
        hits, scanned = scan_file(file_path, repo_root)
        all_hits.extend(hits)
        total_scanned += scanned
        seen.add(file_path)

    # The private tier sweeps the whole repo, not just the web tree: the sibling
    # platform packages were unpoliced, and a private repo name is a leak there
    # too. Rides along only with the default invocation — explicit roots mean the
    # caller is asking about those roots and nothing else.
    if not args.roots:
        hits, scanned = scan_wide(repo_root, seen)
        all_hits.extend(hits)
        total_scanned += scanned

    if total_scanned == 0:
        print(f"check_no_private_scope: nothing to scan under {roots}", file=sys.stderr)
        return 2

    if all_hits:
        print(f"check_no_private_scope: {len(all_hits)} leak(s) in {total_scanned} files:\n", file=sys.stderr)
        for hit in all_hits:
            print(f"  {hit}", file=sys.stderr)
        print(
            "\nThis repo is public. A private package name here is an install "
            "instruction the reader cannot follow.",
            file=sys.stderr,
        )
        return 1

    print(f"check_no_private_scope: {total_scanned} files, no private references")
    return 0


if __name__ == "__main__":
    sys.exit(main())
