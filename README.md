# 로켓단 신입사원 (포켓몬 팬게임)

로켓단 창고에 입사한 신입이 되어 월요일부터 금요일까지 일한다. 매일 들어오는 포켓몬 상자를 열어 본사 트럭에 실을지 뒷문으로 풀어줄지 고른다. 할당량, 의심도, 금요일 월세 15,000원 사이에서 줄타기를 해야 한다.

- 엔진: Godot 4.7 (Compatibility), 960x540
- 실행: Godot에서 이 폴더를 열고 F5

## 구조
- `scripts/days.gd`: 5일치 대본과 상자 데이터. 대사와 규칙은 전부 여기서 고친다.
- `scripts/main.gd`: 하루 진행, 일당·생활비·월세 계산, 결말 고르기
- `scenes/main.tscn`: 화면 배치
- `tools/sim.gd`: 자동 플레이 점검
  `godot --headless --path . -s tools/sim.gd -- smart` (전략: send_all · release_all · kind · smart · report · poor)
- `tools/shot.gd`: 장면 캡처. `godot --path . -s tools/shot.gd -- <저장할 폴더>`

## 결말 6개
뒷문으로 나간 사람(해고) · 창고 식구 · 잠긴 창고 · 안 읽는 게 편해 · 실적 꼴찌 창고 · 다음 주도 출근

## 에셋 출처와 주의
- 포켓몬 스프라이트 `assets/pokemon/`: PokeAPI sprites (https://github.com/PokeAPI/sprites)
- 트레이너 그림 `assets/trainers/`: Pokémon Showdown (https://play.pokemonshowdown.com/sprites/trainers/)
- 글꼴 `assets/fonts/Mulmaru.woff2`: 물마루 by Mushsooni, SIL OFL 1.1 (`Mulmaru-LICENSE.txt`)

포켓몬 관련 그림과 이름의 저작권은 Nintendo, Creatures, GAME FREAK, The Pokémon Company에 있다. 개인 연습용으로만 쓰고, 공개 배포나 수익화는 하지 않는다.
