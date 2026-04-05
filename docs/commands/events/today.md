# `daymark events today`

Lists events happening today in the current local time zone.

## Usage

```bash
daymark events today [--calendar <calendar> ...] [--json]
```

## Options

- `--calendar <calendar>`: One or more calendar identifiers or exact titles.
- `--json`: Print machine-readable JSON instead of terminal output.

## Notes

- The date window uses the local start and end of the current day.
- Human-readable output reuses the normal event renderer.

## Examples

```bash
daymark events today
daymark events today --calendar Work
daymark events today --json
```
