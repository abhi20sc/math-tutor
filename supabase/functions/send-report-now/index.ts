// ===========================================================================
// send-report-now — Supabase Edge Function
// ===========================================================================
// The Send a report now button in the app.
//
// Deploy exactly like the weekly one:
//
//   mkdir -p supabase/functions/send-report-now
//   cp ~/Downloads/send-report-now.ts supabase/functions/send-report-now/index.ts
//   supabase functions deploy send-report-now
//
// It reuses the same secrets, so nothing extra to set.
//
// ---------------------------------------------------------------------------
// Why this exists as a separate function rather than a button that emails
// ---------------------------------------------------------------------------
// Sending needs two things a browser must never hold: the service key, which
// bypasses row level security entirely, and the consent tokens, which are the
// only credential on the unsubscribe links.
//
// So the app sends nothing. It calls this, which works out WHO is asking from
// their own sign-in token and then can only ever send that person's report.
// A student cannot ask it to send somebody else's, because their identity is
// taken from the token rather than from anything they typed.
//
// The one-a-day limit is enforced in the database too, inside
// manual_report_for. The check in the app is a courtesy; this one is the rule.

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!;
const SERVICE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
const ANON_KEY = Deno.env.get('SUPABASE_ANON_KEY')!;
const RESEND_KEY = Deno.env.get('RESEND_API_KEY')!;
const FROM = Deno.env.get('REPORT_FROM') ?? 'Math Tutor <reports@example.ca>';
const SITE = (Deno.env.get('SITE_URL') ?? 'https://example.netlify.app')
  .replace(/\/+$/, ''); // a trailing slash would make every link a double one

const admin = createClient(SUPABASE_URL, SERVICE_KEY);

const CORS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers':
    'authorization, x-client-info, apikey, content-type',
};

// --------------------------------------------------------------------------
// Rendering — identical output to the weekly job, so a report a student sends
// on a Tuesday looks exactly like the one that arrives on Sunday.
// --------------------------------------------------------------------------

const esc = (t: unknown) =>
  String(t ?? '')
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;');

const MEDAL_COLOURS: Record<string, string> = {
  Gold: '#C79A2E',
  Silver: '#7A828A',
  Bronze: '#B07348',
};

// deno-lint-ignore no-explicit-any
function summary(name: string, p: any): string {
  const first = esc(name.split(' ')[0]);
  if (!p.questions_seen) return `${first} has not practised yet this week.`;

  const rate = p.first_try_rate ?? 0;
  const days = p.days_active;
  const medals = p.medals_earned?.length ?? 0;

  let line =
    `${first} practised on <strong>${days} ${days === 1 ? 'day' : 'days'}</strong>` +
    `, worked through <strong>${p.questions_seen} questions</strong>`;
  if (medals > 0) {
    line += `, and finished ${medals === 1 ? 'a unit' : `${medals} units`}`;
  }
  line += '.';

  if (rate >= 85) line += ' Most of it landed first time.';
  else if (rate >= 60) line += ' Most of it landed on the first or second try.';
  else if (rate > 0) {
    line +=
      ' A lot of it needed a second attempt, which is what the section below is about.';
  }
  return line;
}

const statCell = (value: string, label: string) =>
  `<td width="33%" align="center" style="padding:14px 6px;background:#F6F5F1;border-radius:10px;">
     <div style="font-size:27px;color:#2F6F62;">${esc(value)}</div>
     <div style="font-family:Helvetica,Arial,sans-serif;font-size:11px;color:#6E7772;padding-top:3px;">${esc(label)}</div>
   </td>`;

