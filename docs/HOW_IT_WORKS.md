# Astro Math Assist — what it does and why

A guide to every part of the app, in plain terms. No code, no jargon.

---

## The idea behind it

Photomath already solves any maths question you point a camera at. So an app
that gives answers is not worth building.

What no app does well is tell a student **what they did wrong**. That is the
whole point of this one.

Every question has four options. The three wrong ones are not random — each
one is the answer you get if you make a particular mistake. Pick the option
that comes from forgetting to flip a sign, and the app tells you that you
forgot to flip a sign. It does not tell you the right answer. You try again.

That single decision shapes everything else in the app.

---

## For students

### Signing up

Name, email, password, and a grade. Grade 10 is the course that exists —
MPM2D, 240 questions across six units. The other grades can be chosen at
signup but have no questions behind them yet.

The name matters because it is what a teacher sees on their class list, and
because the first name is what appears on a shared report. An email address is
for signing in, not for identifying a person.

Grade is set at signup so a student can practise before anybody enrols them.
Once a tutor puts them in a class, the class decides the grade.

### The six units, and four levels each

Linear systems · Analytic geometry · Factoring · Quadratics · Solving
quadratic equations · Trigonometry.

Each unit has forty questions in four levels of ten:

| Level | What it asks for |
|---|---|
| **Easy** | One concept, one step. Vocabulary and recognition |
| **Medium** | The standard procedure, two or three steps |
| **Challenge** | Multi-step, word problems, choosing the method |
| **Advanced** | Parameters, combined subtopics — the ones that separate 90s from 70s |

**Easy and Medium are free. Challenge and Advanced need Astro+.** Locked
levels are still shown, with their question counts, so a student can see what
a subscription would buy rather than discovering it later.

### Answering a question

Tap an option and you find out straight away. There is no "check answer"
button and no submitting.

- **Right** — it turns green and you move on.
- **Wrong** — it is crossed out and cannot be picked again. You get a sentence
  explaining the mistake behind that option. **The right answer stays
  hidden.** You keep trying until you find it.

So a wrong answer is not a dead end, it is the lesson. Most apps punish wrong
answers; here they are how you learn something.

The feedback scrolls itself into view, because a hint below the fold is a hint
nobody reads.

### The score

You get a point only for questions you get right on the **first** tap.

This sounds harsh but it is the honest measure. Getting there on the fourth
guess means you did not know it, and a score that pretended otherwise would be
useless to everybody — including the student.

### Picking up where you left off

Everything is saved as you go. Close the tab mid-level, come back next week,
and the app puts you straight back on the next unanswered question. A card at
the top says "Pick up where you left off".

You can still choose a different unit whenever you want — before a test you
might want to drill one thing. The point is only that you never *have* to.

### Medals

One medal per level, not per unit. Finish all ten questions in a level and you
earn one:

| Medal | What it takes |
|---|---|
| **Bronze** | Finishing the level, however many tries it took |
| **Silver** | 7 of 10 right on the first try |
| **Gold** | 9 of 10 right on the first try |

Bronze rewards finishing rather than being perfect, deliberately. If the entry
medal needed a high score, students would stop tapping when unsure — and
tapping when unsure is exactly how this app teaches.

**Medals never go down.** Redo a level and do badly, and you keep the medal you
had. That means practising again is free — there is no risk in it.

A locked level cannot be medalled at all, even if somebody found a way to
answer it. The server refuses.

### Worth another look

Levels finished at Bronze appear in an amber box: "You finished these, but a
few took more than one try." Silver and Gold are left alone.

It is the most useful part of the medal system — a medal says how you did,
this says where to go next.

### Starting over

There is a **Reset my progress** option. It clears your position so every unit
starts from question one.

It does **not** delete anything. Your medals stay, and so does everything a
teacher can see. It is a fresh run, not an erasure — which also means nobody
can quietly wipe a bad week before somebody looks at the report.

### Astro+

The subscription unlocks Challenge and Advanced across all six units — 120 of
the 240 questions.

Payment goes through Stripe. The app never sees a card: it asks the server for
a checkout page and gets back a URL. Stripe tells the database what was paid
for, and the database decides what is unlocked. If the app lied about having a
subscription, the server would still refuse the locked questions.

Cancelling does not cut you off on the spot. Access runs to the end of the
period that was paid for. Taking back time a family paid for would be theft
with extra steps.

---

## The report, and sharing it

A student can open their own report at any time: how far through each unit
they are, their first-try rate, a topic map coloured green to red, and the
specific subtopics costing them the most.

The colours are decided by **first-try rate, not completion**. A student who
finished a unit by guessing has not learned it, and a green bar would be a
lie. Under four first looks at a unit, it stays grey — not enough evidence to
say anything.

### The share link

The student can create a link and send it to whoever they like — a parent, a
tutor, a grandparent. Opening it needs no account.

**The link carries a first name and nothing else.** No surname, no email
address, no class name, no teacher's name. This is deliberate: a public URL
can be forwarded anywhere, so anything in it is effectively published, and
this one is about a child.

