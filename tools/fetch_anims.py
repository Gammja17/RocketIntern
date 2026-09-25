"""데이터에 나오는 포켓몬의 움직이는 스프라이트를 받아 프레임 시트로 바꾼다.

python tools/fetch_anims.py

- scripts/data/*.gd 에서 "id": 번호 와 pokemon:번호 를 모은다.
- 쇼다운 gen5ani GIF 를 받아 assets/pokemon_anim/<번호>.png (가로 한 줄) 로 저장한다.
- 정지 그림 assets/pokemon/<번호>.png 도 없으면 PokeAPI 에서 받는다.
- 프레임 수 · 크기 · 프레임 길이를 scripts/data/anim_meta.gd 에 적는다.
"""
import io
import pathlib
import re
import urllib.request

from PIL import Image, ImageSequence

ROOT = pathlib.Path(__file__).resolve().parent.parent
ANIM = ROOT / "assets" / "pokemon_anim"
STILL = ROOT / "assets" / "pokemon"

# 쇼다운 파일 이름 (영어 소문자, 기호 없음)
SLUG = {
    1: "bulbasaur", 7: "squirtle", 10: "caterpie", 13: "weedle", 14: "kakuna", 16: "pidgey", 17: "pidgeotto",
    19: "rattata", 21: "spearow", 23: "ekans", 24: "arbok", 25: "pikachu", 27: "sandshrew", 29: "nidoranf",
    32: "nidoranm", 35: "clefairy", 37: "vulpix", 39: "jigglypuff", 41: "zubat", 43: "oddish", 46: "paras",
    48: "venonat", 50: "diglett", 52: "meowth", 54: "psyduck", 56: "mankey", 58: "growlithe", 60: "poliwag",
    61: "poliwhirl", 63: "abra", 64: "kadabra", 66: "machop", 69: "bellsprout", 72: "tentacool", 74: "geodude",
    77: "ponyta", 79: "slowpoke", 80: "slowbro", 81: "magnemite", 83: "farfetchd", 84: "doduo", 86: "seel",
    88: "grimer", 90: "shellder", 92: "gastly", 95: "onix", 96: "drowzee", 98: "krabby", 100: "voltorb",
    101: "electrode", 102: "exeggcute", 104: "cubone", 106: "hitmonlee", 107: "hitmonchan", 109: "koffing",
    111: "rhyhorn", 113: "chansey", 114: "tangela", 115: "kangaskhan", 116: "horsea", 118: "goldeen",
    120: "staryu", 122: "mrmime", 123: "scyther", 125: "electabuzz", 126: "magmar", 127: "pinsir",
    129: "magikarp", 131: "lapras", 132: "ditto", 133: "eevee", 134: "vaporeon", 137: "porygon", 147: "dratini",
}


def used_ids() -> list[int]:
    ids = set()
    for f in (ROOT / "scripts" / "data").glob("*.gd"):
        text = f.read_text(encoding="utf-8")
        ids |= {int(n) for n in re.findall(r'"id":\s*(\d+)', text)}
        ids |= {int(n) for n in re.findall(r'pokemon:(\d+)', text)}
    return sorted(ids)


def get(url: str) -> bytes:
    req = urllib.request.Request(url, headers={"User-Agent": "RocketIntern asset fetch"})
    with urllib.request.urlopen(req, timeout=30) as r:
        return r.read()


def main() -> None:
    ANIM.mkdir(parents=True, exist_ok=True)
    meta = {}
    for pid in used_ids():
        still = STILL / f"{pid}.png"
        if not still.exists():
            still.write_bytes(get(f"https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/{pid}.png"))
        gif = Image.open(io.BytesIO(get(f"https://play.pokemonshowdown.com/sprites/gen5ani/{SLUG[pid]}.gif")))
        frames = [fr.convert("RGBA") for fr in ImageSequence.Iterator(gif)]
        w, h = frames[0].size
        sheet = Image.new("RGBA", (w * len(frames), h))
        for i, fr in enumerate(frames):
            sheet.paste(fr, (i * w, 0))
        sheet.save(ANIM / f"{pid}.png")
        ms = max(20, gif.info.get("duration", 60))
        meta[pid] = (len(frames), w, h, ms)
        print(pid, SLUG[pid], len(frames), "frames", f"{w}x{h}")
    lines = ["extends RefCounted", "## tools/fetch_anims.py 가 만든다. 번호: [프레임 수, 너비, 높이, 프레임 길이(ms)]", "", "const META := {"]
    lines += [f"\t{pid}: [{n}, {w}, {h}, {ms}]," for pid, (n, w, h, ms) in meta.items()]
    lines.append("}")
    (ROOT / "scripts" / "data" / "anim_meta.gd").write_text("\n".join(lines) + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()
