# `daymark events upcoming`

Lists the next upcoming events starting from now.

## Usage

```bash
daymark events upcoming [--limit <n>] [--days <n>] [--calendar <calendar> ...] [--json]
```

## Options

- `--limit <n>`: Maximum number of events to return. Default: `10`.
- `--days <n>`: How many days ahead to search. Default: `30`.
- `--calendar <calendar>`: One or more calendar identifiers or exact titles.
- `--json`: Print machine-readable JSON instead of terminal output.

## Notes

- The search window starts at the current time, not the start of the day.
- Results are sorted chronologically and then truncated to the requested limit.

## Examples

```bash
daymark events upcoming
daymark events upcoming --limit 5
daymark events upcoming --days 7 --calendar Work
daymark events upcoming --limit 20 --json
```
