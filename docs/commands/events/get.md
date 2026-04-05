# `daymark events get`

Fetches a single event by its exact event identifier.

## Usage

```bash
daymark events get --id <event-id> [--json]
```

## Options

- `--id <event-id>`: Exact Apple Calendar event identifier.
- `--json`: Print machine-readable JSON instead of terminal output.

## Notes

- This is an exact lookup command.
- For partial ID matching, use [`events search`](./search.md) with `--id`.

## Output

Human-readable output includes:

- title
- date and time summary
- calendar title
- optional location and notes
- recurrence metadata when present
- event identifier

## Examples

```bash
daymark events get --id abc123
daymark events get --id abc123 --json
```
