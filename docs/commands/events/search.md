# `daymark events search`

Searches events in a date range by text, partial identifier, or both.

## Usage

```bash
daymark events search [--query <text>] [--id <partial-id>] --from <date> --to <date> [--calendar <calendar> ...] [--limit <n>] [--json]
```

## Options

- `--query <text>`: Search text for event title, location, and notes.
- `--id <partial-id>`: Partial event identifier match.
- `--from <date>`: Range start in ISO-8601 or `YYYY-MM-DD`.
- `--to <date>`: Range end in ISO-8601 or `YYYY-MM-DD`.
- `--calendar <calendar>`: One or more calendar identifiers or exact titles.
- `--limit <n>`: Maximum number of events to return.
- `--json`: Print machine-readable JSON instead of terminal output.

## Notes

- You must provide at least one of `--query` or `--id`.
- If both are provided, both filters are applied.
- Partial ID matching is case-insensitive.
- Human-readable output is grouped by day when the result set spans multiple calendar days.

## Examples

```bash
daymark events search --query design --from 2026-04-01 --to 2026-04-30
daymark events search --id abc123 --from 2026-04-01 --to 2026-04-30
daymark events search --query standup --id abc --from 2026-04-01 --to 2026-04-30 --limit 10
daymark events search --query dentist --from 2026-04-01 --to 2026-04-30 --json
```
