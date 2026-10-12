# CommonUtils

`CommonUtils`는 여러 iOS 앱에서 사용하는 Swift Package 공통 라이브러리입니다. Foundation·UIKit 확장, Combine 이벤트, Moya 네트워크 요청, 이미지 로딩, 영상 압축과 공통 UI 기능을 제공합니다.

이 문서는 1.0.18에 포함할 현재 소스와 설정을 기준으로 작성했습니다. 버전별 변경 내용은 [CHANGELOG.md](CHANGELOG.md)를 참고하세요.

## 주요 기능

| 영역 | 제공 기능 | 관련 소스 |
| --- | --- | --- |
| 타입 확장 | 문자열·날짜·숫자·색상·이미지·뷰·CoreData 등 공통 확장 | [Sources/Extensions](Sources/Extensions) |
| UIKit 이벤트 | 버튼·텍스트필드·스크롤뷰·제스처 등의 Combine publisher | [Sources/CombineCocoa](Sources/CombineCocoa) |
| 네트워크 | Moya 요청 publisher, 응답 디코딩, 상태 코드 오류와 요청·응답 로깅 | [Sources/MoyaNetwork](Sources/MoyaNetwork) |
| 이미지·로딩 UI | Kingfisher 이미지 다운로드·다운샘플링·캐시 설정, ProgressHUD 설정과 표시 | [CommonUtils.swift](Sources/Function/CommonUtils.swift), [UIImageView 확장](Sources/Extensions/UIImageView+Extension.swift) |
| 내비게이션 | 내비게이션바 appearance, iOS 26 시스템 버튼, 아이콘 정렬·메뉴·접근성 라벨 | [CommonNavigationAppearance.swift](Sources/Model/CommonNavigationAppearance.swift) |
| 미디어·기기 유틸 | 영상 정보·압축, MIME 판별, TTS, 한글 초성·자모 처리, 연결 상태 감시 | [Sources/Function](Sources/Function) |
| 로그·공통 뷰 | 파일 로그·ZIP 압축·외부 로그 전달, collection view layout와 padding label | [DebugLoggerManager.swift](Sources/Function/DebugLoggerManager.swift), [Sources/Views](Sources/Views) |

## 요구사항

| 항목 | 현재 기준 |
| --- | --- |
| Swift 도구 버전 | **6.4 이상** (`swift-tools-version: 6.4`) |
| Swift 언어 모드 | **5** (`swiftLanguageModes: [.v5]`) |
| iOS | **15.0 이상** |
| 기타 플랫폼 선언 | macOS 12, tvOS 15, watchOS 9 |
| 기본 지역화 | 한국어 (`defaultLocalization: "ko"`) |
| 제품·소스 대상 / 테스트 대상 | `CommonUtils` / `CommonUtilsTests` |

패키지는 UIKit, Photos, AVFoundation 및 ProgressHUD를 사용합니다. macOS·tvOS·watchOS 버전 선언만으로 해당 플랫폼의 빌드·실행 지원을 보장하지 않으며, 빌드와 테스트는 iOS 대상을 기준으로 확인합니다. macOS에서 실행하는 `swift test`는 iOS Simulator 테스트를 대신할 수 없습니다.

1.0.17에서 갱신하는 소비 앱은 iOS 최소 버전과 Swift 도구 버전을 먼저 확인하세요. 최신 컴파일러를 사용해도 패키지의 Swift 언어 모드는 5로 유지됩니다.

## 설치

### Xcode

1. **File > Add Package Dependencies…**에서 아래 저장소 URL을 입력합니다.
2. 사용할 태그 또는 브랜치를 선택합니다.
3. `CommonUtils` 제품을 앱 대상의 의존성에 추가합니다.

```text
https://github.com/appsstudioio/CommonUtils.git
```

1.0.18 버전으로 설치하려면 해당 태그가 원격 저장소에 게시되어 있어야 합니다. 태그 게시 전에는 검토할 브랜치나 로컬 패키지를 선택하세요.

