// ===========================================================================
// send-weekly-reports — Supabase Edge Function
// ===========================================================================
// This is the piece SQL cannot do. It runs once a week, asks the database
// which reports are due, renders each one as HTML, sends it, and records what
// went out.
//
// ---------------------------------------------------------------------------
// Deploying it (about ten minutes, one time)
// ---------------------------------------------------------------------------
//
//  1. Install the Supabase CLI:
//        brew install supabase/tap/supabase
//
//  2. From the project folder:
//        supabase login
//        supabase link --project-ref frkswzowskeqmgdrrwab
//
//  3. Put this file at:
//        supabase/functions/send-weekly-reports/index.ts
//
//  4. Get a sending key from https://resend.com (free tier is plenty), verify
//     a domain or use their test address, then:
//        supabase secrets set RESEND_API_KEY=re_xxxxxxxx
//        supabase secrets set REPORT_FROM="Math Tutor <reports@yourdomain.ca>"
//        supabase secrets set SITE_URL=https://your-site.netlify.app
//
//  5. Deploy:
//        supabase functions deploy send-weekly-reports
//
//  6. Test it by hand before scheduling anything:
//        curl -X POST \
//          "https://frkswzowskeqmgdrrwab.supabase.co/functions/v1/send-weekly-reports?dry=1" \
//          -H "Authorization: Bearer YOUR_SERVICE_ROLE_KEY"
//
//     With ?dry=1 it renders and returns the emails WITHOUT sending them.
//     Read one before you ever let it send for real.
//
//  7. Schedule it. In the SQL editor:
//        create extension if not exists pg_cron;
//        create extension if not exists pg_net;
//
//        select cron.schedule(
//          'weekly-parent-reports',
//          '0 18 * * 0',                     -- Sundays at 18:00 UTC
//          $$
//          select net.http_post(
//            url := 'https://frkswzowskeqmgdrrwab.supabase.co/functions/v1/send-weekly-reports',
//            headers := jsonb_build_object(
//              'Authorization', 'Bearer YOUR_SERVICE_ROLE_KEY',
//              'Content-Type', 'application/json')
//          );
//          $$
//        );
//
// ---------------------------------------------------------------------------
// Two things not to change without thinking
// ---------------------------------------------------------------------------
//
// The service role key lives only in Edge Function secrets. It bypasses RLS
// entirely, which is why reports_due can read across students — and why that
// key must never appear in main.dart or anywhere the browser can reach.
//
// Every email carries a working unsubscribe link built from the consent
// token. Under CASL that is a legal requirement in Canada, not a nicety, and
// a guardian must never need an account to stop mail about their own child.

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!;
const SERVICE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
const RESEND_KEY = Deno.env.get('RESEND_API_KEY')!;
const FROM = Deno.env.get('REPORT_FROM') ?? 'Math Tutor <reports@example.ca>';
const SITE = Deno.env.get('SITE_URL') ?? 'https://example.netlify.app';

const db = createClient(SUPABASE_URL, SERVICE_KEY);

// --------------------------------------------------------------------------
// Rendering
// --------------------------------------------------------------------------
// Email is not the web. Tables for layout because Outlook ignores flexbox
// and grid. Inline styles because Gmail strips <style> blocks. No web fonts,
// no background images, no JavaScript, 600px wide.

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

/** The opening line. Said in words, and never praise the numbers do not
 *  support — a parent who learns to distrust the first sentence stops
 *  reading the useful part further down. */
function summary(name: string, p: Report): string {
  const first = name.split(' ')[0];
  if (!p.questions_seen) return `${esc(first)} did not practise this week.`;

  const rate = p.first_try_rate ?? 0;
  const days = p.days_active;
  const medals = p.medals_earned?.length ?? 0;

  const bits: string[] = [];
  bits.push(
    `${esc(first)} practised on <strong>${days} ${days === 1 ? 'day' : 'days'}</strong>`,
  );
  bits.push(
    `worked through <strong>${p.questions_seen} questions</strong>`,
  );
  if (medals > 0) {
    bits.push(
      `and finished ${medals === 1 ? 'a unit' : `${medals} units`}`,
    );
  }

  let close = '';
  if (rate >= 85) close = ' Most of it landed first time.';
  else if (rate >= 60) close = ' Most of it landed on the first or second try.';
  else if (rate > 0) {
    close =
      ' A lot of it needed a second attempt, which is what the section below is about.';
  }

  return bits.join(', ') + '.' + close;
}

function statCell(value: string, label: string): string {
  return `<td width="33%" align="center" style="padding:14px 6px;background:#F6F5F1;border-radius:10px;">
    <div style="font-size:27px;color:#2F6F62;">${esc(value)}</div>
    <div style="font-family:Helvetica,Arial,sans-serif;font-size:11px;color:#6E7772;padding-top:3px;">${esc(label)}</div>
  </td>`;
}

