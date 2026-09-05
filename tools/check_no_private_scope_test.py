#!/usr/bin/env python3
"""Self-test: the private-scope guard must catch what the src-only greps missed.

Every case here is a real shape from the migration. The README case is the one
that motivated the guard — it passed eight src-scoped greps.
"""
import subprocess
import sys
import tempfile
from pathlib import Path

GUARD = Path(__file__).resolve().parent / "check_no_private_scope.py"


def run(root: Path) -> subprocess.CompletedProcess:
    return subprocess.run(
        [sys.executable, str(GUARD), str(root)],
        capture_output=True,
        text=True,
    )


def run_default(repo_root: Path) -> subprocess.CompletedProcess:
    """Invoke the guard's default (no positional roots) code path, but pointed at a
    throwaway repo_root via --repo-root instead of this script's own repo — the
    only way to exercise DEFAULT_ROOTS/DEFAULT_FILES without editing real files."""
    return subprocess.run(
        [sys.executable, str(GUARD), "--repo-root", str(repo_root)],
        capture_output=True,
        text=True,
    )


def _stub_default_roots(repo_root: Path) -> None:
    """The default invocation scans DEFAULT_ROOTS alongside DEFAULT_FILES — stub
    them out as empty dirs so a DEFAULT_FILES test doesn't also need real
    package/recipe/doc content to scan."""
    for rel in ("packages/web/packages", "recipes", "docs", "websites"):
        (repo_root / rel).mkdir(parents=True, exist_ok=True)


def test_clean_tree_passes() -> None:
    with tempfile.TemporaryDirectory() as tmp:
        root = Path(tmp)
        (root / "src").mkdir()
        (root / "src" / "index.ts").write_text(
            "export { thing } from '@agenticdevelopertoolkit/model'\n", encoding="utf-8"
        )
        (root / "README.md").write_text("# @agenticdevelopertoolkit/model\n", encoding="utf-8")
        result = run(root)
        assert result.returncode == 0, f"clean tree rejected: {result.stderr}"


def test_readme_leak_is_caught() -> None:
    """The motivating case: prose outside src/, which no arrival grep looked at."""
    with tempfile.TemporaryDirectory() as tmp:
        root = Path(tmp)
        (root / "src").mkdir()
        (root / "src" / "index.ts").write_text("export const a = 1\n", encoding="utf-8")
        (root / "README.md").write_text("# @agentic-toolkit/model\n", encoding="utf-8")
        result = run(root)
        assert result.returncode == 1, "README leak survived the guard"
        assert "README.md:1" in result.stderr, result.stderr


def test_product_name_is_caught() -> None:
    with tempfile.TemporaryDirectory() as tmp:
        root = Path(tmp)
        (root / "src").mkdir()
        (root / "src" / "site.ts").write_text(
            "// built for agenticdeveloperhub\n", encoding="utf-8"
        )
        result = run(root)
        assert result.returncode == 1, "product name survived the guard"
        assert "product name" in result.stderr, result.stderr


def test_private_repo_path_is_caught() -> None:
    """A comment giving coordinates into a repo the reader does not have."""
    cases = [
        "// A MIRROR of backend/src/adh/src/lib/rdid.ts, pinned by a parity guard.\n",
        "// `<adh-tools>/sites/scripts/verify_autofill_copies.py` is what holds the copies together.\n",
        "/* Route-keyed, over adh-site-config/content/help.en.json. */\n",
        "// NOT adh/src/help/store.ts, which is easy to mistake this for.\n",
    ]
    for source in cases:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            (root / "src").mkdir()
            (root / "src" / "thing.ts").write_text(source, encoding="utf-8")
            result = run(root)
            assert result.returncode == 1, f"path survived the guard: {source!r}"
            assert "private repo path" in result.stderr, result.stderr


def test_private_repo_name_is_caught() -> None:
    """The bare, unhyphenated name of the private REPOSITORY.

    The scope pattern only ever matched `@agentic-toolkit/` — an import specifier.
    The repo is named in PROSE, unhyphenated, and every such mention walked past a
    guard that reported "no private references" over five live ones. All four
    shapes below are verbatim from the tree the guard was green on.
    """
    cases = [
        "// the sibling `agentictoolkit` repo's `chat-status.ts` exports one that adds tags\n",
        '"comment:lint": "In agentictoolkit, `lint` failed on pre-existing type rot."\n',
        "# the same Model A contract as `agentictoolkit`\n",
        '"face. If the agentictoolkit submodule is not checked out, run "\n',
        "/// Vendored from agentictoolkit's `KeychainHelper`.\n",
    ]
    for source in cases:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            (root / "src").mkdir()
            (root / "src" / "thing.ts").write_text(source, encoding="utf-8")
            result = run(root)
            assert result.returncode == 1, f"private repo name survived: {source!r}"
            assert "private repo name" in result.stderr, result.stderr


