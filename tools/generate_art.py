"""Generates line art and its colored version for a color-by-number picture
with the OpenAI Images API, ready for tools/generate_picture.py.

    OPENAI_API_KEY=... python tools/generate_art.py "a cute red fox sitting in \
an autumn forest clearing, fly agaric mushrooms, fallen maple leaves, trees, \
a lake, hills and clouds in the background" OUT_DIR

Writes OUT_DIR/lines.png, then colors exactly those lines into
OUT_DIR/color.png. Lines come first so the colors follow them.
"""

import argparse
import base64
import json
import os
import subprocess
import time
from pathlib import Path

MODEL = "gpt-image-2.5-flare"
API = "https://api.openai.com/v1/images"

LINES_PROMPT = (
    "Coloring book page for a color-by-number app like Happy Color: {subject}. "
    "Clean black line art on pure white background, uniform line thickness, every area is a fully closed shape. "
    "Separate closed shapes also for light and shadow areas on the main objects. "
    "Medium detail, shapes large enough to tap on a phone. No gray, no fill, no shading, no hatching, no text."
)

COLOR_PROMPT = (
    "Color this exact line art as the finished artwork of a Happy Color picture: a rich, polished digital painting "
    "with soft shading, subtle gradients, light and shadow, and a harmonious palette. "
    "Each closed area should keep one clearly dominant color family so it can be matched to a color number, "
    "while still having painterly depth inside it. "
    "Keep every black line exactly where it is: do not move, add, remove or redraw any line or shape; "
    "the colors must stay inside the lines and the output must stay pixel-aligned with the input."
)


def request(args, out_json):
    key = os.environ.get("OPENAI_API_KEY")
    if not key:
        raise SystemExit("set OPENAI_API_KEY")
    subprocess.run(["curl", "-s", "-H", f"Authorization: Bearer {key}", *args, "-o", str(out_json)], check=True)
    response = json.loads(out_json.read_text())
    out_json.unlink()
    if "data" not in response:
        raise SystemExit(f"OpenAI error: {response}")
    return base64.b64decode(response["data"][0]["b64_json"])


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("subject", help="what the picture shows")
    parser.add_argument("out")
    parser.add_argument("--size", default="1024x1024")
    args = parser.parse_args()

    out = Path(args.out)
    out.mkdir(parents=True, exist_ok=True)
    lines, color, response = out / "lines.png", out / "color.png", out / "response.json"

    start = time.time()
    body = {"model": MODEL, "prompt": LINES_PROMPT.format(subject=args.subject),
            "size": args.size, "quality": "high"}
    lines.write_bytes(request([f"{API}/generations", "-H", "Content-Type: application/json",
                               "-d", json.dumps(body)], response))
    print(f"{lines} in {time.time() - start:.0f}s", flush=True)

    start = time.time()
    color.write_bytes(request([f"{API}/edits", "-F", f"model={MODEL}", "-F", f"size={args.size}",
                               "-F", "quality=high", "-F", f"image[]=@{lines}",
                               "-F", f"prompt={COLOR_PROMPT}"], response))
    print(f"{color} in {time.time() - start:.0f}s", flush=True)
    print(f"next: python tools/generate_picture.py {lines} {color} assets/pictures/<name>")


if __name__ == "__main__":
    main()
