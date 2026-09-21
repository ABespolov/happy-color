"""Builds a color-by-number picture from AI line art and its colored version.

    python tools/generate_picture.py LINES.png COLOR.png OUT_DIR [--colors 24]

Regions are the closed areas between the lines of LINES.png. Each region gets
the palette color closest to its dominant color in COLOR.png, which is also
exported as the artwork revealed while coloring.

A picture can be rebuilt from its own folder, which keeps its artwork as is:

    python tools/generate_picture.py DIR/lines.webp DIR/artwork.webp DIR

Writes to OUT_DIR:
- picture.json: palette, and for each region its color, label spot and bounds;
- regions.png: region map, pixel RGB = region index + 1 (R low byte, G high);
- artwork.webp: the colored picture (lossy, quality 95);
- artwork_thumb.webp, lines_thumb.webp: small copies for the picture grids;
- lines.webp: the line art as black lines on a transparent background
  (lossless), with a line added along every border the art did not draw;
- preview.png: region borders with color numbers, for checking.
"""

import argparse
import json
from pathlib import Path

import cv2
import numpy as np

SIZE = 1000  # Picture coordinate space.


def read(path, flags=cv2.IMREAD_COLOR):
    image = cv2.imread(str(path), flags)
    if image is None:
        raise SystemExit(f"cannot read {path}")
    return image


def read_lines(path):
    """Line art as dark ink on white. Also reads the transparent lines.webp
    this tool writes, where the ink is the alpha channel."""
    image = read(path, cv2.IMREAD_UNCHANGED)
    if image.ndim == 3 and image.shape[2] == 4:
        return 255 - image[..., 3]
    return image if image.ndim == 2 else cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)


def shrink(image):
    return cv2.resize(image, (SIZE, SIZE), interpolation=cv2.INTER_AREA)


def grow(labels, inside):
    """Spreads labels over the unlabelled (0) pixels of [inside]."""
    grown = labels.astype(np.float32)
    kernel = np.ones((3, 3), np.uint8)
    while True:
        empty = (grown == 0) & inside
        dilated = cv2.dilate(grown, kernel)
        fill = empty & (dilated > 0)
        if not fill.any():
            return grown.astype(np.int32)
        grown[fill] = dilated[fill]


def find_regions(lines, min_area, close_gaps):
    """Labels closed areas between lines, then grows them over the lines so
    neighbouring regions share borders. AI line art often leaves small gaps in
    strokes; thickening the lines by [close_gaps] px seals them."""
    wall = lines < 140
    # Drop isolated specks of ink that are not part of any stroke.
    count, ink, stats, _ = cv2.connectedComponentsWithStats(wall.astype(np.uint8), connectivity=8)
    wall &= (stats[:, cv2.CC_STAT_AREA] >= 15)[ink]
    if close_gaps:
        size = 2 * close_gaps + 1
        kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (size, size))
        wall = cv2.dilate(wall.astype(np.uint8), kernel) > 0
    count, labels = cv2.connectedComponents((~wall).astype(np.uint8), connectivity=4)
    areas = np.bincount(labels.ravel(), minlength=count)
    labels[wall] = 0
    labels[areas[labels] < min_area] = 0  # Specks become part of the lines.

    _, regions = np.unique(grow(labels, np.ones_like(wall)), return_inverse=True)
    return regions.reshape(SIZE, SIZE)


def merge_small_regions(regions, min_area, min_width):
    """Merges regions that are too small or too thin to tap into the neighbour
    they share the longest border with."""
    while True:
        count = regions.max() + 1
        areas = np.bincount(regions.ravel(), minlength=count)
        # Width: twice the largest distance from any pixel to the region border.
        width = np.zeros(count, np.float32)
        for r in range(count):
            ys, xs = np.nonzero(regions == r)
            y0, x0 = ys.min(), xs.min()
            mask = np.zeros((ys.max() - y0 + 3, xs.max() - x0 + 3), np.uint8)
            mask[ys - y0 + 1, xs - x0 + 1] = 1
            width[r] = 2 * cv2.distanceTransform(mask, cv2.DIST_L2, 3).max()
        bad = (areas < min_area) | (width < min_width)
        if not bad.any():
            return regions

        pairs = {}
        for a, b in ((regions[:, :-1], regions[:, 1:]), (regions[:-1, :], regions[1:, :])):
            m = a != b
            for lo, hi in ((a[m], b[m]), (b[m], a[m])):
                keys, counts = np.unique(lo.astype(np.int64) * count + hi, return_counts=True)
                for k, c in zip(keys, counts):
                    pairs[int(k)] = pairs.get(int(k), 0) + int(c)
        target = np.arange(count)
        best = {}
        for k, c in pairs.items():
            r, n = divmod(k, count)
            if bad[r] and not bad[n] and c > best.get(r, (0, -1))[0]:
                best[r] = (c, n)
        if not best:  # Only bad neighbours left: merge into the largest one.
            for k, c in pairs.items():
                r, n = divmod(k, count)
                if bad[r] and areas[n] > areas[best.get(r, (0, r))[1]]:
                    best[r] = (c, n)
        for r, (_, n) in best.items():
            target[r] = n
        _, regions = np.unique(target[regions], return_inverse=True)
        regions = regions.reshape(SIZE, SIZE)


