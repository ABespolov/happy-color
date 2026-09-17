"""Builds a color-by-number picture from AI line art and its colored version.

    python tools/generate_picture.py LINES.png COLOR.png OUT_DIR [--colors 24]

Regions are the closed areas between the lines of LINES.png. Each region gets
the palette color closest to its dominant color in COLOR.png, which is also
exported as the artwork revealed while coloring.

Writes OUT_DIR/picture.json (format read by ColoringPicture.fromJson),
OUT_DIR/artwork.png, OUT_DIR/lines.png (the line art drawn over the picture)
and OUT_DIR/preview.png (outlines with color numbers).
"""

import argparse
import json
from pathlib import Path

import cv2
import mapbox_earcut as earcut
import numpy as np
from shapely.geometry import Polygon
from shapely.ops import unary_union
from shapely.validation import make_valid
from sklearn.cluster import KMeans

SIZE = 1000  # Picture coordinate space.


def load(path, flags=cv2.IMREAD_COLOR):
    image = cv2.imread(str(path), flags)
    if image is None:
        raise SystemExit(f"cannot read {path}")
    return cv2.resize(image, (SIZE, SIZE), interpolation=cv2.INTER_AREA)


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

    grown = labels.astype(np.float32)
    kernel = np.ones((3, 3), np.uint8)
    while (grown == 0).any():
        dilated = cv2.dilate(grown, kernel)
        empty = grown == 0
        grown[empty] = dilated[empty]
    _, regions = np.unique(grown.astype(np.int32), return_inverse=True)
    return regions.reshape(SIZE, SIZE), wall


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
    return out


def region_colors(regions, wall, color):
    """Median Lab color of each region, ignoring line pixels."""
    lab = cv2.cvtColor(color, cv2.COLOR_BGR2LAB).reshape(-1, 3)
    ids = regions.ravel()
    inside = ~wall.ravel()
    count = regions.max() + 1
    medians = np.zeros((count, 3), np.float32)
    areas = np.bincount(ids, minlength=count)
    order = np.argsort(ids, kind="stable")
    starts = np.concatenate([[0], np.cumsum(areas)])
    for r in range(count):
        idx = order[starts[r]:starts[r + 1]]
        own = idx[inside[idx]]
        medians[r] = np.median(lab[own if len(own) else idx], axis=0)
    return medians, areas


def build_palette(medians, areas, colors):
    k = min(colors, len(medians))
    km = KMeans(k, n_init=10, random_state=0).fit(medians, sample_weight=areas)
    # Number colors from light to dark, like most color-by-number apps.
    order = np.argsort(-km.cluster_centers_[:, 0])
    rank = np.empty(k, int)
    rank[order] = np.arange(k)
    centers = km.cluster_centers_[order].astype(np.uint8).reshape(-1, 1, 3)
    rgb = cv2.cvtColor(centers, cv2.COLOR_LAB2RGB).reshape(-1, 3)
    return ["#%02X%02X%02X" % tuple(c) for c in rgb], rank[km.labels_]


def region_polygons(mask):
    """Polygons of a region, largest first. Contours run through the centres of
    the border pixels; growing them by half a pixel moves every edge onto the
    boundary shared with the neighbour, so adjacent regions meet in one line."""
    contours, hierarchy = cv2.findContours(mask, cv2.RETR_CCOMP, cv2.CHAIN_APPROX_NONE)
    if not contours:
        return []
    hierarchy = hierarchy[0]
    parts = []
    for i, h in enumerate(hierarchy):
        if h[3] >= 0 or len(contours[i]) < 3:
            continue
        holes = [
            contours[k].reshape(-1, 2) for k, hk in enumerate(hierarchy)
            if hk[3] == i and len(contours[k]) >= 3
        ]
        parts.append(Polygon(contours[i].reshape(-1, 2), holes))
    shape = make_valid(unary_union(parts)).buffer(0.5, join_style="mitre", mitre_limit=2)
    shape = shape.simplify(0.8, preserve_topology=True)
    polygons = [g for g in getattr(shape, "geoms", [shape]) if isinstance(g, Polygon) and g.area >= 2]
    return sorted(polygons, key=lambda g: -g.area)


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
        # One pixel of margin so contours around the crop edge stay closed.
        mask = np.zeros((y1 - y0 + 2, x1 - x0 + 2), np.uint8)
        mask[ys - y0 + 1, xs - x0 + 1] = 1
        shift = np.array([x0 - 1, y0 - 1], np.float64)
        polygons = region_polygons(mask)
        if not polygons:
            continue
        ring = lambda coords: np.asarray(coords, np.float64)[:-1] + shift + 0.5
        triangles = []
        for polygon in polygons:
            rings = [ring(polygon.exterior.coords)] + [ring(h.coords) for h in polygon.interiors]
            vertices = np.concatenate(rings)
            ends = np.cumsum([len(r) for r in rings]).astype(np.uint32)
            triangles.append(vertices[earcut.triangulate_float64(vertices, ends)])
        main = polygons[0]
        lx, ly, lr = label_spot(mask)
        round1 = lambda a: [round(float(v), 1) for v in np.asarray(a).ravel()]
        entry = {
            "color": int(color_ids[r]),
            "points": round1(ring(main.exterior.coords)),
            "triangles": round1(np.concatenate(triangles)),
            "label": [round(lx + x0 - 1, 1), round(ly + y0 - 1, 1), round(lr, 1)],
        }
        if main.interiors:
            entry["holes"] = [round1(ring(h.coords)) for h in main.interiors]
        if len(polygons) > 1:
            entry["parts"] = [round1(ring(p.exterior.coords)) for p in polygons[1:]]
        out.append(entry)
    return out


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
    parser.add_argument("--colors", type=int, default=24)
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
    args = parser.parse_args()

    lines = load(args.lines, cv2.IMREAD_GRAYSCALE)
    color = load(args.color)
    regions, wall = find_regions(lines, args.min_area, args.close_gaps)
    regions = smooth_borders(regions, args.smooth)
    regions = merge_small_regions(regions, args.min_region, args.min_width)
    medians, areas = region_colors(regions, wall, color)
    palette, color_ids = build_palette(medians, areas, args.colors)
    region_list = export_regions(regions, color_ids)

    out = Path(args.out)
    out.mkdir(parents=True, exist_ok=True)
    picture = {"width": float(SIZE), "height": float(SIZE), "outlineWidth": 1.4,
               "palette": palette, "regions": region_list}
    (out / "picture.json").write_text(json.dumps(picture, separators=(",", ":")))
    # Full source resolution keeps the artwork and lines sharp when zoomed.
    cv2.imwrite(str(out / "artwork.png"), cv2.imread(args.color))
    ink = 255 - cv2.imread(args.lines, cv2.IMREAD_GRAYSCALE)
    lines_rgba = np.zeros((*ink.shape, 4), np.uint8)
    lines_rgba[..., 3] = ink  # Black lines on a transparent background.
    cv2.imwrite(str(out / "lines.png"), lines_rgba)
    preview(regions, region_list, palette, out / "preview.png")
    print(f"{len(region_list)} regions, {len(palette)} colors -> {out}")


if __name__ == "__main__":
    main()
