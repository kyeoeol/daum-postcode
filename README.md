# Daum PostCode Service
Daum 우편번호 서비스를 이용해 쉽고 간편하게 우편번호 검색, 도로명 주소 입력 기능 만들기 <br>

<image src="https://user-images.githubusercontent.com/80438047/154786539-53ee9551-1cdd-4f66-8006-82d48478e0cb.gif" height="400">

**요약**
> 1. 우편번호 검색 페이지 생성
> 2. webView를 이용해 페이지 load
> 3. WKUserContentController & WKScriptMessageHandler를 이용해 해당 페이지로 부터 우편번호 & 주소 받아오기
> 4. 입력할 textField에 적용

⚠️ **Daum 우편번호 서비스를 앱에서 사용하려면 webView 및 브라우저를 사용해야 한다.** <br>

⚠️ **Daum 우편번호 서비스는 인터넷이 가능한 환경에서 동작한다.** (html을 로컬 파일로 두고 사용할 수 없다.)

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
	
* **로컬서버**
  * postcode.html 이 있는 경로에서 ``$ serve .`` 실행
  * 아래 이미지에 표시된 영역에 나오는 주소를 이용해 webView load
  * ex. ``http://000.000.0.00:300/postcode.html``
<image src="https://user-images.githubusercontent.com/80438047/154787236-9b4be9f1-6f0a-4783-b081-6b0ecd0549bd.png">

<br>
<br>
	
## Model
```swift
struct PostCode {
    static var zipcode: String?
    static var adderss: String?
}
```
	
<br>
<br>
	
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

<br>
<br>

## PostCodeViewController
* **webView 설정**
```swift
func configureWebView() {
    /// WKWebViewConfiguration
    let configuration = WKWebViewConfiguration()
    configuration.preferences = WKPreferences()
    configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
    if #available(iOS 14, *) {
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true
    }
    else {
        configuration.preferences.javaScriptEnabled = true
    }
    /// WKUserContentController
    let contentController = WKUserContentController()
    contentController.add(self,
		    	  name: "callbackHandler")
    configuration.userContentController = contentController
    /// WKWebView
    webView = WKWebView(frame: .zero,
			configuration: configuration)
    /// add if needed
//        webView?.uiDelegate = self
//        webView?.navigationDelegate = self

    /// add webView To container
    if let webView = webView {
        webViewContainerView.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.topAnchor.constraint(equalTo: webViewContainerView.topAnchor).isActive = true
        webView.leadingAnchor.constraint(equalTo: webViewContainerView.leadingAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: webViewContainerView.bottomAnchor).isActive = true
        webView.trailingAnchor.constraint(equalTo: webViewContainerView.trailingAnchor).isActive = true
    }

    /// load
    webView?.load(postCodeRuquest)
}
```
* **WKScriptMessageHandler**
```swift
func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
    print("--->[PostCodeViewController:userContentController] message name:", message.name)

    if message.name == "callbackHandler" {
        print("--->[PostCodeViewController:userContentController] message body:", message.body)
	guard let postCode = message.body as? [String: String] else { return }
	guard let zipcode = postCode["zipcode"],
            let address = postCode["address"] else { return }

	    print("--->[postcode] zipcode:\(zipcode), address:\(address)")
	    PostCode.zipcode = zipcode
	    PostCode.adderss = address

	    dismiss(animated: true)
    }
}
```

<br>
<br>
	
## postcode.html
우편번호 검색 페이지<br>	
**참고:** <a href="https://postcode.map.daum.net/guide#usage">Daum 우편번호 가이드</a>

```swift
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>daum postcode</title>
</head>
<body onload="openDaumPostcode()">
    
    <div id="wrap" style="width:99%;height:auto;"></div>
    
    <script src="//t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>
    <script>
        function sendPostCode(address) {
            window.webkit.messageHandlers.callbackHandler.postMessage(address);
        }
        
        // 우편번호 찾기 찾기 화면을 넣을 element
        var element_wrap = document.getElementById('wrap');
        
        function openDaumPostcode() {
            new daum.Postcode({
                oncomplete: function(data) {
                    // 검색결과 항목을 클릭했을때 실행할 코드를 작성하는 부분.
                    
                    // 각 주소의 노출 규칙에 따라 주소를 조합한다.
                    // 내려오는 변수가 값이 없는 경우엔 공백('')값을 가지므로, 이를 참고하여 분기 한다.
                    var zipcode = data.zonecode
                    var addr = ''; // 주소 변수
                    var extraAddr = ''; // 참고항목 변수
                    
                    //사용자가 선택한 주소 타입에 따라 해당 주소 값을 가져온다.
                    if (data.userSelectedType === 'R') { // 사용자가 도로명 주소를 선택했을 경우
                        addr = data.roadAddress;
                    } else { // 사용자가 지번 주소를 선택했을 경우(J)
                        addr = data.jibunAddress;
                    }
                    
                    // 사용자가 선택한 주소가 도로명 타입일때 참고항목을 조합한다.
                    if(data.userSelectedType === 'R'){
                        // 법정동명이 있을 경우 추가한다. (법정리는 제외)
                        // 법정동의 경우 마지막 문자가 "동/로/가"로 끝난다.
                        if(data.bname !== '' && /[동|로|가]$/g.test(data.bname)){
                            extraAddr += data.bname;
                        }
                        // 건물명이 있고, 공동주택일 경우 추가한다.
                        if(data.buildingName !== '' && data.apartment === 'Y'){
                            extraAddr += (extraAddr !== '' ? ', ' + data.buildingName : data.buildingName);
                        }
                        // 표시할 참고항목이 있을 경우, 괄호까지 추가한 최종 문자열을 만든다.
                        if(extraAddr !== ''){
                            extraAddr = ' (' + extraAddr + ')';
                        }
                    }
                    
                    var myAddress = {
                        "zipcode": zipcode,
                        "address": addr + extraAddr
                    };
                    sendPostCode(myAddress)
                },
                onresize : function(size) {
                    element_wrap.style.height = size.height+'px';
                },
                width : '100%',
                height : '100%'
            }).embed(element_wrap, {
                autoClose: false
            });
            
            // iframe을 넣은 element를 보이게 한다.
            element_wrap.style.display = 'block';
        }
    </script>
</body>
</html>
```
