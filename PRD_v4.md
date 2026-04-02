# ISO-Weather PRD v4.0 — Claude Code 개발용

**프로젝트명:** ISO-Weather
**한글명:** 아이소웨더 (앱스토어 표시명 별도 결정)
**작성일:** 2026.03.31
**최종 수정일:** 2026.04.02
**목적:** Claude Code CLI를 통한 Flutter 기반 모바일 날씨 앱 개발

---

## 1. 제품 비전

### 핵심 컨셉
각 도시의 아이코닉한 건축물과 풍경을 **등축(Isometric) 3D 렌더링 미니어처** 이미지로 표현하는 감성 날씨 앱. 사전 생성된 도시별 이미지가 실제 날씨·계절·시간대에 따라 자동으로 전환되며, 날씨에 맞는 옷차림을 추천한다.

### 핵심 차별점
- 도시별 아이소메트릭 미니어처 아트 (AI 이미지 생성으로 사전 제작)
- 계절 x 날씨 x 낮밤에 따라 달라지는 배경 이미지
- 선택적 날씨 파티클 애니메이션 (눈, 비 등)
- 수치 나열이 아닌, 직관적 옷차림 텍스트 추천

### 타겟 사용자
- 감각적 디자인을 선호하는 20~40대
- "오늘 뭐 입지?" 고민하는 사용자
- 수치보다 직관적 조언을 원하는 사용자

---

## 2. 기술 스택

| 영역 | 기술 | 선정 이유 |
|------|------|---------|
| 프레임워크 | **Flutter (Dart)** | iOS/Android 크로스플랫폼, 60fps 애니메이션, Skia 렌더링 |
| 날씨 API | **OpenWeatherMap One Call API 3.0** | 한국어 지원, 무료 1,000건/일, 체감온도·습도·풍속·일출일몰 포함 |
| 옷차림 로직 | **사전 정의 JSON (clothing_logic.json)** | 오프라인 작동, 0.1초 이내 응답, API 비용 없음 |
| 이미지 생성 | **Google Gemini API (Nano Banana Pro 2)** | Claude Code에서 스크립트로 자동 생성, 개발 파이프라인 통합 |
| 날씨 애니메이션 | **Flutter CustomPainter + 파티클 시스템** | 경량, 네이티브 성능 |
| 로컬 저장 | **shared_preferences + Hive** | 설정값 및 날씨 캐시 |
| 상태 관리 | **Riverpod** | 간결하고 테스트 용이 |

---

## 3. 이미지 에셋 시스템 (핵심 기능)

### 3.1 이미지 분류 체계

각 도시별로 다음 조합의 이미지를 사전 생성하여 `assets/images/cities/`에 내장한다.

**분류 축:**

| 축 | 값 | 설명 |
|------|------|------|
| 도시 | seoul, tokyo, beijing, shanghai, newyork, sydney, paris, london, berlin, madrid, barcelona | 11개 도시 |
| 계절 | spring, summer, autumn, winter | 날짜 기반 자동 판별 |
| 시간대 | day, night | 일출/일몰 시간 기준 판별 |
| 날씨 | clear, cloudy, rain, snow, fog | API 날씨 코드 매핑 |

**파일 네이밍 규칙:**
```
{city}_{season}_{time}_{weather}.webp
```

**예시:**
```
seoul_spring_day_clear.webp     → 서울, 봄, 낮, 맑음
seoul_winter_night_snow.webp    → 서울, 겨울, 밤, 눈
tokyo_autumn_day_cloudy.webp    → 도쿄, 가을, 낮, 흐림
```

### 3.2 이미지 수량 계산

전체 11개 도시 기준:
- 11 도시 x 4 계절 x 2 시간대 x 5 날씨 = **440장** (전량 생성 완료)

**참고:** 모든 조합을 커버하기 어려울 경우 fallback 이미지 사용. 예를 들어, 봄+눈 조합이 없으면 `winter_day_snow` 이미지로 대체하는 로직 구현.

### 3.3 이미지 선택 알고리즘

**입력:** 도시, 현재 날짜, 현재 시각, 일출/일몰 시각, API 날씨 코드

1. 계절 판별
   - 3~5월: spring
   - 6~8월: summer
   - 9~11월: autumn
   - 12~2월: winter

2. 시간대 판별
   - 일출 ~ 일몰: day
   - 그 외: night

