import os
from dataclasses import dataclass

import cv2
import matplotlib.pyplot as plt
import numpy as np
from matplotlib.colors import PowerNorm

import generalized_hough_transform as ght


@dataclass(frozen=True)
class ShapeSpec:
    name: str
    template_path: str
    threshold_ratio: float
    max_detections: int


def _read_gray(path: str) -> np.ndarray:
    img = cv2.imread(path, cv2.IMREAD_GRAYSCALE)
    if img is None:
        raise FileNotFoundError(f"Could not read image: {path}")
    return img


def _read_bgr(path: str) -> np.ndarray:
    img = cv2.imread(path, cv2.IMREAD_COLOR)
    if img is None:
        raise FileNotFoundError(f"Could not read image: {path}")
    return img


def _to_rgb(bgr: np.ndarray) -> np.ndarray:
    return cv2.cvtColor(bgr, cv2.COLOR_BGR2RGB)


def _normalize_to_uint8(img: np.ndarray) -> np.ndarray:
    img = img.astype(np.float32)
    mn, mx = float(np.min(img)), float(np.max(img))
    if mx <= mn:
        return np.zeros_like(img, dtype=np.uint8)
    out = (img - mn) / (mx - mn)
    out = (out * 255.0).clip(0, 255)
    return out.astype(np.uint8)


def _accumulator_imshow_args(acc: np.ndarray):
    """Return (acc_display, cmap, norm) for a clear accumulator visualization.

    Goals:
    - Background stays black (0 votes are masked).
    - Peak votes stand out strongly vs smaller votes.
    - Avoid overly colorful colormaps.
    """
    acc_f = acc.astype(np.float32)
    acc_masked = np.ma.masked_where(acc_f <= 0, acc_f)

    positive = acc_f[acc_f > 0]
    vmax = float(np.percentile(positive, 99.7)) if positive.size else 1.0
    if vmax <= 0:
        vmax = 1.0

    # Gamma curve: gamma < 1 brightens low values while keeping peaks distinct.
    norm = PowerNorm(gamma=0.5, vmin=0.0, vmax=vmax)

    cmap = plt.get_cmap("hot").copy()  # black->red->yellow->white
    cmap.set_under("black")
    cmap.set_bad("black")

    return acc_masked, cmap, norm


def _make_template_montage(template_paths: list[str], tile_size: int = 260, pad: int = 12) -> np.ndarray:
    """Creates a 2x2 montage (grayscale) of the given template images."""
    tiles: list[np.ndarray] = []
    for path in template_paths:
        t = _read_gray(path)
        t = _normalize_to_uint8(t)
        t = cv2.resize(t, (tile_size, tile_size), interpolation=cv2.INTER_AREA)
        tiles.append(t)

    if len(tiles) != 4:
        raise ValueError("Expected exactly 4 template paths for a 2x2 montage")

    def pad_tile(x: np.ndarray) -> np.ndarray:
        return cv2.copyMakeBorder(x, pad, pad, pad, pad, cv2.BORDER_CONSTANT, value=0)

    tiles = [pad_tile(t) for t in tiles]

    top = np.hstack([tiles[0], tiles[1]])
    bottom = np.hstack([tiles[2], tiles[3]])
    return np.vstack([top, bottom])


def _top_k_peaks(acc: np.ndarray, threshold_ratio: float, k: int, min_distance: int = 25) -> list[tuple[int, int]]:
    """Pick up to k peak locations (y,x) from accumulator with simple distance suppression."""
    if acc.size == 0:
        return []

    max_val = float(np.max(acc))
    if max_val <= 0:
        return []

    thresh = max_val * float(threshold_ratio)
    candidates = np.argwhere(acc >= thresh)
    if candidates.size == 0:
        return []

    # Sort candidates by vote descending
    votes = acc[candidates[:, 0], candidates[:, 1]]
    order = np.argsort(-votes)
    candidates = candidates[order]

    chosen: list[tuple[int, int]] = []
    for y, x in candidates:
        y_i, x_i = int(y), int(x)
        if all((y_i - cy) ** 2 + (x_i - cx) ** 2 >= min_distance**2 for cy, cx in chosen):
            chosen.append((y_i, x_i))
            if len(chosen) >= k:
                break
    return chosen


def _run_for_shape(source_image_path: str, spec: ShapeSpec) -> tuple[np.ndarray, np.ndarray]:
    """Returns (accumulator, detected_bgr_image)."""
    r_table, _ = ght.build_r_table(spec.template_path)
    accumulator = ght.generalized_hough_transform(source_image_path, r_table)

    peaks = _top_k_peaks(
        accumulator,
        threshold_ratio=spec.threshold_ratio,
        k=spec.max_detections,
        min_distance=25,
    )
    detected_bgr = ght.draw_detections(source_image_path, peaks, spec.template_path)
    return accumulator, detected_bgr


def create_report_grids(
    source_image_path: str = "test_image.png",
    out_dir: str = "ght_reports",
) -> None:
    os.makedirs(out_dir, exist_ok=True)

    # Ensure templates exist (overwrites existing files; safe for your workflow).
    ght.generate_all_templates()

    template_paths = [
        "template_triangle.png",
        "template_book.png",
        "template_square.png",
        "template_star.png",
    ]

    template_montage = _make_template_montage(template_paths)

    # Read the source/test image once
    test_gray = _read_gray(source_image_path)

    shapes = [
        ShapeSpec("triangle", "template_triangle.png", threshold_ratio=0.70, max_detections=10),
        ShapeSpec("book", "template_book.png", threshold_ratio=0.70, max_detections=6),
        ShapeSpec("square", "template_square.png", threshold_ratio=0.70, max_detections=10),
        ShapeSpec("star", "template_star.png", threshold_ratio=0.70, max_detections=10),
    ]

    for spec in shapes:
        accumulator, detected_bgr = _run_for_shape(source_image_path, spec)

        fig, axes = plt.subplots(2, 2, figsize=(12, 9))
        fig.suptitle(f"GHT Report: {spec.name}", fontsize=14)

        # (1) Top-left: test image
        axes[0, 0].imshow(test_gray, cmap="gray")
        axes[0, 0].set_title("Test image")
        axes[0, 0].axis("off")

        # (2) Top-right: 2x2 template montage
        axes[0, 1].imshow(template_montage, cmap="gray")
        axes[0, 1].set_title("Templates (triangle / book / square / star)")
        axes[0, 1].axis("off")

        # (3) Bottom-left: accumulator (colored gradient)
        acc_vis, acc_cmap, acc_norm = _accumulator_imshow_args(accumulator)
        axes[1, 0].set_facecolor("black")
        axes[1, 0].imshow(acc_vis, cmap=acc_cmap, norm=acc_norm, interpolation="nearest")
        axes[1, 0].set_title("Accumulator space")
        axes[1, 0].axis("off")

        # (4) Bottom-right: detections
        axes[1, 1].imshow(_to_rgb(detected_bgr))
        axes[1, 1].set_title("Detected objects")
        axes[1, 1].axis("off")

        plt.tight_layout()

        out_path = os.path.join(out_dir, f"ght_grid_{spec.name}.png")
        fig.savefig(out_path, dpi=200)
        plt.close(fig)

        print(f"Saved: {out_path}")


if __name__ == "__main__":
    create_report_grids()
