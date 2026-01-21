# TSR 모니터링 프레임워크

특정 머신들(현재 4개)의 데이터를 수집/전송하고, 서버에서 값의 1분간 평균 값을 클라이언트 앱으로 시각화하는 전체 스택입니다.

2025년 마지막 수정을 기준으로, 기존 코드를 이어받아 2026 내부 배포용으로 정리된 형태이며, mini-pc(진동 등 머신), server-pc, App(android) 구성으로 운영됩니다.

## 구성 요소
- `TSR_DAQSystem-master`
  - Python + PySide6 기반 데스크톱 앱
  - NI-DAQ 장치에서 실시간 데이터 수집
  - LSTM-AE로 이상 탐지(옵션)
  - TCP로 Monitoring Server에 전송 + 로컬 CSV 저장
- `TSR_MonitoringServer-master`
  - Python + FastAPI + Socket.IO 서버
  - DAQ TCP 수신 → 통계/이상치 처리 → SQLite/CSV 저장
  - REST/Socket.IO로 클라이언트에 제공
- `tsr_monitoring_app-master`
  - Flutter 클라이언트
  - 실시간 차트, 평균 통계, 이상 이력 조회
  - FCM 알림(옵션)

## 데이터 흐름
1) DAQSystem이 NI-DAQ 데이터를 읽어 이벤트로 생성
2) TCP로 Monitoring Server에 전송
3) Server가 분/시/일/월/년 통계와 이상치 기록 생성
4) 클라이언트는 REST + Socket.IO로 실시간/통계를 조회

## 통신 규약 요약
- DAQ → Server: TCP + `pickle` 직렬화, 구분자 `b'\0'`
  - 최초: `(event='name', data='<machine_name>')`
  - 이후: `DataUpdate`, `FaultDetect`
- Server → Client:
  - REST: `/stat/*`
  - Socket.IO: `/sio/<machine_name>` 네임스페이스, `initialize/update/anomaly` 이벤트

## 저장 구조
- DAQSystem 로컬 CSV: `TSR_DAQSystem-master/resources/data/<machine>/`
- Server 원시 CSV: `TSR_MonitoringServer-master/data/<machine>/`
- Server SQLite: `TSR_MonitoringServer-master/db/<machine>.db`

## 실행 순서(권장)
1) Monitoring Server 실행
2) DAQSystem 실행 및 서버 주소 설정
3) Flutter 앱 실행

## 상세 메뉴얼
- DAQSystem: `TSR_DAQSystem-master/README.md`
- Monitoring Server: `TSR_MonitoringServer-master/README.md`
- Flutter App: `tsr_monitoring_app-master/README.md`