3. 날씨 매핑 (OpenWeatherMap 코드 → 앱 내 카테고리)
   - 200~232 (Thunderstorm) → rain
   - 300~321 (Drizzle) → rain
   - 500~531 (Rain) → rain
   - 600~622 (Snow) → snow
   - 701~781 (Atmosphere: 안개/연무 등) → fog
   - 800 (Clear) → clear
   - 801~804 (Clouds) → cloudy

4. 이미지 파일 경로 조합
   `path = "assets/images/cities/{city}_{season}_{time}_{weather}.webp"`

5. Fallback 체인
   1차: 정확한 조합 파일 검색
   2차: 같은 도시 + 같은 계절 + 같은 시간대 + clear (기본 날씨)
   3차: 같은 도시 + 같은 계절 + day + clear
   4차: 같은 도시 + spring_day_clear (최종 fallback)

### 3.4 이미지 전환 애니메이션

날씨나 시간대 변경으로 이미지가 바뀔 때:
- **CrossFade 애니메이션** (800ms, ease-in-out)
- 이전 이미지가 서서히 사라지고 새 이미지가 나타남
- 앱 최초 로딩 시에도 fade-in 적용

### 3.5 이미지 사양

| 항목 | 사양 |
|------|------|
| 포맷 | WebP (압축 효율) |
| 해상도 | 1320 x 2868 px (iPhone 17 Pro Max 대응, EDSR 2x 업스케일) |
| 파일 크기 | 장당 150KB~250KB |
| 배경 | 어두운 남색(밤) 또는 밝은 하늘색(낮) — 시간대별 단색 배경 |
| 구도 | 아이소메트릭 45도 탑다운 뷰, 이미지 중앙~중하단 배치 |
| 받침대 | 얇은 둥근 판 (paper-thin edge) |

### 3.6 이미지 생성 파이프라인 (완료)

> **Status: 전체 11개 도시 440장 생성 완료 (2026-04-02)**

**모델 & API:**
- **모델:** Nano Banana Pro 2 (`nano-banana-pro-preview`) — Gemini `generateContent` API 사용
- **비율 지정:** `image_config=types.ImageConfig(aspect_ratio="9:16")`
- **업스케일:** EDSR AI x2 (`super_image` 패키지, `eugenesiow/edsr-base`)
- **최종 해상도:** 1320x2868 px

**3단계 프로세스:**
1. **Phase 1 — 기본 이미지 생성:** 도시별 1장 (봄/낮/맑음), 원본 PNG로 보관 (`assets/images/base/`)
2. **Phase 2 — 변형 이미지 생성:** 기본 이미지를 레퍼런스로 제출 → 계절/시간대/날씨만 변경 요청 (도시 레이아웃 일관성 유지)
3. **Phase 3 — 후처리:** 배경 아티팩트 정리 → EDSR AI 2x 업스케일 → 최종 리사이즈 → UnsharpMask 샤프닝 → 품질 검증 → WebP 저장 (quality 90)

**배경 아티팩트 정리 로직:**
- AI 모델이 배경에 건물 잔상/반사를 생성 → EDSR이 증폭하는 이슈 발생
- 해결: 행별 콘텐츠 밀도 분석 → >15% 행의 가장 큰 연속 블록 = 디오라마 본체 → 본체 외부를 순수 배경색으로 교체
- 상단 마진 30% (탑 꼭대기), 하단 마진 3% (그림자)
- 업스케일 전/후 2회 정리 + 최종 품질 검증 루프

**스크립트:** `scripts/generate_city_images.py`
- 옵션: `--city <id>`, `--dry-run`, `--retry-failed`, `--skip-base`
- 이미 존재하는 파일은 자동 스킵

---

## 4. 화면 구성

### 4.1 메인 화면 (단일 스크린 앱)

**레이아웃 (위→아래):**
```
┌─────────────────────────────┐
│  [오프라인 배너]    [⚙ 설정]  │  ← 상단 바
│                             │
│       서울특별시              │  ← 도시명 (Bold, 큰 텍스트)
│       2026.03.31            │  ← 날짜
│         12°C                │  ← 현재 기온 (가장 큰 텍스트)
│                             │
│    ┌───────────────┐        │
│    │  [아이소메트릭 도시  │  │
│    │   미니어처 이미지]  │  │  ← 화면 중앙, 최대 면적
│    │                │  │
│    │ + 날씨 파티클 오버레이│  │  ← 눈/비 애니메이션 (선택적)
│    │                │  │
│    └───────────────┘        │
│                             │
│ ┌─────────────────────────┐ │
│ │ 겨울바람이 차갑습니다.    │ │  ← 옷차림 추천 텍스트
│ │ 따뜻한 코트와 니트 조합이│ │       반투명 배경 카드
│ │ 좋겠어요.                │ │
│ └─────────────────────────┘ │
│                             │
└─────────────────────────────┘
```

