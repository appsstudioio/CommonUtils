# CommonUtils 에이전트 작업 지침

이 지침은 저장소 전체에 적용한다. 명시적인 사용자 요청과 상위 작업 지침을 우선하며, 작업 시작 시 실제 소스와 설정을 다시 확인한다.

## 1. 프로젝트 이해

- `CommonUtils`는 여러 iOS 앱에서 사용하는 Swift Package Manager 공통 라이브러리다. 독립 실행 앱이 아니므로 공개 API 변경은 사용하는 앱에 영향을 준다.
- 패키지·제품·소스 대상 이름은 `CommonUtils`, 테스트 대상은 `CommonUtilsTests`다.
- `Sources/Extensions`: Foundation·UIKit·AVFoundation 등의 확장. 기존 `타입+Extension.swift` 명명과 배치를 따른다.
- `Sources/Function`: 공통 함수, 공유 파일 준비, 영상 압축, TTS, 연결 상태, 로그, 한글 검색 등.
- `Sources/Model`, `Sources/Views`: 공통 설정·모델과 UIKit 뷰·레이아웃.
- `Sources/CombineCocoa`: UIKit 이벤트를 Combine으로 연결하는 Publisher·Subscription.
- `Sources/MoyaNetwork`: Moya·Combine 요청, 응답 변환, 오류 처리와 네트워크 로그.
- `Sources/Resources`: 한국어 기본 지역화와 이미지 리소스. `Bundle.module`을 사용한다.
- `Tests/CommonUtilsTests`: XCTest 단위 테스트. 이미지·동영상 샘플은 `TestSampleData`에 있다.

## 2. 기본 작업 방식과 변경 범위

1. `git status --short`로 기존 변경을 확인하고, 요청과 관련된 소스·테스트·`Package.swift`를 읽는다.
2. 한국어와 Markdown으로 목표 요약 → 실행 계획(3~7줄) → 변경 내용 → 검증 방법 순서로 소통한다.
3. 기존 코드 스타일·구조·명명·접근 수준을 유지하고 관련 파일만 최소한으로 수정한다. 전체 자동 포맷, 무관한 파일 이동·리네이밍·경고 정리는 하지 않는다.
4. 신규 기능은 구현과 테스트를 함께 작성하고, 버그 수정은 재현되는 회귀 테스트를 가능한 범위에서 추가한다.
5. 관련 테스트부터 실행하고, 영향에 따라 전체 테스트와 빌드를 진행한다. 결과·미검증 항목·원인·필요한 다음 단계를 구분해서 보고한다.
6. 불확실한 내용은 추정/가설로 표시한다. 확인 질문은 최대 3개로 제한하고, 질문과 무관한 작업은 계속한다.

- 요청 밖의 대규모 리팩터링·폴더 재구성은 근거와 범위를 제안하고 승인 후 진행한다.
- 새 의존성 추가, 빌드 설정 변경, CI 수정은 목적·대안·영향 범위를 설명하고 승인 후 진행한다. 이미 승인된 범위는 다시 확인하지 않는다.
- 시크릿·API 키·토큰을 소스, 샘플 데이터, 로그, 커밋에 넣지 않는다. 유출이 의심되면 작업을 중단하고 안전한 대응 계획을 제시한다.

## 3. iOS 15 지원 기준

- **신규 기능과 수정의 최소 지원 기준은 iOS 15.0이다.** iOS 15에서 실행할 수 있는 API와 의존성을 선택한다.
- iOS 16 이상의 API는 정확한 도입 버전으로 `if #available` 또는 `@available`을 적용한다. 공통 기능에는 iOS 15 대체 동작을 제공하고, 최신 OS 전용 기능은 제한을 공개 API에 명시한다.
- 최신 SDK로 빌드가 성공했다는 사실과 iOS 15에서 실행된다는 사실을 구분한다. iOS 15 실행 환경이 없으면 호환성 검토와 실제 실행 검증의 범위를 따로 보고한다.
- 기존 iOS 13/14 가드나 호환 코드를 이번 변경과 무관하게 일괄 삭제하지 않는다.
- iPad, 회전, Split View, safe area를 고려하고, 화면 크기는 실제 뷰·레이아웃 가이드를 기준으로 계산한다.

