"""Aproxima assets planos (vetor, fundo branco) da identidade visual do Verine's:
cores quentes e menos saturadas, contorno marrom-escuro, sombra suave nas bordas e grão de papel."""
import sys
import numpy as np
from PIL import Image, ImageFilter, ImageDraw

OUTLINE = (58, 34, 24)        # marrom das linhas da cozinha / personagens
WARM = np.array([1.0, 0.955, 0.87])
SAT = 0.68                    # quanto da saturação original fica
TARGET_W = 480

def remove_white(im, thresh=246):
    """Fundo branco ligado às bordas vira transparente (o branco de dentro do desenho fica)."""
    rgb = im.convert("RGB")
    w, h = rgb.size
    mask = Image.new("L", (w, h), 0)
    a = np.array(rgb).astype(int)
    near = (a.min(axis=2) >= thresh).astype(np.uint8) * 255
    near_img = Image.fromarray(near)
    # flood fill a partir das bordas, só por pixels quase brancos
    seeds = [(0, 0), (w - 1, 0), (0, h - 1), (w - 1, h - 1), (w // 2, 0), (w // 2, h - 1), (0, h // 2), (w - 1, h // 2)]
    ff = near_img.copy()
    for s in seeds:
        if ff.getpixel(s) == 255:
            ImageDraw.floodfill(ff, s, 128)
    bg = (np.array(ff) == 128)
    alpha = np.where(bg, 0, 255).astype(np.uint8)
    # borda suave: pixels claros vizinhos do fundo ganham alpha parcial
    al = Image.fromarray(alpha).filter(ImageFilter.GaussianBlur(0.8))
    out = np.dstack([np.array(rgb), np.array(al)])
    return Image.fromarray(out.astype(np.uint8), "RGBA")

def grade(arr):
    rgb = arr[..., :3].astype(float) / 255.0
    gray = (rgb * [0.299, 0.587, 0.114]).sum(axis=2, keepdims=True)
    rgb = gray + (rgb - gray) * SAT          # menos saturado
    rgb = rgb * WARM                         # puxa para o quente
    rgb = rgb * 0.93 + np.array([0.33, 0.2, 0.12]) * 0.07   # sombras amarronzadas
    return rgb

def stylize(src, dst, flood=True, outline_px=4, thresh=246, max_w=TARGET_W):
    im = Image.open(src)
    im = remove_white(im, thresh) if flood else im.convert("RGBA")
    im = im.crop(im.getbbox())
    if im.width > max_w:
        im = im.resize((max_w, round(im.height * max_w / im.width)), Image.LANCZOS)
    pad = outline_px + 8
    canvas = Image.new("RGBA", (im.width + 2 * pad, im.height + 2 * pad), (0, 0, 0, 0))
    canvas.paste(im, (pad, pad))
    arr = np.array(canvas).astype(float)
    alpha = arr[..., 3] / 255.0
    rgb = grade(arr)
    # sombra suave para dentro das bordas (volume "pintado à mão")
    inner = np.array(Image.fromarray((alpha * 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(7))) / 255.0
    edge = np.clip((1.0 - inner) * 1.6, 0, 1) * alpha
    rgb = rgb * (1.0 - 0.22 * edge[..., None])
    # grão de papel
    rng = np.random.default_rng(7)
    rgb = rgb * (1.0 + rng.normal(0, 0.018, rgb.shape[:2])[..., None])
    rgb = np.clip(rgb, 0, 1)
    body = np.dstack([rgb * 255, alpha * 255]).astype(np.uint8)
    body_img = Image.fromarray(body, "RGBA")
    # contorno marrom: alpha dilatado por trás da imagem
    hard = Image.fromarray(((alpha > 0.35) * 255).astype(np.uint8))
    dil = hard.filter(ImageFilter.MaxFilter(outline_px * 2 + 1)).filter(ImageFilter.GaussianBlur(0.7))
    line = Image.new("RGBA", canvas.size, OUTLINE + (0,))
    line.putalpha(dil)
    out = Image.alpha_composite(line, body_img)
    out.save(dst)
    return out.size

if __name__ == "__main__":
    src, dst = sys.argv[1], sys.argv[2]
    flood = sys.argv[3] != "noflood" if len(sys.argv) > 3 else True
    thresh = int(sys.argv[4]) if len(sys.argv) > 4 else 246
    print(dst, stylize(src, dst, flood=flood, thresh=thresh))