**UI 상세 스펙:**

| 요소 | 스타일 |
|------|--------|
| 배경 | 풀스크린 도시 이미지 (화면 전체를 덮음) |
| 도시명 | 흰색, Bold, 24~28sp |
| 날짜 | 흰색 70% opacity, Regular, 14sp |
| 기온 | 흰색, Bold, 64~72sp |
| 추천 카드 | 반투명 흰색(밤: 반투명 검정) 배경, 둥근 모서리(16dp), 내부 패딩 16dp |
| 추천 텍스트 | 흰색(밤) 또는 검정(낮), Regular, 16sp, 중앙 정렬 |
| 설정 아이콘 | 우측 상단, 흰색 톱니바퀴, 44x44dp 터치 영역 |
| 오프라인 배너 | 좌측 상단, 인터넷 끊김 시에만 표시, "Offline Mode (HH:mm)" |

### 4.2 설정 화면

| 항목 | 컨트롤 | 설명 |
|------|--------|------|
| 온도 단위 | 토글 (°C / °F) | 기본값: °C |
| 도시 선택 | 리스트 / 검색 | 지원 도시 목록에서 선택 |
| 현재 위치 사용 | 토글 ON/OFF | GPS 기반 자동 도시 판별 |
| 알림 | 토글 ON/OFF | 매일 아침 옷차림 알림 |
| 알림 시간 | 시간 선택기 | 기본값: 07:00 |
| 날씨 애니메이션 | 토글 ON/OFF | 파티클 ON/OFF |
| 앱 정보 | - | 버전, 크레딧 |

### 4.3 Pull-to-Refresh
- 메인 화면에서 아래로 당기면 날씨 데이터 새로고침
- 새로고침 중 로딩 인디케이터 표시
- 이미지도 새 날씨에 맞게 전환

---

## 5. 옷차림 추천 시스템

### 5.1 입력 변수

| 변수 | 소스 | 구간 |
|------|------|------|
| 체감온도 | API `feels_like` | -10 이하 / -10~-5 / -5~0 / 0~5 / 5~10 / 10~15 / 15~20 / 20~25 / 25~30 / 30 이상 |
| 풍속 | API `wind_speed` | low(<3m/s) / normal(3~8m/s) / high(>8m/s) |
| 습도 | API `humidity` | low(<40%) / normal(40~70%) / high(>70%) |
| 날씨 상태 | API `weather.id` | clear / cloudy / rain / snow / fog |
| 자외선 지수 | API `uvi` | low(0~2) / moderate(3~5) / high(6~7) / very_high(8+) |

### 5.2 clothing_logic.json 구조

```json
{
  "meta": {
    "version": "3.0",
    "updated": "2026-03-31"
  },
  "cases": [
    {
      "id": "freezing_snow",
      "priority": 1,
      "conditions": {
        "temp_range": "below_minus_10",
        "weather": ["snow"],
        "wind": ["any"],
        "humidity": ["any"]
      },
      "messages": [
        "한파와 폭설이 예상됩니다. 패딩, 목도리, 장갑은 필수예요.",
        "매서운 추위에 눈까지! 두꺼운 패딩에 방한 용품을 챙기세요.",
        "극강 한파입니다. 롱패딩에 목도리, 귀마개까지 완전 무장하세요."
      ],
      "items": ["롱패딩", "히트텍", "목도리", "장갑", "방한 부츠"]
    }
  ]
}
```

### 5.3 매칭 알고리즘

1. 현재 날씨 데이터로 각 변수의 구간 판별
2. `clothing_logic.json`에서 조건이 일치하는 case 필터링
   - "any"는 모든 값과 매칭
   - 배열 값은 OR 조건 (하나라도 일치하면 매칭)
3. 매칭된 case가 여러 개면 priority가 낮은 것(=높은 우선순위) 선택
4. 선택된 case의 messages 배열에서 랜덤으로 1개 선택하여 표시
5. 매칭 없으면 기본 메시지: "오늘 하루도 좋은 하루 보내세요!"

**Priority 가이드:**
- 1: 특수 기상 (한파, 폭염, 태풍, 미세먼지)
- 2: 복합 조건 (비+강풍, 눈+한파)
- 3: 일반 날씨

