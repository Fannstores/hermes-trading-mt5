# Cron and Goal Reconciliation

Managed job:

- Name: `MT5-EVO-SUPERVISOR`
- Marker: `MT5-EVO-MANAGED:v1`

## Scope

Only jobs carrying the exact marker are managed by this skill.

## Reconciliation

1. Read current goals.
2. Read managed cron only.
3. Compare objective and schedule.
4. If aligned, leave it unchanged.
5. If stale, remove/update only the managed job.
6. Create replacement with marker.
7. Verify cron list and payload.

Never delete, edit, disable, or replace unrelated user cron jobs.

## Evolution supervisor duties

- inspect new evidence;
- select next research/experiment task;
- check strategy lifecycle gates;
- update journal/state;
- report material changes;
- respect `/stoptreding` and kill switch;
- never bypass execution/risk controls.
