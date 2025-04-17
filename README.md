# CommonUtils

`CommonUtils`는 iOS 개발을 위한 유용한 유틸리티 함수와 확장 기능을 모아놓은 Swift 패키지입니다.  
이 패키지는 코드의 재사용성을 높이고, 개발 시간을 단축하는 데 도움을 줍니다.

## 🔧 특징

- 다양한 범용 유틸리티 함수 제공
- Swift 5 이상 지원
- Swift Package Manager(SPM)를 통한 간편한 통합

## 📦 설치 방법

### Xcode를 통한 설치

1. Xcode에서 프로젝트를 열고, 메뉴에서 **File > Add Packages...** 를 선택합니다.
2. 다음 저장소 URL을 입력합니다: https://github.com/appsstudioio/CommonUtils.git
3. 버전을 선택하고 **Add Package** 를 클릭하여 설치를 완료합니다.

### Package.swift를 통한 설치

```swift
dependencies: [
 .package(url: "https://github.com/appsstudioio/CommonUtils.git", from: "1.0.0")
]

그리고 필요한 타겟에 CommonUtils를 추가합니다:
```swift
targets: [
    .target(
        name: "YourTargetName",
        dependencies: ["CommonUtils"]
    )
]

💡 사용 예시
```swift
import CommonUtils

// 예: 문자열이 비어있는지 확인
let text = ""
if text.isBlank {
    print("텍스트가 비어 있습니다.")
}

// 예: 날짜 포맷 변환
let dateString = "2025-04-17"
if let date = dateString.toDate(format: "yyyy-MM-dd") {
    print("변환된 날짜: \(date)")
}

// 예: 디바이스 정보 출력
print("디바이스 모델: \(DeviceInfo.modelName)")
print("iOS 버전: \(DeviceInfo.systemVersion)")


🤝 기여 방법

기여를 환영합니다!
이슈를 등록하거나 Pull Request를 통해 개선사항을 제안해주세요.

📄 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다.
자세한 내용은 LICENSE 파일을 참고해주세요.