---

## 6. 날씨 파티클 애니메이션 (선택적 기능)

> 구현 원칙: 자연스럽고 부드러운 퀄리티가 확보될 때만 적용. 퀄리티가 낮으면 파티클 없이 이미지만 표시.

### 6.1 구현 대상

| 날씨 | 파티클 | 설명 |
|------|--------|------|
| 눈 (snow) | 흰색 원형 파티클 | 다양한 크기, 느리게 떨어지며 좌우로 흔들림 |
| 비 (rain) | 흰색 선형 파티클 | 일정 각도로 빠르게 떨어짐, 바람 방향 반영 |
| 안개 (fog) | 반투명 흰색 레이어 | 느리게 좌우로 이동하는 안개 효과 |
| 맑음/흐림 | 없음 | 파티클 없이 이미지만 표시 |

### 6.2 기술 구현
- **Flutter CustomPainter** 기반 파티클 시스템
- 파티클 수: 눈 50~100개, 비 100~200개
- 프레임레이트: 30fps 이상 유지 필수
- 이미지 위에 반투명 오버레이로 렌더링
- 기기 성능 감지하여 저사양에서는 파티클 수 자동 감소 또는 비활성화

---

## 7. 데이터 흐름

### 7.1 앱 실행 시 (App Launch Flow)
```
앱 실행
│
├─ GPS 권한 확인
│  ├─ 허용 → 현재 위치 획득 → 도시 판별
│  └─ 거부 → 마지막 저장된 도시 사용 (없으면 서울 기본)
│
├─ 캐시 확인
│  ├─ 30분 이내 캐시 있음 → 캐시 데이터 즉시 표시
│  └─ 캐시 없거나 만료 → API 호출
│
├─ API 호출 (OpenWeatherMap)
│  ├─ 성공 → 데이터 파싱 → 화면 갱신 + 캐시 저장
│  └─ 실패 → 캐시 데이터 표시 + 오프라인 배너
│
├─ 이미지 선택 (계절 + 시간대 + 날씨 → 파일 경로)
│
├─ 옷차림 추천 (체감온도 + 날씨 + 풍속 + 습도 → 메시지)
│
└─ 화면 렌더링 완료
```

### 7.2 API 응답 데이터 사용 필드
```json
{
  "current": {
    "temp": 12.5,
    "feels_like": 10.2,
    "humidity": 65,
    "wind_speed": 4.2,
    "uvi": 3,
    "weather": [
      {
        "id": 800,
        "description": "맑음"
      }
    ],
    "sunrise": 1711929600,
    "sunset": 1711973400
  }
}
```

---

## 8. 오프라인 모드

| 상황 | 동작 |
|------|------|
| 인터넷 있음 + 캐시 유효 (30분 이내) | 캐시 데이터 표시, 백그라운드 갱신 안 함 |
| 인터넷 있음 + 캐시 만료 | API 호출 → 갱신 |
| 인터넷 없음 + 캐시 있음 | 캐시 데이터 표시 + 상단 "Offline Mode (마지막 업데이트 시각)" 배너 |
| 인터넷 없음 + 캐시 없음 | 기본 이미지(서울, 봄, 낮, 맑음) + 안내 메시지 |

---

## 9. 프로젝트 구조

```
lib/
├── main.dart                    # 앱 진입점
├── app.dart                     # MaterialApp 설정
├── config/
│   ├── theme.dart               # 앱 테마 (색상, 폰트)
│   └── constants.dart           # API 키, 상수
├── models/
│   ├── weather_data.dart        # 날씨 데이터 모델
│   ├── city.dart                # 도시 모델
│   └── clothing_case.dart       # 옷차림 추천 모델
├── services/
│   ├── weather_service.dart     # OpenWeatherMap API 호출
│   ├── location_service.dart    # GPS 위치 서비스
│   ├── cache_service.dart       # 데이터 캐싱
│   ├── image_selector.dart      # 이미지 선택 로직
│   └── clothing_recommender.dart # 옷차림 추천 로직
├── providers/
│   ├── weather_provider.dart    # 날씨 상태 관리
│   └── settings_provider.dart   # 설정 상태 관리
├── screens/
│   ├── home_screen.dart         # 메인 화면
│   └── settings_screen.dart     # 설정 화면
├── widgets/
│   ├── weather_background.dart  # 배경 이미지 + 전환 애니메이션
│   ├── weather_info.dart        # 도시명, 날짜, 기온 표시
│   ├── clothing_card.dart       # 옷차림 추천 카드
│   ├── offline_banner.dart      # 오프라인 상태 배너
│   └── particle_overlay.dart    # 날씨 파티클 애니메이션
│
assets/
├── images/
│   ├── base/                    # 도시별 기본 이미지 (PNG 원본)
│   └── cities/                  # 최종 이미지 (WebP, 440장)
├── data/
│   └── clothing_logic.json      # 옷차림 추천 데이터
└── fonts/
    └── ...                      # 커스텀 폰트
```

