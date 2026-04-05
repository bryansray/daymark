# `daymark calendars list`

Lists calendars available through Apple Calendar.

## Usage

```bash
daymark calendars list [--json]
```

## Options

- `--json`: Print machine-readable JSON instead of the terminal table view.

## Output

Human-readable output renders a table with:

- calendar title
- calendar source
- writable status
- calendar identifier

JSON output returns the raw calendar objects.

## Examples

```bash
daymark calendars list
daymark calendars list --json
```
