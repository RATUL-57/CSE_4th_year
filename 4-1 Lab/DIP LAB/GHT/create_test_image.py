import numpy as np
import cv2


def create_test_image(width=1200, height=900):
    """Creates a single test image with MULTIPLE same-sized objects.

    Sizes are chosen to match the templates defined in `generalized_hough_transform.py`:
    - Triangle: points [[100,50],[50,150],[150,150]] (template is 200x200)
    - Star: points from `create_star_template()` (template is 350x400)
    - Square: 100x100 square (template is 120x120 with (10,10)-(110,110))
    - Book: same params as `create_book_template()` (template is 200x300)

    Output: `test_image.png`
    """

    image = np.zeros((height, width), dtype=np.uint8)

    # -------------------- TRIANGLES (same size) --------------------
    triangle_pts = np.array([[100, 50], [50, 150], [150, 150]], np.float32)
    triangle_center = triangle_pts.mean(axis=0)
    triangle_offsets = [(30, 30), (260, 40), (30, 260), (260, 270), (520, 60)]

    for idx, (ox, oy) in enumerate(triangle_offsets):
        pts = triangle_pts - triangle_center

        scale = 1.0
        if idx == 0:
            scale = 1.5  # first triangle 1.5x larger
        elif idx == 1:
            scale = 0.8  # second triangle 0.8x (scaled down)

        angle_deg = 0.0
        if idx == 4:
            angle_deg = 30.0  # last triangle rotated 30 degrees

        angle_rad = np.deg2rad(angle_deg)
        rotation_matrix = np.array(
            [
                [np.cos(angle_rad), -np.sin(angle_rad)],
                [np.sin(angle_rad), np.cos(angle_rad)],
            ],
            dtype=np.float32,
        )

        transformed = pts @ rotation_matrix.T * scale
        transformed += triangle_center + np.array([ox, oy], dtype=np.float32)

        cv2.polylines(image, [transformed.astype(np.int32)], isClosed=True, color=255, thickness=2)

    # -------------------- STARS (with scaling/rotation) --------------------
    star_pts = np.array(
        [
            [250, 50],
            [280, 150],
            [380, 150],
            [310, 220],
            [340, 320],
            [250, 270],
            [160, 320],
            [190, 220],
            [120, 150],
            [220, 150],
        ],
        np.float32,
    )
    star_center = star_pts.mean(axis=0)
    star_offsets = [(700, 20), (700, 380), (420, 520)]

    for idx, (ox, oy) in enumerate(star_offsets):
        pts = star_pts - star_center

        scale = 1.0
        angle_deg = 0.0
        if idx == 2:
            scale = 0.5  # third star scaled down to 0.5x
            angle_deg = 15.0  # and rotated by 15 degrees

        angle_rad = np.deg2rad(angle_deg)
        rotation_matrix = np.array(
            [
                [np.cos(angle_rad), -np.sin(angle_rad)],
                [np.sin(angle_rad), np.cos(angle_rad)],
            ],
            dtype=np.float32,
        )

        transformed = pts @ rotation_matrix.T * scale
        transformed += star_center + np.array([ox, oy], dtype=np.float32)

        cv2.polylines(image, [transformed.astype(np.int32)], isClosed=True, color=255, thickness=2)

    # -------------------- SQUARES (with scaling/rotation) --------------------
    square_top_lefts = [(520, 260), (520, 400), (520, 540), (200, 520)]
    square_pts = np.array(
        [
            [0, 0],
            [100, 0],
            [100, 100],
            [0, 100],
        ],
        np.float32,
    )
    square_center = square_pts.mean(axis=0)

    for idx, (x, y) in enumerate(square_top_lefts):
        pts = square_pts - square_center

        scale = 1.0
        angle_deg = 0.0
        if idx == 2:
            angle_deg = 35.0  # third square rotated 35 degrees
        elif idx == 3:
            scale = 1.7  # fourth square scaled to 1.7x
            angle_deg = 5.0  # and rotated by 5 degrees

        angle_rad = np.deg2rad(angle_deg)
        rotation_matrix = np.array(
            [
                [np.cos(angle_rad), -np.sin(angle_rad)],
                [np.sin(angle_rad), np.cos(angle_rad)],
            ],
            dtype=np.float32,
        )

        transformed = pts @ rotation_matrix.T * scale
        transformed += square_center + np.array([x, y], dtype=np.float32)

        cv2.polylines(image, [transformed.astype(np.int32)], isClosed=True, color=255, thickness=2)

    # -------------------- BOOKS (same size) --------------------
    page_width = 120
    page_height = 150
    slant = 20

    def draw_book(top_left):
        left_page = np.array(
            [
                top_left,
                (top_left[0] + page_width, top_left[1] + slant),
                (top_left[0] + page_width, top_left[1] + page_height + slant),
                (top_left[0], top_left[1] + page_height),
            ],
            np.int32,
        )
        right_page_top_left = (top_left[0] + page_width, top_left[1] + slant)
        right_page = np.array(
            [
                right_page_top_left,
                (right_page_top_left[0] + page_width, right_page_top_left[1] - slant),
                (right_page_top_left[0] + page_width, right_page_top_left[1] + page_height - slant),
                (right_page_top_left[0], right_page_top_left[1] + page_height),
            ],
            np.int32,
        )
        cv2.polylines(image, [left_page, right_page], isClosed=True, color=255, thickness=2)

    draw_book((50, 720))
    draw_book((350, 720))

    # Minimal distractor
    cv2.circle(image, (1050, 120), 60, color=255, thickness=2)

    cv2.imwrite("test_image_2.png", image)
    print("Test image 'test_image2.png' created successfully.")


if __name__ == "__main__":
    create_test_image()