---

## 10. 디자인 & 에이전트 팀 구성 전략

### 10.1 활용 Skill 목록

앱의 UI/UX 설계 및 구현 시 다음 skill들을 활용하여 프리미엄 품질을 확보한다:

| Skill | 활용 영역 | 적용 Step |
|-------|---------|---------|
| **frontend-design** | 화면 레이아웃 설계, 컴포넌트 구조, 색상/타이포 시스템 | Step 9, 11 |
| **superpowers:brainstorming** | 디자인 방향 탐색, UX 패턴 선정, 애니메이션 전략 | Step 9, 10, 11 |
| **supanova-taste-skill** | 프리미엄 디자인 기준 (컬러 팔레트, 간격 시스템, 그림자) | Step 9 |
| **supanova-soft-skill** | 카드 구조, 애니메이션 기준, 한국어 타이포그래피 | Step 9, 10 |
| **harness** | 에이전트 팀 구성, 병렬 개발 전략 | 전체 |

### 10.2 디자인 원칙 (Skill 기반)

1. **레이아웃**: frontend-design skill의 그리드/간격 시스템을 Flutter에 적용
   - 8dp 기본 그리드, 16dp 주요 간격
   - Safe Area 고려한 상하 패딩
   - 배경 이미지가 핵심이므로 UI 요소는 최소한으로 유지

2. **타이포그래피**: supanova-soft-skill의 한국어 타이포 기준 적용
   - 제목: Bold, 충분한 letter-spacing
   - 본문: Regular, 적절한 line-height (1.5~1.6)
   - 이미지 위 텍스트는 그림자(shadow) 추가로 가독성 확보

3. **색상 & 테마**: supanova-taste-skill의 프리미엄 색상 기준
   - 다크/라이트 자동 전환 (배경 이미지 시간대 연동)
   - 반투명 글래스모피즘 카드 (backdrop-filter 효과)
   - 고급스러운 색감 유지

4. **애니메이션**: supanova-soft-skill + brainstorming
   - 이미지 전환: CrossFade 800ms, ease-in-out
   - 파티클: 자연스러운 물리 시뮬레이션
   - 화면 진입: subtle fade-in + slide-up
   - 설정 화면: slide 트랜지션

### 10.3 에이전트 팀 구성 (Harness Skill)

harness skill을 활용하여 개발 단계별로 에이전트 팀을 구성할 수 있다:

**Pipeline 패턴 (순차 의존성이 있는 Step):**
- Step 1 (프로젝트 초기화) → Step 2 (데이터 모델) → Step 3 (API 서비스) → Step 8 (상태 관리)

**Fan-out/Fan-in 패턴 (독립적으로 병렬 가능한 Step):**
- Step 4 (위치 서비스) / Step 5 (이미지 선택) / Step 6 (옷차림 로직) / Step 7 (캐시 서비스)
  → 이 4개는 Step 2~3 완료 후 동시 진행 가능

**Expert Pool 패턴 (전문 영역):**
- UI Agent: Step 9 (메인 화면) + Step 11 (설정 화면) — frontend-design, supanova skill 활용
- Animation Agent: Step 10 (파티클) — brainstorming, supanova-soft-skill 활용
- Integration Agent: Step 12 (통합 테스트)

---

## 11. Claude Code 개발 Step-by-Step 프롬프트

> 각 Step을 순서대로 Claude Code에 입력하여 개발을 진행한다.
> Step 0은 완료되었으므로 Step 1부터 시작한다.

### [Step 0] 도시 이미지 자동 생성 — ✅ 완료

11개 도시 x 40장 = 440장 전량 생성 완료 (2026-04-02).
스크립트: `scripts/generate_city_images.py`
이미지 위치: `assets/images/cities/`

### [Step 1] 프로젝트 초기화

Flutter 프로젝트를 초기화해줘.

