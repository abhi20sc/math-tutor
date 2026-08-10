# Math Tutor

A maths practice web app for Ontario high-school students, grades 9 to 12.

**It is not an answer key.** Photomath already solves any question you point a
camera at. What no app does well is tell a student *what they did wrong* — so
every question here has four options, the three wrong ones are each the answer
you get from a specific mistake, and picking one tells you which mistake you
made **without revealing the correct answer**. You try again.

That one decision shapes everything else: the scoring, the medals, the teacher
dashboard, and the weekly report a parent receives.

New to the project? Read **[docs/HOW_IT_WORKS.md](docs/HOW_IT_WORKS.md)** —
every feature in plain English, no code.

---

## What is in here

| Path | What |
|---|---|
| `lib/main.dart` | The whole Flutter app. One file, ~5,700 lines, deliberately — see below |
| `supabase/migrations/` | Database schema and all 200 questions |
| `supabase/functions/` | Three Edge Functions for the parent emails |
| `web-pages/` | Consent and unsubscribe pages the emails link to |
| `docs/` | Handoff, feature guide, test plan, security review |
| `tests/` | SQL test suites, runnable against a local Postgres |

**On the single file:** a seven-file split was tried and rejected — *"just
comment in the large dart file, this is tiresome to handle."* It has eight
numbered sections and heavy teaching comments. Please keep it that way.

---

## Stack

Flutter Web · Supabase (Postgres, Auth, Row Level Security) · Netlify ·
Resend for email.

No server to maintain. The database enforces every access rule itself rather
than trusting the app, which means a bug in the app cannot show one student
another student's work.

---

## Running it locally

```bash
flutter run -d chrome
```

First build takes 2–3 minutes and sits at *"Waiting for connection from debug
service"*. That is normal — do not Ctrl+C.

Requires the database to be set up first (below).

---

## Deploying

**Order matters.** The setup file drops and rebuilds `questions` and
`profiles`, so the questions always load after it.

1. Supabase SQL editor → run `supabase/migrations/supabase_full_setup.sql`
2. Same → run `supabase/migrations/questions_all_tagged.sql`
3. Build and copy the static pages in:

```bash
flutter build web --base-href /
cp web-pages/*.html build/web/
```

4. Drag `build/web` onto Netlify → Deploys
5. Hard-reload the live site with **Cmd+Shift+R** (a normal reload serves the
   cached old build)

`flutter build web` wipes that folder each time, so step 3's `cp` has to be
repeated on every deploy. A deploy that silently drops `unsubscribe.html` is
not noticed until a guardian clicks the link.

**After any re-run of the setup file, every student must sign in once before
they appear on a teacher's roster** — signing in is what recreates their
profile row.

### Edge Functions

```bash
supabase functions deploy send-weekly-reports
supabase functions deploy send-report-now
supabase functions deploy send-consent-email
```

Secrets (set once, read at runtime, no redeploy needed):

```bash
supabase secrets set RESEND_API_KEY=...
supabase secrets set REPORT_FROM="Math Tutor <reports@yourdomain.ca>"
supabase secrets set SITE_URL=https://your-site.netlify.app
```

### Making somebody a teacher

Teacher accounts can read the work of every student in their class, so they
are not self-serve. Generate a code, hand it over, and they redeem it in the
app under **… → I am a teacher**.

```sql
insert into teacher_invite_codes (code, label, max_uses, expires_at)
values (upper(substr(md5(random()::text), 1, 10)),
        'who this is for', 5, now() + interval '30 days')
returning code;
```

Use a random code rather than something memorable — see the security review.

---

## About keys

The Supabase **publishable** key appears in `lib/main.dart` and the two HTML
pages. That is correct and safe: it grants nothing on its own, because Row
Level Security is what actually protects the data.

The **service role** key and the **Resend** key must never appear in any file
in this repo. They live only in Supabase Edge Function secrets. The service
role key bypasses RLS entirely.

---

## Known issues

**[docs/REVIEW.md](docs/REVIEW.md)** has the full audit. Two things matter
before a real class uses this:

- Teacher access codes are guessable if you pick memorable ones, and there is
  no rate limit on redemption
- `class_roster` joins two tables on the same key and multiplies its own rows

Neither matters at family scale. Both matter at school scale.

---

## Before a real school

Not technical, and not optional:

- **Tell students.** They can see which classes they are in and leave in one
  tap. Keep it that way — access a child does not know about is surveillance
  whatever the intent.
- **Decide how students join.** A code is friendlier; a teacher adding by
  email is harder to misuse.
- **Read the privacy rules.** A dashboard holding children's academic records
  and a list of guardian email addresses is where this stops being a family
  project. In Ontario that means MFIPPA for schools and PIPEDA outside one.
