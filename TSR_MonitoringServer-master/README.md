# TSR Monitoring Server

DAQSystem에서 들어오는 TCP 스트림을 수신하고, 통계/이상치를 계산해 DB/CSV로 저장하며, REST + Socket.IO로 클라이언트에 제공하는 백엔드입니다.

## 구성 개요
- `src/main.py`: 엔트리 포인트(단일 실행 락)
- `src/monitoring_app/monitoring_app.py`: FastAPI + Socket.IO 설정
- `src/monitoring_app/machine_server`: TCP 수신 서버
- `src/monitoring_app/routers`: REST API
- `src/database`: SQLite 접근 계층
- `src/util`: 로깅, FCM, CSV, 시간 유틸
- `resources/config.yml`: 런타임 설정

## 실행
```bash
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
python src/main.py
```
- `monitoring.lock` 파일로 중복 실행을 방지합니다.

## 설정 파일 (resources/config.yml)
- `SERVER.HOST` / `SERVER.PORT`: REST + Socket.IO 바인딩
- `SERVER.TCP_PORT`: DAQSystem TCP 수신 포트
- `FCM.CRED_PATH`: Firebase 서비스 계정 JSON 경로
- `FCM.TIMEOUT`: 알림 최소 간격(초)
- `LOGGER.PATH`: 로그 저장 경로
- `STAT`: 센서 타입별 통계 모드(`ABS`/`REAL`)
- `DATABASE.PATH`: SQLite 저장 경로
- `DATA.PATH`: 원시 CSV 저장 경로

## TCP 프로토콜 (DAQ → 서버)
- 접속: `SERVER.TCP_PORT`
- 최초 메시지: `(event='name', data='<machine_name>')`
- 이후 메시지: `pickle` 직렬화 + 구분자 `b'\0'`
  - `DataUpdate`:
    `{ "<sensor>": { "type": "VIB|TEMP", "data": [float, ...] } }`
  - `FaultDetect`:
    `{ "score": <float>, "threshold": <float> }`
NOTE: Python `pickle` 기반이므로 외부 언어 클라이언트는 별도 구현 필요.

## Socket.IO
- 네임스페이스: `/sio/<machine_name>`
- 클라이언트 이벤트: `initialize`
- 서버 이벤트:
  - `initialize`: 센서별 최근 데이터 캐시 전달(최대 60개)
  - `update`: `{ "sensor_name": "<sensor>", "data": <float>, "time": "<datetime>" }`
  - `anomaly`: `{ "score": <float>, "threshold": <float> }`

## REST API
- `GET /sio/machineList`
- `GET /stat/machineList`
- `GET /stat/hour?machine=<name>&start=YYYY-MM-DD&end=YYYY-MM-DD`
- `GET /stat/day?machine=<name>&start=YYYY-MM-DD&end=YYYY-MM-DD`
- `GET /stat/month?machine=<name>&start=YYYY-MM-DD&end=YYYY-MM-DD`
- `GET /stat/year?machine=<name>&start=YYYY-MM-DD&end=YYYY-MM-DD`
- `GET /stat/anomaly?machine=<name>&start=YYYY-MM-DD&end=YYYY-MM-DD`
- `GET /stat/anomaly/all?start=YYYY-MM-DD&end=YYYY-MM-DD`

## 저장 구조
- 원시 CSV: `data/<machine>/YYYYMMDD_<sensor>.csv`
- SQLite: `db/<machine>.db`
  - `<sensor>_hour_avg`, `<sensor>_day_avg`, `<sensor>_month_avg`, `<sensor>_year_avg`
  - `anomaly` 테이블
- 로그: `log/`

## 트러블슈팅
- 머신 목록이 비어 있음: DAQSystem 연결 및 초기 `name` 핸드셰이크 확인
- 알림이 오지 않음: `FCM.CRED_PATH`와 Firebase 권한 확인
- 포트 충돌: `SERVER.PORT` 또는 `SERVER.TCP_PORT` 변경
