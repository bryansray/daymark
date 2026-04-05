# `daymark auth grant`

Requests Apple Calendar access for `daymark`.

## Usage

```bash
daymark auth grant [--json]
```

## Options

- `--json`: Print machine-readable JSON instead of styled terminal output.

## Notes

- This command may trigger the macOS permission prompt.
- If access was already granted or denied, macOS may not show the prompt again.

## Output

Human-readable output prints the resulting authorization state.

JSON output looks like:

```json
{
  "status": "fullAccess"
}
```

## Examples

```bash
daymark auth grant
daymark auth grant --json
```
