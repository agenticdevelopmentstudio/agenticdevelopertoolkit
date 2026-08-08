# agenticdevelopertoolkit

A toolkit that ships reusable per-platform SDKs for wiring AI persona chats
into apps using the [official agentic registry](https://github.com/agentic-cookbook/agenticregistry)
(persona definitions + LLM provider integrations) and
[my-agentic-storage](https://github.com/agentic-cookbook/my-agentic-storage)
(chat history + state). The toolkit's coordinator code is the glue that
splices both services into the shape a chat UI expects, so each consumer
app does not have to re-implement orchestration.

Supersedes the deprecated `agentic-persona-coordinator`.

## Layout

Each platform folder under `packages/` is the **root of its native build
system** — open it and you'll find the conventional manifest for that
platform.

| Platform | Folder | Manifest | Status |
|---|---|---|---|
| Web (TS) | `packages/web/` | `package.json` (pnpm workspace) | active |
| Apple | `packages/apple/` | `Package.swift` + `project.yml` | active |
| Terminal (Python) | `packages/terminal/` | `pyproject.toml` | active |
| Android | `packages/android/` | (TBD) | placeholder |
| Windows | `packages/windows/` | (TBD) | placeholder |
| Demo site | `websites/demo/` | `package.json` | active |

The web platform is a pnpm monorepo with libraries under
`packages/web/packages/`:

- `@agenticdevelopertoolkit/avatar` — headless avatar behaviour and the
  `useAvatarEngine` hook.
- `@agenticdevelopertoolkit/chat` — React chat components (`InlineChat`,
  `ThreePaneChat`, `MobileChat`, `PersonaChat`) with pluggable backends.
- `@agenticdevelopertoolkit/chrome` — site chrome: the menu button and the
  close glyph derived from it.
- `@agenticdevelopertoolkit/popover` — hover popovers: the anchored panel, its
  pointing arrow, and the hover-intent state for a row of them.
- `@agenticdevelopertoolkit/textlens` — a travelling lens that magnifies,
  softens and tints each character of a line as it passes.
- `@agenticdevelopertoolkit/themes` — Theme manifest, `ThemeStyle`, and
  `ColorModeProvider`.
- `@agenticdevelopertoolkit/viewport` — iOS-correct viewport / keyboard
  primitives.

## Build

One-shot bootstrap (installs the web workspace and runs theme codegen):

```bash
./install.sh
```

Per-platform commands:

```bash
# Web
cd packages/web && pnpm build
cd packages/web && pnpm test

# Terminal (Python)
cd packages/terminal && pip install -e . && pytest

# Apple
cd packages/apple && open Package.swift

# Demo site (local dev)
cd websites && ./run.sh
```

## Design

How this repo is laid out, how it's consumed, and the recipe for building
sibling toolkit repos the same way:
[`docs/repo-pattern.md`](docs/repo-pattern.md).

Consumer setup walkthrough (git submodule path):
[`docs/consuming-as-submodule.md`](docs/consuming-as-submodule.md).

## Planning

Milestones, the open architectural decision, and design notes live in
[`docs/planning/planning.md`](docs/planning/planning.md).

Agent-oriented orientation: [`AGENTS.md`](AGENTS.md).
Repo conventions and build rules: [`.claude/CLAUDE.md`](.claude/CLAUDE.md).
