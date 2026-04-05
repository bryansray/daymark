# `daymark calendars get`

Fetches a single calendar by identifier or exact title.

## Usage

```bash
daymark calendars get --id <calendar-id> [--json]
daymark calendars get --name "<exact title>" [--json]
```

## Options

- `--id <calendar-id>`: Calendar identifier.
- `--name <exact title>`: Exact calendar title.
- `--json`: Print machine-readable JSON instead of terminal output.

## Notes

- You must provide at least one of `--id` or `--name`.
- `--name` is an exact title match, not a fuzzy search.

## Output

Human-readable output renders:

- title
- source
- writable status
- identifier

## Examples

```bash
daymark calendars get --id 1234567890
daymark calendars get --name Work
daymark calendars get --name Work --json
```
