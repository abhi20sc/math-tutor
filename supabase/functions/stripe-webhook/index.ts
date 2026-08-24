// ===========================================================================
// stripe-webhook — Supabase Edge Function
// ===========================================================================
// Stripe calls this when money moves. It is the ONLY writer of the
// subscriptions table, which is what makes the paywall trustworthy: access
// changes when Stripe says so, never when a browser does.
//
// ---------------------------------------------------------------------------
// Setup
// ---------------------------------------------------------------------------
//   mkdir -p supabase/functions/stripe-webhook
//   cp ~/Downloads/stripe-webhook.ts supabase/functions/stripe-webhook/index.ts
//   supabase functions deploy stripe-webhook --no-verify-jwt
//
// --no-verify-jwt matters: Stripe is not a signed-in user, so Supabase's own
// JWT check must stand aside. What replaces it is the signature check below,
// which is stronger for this purpose — it proves the request came from
// Stripe and nobody else.
//
// Then in Stripe: Developers → Webhooks → Add endpoint →
//   https://frkswzowskeqmgdrrwab.supabase.co/functions/v1/stripe-webhook
// Events to send:
//   checkout.session.completed
//   customer.subscription.updated
//   customer.subscription.deleted
// Copy the signing secret (whsec_...) and:
//   supabase secrets set STRIPE_WEBHOOK_SECRET=whsec_xxx
//
// Test the whole loop with card 4242 4242 4242 4242 before any real key.

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!;
const SERVICE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
const STRIPE_KEY = Deno.env.get('STRIPE_SECRET_KEY')!;
const WEBHOOK_SECRET = Deno.env.get('STRIPE_WEBHOOK_SECRET')!;

const admin = createClient(SUPABASE_URL, SERVICE_KEY);

// ---------------------------------------------------------------------------
// Signature verification, by hand.
//
// Stripe signs every delivery: the Stripe-Signature header carries a
// timestamp and an HMAC-SHA256 of "timestamp.body" under the endpoint
// secret. Recomputing it proves the payload came from Stripe unaltered.
// Skip this and anyone who finds the URL can POST a forged
// "checkout.session.completed" and grant themselves a subscription — the
// whole paywall would hang on an unauthenticated endpoint.
// ---------------------------------------------------------------------------

async function verify(body: string, header: string | null): Promise<boolean> {
  if (!header) return false;

  const parts = Object.fromEntries(
    header.split(',').map((p) => p.split('=') as [string, string]),
  );
  const timestamp = parts['t'];
  const signature = parts['v1'];
  if (!timestamp || !signature) return false;

  // Older than five minutes gets refused, which is what stops a captured
  // request being replayed later.
  if (Math.abs(Date.now() / 1000 - Number(timestamp)) > 300) return false;

  const key = await crypto.subtle.importKey(
    'raw',
    new TextEncoder().encode(WEBHOOK_SECRET),
    { name: 'HMAC', hash: 'SHA-256' },
    false,
    ['sign'],
  );
  const mac = await crypto.subtle.sign(
    'HMAC',
    key,
    new TextEncoder().encode(`${timestamp}.${body}`),
  );
  const expected = Array.from(new Uint8Array(mac))
    .map((b) => b.toString(16).padStart(2, '0'))
    .join('');

  // Constant-time comparison. A byte-by-byte early exit leaks how much of a
  // guessed signature matched, which is enough to forge one eventually.
  if (expected.length !== signature.length) return false;
  let diff = 0;
  for (let i = 0; i < expected.length; i++) {
    diff |= expected.charCodeAt(i) ^ signature.charCodeAt(i);
  }
  return diff === 0;
}

// Fetch a subscription from Stripe, because several events carry only ids.
// Throws on a non-2xx: the catch below turns that into a 500, Stripe
// retries, and nothing is granted meanwhile. The old version returned the
// error body, whose missing status fell through to a default of 'active' —
// a Stripe outage must never hand out premium.
async function fetchSubscription(id: string): Promise<Record<string, unknown>> {
  const res = await fetch(`https://api.stripe.com/v1/subscriptions/${id}`, {
    headers: { Authorization: `Bearer ${STRIPE_KEY}` },
  });
  if (!res.ok) {
    throw new Error(`Stripe subscriptions/${id} returned ${res.status}`);
  }
  return await res.json();
}

const periodEnd = (sub: Record<string, unknown>): string | null =>
  sub.current_period_end
    ? new Date((sub.current_period_end as number) * 1000).toISOString()
    : null;

Deno.serve(async (req: Request) => {
  const body = await req.text();

  if (!(await verify(body, req.headers.get('Stripe-Signature')))) {
    return new Response('Bad signature', { status: 400 });
  }

  const event = JSON.parse(body);
  // deno-lint-ignore no-explicit-any
  const obj = event.data?.object as any;

  try {
    switch (event.type) {
      case 'checkout.session.completed': {
        const student = obj.client_reference_id as string | null;
        const subId = obj.subscription as string | null;
        // completed is not the same as PAID: for asynchronous payment
        // methods the session completes before the money settles, and a
        // grant here would be access for free. Card payments — all this
        // product sells today — arrive as 'paid', so this check costs
        // nothing until the day someone enables a new payment method in
        // Stripe, which is exactly when it starts mattering.
        if (obj.payment_status !== 'paid') break;
        if (student && subId) {
          const sub = await fetchSubscription(subId);
          await admin.rpc('upsert_subscription', {
            p_student: student,
            p_customer: obj.customer,
            p_sub: subId,
            p_status: (sub.status as string) ?? 'incomplete',
            p_period_end: periodEnd(sub),
          });
        }
        break;
      }

      case 'customer.subscription.updated':
      case 'customer.subscription.deleted': {
        // These carry the Stripe id, not the student; the row is found by
        // subscription id. status becomes whatever Stripe says — 'canceled',
        // 'past_due', 'active' — and has_premium() in the database is the
        // single place that decides what those words mean for access.
        await admin.rpc('update_subscription_by_sid', {
          p_sub: obj.id,
          p_status: obj.status,
          p_period_end: periodEnd(obj),
        });
        break;
      }

      default:
        // Unhandled event types are acknowledged, not errored: Stripe
        // retries failures, and retrying something we ignore on purpose
        // just fills their dashboard with red.
        break;
    }

    return new Response(JSON.stringify({ received: true }), {
      headers: { 'Content-Type': 'application/json' },
    });
  } catch (e) {
    // A 500 makes Stripe retry later, which is what you want if the
    // database was briefly unreachable.
    return new Response((e as Error).message, { status: 500 });
  }
});
