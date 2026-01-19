# TSR DAQSystem

NI-DAQ 장비에서 데이터를 수집하고, 필요 시 LSTM-AE로 이상 탐지를 수행하며, Monitoring Server로 전송/로컬 저장까지 담당하는 데스크톱 앱입니다.

## 구성 개요
- `src/main.py`: 엔트리 포인트
- `src/app.py`: PySide6 GUI 부트스트랩
- `src/gui`: 시작/설정/실행 화면
- `src/background`: DAQ 스레드, 송신/저장 핸들러
- `src/lib/daq`: NI-DAQ 장치 추상화
- `src/lib/lstm_ae`: 이상 탐지 모델 로드/추론
- `src/config`: 설정 클래스와 경로 정의
- `resources`: 설정 파일, 이미지, 모델/데이터 저장 루트

## 실행 흐름
1) `main.py` → `App` 실행  
2) 설정 화면에서 장비/센서/전송/저장 옵션 구성  
3) `DAQSystem(QThread)`가 NI-DAQ 데이터를 읽어 각 `Machine`으로 전달  
4) `Machine`이 이벤트를 브로드캐스트
   - `DataSender`: Monitoring Server로 TCP 전송
   - `DataSaver`: CSV 저장 및 외부 경로로 이동
   - `EventSender`: GUI 갱신

## 설치/실행
```bash
python -m venv .venv
source .venv/bin/activate  # Windows: .venv\Scripts\activate
pip install -r requirements.txt
python src/main.py
```

## 설정/리소스
- `resources/DAQSystem.conf`
  - `DAQSystemConfig`가 pickle로 저장되는 바이너리 파일
  - 반드시 GUI 설정 화면에서만 수정
- `src/config/paths.py`
  - `resources/model`, `resources/data` 등 경로 정의
- 모델 파일
  - `resources/model/<machine>/METADATA.yml`
  - `resources/model/<machine>/<model>.h5`
  - 로드 실패 시 해당 머신의 이상 탐지는 자동 비활성화

## 전송 프로토콜 (DAQ → Monitoring Server)
- TCP 연결: `DATA_SEND_MODE.HOST:PORT`
- 최초 메시지: `(event='name', data='<machine_name>')`
- 이후 메시지: `pickle` 직렬화 + 구분자 `b'\0'`
  - `DataUpdate`:
    `{ "<sensor>": { "type": "VIB|TEMP", "data": [float, ...] } }`
  - `FaultDetect`:
    `{ "score": <float>, "threshold": <float> }`
  - 송신 시 데이터는 `MAXIMUM_RATE=30`으로 리샘플링됨

## 저장 구조
- 로컬 CSV: `resources/data/<machine>/YYYYMMDD_<sensor>.csv`
- 외부 저장 경로: `DATA_SAVE_MODE.PATH/<machine>/`
  - 날짜 변경 시 파일 이동

## 트러블슈팅
- 장비 데이터가 안 보임: NI-DAQ 장치명/채널 매핑 확인
- 서버 전송 실패: `DATA_SEND_MODE` 호스트/포트 확인
- 이상 탐지 비활성: 모델 파일 경로/이름 확인
