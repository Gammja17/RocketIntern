"""위쪽 막대 아이콘(16x16 픽셀아트)을 그린다: 돈 · 의심도 · 수사망 · 설정.

python tools/make_icons.py  →  assets/ui/icon_money.png · icon_susp.png · icon_heat.png · icon_gear.png
"""
import pathlib

from PIL import Image

OUT = pathlib.Path(__file__).resolve().parent.parent / "assets" / "ui"
PAL = {
    ".": (0, 0, 0, 0), "k": (20, 16, 24, 255), "y": (255, 214, 90, 255), "o": (214, 150, 40, 255),
    "w": (250, 246, 236, 255), "r": (230, 64, 76, 255), "d": (150, 30, 40, 255), "b": (90, 150, 255, 255),
    "n": (40, 80, 170, 255), "g": (120, 120, 132, 255),
}
ICONS = {
    "icon_money": [  # 로켓단 R 이 찍힌 동전
        "................",
        ".....kkkkkk.....",
        "...kkyyyyyykk...",
        "..kyyyyyyyyyyk..",
        "..kyyokkkoyyyk..",
        ".kyyyokyykoyyyk.",
        ".kyyyokyykoyyyk.",
        ".kyyyokkkoyyyyk.",
        ".kyyyokyko yyyk.".replace(" ", "y"),
        ".kyyyokyykoyyyk.",
        "..kyyokyyykoyk..",
        "..kyyyyyyyyyyk..",
        "...kkyyyyyykk...",
        ".....kkkkkk.....",
        "................",
        "................",
    ],
    "icon_susp": [  # 지켜보는 눈 (아폴로)
        "................",
        "................",
        "................",
        ".....kkkkkk.....",
        "...kkwwwwwwkk...",
        "..kwwwwrrwwwwk..",
        ".kwwwwrddrwwwwk.",
        "kwwwwrdkkdrwwwwk",
        "kwwwwrdkkdrwwwwk",
        ".kwwwwrddrwwwwk.",
        "..kwwwwrrwwwwk..",
        "...kkwwwwwwkk...",
        ".....kkkkkk.....",
        "................",
        "................",
        "................",
    ],
    "icon_gear": [  # 설정 톱니바퀴
        "................",
        ".......kk.......",
        "...kk.kwwk.kk...",
        "..kwwkkwwkkwwk..",
        "..kwwwwwwwwwwk..",
        "...kwwwkkwwwk...",
        ".kkkwwk..kwwkkk.",
        "kwwwwk....kwwwwk",
        "kwwwwk....kwwwwk",
        ".kkkwwk..kwwkkk.",
        "...kwwwkkwwwk...",
        "..kwwwwwwwwwwk..",
        "..kwwkkwwkkwwk..",
        "...kk.kwwk.kk...",
        ".......kk.......",
        "................",
    ],
    "icon_heat": [  # 경찰 경광등
        "................",
        "......kkkk......",
        ".....kbbbbk.....",
        "....kbbwwbbk....",
        "....kbwwbbbk....",
        "....kbbbbbnk....",
        "...kbbbbbbnnk...",
        "...kbbbbbnnnk...",
        "..kkkkkkkkkkkk..",
        "..kggggggggggk..",
        "..kkkkkkkkkkkk..",
        "................",
        ".k............k.",
        "k..............k",
        "................",
        "................",
    ],
}


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    for name, rows in ICONS.items():
        im = Image.new("RGBA", (16, 16))
        for y, row in enumerate(rows):
            for x, ch in enumerate(row[:16]):
                im.putpixel((x, y), PAL.get(ch, PAL["."]))
        im.save(OUT / f"{name}.png")
    print("ok")


if __name__ == "__main__":
    main()
