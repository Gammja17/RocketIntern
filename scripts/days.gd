extends RefCounted
## 5일치 대본과 상자 데이터.
##
## 단계(step) 종류
##   title   화면 가운데 큰 제목
##   say     대사. who: rosa · roy · meowth · apollo · boss · me · narr
##   fx      money · susp 를 더하고 flag 를 켠다
##   choice  선택지 두 개. 고른 쪽의 flag 가 켜진다
##   work    그날 상자 검수
##   report  일당 계산 (main.gd 가 만든다)
##   evening 저녁 생활비 · 창밖 손님 (main.gd 가 만든다)
##   rent    금요일 월세 (main.gd 가 만든다)
##   ending  결말 고르기 (main.gd 가 만든다)
## "if" 조건: 플래그 이름, "sent:키", "rel:키", "susp>=숫자", "rel_today", "pair_split". 앞에 ! 를 붙이면 반대.
## 배열로 주면 전부 맞아야 한다.
##
## 상자 필드
##   key 고유 이름 · id 스프라이트 번호 · name · memo 수거 메모 · item 딸려 온 것
##   risk 풀어줄 때 오르는 의심도 · named 이름표·사연이 있는 녀석(창밖 손님 후보)
##   reject 본사로 보내면 반품(아픔·가짜). 풀어줘도 의심도가 오르지 않는다
##   reveal 반품될 때 밝혀지는 진짜 이름 · bonus 보냈을 때 특별 수당

