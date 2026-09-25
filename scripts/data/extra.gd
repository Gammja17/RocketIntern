extends RefCounted
## 인물 · 토요일 장소 · 게임코너 경품 · 백화점 물건 · 뒷문 풀밭.

## 말하는 사람: 이름, 초상(trainers/ 파일 이름, 또는 pokemon:번호, 또는 crop:로사/로이), 무대 그림.
const PEOPLE := {
	"rosa": {"name": "로사", "portrait": "crop:rosa", "stage": "teamrocket"},
	"roy": {"name": "로이", "portrait": "crop:roy", "stage": "teamrocket"},
	"meowth": {"name": "나옹", "portrait": "pokemon:52", "stage": "teamrocket"},
	"apollo": {"name": "아폴로", "portrait": "archer", "stage": "archer"},
	"boss": {"name": "비주기", "portrait": "giovanni", "stage": "giovanni"},
	"sena": {"name": "세나", "portrait": "rocketgruntf", "stage": "rocketgruntf"},
	"butler": {"name": "집사", "portrait": "gentleman", "stage": "gentleman"},
	"bella": {"name": "벨라", "portrait": "lady", "stage": "lady"},
	"officer": {"name": "순경", "portrait": "policeman", "stage": "policeman"},
	"minsu": {"name": "민수", "portrait": "bugcatcher", "stage": "bugcatcher"},
	"hana": {"name": "하나", "portrait": "lass", "stage": "lass"},
	"oak": {"name": "오박사", "portrait": "oak", "stage": "oak"},
	"clerk": {"name": "경품 교환소 직원", "portrait": "scientist", "stage": "scientist"},
	"me": {"name": "나"},
	"narr": {},
	"news": {},
}

## 토요일에 갈 수 있는 곳. steps 는 주차별(1~3)이고, 없는 주차는 common 을 쓴다.
const PLACES := [
	{"key": "gamecorner", "text": "무지개시티 게임코너", "steps": [
		{"t": "bg", "name": "gamecorner"},
		{"t": "bgm", "name": "gamecorner"},
		{"t": "say", "who": "narr", "text": "게임코너는 담배 연기와 슬롯머신 소리로 가득했다. 경품 교환소 진열장에는 몬스터볼이 줄지어 놓여 있었다."},
		{"t": "say", "who": "narr", "if": "covered_rosa", "text": "구석 포스터 뒤에서 로켓단 옷을 입은 남자가 나왔다. 로사가 말한 지하 아지트 입구가 저기일 것이다."},
		{"t": "slots"},
		{"t": "prizes"},
	]},
	{"key": "stall", "text": "역 앞 포장마차 (선배들과 저녁)", "if": "!reported_roy", "steps": [
		{"t": "bg", "name": "stall"},
		{"t": "bgm", "name": "center"},
		{"t": "say", "who": "narr", "text": "포장마차 비닐 천막 안은 따뜻했다. 선배들은 벌써 어묵 국물을 두 그릇째 비우고 있었다."},
		{"t": "say", "who": "meowth", "if": "week==1", "text": "나옹은 어묵 꼬치를 세 개까지만 먹는다옹. 네 개부터는 로이 지갑이 운다옹."},
		{"t": "say", "who": "roy", "if": "week==1", "text": "우리 둘이 처음 만난 것도 이런 포장마차였어. 둘 다 로켓단 입단 시험에서 떨어진 날이었지. 다음 해에 같이 붙었어."},
		{"t": "say", "who": "rosa", "if": "week==2", "text": "기록실에 가 보면 뭐가 달라질까. 엄마가 왜 안 돌아왔는지 알게 되면, 난 그다음엔 뭘 하지?"},
		{"t": "say", "who": "rosa", "if": ["week==3", "showed_arbok"], "text": "아보크가 요즘 밤마다 북쪽을 보고 울어. 엄마가 있는 쪽이겠지."},
		{"t": "say", "who": "rosa", "if": ["week==3", "!showed_arbok"], "text": "요즘은 기록실 생각도 잘 안 나. 그냥 오늘 하루 버티는 거지 뭐."},
		{"t": "say", "who": "roy", "if": ["week==3", "!roy_gone"], "text": "집을 나오고 처음으로 누가 나를 숨겨 줬어. 이상하지. 로켓단에서 그런 걸 받을 줄은 몰랐어."},
		{"t": "say", "who": "meowth", "if": ["week==3", "roy_gone"], "text": "로이 자리가 비었다옹. 어묵이 남는다옹. …하나도 안 기쁘다옹."},
		{"t": "fx", "trust": {"rosa": 1, "roy": 1, "meowth": 1}},
	]},
	{"key": "shop", "text": "무지개시티 백화점 (원룸 물건)", "steps": [
		{"t": "bg", "name": "city"},
		{"t": "bgm", "name": "celadon"},
		{"t": "say", "who": "narr", "text": "무지개시티 백화점은 사람으로 북적였다. 5층 생활용품 코너에 들렀다."},
		{"t": "shop"},
	]},
	{"key": "forest", "text": "상록숲 산책", "steps": [
		{"t": "bg", "name": "forest"},
		{"t": "bgm", "name": "pallet"},
		{"t": "say", "who": "narr", "text": "상록숲은 창고에서 걸어서 삼십 분 거리다. 나무 사이로 햇빛이 조각조각 떨어졌다."},
		{"t": "say", "who": "minsu", "if": "rel:caterpie", "text": "형도 벌레 잡으러 왔어요? 얘는 초록이예요! 한번 잃어버렸는데 혼자 집에 찾아왔어요. 대단하죠?"},
		{"t": "say", "who": "narr", "if": "rel:caterpie", "text": "민수 어깨 위의 캐터피가 나를 빤히 보았다. 기억하는 걸까. 설마."},
		{"t": "say", "who": "minsu", "if": ["sent:caterpie", "!bought_butterfree"], "text": "초록아! 초록아…! 아, 죄송해요. 혹시 캐터피 못 보셨어요? 초록색이고요, 이만해요."},
		{"t": "say", "who": "minsu", "if": ["sent:caterpie", "!bought_butterfree"], "text": "매일 여기서 불러요. 초록이는 제 목소리를 알거든요. 언젠가는 대답할 거예요."},
		{"t": "say", "who": "minsu", "if": "bought_butterfree", "text": "형! 초록이가 버터플이 돼서 돌아왔어요! 제가 쓴 쪽지도 그대로 달고요! 누가 보냈는지는 몰라요."},
		{"t": "say", "who": "narr", "if": ["!rel:caterpie", "!sent:caterpie"], "text": "숲은 조용했다. 잠깐이나마 창고 일을 잊을 수 있었다."},
	]},
	{"key": "visit", "text": "돌려보낸 포켓몬의 집 찾아가 보기", "if": "returned>=1", "steps": [
		{"t": "bg", "name": "city"},
		{"t": "bgm", "name": "celadon"},
		{"t": "visits"},
	]},
]

