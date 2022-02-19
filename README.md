# Daum PostCode Service
Daum 우편번호 서비스를 이용해 쉽고 간편하게 우편번호 검색, 도로명 주소 입력 기능 만들기

<image src="https://user-images.githubusercontent.com/80438047/154786539-53ee9551-1cdd-4f66-8006-82d48478e0cb.gif" height="400">

<br>
  
***
  
<br>

## Settings
### 로컬 서버로 확인하기 위해 필요한 설정
* **info.plist**
```swift
<key>NSAppTransportSecurity</key>
<dict>
	<key>NSAllowsArbitraryLoadsInWebContent</key>
	<true/>
</dict>
```
* **node 설치 & serve 설치**
```
$ brew update
$ brew install node
$ npm -g install serve
```

<br>
<br>
	
## Model
```swift
struct PostCode {
    static var zipcode: String?
    static var adderss: String?
}
```
	
## MainViewController
* **주소필드 & 주소검색 버튼 UI**
```swift
@IBOutlet weak var zipcodeField: UITextField!
@IBOutlet weak var addressField: UITextField!
@IBOutlet weak var detailAddressField: UITextField!
@IBOutlet weak var searchPostcodeButton: UIButton!
```
	
* **(샘플용) viewController가 나타날 때마다 모델에서 주소값을 가져와 textField에 적용**
```swift
/// 실제로 사용할 때에는 다양한 방법으로 이용
override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    zipcodeField.text = PostCode.zipcode
    addressField.text = PostCode.adderss
}
```