const DAYS := [
	{
		"name": "월요일",
		"quota": 4,
		"risk_mult": 1.0,
		"rule": "상자를 열어 확인하고 본사 트럭에 실을 것. 오늘 할당량은 4마리.",
		"crates": [
			{"key": "rattata1", "id": 19, "name": "꼬렛", "memo": "22번 도로 풀숲에서 덫으로 잡았다.", "item": "", "risk": 10},
			{"key": "eevee", "id": 133, "name": "이브이", "memo": "무지개시티 주택가의 어느 집 마당에서 데려왔다.", "item": "분홍 리본을 달고 있다. 이름표에 '솜이'라고 적혀 있다.", "risk": 20, "named": true},
			{"key": "pikachu", "id": 25, "name": "피카츄", "memo": "무인발전소 근처에서 잡은 야생 개체. 만질 때 전기 조심.", "item": "", "risk": 10},
			{"key": "caterpie", "id": 10, "name": "캐터피", "memo": "상록숲에서 벌레잡이 소년에게서 '넘겨받았다'.", "item": "삐뚤빼뚤한 글씨의 쪽지가 붙어 있다. '제 첫 포켓몬이에요. 이름은 초록이에요. 돌려주세요. 민수'", "risk": 15, "named": true},
			{"key": "growlithe", "id": 58, "name": "가디", "memo": "순찰하던 경찰관 곁에서 떨어져 나온 개체.", "item": "경찰 인식표를 차고 있다. '상록시티 경찰서 3호'", "risk": 20, "named": true},
			{"key": "poliwag1", "id": 60, "name": "발챙이", "memo": "25번 도로 연못에서 그물로 건졌다.", "item": "", "risk": 10},
		],
		"steps": [
			{"t": "title", "text": "월요일 · 입사 첫날"},
			{"t": "say", "who": "narr", "text": "로켓단 합격 문자를 받은 건 지난주였다. 그때 월세는 이미 두 달째 밀려 있었다."},
			{"t": "say", "who": "narr", "text": "첫 출근지는 상록시티 외곽에 있는 낡은 창고였다."},
			{"t": "say", "who": "rosa", "text": "네가 이번에 들어온 신입이구나. 난 로사, 이쪽은 로이야. 오늘부터 우리가 네 사수야."},
			{"t": "say", "who": "roy", "text": "반가워. 너무 긴장하지 마. 여기 일은 어렵지 않아."},
			{"t": "say", "who": "meowth", "text": "나는 나옹이다옹. 말하는 나옹은 처음 보지? 놀라는 건 일 끝나고 하라옹."},
			{"t": "say", "who": "rosa", "text": "일은 간단해. 현장 팀이 잡아 온 포켓몬이 상자에 담겨서 들어와. 상자를 열어 상태를 보고 본사 트럭에 실으면 끝이야."},
			{"t": "say", "who": "rosa", "text": "오늘 할당량은 네 마리야. 못 채우면 일당이 깎이니까 알아서 잘해."},
			{"t": "say", "who": "roy", "text": "…그리고 상자에 가끔 편지나 이름표 같은 게 같이 딸려 와."},
			{"t": "say", "who": "roy", "text": "그런 건 그냥 안 읽는 게 편해. 진짜로."},
			{"t": "say", "who": "rosa", "text": "로이, 신입한테 쓸데없는 소리 하지 마. 자, 트럭 오기 전에 시작하자."},
			{"t": "work"},
			{"t": "say", "who": "rosa", "if": "rel_today", "text": "…어? 상자 수가 안 맞는데. 아침에 여섯 개 들어왔잖아."},
			{"t": "say", "who": "roy", "if": "rel_today", "text": "아, 아까 쥐가 상자 하나를 갉아 놨더라고. 안에 아무것도 없었어."},
			{"t": "say", "who": "rosa", "if": "rel_today", "text": "쥐가 포켓몬을 물고 갔다는 거야? …됐어. 보고서엔 그렇게 쓸게."},
			{"t": "say", "who": "rosa", "if": "!rel_today", "text": "첫날인데 손이 빠르네. 본사가 좋아하겠어."},
			{"t": "report"},
			{"t": "evening"},
			{"t": "say", "who": "narr", "text": "원룸 문 앞에 월세 고지서가 붙어 있었다. '금요일까지 15,000원.'"},
			{"t": "say", "who": "narr", "if": "rel:caterpie", "text": "잠들기 전에 쪽지에 적힌 이름이 자꾸 떠올랐다. 초록이는 상록숲까지 혼자 잘 찾아갔을까."},
			{"t": "say", "who": "narr", "if": "sent:caterpie", "text": "잠들기 전에 쪽지에 적힌 이름이 자꾸 떠올랐다. 민수라는 아이는 오늘 밤에도 숲에서 초록이를 부르고 있을까."},
		],
	},
	{
		"name": "화요일",
		"quota": 4,
		"risk_mult": 1.0,
		"rule": "아픈 포켓몬은 반품된다. 아픈 녀석은 트럭 말고 뒷문 폐기함으로. (폐기는 의심받지 않는다)",
		"crates": [
			{"key": "pidgey1", "id": 16, "name": "구구", "memo": "1번 도로에서 그물로 잡았다.", "item": "", "risk": 10},
			{"key": "jigglypuff", "id": 39, "name": "푸린", "memo": "달맞이산 입구에서 노래를 부르다가 잡혔다.", "item": "목이 잔뜩 쉬어 있다. 만져 보니 몸이 뜨겁다.", "risk": 10, "reject": true, "reveal": "푸린(열병)"},
			{"key": "spearow", "id": 21, "name": "깨비참", "memo": "3번 도로. 성질이 사나우니 손 조심.", "item": "", "risk": 10},
			{"key": "squirtle", "id": 7, "name": "꼬부기", "memo": "주인 없는 꼬부기 무리에서 떨어진 한 마리를 데려왔다.", "item": "까만 선글라스를 끼고 있다. 벗기려고 하면 운다.", "risk": 15, "named": true},
			{"key": "clefairy", "id": 35, "name": "삐삐", "memo": "달맞이산 아래 어느 할머니 집 창가에서 데려왔다.", "item": "손뜨개 목도리를 두르고 있다. 쉬지 않고 기침을 한다.", "risk": 20, "named": true, "reject": true, "reveal": "삐삐(감기)"},
			{"key": "oddish", "id": 43, "name": "뚜벅쵸", "memo": "24번 도로 풀숲에서 잡았다.", "item": "", "risk": 10},
		],
		"steps": [
			{"t": "title", "text": "화요일 · 반품"},
			{"t": "say", "who": "rosa", "text": "본사에서 공지 왔어. 어제 다른 창고에서 보낸 푸린이 병이 나서 반품됐대."},
			{"t": "say", "who": "rosa", "text": "그래서 오늘부터 아픈 포켓몬은 트럭에 싣지 말고 뒷문 폐기함에 넣으래. 반품되면 그만큼 일당에서 깎을 거래."},
			{"t": "say", "who": "roy", "text": "폐기함이라고 해도 별거 없어. 뒷문 옆에 있는 커다란 통이야."},
			{"t": "say", "who": "narr", "text": "나중에 보니 폐기함은 바닥이 뚫린 통이었다. 뚜껑을 열면 그냥 바깥 풀밭이었다."},
			{"t": "say", "who": "meowth", "text": "본사는 아픈 녀석을 치료해 줄 돈이 아깝다는 거다옹. 결국 풀어주라는 소리랑 같다옹."},
			{"t": "say", "who": "rosa", "if": "sent:growlithe", "text": "그리고 어제 그 가디 말이야. 상록시티 경찰서에서 경찰견을 찾는다는 전단을 붙였더라. 당분간 몸조심해."},
			{"t": "fx", "if": "sent:growlithe", "susp": 15},
			{"t": "say", "who": "roy", "if": "rel:growlithe", "text": "어제 그 가디, 아침에 경찰서 앞에 혼자 앉아 있는 걸 봤어. 알아서 잘 찾아갔더라."},
			{"t": "work"},
			{"t": "say", "who": "roy", "if": "sent:clefairy", "text": "삐삐가 반품됐다고? 기침하던 그 녀석 말이지…. 본사에서 돌아온 상자는 폐기함으로 가. 그나마 다행이네."},
			{"t": "say", "who": "rosa", "if": "rel:squirtle", "text": "선글라스 낀 꼬부기 봤어? 뒷문 밖에서 친구들이 데리러 왔더라. 다섯 마리가 전부 선글라스를 끼고 있었어."},
			{"t": "report"},
			{"t": "evening"},
			{"t": "say", "who": "narr", "if": "rel:clefairy", "text": "퇴근길에 달맞이산 쪽을 올려다봤다. 목도리를 두른 삐삐는 할머니 집까지 갈 수 있을까."},
		],
	},
	{
		"name": "수요일",
		"quota": 4,
		"risk_mult": 2.0,
		"rule": "감사관 아폴로가 와 있다. 오늘은 풀어주면 의심도가 두 배로 오른다.",
		"crates": [
			{"key": "magikarp", "id": 129, "name": "잉어킹", "memo": "갈색시티 항구에서 건졌다. 튀어 오르기만 한다.", "item": "", "risk": 10},
			{"key": "cubone", "id": 104, "name": "탕구리", "memo": "보라타운 외곽에서 혼자 울고 있던 것을 데려왔다.", "item": "뼈로 된 투구를 쓰고 있다. 벗기려고 하면 몹시 날뛴다.", "risk": 15, "named": true},
			{"key": "geodude", "id": 74, "name": "꼬마돌", "memo": "달맞이산 동굴 입구에서 잡았다.", "item": "", "risk": 10},
			{"key": "vulpix", "id": 37, "name": "식스테일", "memo": "어느 브리더의 집 마당에서 데려왔다.", "item": "브리더 협회 인증 목걸이를 차고 있다. 뒷면에 주인 연락처가 새겨져 있다.", "risk": 20, "named": true},
			{"key": "psyduck", "id": 54, "name": "고라파덕", "memo": "25번 도로. 계속 머리를 감싸 쥐고 있다.", "item": "아픈 건 아니다. 원래 그런 녀석이다.", "risk": 10},
			{"key": "abra", "id": 63, "name": "캐이시", "memo": "24번 도로에서 잠든 것을 그대로 들고 왔다.", "item": "계속 자고 있다. 그런데 상자를 열 때마다 안에서 자리가 조금씩 바뀌어 있다.", "risk": 10},
		],
		"steps": [
			{"t": "title", "text": "수요일 · 감사"},
			{"t": "say", "who": "rosa", "text": "오늘은 본사에서 감사관이 와. 아폴로 간부님이야."},
			{"t": "say", "who": "roy", "text": "그분 있는 동안에는 뒷문 근처에 얼씬도 하지 마. 뒤통수에도 눈이 달린 사람이야."},
			{"t": "say", "who": "apollo", "text": "네가 신입인가. 로사와 로이 밑으로 들어왔다니, 운이 없군."},
			{"t": "say", "who": "apollo", "text": "이 창고는 실적이 늘 바닥이다. 상자가 자꾸 비어서 올라오거든. 오늘은 내가 직접 지켜보겠다."},
			{"t": "say", "who": "apollo", "if": "sent:growlithe", "text": "그리고 요즘 경찰이 이 근처를 캐묻고 다닌다. 누가 경찰견을 건드린 모양이더군."},
			{"t": "work"},
			{"t": "say", "who": "narr", "text": "퇴근 직전, 뒷문 쪽에서 부스럭거리는 소리가 들렸다."},
			{"t": "say", "who": "narr", "text": "가 보니 로이가 자기 몫의 상자에서 꺼낸 발챙이를 연못 쪽으로 내보내고 있었다."},
			{"t": "say", "who": "roy", "text": "…봤구나."},
			{"t": "say", "who": "roy", "text": "이 창고 실적이 왜 늘 바닥인지 이제 알겠지. 로사도 나도 매일 몇 마리씩 이렇게 내보내."},
			{"t": "say", "who": "roy", "text": "아폴로 간부님한테 말해도 돼. 그럼 너는 제보 수당을 받고, 나는 아마 다른 창고로 쫓겨나겠지. 네가 정해."},
			{"t": "choice", "options": [
				{"text": "못 본 척한다", "flag": "covered_roy"},
				{"text": "아폴로에게 알린다 (제보 수당 2,000원)", "flag": "reported_roy"},
			]},
			{"t": "say", "who": "roy", "if": "covered_roy", "text": "…고마워. 내일 저녁은 내가 살게."},
			{"t": "say", "who": "apollo", "if": "reported_roy", "text": "로이가? 역시 그랬군. 수고했다, 신입. 제보 수당은 오늘 일당에 얹어 주지."},
			{"t": "fx", "if": "reported_roy", "money": 2000},
			{"t": "say", "who": "narr", "if": "reported_roy", "text": "로이는 그날 밤 짐을 싸서 무지개시티 창고로 옮겨 갔다. 로사는 퇴근할 때까지 나에게 한마디도 하지 않았다."},
			{"t": "say", "who": "apollo", "if": "susp>=40", "text": "그리고 신입, 뒷문 밖 풀밭에 발자국이 너무 많다. 벌금 3,000원이다. 다음번엔 벌금으로 끝나지 않아."},
			{"t": "fx", "if": "susp>=40", "money": -3000},
			{"t": "say", "who": "apollo", "if": "!susp>=40", "text": "흠. 오늘은 상자 수가 맞는군. 계속 이렇게 해라."},
			{"t": "report"},
			{"t": "evening"},
		],
	},
	{
		"name": "목요일",
		"quota": 4,
		"risk_mult": 1.0,
		"rule": "본사 특별 지시: 오박사 연구소에서 온 포켓몬은 한 마리당 수당 2,000원 추가.",
		"crates": [
			{"key": "machop", "id": 66, "name": "알통몬", "memo": "회색시티 체육관 뒤에서 혼자 수련하던 것을 잡았다.", "item": "", "risk": 10},
			{"key": "nidoran_f", "id": 29, "name": "니드런♀", "memo": "22번 도로. 두 마리가 같이 잡혔다.", "item": "옆 상자 쪽을 보며 계속 운다.", "risk": 15},
			{"key": "nidoran_m", "id": 32, "name": "니드런♂", "memo": "22번 도로. 두 마리가 같이 잡혔다.", "item": "옆 상자 쪽을 보며 계속 운다.", "risk": 15},
			{"key": "bulbasaur", "id": 1, "name": "이상해씨", "memo": "태초마을 오박사 연구소 뒷마당에서 데려왔다.", "item": "등에 '오박사 연구소 관리 번호 001' 스티커가 붙어 있다. 곧 새내기 트레이너에게 갈 녀석이었다.", "risk": 30, "named": true, "bonus": 2000},
			{"key": "slowpoke", "id": 79, "name": "야돈", "memo": "갈색시티 우물가에서 데려왔다. 잡혀 온 줄도 모르는 눈치다.", "item": "", "risk": 10},
			{"key": "meowth_stray", "id": 52, "name": "나옹", "memo": "무지개시티 골목의 떠돌이.", "item": "아침에 선배네 나옹이 이 상자 앞에 한참 서 있다가 갔다.", "risk": 15, "named": true},
		],
		"steps": [
			{"t": "title", "text": "목요일 · 특별 수당"},
			{"t": "say", "who": "rosa", "if": "sent:caterpie", "text": "신문 봤어? 상록숲에서 어떤 애가 사흘째 캐터피를 찾아다닌대. 이름이 초록이라나."},
			{"t": "say", "who": "rosa", "if": "sent:caterpie", "text": "…어디서 들어 본 이름 같지 않아?"},
			{"t": "say", "who": "rosa", "if": "rel:caterpie", "text": "신문 봤어? 상록숲에서 잃어버린 캐터피가 혼자 집에 돌아왔대. 주인 애가 좋아서 엉엉 울었다더라."},
			{"t": "say", "who": "rosa", "if": "rel:caterpie", "text": "희한한 일도 다 있지. …너 왜 웃어?"},
			{"t": "say", "who": "rosa", "text": "그리고 본사 특별 지시야. 태초마을 오박사 연구소에서 온 포켓몬은 한 마리당 수당을 2,000원 더 준대."},
			{"t": "say", "who": "roy", "if": "!reported_roy", "text": "연구소 포켓몬이면 새내기 트레이너들이 처음 받을 녀석들이잖아. …본사도 참 치사하다."},
			{"t": "say", "who": "meowth", "text": "2,000원이면 참치캔이 열 개다옹. 생각만 해도 침이 고인다옹."},
			{"t": "work"},
			{"t": "say", "who": "narr", "if": "pair_split", "text": "니드런 두 마리 중 한 마리만 트럭에 실렸다. 남은 녀석은 트럭이 떠날 때까지 울었다."},
			{"t": "say", "who": "meowth", "if": "rel:meowth_stray", "text": "…그 떠돌이 나옹, 무지개시티 골목에서 알던 녀석이다옹. 풀어줘서 고맙다옹."},
			{"t": "say", "who": "meowth", "if": "sent:meowth_stray", "text": "…그 떠돌이 나옹, 무지개시티 골목에서 알던 녀석이다옹. 일은 일이다옹. 알고 있다옹."},
			{"t": "report"},
			{"t": "evening"},
			{"t": "say", "who": "narr", "if": "!reported_roy", "text": "퇴근길에 로이가 정말로 밥을 샀다. 역 앞 포장마차였다."},
			{"t": "say", "who": "rosa", "if": "!reported_roy", "text": "우리가 왜 이러고 사는지 궁금하지?"},
			{"t": "say", "who": "rosa", "if": "!reported_roy", "text": "우리 엄마도 로켓단원이었어. 내가 어릴 때 임무를 나갔는데 그 뒤로 안 돌아왔어."},
			{"t": "say", "who": "rosa", "if": "!reported_roy", "text": "간부 자리까지 올라가면 옛날 임무 기록을 볼 수 있대. 그래서 버티는 거야. 포켓몬 훔치는 게 좋아서가 아니라."},
			{"t": "say", "who": "roy", "if": "!reported_roy", "text": "나는 집이 꽤 잘살았어. 그런데 부모님이 정해 놓은 사람이랑 결혼하라고 해서 도망쳐 나왔지."},
			{"t": "say", "who": "roy", "if": "!reported_roy", "text": "로켓단에 이름이 올라가 있으면 우리 집에서도 함부로 못 끌고 가. 나한텐 여기가 숨을 곳인 셈이야."},
			{"t": "say", "who": "meowth", "if": "!reported_roy", "text": "나는 옛날에 좋아하던 나옹한테 잘 보이려고 사람 말을 배웠다옹. 그랬더니 사람 흉내 내는 녀석은 싫다고 차였다옹."},
			{"t": "say", "who": "meowth", "if": "!reported_roy", "text": "그 뒤로 이 둘을 따라다닌다옹. 둘 다 나만큼 한심해서 마음이 편하다옹."},
			{"t": "say", "who": "rosa", "if": "!reported_roy", "text": "…그러니까 너는 우리처럼 되지 마. 월세 모이면 다른 일 찾아."},
			{"t": "say", "who": "narr", "if": "reported_roy", "text": "퇴근길에 보니 역 앞 포장마차에 로사가 혼자 앉아 있었다. 나를 보고도 모른 척했다."},
			{"t": "say", "who": "meowth", "if": "reported_roy", "text": "로이는 무지개시티 창고로 갔다옹. 거기는 여기보다 훨씬 춥다옹."},
			{"t": "say", "who": "meowth", "if": "reported_roy", "text": "…너를 탓하려는 건 아니다옹. 월세가 급했던 것도 안다옹."},
		],
	},
	{
		"name": "금요일",
		"quota": 5,
		"risk_mult": 1.0,
		"rule": "주말 대형 이송. 오늘 할당량은 5마리. 저녁에 월세 15,000원 마감.",
		"crates": [
			{"key": "diglett", "id": 50, "name": "디그다", "memo": "디그다굴에서 파냈다. 파내는 데 반나절이 걸렸다.", "item": "", "risk": 10},
			{"key": "chansey", "id": 113, "name": "럭키", "memo": "사파리존 관리소 근처에서 데려왔다.", "item": "알을 품고 있다. 알을 떼어 놓으려고 하면 아무것도 먹지 않는다.", "risk": 20, "named": true},
			{"key": "ditto", "id": 25, "name": "피카츄?", "memo": "무인발전소. 월요일에 들어온 피카츄와 생김새가 조금 다르다.", "item": "눈이 점 두 개처럼 생겼다. 가끔 몸이 흐물거린다.", "risk": 10, "reject": true, "reveal": "메타몽"},
			{"key": "dratini", "id": 147, "name": "미뇽", "memo": "사파리존 연못에서 건졌다. 보기 드문 개체.", "item": "본사가 특히 반길 것이다.", "risk": 20},
			{"key": "lapras", "id": 131, "name": "라프라스", "memo": "실프주식회사 빌딩에서 빼돌렸다.", "item": "사람을 등에 태우던 버릇이 남아 있다. 상자 안에서 노래를 흥얼거린다.", "risk": 25, "named": true},
			{"key": "rattata2", "id": 19, "name": "꼬렛", "memo": "또 22번 도로 풀숲.", "item": "", "risk": 10},
			{"key": "oddish2", "id": 43, "name": "뚜벅쵸", "memo": "24번 도로 풀숲.", "item": "", "risk": 10},
		],
		"steps": [
			{"t": "title", "text": "금요일 · 월세 마감"},
			{"t": "say", "who": "rosa", "text": "오늘은 주말 대형 이송이야. 할당량은 다섯 마리고, 본사 트럭이 두 대 와."},
			{"t": "say", "who": "roy", "if": "!reported_roy", "text": "오늘 저녁이 월세 마감이라며. 무리하진 마. 조금 모자라면 우리가 보태 줄 수 있어."},
			{"t": "say", "who": "meowth", "text": "오늘 라프라스가 들어온다는 소문이 있다옹. 실프주식회사에서 빼돌린 녀석이라옹."},
			{"t": "work"},
			{"t": "say", "who": "rosa", "if": "sent:ditto", "text": "피카츄가 본사에서 메타몽으로 변해 버렸대. 반품이야. …너 그거 몰랐어?"},
			{"t": "say", "who": "roy", "if": ["rel:lapras", "!reported_roy"], "text": "라프라스를 풀어줬구나. 강까지 노래하면서 가더라. 오늘 들은 것 중에 제일 좋은 소리였어."},
			{"t": "report"},
			{"t": "evening"},
			{"t": "rent"},
			{"t": "ending"},
		],
	},
]
