# AGENTS.md

Orientation for agents (and humans) working in this repo.

## Purpose

A set of reusable per-platform packages: sixteen web libraries under
`packages/web/packages/` (`ui`, `chat`, `editing`, `markdown`, `search`,
`themes`, and more, listed in full below), a Swift package for Apple, and a
Python package for Terminal. Android and Windows are port plans in
`docs/planning/ports/`, with no code yet.

Persona-chat wiring is one capability among them, not the toolkit's
identity: the `chat` package's `PersonaChatBackend` wires apps to the
[agentic registry](https://github.com/mfullerton-archive/agenticregistry) and
[my-agentic-storage](https://github.com/mfullerton-archive/my-agentic-storage).

Each platform folder under `packages/` is the **root of its native build
system** — its conventional manifest file lives there.

## Layout

| Platform | Folder | Manifest | Status |
|---|---|---|---|
| Web (TS) | `packages/web/` | `package.json` (pnpm workspace) | active |
| Apple | `packages/apple/` | `Package.swift` + `project.yml` | active |
| Terminal (Python) | `packages/terminal/` | `pyproject.toml` | active |
| Android | `packages/android/` | (Gradle, planned) | [port plan](docs/planning/ports/android-coordinator.md) |
| Windows | `packages/windows/` | (`.csproj`, planned) | [port plan](docs/planning/ports/windows-coordinator.md) |
| Demo site | `websites/demo/` | `package.json` | active |

The web platform is a pnpm workspace; its libraries live under
`packages/web/packages/`:

- `@agenticdevelopertoolkit/avatar`
- `@agenticdevelopertoolkit/chat`
- `@agenticdevelopertoolkit/chrome`
- `@agenticdevelopertoolkit/controls`
- `@agenticdevelopertoolkit/editing`
- `@agenticdevelopertoolkit/landing`
- `@agenticdevelopertoolkit/markdown`
- `@agenticdevelopertoolkit/model`
- `@agenticdevelopertoolkit/popover`
- `@agenticdevelopertoolkit/registry-profile`
- `@agenticdevelopertoolkit/registry-types`
- `@agenticdevelopertoolkit/search`
- `@agenticdevelopertoolkit/textlens`
- `@agenticdevelopertoolkit/themes`
- `@agenticdevelopertoolkit/ui`
- `@agenticdevelopertoolkit/viewport`

## Where to look first

- Planning, milestones, open architectural decisions →
  [`docs/planning/planning.md`](docs/planning/planning.md)
- Repo conventions, build commands, ground rules →
  [`.claude/CLAUDE.md`](.claude/CLAUDE.md)
- Cookbook recipes referenced by the project → [`recipes/`](recipes/)

## Build entry points

- One-shot bootstrap (web only): `./install.sh`
- Web build / test: `cd packages/web && pnpm build` / `pnpm test`
- Terminal: `cd packages/terminal && pip install -e .` then `pytest`
- Apple: `cd packages/apple && open Package.swift`
- Demo site: `cd websites/demo && python3 scripts/build.py` (or
  `websites/run.sh` for local dev)

## Conventions you should know

- The repo root has **no `package.json`** and no loose build configs.
  Tooling that needs one should `cd` into the relevant platform folder.
- Library packages may only depend on other packages within the same
  platform — never on ad-hoc paths outside their workspace.
- `learntruefacts` is the dogfood site for the web SDK. Features should
  demonstrate themselves there before being considered done.
