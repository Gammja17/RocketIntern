"""번역 묶음(JSON)을 translations/strings.csv 의 en 칸에 합친다.

python tools/i18n_merge.py <묶음 폴더>

폴더 안의 batch_N.json(원문) 과 batch_N_en.json(번역)을 짝지어, 원문 문장을 키로 en 칸을 채운다.
자리표시자(%s · %d)의 순서가 원문과 다르면 합치지 않고 알려 준다.
"""
import csv
import json
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
CSV = ROOT / "translations" / "strings.csv"
PH = re.compile(r"%[sd%]")


def main() -> None:
    folder = pathlib.Path(sys.argv[1])
    en = {}
    bad = []
    for src in sorted(folder.glob("batch_[0-9].json")) + sorted(folder.glob("batch_[0-9][0-9].json")):
        out = src.with_name(src.stem + "_en.json")
        if not out.exists():
            print("번역 없음:", out.name)
            continue
        ko = json.loads(src.read_text(encoding="utf-8"))
        tr = json.loads(out.read_text(encoding="utf-8"))
        for k, s in ko.items():
            t = tr.get(k, "")
            if not t or PH.findall(s) != PH.findall(t):
                bad.append(s)
                continue
            en[s] = t
    rows = list(csv.DictReader(CSV.open(encoding="utf-8", newline="")))
    filled = 0
    with CSV.open("w", encoding="utf-8", newline="") as fp:
        w = csv.writer(fp)
        w.writerow(["keys", "ko", "en"])
        for r in rows:
            t = en.get(r["keys"], r.get("en", ""))
            filled += 1 if t else 0
            w.writerow([r["keys"], r["keys"], t])
    print(f"문장 {len(rows)}개 중 번역 {filled}개 · 문제 {len(bad)}개")
    for s in bad[:20]:
        print("  문제:", s[:60])


if __name__ == "__main__":
    main()