def test_private_repo_name_is_case_insensitive() -> None:
    """`AgenticToolkit` is the same repository with a capital letter on it — a
    README saying "ported from the macOS AgenticToolkit" is the same coordinate."""
    with tempfile.TemporaryDirectory() as tmp:
        root = Path(tmp)
        (root / "src").mkdir()
        (root / "src" / "README.md").write_text(
            "A web port of the `LogView` model from the macOS AgenticToolkit.\n",
            encoding="utf-8",
        )
        result = run(root)
        assert result.returncode == 1, f"capitalised repo name survived: {result.stderr}"
        assert "private repo name" in result.stderr, result.stderr


def test_repo_name_pattern_is_word_bounded() -> None:
    """The negative half, and the reason for the `\\b`: THIS repo is
    `agenticdevelopertoolkit`, its packages are `@agenticdevelopertoolkit/*`, and a
    Swift module may merely start with the private name (`AgenticToolkitSync`). A
    pattern without word boundaries would fire on all of them and be deleted."""
    with tempfile.TemporaryDirectory() as tmp:
        root = Path(tmp)
        (root / "src").mkdir()
        (root / "src" / "index.ts").write_text(
            "export { Button } from '@agenticdevelopertoolkit/ui'\n"
            "// agenticdevelopertoolkit ships these packages\n"
            "// AgenticToolkitSync is a module name, not a bare repo mention\n",
            encoding="utf-8",
        )
        result = run(root)
        assert result.returncode == 0, f"false positive on this repo's own name: {result.stderr}"


def test_private_product_log_prefix_is_caught() -> None:
    """`[adh]` on a thrown Error is the private product's name in output a public
    consumer reads. A package labels its own output with its own name."""
    with tempfile.TemporaryDirectory() as tmp:
        root = Path(tmp)
        (root / "src").mkdir()
        (root / "src" / "fonts.mjs").write_text(
            "throw new Error(`[adh] cannot create ${dest}.`)\n", encoding="utf-8"
        )
        result = run(root)
        assert result.returncode == 1, f"[adh] prefix survived the guard: {result.stderr}"
        assert "private product log prefix" in result.stderr, result.stderr


def test_log_prefix_pattern_is_the_bracketed_form_only() -> None:
    """The negative half: bare `adh` in prose is legitimate here (see the docstring
    and test_naming_adh_as_a_service_is_not_a_leak), and a package prefixing with
    its OWN name must stay clean."""
    with tempfile.TemporaryDirectory() as tmp:
        root = Path(tmp)
        (root / "src").mkdir()
        (root / "src" / "fonts.mjs").write_text(
            "// adh's chat endpoint carries a message and nothing else.\n"
            "throw new Error(`[@agenticdevelopertoolkit/themes] cannot create ${dest}.`)\n",
            encoding="utf-8",
        )
        result = run(root)
        assert result.returncode == 0, f"false positive on a self-named prefix: {result.stderr}"


def test_naming_adh_as_a_service_is_not_a_leak() -> None:
    """The narrow half of the rule, and the reason the pattern is about paths.

    `chat` exists to talk to adh's API and says so in twenty-one places. A CSS class
    is public API; a theme name is branding; a fixture is sample data. A guard that
    fired on these would be turned off within a week, and it would deserve to be.
    """
    with tempfile.TemporaryDirectory() as tmp:
        root = Path(tmp)
        (root / "src").mkdir()
        (root / "src" / "backend.ts").write_text(
            "// adh's chat endpoint carries a message and nothing else.\n"
            "const cls = 'adh-mv-prose'\n"
            "const theme = 'adh-comic'\n"
            "const fixture = { orgSlug: 'adh', badge: 'ADH-42' }\n",
            encoding="utf-8",
        )
        result = run(root)
        assert result.returncode == 0, f"false positive on legitimate adh prose: {result.stderr}"


def test_node_modules_and_lockfiles_are_skipped() -> None:
    """A vendored dep naming the private scope is not this repo's leak to fix."""
    with tempfile.TemporaryDirectory() as tmp:
        root = Path(tmp)
        (root / "node_modules" / "dep").mkdir(parents=True)
        (root / "node_modules" / "dep" / "index.js").write_text(
            "require('@agentic-toolkit/ui')\n", encoding="utf-8"
        )
        (root / "dist").mkdir()
        (root / "dist" / "index.js").write_text("'@agentic-toolkit/ui'\n", encoding="utf-8")
        (root / "pnpm-lock.yaml").write_text("'@agentic-toolkit/ui':\n", encoding="utf-8")
        (root / "src").mkdir()
        (root / "src" / "index.ts").write_text("export const a = 1\n", encoding="utf-8")
        result = run(root)
        assert result.returncode == 0, f"skipped trees were scanned: {result.stderr}"


