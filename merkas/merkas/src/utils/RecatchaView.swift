//
//  RecatchaView.swift
//  merkas
//
//  Created by sistemas on 13/05/26.
//

import SwiftUI
import WebKit

struct RecatchaView: UIViewRepresentable {
    
    var onTokenReceived: (String) -> Void
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onTokenReceived: onTokenReceived)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.userContentController.add(context.coordinator, name: "recaptchaToken")
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.isHidden = true
        
        if let url = URL(string: "\(baseURL)/recaptcha.php") {
            let request = URLRequest(url: url)
            webView.load(request)
        }
        
        
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
    
    class Coordinator: NSObject, WKScriptMessageHandler {
        var onTokenReceived: (String) -> Void
        
        init(onTokenReceived: @escaping (String) -> Void) {
            self.onTokenReceived = onTokenReceived
        }
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "recaptchaToken", let token = message.body as? String {
                print("recatcha token" , token)
                onTokenReceived(token)
            }
        }
    }
}

        
         
        
       
