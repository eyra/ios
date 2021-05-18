//
//  ScriptWrapper.swift
//  NativeDemo
//
//  Created by Emiel van der Veen on 18/05/2021.
//

import WebKit

class ScriptWrapper {

    enum Function: String {
        case screenIsPopped
        case modalIsPopped
        
        func toScript() -> String {
            "\(self.rawValue)()"
        }
    }
    
    let webView: WKWebView
    
    init(webView: WKWebView) {
        self.webView = webView
    }
    
    @objc func screenIsPopped() {
        execute(function: .screenIsPopped)
    }
    
    @objc func modalIsPopped() {
        execute(function: .modalIsPopped)
    }
    
    func execute(function: Function) {
        webView.evaluateJavaScript(function.toScript()) { (_, error) in
            if let error = error {
                print("Failed to execute script function '\(function.toScript())': \(error.localizedDescription)")
            }
        }
    }
}