function render(name: string, p: Report, token: string): string {
  const rate = p.first_try_rate == null ? '—' : `${p.first_try_rate}%`;
  const prev = p.previous_week ?? {};

  const medals = (p.medals_earned ?? [])
    .map((m) => {
      const colour = MEDAL_COLOURS[m.medal] ?? '#6E7772';
      return `<tr><td style="padding:11px 14px;background:#FBF9F4;border-radius:10px;border-left:3px solid ${colour};">
        <span style="font-size:15px;color:#1E2422;">
          <strong style="color:${colour};">${esc(m.medal)}</strong>&nbsp;${esc(m.unit)}
        </span></td></tr><tr><td style="height:8px;"></td></tr>`;
    })
    .join('');

  const units = (p.units ?? [])
    .map(
      (u) => `<tr>
        <td style="padding:9px 0;border-bottom:1px solid #E2E0D9;color:#1E2422;">${esc(u.unit)}</td>
        <td align="right" style="padding:9px 0;border-bottom:1px solid #E2E0D9;color:${
        u.first_try === 0 && u.questions > 0 ? '#B9791C' : '#6E7772'
      };">${u.first_try} of ${u.questions} first try</td>
      </tr>`,
    )
    .join('');

  const weak = (p.weak_spots ?? [])
    .map(
      (w) =>
        `<tr><td style="padding-bottom:8px;">&bull;&nbsp; <strong>${esc(w.label)}</strong>
          <span style="color:#6E7772;">(${esc(w.unit)})</span></td></tr>`,
    )
    .join('');

  const comparison = prev.questions_seen
    ? `<p style="margin:12px 0 0;font-family:Helvetica,Arial,sans-serif;font-size:12.5px;color:#6E7772;">
         Last week: ${prev.questions_seen} questions, ${
      prev.first_try_rate == null ? '—' : prev.first_try_rate + '%'
    } first try, ${prev.days_active} ${prev.days_active === 1 ? 'day' : 'days'}.
       </p>`
    : `<p style="margin:12px 0 0;font-family:Helvetica,Arial,sans-serif;font-size:12.5px;color:#6E7772;">
         First week of practice.
       </p>`;

  const weekLabel = new Date(p.week_start + 'T00:00:00Z').toLocaleDateString(
    'en-CA',
    { day: 'numeric', month: 'long', timeZone: 'UTC' },
  );

  return `<!DOCTYPE html><html><body style="margin:0;padding:0;background:#F6F5F1;">
<div style="display:none;max-height:0;overflow:hidden;opacity:0;">${esc(name)} practised on ${p.days_active} days this week.</div>
<table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="background:#F6F5F1;padding:24px 12px;">
<tr><td align="center">
<table role="presentation" width="600" cellpadding="0" cellspacing="0" style="max-width:600px;width:100%;background:#ffffff;border-radius:14px;overflow:hidden;font-family:Georgia,'Times New Roman',serif;">

  <tr><td style="background:#2F6F62;padding:26px 30px;">
    <p style="margin:0 0 6px;font-family:Helvetica,Arial,sans-serif;font-size:11px;letter-spacing:1.4px;text-transform:uppercase;color:#BFD8D1;">Week of ${esc(weekLabel)}</p>
    <h1 style="margin:0;font-size:25px;font-weight:normal;color:#ffffff;">How ${esc(name.split(' ')[0])} got on this week</h1>
    <p style="margin:7px 0 0;font-family:Helvetica,Arial,sans-serif;font-size:13px;color:#CFE2DC;">Grade ${p.grade ?? ''}</p>
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
    ${comparison}
  </td></tr>

  ${
    medals
      ? `<tr><td style="padding:24px 30px 0;">
      <h2 style="margin:0 0 12px;font-family:Helvetica,Arial,sans-serif;font-size:11px;letter-spacing:1.3px;text-transform:uppercase;color:#6E7772;">Earned this week</h2>
      <table role="presentation" width="100%" cellpadding="0" cellspacing="0">${medals}</table>
    </td></tr>`
      : ''
  }

  ${
    units
      ? `<tr><td style="padding:26px 30px 0;">
      <h2 style="margin:0 0 12px;font-family:Helvetica,Arial,sans-serif;font-size:11px;letter-spacing:1.3px;text-transform:uppercase;color:#6E7772;">Where the time went</h2>
      <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="font-family:Helvetica,Arial,sans-serif;font-size:13px;">${units}</table>
    </td></tr>`
      : ''
  }

  ${
    weak
      ? `<tr><td style="padding:26px 30px 0;">
      <table role="presentation" width="100%" cellpadding="0" cellspacing="0"><tr>
      <td style="padding:18px 20px;background:#FCF5E9;border-radius:12px;border-left:3px solid #B9791C;">
        <h2 style="margin:0 0 10px;font-family:Helvetica,Arial,sans-serif;font-size:11px;letter-spacing:1.3px;text-transform:uppercase;color:#B9791C;">What ${esc(name.split(' ')[0])} is getting stuck on</h2>
        <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="font-size:14.5px;line-height:1.55;color:#1E2422;">${weak}</table>
        <p style="margin:14px 0 0;font-family:Helvetica,Arial,sans-serif;font-size:12.5px;line-height:1.55;color:#6E7772;">
          These are specific habits rather than gaps in effort. Asking about one of them out loud is usually enough — the point is catching it, not learning it again.
        </p>
      </td></tr></table>
    </td></tr>`
      : ''
  }

  <tr><td style="padding:24px 30px 0;">
    <p style="margin:0;font-family:Helvetica,Arial,sans-serif;font-size:12px;line-height:1.6;color:#6E7772;">
      This is a practice app, not a test. Nothing here is a school mark, and wrong answers are the point — each one explains the mistake before the right answer is shown. A week with more mistakes than usual is often a week of harder work.
    </p>
  </td></tr>

  <tr><td style="padding:26px 30px 28px;">
    <hr style="border:none;border-top:1px solid #E2E0D9;margin:0 0 16px;">
    <p style="margin:0 0 8px;font-family:Helvetica,Arial,sans-serif;font-size:11.5px;line-height:1.6;color:#8A918D;">
      You receive this because ${esc(name.split(' ')[0])} added you and you confirmed it. They can see who is on that list and remove anyone at any time.
    </p>
    <p style="margin:0;font-family:Helvetica,Arial,sans-serif;font-size:11.5px;color:#8A918D;">
      <a href="${SITE}/unsubscribe?token=${esc(token)}" style="color:#2F6F62;">Stop receiving these</a> &nbsp;&middot;&nbsp; Math Tutor
    </p>
  </td></tr>

</table></td></tr></table></body></html>`;
}

