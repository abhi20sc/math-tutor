# LAUNCH CHECKLIST — Astro Math Assist

Produced from a two-track pre-launch audit: a security review (OWASP/ASVS
lens, adversarial trace of grants, definer functions, both edge functions
and the e-transfer state machine) and a usability/design review of the whole
app. Findings were fixed where fixable in code; what remains is listed
honestly below.

---

## Fixed during the audit — deploy carries these

The two that mattered most:

1. **The reporting views bypassed RLS.** `my_weekly_progress` and
   `misconception_counts` ran with their owner's privileges, so any
   signed-in student could read every student's weekly rows — and
   `misconception_counts` listed which options are wrong per question,
   an answer-elimination oracle that quietly defeated the entire
   answers-never-reach-the-browser design. Both views are now
   `security_invoker` and covered by tests F1a/F1b.
2. **Opening the Astro+ menu destroyed an e-transfer subscription.**
   `create-checkout` remembered a new Stripe customer via an upsert that
   wrote `status='none', period_end=null` — overwriting a family's paid
   `manual` grant on one tap. It now calls `set_stripe_customer`, which
   touches nothing but the customer id. Tests F3a–F3c.

The rest: students can no longer change their own grade through the
profiles table (trigger; the tutor owns grade — test F2a, name stays
editable F2b); the webhook only grants on `payment_status = 'paid'` and
treats a Stripe API error as an error instead of defaulting to premium;
`has_premium()` is the single stated definition of premium and now lists
`'manual'`; password floor raised 6 → 8.

And on the product side: the mindmap no longer traps page scrolling (it
sleeps until tapped — "Tap to explore the map"); a Wi-Fi blip mid-answer
shows a snackbar instead of ejecting the student to the level picker; the
report legend no longer describes the retired amber/red scheme; band
percentages carry the band word in a contrast-safe colour, so meaning never
lives in colour alone; the e-transfer plan tiles show selection the same
way answer options do; admin dates read "9 Mar 2026", never "3/9/2026";
the rail's Topics link actually returns to the overview; question figures
reserve their space, announce a failed load, and carry a semantic label;
grading shows a progress line; pending invitations appear on the Profile
pane too; the rail shows the in-N-classes disclosure.

---

## Before real money moves

- [ ] Stripe: swap `sk_test_` → `sk_live_`, create the two live prices
      (monthly $10, annual $100 CAD), set `STRIPE_PRICE_ID_MONTHLY` and
      `STRIPE_PRICE_ID_ANNUAL`, add the live webhook endpoint and its
      `STRIPE_WEBHOOK_SECRET`.
- [ ] **Redeploy BOTH edge functions — both changed in this pass:**
      `supabase functions deploy create-checkout` and
      `supabase functions deploy stripe-webhook --no-verify-jwt`.
- [ ] Test the full loop once in live mode with a real card and refund it.
- [ ] Interac: turn **auto-deposit ON** for stemlabs.ca@gmail.com so no
      security answers travel by text message.
- [ ] Decide who checks the bank inbox and how often — the e-transfer
      promise in the app is "usually within a day", made by you, not code.

## Before real students

- [ ] Supabase → Authentication → Email → turn **Confirm email** back ON.
- [ ] Supabase → Authentication → set minimum password length to 8 there
      too (the app enforces 8, the server setting should agree).
- [ ] Add the Netlify URL to the Auth allowed redirect list, then send
      yourself a reset email and tap it **on a phone** — this path has
      never been verified end to end.
- [ ] The admin account is the keys to every student's data: unique strong
      password, and turn on MFA for it in Supabase if available.
- [ ] Run order on any redeploy: setup → questions → **figures** →
      re-grant admin → build → drag → hard-reload. After setup, every user
      signs in once before they reappear anywhere.
- [ ] On a real phone: the report mindmap (tap-to-wake, expand a unit,
      drag a node), a share link in a private window, and one full
      question with a figure (Trigonometry Medium has them).

## Known and accepted, watch at scale

- `invite_student` reveals whether an email has an account (teacher-only
  audience — REVIEW.md #7).
- `fetchProgress` downloads every attempt row to draw five numbers — the
  first thing to rewrite when classes grow (REVIEW.md #5).
- Database access equals full access; the service key never leaves
  Supabase secrets (REVIEW.md #8).
- Direct enrolment (`add_student_to_class` / admin assign) skips the
  consent step by design for a private tutor; a school deployment makes
  invitation the only path. Documented on the function.

## Open items, not blocking a family-scale launch

- **Keyboard and screen-reader access to the mindmap** — nodes are
  pointer-only. The unit bars carry the same data in text; subtopic bands
  currently exist only on the map. An accessible fallback list (expandable
  rows under each unit bar) is the right future fix.
- Focus states on answer options and rail links use Material's default
  overlay, not the crafted hover treatment; the back arrow in the quiz
  header is under the 44px comfortable hit target.
- "My report" opens as a pushed screen while Topics/Profile swap the pane;
  consistent would be report-in-pane.
- Clicking a different topic in the rail mid-question switches immediately
  and discards the open question — consider a confirm.
- The 640–980px band is correct but plain (stacked layout with side
  margins); an intermediate breakpoint would polish it.
- kHint amber as small text sits just under AA contrast; darken if it ever
  carries essential meaning.
- Still **zero Dart tests**. The SQL suite (103 checks) covers the server;
  the client's answer-handling state machine is the first thing worth a
  widget test.

## The standing content duty

Every new question batch: run the SQL suite (its REVIEW section prints any
feedback that states the answer), and hold figures to the same rule — a
diagram that can be measured for the answer is a leaked answer. The
university-student review spreadsheet covers difficulty and distractor
quality for the current 240.
