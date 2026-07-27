# PIE — Powernet Industrial Engineering 인터넷 빌드 — 프로젝트 전체 문서

> 2026-07-27 기준. 오프라인/중국 빌드(`pie-work-analysis-cn`)에서 축적한 45커밋 분량의 개선을 이 저장소로 이식하면서 작성했다.
> 두 빌드는 **PIE.html 한 파일을 공유**하며, 인터넷 관련 부분만 다르다(아래 5항).

---

## 1. 프로젝트 개요

- **이름**: PIE — Powernet Industrial Engineering (화면 부제: "작업 분석 시스템" / 시작화면 부제 "Process Intelligence Engine" ← 불일치, 백로그)
- **목적**: 작업 영상을 보면서 작업요소(구간)를 마킹해 시간연구(Time Study)를 수행하고, 레이팅·여유율로 표준시간(ST)을 산출, 야마즈미·작업편성·라인 시뮬레이션까지 이어지는 **IE 작업분석 도구**
- **이 빌드의 특징**: 인터넷 가능 환경용. ①구글 시트(GAS) 연동 유지 ②MediaPipe Pose 자산을 jsDelivr CDN에서 로드 ③CN 빌드에서 만든 ST 누적 저장소(공유 폴더 / LAN 서버)도 함께 사용 가능
- **형태**: **단일 HTML 파일 앱** — `PIE.html` 하나(1.92MB, 13,476줄)에 React 18(min)+jsPDF+html2canvas+MediaPipe Pose JS+앱 코드 전부 내장. 빌드 시스템 없음(파일 직접 편집)
- **실행**: `PIE_시작.bat` 또는 `PIE.html` 더블클릭 (Chrome/Edge)
- **라이선스**: 첫 실행 시 `PIE-XXXX-XXXX-XXXX`(12자리 hex) 키 입력, 연·월 단위 만료. 문의 lovekhl83@gmail.com
- **GitHub**: `lovekhl83-stack/pie-work-analysis` (**public**) — GitHub Pages가 download.html(PIE.html 직접 다운로드 페이지)을 서빙

### 기술 스택
| 구분 | 내용 |
|---|---|
| UI | React 18 (min, CDN판 내장) — JSX 없이 `React.createElement` 직접 호출 |
| PDF | jsPDF + html2canvas (화면 스크린샷→JPEG→PDF, 래스터 방식이라 CJK 폰트 문제 없음) |
| AI | MediaPipe Pose (JS 내장 + wasm/tflite는 jsDelivr CDN, modelComplexity 0=lite) / YOLO는 `localhost:8000` 별도 서버(메뉴 숨김) |
| 서버 | ST 공유용 PowerShell `System.Net.HttpListener` 1종(8792) — Node·Python 설치 불필요 |
| 저장 | localStorage + File System Access API(Chrome/Edge 전용) + `.wvas`/`.pie` JSON 파일 + 구글 시트(GAS) |

---

## 2. 폴더 구조

```
작업분석├─ PIE.html                 # 앱 전체 (단일 파일, 1.92MB)
├─ PIE_시작.bat              # 표준 실행: PIE.html을 기본 브라우저로 오픈
├─ PIE_ST_server_시작.bat    # LAN ST 누적 서버 실행 (선택)
├─ PIE_ST_server.ps1        # ST 공유 서버 (+:8792, GET/POST /api/st, st_store.json 병합 저장)
├─ PIE_설치.bat → PIE_setup.ps1  # GUI 설치기(한/영/중/베 병기, 폰트 폴백): %LOCALAPPDATA%\PIE_WorkAnalysis에 설치 + 바탕화면/시작메뉴 바로가기(타겟=PIE_시작.bat) + HKCU 언인스톨 등록
├─ PIE_제거.bat → PIE_uninstall.ps1  # 설치 폴더+레지스트리 제거 (bat은 ASCII로 유지 — CP949 깨짐 방지)
├─ PIE_가이드.html           # 설치·사용 가이드 (ko/zh/vi 3언어 섹션)
├─ download.html            # GitHub Pages 랜딩: PIE.html 다운로드 버튼
├─ README.md                # 실행/설치/ST 공유 방식/주의사항
└─ .nojekyll
```

---

## 3. PIE.html 내부 지도 (줄 번호)

