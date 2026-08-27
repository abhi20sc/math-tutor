// ===========================================================================
// create-checkout — Supabase Edge Function
// ===========================================================================
// Turns "Unlock Challenge and Advanced" into a Stripe checkout page, and
// "Manage subscription" into Stripe's billing portal.
//
// ---------------------------------------------------------------------------
// One-time Stripe setup (the adult who runs this does it, ~20 minutes)
// ---------------------------------------------------------------------------
//  1. stripe.com → create an account. It must belong to an ADULT with real
//     tax details — your uncle, in practice. The users are minors, minors
//     cannot form contracts, and Stripe's terms require the account holder
//     and the purchaser to be adults. This is why every piece of copy in the
//     app says "ask a parent or guardian".
//  2. Products → Add product → name it "Astro+". ONE product, TWO prices —
//     this is the part that trips people up, so the exact clicks:
//       a. In the Add product form, under Price: Recurring, 10.00 CAD,
//          billing period Monthly → Save. That is price #1.
//       b. Open the product you just made → in its Pricing section click
//          "+ Add another price" → Recurring, 100.00 CAD, billing period
//          Yearly → Save. That is price #2.
//       c. Each price has an id starting price_... — click a price to see
//          its id, or use the ⋯ menu → Copy price ID. Copy both.
//  3. Developers → API keys → copy the SECRET key (sk_test_... to start).
//  4. Deploy this and the webhook, then set the secrets:
//
//       supabase functions deploy create-checkout
//
//       supabase secrets set STRIPE_SECRET_KEY=sk_test_xxx
//       supabase secrets set STRIPE_PRICE_ID_MONTHLY=price_xxx
//       supabase secrets set STRIPE_PRICE_ID_ANNUAL=price_yyy
//
//     (STRIPE_PRICE_ID from the old single-price setup still works as the
//     monthly fallback, so nothing breaks mid-migration.)
//  5. Test with Stripe's test card 4242 4242 4242 4242, any future date, any
//     CVC. Nothing real moves until the key starts sk_live_.
//
// The app sends ?plan=monthly or ?plan=annual. The plan name is the ONLY
// thing the browser chooses — it is looked up in the allowlist below, so a
// tampered request cannot name an arbitrary price or amount.
//
// The app calls this with the student's sign-in token; identity comes from
// that token and never from the request body, so nobody can start a checkout
// against another student's account.

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!;
const SERVICE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
const ANON_KEY = Deno.env.get('SUPABASE_ANON_KEY')!;
const STRIPE_KEY = Deno.env.get('STRIPE_SECRET_KEY')!;

// Plan name → price id, resolved here and never from the request. A plan
// the map does not know is a 400, not a guess.
const PRICES: Record<string, string | undefined> = {
  monthly: Deno.env.get('STRIPE_PRICE_ID_MONTHLY') ??
    Deno.env.get('STRIPE_PRICE_ID'),
  annual: Deno.env.get('STRIPE_PRICE_ID_ANNUAL'),
};
const SITE = (Deno.env.get('SITE_URL') ?? 'https://example.netlify.app')
  .replace(/\/+$/, '');

const admin = createClient(SUPABASE_URL, SERVICE_KEY);

// Locked to the site this app is actually served from.
//
// It was '*'. That is the default every Supabase edge-function example
// ships with and it is wrong here: this endpoint starts a payment, and a
// wildcard lets any page on the internet call it with a token it has got
// hold of. The token is a bearer token in a header rather than a cookie, so
// this was never CSRF — but "any origin may call our checkout endpoint" is
// not a sentence worth defending when one line fixes it.
//
// SITE_URL already exists and is already required for the success and
// cancel URLs, so there is no new secret to set. If it is unset, SITE falls
// back to a placeholder that will not match any real origin, which fails
// CLOSED — the browser refuses the response rather than the function
// admitting everybody.
const CORS = {
  'Access-Control-Allow-Origin': SITE,
  'Access-Control-Allow-Headers':
    'authorization, x-client-info, apikey, content-type',
  // Tells a cache that the response depends on who asked, so a response cut
  // for one origin is never replayed to another.
  'Vary': 'Origin',
};

// Stripe's REST API takes form-encoded bodies. Doing this by hand keeps the
// function free of an SDK dependency, and the encoding is the only fiddly
// part: nested keys become bracketed names.
function form(params: Record<string, string>): string {
  return Object.entries(params)
    .map(([k, v]) => `${encodeURIComponent(k)}=${encodeURIComponent(v)}`)
    .join('&');
}

