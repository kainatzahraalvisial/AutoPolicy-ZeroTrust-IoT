import math
from PIL import Image, ImageDraw

def create_preview():
    W, H = 840, 260
    img = Image.new('RGBA', (W, H), (14, 16, 20, 255))
    draw = ImageDraw.Draw(img)

    # Let's test drawing the letters EVERY DEVICE on top, ZERO TRUST on bottom
    # with exact 45 chamfers and 45 stencil cuts
    print("Generating vector glyphs...")

create_preview()
