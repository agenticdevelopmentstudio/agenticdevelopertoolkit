# agenticdevelopertoolkit

Developer toolkit for wiring AI persona chats into apps using the official
agentic registry (persona definitions + LLM provider integrations) and
my-agentic-storage (chat history + state). Replaces the deprecated
`agentic-persona-coordinator`.

Authoritative planning: [`docs/planning/planning.md`](../docs/planning/planning.md).
README: [`README.md`](../README.md).

## Ecosystem map

- **`~/Development/projects/agenticregistry`** — registry service. Has
  per-user persona services (Anthropic / OpenAI / Gemini), provider
  integrations at `web/backend/src/lib/providers/`, persona records with
  `slug`, `modelPrompt`, `voice`, `character`, `examples`, `serviceId`,
  `model`. Public read at `/api/public/personas/:slug`. No chat-completion
  endpoint exists yet — M1 will add one.
- **`~/Development/projects/my-agentic-storage`** — storage service.
  Primitives: `buckets`, `lists`, `events`, `kv`, `counters`, `queues`,
  `memory`, `keywords`. Per-user API keys. Chat history is a fit for `lists`
  or `events`.
- **`~/Development/projects/agentic-web-toolkit`** — current home of the
  chat package at `packages/features/chat/`. M1 relocates it here.
- **`~/Development/projects/learntruefacts`** — dogfood site for apt.
  Currently vendors `agentic-web-toolkit/` under `vendor/`. M1's success
  criterion is replacing that vendor copy with a real apt dependency.
- **`~/Development/projects/agentic-persona-coordinator`** — deprecated.
  Do not change anything there.

## M1 scope (the only milestone designed so far)

1. Relocate `agentic-web-toolkit/packages/features/chat/` into this repo.
2. Build the coordinator package — the glue between the chat UI's
   `ChatBackend` interface and the registry + storage pair.
3. Switch `learntruefacts/sites/main/` from the vendored toolkit to a real
   apt dependency.

Later milestones (M2–M6) cover Python persona-config and try-out tools,
persona-authoring skills, registry population skills, a whimsical name/bio
generator, absorbing `personacreator`, and Apple/Windows/Android coordinator
ports. Each gets its own design spec when its turn comes.

## Open architectural decision (paused)

Where does chat orchestration live?

- **A1** — registry orchestrates a `POST /api/personas/:slug/chat` endpoint
  that handles persona lookup, history read/write to storage, and provider
  call. Coordinator is a thin client.
- **A2** — registry exposes a stateless `POST /api/personas/:slug/complete`.
  Coordinator package implements `ChatBackend`, reads history from storage,
  calls registry's `complete`, writes the new turn back to storage.

A2 was the tentative recommendation in brainstorming, not yet confirmed by
the user. **Do not write the design spec or scaffold the coordinator package
until the user picks one.** This is the brainstorming HARD-GATE.

## Tech stack

- TypeScript / Node throughout for M1 (matches registry, storage, chat
  package).
- Python arrives in M2 for the persona-config scripts and terminal try-out
  tool.
- Future platforms (Swift / Windows / Android) live in M6.

## Repo layout: per-platform top-level dirs

Each platform owns a folder under `packages/` and that folder is the
ROOT of its native build system — its conventional manifest lives
there. See `AGENTS.md` at the repo root for the layout map.

| Platform | Folder | Manifest |
|---|---|---|
| Web (TS) | `packages/web/` | `package.json` (pnpm workspace) |
| Apple | `packages/apple/` | `Package.swift` + `project.yml` |
| Terminal (Python) | `packages/terminal/` | `pyproject.toml` |
| Android | `packages/android/` | (TBD, placeholder) |
| Windows | `packages/windows/` | (TBD, placeholder) |
| Demo site | `websites/demo/` | `package.json` |

## Web workspace: `packages/web/`

The pnpm workspace root lives at `packages/web/` — that's where
`package.json`, `pnpm-workspace.yaml`, `pnpm-lock.yaml`,
`tsconfig.base.json`, `vitest.config.ts`, `vitest.setup.ts`, and
`copy-css.mjs` live. Library packages live at
`packages/web/packages/<name>/`. The repo root has no `package.json`
and no loose build configs — only `install.sh`, `README.md`, and
`AGENTS.md`. Each library declares its own build-time devDeps
(`tsup`, `typescript`, `esbuild-plugin-preserve-directives`,
`@types/react`, `@types/react-dom`); pnpm symlinks those into each
library's `node_modules/` so `tsup.config.ts` and `tsc` resolve them
locally without walking up to the workspace root.

**All web workspace commands run from `packages/web/`**: `pnpm install`,
`pnpm build`, `pnpm test`, `pnpm lint`, `pnpm --filter <pkg> ...`.
There is no turbo — scripts use `pnpm -r run <task>` directly.

`packages/web/packages/themes` has a `build:data` codegen step
(`scripts/build-theme-data.mjs`) that reads `src/styles/*.css` and
emits `src/theme-data.ts` with string-literal exports. This replaces
Vite's `?inline` CSS imports so the package builds under esbuild via
tsup. `src/theme-data.ts` is gitignored — `install.sh` regenerates it.

## Web library packages

| Package | Source dir |
|---|---|
| `@agenticdevelopertoolkit/chat` | `packages/web/packages/chat/src/` (modes/, components/, hooks/, backends/, css/) |
| `@agenticdevelopertoolkit/themes` | `packages/web/packages/themes/src/` (manifest, ThemeStyle, colorMode, styles/) |
| `@agenticdevelopertoolkit/viewport` | `packages/web/packages/viewport/src/` (ViewportShell, ViewportSpacer, ViewportComposer, useKeyboardInset) |
| `@agenticdevelopertoolkit/landing` | `packages/web/packages/landing/src/` (deck/, chrome/, blocks/, css/) |

