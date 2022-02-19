//
//  PostCodeViewController.swift
//  daum-postcode
//
//  Created by haanwave on 2022/02/19.
//

import UIKit
import WebKit

private let localUrl = URL(string: "http://172.30.1.22:3000/postcode.html")!
private let postCodeRuquest = URLRequest(url: localUrl)

class PostCodeViewController: UIViewController {
    @IBOutlet weak var webViewContainerView: UIView!
    
    private var webView: WKWebView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureWebView()
    }
    
    @IBAction func tapCloseButton(_ sender: UIButton) {
        dismiss(animated: true)
    }
}

// MARK: - WKScriptMessageHandler
extension PostCodeViewController: WKScriptMessageHandler {
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
}

// MARK: - Configure
private extension PostCodeViewController {
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
}