| 구간 | 내용 |
|---|---|
| 1~1013 | 내장 라이브러리: React/ReactDOM(min), MediaPipe Pose glue, jsPDF+플러그인, html2canvas |
| 1014~1043 | **PIE 라이선스 시스템** — `window._pieLicCheck(key)` 해시 기반 오프라인 검증. 12자리 hex, {year, month} 반환 (상세 알고리즘은 public 저장소이므로 문서화하지 않음) |
| 1044~1156 | **i18n STRINGS** — ko/zh/vi. UI 토글은 ko/zh만 |
| 1157~1352 | **MSG_ZH 메시지 테이블 + `_m()`(1348)** — alert/confirm 문구 zh 번역 (CN 빌드에서 신설) |
| 1353~1396 | 상수: TT(정미/부수/낭비 3분류), TASK_COLORS, CYCLE_COLORS, THERBLIGS 18종, ECRS_LIST, SPEEDS(0.1~4x), WHEEL_PRESETS |
| 1397~1519 | **구글 시트(GAS) 연동 — 인터넷 빌드 전용** `GAS_URL_DEFAULT`(1400), `getGasUrl`(1453), `syncToGoogleSheet`(1475, no-cors POST), `fetchFromGoogleSheet`(1505, GET) + 중복 임포트 방지 키 `wvas_gas_imported` |
| 1520~1575 | 유틸(fmt/fmtS/uid/unionDur) + `autoAssignCycles`(1556) — 최다 빈도 작업명을 앵커로 사이클 경계 추정 |
| 1576~1750 | localStorage 헬퍼: 세션(최대 30개, 1577~)/모델-공정(1611~)/부품 마스터(1633~)/부품 ST DB(1639~)/삭제 툼스톤(1647~)/레이팅(1659~)/작업자(1662~) |
| 1717~1750 | E드라이브 저장: IndexedDB에 디렉터리 핸들 보관 → `.wvas` 파일 저장/목록/읽기/삭제 (File System Access API) |
| 1751~1905 | **ST 누적 저장소** — none/folder/server 3모드(1756~), `PIE_ST_누적.json`, `_stPickBetter`(1782, 표본수 n 우선→최신 updatedAt) + `mergePartStPayload`(1795) + `stBackendSync`(읽기→병합→로컬 반영→쓰기) |
| 1906~2706 | 공용 컴포넌트: DualTimeDisplay(1912), WheelStepControl(1942), VideoWithOverlay(1959), VideoCtrlMenu(2016), HomeDashboard(2070), GanttTimeline(2132)/GanttByName(2200), **SettingsModal(2287** — 언어 + ST 저장소 + 구글시트), LoadProjectModal(2467), ProjectMenuDropdown(2551), LeftSidebar(2607) |
| 2707~2846 | Tip(2686), WelcomeModal(2714), StartupModal(2777, ko/zh 토글), StepGuide(2820) |
| 2847~3810 | CycleComparison(2847), CycleStats(3428) — 사이클 반복 분석 |
| 3811~5914 | 라인 계열: Yamazumi(3817, `wvas_constraints`·`wvas_waittimes`), WorkerSim(4809), WorkAssignmentTab(4994), RebalanceWorkspace(5300), STAnalysis(5462), **LinePredict(5561**, 부품 ST DB 기반 재작성), BottleneckChart(5862) |
| 5915~6510 | FileManager(5921), **PartsManager(5999** — 구글시트 동기화·폴더/서버 동기화·부품 ST DB), ModelBrowserModal(6517) |
| 6511~7069 | AiAnalysisModal(6806) — YOLO `localhost:8000` 연동 (메뉴 숨김 상태) |
| 7070~7441 | TaskDictBtn(7070), GlossaryModal(7115), IETip(7185), TherbligPicker(7214), ECRSCell(7287), EcrsPanel(7360) |
| 7442~8169 | SegmentCompareModal(7448), VideoCompareModal(7772) |
| 8170~8629 | SopExportModal(8170), ReportModal(8259) — SOP/산출보고서 |
| 8630~10810 | VisionResultPanel(8635) + Pose 비교 엔진: DTW(8811), VisionAiModal(8847), **initPose(9609, `locateFile→jsDelivr CDN`)** |
| 10811~11375 | LineAnalysisPanel(10818) — 부품별 평균시간→작업배분 연동 (`pie_line_workers/tasks/model` 키) |
| 11376~13364 | **App()** — 전체 상태·탭 라우팅·키보드 단축키(Space/←→/I/O/Esc)·세션 저장/불러오기·.wvas 내보내기/가져오기·exportPDF(html2canvas)·`saveAnalysisToPartsDb`(11423)·부품 ST 저장(12840~) |
| 13365~13461 | LicenseScreen (ko/zh 토글, `pie_license_key` 저장) |
| 13462~13476 | ErrorBoundary + LicensedApp(키 검증→만료 확인→App) + `ReactDOM.createRoot` 부트스트랩 |

