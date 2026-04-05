# AGENTS.md

## Project purpose
`daymark` is a macOS Swift CLI for reading Apple Calendar data from the terminal.

Current scope is intentionally read-focused:

- inspect Apple Calendar authorization
- request Apple Calendar access
- list calendars
- get a single calendar by ID or exact name
- list events in a date range
- search events in a date range
- support both human-readable terminal output and JSON output

This repo is also a Swift learning exercise. Favor clarity, local reasoning, and clean boundaries over overly clever abstractions.

## Architecture map
- Package manifest: `Package.swift`
- CLI entrypoint: `Sources/App/CalendarCLI.swift`
- CLI commands: `Sources/App/Commands/*`
- CLI support helpers: `Sources/App/Support/*`
- App-facing models and protocols: `Sources/Core/*`
- Apple Calendar integration via EventKit: `Sources/AppleCalendar/*`
- Tests:
  - `Tests/CoreTests/*`
  - `Tests/AppTests/*`
  - `Tests/AppleCalendarTests/*`

## Architectural rules
- `Core` must not import `EventKit`.
- Apple-specific behavior belongs in `Sources/AppleCalendar/*`.
- Keep command files thin:
  - parse CLI input
  - validate required flags
  - call the provider
  - hand output to `OutputPrinter`
- Prefer extending the `CalendarProvider` protocol rather than reaching into `AppleCalendarProvider` directly from commands.
- Human-readable output belongs in `OutputPrinter`.
- JSON output should stay stable and use the existing `printJSON` path.

## Current command surface
- `daymark auth status`
- `daymark auth grant`
- `daymark calendars list`
- `daymark calendars get --id ... | --name ...`
- `daymark events list --from ... --to ... [--calendar ...]`
- `daymark events search --query ... --from ... --to ... [--calendar ...]`

Most commands also support `--json`.

## Output conventions
- Human-readable output is styled with `Rainbow`.
- Calendar lists use a table renderer in `OutputPrinter`.
- Single-item calendar output uses a short detail view.
- Event output uses a two-line summary format with local date/time formatting.
- If you change human-readable output, add or update tests in `Tests/AppTests/OutputPrinterTests.swift`.

## Dependencies
- CLI parsing: `swift-argument-parser`
- Terminal styling: `Rainbow`

Keep dependencies lightweight. For terminal tables, prefer the internal renderer in `OutputPrinter` over bringing in another package unless there is a clear need.

## Validation workflow
Default validation:

```bash
just test
```

Useful commands:

```bash
just build
just test
just check
just run -- auth status
```

If the default `.build/` directory is locked by another SwiftPM process, it is acceptable to use:

```bash
swift build --scratch-path .build-validation
swift test --scratch-path .build-validation
```

Clean temporary scratch directories after use. The repo ignores `/.build*/`.

## Tooling notes
- `justfile` contains the expected local recipes.
- Local task tracking uses `td`.
- `.todos/` is local workflow state and should not be committed.
- `README.md` is user-facing documentation; `AGENTS.md` is implementation guidance.

## Testing guidance
- Prefer small unit tests over live EventKit-heavy coverage when possible.
- `AppTests` is the right place for output formatting tests.
- If command behavior becomes more complex, add a `CalendarProvider` test double rather than depending on live calendars.

## Near-term priorities
The next likely tasks after the current state are:

1. `events get`
2. an app-specific error model in `Core`
3. a `CalendarProvider` test double
4. eventually event creation/update flows

## Commit guidance
- Use Conventional Commits.
- Keep commits scoped to one logical change when possible.
- Good examples for this repo:
  - `feat(calendars): add get command`
  - `feat(cli): improve event output formatting`
  - `chore(git): ignore swiftpm scratch builds`

## Practical guidance for future agents
When starting work:

1. Read the relevant command file in `Sources/App/Commands/`.
2. Check whether the change requires extending `CalendarProvider`.
3. Keep EventKit logic inside `AppleCalendarProvider`.
4. Update `OutputPrinter` only for human-readable output changes.
5. Run tests before finishing.

When updating docs:

- Prefer updating `README.md` for user-visible command changes.
- Keep `AGENTS.md` focused on architecture, workflow, and repo conventions.
