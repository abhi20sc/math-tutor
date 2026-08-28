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

WHY THIS IS SAFE

Cloudflare Pages negotiates content encoding properly. A file stored with
`Content-Encoding: br` from _headers is served as brotli to a client that
asks for brotli, RE-ENCODED to gzip for a client that asks for gzip, and
decompressed to the raw bytes for a client that asks for neither. Every
response is labelled correctly. No client is handed something it cannot
decode.

Measured on the live site, 29 August 2026, on main.dart.wasm:

    Accept-Encoding: br            -> br,   930,235 bytes (these bytes)
    Accept-Encoding: gzip          -> gzip, 1,197,255 bytes
    Accept-Encoding: identity      -> none, 3,336,431 bytes (raw wasm)
    Accept-Encoding: gzip, deflate -> gzip, 1,197,255 bytes
    Accept-Encoding: *             -> none, 3,336,431 bytes

THIS FILE PREVIOUSLY CLAIMED THE OPPOSITE, AND IT WAS WRONG.

It said Cloudflare had no negotiation, that the header was unconditional,
and that pre-compressing anything an old browser might fetch would hand it
garbage. On that reasoning the list below was restricted to files only a
WasmGC-capable browser ever requests. The reasoning was false and the
restriction cost real bytes on exactly the browsers that could least afford
them — the old ones taking the main.dart.js fallback path.

The argument is now simply: pre-compressing at -q 11 beats what Cloudflare
does per-request at the edge, and costs nothing at runtime because the work
happened at build time. That applies to any large text-like asset.

WHAT STILL SHOULD NOT GO IN THE LIST

Already-compressed formats. PNG, JPEG and WOFF2 have their entropy squeezed
out already; brotli over them buys a percent or two for real build time.
The `after >= before` guard below would catch it, but not adding them is
better than relying on the guard.

IF THIS EVER LOOKS WRONG

A blank page with a console error about a corrupt wasm module means the
header and the bytes disagree — either the file was compressed twice, or
_headers lost its entry. Rebuild without running this script and the site
works, slower. That is the fallback.

To check a deployed file, ASK FOR AN ENCODING. `curl -I` sends no
Accept-Encoding header, so it shows the identity response and no
`content-encoding` line at all, which looks exactly like a failure and is
not one:

    curl -sI .../main.dart.wasm                      # misleading
    curl -sI .../main.dart.wasm -H 'Accept-Encoding: br'   # the real answer

IF THIS EVER LOOKS WRONG

A blank page on a modern browser with a console error about a corrupt wasm
module means the header and the bytes disagree — either the file was
compressed twice, or _headers lost its entry. Rebuild without running this
script and the site works, slower. That is the fallback.
"""

import os
import subprocess
import sys

# Large text-like assets. See "WHAT STILL SHOULD NOT GO IN THE LIST" above
# before adding anything: already-compressed formats do not belong here.
TARGETS = [
    # The WasmGC path, which is what a current browser takes.
    "main.dart.wasm",
    "main.dart.mjs",
    "canvaskit/skwasm.wasm",
    "canvaskit/skwasm.js",
    # The FALLBACK path, for browsers without WasmGC. These were excluded on
    # a mistaken reading of how Cloudflare serves _headers, which meant the
    # oldest browsers — the slowest devices, most likely a student on a hand
    # -me-down phone — were the only ones getting no benefit from this at
    # all. They are the biggest files in the build.
    "main.dart.js",
    "canvaskit/canvaskit.wasm",
    "canvaskit/skwasm_heavy.wasm",
    "canvaskit/wimp.wasm",
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
        #
        # Only .wasm files can be checked this way — there is no magic
        # number for JavaScript. For those, re-running over a build is
        # caught by the _headers block being appended twice instead, which
        # is why a rebuild rather than a re-run is the way to redo this.
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
