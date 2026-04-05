# daymark

`daymark` is a macOS command-line tool for reading Apple Calendar data from the terminal.

It is intentionally small and local-first:

- no server process
- no external calendar sync service
- direct access to Apple Calendar through `EventKit`
- a modular Swift codebase meant to be easy to learn from and extend

This project is also a Swift learning exercise, so the code favors clear boundaries over clever abstractions.

## What The Binary Does

Today, `daymark` can:

- report its own version
- inspect Apple Calendar authorization state
- request Apple Calendar access
- list calendars
- list events in a date range
- search events by text in a date range
- output either human-readable terminal formatting or JSON

The human-readable output is styled for the terminal and uses table formatting where it helps readability.

## Requirements

- macOS
- Swift toolchain / Xcode with `swift build` and `swift test` available
- Apple Calendar access when using the live commands

## Quick Start

Build the project:

```bash
swift build
```

Check authorization:

```bash
swift run daymark auth status
```

Check the CLI version:

```bash
swift run daymark --version
```

Request access:

```bash
swift run daymark auth grant
```

List calendars:

```bash
swift run daymark calendars list
```

List events:

```bash
swift run daymark events list --from 2026-04-01 --to 2026-04-07
```

Search events:

```bash
swift run daymark events search --query dentist --from 2026-04-01 --to 2026-04-30
```

## Commands

### `auth`

Inspect or request Apple Calendar permissions.

```bash
swift run daymark auth status
swift run daymark auth grant
```

Optional flags:

- `--json` for machine-readable output

### Global flags

```bash
swift run daymark --version
```

### `calendars`

List calendars visible through Apple Calendar.

```bash
swift run daymark calendars list
swift run daymark calendars list --json
```

### `events`

List or search events in a date range.

```bash
swift run daymark events list --from 2026-04-01 --to 2026-04-07
swift run daymark events list --from 2026-04-01 --to 2026-04-07 --calendar Work
swift run daymark events search --query design --from 2026-04-01 --to 2026-04-30
swift run daymark events search --query design --from 2026-04-01 --to 2026-04-30 --json
```

Supported event flags:

- `--from` range start in ISO-8601 or `YYYY-MM-DD`
- `--to` range end in ISO-8601 or `YYYY-MM-DD`
- `--calendar` one or more calendar IDs or exact titles
- `--query` search text for `events search`
- `--json` for machine-readable output

## Output Modes

`daymark` currently supports two output styles:

- human-readable terminal output
- JSON output via `--json`

Human-readable output uses:

- colored authorization state
- table output for calendar lists
- styled event summaries with local date/time formatting

JSON output is useful for scripting or piping into other tools.

## `just` Recipes

This repo includes a small [just](https://github.com/casey/just) task runner configuration in [justfile](/Users/bryanray/Projects/Personal/calendr/justfile).

Available recipes:

- `just build` — build the CLI in debug mode
- `just test` — run the SwiftPM test suite
- `just check` — clean and run the test suite
- `just run -- ...` — pass arbitrary arguments through to `daymark`
- `just clean` — remove the default SwiftPM build directory

Examples:

```bash
just build
just test
just run -- auth status
just run -- calendars list
just run -- events list --from 2026-04-01 --to 2026-04-07
```

## TODOs

Project tasks are tracked locally with `td`.

Current tracked tasks:

- `td-0d8550` Improve event output formatting
  Status: `in_progress`
- `td-b9e9f1` Add calendars get command
  Status: `open`
- `td-35dcc1` Add events get command
  Status: `open`
- `td-ac8177` Introduce app-specific error model
  Status: `open`
- `td-8c2a89` Add `CalendarProvider` test double
  Status: `open`

You can inspect them directly with:

```bash
td show td-0d8550 td-b9e9f1 td-35dcc1 td-ac8177 td-8c2a89
```

Or view the ready queue:

```bash
td ready
```

## Project Structure

The package is split into three primary targets:

- `App`
  Owns CLI parsing, command definitions, and terminal output
- `Core`
  Owns models, shared parsing, and app-facing protocols
- `AppleCalendar`
  Owns the `EventKit` integration layer

That separation is intentional:

- `Core` does not know about `EventKit`
- Apple-specific details stay in one target
- future backends, like Google Calendar, can hang off the same provider boundary

## Development Notes

- The default SwiftPM build directory is `.build/`
- alternate scratch builds such as `.build-validation/` are ignored through the `.gitignore` pattern `/.build*/`
- todos are tracked locally in `.todos/` and are not committed

## Near-Term Roadmap

Likely next improvements:

- `calendars get`
- `events get`
- a small app-specific error model
- a provider test double for command testing
- eventually, event creation and update flows

## Current Status

`daymark` is usable as an MVP read-focused Apple Calendar CLI, but it is still early-stage.

The project is at the point where the architecture is stable enough to extend, while the command surface is still intentionally small.
