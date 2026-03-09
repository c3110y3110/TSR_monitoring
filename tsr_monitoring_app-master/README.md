# TSR Monitoring App

Monitoring Server의 REST/Socket.IO를 사용해 실시간 차트, 평균 통계, 이상 이력을 보여주는 Flutter 클라이언트입니다.

## 구성 개요
- `lib/main.dart`: 엔트리 포인트
- `lib/page`: 페이지(초기/상세/설정)
- `lib/widget`: 차트/카드/리스트 UI
- `lib/util`: API, Socket, 상수, 설정 저장
- `assets`, `font`: 리소스

## TSR Monitoring App 설치/빌드 매뉴얼 (Windows 기준)

> 이 문서는 **Windows + Android Studio + PowerShell** 기준으로 작성되었습니다.

### 1) 먼저 확인할 프로젝트 파일

1. `pubspec.yaml` / `pubspec.lock`
2. `android/settings.gradle`
3. `android/build.gradle`
4. `android/gradle/wrapper/gradle-wrapper.properties`
5. `android/app/build.gradle`

### 2) 버전 매트릭스 (현재 코드 기준)

- Flutter SDK: `stable 권장`
- Dart SDK: `>=3.0.6 <4.0.0`
- AGP: `8.3.2`
- Kotlin plugin: `1.9.24`
- Gradle Wrapper: `8.7`
- Android Studio: `Iguana 2023.2.1 Patch 2 이상 권장`
- Android 빌드용 JDK: `17`
- Android compileSdk: `36`
- Android targetSdk: `36`
- Android minSdk: `24`
- Android SDK Platform: `Android API 36`
- Android SDK Build-Tools: `36.x`

### 2-1) 코드에서 직접 고정한 값

- `android/settings.gradle`
  - AGP `8.3.2`
  - Kotlin plugin `1.9.24`
- `android/gradle/wrapper/gradle-wrapper.properties`
  - Gradle `8.7`
- `android/app/build.gradle`
  - `compileSdk = 36`
  - `targetSdk = 36`
  - `minSdkVersion = 24`

---

### 3) Windows 설치 절차 (클릭 경로 + 입력 명령 포함)

#### 3-1. Android Studio 설치 (무엇을 눌러야 하나요?)

1. Android Studio 다운로드 페이지 접속
   - https://developer.android.com/studio
   - 코드와 가장 직접적으로 맞는 Android Studio가 필요하면 Archive에서 `Iguana 2023.2.1 Patch 2` 이상 사용
   - Archive: https://developer.android.com/studio/archive
2. `Download Android Studio` 클릭
3. 설치 파일 실행 후 기본값으로 `Next` 진행
4. 설치 완료 후 `Run Android Studio` 체크하고 `Finish`
5. 최초 실행 시 Setup Wizard:
   - `Do not import settings` 선택 (처음 설치면)
   - `Standard` 선택
   - `Finish`

> 최신 안정판 Android Studio도 대부분 사용 가능하지만, 이 프로젝트의 AGP `8.3.2`와 가장 세대가 잘 맞는 기준은 `Iguana 2023.2.1 Patch 2`입니다.

#### 3-2. Android Studio에서 플러그인 설치 (클릭 경로)

1. Android Studio 실행
2. `File > Settings` 진입
3. 왼쪽 `Plugins` 클릭
4. `Marketplace` 탭에서 검색/설치
   - `Flutter` 설치
   - Flutter 설치 중 Dart 설치 팝업 뜨면 `Yes`
5. 우측 하단 `Restart IDE` 클릭

#### 3-3. Android SDK 구성요소 설치 (클릭 경로)

1. `File > Settings > Appearance & Behavior > System Settings > Android SDK`
2. `SDK Platforms` 탭
   - 아래 항목 체크
     - `Android SDK Platform 36`
