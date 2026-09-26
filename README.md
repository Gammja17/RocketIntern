# 로켓단 신입사원 (포켓몬 팬게임)

월세가 밀린 주인공이 로켓단 창고에 들어가 한 달을 일하는 이야기다. 매일 들어오는 포켓몬 상자를 열어서 본사 트럭에 실을지, 뒷문으로 풀어줄지, 주인에게 돌려보낼지 고른다. 할당량과 의심도, 매주 금요일 월세 사이에서 줄타기를 한다. 첫 주에 내린 선택은 몇 주 뒤에 돌아온다. 1세대 원작의 실프주식회사 사건 주간을 창고 안쪽에서 겪게 된다.

- 엔진: Godot 4.7 (Compatibility), 960x540
- 실행: Godot에서 이 폴더를 열고 F5. 장면마다 자동 저장되고, 타이틀에서 이어하기를 하면 하던 장면부터 이어진다. 저장 코드(타이틀 · 설정)를 복사해 두면 다른 기기나 브라우저에서 붙여넣어 이어할 수 있다.

## 한 달의 흐름
| 주차 | 이야기 | 새로 생기는 것 |
|---|---|---|
| 1주 · 입사 | 로사 · 로이 · 나옹, 동기 세나, 감사관 아폴로 | 검수, 반품, 감사, 아침 신문 |
| 2주 · 로사의 엄마 | 게임코너 지하 기록실, 아보크 M-04 | 서류 대조(수배 · 실종 전단), 돌려보내기 |
| 3주 · 로이의 집 | 집사와 약혼자, 가디 '대장', 제보 수당 | 탐지견, 관계에 따라 갈리는 금요일 |
| 4주 · 실프주식회사 | 레드, 실프 점거, 마지막 금요일의 불 | 결말 선택 |

토요일에는 게임코너(슬롯 · 경품), 포장마차, 백화점(원룸 물건), 상록숲, 돌려보낸 집 가운데 두 곳에 간다.

## 두 개의 압박
- **로켓단 의심도**: 풀어줄수록 오른다. 100이 되면 마지막 경고, 두 번째는 해고.
- **경찰 수사망**: 사연 있는 녀석을 본사로 보낼수록 오른다. 참고인 조사 → 가택 수색 → 체포. 다 보내면 결국 감옥에 가거나 로켓단의 목줄을 차야 한다.

## 뒷문 풀밭
갈 곳 없는 녀석만 며칠씩 머문다. 밤마다 먹이 주기, 한 마리와 놀아 주기, 은신처 만들기 중 하나를 고른다. 친밀도가 3이 되면 떠나지 않고, 원룸에 데려갈 수 있다(최대 3마리). 데려간 녀석은 배틀에 나서고, 저마다 쓸모가 있다(캐이시는 체포 순간 순간이동, 메타몽은 가택 수색 때 인형 흉내, 폴리곤은 본사 기록 지우기).

## 매일 조금씩 다른 창고
- 사연 없는 야생 포켓몬 상자는 판마다 43종 가운데서 바뀐다 (판의 씨앗으로 정해서 이어 해도 같다).
- 평일 아침에 가끔 창고 안 사건이 끼어든다 (탈출한 꼬렛, 트럭 고장, 나옹의 참치캔, 정전 등 12개).
- 밤에는 전에 풀어준 녀석이 풀밭에 들르기도 하고, 원룸 식구와 산책하면 그 녀석이 배틀에 나선다.
- 상자를 열면 그 포켓몬의 울음소리가 난다.

## 기록실
본 결말과 동료 운명(35가지)을 모아 두는 도감. 새로 시작해도 남고, 두 번째 판부터는 기시감 대사가 나온다.

## 모바일
웹판을 폰에서 세로로 들면 540x960 세로 배치로 바뀐다.

## 배틀
투기장 경비, 그린, 아폴로와 한 번씩. 마지막으로 산책한 원룸 식구가 나서고, 없으면 로켓단 지급 꼬렛이 나선다. 저마다 한 번 쓸 수 있는 특기가 있다. 이기고 지는 것에 따라 이야기가 갈린다.

## 결말
큰 결말 10개: 안 읽는 게 편해 · 기록 상자 · 거래 · 마지막 트럭 · 첫 포켓몬 · 돌아온 차례 · 빈 몬스터볼 · 수갑 · 뒷문으로 나간 사람(해고) · 잠긴 창고.
결말 뒤에 로사(7) · 로이(8) · 세나(6) · 나옹(4)의 운명, 원룸 식구의 뒷이야기, 한 달 뒤 신문이 선택에 따라 따로 붙는다. 경우의 수는 `tools/explore.gd`로 잰다.

## 도전 과제
25개. 목록과 exe 등록 코드는 `scripts/data/achievements.gd`에 있다. 웹판은 달성할 때 `SKEAM.unlock(id)`를 부르고, SDK는 내보내기 설정의 head_include로 넣는다. exe판은 달성하면 화면 오른쪽 위에 등록 코드를 보여 준다. 타이틀의 "도전 과제" 메뉴에서 달성한 과제의 코드를 다시 볼 수 있다. 달성 기록은 `user://achievements.json`에 남아서 새로 시작해도 유지된다.

## 배포
- 웹판: main에 올리면 `.github/workflows/pages.yml`이 내보내서 https://gammja17.github.io/RocketIntern/ 에 올린다.
- exe판: 128MB라 git에 못 올린다. 이 PC에서 내보낸 뒤 zip으로 묶어 GitHub Release에 직접 올린다.

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
- `tools/ui_check.gd`: 끝까지 돌리며 패널이 화면 밖으로 나가거나 겹치는지 잰다. 창이 있어야 한다. `godot --path . -s tools/ui_check.gd -- en 540 960 2`
- `tools/explore.gd`: 성향이 제각각인 가상 플레이어로 끝까지 돌려 분기점과 서로 다른 결말 조합을 센다. `godot --headless --path . -s tools/explore.gd -- 300 1`

## 에셋 출처와 주의
- 포켓몬 정지 스프라이트 `assets/pokemon/`: PokeAPI sprites (https://github.com/PokeAPI/sprites)
- 움직이는 스프라이트 `assets/pokemon_anim/`: Pokémon Showdown gen5ani (https://play.pokemonshowdown.com/sprites/gen5ani/)
- 트레이너 그림 `assets/trainers/`: Pokémon Showdown (https://play.pokemonshowdown.com/sprites/trainers/)
- 배경 `assets/bg/city · meadow · forest`: Pokémon Showdown 배틀 배경
- 배경 `assets/bg/warehouse · room · stall · gamecorner · archive · silph`: PixelLab으로 생성
- 울음소리 `assets/cries/`: Pokémon Showdown (https://play.pokemonshowdown.com/audio/cries/)
- 음악 `assets/music/`: 포켓몬 파이어레드 · 리프그린 사운드트랙 (archive.org `pkmn-frlg-soundtrack`)
- 글꼴 `assets/fonts/Mulmaru.woff2`: 물마루 by Mushsooni, SIL OFL 1.1 (`Mulmaru-LICENSE.txt`)

포켓몬 관련 그림, 이름, 음악의 저작권은 Nintendo, Creatures, GAME FREAK, The Pokémon Company에 있다. 비영리 팬 프로젝트이며 수익화하지 않는다.
