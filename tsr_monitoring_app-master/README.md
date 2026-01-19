# TSR Monitoring App

Monitoring Server의 REST/Socket.IO를 사용해 실시간 차트, 평균 통계, 이상 이력을 보여주는 Flutter 클라이언트입니다.

## 구성 개요
- `lib/main.dart`: 엔트리 포인트
- `lib/page`: 페이지(초기/상세/설정)
- `lib/widget`: 차트/카드/리스트 UI
- `lib/util`: API, Socket, 상수, 설정 저장
- `assets`, `font`: 리소스

## 요구 사항
- Flutter SDK >=3.0.6 <4.0.0
- Android SDK + platform tools
- JDK 17(AGP 8.x 권장)

## Android Studio 설치 및 추가 구성
- Android Studio 설치 후 SDK Manager에서 아래 구성요소 설치
  - Android SDK Platform (예: 34/35)
  - Android SDK Platform-Tools
  - Android SDK Build-Tools
  - Android SDK Command-line Tools (latest)
- 에뮬레이터가 필요하면 Android Emulator와 시스템 이미지 추가 설치

## 설정 위치
- REST Base URL 및 Socket.IO 네임스페이스: `lib/util/constants.dart`
- 실시간 차트 Y축 기본 범위: `lib/util/unique_shared_preference.dart`
- Firebase 설정:
  - `android/app/google-services.json` (수정 금지)
  - `lib/firebase_options.dart`

## 실행/빌드 (Windows)
- PowerShell/터미널에서 실행 (환경에 따라 관리자 권한 필요)
```powershell
cd C:\path\to\tsr_monitoring_app-master
flutter doctor
flutter doctor --android-licenses
flutter pub get
flutter run
flutter build apk --release
```
결과물: `build/app/outputs/flutter-apk/app-release.apk`

## 서버 연동 규약
- REST: `BASE_URL` 기준으로 `/stat/*` 호출
- Socket.IO: `/sio/<machine_name>` 네임스페이스
- 이벤트 이름
  - `initialize`: 서버 캐시 데이터 수신
  - `update`: 1분 평균 값
  - `anomaly`: 이상치 이벤트

## 머신 매핑
- 쇼트블라스트: 1R_bearing_5
- 인산염피막기: AROPump
- 비형상도포기: Dispenser
- 진공펌프: VacuumPump1, VacuumPump2

## 코드 수정 포인트
1) 서버 주소/머신 매핑
   - `lib/util/constants.dart`
```dart
const BASE_URL = "http://100.88.22.119:8445";
const SHOT_BLAST_URL = "/sio/1R_bearing_5";
const ARO_PUMP_URL = "/sio/AROPump";
const DISPENSING_MACHINE_URL = "/sio/Dispenser";
const VACUUM_PUMP1_URL = "/sio/VacuumPump1";
const VACUUM_PUMP2_URL = "/sio/VacuumPump2";
```
2) 차트 Y축 기본 범위
   - `lib/util/unique_shared_preference.dart`
   - 필요 시 값 조정(현재 기본값은 코드 내 `maxvalue/minvalue`)
```dart
setString('maxvalue', '10.0'); // 최댓값
setString('minvalue', '-10.0'); // 최솟값
```

## 참고
- `BASE_URL`이 `http://`인 경우 Android 9+에서 cleartext 허용 필요
- Socket.IO 네임스페이스는 서버 `/sio/machineList` 결과와 일치해야 함
- 서버는 1분 평균값만 소켓으로 전송(진동 원시 파형 아님)