## 돌려보낸 뒤 토요일에 찾아가면 보이는 장면.
const VISITS := {
	"magnemite": "갈색시티 발전소 사택 창문 너머로, 코일 한 마리가 전구 옆에 붙어서 불을 밝히고 있었다. 찌릿이였다.",
	"pikachu2": "무인발전소 경비원 숙소 앞마당에서 여자아이가 피카츄를 안고 빙글빙글 돌고 있었다. 반창고는 새것으로 바뀌어 있었다.",
	"hitmonlee": "격투도장 마당에서 시라소몬이 관장과 대련을 하고 있었다. 관장은 발차기를 맞고도 웃었다.",
	"chansey2": "보라타운 포켓몬하우스 앞에서 할아버지가 럭키에게 알을 받아 들고 있었다. 할아버지는 그 알을 다시 럭키에게 돌려주었다.",
	"vaporeon": "무지개시티 하나네 집 마당 물통 속에서 샤미드가 헤엄치고 있었다. 하나는 물에 젖은 분홍 리본을 햇볕에 말리고 있었다.",
	"roy_dog": "상록시티 외곽 저택 대문 앞에서 가디 여섯 마리가 나란히 엎드려 길 쪽을 보고 있었다. 맨 앞의 대장은 금목걸이를 하고 있었다.",
	"clefairy3": "갈색시티 팬클럽 회관 창문 너머로, 회장님이 삐삐를 무릎에 앉혀 놓고 누군가에게 쉬지 않고 이야기하고 있었다.",
	"farfetchd": "갈색시티 어느 집 마당에서 파오리가 대파로 할머니 어깨를 두드려 주고 있었다.",
	"jigglypuff3": "실프 사원 기숙사 로비에서 푸린이 노래를 불렀다. 사원들은 전부 잠들었다.",
}

