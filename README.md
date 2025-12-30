# TSR Monitoring App

TSR 모니터링용 Flutter 클라이언트. 
Socket.IO 서버에 연결해 차트를 표시하고, 평균/이상 이력을 확인.

## 주요 기능
- Socket.IO 기반 실시간 진동 차트
- 시간/일/월/년 단위 평균 차트
- 이상 이력(스코어/임계값) 목록
- Firebase Cloud Messaging 알림(설정 시)

## 요구 사항
- Flutter SDK >=3.0.6 <4.0.0
- Android SDK + platform tools
- JDK 17(AGP 8.x 권장)
- Android Studio 또는 standalone SDK
- VS Code + Flutter/Dart 확장(선택)

## Android Studio 설치 및 추가 구성
- Android Studio 설치 후 SDK Manager에서 아래 구성요소 설치
  - Android SDK Platform (예: 34/35)
  - Android SDK Platform-Tools
  - Android SDK Build-Tools
  - Android SDK Command-line Tools (latest)
- 에뮬레이터가 필요하면 Android Emulator와 시스템 이미지 추가 설치

## 설정 위치
- API Base URL 및 Socket.IO 네임스페이스: `lib/util/constants.dart`
- 그래프 기본 축 범위: `lib/util/unique_shared_preference.dart`
- Firebase 설정: `android/app/google-services.json` - 현재는 건들지 말아야함
## 빌드/실행 (Windows)
```powershell, terminor 등 동일
cd C:\path\to\tsr_monitoring_app-master
flutter doctor
flutter doctor --android-licenses
flutter pub get
flutter run
flutter build apk --release
```
결과물: `build/app/outputs/flutter-apk/app-release.apk`

## 파일-머신 매핑
- 쇼트블라스트: 1R_bearing_5
- 인산염피막기: AROPump
- 비형상도포기: Dispenser
- 진공펌프: VacuumPump1, VacuumPump2

## 코드 수정 포인트
1) IP(vpn 값) 및 파일-머신 매핑
   - `lib/util/constants.dart`
```dart
const SHOT_BLAST_URL = "/sio/1R_bearing_5";
const ARO_PUMP_URL = "/sio/AROPump";
const DISPENSING_MACHINE_URL = "/sio/Dispenser";
const VACUUM_PUMP1_URL = "/sio/VacuumPump1";
const VACUUM_PUMP2_URL = "/sio/VacuumPump2";
```
2) 그래프 Y축 기본 범위
   - `lib/util/unique_shared_preference.dart`
```dart
setString('maxvalue', '0.04'); // 최댓값
setString('minvalue', '0.0'); // 최솟값
```

## 참고
- `BASE_URL`이 `http://`인 경우 Android 9+에서 cleartext 허용이 필요할 수 있습니다.
- Socket.IO 네임스페이스는 서버 `/sio/machineList` 결과와 일치해야 합니다.
- 지금 서버는 1분 평균값만 소켓으로 전송하므로(진동 원시 파형이 아님) Hz를 올려도 앱에 들어오는 값은 거의 변함이 없음.

