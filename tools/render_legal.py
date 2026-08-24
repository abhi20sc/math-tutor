#!/usr/bin/env python3
"""Render PRIVACY.md and TERMS.md into standalone branded pages for web/.

Kept as a script so the markdown in docs/ stays the single source of truth:
edit the markdown, re-run this, redeploy. Hand-editing the HTML would leave
two versions of a legal document, which is exactly the failure mode a policy
page cannot afford.
"""
import markdown, os, re

# Run from anywhere: markdown lives in docs/, pages are written to web/.
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE) if os.path.basename(HERE) == "tools" else HERE
SRC  = os.path.join(ROOT, "docs") if os.path.isdir(os.path.join(ROOT, "docs")) else HERE
OUT  = os.path.join(ROOT, "web") if os.path.isdir(os.path.join(ROOT, "web")) \
       else os.path.join(HERE, "out")
os.makedirs(OUT, exist_ok=True)

CSS = """
:root{--ground:#F6F5F1;--raise:#fff;--ink:#1E2422;--soft:#6E7772;--line:#E2E0D9;
--teal:#2F6F62;--teal-deep:#20514A;--wash:#EDF5F2;--gold:#C79A2E;}
@media (prefers-color-scheme:dark){:root{--ground:#121716;--raise:#1A211F;
--ink:#E7EBE8;--soft:#95A09B;--line:#2A3331;--teal:#6FB3A2;--teal-deep:#8FCBBB;
--wash:#1C2A27;--gold:#E0B44A;}}
*{box-sizing:border-box}
body{margin:0;background:var(--ground);color:var(--ink);
font:16.5px/1.68 -apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,Helvetica,Arial,sans-serif;
-webkit-font-smoothing:antialiased}
.wrap{max-width:760px;margin:0 auto;padding:0 24px 80px}
.brand{display:flex;align-items:center;gap:12px;padding:34px 0 8px;
text-decoration:none;color:var(--ink)}
.brand svg{width:34px;height:34px;flex:none}
.brand span{font-weight:700;font-size:15.5px;letter-spacing:-.01em}
h1{font-size:clamp(30px,5vw,40px);line-height:1.12;letter-spacing:-.02em;
margin:24px 0 6px;font-weight:700}
h2{font-size:21px;line-height:1.3;margin:44px 0 10px;font-weight:700;
padding-top:22px;border-top:1px solid var(--line)}
h2:first-of-type{border-top:0;padding-top:0}
h3{font-size:16px;margin:26px 0 6px;font-weight:700}
p,li{max-width:68ch}
p{margin:0 0 15px}
ul,ol{padding-left:22px;margin:0 0 15px}
li{margin-bottom:7px}
li::marker{color:var(--soft)}
hr{border:0;border-top:1px solid var(--line);margin:30px 0}
strong{font-weight:700}
a{color:var(--teal-deep)}
code{background:var(--wash);padding:1px 5px;border-radius:4px;font-size:.9em;
color:var(--teal-deep)}
blockquote{margin:0;padding-left:18px;border-left:3px solid var(--teal);
color:var(--soft)}
table{border-collapse:collapse;width:100%;font-size:15px;margin:0 0 18px;
display:block;overflow-x:auto}
th,td{text-align:left;padding:10px 16px 10px 0;border-bottom:1px solid var(--line);
vertical-align:top}
th{font-size:11.5px;letter-spacing:.09em;text-transform:uppercase;
color:var(--soft);border-bottom-color:var(--ink)}
em{color:var(--soft);font-style:italic}
footer{margin-top:54px;padding-top:22px;border-top:1px solid var(--line);
color:var(--soft);font-size:14px}
footer a{margin-right:18px}
"""

MARK = ('<svg viewBox="0 0 100 100" aria-hidden="true">'
        '<path d="M 9 15 Q 50 155 91 15" fill="none" stroke="var(--teal)" '
        'stroke-width="9.8" stroke-linecap="round"/>'
        '<polygon points="50.00,41.80 52.64,50.43 61.43,48.40 55.28,55.00 '
        '61.43,61.60 52.64,59.57 50.00,68.20 47.36,59.57 38.57,61.60 '
        '44.72,55.00 38.57,48.40 47.36,50.43" fill="var(--gold)"/></svg>')

PAGES = [("PRIVACY.md", "privacy.html", "Privacy Policy"),
         ("TERMS.md",   "terms.html",   "Terms of Service")]

for src, dest, title in PAGES:
    body = markdown.markdown(open(os.path.join(SRC, src)).read(),
                             extensions=["tables", "attr_list"])
    # The markdown starts with its own H1; drop it, the page supplies one.
    body = re.sub(r"^<h1>.*?</h1>\s*", "", body, count=1, flags=re.S)
    html = f"""<!DOCTYPE html>
<html lang="en-CA">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>{title} — Astro Math Assist</title>
<meta name="description" content="{title} for Astro Math Assist, Ontario high-school maths practice.">
<meta name="theme-color" content="#2F6F62">
<meta name="color-scheme" content="light dark">
<link rel="icon" type="image/png" href="favicon.png">
<style>{CSS}</style>
</head>
<body>
<div class="wrap">
  <a class="brand" href="/">{MARK}<span>Astro Math Assist</span></a>
  <h1>{title}</h1>
  {body}
  <footer>
    <a href="/">Back to the app</a>
    <a href="privacy.html">Privacy</a>
    <a href="terms.html">Terms</a>
    <a href="mailto:stemlabs.ca@gmail.com">stemlabs.ca@gmail.com</a>
  </footer>
</div>
</body>
</html>
"""
    open(os.path.join(OUT, dest), "w").write(html)
    print(f"{dest:16} {len(html):7d} bytes")
