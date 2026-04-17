import cv2
import numpy as np

def make_2x2_grid(image_paths, output_path, cell_size=None):
    """
    image_paths: list/tuple of 4 image file paths.
    output_path: where to save the grid image.
    cell_size: (width, height) for each cell; if None, use min size from inputs.
    """
    if len(image_paths) != 4:
        raise ValueError("Exactly 4 image paths are required.")

    images = []
    for p in image_paths:
        img = cv2.imread(p)
        if img is None:
            raise FileNotFoundError(f"Could not read image: {p}")
        images.append(img)

    # Decide cell size
    if cell_size is None:
        h = min(img.shape[0] for img in images)
        w = min(img.shape[1] for img in images)
    else:
        w, h = cell_size

    resized = [cv2.resize(img, (w, h)) for img in images]

    # Add spacing between images
    gap = 10  # pixels
    vertical_strip = np.full((h, gap, 3), 255, dtype=np.uint8)

    top_row = np.hstack((resized[0], vertical_strip, resized[1]))
    bottom_row = np.hstack((resized[2], vertical_strip, resized[3]))

    horizontal_strip = np.full((gap, top_row.shape[1], 3), 255, dtype=np.uint8)
    grid = np.vstack((top_row, horizontal_strip, bottom_row))

    cv2.imwrite(output_path, grid)
    print(f"Saved grid image to: {output_path}")


if __name__ == "__main__":
    # TODO: put your image paths here
    img1_path = r"test_image.png"
    img2_path = r"template_book.png"
    img3_path = r"accumulator_template_book.png"
    img4_path = r"detected_template_book_in_test_image.png"

    out_path = r"OUTPUT_GRID.png"

    make_2x2_grid(
        [img1_path, img2_path, img3_path, img4_path],
        out_path,
        cell_size=(500,400)  # or e.g. (600, 400)
    )