"""Gera versões em perspectiva (vista lateral 3/4, como o hambúrguer) de assets vistos de cima:
achata na vertical (círculo -> elipse) e dá espessura empilhando cópias mais escuras por baixo.
Depois aplica o estilo do Verine's (stylize_assets.py)."""
import sys, importlib.util
import numpy as np
from PIL import Image, ImageDraw, ImageEnhance, ImageFilter

spec = importlib.util.spec_from_file_location("stylize", sys.argv[1])
st = importlib.util.module_from_spec(spec); spec.loader.exec_module(st)
OUT = sys.argv[2]          # pasta do projeto (assets/)
U = "/mnt/user-data/uploads/"
SQUASH = 0.42              # altura da elipse / largura (ângulo de visão)

def cut(path):
    im = st.remove_white(Image.open(path))
    return im.crop(im.getbbox())

def perspective(im, thickness_ratio, side_dark=0.68, width=600):
    im = im.resize((width, round(im.height * width / im.width)), Image.LANCZOS)
    face = im.resize((width, max(1, round(im.height * SQUASH))), Image.LANCZOS)
    t = max(0, round(width * thickness_ratio))
    canvas = Image.new("RGBA", (width, face.height + t), (0, 0, 0, 0))
    side = ImageEnhance.Brightness(face).enhance(side_dark)
    for i in range(t, 0, -1):            # lateral: cópias escuras descendo
        canvas.alpha_composite(side, (0, i))
    canvas.alpha_composite(face, (0, 0))  # face de cima
    return canvas

def raw_dough(size=800):
    """Massa crua de pizza (vista de cima): disco claro com borda e pontinhos de farinha."""
    im = Image.new("RGBA", (size, size), (255, 255, 255, 255))
    d = ImageDraw.Draw(im)
    d.ellipse([10, 10, size - 10, size - 10], fill=(233, 190, 128))          # borda
    d.ellipse([58, 58, size - 58, size - 58], fill=(246, 214, 160))          # centro
    rng = np.random.default_rng(3)
    for _ in range(70):
        x, y = rng.integers(90, size - 90, 2)
        if (x - size / 2) ** 2 + (y - size / 2) ** 2 < (size / 2 - 90) ** 2:
            r = int(rng.integers(4, 11))
            d.ellipse([x - r, y - r, x + r, y + r], fill=(252, 236, 205))
    return im.filter(ImageFilter.GaussianBlur(1.2))

def save_styled(rgba, dst, max_w=480):
    tmp = "/tmp/_persp.png"
    rgba.save(tmp)
    print(dst, st.stylize(tmp, dst, flood=False, max_w=max_w))

ING = OUT + "/ingredientes/"
PR = OUT + "/pratos/"
dough = raw_dough()
dough.save("/tmp/_dough.png")
save_styled(perspective(cut("/tmp/_dough.png"), 0.06), ING + "massa_pizza.png")
save_styled(perspective(cut(U + "afb0bc1a-image.png"), 0.018, 0.6), ING + "molho_tomate.png")
save_styled(perspective(cut(U + "f81fde22-image.png"), 0.008, 0.75), ING + "queijo_ralado.png")
save_styled(perspective(cut(U + "9d3c0b99-image.png"), 0.06), PR + "pizza.png")
save_styled(perspective(cut(U + "6ac3d8e0-image.png"), 0.03, 0.85), PR + "prato_lateral.png")