3. `SDK Tools` 탭
   - 우측 하단 `Show Package Details` 체크
   - 아래 항목 체크
     - `Android SDK Build-Tools`
       - `36.0.x`
     - `Android SDK Platform-Tools`
     - `Android SDK Command-line Tools (latest)`
     - `Android Emulator` (에뮬레이터 쓸 경우)
4. `Apply` → `OK`

> 이 프로젝트는 현재 `compileSdk 36 / targetSdk 36 / minSdk 24`로 코드에 고정되어 있습니다.
> 현재 의존성 기준으로 `API 34`만 설치하면 경고가 남습니다. `shared_preferences_android`가 `compileSdk 36`을 요구합니다.

#### 3-4. JDK 17 설치/설정 (클릭 + 명령)

##### A) 가장 쉬운 방법: Android Studio 번들 JDK 사용

- Android Studio가 포함한 JDK를 그대로 써도 됩니다.
- 단, `Gradle JDK` 설정은 `17` 또는 Android Studio 내장 JDK로 맞추세요.

##### B) 외부 JDK를 따로 설치하려면 JDK 17 설치

관리자 PowerShell:

```powershell
winget install EclipseAdoptium.Temurin.17.JDK
```

##### C) 설치 확인

```powershell
java -version
```

- `17.x` 이상이 나오면 정상

##### D) JAVA_HOME 설정(외부 JDK를 쓸 때만, 필요 시)

```powershell
setx JAVA_HOME "C:\Program Files\Eclipse Adoptium\jdk-17.0.**"
```

> `**` 부분은 실제 설치된 정확한 폴더명으로 바꿔 입력하세요.

##### E) Android Studio에서 Gradle JDK를 17 이상으로 설정

1. `File > Settings > Build, Execution, Deployment > Build Tools > Gradle`
2. `Gradle JDK` 드롭다운에서 아래 둘 중 하나 선택
   - Android Studio 내장 JDK
   - 직접 설치한 JDK 17
3. `Apply` → `OK`

> `JDK 11`로 맞추면 안 됩니다. 이 프로젝트는 `android/settings.gradle`에서 AGP `8.3.2`를 사용합니다.

#### 3-5. Flutter SDK 설치 (Windows)

1. Flutter 설치 페이지 접속
   - https://docs.flutter.dev/get-started/install/windows
2. SDK zip 다운로드
3. `C:\src\flutter`에 압축 해제
4. 환경 변수 등록
   - `시작 메뉴` → `환경 변수` 검색 → `시스템 환경 변수 편집`
   - `환경 변수` 버튼
   - `Path` 선택 → `편집` → `새로 만들기`
   - `C:\src\flutter\bin` 입력 → 확인
5. PowerShell 완전히 종료 후 재실행

확인 명령:

```powershell
flutter --version
flutter doctor
```

#### 3-6. Android Studio 설치 후 "실제로 하는 작업" (중요)

Android Studio를 설치만 해서는 실행이 안 되고, 아래 작업까지 해야 앱이 뜹니다.

1. 프로젝트 열기
   - Android Studio 시작 화면에서 `Open` 클릭
   - `tsr_monitoring_app-master` 폴더 선택
2. 프로젝트 신뢰/인덱싱 대기
   - 보안 관련 팝업이 뜨면 `Trust Project` 선택
   - 우하단 인덱싱이 끝날 때까지 대기
3. Gradle Sync 대기
   - 우하단 진행바에서 `Gradle build / Sync` 완료까지 대기
   - AGP/Gradle 업그레이드 제안 팝업이 떠도 자동 수정하지 말고 `Cancel` 또는 유지 선택
   - 오류가 나면 먼저 `Gradle JDK = 17` 확인
4. Flutter Pub 패키지 동기화
   - 하단 `Terminal` 열기 후 아래 실행:

```powershell
flutter clean
flutter pub get
```

