# PIE - Powernet Industrial Engineering (인터넷 버전)

영상 기반 작업분석 / 표준시간(ST) 산출 / 라인편성 프로그램입니다.
인터넷 연결이 가능한 환경용 버전으로, MediaPipe(Pose) 자산을 CDN에서 받아오고
구글 시트(GAS) 연동으로 부품 ST를 누적할 수 있습니다.

> 인터넷이 차단된 환경(중국 등)에서는 오프라인 버전을 사용하세요 →
> https://github.com/lovekhl83-stack/pie-work-analysis-cn

## 실행 방법
1. `PIE_시작.bat` 더블클릭 (또는 `PIE.html`을 Chrome/Edge로 열기)
2. 첫 실행 시 라이선스 키 입력 필요 — 문의: lovekhl83@gmail.com

## 설치(다른 PC에 배포할 때)
- 권장: `PIE_설치.bat` 실행 — 프로그램이 설치되고 바탕화면/시작 메뉴 바로가기가 생성됩니다.
- 또는 `PIE.html` 파일 하나만 복사해도 동작합니다.
- 제거: 시작 메뉴의 "PIE 제거" 또는 설치 폴더의 `PIE_제거.bat`

## 부품 ST 누적 저장소 (여러 PC 공유)
설정(⚙) 화면에서 아래 방식을 선택할 수 있으며, 함께 사용할 수도 있습니다.

| 방식 | 설명 |
|---|---|
| 📊 구글 시트 | GAS 웹 앱 URL 등록 → 부품 ST 저장 시 시트에 자동 누적. 부품관리의 `🔄 구글시트 동기화`로 다시 가져오기 |
| 📁 폴더 | 네트워크 공유 폴더를 등록해 같은 폴더를 보는 PC끼리 누적 공유 |
| 🌐 서버 | 한 대에서 `PIE_ST_server_시작.bat` 실행 → 다른 PC가 그 LAN 주소를 등록 |

## 주의사항
- Chrome 또는 Edge 브라우저 필요 (Internet Explorer 미지원)
- Pose 비교(MediaPipe) 기능은 CDN 자산을 받아오므로 인터넷 연결이 필요합니다
- "AI 비전 분석"(YOLO) 메뉴는 별도 로컬 서버가 필요해 현재 숨겨져 있습니다