### 현재 패키지 설정: 2026-10-07 갱신

- `Package.swift`는 iOS 15, macOS 12, tvOS 15, watchOS 9를 선언한다. iOS 최소 지원 기준은 `.iOS(.v15)`로 유지한다.
- 다른 플랫폼의 선언은 최신 Kingfisher·Alamofire의 최소 버전에 맞춘 것이다. UIKit 의존성이 있으므로 선언만으로 해당 플랫폼의 빌드·실행 지원을 보장하지 않는다.
- 자체 매니페스트는 `swift-tools-version: 6.4`, Swift 언어 모드 5다. 개발 환경·CI·소비 앱은 Swift 도구 버전 6.4 이상을 사용한다.
- 도구 버전 갱신과 Swift 언어 모드 전환은 별개다. 최신 컴파일러 사용을 이유로 Swift 6 언어 모드로 일괄 전환하지 않는다.

## 4. 신규 기능의 테스트 작성 원칙

- **신규 기능 구현과 대응하는 테스트 코드는 같은 작업에 포함한다.** `Tests/CommonUtilsTests`에 기존 XCTest 스타일로 작성하고 `@testable import CommonUtils`를 사용한다.
- 기능에 해당하는 정상 입력, 경계값(빈 값·nil·최소/최대값), 실패 경로를 검증한다. 반환값뿐 아니라 필요한 상태 변경·콜백·자원 정리도 확인한다.
- UIKit·공통 UI 상태 테스트는 메인 스레드 또는 `@MainActor`에서 수행한다. 변경한 전역 설정·싱글톤 상태는 `defer` 또는 `tearDown`으로 원복한다.
- 네트워크는 `MoyaProvider.immediatelyStub` 및 기존 mock 패턴을 우선 사용한다. 실제 서버·외부 인터넷·계정에 의존하는 단위 테스트를 만들지 않는다.
- TTS·오디오 세션·연결 상태는 기존 프로토콜 기반 의존성 주입 패턴을 활용한다. 테스트를 위해 공개 API를 불필요하게 늘리지 않는다.
- Combine·비동기 콜백은 expectation과 명시적인 timeout으로 검증한다. 임의의 `sleep` 대신 완료·실패·취소 및 이벤트 전달을 검증하고 구독을 정리한다.
- 파일·영상 테스트는 `Bundle.module`의 샘플과 테스트별 임시 디렉터리를 사용하고 생성 파일을 정리한다. 필수 샘플 누락은 실패로 처리하고 테스트를 통과시키기 위한 `XCTSkip`을 추가하지 않는다.
- 날짜·문자열 테스트는 필요에 따라 locale·time zone·기준 시각을 고정한다. 테스트 순서나 기기 설정에 의존하지 않게 한다.
- OS 전용 테스트의 skip은 실제 API 가용성으로 제한하고 이유를 명시한다. skip을 성공한 검증과 동일하게 보고하지 않는다.
- UI 표시·사진 권한·공유 시트·실제 음성 재생처럼 단위 테스트만으로 확인하기 어려운 부분은 자동 테스트와 함께 소비 앱에서의 수동 검증 절차·성공 기준을 적는다.

## 5. 공통 라이브러리 구현 원칙