async function stripe(
  path: string,
  params: Record<string, string>,
): Promise<Record<string, unknown>> {
  const res = await fetch(`https://api.stripe.com/v1/${path}`, {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${STRIPE_KEY}`,
      'Content-Type': 'application/x-www-form-urlencoded',
    },
    body: form(params),
  });
  const body = await res.json();
  if (!res.ok) {
    throw new Error(
      (body?.error?.message as string) ?? `Stripe ${path} failed`,
    );
  }
  return body;
}

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: CORS });

  const json = (body: unknown, status = 200) =>
    new Response(JSON.stringify(body), {
      status,
      headers: { ...CORS, 'Content-Type': 'application/json' },
    });

  const asUser = createClient(SUPABASE_URL, ANON_KEY, {
    global: {
      headers: { Authorization: req.headers.get('Authorization') ?? '' },
    },
  });
  const { data: userData, error: userError } = await asUser.auth.getUser();
  if (userError || !userData?.user) return json({ error: 'Not signed in.' }, 401);
  const student = userData.user;

  try {
    // One Stripe customer per student, created on first contact and reused,
    // so the portal and the webhook always talk about the same person.
    const { data: existing } = await admin
      .from('subscriptions')
      .select('stripe_customer_id')
      .eq('student_id', student.id)
      .maybeSingle();

    let customer = existing?.stripe_customer_id as string | undefined;
    if (!customer) {
      const created = await stripe('customers', {
        email: student.email ?? '',
        'metadata[student_id]': student.id,
      });
      customer = created.id as string;
      // Narrow write on purpose: this sets ONLY the customer id. The old
      // upsert here passed status 'none' and a null period end, which
      // overwrote an e-transfer subscriber's 'manual' grant the moment
      // they opened the Astro+ menu — one tap and a paid year vanished.
      await admin.rpc('set_stripe_customer', {
        p_student: student.id,
        p_customer: customer,
      });
    }

    // ---------------------------------------------------------------------
    // Where the request says what it wants
    // ---------------------------------------------------------------------
    // This used to read ONLY the query string, and the app called it as
    // functions.invoke('create-checkout?plan=annual'). That does not survive
    // the trip: the Supabase client builds the URL from the function NAME, so
    // the ?plan=... never arrived and every request landed with no query.
    //
    // The symptom was quiet rather than loud. A missing plan falls back to
    // 'monthly', so tapping Annual opened a MONTHLY checkout — no error, just
    // the wrong price, which is the kind of bug that reaches a real card.
    // The portal was worse: ?portal=1 vanished too, so "Manage subscription"
    // skipped the billing portal and started a SECOND subscription instead.
    // Cancelling is meant to be one click in there.
    //
    // The body is what functions.invoke is built to send, so it is the source
    // of truth now. The query string stays as a fallback, which means a
    // browser holding a cached copy of the old app keeps working rather than
    // breaking on deploy day.
    let payload: Record<string, unknown> = {};
    try {
      payload = (await req.json()) ?? {};
    } catch (_) {
      // No body, or not JSON. The query-string fallback covers it.
    }

    const url = new URL(req.url);

    const wantsPortal = payload.portal === true ||
      payload.portal === '1' ||
      url.searchParams.get('portal') === '1';

    // The Stripe billing portal, where a family can change card, see invoices,
    // or cancel. Card-network rules require cancellation to be as easy as
    // signing up, and the portal is the honest version of that.
    if (wantsPortal) {
      const session = await stripe('billing_portal/sessions', {
        customer: customer!,
        return_url: `${SITE}/`,
      });
      return json({ url: session.url });
    }

    const plan = String(
      payload.plan ?? url.searchParams.get('plan') ?? 'monthly',
    );
    const priceId = PRICES[plan];
    if (!priceId) {
      // Naming the configured plans makes the difference between "I chose
      // annual and nothing happened" and "STRIPE_PRICE_ID_ANNUAL is not set".
      const configured = Object.entries(PRICES)
        .filter(([, v]) => v)
        .map(([k]) => k)
        .join(', ') || 'none';
      return json(
        { error: `Unknown plan: ${plan}. Plans configured: ${configured}.` },
        400,
      );
    }

    const session = await stripe('checkout/sessions', {
      mode: 'subscription',
      customer: customer!,
      'line_items[0][price]': priceId,
      'line_items[0][quantity]': '1',
      // The student id rides in both places the webhook might look.
      client_reference_id: student.id,
      'subscription_data[metadata][student_id]': student.id,
      success_url: `${SITE}/?upgraded=1`,
      cancel_url: `${SITE}/`,
    });

    return json({ url: session.url });
  } catch (e) {
    return json({ error: (e as Error).message }, 500);
  }
});