Library packages may only depend on other `packages/web/packages/*`
— never on ad-hoc paths outside the web workspace.

`landing` is a **sibling of `viewport`, not a layer on it.** Their `html`/`body`
rules are contradictory — a scroll-snapping deck owns the scroll container, a
keyboard-inset shell owns the visual viewport — so a site picks one. Composing
them is not a missing feature to add; it is a conflict to resolve first.

### Three rules the landing extraction actually broke

Each of these shipped at least once during the port, and each is invisible to
vitest, `tsc`, ESLint and a screenshot. That is what makes them worth writing
down rather than leaving to review.

- **Package CSS may name only the neutral scale.** Every visual value is a
  `--lp-*` token whose inline fallback is greyscale, so an unconfigured host
  renders something legible and obviously unthemed. Put a host's own colour in
  a fallback and it looks right on that host forever, because that host
  overrides it — the defect only appears on the *second* site. The same holds
  for prose: a doc line saying a button "is gold-filled" is a colour claim
  about the package's behaviour, and it is false for every other host. Name the
  token or the role instead.
- **A renamed selector keeps its source specificity.** Flattening `.shot .bar`
  to `.lp-shot__bar` drops (0,2,0) to (0,1,0) and can hand the cascade to a
  different rule. jsdom does not resolve the cascade, so no test can see it.
  When a rename changes a selector's shape, the replacement has to carry the
  original's weight.
- **The package owns the UI; the host owns the words.** No component renders a
  literal string — every visible character arrives as a prop, a child, or a
  token. This one is easier to break in CSS than in JSX: `content: "✓"` in a
  `::before` is copy the host cannot reach, which is why such glyphs are tokens
  (`--lp-checklist-mark`, `--lp-versus-bullet`) for the same reason the colours
  are. The one deliberate exception is a component's default *accessible* names
  (`NavChrome`'s "Open menu" and friends) — overridable props, where a default
  saves every host from restating four labels.

The first two get a mechanical check when the package's own tooling lands;
until then all three are review rules.

## Build

```bash
./install.sh                        # one-time, runs pnpm install + theme codegen
cd packages/web && pnpm build
cd packages/web && pnpm test
```

## Conventions

- Follow the user's global instructions (see `~/.claude/CLAUDE.md`):
  Python over Bash for scripts, no `git add -A`, commit only what was
  touched in the session, ask before pull/merge/rebase/etc.
- The chat package's HTTP contract is fixed by what already exists: POST
  `{ message, history }` and either return `{ reply: string }` or stream
  `ChatStreamEvent` values. Do not redesign that.
- `learntruefacts` is the test bed. New apt features must demonstrate
  themselves in `learntruefacts/sites/main` before being considered done.

<!-- mytools:web BEGIN -->
## Web Development

### Available Plugins & Tools

#### MCP Servers
- **Chrome DevTools MCP** — live browser debugging, network inspection, console
  errors, and performance traces. Use when diagnosing runtime issues in a running
  browser session. Requires Chrome to be open.

#### Skills (Auto-Invoked)
- **frontend-design** — activates automatically for UI work. Follow its guidance
  on design choices, typography, animations, and visual details. Do not override it.
- **security-guidance** — activates automatically on file edits. Never bypass
  warnings. Either fix the issue or explicitly document why the risk is acceptable.
- **code-review** — run via `/code-review` before every commit. Treat findings
  scored 80+ as blocking. Use `/code-review --comment` to post directly to a PR.

#### LSP Servers
- **TypeScript LSP** — provides real-time type checking as you write. If it reports
  a type error, fix it before moving on. Do not suppress errors with `@ts-ignore`
  unless absolutely necessary and documented.
- **HTML LSP** — live validation for HTML structure and attributes.
- **CSS LSP** — live validation for CSS/Tailwind class usage.
- **ESLint LSP** — linting runs automatically on file read/write. Treat errors as
  blocking. Warnings should be resolved unless documented.

#### Testing
- **Playwright** — use for all E2E testing and UI validation. Prefer Playwright
  over manual testing instructions. Always verify responsive behavior at:
  - Mobile: 375px
  - Tablet: 768px
  - Desktop: 1440px

### Documentation
- **Context7** — always query Context7 before writing code that uses any external
  library. Never rely on training data for React, Next.js, Tailwind, or any
  fast-moving dependency. Treat training-data API knowledge as potentially stale.

### Tool Priority Order
1. Context7 — resolve library APIs before writing any code
2. TypeScript/HTML/CSS/ESLint LSPs — validate as you write
3. Playwright — verify behavior after writing
4. Chrome DevTools MCP — diagnose when something doesn't work at runtime
5. /code-review — gate before every commit

### Language & Framework Rules

#### TypeScript
- Strict mode is always on. No implicit `any`.
- Never use `@ts-ignore` without a comment explaining why.
- Prefer explicit return types on all exported functions.
- Use `unknown` over `any` when type is genuinely uncertain.

#### React
- Functional components only. No class components.
- Prefer named exports over default exports for components.
- Co-locate component styles, tests, and types with the component file.
- Never use `useEffect` to sync state — derive it instead.

#### General
- Do not guess at library APIs — use Context7.
- Do not ship a component without Playwright coverage for its primary user flow.
- Do not ignore ESLint errors — fix them or document the exception in `.eslintrc`.
- Do not use `!important` in CSS.
<!-- mytools:web END -->
