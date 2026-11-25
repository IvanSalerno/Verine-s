"""Desenha os sprites que faltam (ingredientes e pratos prontos) no estilo do Verine's:
formas simples com sombreado suave, linhas internas marrons e rótulos creme com letra serifada.
Depois cada um passa por stylize_assets.stylize (contorno, tom quente, grão)."""
import math, sys, importlib.util
import numpy as np
from PIL import Image, ImageDraw, ImageFont, ImageFilter

spec = importlib.util.spec_from_file_location("stylize", sys.argv[1])
st = importlib.util.module_from_spec(spec); spec.loader.exec_module(st)
OUT = sys.argv[2]
S = 1000
LINE = (78, 46, 30)
FONT = "/usr/share/fonts/truetype/google-fonts/Lora-Variable.ttf"

def font(size):
    f = ImageFont.truetype(FONT, size)
    try:
        f.set_variation_by_name("Bold")
    except Exception:
        pass
    return f

def canvas():
    return Image.new("RGBA", (S, S), (0, 0, 0, 0))

def poly_mask(pts):
    m = Image.new("L", (S, S), 0); ImageDraw.Draw(m).polygon(pts, fill=255); return m

def ellipse_mask(box):
    m = Image.new("L", (S, S), 0); ImageDraw.Draw(m).ellipse(box, fill=255); return m

def rrect_mask(box, r):
    m = Image.new("L", (S, S), 0); ImageDraw.Draw(m).rounded_rectangle(box, r, fill=255); return m

def shade_map(kind, box, strength=0.3):
    """Fator de luz: 'cyl' (cilindro vertical, luz à esquerda), 'v' (de cima p/ baixo), 'flat'."""
    x0, y0, x1, y1 = box
    xs = (np.arange(S) - (x0 + x1) / 2) / max(1, (x1 - x0) / 2)
    ys = (np.arange(S) - (y0 + y1) / 2) / max(1, (y1 - y0) / 2)
    X, Y = np.meshgrid(xs, ys)
    if kind == "cyl":
        f = 1.08 - strength * np.clip(X + 0.35, -1, 1.5) ** 2 * 0.6 - 0.08 * X
    elif kind == "v":
        f = 1.06 - strength * 0.5 * (Y + 1)
    elif kind == "dome":
        f = 1.12 - strength * ((X + 0.35) ** 2 + (Y + 0.45) ** 2) * 0.5
    else:
        f = np.ones_like(X)
    return np.clip(f, 0.55, 1.25)

def fill(img, mask, color, kind="flat", box=None, strength=0.3):
    box = box or mask.getbbox() or (0, 0, S, S)
    f = shade_map(kind, box, strength)
    rgb = np.clip(np.array(color, float)[None, None, :] * f[..., None], 0, 255)
    layer = Image.fromarray(np.dstack([rgb, np.array(mask, float)]).astype(np.uint8), "RGBA")
    img.alpha_composite(layer)

def line(img, pts, w=8, color=LINE):
    ImageDraw.Draw(img).line(pts, fill=color + (255,), width=w, joint="curve")

def outline_shape(img, mask, w=8, color=LINE):
    edge = mask.filter(ImageFilter.MaxFilter(w | 1))
    ring = np.clip(np.array(edge, int) - np.array(mask, int), 0, 255).astype(np.uint8)
    layer = Image.new("RGBA", (S, S), color + (0,)); layer.putalpha(Image.fromarray(ring))
    img.alpha_composite(layer)

