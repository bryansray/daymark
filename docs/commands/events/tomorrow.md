# `daymark events tomorrow`

Lists events happening tomorrow in the current local time zone.

## Usage

```bash
daymark events tomorrow [--calendar <calendar> ...] [--json]
```

## Options

- `--calendar <calendar>`: One or more calendar identifiers or exact titles.
- `--json`: Print machine-readable JSON instead of terminal output.

## Notes

- The date window uses the local start and end of the next calendar day.
- This is a convenience wrapper around the normal range-based event listing flow.

## Examples

```bash
daymark events tomorrow
daymark events tomorrow --calendar Personal
daymark events tomorrow --json
```
