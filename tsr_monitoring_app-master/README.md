# TSR Monitoring App

Monitoring Server의 REST/Socket.IO를 사용해 실시간 차트, 평균 통계, 이상 이력을 보여주는 Flutter 클라이언트입니다.

## 구성 개요
- `lib/main.dart`: 엔트리 포인트
- `lib/page`: 페이지(초기/상세/설정)
- `lib/widget`: 차트/카드/리스트 UI
- `lib/util`: API, Socket, 상수, 설정 저장
- `assets`, `font`: 리소스

## TSR Monitoring App 설치/빌드 매뉴얼 (Windows, 비전공자용)

> 목표:
> 1. 처음 설치하는 사람도 앱을 실행할 수 있다.
> 2. APK 파일까지 만들 수 있다.

### 0) 이 문서에서 최종적으로 할 일

- Android Studio 설치
- Flutter 설치
- 프로젝트 열기
- 앱 실행
- APK 빌드

### 1) 이 프로젝트 최소 기준

- Flutter SDK: `stable`
- Dart SDK: `>=3.0.6 <4.0.0`
- Android Studio: `Iguana 2023.2.1 Patch 2 이상 권장`
- JDK: `17 이상`
- AGP: `8.3.2`
- Kotlin plugin: `1.9.24`
- Gradle Wrapper: `8.7`
- Android SDK Platform: `36`
- Android SDK Build-Tools: `36.x`
- Android compileSdk: `36`
- Android targetSdk: `36`
- Android minSdk: `24`

### 2) 이 프로젝트에서 실제로 보는 파일

1. `pubspec.yaml` / `pubspec.lock`
2. `android/settings.gradle`
3. `android/gradle/wrapper/gradle-wrapper.properties`
4. `android/app/build.gradle`

### 3) Android Studio 설치

1. Android Studio 다운로드 페이지 접속
   - https://developer.android.com/studio
   - 코드 기준으로 가장 무난한 버전은 `Iguana 2023.2.1 Patch 2` 이상
   - 구버전이 필요하면 Archive 사용
   - https://developer.android.com/studio/archive
2. `Download Android Studio` 클릭
3. 설치 파일 실행
4. 기본값으로 `Next` 계속 진행
5. 설치 완료 후 `Run Android Studio` 체크
6. `Finish`
7. 처음 실행 시:
   - `Do not import settings`
   - `Standard`
   - `Finish`

### 4) Android Studio에서 꼭 설치해야 하는 것

#### 4-1. Flutter 플러그인 설치

1. Android Studio 실행
2. `File > Settings`
3. `Plugins`
4. `Marketplace`
5. `Flutter` 검색 후 설치
6. Dart 설치 팝업이 뜨면 `Yes`
7. `Restart IDE`

#### 4-2. Android SDK 설치

1. `File > Settings > Appearance & Behavior > System Settings > Android SDK`
2. `SDK Platforms` 탭
   - `Android SDK Platform 36` 체크
3. `SDK Tools` 탭
   - 우측 하단 `Show Package Details` 체크
   - 아래 항목 체크
     - `Android SDK Build-Tools 36.x`
     - `Android SDK Platform-Tools`
     - `Android SDK Command-line Tools (latest)`
     - `Android Emulator`
4. `Apply > OK`

> 이 프로젝트는 현재 `compileSdk 36 / targetSdk 36 / minSdk 24`로 코드에 고정되어 있습니다.

### 5) JDK 설정

#### 가장 쉬운 방법

- Android Studio에 포함된 JDK 사용
- 단, `Gradle JDK`는 `17 이상`이어야 함

#### 직접 설치할 경우

관리자 PowerShell:

```powershell
winget install EclipseAdoptium.Temurin.17.JDK
java -version
```

- `17.x` 이상이 나오면 정상

필요하면:

```powershell
setx JAVA_HOME "C:\Program Files\Eclipse Adoptium\jdk-17.0.**"
```

#### Android Studio 안에서 설정

1. `File > Settings > Build, Execution, Deployment > Build Tools > Gradle`
2. `Gradle JDK`에서 아래 둘 중 하나 선택
   - Android Studio 내장 JDK
   - 직접 설치한 JDK 17 이상
3. `Apply > OK`

### 6) Flutter 설치

1. Flutter 설치 페이지 접속
   - https://docs.flutter.dev/get-started/install/windows
2. SDK zip 다운로드
3. `C:\src\flutter`에 압축 해제
4. 환경 변수 등록
   - `시작 메뉴` → `환경 변수` 검색 → `시스템 환경 변수 편집`
   - `환경 변수`
   - `Path` 선택 → `편집` → `새로 만들기`
   - `C:\src\flutter\bin`
5. PowerShell 완전히 종료 후 재실행

확인:

```powershell
flutter --version
flutter doctor
```

### 7) 프로젝트 열기

1. Android Studio 실행
2. `Open`
3. `tsr_monitoring_app-master` 폴더 선택
4. 보안 팝업이 뜨면 `Trust Project`
5. 아래 작업이 끝날 때까지 대기
   - Indexing
   - Gradle Sync

> AGP/Gradle 업그레이드 제안 팝업이 떠도 자동 수정하지 말고 `Cancel` 또는 유지 선택

### 8) 앱 실행

PowerShell 또는 Android Studio 하단 `Terminal`에서:

```powershell
cd C:\path\to\tsr_monitoring_app-master
flutter clean
flutter pub get
flutter devices
flutter run
```

또는 Android Studio에서:

1. 상단 기기 선택
2. `Run` 버튼(▶) 클릭

### 9) 에뮬레이터 만드는 방법

1. `Tools > Device Manager`
2. `Create Device`
3. 예: `Pixel 6` 선택
4. `Next`
5. 시스템 이미지에서 `API 36` 선택
6. `Download > Next > Finish`
7. 실행 버튼(▶) 클릭

### 10) APK 만드는 방법

```powershell
flutter build apk --debug
flutter build apk --release
```

결과 파일:

- `build\app\outputs\flutter-apk\app-debug.apk`
- `build\app\outputs\flutter-apk\app-release.apk`

주의:

- 현재 `release APK`도 내부 테스트용 서명(debug keystore) 상태
- 스토어 배포용이면 별도 signing 설정 필요

### 11) 선택 사항: Firebase 다시 설정해야 할 때

확인 파일:

- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`
- `lib/firebase_options.dart`

재설정 필요 시:

```powershell
dart pub global activate flutterfire_cli
flutterfire configure
```

### 12) 자주 막히는 경우

#### 12-1. JDK 관련 에러

```powershell
java -version
```

- 17 미만이면:
  1. `JAVA_HOME` 재설정
  2. Android Studio의 `Gradle JDK`를 17 이상으로 재선택

#### 12-2. `pub get` 실패

```powershell
flutter pub cache repair
flutter pub get
```

#### 12-3. Gradle Sync 실패

- `Android SDK Platform 36` 설치 여부 재확인
- `Android SDK Build-Tools 36.x` 설치 여부 재확인
- `Gradle JDK`가 17 이상인지 재확인
- Android Studio의 AGP/Gradle 업그레이드 제안으로 프로젝트 파일을 바꾸지 않았는지 확인
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
