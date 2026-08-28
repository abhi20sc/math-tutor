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
- [ ] `supabase/migrations/reachable_pool.sql`
- [ ] `supabase/migrations/indexes_and_policy_perf.sql`

**Do NOT re-run `astro_math_assist_setup.sql` or any question file.** They
are already applied. Re-running the setup would drop and rebuild `questions`
for no reason.

`reachable_pool.sql` is the only one of these that redefines something the
setup file created: `has_premium()` becomes a one-line call to the new
`student_has_premium(uuid)`, so the same rule can also answer for a student
who is not the caller — which is what a parent reading a share link needs.
The answer does not change. It matters only for the ordering above: setup
first, then this. Re-running setup afterwards would put the old inline copy
back, which still works but puts the definition in two places again.

### 1.3 Check it took

- [ ] ```sql
      select count(*) from questions;                    -- 1600
      select count(*) from lessons;                      -- 219
      select * from my_consent_status();                 -- one row
      select note_rate_limit('launch-check', 2, '1 minute');  -- t, t, then f
      ```

- [ ] The progress ladder can actually be finished on a free account:
      ```sql
      select min(questions_open), max(questions_open), count(*)
      from my_reachable_pool();     -- signed in as a student
      ```
      Expect a minimum of **2** on a free account. That number is not a
      typo and the app depends on knowing it: 26 subtopics across the six
      courses have only two Easy/Medium questions, and the report scores a
      subtopic off the whole pool when the pool is smaller than three
      looks. If the minimum ever comes back as 0, a subtopic exists that a
      free student cannot open at all, and it will sit on "Not started" for
      ever with no way in.

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
      Cloudflare Pages URL. Without it the password-reset link goes
      nowhere.
- [ ] **The admin account:** a unique strong password, and MFA if Supabase
      offers it on your plan. That account can read every student's work.

---

## 3. Stripe

The keys, prices and webhook are already connected. Two things here are
still outstanding, and both exist because the code changed under them.

- [ ] **Set `SITE_URL`** to the Cloudflare Pages origin, no trailing slash.

      **You do not have this value yet, and that is the point.** Cloudflare
      invents the URL when the project is first created — it is
      `https://<project-name>.pages.dev`, and you cannot know
      `<project-name>` until you have named the project.

      So the order is: deploy first with SITE_URL unset, read the URL
      Cloudflare gives you, then set it and redeploy the two functions.
      Astro+ will not work in between, and that is expected rather than a
      fault. Nothing else is affected — sign in, questions, lessons, tests
      and the report do not touch SITE_URL at all.

      If you later put a custom domain in front of it, SITE_URL has to
      change to the custom domain and the functions redeployed again. The
      pages.dev URL keeps working, but a browser on the custom domain will
      be refused by CORS until SITE_URL matches what the browser is
      actually showing.

      This is new. CORS on `create-checkout` used to be `'*'` — any page on
      the internet could call your payment endpoint — and is now locked to
      `SITE_URL`. If it is unset the fallback is `https://unset.invalid`,
      which matches no real origin, so the browser refuses every response.
      That is the correct failure rather than a silent hole, but it is
      still a failure, and it is the one that will look like "Astro+ is
      broken" if this step is skipped.

      It also has to be the CLOUDFLARE origin now, not whatever it pointed
      at before.

- [ ] **Redeploy both functions.** Not optional even with keys set: the
      CORS change is in `create-checkout`'s source and does nothing until
      it is deployed.

      ```bash
      supabase functions deploy create-checkout
      supabase functions deploy stripe-webhook --no-verify-jwt
      ```

      `--no-verify-jwt` on the webhook is required: Stripe is not a
      signed-in user. The signature check inside the function replaces it,
      and it is a real one — HMAC, a five-minute timestamp tolerance and a
      constant-time compare.

Already done, so nothing to do:

- Live keys, the two live prices, and `STRIPE_WEBHOOK_SECRET`

Still worth doing before real money moves:

- [ ] Put one real card through the whole loop, then refund it
- [ ] Interac: turn **auto-deposit ON** for stemlabs.ca@gmail.com, so no
      security answers travel by text message
- [ ] Decide who reads the bank inbox and how often. The app promises
      "usually within a day" — that promise is made by a person, not by code

---

## 4. Build and deploy — Cloudflare Pages

```bash
flutter pub get
flutter analyze          # expect zero issues
flutter test             # expect 44 passing
flutter build web --release --no-web-resources-cdn --wasm
python3 tools/precompress.py
```