def two_colors(pixels):
    """The two colors that describe [pixels] best."""
    sample = pixels[:: max(1, len(pixels) // 20000)]
    criteria = (cv2.TERM_CRITERIA_EPS + cv2.TERM_CRITERIA_MAX_ITER, 20, 0.5)
    cv2.setRNGSeed(0)
    _, _, centers = cv2.kmeans(sample, 2, None, criteria, 3, cv2.KMEANS_PP_CENTERS)
    return centers


def cut(lab, mask, clean, min_part, min_contrast):
    """Pieces to cut out of the region [mask], or none if it is one thing.

    Sorts its pixels into two colors, and keeps the pieces of the rarer one
    that are big and end in a sharp edge. A gradient or soft shading has no
    such edge, and a texture falls apart into pieces that are too small."""
    own = mask & clean
    if own.sum() < 2 * min_part:
        return []
    centers = two_colors(lab[own])
    if np.linalg.norm(centers[0] - centers[1]) < min_contrast:
        return []

    # Each pixel sides with most of its neighbourhood, for a smooth cut.
    second = np.linalg.norm(lab - centers[1], axis=2) < np.linalg.norm(lab - centers[0], axis=2)
    known = own.astype(np.float32)
    share = cv2.GaussianBlur(second * known, (0, 0), 2.5) / np.maximum(cv2.GaussianBlur(known, (0, 0), 2.5), 1e-6)
    sides = grow(np.where(own, 1 + (share > 0.5), 0), mask)
    rare = 1 + ((sides == 2).sum() < (sides == 1).sum())

    count, pieces, stats, _ = cv2.connectedComponentsWithStats((sides == rare).astype(np.uint8), connectivity=4)
    big = [k for k in range(1, count) if stats[k, cv2.CC_STAT_AREA] >= min_part]
    if sum(stats[k, cv2.CC_STAT_AREA] for k in big) < 0.6 * (sides == rare).sum():
        return []
    near, far = np.ones((5, 5), np.uint8), np.ones((15, 15), np.uint8)
    out = []
    for k in big:
        piece = (pieces == k).astype(np.uint8)
        rest = (mask & (pieces != k)).astype(np.uint8)
        small = min(piece.sum(), rest.sum())
        seam = ((cv2.dilate(piece, np.ones((3, 3), np.uint8)) > 0) & (rest > 0)).sum()
        # A short seam is a gap in a line that let two shapes run together. A
        # long one is worth drawing only around something big: around a
        # highlight or a petal it would be a scribble.
        if small < min_part or seam > (5 if small >= 6 * min_part else 2.5) * np.sqrt(small):
            continue
        # Compare the colors a few px off the cut on both sides.
        inner = (cv2.erode(piece, near) > 0) & (cv2.dilate(rest, far) > 0) & clean
        outer = (cv2.erode(rest, near) > 0) & (cv2.dilate(piece, far) > 0) & clean
        # Almost no paint along the cut means a line already runs there.
        if min(inner.sum(), outer.sum()) < 20 or np.linalg.norm(
                np.median(lab[inner], axis=0) - np.median(lab[outer], axis=0)) >= 0.7 * min_contrast:
            out.append(piece > 0)
    return out


def split_mixed_regions(regions, lines, color, min_part, min_contrast=30, passes=3):
    """AI line art leaves some shapes open, so one region can cover two things,
    like a tree top and the sky behind it, and no single color fits it. Cuts
    such regions along the color edge inside them."""
    if min_part <= 0:
        return regions
    lab = to_lab(color)
    clean = cv2.erode((lines > 215).astype(np.uint8), np.ones((5, 5), np.uint8)) > 0
    regions = regions.copy()
    count = regions.max() + 1
    todo = range(count)
    for _ in range(passes):
        made = []
        for r in todo:
            ys, xs = np.nonzero(regions == r)
            if len(ys) < 2 * min_part:
                continue
            y0, y1, x0, x1 = ys.min(), ys.max() + 1, xs.min(), xs.max() + 1
            window = regions[y0:y1, x0:x1]
            mask = window == r
            pieces = cut(lab[y0:y1, x0:x1], mask, clean[y0:y1, x0:x1], min_part, min_contrast)
            if not pieces:
                continue
            for piece in pieces:
                mask &= ~piece
            # What is left may have been cut apart too.
            islands, rest = cv2.connectedComponents(mask.astype(np.uint8), connectivity=4)
            pieces += [rest == k for k in range(2, islands)]
            for piece in pieces:
                window[piece] = count
                made.append(count)
                count += 1
            made.append(r)
        if not made:
            break
        todo = made  # Only what changed can be cut again.
    return regions


def smooth_borders(regions, radius):
    """Rounds off jagged borders: every pixel goes to the region that covers
    most of its neighbourhood. Neighbours still share exact borders."""
    if radius <= 0:
        return regions
    count = regions.max() + 1
    best = np.full(regions.shape, -1.0, np.float32)
    out = regions.copy()
    size = 4 * radius + 1
    margin = 2 * radius
    for r in range(count):
        ys, xs = np.nonzero(regions == r)
        y0, y1 = max(ys.min() - margin, 0), min(ys.max() + margin + 1, SIZE)
        x0, x1 = max(xs.min() - margin, 0), min(xs.max() + margin + 1, SIZE)
        mask = (regions[y0:y1, x0:x1] == r).astype(np.float32)
        score = cv2.GaussianBlur(mask, (size, size), radius)
        window = best[y0:y1, x0:x1]
        win = score > window
        window[win] = score[win]
        out[y0:y1, x0:x1][win] = r
    _, out = np.unique(out, return_inverse=True)  # A sliver can be smoothed away.
    return out.reshape(regions.shape)


def to_lab(bgr):
    """True CIELAB, where plain distance is close to how different two colors
    look. OpenCV's 8-bit Lab stretches lightness 2.55x against the color axes,
    which groups regions by how light they are rather than by hue."""
    return cv2.cvtColor(bgr.astype(np.float32) / 255, cv2.COLOR_BGR2LAB)


def main_color(pixels, min_contrast=25):
    """The median color, or the median of the larger part when the pixels fall
    into two distinct colors: a fir under snow is green, not the olive that
    lies between green and white."""
    if len(pixels) >= 50:
        centers = two_colors(pixels)
        if np.linalg.norm(centers[0] - centers[1]) >= min_contrast:
            second = np.linalg.norm(pixels - centers[1], axis=1) < np.linalg.norm(pixels - centers[0], axis=1)
            pixels = pixels[second == (second.mean() > 0.5)]
    return np.median(pixels, axis=0)


def region_colors(regions, lines, color, margin=2):
    """Main Lab color of each region, taken [margin] px away from any ink, so
    the soft edges of the lines and paint that crossed them do not muddy it."""
    lab = to_lab(color).reshape(-1, 3)
    paper = lines > 215
    size = 2 * margin + 1
    inner = cv2.erode(paper.astype(np.uint8), np.ones((size, size), np.uint8)) > 0
    paper, inner = paper.ravel(), inner.ravel()
    ids = regions.ravel()
    count = regions.max() + 1
    medians = np.zeros((count, 3), np.float32)
    areas = np.bincount(ids, minlength=count)
    order = np.argsort(ids, kind="stable")
    starts = np.concatenate([[0], np.cumsum(areas)])
    for r in range(count):
        idx = order[starts[r]:starts[r + 1]]
        own = idx[inner[idx]]
        if len(own) < 30:  # Thin region: settle for anything that is not ink.
            own = idx[paper[idx]]
        medians[r] = main_color(lab[own if len(own) else idx])
    return medians, areas


def distances(colors, centers):
    return np.linalg.norm(colors[:, None] - centers[None], axis=2)


def build_palette(medians, areas, colors, max_error=10, min_gap=9):
    """Picks at most [colors] palette colors and gives each region the closest.

    Starts from the colors that differ most, so a small bright accent gets its
    own number instead of dissolving into a big neighbour, and stops early once
    every region is within [max_error] of a color. Colors closer than [min_gap]
    look the same in the palette and are merged."""
    centers = [medians[np.argmax(areas)]]
    while len(centers) < min(colors, len(medians)):
        error = distances(medians, np.array(centers)).min(axis=1)
        if error.max() < max_error:
            break
        centers.append(medians[np.argmax(error)])
    centers = np.array(centers)

    # Square root: a big background should not outvote everything else.
    weights = np.sqrt(areas)
    for _ in range(20):
        ids = distances(medians, centers).argmin(axis=1)
        for k in range(len(centers)):
            if (ids == k).any():
                centers[k] = np.average(medians[ids == k], axis=0, weights=weights[ids == k])

    while len(centers) > 1:
        gaps = distances(centers, centers)
        np.fill_diagonal(gaps, np.inf)
        a, b = np.unravel_index(np.argmin(gaps), gaps.shape)
        if gaps[a, b] >= min_gap:
            break
        ids = distances(medians, centers).argmin(axis=1)
        both = (ids == a) | (ids == b)
        if both.any():
            centers[a] = np.average(medians[both], axis=0, weights=weights[both])
        centers = np.delete(centers, b, axis=0)

    # Number colors from light to dark, like most color-by-number apps.
    centers = centers[np.argsort(-centers[:, 0])]
    rgb = cv2.cvtColor(centers.reshape(-1, 1, 3), cv2.COLOR_LAB2RGB).reshape(-1, 3)
    rgb = np.round(rgb * 255).clip(0, 255).astype(np.uint8)
    return ["#%02X%02X%02X" % tuple(c) for c in rgb], distances(medians, centers).argmin(axis=1)


def label_spot(mask):
    """Point deepest inside the region and its distance to the border."""
    dist = cv2.distanceTransform(np.pad(mask, 1), cv2.DIST_L2, 5)[1:-1, 1:-1]
    y, x = np.unravel_index(np.argmax(dist), dist.shape)
    return float(x), float(y), float(dist[y, x])


def export_regions(regions, color_ids):
    out = []
    for r in range(regions.max() + 1):
        ys, xs = np.nonzero(regions == r)
        x0, y0, x1, y1 = xs.min(), ys.min(), xs.max() + 1, ys.max() + 1
        mask = np.zeros((y1 - y0, x1 - x0), np.uint8)
        mask[ys - y0, xs - x0] = 1
        lx, ly, lr = label_spot(mask)
        out.append({
            "color": int(color_ids[r]),
            "label": [round(lx + x0 + 0.5, 1), round(ly + y0 + 0.5, 1), round(lr, 1)],
            "bounds": [int(x0), int(y0), int(x1), int(y1)],
        })
    return out


def region_map(regions):
    ids = regions.astype(np.int64) + 1
    image = np.zeros((*regions.shape, 3), np.uint8)
    image[..., 2] = ids & 0xFF         # R (OpenCV stores BGR)
    image[..., 1] = (ids >> 8) & 0xFF  # G
    return image


def ink_new_borders(ink, regions, lines):
    """Draws a thin line along every border that has none, so the regions cut
    by split_mixed_regions are outlined like the rest. [ink] is full size."""
    edge = np.zeros(regions.shape, np.uint8)
    edge[:, :-1] |= regions[:, :-1] != regions[:, 1:]
    edge[:-1, :] |= regions[:-1, :] != regions[1:, :]
    drawn = cv2.dilate((lines < 140).astype(np.uint8), np.ones((7, 7), np.uint8))
    edge &= 1 - drawn
    # Stubs where smoothing pulled a border slightly off its line.
    count, parts, stats, _ = cv2.connectedComponentsWithStats(edge, connectivity=8)
    edge &= (stats[:, cv2.CC_STAT_AREA] >= 12)[parts].astype(np.uint8)
    edge = cv2.dilate(edge, np.ones((2, 2), np.uint8))

    height, width = ink.shape
    line = cv2.resize(edge.astype(np.float32), (width, height), interpolation=cv2.INTER_CUBIC)
    line = cv2.GaussianBlur(line, (0, 0), width / SIZE)
    line = np.clip((line - 0.35) * 5, 0, 1) * 255
    return np.maximum(ink, line.astype(np.uint8))


THUMB = 512  # Enough for a grid cell on a dense screen.


def thumbnail(image):
    """A small copy, so a grid of cards does not decode the full-size picture."""
    return cv2.resize(image, (THUMB, THUMB), interpolation=cv2.INTER_AREA)


def preview(regions, region_list, palette, path):
    image = np.full((SIZE, SIZE, 3), 255, np.uint8)
    edge = np.zeros((SIZE, SIZE), bool)
    edge[:, :-1] |= regions[:, :-1] != regions[:, 1:]
    edge[:-1, :] |= regions[:-1, :] != regions[1:, :]
    image[edge] = (120, 120, 120)
    for region in region_list:
        x, y, r = region["label"]
        if r < 5:
            continue
        text = str(region["color"] + 1)
        scale = min(r / 14, 0.6)
        (w, h), _ = cv2.getTextSize(text, cv2.FONT_HERSHEY_SIMPLEX, scale, 1)
        cv2.putText(image, text, (int(x - w / 2), int(y + h / 2)),
                    cv2.FONT_HERSHEY_SIMPLEX, scale, (60, 60, 60), 1, cv2.LINE_AA)
    cv2.imwrite(str(path), image)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("lines")
    parser.add_argument("color")
    parser.add_argument("out")
    parser.add_argument("--colors", type=int, default=24,
                        help="at most this many colors; simple pictures get fewer")
    parser.add_argument("--min-region", type=int, default=150,
                        help="regions smaller than this many px merge into a neighbour")
    parser.add_argument("--min-width", type=float, default=7,
                        help="regions thinner than this many px merge into a neighbour")
    parser.add_argument("--smooth", type=int, default=2,
                        help="border smoothing radius in px, 0 to disable")
    parser.add_argument("--close-gaps", type=int, default=0,
                        help="thicken lines by this many px to seal gaps in strokes")
    parser.add_argument("--min-area", type=int, default=40,
                        help="areas smaller than this (px on a 1000px canvas) merge into lines")
    parser.add_argument("--min-split", type=int, default=400,
                        help="a region of two colors is cut in two if both parts "
                             "are at least this many px, 0 to disable")
    args = parser.parse_args()

    full_lines, full_color = read_lines(args.lines), read(args.color)
    lines, color = shrink(full_lines), shrink(full_color)
    regions = find_regions(lines, args.min_area, args.close_gaps)
    regions = split_mixed_regions(regions, lines, color, args.min_split)
    regions = smooth_borders(regions, args.smooth)
    regions = merge_small_regions(regions, args.min_region, args.min_width)
    medians, areas = region_colors(regions, lines, color)
    palette, color_ids = build_palette(medians, areas, args.colors)
    region_list = export_regions(regions, color_ids)

    out = Path(args.out)
    out.mkdir(parents=True, exist_ok=True)
    picture = {"width": float(SIZE), "height": float(SIZE),
               "palette": palette, "regions": region_list}
    (out / "picture.json").write_text(json.dumps(picture, separators=(",", ":")))
    # Full source resolution keeps the artwork and lines sharp when zoomed.
    cv2.imwrite(str(out / "regions.png"), region_map(regions))
    # Rebuilding a picture from its own folder: encoding the artwork again
    # would only wear it down.
    if Path(args.color).resolve() != (out / "artwork.webp").resolve():
        cv2.imwrite(str(out / "artwork.webp"), full_color, [cv2.IMWRITE_WEBP_QUALITY, 95])
        cv2.imwrite(str(out / "artwork_thumb.webp"), thumbnail(full_color), [cv2.IMWRITE_WEBP_QUALITY, 90])
    lines_rgba = np.zeros((*full_lines.shape, 4), np.uint8)
    # Black lines on a transparent background.
    lines_rgba[..., 3] = ink_new_borders(255 - full_lines, regions, lines)
    cv2.imwrite(str(out / "lines.webp"), lines_rgba, [cv2.IMWRITE_WEBP_QUALITY, 101])  # >100 = lossless
    cv2.imwrite(str(out / "lines_thumb.webp"), thumbnail(lines_rgba), [cv2.IMWRITE_WEBP_QUALITY, 101])
    preview(regions, region_list, palette, out / "preview.png")
    print(f"{len(region_list)} regions, {len(palette)} colors -> {out}")


if __name__ == "__main__":
    main()