def test_multiple_roots_are_all_scanned() -> None:
    """Step 13 widened the guard from one default root to four. Prove the multi-root
    path actually scans every root passed, not just the first — a hit in a
    docs-shaped second root must fail the run exactly like one in the first."""
    with tempfile.TemporaryDirectory() as tmp:
        packages_root = Path(tmp) / "packages"
        docs_root = Path(tmp) / "docs"
        packages_root.mkdir()
        docs_root.mkdir()
        (packages_root / "index.ts").write_text("export const a = 1\n", encoding="utf-8")
        (docs_root / "guide.md").write_text(
            "See `@agentic-toolkit/ui` for the source component.\n", encoding="utf-8"
        )
        result = subprocess.run(
            [sys.executable, str(GUARD), str(packages_root), str(docs_root)],
            capture_output=True, text=True,
        )
        assert result.returncode == 1, f"docs-root leak survived a multi-root scan: {result.stderr}"
        assert "guide.md:1" in result.stderr, result.stderr


def test_empty_scan_is_not_a_pass() -> None:
    """A guard that greens on a wrong path is worse than no guard."""
    with tempfile.TemporaryDirectory() as tmp:
        root = Path(tmp) / "nope"
        result = run(root)
        assert result.returncode == 2, f"missing path returned {result.returncode}"

        empty = Path(tmp) / "empty"
        empty.mkdir()
        result = run(empty)
        assert result.returncode == 2, f"empty tree returned {result.returncode}"


def test_default_files_readme_leak_is_caught() -> None:
    """Fix 2, Step 6: DEFAULT_FILES widens the default invocation with three
    root-level files scanned individually, without widening to the repo root.
    Mirrors test_multiple_roots_are_all_scanned, but for the new file-shaped scan."""
    with tempfile.TemporaryDirectory() as tmp:
        repo_root = Path(tmp)
        _stub_default_roots(repo_root)
        (repo_root / "README.md").write_text(
            "# @agentic-toolkit/model\n", encoding="utf-8"
        )
        result = run_default(repo_root)
        assert result.returncode == 1, f"README.md leak survived the default scan: {result.stderr}"
        assert "README.md:1" in result.stderr, result.stderr


def test_default_files_missing_entry_is_skipped() -> None:
    """A DEFAULT_FILES entry that does not exist (AGENTS.md and .claude/CLAUDE.md,
    in this fixture) is skipped rather than erroring — only README.md is present."""
    with tempfile.TemporaryDirectory() as tmp:
        repo_root = Path(tmp)
        _stub_default_roots(repo_root)
        (repo_root / "README.md").write_text("clean\n", encoding="utf-8")
        result = run_default(repo_root)
        assert result.returncode == 0, (
            f"a missing DEFAULT_FILES entry was not skipped cleanly: {result.stderr}"
        )


def test_recipe_uri_scheme_is_not_a_leak() -> None:
    """Fix 3, Step 9 — positive: the recipe corpus's own domain-URI scheme is
    exactly what the `(?!://recipes/)` lookahead exists to carve out."""
    with tempfile.TemporaryDirectory() as tmp:
        root = Path(tmp)
        (root / "src").mkdir()
        (root / "src" / "button.md").write_text(
            "domain: agenticdeveloperhub://recipes/button\n", encoding="utf-8"
        )
        result = run(root)
        assert result.returncode == 0, f"recipe URI scheme false-flagged: {result.stderr}"


def test_lookahead_does_not_swallow_the_whole_scheme() -> None:
    """Fix 3, Step 9 — negative, the one that matters: the carve-out is exactly one
    scheme shape (`agenticdeveloperhub://recipes/...`). A bare product-name mention
    still fires, and so does an `agenticdeveloperhub://` URI whose path is not
    `recipes/` — proving the lookahead did not swallow the whole scheme."""
    with tempfile.TemporaryDirectory() as tmp:
        root = Path(tmp)
        (root / "src").mkdir()
        (root / "src" / "bare.ts").write_text(
            "// built for agenticdeveloperhub\n", encoding="utf-8"
        )
        result = run(root)
        assert result.returncode == 1, f"bare product name survived the lookahead: {result.stderr}"
        assert "product name" in result.stderr, result.stderr

    with tempfile.TemporaryDirectory() as tmp:
        root = Path(tmp)
        (root / "src").mkdir()
        (root / "src" / "api.ts").write_text(
            "// see agenticdeveloperhub://api/personas\n", encoding="utf-8"
        )
        result = run(root)
        assert result.returncode == 1, f"non-recipes URI survived the lookahead: {result.stderr}"
        assert "product name" in result.stderr, result.stderr


