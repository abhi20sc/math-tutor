// ===========================================================================
// send-link — emails a guardian consent link, or an Astro+ payment link
// ===========================================================================
//
//   supabase functions deploy send-link
//
// This is the function that was missing, and its absence is why both the
// consent screen and the Astro+ screen hand the student a link to pass on
// instead of sending it.
//
// THE ONE RULE THAT SHAPES ALL OF IT
//
// The client sends a KIND and nothing else. Not a token, not an address,
// not a name.
//
// The obvious design — POST {to, token} — is a spam relay: anybody with an
// account could send Astro-branded mail to any address, carrying any link.
// So the caller says "send my consent link" and the function derives who
// they are from their JWT, looks up their own token and their own
// guardian's address with the service key, and sends to that. A caller
// cannot name the recipient, so a caller cannot abuse the recipient.
//
// RATE LIMITED, AND IT MATTERS MORE HERE
//
// Every call sends real mail to a real parent. note_rate_limit is the same
// counter the app uses for sign-in, and it fails CLOSED here rather than
// open — the reverse of the app's own choice, and deliberately. A student
// unable to send is inconvenienced; a parent receiving forty emails is a
// complaint about a product for children.
//
// SECRETS
//
//   RESEND_API_KEY   from resend.com
//   REPORT_FROM      e.g. "Astro STEM Labs <hello@astrostemlabs.com>"
//   SITE_URL         the app's origin, used to build the links
//
// WITHOUT RESEND_API_KEY THIS FUNCTION REFUSES CLEANLY. It returns 503 and
// a message the app shows as "we could not send it — here is the link
// instead". That is why the app still works before any of this is set up:
// the fallback is the behaviour, not an error path nobody tested.
// ===========================================================================

import { createClient } from 'jsr:@supabase/supabase-js@2';

const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!;
const SERVICE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
const RESEND_KEY = Deno.env.get('RESEND_API_KEY');
const FROM = Deno.env.get('REPORT_FROM') ??
  'Astro STEM Labs <onboarding@resend.dev>';
const SITE = (Deno.env.get('SITE_URL') ?? 'https://example.netlify.app')
  .replace(/\/+$/, '');

// Locked to the app's own origin, like create-checkout. Never '*'.
const CORS = {
  'Access-Control-Allow-Origin': SITE,
  'Access-Control-Allow-Headers':
    'authorization, x-client-info, apikey, content-type',
  'Vary': 'Origin',
};

const admin = createClient(SUPABASE_URL, SERVICE_KEY);

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...CORS, 'Content-Type': 'application/json' },
  });
}

// Plain text alongside the HTML. A parent's mail client may show either,
// and a message that is only HTML is more likely to be filtered.
async function send(to: string, subject: string, html: string, text: string) {
  const res = await fetch('https://api.resend.com/emails', {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${RESEND_KEY}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ from: FROM, to, subject, html, text }),
  });
  if (!res.ok) {
    // The body carries Resend's own reason — a domain that is not verified
    // is the usual one, and it is worth surfacing rather than swallowing.
    throw new Error(`Resend returned ${res.status}: ${await res.text()}`);
  }
}