def text(img, xy, s, size, color=LINE, anchor="mm", angle=0):
    if angle == 0:
        ImageDraw.Draw(img).text(xy, s, font=font(size), fill=color + (255,), anchor=anchor); return
    t = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    ImageDraw.Draw(t).text((S // 2, S // 2), s, font=font(size), fill=color + (255,), anchor="mm")
    t = t.rotate(angle, resample=Image.BICUBIC, center=(S // 2, S // 2))
    img.alpha_composite(t, (int(xy[0] - S // 2), int(xy[1] - S // 2)))

def label(img, box, title, sub=None, band=None, size=64):
    m = rrect_mask(box, 22)
    fill(img, m, (246, 234, 206), "v", strength=0.15)
    outline_shape(img, m, 9)
    cx = (box[0] + box[2]) / 2
    cy = (box[1] + box[3]) / 2
    text(img, (cx, cy - (18 if sub else 0)), title, size)
    if sub:
        text(img, (cx, cy + 42), sub, int(size * 0.5), (120, 80, 50))
    if band:
        bm = rrect_mask((box[0] + 14, box[3] - 62, box[2] - 14, box[3] - 14), 14)
        fill(img, bm, band[0], "flat")
        text(img, (cx, box[3] - 38), band[1], int(size * 0.5), (250, 244, 228))

def egg_pts(cx, cy, rx, ry, ang):
    pts = []
    a = math.radians(ang)
    for i in range(80):
        t = 2 * math.pi * i / 80
        y = -math.cos(t) * ry
        x = math.sin(t) * rx * (1 - 0.16 * max(0.0, -y / ry))
        pts.append((cx + x * math.cos(a) - y * math.sin(a), cy + x * math.sin(a) + y * math.cos(a)))
    return pts

def save(img, name, folder="ingredientes"):
    tmp = f"/tmp/_draw_{name}.png"
    img.save(tmp)
    print(name, st.stylize(tmp, f"{OUT}/{folder}/{name}.png", flood=False))

# ------------------------------------------------------------------ INGREDIENTES
def flour_sack(band=None):
    img = canvas()
    body = [(300, 300), (700, 300), (745, 820), (712, 875), (290, 875), (255, 820)]
    fill(img, poly_mask(body), (214, 168, 108), "cyl", (255, 300, 745, 875), 0.32)
    outline_shape(img, poly_mask(body), 10)
    crimp = [(305, 305), (695, 305), (690, 238)] + [(690 - i * 32.5, 220 if i % 2 else 245) for i in range(13)] + [(310, 238)]
    fill(img, poly_mask(crimp), (196, 148, 92), "cyl", (300, 210, 700, 310), 0.25)
    outline_shape(img, poly_mask(crimp), 9)
    for p in ([(330, 380), (360, 450)], [(690, 420), (660, 520)], [(300, 760), (340, 820)], [(700, 760), (672, 830)]):
        line(img, p, 6, (150, 105, 62))
    label(img, (355, 470, 645, 690), "Farinha", None if band else "de trigo", band=band, size=66)
    # espiga de trigo no rótulo
    line(img, [(500, 520), (500, 470)], 5)
    # montinho de farinha na frente
    mound = []
    for i in range(41):   # montinho: topo arredondado, base achatada
        t = i / 40
        mound.append((560 + 340 * t, 925 - 120 * math.sin(math.pi * t) ** 1.4))
    for i in range(21):
        t = 1 - i / 20
        mound.append((560 + 340 * t, 925 + 14 * math.sin(math.pi * t)))
    pile = poly_mask(mound)
    fill(img, pile, (250, 247, 240), "dome", pile.getbbox(), 0.4)
    outline_shape(img, pile, 8)
    line(img, [(650, 870), (700, 845), (760, 850)], 5, (215, 205, 190))
    return img

def sugar_jar():
    img = canvas()
    body = rrect_mask((320, 320, 680, 880), 70)
    fill(img, body, (214, 228, 226), "cyl", (320, 320, 680, 880), 0.25)
    # açúcar dentro do vidro (granulado)
    sugar = rrect_mask((338, 470, 662, 862), 56)
    fill(img, sugar, (250, 248, 242), "cyl", (338, 470, 662, 862), 0.18)
    rng = np.random.default_rng(5)
    d = ImageDraw.Draw(img)
    for _ in range(900):
        x, y = rng.integers(350, 650), rng.integers(480, 850)
        if sugar.getpixel((int(x), int(y))):
            c = int(rng.integers(205, 235))
            d.ellipse((x - 3, y - 3, x + 3, y + 3), fill=(c, c - 4, c - 12, 255))
    line(img, [(345, 470), (655, 470)], 6, (190, 185, 170))
    outline_shape(img, body, 10)
    # brilho do vidro
    line(img, [(365, 380), (365, 820)], 16, (255, 255, 255))
    line(img, [(395, 400), (395, 540)], 8, (255, 255, 255))
    # tampa de madeira
    lid = rrect_mask((345, 230, 655, 330), 26)
    fill(img, lid, (160, 108, 66), "cyl", (345, 230, 655, 330), 0.35)
    outline_shape(img, lid, 9)
    line(img, [(360, 280), (640, 280)], 6, (120, 78, 45))
    label(img, (375, 590, 625, 760), "Açúcar", size=62)
    return img

def milk_carton(color, title, sub=None):
    img = canvas()
    front = [(320, 340), (600, 340), (600, 880), (320, 880)]
    side = [(600, 340), (720, 295), (720, 835), (600, 880)]
    roof_f = [(320, 340), (460, 215), (600, 340)]
    roof_s = [(460, 215), (580, 172), (720, 295), (600, 340)]
    fin = [(452, 222), (458, 178), (578, 132), (585, 176)]
    fill(img, poly_mask(front), (246, 243, 235), "flat")
    fill(img, poly_mask(side), (214, 210, 200), "v", strength=0.2)
    fill(img, poly_mask(roof_f), (236, 232, 222), "flat")
    fill(img, poly_mask(roof_s), (205, 200, 190), "flat")
    fill(img, poly_mask(fin), (228, 224, 214), "flat")
    # faixa colorida
    band_f = [(320, 560), (600, 560), (600, 880), (320, 880)]
    band_s = [(600, 560), (720, 515), (720, 835), (600, 880)]
    fill(img, poly_mask(band_f), color, "v", strength=0.18)
    fill(img, poly_mask(band_s), tuple(int(c * 0.78) for c in color), "v", strength=0.18)
    for p in (front, side, roof_f, roof_s, fin):
        outline_shape(img, poly_mask(p), 9)
    # gota de leite
    drop = [(460, 395)] + [(460 + 48 * math.sin(t), 470 - 48 * math.cos(t)) for t in np.linspace(math.radians(40), math.radians(320), 30)]
    fill(img, poly_mask(drop), (250, 250, 252), "flat")
    outline_shape(img, poly_mask(drop), 7)
    text(img, (460, 650), title, 72, (252, 246, 232))
    if sub:
        text(img, (460, 735), sub, 40, (252, 246, 232))
    line(img, [(600, 340), (600, 880)], 6)
    return img

def eggs():
    img = canvas()
    shell = (236, 202, 152)
    for cx, cy, rx, ry, ang in [(520, 470, 150, 205, -8), (360, 700, 140, 190, -72), (660, 720, 140, 190, 70)]:
        m = poly_mask(egg_pts(cx, cy, rx, ry, ang))
        fill(img, m, shell, "dome", m.getbbox(), 0.45)
        outline_shape(img, m, 10)
        ImageDraw.Draw(img).ellipse((cx - 70, cy - 95, cx - 30, cy - 40), fill=(255, 248, 235, 200))
        rng = np.random.default_rng(cx)
        for _ in range(12):
            x, y = cx + rng.integers(-60, 60), cy + rng.integers(-60, 80)
            if m.getpixel((int(x), int(y))):
                ImageDraw.Draw(img).ellipse((x - 4, y - 4, x + 4, y + 4), fill=(200, 160, 110, 255))
    return img

def spaghetti(band_color, title):
    img = canvas()
    rng = np.random.default_rng(11)
    strands = []
    for i in range(70):   # feixe denso, um pouco aberto em cima
        bx = 410 + i * 2.6 + rng.normal(0, 3)
        tx = 340 + i * 4.6 + rng.normal(0, 5)
        strands.append(((bx, 900 + rng.normal(0, 6)), (tx, 140 + rng.normal(0, 12))))
    for a, b in strands:
        line(img, [a, b], 19, (150, 100, 40))
    for a, b in strands:
        c = int(rng.integers(228, 250))
        line(img, [a, b], 13, (c, int(c * 0.8), int(c * 0.42)))
    for a, b in strands[::5]:   # brilho
        line(img, [(a[0] * 0.7 + b[0] * 0.3, a[1] * 0.7 + b[1] * 0.3), (a[0] * 0.35 + b[0] * 0.65, a[1] * 0.35 + b[1] * 0.65)], 4, (255, 240, 200))
    # cinta de papel
    band = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    bm = rrect_mask((300, 450, 700, 600), 18)
    fill(band, bm, band_color, "v", strength=0.15)
    outline_shape(band, bm, 9)
    tc = LINE if sum(band_color) > 600 else (250, 244, 228)
    text(band, (500, 525), title, 62, tc)
    band = band.rotate(4, resample=Image.BICUBIC, center=(500, 525))
    img.alpha_composite(band)
    return img

def cheese_zero():
    im = st.remove_white(Image.open("/mnt/user-data/uploads/666f3960-image.png"))
    im = im.crop(im.getbbox())
    im = im.resize((800, round(im.height * 800 / im.width)), Image.LANCZOS)
    img = canvas()
    img.alpha_composite(im, (100, 500 - im.height // 2))
    # etiqueta verde "sem lactose"
    tag = rrect_mask((560, 300, 900, 420), 24)
    fill(img, tag, (104, 156, 88), "v", strength=0.15)
    outline_shape(img, tag, 9)
    text(img, (730, 360), "sem lactose", 48, (250, 244, 228))
    line(img, [(600, 420), (560, 480)], 7)
    return img

GREEN = (104, 156, 88)
save(flour_sack(), "farinha")
save(flour_sack(band=(GREEN, "sem glúten")), "farinha_sg")
save(sugar_jar(), "acucar")
save(milk_carton((86, 136, 196), "Leite"), "leite")
save(milk_carton(GREEN, "Leite", "zero lactose"), "leite_zero")
save(eggs(), "ovo")
save(spaghetti((246, 234, 206), "Macarrão"), "macarrao")
save(spaghetti(GREEN, "sem glúten"), "macarrao_sg")
save(cheese_zero(), "queijo_zero")