- **공통 기능은 기존 공통 모듈의 API를 우선 사용한다.** 구현 전에 관련 모듈·확장·유틸리티를 검색하고, 같은 역할의 로직을 화면이나 기능 코드에 다시 구현하지 않는다.
- **공통 모듈에는 특정 앱·화면·업무 기능만을 위한 별도 메서드를 만들지 않는다.** 특정 기능의 정책·분기·데이터 조합은 그 기능의 소유 코드에서 처리한다. 공통 모듈에는 여러 사용처가 재사용할 수 있는 범용 동작만 둔다.
- **같은 공통 코드를 여러 곳에 중복 정의하지 않는다.** 기존 구현을 단일 정의로 재사용하고, 공통 동작 변경은 그 정의와 관련 테스트에 반영한다. 변경 범위 밖의 중복 정리가 필요하면 먼저 범위와 근거를 제안한다.
- 공개 함수의 시그니처, 기본값, 오류 타입, 콜백 전달 스레드와 기존 동작을 보존한다. 변경이 필요하면 소비 앱 영향과 마이그레이션 방법을 설명한다.
- UIKit 작업은 메인 스레드에서 처리한다. 비동기 작업의 중복 완료·취소·객체 수명과 Combine 구독 해제를 확인한다.
- `CommonNavigationAppearance.isEnabled`는 현재 명시적으로 활성화하는 설정이다. iOS 26 이상 시스템 버튼 경로와 기본 비활성 경로를 유지하고, 색상·target/action·메뉴·접근성을 보존한다. 시스템 `UIBarButtonItem`의 `customView`가 nil일 수 있음을 고려한다.
- 네트워크 변경은 `NetworkException` 매핑, HTTP 실패 응답, 디코딩 오류와 요청 취소를 확인한다. 요청·응답 로그에 인증 정보나 개인정보를 노출하지 않는다.
- 영상·오디오·공유 작업은 오디오가 없는 파일, 잘못된 입력, 임시 파일 정리, 완료·실패 경로를 확인한다. 기존 오디오 설정과 TTS 세션 정책을 무관하게 바꾸지 않는다.
- 공통 로그의 외부 전달은 기존 `DebugLoggerManager.externalLogHandler`와 테스트를 참고한다. 특정 앱의 분석·크래시 SDK를 공통 라이브러리에 임의로 추가하지 않는다.
- 리소스 변경 시 `Bundle.module`, 지역화 키와 `PrivacyInfo.xcprivacy`의 패키지 포함 여부를 확인한다.

## 6. 패키지 최신화 기준

**각 작업 시점의 공식 최신 안정 버전을 조사하되, iOS 15·도구 버전·의존성 제약과 호환되는 버전을 선택한다.** beta/RC, 단순히 가장 높은 버전, 다른 저장소의 동명 패키지를 자동 적용하지 않는다.

아래는 **2026-10-07에 확인한 참고 정보**다. 로컬 해석 기록은 `Package.resolved`를 읽은 값이며 실제 빌드에 사용된 버전을 증명하지 않는다. 이후 최신화 작업에서는 공식 릴리스와 매니페스트를 다시 확인하고 이 표를 갱신한다.

