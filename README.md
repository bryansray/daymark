# daymark

`daymark` is a small Apple Calendar CLI written in Swift as a learning project.

Current MVP scope:

- check calendar authorization
- request calendar access
- list calendars
- list events in a date range
- search events in a date range

## Commands

```bash
swift run daymark auth status
swift run daymark auth grant
swift run daymark calendars list
swift run daymark events list --from 2026-04-01 --to 2026-04-07
swift run daymark events search --query dentist --from 2026-04-01 --to 2026-04-30
```

## Notes

- `Core` contains app-facing models and protocols only.
- `AppleCalendar` is the only target that imports `EventKit`.
- `App` owns CLI parsing and output.
