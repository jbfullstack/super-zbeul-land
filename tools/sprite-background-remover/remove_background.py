import cv2
import numpy as np
from PIL import Image
import os

def add_alpha_channel(image):
    """
    Adds an alpha channel to an image if it doesn't already have one.
    """
    bgr = cv2.cvtColor(image, cv2.COLOR_BGR2BGRA)  # Convert to BGRA
    h, w, _ = image.shape
    alpha = np.full((h, w), 255, dtype=np.uint8)  # Fully opaque alpha channel
    bgr[:, :, 3] = alpha  # Add alpha channel
    return bgr

def remove_background_with_color(image_path, output_path, background_color=(255, 0, 255)):
    # Unpack the background color
    b, g, r = background_color
    image = cv2.imread(image_path, cv2.IMREAD_UNCHANGED)

    if image is None:
        print(f"Skipping {image_path}: Unable to read image.")
        return

    # Check if the image has an alpha channel
    if image.shape[2] < 4:
        print(f"Adding alpha channel to: {image_path}")
        image = add_alpha_channel(image)

    # Convert to RGBA
    image = cv2.cvtColor(image, cv2.COLOR_BGRA2RGBA)
    h, w, _ = image.shape

    # Create a mask for the background color
    lower_bound = np.array([b - 10, g - 10, r - 10, 0])  # Adjust tolerance
    upper_bound = np.array([b + 10, g + 10, r + 10, 255])

    background_mask = cv2.inRange(image, lower_bound, upper_bound)

    # Set the alpha channel of the masked background to 0 (fully transparent)
    image[background_mask > 0, 3] = 0

    # Save the image
    Image.fromarray(image).save(output_path)

def process_folder(input_folder, output_folder, background_color=(0, 0, 0)):
    if not os.path.exists(output_folder):
        os.makedirs(output_folder)

    for filename in os.listdir(input_folder):
        if filename.lower().endswith('.png'):
            input_path = os.path.join(input_folder, filename)
            output_path = os.path.join(output_folder, filename)
            try:
                remove_background_with_color(input_path, output_path, background_color)
                print(f"Processed: {filename}")
            except Exception as e:
                print(f"Failed to process {filename}: {e}")

if __name__ == "__main__":
    input_folder = "./from"  # Replace with your folder containing PNGs
    output_folder = "./to"  # Replace with your output folder
    background_color = (255, 0, 255)  # Pink background to be removed

    process_folder(input_folder, output_folder, background_color)
    print("All images processed!")