> 위 3장 표의 줄 번호는 2026-07-27 인터넷 빌드 기준으로 재확인한 값이다. **4장 이후 본문에 나오는 줄 번호는 2026-07-24 CN 빌드 기준이라 최대 ~1,100줄 밀려 있다** — 정확한 위치는 3장 표나 검색으로 확인할 것.

---

## 4. 데이터 모델·저장

### localStorage 키 전체
| 키 | 내용 |
|---|---|
| `wvas_sessions` | 세션 메타 목록 (최신순, **30개 캡** — 초과분은 목록에서 잘림) |
| `wvas_sessions_<id>` | 세션 데이터 본문 (작업요소 배열 등. ⚠ 30개 캡에서 잘린 세션의 본문은 미삭제 → 고아 누적, 백로그) |
| `wvas_models` | 모델-공정 트리 (공정에 tasks/fps/rating/takt 스냅숏 저장, `loadFromProcess`로 복원) |
| `wvas_parts` | 부품 마스터 (기본 11종 PCB 부품: id/name/insertType(Radial·Axial)/leadCount) |
| `wvas_part_st` | **부품 표준시간 DB** (모델 무관): `{partId: {taskName: {st:초, n:표본수, updatedAt:ISO}}}` — 필드는 이 3개뿐. 특수 키: 작업명 `'전체작업'`(일괄 저장), partId `'__none__'`(부품 미지정, UI 미표시) |
| `pie_last_upload_sig` | "분석 내용 저장" 중복 방지 서명 (1단계) |
| `wvas_part_taskdb_reset` | 부품 ST 초기화 이력 |
| `wvas_rating` | 레이팅·여유율 (기본 `{r:100, a:15}`) |
| `wvas_workers` | 작업자 마스터 (기본 작업자1~3) |
| `wvas_constraints` / `wvas_waittimes` | 야마즈미 배분 제약 / 대기시간 |
| `wvas_lang` | 언어 'ko'/'zh' | 
| `wvas_expert` / `wvas_welcomed` / `wvas_adv_cols` | 초보자 모드 해제 / 웰컴 표시 여부 / 고급 컬럼 표시 |
| `pie_line_workers` / `pie_line_tasks` / `pie_line_model` | 라인분석 탭 전용 (작업자/작업/모델명) |
| `pie_st_backend_mode` / `_url` / `_folder_name` | ST 누적 저장소 모드('none'\|'folder'\|'server')/서버 주소/폴더 표시명 |
| `pie_license_key` | 활성화된 라이선스 키 |
| IndexedDB `wvas_fs` | 디렉터리 핸들 2개(`dirHandle`, `stDirHandle`) + 영상 원본 `vid_<id>`(addVideos 10499가 기록하나 읽기·삭제 코드 없음 — 백로그) |

### .wvas 프로젝트 파일 (내보내기/E드라이브 저장 공통, version 2)
```jsonc
{ "version":2, "savedAt":"ISO", "analysisName":"", "videoName":"", "fps":30,
  "tasks":[...],                      // 단일 영상 모드 하위호환
  "videos":[{id,name,tasks,fps,completed}], // 다중 영상. src는 저장 안 함(null)
  "activeVideoId":"", "partId":"" }
```
### 저장 경로별 복원 범위 (2026-07-27 실측)
| 저장 방법 | 복원 | 미복원 |
|---|---|---|
| 메뉴 > 분석 저장 (폴더, `project.json` v4) | 작업분석 + 라인분석 + **작업배분(balance)** + 레이팅·여유율·택트 + **영상 파일** | — |
| 세션 저장 (localStorage, 30개 캡) | 작업분석 구간 | 영상·라인분석·작업배분 |
| `.wvas` 내보내기 | 작업분석 구간 | 영상·라인분석·작업배분 |
| 부품 ST DB | 항상 유지(+LAN 서버 공유) | — |