// The house style for both messages: short, no marketing, no images, and
// the link in full so it can be read before it is clicked. A parent
// deciding about their child's data should not have to trust a button.
function wrap(heading: string, body: string, link: string, cta: string) {
  const html = `<div style="font-family:Georgia,'Times New Roman',serif;
  max-width:520px;margin:0 auto;padding:24px;color:#1B2430">
  <h1 style="font-size:22px;font-weight:600;margin:0 0 14px">${heading}</h1>
  <div style="font-family:system-ui,-apple-system,sans-serif;font-size:15px;
  line-height:1.6;color:#5C6670">${body}</div>
  <p style="margin:22px 0">
    <a href="${link}" style="background:#1D3557;color:#fff;padding:12px 20px;
    border-radius:10px;text-decoration:none;font-family:system-ui,sans-serif;
    font-size:15px;display:inline-block">${cta}</a>
  </p>
  <p style="font-family:system-ui,sans-serif;font-size:12px;line-height:1.5;
  color:#5C6670">Or paste this into your browser:<br>
  <span style="word-break:break-all">${link}</span></p>
  <p style="font-family:system-ui,sans-serif;font-size:12px;color:#5C6670">
  Astro STEM Labs · stemlabs.ca@gmail.com</p>
</div>`;
  const text = `${heading}\n\n${body.replace(/<[^>]+>/g, '')}\n\n${cta}: ${link}\n\nAstro STEM Labs · stemlabs.ca@gmail.com`;
  return { html, text };
}

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: CORS });

  if (!RESEND_KEY) {
    // Deliberate, and the app depends on this shape: it falls back to
    // showing the link rather than reporting a failure.
    return json({
      error: 'not_configured',
      message: 'Email is not set up yet.',
    }, 503);
  }

  // Who is asking. The JWT is the only identity this function trusts.
  const authHeader = req.headers.get('Authorization') ?? '';
  const jwt = authHeader.replace(/^Bearer\s+/i, '');
  const { data: userData, error: userErr } = await admin.auth.getUser(jwt);
  if (userErr || !userData?.user) {
    return json({ error: 'unauthorised' }, 401);
  }
  const uid = userData.user.id;

  let kind = '';
  try {
    kind = (await req.json())?.kind ?? '';
  } catch {
    return json({ error: 'bad_request' }, 400);
  }
  if (kind !== 'consent' && kind !== 'pay') {
    return json({ error: 'bad_request' }, 400);
  }

  // Three per fifteen minutes per student per kind. Fails CLOSED: if the
  // counter is unreachable we do not send. See the header.
  const { data: allowed, error: limitErr } = await admin.rpc(
    'note_rate_limit',
    { p_bucket: `email:${kind}:${uid}`, p_limit: 3 },
  );
  if (limitErr || allowed === false) {
    return json({
      error: 'rate_limited',
      message: 'That has already been sent. Check the inbox, including spam.',
    }, 429);
  }

  try {
    if (kind === 'consent') {
      const { data: p } = await admin
        .from('profiles')
        .select('full_name, guardian_email, guardian_consent_token')
        .eq('id', uid)
        .single();

      if (!p?.guardian_email || !p?.guardian_consent_token) {
        return json({ error: 'nothing_to_send' }, 409);
      }

      const link = `${SITE}/?consent=${p.guardian_consent_token}`;
      const first = (p.full_name ?? 'Your child').split(' ')[0];
      const { html, text } = wrap(
        'A quick yes, for ' + first,
        `${first} has started using Astro STEM Labs, a maths practice app for
         Ontario students in Grades 9 to 12. Because they are under 18, we
         will not keep any record of their work until you say it is alright.
         <br><br>Opening the link below is all it takes. You do not need an
         account, and you can change your mind at any time by opening the
         same link again.`,
        link,
        'Confirm',
      );
      await send(p.guardian_email, `Please confirm ${first}'s account`, html, text);
      return json({ sent: true, to: p.guardian_email });
    }

    // kind === 'pay'
    const { data: r } = await admin
      .from('enrolment_requests')
      .select('id, student_name, parent_email, parent_name, plan, pay_token')
      .eq('student_id', uid)
      .in('status', ['new', 'sent'])
      .order('created_at', { ascending: false })
      .limit(1)
      .maybeSingle();

    if (!r?.parent_email || !r?.pay_token) {
      return json({ error: 'nothing_to_send' }, 409);
    }

    const link = `${SITE}/?pay=${r.pay_token}`;
    const first = (r.student_name ?? 'Your child').split(' ')[0];
    const price = r.plan === 'annual' ? '$100 CAD a year' : '$10 CAD a month';
    const { html, text } = wrap(
      `Astro+ for ${first}`,
      `${first} has asked about Astro+, which unlocks the Challenge and
       Advanced levels and a tutor who reviews their work. It is ${price}.
       <br><br>Easy and Medium stay free forever, and every medal they have
       already earned stays theirs either way. Nothing is charged until you
       choose to pay.`,
      link,
      'See the details',
    );
    await send(r.parent_email, `Astro+ for ${first}`, html, text);

    // Only after the send succeeded. Marking it sent first and then failing
    // would leave a request nobody chases, which is the worse of the two.
    await admin
      .from('enrolment_requests')
      .update({ status: 'sent', emailed_at: new Date().toISOString() })
      .eq('id', r.id);

    return json({ sent: true, to: r.parent_email });
  } catch (e) {
    return json({
      error: 'send_failed',
      message: e instanceof Error ? e.message : String(e),
    }, 502);
  }
});