**Both lines, in that order.** The second one brotli-11s the two big wasm
files and writes the `Content-Encoding: br` header that goes with them.
Cloudflare compresses on the fly, which means compressing for speed rather
than size: measured on this site its brotli left 231 KB on the table on one
file. Doing it once at build time saves about 575 KB on every cold load and
costs nothing at runtime.

Skipping the second line is safe — you get a slower site, not a broken one.
The header is written by the script, so it only exists when the compression
did. That is deliberate: keeping it in `web/_headers` would have shipped a
brotli claim on raw files any time somebody forgot, and a raw wasm file
served as brotli is a white screen.

Then upload `build/web` to Cloudflare Pages — either drag it in the
dashboard, or `npx wrangler pages deploy build/web`.

### The one that would break everything

**`web/_redirects` must NOT contain the single-page-app catch-all.** It
used to, and on Netlify that was correct:

```
/*    /index.html   200
```

On Cloudflare Pages that line breaks the entire app. Netlify serves a
matching static asset first and only falls through to the redirect when
nothing matched. Cloudflare applies redirects **before** looking for an
asset, and its own documentation says they are *"always followed,
regardless of whether or not an asset matches the incoming request"*. So
that rule rewrites `main.dart.js`, `canvaskit.wasm` and all 376 figures to
`index.html`, and the app never starts — failing in a way that looks like a
broken build rather than a routing rule.

The line is already removed. The file is kept, with the explanation in it,
so nobody puts it back.

**Nothing replaces it, and nothing needed to.** This app has no path
routing. Every link it makes is a query string on the root —
`/?report=<token>`, `/?consent=<token>`, `/?pay=<token>` — read with
`Uri.base.queryParameters` and nothing else. A query string never reaches
the server as a path, so those links were always going to be served
`index.html` by any host. The catch-all was defensive, not load-bearing.

Cloudflare covers path routes anyway: a project with no top-level
`404.html` is treated as a single-page app. That is belt-and-braces here
rather than the thing holding the links up.

Verified on the built output: `main.dart.js` serves as 3.7 MB of
JavaScript, `canvaskit.js` as JavaScript, and all three deep links return
the app's HTML.

- [ ] **Do not add a `web/404.html`.** The moment a top-level 404.html
      exists, Cloudflare stops assuming this is an SPA and every deep link
      404s. A custom 404 page is the one obvious improvement that would
      silently break link sharing.

### The rest

- [ ] Confirm `build/web/_headers` is there. Cloudflare reads it with the
      same syntax as Netlify — checked against their limits: 8 rule blocks
      against a maximum of 100, longest line 102 characters against a
      maximum of 2,000.
- [ ] Confirm `web/figures/` shipped — 376 PNGs. Missing figures make
      questions reference invisible diagrams, with no error.
- [ ] After deploying, **close the tab completely and reopen it.** Flutter's
      service worker serves the old app for a load or two otherwise, and
      "I deployed but nothing changed" is almost always this.

**`--no-web-resources-cdn` is not optional, and it is not about speed.**
Without it the browser fetches Flutter's rendering engine — 2.1 MB — from
`gstatic.com`, which means every student's browser contacts Google on every
cold load. With it, the engine is served from your own origin, where the
`_headers` file caches it for a year.

Measured, both ways, on a cold load: the bytes are the same. What changes is
who sees the request. For an app used by children that is worth the flag.

It does not remove Google entirely — `fonts.gstatic.com` is still contacted
for two fallback font files the framework loads to draw text, and there is
no supported way to stop that short of bundling fonts. Google is named in
the privacy policy for exactly that reason.

**`--wasm` is now on, and my earlier note saying it was worse was wrong.**

That note compared `main.dart.wasm` against `main.dart.js` and stopped
there. It missed that the two builds use DIFFERENT RENDERERS, and the
renderer is the bigger half of the download. Measured properly, as the
browser actually fetches it:

| | wasm | js |
|---|---|---|
| app | 1,163 KB | 1,057 KB |
| renderer | skwasm 1,496 KB | canvaskit 2,131 KB |
| everything else | 47 KB | 48 KB |
| **cold load** | **2,706 KB** | **3,236 KB** |

The app half is 106 KB bigger and the renderer half is 635 KB smaller, so
the whole thing is 530 KB lighter. Comparing only the half that got worse
is how I got it backwards.

Nobody is worse off. `--wasm` builds BOTH targets and `flutter_bootstrap.js`
picks at runtime: a browser with WasmGC (Chrome 119+, Firefox 120+, Safari
18.2+) takes the 2,706 KB path, anything older takes the 3,236 KB one,
which is exactly what every browser gets today.

**You need about 2 GB free to build.**

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