// deno-lint-ignore no-explicit-any
function render(name: string, p: any, token: string): string {
  const rate = p.first_try_rate == null ? '—' : `${p.first_try_rate}%`;

  const medals = (p.medals_earned ?? [])
    // deno-lint-ignore no-explicit-any
    .map((m: any) => {
      const colour = MEDAL_COLOURS[m.medal] ?? '#6E7772';
      return `<tr><td style="padding:11px 14px;background:#FBF9F4;border-radius:10px;border-left:3px solid ${colour};">
        <span style="font-size:15px;color:#1E2422;"><strong style="color:${colour};">${esc(m.medal)}</strong>&nbsp;${esc(m.unit)}</span>
      </td></tr><tr><td style="height:8px;"></td></tr>`;
    })
    .join('');

  const units = (p.units ?? [])
    // deno-lint-ignore no-explicit-any
    .map(
      (u: any) => `<tr>
        <td style="padding:9px 0;border-bottom:1px solid #E2E0D9;color:#1E2422;">${esc(u.unit)}</td>
        <td align="right" style="padding:9px 0;border-bottom:1px solid #E2E0D9;color:${
        u.first_try === 0 && u.questions > 0 ? '#B9791C' : '#6E7772'
      };">${u.first_try} of ${u.questions} first try</td></tr>`,
    )
    .join('');

  const weak = (p.weak_spots ?? [])
    // deno-lint-ignore no-explicit-any
    .map(
      (w: any) =>
        `<tr><td style="padding-bottom:8px;">&bull;&nbsp; <strong>${esc(w.label)}</strong> <span style="color:#6E7772;">(${esc(w.unit)})</span></td></tr>`,
    )
    .join('');

  return `<!DOCTYPE html><html><body style="margin:0;padding:0;background:#F6F5F1;">
<table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="background:#F6F5F1;padding:24px 12px;">
<tr><td align="center">
<table role="presentation" width="600" cellpadding="0" cellspacing="0" style="max-width:600px;width:100%;background:#ffffff;border-radius:14px;overflow:hidden;font-family:Georgia,'Times New Roman',serif;">

  <tr><td style="background:#2F6F62;padding:26px 30px;">
    <p style="margin:0 0 6px;font-family:Helvetica,Arial,sans-serif;font-size:11px;letter-spacing:1.4px;text-transform:uppercase;color:#BFD8D1;">This week so far</p>
    <h1 style="margin:0;font-size:25px;font-weight:normal;color:#ffffff;">How ${esc(name.split(' ')[0])} is getting on</h1>
    <p style="margin:7px 0 0;font-family:Helvetica,Arial,sans-serif;font-size:13px;color:#CFE2DC;">Grade ${esc(p.grade ?? '')} &middot; sent by ${esc(name.split(' ')[0])}</p>
  </td></tr>

  <tr><td style="padding:26px 30px 6px;">
    <p style="margin:0;font-size:17px;line-height:1.6;color:#1E2422;">${summary(name, p)}</p>
  </td></tr>

  <tr><td style="padding:20px 30px 4px;">
    <table role="presentation" width="100%" cellpadding="0" cellspacing="0"><tr>
      ${statCell(String(p.questions_seen), 'questions')}<td width="8"></td>
      ${statCell(rate, 'right first try')}<td width="8"></td>
      ${statCell(String(p.days_active), 'days practised')}
    </tr></table>
  </td></tr>

  ${medals ? `<tr><td style="padding:24px 30px 0;">
    <h2 style="margin:0 0 12px;font-family:Helvetica,Arial,sans-serif;font-size:11px;letter-spacing:1.3px;text-transform:uppercase;color:#6E7772;">Earned this week</h2>
    <table role="presentation" width="100%" cellpadding="0" cellspacing="0">${medals}</table></td></tr>` : ''}

  ${units ? `<tr><td style="padding:26px 30px 0;">
    <h2 style="margin:0 0 12px;font-family:Helvetica,Arial,sans-serif;font-size:11px;letter-spacing:1.3px;text-transform:uppercase;color:#6E7772;">Where the time went</h2>
    <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="font-family:Helvetica,Arial,sans-serif;font-size:13px;">${units}</table></td></tr>` : ''}

  ${weak ? `<tr><td style="padding:26px 30px 0;">
    <table role="presentation" width="100%" cellpadding="0" cellspacing="0"><tr>
    <td style="padding:18px 20px;background:#FCF5E9;border-radius:12px;border-left:3px solid #B9791C;">
      <h2 style="margin:0 0 10px;font-family:Helvetica,Arial,sans-serif;font-size:11px;letter-spacing:1.3px;text-transform:uppercase;color:#B9791C;">What ${esc(name.split(' ')[0])} is getting stuck on</h2>
      <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="font-size:14.5px;line-height:1.55;color:#1E2422;">${weak}</table>
      <p style="margin:14px 0 0;font-family:Helvetica,Arial,sans-serif;font-size:12.5px;line-height:1.55;color:#6E7772;">These are specific habits rather than gaps in effort. Asking about one out loud is usually enough — the point is catching it, not learning it again.</p>
    </td></tr></table></td></tr>` : ''}

  <tr><td style="padding:24px 30px 0;">
    <p style="margin:0;font-family:Helvetica,Arial,sans-serif;font-size:12px;line-height:1.6;color:#6E7772;">
      This is a practice app, not a test. Wrong answers are the point — each one explains the mistake before the right answer is shown.
    </p></td></tr>

  <tr><td style="padding:26px 30px 28px;">
    <hr style="border:none;border-top:1px solid #E2E0D9;margin:0 0 16px;">
    <p style="margin:0 0 8px;font-family:Helvetica,Arial,sans-serif;font-size:11.5px;line-height:1.6;color:#8A918D;">
      ${esc(name.split(' ')[0])} sent you this from the app. You also receive a summary each Sunday.
    </p>
    <p style="margin:0;font-family:Helvetica,Arial,sans-serif;font-size:11.5px;color:#8A918D;">
      <a href="${SITE}/unsubscribe?token=${esc(token)}" style="color:#2F6F62;">Stop receiving these</a> &nbsp;&middot;&nbsp; Math Tutor
    </p></td></tr>

</table></td></tr></table></body></html>`;
}

