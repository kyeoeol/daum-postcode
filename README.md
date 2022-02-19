# Daum PostCode Service
Daum 우편번호 서비스를 이용해 쉽고 간편하게 우편번호 검색, 도로명 주소 입력 기능 만들기

<image src="https://user-images.githubusercontent.com/80438047/154786539-53ee9551-1cdd-4f66-8006-82d48478e0cb.gif" height="400">

<br>
  
***
  
<br>

## Settings
### 로컬 서버로 확인하기 위해 필요한 설정
**info.plist**
```swift
<key>NSAppTransportSecurity</key>
<dict>
	<key>NSAllowsArbitraryLoadsInWebContent</key>
	<true/>
</dict>
```
**node 설치 & serve 설치**
```
$ brew update
$ brew install node
$ npm -g install serve
```
