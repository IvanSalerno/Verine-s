"""Pratos prontos em vista 3/4 (para a louça lateral): bolo, pudim, lasanha e panqueca."""
import math, sys, importlib.util
import numpy as np
from PIL import Image, ImageDraw

spec = importlib.util.spec_from_file_location("ds", sys.argv[3])
ds = importlib.util.module_from_spec(spec)
sys.argv = [sys.argv[3], sys.argv[1], sys.argv[2]]
src = open(sys.argv[0]).read().split("GREEN = (104, 156, 88)")[0]   # só as funções de desenho
exec(compile(src, "draw_sprites", "exec"), ds.__dict__)
S, LINE = ds.S, ds.LINE
canvas, fill, outline_shape, line = ds.canvas, ds.fill, ds.outline_shape, ds.line
poly_mask, ellipse_mask, rrect_mask = ds.poly_mask, ds.ellipse_mask, ds.rrect_mask

def cylinder(img, cx, top, rx, ry, h, side, topc, taper=0.0):
    """Cilindro em perspectiva: lateral + elipse de cima. taper > 0 afina o topo."""
    rt = rx * (1 - taper)
    body = [(cx - rt, top)] + [(cx - rx + 0 * i, top + h) for i in range(1)]
    pts = [(cx - rt, top)]
    pts += [(cx - rx, top + h)]
    pts += [(cx + rx * math.cos(t), top + h + ry * math.sin(t)) for t in np.linspace(math.pi, 0, 40)]
    pts += [(cx + rt, top)]
    m = poly_mask(pts)
    fill(img, m, side, "cyl", (cx - rx, top, cx + rx, top + h + ry), 0.35)
    outline_shape(img, m, 10)
    tm = ellipse_mask((cx - rt, top - ry * (rt / rx), cx + rt, top + ry * (rt / rx)))
    fill(img, tm, topc, "dome", tm.getbbox(), 0.25)
    outline_shape(img, tm, 9)
    return tm

def drips(img, cx, top, rx, ry, length, color, n=9, seed=1):
    rng = np.random.default_rng(seed)
    for i in range(n):
        t = math.pi * (0.08 + 0.84 * i / (n - 1))
        x = cx - rx * math.cos(t)
        y = top + ry * math.sin(t)
        L = length * (0.5 + rng.random())
        w = 30 + rng.integers(0, 22)
        d = [(x - w / 2, y - 10), (x + w / 2, y - 10), (x + w / 2, y + L - w / 2)]
        d += [(x + w / 2 * math.cos(a), y + L - w / 2 + w / 2 * math.sin(a)) for a in np.linspace(0, math.pi, 12)]
        m = poly_mask(d)
        fill(img, m, color, "cyl", m.getbbox(), 0.2)
        outline_shape(img, m, 7)

def bolo():
    img = canvas()
    cx, top, rx, ry, h = 500, 400, 330, 120, 300
    cylinder(img, cx, top, rx, ry, h, (226, 170, 92), (246, 236, 214))
    line(img, [(cx - rx + 10, top + h - 40), (cx + rx - 10, top + h - 40)], 5, (180, 120, 60))   # base assada
    # cobertura: elipse de cima + escorridos
    drips(img, cx, top, rx, ry, 120, (248, 240, 222), 10, 3)
    tm = ellipse_mask((cx - rx - 6, top - ry - 4, cx + rx + 6, top + ry + 4))
    fill(img, tm, (250, 243, 228), "dome", tm.getbbox(), 0.2)
    outline_shape(img, tm, 9)
    # morangos/confeitos simples
    for x, y in [(400, 380), (520, 350), (610, 410), (470, 445), (560, 470)]:
        m = ellipse_mask((x - 26, y - 22, x + 26, y + 22))
        fill(img, m, (214, 72, 60), "dome", m.getbbox(), 0.4)
        outline_shape(img, m, 7)
        ImageDraw.Draw(img).ellipse((x - 12, y - 12, x - 2, y - 4), fill=(255, 220, 210, 255))
    return img

def pudim():
    img = canvas()
    cx, top, rx, ry, h = 500, 430, 320, 115, 260
    # poça de calda embaixo
    pool = ellipse_mask((cx - rx - 70, top + h + ry - 70, cx + rx + 70, top + h + ry + 60))
    fill(img, pool, (176, 96, 36), "dome", pool.getbbox(), 0.25)
    outline_shape(img, pool, 8)
    tm = cylinder(img, cx, top, rx, ry, h, (238, 196, 104), (190, 104, 38), taper=0.12)
    # calda escorrendo
    drips(img, cx, top, rx * 0.88, ry * 0.88, 150, (184, 98, 34), 9, 5)
    tm = ellipse_mask((cx - rx * 0.88, top - ry * 0.88, cx + rx * 0.88, top + ry * 0.88))
    fill(img, tm, (188, 100, 36), "dome", tm.getbbox(), 0.3)
    outline_shape(img, tm, 9)
    # furo no meio (pudim de leite)
    hole = ellipse_mask((cx - 70, top - 26, cx + 70, top + 26))
    fill(img, hole, (120, 60, 22), "v", hole.getbbox(), 0.3)
    outline_shape(img, hole, 8)
    line(img, [(cx - 200, top - 40), (cx - 120, top - 70)], 10, (240, 170, 110))   # brilho
    return img