// --------------------------------------------------------------------------

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: CORS });

  const json = (body: unknown, status = 200) =>
    new Response(JSON.stringify(body), {
      status,
      headers: { ...CORS, 'Content-Type': 'application/json' },
    });

  // Who is asking. Taken from their own sign-in token, never from the body,
  // which is what stops one student sending another student's report.
  const authHeader = req.headers.get('Authorization') ?? '';
  const asUser = createClient(SUPABASE_URL, ANON_KEY, {
    global: { headers: { Authorization: authHeader } },
  });

  const { data: userData, error: userError } = await asUser.auth.getUser();
  if (userError || !userData?.user) {
    return json({ error: 'Not signed in.' }, 401);
  }
  const studentId = userData.user.id;

  const { data: rows, error } = await admin.rpc('manual_report_for', {
    p_student: studentId,
  });
  if (error) return json({ error: error.message }, 500);

  // Empty means either nobody has confirmed, or one already went today. The
  // database decided that, not the app.
  if (!rows || rows.length === 0) return json({ sent: 0 });

  const { data: profile } = await admin
    .from('profiles')
    .select('full_name, email')
    .eq('id', studentId)
    .maybeSingle();

  const name =
    (profile?.full_name ?? '').trim() ||
    (profile?.email ?? 'your child').split('@')[0];

  let sent = 0;
  for (const row of rows) {
    const payload = { ...row.payload, grade: row.grade };
    const html = render(name, payload, row.unsubscribe);

    const res = await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${RESEND_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        from: FROM,
        to: row.email,
        subject: `${name.split(' ')[0]} — maths practice update`,
        html,
        headers: {
          'List-Unsubscribe': `<${SITE}/unsubscribe?token=${row.unsubscribe}>`,
          'List-Unsubscribe-Post': 'List-Unsubscribe=One-Click',
        },
      }),
    });

    // Only log a send that actually happened. Logging a failure would burn
    // the daily allowance on an email nobody received.
    if (res.ok) {
      sent++;
      await admin.rpc('record_report_sent', {
        p_recipient_id: row.recipient_id,
        p_week_start: payload.week_start,
        p_payload: row.payload,
        p_kind: 'manual',
      });
    }
  }

  return json({ sent });
});