The student can revoke the link at any time and it stops working that second.
Reissuing gives a new link and kills the old one, which is the thing to do if
it has gone somewhere it should not have.

There is no email. There is no weekly send, no list of guardian addresses, no
consent flow to manage — all of that was removed in favour of one link the
student controls. Fewer moving parts, and no address list to look after.

---

## For teachers

### Getting a teacher account

Teacher accounts can see the work of every student in their class, so they are
not something anybody can switch on. There is no button and no code. Whoever
runs the app grants the role with one line in the database, and that statement
cannot be run from a browser at all.

### Creating a class

Give it a name and a grade. That is the whole form — there is no join code.
Codes were removed along with the flow that redeemed them; a code nobody can
use is a button that lies to a teacher.

### Getting students in

Two ways.

**Invite them by email.** They see a card next time they open the app naming
you and saying exactly what you would be able to see. **Until they accept, you
see nothing of theirs** — not a name on a roster, not a number. An invitation
is a request, not an enrolment. This is what the app's Invite button does.

**Enrol them directly.** A tutor can add a student by email straight into a
class, without asking. This is the private-tutor case: the student already
knows their tutor sees their work, and the enrolment is recording a
relationship that exists outside the app rather than creating one. It also
settles their grade from the class.

The second one is a real trade and worth being clear about. What keeps it
honest is that the student sees every class they are in, on their front
screen, and can leave in one tap. **If this app ever goes to a school, the
invitation becomes the only way in** — there, the teacher and the family have
not already had that conversation.

Either side can end it. A student can leave, you can remove them, and access
stops immediately in both cases.

### The Students tab

One row per student, most recently active first. Each shows their name, when
they last practised, how many questions they have done, their first-try
percentage, and their medals.

Anyone who has not appeared in two weeks is flagged in amber. That is a
different problem from a low score and needs a different response — you chase
one and you teach the other.

**Tap a student** and you get their full picture: a plain-English summary,
their totals, every unit they have touched, and the specific things they keep
getting wrong. It is laid out exactly like the report the student can share,
so you are never looking at a different story from the family.

### The Class progress tab

This is the part that does not exist in other apps.

**Topics.** Every unit the class has touched, weakest first, with the
percentage the class gets right on the first try. Underneath: how many
started it, how many finished, and **how many are struggling**.

That last number matters more than the average. An average of 60% could mean
everybody is middling, or it could mean half the class has it cold and half
are lost. The struggling count tells you which.

Each topic also names the single most common slip across the class.

**Questions most got wrong.** The individual questions failing most widely.
Tap one and it opens up to show:

- the actual question
- the wrong answer most of them chose
- what that mistake is, in plain words
- the feedback those students already saw, so you do not repeat it

This is the difference between "the class average is 62%" and "eleven of your
thirty are dropping the minus sign when they expand brackets, and here is the
question where it shows". The first is a number. The second is a lesson plan.

It only works because every wrong option was written to match a specific
mistake — which was the slow part of building the app, and the reason it pays
off here.

---

## Who can see what

| | Their own work | Other students | Class totals | The answers |
|---|---|---|---|---|
| Student | Yes | No | No | **No** |
| Teacher | — | Only their own class | Yes | Only in the class analysis |
| Anyone with a share link | First name and progress only | No | No | No |

Three things worth knowing:

**Students cannot see the correct answers**, even by inspecting the app. The
answers never leave the server. The app sends your tap away and gets back only
"right" or "wrong" plus the explanation for that one option. There is nothing
in the network tab to find, and nothing to edit.

**A teacher reaches a student only through a live class.** Not "teachers can
see students" — this teacher, this student, this class, checked on every
single query. Remove them and it stops that second.

**The paywall is enforced by the database, not the app.** Four separate places
refuse a locked level: listing the questions, answering one by number,
awarding a medal for it, and the subscription check itself. A modified copy of
the app gets nothing extra.

---

## Where it runs

The app is a website. Nothing to install, works on a phone or a laptop.

The data lives in a database that enforces all of the above itself, rather
than trusting the app to behave. That matters because it means a bug in the
app cannot accidentally show one student another student's work.

---

## What is still missing

- **Only Grade 10 has questions.** Grades 9, 11 and 12 can be chosen at signup
  and have nothing behind them.
- **Stripe is still in test mode.** Real money needs the live keys.
- **The password reset link needs the live URL registered** with Supabase, or
  the email sends people somewhere that is not the app.
- **No Dart tests.** The database has a suite; the app has never been tested
  beyond compiling.
- **Some wrong-answer feedback states the answer.** Eleven cases across the
  bank, listed by the test suite. Each one hands a student the answer they
  were meant to work out, which is the one thing this app exists not to do.

## Before it goes near a real school

Three things, none of them technical:

**Tell students plainly.** They can see their classes and leave at any time.
That should stay true.

**Make invitation the only way in.** Direct enrolment is right for a tutor and
wrong for a school.

**Somebody should read the privacy rules properly.** A dashboard holding
children's academic records is the point where this stops being a family
project. In Ontario that means MFIPPA for schools and PIPEDA for anything
outside one.
