"""번역할 문장을 모은다.

python tools/i18n_extract.py

- scripts/data/*.gd 와 scripts/main.gd 에서 한글이 든 문자열을 전부 모은다.
- scenes/main.tscn 의 text = "..." 도 모은다.
- translations/strings.csv 에 이미 있는 번역은 그대로 두고, 새 문장만 빈칸으로 덧붙인다.
- 번역이 빈 문장 수를 알려 준다.
"""
import csv
import pathlib
import re

ROOT = pathlib.Path(__file__).resolve().parent.parent
CSV = ROOT / "translations" / "strings.csv"
HANGUL = re.compile(r"[가-힣]")
STR = re.compile(r'"((?:[^"\\\n]|\\.)*)"')


def unescape(s: str) -> str:
    return s.replace('\\"', '"').replace("\\n", "\n").replace("\\\\", "\\")


def collect() -> list[str]:
    found = []
    files = sorted((ROOT / "scripts" / "data").glob("*.gd")) + [ROOT / "scripts" / "main.gd"]
    for f in files:
        for line in f.read_text(encoding="utf-8").splitlines():
            code = line.lstrip()
            if code.startswith("#"):
                continue
            for m in STR.finditer(line):
                s = unescape(m.group(1))
                if HANGUL.search(s) and len(s) > 1:   # 한 글자짜리 조사는 빼고
                    found.append(s)
    for m in re.finditer(r'^text = "((?:[^"\\]|\\.)*)"', (ROOT / "scenes" / "main.tscn").read_text(encoding="utf-8"), re.M):
        s = unescape(m.group(1))
        if HANGUL.search(s):
            found.append(s)
    seen = set()
    out = []
    for s in found:
        if s not in seen:
            seen.add(s)
            out.append(s)
    return out


def main() -> None:
    old = {}
    if CSV.exists():
        with CSV.open(encoding="utf-8", newline="") as fp:
            for row in csv.DictReader(fp):
                old[row["keys"]] = row.get("en", "")
    strings = collect()
    CSV.parent.mkdir(exist_ok=True)
    with CSV.open("w", encoding="utf-8", newline="") as fp:
        w = csv.writer(fp)
        w.writerow(["keys", "ko", "en"])
        for s in strings:
            w.writerow([s, s, old.get(s, "")])
    empty = sum(1 for s in strings if not old.get(s))
    print(f"문장 {len(strings)}개 · 번역 빈칸 {empty}개 · 글자 {sum(len(s) for s in strings)}자")


if __name__ == "__main__":
    main()
