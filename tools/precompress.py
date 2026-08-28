#!/usr/bin/env python3
"""Pre-compress the two big wasm files with brotli 11.

    flutter build web --release --no-web-resources-cdn --wasm
    python3 tools/precompress.py

WHY

Cloudflare compresses on the fly, and it compresses for SPEED rather than
size — it has to, it is doing it per request at the edge. Measured on the
live site, its brotli came out 1,047 KB on a file that brotli -q 11 takes
to 816 KB. That is 231 KB of pure waste on one file, and the two wasm
files are bigger still:

    main.dart.wasm      1,163 KB gzip   ->   906 KB brotli 11
    canvaskit/skwasm    1,495 KB gzip   -> 1,177 KB brotli 11

Compressing them once, here, at the highest setting, and telling Cloudflare
to serve the bytes as they are saves about 575 KB on every cold load. There
is no runtime cost: the work happens at build time and the edge just hands
the file over.

WHY THIS IS SAFE, WHICH IS THE WHOLE ARGUMENT

Cloudflare Pages has no content negotiation in _headers. A header set there
is unconditional, so a file served with `Content-Encoding: br` goes out
that way to EVERY client, including one that cannot decode brotli. Doing
this to a file that any browser might request would hand some of them
garbage.

These two files are different, and the reason is worth stating exactly:

    main.dart.wasm and skwasm.wasm are ONLY EVER REQUESTED BY A BROWSER
    THAT SUPPORTS WasmGC.

flutter_bootstrap.js checks for WasmGC first and falls back to
main.dart.js plus canvaskit for anything that lacks it. WasmGC landed in
Chrome 119, Firefox 120 and Safari 18.2. Brotli landed in Chrome 50,
Firefox 44 and Safari 11, eight years earlier in every case. So the set of
browsers that can ask for these files is a strict subset of the set that
can decode brotli, and there is no client that gets one without the other.

That argument does NOT extend to main.dart.js, canvaskit.wasm, the figures
or anything else, because those ARE fetched by old browsers. They are left
alone for Cloudflare to compress as it likes. Do not add files to the list
below without making the same argument about them.

IF THIS EVER LOOKS WRONG

A blank page on a modern browser with a console error about a corrupt wasm
module means the header and the bytes disagree — either the file was
compressed twice, or _headers lost its entry. Rebuild without running this
script and the site works, slower. That is the fallback.
"""

import os
import subprocess
import sys

# Only files whose requesters are guaranteed to support brotli. See above.
TARGETS = [
    "main.dart.wasm",
    "canvaskit/skwasm.wasm",
    # Loaded alongside skwasm by the same WasmGC-capable browsers.
    "canvaskit/skwasm.js",
    "main.dart.mjs",
]


def main() -> int:
    root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    web = os.path.join(root, "build", "web")

    if not os.path.isdir(web):
        print("No build/web. Run flutter build web first.", file=sys.stderr)
        return 1

    try:
        subprocess.run(["brotli", "--version"], capture_output=True, check=True)
    except (OSError, subprocess.CalledProcessError):
        print("brotli is not installed. `brew install brotli`", file=sys.stderr)
        return 1

    total_before = total_after = 0
    done = []

    for rel in TARGETS:
        path = os.path.join(web, rel)
        if not os.path.exists(path):
            print(f"  skipped {rel} (not in this build)")
            continue

        before = os.path.getsize(path)

        # Already brotli? Then this script has run over this build before,
        # and compressing again would produce a file the browser decodes
        # once and hands to the wasm parser as brotli. Wasm starts with the
        # bytes 00 61 73 6d; brotli does not.
        with open(path, "rb") as fh:
            head = fh.read(4)
        if rel.endswith(".wasm") and head != b"\x00asm":
            print(f"  skipped {rel} (already compressed)")
            continue

        # Compress to a temp file, then replace. Writing in place would
        # leave a half-compressed file behind if brotli failed part way,
        # and a half-compressed wasm module is a white screen.
        tmp = path + ".br.tmp"
        subprocess.run(["brotli", "-q", "11", "-f", "-o", tmp, path], check=True)
        after = os.path.getsize(tmp)

        # Only keep it if it actually helped. It always will on these files,
        # but a rule that can silently make a file bigger is not a rule.
        if after >= before:
            os.remove(tmp)
            print(f"  skipped {rel} (brotli made it bigger)")
            continue

        os.replace(tmp, path)
        total_before += before
        total_after += after
        done.append(rel)
        print(f"  {rel}: {before / 1024:.0f} KB -> {after / 1024:.0f} KB")

    if not done:
        print("Nothing compressed.")
        return 0

    print()
    print(f"  {total_before / 1024:.0f} KB -> {total_after / 1024:.0f} KB, "
          f"saving {(total_before - total_after) / 1024:.0f} KB")
    # The header block is written HERE, by the step that did the
    # compressing, and appended to the built _headers rather than kept in
    # the source one. If it lived in web/_headers it would ship on every
    # build including the ones where this script was not run, and a raw
    # wasm file served with Content-Encoding: br is a white screen with a
    # console error nobody will connect to a missing build step.
    #
    # This way the claim and the bytes are produced together and cannot
    # drift apart.
    headers = os.path.join(web, "_headers")
    block = ["", "# Written by tools/precompress.py. These files are brotli 11.",
             "# See that script for why this is safe on these paths only."]
    for rel in done:
        block.append(f"/{rel}")
        block.append("  Content-Encoding: br")
        block.append("  Cache-Control: public, max-age=31536000, immutable")
    with open(headers, "a") as fh:
        fh.write("\n".join(block) + "\n")

    print()
    print(f"  declared Content-Encoding: br for {len(done)} files "
          f"in build/web/_headers")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
