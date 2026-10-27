#!/usr/bin/env python3
"""Gera os papéis de parede do sistema (estilo macOS: manchas de cor suaves), versão dia e noite.

Uso: python3 assets/gerar-imagens.py
"""
from pathlib import Path

import numpy as np
from PIL import Image

RAIZ = Path(__file__).resolve().parent.parent
DESTINO = RAIZ / "pacote/raiz/usr/share/wallpapers"

W, H = 2560, 1600

# (centro x, centro y, raio, cor RGB) em frações da tela
TEMAS = {
    "Distro": {
        "fundo": (42, 30, 92),
        "manchas": [
            (0.15, 1.10, 0.75, (242, 153, 74)),
            (0.85, 0.00, 0.60, (91, 63, 217)),
            (0.60, 0.70, 0.62, (214, 69, 122)),
            (0.35, 0.35, 0.45, (120, 80, 230)),
        ],
    },
    "DistroNoite": {
        "fundo": (10, 10, 32),
        "manchas": [
            (0.15, 1.10, 0.75, (120, 52, 70)),
            (0.85, 0.00, 0.60, (40, 30, 120)),
            (0.60, 0.70, 0.62, (90, 30, 90)),
            (0.35, 0.35, 0.45, (30, 40, 110)),
        ],
    },
}


def gerar(fundo, manchas):
    y, x = np.mgrid[0:H, 0:W].astype(np.float32)
    x /= W
    y /= H
    y *= H / W  # mantém as manchas circulares
    img = np.tile(np.array(fundo, dtype=np.float32), (H, W, 1))
    for cx, cy, r, cor in manchas:
        d = np.sqrt((x - cx) ** 2 + (y - cy * H / W) ** 2) / r
        a = np.clip(1 - d, 0, 1) ** 2
        img = img * (1 - a[..., None]) + np.array(cor, dtype=np.float32) * a[..., None]
    # ruído leve evita faixas visíveis no degradê
    img += np.random.default_rng(1).normal(0, 1.2, img.shape)
    return Image.fromarray(np.clip(img, 0, 255).astype(np.uint8))


def main():
    for nome, tema in TEMAS.items():
        pasta = DESTINO / nome / "contents/images"
        pasta.mkdir(parents=True, exist_ok=True)
        gerar(tema["fundo"], tema["manchas"]).save(pasta / f"{W}x{H}.jpg", quality=92)


if __name__ == "__main__":
    main()