### Package.swift

소비 패키지에서 사용하는 예시입니다. `AppSupport`는 소비 프로젝트의 실제 대상 이름으로 바꿉니다.

```swift
// swift-tools-version: 6.4
import PackageDescription

let package = Package(
    name: "AppModules",
    platforms: [.iOS(.v15)],
    dependencies: [
        .package(url: "https://github.com/appsstudioio/CommonUtils.git", from: "1.0.18")
    ],
    targets: [
        .target(
            name: "AppSupport",
            dependencies: [.product(name: "CommonUtils", package: "CommonUtils")]
        )
    ]
)
```

앱 소스에서는 `import CommonUtils`로 공개 API를 사용합니다. Moya 등 의존 패키지의 타입을 앱에서 직접 사용할 때는 해당 제품도 소비 대상의 의존성에 연결합니다.

## 의존성

[Package.swift](Package.swift)의 직접 의존성 선언입니다.

| 패키지 | 선언 범위 | 용도 |
| --- | --- | --- |
| [Moya](https://github.com/Moya/Moya) | `15.0.3 ..< 16.0.0` | 네트워크 요청·응답 |
| [SnapKit](https://github.com/SnapKit/SnapKit) | `6.0.0 ..< 7.0.0` | 레이아웃 |
| [Then](https://github.com/devxoul/Then) | `3.0.0 ..< 4.0.0` | 객체 설정 |
| [ProgressHUD](https://github.com/uwiseone-ios/ProgressHUD) | 사내 포크의 `master` | 로딩·진행률 UI |
| [Kingfisher](https://github.com/onevcat/Kingfisher) | `8.13.0 ..< 9.0.0` | 이미지 다운로드·캐시 |
| [ZIPFoundation](https://github.com/weichsel/ZIPFoundation) | `0.9.20 ..< 1.0.0` | 파일 로그 압축 |

2026-10-12 로컬 테스트에서는 Moya 15.0.3, SnapKit 6.0.0, Then 3.0.0, Kingfisher 8.13.0, ZIPFoundation 0.9.20과 ProgressHUD revision `a8b101d905f78178bef45c16122be0f16e54aa40`을 사용했습니다. 간접 의존성은 Alamofire 5.12.2, RxSwift 6.10.2, ReactiveSwift 6.7.0입니다. 실제 선택 버전은 소비 프로젝트의 해석 결과에 따라 달라질 수 있고, 브랜치 의존성은 고정 버전과 달리 이후 커밋을 선택할 수 있습니다.

## 사용 예시

### 문자열·숫자·날짜·한글 처리

날짜나 숫자 출력의 형식이 계약으로 정해져 있다면 locale과 time zone을 명시합니다. 기본값은 현재 환경의 설정을 사용합니다.

```swift
import Foundation
import UIKit
import CommonUtils

let formatted = 1234567.withCommas(Locale(identifier: "en_US_POSIX"))
// "1,234,567"
let phoneNumber = "0212345678".toPhoneNumberFormat()
// "02-1234-5678"
let color = UIColor(hex: "#FF9900")
let initials = HangeulSearch.getCho("한글")
// "ㅎㄱ"

let locale = Locale(identifier: "en_US_POSIX")
let timeZone = TimeZone(secondsFromGMT: 9 * 60 * 60)!
let date = "2024-01-01 15:20:00".toDate(locale: locale, timeZone: timeZone)
let text = date?.toString(format: "yyyy-MM-dd HH:mm", timeZone: timeZone, locale: locale)
// "2024-01-01 15:20"
```

### 이미지 로딩과 캐시

`UIImageView.setUrlImage`는 이전 다운로드를 취소한 뒤 이미지를 요청합니다. `imageResize`를 지정하지 않으면 레이아웃이 완료된 뷰의 크기를 기준으로 다운샘플링합니다. 크기가 아직 0이라면 다운샘플링을 적용하지 않습니다.

```swift
@MainActor
func loadImages(thumbnail: UIImageView, original: UIImageView) {
    thumbnail.setUrlImage(
        "https://example.com/image.jpg",
        placeholder: UIImage(named: "placeholder"),
        imageResize: CGSize(width: 300, height: 300)
    )

    original.setUrlImage(
        "https://example.com/image.jpg",
        skipDownsampling: true,
        isIndicator: false
    )
}
```

`skipDownsampling: true`는 공통 헬퍼의 다운샘플링 적용을 건너뜁니다. 추가 `options`로 전달한 Kingfisher processor까지 제거하지는 않습니다. 재사용 셀에서는 `stopDownloadTask()`로 이미지와 이전 요청을 정리할 수 있습니다.

캐시와 로딩 UI의 공통 설정은 앱 초기화 시 메인 스레드에서 적용합니다. `CommonKingfisherConfig`의 기본값은 메모리 200 MiB·10개, 디스크 2,000 MiB, 디스크 만료 14일, 메모리 만료 300초입니다.

```swift
@MainActor
func configureCommonUI() {
    CommonUtils.kingfisherConfig(
        CommonKingfisherConfig(diskStorageSizeLimit: 500 * 1024 * 1024)
    )
    CommonUtils.progressHUDConfig(CommonProgressHUDConfig(colorStatus: .label))
}
```

### Combine UIKit 이벤트

구독을 유지할 `AnyCancellable`을 보관합니다. UI 변경은 메인 스레드에서 처리하고, 화면이나 기능의 수명이 끝나면 구독을 해제합니다.

```swift
import Combine

@MainActor
final class ExampleViewController: UIViewController {
    private var cancellables = Set<AnyCancellable>()
    private let button = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        button.tapPublisher
            .sink { print("button tapped") }
            .store(in: &cancellables)
    }
}
```

버튼 외에 `UIControl`, `UIBarButtonItem`, `UITextField`, `UIScrollView`, `UISwitch`, `UISlider`, `UIDatePicker`와 제스처 확장이 있습니다.

### 내비게이션바와 iOS 26 시스템 버튼

`CommonNavigationAppearance.isEnabled`의 기본값은 `false`입니다. 앱에서 활성화하면 iOS 26 이상에서 `UIBarButtonItem.createUIBarButtonItem`의 이미지·메뉴 팩토리가 시스템 버튼을 생성합니다. iOS 15~25와 비활성 상태에서는 기존 사용자 지정 버튼 경로를 사용합니다.

```swift
@MainActor
func configureNavigation(_ navigation: UINavigationController, target: Any, action: Selector) {
    CommonNavigationAppearance.isEnabled = true
    CommonNavigationAppearance.buttonTintColor = .label

    navigation.navigationBar.setNavigationBarStyle(
        .systemBackground,
        fontColor: .label,
        font: .systemFont(ofSize: 17, weight: .semibold),
        style: .system
    )

    navigation.topViewController?.navigationItem.rightBarButtonItem =
        UIBarButtonItem.createUIBarButtonItem(
            image: UIImage(systemName: "plus"),
            target: target,
            action: action
        )
}
```

`setNavigationBarStyle`의 기본 스타일은 `.legacy`이며 `.system`, `.customBackground`도 선택할 수 있습니다. appearance의 `style`과 버튼 팩토리의 `isEnabled`는 별도 설정입니다. 시스템 버튼은 `customView`가 nil일 수 있으므로 기존 소비 코드의 강제 캐스팅을 확인하세요. `buttonToBarButtonItem`은 전달받은 `UIButton`을 custom view로 사용하는 API입니다.

`hideNavigationLeftButton(hidden:target:action:)`는 root 또는 내비게이션 컨트롤러가 없는 화면에 닫기 아이콘을, 상세 화면에 뒤로 아이콘을 설정하며 지역화된 접근성 라벨과 전달받은 target/action을 유지합니다. `UIButton.alignTextBelow(spacing:)`는 이미지를 제목 위로 배치할 때 사용합니다.

### Moya 요청과 연결 상태

`MoyaProvider.requestPublisher`는 HTTP 200~299 응답을 전달하고, 그 외 상태 코드는 `NetworkException.errorStatusCode`로 처리합니다. 요청 실패와 응답 변환 오류는 `NetworkException.serverError`로 전달합니다. 응답 publisher에서 `map`, `mapJSON`, `mapString`, `mapImage`와 상태 코드 필터를 사용할 수 있습니다.

```swift
import Moya

func request<Model: Decodable, API: TargetType>(
    _ model: Model.Type,
    target: API,
    provider: MoyaProvider<API>
) -> AnyPublisher<Model, NetworkException> {
    provider.requestPublisher(target)
        .map(model)
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
}
```

앱이 provider와 구독의 수명을 관리합니다. `NetworkConnectivityManager`는 연결 상태 변경을 `networkStatusPublisher`로 제공하며 `startMonitoring()`·`stopMonitoring()`을 지원합니다. 이 publisher는 현재 상태를 재전달하지 않고, `isOnline`의 초기값은 첫 상태 통지 전까지 `true`입니다. 연결 상태는 특정 서버 요청의 성공을 보장하지 않습니다.

### 파일 로그와 외부 이벤트

`DebugLog`는 콘솔 출력(`isDebugPrint`, 기본 `false`), 파일 기록(`isFileLog`, 기본 `true`), 외부 이벤트 전달을 각각 설정할 수 있습니다. 파일에는 `.debug`, `.error`, `.log`, `.trace`, `.critical`, `.fault` 레벨을 기록합니다. 기본 `.info`는 파일에 기록하지 않습니다.

```swift
func configureExternalLogging() {
    DebugLoggerManager.externalLogHandler = { event, _, level, _, _, _, _ in
        // 소비 앱의 로깅 SDK 연결 위치입니다.
        print("\(event): \(level.rawValue)")
    }

    DebugLog(
        "미디어 처리 준비",
        level: .log,
        param: ["stage": "prepare"],
        isDebugPrint: false,
        isFileLog: false,
        externalEventName: "media_prepare"
    )
}
```

처리기는 이벤트 이름, 메시지, 레벨, 파라미터, 파일, 함수, 줄 번호를 호출한 스레드에서 동기적으로 받습니다. `externalEventName`을 지정하면 콘솔·파일 기록을 꺼도 전달되므로, 앱 초기화 시 처리기를 등록하고 필요한 마스킹·전달량 제한을 적용합니다. 인증 정보나 개인정보를 메시지·파라미터에 넣지 않습니다.

파일 로그는 앱의 `Documents/Logs` 아래에 저장하며 파일별 512 KiB, 전체 50 MiB 제한과 오래된 로그 정리를 적용합니다. `DebugLoggerManager.shared.zipLogFiles()`로 로그 ZIP 파일을 만들 수 있고, 반환값이 nil이면 실패한 것입니다.

### 영상 압축

```swift
func compress(inputURL: URL, completion: @escaping (Result<URL, Error>) -> Void) {
    let outputURL = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString)
        .appendingPathExtension("mp4")

    CommonUtils.compressVideo(
        inputURL: inputURL,
        outputURL: outputURL,
        quality: .medium
    ) { result in
        DispatchQueue.main.async { completion(result) }
    }
}
```

압축 품질은 `.low`, `.medium`, `.high`, `.original`입니다. 비디오 트랙이 없는 입력은 `videoTrackNotFound`, 지원하지 않는 오디오 구성은 `unsupportedAudioFormat` 오류를 반환합니다. 다채널 오디오는 유효한 채널 레이아웃과 AAC writer 지원 여부를 확인합니다.

`maxFileSize`는 예상 압축 크기를 기준으로 한 사전 검사이며 실제 결과 파일 크기의 상한을 보장하지 않습니다. 입력과 다른 출력 URL을 사용하고 완료 후 필요 없어진 파일은 호출자가 정리합니다. 완료 콜백의 메인 스레드 전달은 보장하지 않으므로 UI 작업은 예시처럼 메인 큐로 전달합니다.

### TTS와 로딩 UI

```swift
@MainActor
func playGuide() {
    TTSManager.shared.play("안녕하세요", locale: Locale(identifier: "ko_KR"))
}

@MainActor
func updateLoadingUI(progress: CGFloat) {
    showProgressView("처리 중", value: progress)
}
```

TTS 중단은 `TTSManager.shared.stop()`, 로딩 표시는 `showLoadingView`, 닫기는 `dismissLoadingView`를 사용합니다. TTS는 앱의 오디오 세션을 사용하므로 다른 재생 기능과 함께 쓰는 앱에서는 실제 재생·중단 동작을 확인합니다.

## 소스와 리소스 구성

```text
Sources/
  Extensions/       Foundation·UIKit·AVFoundation 등 확장
  Function/         공통 함수, 영상·TTS·로그·연결 상태·MIME·한글 처리
  Model/            설정 모델, 영상 오류·품질, 내비게이션 appearance
  CombineCocoa/     UIKit 이벤트·프로퍼티 publisher와 subscription
  MoyaNetwork/      네트워크 요청 publisher와 logging plugin
  Views/            collection view layout와 PaddingLaebl
  Resources/        지역화 문자열과 이미지
Tests/CommonUtilsTests/
  TestSampleData/   이미지·영상 테스트 샘플
```

`Sources/Resources`와 `Tests/CommonUtilsTests/TestSampleData`는 각 대상에서 SPM 리소스로 처리하며 내부에서 `Bundle.module`로 접근합니다. `ActivityShareItemPreparer`와 `VideoCompressionAudioSettings`는 내부 구현입니다. 공유 파일 준비 유틸은 현재 공개 `showActivityViewController`에 연결되지 않았으므로, 공유 시트 호출이 자동으로 `Data`를 임시 파일로 바꾸지는 않습니다.

## 빌드와 테스트

저장소 루트에서 도구 버전과 실제 사용 가능한 Simulator를 확인합니다.

```sh
xcodebuild -version
xcrun swift --version
xcodebuild -list -disableAutomaticPackageResolution -skipPackageUpdates
xcodebuild -scheme CommonUtils -showdestinations \
  -disableAutomaticPackageResolution -skipPackageUpdates
xcrun simctl list devices available
```

아래 변수에 확인한 UDID를 넣습니다. 기존 해석 결과를 사용하며, 최초 환경에서 의존성이 없으면 먼저 해석하고 실제 선택 버전을 확인합니다.

```sh
SIMULATOR_UDID='사용 가능한 Simulator UDID'

# 내비게이션 회귀 테스트
xcodebuild test -scheme CommonUtils -configuration Debug \
  -destination "platform=iOS Simulator,id=${SIMULATOR_UDID}" \
  -disableAutomaticPackageResolution -skipPackageUpdates \
  -only-testing:CommonUtilsTests/NavigationAppearanceTests \
  CODE_SIGNING_ALLOWED=NO

# 전체 테스트: 영상 통합 테스트 포함
xcodebuild test -scheme CommonUtils -configuration Debug \
  -destination "platform=iOS Simulator,id=${SIMULATOR_UDID}" \
  -disableAutomaticPackageResolution -skipPackageUpdates \
  CODE_SIGNING_ALLOWED=NO

# iOS Release 빌드
xcodebuild build -scheme CommonUtils -configuration Release \
  -destination 'generic/platform=iOS' \
  -disableAutomaticPackageResolution -skipPackageUpdates \
  CODE_SIGNING_ALLOWED=NO
```

성공 기준은 종료 코드 0, `TEST SUCCEEDED` 또는 `BUILD SUCCEEDED`, 관련 테스트 실패 0건입니다. skip은 통과와 구분합니다. 의존성 변경 후 모듈 캐시 오류가 있다면 별도 `-derivedDataPath`와 `-clonedSourcePackagesDirPath`를 지정해 검증하고 다른 작업의 캐시는 삭제하지 않습니다. 영상 테스트 전에는 디스크 여유 공간을 확인합니다.

### 확인된 결과와 CI 제약

2026-10-12에 Xcode 27.0 / Swift 6.4 / iPhone 17 Pro Simulator(iOS 26.2)의 로컬 기본 환경에서 전체 **462개 통과, 실패 0개, skip 0개**를 확인했습니다. iOS 15 실제 실행, 소비 앱의 화면·메뉴·VoiceOver, 공유 시트와 TTS 재생은 별도 검증 항목입니다.

현재 [PR 테스트 워크플로](.github/workflows/pr-tests.yml)는 `macos-15`에서 사용 가능한 첫 iPhone Simulator를 선택합니다. 기본 job은 영상 통합 테스트 3개를 제외하고, 해당 테스트는 수동 실행 또는 PR의 `run-video-compression-tests` 라벨이 있을 때 별도 job으로 실행합니다.

| 실패 조건 | 현재 확인한 내용 | 필요한 확인·대응 |
| --- | --- | --- |
| Swift 도구 버전 부족 | 워크플로에 명시적 Xcode 선택이 없고 패키지는 Swift 6.4 이상을 요구 | runner의 `xcodebuild -version`, `xcrun swift --version` 확인 후 호환 Xcode 선택 |
| 영어 locale | `test_dateFormatChange_withDifferentFormat`이 한국어 월 이름을 고정 기대값으로 사용하며 영어/미국 실행에서 실패 재현 | 테스트가 의도한 locale을 명시하거나 현재 locale에 맞춘 기대값으로 검증 |
| KST와 현재 시간대의 차이 | 일부 Date 테스트는 KST 입력을 만든 뒤 기본 `.current` 시간대로 변환 | 테스트 입력·변환·기대값의 time zone을 일치시키기 |
| 저장 공간 부족·영상 처리 제한 | 압축 테스트는 샘플 읽기, 임시 영상 쓰기와 인코더 실행이 필요 | 디스크·샘플·writer 오류를 확인하고 테스트가 만든 파일 정리 |
| Simulator 차이 | 선택하는 기기·OS 버전을 고정하지 않음 | 실패한 실행의 실제 UDID·OS를 기록하고 같은 대상으로 재현 |

영어/미국 설정에서도 내비게이션 테스트 11개는 통과했습니다. 위 CI·locale·time zone 제약을 해결하는 소스나 워크플로 변경은 이번 문서 갱신에 포함하지 않았습니다.

## 릴리즈와 기여

[릴리즈 워크플로](.github/workflows/release.yml)는 `1.2.3` 또는 `v1.2.3` 형식의 태그 push를 계기로 GitHub Release를 생성합니다. `CHANGELOG.md`의 `## [1.2.3] - YYYY-MM-DD` 섹션을 본문으로 사용하며, 해당 섹션이 없으면 GitHub 자동 생성 노트를 사용합니다. 릴리즈 job 자체는 빌드·테스트를 실행하지 않으므로 태그 게시 전에 위 검증을 마칩니다.

[PR 본문 워크플로](.github/workflows/pr-description.yml)는 커밋 메시지를 기준으로 PR 내용을 갱신합니다. 공통 API를 변경할 때는 소비 앱의 동작과 iOS 15 호환성을 함께 확인하고, 정상·경계·실패 경로의 테스트를 추가합니다. 상세 작업·검증 기준은 [AGENTS.md](AGENTS.md)를 참고하세요.

## 라이선스

MIT 라이선스를 따릅니다. 자세한 내용은 [LICENSE](LICENSE)를 참고하세요.