## 게임코너 경품. 사면 돌려보낸 것과 같이 취급한다.
const PRIZES := [
	{"key": "butterfree", "text": "버터플 (4,000원)", "cost": 4000, "if": ["sent:caterpie", "!bought_butterfree", "week>=2"], "steps": [
		{"t": "say", "who": "narr", "text": "진열장 속 버터플의 목에 낡은 쪽지가 매달려 있었다. '제 첫 포켓몬이에요. 이름은 초록이에요. 돌려주세요. 민수'"},
		{"t": "say", "who": "narr", "text": "본사는 초록이를 진화시켜 경품으로 내놓은 것이다. 쪽지를 떼는 것조차 귀찮았던 모양이다."},
		{"t": "say", "who": "clerk", "text": "버터플 교환이요? 손님, 이거 인기 경품인데. 좋은 거 고르셨네요."},
		{"t": "say", "who": "narr", "text": "그날 오후 상록숲 민수 앞으로 소포를 부쳤다. 보낸 사람 칸은 비워 두었다."},
	]},
	{"key": "meowzie", "text": "나옹 (3,000원)", "cost": 3000, "if": ["sent:meowth_stray", "!bought_meowzie", "week>=2"], "steps": [
		{"t": "say", "who": "narr", "text": "진열장 구석에 떠돌이 나옹이 있었다. 1주차 목요일, 선배네 나옹이 상자 앞에서 한참 서 있던 그 녀석이었다."},
		{"t": "say", "who": "narr", "text": "교환한 나옹을 무지개시티 골목에 풀어 주었다. 녀석은 한 번 뒤돌아보고 골목 안으로 사라졌다."},
		{"t": "say", "who": "meowth", "text": "…누가 그 녀석을 골목에 데려다 놨다는 소문을 들었다옹. 너지? 대답 안 해도 된다옹. 고맙다옹."},
		{"t": "fx", "trust": {"meowth": 2}},
	]},
	{"key": "vulpix", "text": "식스테일 (3,000원)", "cost": 3000, "if": ["sent:vulpix", "!bought_vulpix", "week>=3"], "steps": [
		{"t": "say", "who": "narr", "text": "브리더 협회 목걸이를 찬 식스테일이 진열장에 있었다. 목걸이 뒷면의 연락처는 그대로였다."},
		{"t": "say", "who": "narr", "text": "교환해서 목걸이에 적힌 주소로 보냈다. 이번에는 보낸 사람 칸에 '로켓단 창고 직원 일동'이라고 적었다가, 지웠다."},
	]},
]

## 백화점 물건. 저녁에 원룸에 있으면 한 줄씩 나온다. 라디오는 다음 날 지침을 미리 알려 준다.
const ITEMS := [
	{"key": "stove", "text": "작은 난로 (3,000원)", "cost": 3000, "line": "난로가 방을 데웠다. 오늘 밤은 발이 덜 시렸다."},
	{"key": "radio", "text": "중고 라디오 (2,000원)", "cost": 2000, "line": ""},
	{"key": "plant", "text": "창가 화분 (1,000원)", "cost": 1000, "line": "창가 화분에 새잎이 하나 났다. 물을 주고 불을 껐다."},
	{"key": "frame", "text": "사진 액자 (2,000원)", "cost": 2000, "line": "액자 속 가족사진을 봤다. 아버지는 사진 속에서도 웃지 않는다. 그래도 사진을 찍던 날은 옆에 서 있었다."},
	{"key": "shelf", "text": "작은 선반 (1,500원)", "cost": 1500, "line": "빈 몬스터볼을 새 선반 한가운데 올려 두었다. 언젠가 채울 자리다."},
]

## 뒷문 풀밭을 떠날 때의 한 줄.
const MEADOW_LEAVE := {
	"cubone": "탕구리가 풀밭을 떠났다. 보라타운 쪽으로 걸어갔다. 엄마가 있는 곳이었다.",
	"abra": "캐이시가 사라졌다. 순간이동을 한 모양이다. 먹이 그릇만 남았다.",
	"meowth_stray": "떠돌이 나옹이 풀밭을 떠났다. 무지개시티 골목 쪽이었다.",
	"nidoran_f": "니드런♀이 떠났다. 22번 도로 쪽으로, 짝을 찾으러.",
	"nidoran_m": "니드런♂이 떠났다. 22번 도로 쪽으로, 짝을 찾으러.",
	"cubone2": "탕구리가 풀밭을 떠났다. 보라타운 쪽으로 걸어갔다.",
}
