#!/usr/bin/env python3
"""Rasterise every lesson diagram to PNG, light and dark.

WHY NOT SHIP THE SVG
--------------------
Flutter cannot draw SVG without a package, and this app has deliberately
avoided packages — no charting library, one CustomPainter, everything else
hand-built. It already has a proven way to show a picture beside a question:
a PNG in web/figures, referenced by path, drawn with Image.network. Lesson
diagrams use the same road rather than adding a dependency and a second one.

Two files per diagram, because the source colours are theme tokens rather
than hex: the light pair uses the app's paper palette, the dark pair the
dark one. Dart picks by Theme.of(context).brightness.

Rendered in the headless Chromium that ships with this container, at 2x,
cropped to the drawing.
"""
import asyncio, hashlib, json, os, re, glob

OUT_DIR = "/home/claude/lessons/figures"
CHROME = "/opt/pw-browsers/chromium-1194/chrome-linux/chrome"

THEMES = {
    "light": {"accent": "#2F6F62", "accent-2": "#C79A2E", "code-accent": "#8A5A2B",
              "text": "#1E2422", "text-2": "#6E7772", "border": "#E2E0D9",
              "bg": "#FFFFFF"},
    "dark":  {"accent": "#6FB3A2", "accent-2": "#E0B44A", "code-accent": "#C79A6A",
              "text": "#E7EBE8", "text-2": "#95A09B", "border": "#2A3331",
              "bg": "#1A211F"},
}


def collect():
    """Read the manifest tools/import_lessons.py wrote.

    Driving both sides off one manifest is the point: the name in the lesson
    body and the name of the PNG cannot drift apart, and a diagram that is
    added, moved or deleted upstream is reflected here without anyone
    remembering to say so.
    """
    m = json.load(open("/home/claude/lessons/diagrams.json"))
    return [(d["name"], d["svg"], d["course"], d["tag"]) for d in m]


async def main():
    from playwright.async_api import async_playwright
    items = collect()
    os.makedirs(OUT_DIR, exist_ok=True)
    print("%d diagrams x 2 themes" % len(items))
    async with async_playwright() as p:
        br = await p.chromium.launch(executable_path=CHROME, args=["--no-sandbox"])
        for theme, pal in THEMES.items():
            ctx = await br.new_context(viewport={"width": 900, "height": 700},
                                       device_scale_factor=2)
            page = await ctx.new_page()
            for name, svg, course, tag in items:
                body = svg
                for k, v in pal.items():
                    body = body.replace("var(--%s)" % k, v)
                # A viewBox with no width/height collapses to nothing inside
                # an inline-block. Give it a real size, twice the viewBox so
                # the 2x device scale lands on a crisp 4x asset.
                vb = re.search(r'viewBox="([\d.\-]+)[ ,]+([\d.\-]+)[ ,]+'
                               r'([\d.]+)[ ,]+([\d.]+)"', body)
                if vb:
                    w, h = float(vb.group(3)), float(vb.group(4))
                    body = re.sub(r'<svg\b',
                                  '<svg width="%d" height="%d"' % (w * 2, h * 2),
                                  body, count=1)
                html = ("<html><body style='margin:0;background:%s'>"
                        "<div id='d' style='display:inline-block;padding:10px'>%s</div>"
                        "</body></html>" % (pal["bg"], body))
                await page.set_content(html)
                el = await page.query_selector("#d")
                await el.screenshot(path=os.path.join(
                    OUT_DIR, "%s_%s.png" % (name, theme)))
            await ctx.close()
        await br.close()
    n = len(glob.glob(os.path.join(OUT_DIR, "*.png")))
    total = sum(os.path.getsize(f) for f in glob.glob(os.path.join(OUT_DIR, "*.png")))
    print("%d PNGs, %.1f MB" % (n, total / 1e6))

asyncio.run(main())