1. 프로젝트 이름: iso_weather
2. 최소 SDK: Flutter 3.19+, Dart 3.3+
3. pubspec.yaml에 다음 의존성 추가:
   - flutter_riverpod (상태 관리)
   - http (API 호출)
   - geolocator (GPS)
   - geocoding (좌표→도시 변환)
   - shared_preferences (설정 저장)
   - hive, hive_flutter (캐시)
   - connectivity_plus (네트워크 상태 감지)
   - intl (날짜 포맷)
4. assets/ 폴더 구조를 만들어줘:
   - assets/images/cities/ (이미지 폴더)
   - assets/data/ (JSON 데이터)
   - assets/fonts/
5. pubspec.yaml에 assets 경로 등록
6. .env 파일에 OPENWEATHERMAP_API_KEY 플레이스홀더 생성

### [Step 2] 데이터 모델 정의

다음 데이터 모델들을 작성해줘.

lib/models/weather_data.dart:
- WeatherData 클래스 (temp, feelsLike, humidity, windSpeed, uvi, weatherId, weatherDescription, sunrise, sunset)
- JSON 파싱 (fromJson) 메서드 포함
- OpenWeatherMap One Call API 3.0 응답 구조에 맞춰줘

lib/models/city.dart:
- City 클래스 (id, nameKo, nameEn, lat, lon, hasCustomImages)
- 11개 도시 기본 데이터 포함 (서울, 도쿄, 베이징, 상하이, 뉴욕, 시드니, 파리, 런던, 베를린, 마드리드, 바르셀로나)

lib/models/clothing_case.dart:
- ClothingCase 클래스 (id, priority, conditions, messages, items)
- conditions는 temp_range, weather, wind, humidity 포함
- JSON 파싱 메서드 포함

### [Step 3] 날씨 API 서비스

OpenWeatherMap API 서비스를 구현해줘.

lib/services/weather_service.dart:
1. WeatherService 클래스
2. fetchWeather(double lat, double lon) 메서드
   - One Call API 3.0 호출
   - URL: https://api.openweathermap.org/data/3.0/onecall
   - 파라미터: lat, lon, exclude=minutely,hourly,daily,alerts, units=metric, lang=ko
   - WeatherData 객체로 반환
3. API 키는 .env에서 읽기 (flutter_dotenv 사용)
4. 에러 핸들링: 네트워크 에러, API 에러 구분
5. 타임아웃: 10초

### [Step 4] 위치 서비스

위치 서비스를 구현해줘.

lib/services/location_service.dart:
1. LocationService 클래스
2. getCurrentLocation() 메서드 – 현재 GPS 좌표 반환
3. getCityFromCoordinates(lat, lon) 메서드 – 좌표를 도시명으로 변환
4. 위치 권한 요청 처리
5. 권한 거부 시 기본 도시(서울) 반환
6. iOS Info.plist, Android manifest에 필요한 권한 설정도 해줘

### [Step 5] 이미지 선택 로직

이미지 선택 서비스를 구현해줘. 이것은 이 앱의 핵심 기능이야.

lib/services/image_selector.dart:
1. ImageSelector 클래스
2. getImagePath(String cityId, DateTime now, int weatherCode, DateTime sunrise, DateTime sunset) 메서드
   - 계절 판별: 3~5월 spring, 6~8월 summer, 9~11월 autumn, 12~2월 winter
   - 시간대 판별: sunrise~sunset이면 day, 아니면 night
   - 날씨 매핑:
     - 200~531 → rain
     - 600~622 → snow
     - 701~781 → fog
     - 800 → clear
     - 801~804 → cloudy
   - 파일 경로: "assets/images/cities/{city}_{season}_{time}_{weather}.webp"

Fallback 체인 (파일이 없을 경우):
1. 정확한 조합
2. 같은 도시+계절+시간+clear
3. 같은 도시+계절+day+clear
4. 같은 도시+spring_day_clear

에셋 존재 여부 확인 로직도 포함해줘.

### [Step 6] 옷차림 추천 로직

옷차림 추천 서비스를 구현해줘.

