# CommonUtils

`CommonUtils`는 iOS 앱 개발에서 반복적으로 사용하는 확장 함수, UI 헬퍼, 네트워크 유틸, 미디어 처리 기능을 모아둔 Swift Package입니다.

## 주요 기능

- `String`, `Int`, `Date`, `UIColor`, `UIImage`, `UIView` 등 Foundation/UIKit 타입 확장
- Combine 기반 UIKit control event/control property publisher
- Moya 기반 네트워크 provider 및 logging helper
- Kingfisher 기반 이미지 로딩 helper와 ProgressHUD wrapper
- 비디오 정보 추출, 비디오 압축, MIME 타입 판별, TTS, 한글 검색 유틸
- collection view layout, padding label 등 공통 UI 컴포넌트

## 요구사항

- Swift tools version: `5.10`
- Swift language version: `5`
- iOS 13.0+
- macOS 10.15+
- tvOS 13.0+
- watchOS 6.0+

> 이 패키지는 UIKit 기반 기능과 `ProgressHUD` 의존성이 포함되어 있어 실제 테스트/빌드는 iOS 대상에서 검증하는 것을 권장합니다.

## 의존성

| 패키지 | 버전 범위 |
| --- | --- |
| Moya | `15.0.3 ..< 16.0.0` |
| SnapKit | `5.7.1 ..< 6.0.0` |
| Then | `3.0.0 ..< 4.0.0` |
| ProgressHUD | `14.1.4 ..< 15.0.0` |
| Kingfisher | `8.10.0 ..< 9.0.0` |
| ZIPFoundation | `0.9.20 ..< 1.0.0` |

## 설치

### Xcode

1. Xcode에서 프로젝트를 엽니다.
2. **File > Add Packages...** 를 선택합니다.
3. 저장소 URL을 입력합니다.

```text
https://github.com/appsstudioio/CommonUtils.git
```

4. 사용할 버전을 선택한 뒤 `CommonUtils`를 앱 타겟에 추가합니다.

### Package.swift

```swift
dependencies: [
    .package(url: "https://github.com/appsstudioio/CommonUtils.git", from: "1.0.0")
]
```

```swift
targets: [
    .target(
        name: "YourTargetName",
        dependencies: ["CommonUtils"]
    )
]
```

## 사용 예시

```swift
import CommonUtils
import UIKit

let formatted = 1234567.withCommas()
print(formatted) // 1,234,567

let phoneNumber = "0212345678".toPhoneNumberFormat()
print(phoneNumber) // 02-1234-5678

let color = UIColor(hex: "#FF9900")
print(color?.toHex(isAlpha: false) ?? "")
```

### 이미지 로딩

```swift
imageView.setImage(
    "https://example.com/image.jpg",
    placeholder: UIImage(named: "placeholder"),
    imageResize: CGSize(width: 300, height: 300)
)
```

원본 크기 캐시/표시가 필요하면 다운샘플링을 건너뛸 수 있습니다.

```swift
imageView.setImage(
    "https://example.com/image.jpg",
    skipDownsampling: true
)
```

### Combine UIKit 이벤트

```swift
button.tapPublisher
    .sink {
        print("button tapped")
    }
    .store(in: &cancellables)
```

## 테스트

로컬에서 iOS 빌드를 확인하려면 다음 명령을 사용합니다.

```bash
xcodebuild -scheme CommonUtils -destination generic/platform=iOS build
```

테스트는 iOS Simulator 대상에서 실행합니다.

```bash
xcodebuild test -scheme CommonUtils -destination 'platform=iOS Simulator,name=iPhone 16'
```

Pull Request가 열리거나 갱신되면 GitHub Actions가 사용 가능한 iPhone 시뮬레이터를 선택해 테스트를 실행합니다. PR 본문은 커밋 메시지를 기준으로 자동 갱신됩니다.

## 릴리즈

버전 태그를 push하면 GitHub Release가 자동으로 생성됩니다. 태그는 `1.2.3` 또는 `v1.2.3` 형식을 사용할 수 있습니다.

```bash
git tag 1.2.3
git push origin 1.2.3
```

릴리즈 노트를 직접 관리하려면 `CHANGELOG.md`에 아래 형식으로 섹션을 추가합니다.

```markdown
## [1.2.3] - 2026-06-23

- 변경 내용 1
- 변경 내용 2
```

태그와 같은 버전 섹션이 있으면 해당 내용을 릴리즈 본문으로 사용하고, 없으면 GitHub의 자동 생성 릴리즈 노트를 사용합니다.

## 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다. 자세한 내용은 [LICENSE](LICENSE)를 참고하세요.
