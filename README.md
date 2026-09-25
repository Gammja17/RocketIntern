# 로켓단 신입사원 (포켓몬 팬게임)

월세가 밀린 주인공이 로켓단 창고에 들어가 한 달을 일하는 이야기다. 매일 들어오는 포켓몬 상자를 열어서 본사 트럭에 실을지, 뒷문으로 풀어줄지, 주인에게 돌려보낼지 고른다. 할당량과 의심도, 매주 금요일 월세 사이에서 줄타기를 한다. 첫 주에 내린 선택은 몇 주 뒤에 돌아온다. 1세대 원작의 실프주식회사 사건 주간을 창고 안쪽에서 겪게 된다.

- 엔진: Godot 4.7 (Compatibility), 960x540
- 실행: Godot에서 이 폴더를 열고 F5. 매일 아침 자동 저장되고, 타이틀에서 이어하기를 할 수 있다.

## 한 달의 흐름
| 주차 | 이야기 | 새로 생기는 것 |
|---|---|---|
| 1주 · 입사 | 로사 · 로이 · 나옹, 동기 세나, 감사관 아폴로 | 검수, 반품, 감사, 아침 신문 |
| 2주 · 로사의 엄마 | 게임코너 지하 기록실, 아보크 M-04 | 서류 대조(수배 · 실종 전단), 돌려보내기 |
| 3주 · 로이의 집 | 집사와 약혼자, 가디 '대장', 제보 수당 | 탐지견, 관계에 따라 갈리는 금요일 |
| 4주 · 실프주식회사 | 레드, 실프 점거, 마지막 금요일의 불 | 결말 선택 |

토요일에는 게임코너(슬롯 · 경품), 포장마차, 백화점(원룸 물건), 상록숲, 돌려보낸 집 가운데 두 곳에 간다. 뒷문 풀밭에는 갈 곳 없는 몇 마리만 며칠씩 머물다 떠난다.

## 결말
안 읽는 게 편해 · 기록 상자 · 마지막 트럭 · 첫 포켓몬 · 돌아온 차례 · 빈 몬스터볼 · 뒷문으로 나간 사람(해고) · 잠긴 창고

## 구조
- `scripts/data/week1.gd`~`week4.gd`: 대본과 상자. 형식은 `scripts/data/README.md`
- `scripts/data/extra.gd`: 인물, 토요일 장소, 경품, 백화점 물건, 풀밭
- `scripts/data/anim_meta.gd`: 움직이는 스프라이트 정보 (`tools/fetch_anims.py`가 만든다)
- `scripts/main.gd`: 진행 엔진 · 저장 · 연출
- `scenes/main.tscn`: 화면 배치
- `tools/sim.gd`: 자동 플레이 점검
  `godot --headless --path . -s tools/sim.gd -- kind 1 2` (전략 kind · evil · greedy · random, 씨앗, 마지막 선택 번호)
- `tools/shot.gd`: 장면 캡처. `godot --path . -s tools/shot.gd -- <폴더>`
- `tools/fetch_anims.py`: 데이터에 나온 포켓몬의 움직이는 스프라이트를 받아 프레임 시트로 만든다

## 에셋 출처와 주의
- 포켓몬 정지 스프라이트 `assets/pokemon/`: PokeAPI sprites (https://github.com/PokeAPI/sprites)
- 움직이는 스프라이트 `assets/pokemon_anim/`: Pokémon Showdown gen5ani (https://play.pokemonshowdown.com/sprites/gen5ani/)
- 트레이너 그림 `assets/trainers/`: Pokémon Showdown (https://play.pokemonshowdown.com/sprites/trainers/)
- 배경 `assets/bg/city · meadow · forest`: Pokémon Showdown 배틀 배경
- 배경 `assets/bg/warehouse · room · stall · gamecorner · archive · silph`: PixelLab으로 생성
- 음악 `assets/music/`: 포켓몬 파이어레드 · 리프그린 사운드트랙 (archive.org `pkmn-frlg-soundtrack`)
- 글꼴 `assets/fonts/Mulmaru.woff2`: 물마루 by Mushsooni, SIL OFL 1.1 (`Mulmaru-LICENSE.txt`)

포켓몬 관련 그림, 이름, 음악의 저작권은 Nintendo, Creatures, GAME FREAK, The Pokémon Company에 있다. 비영리 팬 프로젝트이며 수익화하지 않는다.
