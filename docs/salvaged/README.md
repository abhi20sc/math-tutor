# Salvaged edge functions

Three functions are deployed on the live Supabase project and are not in
this repository. The deployed copy is the only one that exists, and
"deployed" is not a backup.

**Download them before deleting anything.** One command, and it copies the
real source rather than a transcription of it:

```bash
supabase functions download send-weekly-reports
supabase functions download send-report-now
supabase functions download send-consent-email
```

They land in `supabase/functions/<slug>/index.ts`. Move them in here, or
commit them where they land and delete the deployed versions afterwards.
This file is the note about WHY they are worth keeping; it is not a copy of
them, deliberately — a hand-transcribed 500-line email template with one
character wrong is worse than no copy at all, because it looks like a copy.

**None of them runs.** Each calls a schema that `astro_math_assist_setup.sql`
replaced, so each fails on its first RPC call:

| Function | Wants | On the database |
|---|---|---|
| `send-consent-email` | `report_recipients`, `pending_consents_for`, `mark_consent_sent` | gone |
| `send-report-now` | `manual_report_for`, `record_report_sent` | gone |
| `send-weekly-reports` | `reports_due`, `record_report_sent`, `weekly_report` | gone |

They also link to `/confirm?token=` and `/unsubscribe?token=`, path routes
this app does not have — every link it makes today is a query string on the
root, read with `Uri.base.queryParameters`.

## Why keep them at all

The weekly parent report was a real, finished feature and this is the only
surviving copy of it. The HTML is the valuable part and it is not cheap
work: tables for layout because Outlook ignores flexbox, inline styles
because Gmail strips `<style>` blocks, no web fonts, 600px, a `List-Unsubscribe`
header pair so Gmail and Apple Mail show one-click unsubscribe, and a
summary function that deliberately refuses to praise what the numbers do
not support.

There is also a CASL point worth not losing: every email carries a working
unsubscribe built from the consent token, and a guardian must never need an
account to stop mail about their own child. Anything that sends to parents
in future has to keep that property.

## What reviving one would take

A schema, not a redeploy. Recipients with double opt-in, consent tokens,
a per-week send log, and `weekly_report(student, week)`. Then the links
change to query strings, and the branding changes — these say "Math Tutor"
and default to `reports@example.ca` and a Netlify URL.

`send-link` in `supabase/functions/` is the current, working equivalent for
the two links the app actually sends today.
