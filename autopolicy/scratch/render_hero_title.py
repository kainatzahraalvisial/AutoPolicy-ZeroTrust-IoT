import math
from PIL import Image, ImageDraw, ImageFont

# Let's create an image to preview the exact letter geometry
W, H = 900, 320
img = Image.new('RGBA', (W, H), (10, 12, 16, 255))
draw = ImageDraw.Draw(img)

# Let's draw HUD elements
# 1. Top Index Tag
draw.text((20, 15), "[SYS.01 // ZERO-TRUST ENCLAVE]", fill=(0, 229, 255, 200))

# 2. Diagonal hash marks underneath test
for i in range(10):
    x = 24 + i * 14
    draw.polygon([(x, 260), (x + 8, 260), (x + 2, 280), (x - 6, 280)], fill=(220, 255, 51, 230))

# 3. Mechanical crossbar datum line
draw.line([(180, 270), (W - 30, 270)], fill=(0, 229, 255, 120), width=2)
draw.rectangle([(W - 140, 262), (W - 40, 278)], outline=(0, 229, 255, 200), width=1)
draw.text((W - 130, 264), "SEC: ACTIVE", fill=(0, 229, 255, 230))

img.save('scratch/preview_hud.png')
print("Preview HUD generated")