// --------------------------------------------------------------------------
// Types, matching the weekly_report() payload
// --------------------------------------------------------------------------

interface Report {
  week_start: string;
  questions_seen: number;
  first_try: number;
  first_try_rate: number | null;
  wrong_taps: number;
  units_touched: number;
  days_active: number;
  grade?: number;
  previous_week?: {
    questions_seen?: number;
    first_try_rate?: number | null;
    days_active?: number;
  };
  units?: Array<{ unit: string; questions: number; first_try: number; medal: string }>;
  medals_earned?: Array<{ unit: string; medal: string }>;
  weak_spots?: Array<{ label: string; unit: string; times: number }>;
}

// --------------------------------------------------------------------------
// The job
// --------------------------------------------------------------------------

Deno.serve(async (req: Request) => {
  const url = new URL(req.url);
  const dryRun = url.searchParams.get('dry') === '1';

  // Last completed week. Running on Sunday evening reports the week that has
  // just ended, not the one three hours old.
  const now = new Date();
  const monday = new Date(now);
  monday.setUTCDate(now.getUTCDate() - ((now.getUTCDay() + 6) % 7) - 7);
  const weekStart = monday.toISOString().slice(0, 10);

  const { data: due, error } = await db.rpc('reports_due', {
    p_week_start: url.searchParams.get('week') ?? weekStart,
  });

  if (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' },
    });
  }

  const results: unknown[] = [];

  for (const row of due ?? []) {
    // The student's own name, so the email reads like a person rather than
    // an address. Falls back to the part before the at sign.
    const { data: profile } = await db
      .from('profiles')
      .select('full_name, email')
      .eq('id', row.student_id)
      .maybeSingle();

    const name =
      (profile?.full_name ?? '').trim() ||
      (profile?.email ?? 'your child').split('@')[0];

    const payload: Report = { ...row.payload, grade: row.grade };
    const html = render(name, payload, row.unsubscribe);
    const subject = `${name.split(' ')[0]} — maths practice, week of ${payload.week_start}`;

    if (dryRun) {
      results.push({ to: row.email, subject, html });
      continue;
    }

    const send = await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${RESEND_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        from: FROM,
        to: row.email,
        subject,
        html,
        // Lets Gmail and Apple Mail show a one-click unsubscribe, which keeps
        // the messages out of spam and is the right thing regardless.
        headers: {
          'List-Unsubscribe': `<${SITE}/unsubscribe?token=${row.unsubscribe}>`,
          'List-Unsubscribe-Post': 'List-Unsubscribe=One-Click',
        },
      }),
    });

    const ok = send.ok;

    // Only record it as sent if it actually went. A failed send that gets
    // logged would never be retried, and a family would silently receive
    // nothing.
    if (ok) {
      await db.rpc('record_report_sent', {
        p_recipient_id: row.recipient_id,
        p_week_start: payload.week_start,
        p_payload: row.payload,
      });
    }

    results.push({ to: row.email, sent: ok, status: send.status });
  }

  return new Response(
    JSON.stringify(
      { week: weekStart, dryRun, count: results.length, results },
      null,
      2,
    ),
    { headers: { 'Content-Type': 'application/json' } },
  );
});