- 세션(localStorage)/.wvas/E드라이브 경로는 **영상 원본을 저장하지 않는다** — 불러오면 `src:null`, 영상 재선택 필요. 단 **메뉴의 통합 프로젝트 저장(version:4, saveUnifiedProject 11194)은 예외**: 사용자 지정 폴더에 `project.json`+영상 바이너리(분석 영상 `analysis_N_이름`, 라인분석 작업자 영상 `line_wid_이름`)를 저장하고 loadUnifiedProject(11242)가 복원
- 같은 로드 로직이 loadFromStorage/importFromFile/applyFileData 3곳 중복(11041~11116). LoadProjectModal(2021)+loadProjectData(11289)는 호출 경로 없는 4번째 사본(죽은 코드)

### 부품 ST DB 쓰기 3경로 — 의미가 서로 다름 (백로그 결정 D)
| 경로 | 저장 값 | n 의미 | 중복가드 |
|---|---|---|---|
| PartsManager 확정저장 (5292) | 이력 평균 **raw**(레이팅 미적용) **덮어쓰기** | 이력 표본수 | — |
| analysis "분석 내용 저장" (10650) | `'전체작업'` 키에 **raw** 가중평균 누적 | +=사이클수 | `pie_last_upload_sig` |
| 테이블 툴바 "부품 ST 저장" (11809) | **레이팅·여유율 적용값** 가중평균 누적 | +=표본수 | 없음(재클릭 시 n 부풀림) |

### ST 누적 동기화 트리거 (시작·주기 자동 동기화 없음 — 전부 사용자 액션 후)
- 수동: SettingsModal·PartsManager "지금 동기화" 버튼 (1913, 5227)
- 자동(silent): 위 3개 저장 직후 (5304, 10702, 11845)

### ST 누적 저장소 (이 빌드의 핵심 대체 기능 — 구글시트 GAS 대신)
| 모드 | 동작 |
|---|---|
| none | 로컬 localStorage만 사용 |
| folder | 공유 폴더의 `PIE_ST_누적.json`을 읽고→로컬과 병합→다시 씀 (File System Access API, 핸들은 IndexedDB에 보관) |
| server | `<url>/api/st` GET→병합→POST. 서버(PIE_ST_server.ps1)는 POST 수신 시 **서버측에서 한 번 더 병합** 후 st_store.json에 저장 |

병합 규칙(클라이언트 JS와 서버 PS1이 동일 로직으로 구현됨):
1. 부품은 **이름 소문자 기준** 통합(id가 달라도 같은 이름이면 같은 부품으로 매핑)
2. 같은 부품·같은 작업명의 ST 항목은 `_stPickBetter`: **표본수 n 큰 쪽 우선, 같으면 updatedAt 최신 쪽** — 합산이 아닌 "선택"이라 반복 동기화해도 값이 부풀지 않음
- folder 모드는 파일 잠금이 없어 두 PC 동시 동기화 시 last-writer-wins (server 모드는 서버가 순차 병합하므로 안전)

---

## 5. 화면 구성과 워크플로

### 내비게이션 (LeftSidebar 2161, 상단 ProjectMenuDropdown 2105)
- **작업**: 작업분석(analysis) / 차트(gantt: timeline·byname·cycle 3뷰) / 통계(stats) / 영상비교(모달)
- **라인**: 라인분석(lineanalysis) / 야마즈미=작업배분(yamazumi) / 시뮬=배치실험(sim)
- **도구**: 부품관리(parts) / 라인예측(line) / AI 비전 분석·AI 분석결과(vision)
  - ~~ST분석~~ → 부품관리 > 영상분석이력 탭으로 통합(2026-07-26), ~~작업편성~~ → 숨김(2026-07-27, 역할 중복). 두 컴포넌트 코드는 보존
- **메뉴**: 세션, CSV·PDF 내보내기, 모델, AI 동작분석, 낭비 구간 비교, 사이클 속도 비교, SOP, 산출보고서, 도움말, 용어집, 설정
- 초보자 모드(기본): 탭 이름이 쉬운 말로 바뀌고(야마즈미→작업배분) StepGuide 4단계 안내 표시. `wvas_expert` 설정 시 해제

