extends RefCounted
## 도전 과제. 웹판은 SKEAM.unlock(id), exe판은 code 를 화면에 보여 주고 플레이어가 라이브러리에 입력한다.
## end 가 있는 과제는 그 결말 제목이 뜰 때 달성된다.

const LIST := [
	{"id": "first_day", "code": "RKT-C474", "name": "첫 출근", "desc": "1주차 월요일을 마친다."},
	{"id": "back_door", "code": "RKT-4C0B", "name": "뒷문", "desc": "처음으로 포켓몬을 뒷문으로 풀어준다."},
	{"id": "no_sender", "code": "RKT-2B8D", "name": "보낸 사람 칸은 비워 두고", "desc": "처음으로 포켓몬을 주인에게 돌려보낸다."},
	{"id": "ribbon", "code": "RKT-F85C", "name": "분홍 리본", "desc": "솜이를 집으로 돌려보낸다."},
	{"id": "prize_case", "code": "RKT-D4F2", "name": "경품 진열장", "desc": "게임코너 진열장에서 초록이를 되찾는다."},
	{"id": "m04", "code": "RKT-B402", "name": "M-04", "desc": "아보크를 로사에게 보여 준다."},
	{"id": "empty_attic", "code": "RKT-CF73", "name": "다락은 비어 있다", "desc": "로이를 끝까지 숨겨 준다."},
	{"id": "same_month", "code": "RKT-13E5", "name": "같은 달 입사", "desc": "세나와 가까워진다."},
	{"id": "meadow_debt", "code": "RKT-0964", "name": "풀밭의 은혜", "desc": "뒷문 풀밭에서 돌본 포켓몬에게 도움을 받는다."},
	{"id": "jackpot", "code": "RKT-98BD", "name": "7 7 7", "desc": "게임코너 슬롯에서 잭팟을 터뜨린다."},
	{"id": "my_room", "code": "RKT-52C3", "name": "내 방", "desc": "백화점에서 원룸 물건 다섯 개를 전부 산다."},
	{"id": "last_warning", "code": "RKT-B75E", "name": "마지막 경고", "desc": "아폴로에게 마지막 경고를 받는다."},
	{"id": "adopted", "code": "RKT-6A1E", "name": "한 식구", "desc": "뒷문 풀밭의 포켓몬을 원룸에 데려간다."},
	{"id": "battle_win", "code": "RKT-3D90", "name": "지급품의 반란", "desc": "포켓몬 배틀에서 처음으로 이긴다."},
	{"id": "rival", "code": "RKT-E57B", "name": "옆집 애의 라이벌", "desc": "그린을 배틀에서 이긴다."},
	{"id": "end_rocket", "code": "RKT-35BD", "name": "안 읽는 게 편해", "desc": "아폴로를 따라 성도로 간다.", "end": "엔딩: 안 읽는 게 편해"},
	{"id": "end_records", "code": "RKT-2473", "name": "기록 상자", "desc": "기록 상자를 들고 경찰에게 간다.", "end": "엔딩: 기록 상자"},
	{"id": "end_truck", "code": "RKT-CAA8", "name": "마지막 트럭", "desc": "선배들과 마지막 트럭을 몰고 나간다.", "end": "엔딩: 마지막 트럭"},
	{"id": "end_first", "code": "RKT-4B75", "name": "첫 포켓몬", "desc": "관리 번호 001과 다시 만난다.", "end": "엔딩: 첫 포켓몬"},
	{"id": "end_turn", "code": "RKT-CB2D", "name": "돌아온 차례", "desc": "누군가 돌려준 이상해씨를 받는다.", "end": "엔딩: 돌아온 차례"},
	{"id": "end_empty", "code": "RKT-B10D", "name": "빈 몬스터볼", "desc": "빈 몬스터볼을 들고 고향으로 돌아간다.", "end": "엔딩: 빈 몬스터볼"},
	{"id": "end_fired", "code": "RKT-2979", "name": "뒷문으로 나간 사람", "desc": "로켓단에서 해고된다.", "end": "엔딩: 뒷문으로 나간 사람"},
	{"id": "end_deal", "code": "RKT-91C4", "name": "거래", "desc": "기록 상자로 형량을 산다.", "end": "엔딩: 거래"},
	{"id": "end_cuffed", "code": "RKT-5F28", "name": "수갑", "desc": "검수 기록의 서명 때문에 체포된다.", "end": "엔딩: 수갑"},
	{"id": "end_locked", "code": "RKT-89E7", "name": "잠긴 창고", "desc": "월세를 못 내고 갈 곳을 잃는다.", "end": "엔딩: 잠긴 창고"},
]
