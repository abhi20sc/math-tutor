# Launch checklist — Astro STEM Labs

Everything that has to be true before a real student uses this, in the order
it has to happen. Current as of 27 August 2026.

Nothing on this page is code. All of it is yours to do, because all of it
needs a password, a card, or a decision that is not mine to make.

Tick order matters in section 1. Sections 2 and 3 can be done in any order,
but all of section 1 has to be done first.

---

## 1. The database, in this order

The live project is `frkswzowskeqmgdrrwab`. Everything here is the Supabase
SQL editor unless it says otherwise.

### 1.1 The old rate-limit table — handled, but know about it

Nothing to do. This is here because it is the one upgrade hazard on the live
project and you should know it exists rather than trust that it does not.

There is already a `rate_limit_hits` on the live database. It has no primary
key, nothing has ever written to it, and no file in this repository created
it — a leftover from a feature that was never built.

`create table if not exists` would have found it, left it exactly as it was,
and reported success. Then every `note_rate_limit` call would fail with *no
unique or exclusion constraint matching the ON CONFLICT specification* — and
because the app's rate-limit check fails open, that error would be swallowed.
You would have had no rate limiting and no sign of it.

`student_safeguarding.sql` now detects the old shape and drops it first. It
prints `dropping the old keyless rate_limit_hits (0 rows)` when it does.
Safe, because nothing has ever written to it.

### 1.2 Run the new migrations

In this order. Each is safe to re-run; none of them touches a question, a
lesson, or a student's history.

- [ ] `supabase/migrations/test_review_answers.sql`
- [ ] `supabase/migrations/learn_journey.sql`
- [ ] `supabase/migrations/my_progress.sql`
- [ ] `supabase/migrations/student_safeguarding.sql`
- [ ] `supabase/migrations/enrolment_links.sql`
- [ ] `supabase/migrations/indexes_and_policy_perf.sql`

**Do NOT re-run `astro_math_assist_setup.sql` or any question file.** They
are already applied. Re-running the setup would drop and rebuild `questions`
for no reason.

### 1.3 Check it took

- [ ] ```sql
      select count(*) from questions;                    -- 1600
      select count(*) from lessons;                      -- 219
      select * from my_consent_status();                 -- one row
      select note_rate_limit('launch-check', 2, '1 minute');  -- t, t, then f
      ```

- [ ] Confirm the eight existing accounts are not locked out:
      ```sql
      select count(*) from profiles where date_of_birth is null;   -- 8
      select count(*) from profiles p where consent_required(p.id); -- 0
      ```
      Null birth date means "not blocked", deliberately — see the note in
      `student_safeguarding.sql`. If the second query returns anything other
      than 0, stop and read that note before going further.

---

## 2. Supabase settings

These are in the dashboard, not in SQL, which is why no migration can do
them and why they are the ones most often forgotten.

- [ ] **Authentication → Sign In / Providers → Email → Confirm email: ON.**
      It was turned off for testing. Leaving it off means anybody can create
      an account on somebody else's address.
- [ ] **Authentication → leaked-password protection: ON.** Supabase's own
      advisor has been flagging this the whole time.
- [ ] **Authentication → minimum password length: 8.** The app enforces 8;
      the server should agree rather than being two rules that can drift.
- [ ] **Authentication → URL Configuration → Redirect URLs:** add the
      Netlify URL. Without it the password-reset link goes nowhere.
- [ ] **The admin account:** a unique strong password, and MFA if Supabase
      offers it on your plan. That account can read every student's work.

---

## 3. Stripe, before any real money

- [ ] Swap `sk_test_` for `sk_live_`
- [ ] Create the two live prices — monthly $10, annual $100 CAD
- [ ] Set `STRIPE_PRICE_ID_MONTHLY` and `STRIPE_PRICE_ID_ANNUAL`
- [ ] Add the live webhook endpoint and set `STRIPE_WEBHOOK_SECRET`
- [ ] **Set `SITE_URL`** to the real Netlify origin, with no trailing slash.
      This is new and it is not optional any more: CORS on `create-checkout`
      is locked to it. Unset, it falls back to a placeholder that matches no
      real origin, and the browser will refuse every response — which is the
      correct failure, but it is still a failure.
- [ ] Redeploy **both** functions:
      ```bash
      supabase functions deploy create-checkout
      supabase functions deploy stripe-webhook --no-verify-jwt
      ```
      `--no-verify-jwt` on the webhook is required: Stripe is not a signed-in
      user. The signature check inside the function is what replaces it.
- [ ] Put one real card through the whole loop, then refund it
- [ ] Interac: turn **auto-deposit ON** for stemlabs.ca@gmail.com, so no
      security answers travel by text message
