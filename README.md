# Happy Color

Color-by-number prototype in Flutter.

## How it works

- **The finished artwork is revealed, not painted.** `assets/artwork.png` is the colored picture. Filling a region reveals that part of it.
- **The picture is split into regions.** `assets/picture.json` lists every region: its outline, its color number, where its label goes, and its shape pre-cut into triangles.
- **Filled regions are drawn as triangles** (`drawVertices`), painted with the artwork image as a shader. Each region shows the exact piece of the artwork underneath it.
- **A 16×16 grid groups nearby regions.** A tap only checks the regions near it, zoom only draws what is on screen, and a fill only rebuilds one group.
- **The canvas is a stack of independent layers**: the highlight for the selected color, the revealed artwork, the outlines, and the numbers. Each layer redraws only when its own data changes.
- **Numbers come from one prebuilt texture** and are all drawn in a single call. Numbers too small to read at the current zoom are hidden.