### 기본 워크플로
1. 영상 드래그&드롭(다중 가능) → analysis 탭
2. 재생하며 **I**(시작)/**O**(끝) 또는 클릭으로 작업요소 마킹 → 이름/유형(정미·부수·낭비)/서블릭/ECRS 부여
3. `autoAssignCycles`가 반복 사이클 자동 배정(최대 10) → 차트·사이클비교·통계
4. 레이팅(기본 100)·여유율(기본 15%)로 ST 산출 → 부품 ST DB에 누적(`wvas_part_st`) → ST 누적 저장소로 PC 간 공유
5. 라인분석에서 작업자별 영상 분석 → 야마즈미 배분(제약·대기시간 반영) → 시뮬 → SOP/보고서/PDF/CSV 출력
- 키보드: Space 재생/정지, ←→ 1프레임(Shift=5초), I/O 마킹, Esc 루프 해제. 마우스 휠 스텝 30/50/67/100ms

### 작업요소(task) 레코드 (finishMark 10552 생성)
`{id(uid 7자), name, type(value-added|auxiliary|waste), color, cycle(1~10), hand(LH|RH), startTime, endTime, duration, note, worker, partId, wasteType*, therbligs*, ecrs*}` (*: waste/고급열 전용). video 레코드 `{id,name,src(objectURL),file,tasks,completed,fps}`(10488)
- 마킹 상태기계: 클릭/I → `pending=현재시각`+자동 재생 → 클릭/O → 역방향이면 alert 유지, 정상이면 pause+task 생성. I는 pending 중 확정 겸용(토글)
- **ST 수식**: `ST = 관측시간 × (레이팅/100) × (1 + 여유율/100)` — 동일식이 16곳 산재(공용 함수 없음: 10600·2989·3535·4074·11833 등)
- CSV(10633): `영상,#,작업명,사이클,분류,시작,종료,소요(s),소요(hms),비고` — ST·부품·작업자·손·서블릭·ECRS 열 미포함. BOM+CRLF
- 통계(CycleStats 2967): 사이클별 관측·ST·유형합·CV, 이상치(n>3 && |x−μ|>2σ), 대표 ST=이상치 제외 평균×보정, 필요관측수 `ceil((40σ/μ)²)`, 필요인원 `ceil(베스트사이클 ST/택트)`

### 라인 계열 데이터 흐름·알고리즘
- 라인분석(9830) 작업자별 마킹 → 작업자×부품 평균 `yamaTasks`(type 고정 value-added, cycle 고정 1) → App.lineYamaData(10418) → 야마즈미(드래그 재배분은 `yamaAssignments` 오버레이, 원본 불변 12119) → 시뮬(이 빌드에선 항상 읽기 전용 뷰)
- 별갈래: 분석 탭 → 모델관리 "공정으로 저장"(5696, stdTimeTotal 스냅숏) → `wvas_models` → 작업편성·병목차트
- 배분 휴리스틱: 야마즈미 AI 재배치 = First-Fit Decreasing(용량 takt×1.05, 최소 인원 탐색, 3530) / 라인예측 편성 = LPT 탐욕(4981)
- **택트 3원화**: App.taktTime(야마즈미·시뮬 10436) vs model.taktTime(작업편성 4395) vs LinePredict 자체 tt(4942) — 상호 동기화 없음
- ST분석·라인예측은 공유 ST DB가 아니라 **세션 30개의 원시 duration** 재계산(4851, 4946) — 타 PC 동기화 데이터 미반영
- 제약 `wvas_constraints`(before/wait)·대기 `wvas_waittimes`(작업명→초)는 작업 "이름" 기준 전역 키(프로젝트 무관)

### AI 기능 (모두 로컬)
- **AI 비전 분석(Pose, VisionAiModal 7882)**: 영상 1~2개 × 작업자 1~2명(좌우 반분할 crop)을 1x 실시간 재생하며 MediaPipe Pose(complexity 0, initPose 8643) 추론 → 손목 랜드마크→칼만→EMA 속도 → 마스터 구간(캔버스 2클릭, 2패스) 대비 **DTW**(25샘플, 위치1.0+방향0.5+몸중심0.3+비대칭0.2 가중, 7836) 판정: 정미/대기·낭비/이동 → 0.4s 미만 세그먼트 버림 → 사이클 일관성 점수·Westinghouse 자동 레이팅(8768)·병목 CV 분석(8779)·궤적 히트맵. 자산은 `mediapipe/pose/` 로컬 서빙(**8791 서버 전제**). 결과는 React state(10449)에만 보관(휘발 — 백로그)
- **AI 동작분석(YOLO, AiAnalysisModal 5953)**: `localhost:8000` 별도 서버 — `GET /health`(3s) → `POST /analyze/stream`(multipart: file·sample_fps 5·idle_threshold 1.5·min_segment 1.0·use_yolo) → SSE 스트림(progress/status/result, `[DONE]`) → 결과 tasks로 **현재 분석 전체 교체**(applyAiTasks 11170, beforeSnap 백업). ⚠ 백엔드 코드는 저장소 미동봉(백로그)
- **영상비교(VideoCompareModal 6907)**: 2영상 나란히 수동 재생 비교(Pose 미사용)

### 내보내기 산출물 (⑤ 정리)
| 기능 | 위치 | 형식 | CJK |
|---|---|---|---|
| SOP `exportSOP` | 10738 | 베스트 사이클 → 작업별 480×270 JPEG 캡처 → PDF+Excel 동시 생성 | PDF는 helvetica로 작업명 출력 → **한글·한자 깨짐**(백로그) |
| SOP Excel | 10932 | HTML table → .xls(BOM) + data URI 이미지 | 안전(헤더는 한국어 고정) |
| 산출보고서 ReportModal | 7304 | **화면 표시 전용**(다운로드 없음): 요약·파이·CoV 안정도·스크린샷 그리드 | — |
| 전체 PDF `exportPDF` | 11132 | html2canvas 래스터 → jsPDF | 안전 |
| CSV | 10633 | BOM+CRLF+이스케이프 | 안전(헤더 한국어 고정) |

---

## 6. 부가 서버 (순수 PowerShell, 설치 불필요)

| | PIE_ST_server.ps1 |
|---|---|
| 포트 | +:8792 (LAN 바인딩, 최초 1회 관리자 urlacl 등록; 실패 시 127.0.0.1 폴백) |
| 역할 | ST 누적 공유 API — GET/POST `/api/st`, CORS 허용, `st_store.json`에 병합 저장 |
| 보안 | 경로 1개만 허용, OPTIONS 204 |
| 종료 | 창 닫으면 종료 |

(CN 빌드의 정적 서버 `PIE_local_server.ps1`은 MediaPipe 자산을 로컬에서 서빙하기 위한 것이라 이 빌드에는 없다 — CDN을 쓰므로 file:// 직접 실행으로도 Pose가 동작한다.)

---

## 7. 실행·설치·배포

- **표준 실행**: `PIE_시작.bat` 또는 `PIE.html` 더블클릭 (Chrome/Edge)
- **ST 공유 서버 PC**: `PIE_ST_server_시작.bat` 실행, 각 클라이언트는 설정>ST 누적 저장소>서버에 `http://<서버IP>:8792` 등록
- **설치**: `PIE_설치.bat` → **PIE_setup.ps1**(한/영/중/베 병기 GUI): `%LOCALAPPDATA%\PIE_WorkAnalysis`에 PIE.html·PIE_시작.bat·ST 서버·가이드·README 복사, 바탕화면/시작메뉴 바로가기(타겟=PIE_시작.bat), HKCU 언인스톨 등록
- **제거**: `PIE_제거.bat` → PIE_uninstall.ps1 (bat은 ASCII로 유지해 chcp 65001에서 깨지지 않는다 — CN 빌드 P0 수정 이식)
- **외부 통신**: ①MediaPipe Pose 자산(jsDelivr CDN) ②구글 시트(GAS) 연동을 켠 경우의 script.google.com ③사용자가 직접 입력한 ST 서버/YOLO 서버 주소 — 이 3가지뿐
- **Pages 배포 범위 주의**: 저장소 전체가 Pages로 올라가므로 CLAUDE.md·PROJECT_OVERVIEW.md·WORKLOG.md 같은 내부 문서도 공개 배포에 포함됨(백로그)
- **웹 배포**: push → GitHub Pages → download.html에서 PIE.html 직접 다운로드
- **CN 빌드 대비 차이**: 구글 시트(GAS) 연동 유지, MediaPipe는 CDN 로드, 정적 서버·mediapipe 자산 없음. 그 외 앱 코드는 동일

## 8. 라이선스

- 형식 `PIE-XXXX-XXXX-XXXX`(hex 12자리). `_pieLicCheck`가 오프라인 해시 검증, {year, month} 만료 반환 — 해당 월 말일까지 유효, 이후 LicenseScreen으로 회귀
- 활성 키는 `pie_license_key`에 저장, 기동 시마다 재검증(LicensedApp 12373)
- ⚠ 검증 로직·시크릿이 public 저장소의 PIE.html 안에 있으므로 **알고리즘 상세는 어떤 문서에도 기재하지 않는다** (노출 리스크 자체는 백로그 B에서 결정)

## 9. 다국어

- STRINGS(1042): ko 52키 / zh 51키 / vi 51키(⑤ 실측; zh·vi 모두 `tab_lineanalysis` 누락). zh 값 6곳에 한글 혼입 "分석"(1088·1091·1093·1108·1109·1116). 언어 선택: 시작·라이선스 화면은 ko/zh 토글이지만 **SettingsModal 라디오는 ko/zh/vi 3개**(1917) — vi도 노출됨(원본 잔재)
- **STRINGS를 참조하는 컴포넌트는 6곳뿐**(HomeDashboard·Settings·LoadProject·ProjectMenu·LeftSidebar·SegmentCompare) — 본문 화면은 사실상 한국어 전용. alert/confirm 68곳 중 67곳 미번역, 한국어 렌더 리터럴 약 1,600건(⑤ 실측)
- 라이선스·시작 화면은 STRINGS와 별도의 내장 T 객체로 ko/zh 처리 (12281, 2324)
- **한국어 하드코딩 잔존 구역**: StepGuide 4단계 안내(2367~2373), 각종 alert/confirm(11043, 8656 등), 간트 안내문(12255), **AI 모달 4종 전체**(AiAnalysis/VisionAi/SegmentCompare/VideoCompare — STRINGS 미사용), 통계 인사이트·용어집 — zh 전수 커버리지 미달 (백로그 C)
- PIE_가이드.html은 ko/zh/vi 3언어 섹션 구조(단, 언어별 섹션 구성 일치 여부 미검증)

## 10. 알아둘 설계 결정·이음새(seam)

1. **영상 비저장 원칙**: 세션/.wvas 어디에도 영상 바이너리를 넣지 않는다. 불러온 뒤 영상 재드롭 필요
2. **부품 ST DB는 모델 무관**(model-independent): 같은 부품·작업명이면 모델이 달라도 하나의 ST로 누적 — `_stPickBetter`의 "표본수 우선" 선택 방식이 부풀림을 방지
3. **세션 30개 캡**: lsSave가 메타 목록을 30개로 자르지만 본문 blob은 남음(백로그 P0-2)
4. **하드코딩 기본값**: 레이팅 100·여유율 15%·택트 60초·유휴 임계 0.5초·fps 30·세션 캡 30·사이클 캡 10
5. **beginnerMode 기본 ON**: 첫 사용자는 쉬운 라벨+StepGuide. 전문가 전환은 설정에서
6. **구명 잔재**: vi 사전(UI 토글은 ko/zh만), 'WVAS-report' PDF 파일명, wvas_ 키 프리픽스(구명 Work Video Analysis System 추정)
7. **file:// 실행 가능**: MediaPipe 자산을 CDN에서 받으므로 file:// 직접 실행에서도 Pose가 동작한다 (CN 빌드는 로컬 서버 필수 — 두 빌드의 가장 큰 실행상 차이)
8. **브라우저 요구**: File System Access API(저장/불러오기·ST folder 모드)와 `AbortSignal.timeout`(1461) 때문에 Chrome/Edge 최신판 필요. StartupModal에 명시
9. **stdTime 수식 16곳 산재**: 공용 함수 없이 같은 식 반복 — 수식 수정 시 전수 교체 필요
10. **죽은 코드 군**: LoadProjectModal+loadProjectData(2021·11289 도달 불가), 야마즈미 멀티영상 분기 약 200줄(allVideos:[] 고정 12130)·사이클 필터(3385), VideoCompare 작업 비교 패널(7118), VisionResultPanel applyAll(7705), CycleStats pct()(3040) 등
11. **라인예측은 부품 ST DB 기반**(2026-07-27 개편, `wvas_part_st` 사용 + 택트 역산·BOM 저장·내보내기). ST분석 화면은 여전히 세션 원시값 재계산이라 값이 다를 수 있음
12. **비전 분석 결과 휘발**: visionResults는 저장 경로 없음 — 새로고침 시 소실
