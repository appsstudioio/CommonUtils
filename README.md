# CommonUtils

`CommonUtils`는 iOS 개발을 위한 유용한 유틸리티 함수와 확장 기능을 모아놓은 Swift 패키지입니다.  
이 패키지는 코드의 재사용성을 높이고, 개발 시간을 단축하는 데 도움을 줍니다.
<br><br>

## 🔧 특징

- 다양한 범용 유틸리티 함수 제공
- Swift 5 이상 지원
- Swift Package Manager(SPM)를 통한 간편한 통합 
<br><br>

## 📦 설치 방법 (Installation)

### Xcode를 통한 설치

1. Xcode에서 프로젝트를 열고, 메뉴에서 **File > Add Packages...** 를 선택합니다.
2. 다음 저장소 URL을 입력합니다: https://github.com/appsstudioio/CommonUtils.git
3. 버전을 선택하고 **Add Package** 를 클릭하여 설치를 완료합니다.

### Package.swift를 통한 설치
````swift
dependencies: [
 .package(url: "https://github.com/appsstudioio/CommonUtils.git", from: "1.0.0")
]
````
그리고 필요한 타겟에 CommonUtils를 추가합니다:
````swift
targets: [
    .target(
        name: "YourTargetName",
        dependencies: ["CommonUtils"]
    )
]
````
<br>

## 💡 사용 예시

````swift
import CommonUtils

// 예: 문자열에 이모지가 있는지
let emoji = "Hello world 😄"
if emoji.isEmoji {
    print("이모지가 있습니다.")
}

// 예: 날짜 포맷 변환
let dateString = "2024/04/15"
if let date = dateString.toDate(format: "yyyy-MM-dd") {
    print("변환된 날짜: \(date)")
}

// 예: 색상을 Hex 코드로 변경
let color = UIColor(red: 1, green: 0.5, blue: 0, alpha: 1)
print("\(color.toHex(isAlpha: false))")
````
<br>

## 🤝 기여 방법

기여를 환영합니다!
이슈를 등록하거나 Pull Request를 통해 개선사항을 제안해주세요.
<br><br>

## 📄 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다.
자세한 내용은 LICENSE 파일을 참고해주세요.
