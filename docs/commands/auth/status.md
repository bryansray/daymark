# `daymark auth status`

Shows the current Apple Calendar authorization state for `daymark`.

## Usage

```bash
daymark auth status [--json]
```

## Options

- `--json`: Print machine-readable JSON instead of styled terminal output.

## Output

Human-readable output prints the current authorization state with terminal styling.

JSON output looks like:

```json
{
  "status": "fullAccess"
}
```

## Examples

```bash
daymark auth status
daymark auth status --json
```