- [ ] Decide who reads the bank inbox and how often. The app promises
      "usually within a day" — that promise is made by a person, not by code

---

## 4. Build and deploy

```bash
flutter pub get
flutter analyze          # expect zero issues
flutter test             # expect 44 passing
flutter build web --release --no-web-resources-cdn
# then drag build/web onto Netlify
```

**`--no-web-resources-cdn` is not optional, and it is not about speed.**
Without it the browser fetches Flutter's rendering engine — 2.1 MB — from
`gstatic.com`, which means every student's browser contacts Google on every
cold load. With it, the engine is served from your own Netlify origin,
where the `_headers` file already caches it for a year.

Measured, both ways, on a cold load: the bytes are the same. What changes
is who sees the request. For an app used by children that is worth the
flag.

It does not remove Google entirely — `fonts.gstatic.com` is still contacted
for two fallback font files that the framework loads to draw text, and
there is no supported way to stop that short of bundling fonts. Google is
named in the privacy policy for exactly that reason.

**You need about 2 GB free to build.** The disk was at 316 MB when this was
last checked and the build failed outright. `flutter clean` and emptying
`~/Library/Developer/Xcode/DerivedData` are the usual two.

- [ ] Confirm `build/web` contains `_headers` and `_redirects`. They live in
      `web/` and are copied by the build. Without `_redirects` every shared
      link and every reload 404s; without `_headers` there are no security
      headers at all.
- [ ] Confirm `web/figures/` shipped — 376 PNGs. Missing figures make
      questions reference invisible diagrams, with no error.
- [ ] After deploying, **close the tab completely and reopen it.** Flutter's
      service worker serves the old app for a load or two otherwise, and
      "I deployed but nothing changed" is almost always this.

Do not use `--wasm`. It was measured: 1,156 KB gzipped against 1,056 KB for
the normal build. It is worse.

---

## 5. On a real phone, signed in as a real student

The things that have never been tested end to end on hardware.

- [ ] Sign up as a 15-year-old. Confirm you land on the guardian screen,
      that you can still read a lesson, and that **nothing is saved** — check
      `select count(*) from attempts where student_id = ...` is still 0
- [ ] Open the guardian link in a private window. Confirm it says the
      student's name, and that opening it twice is harmless
- [ ] Answer a question after consent, and confirm the row appears
- [ ] Open the same guardian link again and withdraw. Confirm new answers
      stop being recorded and old ones are still there
- [ ] Sign up as a 12-year-old and confirm you are refused
- [ ] The password reset email, opened **on a phone**. This path has never
      been verified end to end
- [ ] A share link in a private window
- [ ] One full question with a figure — Trigonometry Medium has them
- [ ] The mindmap: expand a unit, drag a branch, then Reset view
- [ ] The Astro+ form, and the link it gives you, opened in a private window
- [ ] Every dialog, on the phone. Five are covered by widget tests at
      375x812; the rest have never been seen on a phone and cannot be
      tested that way.

      Worth knowing why, so nobody spends an afternoon on it again: a
      widget holding a repository reaches Supabase.instance in its field
      initialisers, and Supabase.initialize hangs inside a widget test —
      it waits on platform channels for secure storage that the test
      binding does not provide. Making those screens testable means
      injecting the repositories rather than constructing them inline,
      which is its own piece of work and probably belongs with splitting
      main.dart. Until then the signup form, the guardian screen, the
      Astro+ sheet and the admin queue are hand-checked only.
- [ ] Profile → Download my data, and read what comes out
- [ ] Profile → Delete my account, on a throwaway account. Confirm the rows
      are gone rather than flagged

---

## 6. Decisions I could not make for you

- **Error monitoring.** `_reportError` in `lib/main.dart` catches everything
  and writes to the browser console. It is a seam for a real reporter, and
  it says so. Adding Sentry costs money and sends data to a third party you
  would then have to name in the privacy policy. Right now, if a student
  hits a crash, you will not hear about it unless they tell you.
- **Account lockout.** Rate limiting throttles guesses at one address. It
  does not stop a slow distributed guess at one account. A real lockout
  needs a "we have locked your account" email, and there is no email
  function in this project.
- **Analytics.** There is none, and no cookie banner is needed because of
  that. Adding any is a decision with a privacy-policy consequence, and for
  a product used by minors the answer should probably stay no.

---

## 7. Not blocking, but true

- The Astro+ enrolment flow has six working server functions and no
  interface. A parent cannot currently be sent a payment link by the app.
- The guardian consent link is handed to the student to pass on, because
  the app cannot send email. It works; it is not what you would want.
- `purge_rate_limits` is not scheduled. Run it by hand occasionally, or
  leave it — the table is small.
- `lib/main.dart` is 16,000 lines, and that is the only real lever left on
  the 1,056 KB payload.
