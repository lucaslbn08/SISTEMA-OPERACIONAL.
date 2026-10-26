#!/usr/bin/env python3
"""Gera o papel de parede padrão do sistema (estilo macOS: manchas de cor suaves).

Uso: python3 assets/gerar-imagens.py
"""
from pathlib import Path

import numpy as np
from PIL import Image

RAIZ = Path(__file__).resolve().parent.parent
DESTINO = RAIZ / "config/includes.chroot/usr/share/wallpapers/Distro/contents/images"

W, H = 2560, 1600

# (centro x, centro y, raio, cor RGB) em frações da tela
MANCHAS = [
    (0.15, 1.10, 0.75, (242, 153, 74)),
    (0.85, 0.00, 0.60, (91, 63, 217)),
    (0.60, 0.70, 0.62, (214, 69, 122)),
    (0.35, 0.35, 0.45, (120, 80, 230)),
]
FUNDO = np.array((42, 30, 92), dtype=np.float32)


def main():
    y, x = np.mgrid[0:H, 0:W].astype(np.float32)
    x /= W
    y /= H
    y *= H / W  # mantém as manchas circulares
    img = np.tile(FUNDO, (H, W, 1))
    for cx, cy, r, cor in MANCHAS:
        d = np.sqrt((x - cx) ** 2 + (y - cy * H / W) ** 2) / r
        a = np.clip(1 - d, 0, 1) ** 2
        img = img * (1 - a[..., None]) + np.array(cor, dtype=np.float32) * a[..., None]
    # ruído leve evita faixas visíveis no degradê
    img += np.random.default_rng(1).normal(0, 1.2, img.shape)
    DESTINO.mkdir(parents=True, exist_ok=True)
    Image.fromarray(np.clip(img, 0, 255).astype(np.uint8)).save(DESTINO / f"{W}x{H}.jpg", quality=92)


if __name__ == "__main__":
    main()