lib/services/clothing_recommender.dart:
1. ClothingRecommender 클래스
2. 앱 초기화 시 assets/data/clothing_logic.json 로드
3. getRecommendation(WeatherData weather) 메서드:
   - 체감온도 구간 판별 (below_minus_10, minus_10_to_0, 0_to_5, 5_to_10, 10_to_15, 15_to_20, 20_to_25, 25_to_30, above_30)
   - 풍속 레벨 판별 (low/normal/high)
   - 습도 레벨 판별 (low/normal/high)
   - 날씨 카테고리 판별
   - conditions가 매칭되는 case 필터링 ("any"는 모든 값과 매칭)
   - 여러 매칭 시 priority가 가장 낮은(=높은 우선순위) case 선택
   - messages 배열에서 랜덤 1개 선택
   - 매칭 없으면 기본 메시지 반환

assets/data/clothing_logic.json:
- 최소 30개 이상의 케이스를 생성해줘
- 한국 기후 기준으로 자연스러운 한국어 추천 멘트
- 각 케이스당 messages 3개씩
- 특수 기상(한파, 폭염, 태풍) 케이스 포함

### [Step 7] 캐시 서비스

날씨 데이터 캐시 서비스를 구현해줘.

lib/services/cache_service.dart:
1. CacheService 클래스 (Hive 사용)
2. saveWeatherData(WeatherData data) – 날씨 데이터 저장
3. getWeatherData() – 저장된 데이터 반환
4. isCacheValid() – 30분 이내인지 확인
5. getLastUpdateTime() – 마지막 업데이트 시각
6. clearCache() – 캐시 삭제

### [Step 8] 상태 관리 (Riverpod)

Riverpod으로 상태 관리를 구현해줘.

lib/providers/weather_provider.dart:
1. weatherProvider – 날씨 데이터 상태
2. 앱 실행 시 자동으로 위치 확인 → 캐시 확인 → API 호출 흐름
3. refreshWeather() – 수동 새로고침
4. 로딩/에러/성공 상태 관리

lib/providers/settings_provider.dart:
1. 온도 단위 (celsius/fahrenheit)
2. 선택된 도시
3. GPS 사용 여부
4. 알림 설정
5. shared_preferences에 자동 저장/로드

### [Step 9] 메인 화면 UI

> **디자인 Skill 활용**: 이 Step 실행 전 반드시 다음 skill을 invoke하여 디자인 기준을 확립할 것:
> 1. `superpowers:brainstorming` — 메인 화면 UX 방향 탐색
> 2. `frontend-design` — 레이아웃 그리드, 컴포넌트 구조 설계
> 3. `supanova-taste-skill` — 프리미엄 색상/간격/그림자 기준
> 4. `supanova-soft-skill` — 카드 구조, 한국어 타이포 기준

메인 화면을 구현해줘. 이 앱의 핵심 UI야.

lib/screens/home_screen.dart + 관련 위젯들:

1. 전체 화면을 도시 이미지로 채워줘 (Stack 사용)
2. 이미지 위에 날씨 정보 오버레이:
   - 상단: 도시명 (Bold, 24sp, 흰색) + 날짜 (14sp, 흰색 70%)
   - 상단 아래: 기온 (Bold, 64sp, 흰색)
   - 하단: 옷차림 추천 카드 (반투명 배경, 둥근 모서리)
   - 우측 상단: 설정 아이콘
3. 이미지 전환 시 CrossFade 애니메이션 (800ms)
4. Pull-to-refresh로 날씨 새로고침
5. 오프라인 시 상단에 "Offline Mode" 배너
6. 안전 영역(SafeArea) 처리
7. 텍스트에 그림자 추가하여 이미지 위에서도 가독성 확보

**디자인 참고:**
- 배경 이미지가 핵심이므로, UI 요소는 최소한으로 유지
- 다크 톤 배경에서 흰색 텍스트가 잘 보이도록

### [Step 10] 날씨 파티클 애니메이션

> **디자인 Skill 활용**: 이 Step 실행 전 반드시 다음 skill을 invoke할 것:
> 1. `superpowers:brainstorming` — 파티클 애니메이션 전략 탐색
> 2. `supanova-soft-skill` — 애니메이션 품질 기준

날씨 파티클 애니메이션을 구현해줘. 단, 자연스럽고 부드러운 퀄리티가 나올 때만 적용할 거야.

lib/widgets/particle_overlay.dart:
1. CustomPainter 기반 파티클 시스템
2. 눈: 흰색 원형, 다양한 크기(2~6px), 느린 낙하 + 좌우 흔들림(sin 곡선)
3. 비: 흰색 선형(길이 10~20px), 빠른 낙하, 약간의 각도
4. 안개: 큰 반투명 원형들이 느리게 이동
5. 파티클 수: 눈 60개, 비 150개 (기기 성능에 따라 조절)
6. AnimationController로 매 프레임 갱신
7. 화면 밖으로 나간 파티클은 위에서 재생성
8. 성능 최적화: RepaintBoundary 사용

