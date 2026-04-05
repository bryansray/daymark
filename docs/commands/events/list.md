# `daymark events list`

Lists events in a specific date range.

## Usage

```bash
daymark events list --from <date> --to <date> [--calendar <calendar> ...] [--limit <n>] [--json]
```

## Options

- `--from <date>`: Range start in ISO-8601 or `YYYY-MM-DD`.
- `--to <date>`: Range end in ISO-8601 or `YYYY-MM-DD`.
- `--calendar <calendar>`: One or more calendar identifiers or exact titles.
- `--limit <n>`: Maximum number of events to return.
- `--json`: Print machine-readable JSON instead of terminal output.

## Notes

- Results are sorted chronologically.
- Human-readable output is grouped by day when the result set spans multiple calendar days.
- `--limit` is applied after the events are fetched and sorted.

## Examples

```bash
daymark events list --from 2026-04-01 --to 2026-04-07
daymark events list --from 2026-04-01 --to 2026-04-07 --calendar Work
daymark events list --from 2026-04-01 --to 2026-04-30 --limit 20 --json
```
