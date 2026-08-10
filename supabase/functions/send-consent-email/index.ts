// ===========================================================================
// send-consent-email — Supabase Edge Function
// ===========================================================================
// The email a guardian gets when a student adds them, asking whether they
// want the weekly reports at all.
//
// Deploy:
//   mkdir -p supabase/functions/send-consent-email
//   cp ~/Downloads/send-consent-email.ts supabase/functions/send-consent-email/index.ts
//   supabase functions deploy send-consent-email
//
// Reuses the same secrets as the other two. Nothing extra to set.
//
// ---------------------------------------------------------------------------
// What makes this the important one
// ---------------------------------------------------------------------------
// Until somebody clicks the link in this email, that address is 'pending' and
// receives nothing. It is the entire double opt-in — the difference between
// "a student typed an address" and "a guardian agreed".
//
// The consent token comes from pending_consents_for, which is service_role
// only. It never passes through a browser. A student who could read their own
// guardian's token could confirm on their behalf, and the whole thing would
// be decoration.
//
// The tone matters more here than anywhere else in the project. This arrives
// unsolicited, about somebody's child, from a name they do not recognise. It
// has to read as a question rather than an announcement, say plainly what
// would and would not be shared, and make declining as easy as accepting —
// which, since ignoring it works, it already is.

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!;
const SERVICE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
const ANON_KEY = Deno.env.get('SUPABASE_ANON_KEY')!;
const RESEND_KEY = Deno.env.get('RESEND_API_KEY')!;
const FROM = Deno.env.get('REPORT_FROM') ?? 'Math Tutor <reports@example.ca>';
const SITE = (Deno.env.get('SITE_URL') ?? 'https://example.netlify.app')
  .replace(/\/+$/, '');

const admin = createClient(SUPABASE_URL, SERVICE_KEY);

const CORS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers':
    'authorization, x-client-info, apikey, content-type',
};

const esc = (t: unknown) =>
  String(t ?? '')
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;');