이 기능은 ON/OFF 가능하도록 설정에 토글 추가.
만약 파티클이 부자연스러우면 이 기능은 비활성화하고 이미지만 표시해도 됨.

### [Step 11] 설정 화면

> **디자인 Skill 활용**: 이 Step 실행 전 반드시 다음 skill을 invoke할 것:
> 1. `frontend-design` — 설정 화면 레이아웃 설계
> 2. `supanova-soft-skill` — 리스트/토글 컴포넌트 기준

설정 화면을 만들어줘.

lib/screens/settings_screen.dart:
1. 온도 단위 (°C / °F) – 토글 스위치
2. 도시 선택 – 지원 도시 리스트 (서울, 도쿄, 베이징, 상하이, 뉴욕, 시드니, 파리, 런던, 베를린, 마드리드, 바르셀로나)
3. 현재 위치 사용 – 토글 스위치
4. 매일 아침 알림 ON/OFF – 토글 스위치
5. 알림 시간 설정 – TimePicker
6. 날씨 애니메이션 ON/OFF – 토글 스위치
7. 앱 정보 (버전, 크레딧)

설정값은 shared_preferences로 저장.
메인 화면 우측 상단 톱니바퀴 아이콘으로 진입.
네비게이션은 slide 트랜지션.

### [Step 12] 통합 테스트 및 마무리

전체 앱을 통합하고 마무리해줘.

1. main.dart에서 모든 서비스 초기화 순서 정리
2. 앱 아이콘 설정 (flutter_launcher_icons)
3. 스플래시 화면 설정 (flutter_native_splash) – 단색 다크 배경
4. iOS/Android 빌드 설정 확인
5. 에러 핸들링 전반 점검
6. 메모리 누수 방지 (dispose 처리)
7. README.md 작성 (설정 방법, API 키 등록 등)

---

## 12. MVP 범위

### MVP에 포함
- 11개 도시 (모든 계절/시간대/날씨 이미지, 440장)
- 현재 날씨 표시 (기온, 체감온도)
- 옷차림 추천 텍스트
- 이미지 자동 전환 (계절/시간대/날씨)
- 오프라인 모드
- 기본 설정 (온도 단위, 도시 선택)

### MVP 이후 (Phase 2)
- 추가 한국 도시 (부산, 대구, 인천, 대전)
- 날씨 파티클 애니메이션
- 매일 아침 푸시 알림
- 위젯 (iOS/Android 홈 화면)
- 시간별/주간 날씨 예보 (스크롤 확장)

### MVP 이후 (Phase 3)
- 사용자 도시 추가 기능
- 커뮤니티 이미지 공유
- Apple Watch / WearOS 연동

---

## 13. 앱스토어 배포 정보

| 항목 | 내용 |
|------|------|
| 앱 이름 (영문) | ISO-Weather |
| 카테고리 | 날씨 |
| 연령 등급 | 전체 이용가 (4+) |
| 핵심 키워드 | 날씨, 옷차림 추천, 코디, 미니어처, 감성 날씨앱 |

---

## 14. 체크리스트

### 개발 전 준비
- [x] Google Gemini API 키 발급
- [ ] OpenWeatherMap API 키 발급
- [ ] Flutter 개발 환경 설정

### MVP 완료 기준
- [x] 이미지 생성 스크립트로 11개 도시 440장 생성 완료
- [ ] 생성된 이미지 품질 검수 및 불량 재생성
- [ ] 날씨 정상 표시
- [ ] 이미지가 계절/시간대/날씨에 따라 자동 전환
- [ ] 옷차림 추천 멘트 정상 표시
- [ ] 오프라인 모드 작동
- [ ] iOS/Android 시뮬레이터 테스트 통과
- [ ] Pull-to-refresh 작동
- [ ] 설정 화면 정상 작동

---

*이 PRD는 Claude Code CLI에 Step-by-Step 프롬프트를 순서대로 입력하여 개발을 진행하도록 설계되었습니다.*
*디자인 관련 Step(9, 10, 11) 실행 시 반드시 명시된 skill을 먼저 invoke하여 프리미엄 품질 기준을 확립한 후 구현을 진행합니다.*
*harness skill을 활용하여 독립적인 Step들을 병렬 에이전트로 동시 진행할 수 있습니다.*
