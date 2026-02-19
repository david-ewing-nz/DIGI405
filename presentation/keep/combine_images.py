from PIL import Image

# Load the two images
img1 = Image.open('q-space-visual.png')
img2 = Image.open('q-space-bullets.png')

# Calculate dimensions for combined image
width = max(img1.width, img2.width)
height = img1.height + img2.height

# Create a new white canvas
combined = Image.new('RGB', (width, height), 'white')

# Paste images vertically
combined.paste(img1, (0, 0))
combined.paste(img2, (0, img1.height))

# Save the combined image
combined.save('q-space-combined.png')
print("Combined image saved as q-space-combined.png")