def lasanha():
    img = canvas()
    # travessa larga e rasa, vista de cima-lado: muita superfície gratinada à mostra
    front = [(150, 575), (850, 575), (822, 735), (178, 735)]
    fill(img, poly_mask(front), (196, 108, 66), "v", (150, 575, 850, 735), 0.35)
    outline_shape(img, poly_mask(front), 10)
    line(img, [(168, 650), (832, 650)], 6, (160, 82, 48))
    rim = rrect_mask((120, 300, 880, 610), 80)
    fill(img, rim, (240, 230, 210), "v", (120, 300, 880, 610), 0.18)
    outline_shape(img, rim, 10)
    food = rrect_mask((165, 330, 835, 580), 60)
    fill(img, food, (226, 92, 56), "flat")          # molho nas bordas
    top = rrect_mask((190, 348, 810, 562), 52)
    fill(img, top, (240, 190, 92), "dome", (190, 348, 810, 562), 0.25)
    outline_shape(img, food, 8)
    rng = np.random.default_rng(9)
    d = ImageDraw.Draw(img)
    for _ in range(40):   # queijo gratinado: manchas douradas e tostadas
        x, y = rng.integers(220, 780), rng.integers(370, 545)
        r = int(rng.integers(14, 34))
        c = (198, 124, 50, 255) if rng.random() < 0.7 else (160, 90, 40, 255)
        d.ellipse((x - r, y - r * 0.55, x + r, y + r * 0.55), fill=c)
    for _ in range(18):   # bolhinhas de molho
        x, y = rng.integers(210, 790), rng.integers(360, 550)
        r = int(rng.integers(8, 16))
        d.ellipse((x - r, y - r * 0.6, x + r, y + r * 0.6), fill=(204, 66, 44, 255))
    for _ in range(10):   # manjericão
        x, y = rng.integers(260, 740), rng.integers(380, 530)
        d.ellipse((x - 12, y - 7, x + 12, y + 7), fill=(92, 150, 70, 255))
    for x0, x1 in ((60, 135), (865, 940)):   # alças
        h = rrect_mask((x0, 420, x1, 490), 24)
        fill(img, h, (240, 230, 210), "v", h.getbbox(), 0.2)
        outline_shape(img, h, 8)
    return img

def panqueca():
    img = canvas()
    crepe = (242, 206, 140)
    def roll(x0, y0, w, r):
        body = rrect_mask((x0, y0, x0 + w, y0 + 2 * r), r)
        fill(img, body, crepe, "v", (x0, y0, x0 + w, y0 + 2 * r), 0.38)
        outline_shape(img, body, 9)
        # ponta aberta mostrando o enrolado (espiral) e o recheio
        ex, ey = x0 + w - r * 0.35, y0 + r
        end = ellipse_mask((ex - r * 0.55, y0 + 6, ex + r * 0.55, y0 + 2 * r - 6))
        fill(img, end, (250, 226, 170), "flat")
        outline_shape(img, end, 8)
        fillc = ellipse_mask((ex - r * 0.28, ey - r * 0.4, ex + r * 0.28, ey + r * 0.4))
        fill(img, fillc, (170, 92, 54), "flat")
        spiral = [(ex + 0.5 * t * math.cos(t * 1.15), ey + 0.85 * t * math.sin(t * 1.15)) for t in np.linspace(18, 60, 60)]
        line(img, spiral, 6, (190, 130, 70))
        rng = np.random.default_rng(int(x0))
        for _ in range(14):   # pintinhas douradas da frigideira
            x, y = rng.integers(int(x0 + 40), int(x0 + w - r)), rng.integers(int(y0 + 18), int(y0 + 2 * r - 18))
            ImageDraw.Draw(img).ellipse((x - 10, y - 6, x + 10, y + 6), fill=(206, 146, 78, 255))
    roll(230, 380, 540, 100)
    roll(170, 540, 590, 112)
    # molho de tomate derramado: forma orgânica (união de círculos) com escorridos
    sauce = Image.new("L", (S, S), 0)
    d = ImageDraw.Draw(sauce)
    rng = np.random.default_rng(4)
    for i in range(26):
        x = 270 + i * 17 + rng.normal(0, 8)
        y = 520 + 40 * math.sin(i / 3.0) + rng.normal(0, 10)
        r = rng.integers(48, 72)
        d.ellipse((x - r, y - r * 0.8, x + r, y + r * 0.8), fill=255)
    for x in (330, 470, 600, 700):
        L = rng.integers(70, 130)
        d.rounded_rectangle((x - 18, 540, x + 18, 560 + L), 18, fill=255)
    fill(img, sauce, (204, 60, 40), "dome", sauce.getbbox(), 0.22)
    outline_shape(img, sauce, 8)
    for x, y in [(330, 500), (420, 540), (520, 495), (610, 530), (690, 505)]:   # brilho + salsinha
        ImageDraw.Draw(img).ellipse((x - 16, y - 8, x + 4, y + 2), fill=(240, 130, 110, 255))
        ImageDraw.Draw(img).ellipse((x + 10, y + 16, x + 30, y + 28), fill=(92, 150, 70, 255))
    return img

def save(img, name):
    tmp = f"/tmp/_dish_{name}.png"
    img.save(tmp)
    print(name, ds.st.stylize(tmp, f"{sys.argv[2]}/pratos/{name}.png", flood=False))

save(bolo(), "bolo")
save(pudim(), "pudim_verine")
save(lasanha(), "lasanha")
save(panqueca(), "panqueca")