| 패키지 | 종류 | 현재 선언 / 로컬 해석 기록 | 공식 최신 안정 버전 | 작업 기준 |
| --- | --- | --- | --- | --- |
| [Moya](https://github.com/Moya/Moya/releases) | 직접 | 15.0.3 이상, 16 미만 / 15.0.3 | 15.0.3 | 네트워크·Combine 회귀 테스트 실행 |
| [SnapKit](https://github.com/SnapKit/SnapKit/releases) | 직접 | 6.0.0 이상, 7 미만 / 6.0.0 | 6.0.0 | Swift 도구 버전 요구와 소비 앱의 레이아웃 확인 |
| [Then](https://github.com/devxoul/Then/releases) | 직접 | 3.0.0 이상, 4 미만 / 3.0.0 | 3.0.0 | 유지 후보, 다음 작업 시 재확인 |
| ProgressHUD | 직접, 사내 포크 | `uwiseone-ios/ProgressHUD`의 `master` / `a8b101d905f78178bef45c16122be0f16e54aa40` | `master` HEAD `a8b101d905f78178bef45c16122be0f16e54aa40` | 최신 브랜치 커밋 확인 완료. 다른 upstream으로 교체하지 않음 |
| [Kingfisher](https://github.com/onevcat/Kingfisher/releases) | 직접 | 8.13.0 이상, 9 미만 / 8.13.0 | 8.13.0 | iOS 15 선언과 도구 버전 요구 정합성 확인, 이미지 로딩 회귀 검증 |
| [ZIPFoundation](https://github.com/weichsel/ZIPFoundation/releases) | 직접 | 0.9.20 이상, 1.0.0 미만 / 0.9.20 | 0.9.20 | 로그 압축·파일 처리 검증 |
| [Alamofire](https://github.com/Alamofire/Alamofire/releases) | Moya의 간접 의존성, 소스에서도 import | 직접 선언 없음 / 5.12.2 | 5.12.2 | Moya 허용 범위 내 갱신 완료, 도구 버전·연결 상태 테스트 확인 |
| [RxSwift](https://github.com/ReactiveX/RxSwift/releases) | Moya의 간접 의존성 | 직접 선언 없음 / 6.10.2 | 6.10.2 | 해석 결과 점검, 사용하지 않는 제품을 새로 연결하지 않음 |
| [ReactiveSwift](https://github.com/ReactiveCocoa/ReactiveSwift/releases) | Moya의 간접 의존성 | 직접 선언 없음 / 6.7.0 | 7.2.1 | Moya 15.0.3은 6.x만 허용. 호환 6.x 유지, 7.x 강제 추가 금지 |

- [Kingfisher 8.13.0](https://github.com/onevcat/Kingfisher/blob/8.13.0/Package.swift)은 Swift 도구 버전 6.2 이상을 요구한다.
- [SnapKit 6.0.0](https://github.com/SnapKit/SnapKit/blob/6.0.0/Package.swift)은 Swift 도구 버전 6.0, iOS/tvOS 14, macOS 12 이상을 요구한다.
- [Alamofire 5.12.2](https://github.com/Alamofire/Alamofire/blob/5.12.2/Package.swift)는 Swift 도구 버전 6.4, iOS/tvOS 15, macOS 12, watchOS 9 이상을 요구한다. 최신화 시 개발·CI·소비 앱의 도구 버전을 함께 확인한다.
- [Moya 15.0.3 매니페스트](https://github.com/Moya/Moya/blob/15.0.3/Package.swift)의 Alamofire 5.x, RxSwift 6.x, ReactiveSwift 6.x 제약을 존중한다.

### 최신화 절차

1. 현재 `Package.swift`, 로컬 `Package.resolved`, 관련 checkout revision과 소비 앱의 의존성 설정을 확인한다. 오래된 `.build` checkout을 최신 또는 현재 적용 버전으로 간주하지 않는다.
2. 공식 릴리스·마이그레이션 문서·해당 태그의 `Package.swift`에서 안정 버전, 최소 OS·도구 버전, API 변경과 간접 의존성 범위를 확인한다.
3. 변경 목적·후보 버전·영향·대안을 정리한다. 새 의존성·빌드 설정·CI 변경은 승인 후 적용한다. 최신 버전이 iOS 15와 호환되지 않으면 호환 가능한 최신 안정 버전을 제안한다.
4. 승인되거나 요청에 포함된 패키지만 선언 범위·해석 결과를 갱신한다. 의존성 작업과 무관한 빌드에서 전체 패키지 업데이트를 실행하지 않는다.
5. 관련 회귀 테스트, 전체 iOS Simulator 테스트, 필요 시 Debug/Release 빌드를 실행하고 선언 하한·해석 버전·실제 checkout을 대조한다.
6. 적용 버전·확인 날짜·남은 제약을 이 문서에 갱신한다. 실패 시 해당 작업에서 변경한 선언과 해석 결과만 되돌리고 기존 사용자 변경을 보존한다.

현재 `Package.resolved`는 `.gitignore` 대상이다. 임의로 강제 추가하거나 추적 정책을 바꾸지 않는다. 로컬 해석 파일이 없는 환경에서는 `Package.swift`의 범위 안에서 버전이 다시 선택되므로 검증에 사용한 실제 버전도 보고한다.

## 7. 빌드·테스트·검증

저장소 루트에서 실행한다. UIKit을 사용하므로 macOS용 `swift test` 결과를 iOS 검증으로 대신하지 않는다. 먼저 패키지 선언과 의존성의 최소 OS·도구 버전 불일치를 확인하고, 실패 원인을 숨기기 위해 배포 대상을 명령행에서 강제로 덮어쓰지 않는다.

```sh
# 환경과 패키지 scheme 확인
xcodebuild -version
xcrun swift --version
xcodebuild -list -disableAutomaticPackageResolution -skipPackageUpdates

# 테스트 가능한 Simulator 확인: 출력에서 실제 사용 가능한 UDID 선택
xcodebuild -scheme CommonUtils -showdestinations \
  -disableAutomaticPackageResolution -skipPackageUpdates
xcrun simctl list devices available
```

아래 `SIMULATOR_UDID`를 위 출력의 실제 ID로 바꾼다. `CommonUtils` scheme이 출력에 없다면 확인된 scheme을 사용하고 차이를 보고한다. 로컬 해석 파일이 없으면 의도한 버전을 먼저 resolve한 뒤 버전을 기록한다.

```sh
# 변경과 관련된 테스트 먼저 실행: 테스트 클래스는 변경 대상에 맞게 선택
xcodebuild -scheme CommonUtils -configuration Debug \
  -destination 'platform=iOS Simulator,id=SIMULATOR_UDID' \
  -disableAutomaticPackageResolution -skipPackageUpdates \
  -only-testing:CommonUtilsTests/NavigationAppearanceTests test

# 전체 테스트
xcodebuild -scheme CommonUtils -configuration Debug \
  -destination 'platform=iOS Simulator,id=SIMULATOR_UDID' \
  -disableAutomaticPackageResolution -skipPackageUpdates test

# 공개 API·의존성·플랫폼 영향이 있으면 빌드도 확인
xcodebuild -scheme CommonUtils -configuration Release \
  -destination 'generic/platform=iOS' \
  -disableAutomaticPackageResolution -skipPackageUpdates \
  CODE_SIGNING_ALLOWED=NO build

# 변경 파일·공백 오류 확인
git diff --check
git status --short
```

- 성공 기준: 명령 종료 코드 0, 테스트 `TEST SUCCEEDED`, 빌드 `BUILD SUCCEEDED`, 관련 테스트 실패 0건. skip·기존 실패·새 경고는 별도로 보고한다.
- 문서만 바꾼 경우에는 경로·명령 옵션·설정과의 일치, 공백 오류와 변경 범위를 확인한다. 기능을 구현하지 않은 문서 변경에 테스트 코드를 추가하지 않는다.
- OS 분기가 바뀌면 iOS 15 기본 경로와 최신 OS 경로를 각각 검증한다. 해당 실행 환경이 없으면 미검증으로 기록하고 소비 앱에서 확인할 절차를 제시한다.
- UI 변경은 소비 앱에서 색상·동작·메뉴·safe area·스크롤 마지막 콘텐츠를 확인한다. 미디어·공유·TTS 변경은 파일 결과와 실제 재생·공유 동작도 확인한다.
- 의존성 갱신 후 모듈 캐시 오류가 발생하면 별도의 새 `-derivedDataPath`로 검증한다. 전역 캐시나 다른 앱의 빌드 결과를 임의로 삭제하지 않는다.

## 8. Git과 완료 보고

- 사용자의 기존 변경을 되돌리거나 무관한 파일을 stage하지 않는다. 커밋은 요청 또는 승인된 작업 범위에서만 수행한다.
- 새 브랜치가 필요하면 활성 상위 지침의 명명 규칙을 따른다. 한 커밋에는 한 가지 논리적 변경만 담고 기능·포맷·리네이밍을 섞지 않는다.
- 커밋 메시지는 활성 상위 지침과 최근 저장소의 한국어 형식을 따른다: `[YYYYMMDD] 키워드: 내용`. 날짜는 커밋 생성일을 사용한다.
- 최종 보고에는 변경 파일과 이유, 실행한 명령·성공 기준·실제 결과, 미검증 항목, 필요한 경우 변경 부분만 되돌리는 방법을 포함한다.
- 빌드·자동 테스트 성공, 기기·소비 앱 실행 확인, 외부 서비스 확인을 구분하고 마지막에 `git status --short`로 변경 범위를 재확인한다.