function render(student: string, grade: number, token: string): string {
  const first = esc(student.split(' ')[0]);

  return `<!DOCTYPE html><html><body style="margin:0;padding:0;background:#F6F5F1;">
<div style="display:none;max-height:0;overflow:hidden;opacity:0;">${first} would like you to receive a weekly summary of their maths practice.</div>
<table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="background:#F6F5F1;padding:24px 12px;">
<tr><td align="center">
<table role="presentation" width="600" cellpadding="0" cellspacing="0" style="max-width:600px;width:100%;background:#ffffff;border-radius:14px;overflow:hidden;font-family:Georgia,'Times New Roman',serif;">

  <tr><td style="background:#2F6F62;padding:26px 30px;">
    <h1 style="margin:0;font-size:24px;font-weight:normal;color:#ffffff;">
      ${first} would like to share their maths practice with you
    </h1>
  </td></tr>

  <tr><td style="padding:26px 30px 4px;">
    <p style="margin:0 0 14px;font-size:16px;line-height:1.65;color:#1E2422;">
      ${first} is using Math Tutor to practise Grade ${esc(grade)} maths, and has
      added this address to receive a short weekly summary.
    </p>
    <p style="margin:0;font-size:16px;line-height:1.65;color:#1E2422;">
      Nothing has been sent yet, and nothing will be unless you say yes below.
    </p>
  </td></tr>

  <tr><td style="padding:22px 30px 0;">
    <table role="presentation" width="100%" cellpadding="0" cellspacing="0"><tr>
    <td style="padding:18px 20px;background:#F6F5F1;border-radius:12px;">
      <h2 style="margin:0 0 10px;font-family:Helvetica,Arial,sans-serif;font-size:11px;letter-spacing:1.3px;text-transform:uppercase;color:#6E7772;">What you would get</h2>
      <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="font-size:14.5px;line-height:1.6;color:#1E2422;">
        <tr><td style="padding-bottom:6px;">&bull;&nbsp; How much they practised, and on how many days</td></tr>
        <tr><td style="padding-bottom:6px;">&bull;&nbsp; Which topics they worked on and how those went</td></tr>
        <tr><td>&bull;&nbsp; The specific mistakes they keep making, in plain words</td></tr>
      </table>
      <p style="margin:12px 0 0;font-family:Helvetica,Arial,sans-serif;font-size:13px;line-height:1.55;color:#6E7772;">
        One email on Sunday evening, and only in weeks they actually practised. ${first} can also send you one directly.
      </p>
    </td></tr></table>
  </td></tr>

  <tr><td style="padding:14px 30px 0;">
    <table role="presentation" width="100%" cellpadding="0" cellspacing="0"><tr>
    <td style="padding:18px 20px;background:#F6F5F1;border-radius:12px;">
      <h2 style="margin:0 0 10px;font-family:Helvetica,Arial,sans-serif;font-size:11px;letter-spacing:1.3px;text-transform:uppercase;color:#6E7772;">What you would not</h2>
      <p style="margin:0;font-size:14.5px;line-height:1.6;color:#1E2422;">
        No questions, no answers they gave, and no school marks. This is a practice app rather than a test, and the summary is meant to tell you what to help with, not what they got wrong.
      </p>
    </td></tr></table>
  </td></tr>

  <tr><td align="center" style="padding:26px 30px 6px;">
    <a href="${SITE}/confirm?token=${esc(token)}"
       style="display:inline-block;background:#2F6F62;color:#ffffff;text-decoration:none;font-family:Helvetica,Arial,sans-serif;font-size:15.5px;font-weight:600;padding:15px 30px;border-radius:12px;">
      Yes, send me the weekly report
    </a>
  </td></tr>

  <tr><td align="center" style="padding:12px 30px 0;">
    <p style="margin:0;font-family:Helvetica,Arial,sans-serif;font-size:12.5px;line-height:1.6;color:#8A918D;">
      If you would rather not, ignore this email. Nothing will be sent, and you will not be asked again unless ${first} adds you a second time.
    </p>
  </td></tr>

  <tr><td style="padding:26px 30px 28px;">
    <hr style="border:none;border-top:1px solid #E2E0D9;margin:0 0 16px;">
    <p style="margin:0;font-family:Helvetica,Arial,sans-serif;font-size:11.5px;line-height:1.6;color:#8A918D;">
      If you do not know ${first} or think this was sent by mistake, ignoring it is enough — the address stays inactive. Math Tutor
    </p>
  </td></tr>

</table></td></tr></table></body></html>`;
}

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: CORS });

  const json = (body: unknown, status = 200) =>
    new Response(JSON.stringify(body), {
      status,
      headers: { ...CORS, 'Content-Type': 'application/json' },
    });

  // Identity comes from the caller's own sign-in token, so a student can only
  // ever trigger consent emails for people on their own list.
  const asUser = createClient(SUPABASE_URL, ANON_KEY, {
    global: {
      headers: { Authorization: req.headers.get('Authorization') ?? '' },
    },
  });

  const { data: userData, error: userError } = await asUser.auth.getUser();
  if (userError || !userData?.user) return json({ error: 'Not signed in.' }, 401);

  const { data: rows, error } = await admin.rpc('pending_consents_for', {
    p_student: userData.user.id,
  });
  if (error) return json({ error: error.message }, 500);
  if (!rows || rows.length === 0) return json({ sent: 0 });

  let sent = 0;
  for (const row of rows) {
    const res = await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${RESEND_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        from: FROM,
        to: row.email,
        subject: `${row.student_name.split(' ')[0]} would like to share their maths practice with you`,
        html: render(row.student_name, row.grade, row.token),
      }),
    });

    // Only mark it sent if it went. Marking a failure would leave the guardian
    // waiting on an email that never arrives, with no retry for a day.
    if (res.ok) {
      sent++;
      await admin.rpc('mark_consent_sent', { p_recipient_id: row.recipient_id });
    }
  }

  return json({ sent });
});
