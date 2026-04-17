import numpy as np
import cv2
import matplotlib.pyplot as plt
from collections import defaultdict
import math


def _quantize_angle(angle_degrees):
    """Quantize angle to integer degrees in [-180, 180]."""
    a = int(round(angle_degrees))
    if a > 180:
        a -= 360
    elif a < -180:
        a += 360
    return a


def build_r_table(template_path):

    template = cv2.imread(template_path, 0)
    if template is None:
        raise FileNotFoundError(f"Template image not found at {template_path}")
    edges = cv2.Canny(template, 50, 150)
    contours, _ = cv2.findContours(edges, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    if not contours:
        raise ValueError("No contours found in the template image.")

    contour = max(contours, key=cv2.contourArea)
    M = cv2.moments(contour)
    if M["m00"] == 0:
        raise ValueError("Centroid of the template could not be calculated.")

    ref_x = int(M["m10"] / M["m00"])
    ref_y = int(M["m01"] / M["m00"])

    # R-table now stores (r_i, alpha_i) per gradient angle for rotation/scale invariance
    r_table = defaultdict(list)

    sobelx = cv2.Sobel(edges, cv2.CV_64F, 1, 0, ksize=3)
    sobely = cv2.Sobel(edges, cv2.CV_64F, 0, 1, ksize=3)

    edge_points = np.argwhere(edges > 0)

    for y, x in edge_points:
        grad_angle = math.degrees(math.atan2(sobely[y, x], sobelx[y, x]))
        grad_angle_q = _quantize_angle(grad_angle)

        dx = ref_x - x
        dy = ref_y - y
        r_i = math.hypot(dx, dy)
        alpha_i = math.atan2(dy, dx)  # radians

        r_table[grad_angle_q].append((r_i, alpha_i))

    return r_table, (ref_x, ref_y)

def display_r_table(r_table, num_rows=10):
    """
    Displays the first few rows of the R-Table.
    """
    print("--- R-Table (first 10 entries) ---")
    print("Angle (degrees) | Vectors (dx, dy)")
    print("------------------------------------")
    count = 0
    for angle, vectors in sorted(r_table.items()):
        if count >= num_rows:
            break
        print(f"{angle:<15} | {vectors}")
        count += 1
    print("------------------------------------\n")


def generalized_hough_transform(image_path, r_table):
    """Standard (non-rotation/scale invariant) GHT kept for reference.

    NOTE: This expects the R-table to contain (dx, dy) entries. Since the
    current build_r_table stores (r_i, alpha_i) for rotation-invariant GHT,
    this function is no longer used in the main workflow.
    """
    image = cv2.imread(image_path, 0)
    if image is None:
        raise FileNotFoundError(f"Source image not found at {image_path}")

    edges = cv2.Canny(image, 50, 150)
    height, width = image.shape

    accumulator = np.zeros((height, width), dtype=np.float32)

    sobelx = cv2.Sobel(edges, cv2.CV_64F, 1, 0, ksize=3)
    sobely = cv2.Sobel(edges, cv2.CV_64F, 0, 1, ksize=3)

    edge_points = np.argwhere(edges > 0)

    for y, x in edge_points:
        angle = math.degrees(math.atan2(sobely[y, x], sobelx[y, x]))
        angle_q = _quantize_angle(angle)

        if angle_q in r_table:
            for dx, dy in r_table[angle_q]:
                cx, cy = x + dx, y + dy
                if 0 <= cx < width and 0 <= cy < height:
                    accumulator[cy, cx] += 1

    return accumulator


def generalized_hough_transform_rot_scale(image_path, r_table, scales, rotations_deg):
    """Rotation- and scale-invariant Generalized Hough Transform.

    Uses the polar form from the statement:

        x_c = x_i + s * r_i * cos(alpha_i - theta)
        y_c = y_i + s * r_i * sin(alpha_i - theta)

    where (x_i, y_i) are edge points in the image, and (r_i, alpha_i) come
    from the R-table for the corresponding model edge orientation.
    """

    image = cv2.imread(image_path, 0)
    if image is None:
        raise FileNotFoundError(f"Source image not found at {image_path}")

    edges = cv2.Canny(image, 50, 150)
    height, width = image.shape

    accumulator = np.zeros((height, width), dtype=np.float32)

    sobelx = cv2.Sobel(edges, cv2.CV_64F, 1, 0, ksize=3)
    sobely = cv2.Sobel(edges, cv2.CV_64F, 0, 1, ksize=3)

    edge_points = np.argwhere(edges > 0)

    # Precompute radians for all rotation hypotheses
    rotations_rad = [math.radians(th) for th in rotations_deg]

    for y, x in edge_points:
        # Gradient orientation at this image edge point
        grad_angle_img = math.degrees(math.atan2(sobely[y, x], sobelx[y, x]))

        for th_deg, th_rad in zip(rotations_deg, rotations_rad):
            # Corresponding model gradient angle (accounting for rotation)
            model_angle = _quantize_angle(grad_angle_img - th_deg)

            # Collect entries for this angle and its opposite (180 deg flip)
            entries = []
            for a in (model_angle, _quantize_angle(model_angle + 180)):
                if a in r_table:
                    entries.extend(r_table[a])

            if not entries:
                continue

            for s in scales:
                for r_i, alpha_i in entries:
                    # Apply the transformation from model space to image space
                    cx = x + s * r_i * math.cos(alpha_i - th_rad)
                    cy = y + s * r_i * math.sin(alpha_i - th_rad)

                    cx_i = int(round(cx))
                    cy_i = int(round(cy))

                    if 0 <= cx_i < width and 0 <= cy_i < height:
                        accumulator[cy_i, cx_i] += 1

    return accumulator

def find_peaks(accumulator, threshold_ratio=0.7):
    """
    Finds peaks in the accumulator space.
    """
    max_val = np.max(accumulator)
    if max_val == 0:
        return []
    threshold = max_val * threshold_ratio
    peaks = np.argwhere(accumulator >= threshold)
    return [(y, x) for y, x in peaks]

def draw_detections(image_path, peaks, template_path):
    """
    Draws the detected objects on the source image.
    """
    image = cv2.imread(image_path)
    template = cv2.imread(template_path, 0)
    
    contours, _ = cv2.findContours(cv2.Canny(template, 50, 150), cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    template_contour = max(contours, key=cv2.contourArea)
    
    M = cv2.moments(template_contour)
    ref_x = int(M["m10"] / M["m00"])
    ref_y = int(M["m01"] / M["m00"])

    for peak_y, peak_x in peaks:
        # Calculate the offset to draw the contour
        offset_x = peak_x - ref_x
        offset_y = peak_y - ref_y
        
        # Create a copy of the contour and translate it
        translated_contour = template_contour.copy()
        translated_contour[:, :, 0] += offset_x
        translated_contour[:, :, 1] += offset_y
        
        cv2.drawContours(image, [translated_contour], -1, (0, 255, 0), 2)

    return image

def create_template_image():
    """
    Creates a simple triangle template image.
    """
    template = np.zeros((200, 200), dtype=np.uint8)
    triangle = np.array([[100, 50], [50, 150], [150, 150]], np.int32)
    cv2.polylines(template, [triangle], isClosed=True, color=255, thickness=2)
    cv2.imwrite("template_triangle.png", template)
    print("Template image 'template_triangle.png' created successfully.")

def create_star_template():
    """
    Creates a template image for the star shape.
    """
    template = np.zeros((350, 400), dtype=np.uint8)
    pts = np.array([
        [250, 50], [280, 150], [380, 150], [310, 220],
        [340, 320], [250, 270], [160, 320], [190, 220],
        [120, 150], [220, 150]
    ], np.int32)
    cv2.polylines(template, [pts], isClosed=True, color=255, thickness=2)
    cv2.imwrite("template_star.png", template)
    print("Template image 'template_star.png' created successfully.")



def create_square_template():
    """Creates a template for a square."""
    template = np.zeros((120, 120), dtype=np.uint8)
    cv2.rectangle(template, (10, 10), (110, 110), 255, 2)
    cv2.imwrite("template_square.png", template)
    print("Template 'template_square.png' created.")

def create_leaf_template():
    """Creates a template for a leaf shape."""
    template = np.zeros((150, 250), dtype=np.uint8)
    # Use the same drawing logic as in create_real_objects_image.py
    center = (125, 75)
    size = (80, 40)
    angle = 0 # Canonical orientation
    cv2.ellipse(template, center, size, angle, 0, 360, 255, 2)
    rad_angle = math.radians(angle)
    stem_start_x = int(center[0] - (size[1] / 1.5) * math.cos(rad_angle))
    stem_start_y = int(center[1] - (size[1] / 1.5) * math.sin(rad_angle))
    stem_end_x = int(stem_start_x - 30 * math.cos(rad_angle))
    stem_end_y = int(stem_start_y - 30 * math.sin(rad_angle))
    cv2.line(template, (stem_start_x, stem_start_y), (stem_end_x, stem_end_y), 255, 2)
    cv2.imwrite("template_leaf.png", template)
    print("Template 'template_leaf.png' created.")

def create_book_template():
    """Creates a template for an open book."""
    template = np.zeros((200, 300), dtype=np.uint8)
    top_left = (20, 20)
    page_width = 120
    page_height = 150
    slant = 20
    # Use the same drawing logic as in create_real_objects_image.py
    left_page = np.array([
        top_left, (top_left[0] + page_width, top_left[1] + slant),
        (top_left[0] + page_width, top_left[1] + page_height + slant), (top_left[0], top_left[1] + page_height)
    ], np.int32)
    right_page_top_left = (top_left[0] + page_width, top_left[1] + slant)
    right_page = np.array([
        right_page_top_left, (right_page_top_left[0] + page_width, right_page_top_left[1] - slant),
        (right_page_top_left[0] + page_width, right_page_top_left[1] + page_height - slant),
        (right_page_top_left[0], right_page_top_left[1] + page_height)
    ], np.int32)
    cv2.polylines(template, [left_page, right_page], isClosed=True, color=255, thickness=2)
    cv2.imwrite("template_book.png", template)
    print("Template 'template_book.png' created.")

def create_l_shape_template():
    """Creates a template for the L-shape."""
    template = np.zeros((120, 120), dtype=np.uint8)
    center = (60, 60)
    size = 50
    pts = np.array([
        [-1, -1], [1, -1], [1, 0], [0, 0], [0, 1], [-1, 1]
    ], np.float32) * size
    translated_pts = (pts + np.array(center)).astype(np.int32)
    cv2.polylines(template, [translated_pts], isClosed=True, color=255, thickness=3)
    cv2.imwrite("template_l_shape.png", template)
    print("Template 'template_l_shape.png' created.")


def generate_all_templates():
    """A utility function to generate all template images at once."""
    print("--- Generating All Template Images ---")
    create_template_image()      # Triangle
    create_star_template()
    create_square_template()
    create_leaf_template()
    create_book_template()
    create_l_shape_template()
    print("--- All templates generated. ---\n")


if __name__ == '__main__':
    # --- Generic GHT Detection Workflow ---

    # 1. SET YOUR TEMPLATE AND SOURCE IMAGE PATHS HERE
    #    You can use any of the generated templates:
    #    - "template_triangle.png"
    #    - "template_star.png"
    #    - "template_plus.png"
    #    - "template_square.png"
    #    - "template_leaf.png"
    #    - "template_book.png"
    #    - "template_l_shape.png"
    TEMPLATE_IMAGE_PATH = "template_square.png"
    
    #    And any of the source images:
    #    - "test_image.png"
    #    - "irregular_shape_image.png"
    #    - "plus_shape_image.png"
    #    - "real_objects_image.png"
    #    - "combined_image.png"
    SOURCE_IMAGE_PATH = "test_image_2.png"

    # --- Optional: Uncomment the line below to generate all template files ---
    # generate_all_templates()


    print(f"--- Running GHT to detect '{TEMPLATE_IMAGE_PATH}' in '{SOURCE_IMAGE_PATH}' ---")

    # 2. Build R-Table from the chosen template
    try:
        r_table, ref_point = build_r_table(TEMPLATE_IMAGE_PATH)
    except (FileNotFoundError, ValueError) as e:
        print(f"Error: {e}")
        print("Please ensure the template image exists and contains a detectable shape.")
        exit()

    # 3. Display the R-Table
    display_r_table(r_table)

    # 4. Perform rotation- and scale-invariant GHT on the source image
    #    Scan scales from 0.5x to 2.5x (step 0.1) and angles every 5 degrees
    #    over a full 0–360° range.
    scales = [round(0.5 + 0.1 * i, 2) for i in range(int((2.5 - 0.5) / 0.1) + 1)]
    rotations_deg = list(range(0, 360, 5))

    try:
        accumulator = generalized_hough_transform_rot_scale(
            SOURCE_IMAGE_PATH,
            r_table,
            scales=scales,
            rotations_deg=rotations_deg,
        )
    except FileNotFoundError as e:
        print(f"Error: {e}")
        print("Please ensure the source image exists.")
        exit()

    # 5. Visualize the accumulator space
    plt.figure(figsize=(10, 8))
    plt.imshow(accumulator, cmap='hot', interpolation='nearest')
    plt.title(f'Accumulator Space for {TEMPLATE_IMAGE_PATH}')
    plt.colorbar(label='Votes')
    output_filename_accumulator = f"accumulator_{TEMPLATE_IMAGE_PATH.split('.')[0]}.png"
    plt.savefig(output_filename_accumulator)
    print(f"Accumulator space image '{output_filename_accumulator}' saved.")
    plt.show()

    # 6. Find peaks in the accumulator
    peaks = find_peaks(accumulator, threshold_ratio=0.7)
    print(f"\nFound {len(peaks)} potential object(s).")

    # 7. Draw detections on the original image
    detected_image = draw_detections(SOURCE_IMAGE_PATH, peaks, TEMPLATE_IMAGE_PATH)

    # 8. Display the final result
    plt.figure(figsize=(10, 8))
    plt.imshow(cv2.cvtColor(detected_image, cv2.COLOR_BGR2RGB))
    plt.title(f'Detected Objects: {TEMPLATE_IMAGE_PATH}')
    plt.axis('off')
    output_filename_detection = f"detected_{TEMPLATE_IMAGE_PATH.split('.')[0]}_in_{SOURCE_IMAGE_PATH.split('.')[0]}.png"
    plt.savefig(output_filename_detection)
    print(f"Detected objects image '{output_filename_detection}' saved.")
    plt.show()