5. 디바이스 준비 (둘 중 하나)
   - 실기기: 개발자 옵션 + USB 디버깅 ON 후 연결
   - 에뮬레이터:
     - `Tools > Device Manager`
     - `Create Device`
     - 예: `Pixel 6` 선택 → `Next`
     - 시스템 이미지에서 `API 36` 또는 원하는 최신 이미지 선택 → `Download` → `Next` → `Finish`
     - 실행 버튼(▶) 클릭
6. 앱 실행
   - Android Studio 상단 디바이스 드롭다운에서 실행 대상 선택
   - 실행 버튼(▶) 클릭 또는 터미널에서 `flutter run`
7. 첫 실행 체크 포인트
   - 로그에 `Running Gradle task 'assembleDebug'...` 이후 `Built ...`가 뜨면 정상
   - `No devices`면 `flutter devices`로 연결 상태 재확인
   - Firebase 관련 오류가 나면 `android/app/google-services.json` 파일 존재 여부 확인

---

### 4) 프로젝트 세팅 및 실행 (터미널에 정확히 입력)

PowerShell에서 프로젝트 폴더로 이동:

```powershell
cd C:\path\to\tsr_monitoring_app-master
```

의존성 설치:

```powershell
flutter clean
flutter pub get
```

디바이스 확인:

```powershell
flutter devices
```

앱 실행:

```powershell
flutter run
```

---

### 5) APK 빌드

```powershell
flutter build apk --debug
flutter build apk --release
```

빌드 결과물 기본 경로:

- `build\app\outputs\flutter-apk\app-debug.apk`
- `build\app\outputs\flutter-apk\app-release.apk`

추가 참고:

- 현재 `android/app/build.gradle`의 release 서명은 `debug keystore`를 사용하도록 되어 있어 내부 테스트용 빌드에 가깝습니다.
- 스토어 배포용이면 별도 signing 설정을 추가해야 합니다.

---

### 6) Firebase 사용하는 경우

확인 파일:

- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`
- `lib/firebase_options.dart`

재설정 필요 시:

```powershell
dart pub global activate flutterfire_cli
flutterfire configure
```

---

### 7) 트러블슈팅

#### 7-1. JDK 관련 에러

```powershell
java -version
```

- 17이 아니면:
  1. `JAVA_HOME` 재설정
  2. Android Studio의 `Gradle JDK`를 17로 재선택

#### 7-2. `pub get` 실패

```powershell
flutter pub cache repair
flutter pub get
```

#### 7-3. Gradle Sync 실패

- SDK Tools 누락 여부 재확인
- `Android SDK Platform 36`과 `Build-Tools 36.x` 설치 여부 재확인
- Gradle JDK가 17인지 재확인
- Android Studio의 AGP/Gradle 자동 업그레이드 제안으로 프로젝트 파일을 바꾸지 않았는지 확인
- Android Studio 재시작 후 재시도

## 설정 위치
- REST Base URL 및 Socket.IO 네임스페이스: `lib/util/constants.dart`
- 실시간 차트 Y축 기본/대체 범위: `lib/util/unique_shared_preference.dart`
- Firebase 설정:
  - `android/app/google-services.json` (수정 금지)
  - `lib/firebase_options.dart`

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
2) 차트 Y축 기본/대체 범위
   - `lib/util/unique_shared_preference.dart`
   - 실제 Y축은 수신 데이터 기준 자동 스케일
   - 데이터가 없거나 평탄하면 아래 설정값을 fallback으로 사용
```dart
setString('maxvalue', '10.0'); // 최댓값
setString('minvalue', '-10.0'); // 최솟값
```

## 설정 동작
- 설정에서 표시 장비는 최소 1개 선택(빈 화면/탭 방지)
- 설정 변경 후 홈 화면은 자동 갱신(RouteAware)

## 참고
- `BASE_URL`이 `http://`인 경우 Android 9+에서 cleartext 허용 필요
- Socket.IO 네임스페이스는 서버 `/sio/machineList` 결과와 일치해야 함
- 서버는 1분 평균값만 소켓으로 전송(진동 원시 파형 아님)