def test_private_name_outside_default_roots_is_caught() -> None:
    """The gap this tier exists to close.

    DEFAULT_ROOTS names the web tree, so the sibling platform packages were never
    scanned at all — a private repo name could sit in packages/apple indefinitely
    with the guard reporting a clean tree. It is a leak wherever it sits.
    """
    with tempfile.TemporaryDirectory() as tmp:
        repo_root = Path(tmp)
        _stub_default_roots(repo_root)
        apple = repo_root / "packages" / "apple" / "Client"
        apple.mkdir(parents=True)
        (apple / "README.md").write_text(
            "Build the agentictoolkit submodule first.\n", encoding="utf-8"
        )
        result = run_default(repo_root)
        assert result.returncode == 1, f"private name outside the roots missed: {result.stdout}"
        assert "private repo name" in result.stderr


def test_product_name_outside_default_roots_is_not_a_leak() -> None:
    """The other half, and the reason the tiers are split rather than the roots widened.

    The platform packages ship a client NAMED for the product and call its PUBLIC
    API host. Sweeping the product-name pattern repo-wide would condemn the thing
    itself as a leak, so that pattern stays scoped while the private ones widen.
    """
    with tempfile.TemporaryDirectory() as tmp:
        repo_root = Path(tmp)
        _stub_default_roots(repo_root)
        apple = repo_root / "packages" / "apple" / "AgenticDeveloperHubClient"
        apple.mkdir(parents=True)
        (apple / "README.md").write_text(
            "# AgenticDeveloperHubClient\n\nTalks to https://api.agenticdeveloperhub.com\n",
            encoding="utf-8",
        )
        result = run_default(repo_root)
        assert result.returncode == 0, f"public branding condemned: {result.stderr}"


def test_product_name_inside_default_roots_still_fires() -> None:
    """Splitting the tiers must not weaken the product-name rule where it applies."""
    with tempfile.TemporaryDirectory() as tmp:
        repo_root = Path(tmp)
        _stub_default_roots(repo_root)
        (repo_root / "docs" / "guide.md").write_text(
            "Deployed at agenticdeveloperhub.com\n", encoding="utf-8"
        )
        result = run_default(repo_root)
        assert result.returncode == 1, f"scoped product name missed: {result.stdout}"
        assert "product name" in result.stderr


def test_explicit_roots_do_not_trigger_the_wide_sweep() -> None:
    """Passing roots means "ask about these roots" — it must not silently widen.

    Without this, a per-package invocation would start reporting hits from the rest
    of the repo, and the caller could not tell which root they came from.
    """
    with tempfile.TemporaryDirectory() as tmp:
        repo_root = Path(tmp)
        clean = repo_root / "packages" / "web" / "packages" / "ui"
        clean.mkdir(parents=True)
        (clean / "index.ts").write_text("export const a = 1\n", encoding="utf-8")
        stray = repo_root / "packages" / "apple"
        stray.mkdir(parents=True)
        (stray / "README.md").write_text("agentictoolkit\n", encoding="utf-8")
        result = run(clean)
        assert result.returncode == 0, f"explicit root widened: {result.stderr}"


def test_the_guards_own_source_is_not_scanned_as_a_leak() -> None:
    """A guard that hunts a string necessarily contains it, in regex and in prose.

    The allowance is by filename and deliberately narrow: any OTHER file under
    tools/ is swept like the rest of the repo.
    """
    with tempfile.TemporaryDirectory() as tmp:
        repo_root = Path(tmp)
        _stub_default_roots(repo_root)
        # One clean file, so a 0 here means "scanned and found nothing" rather
        # than the empty-scan 2 the guard returns when it read nothing at all.
        (repo_root / "docs" / "guide.md").write_text("All public.\n", encoding="utf-8")
        tools = repo_root / "tools"
        tools.mkdir()
        (tools / "check_no_private_scope.py").write_text(
            'PATTERN = "@agentic-toolkit/"\n', encoding="utf-8"
        )
        assert run_default(repo_root).returncode == 0, "the guard condemned itself"

        (tools / "helper.py").write_text('SCOPE = "@agentic-toolkit/"\n', encoding="utf-8")
        result = run_default(repo_root)
        assert result.returncode == 1, f"a non-guard file under tools/ was skipped: {result.stdout}"


def main() -> int:
    tests = [v for k, v in sorted(globals().items()) if k.startswith("test_")]
    for test in tests:
        test()
    print(f"check_no_private_scope_test: {len(tests)} passed")
    return 0


if __name__ == "__main__":
    sys.exit(main())
