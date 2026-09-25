# 대본 데이터 형식

`week1.gd`~`week4.gd`의 `DAYS`는 하루 단위 배열이다. 1~3주차는 월~토 6일, 4주차는 월~금 5일이라 모두 23일이다. `main.gd`가 차례로 이어 붙여 굴린다.

## 하루
| 키 | 뜻 |
|---|---|
| `name` | 위쪽 막대에 뜨는 이름 |
| `kind` | `"sat"`이면 토요일 (배경은 도시, 음악은 무지개시티) |
| `quota` | 할당량 |
| `risk_mult` | 풀어줄 때 의심도 배수 (감사하는 날 2.0) |
| `rule` | 검수 화면 위의 오늘 규칙. 라디오를 산 전날 밤에도 들린다 |
| `docs` | 서류철. 문자열, 또는 `{"if": 조건, "text": ...}` |
| `crates` | 상자 목록 (아래) |
| `steps` | 단계 목록 (아래) |

## 상자
| 키 | 뜻 |
|---|---|
| `key` | 고유 이름. 조건 `sent:키` · `rel:키` · `ret:키` · `spc:키`에 쓴다 |
| `id` | 도감 번호. 움직이는 그림은 `assets/pokemon_anim/`, 없으면 정지 그림 |
| `name` · `memo` · `item` | 이름 · 수거 메모 · 딸려 온 것 |
| `risk` | 풀어줄 때 오르는 의심도. 돌려보내면 절반 |
| `named` | 사연 있는 녀석. 풀어준 날 저녁 가로등 아래 그림자로 나온다 |
| `reject` · `reveal` | 보내면 반품(벌금). 풀어줘도 의심받지 않는다 · 반품될 때 밝혀지는 이름 |
| `wanted` | 수배 개체. 트럭에 안 실으면 벌금 2,000원 |
| `owner` · `ret_news` | 2주차부터 주인에게 돌려보낼 수 있다 · 다음 날 아침 신문 |
| `stray` | 풀어주면 뒷문 풀밭에 이 밤 수만큼 머문다. 먹이를 주면 `help:키`가 켜진다 |
| `bonus` | 보냈을 때 특별 수당 |
| `if` | 조건이 맞을 때만 들어온다 |
| `intro` | 상자를 열기 전에 나오는 단계들 (무대에 그 포켓몬이 선다) |
| `special` | 네 번째 버튼. `label`, `flag`, `no_fine`(수배 벌금 면제), `steps` |

## 단계 (`t`)
| t | 뜻 |
|---|---|
| `title` | 가운데 큰 제목 |
| `say` | 대사. `who`는 `extra.gd`의 `PEOPLE` 키. `shake`는 흔들림, `pokemon`은 무대에 세울 포켓몬 번호 |
| `fx` | `money` · `susp` · `flag` · `trust`(`{"rosa": 1}`) · `sena` · `watch` |
| `choice` | `options`: `text`, `if`, 효과(fx와 같은 키), `steps`(고르면 이어지는 단계) |
| `work` | 그날 상자 검수 |
| `report` · `evening` · `rent` · `news` | 일당 · 저녁(생활비, 원룸 물건, 라디오, 뒷문 풀밭) · 금요일 월세 · 전날 돌려보낸 소식 |
| `free` | 토요일 장소 고르기 (`extra.gd`의 `PLACES`) |
| `slots` · `prizes` · `shop` · `visits` | 게임코너 슬롯 · 경품 교환 · 백화점 · 돌려보낸 집 찾아가기 |
| `bg` · `bgm` | `assets/bg/이름.png` · `assets/music/이름.mp3` |
| `epilogue` | 4주차 `EPILOGUE` (한 달 뒤 신문) |
| `end` | 결말 제목을 띄우고 끝낸다 |

모든 단계와 선택지에 `"if"`를 붙일 수 있다.

## 조건
- 플래그 이름: `covered_roy`, `showed_arbok`, `roy_gone`, `bought_butterfree`, …
- `sent:키` · `rel:키` · `ret:키` · `spc:키` · `help:키` · `item:키` · `meadow:키`
- `trust:rosa>=3` · `sena>=2` · `watch>=1` · `susp>=40` · `money>=5000` · `released>=5` · `returned>=1` · `week==2` · `week>=3`
- `rel_today` (오늘 풀어준 게 있음) · `pair_split` (니드런 둘 중 하나만 보냄)
- 앞에 `!`를 붙이면 반대. 배열로 주면 전부 맞아야 한다.
